-- scene-wetland: marsh pond, lily pads, reeds, boardwalk stub, frog quirk. Day palette.
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H = X.hash
local INK = GX.INK
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "wetland" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end
local mix = GX.mix

local GRN1 = { hi = "#c8f070", base = "#6cc050", shade = "#3a9048", deep = "#1f5a44" }
local GRN2 = { hi = "#a0dc60", base = "#48a050", shade = "#2e7648", deep = "#1c4a40" }
local WILL = { hi = "#d4f080", base = "#9cd060", shade = "#5aa048", deep = "#2e7048" }
local P = {
  bg = { "#c8ecf8", "#d4f0e8", "#e4f6c8", "#f0f4b8", "#e0eca0", "#c8e090" }, lift = "#ffffd0", far = "#8cc0a0",
  hill = { hi = "#c0e888", base = "#9cd070", shade = "#78b060", deep = "#5a9060" },
  grass = { hi = "#d0f070", base = "#92d048", shade = "#58a840", deep = "#2a7a44" },
  mud = { hi = "#c8a46a", base = "#9a7248", shade = "#6e4e3a", deep = "#46303a" },
  shadow = "#4a5a34",
}
local function blocked(x, y) return (x > 276 and x < 440 and y > 56 and y < 222) or (x < 150 and y > 140 and y < 200) end

---------------------------------------------------------------- sky + far
local function shaft(x, y) local t = y / 150; for i = 0, 5 do local x0 = 40 + i * 80; if x >= x0 + t * 30 and x <= x0 + 22 + t * 40 then return true end end return false end
GX.bands(c, 0, 150, P.bg, 3, .22, shaft, P.lift)
-- sun glare
local sun = mk(); E(sun, 330, 14, 26, 14); c:fillMask(sun, "#fffbd0"); local s2 = mk(); E(s2, 330, 14, 15, 8); c:fillMask(s2, "#ffffff")
-- far willows/trees (low, soft)
for _, t in ipairs{ {20,70,40,26}, {96,84,34,20}, {190,94,30,16}, {250,98,34,14}, {310,100,30,12}, {380,98,36,13}, {440,86,32,20} } do
  local m = GX.foliage(c, t[1], t[2] + 18, t[3], t[4] + 4, { hi = mix(P.far, P.lift, .35), base = P.far, shade = mix(P.far, "#2a6a5a", .3), deep = mix(P.far, "#2a5a50", .5) }, 200 + t[1])
