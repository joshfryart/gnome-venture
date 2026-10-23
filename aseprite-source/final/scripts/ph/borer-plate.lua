-- borer-plate: a curved back plate shed by the Basalt Borer (mole-cricket).
-- Same brown body ramp, dark segment bands and lavender back sheen as creature-basalt-borer.
-- Drawn as a telescoping pauldron: three arched segments that nest into each other,
-- with a dark underside lip along the flat base, grey basalt grit pressed in from digging,
-- and a seam along the hem of the front segment where it was sewn on.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- local frame: base centre at origin, y up is negative, tilted so the plate leans right
local CX, CY, A = 31, 47, math.rad(-12)
local ca, sa = math.cos(A), math.sin(A)
local function loc(x, y) local dx, dy = x - CX, y - CY return dx * ca + dy * sa, -dx * sa + dy * ca end
local function R(test)
  local m = c:mask()
  for y = 0, 63 do for x = 0, 63 do local lx, ly = loc(x, y) if test(lx, ly) then m:set(x, y) end end end
  return m
end
local function L2C(lx, ly) return math.floor(CX + lx * ca - ly * sa + 0.5), math.floor(CY + lx * sa + ly * ca + 0.5) end
local function E(x, y, cx, cy, rx, ry) return ((x-cx)/rx)^2 + ((y-cy)/ry)^2 <= 1 end

-- segments: back (largest) to front (smallest); all share one arched hem b(x) that is high
-- in the middle and curls down at the ends, so the plate reads as a curved shell
local function b(x) return -4 + 7 * (x / 24)^2 end
local function seg(rx, ry)
  return R(function(x, y) return E(x, y, 0, 3, rx, ry) and y <= b(x) end)
end
local s1 = seg(25, 34)
local s2 = seg(19.5, 24.5)
local s3 = seg(13.5, 15)
-- underside lip: the thickness of the plate showing under the hem
local lip = R(function(x, y) return y > b(x) and y <= b(x) + 4 and E(x, y, 0, 3, 24.5, 34) end)
s1 = s1:shrink(1):grow(1); lip = lip:shrink(1):grow(1)

local body = GV.ramp("#9a7447")
local whole = s1:copy():add(lip)
local p = c:build{
  { "lip", lip, GV.ramp("#6b4a2c"), { gloss = false } },
  { "s1", s1, body, { light = whole, gloss = { 14, 24 } } },
  { "s2", s2, body, { gloss = false, cres = 3 } },
  { "s3", s3, body, { gloss = { 22, 39 }, cres = 3 } },
}
-- dark 2 px segment gaps where each segment tucks under the one behind (creature's bands)
local base = R(function(x, y) return y <= b(x) - 1 end)
for _, sm in ipairs({ s2, s3 }) do
  local gap = sm:grow(2):cut(sm):clip(base):clip(p.s1.m:shrink(1))
  c:fill(gap, "#2a1a10")
end

-- lavender back sheen arcs on the lit shoulder of the two back segments, as on the creature
local function sheen(rx, ry, base, a0, a1)
  for i = a0, a1, 2 do
    local t = math.rad(i)
    local x, y = L2C(rx * math.cos(t), base - ry * math.sin(t))
    local q = c:get(x, y)
    if q == body.base then c:px(x, y, "#8f7fc9") end
  end
end
sheen(21.5, 30.5, 3, 112, 158)
sheen(16, 21, 3, 118, 156)

-- seam along the hem of the front segment, button at its head
local pts = {}
for i = 0, 18 do
  local t = math.rad(165 - i * 150 / 18)
  pts[#pts+1] = { L2C(10.5 * math.cos(t), 3 - 12 * math.sin(t)) }
end
c:seam(pts)
local bx, by = L2C(-10.5, -1)
c:button(bx - 1, by - 2)

-- basalt grit pressed into the felt: small stone-grey diamonds with a pale glint
local function grit(lx, ly)
  local x, y = L2C(lx, ly)
  c:spot(c:ascii({ ".s.", "sss", ".s." }, x - 1, y - 1), "#5b6470", "#8b8f96")
end
grit(4, -27); grit(18, -6); grit(-15, -15)

local t = c:save(D .. "final/aseprite/ph/borer-plate.aseprite", PNG .. "borer-plate.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
