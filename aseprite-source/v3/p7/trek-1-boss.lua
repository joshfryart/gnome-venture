local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H, INK, vn, mix = X.hash, GX.INK, GX.vn, GX.mix
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "trek-1-boss" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, floor(cx), floor(cy), rx, ry or rx) end
local R6 = GX.ramp6

local EARTH = { hi = "#a8704a", base = "#7a4a34", shade = "#53302f", deep = "#301c28" }
local CLAY  = { hi = "#e89a5c", base = "#b8683c", shade = "#8a4634", deep = "#52282c" }
local BARK  = { hi = "#c0825a", base = "#8a5238", shade = "#6a3a38", deep = "#40242c" }
local WOOD  = { hi = "#d8a068", base = "#a8683e", shade = "#7a4634", deep = "#4a2a2c" }
local STRAW = { hi = "#ffe38a", base = "#e8b84a", shade = "#c0862e", deep = "#7a4a28" }
local RED   = { hi = "#ff8a5c", base = "#d84a3b", shade = "#a02e3f", deep = "#6e2038" }
local SACK  = { hi = "#f0d8a8", base = "#d0aa78", shade = "#a47c58", deep = "#6a4a3c" }
local GRN   = { hi = "#c8f070", base = "#6cc050", shade = "#3a9048", deep = "#1f5a44" }
local STONE = { hi = "#d8c8b0", base = "#a89480", shade = "#7a6a64", deep = "#4a3c48" }
local METAL = { hi = "#a8b4c8", base = "#6a7898", shade = "#485070", deep = "#2c3050" }

---------------------------------------------------------------- backdrop: earth, pale wall, far hills
local function cy(x) return 50 + floor(7 * vn(x, 0, 28, 1) + 3 * sin(x / 11)) end
GX.bands(c, 0, 100, { "#2a1a26", "#3a2330", "#4e3030", "#6a4234", "#835440", "#9a6a48" }, 4, .3)
local function wy(x) return 96 + floor((vn(x, 3, 14, 6) - .5) * 9) end
local WALL = { "#f4e6c4", "#efdfba", "#e8d4ac", "#dfc8a0", "#d4b894", "#c8a888" }
for x = 0, 479 do for y = wy(x), 150 do
  local t = (y - 96) / 56 + (vn(x, y, 18, 8) - .5) * .25
  local col = WALL[max(1, min(6, floor(t * 6) + 1))]
  local n = vn(x, y, 2.5, 9)
  if n < .2 then col = mix(col, "#8a5a48", .22) elseif n > .86 then col = mix(col, "#fff6dc", .3) end
  if (y - 96) % 13 == 0 and vn(x, y, 6, 3) > .3 then col = mix(col, "#8a5a48", .3) end
  c:px(x, y, col)
end end
GX.ground(c, function(x) return 138 + floor(6 * sin(x / 37) + 3 * sin(x / 13)) end,
  { hi = "#d8c890", base = "#b8a878", shade = "#988868", deep = "#786a64" }, 5, { top = .75, fall = .3, tex = .35 })
GX.ground(c, function(x) return 156 + floor(4 * sin(x / 23 + 2)) end,
  { hi = "#c8dc78", base = "#88b858", shade = "#5a9048", deep = "#2f6a46" }, 7, { top = .85, fall = .4, tex = .4 })

---------------------------------------------------------------- floor: dirt path + planks
local DIRT = R6{ hi = "#c8864e", base = "#a8683e", shade = "#865038", deep = "#5e3a30" }
for x = 0, 479 do
  local y0 = 180 + floor((vn(x, 1, 10, 2) - .5) * 5)
  for y = y0, 227 do
    local v = .62 - (y - y0) / 150 + (vn(x, y, 6, 3) - .5) * .32 + (vn(x, y, 2, 4) - .5) * .18
    c:px(x, y, DIRT[GX.idx(max(0, min(1, v)))])
  end
  if (x % 4 == 0 or x % 4 == 1) and H(x, 5, 1) < .6 then c:px(x, y0 - 1, "#5a9048"); if H(x, 6, 1) < .4 then c:px(x, y0 - 2, "#88b858") end end
