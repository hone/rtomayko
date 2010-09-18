require "spec_helper"

describe "RTomayko" do
  it "doesn't change the behavior of regular specs" do
    output = run_spec <<EOF
      describe "normal spec" do
        it { true.should be_false }
        it { true.should be_false }
      end
EOF
    output.should =~ /2 examples, 2 failure/
  end

  it "skips the execution of an example when something failed before it" do
    output = run_spec <<EOF
      describe "skip spec", :type => :rtomayko do
        it { true.should be_false }
        it { true.should be_false }
      end
EOF

    output.should =~ /2 examples, 1 failure, 1 skipped/
  end
end
