-- scene-coast: "Salt wind, tide pools and gull cries."  Day palette.
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H = X.hash
local INK = GX.INK
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "scene-coast" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end

local SAND = { hi = "#fff0b8", base = "#f2cf80", shade = "#d9a45e", deep = "#a8704a" }
local WOOD = { hi = "#f4e8d0", base = "#cdb28c", shade = "#9a7a60", deep = "#5e4a4a" }
local ROCK = { hi = "#c8c0d0", base = "#8e88a4", shade = "#605c80", deep = "#363452" }
local SEA = { hi = "#8ae8e0", base = "#3cb8c8", shade = "#2a84b0", deep = "#1f5088" }
local POOL = { hi = "#a8f4ec", base = "#58d0d0", shade = "#2e98b8", deep = "#1f6090" }
local KELP = { hi = "#b4d060", base = "#6a9a38", shade = "#46703c", deep = "#2a4a3c" }
local SUCC = { hi = "#c8f070", base = "#6cc050", shade = "#3a9048", deep = "#1f5a44" }
local STAR = { hi = "#ffb070", base = "#f0683c", shade = "#c0402e", deep = "#7a2638" }
local CRAB = { hi = "#ff9a6c", base = "#e8503c", shade = "#b03038", deep = "#6e2038" }
local SHADOW = "#9a6a4c"

