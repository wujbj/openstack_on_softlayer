require_relative 'spec_helper'

describe 'openstack-network::linuxbridge' do

  describe "redhat" do
    before do
      neutron_stubs
      @chef_run = ::ChefSpec::ChefRunner.new ::REDHAT_OPTS do |n|
        n.set["openstack"]["network"]["interface_driver"] = "neutron.agent.linux.interface.BridgeInterfaceDriver"
      end
      @chef_run.converge "openstack-network::linuxbridge"
    end

    it "installs linuxbridge agent" do
      expect(@chef_run).to install_package "openstack-neutron-linuxbridge"
    end

    it "sets the linuxbridge service to start on boot" do
      expect(@chef_run).to set_service_to_start_on_boot "neutron-linuxbridge-agent"
    end

  end
end
