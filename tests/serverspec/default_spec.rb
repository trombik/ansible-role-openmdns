require "spec_helper"
require "serverspec"

package = "openmdns"
service = "mdnsd"
user    = "_mdnsd"
group   = "_mdnsd"
ports   = [5353]

describe package(package) do
  it { should be_installed }
end

describe command("rcctl get #{service} flags") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should eq "em0\n" }
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening.with("udp") }
  end
end

describe command("mdnsctl rlookup  10.0.2.15") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/^Hostname: default-[a-z]+-\d+-\w+\.local$/) }
end
