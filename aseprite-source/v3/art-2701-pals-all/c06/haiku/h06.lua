-- h06.lua: shared tools for the c06 Haiku pal pass (art-2701-pals-all/c06/haiku).
-- Every sprite script (<key>-yard.lua, <key>-perch.lua) draws its own shapes with the v3 lib;
-- this file only holds the output and a couple of helpers.
--   local H = dofile(dir .. "/h06.lua"); local c = H.canvas("name", 64)
--   H.dot(c, x, y, hex)  H.flat(c, mask, hex)  H.done(c, "name")
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local H = { HP = HP, P = HP.P }
H.out = app.params.out or (dir .. "/")

function H.canvas(name, size) return HP.canvas{ w = size, h = size, scale = 1, name = name } end

-- single hard pixel that counts as a solid part (gets outlined, later parts paint over it)
function H.dot(c, x, y, hex) c:put(x, y, hex, { r = { name = "dot" } }) end
function H.dots(c, list, hex) for _, p in ipairs(list) do H.dot(c, p[1], p[2], hex) end end
-- flat fill that counts as a solid part (no shading)
function H.flat(c, m, hex)
  local tok = { r = { name = "flat" } }
  m:each(function(x, y) c:put(x, y, hex, tok) end)
  return m
end

-- finish: 1 px ink outline, report, assert clean, save .aseprite + native-size .png
function H.done(c, file)
  c:finish{ outline = true }
  HP.report(c)
  HP.assertClean(c)
  c:save{ aseprite = H.out .. file .. ".aseprite", png = H.out .. file .. ".png", scale = 1 }
end

return H
