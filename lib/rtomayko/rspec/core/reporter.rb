require 'rspec/core/reporter'

class RSpec::Core::Reporter
  alias :initialize_without_skipped_count :initialize
  def initialize(*formatters)
    @skipped_count = 0
    initialize_without_skipped_count(*formatters)
  end

  def example_skipped(example)
    @skipped_count += 1
    notify :example_skipped, example
  end

  alias :conclude_without_skipped_examples :conclude
  def conclude
    begin
      stop
      notify :start_dump
      notify :dump_pending
      notify :dump_failures
      notify :dump_summary, @duration, @example_count, @failure_count, @pending_count, @skipped_count
    ensure
      notify :close
    end
  end
end
