-- creature-pill-bug-brute : a grey armoured pill bug, half-curled into a high hump (side view),
-- head tucked low at the front, tail tucked under: ready to roll. Big scowling dusk head,
-- back plated as a fan of alternating stone bands.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- stone family: two alternating plate tones, slate belly, dusk-dark head
local plateA = GV.R.stone                -- #8b8f96
local plateB = GV.ramp("#5b6470")        -- stone dark
local bellyR = GV.ramp("#4a5160")
local headR  = GV.R.dusk

-- the hump: a near-circle, flattened underneath
local hump = c:ellipse(36, 27, 19.5, 19):cut(c:rect(0, 40, 63, 63))
hump:add(c:rrect(19, 33, 54, 41, 6))
-- plates are bands across the back, fanning slightly from a far hub below
local HX, HY = 36, 72
local A0, A1, N = 251, 291, 8
local function wedge(i)
  local lo, hi = A0 + (A1 - A0) * (i - 1) / N, A0 + (A1 - A0) * i / N
  if i == 1 then lo = 90 end
  if i == N then hi = 450 end
  local m = c:mask()
  hump:each(function(x, y)
    local a = math.deg(math.atan(y - HY, x - HX)) % 360
    if a < 90 then a = a + 360 end
    if a >= lo and a < hi then m:set(x, y) end
  end)
  return m
end

-- stubby legs braced under the belly (behind everything)
for _, x in ipairs({ 24, 30, 36, 42, 48 }) do
  c:limb({ { x, 41 }, { x - 2, 45 }, { x - 1, 48 } })
end

local parts = {}
parts[#parts + 1] = { "belly", c:rrect(18, 38, 54, 44, 3), bellyR, { gloss = false } }
parts[#parts + 1] = { "tail", c:ellipse(53, 43, 3, 2.5), plateB, { gloss = false } }
for i = N, 1, -1 do                          -- tail first, so each forward plate laps over the next
  local r = (i % 2 == 1) and plateA or plateB
  parts[#parts + 1] = { "plate" .. i, wedge(i), r,
    { light = hump, gloss = (i == 3) and { 26, 13 } or false, contact = false } }
end
-- big head at the front, chin tucked, ready to charge
parts[#parts + 1] = { "head", c:ellipse(19.5, 36.5, 12, 10), headR }
c:build(parts)

-- antennae with clubs, up and forward
c:limb({ { 12, 29 }, { 9, 24 }, { 10, 20 } })
c:part(c:rrect(8, 16, 11, 19, 1), headR, { flat = true })

-- armour hem: seam where the plates meet the belly, button at its head by the tail
c:seam({ { 22, 38 }, { 48, 38 } })
c:button(49, 36)

-- brute face: stone brow ridges in a scowl, locked eyes, gritted underbite with fangs
local brow, browL = "#c9c5bc", plateA.gloss
c:paint({ "lbb.......", ".bbbb.....", "...bbb...." }, 9, 31, { b = brow, l = browL })
c:paint({ ".......bbl", ".....bbbb.", "....bbb..." }, 19, 31, { b = brow, l = browL })
c:eye(11, 34); c:eye(23, 34)
c:paint({ ".uuuuuuu.", "uc.ccc.cu", ".uuuuuuu." }, 15, 41, { u = "#2a1a10", c = "#f2e4c0" })

c:ground(34, 50, 21, 1.5)
local t = c:save(D .. "final/aseprite/ph/creature-pill-bug-brute.aseprite", PNG .. "creature-pill-bug-brute.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
