module Hypersonic
  module Rspec
    module Rspec3
      class Formatter
        attr_reader :test_graph

        def initialize(*args)
          @test_graph = TestGraph.new
          @stack = [@test_graph]
        end

        def example_group_started(notification)
          name = notification.group.metadata[:description]
          debug(notification, name: name)
          suite = TestSuite.new(name)
          current_element.children << suite
          @stack << suite

          suite.start
        end

        def example_group_finished(notification)
          name = notification.group.metadata[:description]
          suite = @stack.pop
          debug(notification, name: suite.name)
          suite.stop
        end

        def example_started(notification)
          debug(notification)
          spec = TestCase.new
          @current_spec = spec
          current_element.children << spec
          spec.start
        end

        def example_failed(notification)
          debug(notification)
          @current_spec.fail!(notification.example.description)
        end

        def example_passed(notification)
          debug(notification)
          @current_spec.pass!(notification.example.description)
        end

        def example_pending(notification)
          debug(notification)
          @current_spec.pending!(notification.example.description)
        end

        def start(notification)
          debug(notification, name: "Suite")
          @test_graph.start
        end

        def stop(notification)
          debug(notification, name: "Suite")
          @test_graph.stop

          to_metric.save
        end

        def to_metric
          Publisher.new(@test_graph).to_metric
        end

        private

        def debug(notification, name: notification.example.description)
          return unless ENV['HYPERSONIC_DEBUG']
          method = caller[0]
          puts "#{method} #{name}"
        end

        def current_element
          @stack.last
        end
      end

      # Documented at http://www.rubydoc.info/gems/rspec-core/RSpec/Core/Formatters/Protocol#example_group_started-instance_method
      #::RSpec::Core::Formatters.register Formatter,
      #  :example_group_started,
      #  :example_group_finished,
      #  :example_started,
      #  :example_passed,
      #  :example_failed,
      #  :example_pending,
      #  :stop,
      #  :start
    end
  end
end
