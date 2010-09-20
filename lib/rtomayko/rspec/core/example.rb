require "rspec/core/example"

class RSpec::Core::Example
  delegate_to_metadata :type

  alias :run_without_dependency_resolving :run
  def run(example_group_instance, reporter)
    if type == :rtomayko
      others      = example_group_instance.class.examples
      my_position = example_group_instance.class.examples.index(self)

      if others[0...my_position].any? { |e| e.execution_result[:status] == "failed" }
        @skipped = true
        @metadata[:pending] = true
      end
    end
    run_without_dependency_resolving(example_group_instance, reporter)
  end

  alias :finish_without_skipped_examples :finish
  def finish(reporter)
    return finish_without_skipped_examples(reporter) unless @skipped
    pending = false
    record_finished 'skipped'
    reporter.example_skipped self
  end
end
