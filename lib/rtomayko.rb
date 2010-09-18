require "rspec/core"

module RSpec
  module Core
    class Example

      delegate_to_metadata :type

      alias :run_without_dependency_resolving :run
      def run(example_group_instance, reporter)
        if type == :rtomayko
          others      = example_group_instance.class.examples
          my_position = example_group_instance.class.examples.index(self)

          if others[0...my_position].any? { |e| e.execution_result[:status] == "failed" }
            @skipped = true
            pending  = true # prevent it from running
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

    class Reporter
      def initialize(*formatters)
        @formatters = formatters
        @example_count = @failure_count = @pending_count = @skipped_count = 0
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

    module Formatters
      class BaseFormatter
        def initialize(output)
          @output = output
          @example_count = @pending_count = @failure_count = 0
          @examples = []
          @failed_examples = []
          @pending_examples = []
          @skipped_examples = []
          @example_group = nil
        end

        def dump_summary(duration, example_count, failure_count, pending_count, skipped_count)
          @duration = duration
          @example_count = example_count
          @failure_count = failure_count
          @pending_count = pending_count
          @skipped_count = skipped_count
        end

        def example_skipped(example)
          @skipped_examples << example
        end
      end

      class BaseTextFormatter
        def dump_summary(duration, example_count, failure_count, pending_count, skipped_count)
          super(duration, example_count, failure_count, pending_count, skipped_count)
          output.puts "\nFinished in #{format_seconds(duration)} seconds\n"
          output.puts colorise_summary(summary_line(example_count, failure_count, pending_count, skipped_count))
        end

        def summary_line(example_count, failure_count, pending_count, skipped_count)
          summary = pluralize(example_count, "example")
          summary << ", " << pluralize(failure_count, "failure")
          summary << ", #{pending_count} pending" if pending_count > 0
          summary << ", #{skipped_count} skipped" if skipped_count > 0
          summary
        end
      end

      class DocumentationFormatter
        def example_skipped(example)
          output.puts skipped_output(example)
        end

        def skipped_output(example)
          blue("#{current_indentation}#{example.description}")
        end
      end

      class ProgressFormatter
        def example_skipped(example)
          super(example)
          output.print blue('-')
        end
      end
    end
  end
end
