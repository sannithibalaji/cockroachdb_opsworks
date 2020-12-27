#
# Copyright (c) 2015-2016 Sam4Mobile, 2017-2018 Make.org
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

require 'spec_helper'

describe 'CockroachDB Configuration' do
  describe file('/etc/systemd/system/cockroachdb.service') do
    its(:content) { should contain 'Type = simple' }
    its(:content) { should contain '--store=path=/var/opt/cockroachdb/data' }
    its(:content) { should contain '--certs-dir=/var/opt/cockroachdb/certs' }
    its(:content) { should contain '--cache=256MB' }
    its(:content) { should contain '--join=cockroachdb-platform-' }
  end
end

describe 'CockroachDB Process' do
  it 'is listening on correct port' do
    expect(port(26_257)).to be_listening
  end
end

describe 'CockroachDB UI' do
  it 'is listening on correct port' do
    expect(port(8_080)).to be_listening
  end
end

cmd = '/opt/cockroachdb/cockroach \
  --certs-dir=/var/opt/cockroachdb/certs \
  node status'

describe 'Node status' do
  describe command(cmd) do
    its(:stdout) { should contain(host_inventory['hostname']) }
  end
end

hosts = [
  'cockroachdb-platform-kitchen-1',
  'cockroachdb-platform-kitchen-2',
  'cockroachdb-platform-kitchen-3'
]

dbname = host_inventory['hostname'].tr('-', '_')

def sql_query(query)
  `/opt/cockroachdb/cockroach sql \
  --certs-dir=/var/opt/cockroachdb/certs \
  -e "#{query}"`
end

createdb_cmd = "create database if not exists test_#{dbname}"
checkdb_cmd = 'show databases'

sql_query(createdb_cmd)

describe 'Replication' do
  hosts.each do |server|
    it "#{server} should have serverspec_#{dbname} database created" do
      expect(sql_query(checkdb_cmd)).to include("test_#{dbname}")
    end
  end
end
