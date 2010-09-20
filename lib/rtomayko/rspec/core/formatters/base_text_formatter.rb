require 'rspec/core/formatters/base_text_formatter'

class RSpec::Core::Formatters::BaseTextFormatter
  def dump_summary(duration, example_count, failure_count, pending_count, skipped_count)
    super(duration, example_count, failure_count, pending_count, skipped_count)
    # Don't print out profiled info if there are failures, it just clutters the output
    dump_profile if profile_examples? && failure_count == 0
    output.puts "\nFinished in #{format_seconds(duration)} seconds\n"
    output.puts colorise_summary(summary_line(example_count, failure_count, pending_count, skipped_count))
  end

  alias :summary_line_without_skipped_examples :summary_line
  def summary_line(example_count, failure_count, pending_count, skipped_count)
    summary = summary_line_without_skipped_examples(example_count, failure_count, pending_count)
    summary << ", #{skipped_count} skipped" if skipped_count > 0
    summary
  end
end
