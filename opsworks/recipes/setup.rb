include_recipe "tar"
directory "/opt/sources" do
    owner "root"
    group "root"
    mode "0755"
    action :create
end

cockroach_version= node["cockroach_version"]
remote_file "/opt/sources/cockroach-#{cockroach_version}.linux-amd64.tgz" do
  source "https://binaries.cockroachdb.com/cockroach-#{cockroach_version}.linux-amd64.tgz"
  action :create
end


tar_extract "/opt/sources/cockroach-#{cockroach_version}.linux-amd64.tgz" do
  action :extract_local
  target_dir "/opt/sources"
  creates "/opt/sources/cockroach-#{cockroach_version}.linux-amd64/cockroach"
end

remote_file "Copy executable" do 
  path "/usr/local/bin/cockroach" 
  source "file:///opt/sources/cockroach-#{cockroach_version}.linux-amd64/cockroach"
  owner "root"
  group "root"
  mode 0755
end