module Hypersonic
  module Rspec
    class Publisher
      attr_reader :graph

      def initialize(graph)
        @graph = graph
      end

      def to_metric
        Hypersonic::Ruby::Metric.new("RSpec Test Suite", source: 'rspec', duration: @graph.duration) do |m|
          @graph.children.each do |child|
            add_to_metric(m, child)
          end
        end
      end

      private
      def add_to_metric(metric, child)
        if child.respond_to?(:children)
          metric.metric(child.name) do |m|
            child.children.each do |child|
              add_to_metric(m, child)
            end
          end
        else
          metric.duration child.duration
          metric.source 'rspec'
        end
      end
    end
  end
end

