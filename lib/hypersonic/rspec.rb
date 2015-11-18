require "hypersonic/ruby"
require "hypersonic/rspec/version"
require "hypersonic/rspec/test_graph"
require "hypersonic/rspec/publisher"
require "hypersonic/rspec/rspec3/formatter"

module Hypersonic
  module Rspec
    def self.enable!
      notifications = [
        :example_group_started,
        :example_group_finished,
        :example_started,
        :example_passed,
        :example_failed,
        :example_pending,
        :stop,
        :start
      ]

      ::RSpec.configure do |config|
        reporter = config.formatter_loader.reporter
        reporter.register_listener(Rspec3::Formatter.new, *notifications)
      end
    end
  end
end
