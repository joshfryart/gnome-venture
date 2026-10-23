-- ph/glass-thread : one fine glassy strand from the Crystal Weaver, wound into a loose
-- springy coil lying on the diagonal, a stray end curling off and a ringing glass bead
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- coil axis from lower-left to upper-right
local AX, AY, BX, BY = 19, 42, 41, 24
local L = math.sqrt((BX - AX) ^ 2 + (BY - AY) ^ 2)
local ux, uy = (BX - AX) / L, (BY - AY) / L      -- along the axis
local px, py = -uy, ux                           -- across the axis (points up-left)
local TURNS, R, r = 2.5, 12, 5
local T = TURNS * 2 * math.pi

local back, front = c:mask(), c:mask()
local function run(pts, into) if #pts >= 2 then into:add(c:line(pts, 2)) end end
local cur, curFront = {}, nil
for i = 0, 420 do
  local t = i / 420 * T
  local a = L * t / T + r * math.sin(t)
  local x = AX + ux * a + px * R * math.cos(t)
  local y = AY + uy * a + py * R * math.cos(t)
  local isFront = math.sin(t) >= 0
  if curFront ~= nil and isFront ~= curFront then
    cur[#cur + 1] = { x, y }
    run(cur, curFront and front or back); cur = {}
  end
  curFront = isFront
  cur[#cur + 1] = { x, y }
end
run(cur, curFront and front or back)

-- loose ends: a stray tail curling off the bottom, a free end up top with a bead
local tail = c:line({ { AX + px * R, AY + py * R }, { 9, 38 }, { 7, 44 }, { 9, 50 }, { 15, 52 }, { 22, 53 } }, 2)
local topEnd = { BX + px * R * math.cos(T), BY + py * R * math.cos(T) }
local loose = c:line({ topEnd, { 46, 12 }, { 50, 9 }, { 54, 10 } }, 2)
local bead = c:ellipse(54.5, 13, 2.5, 2.5)

local glass = GV.R.glass
local dim = GV.ramp("#6f98c4", { rim = "#8fb4d6" })
c:build{
  { "back", back:add(tail), dim, { flat = true, contact = false } },
  { "front", front:add(loose), glass, { flat = true, contact = false } },
  { "bead", bead, glass, { gloss = false, cres = 2, deep = 1 } },
}
c:px(53, 12, "#f8fcf4")

-- glints running along the front strands (1 px, upper-left of each front pass)
for k = 0, TURNS - 1 do
  local t = (k + 0.25) * 2 * math.pi
  local a = L * t / T + r * math.sin(t)
  local x = AX + ux * a + px * R * math.cos(t)
  local y = AY + uy * a + py * R * math.cos(t)
  c:px(math.floor(x + 0.5), math.floor(y + 0.5), "#eef8f2")
end


local t = c:save(D .. "final/aseprite/ph/glass-thread.aseprite", PNG .. "glass-thread.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
