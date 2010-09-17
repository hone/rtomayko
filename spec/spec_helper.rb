require "tempfile"
require "rtomayko"

module Runner
  def run_spec(text)
    path = "#{Dir.tmpdir}/#{Process.pid}"
    File.open(path, "w") do |file|
      file.puts text
    end
    `rspec #{path} 2>&1`
  end
end

RSpec.configure do |config|
  config.include Runner
end
