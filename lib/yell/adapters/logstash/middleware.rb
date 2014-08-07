module Yell
  module Adapters
    module Logstash
      class Middleware

        def initialize(app)
          @app = app
        end

        def call(env)
          Yell::Adapters::Logstash::ControllerFilters.reset
          @app.call(env)
        end

      end
    end
  end
end