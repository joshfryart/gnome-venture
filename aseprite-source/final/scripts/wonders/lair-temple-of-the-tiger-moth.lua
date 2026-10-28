-- lair-temple-of-the-tiger-moth.lua : Boss lair (CSA, zone 3). Himalayan stone shikhara temple at night, prayer flags, a giant tiger moth hovering beside it.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV = L.GV
local c = L.new()
local W, H = L.W, L.H
L.sky(c, "night", 100)
L.stars(c, 46, 60, 11)
-- moon, upper right
c:fill(c:ellipse(196, 30, 17, 17), "#6a5fa8"); c:fill(c:ellipse(196, 30, 15, 15), "#9a8ed4"); c:fill(c:ellipse(196, 30, 12, 12), "#c3b8ec")
c:fill(c:ellipse(192, 26, 3, 2), "#9a8ed4"); c:fill(c:ellipse(200, 35, 3, 2), "#9a8ed4")
-- Himalayan snow peaks
local function peak(x, top, hw, col, snow)
  local m = c:poly({ {x - hw, 108}, {x, top}, {x + hw, 108} })
  c:fill(m, col)
  if snow then c:fill(m:copy():clip(c:rect(0, 0, W, top + 12)), snow) end
end
peak(24, 50, 50, "#3e3680", "#8c84c8"); peak(110, 66, 44, "#322c6c", "#6a62a8"); peak(214, 56, 44, "#3e3680", "#8c84c8"); peak(170, 78, 30, "#322c6c")
c:fill(c:rect(0, 96, W, 101), "#4a428e"); c:fill(c:rect(0, 102, W, 104), "#5a52a0")
-- pine hills
c:part(L.below(c, function(x) return 98 + math.sin(x * 0.09) * 4 end), GV.ramp("#2f5a2a"), { outline = false, gloss = false, cres = 3, deep = 4 })
local function pine(x, base, h)
  c:fill(c:poly({ {x - 5, base}, {x, base - h}, {x + 5, base} }), "#24482a"); c:fill(c:poly({ {x - 3, base - h * 0.4}, {x, base - h - 2}, {x + 3, base - h * 0.4} }), "#2f5a2a")
end
for _, p in ipairs({ {6,112,18},{18,114,14},{226,112,18},{234,114,14},{60,108,12},{200,108,12} }) do pine(p[1], p[2], p[3]) end
-- stone terrace ground
c:part(c:rect(0, 118, W - 1, H - 1), GV.ramp("#5b6470"), { outline = false, gloss = false, cres = 2, deep = 3 })

