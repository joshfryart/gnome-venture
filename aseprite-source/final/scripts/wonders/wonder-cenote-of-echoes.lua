-- wonder-cenote-of-echoes.lua : CA zone 3. A round pool drops into the earth, deep and green; a voice comes back slightly late; something glints below.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
local GT = 34 -- ground surface row

L.sky(c, "day", GT + 2)
L.cloud(c, 40, 12, 14); L.cloud(c, 196, 18, 12)
-- earth cross-section
c:bands(c:rect(0, GT, W - 1, H - 1), { "#8a5a34", "#7a4a2a", "#6a3e24", "#5a3420", "#4c2c1c" }, { dir = "v" })
-- earth strata flecks
for _, f in ipairs({ {10,44,6},{30,60,5},{14,86,7},{22,110,6},{208,50,7},{222,74,5},{200,98,8},{226,118,6},{6,70,4} }) do
  c:fill(c:rect(f[1], f[2], f[1] + f[3], f[2] + 1), "#9a6b3f")
  c:px(f[1] + 2, f[2] + 3, "#3d2a1c")
end
-- the cavity: big round chamber
local cav = c:ellipse(120, 80, 108, 46)
cav:clip(c:rect(0, GT, W, 126))
c:fill(cav:copy():grow(2), "#3d2a1c")
c:bands(cav, { "#34505a", "#2e4852", "#28404a", "#243a44" }, { dir = "v" })
-- open sky above the mouth
local mouth = c:rect(70, 0, 170, GT + 3)
c:bands(mouth, L.SKY.day, { dir = "v" })
L.cloud(c, 118, 10, 11)
-- jungle lip around the mouth
c:part(c:poly({ {0,GT-2},{30,GT-6},{60,GT-4},{72,GT+2},{72,GT+8},{0,GT+8} }), GV.ramp("#4a8a3e"), { cres = 3, deep = 5, gloss = false })
c:part(c:poly({ {240,GT-2},{210,GT-6},{180,GT-4},{168,GT+2},{168,GT+8},{240,GT+8} }), GV.ramp("#4a8a3e"), { cres = 3, deep = 5, gloss = false })
for _, t in ipairs({ {14,GT-10},{44,GT-12},{200,GT-12},{228,GT-10} }) do
  c:fill(c:rect(t[1], t[2] + 2, t[1] + 1, GT - 3), "#5e2f1e")
  c:part(c:ellipse(t[1], t[2], 8, 6), GV.ramp("#2f7a3a"), { cres = 3, deep = 5, gloss = false })
end
-- sun shafts (hard diagonal bands) from the mouth to the water
local WS = 64 -- water surface row
local shaft1 = c:poly({ {84,GT+3},{104,GT+3},{136,WS},{104,WS} })
local shaft2 = c:poly({ {112,GT+3},{130,GT+3},{158,WS},{140,WS} })
c:fill(shaft1:copy():clip(cav), "#5a8c88"); c:fill(shaft2:copy():clip(cav), "#5a8c88")
c:fill(c:poly({ {92,GT+3},{98,GT+3},{120,WS},{114,WS} }):clip(cav), "#8fb8a8")
-- stalactites
for _, s in ipairs({ {30,52,12},{44,50,9},{62,46,10},{176,46,10},{198,50,12},{212,52,9} }) do
  c:part(c:poly({ {s[1] - 4, s[2] - 6}, {s[1] + 4, s[2] - 6}, {s[1], s[2] + s[3] - 6} }):clip(cav:copy():grow(2)), GV.ramp("#7a6a58"), { cres = 2, deep = 3, gloss = false })
end
-- vines hanging from the rim
for _, v in ipairs({ {76,GT+4,14},{82,GT+4,22},{160,GT+4,18},{166,GT+4,10} }) do
  c:fill(c:rect(v[1], v[2], v[1], v[2] + v[3]), "#4a8a3e")
  for i = 0, v[3], 5 do c:px(v[1] + 1, v[2] + i, "#7ab55c") end
end

