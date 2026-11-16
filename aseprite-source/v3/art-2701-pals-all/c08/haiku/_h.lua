-- Haiku pass helper for the c08 Puzzle Pals batch. Thin wrapper over the shared Hearth Pop lib.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local H = { HP = HP, P = HP.P }

function H.canvas(name, size)
  return HP.canvas{ w = size, h = size, scale = 1, name = name }
end

function H.done(c, name)
  c:finish{ outline = true }
  HP.report(c, true)
  HP.assertClean(c)
  local out = app.params.out or (dir .. "/")
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end

return H
