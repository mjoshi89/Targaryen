#For creating required directory
def create_dir(dir,mod)
  Chef::Log.info("*** Creating directory -> #{dir} ***")
  directory "#{dir}" do
    recursive true
    action :create
    mode mod
  end
end