-- the water ---------------------------------------------------------------------------------------
local water = cav:copy():clip(c:rect(0, WS, W, H))
c:bands(water, { "#8fd0b8", "#5fb8a4", "#3fa090", "#2f8480", "#256a70", "#1f5260", "#1b4452" }, { dir = "v" })
-- surface highlight and ripples
c:fill(c:rect(0, WS, W, WS):clip(cav), "#c8ecdc")
for _, r in ipairs({ {30,68,10},{80,70,14},{140,69,12},{190,71,10},{60,76,8},{170,78,12} }) do c:fill(c:rect(r[1], r[2], r[1] + r[3], r[2]):clip(cav), "#c8ecdc") end
-- light shafts continue under water as pale bands
c:fill(c:poly({ {104,WS+1},{140,WS+1},{128,100},{96,100} }):clip(water), "#5fb8a4")
c:fill(c:poly({ {112,WS+1},{132,WS+1},{122,92},{106,92} }):clip(water), "#8fd0b8")
-- bubbles
for _, b in ipairs({ {112,90},{114,84},{111,78},{132,100},{134,94},{100,104} }) do c:fill(c:ellipse(b[1], b[2], 1, 1), "#c8ecdc"); end
-- treasure on the pool floor: a gilded little chest with a glint
local tx, ty = 120, 112
c:part(c:rrect(tx - 9, ty - 7, tx + 9, ty + 6, 2), GV.ramp("#b07a45"), { cres = 3, deep = 5, gloss = false })
c:part(c:ellipse(tx, ty - 7, 9, 4):clip(c:rect(0, 0, W, ty - 6)), GV.ramp("#a8582f"), { cres = 2, deep = 4, gloss = false })
c:fill(c:rect(tx - 9, ty - 4, tx + 9, ty - 3), "#e8a317")
c:part(c:rect(tx - 2, ty - 5, tx + 2, ty), GV.ramp("#e8a317"), { flat = true })
c:seam({ {tx - 8, ty + 3}, {tx + 8, ty + 3} }, { free = true })
-- glint star
for _, g in ipairs({ {tx - 12, ty - 14}, {tx + 12, ty - 10} }) do
  c:px(g[1], g[2], "#fff1c8"); c:px(g[1] - 1, g[2], "#fff1c8"); c:px(g[1] + 1, g[2], "#fff1c8"); c:px(g[1], g[2] - 1, "#fff1c8"); c:px(g[1], g[2] + 1, "#fff1c8")
  c:px(g[1] - 2, g[2], "#fff1c8"); c:px(g[1] + 2, g[2], "#fff1c8"); c:px(g[1], g[2] - 2, "#fff1c8"); c:px(g[1], g[2] + 2, "#fff1c8")
end
c:ground(tx, ty + 8, 14, 1.5, "#1b4452")
-- pale fish and a little shoal
local function fish(x, y, col)
  c:part(c:ellipse(x, y, 5, 3), GV.ramp(col), { flat = true, gloss = false })
  c:part(c:poly({ {x + 5, y}, {x + 9, y - 3}, {x + 9, y + 3} }), GV.ramp(col), { flat = true, gloss = false })
  c:px(x - 3, y - 1, "#2a1a10")
end
fish(66, 92, "#f08a24"); fish(168, 98, "#f5cf6a"); fish(60, 104, "#f08a24")
-- underwater rocks on the floor
for _, r in ipairs({ {44,120,10,4},{80,122,8,3},{164,122,10,4},{196,118,9,3} }) do c:part(c:ellipse(r[1], r[2], r[3], r[4]):clip(cav), GV.ramp("#4a6a70"), { cres = 2, deep = 3, gloss = false }) end

-- foreground ledge (left) with a singing frog; echo rings come back from the walls ---------------------
local ledge = c:poly({ {0,58},{22,56},{46,60},{58,66},{50,72},{0,76} })
c:part(ledge, GV.ramp("#a8a498"), { cres = 4, deep = 6, gloss = false })
local fx, fy = 28, 50
c:part(c:ellipse(fx, fy, 8, 6), GV.ramp("#7ab55c"), { cres = 3, deep = 5 })
c:part(c:ellipse(fx - 4, fy - 5, 3, 3), GV.ramp("#7ab55c"), { cres = 2, deep = 3, gloss = false })
c:part(c:ellipse(fx + 4, fy - 5, 3, 3), GV.ramp("#7ab55c"), { cres = 2, deep = 3, gloss = false })
c:eye(fx - 6, fy - 8); c:eye(fx + 2, fy - 8)
c:fill(c:ellipse(fx + 6, fy + 1, 3, 2.5), "#2a1a10")  -- open mouth, calling out
c:fill(c:ellipse(fx + 6, fy + 2, 2, 1), "#d6322b")
c:ground(fx, fy + 7, 9, 1.5)
-- echo rings, widening and fainter (late returns)
local function ring(cx, cy, rx, ry, col)
  local m = c:ellipse(cx, cy, rx, ry); m:cut(c:ellipse(cx, cy, rx - 1, ry - 1)); m:clip(c:rect(cx, 0, W, H))
  c:fill(m, col)
end
ring(62, 50, 8, 8, "#c8ecdc"); ring(62, 50, 16, 14, "#8fcbd8"); ring(62, 50, 26, 20, "#5a86b8")
-- right foreground: mossy rocks and ferns
c:part(c:poly({ {W,64},{214,66},{200,78},{W,84} }), GV.ramp("#a8a498"), { cres = 4, deep = 6, gloss = false })
for _, f in ipairs({ {208,66},{222,62} }) do
  for _, a in ipairs({ -1, 0, 1 }) do c:part(c:ellipse(f[1] + a * 5, f[2] - 5 - (a == 0 and 3 or 0), 2, 6), GV.ramp(a == 0 and "#7ab55c" or "#4a8a3e"), { flat = true, gloss = false }) end
end

L.finish(c, "wonder-cenote-of-echoes")
