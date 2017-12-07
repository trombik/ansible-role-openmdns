require "spec_helper"
require "serverspec"

package = "openmdns"
service = "mdnsd"
_user    = "_mdnsd"
_group   = "_mdnsd"
ports = [5353]
default_owner = "root"
default_group = "root"

case os[:family]
when "freebsd"
  default_group = "wheel"
when "openbsd"
  default_group = "wheel"
end

describe package(package) do
  it { should be_installed }
end

case os[:family]
when "openbsd"
  describe command("rcctl get #{service} flags") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq "" }
    its(:stdout) { should eq "em0\n" }
  end
when "freebsd"
  describe file("/etc/rc.conf.d/#{service}") do
    it { should exist }
    it { should be_file }
    it { should be_owned_by default_owner }
    it { should be_grouped_into default_group }
    it { should be_mode 644 }
    its(:content) { should match(/^#{service}_flags="em0"$/) }
  end
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
