-- npc-bramble-mossfoot PASS 3 (B: polish over A). Hearth Pop v3, 80x100 portrait, bleed off bottom.
-- Hedgehog villager: spiky crown (wood ramp, pale quill tips, darker back row), tan face, pointed cream snout
-- with a wet ink nose, red knitted scarf with gold-striped tails, green knit jumper with placket and two buttons.
-- quirk: a nibbled leaf tucked behind the right ear.
-- p3: eye "goggle" band removed, real snout + whiskers, knit texture / folds / cables on the jumper,
-- quill texture in the crown, extra ramp steps, disc outlined in its own sky tones.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-bramble-mossfoot"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local D4 = { {1,0},{-1,0},{0,1},{0,-1} }
local function keep(x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
local function pts(list, hex) for _, p in ipairs(list) do keep(p[1], p[2], hex) end end
local function mid(mask, a, b, m)
  local s = {}
  mask:each(function(x, y) if c:get(x, y) == a then
    for _, d in ipairs(D4) do if c:get(x + d[1], y + d[2]) == b then s[#s + 1] = { x, y } break end end end end)
  for _, p in ipairs(s) do keep(p[1], p[2], m) end
end
local function recol(mask, map) mask:each(function(x, y) local v = map[c:get(x, y) or ""] if v then keep(x, y, v) end end) end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs(D4) do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local FACE = { hi = P.cream, base = "#f4d3a6", shade = P.skinA.base, deep = P.skinA.shade }
local cx, cy = 40, 46

---------------------------------------------------------------- jumper: knit, folds, placket
local jum = c:ellipse(39.5, 104, 38, 34):clip(c:rect(0, 68, 79, 99))
c:part(jum, "moss", { band = 3, pop = { x = 12, y = 84 } })
mid(jum, P.moss.base, P.moss.shade, "#5aa855")
-- V-stitch knit columns (low contrast)
local knit = HP.mask()
for y = 68, 99 do for x = 0, 79 do
  local a, b = x % 4, (y + (x // 4) % 2) % 3
  if (b == 0 and (a == 0 or a == 3)) or (b == 1 and (a == 1 or a == 2)) then knit:set(x, y) end
end end
recol(knit:clip(jum), { [P.moss.base] = "#6db552", [P.moss.shade] = "#36854a", ["#5aa855"] = "#4f9c51", [P.moss.hi] = "#a9d46c" })
-- drape folds from the shoulders toward the placket
for _, f in ipairs{ { {14,76},{20,84},{24,96} }, { {66,77},{60,86},{57,97} } } do
  local ln = c:line(f, 1):clip(jum)
  recol(ln, { [P.moss.base] = "#5aa855", ["#6db552"] = "#5aa855", ["#5aa855"] = P.moss.shade, [P.moss.shade] = "#2f7448", ["#36854a"] = "#2f7448" })
  recol(ln:shift(-1, 0):clip(jum), { [P.moss.base] = "#98d06a", ["#6db552"] = "#98d06a" })
end
-- cable twists either side of the placket
for _, cx0 in ipairs{ 32, 45 } do
  for y = 76, 99, 4 do
    recol(c:line({ {cx0, y}, {cx0 + 2, y + 2} }, 1):clip(jum), { [P.moss.base] = "#98d06a", ["#6db552"] = "#98d06a", ["#5aa855"] = P.moss.base, [P.moss.shade] = "#5aa855", ["#36854a"] = "#5aa855" })
    recol(c:line({ {cx0 + 2, y + 2}, {cx0, y + 4} }, 1):clip(jum), { [P.moss.base] = P.moss.shade, ["#6db552"] = P.moss.shade, ["#5aa855"] = P.moss.shade, [P.moss.shade] = "#2f7448", ["#36854a"] = "#2f7448" })
    keep(cx0 - 1, y + 2, P.moss.shade) keep(cx0 + 3, y + 2, P.moss.shade)
  end
end
-- ribbed neckline under the scarf
for x = 20, 60 do if jum:has(x, 72) then keep(x, 72, (x % 2 == 0) and P.moss.shade or "#5aa855") keep(x, 73, (x % 2 == 0) and "#5aa855" or P.moss.base) end end
-- raglan seams and a ribbed patch pocket on the left breast
for _, sm in ipairs{ { {25,73},{17,80},{9,92} }, { {55,73},{63,80},{71,92} } } do
  local ln = c:line(sm, 1):clip(jum)
  recol(ln, { [P.moss.base] = "#5aa855", ["#6db552"] = "#5aa855", ["#98d06a"] = "#5aa855", ["#5aa855"] = P.moss.shade, [P.moss.shade] = "#2f7448", ["#36854a"] = "#2f7448", [P.moss.hi] = P.moss.base, ["#a9d46c"] = P.moss.base })
end
local pk = c:rrect(19, 86, 28, 96, 1)
c:part(pk, "moss", { band = 1, nopop = true })
mid(pk, P.moss.base, P.moss.shade, "#5aa855")
for x = 19, 28 do keep(x, 87, (x % 2 == 0) and P.moss.shade or "#5aa855") end
keep(20, 89, P.moss.hi) keep(21, 89, P.moss.hi)
-- placket + buttons
local plk = c:rect(38, 76, 41, 99):clip(jum)
recol(plk, { [P.moss.base] = "#6db552", ["#5aa855"] = "#6db552" })
c:fillMask(c:line({ {37,76},{37,99} }, 1), P.moss.shade)
c:fillMask(c:line({ {42,76},{42,99} }, 1), P.moss.shade)
c:button(40, 84) c:button(40, 94)
pts({ {39,83},{39,93} }, P.gold.hi)

---------------------------------------------------------------- spikes
local core = c:ellipse(cx, cy, 20, 19)
local function wedge(tx, ty, half)
  local a = math.atan(ty - cy, tx - cx)
  local r0 = 19
  local m = c:poly{ { cx + math.cos(a - half) * r0, cy + math.sin(a - half) * r0 }, { tx, ty }, { cx + math.cos(a + half) * r0, cy + math.sin(a + half) * r0 } }
  return { s = m, a = a, t = { tx, ty }, len = math.sqrt((tx - cx) ^ 2 + (ty - cy) ^ 2), half = half, r0 = r0 }
end
local front = {}
local LEN = { 34, 36, 34, 37, 35, 38, 35, 37, 34, 36, 33 }
for i = 0, 10 do
  local a = math.rad(152 + i * 23.6)
  local L = LEN[i + 1]
  front[#front + 1] = wedge(cx + math.cos(a) * L, cy + math.sin(a) * L * 0.9, 0.34)
end
local back = {}
local BL = { 29, 30, 31, 30, 32, 30, 31, 29, 30, 28 }
for i = 0, 9 do
  local a = math.rad(152 + 11.8 + i * 23.6)
  back[#back + 1] = wedge(cx + math.cos(a) * BL[i + 1], cy + math.sin(a) * BL[i + 1] * 0.9, 0.26)
end
local mass = core:copy()
for _, sp in ipairs(front) do mass:add(sp.s) end
for _, sp in ipairs(back) do mass:add(sp.s) end
c:part(mass, "wood", { band = 3, pop = { x = 27, y = 33 } })
local inFront = HP.mask()
for _, sp in ipairs(front) do inFront:add(sp.s) end
for _, sp in ipairs(back) do
  sp.s:copy():cut(core):cut(inFront):each(function(x, y)
    local col = P.wood.shade
    if inFront:has(x - 1, y) or inFront:has(x + 1, y) or inFront:has(x, y - 1) then col = P.wood.deep end
    c:put(x, y, col, P.wood)
  end)
end
for _, sp in ipairs(front) do
  local ax, ay = math.cos(sp.a), math.sin(sp.a)
  sp.s:copy():cut(core):each(function(x, y)
    local dx, dy = x + .5 - cx, y + .5 - cy
    local along = dx * ax + dy * ay
    local side = ax * dy - ay * dx
    local hw = math.sin(sp.half) * sp.r0 * (1 - (along - sp.r0) / (sp.len - sp.r0))
    local col = P.wood.base
    if side > hw - 2.2 then col = P.wood.shade elseif side > hw - 3.4 then col = "#a06640" end
    if sp.len - along < 4 then col = (side > hw - 1.6) and "#d3a06c" or P.wood.hi end
    c:put(x, y, col, P.wood)
  end)
end

---------------------------------------------------------------- leaf
local leaf = c:poly{ {57,38},{59,30},{64,24},{71,21},{70,28},{66,34},{60,39} }
leaf:cut(c:ellipse(69.5, 29.5, 1.5, 1.5)):cut(c:ellipse(67, 32.5, 1.5, 1.2))
c:part(leaf, "moss", { band = 1, pop = { x = 61, y = 30 } })
c:fillMask(c:line({ {59,37},{63,30},{70,22} }, 1):clip(leaf), P.moss.shade)

---------------------------------------------------------------- ears
for _, e in ipairs{ { 24, 38 }, { 56, 38 } } do
  c:part(c:ellipse(e[1], e[2], 3.5, 3.5), "skinA", { band = 1, nopop = true })
  c:fillMask(c:ellipse(e[1], e[2] + 0.5, 1.5, 1.5), P.petal.base)
end

---------------------------------------------------------------- face: tan fur, no eye mask
local face = c:ellipse(40.5, 52, 18, 13):add(c:ellipse(33, 44, 9, 7)):add(c:ellipse(48, 44, 9, 7))
face:cut(c:poly{ {35,32},{40.5,41},{46,32} })
for _, t in ipairs{ { {23,52},{19,55},{23,57} }, { {23,57},{20,61},{25,61} }, { {58,52},{62,55},{58,57} }, { {57,57},{61,61},{56,61} } } do face:add(c:poly(t)) end
c:part(face, FACE, { nopop = true, band = 2 })
mid(face, FACE.base, FACE.shade, "#f4cb9e")
c:eyeLocked(30, 45) c:eyeLocked(44, 45)
pts({ {30,43},{31,42},{32,42},{46,42},{47,42},{48,43} }, P.wood.shade)   -- brows
c:cheek(26, 55) c:cheek(54, 55)
-- MUZZLE: pointed cream snout set off from the tan face, contour under it, nose at the point
local muz = c:poly{ {33,50},{50,50},{49.5,54},{46.5,58},{42,59.5},{37.5,57.5},{34,54} }
muz:add(c:ellipse(41.5, 51.5, 8.5, 2.5)):add(c:poly{ {37.5,50},{38.5,45},{40,43.5},{42,43.5},{43.5,45},{44.5,50} })
c:part(muz, { hi = P.cream, base = P.cream, shade = "#fbe6c4", deep = P.skinA.base }, { nopop = true, band = 1, inner = false })
muz:edge():each(function(x, y) if y >= 54 or x >= 49 then keep(x, y, P.skinA.base) end end)
pts({ {43,45},{43,46},{43,47},{44,48},{44,49} }, "#fbe6c4")             -- bridge side plane
pts({ {39,46},{39,47} }, P.cream)
-- wet nose tip: ink button at the snout point, cream glint, cool reflected light under it
c:paint({
  ".iiii.",
  "iCgiii",
  "iiiiri",
  ".iiii.",
}, 40, 55, { i = "ink", C = "cream", g = "#8a7a86", r = "#5a4458" })
-- little w mouth under the point
pts({ {39,60},{40,61},{41,61},{42,60},{43,61},{44,61},{45,60} }, P.skinA.deep)
-- whisker dots
pts({ {36,53},{35,55},{37,55},{47,53},{48,55},{46,55} }, P.wood.shade)

---------------------------------------------------------------- scarf: knit wrap, knot, striped tails, fringe
local wrap = c:poly{ {22,66},{32,63},{40,66},{48,63},{58,66},{59,73},{48,76},{40,77},{32,76},{21,73} }
c:part(wrap, "ember", { band = 2, pop = { x = 26, y = 67 } })
mid(wrap, P.ember.base, P.ember.shade, "#cf3b3c")
for x = 23, 58, 3 do recol(c:line({ {x,63},{x,77} }, 1):clip(wrap), { [P.ember.base] = "#cf3b3c", [P.ember.shade] = "#9c2a3c" }) end
local t1 = c:poly{ {46,77},{54,77},{56,93},{48,93} }
local t2 = c:poly{ {53,76},{58,76},{65,88},{60,91} }
c:part(t2, "ember", { band = 1, nopop = true })
c:part(t1, "ember", { band = 2, nopop = true })
recol(c:rect(40, 82, 70, 83):clip(t1), { [P.ember.base] = P.gold.base, [P.ember.shade] = P.gold.shade })
recol(c:rect(40, 88, 70, 89):clip(t1), { [P.ember.base] = P.gold.base, [P.ember.shade] = P.gold.shade })
recol(c:line({ {56,81},{61,79} }, 2):clip(t2), { [P.ember.base] = P.gold.base, [P.ember.shade] = P.gold.shade })
c:part(c:ellipse(50.5, 76, 4, 3), "ember", { band = 1, pop = { x = 48, y = 75 } })
-- fringe
for _, x in ipairs{ 48, 51, 54 } do c:part(c:rect(x, 94, x + 1, 96), "ember", { noshade = true, nopop = true, inner = false }) keep(x + 1, 96, P.ember.shade) end
-- wrap crease where the scarf crosses itself
c:line({ {40,67},{38,72},{40,76} }, 1):clip(wrap):each(function(x, y) keep(x, y, P.ember.shade) end)

c:finish{ outline = true }
backdrop(P.sky)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
