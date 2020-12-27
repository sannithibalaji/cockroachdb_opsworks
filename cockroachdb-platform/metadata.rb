name 'cockroachdb-platform'
maintainer 'Make.org'
maintainer_email 'sre@make.org'
license 'Apache-2.0'
description 'Cookbook used to install and configure cockroachdb'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url 'https://gitlab.com/chef-platform/cockroachdb-platform'
issues_url 'https://gitlab.com/chef-platform/cockroachdb-platform/issues'
version '1.4.0'

chef_version '>= 12.9'

depends 'tar'
