-- creature-pill-bug-brute : a grey armoured pill bug, half-curled into a "C" (side view),
-- ready to roll. Big scowling dusk head at the front end, plated back as alternating stone bands.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- stone family: two alternating plate tones, slate belly, dusk-dark head
local plateA = GV.R.stone                -- #8b8f96
local plateB = GV.ramp("#6e7580")        -- slate step between stone #5b6470 and #8b8f96
local bellyR = GV.ramp("#5b6470")
local headR  = GV.R.dusk

local CX, CY, R0, R1 = 35.5, 26.5, 6, 21   -- curl centre, inner and outer radius
local ball = c:ellipse(CX, CY, R1, R1)

-- plate wedges: angles in degrees, screen coords (0 = right, 90 = down, 180 = left, 270 = up)
local A0, A1, N = 150, 410, 9               -- from the head (lower left) over the top to the tail (lower right)
local function ang(x, y)
  local a = math.deg(math.atan(y - CY, x - CX)) % 360
  if a < 100 then a = a + 360 end
  return a
end
local function wedge(i)
  local lo, hi = A0 + (A1 - A0) * (i - 1) / N, A0 + (A1 - A0) * i / N
  local m = c:mask()
  ball:each(function(x, y)
    local d = math.sqrt((x - CX) ^ 2 + (y - CY) ^ 2)
    local a = ang(x, y)
    if d >= R0 and a >= lo and a < hi then m:set(x, y) end
  end)
  return m
end

-- open belly of the curl (between tail and head) with tucked legs
local belly = c:mask()
ball:each(function(x, y) local a = ang(x, y) if a >= 410 and a < 460 or (a < 150 and a >= 100) then belly:set(x, y) end end)
belly:add(c:ellipse(CX, CY + 2, R0 + 2, R0 + 2))
c:part(belly, bellyR, { gloss = false })
c:limb({ {33, 34}, {31, 41}, {33, 45} })
c:limb({ {38, 35}, {39, 41}, {41, 45} })
c:limb({ {43, 33}, {46, 38}, {48, 42} })

local parts = {}
for i = N, 1, -1 do                          -- tail first, so each forward plate laps over the next
  local r = (i % 2 == 1) and plateA or plateB
  parts[#parts + 1] = { "plate" .. i, wedge(i), r,
    { light = ball, gloss = (i == 4) and { 25, 12 } or false, contact = false } }
end
-- flank hub where the plates meet
parts[#parts + 1] = { "hub", c:ellipse(CX, CY, R0 + 0.5, R0 + 0.5), plateA, { light = ball, gloss = false } }
-- big head at the front end, chin down, ready to charge
parts[#parts + 1] = { "head", c:ellipse(20, 37.5, 12.5, 10.5), headR, { gloss = { 11, 32 } } }
-- stone head shield: heavy brow plate dipping into a V between the eyes
parts[#parts + 1] = { "brow", c:poly({ {9, 30}, {20, 34}, {21, 34}, {32, 30}, {32, 33}, {21, 37}, {20, 37}, {9, 33} }), plateA, { gloss = false } }
c:build(parts)

-- antennae with clubs, swept forward
c:limb({ {11, 31}, {8, 26}, {9, 22} })
c:limb({ {16, 29}, {15, 24}, {17, 20} })
c:part(c:rrect(7, 18, 10, 21, 1), headR, { flat = true })
c:part(c:rrect(16, 16, 19, 19, 1), headR, { flat = true })

-- armour hem: seam along the inner edge of the plates, button at its head by the tail
local sp = {}
for a = 160, 400, 4 do
  local r = math.rad(a)
  sp[#sp + 1] = { math.floor(CX + (R0 + 2) * math.cos(r) + 0.5), math.floor(CY + (R0 + 2) * math.sin(r) + 0.5) }
end
c:seam(sp)

-- brute face: locked eyes under the brow, gritted underbite with two up-fangs
c:eye(12, 35); c:eye(24, 35)
c:paint({ ".uuuuuuu.", "uc.ccc.cu", ".uuuuuuu." }, 14, 42, { u = "#2a1a10", c = "#f2e4c0" })

c:ground(33, 50, 20, 1.5)
local t = c:save(D .. "final/aseprite/ph/creature-pill-bug-brute.aseprite", PNG .. "creature-pill-bug-brute.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
