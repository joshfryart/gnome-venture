-- delve-snowleopard-ledges.lua : CSA zone 4 delve. "Narrow mountain paths."
-- Andean dawn: snow peaks over a cloud sea, a switchback ledge path on a cliff, a wool-pennant cairn, and a fluffy snow leopard.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, W, H = L.GV, L.W, L.H
local c = L.new()
local SLUG = "delve-snowleopard-ledges"
local NP = { gloss = false, rim = false, bounce = false, outline = false }
local function o(t) local r = {}; for k, v in pairs(NP) do r[k] = v end; for k, v in pairs(t or {}) do r[k] = v end; return r end

L.sky(c, "dawn", 96)
-- last stars up top
for _, s in ipairs({ {20,12},{54,9},{98,14},{140,10},{188,13},{226,9},{76,20},{210,22} }) do c:px(s[1], s[2], "#fbe0a8") end
-- low sun peeking behind the far peak
c:fill(c:ellipse(150, 78, 11, 11), "#fbe0a8"); c:fill(c:ellipse(150, 78, 8, 8), "#fff1c8")
L.cloud(c, 40, 40, 16, "#f8c890", "#f0aa98"); L.cloud(c, 210, 36, 14, "#f8c890", "#f0aa98"); L.cloud(c, 110, 28, 12, "#d49ab8", "#a48ac0")

-- far snow peaks (blue-violet with snow caps)
local function peak(x0, x1, apex, ax, base, rock, snow, snowline)
  local p = c:poly({ {x0, base}, {ax - 10, apex + 18}, {ax, apex}, {ax + 12, apex + 14}, {x1, base} })
  c:part(p, GV.ramp(rock), o({ cres = 8, deep = 12 }))
  local cap = p:copy():clip(c:rect(0, 0, W, snowline))
  c:part(cap, GV.ramp(snow, { dot = "#fff3c8" }), o({ cres = 5, deep = 8, pale = true }))
end
peak(70, 250, 38, 156, 108, "#6a5a98", "#e8f0f8", 64)
peak(-10, 120, 50, 30, 108, "#7a6aa8", "#e8f0f8", 70)
-- cloud sea in the valley (hard bands)
c:fill(c:rect(0, 96, W - 1, H - 1), "#d49ab8")
c:fill(c:rect(0, 100, W - 1, H - 1), "#e8b0b8")
c:fill(c:rect(0, 106, W - 1, H - 1), "#f0c4b8")
for _, cl in ipairs({ {20,98,18},{80,100,24},{150,97,20},{210,99,22} }) do
  c:part(c:ellipse(cl[1], cl[2], cl[3], 5), GV.ramp("#f8dccc", { dot = "#fff3c8" }), o({ cres = 3, deep = 5, pale = true }))
end

-- the cliff: big stone face from the left, switchback path carved into it
local cliff = c:poly({ {0,64},{22,68},{50,74},{84,86},{112,96},{140,104},{174,112},{204,118},{W,122},{W,H},{0,H} })
c:part(cliff, GV.ramp("#8b8f96"), { cres = 8, deep = 12, gloss = false })
-- strata cracks
for _, l in ipairs({ { {6,76},{24,79},{44,77} }, { {72,98},{90,102},{100,100} }, { {30,122},{70,120},{100,126} }, { {50,112},{70,114} }, { {120,114},{150,116},{176,122} } }) do
  c:seam(l, { free = true, on = 3, off = 0, gap = "#4a3a50" })
end
-- tufts of ichu grass on the cliff
for _, p in ipairs({ {14,72},{58,80},{100,96},{132,102},{12,116},{184,118} }) do
  c:px(p[1], p[2], "#a4b86a"); c:px(p[1]+1, p[2]-1, "#c8d77a"); c:px(p[1]+2, p[2], "#a4b86a"); c:px(p[1]+1, p[2], "#7ab55c")
end
-- switchback path: lighter dusty ledges zigzagging up (3 runs) then the broad ledge in front
local path = { hex = "#d8b888" }
local function ledge(pts) c:part(c:poly(pts), GV.ramp(path.hex, { shade = "#b08a6a", deep = "#7a5a4a" }), { cres = 2, deep = 3, gloss = false, rim = false, outline = false }) end
local zz = { {8,84},{62,92},{22,104},{96,114},{108,108} }
c:part(c:line(zz, 5), GV.ramp("#d8b888", { shade = "#b08a6a", deep = "#7a5a4a" }), { cres = 2, deep = 3, gloss = false, rim = false, outline = true })
-- broad foreground ledge, right half
local ledge2 = c:poly({ {96,H},{104,112},{124,106},{150,104},{176,106},{204,110},{W,112},{W,H} })
c:part(ledge2, GV.ramp("#d8b888", { shade = "#b08a6a", deep = "#7a5a4a" }), { cres = 5, deep = 8, gloss = false })
-- snow patches on the ledge
for _, s in ipairs({ {190,114,5},{212,118,6},{168,120,4},{150,124,5} }) do
  c:part(c:ellipse(s[1], s[2], s[3], 1.6), GV.ramp("#e8f0f8", { dot = "#fff3c8" }), { flat = true, gloss = false, pale = true, outline = false })
