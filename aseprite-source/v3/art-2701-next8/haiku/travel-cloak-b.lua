-- travel-cloak-b: Travel Cloak, cut b "stitched patch" icon. Haiku first pass.
-- Base = game ph/travel-cloak.png (pixels unchanged) plus a violet cloth patch sewn on the left panel:
-- a little diagonal weave, darker turned-under edge, gold whip stitches around the outside.
-- quirk: a single gold button sewn in the middle of the patch.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local OUT = app.params.out or (DIR .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "travel-cloak-b" }
local tok = { r = { name = "base" } }

local pc = app.pixelColor
local im = Image{ fromFile = DIR .. "/../../../../game/assets/img/ph/travel-cloak.png" }
for y = 0, im.height - 1 do for x = 0, im.width - 1 do
  local v = im:getPixel(x, y)
  if pc.rgbaA(v) > 0 then
    c:put(x, y, string.format("#%02x%02x%02x", pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v)), tok)
  end
end end

local ptok = { r = { name = "patch" } }
local m = HP.rrect(13, 25, 21, 33, 1)
local e = m:edge()
m:each(function(x, y)
  local col
  if e:has(x, y) then col = P.dusk.deep
  elseif (x + y) % 4 == 0 then col = P.dusk.shade
  elseif (x + y) <= 27 then col = P.dusk.hi
  else col = P.dusk.base end
  c:put(x, y, col, ptok)
end)
m:grow(1):cut(m):each(function(x, y)
  if (x + y) % 3 ~= 0 then c:put(x, y, P.gold.base, ptok) end
end)
c:button(17, 29)

HP.assertClean(c)
c:save{ aseprite = OUT .. "travel-cloak-b.aseprite", png = OUT .. "travel-cloak-b.png", scale = 1 }
