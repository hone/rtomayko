require "spec_helper"

describe "RTomayko" do
  let(:rtomayko_file) { File.dirname(__FILE__) + "/../lib/rtomayko" }
  let(:spec) { "require '#{rtomayko_file}'\n" }

  it "doesn't change the behavior of regular specs" do
    spec << <<EOF
      describe "normal spec" do
        it { true.should be_false }
        it { true.should be_false }
      end
EOF

    output = run_spec(spec)

    output.should =~ /2 examples, 2 failure/
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
  end
end