end
for i = 0, 70 do   -- pebbles and grass ticks on the path
  local x, y = floor(H(i, 7, 2) * 476) + 2, 186 + floor(H(i, 8, 2) * 38)
  if i % 3 == 0 then local m = mk(); E(m, x, y, 2, 1); GX.lit(c, m, R6(STONE), { R = 2, tex = .1, ink = "#5e3a30", seed = i })
  else c:px(x, y, "#865038"); c:px(x + 1, y, "#865038"); c:px(x, y - 1, "#5a9048") end
end
local PL = R6(WOOD)
for row = 0, 3 do
  local y0 = 228 + row * 11
  local off = (row * 61) % 97
  for x = 0, 479 do for y = y0, min(269, y0 + 10) do
    local gx = (x + off) % 97
    local v = .66 - (y - y0) * .04 + (vn(x * .2, y * 1.6, 2, 11 + row) - .5) * .5
    if y == y0 then v = .22 elseif y == y0 + 1 then v = .8 end
    if gx == 0 then v = .05 end
    if (gx == 4 or gx == 92) and (y == y0 + 3 or y == y0 + 8) then v = .1 end
    c:px(x, y, PL[GX.idx(max(0, min(1, v)))])
  end end
end

---------------------------------------------------------------- fence
local function fence()
  local rail = function(y0) for x = 0, 479 do for y = y0, y0 + 2 do
    local v = y == y0 and .85 or (y == y0 + 1 and .55 or .2); v = v + (vn(x * .3, y, 2, 4) - .5) * .3
    c:px(x, y, R6(BARK)[GX.idx(max(0, min(1, v)))]) end c:px(x, y0 + 3, INK) end end
  for x0 = 6, 479, 26 do
    local m = mk(); local top = 150 + floor(H(x0, 3, 1) * 4)
    for y = top, 188 do for x = x0, x0 + 3 do m:set(x, y) end end
    m = GX.rough(m, x0, 1)
    GX.lit(c, m, R6(BARK), { R = 3, tex = .4, sc = 2, seed = x0, rimlight = true })
  end
  rail(163); rail(175)
end
fence()

---------------------------------------------------------------- the den: big clay dome
local cx, base = 245, 190
local dome = mk()
for x = cx - 78, cx + 78 do
  local t = (x - cx) / 78
  local top = base - floor(70 * sqrt(max(0, 1 - t * t)) + (vn(x, 0, 9, 3) - .5) * 4)
  for y = top, base do dome:set(x, y) end
