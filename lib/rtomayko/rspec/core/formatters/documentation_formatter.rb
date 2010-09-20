require 'rspec/core/formatters/documentation_formatter'

class RSpec::Core::Formatters::DocumentationFormatter
  def example_skipped(example)
    super(example)
    output.puts skipped_output(example)
  end

  def skipped_output(example)
    blue("#{current_indentation}#{example.description}")
  end
end
