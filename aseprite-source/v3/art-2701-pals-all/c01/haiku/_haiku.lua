-- Haiku first-pass helper for chunk c01 (Puzzle Pals). Built only on lib/hp.lua.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local M = { HP = HP, P = HP.P, dir = dir }
M.out = app.params.out or (dir .. "/")

function M.canvas(name, size)
  return HP.canvas { w = size, h = size, scale = 1, name = name }
end

-- outline, assert, save native-size .aseprite + .png
function M.done(c, name)
  c:finish { outline = true }
  HP.assertClean(c)
  c:save { aseprite = M.out .. name .. ".aseprite", png = M.out .. name .. ".png", scale = 1 }
end

return M