end
dome = GX.rough(dome, 31, 1)
GX.lit(c, dome, R6(CLAY), { R = 26, h = 1.2, tex = .55, sc = 4, seed = 12, rimlight = true, amb = .22,
  fn = function(x, y)
    local bx = (x + (floor(y / 7) % 2) * 6) % 12   -- hand-packed clay courses
    local f = 0
    if y % 7 == 0 then f = -.22 elseif bx == 0 then f = -.14 elseif y % 7 == 1 then f = .1 end
    return f + (H(x // 6, y // 7, 9) - .5) * .18
  end })
dome:each(function(x, y) if H(x, y, 44) < .01 then c:px(x, y, CLAY.deep); c:px(x + 1, y, CLAY.shade) end end)
-- doorway: stone ring + dark mouth
local door = mk()
for x = cx - 22, cx + 22 do
  local t = (x - cx) / 22
  local top = base - floor(30 * sqrt(max(0, 1 - t * t)))
  for y = top, base do door:set(x, y) end
end
door = GX.rough(door, 14, 1)
local ring = door:copy():grow(3); ring:cut(door)
ring:each(function(x, y) if y > base then ring.s[(y + 256) * 1024 + (x + 256)] = nil end end)
GX.lit(c, ring, R6(STONE), { R = 3, tex = .7, sc = 3, seed = 5, rimlight = true,
  fn = function(x, y) return (H(x // 4, y // 3, 5) - .5) * .35 end })
for y = base - 34, base do for x = cx - 25, cx + 25 do if door:has(x, y) then
  local v = .22 - (base - y) / 140 + (vn(x, y, 4, 2) - .5) * .2
  c:px(x, y, R6{ hi = "#4a2c3a", base = "#2f1c2a", shade = "#22141f", deep = "#160e18" }[GX.idx(max(0, min(1, v)), {.12,.3,.5,.7,.9})])
end end end
c:rim(door, INK)
local sill = mk(); for x = cx - 26, cx + 26 do for y = base + 1, base + 3 do sill:set(x, y) end end
GX.lit(c, GX.rough(sill, 8, 1), R6(STONE), { R = 2, tex = .4, seed = 2, rimlight = true })

---------------------------------------------------------------- torches
local function pole(x, ytop, ybot, w)
  local m = mk(); for y = ytop, ybot do for xx = x, x + w - 1 do m:set(xx, y) end end
  GX.lit(c, GX.rough(m, x, 1), R6(WOOD), { R = 2, tex = .5, sc = 2, seed = x, rimlight = true })
end
local function brazier(x, y)
  local m = mk()
  for yy = 0, 5 do local hw = 7 - floor(yy * .8); for xx = -hw, hw do m:set(x + xx, y + yy) end end
  GX.lit(c, GX.rough(m, x, 1), R6(METAL), { R = 4, tex = .3, seed = x, rimlight = true })
end
local flames = {}
local function flame(x, y, s) flames[#flames + 1] = { x, y, s } end
pole(134, 150, 190, 4); brazier(136, 144); flame(136, 143, 1)
-- coals/embers glow above brazier drawn with flame later

---------------------------------------------------------------- scarecrow (a prop on a post)
local sx = 352
pole(sx - 2, 112, 192, 5)
local arms = mk(); for x = sx - 30, sx + 34 do for y = 140, 143 do arms:set(x, y) end end
GX.lit(c, GX.rough(arms, 3, 1), R6(WOOD), { R = 2, tex = .5, sc = 2, seed = 3, rimlight = true })
for _, ax in ipairs{ sx - 32, sx + 36 } do   -- straw tufts at the hands
  for k = 0, 6 do local m = mk(); for y = 0, 5 + k % 3 do m:set(ax + k - 3, 138 + y + (k % 2)) end
    GX.lit(c, m, R6(STRAW), { R = 2, tex = .3, seed = k + ax, rimlight = false, ink = INK }) end
end
local body = mk()
for y = 144, 176 do local hw = 13 + floor((y - 144) * .15) + floor((vn(0, y, 6, 3) - .5) * 3); for x = sx - hw, sx + hw do body:set(x, y) end end
for x = sx - 12, sx + 12 do for y = 177, 180 + (x % 3) do body:set(x, y) end end   -- ragged hem
body = GX.rough(body, 22, 1)
GX.lit(c, body, R6(RED), { R = 12, tex = .5, sc = 3, seed = 6, rimlight = true,
  fn = function(x, y) if (x + y) % 9 == 0 then return -.15 end return (H(x // 3, y // 3, 6) - .5) * .12 end })
local patch = mk(); for x = sx - 9, sx - 3 do for y = 156, 162 do patch:set(x, y) end end
GX.lit(c, patch, R6(STRAW), { R = 3, tex = .3, seed = 1, ink = INK })
for x = sx - 9, sx - 3, 2 do c:px(x, 156, INK); c:px(x, 162, INK) end
local head = mk(); E(head, sx, 128, 10, 11); head = GX.rough(head, 9, 1)
GX.lit(c, head, R6(SACK), { R = 9, tex = .5, sc = 3, seed = 8, rimlight = true })
for _, e in ipairs{ { -4, 126 }, { 4, 126 } } do   -- stitched x eyes
  c:px(sx + e[1] - 1, e[2] - 1, INK); c:px(sx + e[1] + 1, e[2] + 1, INK); c:px(sx + e[1] + 1, e[2] - 1, INK); c:px(sx + e[1] - 1, e[2] + 1, INK)
end
for k = -4, 4 do c:px(sx + k, 134 + (k % 2), INK) end
local brim = mk(); for x = sx - 20, sx + 20 do local t = (x - sx) / 20; for y = 117 - floor(2 * (1 - abs(t))), 120 + floor(2 * t * t * 3) do brim:set(x, y) end end
local crown = mk(); for x = sx - 11, sx + 11 do for y = 105 + floor(abs(x - sx) * .4), 118 do crown:set(x, y) end end
crown = GX.rough(crown, 5, 1)
GX.lit(c, GX.rough(brim, 4, 1), R6(STRAW), { R = 6, tex = .6, sc = 2, seed = 4, rimlight = true })
GX.lit(c, crown, R6(STRAW), { R = 8, tex = .6, sc = 2, seed = 5, rimlight = true })
for x = sx - 11, sx + 11 do c:px(x, 116, RED.base) ; if x % 4 == 0 then c:px(x, 115, RED.shade) end end
pole(sx + 36, 124, 142, 3); brazier(sx + 38, 119); flame(sx + 38, 118, 1.4)

---------------------------------------------------------------- sunflowers
local function sunflower(x, y, r)
  local st = mk(); for yy = y, y + 34 do st:set(x, yy); st:set(x + 1, yy) end
  GX.lit(c, st, R6(GRN), { R = 1, tex = .2, seed = x, ink = INK })
  local lf = mk(); for k = 0, 8 do for j = 0, 2 do lf:set(x + 3 + k, y + 22 - floor(k * .5) + j) end end
  GX.lit(c, GX.rough(lf, x, 1), R6(GRN), { R = 2, tex = .3, seed = x + 2, rimlight = true })
  local pet = mk()
  for i = 0, 11 do local a = i / 12 * 6.283; E(pet, x + cos(a) * (r - 2), y + sin(a) * (r - 2), 3, 3) end
  E(pet, x, y, r - 3, r - 3)
  GX.lit(c, GX.rough(pet, x, 1), R6{ hi = "#fff0a0", base = "#f5c030", shade = "#d08a28", deep = "#8a5020" }, { R = 6, tex = .4, sc = 2, seed = x, rimlight = true })
  local ce = mk(); E(ce, x, y, r // 2 + 1, r // 2 + 1)
  GX.lit(c, ce, R6{ hi = "#8a5a3a", base = "#5e3a2c", shade = "#412430", deep = "#2a1822" }, { R = 4, tex = .6, sc = 1.5, seed = x + 1, ink = INK })
end
sunflower(96, 160, 9); sunflower(124, 176, 8); sunflower(166, 168, 6)
sunflower(424, 168, 9); sunflower(452, 158, 8); sunflower(404, 184, 6)

---------------------------------------------------------------- ceiling with roots and stalactites
for x = 0, 479 do
  local b = cy(x)
  for y = 0, b do
    local v = .5 - (y / b) * .42 + (vn(x, y, 7, 3) - .5) * .5 + (vn(x, y, 2, 6) - .5) * .12
    if y % 17 == 0 then v = v - .1 end
    c:px(x, y, R6(EARTH)[GX.idx(max(0, min(1, v)))])
  end
  c:px(x, b + 1, INK)
end
for i = 0, 40 do   -- stones embedded in the ceiling
  local x, y = floor(H(i, 20, 3) * 470) + 4, floor(H(i, 21, 3) * 30) + 4
  if y < cy(x) - 4 then local m = mk(); E(m, x, y, 3 + i % 3, 2 + i % 2); GX.lit(c, GX.rough(m, i, 1), R6(STONE), { R = 3, tex = .4, seed = i, rimlight = true }) end
end
for i = 0, 17 do
  local x0 = 14 + i * 27 + floor(H(i, 1, 5) * 12)
  local L = 14 + floor(H(i, 2, 5) * 24); local w = 6 + floor(H(i, 3, 5) * 5)
  local m = mk()
  for x = x0 - w, x0 + w do local t = 1 - abs(x - x0) / w; for y = cy(x) - 2, cy(x) + floor(L * t) do m:set(x, y) end end
  GX.lit(c, GX.rough(m, i + 40, 1), R6(EARTH), { R = 5, tex = .5, sc = 3, seed = i, rimlight = true })
end
for i = 0, 11 do   -- hanging roots
  local x0 = 10 + i * 40 + floor(H(i, 5, 6) * 25)
  local L = 28 + floor(H(i, 6, 6) * 40); local m = mk()
  for y = cy(x0) - 2, cy(x0) + L do
    local xo = x0 + floor(sin(y / 7 + i) * 2.5); local w = (y - cy(x0) < L * .6) and 2 or 1
    for xx = xo, xo + w do m:set(xx, y) end
  end
  GX.lit(c, m, R6(BARK), { R = 2, tex = .5, sc = 2, seed = i, rimlight = true })
  local tip = cy(x0) + L; c:px(x0 + floor(sin(L / 7 + i) * 2.5) + 1, tip + 1, BARK.shade)
end
-- the sun/footprint disc glowing through the ceiling
local sun = mk(); E(sun, 410, 40, 28, 28); sun = GX.rough(sun, 77, 2)
GX.lit(c, sun, R6{ hi = "#fffadc", base = "#ffe08a", shade = "#f5b84a", deep = "#d98a3a" }, { R = 20, tex = .35, sc = 4, seed = 9, rimlight = false, amb = .5, ink = "#7a3a2c" })
local foot = mk(); E(foot, 406, 44, 6, 9); E(foot, 416, 34, 4, 6)
foot:each(function(x, y) c:px(x, y, "#f0a030") end)
for i = 0, 7 do local a = i / 8 * 6.283; c:px(floor(410 + cos(a) * 33), floor(40 + sin(a) * 33), "#ffd890") end

---------------------------------------------------------------- warm light pass (hard-stepped, no blending alpha)
local LIGHTS = { { 136, 140, 70, 1 }, { sx + 38, 116, 95, 1.1 }, { 410, 40, 60, .55 }, { 245, 178, 34, .6 } }
for y = 0, 269 do for x = 0, 479 do
  local g = 0
  for _, L in ipairs(LIGHTS) do
    local dd = sqrt((x - L[1]) ^ 2 + ((y - L[2]) * 1.15) ^ 2) / L[3]
    if dd < 1 then g = max(g, (1 - dd) * L[4] + (vn(x, y, 3, 55) - .5) * .12) end
  end
  local q = floor(g * 5) / 5
  if q > 0 then
    local col = c:get(x, y)
    if col and col ~= INK then c:px(x, y, mix(col, "#ffa23c", min(.5, q * .62))) end
  end
end end

---------------------------------------------------------------- flames, eyes, drips (drawn after light)
local function drawflame(x, y, s)
  local rows = { { 0, 1 }, { 1, 1 }, { 1, 2 }, { 2, 3 }, { 2, 4 }, { 3, 4 }, { 3, 5 }, { 4, 5 }, { 4, 5 }, { 3, 4 } }
  local h = #rows
  for i, r in ipairs(rows) do
    local yy = y - floor((h - i + 1) * s) + 1
    local hw = floor(r[2] * s + .5)
    local sway = (i < 4) and 1 or 0
    for xx = -hw, hw do
      local col = "#e8493b"; local a = abs(xx) / max(1, hw)
      if a < .75 then col = "#ff8a2c" end
      if a < .5 and i > 4 then col = "#ffd45a" end
      if a < .25 and i > 6 then col = "#fff4c0" end
      for k = 0, floor(s) do c:px(x + xx + sway, yy + k, col) end
    end
  end
  c:px(x + 2, y - floor(h * s) - 1, "#ffd45a")
end
for _, f in ipairs(flames) do drawflame(f[1], f[2], f[3]) end
-- boss eyes in the dark (the quirk): wide, glowing, a little curious
for _, ex in ipairs{ cx - 8, cx + 8 } do
  for _, p in ipairs{ { -2, -1 }, { -2, 0 }, { -2, 1 }, { 2, -1 }, { 2, 0 }, { 2, 1 }, { -1, -2 }, { 0, -2 }, { 1, -2 }, { -1, 2 }, { 0, 2 }, { 1, 2 } } do
    c:px(ex + p[1], 172 + p[2], "#a8661e") end
  for dx = -1, 1 do for dy = -1, 1 do c:px(ex + dx, 172 + dy, "#ffcc3a") end end
  c:px(ex, 172, "#fff4c0"); c:px(ex - 1, 171, "#fff4c0")
  c:px(ex + 1, 173, "#ff8a2c")
end
for k = -3, 3 do c:px(cx + k, 171 - (abs(k) > 1 and 1 or 0) - 5, "#4a2c3a") end   -- heavy brow
for i = 0, 4 do   -- little teeth in the dark
  local tx = cx - 9 + i * 4 + 1
  c:px(tx, 182, "#d8c8b0"); c:px(tx + 1, 182, "#d8c8b0"); c:px(tx, 183, "#a89480")
end
for _, p in ipairs{ { 126, 120 }, { 312, 100 }, { 205, 132 } } do   -- drips
  c:px(p[1], p[2], "#8ad0e8"); c:px(p[1], p[2] + 1, "#c8f0f8")
end
for i = 0, 14 do   -- drifting embers
  local x, y = floor(120 + H(i, 90, 7) * 270), floor(60 + H(i, 91, 7) * 100)
  c:px(x, y, "#ffb040"); if i % 3 == 0 then c:px(x, y - 1, "#ffe08a") end
end

c:save{ aseprite = d.."/out/trek-1-boss.aseprite", png = d.."/out/trek-1-boss.png", scale = 1 }
