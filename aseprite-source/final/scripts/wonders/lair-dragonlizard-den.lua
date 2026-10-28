-- lair-dragonlizard-den.lua : boss lair, SEA, bright jungle day. A huge monitor lizard before a cave in a karst tower.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, c, W, H = L.GV, L.new(), L.W, L.H
local SLUG = "lair-dragonlizard-den"

L.sky(c, "day", 104)
L.cloud(c, 40, 22, 20); L.cloud(c, 170, 14, 22); L.cloud(c, 112, 32, 14)
-- far hazy karst towers
local function karst(x0, x1, top, base, col, topcol)
  local m = c:poly({ {x0,base},{x0+4,top+14},{x0+10,top+4},{(x0+x1)/2,top},{x1-8,top+5},{x1-3,top+16},{x1,base} })
  c:fill(m, col); c:fill(m:copy():clip(c:rect(0, 0, W, top + 5)), topcol)
end
karst(70, 100, 40, 100, "#8cc0b0", "#7ab08a"); karst(150, 176, 34, 100, "#8cc0b0", "#7ab08a"); karst(200, 240, 44, 100, "#84b8aa", "#7ab08a")
-- jungle floor
local fl = L.below(c, function(x) return 96 + 2 * math.sin(x / 20) end)
c:fill(fl, "#5aa04a"); c:fill(fl:copy():clip(c:rect(0, 112, W, H)), "#4a8a3e"); c:fill(fl:copy():clip(c:rect(0, 124, W, H)), "#3a7a38")
for i = 0, 40 do local x = (i * 59 + 11) % W; local y = 100 + (i * 13) % 28; c:px(x, y, "#a4b86a"); c:px(x + 1, y - 1, "#c8d77a"); c:px(x + 2, y, "#a4b86a") end

-- the big karst tower with the den (centre-left)
local tower = c:poly({ {50,104},{56,70},{64,40},{80,22},{104,14},{128,16},{146,30},{154,56},{158,84},{164,104} })
c:part(tower, GV.ramp("#a8b4a0"), { cres = 9, deep = 14, gloss = false })
-- green growth on the crown and ledges
c:fill(c:poly({ {64,40},{80,22},{104,14},{128,16},{146,30},{138,34},{124,28},{108,30},{92,28},{78,36},{70,44} }), "#4a8a3e")
c:fill(c:poly({ {80,24},{104,15},{128,17},{140,26},{124,22},{104,22},{86,28} }), "#7ab55c")
for _, v in ipairs({ {86,44,56},{96,36,50},{138,40,60},{128,34,48} }) do c:fill(c:rect(v[1], v[2], v[1], v[3]), "#4a8a3e"); c:px(v[1] - 1, v[3], "#7ab55c") end
-- cave mouth
local cave = c:ellipse(106, 88, 22, 24):clip(c:rect(0, 40, W, 90)); cave:add(c:rect(84, 88, 128, 104))
c:fill(cave, "#3e2f66")
local cave2 = c:ellipse(106, 90, 18, 20):clip(c:rect(0, 40, W, 90)); cave2:add(c:rect(88, 90, 124, 104))
c:fill(cave2, "#291d4a")
-- cave eyes of the dragonlizard's hoard: glints of treasure
for _, p in ipairs({ {96,98},{104,95},{114,98},{120,95} }) do c:px(p[1], p[2], "#f5cf6a"); c:px(p[1] + 1, p[2], "#e8a317") end
c:fill(c:rect(86, 102, 126, 104), "#c9a96e")
-- hanging vines at the mouth
for _, x in ipairs({ 86, 92, 122, 128 }) do for y = 64, 76 + (x % 4) * 3 do c:px(x + (y % 4 == 0 and 1 or 0), y, "#4a8a3e") end c:px(x, 80 + (x % 4) * 3, "#7ab55c") end

-- right small hill with a tall palm
c:part(c:poly({ {188,104},{196,82},{214,70},{232,76},{240,86},{240,104} }), GV.ramp("#6aa860"), { cres = 6, deep = 9, gloss = false })
local function palm(x, y, h)
  for i = 0, h do c:fill(c:rect(x + math.floor(1.5 * math.sin(i / 8)) , y - i, x + math.floor(1.5 * math.sin(i / 8)) + 2, y - i), (i % 3 == 0) and "#8a4f2a" or "#b07a45") end
  local tx = x + math.floor(1.5 * math.sin(h / 8)) + 1; local ty = y - h
  for _, d in ipairs({ { -16, 6 }, { -10, -2 }, { 0, -6 }, { 10, -2 }, { 16, 6 } }) do
    c:part(c:poly({ {tx - 1, ty}, {tx + d[1], ty + d[2] + 2}, {tx + d[1] * 0.5, ty + d[2] - 4}, {tx + 1, ty} }), GV.ramp("#4a8a3e"), { flat = true, gloss = false })
  end
  c:part(c:ellipse(tx, ty + 2, 2.5, 2.5), GV.ramp("#8a4f2a"), { flat = true, gloss = false })
