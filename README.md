# Yell::Adapters::Logstash

LogStash adapter for Yell.

Currently implements a `:file` like adapter (`:logstash_file`), that writes a JSON formatted file that can be transported to LogStash server.

## Installation

Add this line to your application's Gemfile:

    gem 'yell-adapters-logstash', github: 'aupeo/yell-adapters-logstash'

And then execute:

    $ bundle

## Usage

Use the `:logstash_file` adapter in your config as described in the [yell wiki](https://github.com/rudionrails/yell/wiki).

Adapter accepts following options:

- `:filename` string; defaults to `logstash_{environment}.log`.
- `:sync` boolean; defaults to `true`.
- `:level` string; log level (check [yell wiki](https://github.com/rudionrails/yell/wiki) for this one).

The adapter will generate a separate JSON formatted log file that you can transport to the LogStash server.
If there is a `log` directory present, file will be stored in it.

If you are using `yell-rails`, you just need to add another entry to your `yell.yml`

    :adapters:
        - :file:
            :level: 'gte.debug'
        - :logstash_file:
            :level: 'gte.debug'

More details in [yell wiki](https://github.com/rudionrails/yell/wiki): Configuration with YAML.

Based on the `:file` adapter, and inspired by `:gelf` and `:fluentd`.

### Custom Fields/Tags

Also, included in the gem there is a `ControllerFilters` class, that you can use in Rails as a `before_action` filter to capture more/custom fields.

    class ApplicationController < ActionController::Base
        before_action Yell::Adapters::Logstash::ControllerFilters
    end

To override the default provided fields just define the `yell_adapter_logstash_fields` and/or `yell_adapter_logstash_tags` in your controller and return the appropriate hash of fields. The `before()` action of the filter class checks for them before using the defaults.

    class ApplicationController < ActionController::Base
        before_action Yell::Adapters::Logstash::ControllerFilters
        
        def yell_adapter_logstash_fields(controller)
            {
                'controller' => controller.class.name
            }
        end
        
        def yell_adapter_logstash_tags(controller)
            {
                'environment' => Rails.env
            }
        end
    end

Based on this class, you can derive your own for other type of filters; or other type of objects/purposes. The hash of fields/tags is stored in `Thread.current` and retrieved by the adapter. This provides a somehow cleaner way to do this without interfering with Rails internals. 

## Contributing

1. Fork it ( https://github.com/[my-github-username]/yell-adapters-logstash/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
