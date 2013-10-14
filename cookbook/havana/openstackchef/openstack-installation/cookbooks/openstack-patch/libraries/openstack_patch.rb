# Patching for nova
module RCB
  def patch_openstack(patch_url, component)
    com_list = %x[curl #{patch_url}/components.list | grep #{component}]
    python_dir = %x[python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"]
    python_dir.strip! if python_dir
    com_list.split.each do |com|
      Chef::Log.info "Download #{com}.patch from #{patch_url} and apply patch in #{python_dir} ..."
      msg = %x[cd #{python_dir} && wget -N #{patch_url}/#{com}.patch && patch -p1 -f < #{com}.patch]
      Chef::Log.info msg
      %x[ [ -e #{com}.path ] && rm -f  #{com}.path]
      Chef::Log.info "Download #{com}.sh from #{patch_url} and run ... "
      msg = %x[cd /tmp/ && wget -N #{patch_url}/#{com}.sh && /bin/sh #{com}.sh]
      Chef::Log.info msg
      %x[ [ -e #{com}.sh ] && rm -f #{com}.sh ]
    end
  end
end
