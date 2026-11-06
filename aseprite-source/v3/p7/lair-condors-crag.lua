-- v3 redraw: LAIR OF THE CONDOR'S CRAG (480x270). Dusk-gold light, a tall faceted crag, a great condor on its nest.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d .. "/../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H, K = X.hash, X.K
local INK = GX.INK
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "lair-condors-crag" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, floor(cx), floor(cy), rx, ry or rx) end

local DARK  = { hi = "#9a82bc", base = "#56426e", shade = "#3a2c56", deep = "#221a38" }
local CREAM = { hi = "#fff4d0", base = "#f0d8a8", shade = "#c0a0a0", deep = "#80668a" }
local SKIN  = { hi = "#ffb878", base = "#e4743e", shade = "#b04a40", deep = "#6e2a3c" }
local TWIG  = { hi = "#e0a468", base = "#a8704a", shade = "#6e4a48", deep = "#3c2a3c" }
local BONE  = { hi = "#fffae0", base = "#f0dcb4", shade = "#bc9ca4", deep = "#76608a" }
local WARM  = { hi = "#ffd890", base = "#d89a84", shade = "#9a6890", deep = "#5a4478" }
local COOL  = { hi = "#c4a4cc", base = "#8a6a9e", shade = "#5e4a80", deep = "#38305c" }
local LEDGE = { hi = "#f8c888", base = "#b8806c", shade = "#7c5a74", deep = "#483452" }
for _, t in ipairs{ DARK, CREAM, SKIN, TWIG, BONE, WARM, COOL, LEDGE } do local r6 = GX.ramp6(t); for i = 1, 6 do t[i] = r6[i] end end

---------------------------------------------------------------- sky
GX.bands(c, 0, 190, { "#3c3880", "#54449a", "#7c52a4", "#b2609e", "#dc7e90", "#f19c74", "#fbbd7a", "#ffd890", "#ffe8aa" }, 3, .22)
-- sun halo (hard rings that lift whatever sky is under them) and sun
local function halo(cx, cy, r, ry, t, seed)
  local m = mk(); E(m, cx, cy, r, ry); m = GX.rough(m, seed, 1)
  m:each(function(x, y) local o = c:get(x, y); if o then c:px(x, y, GX.mix(o, "#fff0b8", t)) end end)
end
halo(62, 58, 64, 56, .16, 11); halo(62, 58, 46, 40, .2, 12); halo(62, 58, 30, 27, .28, 13)
do
  local m = mk(); E(m, 62, 58, 18, 18); m = GX.rough(m, 14, 1)
  GX.lit(c, m, GX.ramp6({ hi = "#ffffe4", base = "#ffec98", shade = "#ffc860", deep = "#f0a05a" }), { R = 18, tex = .18, sc = 5, seed = 14, ink = false, amb = .5 })
end
local function streak(cx, cy, rw, seed)
  local m = mk()
  for i = 0, 6 do E(m, cx + floor((H(i, seed, 1) - .5) * rw * 1.5), cy + floor((H(i, seed, 2) - .5) * 3), 8 + floor(H(i, seed, 3) * 12), 2 + floor(H(i, seed, 4) * 3)) end
  m = GX.rough(m, seed, 1)
  GX.lit(c, m, GX.ramp6({ hi = "#ffe8c0", base = "#f8bea0", shade = "#d8869e", deep = "#a05c96" }), { R = 5, tex = .25, sc = 4, seed = seed, ink = false })
end
streak(150, 34, 50, 4); streak(380, 26, 46, 5); streak(430, 74, 40, 6); streak(300, 62, 30, 7); streak(60, 112, 36, 8)
-- a few distant condors (friends of the boss)
for _, b in ipairs{ { 120, 108 }, { 138, 100 }, { 396, 118 }, { 414, 110 }, { 352, 52 } } do
  local x, y = b[1], b[2]
  for i = 0, 4 do c:px(x - 5 + i, y + (i < 3 and i or 4 - i) - 3 + 2, INK); c:px(x + 5 - i, y + (i < 3 and i or 4 - i) - 3 + 2, INK) end
  c:px(x, y, INK)
