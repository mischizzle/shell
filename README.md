shell script for new mac setup
=====

Applications
=====

- iterm2
- sublime text
- sequel pro
- google chrome


Tools / Utilities
=====

- homebrew
- homebrew cask
- wget
- mysql
- varnish3
- node
- npm
- grunt-cli
- compass
- karma

Troubleshooting
=====

-Apache:
Ensure the syntax of the cwf.conf file is correct by running:
  sudo apachectl configtest

-Varnish:
Equivalent to Apache's configtest, run:
  varnishd -C -f /etc/varnish3/default.vcl
