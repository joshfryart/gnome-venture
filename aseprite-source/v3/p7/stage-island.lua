-- stage-island v3: clear-day desert base backdrop (arch, mesas, saguaros), no weather painted in
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H, INK = X.hash, GX.INK
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "stage-island" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end
local R6 = GX.ramp6
local SAND = { hi = "#fff0c0", base = "#f0cc84", shade = "#d4a068", deep = "#a06c4c" }
local DUNE = { hi = "#ffe89a", base = "#f4c868", shade = "#d89c52", deep = "#a8704a" }
local RED = { hi = "#f0a078", base = "#d86c48", shade = "#a8444a", deep = "#6a2c40" }
local CAC = { hi = "#a8e068", base = "#4eb050", shade = "#2e8048", deep = "#1a4c40" }
local ROCK = { hi = "#e8b890", base = "#c08462", shade = "#8c5a54", deep = "#573646" }

-- sky: plain gradient down to a warm haze
GX.bands(c, 0, 150, { "#78bce6", "#94d0f0", "#b0e0f4", "#d0ecf0", "#eef2dc", "#fbe8c0" }, 3, .2)
local sun = mk(); E(sun, 330, 100, 9, 8); sun = GX.rough(sun, 5, 1)
GX.lit(c, sun, R6({ hi = "#fffbe4", base = "#fff2c0", shade = "#ffe49c", deep = "#f8d48c" }), { R = 8, tex = .1, seed = 3, ink = false, amb = .5 })

-- far hazy mesas (flat, no ink)
local function far(x0, x1, ytop, col, seed)
  local m = mk()
  for x = x0, x1 do
    local u = (x - x0) / (x1 - x0)
    local t = ytop + floor(min(u, 1 - u) < .12 and (.12 - min(u, 1 - u)) * 90 or 0) + floor((GX.vn(x, 0, 8, seed) - .5) * 3)
    for y = t, 160 do m:set(x, y) end
  end
  c:fillMask(m, col)
end
far(0, 70, 112, "#ecc8a4", 1); far(130, 250, 124, "#e6bc98", 2); far(300, 400, 106, "#ecc8a4", 3); far(400, 479, 120, "#e6bc98", 4)

-- dune band behind the props
local function dy(x) return 156 + floor(5 * sin(x / 37 + 2) + 3 * sin(x / 13)) end
GX.ground(c, dy, DUNE, 5, { top = .88, fall = .3, tex = .3, sc = 8 })

