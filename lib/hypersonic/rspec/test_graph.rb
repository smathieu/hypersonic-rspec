module Hypersonic
  module Rspec
    module TracksDuration
      def start
        @start_time = Time.now
      end

      def stop
        @stop_time = Time.now
      end

      def duration
        raise "Missing time" unless @start_time && @stop_time
        @stop_time - @start_time
      end
    end

    class TestSuite
      include TracksDuration

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

      def initialize(name)
        @name = name
      end

      def print_tree(indent)
        space = "  " * indent
        space + name + " (#{duration})"
      end

      def fail!
        stop
        @state = :failed
      end

      def pass!
        stop
        @state = :passed
      end

      def pending!
        stop
        @state = :pending
      end
    end

    class TestGraph
      include TracksDuration

      attr_reader :children

      def initialize
        @children = []
      end

      def inspect
        children.map {|s| s.print_tree(0) }.join("\n")
      end
    end
  end
end
