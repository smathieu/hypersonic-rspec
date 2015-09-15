module Hypersonic
  module Rspec
    module Rspec3
      class Formatter
        def initialize(*args)
          @test_graph = TestGraph.new
          @stack = [@test_graph]
        end

        def example_group_started(notification)
          name = notification.group.metadata[:description]
          suite = TestSuite.new(name)
          current_element.children << suite
          @stack << suite

          suite.start
        end

        def example_group_finished(notification)
          name = notification.group.metadata[:description]
          suite = @stack.pop
          suite.stop
        end

        def example_started(notification)
          spec = TestCase.new(notification.example.description)
          @current_spec = spec
          current_element.children << spec
          spec.start
        end

        def example_failed(notification)
          @current_spec.fail!
        end

        def example_passed(notification)
          @current_spec.pass!
        end

        def example_pending(notification)
          @current_spec.pending!
        end

        def start(notification)
          @test_graph.start
        end

        def stop(notification)
          @test_graph.stop

          metric = Publisher.new(@test_graph).to_metric
          metric.save
        end

        private

        def current_element
          @stack.last
        end
      end

      # Documented at http://www.rubydoc.info/gems/rspec-core/RSpec/Core/Formatters/Protocol#example_group_started-instance_method
      ::RSpec::Core::Formatters.register Formatter,
        :example_group_started,
        :example_group_finished,
        :example_started,
        :example_passed,
        :example_failed,
        :example_pending,
        :stop,
        :start
    end
  end
end
