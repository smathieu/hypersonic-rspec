require 'spec_helper'

module Hypersonic
  module Rspec
    module Rspec3
      describe Formatter do
        let(:examples) do
          [
            'example_group_started Metric',
            'example_group_started #all_parent',
            'example_started example at ./spec/models/metric_spec.rb:10',
            'example_passed should eq []',
            'example_started example at ./spec/models/metric_spec.rb:11',
            'example_passed should eq [#<Metric id: 120, project_id: 116, source: "rspec", name: "Total Build Time 2", unit: 0, created_at: "2015-09-20 03:00:51", updated_at: "2015-09-20 03:00:51", parent_metric_id: nil>]',
            'example_started example at ./spec/models/metric_spec.rb:12',
            'example_passed should eq [#<Metric id: 122, project_id: 117, source: "rspec", name: "Total Build Time 4", unit: 0, created_at: "2015-09-20 03:00:51", updated_at: "2015-09-20 03:00:51", parent_metric_id: nil>, #<Metric id: 123, project_id: 117, source: "rspec", name: "Total Build Time 5", unit: 0, created_at: "2015-09-20 03:00:51", updated_at: "2015-09-20 03:00:51", parent_metric_id: 122>]',
            'example_group_finished #all_parent',
            'example_group_finished Metric',
          ]
        end

        def notification_for_method(method, name)
          case method
          when "example_group_started", "example_group_finished"
            group = double(metadata: {description: name})
            double(group: group)
          else
            example = double(description: name)
            double(example: example)
          end
        end

        let(:test_graph) { subject.test_graph }

        before do
          test_graph.start

          examples.each do |name|
            method, name = name.split(' ', 2)
            subject.send(method, notification_for_method(method, name))
          end

          test_graph.stop
        end

        it "creates the valid test graph" do
          test_graph.each_child do |test_case|
            expect(test_case.duration).to be_a(Float)
          end

          test_graph.each_test_case do |test_case|
            expect(test_case.state).to be_a(Symbol)
          end
        end

        it "can convert said test graph for metrics" do
          metric = subject.to_metric

          expect(metric).to be_valid

          metric.submetrics.each do |metric|
            # Group Metric
            expect(metric).to be_valid

            metric.submetrics.each do |metric|
              # Group all_parent
              expect(metric).to be_valid
              expect(metric.submetrics.size).to eq(3)

              metric.submetrics.each do |metric|
                expect(metric).to be_valid
              end
            end
          end
        end
      end
    end
  end
end
