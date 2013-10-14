
require 'openssl'
require 'thread'

# TODO: !!! Need to add an attribute control flag whether or not to use...
# (or consistently use databag secret on all knife clients and nodes at a site.)
# Also, this is hard-coded for openstackconfigs databag--should consider making
# this more generic...
def get_passwords(key)

  if not Chef::DataBag.list.key?('openstackconfigs')
    return nil
  else
    ret = Chef::EncryptedDataBagItem.load("openstackconfigs","passwords")
    return ret[key]
  end
end
