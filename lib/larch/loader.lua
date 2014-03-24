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
 module to `package.loader` to expand macros to regular Lua code
 before byte-compiling for execution.

     local loader = require "larch.loader"
     table.insert (package.loaders, 1, loader.expand)

 @module larch.loader
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


--- Ensure pattern meta-characters are escaped with a leading '%'.
-- @string s a string
-- @return s with pattern meta-characters escaped
local function esc (s)
  return (string.gsub (s, "[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0"))
end


--- Search package.path with a transform callback for module name.
-- @string name module name to load
-- @func transform module name transform function
-- @return compiled module as a function, or `nil` if not found
local function searcher (name, transform)
  local errbuf = {}
  for m in package.path:gmatch ("([^" .. esc (pathsep) .. "]+)") do
    local path = transform (m:gsub (esc (path_mark), (name:gsub ("%.", dirsep))))
    local fh, err = io.open (path, "r")
    if fh == nil then
      errbuf[#errbuf + 1] = "\topen file '" .. path .. "' failed: " .. err
    else

      -- Found and opened...
      local source = fh:read "*a"
      fh:close ()
      local content, err = macro.substitute_tostring (source)
      if content == nil and err ~= nil then
        errbuf[#errbuf + 1] = "\tmacro expansion failed in '" .. path.. "': " .. err
      else

	-- ...and macro substituted...
        local loadfn, err = loadstring (content, name)
        if type (loadfn) ~= "function" then
         errbuf[#errbuf + 1] = "\tloadstring '" .. path .. "' failed: " .. err
        else

          -- ...and successfully loaded! Return it!
          return loadfn
        end
      end
    end
  end

  -- Paths exhausted, return the list of failed attempts.
  return table.concat (errbuf, "\n")
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
  return searcher (name, function (name) return name end)
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
return {
  expand   = expand,
  mexpand  = mexpand,
  searcher = searcher,
}
