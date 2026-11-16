-- trail-pack-b: Trail Pack, cut b "stitched patch" icon. Haiku first pass.
-- Base = game ph/trail-pack.png (pixels unchanged) plus a sea-blue cloth patch sewn onto the front pocket:
-- darker turned-under hem, gold whip stitches biting into the tan just outside it, light from the upper left.
-- quirk: a loose gold thread tail dangles off the bottom corner of the patch.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local OUT = app.params.out or (DIR .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "trail-pack-b" }
local tok = { r = { name = "base" } }

local pc = app.pixelColor
local im = Image{ fromFile = DIR .. "/../../../../game/assets/img/ph/trail-pack.png" }
for y = 0, im.height - 1 do for x = 0, im.width - 1 do
  local v = im:getPixel(x, y)
  if pc.rgbaA(v) > 0 then
    c:put(x, y, string.format("#%02x%02x%02x", pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v)), tok)
  end
end end

local ptok = { r = { name = "patch" } }
local m = HP.rrect(17, 41, 25, 49, 2)
local e = m:edge()
m:each(function(x, y)
  local col
  if e:has(x, y) then col = P.sea.deep
  else
    local s = (x - 17) + (y - 41)
    col = (s <= 4 and P.sea.hi) or (s >= 11 and P.sea.shade) or P.sea.base
  end
  c:put(x, y, col, ptok)
end)
m:grow(1):cut(m):each(function(x, y)
  if (x + y) % 3 ~= 0 then c:put(x, y, P.gold.base, ptok) end
end)
for _, p in ipairs({ {26, 50}, {26, 51}, {27, 52} }) do c:put(p[1], p[2], P.gold.hi, ptok) end

HP.assertClean(c)
c:save{ aseprite = OUT .. "trail-pack-b.aseprite", png = OUT .. "trail-pack-b.png", scale = 1 }
