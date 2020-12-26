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

# Modify CommonSandbox to generate data bag from ruby files
# In case of conflict, the generated json overrides the json file

require 'kitchen/provisioner/chef/common_sandbox'
require 'json'

module Kitchen
  module Provisioner
    module Chef
      class CommonSandbox
        alias prepare_official prepare

        def prepare(component, opts = {})
          # Call 'official' method for everybody
          prepare_official(component, opts)
          # Genenate json from ruby files
          generate_databags(component, opts) if component == :data_bags
        end

        def generate_databags(component, opts)
          dest = File.join(
            sandbox_path, opts.fetch(:dest_name, component.to_s)
          )
          Dir.foreach(dest) do |subdir|
            next if subdir.start_with?('.')
            Dir.foreach(File.join(dest, subdir)) do |file|
              next unless file.end_with?('.rb')
              eval_item(File.join(dest, subdir), file)
            end
          end
        end

        def eval_item(rb_path, rb_base)
          rb_file = File.join(rb_path, rb_base)
          item = eval(IO.read(rb_file)) # rubocop:disable Security/Eval
          json_file = File.join(rb_path, "#{rb_base[0..-4]}.json".tr('_', '-'))
          File.open(json_file, 'w') do |file|
            file.write(item.to_json)
          end
          File.delete(rb_file)
        end
      end
    end
  end
end
