require 'rspec/core/formatters/progress_formatter'

class RSpec::Core::Formatters::ProgressFormatter
  def example_skipped(example)
    super(example)
    output.print blue('-')
  end
end