end
GX.ground(c, function(x) return 122 + floor(5 * sin(x / 31)) end, P.hill, 5, { top = .75, fall = .3, tex = .3 })
-- far reed line
for x = 0, 479 do
  local h = 6 + floor(H(x // 2, 5, 1) * 8)
  local y0 = 132 + floor(3 * sin(x / 23))
  for y = y0 - h, y0 do c:px(x, y, (H(x, 2, 3) < .5) and "#78b060" or "#8cc070") end
end
-- far heron
do
  local hx, hy = 214, 138
  local HR = { "#dce8ec", "#a8b8c4" }
  for y = hy - 2, hy + 8 do c:px(hx, y, "#6a7a84") end   -- legs
  for i = 0, 5 do c:px(hx - 2 + i % 3, hy - 4 - i // 2, HR[1]) ; c:px(hx - 1 + i % 3, hy - 4 - i // 2, HR[1]) end
  c:fillMask(c:rect(hx - 3, hy - 9, hx + 2, hy - 4), HR[1]); c:fillMask(c:rect(hx - 4, hy - 8, hx - 2, hy - 6), HR[2])
  c:fillMask(c:rect(hx - 2, hy - 18, hx - 1, hy - 9), HR[1]); c:fillMask(c:rect(hx - 3, hy - 19, hx - 1, hy - 18), HR[1])
  c:px(hx - 4, hy - 18, "#e8a030"); c:px(hx - 5, hy - 18, "#e8a030"); c:px(hx - 2, hy - 19, "#2b1c26")
end

---------------------------------------------------------------- bank ground
GX.ground(c, function(x) return 142 + floor(4 * sin(x / 23 + 2)) end, P.grass, 7, { top = .86, fall = .6, tex = .32, sc = 8 })
-- muddy patches (satchel bank stays firm grass-mud)
for _, m0 in ipairs{ {330,196,40,8}, {380,170,26,6}, {300,150,22,5}, {410,205,24,5}, {350,120,30,5} } do
  local m = mk(); E(m, m0[1], m0[2], m0[3], m0[4]); m = GX.rough(m, m0[1], 1)
  GX.lit(c, m, GX.ramp6(P.mud), { R = 4, tex = .4, sc = 3, seed = m0[1], ink = false, amb = .5 })
end

---------------------------------------------------------------- pond
local function pondEdge(x) -- bottom/top bounds, nil if outside
  if x < 0 or x > 284 then return nil end
  local top = 150 + floor(4 * sin(x / 19) + 3 * sin(x / 7 + 1))
  local bot = 214 + floor(5 * sin(x / 27 + 1) - max(0, (x - 220)) * .15)
  local rt = 284 - floor(6 * sin(x / 10))
  return top, bot, rt
end
local pond = mk()
for x = 0, 283 do
  local top, bot = pondEdge(x)
  local fade = min(1, (284 - x) / 14)
  for y = top, bot - floor((1 - fade) * 50) do pond:set(x, y) end
end
pond = GX.rough(pond, 31, 1)
-- mud shore ring
local shore = pond:copy():grow(3); shore:cut(pond)
shore:each(function(x, y)
  local v = .45 + (GX.vn(x, y, 3, 8) - .5) * .8
  c:px(x, y, GX.ramp6(P.mud)[GX.idx(v)])
end)
local WA = { "#fff4c8", "#bfe8e0", "#9ad8e0", "#78c4d8", "#5aa8cc", "#4a8cba" }
pond:each(function(x, y)
  local top = pondEdge(x) or 150
  local t = (y - top) / 62
  local v = .3 + t * .7 + (GX.vn(x * .35, y * 1.4, 4, 9) - .5) * .35
  -- reflected sky glow + sun streak
  local sx = abs(x - 200)
  if sx < 14 and (y // 2 + x // 6) % 3 == 0 then v = v - .35 end
  local i = max(1, min(6, 6 - floor((1 - max(0, min(1, v))) * 5.99)))
  i = max(1, min(6, floor(1 + (1 - max(0, min(1, v))) * 0 + max(0, min(1, v)) * 5.99)))
  c:px(x, y, WA[i])
end)
-- ripple lines
for i = 0, 70 do
  local x, y = floor(H(i, 71, 1) * 280), 154 + floor(H(i, 73, 1) * 56)
  if pond:has(x, y) and pond:has(x + 6, y) then for k = 0, 4 + i % 4 do if pond:has(x + k, y) then c:px(x + k, y, (i % 2 == 0) and "#e8fbe8" or "#3e7aa8") end end end
end
-- sky reflection: far tree smudges
for i = 0, 10 do
  local m = mk(); E(m, 20 + i * 26, 160 + (i % 3) * 3, 12, 2); m = GX.rough(m, i, 1)
  m:each(function(x, y) if pond:has(x, y) then c:px(x, y, "#7ac098") end end)
end

---------------------------------------------------------------- mossy islands
local function island(cx, cy, rx, ry, seed)
  local m = mk(); E(m, cx, cy, rx, ry); m = GX.rough(m, seed, 2)
  GX.lit(c, m, GX.ramp6(P.mud), { R = 5, tex = .5, sc = 3, seed = seed, rimlight = true })
  local g = mk(); E(g, cx - 1, cy - 1, rx - 2, max(2, ry - 2)); g = GX.rough(g, seed + 1, 1)
  GX.lit(c, g, GX.ramp6(GRN1), { R = 4, tex = .6, sc = 2.5, seed = seed + 2, ink = false, rimlight = true })
  for k = 0, 2 do GX.tuft(c, cx - rx // 2 + k * (rx // 2), cy - 1, GRN2) end
  return m
end
island(176, 188, 18, 6, 41); island(250, 168, 12, 4, 43); island(92, 206, 14, 4, 47)

---------------------------------------------------------------- lily pads
local PADS = { {60,170,10,4},{118,176,9,3},{150,198,11,4},{210,196,13,4},{236,184,8,3},{268,200,9,3},{40,200,9,3},{130,212,8,3},{196,170,9,3},{110,160,7,2} }
local padpos = {}
for i, p in ipairs(PADS) do
  local m = mk(); E(m, p[1], p[2], p[3], p[4])
  m = GX.rough(m, 50 + i, 1)
  -- notch wedge toward right
  for k = 1, p[3] do local yy = p[2] + floor(k * .0); m:cut(c:rect(p[1] + k, p[2], p[1] + k, p[2])) end
  GX.lit(c, m, GX.ramp6(i % 2 == 0 and GRN1 or GRN2), { R = 4, tex = .35, sc = 2, seed = i, rimlight = true })
  -- water ring shadow under the pad
  for x = p[1] - p[3], p[1] + p[3] do if pond:has(x, p[2] + p[4] + 2) and not m:has(x, p[2] + p[4] + 2) and H(x, i, 5) < .6 then c:px(x, p[2] + p[4] + 2, "#3a78a0") end end
  padpos[i] = p
end
-- blooms: pink + white lilies
local function lily(x, y, col)
  local L = { hi = "#ffffff", base = col, shade = mix(col, "#b04a80", .5), deep = "#8a3a6a" }
  for k = -4, 4, 2 do c:px(x + k, y, L.shade); c:px(x + k, y - 1, L.base); c:px(x + k // 2, y - 2, L.hi) end
  c:px(x - 2, y - 3, L.base); c:px(x + 2, y - 3, L.base); c:px(x, y - 3, L.hi); c:px(x, y - 4, L.hi)
  c:px(x - 1, y - 1, "#ffe38a"); c:px(x, y - 1, "#ffd040"); c:px(x + 1, y - 1, "#ffe38a")
end
lily(210, 195, "#ff9fc0"); lily(60, 169, "#fff4f8"); lily(268, 199, "#ff9fc0"); lily(120, 175, "#fff4f8"); lily(237, 183, "#ffd0e0")
-- frog on pad (quirk): pad 3 at 150,198
do
  local fx, fy = 148, 195
  local fm = mk(); E(fm, fx, fy, 5, 3); fm = GX.rough(fm, 61, 1)
  local FR = { hi = "#e8ff88", base = "#7cd040", shade = "#3e9a40", deep = "#1f5a44" }
  GX.lit(c, fm, GX.ramp6(FR), { R = 3, tex = .2, seed = 5, rimlight = true })
  for _, ex in ipairs{ fx - 3, fx + 2 } do c:fillMask(c:rect(ex, fy - 5, ex + 1, fy - 3), FR.base); c:px(ex, fy - 5, "#ffffff"); c:px(ex + 1, fy - 5, "#ffffff"); c:px(ex, fy - 4, INK) ; c:px(ex-1, fy - 6, INK); c:px(ex + 2, fy - 6, INK) end
  c:px(fx - 4, fy + 2, FR.shade); c:px(fx + 4, fy + 2, FR.shade); c:px(fx - 1, fy + 1, "#ffb0a0"); c:px(fx, fy + 1, "#ffb0a0")
  -- tiny speech/dragonfly target: bubble
  c:px(fx + 6, fy - 9, "#ffffff"); c:px(fx + 7, fy - 11, "#ffffff"); c:px(fx + 8, fy - 14, "#ffffff")
end
-- duckweed
for i = 0, 260 do
  local x, y = floor(H(i, 81, 1) * 284), 152 + floor(H(i, 83, 1) * 62)
  if pond:has(x, y) and GX.vn(x, y, 12, 14) > .5 then c:px(x, y, "#9ae060"); c:px(x + 1, y, "#6cc050"); if i % 3 == 0 then c:px(x, y + 1, "#6cc050") end end
end

---------------------------------------------------------------- boardwalk stub (hero, left)
do
  local WOOD = { hi = "#d6b684", base = "#a8845a", shade = "#7a5a40", deep = "#4a3640" }
  -- posts first (go into water)
  for _, px in ipairs{ 18, 74, 128 } do
    local m = mk()
    for y = 170, 202 do local w = 3 + floor((GX.vn(px, y, 6, 3) - .5) * 2); for x = px - w, px + w do m:set(x, y) end end
    GX.lit(c, m, GX.ramp6(WOOD), { R = 3, tex = .5, sc = 2, seed = px, rimlight = true, fn = function(x, y) return -(y - 170) / 120 end })
    for x = px - 6, px + 6 do if (H(x, 1, px) < .7) then c:px(x, 203, "#e8fbe8") end end -- ripple ring
    local mo = mk(); for y = 188, 202 do for x = px - 4, px + 4 do if GX.vn(x, y, 3, px) > .5 then mo:set(x, y) end end end
    mo:each(function(x, y) if m:has(x, y) then c:px(x, y, GRN2.base) end end)
  end
  -- deck: slightly tapered, ends ragged at x~150
  local deck = mk()
  for x = 0, 150 do
    local top = 160 + floor((x - 0) * 0.02); local bot = top + 14
    local endr = 150 - floor(GX.vn(x, 0, 3, 4) * 3)
    if x <= endr then for y = top, bot do deck:set(x, y) end end
  end
  for _, g in ipairs{ {108, 176}, {132, 160}, {140, 168} } do deck:cut(c:rect(g[1], g[2], g[1] + 3 + g[2] % 2, g[2] + 3)) end
  deck = GX.rough(deck, 71, 1)
  GX.lit(c, deck, GX.ramp6(WOOD), { R = 6, tex = .5, sc = 2.2, seed = 8, rimlight = true,
    fn = function(x, y) local pl = (x // 14) % 2 == 0 and .06 or -.06; local gap = (x % 14 == 0) and -.4 or 0; return pl + gap + (GX.vn(x * .15, y * 1.2, 2, 5) - .5) * .3 end })
  -- plank seams and nails
  for x = 7, 150, 14 do for y = 161, 173 do if deck:has(x, y) then c:px(x, y, WOOD.deep) end end end
  for x = 3, 148, 14 do c:px(x, 163, WOOD.deep); c:px(x, 171, WOOD.deep) end
  -- front board edge highlight/shadow
  for x = 0, 150 do if deck:has(x, 172) and deck:has(x, 173) then c:px(x, 172, WOOD.shade) end end
  -- moss on deck
  deck:each(function(x, y) if GX.vn(x, y, 5, 13) > .66 + (y - 160) / 60 and not (x % 14 == 0) then c:px(x, y, GRN2.base) ; if H(x,y,2) < .4 then c:px(x, y, GRN1.hi) end end end)
  -- shadow on water beneath deck end
  local sh = mk(); E(sh, 80, 180, 66, 3); sh:each(function(x, y) if pond:has(x, y) and (x + y) % 2 == 0 then c:px(x, y, "#3a78a0") end end)
  -- rope coil + lantern-free: a little bird on the post? keep it clean; dragonfly rests on end
  local db = 150
  c:px(db - 6, 156, "#2b1c26")
end

---------------------------------------------------------------- willow fronds (top)
local function frond(x, y0, len, seed)
  for k = 0, len do
    local sway = floor(sin(k / 9 + seed) * 2 + (H(k, seed, 1) - .5))
    local xx = x + sway
    local col = k < 3 and WILL.shade or (H(k, seed, 2) < .3 and WILL.hi or (k > len - 4 and WILL.base or WILL.base))
    c:px(xx, y0 + k, col)
    if k % 5 == 0 then c:px(xx + 1, y0 + k, WILL.hi); c:px(xx - 1, y0 + k + 1, WILL.shade) end
  end
end
for x = 0, 479, 3 do
  local lenmax = 50
  local len
  if x > 250 and x < 450 then len = 12 + floor(H(x, 4, 1) * 24) else len = 20 + floor(H(x, 4, 1) * (x < 250 and 60 or 44)) end
  if x > 276 and x < 440 then len = min(len, 30) end
  local topm = 14 + floor(5 * sin(x / 17))
  for y = 0, topm do c:px(x, y, (x % 6 == 0) and WILL.shade or WILL.base); c:px(x + 1, y, WILL.base); c:px(x + 2, y, WILL.shade) end
  frond(x, topm, len, x * .13)
  frond(x + 1, topm, len - 4 - floor(H(x, 6, 1) * 6), x * .13 + 1)
end
-- top canopy mass
for _, f in ipairs{ {30,8,56,18}, {130,2,50,14}, {222,0,46,12}, {330,0,56,10}, {420,6,56,16}, {470,10,34,16} } do
  GX.foliage(c, f[1], f[2], f[3], f[4], (f[1] % 2 == 0) and WILL or GRN1, 300 + f[1])
end

---------------------------------------------------------------- reeds & cattails (edges)
local function reed(x, yb, h, lean, seed, cat)
  local pts = {}
  for k = 0, h do
    local xx = x + floor(lean * (k / h) ^ 2 * 10) + floor(sin(k / 14 + seed) * 1.2)
    local yy = yb - k
    pts[k] = { xx, yy }
    local col = k < h * .25 and GRN2.deep or (H(k, seed, 3) < .25 and GRN1.hi or GRN1.base)
    c:px(xx, yy, INK); c:px(xx + 1, yy, GRN1.shade); c:px(xx + 2, yy, GRN1.hi)
    c:px(xx + 1, yy, col)
  end
  if cat then
    local tp = pts[h - 6]
    local m = mk(); c:fillMask(c:rect(tp[1] - 1, tp[2] - 8, tp[1] + 3, tp[2]), INK)
    c:fillMask(c:rect(tp[1], tp[2] - 7, tp[1] + 2, tp[2] - 1), "#7a4a34")
    c:px(tp[1], tp[2] - 7, "#b97a4a"); c:px(tp[1], tp[2] - 5, "#b97a4a"); c:px(tp[1] + 2, tp[2] - 3, "#4a2a2c"); c:px(tp[1] + 2, tp[2] - 6, "#4a2a2c")
    c:px(tp[1] + 1, tp[2] - 9, "#c8b080"); c:px(tp[1] + 1, tp[2] - 10, "#c8b080")
  end
  -- wide leaf blades
  return pts
end
local function clump(x0, x1, yb, hmin, hmax, lean, seed)
  for x = x0, x1, 3 do
    local h = hmin + floor(H(x, seed, 1) * (hmax - hmin))
    reed(x, yb + floor(H(x, seed, 2) * 6), h, lean * (0.5 + H(x, seed, 4)), x + seed, H(x, seed, 5) < .3)
  end
end
-- left edge
clump(0, 34, 206, 100, 190, 0.5, 11)
clump(0, 22, 216, 60, 120, 0.9, 12)
-- right edge
clump(448, 479, 214, 90, 180, -0.5, 13)
clump(458, 479, 224, 50, 110, -0.9, 14)
-- low reed tufts at pond edge (center bottom, low)
for _, rx in ipairs{ 150, 200, 232, 270, 292, 426 } do clump(rx, rx + 8, 214 + (rx > 280 and 8 or 0), 14, 26, rx < 280 and 0.5 or -0.4, rx) end

---------------------------------------------------------------- foreground ground detail
for i = 0, 70 do
  local x, y = 20 + floor(H(i, 61, 1) * 440), 220 + floor(H(i, 63, 1) * 48)
  if not blocked(x, y) and not (x < 40 or x > 446) then GX.tuft(c, x, y, y > 244 and { hi = P.grass.base, base = P.grass.shade, shade = P.grass.deep } or P.grass) end
end
for i = 0, 20 do
  local x, y = 20 + floor(H(i, 41, 1) * 440), 152 + floor(H(i, 43, 1) * 112)
  if not blocked(x, y) and y > 218 or (x > 300 and x < 430 and (y < 60)) then local cols = { "#ff9fc0", "#fff4d6", "#ffe38a", "#c9b2f0" }; GX.flower(c, x, y, cols[1 + i % 4]) end
end
-- mud puddles + stones in the foreground
for i, p in ipairs{ {90,240,22,4}, {200,250,26,5}, {330,246,18,3}, {420,252,24,4} } do
  local m = mk(); E(m, p[1], p[2], p[3], p[4]); m = GX.rough(m, 90 + i, 1)
  m:each(function(x, y) local v = GX.vn(x, y, 3, 9); c:px(x, y, v > .55 and "#9ad8e0" or "#78c4d8"); end)
  c:rim(m, P.mud.deep)
end
local STO = { hi = "#e8e4d0", base = "#b4b09c", shade = "#7e7a68", deep = "#4a4850" }
for si, s in ipairs{ {160,238,7,3}, {262,258,9,3}, {50,262,8,3} } do
  local m = mk(); E(m, s[1], s[2], s[3], s[4]); m = GX.rough(m, si + 120, 1)
  GX.lit(c, m, GX.ramp6(STO), { R = 3, tex = .3, sc = 3, seed = si, rimlight = true })
end
-- fallen leaves/seed fluff on the bank
for i = 0, 70 do
  local x, y = floor(H(i, 31, 1) * 480), 150 + floor(H(i, 37, 1) * 120)
  if not blocked(x, y) and not pond:has(x, y) and y > 148 then local col = ({ "#f5d84a", "#f0a830", "#c4e07a" })[1 + i % 3]; c:px(x, y, col); c:px(x + 1, y, col); c:px(x + 1, y + 1, mix(col, "#000000", .3)) end
end

---------------------------------------------------------------- mist wisps (flat pale, dithered edges)
for i, w in ipairs{ {60,152,50,3}, {170,148,44,2}, {240,160,36,2}, {20,185,24,2}, {200,208,40,2} } do
  local m = mk(); E(m, w[1], w[2], w[3], w[4]); m = GX.rough(m, 140 + i, 1)
  m:each(function(x, y) if pond:has(x, y) or y < 150 then if (x + y) % 2 == 0 or GX.vn(x, y, 4, i) > .6 then c:px(x, y, "#f4fcee") end end end)
end

---------------------------------------------------------------- dragonflies
local function dragonfly(x, y, col)
  for k = 0, 4 do c:px(x + k, y, col) end
  c:px(x + 5, y, INK); c:px(x + 6, y, "#ff6040")
  c:px(x + 1, y - 2, "#e8fbff"); c:px(x + 2, y - 3, "#e8fbff"); c:px(x + 3, y - 2, "#e8fbff"); c:px(x + 1, y + 2, "#e8fbff"); c:px(x + 2, y + 3, "#e8fbff"); c:px(x + 3, y + 2, "#e8fbff")
end
dragonfly(170, 126, "#3a8ae0"); dragonfly(100, 146, "#e8493b"); dragonfly(255, 100, "#2ec0a0"); dragonfly(158, 182, "#3a8ae0")

---------------------------------------------------------------- contact shadow for the satchel
local sh = mk(); GX.disc(sh, 357, 213, 74, 5); c:fillMask(sh, P.shadow)

c:save{ aseprite = d.."/../out/scene-wetland.aseprite", png = d.."/../out/scene-wetland.png", scale = 1 }
