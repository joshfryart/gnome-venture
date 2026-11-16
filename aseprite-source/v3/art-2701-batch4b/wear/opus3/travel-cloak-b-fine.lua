-- travel-cloak-b-fine: Fine rank, Travel Cloak cut b (folded cloak, sewn tartan patch, clothes moth). Opus richness pass.
-- Base: ../opus2/travel-cloak-b-fine.png (read only). Added (mirrors the Lined, gold where it has cream):
--  * twisted gold piping on the bottom edge of the top layer and the middle layer, and the hem piping now runs the
--    full width with an umber contact row, so the Fine reads at 16 px as gold bands on green (Lined: cream bands);
--  * the brooch is a 9x9 cast gold boss with a 4x4 faceted garnet, a cream glint and a cream sparkle (the gleam);
--  * the trailing drawstring end is a gold cord with a gold tassel hanging past the hem (quirk);
--  * the same wool twill, lit rim and teal bounce as the Lined.
-- The tartan patch, its stitches and the moth (x >= 42 above row 32) are never painted. No fleece anywhere.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o5.lua")
local Gd = O.GOLD6
local img = O.load(O.OP2 .. "travel-cloak-b-fine.png")
local function safe(x, y) return not (x >= 42 and y <= 32) end
local G = O.ramp({ "#c4dc8e", "#a8cc7a", "#86b464", "#5e9452", "#45784b", "#335f43", "#264a3c", "#1c3530", "#16282a" })
local TEAL = "#2f6a64"

O.texture(img, G, 7, 34, 52, 47, function(x, y, i)
  local k = (x + y) % 4
  if i >= 8 then return 0 end
  if k == 0 then return -1 elseif k == 2 and i <= 6 then return 1 end
end, safe)
O.texture(img, G, 8, 18, 41, 30, function(x, y, i)
  if (x + y) % 4 == 0 and i <= 7 then return -1 end
end, safe)
O.rimbounce(img, G, 5, 13, 54, 49, { ok = safe, rim = -2, bounce = TEAL, bounceOk = function(x, y) return y >= 34 end })

-- gold piping: a twist (pale/hi/base/shade by x), darker on the shaded right; umber contact row below
local function piping(x0, x1, y)
  for x = x0, x1 do
    if safe(x, y) and O.isBody(img, x, y) then
      local k, sh = x % 3, x >= 34
      O.px(img, x, y, sh and ({ Gd.base, Gd.shade, Gd.shade })[k + 1] or ({ Gd.hi, Gd.base, Gd.shade })[k + 1])
      if safe(x, y + 1) and O.isBody(img, x, y + 1) then O.px(img, x, y + 1, Gd.umber) end
    end
  end
end
piping(9, 23, 31); piping(37, 41, 31)
piping(9, 27, 39); piping(36, 50, 39)
for x = 9, 50 do  -- hem: extend the twisted row 48 and its umber row to the right corner
  if O.isBody(img, x, 48) then O.px(img, x, 48, (x % 3 == 0) and Gd.shade or ((x % 3 == 1) and Gd.hi or Gd.base)) end
  if O.isBody(img, x, 49) then O.px(img, x, 49, Gd.umber) end
end
O.px(img, 9, 48, Gd.pale)

-- brooch 9x9 with a faceted garnet
O.paint(img, 27, 37, {
  ".#######.",
  "#phhhbbs#",
  "#hbAABbd#",
  "#hAWBCbd#",
  "#bABCCsd#",
  "#bBCCDsd#",
  "#sbsssdU#",
  "#sddddUU#",
  ".#######.",
}, { p = Gd.pale, h = Gd.hi, b = Gd.base, s = Gd.shade, d = Gd.deep, U = Gd.umber,
     W = "#fff4d6", A = "#f0705a", B = "#b52e3f", C = "#7e2440", D = "#5e1c33" })
O.sparkle(img, 26, 36, Gd.pale)

-- gold drawstring end with a tassel hanging past the hem
for y = 35, 43 do if O.isBody(img, 52, y) then O.px(img, 52, y, (y % 2 == 0) and Gd.base or Gd.shade) end end
O.paint(img, 51, 43, {
  ".h.",
  "hbd",
  ".U.",
  "hbs",
  "bbs",
  "bsd",
  "b.d",
  "s.U",
}, { h = Gd.hi, b = Gd.base, s = Gd.shade, d = Gd.deep, U = Gd.umber })
O.reink(img)
O.save4(img, "travel-cloak-b-fine")
