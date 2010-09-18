require "tempfile"

module Runner
  def run_spec(text)
    path = "#{Dir.tmpdir}/#{Process.pid}"
    File.open(path, "w") do |file|
      file.puts <<RSPEC_CONFIGURE
RSpec.configure do |config|
  config.mock_with ''
end
RSPEC_CONFIGURE
      file.puts text
    end
    `rspec #{path} 2>&1`
  end
end

RSpec.configure do |config|
  config.include Runner
  config.mock_with ''
end