-- mesa
local function mesa(x0, x1, ytop, seed)
  local m = mk()
  for x = x0, x1 do
    local u = (x - x0) / (x1 - x0)
    local sl = floor(max(0, abs(u - .5) - .36) * 140)
    for y = ytop + sl + floor((GX.vn(x, 0, 7, seed) - .5) * 3), 172 do m:set(x, y) end
  end
  m = GX.rough(m, seed, 1)
  GX.lit(c, m, function(x, y) local b = ((y - ytop) // 7) % 2; return R6(b == 0 and RED or { hi = RED.base, base = RED.shade, shade = RED.deep, deep = RED.deep }) end,
    { R = 16, tex = .35, sc = 3, seed = seed, rimlight = true, amb = .26, fn = function(x, y) return (y < ytop + 4) and .15 or 0 end })
  for x = x0 + 3, x1 - 3 do if m:has(x, ytop + 4) and not m:has(x, ytop - 1 + 0) then end end
end
mesa(30, 135, 100, 21); mesa(345, 466, 112, 22)

-- arch (hero)
local ax, aw = 240, 52
local function atop(x) local u = abs(x - ax) / aw; return 106 + floor(u ^ 2.4 * 36) + floor((GX.vn(x, 0, 6, 9) - .5) * 3) end
local arch = mk()
for x = ax - aw, ax + aw do for y = atop(x), 172 do arch:set(x, y) end end
local hole = mk(); E(hole, ax, 175, 32, 52); arch:cut(hole)
arch = GX.rough(arch, 31, 1)
GX.lit(c, arch, function(x, y) return R6((y // 8) % 2 == 0 and RED or ROCK) end,
  { R = 14, tex = .5, sc = 3, seed = 31, rimlight = true, amb = .24 })
-- sky showing through the arch matches the dune/haze behind: repaint with dune ground
for x = ax - 34, ax + 34 do for y = 118, 172 do
  if hole:has(x, y) and not arch:has(x, y) then
    local yy = dy(x)
    if y >= yy then c:px(x, y, DUNE.base) else c:px(x, y, "#f6e2bc") end
  end
end end
local shd = mk(); E(shd, ax, 176, 58, 4); c:fillMask(shd, "#d4a068")

-- saguaro
local function saguaro(x, yb, h, seed, armL, armR)
  local m = mk()
  for y = yb - h, yb do for k = -5, 5 do m:set(x + k, y) end end
  for y = yb - h - 3, yb - h do for k = -3, 3 do m:set(x + k, y) end end
  local function arm(dir, ya, rise)
    for k = 5, 17 do for y = ya, ya + 7 do m:set(x + dir * k, y) end end
    for k = 14, 19 do for y = ya - rise, ya + 7 do m:set(x + dir * k, y) end end
  end
  if armL then arm(-1, yb - floor(h * .5), armL) end
  if armR then arm(1, yb - floor(h * .6), armR) end
  m = GX.rough(m, seed, 1)
  GX.lit(c, m, R6(CAC), { R = 5, tex = .3, sc = 3, seed = seed, rimlight = true, amb = .24,
    fn = function(px, py) return (px % 4 == 0) and -.12 or 0 end })
  m:each(function(px, py) if H(px, py, seed) < .03 and m:has(px, py + 1) then c:px(px, py, CAC.hi) end end)
  local sh = mk(); E(sh, x + 6, yb + 1, 20, 3); sh:cut(m); c:fillMask(sh, "#c89a62")
  return m
end
local cl = saguaro(30, 176, 130, 41, 26, 20)
saguaro(452, 178, 100, 43, 18, nil)
-- quirk: a tiny pink flower on the left saguaro's top
c:px(30, 44, "#ff7aa0"); c:px(29, 45, "#ff7aa0"); c:px(31, 45, "#ff7aa0"); c:px(30, 45, "#ffd0a8")

-- near sand ground
local function gy(x) return 172 + floor(3 * sin(x / 29 + 1) + 1.5 * sin(x / 9)) end
GX.ground(c, gy, SAND, 7, { top = .86, fall = .5, tex = .24, sc = 9 })
for x = 0, 479 do c:px(x, gy(x), "#fff4d0"); if H(x, 1, 3) > .6 then c:px(x, gy(x) - 1, "#ffe8a8") end end
-- redo cactus feet over the ground line
for _, p in ipairs{ {30, 176}, {452, 178} } do local f = mk(); E(f, p[1], p[2], 6, 2); GX.lit(c, f, R6(CAC), { R = 2, tex = 0, ink = false }) end
-- ripple dunes in sand
for y = 180, 269 do for x = 0, 479 do
  local w = sin((y + GX.vn(x, y, 22, 41) * 10) * .8)
  if w > .95 and GX.vn(x, y, 6, 42) > .45 then c:px(x, y, SAND.shade)
  elseif w < -.97 and GX.vn(x, y, 6, 43) > .5 then c:px(x, y, SAND.hi) end
end end

-- calm foreground details: barrel cacti, pebbles, tufts, bones
local function barrel(x, y, r, flower)
  local m = mk(); E(m, x, y, r, r - 1); m = GX.rough(m, x, 1)
  GX.lit(c, m, R6(CAC), { R = r, tex = .2, seed = x, rimlight = true, fn = function(px) return (px % 3 == 0) and -.12 or 0 end })
  if flower then c:px(x, y - r, "#ff7aa0"); c:px(x + 1, y - r, "#ffb0c0") end
  local sh = mk(); E(sh, x + 3, y + r - 1, r + 3, 2); sh:cut(m); c:fillMask(sh, "#c89a62")
end
barrel(312, 190, 8, false); barrel(402, 236, 10, true); barrel(90, 248, 6, false)
for i = 0, 36 do
  local x, y = 8 + floor(H(i, 21, 5) * 465), 184 + floor(H(i, 22, 5) * 82)
  local m = mk(); E(m, x, y, 1 + i % 3, 1 + i % 2)
  GX.lit(c, m, R6(i % 4 == 0 and ROCK or { hi = "#f4e0c0", base = "#c8a888", shade = "#94705c", deep = "#5c4046" }), { R = 2, tex = .15, seed = i, rimlight = true })
end
for i = 0, 11 do
  GX.tuft(c, 10 + floor(H(i, 61, 1) * 460), 196 + floor(H(i, 63, 1) * 68), { hi = "#d8d880", base = "#a8a860", shade = "#78804c", deep = "#505a42" })
end
-- bleached rib bone
for k = 0, 8 do c:px(200 + k, 252 - floor(sin(k / 8 * 3.1) * 3), "#f8ecd8"); c:px(200 + k, 253 - floor(sin(k / 8 * 3.1) * 3), "#c8a888") end

c:save{ aseprite = d.."/out/stage-island.aseprite", png = d.."/out/stage-island.png", scale = 1 }
