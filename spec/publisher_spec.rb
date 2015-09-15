require 'spec_helper'

module Hypersonic
  module Rspec
    describe Publisher do
      describe "#to_metric" do
        def make_test_case(name)
          tc = TestCase.new("t1")
          tc.start
          tc.pass!
          tc
        end
        let(:graph) do
          g = TestGraph.new
          s = TestSuite.new("a")
          s.children << make_test_case("t1")
          s.children << make_test_case("t2")
          s.children << make_test_case("t3")
          g.children << s
          g
        end

        subject { described_class.new(graph).to_metric }

        it "converts a test graph object to an hypersonic-ruby object" do
          expect(subject).to be_a(Hypersonic::Ruby::Metric)
        end
      end
    end
  end
end
