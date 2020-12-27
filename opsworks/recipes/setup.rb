include_recipe 'tar'
directory '/opt/sources' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
end


remote_file '/opt/sources/cockroach-v20.2.3.linux-amd64.tgz' do
  source 'https://binaries.cockroachdb.com/cockroach-v20.2.3.linux-amd64.tgz'
  action :create
end


tar_extract '/opt/sources/cockroach-v20.2.3.linux-amd64.tgz' do
  action :extract_local
  target_dir '/opt/sources'
  creates '/opt/sources/cockroach-v20.2.3.linux-amd64/cockroach'
end