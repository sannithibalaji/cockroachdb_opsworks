instance_private_ips=[]
search("aws_opsworks_instance").each do |instance|
    instance_private_ips.append(instance['private_ip'])
end

log 'message' do
  message 'instance private ips are #{instance_private_ips}'
  level :info
end