module Hypersonic
  module Rspec
    module TracksDuration
      def start
        @start_time = Time.now
      end

      def stop
        raise "Can't stop #{self} before start was called" unless @start_time
        @stop_time = Time.now
      end

      def duration
        raise "Missing time for #{self}" unless @start_time && @stop_time
        @stop_time - @start_time
      end
    end

    module EnumerableChildren
      def each_child
        yield self
        children.each do |child|
          if child.respond_to?(:each_child)
            child.each_child do |child|
              yield child
            end
          else
            yield child
          end
        end
      end
    end

    class TestSuite
      include TracksDuration
      include EnumerableChildren

      attr_reader :children, :name

      def initialize(name)
        @name = name
        @children = []
      end

      def print_tree(indent)
        space = "  " * indent
        space + name + "\n" +
          children.map {|s| space + s.print_tree(indent + 1)}.join("\n")
      end
    end

    class TestCase
      include TracksDuration

      attr_reader :name, :state

      def print_tree(indent)
        space = "  " * indent
        space + name + " (#{duration})"
      end

      ACTION_TO_STATE = {
        fail: :failed,
        pass: :passed,
        pending: :pending,
      }

      ACTION_TO_STATE.each do |action, state|
        define_method("#{action}!") do |name|
          stop
          @name = name
          @state = state
        end
      end
    end

    class TestGraph
      include TracksDuration
      include EnumerableChildren

      attr_reader :children

      def initialize
        @children = []
      end

      def inspect
        children.map {|s| s.print_tree(0) }.join("\n")
      end

      def each_test_case
        each_child do |child|
          if TestCase === child
            yield child
          end
        end
      end
    end
  end
end
