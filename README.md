Larch
=====

[![travis-ci status](https://secure.travis-ci.org/gvvaughan/larch.png?branch=master)](http://travis-ci.org/gvvaughan/larch/builds)

[Larch][] is a Lua ARCHive generator.

Trivially, when given a list of Lua source files, [Larch][] wraps them
up as a script that preloads those sources, somewhat akin to [shar][].

Less trivially, it adds a shell script preamble that will look for a
suitable Lua interpreter and re-execute the archive using that.

Most interesting of all, it provides the infrastructure for
incorporating [LuaMacro][] lexical macros into the listed sources, and
expanding those into valid [Lua][] code in the generated script archive.

This release provides only the `from` macro, which provides a compact
syntax for copying table keys, which is useful for importing module
symbols:

    from "specl.std" import Object, string.escape_pattern

is equivalent to:

    local std = require "specl.std"
    local Object, escape_pattern = std.Object, std.string.escape_pattern

Also, with a table instead of a string as the first argument:

    from state import expectations, ispending, stats

is equivalent to:

    local expectations, ispending, stats =
          state.expectations, state.ispending, state.stats

There are also custom loaders so that source files using `from` (or
other macros) can be required directly, expanding the macros on the fly.
This is, of course, much slower than using larch to pre-expand the
macros and make a script that preloads the results.


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
[luamacro]:  http://github.com/stevedonovan/LuaMacro
[luarocks]:  http://www.luarocks.org
[larch]:     http://github.com/gvvaughan/larch
[L10]:       http://github.com/gvvaughan/larch/blob/master/rockspec.conf#L10
[shar]:      http://gnu.org/s/sharutils
[yaml]:      http//yaml.org
