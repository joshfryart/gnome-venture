-- _h.lua: tiny helper for the c09 haiku pass (own folder). Uses lib/hp.lua directly.
--   local H = dofile(dir .. "/_h.lua"); local c = H.canvas("name", 64)
--   H.save(c, "file")  -> finish outline, report, assertClean, save .aseprite + .png into H.out
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local H = { HP = HP, P = HP.P, ink = HP.P.ink, cream = HP.P.cream }
H.out = app.params.out or (dir .. "/")
function H.canvas(name, size) return HP.canvas{ w = size, h = size, scale = 1, name = name } end
function H.save(c, file)
  c:finish{ outline = true }
  HP.report(c)
  HP.assertClean(c)
  c:save{ aseprite = H.out .. file .. ".aseprite", png = H.out .. file .. ".png", scale = 1 }
end
return H
