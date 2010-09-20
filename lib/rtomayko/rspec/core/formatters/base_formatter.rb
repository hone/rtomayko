require 'rspec/core/formatters/base_formatter'

class RSpec::Core::Formatters::BaseFormatter
  alias :initialize_without_skipped_examples :initialize
  def initialize(output)
    @skipped_count    = 0
    @skipped_examples = []
    initialize_without_skipped_examples(output)
  end

  alias :dump_summary_without_skipped_examples :dump_summary
  def dump_summary(duration, example_count, failure_count, pending_count, skipped_count = 0)
    @skipped_count = skipped_count
    dump_summary_without_skipped_examples(duration, example_count, failure_count, pending_count)
  end

  def example_skipped(example)
    @skipped_examples << example
  end
end
