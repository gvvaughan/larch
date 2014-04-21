-- Generate a self extracting Lua archive.
-- Written by Gary V. Vaughan, 2013
--
-- Copyright (c) 2013-2014 Gary V. Vaughan
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3, or (at your option)
-- any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.


local std_io = require "std.io"

from std_io import slurp


--[[ ============ ]]--
--[[ Global Data. ]]--
--[[ ============ ]]--


local dirsep, pathsep = package.config:match ("^([^\n]+)\n([^\n]+)\n")

local optspec = [[
larch (@PACKAGE_NAME@) @VERSION@
Written by Gary V. Vaughan <gary@gnu.org>, 2013

Copyright (C) 2013-2014, Gary V. Vaughan
@PACKAGE_NAME@ comes with ABSOLUTELY NO WARRANTY.
You may redistribute copies of @PACKAGE_NAME@ under the terms of the GNU
General Public License; either version 3, or any later version.
For more information, see <http://www.gnu.org/licenses>.

Usage: larch [OPTIONS] [FILE]...

Self-extracting Lua ARCHive generator.

If no FILE is listed, or where '-' is given as a FILE, then read from
standard input.

Options:

      --help            print this help, then exit
      --version         print version number, then exit
  -e, --evaluate=EXPR   expression to launch archive

Report bugs to @PACKAGE_BUGREPORT@.]]


-- A shell-script to embed at the top of an executable lua script
-- between 'SH=--[[' and ']]SH', so that the result can be executed
-- as a shell script that finds a compatible Lua interpreter on the
-- command search PATH.

local preamble = [==[
#!/bin/sh
SH=--[[						# -*- mode: lua; -*-
# If LUA is not set, search PATH for something suitable.
test -n "$LUA" || {
  # Check that the supplied binary is executable and returns a compatible
  # Lua version number.
  func_vercheck ()
  {
    test -x "$1" && {
      case `$1 -e 'print (_VERSION)' 2>/dev/null` in
        *"Lua "5\.[12]*) LUA=$1 ;;
      esac
    }
  }

  save_IFS="$IFS"
  LUA=
  for x in lua lua5.2 lua5.1; do
    IFS=:
    for dir in $PATH; do
      IFS="$save_IFS"
      func_vercheck "$dir/$x"
      test -n "$LUA" && break
    done
    IFS="$save_IFS"
    test -n "$LUA" && break
  done
}

# We don't want user environment settings changing the behaviour of this
# script:
LUA_INIT=
export LUA_INIT
LUA_INIT_5_2=
export LUA_INIT_5_2=

# Reexecute using the interpreter suppiled in LUA, or found above.
exec "$LUA" "$0" "$@"
]]SH
]==]



--[[ ======= ]]--
--[[ Output. ]]--
--[[ ======= ]]--


local function execute (self)
  -- Parse command line options.
  local parser = require "std.optparse" (optspec)

  self.arg, self.opts = parser:parse (self.arg, self.opts)

  print (preamble)

  for _, f in ipairs (self.arg) do
    -- Diagnose unrecognised options.
    local h = io.open (f)
    if h == nil and f:match "^%-" then
      return parser:opterr ("unrecognised option '" .. f .. "'")
    end
    h:close ()

    -- Slurp remaining files.
    local module = f:gsub ("^[%." .. dirsep .. "]*", ""):
                     gsub ("^lib" .. dirsep .. "(.*)%.lua$", "%1")
    print ('package.preload["' .. module:gsub (dirsep, ".") ..
           '"] = (function ()')
    print (slurp (f))
    print "end)"
  end

  local eargs = self.opts.evaluate
  if type (eargs) ~= "table" then eargs = {eargs} end
  for _, earg in ipairs (eargs) do
    print (earg)
  end

  return 0
end

return require "std.object" {
  _type = "Main",

  -- Instance data.
  arg = {},
  opts = {},
  inprocess = _G,

  -- Methods.
  __index = {
    execute = execute,
  },

  _init = function (self, arg)
    self.arg = arg
    return self
  end,
}
