require "spec_helper"

describe "RTomayko" do
  let(:rtomayko_file) { File.dirname(__FILE__) + "/../lib/rtomayko" }
  let(:spec) { "require '#{rtomayko_file}'\n" }

  it "doesn't change the behavior of regular specs" do
    spec << <<EOF
      describe "normal spec" do
        it { true.should be_false }
        it { true.should be_false }
        it "true == false", :pending => true do
          true.should be_false
        end
      end
EOF

    output = run_spec(spec)

    output.should =~ /3 examples, 2 failures, 1 pending/
  end

  context "with RTomayko" do
    it "displays the summary line properly" do
      spec << <<EOF
        describe "skip spec", :type => :rtomayko do
          it { true.should be_false }
          it { true.should be_false }
        end
EOF
      output = run_spec(spec)

      output.should =~ /2 examples, 1 failure, 1 skipped/
    end

    it "skips the execution of an example when something failed before it" do
      spec << <<EOF
        describe "skip spec", :type => :rtomayko do
          it { true.should be_false }
          it { true.should be_false }
          it { sleep(1);true.should be_false }
        end
EOF

      output = run_spec(spec)

      md = /Finished in (\d+(\.\d+)?) seconds/.match(output)
      execution_time = md[1].to_f
      execution_time.to_f.should < 1
    end

    context "with pending tests" do
      it "should mark pending tests as pending when before failed test" do
        spec << <<EOF
          describe "skip spec", :type => :rtomayko do
            it "true == false", :pending => true do
              true.should be_false
            end
            it { true.should be_false }
            it { sleep(1);true.should be_false }
          end
EOF

        output = run_spec(spec)

        output.should =~ /3 examples, 1 failure, 1 pending, 1 skipped/
      end

      it "should mark pending tests as skipped after failed test" do
        spec << <<EOF
          describe "skip spec", :type => :rtomayko do
            it { true.should be_false }
            it { sleep(1);true.should be_false }
            it "true == false", :pending => true do
              true.should be_false
            end
          end
EOF

        output = run_spec(spec)

        output.should =~ /3 examples, 1 failure, 2 skipped/
      end
    end

    describe "formatters" do
      describe "progress formatter" do
        let(:formatter) { 'progress' }

        it "should display in progress format" do
          spec << <<EOF
            describe "skip spec", :type => :rtomayko do
              it { true.should be_false }
              it { true.should be_false }
            end
EOF
          output = run_spec(spec, formatter)
          output.should include("\e[31mF\e[0m\e[34m-")
        end
      end

      describe "documentation formatter" do
        let(:formatter) { 'doc' }

        it "should display in documentation format" do
          spec << <<EOF
            describe "skip spec", :type => :rtomayko do
              it "test 1" do
                true.should be_false
              end
              it "test 2" do
                true.should be_false
              end
            end
EOF
          output = run_spec(spec, formatter)
          output.should include("skip spec\n\e[31m  test 1 (FAILED - 1)\e[0m\n\e[34m  test 2")
        end
      end
    end
  end
end
