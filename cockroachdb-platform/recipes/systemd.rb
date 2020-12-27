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

# We need all nodes before attempting any config of systemd
run_state = node.run_state[cookbook_name]
return if run_state.nil? || run_state['hosts'].nil?

# Construct unit content from command line options
def options_to_unit(options, bin)
  options_str = options.map do |key, opts|
    [opts].flatten.map do |opt|
      "--#{key.to_s.tr('_', '-')}=#{opt}" unless opt == 'nil'
    end
  end.flatten.join(" \\\n  ")

  unit = node[cookbook_name]['unit'].to_hash
  unit['Service']['ExecStart'] = "#{bin} start #{options_str}"
  unit
end

# Cli opts for unit, map based
bin = "#{node[cookbook_name]['prefix_home']}/cockroachdb/cockroach"
options = node.run_state[cookbook_name]['options']

unit = options_to_unit(options, bin)
systemd_unit 'cockroachdb.service' do
  content unit
  action %i[create enable start]
end

# Init a cluster if needed
check = 'curl -skL localhost:8080/health?ready=1 | grep "nodeId"'
execute 'init cockroachdb cluster' do
  command <<-BASH
    if curl -skL localhost:8080/health | grep '"nodeId": 0'; then
      #{bin} init --certs-dir #{options['certs-dir']}
    else
     echo 'cluster status:'
     curl -skL localhost:8080/health
     exit 127
    fi
  BASH
  retries 3
  live_stream true
  not_if check
end