end
palm(206, 78, 44); palm(32, 100, 56)

-- the Dragonlizard (huge monitor lizard) facing left
local lz = GV.ramp("#8a8a4a", { gloss = "#c8c878", rim = "#b0b060", shade = "#5a6a3a", deep = "#3a4a2a" })
local BX, BY = 128, 104
-- tail
c:part(c:line({ {160,104},{190,112},{214,114},{232,106} }, 8), lz, { cres = 3, deep = 5, gloss = false })
c:part(c:line({ {214,114},{232,106},{236,98} }, 4), lz, { flat = true, gloss = false })
-- far-side legs
c:part(c:ellipse(98, 118, 6, 6), lz, { flat = true, gloss = false }); c:part(c:ellipse(160, 118, 6, 6), lz, { flat = true, gloss = false })
-- body
c:part(c:ellipse(BX, BY, 42, 17), lz, { cres = 7, deep = 11 })
-- belly band and dorsal diamonds
c:part(c:ellipse(BX, BY + 12, 34, 6):clip(c:rect(0, BY + 8, W, BY + 22)), GV.ramp("#d8c488", { dot = "#fff3c8" }), { flat = true, gloss = false, outline = false, contour = "#5a6a3a" })
for i = 0, 7 do
  local x = 96 + i * 9
  c:fill(c:poly({ {x, BY - 14}, {x + 4, BY - 10}, {x, BY - 6}, {x - 4, BY - 10} }), "#5a4a2a"); c:px(x, BY - 11, "#d8c070")
end
-- near legs over the body
c:part(c:ellipse(92, 116, 8, 7), lz, { cres = 3, deep = 5, gloss = false }); c:part(c:ellipse(158, 116, 8, 7), lz, { cres = 3, deep = 5, gloss = false })
for _, x in ipairs({ 86, 91, 96, 152, 157, 162 }) do c:fill(c:rect(x, 121, x + 1, 122), "#f2e4c0") end
-- neck and head
c:part(c:ellipse(78, 99, 12, 9), lz, { cres = 4, deep = 6, gloss = false })
c:part(c:ellipse(60, 98, 17, 11), lz, { cres = 5, deep = 8 })
c:part(c:ellipse(44, 101, 11, 6), lz, { cres = 3, deep = 5, gloss = false })
c:eye(55, 90)
c:fill(c:rect(33, 104, 55, 104), "#2a1a10")           -- long grin
c:px(32, 103, "#2a1a10"); c:px(56, 103, "#2a1a10")
for _, x in ipairs({ 38, 44, 50 }) do c:px(x, 105, "#f2e4c0") end
c:px(36, 99, "#2a1a10"); c:px(37, 99, "#2a1a10")      -- nostril
-- forked tongue
c:fill(c:rect(20, 103, 32, 104), "#d6322b"); c:px(18, 101, "#d6322b"); c:px(19, 102, "#d6322b"); c:px(18, 106, "#d6322b"); c:px(19, 105, "#d6322b")
-- scales on the head and neck
for _, p in ipairs({ {64,92},{70,98},{74,88},{80,94},{60,96} }) do c:px(p[1], p[2], "#5a6a3a") end

-- foreground leaves and flowers
for _, l in ipairs({ { {0,H},{0,108},{10,114},{26,122},{40,H} }, { {W,H},{W,106},{228,112},{212,122},{198,H} } }) do
  c:part(c:poly(l), GV.ramp("#3a7a38"), { cres = 5, deep = 8, gloss = false })
end
for _, f in ipairs({ {14,120,"#e46a9b"},{30,126,"#f08a24"},{218,120,"#e46a9b"},{206,127,"#f5cf6a"} }) do
  c:part(c:ellipse(f[1], f[2], 3, 3), GV.ramp(f[3]), { flat = true, gloss = false }); c:px(f[1], f[2], "#f5cf6a")
end
-- a banana bunch left as an offering
c:part(c:ellipse(76, 124, 6, 2.5), GV.ramp("#f5cf6a"), { flat = true, gloss = false })
c:part(c:ellipse(84, 124, 6, 2.5), GV.ramp("#e8b830"), { flat = true, gloss = false })
-- butterflies
for _, b in ipairs({ {188,60},{22,70} }) do c:fill(c:rect(b[1], b[2], b[1] + 1, b[2] + 1), "#e46a9b"); c:fill(c:rect(b[1] + 3, b[2], b[1] + 4, b[2] + 1), "#e46a9b"); c:px(b[1] + 2, b[2], "#2a1a10") end
L.finish(c, SLUG)
