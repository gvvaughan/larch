-- Specl provided modules...
local inprocess = require "specl.inprocess"
local std       = require "specl.std"

-- ...which we use to add local larch directory to search path.
package.path = std.package.normalize ("lib/?.lua", package.path)

-- Language macros.
macro = require "macro"
require "larch.from"

-- Now we can insert the macro expanding module loader...
local loader = require "larch.loader"
if package.loaders[1] ~= loader.expand then
  table.insert (package.loaders, 1, loader.expand)
end

-- ...and use that to load the main module.
local main = require "larch.main"


-- Check output, post config substitutions.
function spawn (...)
  local LARCH = os.getenv "LARCH" or "bin/larch"
  return require "specl.shell".spawn {
    LARCH, ...,
    env = { LUA_PATH=package.path },
  }
end

-- Run unsubstituted code directly in the Specl process.
function larch (...)
  return inprocess.call (main, {...})
end
