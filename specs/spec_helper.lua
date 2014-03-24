local hell = require "specl.shell"

function larch (...)
  local LARCH = os.getenv "LARCH" or "bin/larch"
  return hell.spawn {
    LARCH, ...,
    env = { LUA_PATH=package.path },
  }
end
