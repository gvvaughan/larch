-- Copyright (c) 2013-2014 Free Software Foundation, Inc.
-- Written by Gary V. Vaughan, 2013
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
-- along with this program; see the file COPYING.  If not, write to the
-- Free Software Foundation, Fifth Floor, 51 Franklin Street, Boston,
-- MA 02111-1301, USA.

--[[--
 Macro-using Lua package searchers.

 Use macros in your source code, and add one of the searchers in this
 module to `package.loaders` to expand macros to regular Lua code
 before byte-compiling for execution.

     local loaders = require "larch.loaders"
     table.insert (package.loaders, 1, loaders.expand)

 @module larch.loaders
]]


local macro = require "macro"


-- Activate language macros.
require "larch.from"


local M  -- forward declaration



--[[ ================= ]]--
--[[ Helper Functions. ]]--
--[[ ================= ]]--


local dirsep, pathsep, path_mark = 
  string.match (package.config, "^([^\n]+)\n([^\n]+)\n([^\n]+)\n")


--- Search package.path with a transform callback for module name.
-- @string name module name to load
-- @func[opt] transform module name transform function
-- @return compiled module as a function, or `nil` if not found
-- @return 
local function searcher (name, transform)
  for m in package.path:gmatch ("([^" .. pathsep .. "])") do
    local name = name:gsub ("%.", dirsep)
    local path = m:gsub (path_mark, name)
    if transform ~= nil then path = transform (path) end
    local fh,e = io.open (path, "r")
    if fh then
      local content = fh:read "*a"
      fh:close ()
      return macro.substitute_tostring (content)
    end
  end
end


--- Search package.path with a transform callback for module name.
-- @string name module name to load
-- @func transform module name transform function
-- @return compiled module as a function, or `nil` if not found
local function loader (name, transform)
  return loadstring (searcher (name, transform), name)
end



--[[ ================= ]]--
--[[ Custom Searchers. ]]--
--[[ ================= ]]--


--- Search package.path elements for a module.
--
--     table.insert (package.loaders, 1, loader.expand)
--
-- This needs to be early in `package.path` to action macro-expansions
-- before the core searchers try to byte-compile unexpanded macros.
-- @string name module name to load
-- @return compiled module as a function, or `nil` if not found
local function expand (name)
  return loader (name)
end


--- Search package.path for modules with the '.luam' suffix.
--
--    package.loaders[#package.loaders] = loader.mexpand
-- @string name module name to load
-- @return compiled module as a function, or `nil` if not found
local function mexpand (name)
  return loader (name, function (name) return name .. "m" end)
end



--[[ ================= ]]--
--[[ Public Interface. ]]--
--[[ ================= ]]--


--- @export
M = {
  expand   = expand,
  mexpand  = mexpand,
}

return M
