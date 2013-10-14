require_relative 'spec_helper'

describe "openstack-network::common" do
  describe "ubuntu" do
    before do
      neutron_stubs
      @chef_run = ::ChefSpec::ChefRunner.new ::UBUNTU_OPTS
      @chef_run.converge "openstack-network::common"
    end

    it "upgrades python neutronclient" do
      expect(@chef_run).to upgrade_package "python-neutronclient"
    end

    it "upgrades python pyparsing" do
      expect(@chef_run).to upgrade_package "python-pyparsing"
    end
  end
end