end

---------------------------------------------------------------- far peaks
local function layer(peaks, cap, R, seed, haze, ybot)
  local R6 = GX.ramp6(R)
  local function ridge(x)
    local best = cap
    for _, p in ipairs(peaks) do best = min(best, p[2] + abs(x - p[1]) * p[3]) end
    return floor(best + (GX.vn(x, 0, 5, seed) - .5) * 6 + (GX.vn(x, 1, 2, seed) - .5) * 2)
  end
  for x = 0, 479 do
    local top = ridge(x)
    local sl = ridge(x + 3) - ridge(x - 3)
    for y = top, ybot do
      local v = .5 - sl * .04 + (GX.vn(x, y, 6, seed + 1) - .5) * .5 + (GX.vn(x * .5, y, 3, seed + 2) - .5) * .3
      if y - top < 2 and sl < 0 then v = .9 end
      local t = min(1, (y - top) / max(1, ybot - top)) * haze
      c:px(x, y, GX.mix(R6[GX.idx(v)], "#f6b894", t))
    end
  end
end
layer({ { 40, 110, 1.0 }, { 120, 96, 1.1 }, { 205, 120, .9 }, { 330, 98, 1.0 }, { 420, 112, 1.1 }, { 480, 120, 1 } }, 150,
  { hi = "#e8a0b8", base = "#b87aa8", shade = "#9060a0", deep = "#6c4c90" }, 21, .5, 200)
layer({ { 10, 150, .8 }, { 90, 136, .9 }, { 190, 152, .75 }, { 380, 132, 1.0 }, { 470, 140, .9 } }, 164,
  { hi = "#d28cae", base = "#a468a0", shade = "#7c5498", deep = "#5c4084" }, 31, .3, 220)

---------------------------------------------------------------- cloud sea (back + mid layers)
local function sea(y, amp, R, seed, rr, ybot)
  local m = mk()
  for x = -10, 490, 9 do
    local cy = y + floor((GX.vn(x, 0, 40, seed) - .5) * amp)
    E(m, x, cy, rr + floor(H(x, seed, 1) * 8), 4 + floor(H(x, seed, 2) * 4))
  end
  for yy = y + 4, ybot do for x = 0, 479 do m:set(x, yy) end end
  m = GX.rough(m, seed, 1)
  GX.lit(c, m, GX.ramp6(R), { R = 7, tex = .3, sc = 5, seed = seed, ink = false, amb = .3 })
end
sea(190, 10, { hi = "#ffe4c8", base = "#e8aeaa", shade = "#b8789e", deep = "#8a5a98" }, 41, 16, 270)
sea(214, 12, { hi = "#fff0d0", base = "#f4c4a8", shade = "#c890a4", deep = "#9266a0" }, 42, 18, 270)

---------------------------------------------------------------- the crag
local function Lx(y) return 196 - (y - 164) * .47 + (GX.vn(0, y, 12, 71) - .5) * 9 end
local function Rx(y) return 292 + (y - 164) * .5 + (GX.vn(0, y, 12, 72) - .5) * 9 end
local fid = {}
local crag = mk()
for x = 140, 350 do
  local top = 163 + floor(GX.vn(x, 0, 7, 73) * 5)
  for y = top, 266 do
    if x >= Lx(y) and x <= Rx(y) then crag:set(x, y) end
  end
end
-- stepped ledges on the faces
for _, s in ipairs{ { 166, 22, 6, -1 }, { 182, 6, 22, 1 }, { 204, 26, 5, -1 }, { 226, 5, 24, 1 }, { 244, 18, 6, -1 } } do
  local y, a, b = s[1], s[2], s[3]
  for yy = y, y + 5 do for x = floor(Lx(yy)) - a, floor(Lx(yy)) do crag:set(x, yy) end
    for x = floor(Rx(yy)), floor(Rx(yy)) + b do crag:set(x, yy) end end
