-- packet (flowers P2_F4)
local out = app.params["out"] or "./"
local V = dofile(out .. "_vessel_lib.lua")
local PA = V.ramp{"#8a5c34","#b5834a","#d2a566","#e6c283","#f1d9a3","#f9ecc6"}
local GR = V.ramp{"#2f6b3a","#4f9d5d","#7ac27a"}
local LBL = V.hex("#f4e9c9")      -- label panel: flat plain paper (x17..47, y26..51 kept EMPTY)
local INKB = V.hex("#6a4a2e")
local function flap(x, y) return x >= 45 and x <= 53 and y >= 50 and y <= 58 and x + y <= 102 and x + y >= 94 end
local function paper(x, y)
  if x < 10 or x > 53 or y < 6 or y > 58 then return false end
  if y == 6 and x % 4 == 3 then return false end            -- crimped top edge
  if x + y > 102 then return false end                       -- dog-ear cut
  return true
end
local L = V.layer(64, 64)
for y = 5, 59 do for x = 9, 54 do
  if paper(x, y) then
    local v = 0.66 - (x - 10) / 44 * 0.25 - (y - 6) / 52 * 0.2
    local i = V.clamp(math.floor(v * 6) + 1, 1, 6)
    if y <= 11 then i = (x % 2 == 0) and 4 or 3; if y == 11 then i = 2 end   -- crimp ridges + fold line
    elseif x == 10 or x == 11 then i = 5
    elseif x >= 52 then i = 2
    elseif y >= 57 then i = 2 end
    if y > 11 and V.hash(x, y, 4) > 0.955 then i = V.clamp(i + (V.hash(x, y, 5) > 0.5 and 1 or -1), 1, 6) end
    L.p[y * 64 + x] = PA[i]
  end
end end
-- printed header band + title dashes
for y = 14, 18 do for x = 12, 51 do L.p[y * 64 + x] = GR[(y == 14) and 3 or ((y == 18) and 1 or 2)] end end
for x = 20, 44 do if x % 7 ~= 6 then L.p[21 * 64 + x] = INKB end end
for x = 24, 40 do if x % 5 ~= 4 then L.p[23 * 64 + x] = INKB end end
-- label frame (inset) then the empty plain panel
for x = 16, 48 do L.p[25 * 64 + x] = PA[2]; L.p[52 * 64 + x] = PA[6] end
for y = 25, 52 do L.p[y * 64 + 16] = PA[2]; L.p[y * 64 + 48] = PA[6] end
for y = 26, 51 do for x = 17, 47 do L.p[y * 64 + x] = LBL end end
-- seeds rattling under the label
for _, sx in ipairs{24, 31, 38} do L.p[55 * 64 + sx] = INKB; L.p[55 * 64 + sx + 1] = INKB end
-- QUIRK: dog-eared bottom-right corner (underside of the paper shows)
for y = 50, 58 do for x = 45, 53 do
  if flap(x, y) then
    local c = PA[5]
    if x == 45 or y == 50 then c = V.INK elseif x + y >= 101 then c = PA[3] end
    L.p[y * 64 + x] = c
  end
end end
local function solid(x, y) return paper(x, y) end
V.outline(L, solid, 0, 63)
V.save(out, "packet", {{name = "packet", L = L}})
