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



--[[ ============== ]]--
--[[ Parse options. ]]--
--[[ ============== ]]--

local OptionParser = require "larch.optparse"

local parser = OptionParser [[
larch (@PACKAGE_NAME@) @VERSION@
Written by Gary V. Vaughan <gary@gnu.org>, 2013

Copyright (C) 2013-2104, Gary V. Vaughan
@PACKAGE_NAME@ comes with ABSOLUTELY NO WARRANTY.
You may redistribute copies of @PACKAGE_NAME@ under the terms of the GNU
General Public License; either version 3, or any later version.
For more information, see <http://www.gnu.org/licenses>.

Usage: larch [OPTIONS] [FILE]...

Self-extracting Lua ARCHive generator.

If no FILE is listed, or where '-' is given as a FILE, then read from
standard input.

      --help            print this help, then exit
      --version         print version number, then exit
  -e, --evaluate=EXPR   expression to launch archive

Report bugs to @PACKAGE_BUGREPORT@.]]

_G.arg, opts = parser:parse (_G.arg)



--[[ ================= ]]--
--[[ Helper functions. ]]--
--[[ ================= ]]--


function slurp (filename)
  local h, errmsg = io.open (filename)
  if h then
    return h:read "*a"
  end
  error (errmsg)
end



--[[ ======= ]]--
--[[ Output. ]]--
--[[ ======= ]]--


local dirsep, pathsep = package.config:match ("^([^\n]+)\n([^\n]+)\n")

-- A shell-script to embed at the top of an executable lua script
-- between 'SH=--[[' and ']]SH', so that the result can be executed
-- as a shell script that finds a compatible Lua interpreter on the
-- command search PATH.

print [==[
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

# Reexecute using the interpreter suppiled in LUA, or found above.
exec "$LUA" "$0" "$@"
]]SH
]==]


for _, f in ipairs (_G.arg) do
  local module = f:gsub ("^[%." .. dirsep .. "]*", ""):
                   gsub ("^lib" .. dirsep .. "(.*)%.lua$", "%1")
  print ('package.preload["' .. module:gsub (dirsep, ".") ..
         '"] = (function ()')
  print (slurp (f))
  print "end)"
end

print (opts.evaluate)

os.exit (0)
