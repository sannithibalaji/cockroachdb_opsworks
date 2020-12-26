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

cookbook_name = 'cockroachdb-platform'

# Cluster configuration with cluster-search
# Role used by the search to find other nodes of the cluster
default[cookbook_name]['role'] = cookbook_name
# Hosts of the cluster, deactivate search if not empty
default[cookbook_name]['hosts'] = []
# Expected size of the cluster. Ignored if hosts is not empty
default[cookbook_name]['size'] = 1

# cockroachdb package
default[cookbook_name]['version'] = 'v2.0.2'
cockroachdb_version = node[cookbook_name]['version']
default[cookbook_name]['checksum'] =
  'ab510541ab9c7e02e9f4a015a4b55f3f47139920fc5a32cc05cb6673a6252228'

# Where to get the tarball
default[cookbook_name]['mirror_base'] = 'https://binaries.cockroachdb.com'
cockroachdb_mirror = node[cookbook_name]['mirror_base']
default[cookbook_name]['mirror'] =
  "#{cockroachdb_mirror}/cockroach-#{cockroachdb_version}.linux-amd64.tgz"

# User and group of cockroachdb process
default[cookbook_name]['user'] = 'cockroachdb'
default[cookbook_name]['group'] = 'cockroachdb'
# Where to put installation dir
default[cookbook_name]['prefix_root'] = '/opt'
# Where to link installation dir
default[cookbook_name]['prefix_home'] = '/opt'
# Where to link binaries
default[cookbook_name]['prefix_bin'] = '/opt/bin'

# Cockroachdb options
# "key => value" will be transformed to "--key value" in cockroach cli
# For keys without value like 'insecure', set value to empty string
# To unset a key, set it to 'nil' (the string)
# To set a key multiple time, use an array
default[cookbook_name]['options'] = {
  'background' => false,
  # store is a mandatory option
  'store' => 'path=/var/opt/cockroachdb/data', # use an array for multiple path
  'certs-dir' => '/var/opt/cockroachdb/certs',
  'log-dir' => '', # no need for file, we have journald
  'logtostderr' => 'INFO', # change level, or disable it by setting NONE
  'no-color' => false,
  'cache' => '25%%',
  'max-sql-memory' => '25%%'
}

# Configuration about the encrypted data bag containing the certs used
# by cockroachdb for encryption between components.
default[cookbook_name]['data_bag']['name'] = 'secrets'

# CA authority certificate and key for secure mode
default[cookbook_name]['data_bag']['ca'] = 'cockroachdb-ca'

# What to add to the nodes certificates accordingly to cockroachdb doc:
# "Create a node certificate and key specifying all addresses at which the
# node can be reached"
default[cookbook_name]['node_hostnames'] = ['localhost', node['fqdn']]

# Systemd service unit, include config
default[cookbook_name]['unit'] = {
  'Unit' => {
    'Description' => 'cockroachdb server',
    'After' => 'network.target'
  },
  'Service' => {
    'Type' => 'simple',
    'User' => node[cookbook_name]['user'],
    'Group' => node[cookbook_name]['group'],
    'SyslogIdentifier' => 'cockroachdb',
    'Restart' => 'on-failure',
    'ExecStart' => 'TO_BE_COMPLETED',
    # Warning from cockroachdb under 15_000
    'LimitNOFILE' => 'infinity'
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}