end

-- wool-pennant cairn (apacheta), left of the leopard
local cx0, cy0 = 126, 116
for i, r in ipairs({ {0,0,11,5},{1,-8,9,4},{-1,-15,7,4},{0,-21,5,3} }) do
  c:part(c:ellipse(cx0 + r[1], cy0 + r[2], r[3], r[4]), GV.ramp(({ "#8b8f96","#a09ca0","#8b8f96","#c9c5bc" })[i]), { cres = 2, deep = 4, gloss = false })
end
-- pole with woven pennants in Andean colours
c:fill(c:rect(cx0, cy0 - 40, cx0 + 1, cy0 - 22), "#7a4a1f"); c:px(cx0, cy0 - 40, "#b07a45")
local cols = { "#d6322b", "#f08a24", "#e8a317", "#4e8a9a", "#e46a9b" }
for i, col in ipairs(cols) do
  local y = cy0 - 40 + (i - 1) * 3
  c:fill(c:rect(cx0 + 2, y, cx0 + 8 + (i % 2) * 2, y + 1), col)
  c:fill(c:rect(cx0 - 8 - (i % 2) * 2, y + 1, cx0 - 1, y + 2), cols[(i + 1) % 5 + 1])
end
c:ground(cx0, cy0 + 4, 12, 2)

-- snow leopard, sitting on the ledge, tail draped long and fluffy
local JX, JY = 164, 98
local S = GV.ramp("#c9c5bc", { gloss = "#fff3c8", dot = "#ffffff", rim = "#e8e4dc", shade = "#9a9cac", deep = "#5b6470" })
-- fluffy tail sweeping right, curling up
local tail = c:ellipse(JX + 20, JY + 9, 14, 4); tail:add(c:ellipse(JX + 34, JY + 4, 5, 6)); tail:add(c:ellipse(JX + 36, JY - 3, 4, 4))
c:part(tail, S, { cres = 3, deep = 5, gloss = false })
for _, p in ipairs({ {JX+18,JY+8},{JX+24,JY+9},{JX+30,JY+8},{JX+35,JY+2} }) do c:fill(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), "#4a4a60") end
-- body
c:part(c:ellipse(JX, JY, 14, 12), S, { cres = 5, deep = 8 })
for _, dx in ipairs({ -8, 4 }) do c:part(c:ellipse(JX + dx + 2, JY + 11, 4, 3), S, { cres = 2, deep = 3, gloss = false }) end
for _, s in ipairs({ {-11,-3},{-8,4},{9,-2},{10,5},{-2,-9},{4,-8},{-4,1},{3,3} }) do
  c:fill(c:rect(JX + s[1], JY + s[2], JX + s[1] + 2, JY + s[2] + 1), "#4a4a60")
end
-- head
c:part(c:ellipse(JX, JY - 15, 13, 10), S, { cres = 4, deep = 7 })
for _, dx in ipairs({ -10, 10 }) do
  c:part(c:ellipse(JX + dx, JY - 24, 4, 3.5), S, { cres = 2, deep = 3, gloss = false })
  c:fill(c:rect(JX + dx - 1, JY - 25, JX + dx + 1, JY - 23), "#4a4a60")
end
c:part(c:ellipse(JX, JY - 11, 6, 4), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { flat = true, gloss = false, outline = false })
c:fill(c:rect(JX - 1, JY - 13, JX + 1, JY - 12), "#e46a9b")
c:px(JX, JY - 11, "#2a1a10"); for _, dx in ipairs({ -2, -1, 1, 2 }) do c:px(JX + dx, JY - 9, "#2a1a10") end
for _, dx in ipairs({ -3, -2, 2, 3 }) do c:px(JX + dx, JY - 23, "#4a4a60") end
c:eye(JX - 9, JY - 20); c:eye(JX + 4, JY - 20)
c:ground(JX, JY + 14, 22, 2)

-- condor soaring in the valley
for _, g in ipairs({ {52,30},{204,60} }) do
  for dx = -6, 6 do c:px(g[1] + dx, g[2] + math.floor(math.abs(dx) / 3) * -1 + 2, "#3e2f66") end
  c:px(g[1], g[2] + 3, "#3e2f66"); c:px(g[1] + 1, g[2] + 3, "#3e2f66")
end

L.finish(c, SLUG)
