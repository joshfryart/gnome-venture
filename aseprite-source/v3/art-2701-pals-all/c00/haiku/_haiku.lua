-- _haiku.lua: tiny shared helper for the c00 Haiku first pass (Puzzle Pals). Built only on lib/hp.lua.
--   local M = dofile(dir .. "/_haiku.lua"); local c = M.canvas("name", 64); ...; M.done(c, "file")
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local M = { HP = HP, P = HP.P }
M.out = app.params.out or (dir .. "/")
function M.canvas(name, size) return HP.canvas{ w = size, h = size, scale = 1, name = name } end
function M.done(c, file)
  c:finish{ outline = true }
  HP.report(c, true)
  HP.assertClean(c)
  c:save{ aseprite = M.out .. file .. ".aseprite", png = M.out .. file .. ".png", scale = 1 }
end
return M
