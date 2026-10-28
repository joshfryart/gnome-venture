-- delve-beaverdam-tunnels: cutaway of a beaver lodge and the flooded tunnel maze beneath. NA, day.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, W, H = L.GV, L.W, L.H
local c = L.new()
local HOR = 62

L.sky(c, "day", HOR)
L.cloud(c, 40, 20, 16); L.cloud(c, 170, 14, 20); L.cloud(c, 120, 34, 11)
-- far pine hills
c:part(c:poly({ {0,HOR+2},{0,50},{20,44},{50,52},{80,42},{110,50},{150,40},{190,48},{220,41},{W,46},{W,HOR+2} }), GV.ramp("#4a8a7a"), { outline = false, gloss = false, rim = false, bounce = false })
for _, x in ipairs({ 6,18,30,44,58,72,88,104,120,136,152,168,184,200,214,228 }) do
  local h = 8 + (x * 7) % 6
  c:fill(c:poly({ {x-3,HOR-6},{x,HOR-6-h},{x+3,HOR-6} }), (x % 3 == 0) and "#2f6a58" or "#3a7a66")
end
-- pond
L.water(c, HOR + 1, "day")
for i, x in ipairs({ 10, 60, 130, 190, 90 }) do c:fill(c:rect(x, HOR + 3 + (i % 3) * 3, x + 8, HOR + 3 + (i % 3) * 3), "#c8ecdc") end

-- soil bank (cross-section) with water-filled tunnels ------------------------------------------------
local bank = c:poly({ {0,H},{0,100},{30,98},{60,100},{100,99},{140,100},{180,98},{210,100},{W,98},{W,H} })
c:part(bank, GV.ramp("#7a4a1f"), { cres = 5, deep = 8, gloss = false })
-- roots + pebbles in the soil
for _, p in ipairs({ {12,126},{50,112},{98,128},{150,125},{196,129},{228,114},{26,108} }) do
  c:part(c:ellipse(p[1], p[2], 2, 1.5), GV.ramp("#8b8f96"), { flat = true, gloss = false, rim = false })
end
local function tunnel(x0, y0, x1, y1, lvl)
  local m = c:rrect(x0, y0, x1, y1, 3)
  c:fill(m, "#2a1a10")
  c:fill(c:rrect(x0 + 1, y0 + 1, x1 - 1, y1 - 1, 2), "#3d2a1c")
  local w = c:rect(x0 + 1, lvl, x1 - 1, y1 - 1)
  c:fill(w:clip(c:rrect(x0 + 1, y0 + 1, x1 - 1, y1 - 1, 2)), "#3f8fb0")
  c:fill(c:rect(x0 + 2, y1 - 2, x1 - 2, y1 - 2), "#2f6290")
  c:fill(c:rect(x0 + 2, lvl, x1 - 2, lvl), "#8fcbd8")
end
tunnel(8, 108, 64, 118, 111)
tunnel(76, 114, 150, 125, 117)
tunnel(160, 106, 226, 116, 109)
tunnel(40, 118, 50, 131, 121)  -- shafts
tunnel(104, 105, 112, 126, 118)
tunnel(180, 114, 190, 128, 118)
tunnel(62, 122, 104, 130, 124)
tunnel(150, 120, 184, 130, 123)
-- little fish and a tiny lantern in the maze
c:fill(c:ellipse(30, 115, 3, 1.5), "#e0501f"); c:px(27, 115, "#f08a24")
c:fill(c:ellipse(205, 113, 3, 1.5), "#f5cf6a")
c:part(c:rect(129, 118, 132, 121), GV.ramp("#e8a317"), { flat = true }); c:px(130, 117, "#fff1c8")
c:fill(c:rect(124, 116, 138, 116), "#f5cf6a")

