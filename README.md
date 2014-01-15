Larch
=====

[![travis-ci status](https://secure.travis-ci.org/gvvaughan/larch.png?branch=master)](http://travis-ci.org/gvvaughan/larch/builds)

[Larch][] is a Lua ARCHive generator.


Installation
------------

There's no need to download a [Larch][] release, or clone the git repo,
unless you want to modify the code.  If you use [LuaRocks][], you can
use it to install the latest release from it's repository:

    luarocks install larch

Or from the rockspec in a release tarball:

    luarocks make larch-?-1.rockspec

To install current git master from [GitHub][larch] (for testing):

    luarocks install http://raw.github.com/gvvaughan/larch/release/larch-git-1.rockspec

To install without [LuaRocks][], clone the sources from the
[repository][larch], and then run the following commands:

    cd larch
    ./bootstrap
    ./configure --prefix=INSTALLATION-ROOT-DIRECTORY
    make all check install

The dependencies are listed in the dependencies entry of the file
[rockspec.conf][L10]. You will also need [Autoconf][] and [Automake][].

See [INSTALL][] for instructions for `configure`.

Documentation
-------------

Larch includes [Markdown formatted documentation][github.io].


[autoconf]:  http://gnu.org/s/autoconf
[automake]:  http://gnu.org/s/automake
[github.io]: http://gvvaughan.github.io/larch
[install]:   http://raw.github.com/gvvaughan/larch/release/INSTALL
[lua]:       http://www.lua.org
[luarocks]:  http://www.luarocks.org
[larch]:     http://github.com/gvvaughan/larch
[L10]:       http://github.com/gvvaughan/larch/blob/master/rockspec.conf#L10
[yaml]:      http//yaml.org
