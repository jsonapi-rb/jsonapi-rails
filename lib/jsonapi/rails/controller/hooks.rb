require 'jsonapi/rails/configuration'

module JSONAPI
  module Rails
    module Controller
      extend ActiveSupport::Concern

      # Hooks for customizing rendering default options at controller-level.
      module Hooks
        # Hook for serializable class mapping (for resources).
        # Overridden by the `class` renderer option.
        # @return [Hash{Symbol=>Class}]
        def jsonapi_class
          JSONAPI::Rails.config[:jsonapi_class].dup
        end

        # Hook for serializable class mapping (for errors).
        # Overridden by the `class` renderer option.
        # @return [Hash{Symbol=>Class}]
        def jsonapi_errors_class
          JSONAPI::Rails.config[:jsonapi_errors_class].dup
        end

        # Hook for the jsonapi object.
        # Overridden by the `jsonapi_object` renderer option.
        # @return [Hash,nil]
        def jsonapi_object
          JSONAPI::Rails.config[:jsonapi_object]
        end

        # Hook for default exposures.
        # @return [Hash]
        def jsonapi_expose
          instance_exec(&JSONAPI::Rails.config[:jsonapi_expose])
        end

        # Hook for default cache.
        # @return [#fetch_multi]
        def jsonapi_cache
          instance_exec(&JSONAPI::Rails.config[:jsonapi_cache])
        end

        # Hook for default fields.
        # @return [Hash{Symbol=>Array<Symbol>},nil]
        def jsonapi_fields
          instance_exec(&JSONAPI::Rails.config[:jsonapi_fields])
        end

        # Hook for default includes.
        # @return [IncludeDirective]
        def jsonapi_include
          instance_exec(&JSONAPI::Rails.config[:jsonapi_include])
        end

        # Hook for default links.
        # @return [Hash]
        def jsonapi_links
          instance_exec(&JSONAPI::Rails.config[:jsonapi_links])
        end

        # Hook for default meta.
        # @return [Hash,nil]
        def jsonapi_meta
          instance_exec(&JSONAPI::Rails.config[:jsonapi_meta])
        end

        # Hook for pagination scheme.
        # @return [Hash]
        def jsonapi_pagination(resources)
          instance_exec(resources, &JSONAPI::Rails.config[:jsonapi_pagination])
        end
      end
    end
  end
end
