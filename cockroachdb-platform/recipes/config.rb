#
# Copyright (c) 2016 Sam4Mobile, 2017-2018 Make.org
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# We need all nodes before attempting any config
run_state = node.run_state[cookbook_name]
return if run_state.nil? || run_state['hosts'].nil?

# Generate options hash from attribute
options = node[cookbook_name]['options'].to_hash

# Create cockroachdb store directory
stores = options['store']
[stores].flatten.each do |store|
  if store.include?(',')
    store = store.split(',').keep_if { |e| e.include?('path=') }.first
  end
  store = store[5..-1] if store.start_with?('path=')
  directory "#{cookbook_name}_dir: #{store}" do
    path store
    user node[cookbook_name]['user']
    group node[cookbook_name]['user']
    mode '0755'
    recursive true
  end
end

# Deploy data bag in secure mode
if options['insecure'].nil?
  # Create directory for ssl certs storage
  directory "#{cookbook_name}_dir: certs-dir" do
    path options['certs-dir']
    user node[cookbook_name]['user']
    group node[cookbook_name]['user']
    mode '0750'
    recursive true
  end

  # Load certs from encrypted data bag
  data_bag = node[cookbook_name]['data_bag']

  %w[crt key].each do |ext|
    # Create only SSL ca
    file "#{options['certs-dir']}/ca.#{ext}" do
      content data_bag_item(data_bag['name'], data_bag['ca'])[ext]
      user node[cookbook_name]['user']
      group node[cookbook_name]['user']
      mode mode '0600'
    end
  end

  # Node certificates are generated for each node
  bash 'gen node certs' do
    code <<-BASH
      #{node[cookbook_name]['prefix_root']}/cockroachdb/cockroach \
      cert create-node \
      --certs-dir=#{options['certs-dir']} \
      --ca-key=#{options['certs-dir']}/ca.key \
      #{node[cookbook_name]['node_hostnames'].join(' ')} && \
      chown -R #{node[cookbook_name]['user']}.#{node[cookbook_name]['user']} \
      #{options['certs-dir']}/node.*
    BASH
    not_if { ::File.exist?("#{options['certs-dir']}/node.crt") }
  end

  # Generate root certificates to make it easier to operate cockroach
  bash 'gen root certs' do
    code <<-BASH
      #{node[cookbook_name]['prefix_root']}/cockroachdb/cockroach \
      cert create-client root \
      --certs-dir=#{options['certs-dir']} \
      --ca-key=#{options['certs-dir']}/ca.key
      chown -R #{node[cookbook_name]['user']}.#{node[cookbook_name]['user']} \
      #{options['certs-dir']}/client.root.*
    BASH
    not_if { ::File.exist?("#{options['certs-dir']}/client.root.crt") }
  end
end

# join option (with all nodes found)
nodes = node.run_state[cookbook_name]['hosts'] - [node['fqdn']]
options['join'] = nodes.join(',')

# Store options to reuse them later (in systemd unit)
node.run_state[cookbook_name]['options'] = options
