require_relative "spec_helper"

describe 'openstack-network::server' do
  describe "opensuse" do
    before do
      neutron_stubs
      @chef_run = ::ChefSpec::ChefRunner.new ::OPENSUSE_OPTS do |n|
        n.set["chef_client"]["splay"] = 300
      end
      @node = @chef_run.node
      @chef_run.converge "openstack-network::server"
    end

    it "installs openstack-neutron packages" do
      expect(@chef_run).to install_package "openstack-neutron"
    end

    it "enables openstack-neutron service" do
      expect(@chef_run).to enable_service "openstack-neutron"
    end

    it "does not install openvswitch package" do
      opts = ::OPENSUSE_OPTS.merge(:evaluate_guards => true)
      chef_run = ::ChefSpec::ChefRunner.new opts do |n|
        n.set["chef_client"]["splay"] = 300
      end
      chef_run.converge "openstack-network::server"

      expect(chef_run).not_to install_package "openstack-neutron-openvswitch"
    end
  end
end
