-- lair-of-the-hurricane-crab.lua : Boss lair (CB, zone 4). "Its shell is a whole island." Storm. Params out= ase=
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local HOR = 90
L.sky(c, "storm", HOR)
-- hurricane swirl clouds: dark bands with lighter undersides
for i, cl in ipairs({ {30,16,30},{110,10,36},{190,18,32},{70,36,26},{160,34,30},{225,40,20},{12,44,18},{118,50,22} }) do
  L.cloud(c, cl[1], cl[2], cl[3], (i % 2 == 0) and "#5a6478" or "#3a4256", (i % 2 == 0) and "#808a9a" or "#4a5468")
end
-- eye of the storm: a pale break behind the crab
c:fill(c:ellipse(120, 52, 22, 6), "#aab0ba"); c:fill(c:ellipse(120, 54, 14, 3), "#d8dce4")
-- lightning
c:fill(c:line({ {44,22},{38,34},{44,36},{36,52} }, 2), "#fff1c8")
c:fill(c:line({ {202,26},{208,38},{202,40},{210,56} }, 2), "#f5cf6a")
-- rain streaks
for i = 0, 40 do local x = (i * 29 + 7) % W; local y = (i * 53) % 90; c:px(x, y, "#cfd8e4"); c:px(x - 1, y + 1, "#cfd8e4") end
-- sea
L.water(c, HOR + 1, { "#3f6a8a", "#365e80", "#2f5272", "#2a4868", "#243e5e", "#1e3454" })
for i = 0, 16 do local x = (i * 41 + 5) % (W - 12); local y = HOR + 4 + (i * 13) % 38; c:fill(c:rect(x, y, x + 8, y), "#8aa8c8"); c:fill(c:rect(x + 3, y + 1, x + 6, y + 1), "#cfd8e4") end

-- crab legs (behind), planted in the sea
for _, sx in ipairs({ -1, 1 }) do
  for k = 0, 2 do
    local x0 = 120 + sx * (36 + k * 8)
    c:part(c:line({ {x0, 100 + k * 2}, {x0 + sx * 24, 94 + k * 3}, {x0 + sx * 34, 112 + k * 2} }, 5), GV.ramp("#d6322b"), { cres = 2, deep = 3, gloss = false })
  end
end
-- the shell: a whole island
local shell = c:ellipse(120, 82, 80, 30); shell:cut(c:rect(0, 106, W, H))
c:part(shell, GV.ramp("#b8452f"), { cres = 9, deep = 13 })
-- shell ridges
c:seam({ {58,86},{80,76},{110,72} }, { on = 3, off = 1 }); c:seam({ {182,86},{160,76},{130,72} }, { on = 3, off = 1 })
for _, p in ipairs({ {72,96},{96,100},{144,100},{168,96} }) do c:part(c:ellipse(p[1], p[2], 3, 2), GV.ramp("#f2e4c0"), { flat = true, gloss = false, outline = false }) end
-- island on top: sandy beach rim, grassy hill, rocks
c:part(c:ellipse(120, 62, 52, 12), GV.ramp("#c9a96e"), { cres = 3, deep = 4, gloss = false })
c:part(c:ellipse(116, 56, 40, 9), GV.ramp("#7ab55c"), { cres = 3, deep = 5, gloss = false })
c:part(c:ellipse(108, 50, 20, 7), GV.ramp("#6a9a3a"), { cres = 2, deep = 4, gloss = false })
-- palms
local function palm(x, y, h, lean)
  c:fill(c:line({ {x, y}, {x + lean, y - h} }, 2), "#8a4f2a")
  local tx, ty = x + lean, y - h
  for _, d in ipairs({ {-11,3},{-8,-3},{-3,-6},{4,-6},{9,-3},{12,3} }) do
    c:part(c:line({ {tx, ty}, {tx + d[1] * 0.5, ty + d[2] - 2}, {tx + d[1], ty + d[2] + 3} }, 3), GV.ramp("#4a8a3e"), { flat = true, gloss = false })
  end
end
palm(94, 58, 20, -3); palm(142, 60, 24, 4); palm(126, 55, 14, 2)
-- little gnome hut on the island
c:part(c:rect(100, 46, 111, 54), GV.ramp("#e9b98a"), { gloss = false, cres = 3 })
c:part(c:poly({ {98,47},{105,38},{113,47} }), "red", { cres = 3, deep = 5 })
c:part(c:rrect(104, 49, 107, 54, 1), GV.ramp("#7a4a1f"), { outline = false, gloss = false })
c:fill(c:rect(109, 49, 110, 50), "#f5cf6a")
-- flag on the hut, snapping in the wind
c:fill(c:rect(105, 30, 105, 38), "#2a1a10"); c:part(c:poly({ {106,30},{116,32},{106,35} }), GV.ramp("#e8a317"), { flat = true, outline = false })
-- the face: lower body, stalks, angry eyes
c:part(c:ellipse(120, 108, 34, 9), GV.ramp("#d6322b"), { cres = 4, deep = 6 })
for _, ex in ipairs({ 98, 138 }) do
  c:part(c:rect(ex + 1, 96, ex + 3, 108), GV.ramp("#b8452f"), { flat = true })
  c:eye(ex - 1, 90)
  local d = (ex < 120) and 1 or -1
  for k = 0, 4 do local xx = (d == 1) and (ex - 1 + k) or (ex + 3 - k); c:px(xx, (k < 3) and 88 or 89, "#2a1a10") end
end
-- mouth: grumpy line with two little tusk-like teeth
c:fill(c:rect(110, 109, 130, 109), "#2a1a10"); c:fill(c:rect(108, 110, 109, 110), "#2a1a10"); c:fill(c:rect(131, 110, 132, 110), "#2a1a10")
c:fill(c:rect(113, 110, 114, 112), "#f2e4c0"); c:fill(c:rect(126, 110, 127, 112), "#f2e4c0")
-- giant claws raised on both sides
local function claw(x, y, dir)
  c:part(c:line({ {x - dir * 22, 104}, {x - dir * 8, 90}, {x, y + 12} }, 6), GV.ramp("#d6322b"), { cres = 3, deep = 4, gloss = false })
  local m = c:ellipse(x, y, 14, 12); m:cut(c:poly({ {x - 3, y - 15}, {x + 3, y - 15}, {x, y + 1} }))
  c:part(m, GV.ramp("#d6322b"), { cres = 5, deep = 8 })
end
claw(34, 66, -1); claw(206, 66, 1)
-- foreground waves and spray over the crab's feet
for _, w in ipairs({ {6,120,16},{36,124,22},{80,118,20},{128,122,24},{172,119,18},{200,125,26},{20,130,14},{110,129,20} }) do
  c:fill(c:rect(w[1], w[2], w[1] + w[3], w[2] + 1), "#5a86b8"); c:fill(c:rect(w[1] + 3, w[2] - 1, w[1] + w[3] - 3, w[2] - 1), "#cfd8e4")
end
-- little boat of gnomes tossed on the waves (scale joke)
c:part(c:poly({ {16,114},{36,114},{32,121},{20,121} }), GV.ramp("#b07a45"), { cres = 2, deep = 3, gloss = false })
c:fill(c:rect(25, 102, 25, 113), "#2a1a10"); c:part(c:poly({ {26,103},{26,112},{34,112} }), GV.ramp("#f2e4c0"), { flat = true, outline = false })
L.finish(c, "lair-of-the-hurricane-crab")