-- lodge: dome of sticks with a cutaway window ------------------------------------------------------
local LX = 150
local dome = c:ellipse(LX, 100, 50, 46):clip(c:rect(0, 0, W, 101))
c:part(dome, GV.ramp("#a8582f"), { cres = 7, deep = 11, gloss = false })
-- stick texture: dark and light diagonal dashes
local s = 3
for y = 62, 98, 4 do
  for x = LX - 48, LX + 48, 7 do
    local xx = x + ((y // 4) % 2) * 3
    if dome:has(xx, y) and dome:has(xx + 5, y + 1) then
      c:fill(c:line({ {xx, y}, {xx + 5, y - 1} }, 1), "#5e2f1e")
      if dome:has(xx + 1, y - 1) then c:px(xx + 1, y - 1, "#d9a660") end
    end
  end
end
-- cutaway window
local win = c:rrect(LX - 34, 64, LX + 34, 99, 10)
c:part(win, GV.ramp("#3d2a1c"), { cres = 3, deep = 5, gloss = false, rim = false })
-- chambers
local function chamber(x0, y0, x1, y1, r)
  c:fill(c:rrect(x0, y0, x1, y1, r), "#2a1a10")
  c:fill(c:rrect(x0 + 1, y0 + 1, x1 - 1, y1 - 1, r - 1), "#6b3f22")
  c:fill(c:rect(x0 + 2, y1 - 3, x1 - 2, y1 - 2), "#9a6b3f")   -- dry bedding floor
end
chamber(LX - 30, 84, LX - 8, 97, 4)
chamber(LX + 8, 72, LX + 30, 86, 4)
c:fill(c:rect(LX - 8, 90, LX + 8, 97), "#2f6290"); c:fill(c:rect(LX - 8, 90, LX + 8, 90), "#8fcbd8")  -- flooded passage
c:fill(c:rect(LX + 18, 86, LX + 22, 98), "#2f6290"); c:fill(c:rect(LX + 18, 86, LX + 22, 86), "#8fcbd8")
c:fill(c:rect(LX + 10, 70, LX + 12, 72), "#3d2a1c")
-- hay beds + a glowing mushroom lamp in the upper chamber
c:fill(c:ellipse(LX + 19, 83, 6, 2), "#d9a660"); c:fill(c:rect(LX + 14, 84, LX + 24, 84), "#b07a45")
c:part(c:ellipse(LX + 26, 76, 2.5, 2), GV.ramp("#f08a24"), { flat = true }); c:px(LX + 26, 78, "#a4b86a"); c:px(LX + 26, 79, "#a4b86a")
-- a baby beaver asleep in the lower chamber
c:part(c:ellipse(LX - 19, 92, 6, 4), GV.ramp("#b07a45"), { cres = 2, gloss = false })
c:part(c:ellipse(LX - 14, 90, 3, 3), GV.ramp("#b07a45"), { flat = true, gloss = false })
c:fill(c:rect(LX - 15, 90, LX - 14, 90), "#2a1a10"); c:px(LX - 13, 91, "#2a1a10"); c:px(LX - 24, 85, "#c3b2ea"); c:px(LX - 22, 83, "#c3b2ea")
-- the lodge front door: low arch at the waterline
c:part(c:rrect(LX + 36, 90, LX + 47, 101, 4):clip(c:rect(0, 0, W, 100)), GV.ramp("#2a1a10"), { gloss = false, rim = false, outline = false, cres = 1 })
c:fill(c:rect(LX + 38, 96, LX + 45, 99), "#2f6290")
-- twig on top
c:fill(c:line({ {LX - 6, 56}, {LX + 3, 52} }, 2), "#5e2f1e"); c:fill(c:line({ {LX, 56}, {LX + 6, 50} }, 2), "#7a4a1f")

-- beaver dam (logs) left of the lodge, holding the water --------------------------------------------
local function log(x0, y0, x1, y1)
  c:part(c:rrect(x0, y0, x1, y1, 2), GV.ramp("#b07a45"), { cres = 2, deep = 3, gloss = false })
  c:fill(c:rect(x1 - 1, y0 + 2, x1 - 1, y1 - 2), "#ecc58a"); c:px(x0 + 4, y0 + 1, "#7a4a1f"); c:px(x0 + 12, y1 - 2, "#7a4a1f")
end
log(4, 90, 40, 96); log(22, 84, 52, 89); log(0, 96, 30, 100); log(38, 90, 62, 95)
-- foreground sticks on the right bank
log(190, 96, 224, 101); log(206, 91, 236, 96)
-- grass
for _, x in ipairs({ 70, 84, 96, 212, 232, 3, 44 }) do c:px(x, 97, "#7ab55c"); c:px(x + 1, 95, "#a4b86a"); c:px(x + 2, 97, "#7ab55c"); c:px(x+1,96,"#4a8a3e") end

-- the beaver on the bank, chewing a stick -------------------------------------------------------------
local BX, BY = 80, 100
c:part(c:ellipse(BX - 12, BY - 4, 7, 3), GV.ramp("#5e2f1e"), { cres = 2, gloss = false })    -- flat tail
c:seam({ {BX - 17, BY - 4}, {BX - 7, BY - 4} }, { free = true, on = 1, off = 1, gap = "#2a1a10" })
c:part(c:ellipse(BX, BY - 9, 10, 9), GV.ramp("#9a6b3f"), { cres = 4, deep = 7 })             -- body
c:part(c:ellipse(BX + 2, BY - 8, 5, 6), GV.ramp("#e9b98a"), { flat = true, gloss = false })  -- belly
c:part(c:ellipse(BX - 4, BY - 31, 3, 3), GV.ramp("#7a4a1f"), { flat = true, gloss = false })
c:part(c:ellipse(BX + 15, BY - 31, 3, 3), GV.ramp("#7a4a1f"), { flat = true, gloss = false })
c:part(c:ellipse(BX + 6, BY - 23, 12, 9), GV.ramp("#9a6b3f"), { cres = 4, deep = 6 })        -- head
c:eye(BX - 3, BY - 28); c:eye(BX + 8, BY - 28)
c:part(c:ellipse(BX + 6, BY - 18, 4, 3), GV.ramp("#e9b98a"), { flat = true, gloss = false }) -- muzzle
c:fill(c:rect(BX + 5, BY - 20, BX + 7, BY - 19), "#2a1a10")                                    -- nose
c:fill(c:rect(BX + 5, BY - 18, BX + 7, BY - 15), "#f2e4c0"); c:px(BX + 6, BY - 18, "#d8c496") -- buck teeth
-- the stick across the paws
c:fill(c:line({ {BX - 1, BY - 11}, {BX + 22, BY - 14} }, 2), "#7a4a1f"); c:px(BX + 4, BY - 12, "#d9a660"); c:px(BX + 14, BY - 13, "#d9a660")
c:part(c:ellipse(BX + 4, BY - 11, 3, 2.5), GV.ramp("#7a4a1f"), { flat = true, gloss = false }); c:part(c:ellipse(BX + 13, BY - 12, 3, 2.5), GV.ramp("#7a4a1f"), { flat = true, gloss = false })
c:ground(BX, BY + 1, 14, 2)
-- a duck on the pond for life
c:part(c:ellipse(30, 74, 5, 3), GV.ramp("#f2e4c0"), { flat = true, gloss = false })
c:part(c:ellipse(35, 70, 3, 3), GV.ramp("#2f5a2a"), { flat = true, gloss = false }); c:px(38, 71, "#f08a24"); c:px(39, 71, "#f08a24"); c:px(36, 69, "#fff1c8")

L.finish(c, "delve-beaverdam-tunnels")
