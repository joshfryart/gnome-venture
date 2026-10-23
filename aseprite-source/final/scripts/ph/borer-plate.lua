-- borer-plate: one arched back plate shed by the Basalt Borer (mole-cricket).
-- Same brown body ramp, dark segment bands and lavender back sheen as creature-basalt-borer;
-- drawn as a single curved rainbow-arch of overlapping segments, with grey basalt grit
-- pressed into it from digging. Seam along the spine where the plate joined the body.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- local frame: arch centre at origin, tilted a little so it leans right
local CX, CY, A = 32, 48, math.rad(10)
local K = 0.86 -- overall size
local ca, sa = math.cos(A), math.sin(A)
local function loc(x, y) local dx, dy = x - CX, y - CY return (dx * ca + dy * sa) / K, (-dx * sa + dy * ca) / K end
local function R(test)
  local m = c:mask()
  for y = 0, 63 do for x = 0, 63 do local lx, ly = loc(x, y) if test(lx, ly) then m:set(x, y) end end end
  return m
end
local function L2C(lx, ly) lx, ly = lx * K, ly * K return math.floor(CX + lx * ca - ly * sa + 0.5), math.floor(CY + lx * sa + ly * ca + 0.5) end
local function E(x, y, rx, ry) return (x*x)/(rx*rx) + (y*y)/(ry*ry) <= 1 end

-- the arch: between an outer and inner ellipse, top half only; the feet are cut flat
local arch = R(function(x, y) return y <= 0 and E(x, y, 26, 34) and not E(x, y, 14, 19) end)
-- the cut ends show the plate's thickness (deeper brown underside)
local ends = R(function(x, y) return y > 0 and y <= 3.5 and E(x, y - 0.5, 26, 34) and not E(x, y + 2, 14, 21) end)
arch = arch:shrink(1):grow(1); ends = ends:shrink(1):grow(1)

local body = GV.ramp("#9a7447")
local p = c:build{
  { "ends", ends, GV.ramp("#6b4a2c"), { gloss = false } },
  { "arch", arch, body, { light = arch:copy():add(ends), gloss = { 14, 24 } } },
}

-- segment grooves: dark 2 px bands along rays, each with a lit lip on its upper side (shingles)
local inner = p.arch.m:shrink(1)
for _, deg in ipairs({ 140, 108, 72, 40 }) do
  local t = math.rad(deg)
  local ax, ay = L2C(14.5 * math.cos(t), -19.5 * math.sin(t))
  local bx, by = L2C(26.5 * math.cos(t), -34.5 * math.sin(t))
  local g = c:line({ { ax, ay }, { bx, by } }, 2):clip(inner)
  c:fill(g, "#2a1a10")
  -- lit shingle edge on the side toward the arch top-left
  local dx = (deg > 90) and 1 or -1
  local lip = g:shift(dx, -1):cut(g):clip(inner)
  c:fill(lip, body.rim)
end

-- lavender back sheen on the lit shoulder, as on the creature's back
local sheen = c:mask()
for i = 0, 40 do
  local t = math.rad(170 - i * 2)
  local x, y = L2C(23 * math.cos(t), -30.5 * math.sin(t))
  sheen:set(x, y)
end
sheen:clip(inner)
sheen:each(function(x, y) local q = c:get(x, y) if q ~= "#2a1a10" then c:px(x, y, "#8f7fc9") end end)

-- basalt grit pressed into the plate: small stone-grey diamonds with a glint
local function grit(lx, ly)
  local x, y = L2C(lx, ly)
  c:spot(c:ascii({ ".s.", "sss", ".s." }, x - 1, y - 1), "#5b6470", "#8b8f96")
end
grit(-17, -12); grit(5, -26); grit(17, -14)

-- seam down the spine of the plate (where it was sewn to the body), button at the left foot
local pts = {}
for i = 0, 24 do
  local t = math.rad(168 - i * 6.5)
  pts[#pts+1] = { L2C(20 * math.cos(t), -26.5 * math.sin(t)) }
end
c:seam(pts)
local bx, by = L2C(-20, -2.5)
c:button(bx - 2, by - 2)

local t = c:save(D .. "final/aseprite/ph/borer-plate.aseprite", PNG .. "borer-plate.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
