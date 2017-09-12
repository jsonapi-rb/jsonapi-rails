### Added

* Configurable logger and logsubscriber for instrumented events.
* Default configuration and hooks for the `meta` parameter.
* Default configuration and hooks for the `cache` parameter.
* Default configuration and hooks for the `links` parameter.
* Default configuration and hooks for the `fields` parameter.
* Default configuration and hooks for the `include` parameter.

# v0.3.1

### Fixed

* Broken default inferrer.
* Broken initializer generator.

# v0.3.0

### Added

* Default configuration and hooks for the `class` parameter (for resources and
    errors).
* Default configuration and hooks for the `expose` parameter.
* Default configuration and hooks for the `jsonapi_object` parameter.
* Default configuration and hooks for pagination links.
* Support for errors rendering.
  * Automatic `ActionController::Errors` serialization.
* Add configuration and initializer generator (`$ rails g jsonapi:initializer`).
* Fragment caching.
* Deserialization reverse-mapping available in controller via
    `jsonapi_pointers`.

### Changed

* `class` renderer parameter now always takes a hash/lambda.
* Rename `JSONAPI::Rails::ActionController` to `JSONAPI::Rails::Controller`.

### Removed

* `namespace` and `inferrer` renderer parameter.

# v0.2.1

# v0.2.0

# v0.1.2

# v0.1.1
