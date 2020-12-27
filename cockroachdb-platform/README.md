CockroachDB Platform
====================

Description
-----------

[CockroachDB](https://www.cockroachlabs.com/) is an open source, scalable,
survivable, strongly consistent database.

This cookbook is designed to install and configure a CockroachDB cluster.

Requirements
------------

### Cookbooks and gems

Declared in [metadata.rb](metadata.rb) and in [Gemfile](Gemfile).

### Platforms

A *systemd* managed distribution:
- RHEL Family 7, tested on Centos

Usage
-----

### Easy Setup

Set `node['cockroachdb-platform']['hosts']` to an array containing the
hostnames of the nodes of the CockroachDB cluster.

### Search

The recommended way to use this cookbook is through the creation of a role per
**CockroachDB** cluster. This enables the search by role feature, allowing a
simple service discovery.

In fact, there are two ways to configure the search:

1. With a static configuration through a list of hostnames (attributes `hosts`
   that is `node['cockroachdb-platform']['hosts']`) for nodes belonging to
   CockroachDB cluster.
2. With a real search, performed on a role (attributes `role` and `size`
   like in `node['cockroachdb-platform']['role']`).
   The role should be in the run-list of all nodes of the cluster.
   The size is a safety and should be the number of nodes of this role.

If hosts is configured, `role` and `size` are ignored

See [roles](test/integration/roles) for some examples and
[Cluster Search][cluster-search] documentation for more information.

### Test

This cookbook is fully tested through the installation of a working 3-nodes
cluster in docker hosts. This uses kitchen, docker and some monkey-patching.

For more information, see [.kitchen.yml](.kitchen.yml) and [test](test)
directory.

Attributes
----------

Configuration is done by overriding default attributes. All configuration keys
have a default defined in [attributes/default.rb](attributes/default.rb).
Please read it to have a comprehensive view of what and how you can configure
this cookbook behavior.

Recipes
-------

### default

Include `search`, `user`, `install`, `config` and `systemd` recipes.

### search

Search all nodes for the join option.

### user

Create user/group used by CockroachDB.

### install

Install CockroachDB using ark.

### config

Generate options for the CockroachDB node.

Global options for each CockroachDB node in the cluster are defined through
the following attribute: `node['cockroachdb-platform']['options']`.

By default, the CockroachDB cluster will be created and started in secure mode.
SSL certificates used for the secure mode have to be stored in an encrypted
data bag (data bag 'secrets' with items 'ca' and 'node' by default). For an
example, look at the test configuration, you can see also the format needed to
have the client certificates well named and placed in the test-cockroachdb
cookbook. (Note that in the current test configuration, data bag are in ruby
format thanks to a monkey patch. With a production Chef, we have to define them
in JSON.)

To enable the insecure mode, set an insecure attribute to empty string ('')
`node['cockroachdb-platform']['options']['insecure']`. (like the background one
in [attributes/default.rb](attributes/default.rb))

### systemd

Create systemd service file for CockroachDB.

Changelog
---------

Available in [CHANGELOG.md](CHANGELOG.md).

Contributing
------------

Please read carefully [CONTRIBUTING.md](CONTRIBUTING.md) before making a merge
request.

License and Author
------------------

- Author:: Samuel Bernard (<samuel.bernard@gmail.com>)
- Author:: Florian Philippon (<florian.philippon@gmail.com>)
- Author:: Vincent Baret (<vbaret@gmail.com>)

```text
Copyright (c) 2016 Sam4Mobile, 2017-2018 Make.org

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

[cluster-search cookbook]: https://supermarket.chef.io/cookbooks/cluster-search
