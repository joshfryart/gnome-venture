-- home-cottage PASS 2 (final). 240x135 grid, x2 = 480x270.
-- Gnome cottage under a droopy toadstool roof (scalloped lip + gills), leaning stone chimney, arched
-- green door in a stone ring, porthole windows with flower boxes, cobble foundation, lantern.
-- Planes: far = 2-tone hills with tree bumps (no ink); mid = cottage (object: ink outline), apple
-- tree + raised vegetable bed (deep-tone edge); near = ink-edged cream fence with open gate,
-- foxglove bush (bottom-left), sunflower + bush (bottom-right), leafy branch (top-right).
-- quirk: a snail climbing the chimney, leaving a shiny trail.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local c = HP.canvas{ w = 240, h = 135, scale = 2, name = "home-cottage" }
local floor, sin, abs = math.floor, math.sin, math.abs
local R = function(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
local E = function(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local NEARLEAF = { hi = P.moss.base, base = P.moss.shade, shade = P.moss.deep, deep = P.ink }
local CREAMR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }

------------------------------------------------------------ SKY
c:stripes(0, 84, { P.sky.shade, P.sky.base, P.sky.hi }, { 3, 4, 4 })
c:fillMask(E(24, 18, 9, 9), P.gold.base) c:fillMask(E(23, 17, 6, 6), P.gold.hi)
c:cloud(46, 30, 28, P.cream, P.sky.hi)
c:cloud(168, 24, 26, P.cream, P.sky.hi)
c:cloud(196, 48, 16, P.cream, P.sky.hi)

------------------------------------------------------------ FAR (2 colours)
local function far1(x)
  local y = 64 + 6 * sin(x / 31 + .4) + 3 * sin(x / 13)
  for _, t in ipairs{ 70, 84, 190, 204, 214 } do local dx = abs(x - t) if dx < 5 then y = math.min(y, 61 + 5 * sin(t / 31 + .4) + dx * dx * .25 - 4) end end
  return y
end
c:terrain(far1, P.sea.hi)
c:terrain(function(x) return 77 + 5 * sin(x / 23 + 2) + 2 * sin(x / 9) end, P.moss.hi)

------------------------------------------------------------ MID ground
c:terrain(function(x) return 90 + 2 * sin(x / 40) end, P.moss.base)
for _, t in ipairs{ {60, 102}, {176, 96}, {14, 108}, {200, 124}, {150, 120} } do
  c:px(t[1], t[2], P.moss.shade) c:px(t[1] + 2, t[2], P.moss.shade) c:px(t[1] + 1, t[2] - 1, P.moss.shade)
end
-- apple tree (mid, deep-tone edge)
do
  c:fillMask(E(34, 103, 16, 2), P.moss.shade)
  local tr = c:poly{ {29, 103}, {39, 103}, {36, 98}, {35, 74}, {32, 74}, {31, 98} }
  local cr = E(34, 58, 21, 16):add(E(18, 68, 11, 9)):add(E(50, 68, 11, 9)):add(E(26, 46, 9, 7)):add(E(44, 48, 9, 7))
  c:rim(tr:copy():add(cr), P.moss.deep)
  c:part(tr, "wood", { band = 2, nopop = true })
  c:part(cr, "moss", { band = 3, pop = { 22, 48 } })
  for _, l in ipairs{ {30, 52}, {40, 60}, {20, 62}, {46, 52} } do c:px(l[1], l[2], P.moss.shade) c:px(l[1] + 1, l[2] + 1, P.moss.shade) end
  for _, a in ipairs{ {24, 56}, {38, 50}, {30, 66}, {46, 62}, {14, 68}, {52, 70} } do
    R(a[1], a[2], a[1] + 1, a[2] + 1, P.ember.base) c:px(a[1], a[2], P.ember.hi)
  end
  R(44, 101, 45, 102, P.ember.base) R(22, 102, 23, 103, P.ember.shade)
end

------------------------------------------------------------ path stones
for i, s in ipairs{ {115, 116, 6, 2}, {110, 121, 7, 2}, {119, 126, 8, 3}, {111, 132, 9, 3} } do
  c:part(E(s[1], s[2], s[3], s[4]), "stone", { band = 1, nopop = i % 2 == 0 })
end

------------------------------------------------------------ HERO: cottage (ink outline)
local wall = c:rrect(74, 74, 156, 112, 4)
local capC = 113
local cap = E(capC, 77, 62, 40):clip(c:rect(0, 0, 239, 76))
local scal = HP.mask()
for x = 54, 172, 8 do scal:add(E(x, 76, 4, 3)) end
cap:add(scal:clip(E(capC, 77, 63, 40):grow(3)))
local chim = c:poly{ {139, 58}, {153, 56}, {157, 24}, {143, 24} }
local chimTop = c:poly{ {140, 18}, {159, 17}, {160, 24}, {141, 25} }
local base = c:rect(72, 105, 158, 112)
local home = wall:copy():add(cap):add(chim):add(chimTop):add(base)
c:fillMask(E(115, 113, 52, 3), P.moss.shade)
c:rim(home, P.ink)
c:part(wall, CREAMR, { band = 3, nopop = true })
-- gills under the cap
R(74, 79, 156, 80, P.gold.hi)
for x = 75, 156, 3 do c:px(x, 79, P.gold.base) c:px(x, 80, P.gold.base) end
R(74, 81, 156, 81, P.gold.base)
-- timber beams
for _, x in ipairs{ 79, 101, 129, 151 } do R(x, 82, x + 1, 104, P.wood.base) c:px(x + 1, 82, P.wood.shade) end
-- cobble foundation
c:fillMask(base, P.stone.shade)
for i = 0, 14 do
  local x = 73 + i * 6 + ((i % 2) * 1)
  c:part(c:rrect(x, 106 + (i % 2), x + 5, 111, 2), "stone", { band = 1, nopop = i % 3 ~= 0, inner = false })
end
-- cap (droopy toadstool)
c:part(cap, "ember", { band = 4, pop = { 78, 52 } })
for _, s in ipairs{ {82, 60, 7, 5}, {106, 45, 8, 5}, {132, 54, 5, 3}, {164, 68, 6, 4}, {62, 72, 5, 3}, {120, 66, 4, 2}, {94, 70, 3, 2}, {124, 40, 3, 2} } do
  local m = E(s[1], s[2], s[3], s[4]):clip(cap)
  c:fillMask(m, P.cream)
  m:each(function(x, y) if not m:has(x + 1, y + 1) and m:has(x, y - 1) then c:px(x, y, P.gold.hi) end end)
end
-- attic window
c:rim(E(100, 60, 3, 3), P.wood.deep)
c:fillMask(E(100, 60, 3, 3), P.gold.hi) c:px(100, 58, P.cream) R(97, 60, 103, 60, P.wood.deep)
-- leaning chimney, drawn over the cap
local chimVis = chim:copy():cut(cap)
c:part(chimVis, "stone", { band = 2, nopop = true })
for y = 26, 44, 5 do
  local off = ((y // 5) % 2) * 3
  c:fillMask(c:rect(143, y, 157, y):clip(chimVis), P.stone.shade)
  c:fillMask(c:rect(151 + off, y + 1, 151 + off, y + 4):clip(chimVis), P.stone.shade)
end
c:part(chimTop, "stone", { band = 1, pop = { 142, 19 } })
-- door: arched, green, stone ring
local ring = E(115, 99, 12, 14):clip(c:rect(0, 0, 239, 111))
local door = E(115, 99, 9, 11):clip(c:rect(0, 0, 239, 111))
c:part(ring, "stone", { band = 1, nopop = true, inner = false })
for _, a in ipairs{ {104, 98}, {106, 90}, {111, 86}, {119, 86}, {124, 90}, {126, 98} } do c:px(a[1], a[2], P.stone.shade) end
c:rim(door, P.ink)
c:part(door, "moss", { band = 2, pop = { 109, 92 } })
R(112, 89, 112, 110, P.moss.shade) R(118, 89, 118, 110, P.moss.shade)
R(107, 94, 113, 95, P.wood.deep) R(107, 104, 113, 105, P.wood.deep)
c:fillMask(E(121, 100, 1, 1), P.gold.base) c:px(120, 99, P.gold.hi)
R(103, 112, 127, 113, P.stone.base) R(103, 113, 127, 113, P.stone.shade)
-- lantern beside the door
R(96, 84, 96, 86, P.ink) c:part(c:rrect(94, 87, 98, 92, 1), "gold", { band = 1, nopop = true }) c:px(95, 88, P.cream)
-- porthole windows + flower boxes
local function window(cx, cy)
  local f = E(cx, cy, 8, 8)
  c:rim(f, P.wood.deep) c:fillMask(f, P.wood.base)
  c:fillMask(E(cx, cy, 6, 6), P.sea.base)
  c:fillMask(E(cx, cy, 6, 6):clip(c:rect(cx - 7, cy - 7, cx + 1, cy - 1)), P.sea.hi)
  R(cx, cy - 6, cx, cy + 6, P.wood.base) R(cx - 6, cy, cx + 6, cy, P.wood.base)
  c:px(cx - 3, cy - 4, P.cream)
  local box = c:rect(cx - 10, cy + 7, cx + 10, cy + 10)
  c:rim(box, P.wood.deep) c:part(box, "wood", { band = 1, nopop = true })
  local cols = { "petal", "gold", "dusk", "ember", "petal", "gold", "dusk" }
  for i = 0, 6 do
    local fx = cx - 9 + i * 3
    c:px(fx, cy + 6, P.moss.base) c:px(fx + 1, cy + 6, P.moss.shade)
    local col = P[cols[i + 1]]
    c:px(fx, cy + 4 + (i % 2), col.base) c:px(fx + 1, cy + 4 + (i % 2), col.shade) c:px(fx, cy + 3 + (i % 2), col.hi)
  end
end
window(89, 91) window(141, 91)

------------------------------------------------------------ smoke (curly puffs)
c:fillMask(E(153, 11, 3, 2), P.stone.hi) c:fillMask(E(158, 5, 4, 3), P.stone.hi)
c:fillMask(E(166, 2, 5, 3), P.cream) c:px(155, 10, P.cream) c:px(156, 10, P.cream)

------------------------------------------------------------ QUIRK: snail climbing the chimney + shiny trail
for y = 38, 47 do c:px(148 + ((y // 3) % 2), y, P.sky.hi) end
c:paint({
  "...e.e....",
  "...k.k....",
  "...ccc....",
  "...ccc....",
  ".ssssc....",
  "sPhPPsc...",
  "sPdddsc...",
  "sPdPdsc...",
  "sPPddsc...",
  ".ssssc....",
  "....cc....",
  ".....c....",
}, 143, 26, { e = "#2b1c26", k = "#fff4d6", c = "#fff4d6", s = "petal.deep", P = "petal.base", h = "petal.hi", d = "petal.shade" })
c:px(147, 29, P.ink)

------------------------------------------------------------ raised vegetable bed (mid, deep edge)
do
  local bed = c:rrect(170, 98, 232, 117, 2)
  c:rim(bed, P.wood.deep)
  c:fillMask(bed, P.wood.base)
  local soil = c:rect(172, 100, 230, 115)
  c:fillMask(soil, P.wood.shade)
  for i = 0, 5 do
    local x = 176 + i * 10
    c:fillMask(E(x, 103, 3, 2), P.moss.base) c:px(x, 103, P.moss.hi) c:px(x + 2, 104, P.moss.shade)          -- cabbages
    R(x + 3, 107, x + 3, 109, P.moss.shade) c:px(x + 2, 107, P.moss.base) c:px(x + 4, 107, P.moss.base)
    R(x + 2, 110, x + 4, 110, P.ember.hi)                                                                     -- carrots
    if i % 2 == 0 then c:part(E(x, 113, 3, 2), "gold", { band = 1 }) c:px(x, 110, P.moss.deep)
    else c:fillMask(E(x, 113, 2, 1), P.ember.base) R(x, 111, x, 112, P.moss.base) end                       -- pumpkins / radish
  end
  -- watering can
  local can = c:rrect(160, 108, 167, 115, 1)
  local spout = c:line({ {167, 111}, {171, 107} }, 1)
  c:rim(can:copy():add(spout), P.sea.deep)
  c:part(can, "sea", { band = 1 }) c:fillMask(spout, P.sea.shade)
end

------------------------------------------------------------ NEAR: fence (cream pickets, ink), open gate
local fence = HP.mask()
for i, x in ipairs{ -3, 5, 13, 21, 29, 37, 45, 53, 61, 69, 77, 85, 93, 133, 141, 149, 157, 165, 173, 181, 189, 197, 205, 213, 221, 229, 237 } do
  local top = 114 + ((i * 5) % 3 == 0 and 1 or 0) - ((i % 4 == 0) and 1 or 0)
  fence:add(c:rrect(x, top, x + 4, 128, 2))
end
fence:add(c:rect(0, 118, 97, 119)):add(c:rect(0, 123, 97, 124)):add(c:rect(133, 118, 239, 119)):add(c:rect(133, 123, 239, 124))
-- gate swung open toward the viewer (on the right post)
local gate = c:poly{ {128, 116}, {133, 118}, {133, 129}, {128, 131} }
c:rim(fence:copy():add(gate), P.ink)
c:part(fence, CREAMR, { band = 1, nopop = true, inner = false })
c:part(gate, "wood", { band = 1, nopop = true })
R(129, 121, 132, 122, P.wood.deep)
R(0, 129, 239, 134, P.moss.shade)
c:fillMask(c:poly{ {103, 135}, {107, 129}, {124, 129}, {130, 135} }, P.moss.base)
-- bottom-left: bush + foxglove spikes (stacked bells)
do
  local b = E(14, 122, 24, 14):add(E(38, 132, 12, 6))
  local spikes = { {8, 96, 112}, {19, 101, 114}, {30, 107, 118} }
  local fg = HP.mask()
  for _, f in ipairs(spikes) do
    local k = 0
    for y = f[2], f[3], 3 do local r = 1 + floor((y - f[2]) / (f[3] - f[2]) * 1.6 + .5) fg:add(E(f[1] + (k % 2), y, r, 1.5)) k = k + 1 end
  end
  c:rim(b:copy():add(fg), P.ink)
  c:part(b, NEARLEAF, { band = 3, pop = { 4, 112 } })
  c:fillMask(fg, P.petal.base)
  fg:each(function(x, y) if not fg:has(x + 1, y) or not fg:has(x, y + 1) then c:px(x, y, P.petal.shade) end end)
  for _, f in ipairs(spikes) do c:px(f[1], f[2], P.moss.base) for y = f[2] + 3, f[3], 3 do c:px(f[1] - 1, y, P.petal.hi) end end
end
-- bottom-right: sunflower + bush
do
  local b = E(228, 128, 18, 10):add(E(208, 133, 12, 5))
  local stem = c:rect(219, 100, 220, 124)
  local leaf = c:poly{ {220, 112}, {227, 108}, {222, 114} }
  local head = E(219.5, 96, 6, 6)
  c:rim(b:copy():add(stem):add(leaf):add(head), P.ink)
  c:part(b, NEARLEAF, { band = 3, pop = { 214, 124 } })
  c:fillMask(stem, P.moss.shade) c:fillMask(leaf, P.moss.base)
  c:part(head, "gold", { band = 2, pop = { 215, 92 } })
  c:fillMask(E(219.5, 96, 2, 2), P.wood.shade) c:px(219, 95, P.wood.base)
end
-- top-right: leafy branch reaching in from the edge
do
  local br = c:line({ {240, 6}, {226, 10}, {214, 9} }, 2)
  local lv = HP.mask()
  for _, l in ipairs{ {232, 4, 5, 3}, {222, 14, 5, 3}, {214, 4, 4, 3}, {238, 14, 5, 4}, {208, 12, 4, 2} } do lv:add(E(l[1], l[2], l[3], l[4])) end
  c:rim(br:copy():add(lv), P.ink)
  c:fillMask(br, P.wood.shade)
  c:part(lv, "moss", { band = 1, nopop = true })
  c:px(222, 13, P.moss.hi) c:px(223, 13, P.moss.hi) c:px(231, 3, P.moss.hi) c:px(232, 3, P.moss.hi)
end

c:finish{ outline = false }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "home-cottage.aseprite", png = out .. "home-cottage.png", scale = 2 }