---------------------------------------------------------------- sky and sea
GX.bands(c, 0, 96, { "#9ad8f4", "#b4e4f6", "#cdf0f4", "#e4f8ec", "#fff4cc", "#ffe8b0" }, 3, .2)
-- soft hard-pixel clouds
for i, cl in ipairs{ { 70, 30, 40 }, { 210, 18, 34 }, { 330, 40, 46 }, { 430, 22, 30 } } do
  local m = mk(); E(m, cl[1], cl[2], cl[3], 5); E(m, cl[1] - 12, cl[2] - 4, cl[3] // 2, 4); E(m, cl[1] + 14, cl[2] - 3, cl[3] // 2.5, 4)
  m = GX.rough(m, 40 + i, 2)
  GX.lit(c, m, GX.ramp6({ hi = "#ffffff", base = "#fff6e4", shade = "#f4dcc8", deep = "#e0bcb8" }), { R = 5, tex = .25, sc = 4, seed = i, ink = false })
end
-- sun glare near the horizon
local sun = mk(); E(sun, 300, 90, 22, 8); c:fillMask(GX.rough(sun, 5, 1), "#fff8d0")
local sun2 = mk(); E(sun2, 300, 90, 12, 4); c:fillMask(sun2, "#ffffff")
-- sea
local SEA6 = { "#8ae8e0", "#5cd0d4", "#3cb8c8", "#34a0c0", "#2a84b0", "#2670a8" }
GX.bands(c, 94, 134, SEA6, 9, .18)
for y = 95, 133 do for x = 0, 479 do   -- sparkle and wave dashes
  local n = GX.vn(x * .45, y, 3, 14)
  if n > .74 and y % 3 == 0 then c:px(x, y, (y < 112) and "#d8fff4" or "#7ae0e0") end
  if n < .12 and y % 4 == 1 then c:px(x, y, "#2a84b0") end
end end
for x = 270, 330 do if H(x, 3, 3) > .45 then c:px(x, 95 + floor(H(x, 4, 4) * 12), "#fffbe0") end end
-- far island / headland and sail
local isl = mk(); E(isl, 150, 95, 34, 5); E(isl, 130, 92, 14, 4); isl = GX.rough(isl, 8, 1)
GX.lit(c, isl, GX.ramp6({ hi = "#a8d8c0", base = "#7cb8a8", shade = "#5a98a0", deep = "#487890" }), { R = 4, tex = .3, seed = 2, ink = false })
c:fillMask(c:poly{ { 392, 93 }, { 392, 82 }, { 398, 93 } }, "#fff6e4"); c:fillMask(c:rect(388, 94, 400, 94), "#8a5a44")
-- gull far away
for _, g in ipairs{ { 236, 44 }, { 252, 38 }, { 214, 54 } } do
  local x, y = g[1], g[2]
  c:px(x - 3, y, "#fdfdfd"); c:px(x - 2, y - 1, "#fdfdfd"); c:px(x - 1, y - 1, "#fdfdfd"); c:px(x, y, INK); c:px(x + 1, y - 1, "#fdfdfd"); c:px(x + 2, y - 1, "#fdfdfd"); c:px(x + 3, y, "#fdfdfd")
end
-- surf lines: foam crests inside the sea
for k = 0, 3 do
  local yb = 112 + k * 6
  for x = 0, 479 do
    local y = yb + floor(sin(x / 17 + k * 2) * 1.5 + (GX.vn(x, k, 9, 6) - .5) * 3)
    if H(x // 2, k, 7) > .28 then c:px(x, y, (k % 2 == 0) and "#e8fff8" or "#b0f0ec") end
  end
end

---------------------------------------------------------------- beach (sand)
local function shore(x) return 134 + floor(3 * sin(x / 29 + 1) + 2 * sin(x / 11)) end
GX.ground(c, shore, SAND, 7, { top = .86, fall = .55, tex = .26, sc = 9 })
-- wet sand band + foam line
for x = 0, 479 do
  local y0 = shore(x)
  for y = y0, y0 + 7 do
    local t = (y - y0) / 7
    if GX.vn(x, y, 4, 33) > t * .9 + .1 then c:px(x, y, (y - y0 < 3) and "#c8a068" or "#e0b878") end
  end
  c:px(x, y0 - 1, "#f4fffa"); if H(x, 1, 5) > .35 then c:px(x, y0 - 2, "#ffffff") end
  if H(x // 3, 2, 5) > .5 then c:px(x, y0, "#e8fff8") end
  if H(x // 4, 8, 5) > .6 then c:px(x, y0 + 1, "#e8fff8") end
end
-- sand ripples
for y = 150, 269 do for x = 0, 479 do
  local w = sin((y + GX.vn(x, y, 22, 41) * 9) * .85)
  if w > .93 and GX.vn(x, y, 6, 42) > .4 then c:px(x, y, SAND.shade)
  elseif w < -.97 and GX.vn(x, y, 6, 43) > .45 then c:px(x, y, SAND.hi) end
end end

---------------------------------------------------------------- cliff frame (right + top-left)
local function rockmass(m, seed, ramp, R, ink)
  m = GX.rough(m, seed, 2)
  GX.lit(c, m, GX.ramp6(ramp), { R = R or 14, tex = .55, sc = 3.2, seed = seed, rimlight = true, amb = .22,
    fn = function(x, y) return (H(x // 3, y // 3, seed) - .5) * .25 end })
  return m
end
local cl = mk()
for y = 0, 176 do
  local edge = 446 - floor(max(0, y - 120) * .22) + floor((GX.vn(0, y, 14, 3) - .5) * 14)
  for x = edge, 479 do cl:set(x, y) end
end
E(cl, 462, 176, 26, 14); E(cl, 452, 150, 8, 16)
rockmass(cl, 61, ROCK, 18)
-- crack lines
for _, cr in ipairs{ { 456, 20 }, { 466, 70 }, { 452, 110 } } do
  for i = 0, 22 do c:px(cr[1] + floor(sin(i / 3) * 2) + i // 5, cr[2] + i, ROCK.deep) end
end
-- grass tuft cap on cliff top
for x = 450, 479 do for y = 0, 4 + floor(GX.vn(x, 0, 5, 9) * 4) do
  c:px(x, y, GX.ramp6(SUCC)[(y < 2) and 6 or (y < 4 and 5 or 4)])
end end
local tl = mk()
for x = 0, 70 do for y = 0, 26 - floor(x * .28) + floor((GX.vn(x, 0, 8, 2) - .5) * 8) do tl:set(x, y) end end
rockmass(tl, 71, ROCK, 10)
for x = 0, 52 do for y = 0, 3 + floor(GX.vn(x, 0, 5, 12) * 4) do if tl:has(x, y) then c:px(x, y, GX.ramp6(SUCC)[(y < 2) and 6 or 4]) end end end
-- cliff-foot boulders
for i, b in ipairs{ { 452, 186, 16, 9 }, { 470, 192, 16, 9 } } do
  local m = mk(); E(m, b[1], b[2], b[3], b[4]); rockmass(m, 80 + i, ROCK, 8)
end

---------------------------------------------------------------- ground shadows and decor behind the hero
local function blocked(x, y) return (x < 156 and y > 118 and y < 205) or (x > 280 and x < 440 and y > 60 and y < 220) or (x > 436 and y < 208) end
-- driftwood log shadow
local ls = mk(); E(ls, 82, 196, 70, 6); c:fillMask(GX.rough(ls, 5, 1), SHADOW)
-- contact shadow (satchel)
local sh = mk(); GX.disc(sh, 357, 213, 74, 5); c:fillMask(sh, SHADOW)

---------------------------------------------------------------- driftwood log (hero)
local lg = mk()
for x = 12, 136 do
  local top = 156 + floor((GX.vn(x, 0, 12, 4) - .5) * 5) - (x < 40 and floor((40 - x) * .15) or 0)
  local bot = 192 - floor(GX.vn(x, 9, 9, 5) * 4)
  for y = top, bot do lg:set(x, y) end
end
E(lg, 14, 174, 6, 19)
-- bleached branch stubs
for _, br in ipairs{ { 36, 156, 30, 128 }, { 92, 155, 100, 136 }, { 112, 156, 128, 142 } } do
  local bm = c:poly{ { br[1] - 4, br[2] + 4 }, { br[1] + 4, br[2] + 4 }, { br[3] + 2, br[4] }, { br[3] - 2, br[4] } }
  for y = 0, 0 do end
  lg:add(bm)
end
lg = GX.rough(lg, 91, 1)
local lgv = GX.lit(c, lg, GX.ramp6(WOOD), { R = 24, tex = .35, sc = 2.2, seed = 9, rimlight = true,
  fn = function(x, y) return (GX.vn(x * .18, y, 2, 6) - .5) * .55 end })
-- grain streaks + cracks
for i = 0, 18 do
  local y = 160 + floor(H(i, 3, 3) * 30); local x0 = 16 + floor(H(i, 4, 3) * 100); local len = 6 + floor(H(i, 5, 3) * 16)
  for k = 0, len do if lg:has(x0 + k, y) then c:px(x0 + k, y, WOOD.shade) end end
end
-- end face with rings
local face = mk(); E(face, 138, 174, 9, 19); face = GX.rough(face, 33, 1)
GX.lit(c, face, GX.ramp6({ hi = "#f6e2b8", base = "#dcb888", shade = "#b08860", deep = "#7a5a4c" }), { R = 10, tex = .15, seed = 2, rimlight = true,
  fn = function(x, y) local dd = sqrt(((x - 139) / 9) ^ 2 + ((y - 175) / 19) ^ 2); return (floor(dd * 4) % 2) * .16 - .08 end })
-- knot hole
local kn = mk(); E(kn, 62, 172, 4, 3); GX.lit(c, kn, GX.ramp6({ hi = "#8a6a58", base = "#5e4a4a", shade = "#3c2c38", deep = "#241820" }), { R = 3, tex = 0, ink = INK })
-- barnacles + seaweed on the log
for i = 0, 14 do
  local x, y = 18 + floor(H(i, 7, 7) * 110), 178 + floor(H(i, 8, 7) * 12)
  if lg:has(x, y) and lg:has(x + 1, y + 1) then c:px(x, y, "#fff6e4"); c:px(x + 1, y, "#d8d0c8"); c:px(x, y + 1, "#a8a0a0"); c:px(x + 1, y + 1, "#7a7080") end
end
for _, sx in ipairs{ 24, 46, 78 } do   -- kelp draped over the top
  for k = 0, 14 do
    local x, y = sx + floor(sin(k / 2.5) * 2), 154 + k
    c:px(x, y, KELP.base); c:px(x + 1, y, KELP.shade); c:px(x - 1, y, KELP.hi)
  end
end
-- gull perched on the branch? (small, quirk is the crab) -- bleached branch tip highlights
c:px(30, 128, WOOD.hi); c:px(100, 136, WOOD.hi)

---------------------------------------------------------------- tide pool (foreground, low)
local function blob(cx, cy, rx, ry, seed)
  local m = mk(); E(m, cx, cy, rx, ry); return GX.rough(m, seed, 2)
end
local rimr = blob(222, 241, 50, 15, 51)
GX.lit(c, rimr, GX.ramp6({ hi = "#e8d0a0", base = "#b88c68", shade = "#8a6a5c", deep = "#5a4650" }), { R = 8, tex = .4, sc = 3, seed = 6, rimlight = true })
local pool = blob(222, 242, 43, 11, 52)
c:rim(pool, GX.mix(INK, POOL.deep, .5))
GX.lit(c, pool, GX.ramp6(POOL), { R = 14, tex = .22, sc = 4, seed = 8, ink = false, amb = .5, wrap = .6,
  fn = function(x, y) return -.2 + (y - 232) * .015 + ((x + y * 2) % 9 == 0 and .12 or 0) end })
for i = 0, 22 do   -- wavelets and sky glints
  local x, y = 184 + floor(H(i, 13, 3) * 76), 233 + floor(H(i, 14, 3) * 18)
  if pool:has(x, y) and pool:has(x + 3, y) then c:px(x, y, "#e8fffa"); c:px(x + 1, y, "#e8fffa"); c:px(x + 2, y, "#a8f4ec") end
end
-- kelp wisps in the pool
for _, k in ipairs{ { 200, 252, 12 }, { 212, 253, 9 }, { 244, 251, 11 } } do
  for i = 0, k[3] do
    local x, y = k[1] + floor(sin(i / 2 + k[1]) * 2.2), k[2] - i
    if pool:has(x, y) then c:px(x, y, (i % 3 == 0) and KELP.hi or KELP.base); c:px(x + 1, y, KELP.shade) end
  end
end
-- starfish
local function starfish(x, y, s, R)
  local arms = {}
  for a = 0, 4 do
    local t = -1.5708 + a * 1.2566
    arms[#arms + 1] = { x + floor(cos(t) * 7 * s + .5), y + floor(sin(t) * 7 * s * .8 + .5) }
    local t2 = t + .6283
    arms[#arms + 1] = { x + floor(cos(t2) * 2.4 * s + .5), y + floor(sin(t2) * 2.4 * s * .8 + .5) }
  end
  local m = c:poly(arms); E(m, x, y, 2 * s, 2 * s * .8)
  GX.lit(c, m, GX.ramp6(R), { R = 3, tex = .3, sc = 1.6, seed = x, rimlight = true })
  c:px(x, y, R.hi); c:px(x - 1, y + 1, R.shade)
  for a = 0, 4 do local t = -1.5708 + a * 1.2566; c:px(x + floor(cos(t) * 4 * s + .5), y + floor(sin(t) * 4 * s * .8 + .5), R.hi) end
end
starfish(206, 240, 1.0, STAR)
starfish(238, 246, 0.8, { hi = "#ffe38a", base = "#f0b43a", shade = "#d0802a", deep = "#8f4a1f" })
-- anemone / succulent clump on the pool rim
for _, a in ipairs{ { 176, 238 }, { 182, 244 } } do
  local m = blob(a[1], a[2], 4, 3, a[1]); GX.lit(c, m, GX.ramp6(SUCC), { R = 3, tex = .5, sc = 1.8, seed = a[1], rimlight = true })
  for k = -3, 3, 2 do c:px(a[1] + k, a[2] - 4, SUCC.hi) end
end
-- limpets on pool rim
for _, a in ipairs{ { 262, 232 }, { 266, 238 }, { 170, 232 } } do
  c:px(a[1], a[2], "#e8dcc0"); c:px(a[1] + 1, a[2], "#b8a890"); c:px(a[1], a[2] + 1, "#8a7a78"); c:px(a[1] + 1, a[2] + 1, "#6a5a68")
end

---------------------------------------------------------------- shells, pebbles, kelp on sand, driftwood bits
local PEB = { hi = "#e8e4ee", base = "#b4b0c4", shade = "#7e7a98", deep = "#4a4868" }
for i = 0, 34 do
  local x, y = 8 + floor(H(i, 21, 5) * 465), 160 + floor(H(i, 22, 5) * 106)
  if not blocked(x, y) and not (abs(x - 222) < 56 and abs(y - 242) < 20) then
    local m = mk(); E(m, x, y, 1 + i % 3, 1 + (i % 2)); local pr = (i % 4 == 0) and { hi = "#ffd8c0", base = "#e8a090", shade = "#b87078", deep = "#7a4658" } or PEB
    GX.lit(c, m, GX.ramp6(pr), { R = 2, tex = .15, seed = i, rimlight = true })
  end
end
local function shell(x, y, col)   -- fan scallop
  local m = c:poly{ { x - 5, y }, { x - 4, y - 3 }, { x - 2, y - 5 }, { x + 2, y - 5 }, { x + 4, y - 3 }, { x + 5, y } }
  GX.lit(c, m, GX.ramp6(col), { R = 3, tex = .1, seed = x, rimlight = true })
  for k = -3, 3, 2 do c:px(x + k, y - 1, col.shade); c:px(x + k // 2, y - 3, col.shade) end
  c:fillMask(c:rect(x - 1, y + 1, x + 1, y + 1), col.deep)
end
shell(162, 218, { hi = "#fff0e8", base = "#f4b8a8", shade = "#d08088", deep = "#80485a" })
shell(290, 236, { hi = "#fff8e0", base = "#f0d8a0", shade = "#c0985c", deep = "#7a5a48" })
shell(430, 244, { hi = "#fff0e8", base = "#f4b8a8", shade = "#d08088", deep = "#80485a" })
-- spiral shell
local sp = mk(); E(sp, 72, 222, 4, 3); GX.lit(c, sp, GX.ramp6({ hi = "#fffaf0", base = "#f0dcc0", shade = "#c0a080", deep = "#7a5a48" }), { R = 3, tex = 0, seed = 2, rimlight = true })
c:px(71, 222, "#a07858"); c:px(72, 221, "#a07858"); c:px(73, 222, "#a07858")
-- washed up kelp strands on sand
for _, k in ipairs{ { 28, 226, 30, 1 }, { 330, 252, 26, 1 }, { 400, 232, 22, -1 } } do
  local x0, y0, len, dr = k[1], k[2], k[3], k[4]
  for i = 0, len do
    local x, y = x0 + i * dr, y0 + floor(sin(i / 3.2) * 2)
    c:px(x, y - 1, KELP.hi); c:px(x, y, KELP.base); c:px(x, y + 1, KELP.shade)
    if i % 6 == 3 then c:px(x, y - 2, KELP.base); c:px(x + dr, y - 2, KELP.hi) end
  end
end
-- sea grass on dune patches
for i = 0, 16 do
  local x, y = 6 + floor(H(i, 61, 1) * 470), 156 + floor(H(i, 63, 1) * 108)
  if not blocked(x, y) and not (abs(x - 222) < 58 and abs(y - 242) < 22) then GX.tuft(c, x, y, { hi = "#d8e888", base = "#a8c060", shade = "#6c9050", deep = "#486a46" }) end
end
-- tiny beach flowers
for i = 0, 7 do
  local x, y = 20 + floor(H(i, 41, 1) * 440), 170 + floor(H(i, 43, 1) * 90)
  if not blocked(x, y) and not (abs(x - 222) < 58 and abs(y - 242) < 22) then GX.flower(c, x, y, (i % 2 == 0) and "#ff9fc0" or "#fff4d6") end
end

---------------------------------------------------------------- crab (the quirk): carrying a tiny shell hat
local function crab(x, y)
  local bd = mk(); E(bd, x, y, 9, 5); bd = GX.rough(bd, 17, 1)
  for s = -1, 1, 2 do   -- legs
    for k = 0, 2 do
      local lx = x + s * (8 + k)
      c:px(lx, y + 1 + k, INK); c:px(lx + s, y + 2 + k, INK); c:px(lx, y + 2 + k, CRAB.shade)
    end
    -- claws raised
    local cm = mk(); E(cm, x + s * 13, y - 6, 4, 3); cm:cut(c:rect(x + s * 13 - 1, y - 9, x + s * 13 + 1, y - 7))
    GX.lit(c, cm, GX.ramp6(CRAB), { R = 3, tex = .1, seed = 5 + s, rimlight = true })
    for k = 0, 3 do c:px(x + s * (9 + k), y - 2 - k, INK); c:px(x + s * (9 + k) + s, y - 2 - k, CRAB.base) end
  end
  GX.lit(c, bd, GX.ramp6(CRAB), { R = 5, tex = .3, sc = 2, seed = 7, rimlight = true })
  -- eye stalks
  for s = -1, 1, 2 do
    c:px(x + s * 3, y - 6, INK); c:px(x + s * 3, y - 7, CRAB.shade)
    c:px(x + s * 3, y - 8, "#ffffff"); c:px(x + s * 3 + s, y - 8, INK)
  end
  -- little scallop-shell hat
  local hat = c:poly{ { x - 5, y - 8 }, { x - 3, y - 12 }, { x + 3, y - 12 }, { x + 5, y - 8 } }
  GX.lit(c, hat, GX.ramp6({ hi = "#fff8e0", base = "#f4d0a8", shade = "#d08088", deep = "#80485a" }), { R = 3, tex = 0, seed = 3, rimlight = true })
  c:px(x, y - 11, "#d08088"); c:px(x - 2, y - 10, "#d08088"); c:px(x + 2, y - 10, "#d08088")
  c:fillMask(c:rect(x - 2, y - 1, x + 2, y - 1), CRAB.deep)   -- mouth
end
local cs = mk(); E(cs, 120, 228, 15, 3); c:fillMask(cs, SHADOW)
crab(120, 222)
-- crab tracks
for i = 0, 7 do c:px(138 + i * 5, 228 + (i % 2) * 2, SAND.shade); c:px(139 + i * 5, 228 + (i % 2) * 2, SAND.shade) end

c:save{ aseprite = d.."/../out/scene-coast.aseprite", png = d.."/../out/scene-coast.png", scale = 1 }
