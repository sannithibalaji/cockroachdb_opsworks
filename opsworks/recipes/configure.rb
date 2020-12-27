all_instances_private_ips=[]
search("aws_opsworks_instance").each do |instance|
    all_instances_private_ips << instance['private_ip']
end

current_instance = search("aws_opsworks_instance").first

fqdn = node["fqdn"]

file '/var/lib/cockroach/certs/ca.crt' do
    content 'content'
    owner 'cockroach'
    group 'cockroach'
    mode '0755'
    action :create
end

file '/var/lib/cockroach/certs/ca.key' do
    content 'content'
    owner 'cockroach'
    group 'cockroach'
    mode '0755'
    action :create
end


bash 'generate ssl certificates' do
    cwd '/var/lib/cockroach'
    code <<-EOH
    cockroach cert create-node \
#{current_instance['private_ip']} \
#{fqdn} \
--certs-dir=certs \
--ca-key=certs/ca.key
    EOH
    action :run
    creates '/var/lib/cockroach/certs/node.crt'
end


template '/etc/systemd/system/securecockroachdb.service' do
  source 'securecockroachdb.service'
  owner 'root'
  group 'root'
  mode '0755'
  variables(
      all_instances_private_ips: all_instances_private_ips,
      current_instance_private_ip: current_instance['private_ip']
   )
end