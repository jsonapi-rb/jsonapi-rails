require 'rails/railtie'

require 'jsonapi/rails/filter_media_type'
require 'jsonapi/rails/log_subscriber'
require 'jsonapi/rails/renderer'

module JSONAPI
  module Rails
    # @private
    class Railtie < ::Rails::Railtie
      MEDIA_TYPE = 'application/vnd.api+json'.freeze
      PARSER = lambda do |body|
        data = JSON.parse(body)
        hash = { _jsonapi: data }

        hash.with_indifferent_access
      end
      RENDERERS = {
        jsonapi:        SuccessRenderer.new,
        jsonapi_errors: ErrorsRenderer.new
      }.freeze

      initializer 'jsonapi-rails.init' do |app|
        register_mime_type
        register_parameter_parser
        register_renderers
        ActiveSupport.on_load(:action_controller) do
          require 'jsonapi/rails/controller'
          include ::JSONAPI::Rails::Controller
        end

        app.middleware.use FilterMediaType
      end

      private

      def register_mime_type
        Mime::Type.register(MEDIA_TYPE, :jsonapi)
      end

      def register_parameter_parser
        if ::Rails::VERSION::MAJOR >= 5
          ActionDispatch::Request.parameter_parsers[:jsonapi] = PARSER
        else
          ActionDispatch::ParamsParser::DEFAULT_PARSERS[Mime[:jsonapi]] = PARSER
        end
      end

      # rubocop:disable Metrics/MethodLength
      def register_renderers
        ActiveSupport.on_load(:action_controller) do
          RENDERERS.each do |name, renderer|
            ::ActionController::Renderers.add(name) do |resources, options|
              # Renderer proc is evaluated in the controller context.
              headers['Content-Type'] = Mime[:jsonapi].to_s

              ActiveSupport::Notifications.instrument(
                'render.jsonapi-rails',
                resources: resources,
                options: options
              ) do
                # Depending on whether or not a valid cache object is present
                # in the options, the #render call below will return two
                # slightly different kinds of hash.
                #
                # Both hashes have broadly the following structure, where r is
                # some representation of a JSON::API resource:
                #
                # {
                #   data: [ r1, r2, r3 ],
                #   meta: { count: 12345 },
                #   jsonapi: { version: "1.0" }
                # }
                #
                # For non-cached calls to this method, the `data` field in the
                # return value will contain an array of Ruby hashes.
                #
                # For cached calls, the `data` field will contain an array of
                # JSON strings corresponding to the same data. This happens
                # because jsonapi-renderer caches both the JSON serialization
                # step as well as the assembly of the relevant attributes into
                # a JSON::API-compliant structure. Those JSON strings are
                # created via calls to `to_json`. They are then wrapped in
                # CachedResourcesProcessor::JSONString. This defines a
                # `to_json` method which simply returns self, ie - it attempts
                # to ensure that any further `to_json` calls result in no
                # changes.
                #
                # That isn't what happens in a Rails context, however. Below,
                # the last step is to convert the entire output hash of the
                # renderer into a JSON string to send to the client. If we
                # call `to_json` on the cached output, the already-made JSON
                # strings in the `data` field will be converted again,
                # resulting in malformed data reaching the client. This happens
                # because the ActiveSupport `to_json` takes precedent, meaning
                # the "no-op" `to_json` definition on JSONString never gets
                # executed.
                #
                # We can get around this by using JSON.generate instead, which
                # will use the `to_json` defined on JSONString rather than the
                # ActiveSupport one.
                #
                # However, we can't use JSON.generate on the non-cached output.
                # Doing so means that its `data` field contents are converted
                # with a non-ActiveSupport `to_json`. This means cached and
                # non-cached responses have subtle differences in how their
                # resources are serialized. For example:
                #
                # x = Time.new(2021,1,1)
                #
                # x.to_json
                # => "\"2021-01-01T00:00:00.000+00:00\""
                #
                # JSON.generate x
                # => "\"2021-01-01 00:00:00 +0000\""
                #
                # The different outputs mean we need to take different
                # approaches when converting the entire payload into JSON,
                # hence the check below.
                jsonapi_hash = renderer.render(resources, options, self)

                if jsonapi_hash[:data]&.first&.class == JSONAPI::Renderer::CachedResourcesProcessor::JSONString
                  JSON.generate jsonapi_hash
                else
                  jsonapi_hash.to_json
                end
              end
            end
          end
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
