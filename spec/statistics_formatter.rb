require 'rspec/core/formatters/base_formatter'
require 'coverage'

class StatisticsFormatter < ::RSpec::Core::Formatters::BaseFormatter

  def initialize(*)
    super
    Coverage.start
  end

  def dump_summary(duration, example_count, failure_count, pending_count)
    output.puts [ format_seconds(duration), example_count, failure_count, pending_count, loc, lines_covered, lot ].join(',')
  end

  private

  def loc
    lines_in_lib.size
  end

  def lot
    lines_in_dir("spec").size
  end

  def lines_covered
    lines_in_lib.count { |line| line != 0 }
  end

  def lines_in_lib
    @lines_in_lib ||= lines_in_dir("lib")
  end

  def lines_in_dir(dir)
    root = File.expand_path("../../#{dir}", __FILE__)
    coverage_report.select { |file, cov| file =~ /^#{root}/ }.values.flatten.compact
  end

  def coverage_report
    @coverage_report ||= Coverage.result
  end

end
