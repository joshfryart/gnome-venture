-- village-poppyburrow PASS B (final). Village card scene 160x100 (welcome step 2), full canvas, no outer outline.
-- Planes: sky (3 bands, sun, puffs) + far hills (2 low-contrast tones, tree bumps);
-- mid: three grassy burrow mounds with round doors, porthole windows and pipe chimneys, a gold path
-- winding to the hero door, a windsock on the hero mound; near: big ink-edged poppies and grass.
-- quirk: the wind has stolen a gnome's red hat; it tumbles off toward the windsock while he chases it.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (d .. "/")
local NAME = app.params.name or "village-poppyburrow"
local c = HP.canvas{ w = 160, h = 100, scale = 1, name = NAME }
local sin, floor, abs = math.sin, math.floor, math.abs
local seed = 11
local function rnd() seed = (seed * 1103515245 + 12345) % 2147483648 return seed / 2147483648 end
local E = function(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local R = function(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
local FAR1, FAR2 = "#a9dccb", "#93cfb4"
-- sprite(rows, x, y, map): paints a char map and rims it in ink (outline outside only)
local function sprite(rows, x0, y0, map, edge)
  local m = HP.mask()
  for j, row in ipairs(rows) do for i = 1, #row do if row:sub(i, i) ~= "." then m:set(x0 + i - 1, y0 + j - 1) end end end
  c:rim(m, edge or P.ink)
  c:paint(rows, x0, y0, map)
  return m
end

------------------------------------------------------------ SKY
c:stripes(0, 50, { P.sky.shade, P.sky.base, P.sky.hi }, { 3, 4, 4 })
c:fillMask(E(142, 11, 6, 6), P.gold.base) c:fillMask(E(141, 10, 4, 4), P.gold.hi)
c:cloud(8, 22, 26, P.cream, P.sky.hi)
c:cloud(98, 16, 20, P.cream, P.sky.hi)
c:cloud(56, 30, 13, P.cream, P.sky.hi)
for _, g in ipairs{ {26, 6}, {32, 9}, {21, 9} } do c:px(g[1], g[2], P.sky.deep) c:px(g[1] - 1, g[2] - 1, P.sky.deep) c:px(g[1] + 1, g[2] - 1, P.sky.deep) end

------------------------------------------------------------ FAR (2 tones, tree bumps)
local function far1(x)
  local y = 40 + 5 * sin(x / 24 + 1) + 2 * sin(x / 9)
  for _, t in ipairs{ 18, 24, 120, 127, 150 } do local dx = abs(x - t) if dx < 4 then y = math.min(y, 37 + 4 * sin(t / 24 + 1) + dx * dx * .3 - 3) end end
  return y
end
c:terrain(far1, FAR1)
c:terrain(function(x) return 46 + 3 * sin(x / 17 + 3) end, FAR2)
for _, b in ipairs{ {44, 46}, {100, 47}, {150, 45} } do
  c:fillMask(E(b[1], b[2] + 2, 5, 3):clip(c:rect(0, 0, 159, b[2] + 2)), "#7fbf9f")
  c:px(b[1], b[2] + 1, P.wood.shade) c:px(b[1], b[2] + 2, P.wood.shade) c:px(b[1] - 2, b[2], "#a9dccb")
end
-- back meadow
c:terrain(function(x) return 50 + 1.5 * sin(x / 13) end, P.moss.hi)
c:terrain(function(x) return 56 + 2 * sin(x / 21 + 1) end, P.moss.base)
for i = 1, 70 do local x, y = floor(rnd() * 160), 51 + floor(rnd() * 6) c:px(x, y, (y < 54) and P.ember.hi or P.ember.base) end   -- far poppy specks
for i = 1, 50 do local x, y = floor(rnd() * 160), 58 + floor(rnd() * 30) c:px(x, y, P.moss.shade) c:px(x + 1, y - 1, P.moss.shade) end

------------------------------------------------------------ PATH (winding to the hero door)
local path = HP.mask()
for y = 70, 99 do
  local cx = 66 + 8 * sin((y - 70) / 9) + (y - 70) * .35
  local hw = 2 + (y - 70) * .22
  for x = floor(cx - hw), floor(cx + hw + .5) do path:set(x, y) end
end
c:fillMask(path, P.gold.hi)
path:each(function(x, y) if not path:has(x + 1, y) or not path:has(x, y + 1) then c:px(x, y, "#e7b873") end end)
for _, s in ipairs{ {64, 76, 1}, {70, 83, 2}, {74, 92, 2} } do c:fillMask(E(s[1], s[2], s[3] + 1, s[3] * .5), "#e7b873") end

------------------------------------------------------------ MOUNDS (burrow houses)
local DOORS = { hero = "gold", left = "sea", right = "dusk" }
local TURF = { hi = "#b4dc72", base = P.moss.base, shade = P.moss.shade, deep = P.moss.deep }
local function mound(cx, base, rx, ry, o)
  local m = E(cx, base, rx, ry):clip(c:rect(0, 0, 159, base))
  c:rim(m, P.moss.deep)
  c:fillMask(m, TURF.base)
  -- lit dome upper-left, shade band lower-right
  m:each(function(x, y)
    if not m:has(x - 2, y - 2) and x < cx + rx * .35 then c:px(x, y, TURF.hi) end
    if not m:has(x + 3, y + 2) then c:px(x, y, TURF.shade) end
    if not m:has(x + 1, y + 1) and y < base - 1 then c:px(x, y, TURF.deep) end
  end)
  -- bottom skirt: a darker row of grass where the turf meets the meadow
  R(cx - rx, base, cx + rx, base, P.moss.shade)
  -- grass tufts (turf texture)
  for i = 1, floor(rx * .9) do
    local x, y = cx - rx + 3 + floor(rnd() * (rx * 2 - 6)), base - 3 - floor(rnd() * (ry - 4))
    if m:has(x - 2, y - 2) and m:has(x + 3, y + 2) and c:get(x, y) == TURF.base then
      c:px(x, y, P.moss.shade) c:px(x - 1, y - 1, P.moss.shade) c:px(x + 1, y - 1, P.moss.shade) c:px(x, y - 1, TURF.hi)
    end
  end
  m:each(function(x, y) if not m:has(x, y - 1) and (x + floor(cx)) % 5 == 0 then c:px(x, y - 1, P.moss.deep) c:px(x, y - 2, P.moss.deep) end end)
  -- round door: wood ring, coloured planks, knob
  local dr, dcx = o.door, o.dx or cx
  local dcy = base - dr + 1
  local ring = E(dcx, dcy, dr + 1, dr + 1):clip(c:rect(0, 0, 159, base))
  c:rim(ring, P.ink)
  c:part(ring, "wood", { band = 1, nopop = true, inner = false })
  for _, a in ipairs{ {-1, -1}, {1, -1}, {0, -1} } do c:px(dcx + a[1] * (dr - 1), dcy - dr + (a[1] == 0 and 0 or 2), P.wood.deep) end
  local dm = E(dcx, dcy, dr - 1, dr - 1):clip(c:rect(0, 0, 159, base))
  c:part(dm, o.col, { band = 2, nopop = true, inner = false })
  for x = dcx - dr + 2, dcx + dr - 2, 2 do c:fillMask(c:rect(x, dcy - dr, x, base):clip(dm), P[o.col].shade) end
  c:px(dcx - dr + 2, dcy - 2, P[o.col].hi) c:px(dcx - dr + 2, dcy - 1, P[o.col].hi)
  c:fillMask(E(dcx + dr - 3, dcy + 1, .5, .5), P.gold.base) c:px(dcx + dr - 3, dcy, P.gold.hi)
  -- step stone
  local st = E(dcx, base + 1, dr + 1, 1)
  c:fillMask(st, P.stone.base) R(dcx - dr + 1, base + 2, dcx + dr - 1, base + 2, P.stone.shade) c:px(dcx - 2, base + 1, P.stone.hi) c:px(dcx - 1, base + 1, P.stone.hi)
  -- porthole windows
  for _, w in ipairs(o.win or {}) do
    local f = E(w[1], w[2], 3, 3)
    c:rim(f, P.ink) c:fillMask(f, P.wood.base)
    local g = E(w[1], w[2], 2, 2)
    c:fillMask(g, P.gold.base) c:fillMask(g:copy():clip(c:rect(w[1] - 3, w[2] - 3, w[1], w[2])), P.gold.hi)
    R(w[1] - 2, w[2], w[1] + 2, w[2], P.wood.shade) R(w[1], w[2] - 2, w[1], w[2] + 2, P.wood.shade)
    c:px(w[1] - 1, w[2] - 1, P.cream)
    R(w[1] - 3, w[2] + 4, w[1] + 3, w[2] + 4, P.wood.shade)                                  -- sill
    c:px(w[1] - 2, w[2] + 3, P.ember.base) c:px(w[1] + 2, w[2] + 3, P.ember.base) c:px(w[1], w[2] + 3, P.petal.hi)
  end
  -- pipe chimney with smoke
  if o.pipe then
    local px, py = o.pipe[1], o.pipe[2]
    local pm = c:rect(px, py, px + 2, py + 5)
    c:rim(pm, P.ink) c:part(pm, "stone", { band = 1, nopop = true })
    R(px - 1, py - 1, px + 3, py, P.stone.shade) R(px - 1, py - 1, px + 1, py - 1, P.stone.hi)
    c:fillMask(E(px + 3, py - 4, 2, 1), P.stone.hi) c:fillMask(E(px + 6, py - 7, 2, 2), P.cream) c:fillMask(E(px + 10, py - 9, 1, 1), P.cream)
  end
  for _, f in ipairs(o.roofPop or {}) do
    c:px(f[1], f[2], P.ember.base) c:px(f[1] + 1, f[2], P.ember.shade) c:px(f[1], f[2] - 1, P.ember.hi) c:px(f[1], f[2] + 1, P.moss.deep)
  end
  return m
end
mound(17, 68, 22, 18, { door = 5, col = DOORS.left, win = { {32, 59} }, roofPop = { {8, 56}, {22, 53} } })
mound(138, 70, 26, 22, { door = 6, col = DOORS.right, dx = 140, win = { {123, 60}, {153, 58} }, pipe = { 126, 45 }, roofPop = { {132, 51}, {146, 52} } })
local hero = mound(72, 76, 31, 30, { door = 8, col = DOORS.hero, dx = 70, win = { {52, 64}, {88, 63} }, pipe = { 84, 46 }, roofPop = { {62, 52}, {76, 50}, {94, 58}, {50, 56} } })
-- lantern beside the hero door
R(80, 63, 80, 64, P.ink) c:fillMask(c:rect(79, 65, 81, 68), P.gold.base) c:px(79, 65, P.cream) R(79, 68, 81, 68, P.gold.shade) c:rim(c:rect(79, 65, 81, 68), P.ink, c:rect(78, 65, 82, 69))

------------------------------------------------------------ WINDSOCK (on the hero crown)
R(63, 19, 63, 47, P.wood.base) R(62, 19, 62, 47, P.ink) R(64, 19, 64, 47, P.ink) c:fillMask(E(63, 18, 1, 1), P.gold.base) c:px(62, 17, P.gold.hi)
do
  local sx, sy = 65, 20
  for i = 0, 17 do
    local hw = 3 - floor(i / 6)
    local mid = sy + 3 + floor(1.3 * sin(i / 3) + .5)
    local red = ((i // 4) % 2 == 0)
    for j = -hw, hw do c:px(sx + i, mid + j, red and P.ember.base or P.cream) end
    c:px(sx + i, mid + hw, red and P.ember.shade or P.stone.hi)
    c:px(sx + i, mid - hw, red and P.ember.hi or P.cream)
    c:px(sx + i, mid - hw - 1, P.ink) c:px(sx + i, mid + hw + 1, P.ink)
  end
  R(65, 20, 65, 26, P.ink)
end

------------------------------------------------------------ QUIRK: hat in the wind, gnome giving chase
sprite({
  ".....R",
  "....RR",
  "...RRr",
  "..RhRr",
  ".RRRrr",
  "GGGGGg",
  ".gggg.",
}, 109, 21, { R = "ember.base", r = "ember.shade", h = "ember.hi", G = "gold.hi", g = "gold.shade" })
for _, sw in ipairs{ {{98, 26}, {104, 26}}, {{96, 29}, {101, 29}}, {{100, 32}, {104, 32}} } do R(sw[1][1], sw[1][2], sw[2][1], sw[2][2], P.cream) end
sprite({
  "S.........S",
  "B.........B",
  "B...ccc...B",
  "B..cSSSc..B",
  ".B.SiSiS.B.",
  "..BSSnSSB..",
  "..CCSSSCC..",
  "..CCCCCCC..",
  "..BCCcCCB..",
  "..BBCCCBB..",
  "..bBBGBBb..",
  "...bBBBb...",
  "...W...W...",
  "..WW...WW..",
}, 98, 58, { S = "skinA.base", n = "skinA.shade", c = "cream", C = "cream", i = "ink", B = "sea.shade", b = "sea.deep", G = "gold.base", W = "wood.shade" })
c:px(102, 60, P.stone.hi) c:px(103, 66, P.stone.hi)
c:px(99, 65, P.cream) c:px(110, 64, P.cream)                   -- surprise marks

-- mushrooms by the left door, a log pile by the right mound
for _, m in ipairs{ {4, 66, "ember"}, {8, 67, "gold"} } do
  sprite({ ".RR.", "RhRR", ".SS.", ".SS." }, m[1], m[2] - 3, { R = m[3] .. ".base", h = "cream", S = "cream" })
end
sprite({
  "wwwwHe",
  "WWWWeh",
  "sssseH",
  ".wwwwHe",
  ".WWWWeh",
  ".sssseH",
}, 111, 63, { w = "wood.base", W = "wood.shade", s = "wood.deep", H = "wood.hi", e = "#d9a066", h = "wood.base" })

------------------------------------------------------------ NEAR: poppies everywhere
local function poppy(x, y, s, edge)
  local h = 3 + s * 3
  R(x, y + 1, x, y + h, P.moss.shade)
  if s >= 1 then c:px(x - 1, y + h - 2, P.moss.base) c:px(x + 1, y + h - 1, P.moss.base) end
  local pet = E(x, y, 1 + s, s * .8 + .2)
  if edge then c:rim(pet, edge) end
  c:fillMask(pet, P.ember.base)
  pet:each(function(px, py) if py > y then c:px(px, py, P.ember.shade) end end)
  c:px(x - 1, y - floor(s * .8), P.ember.hi) if s >= 2 then c:px(x - 2, y - floor(s * .8) + 1, P.ember.hi) end
  c:px(x, y, P.ink) if s >= 2 then c:px(x + 1, y, P.ink) end
end
for i = 1, 40 do
  local x, y = floor(rnd() * 160), 62 + floor(rnd() * 12)
  local g = c:get(x, y) if not path:has(x, y) and not hero:has(x, y) and (g == P.moss.base:lower() or g == P.moss.shade:lower()) and y > 64 then c:px(x, y, P.ember.base) c:px(x + 1, y, P.ember.shade) c:px(x, y - 1, P.ember.hi) end
end
for i = 1, 40 do
  local x, y = floor(rnd() * 160), 75 + floor(rnd() * 9)
  if not path:has(x, y) and not path:has(x, y + 3) then poppy(x, y, 1) end
end
local function bud(x, y)
  R(x, y + 1, x, y + 8, P.moss.shade) c:px(x + 1, y, P.moss.shade)
  c:rim(c:rect(x + 1, y + 1, x + 2, y + 2), P.ink) R(x + 1, y + 1, x + 2, y + 2, P.moss.base) c:px(x + 2, y + 2, P.ember.base)
end
for _, p in ipairs{ {8, 86, 3}, {22, 93, 2}, {38, 88, 3}, {50, 96, 2}, {96, 92, 3}, {112, 86, 2}, {126, 92, 3}, {144, 86, 2}, {154, 94, 3}, {3, 97, 2}, {136, 97, 2} } do poppy(p[1], p[2], p[3], P.ink) end
-- foreground grass blades
for x = 0, 159, 2 do
  if not path:has(x, 98) then
    local h = 2 + floor(rnd() * 4)
    for k = 0, h do c:px(x, 99 - k, k < 1 and P.moss.deep or P.moss.shade) end
    c:px(x, 99 - h, P.moss.base)
  end
end

HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
