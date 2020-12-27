Changelog
=========

1.4.0
-----

Main:

- feat: use 2.0.2 as default version
  + Update the init script which may not work anymore for 1.1.x versions,
    you can just run it manually if you need to bootstrap a new 1.1.x cluster.

Tests:

- test: replace deprecated require\_chef\_omnibus
- test: include .gitlab-ci.yml from test-cookbook

Misc:

- doc: use doc in git message instead of docs
- chore: add 2018 to copyright notice

1.3.1
-----

Main:

- fix: default config should use %% for %

1.3.0
-----

Main:

- feat: use 1.1.0 as default version
- feat: set production settings as default config
- feat: use 1.1.0 init command, remove initiator
  + DROP SUPPORT for 1.0.X

1.2.1
-----

Main:

- fix: remove invalid working directory in unit

1.2.0
-----

Main:

- feat: use 1.0.6 as default version
- fix(config): wrong guard in node certificates generation
- fix: move certs dir outside symlink dir
- feat: change default directories:
  + store: /var/opt/cockroachdb/data (fix for more complicated store)
  + certs: /var/opt/cockroachdb/certs (independant from store)
- feat: use journald for logging
  Set background to false, log-dir to '' and logtostderr to INFO to have
  journald receiving all the logs. Service is simple instead of fork.
- feat: join all nodes, not just initiator
- feat: create cluster if necessary then join mode
- feat: generate client.root certificate at install

Tests:

- use .gitlab-ci.yml template [20170731]
- replace expired ca cert, rm useless one (node)

Misc:

- docs: use karma for git format in contributing
- style: minor stylish corrections in attributes
- style(rubocop): fix heredoc delimiters

1.1.1
-----

Fix issues url in metadata.

1.1.0
-----

Main:

- Set CockroachDB default version to 1.0 :)
- Set secure mode by default
- Generate client certificate on each node
- Change the way to set/unset an option
- Handover maintenance to Make.org
- Fix metadata, license and chef\_version (12.9)
- Increase max file to 15000 by default

Tests:

- Set always update & build pull for tests
- Use latest template for .gitlab-ci.yml [20170405]
- Fix destroy in kitchen tests

Misc:

- Fix Gemfile for rubocop, add rubocop & foodcritic
- Fix rubocop offenses (%w and %i stuff)

1.0.0
-----

- Initial version, with beta-20161103 support
