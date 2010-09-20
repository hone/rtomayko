require "rspec/core"

module RTomayko
end

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

    class Reporter
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

    module Formatters
      class BaseFormatter
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

      class BaseTextFormatter
        def dump_summary(duration, example_count, failure_count, pending_count, skipped_count)
          super(duration, example_count, failure_count, pending_count, skipped_count)
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