-- the temple: plinth, mandapa, curvilinear shikhara --------------------------------------------------------
local CX = 150
c:part(c:rect(CX - 46, 112, CX + 46, 126), GV.ramp("#a89a82"), { cres = 4, deep = 6, gloss = false })
c:part(c:rect(CX - 38, 104, CX + 38, 112), GV.ramp("#b8aa90"), { cres = 3, deep = 5, gloss = false })
for i = 0, 5 do c:fill(c:rect(CX - 12 - i, 112 + i * 2, CX + 12 + i, 113 + i * 2), (i % 2 == 0) and "#c9c0a8" or "#8a7e68") end
-- mandapa porch with flat pyramid roof
c:part(c:rect(CX - 30, 88, CX + 30, 104), GV.ramp("#a89a82"), { cres = 4, deep = 5, gloss = false })
c:part(c:poly({ {CX - 34, 88}, {CX - 24, 80}, {CX + 24, 80}, {CX + 34, 88} }), GV.ramp("#8a7e68"), { cres = 3, deep = 4, gloss = false })
c:part(c:poly({ {CX - 24, 80}, {CX - 16, 74}, {CX + 16, 74}, {CX + 24, 80} }), GV.ramp("#8a7e68"), { cres = 2, deep = 4, gloss = false })
-- shikhara tower rising behind the porch
c:part(c:poly({ {CX - 20, 78}, {CX - 21, 64}, {CX - 17, 52}, {CX - 10, 40}, {CX - 5, 32}, {CX + 5, 32}, {CX + 10, 40}, {CX + 17, 52}, {CX + 21, 64}, {CX + 20, 78} }), GV.ramp("#b8aa90"), { cres = 4, deep = 6, gloss = false })
for _, x in ipairs({ -12, -6, 0, 6, 12 }) do c:fill(c:rect(CX + x, 36 + math.abs(x) // 2, CX + x, 76), "#8a7e68") end
for y = 40, 74, 8 do c:fill(c:rect(CX - 20 + (74 - y) // 12 * 0 + math.max(0, 40 - y) // 3, y, CX + 20, y), "#d4c8a8") end
c:part(c:poly({ {CX - 6, 56}, {CX - 6, 50}, {CX + 6, 50}, {CX + 6, 56} }), GV.ramp("#d4c8a8"), { cres = 2, gloss = false })
c:part(c:ellipse(CX, 30, 9, 3), GV.ramp("#d4c8a8"), { cres = 2, deep = 3, gloss = false })     -- amalaka disc
c:fill(c:rect(CX - 1, 18, CX + 1, 28), "#d4a02a"); c:px(CX, 17, "#fff1c8")                           -- kalasha finial
c:part(c:ellipse(CX, 24, 3, 3), GV.ramp("#d4a02a"), { flat = true, gloss = false, outline = false })
-- glowing doorway
c:part(c:rrect(CX - 8, 90, CX + 8, 104, 4), GV.ramp("#f5b860"), { outline = false, gloss = false, contour = "#2a1a10", flat = true })
c:fill(c:rect(CX - 4, 94, CX + 4, 104), "#fbe0a8")
c:seam({ {CX - 28, 91}, {CX + 28, 91} }, { on = 3, off = 2 })
-- butter lamps and torches
local function torch(x, y)
  c:fill(c:rect(x, y - 8, x + 1, y), "#4a2c1a")
  c:fill(c:ellipse(x + 0.5, y - 12, 3, 4.5), "#e0501f"); c:fill(c:ellipse(x + 0.5, y - 11, 2, 3), "#f5b838"); c:px(x, y - 11, "#fff1c8")
end
torch(CX - 42, 126); torch(CX + 42, 126); torch(CX - 34, 112); torch(CX + 34, 112)

-- white stupa on the right with prayer flags ---------------------------------------------------------------
c:part(c:rect(214, 112, 236, 120), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 3, deep = 4, pale = true, gloss = false })
c:part(c:ellipse(225, 106, 10, 9), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 3, deep = 5, pale = true, gloss = false })
c:part(c:rect(222, 90, 228, 98), GV.ramp("#d4a02a"), { cres = 2, gloss = false })
c:fill(c:rect(224, 82, 226, 90), "#d4a02a"); c:px(225, 81, "#fff1c8")
-- prayer flags: pole at the left, string up to the finial, on to the stupa
local FLAG = { "#3f8fb0", "#f2e4c0", "#d6322b", "#4a9a4a", "#f5cf6a" }
local function flags(x0, y0, x1, y1, sag, n)
  for i = 0, n do
    local t = i / n
    local x = x0 + (x1 - x0) * t; local y = y0 + (y1 - y0) * t + sag * math.sin(t * math.pi)
    c:fill(c:rect(x, y, x + 1, y), "#2a1a10")
    if i % 2 == 1 then c:fill(c:rect(x - 1, y + 1, x + 2, y + 5), FLAG[(i // 2) % 5 + 1]) end
  end
end
c:fill(c:rect(100, 40, 101, 118), "#4a2c1a")  -- pole
flags(101, 40, CX, 22, 6, 24)
flags(CX, 22, 225, 80, 10, 30)

-- the Tiger Moth, hovering left of the temple, so the temple top stays clear -----------------------------------
local function T(x, y) return 72 + (x - 120) * 0.75, 44 + (y - 20) * 0.85 end
local function TP(pts) local r = {}; for i, p in ipairs(pts) do local x, y = T(p[1], p[2]); r[i] = { x, y } end; return r end
local function mirror(pts) local r = {}; for i, p in ipairs(pts) do r[i] = { 240 - p[1], p[2] } end; return r end
local function wing(pts, base)
  local m = c:poly(TP(pts))
  c:part(m, GV.ramp(base), { cres = 5, deep = 7, gloss = false })
  return m
end
local function E(x, y, rx, ry) local tx, ty = T(x, y); return c:ellipse(tx, ty, rx * 0.75, ry * 0.85) end
local hind = { {118,56},{86,66},{66,88},{70,98},{98,92},{116,76} }
local fore = { {118,50},{80,20},{46,26},{34,46},{54,64},{96,62} }
for _, side in ipairs({ 1, -1 }) do
  local hp, fp = hind, fore
  if side == -1 then hp, fp = mirror(hind), mirror(fore) end
  local hm = wing(hp, "#e0501f")
  local ex = side == 1 and 84 or 156
  c:fill(hm:copy():clip(E(ex, 80, 14, 12):cut(E(ex, 80, 8, 6))), "#2a1a10")
  local tx, ty = T(side == 1 and 82 or 158, 80)
  c:part(c:ellipse(tx, ty, 3, 3), GV.ramp("#f5cf6a"), { flat = true, outline = false, gloss = false })
  local fm = wing(fp, "#f5a838")
  for _, st in ipairs({ { {60,28},{74,58} }, { {76,22},{90,56} }, { {92,34},{104,54} }, { {48,36},{66,62} } }) do
    local a = { side == 1 and st[1][1] or 240 - st[1][1], st[1][2] }; local b = { side == 1 and st[2][1] or 240 - st[2][1], st[2][2] }
    c:fill(fm:copy():clip(c:line(TP({ a, b }), 3)), "#2a1a10")
  end
end
c:part(E(120, 68, 7, 18), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 3, deep = 5, gloss = false })
for _, y in ipairs({ 64, 70, 76 }) do local tx, ty = T(120, y); c:fill(c:rect(tx - 4, ty, tx + 4, ty), "#d8c496") end
c:part(E(120, 46, 10, 9), GV.ramp("#f2e4c0", { dot = "#fff3c8" }), { cres = 3, deep = 5 })
do local hx, hy = T(120, 46); hx = math.floor(hx + 0.5); hy = math.floor(hy + 0.5); c:eye(hx - 7, hy - 3); c:eye(hx + 2, hy - 3) end
do
  local a1x, a1y = T(115, 38); local a2x, a2y = T(108, 26); local a3x, a3y = T(100, 18)
  local b1x = T(125, 38); local b2x = T(132, 26); local b3x = T(140, 18)
  c:fill(c:line({ {a1x, a1y}, {a2x, a2y}, {a3x, a3y} }, 2), "#2a1a10"); c:fill(c:line({ {b1x, a1y}, {b2x, a2y}, {b3x, a3y} }, 2), "#2a1a10")
  c:part(c:ellipse(a3x, a3y - 1, 2, 2), GV.ramp("#f5cf6a"), { flat = true }); c:part(c:ellipse(b3x, a3y - 1, 2, 2), GV.ramp("#f5cf6a"), { flat = true })
end
-- fireflies and snow-pine saplings
for _, p in ipairs({ {20,72},{30,100},{128,96},{10,100},{236,60},{60,118} }) do c:px(p[1], p[2], "#fff1c8"); c:px(p[1] + 1, p[2], "#c8d77a") end
L.finish(c, "lair-temple-of-the-tiger-moth")