end
crag = GX.rough(crag, 74, 1)
local seeds = {}
for i = 1, 22 do
  local sx, sy = 150 + H(i, 5, 1) * 190, 164 + H(i, 5, 2) * 102
  seeds[i] = { sx, sy, .2 - (sx - 150) / 190 * .52 + (H(i, 5, 3) - .5) * .16, sx < 244 }
end
local function facet(x, y)
  local jx, jy = x + (GX.vn(x, y, 9, 75) - .5) * 14, y + (GX.vn(x, y, 9, 76) - .5) * 14
  local best, bd = 1, 1e9
  for i, s in ipairs(seeds) do
    local dx, dy = jx - s[1], (jy - s[2]) * 1.5   -- taller than wide: vertical cleavage
    local dd = dx * dx + dy * dy
    if dd < bd then bd = dd; best = i end
  end
  return best
end
crag:each(function(x, y) fid[K(x, y)] = facet(x, y) end)
GX.lit(c, crag, function(x, y) local f = fid[K(x, y)]; return (f and seeds[f][4]) and WARM or COOL end, {
  R = 16, tex = .42, sc = 4, seed = 77, rimlight = true, amb = .22,
  fn = function(x, y)
    local f = fid[K(x, y)] or 1
    return seeds[f][3] * .8 - max(0, y - 236) / 40 * .16 + (H(x // 2, y // 3, 78) - .5) * .06
  end })
-- crisp facet creases (darker side wins)
crag:each(function(x, y)
  local f = fid[K(x, y)]
  for _, n in ipairs{ { 1, 0 }, { 0, 1 } } do
    local g = fid[K(x + n[1], y + n[2])]
    if g and g ~= f and seeds[g][3] < seeds[f][3] - .02 and crag:has(x + n[1], y + n[2]) then
      c:px(x + n[1], y + n[2], (seeds[g][4] and WARM or COOL).deep)
    end
  end
end)
-- gold veins (old crag had them) and cracks
local function vein(x, y, pts)
  for _, p in ipairs(pts) do
    local nx, ny = x + p[1], y + p[2]
    local n = max(abs(p[1]), abs(p[2]))
    for i = 0, n do
      local px, py = floor(x + (nx - x) * i / n), floor(y + (ny - y) * i / n)
      if crag:has(px, py) then c:px(px, py, "#ffd35a"); if crag:has(px, py + 1) then c:px(px, py + 1, "#c8823a") end end
    end
    x, y = nx, ny
  end
end
vein(196, 192, { { 14, -8 }, { 10, 8 }, { 14, -6 } }); vein(258, 186, { { 16, 6 }, { 14, -8 }, { 12, 8 } })
vein(212, 238, { { 12, 8 }, { 16, -10 }, { 12, 6 } }); vein(272, 226, { { 12, 8 }, { 10, -6 }, { 16, 6 } })
-- ink on the lower-right dropoff only where the crag meets cloud is already rimmed by lit()

---------------------------------------------------------------- front cloud mist over the crag foot
sea(257, 5, { hi = "#fff4d8", base = "#fbd2b0", shade = "#d8a0aa", deep = "#a874a4" }, 43, 20, 270)

---------------------------------------------------------------- nest, bones, feathers
local function twigline(x0, y0, x1, y1, col)
  local n = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, n do c:px(floor(x0 + (x1 - x0) * i / n + .5), floor(y0 + (y1 - y0) * i / n + .5), col) end
end
local nest = mk(); E(nest, 241, 166, 46, 9); E(nest, 214, 168, 14, 7); E(nest, 270, 168, 14, 7)
nest = GX.rough(nest, 80, 1)
for i = 1, 30 do   -- twigs poking out
  local a = H(i, 80, 1) * 6.283
  local ex, ey = 241 + cos(a) * 52, 167 + sin(a) * 12
  if sin(a) > -.5 then twigline(241 + cos(a) * 40, 167 + sin(a) * 8, ex, ey, i % 3 == 0 and TWIG.hi or TWIG.shade) end
end
GX.lit(c, nest, TWIG and GX.ramp6(TWIG), { R = 7, tex = .6, sc = 2.2, seed = 81, rimlight = true, amb = .3,
  fn = function(x, y) return (H(x // 4, y // 1, 82) - .5) * .3 - (((x - 241) / 46) ^ 2 + ((y - 166) / 9) ^ 2 < .5 and .12 or 0) end })
nest:each(function(x, y)   -- criss-cross twig strokes
  if H(x, y, 83) < .035 and nest:has(x + 5, y + 2) then twigline(x, y, x + 5, y + (H(x, y, 84) < .5 and 2 or -2), TWIG.deep); c:px(x, y - 1, TWIG.hi) end
end)
local function bone(x, y, len, dir, col)
  col = col or BONE
  for i = 0, len do
    local px, py = x + i * dir, y + floor(i * .22 * dir + .5)
    c:px(px, py, col.base); c:px(px, py - 1, col.hi); c:px(px, py + 1, col.shade)
  end
  for _, e in ipairs{ { 0, 0 }, { len * dir, floor(len * .22 * dir + .5) } } do
    local ex, ey = x + e[1], y + e[2]
    for _, o in ipairs{ { 0, -2 }, { 0, 2 }, { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } } do c:px(ex + o[1], ey + o[2], (o[2] > 0) and col.shade or col.base) end
    c:px(ex, ey - 1, col.hi)
  end
end
bone(209, 162, 14, 1); bone(268, 164, 12, -1); bone(190, 190, 10, 1); bone(305, 200, 9, 1)
-- ram skull on the left rim of the nest
do
  local sk = mk(); E(sk, 216, 160, 6, 5); sk:set(215, 166); sk:set(216, 166); sk:set(217, 166)
  sk = GX.rough(sk, 85, 1)
  GX.lit(c, sk, GX.ramp6(BONE), { R = 5, tex = .25, seed = 85, rimlight = true })
  for _, p in ipairs{ { 213, 160 }, { 214, 160 }, { 218, 160 }, { 219, 160 }, { 213, 161 }, { 219, 161 } } do c:px(p[1], p[2], INK) end
  c:px(216, 163, INK); c:px(216, 164, BONE.deep)
  for _, p in ipairs{ { 210, 156 }, { 209, 155 }, { 208, 156 }, { 208, 158 }, { 222, 156 }, { 223, 155 }, { 224, 156 }, { 224, 158 } } do c:px(p[1], p[2], BONE.base) end
  for _, p in ipairs{ { 210, 157 }, { 208, 159 }, { 222, 157 }, { 224, 159 } } do c:px(p[1], p[2], BONE.shade) end
end
-- ribcage chunk, right side of nest
for i = 0, 4 do twigline(262 + i * 4, 160 + (i % 2), 258 + i * 4, 168, BONE.base); c:px(262 + i * 4, 160 + (i % 2), BONE.hi) end
-- feathers
local function feather(x, y, len, dir, col)
  for i = 0, len do
    local px, py = x + i * dir, y - floor(sin(i / len * 2.3) * 3)
    c:px(px, py, i < 3 and BONE.base or DARK.base); c:px(px, py - 1, DARK.hi); c:px(px, py + 1, DARK.shade)
    if i > 2 and i % 3 == 0 then c:px(px, py + 2, DARK.shade); c:px(px, py - 2, DARK.base) end
  end
  c:px(x + len * dir, y - floor(sin(2.3) * 3), DARK.deep)
end
feather(284, 162, 12, 1); feather(196, 168, 10, -1); feather(160, 226, 9, 1); feather(330, 214, 10, 1)
-- quirk: a lost little red hat on a twig
twigline(226, 168, 226, 156, TWIG.deep)
for _, p in ipairs{ { 225, 155, "#e8493b" }, { 226, 155, "#e8493b" }, { 227, 155, "#b52e3f" }, { 226, 154, "#e8493b" }, { 226, 153, "#ff8a70" }, { 225, 156, "#b52e3f" }, { 227, 156, "#8a2038" } } do c:px(p[1], p[2], p[3]) end

---------------------------------------------------------------- the condor
local SX, SY = 241, 104   -- shoulder centre
-- wing feathers: root, tip in outward/down local coords
local function fmask(rx, ry, tx, ty, w, sgn, seed)
  local m = mk()
  local n = floor(max(abs(tx - rx), abs(ty - ry)))
  for i = 0, n do
    local t = i / n
    local r = max(1, floor(w * (1 - t ^ 1.4) + .5))
    E(m, SX + sgn * (rx + (tx - rx) * t), SY + ry + (ty - ry) * t, r, r)
  end
  return GX.rough(m, seed, 1)
end
local function wing(sgn, sd)
  local fl = {}
  for i = 6, 1, -1 do fl[#fl + 1] = { 100 + i * 9, -34 + i * 3, 110 + i * 9.5, -22 + i * 10.5, 6, false } end
  for i = 7, 1, -1 do fl[#fl + 1] = { 12 + i * 12, -14 - i * 3.2, 8 + i * 12, 46 - i * 2.2, 8, i >= 2 and i <= 6 } end
  for k, f in ipairs(fl) do
    local m = fmask(f[1], f[2], f[3], f[4], f[5], sgn, sd + k)
    local tipy = SY + f[4]
    local rootg = f[2]
    GX.lit(c, m, function(x, y)
      if f[6] and y > SY + f[2] + (f[4] - f[2]) * .34 and H(x, y // 2, sd) > .03 then return CREAM end
      return DARK
    end, { R = 4, tex = .4, sc = 3, seed = sd + k, amb = .25, rimlight = true,
      fn = function(x, y) return (H(x // 2, y, sd + k) - .5) * .12 + (sgn > 0 and -.2 or -.12) end })
    -- quill shaft
    local n = floor(max(abs(f[3] - f[1]), abs(f[4] - f[2])))
    for i = 2, n - 2 do
      local t = i / n
      local px, py = floor(SX + sgn * (f[1] + (f[3] - f[1]) * t)), floor(SY + f[2] + (f[4] - f[2]) * t)
      if m:has(px, py) and i % 2 == 0 then c:px(px, py, f[6] and CREAM.shade or DARK.deep) end
    end
  end
  -- coverts (arm)
  local cm = mk()
  local poly = { { 0, -12 }, { 24, -26 }, { 70, -40 }, { 110, -46 }, { 150, -40 }, { 176, -22 }, { 150, 4 }, { 110, -4 }, { 60, -2 }, { 20, 6 }, { 0, 10 } }
  local pts = {}
  for _, p in ipairs(poly) do pts[#pts + 1] = { SX + sgn * p[1], SY + p[2] } end
  cm = c:poly(pts)
  for i = 0, 11 do E(cm, SX + sgn * (14 + i * 13), SY + 2 + floor(H(i, sd, 3) * 6) - floor(i * .4), 9, 6) end
  cm = GX.rough(cm, sd + 50, 1)
  GX.lit(c, cm, DARK, { R = 14, tex = .5, sc = 3, seed = sd + 51, amb = .3, rimlight = true,
    fn = function(x, y) return (sgn < 0 and -.08 or -.2) + (H(x // 3, y // 2, sd) - .5) * .18 end })
  -- feather scallops on coverts
  cm:each(function(x, y)
    if (x // 4 + y // 3) % 2 == 0 and H(x // 4, y // 3, sd + 9) < .5 and cm:has(x, y + 1) and not cm:has(x, y + 2) then c:px(x, y, DARK.hi) end
  end)
end
wing(-1, 100); wing(1, 200)

-- body
local body = mk(); E(body, SX, 132, 22, 28); E(body, SX, 120, 24, 14)
body = GX.rough(body, 90, 1)
GX.lit(c, body, DARK, { R = 20, tex = .5, sc = 3, seed = 91, amb = .3, wrap = .1, rimlight = true,
  fn = function(x, y) return (H(x // 3, y // 2, 92) - .5) * .18 end })
body:each(function(x, y)
  if (x // 3 + y // 3) % 2 == 0 and H(x // 3, y // 3, 93) < .5 and body:has(x, y + 1) and not body:has(x, y + 2) then c:px(x, y, DARK.hi) end
end)
-- thighs and talons
for _, sx in ipairs{ -11, 11 } do
  local th = mk(); E(th, SX + sx, 150, 7, 9); th = GX.rough(th, 94 + sx, 1)
  GX.lit(c, th, DARK, { R = 6, tex = .3, seed = 95, rimlight = true })
  local lg = mk()
  for y = 156, 164 do for x = SX + sx - 2, SX + sx + 2 do lg:set(x, y) end end
  GX.lit(c, lg, GX.ramp6({ hi = "#fff0a0", base = "#e8b858", shade = "#b07848", deep = "#6a4448" }), { R = 3, tex = .2, seed = 96 })
  for k = -3, 3, 2 do   -- toes and claws gripping the nest
    twigline(SX + sx, 163, SX + sx + k * 2, 167, INK); c:px(SX + sx + k * 2, 168, BONE.base)
  end
end
-- white ruff
local ruff = mk(); E(ruff, SX, 98, 21, 8); E(ruff, SX - 11, 102, 8, 6); E(ruff, SX + 11, 102, 8, 6)
for i = 0, 6 do E(ruff, SX - 18 + i * 6, 106 + floor(H(i, 97, 1) * 3), 4, 3) end
ruff = GX.rough(ruff, 98, 1)
GX.lit(c, ruff, CREAM, { R = 8, tex = .5, sc = 2.5, seed = 99, amb = .3, rimlight = true })
-- neck + head
local neck = mk(); for y = 86, 98 do for x = SX - 6, SX + 6 do neck:set(x, y) end end
GX.lit(c, neck, SKIN, { R = 5, tex = .3, seed = 100, ink = false })
local head = mk(); E(head, SX, 78, 14, 16); E(head, SX, 90, 9, 7)
head = GX.rough(head, 101, 1)
GX.lit(c, head, SKIN, { R = 13, tex = .5, sc = 3, seed = 102, amb = .3, rimlight = true,
  fn = function(x, y) return (H(x // 2, y // 2, 103) - .5) * .1 end })
-- wattle wrinkles
for _, p in ipairs{ { -8, 84 }, { -7, 88 }, { 6, 86 }, { 7, 90 } } do c:px(SX + p[1], p[2], SKIN.deep); c:px(SX + p[1] + 1, p[2], SKIN.shade) end
-- comb
local comb = mk(); E(comb, SX, 63, 4, 5); comb = GX.rough(comb, 104, 1)
GX.lit(c, comb, GX.ramp6({ hi = "#ff8a78", base = "#d83a48", shade = "#9e2a48", deep = "#5c1e3c" }), { R = 4, tex = .2, seed = 105, rimlight = true })
-- fierce brow + eyes
for _, s in ipairs{ -1, 1 } do
  local ex = SX + s * 6
  for i = 0, 5 do c:px(ex - s * 5 + s * i, 72 + floor((5 - i) * .35), INK) end
  local e = mk(); E(e, ex, 77, 3, 3)
  GX.lit(c, e, GX.ramp6({ hi = "#ffffff", base = "#fff0c8", shade = "#e8b868", deep = "#a8704a" }), { R = 3, tex = 0, seed = 1 })
  c:px(ex - s, 77, INK); c:px(ex, 77, INK); c:px(ex - s, 78, INK); c:px(ex, 78, INK); c:px(ex - s, 76, "#ffffff")
end
-- hooked ivory beak
local beak = c:poly{ { SX - 6, 82 }, { SX + 6, 82 }, { SX + 5, 90 }, { SX + 3, 96 }, { SX, 99 }, { SX - 1, 95 }, { SX - 4, 91 } }
beak = GX.rough(beak, 106, 1)
GX.lit(c, beak, GX.ramp6({ hi = "#fffce0", base = "#f4dca4", shade = "#c49c88", deep = "#7c6078" }), { R = 6, tex = .3, seed = 107, rimlight = true })
c:px(SX - 2, 85, INK); c:px(SX + 2, 85, INK); c:px(SX, 98, INK); c:px(SX, 99, INK); c:px(SX - 1, 96, BONE.deep)
for x = SX - 4, SX + 4 do if beak:has(x, 90) then c:px(x, 90, BONE.shade) end end

---------------------------------------------------------------- foreground ledges (rock with dry gold grass)
local function ledge(x0, x1, topf, seed)
  local m = mk()
  for x = x0, x1 do for y = floor(topf(x) + (GX.vn(x, 0, 6, seed) - .5) * 5), 269 do m:set(x, y) end end
  m = GX.rough(m, seed, 1)
  local sd = {}
  for i = 1, 9 do sd[i] = { x0 + H(i, seed, 1) * (x1 - x0), 205 + H(i, seed, 2) * 65, (H(i, seed, 3) - .5) * .3 } end
  GX.lit(c, m, function(x, y) return LEDGE end, { R = 14, tex = .55, sc = 4, seed = seed, rimlight = true, amb = .2,
    fn = function(x, y)
      local b, bd = 1, 1e9
      for i, s in ipairs(sd) do local dd = (x - s[1]) ^ 2 + ((y - s[2]) * 1.4) ^ 2; if dd < bd then bd = dd; b = i end end
      return sd[b][3] + max(0, y - 250) / 20 * -.05
    end })
  return m
end
local lm = ledge(0, 108, function(x) if x <= 74 then return 212 - x * .05 end return 208 + (x - 74) * 1.8 end, 110)
local rm = ledge(372, 479, function(x) if x >= 410 then return 205 + (x - 410) * .03 end return 270 - (x - 372) * 1.7 end, 120)
for i = 0, 40 do   -- dry gold tufts on the lip
  local x = 2 + floor(H(i, 130, 1) * 104)
  if lm:has(x, 214) or lm:has(x, 209) then end
end
local function tops(m, x0, x1, seed, step)
  for x = x0, x1, step do
    for y = 190, 269 do
      if m:has(x, y) then
        if H(x, y, seed) < .75 then GX.tuft(c, x, y, { hi = "#ffe896", base = "#d8a858", shade = "#946a54" }) end
        break
      end
    end
  end
end
tops(lm, 6, 70, 131, 9); tops(rm, 420, 476, 132, 8)
-- quirk: tiny red flower on the left ledge (kept from the old picture)
do
  local fx = 52
  local fy = 212
  for y = 200, 230 do if lm:has(fx, y) then fy = y; break end end
  c:px(fx, fy - 4, "#e8493b"); c:px(fx - 1, fy - 3, "#e8493b"); c:px(fx + 1, fy - 3, "#b52e3f"); c:px(fx, fy - 3, "#ffd35a")
  c:px(fx, fy - 2, "#3f9150"); c:px(fx, fy - 1, "#3f9150")
end
bone(84, 232, 8, 1); feather(410, 232, 10, 1)

---------------------------------------------------------------- gold stitched hem (as in the old picture)
for x = 0, 479 do
  if x % 6 < 4 then
    for _, y in ipairs{ 2, 3, 266, 267 } do c:px(x, y, "#f5cf6a") end
  end
end

c:save{ aseprite = d .. "/out/lair-condors-crag.aseprite", png = d .. "/out/lair-condors-crag.png", scale = 1 }
