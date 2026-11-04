-- here-market-maplewold: MAPLEWOLD MARKET seen from the entrance gate, looking in (one-point, VP 120,56).
-- 240x135 grid, x2 = 480x270. Layout: here-market-maplewold.layout.json (all coords halved here).
-- Planes: far = sky, low sun, violet hills, autumn wood band (flat, no edge);
--         mid = big red-gold maple + town hall w/ clock tower, timber-frame shops (deep-tone edges);
--         near-mid = plaza w/ syrup fountain, stalls, notice board, orchard gate;
--         near = stone-and-timber entrance arch (ink edge) w/ maple-leaf bunting + lantern, sap-bucket maple.
-- quirk: the sugar shack's steam puff has two little cat ears.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local c = HP.canvas{ w = 240, h = 135, scale = 2, name = "here-market-maplewold" }
local floor, sin, abs, min, max = math.floor, math.sin, math.abs, math.min, math.max
local R = function(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
local E = function(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local function H(x, y, s) local v = sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453 return v - floor(v) end
local VP = { 120, 56 }
local function toVP(p, t) return { p[1] + (VP[1] - p[1]) * t, p[2] + (VP[2] - p[2]) * t } end

------------------------------------------------------------ SKY (warm autumn, low sun upper-left)
c:stripes(0, 56, { P.sky.base, P.sky.hi, P.cream, P.gold.hi }, { 4, 4, 3, 2 })
c:fillMask(E(58, 20, 8, 8), P.gold.base) c:fillMask(E(57, 19, 6, 6), P.gold.hi)
c:cloud(78, 26, 22, P.cream, P.petal.hi)
c:cloud(160, 18, 26, P.cream, P.petal.hi)
c:cloud(196, 34, 16, P.cream, P.petal.hi)

------------------------------------------------------------ FAR: hazy violet hills + autumn wood band
c:terrain(function(x) return 38 + 5 * sin(x / 27 + 1) + 3 * sin(x / 11) end, P.dusk.hi)
c:terrain(function(x) return 46 + 3 * sin(x / 19 + 3) + 2 * sin(x / 7) end, P.petal.hi)
c:terrain(function(x)
  local y = 51 + sin(x / 9)
  local b = (x % 7) local dx = abs(b - 3) if dx < 3 then y = y - (3 - dx) end
  return y
end, P.ember.hi)
for x = 0, 239 do if H(x, 3) > .55 then c:px(x, 50 + floor(sin(x / 9) + .5) + ((x % 7 == 3) and -2 or 0), P.gold.base) end end

------------------------------------------------------------ GROUND: cobble town floor in perspective
c:terrain(function() return 54 end, P.stone.base)
-- street + plaza paving (lighter)
local street = c:poly{ { 70, 135 }, { 170, 135 }, { 125, 56 }, { 115, 56 } }
street:add(E(120, 96, 64, 20))
c:fillMask(street:clip(c:rect(0, 56, 239, 134)), P.stone.hi)
-- cobble courses: rows get thinner toward the horizon, joints converge on the VP
do
  local rows = {}
  local y = 57
  local k = 0
  while y < 135 do rows[#rows + 1] = y; k = k + 1; y = y + 1 + floor(k * .45) end
  for i, ry in ipairs(rows) do
    for x = 0, 239 do
      local col = c:get(x, ry)
      if col == P.stone.hi then c:px(x, ry, P.stone.base) elseif col == P.stone.base then c:px(x, ry, P.stone.shade) end
    end
    local ny = rows[i + 1] or 135
    local step = 3 + floor((ry - 56) / 7)
    local off = (i % 2) * floor(step / 2)
    for x = -40 + off, 280, step do
      -- joints lean toward the VP
      local jx = floor(x + (x - 120) * 0)
      for yy = ry + 1, ny - 1 do
        local xx = floor(120 + (jx - 120) * (yy - 56) / max(1, ry - 56 + 1) + .5)
        if yy == ry + 1 or (ny - ry) > 3 then
          local col = c:get(xx, yy)
          if col == P.stone.hi then c:px(xx, yy, P.stone.base) elseif col == P.stone.base then c:px(xx, yy, P.stone.shade) end
        end
      end
    end
  end
end
-- plaza curb ring
do
  local ring = E(120, 96, 64, 20):cut(E(120, 96, 63, 19)):clip(c:rect(0, 76, 239, 134))
  ring:cut(c:poly{ { 70, 135 }, { 170, 135 }, { 127, 56 }, { 113, 56 } })
  c:fillMask(ring, P.stone.shade)
end

------------------------------------------------------------ MID: giant maple behind the hall (landmark)
local MAPLE = { hi = P.gold.hi, base = P.gold.base, shade = P.ember.base, deep = P.ember.shade }
local function speckle(m, cols, seed, dens)
  m:each(function(x, y) local h = H(x, y, seed) if h < dens then c:px(x, y, cols[1 + floor(h / dens * #cols) % #cols]) end end)
end
local function maple(cx, cy, rx, ry, seed, lit)
  local cr = E(cx, cy, rx, ry)
  for i = 0, 7 do
    local a = i / 8 * 6.283 + seed
    cr:add(E(cx + math.cos(a) * rx * .78, cy + sin(a) * ry * .72, rx * .38, ry * .4))
  end
  return cr
end
do
  local cr = maple(120, 26, 34, 18, .3)
  local tr = c:poly{ { 116, 58 }, { 124, 58 }, { 122, 36 }, { 118, 36 } }
  c:rim(cr:copy():add(tr), P.ember.deep)
  c:fillMask(tr, P.wood.shade)
  c:fillMask(cr, P.ember.base)
  -- lit upper-left (gold), shaded lower-right (crimson -> violet)
  cr:each(function(x, y)
    local v = (x - 120) / 34 + (y - 26) / 18 * 1.2
    if v < -.75 then c:px(x, y, P.gold.hi) elseif v < -.2 then c:px(x, y, P.gold.base)
    elseif v < .45 then c:px(x, y, P.ember.hi) elseif v > 1.15 then c:px(x, y, P.ember.shade) end
  end)
  cr:each(function(x, y)
    local h = H(x, y, 7)
    if h < .08 then c:px(x, y, P.ember.shade) elseif h < .14 then c:px(x, y, P.gold.hi) elseif h < .17 then c:px(x, y, P.dusk.base) end
  end)
end

------------------------------------------------------------ building kit
local function shingles(m, rp, lit, y0, seed)
  -- tile courses: base fill, a darker course line every 3 rows, staggered tile joints
  m:each(function(x, y)
    local row = (y - y0) % 3
    local course = floor((y - y0) / 3)
    local col = lit and rp.base or rp.shade
    local line = lit and rp.shade or rp.deep
    if row == 2 then col = line
    elseif row == 1 and (x + course * 2) % 4 == 0 then col = line
    elseif lit and row == 0 and H(x, y, seed) < .18 then col = rp.hi end
    c:px(x, y, col)
  end)
end
local function window(x0, y0, w, h, box)
  local f = c:rect(x0, y0, x0 + w - 1, y0 + h - 1)
  c:rim(f, P.wood.deep)
  c:fillMask(f, P.gold.base)
  R(x0, y0, x0 + floor(w / 2) - 1, y0 + floor(h / 2) - 1, P.gold.hi)
  R(x0 + floor(w / 2), y0, x0 + floor(w / 2), y0 + h - 1, P.wood.deep)
  R(x0, y0 + floor(h / 2), x0 + w - 1, y0 + floor(h / 2), P.wood.deep)
  c:px(x0 + w - 1, y0 + h - 1, P.gold.shade)
  if box then
    R(x0 - 1, y0 + h + 1, x0 + w, y0 + h + 2, P.wood.shade) R(x0 - 1, y0 + h + 1, x0 + w, y0 + h + 1, P.wood.base)
    local fl = { P.ember.base, P.gold.hi, P.petal.base, P.ember.hi }
    for i = 0, w + 1, 2 do c:px(x0 - 1 + i, y0 + h, fl[1 + (i // 2) % 4]) c:px(x0 + i, y0 + h, P.moss.shade) end
  end
end
local function door(cx, base, w, h, ramp)
  ramp = ramp or P.wood
  local hw = floor(w / 2)
  local m = c:rect(cx - hw, base - h + hw, cx - hw + w - 1, base - 1):add(E(cx - .5 + (w % 2) * .5, base - h + hw, hw - .5 + (w % 2) * .5, hw))
  m:clip(c:rect(cx - hw, base - h, cx - hw + w - 1, base - 1))
  c:rim(m, P.wood.deep)
  c:fillMask(m, ramp.shade)
  for x = cx - hw + 1, cx - hw + w - 1, 2 do c:fillMask(c:rect(x, base - h, x, base - 1):clip(m), ramp.base) end
  c:fillMask(c:rect(cx - hw, base - h + hw + 1, cx - hw + w - 1, base - h + hw + 1):clip(m), P.wood.deep)
  c:px(cx + hw - 2, base - floor(h / 2) + 1, P.gold.hi)
  R(cx - hw - 1, base, cx - hw + w, base, P.stone.shade)
end
local function sign(x, y, bx, icon)
  -- bracket from wall at (bx, y-2) to sign; board 9x8 hanging under
  R(min(bx, x), y - 3, max(bx, x + 8), y - 3, P.wood.deep)
  c:px(x + 1, y - 2, P.wood.deep) c:px(x + 7, y - 2, P.wood.deep)
  local b = c:rect(x, y - 1, x + 8, y + 7)
  c:rim(b, P.wood.deep)
  c:fillMask(b, P.wood.hi) R(x + 8, y - 1, x + 8, y + 7, P.wood.base) R(x, y + 7, x + 8, y + 7, P.wood.base)
  c:paint(icon.rows, x + 1, y, icon.map)
end
local ICON = {
  jug = { rows = {
    "...cc..",
    "...kk..",
    "..gggs.",
    ".gGgggs",
    ".gGgg.s",
    ".gggg.s",
    "..sss..",
  }, map = { c = "wood.deep", k = "cream", g = "gold.base", G = "gold.hi", s = "gold.shade" } },
  pie = { rows = {
    ".......",
    "..hhh..",
    ".hbhbh.",
    "hbhbhbh",
    "rrrrrrr",
    ".sssss.",
    ".......",
  }, map = { h = "gold.hi", b = "gold.shade", r = "ember.base", s = "wood.base" } },
  mug = { rows = {
    ".kkk...",
    "kkkkk..",
    "gGggg..",
    "gGgggss",
    "gGggg.s",
    "ggggsss",
    ".sss...",
  }, map = { k = "cream", g = "gold.base", G = "gold.hi", s = "gold.shade" } },
  herb = { rows = {
    "l.l.l..",
    ".lml.l.",
    "..mlm..",
    "..eee..",
    "..mlm..",
    "..m.m..",
    ".m...m.",
  }, map = { l = "moss.base", m = "moss.shade", e = "ember.base" } },
  pumpkin = { rows = {
    "...m...",
    "..m....",
    ".hgggs.",
    "hgsgsgs",
    "ggsgsgs",
    ".gsgss.",
    "..sss..",
  }, map = { m = "moss.shade", h = "gold.hi", g = "gold.base", s = "gold.shade" } },
}
local function timbers(x0, y0, x1, y1, ramp, diag)
  R(x0, y0, x1, y0, ramp) R(x0, y1, x1, y1, ramp)
  for x = x0, x1, 6 do R(x, y0, x, y1, ramp) end
  R(x1, y0, x1, y1, ramp)
  if diag then
    for x = x0, x1 - 6, 12 do
      for i = 0, min(5, y1 - y0) do c:px(x + i, y1 - floor(i * (y1 - y0) / 6), ramp) end
    end
  end
end

-- B: generic timber-frame shop. side = 1 shows right side wall (left buildings), -1 left side wall.
local function building(o)
  local x0, x1, base, g, u, peak, lean, ov = o.x0, o.x1, o.base, o.g, o.u, o.peak, o.lean or 0, o.ov or 2
  local function L(y) return floor(lean * (base - y) / (base - peak) + .5) end
  local low = c:poly{ { x0, base + 1 }, { x1 + 1, base + 1 }, { x1 + 1 + L(g), g }, { x0 + L(g), g } }
  local up = c:poly{ { x0 - ov + L(g), g }, { x1 + 1 + ov + L(g), g }, { x1 + 1 + ov + L(u), u }, { x0 - ov + L(u), u } }
  local ex0, ex1 = x0 - ov - 3 + L(u), x1 + 1 + ov + 3 + L(u)
  local roof = c:poly{ { ex0, u + 1 }, { ex1, u + 1 }, { x1 - 3 + L(peak), peak }, { x0 + 4 + L(peak), peak } }
  local s = o.side
  local ex = s == 1 and ex1 or ex0
  local px = s == 1 and (x1 - 3 + L(peak)) or (x0 + 4 + L(peak))
  local wx = s == 1 and (x1 + 1 + ov + L(u)) or (x0 - ov + L(u))
  local bx = s == 1 and (x1 + 1) or x0
  local t = o.t or .14
  local A, Bp = { bx, base + 1 }, { wx, u + 1 }
  local A2, B2 = toVP(A, t), toVP(Bp, t)
  local sideW = c:poly{ A, Bp, B2, A2 }
  local Ep, Pp = { ex, u + 1 }, { px, peak }
  local E2, P2 = toVP(Ep, t), toVP(Pp, t)
  local sideR = c:poly{ Ep, Pp, P2, E2 }
  local all = low:copy():add(up):add(roof):add(sideW):add(sideR)
  -- chimney
  local ch
  if o.chim then
    local cx = o.chim
    ch = c:rect(cx, peak - 7, cx + 4, peak + 3)
    all:add(ch)
  end
  c:rim(all, o.edge or P.wood.deep)
  c:fillMask(sideW, P.dusk.hi)
  timbers(min(floor(A[1]), floor(A2[1])), floor(B2[2]) + 1, max(floor(A[1]), floor(A2[1])), base, P.dusk.base)
  c:fillMask(sideW:copy():cut(c:rect(0, 0, 239, floor(A2[2]))), P.dusk.hi)
  sideW:each(function(x, y) if (y - floor(Bp[2])) % 6 == 0 then c:px(x, y, P.dusk.base) end end)
  shingles(sideR, o.roof, false, peak, 2)
  c:fillMask(low, o.wall.lit)
  c:fillMask(up, o.wall.up or o.wall.lit)
  -- shade at the right of lit walls (light from upper-left)
  c:fillMask(low:copy():cut(low:copy():shift(-2, 0)), o.wall.sh)
  c:fillMask(up:copy():cut(up:copy():shift(-2, 0)), o.wall.sh)
  -- overhang shadow under the jetty
  R(x0 + L(g), g + 1, x1 + L(g), g + 1, o.wall.sh)
  if o.frame ~= false then
    timbers(x0 - ov + L(g), u + 1, x1 + ov + L(g), g, o.beam, true)
    R(x0 - ov + L(g), g, x1 + 1 + ov + L(g), g, P.wood.deep)
    R(x0 + L(g), g + 2, x0 + L(g), base, o.beam) R(x1 + L(g), g + 2, x1 + L(g), base, o.beam)
  end
  shingles(roof, o.roof, true, peak, 1)
  R(ex0, u + 1, ex1, u + 1, o.roof.deep)
  c:fillMask(roof:copy():cut(roof:copy():shift(1, 1)):clip(c:rect(0, peak, 239, peak + 1)), o.roof.hi)
  if ch then
    c:fillMask(ch, P.stone.base) R(ch:bbox(), peak - 7, ch:bbox(), peak + 3, P.stone.hi)
    local cx = o.chim
    R(cx + 4, peak - 7, cx + 4, peak + 3, P.stone.shade) R(cx, peak - 7, cx + 4, peak - 7, P.stone.deep)
    for y = peak - 5, peak + 2, 3 do R(cx, y, cx + 4, y, P.stone.shade) end
  end
  return { low = low, up = up, roof = roof, L = L, all = all }
end

local PLASTER = { lit = P.cream, sh = P.gold.hi }

------------------------------------------------------------ FAR houses filling the gaps beside the hall
for _, f in ipairs{ { 100, 108, 59, 44 }, { 133, 141, 59, 45 } } do
  local w = c:rect(f[1], f[4] + 6, f[2], f[3]) local r = c:poly{ { f[1] - 1, f[4] + 6 }, { f[2] + 2, f[4] + 6 }, { (f[1] + f[2]) / 2 + .5, f[4] } }
  c:rim(w:copy():add(r), P.wood.deep)
  c:fillMask(w, P.petal.hi) c:fillMask(r, P.ember.shade)
  R(f[1] + 2, f[4] + 9, f[1] + 3, f[4] + 10, P.gold.hi)
end

------------------------------------------------------------ HALL (far centre) with clock tower
do
  local base = 58
  local body = c:rect(106, 36, 134, base)
  local ped = c:poly{ { 103, 37 }, { 137, 37 }, { 120, 28 } }
  local tower = c:rect(114, 14, 126, 30)
  local belfry = c:rect(115, 9, 125, 14)
  local spire = c:poly{ { 113, 10 }, { 127, 10 }, { 120, -1 } }
  local all = body:copy():add(ped):add(tower):add(belfry):add(spire)
  c:rim(all, P.wood.deep)
  -- brick-red walls with stone quoins
  c:fillMask(body, P.ember.base)
  for y = 37, base, 2 do for x = 106 + ((y // 2) % 2) * 2, 134, 4 do c:px(x, y, P.ember.shade) end end
  R(133, 36, 134, base, P.ember.shade)
  for y = 36, base - 1, 3 do R(106, y, 107, y + 1, P.stone.hi) R(133, y, 134, y + 1, P.stone.base) end
  shingles(ped, P.dusk, true, 28, 4)
  R(103, 37, 137, 37, P.dusk.deep)
  c:fillMask(tower, P.cream) R(125, 14, 126, 30, P.gold.hi) R(114, 14, 114, 30, P.stone.hi)
  c:fillMask(belfry, P.wood.deep) R(117, 10, 118, 14, P.gold.base) R(122, 10, 123, 14, P.gold.base)
  c:part(c:rect(116, 11, 117, 13), "gold", { band = 1, nopop = true })
  shingles(spire, P.dusk, true, -1, 5)
  c:px(120, -1, P.gold.hi)
  -- clock face
  local cf = E(120, 21, 4, 4)
  c:rim(cf, P.gold.shade) c:fillMask(cf, P.cream) c:px(119, 19, P.gold.hi)
  R(120, 18, 120, 21, P.wood.deep) R(121, 21, 122, 21, P.wood.deep) c:px(120, 21, P.ember.base)
  -- double arched door on the dot (120,52)
  door(120, base, 10, 13, P.wood)
  R(120, 46, 120, base - 1, P.wood.deep)
  R(116, 44, 124, 44, P.stone.hi)
  -- windows
  for _, x in ipairs{ 108, 128 } do window(x, 41, 4, 6, false) end
  for _, x in ipairs{ 108, 128 } do window(x, 50, 4, 5, false) end
  -- steps
  R(112, 58, 128, 58, P.stone.hi) R(110, 59, 130, 59, P.stone.base) R(110, 59, 130, 59, P.stone.base)
  -- banners: maple leaves
  for _, x in ipairs{ 111, 128 } do R(x, 38, x + 1, 39, P.gold.base) end
end

------------------------------------------------------------ TAVERN (dot 94,62)
do
  local b = building{ x0 = 82, x1 = 104, base = 68, g = 54, u = 40, peak = 26, lean = -1, ov = 2, side = 1, t = .2,
    wall = { lit = P.petal.hi, sh = P.petal.base, up = P.cream }, beam = P.wood.shade, roof = P.wood, chim = 86 }
  window(84, 44, 5, 6, true) window(97, 44, 5, 6, true)
  window(84, 58, 4, 5, false)
  door(94, 68, 8, 12)
  sign(99, 57, 104, ICON.mug)
  -- barrel by the door
  local br = c:rrect(85, 64, 89, 68, 1) c:rim(br, P.wood.deep) c:part(br, "wood", { band = 1, nopop = true })
  R(85, 66, 89, 66, P.stone.shade)
end

------------------------------------------------------------ STALLS row (dot 148,64): striped awnings + crates
do
  -- backdrop: low barn front
  local bk = c:rect(136, 44, 164, 62) local br = c:poly{ { 134, 45 }, { 166, 45 }, { 150, 34 } }
  c:rim(bk:copy():add(br), P.wood.deep)
  c:fillMask(bk, P.ember.shade) for x = 137, 164, 3 do R(x, 45, x, 62, P.ember.deep) end
  shingles(br, P.wood, true, 34, 9)
  local cols = { { P.ember.base, P.cream }, { P.gold.base, P.cream }, { P.ember.shade, P.gold.hi } }
  for i, sx in ipairs{ 136, 145, 154 } do
    local aw = c:poly{ { sx - 1, 55 }, { sx + 10, 55 }, { sx + 9, 51 }, { sx, 51 } }
    local post = c:rect(sx, 55, sx, 70):add(c:rect(sx + 9, 55, sx + 9, 70))
    local ctr = c:rect(sx, 63, sx + 9, 70)
    c:rim(aw:copy():add(post):add(ctr), P.wood.deep)
    c:fillMask(post, P.wood.shade)
    aw:each(function(x, y) c:px(x, y, ((x - sx) // 2) % 2 == 0 and cols[i][1] or cols[i][2]) end)
    for x = sx - 1, sx + 10, 2 do c:px(x, 56, cols[i][1]) end
    c:fillMask(ctr, P.wood.base) R(sx, 63, sx + 9, 63, P.wood.hi) R(sx, 67, sx + 9, 67, P.wood.shade) R(sx + 9, 63, sx + 9, 70, P.wood.shade)
    -- goods on the counter
    if i == 1 then for k = 0, 3 do local x = sx + 1 + k * 2 c:px(x, 62, P.ember.base) c:px(x + 1, 62, P.ember.shade) c:px(x, 61, P.ember.hi) end
      c:px(sx + 3, 60, P.ember.base) c:px(sx + 5, 60, P.ember.base) c:px(sx + 3, 59, P.ember.hi)
    elseif i == 2 then for k = 0, 2 do local x = sx + 1 + k * 3 R(x, 59, x + 1, 62, P.gold.shade) c:px(x, 59, P.gold.hi) R(x, 60, x + 1, 60, P.cream) end
    else c:fillMask(E(sx + 3, 61, 2, 1), P.gold.base) c:px(sx + 2, 60, P.gold.hi) c:px(sx + 3, 59, P.moss.shade)
      c:fillMask(E(sx + 7, 61, 1, 1), P.ember.hi) end
    for x = sx + 1, sx + 8, 3 do c:px(x, 65, P.wood.shade) end
  end
end

------------------------------------------------------------ BAKERY (dot 66,68)
do
  building{ x0 = 52, x1 = 79, base = 75, g = 58, u = 40, peak = 20, lean = 2, ov = 2, side = 1, t = .2,
    wall = PLASTER, beam = P.wood.shade, roof = P.ember, chim = 70 }
  window(55, 44, 6, 7, true) window(70, 44, 6, 7, true)
  -- shop window with pies
  local sw = c:rect(54, 63, 59, 70) c:rim(sw, P.wood.deep) c:fillMask(sw, P.gold.hi)
  for _, y in ipairs{ 65, 69 } do R(54, y, 59, y, P.wood.shade) R(55, y - 1, 58, y - 1, P.gold.shade) c:px(56, y - 1, P.ember.base) end
  door(66, 75, 8, 13)
  sign(71, 61, 79, ICON.pie)
  -- flower box under shop window
  R(53, 72, 60, 73, P.wood.shade) for x = 53, 60, 2 do c:px(x, 71, P.petal.base) c:px(x + 1, 71, P.moss.shade) end
end

------------------------------------------------------------ STORE (dot 176,69)
do
  building{ x0 = 163, x1 = 190, base = 76, g = 59, u = 41, peak = 21, lean = -2, ov = 2, side = -1, t = .2,
    wall = { lit = P.gold.hi, sh = P.gold.base, up = P.cream }, beam = P.wood.deep, roof = P.moss, chim = 182 }
  window(165, 45, 6, 7, true) window(181, 45, 6, 7, true)
  local sw = c:rect(183, 64, 188, 71) c:rim(sw, P.wood.deep) c:fillMask(sw, P.gold.base) R(183, 64, 185, 66, P.gold.hi) R(183, 68, 188, 68, P.wood.deep)
  door(176, 76, 8, 13)
  sign(163, 61, 163, ICON.pumpkin)
  -- crates of apples + pumpkins out front (left of door, off the stand)
  for i, x in ipairs{ 166, 186 } do
    local cr = c:rect(x, 72, x + 5, 76)
    c:rim(cr, P.wood.deep) c:fillMask(cr, P.wood.base) R(x, 74, x + 5, 74, P.wood.shade)
    for k = 0, 2 do local ax = x + k * 2 c:px(ax, 71, i == 1 and P.ember.base or P.gold.base) c:px(ax + 1, 71, i == 1 and P.ember.shade or P.gold.shade) end
  end
end

------------------------------------------------------------ SUGAR SHACK (dot 32,75): red board-and-batten, steam cupola
do
  local base, x0, x1 = 82, 20, 50
  local wall = c:poly{ { x0, base + 1 }, { x1 + 1, base + 1 }, { x1 + 2, 50 }, { x0 + 1, 50 } }
  local gable = c:poly{ { x0 - 3, 51 }, { x1 + 5, 51 }, { 36, 20 } }
  local A, Bp = { x1 + 1, base + 1 }, { x1 + 2, 51 }
  local A2, B2 = toVP(A, .12), toVP(Bp, .12)
  local side = c:poly{ A, Bp, B2, A2 }
  local Pk = { 36, 20 }
  local P2, E2 = toVP(Pk, .12), toVP({ x1 + 5, 51 }, .12)
  local sroof = c:poly{ { x1 + 5, 51 }, Pk, P2, E2 }
  local cup = c:rect(32, 12, 40, 22) local cupr = c:poly{ { 30, 13 }, { 42, 13 }, { 36, 8 } }
  local all = wall:copy():add(gable):add(side):add(sroof):add(cup):add(cupr)
  c:rim(all, P.ember.deep)
  c:fillMask(side, P.dusk.base) side:each(function(x, y) if y % 4 == 0 then c:px(x, y, P.dusk.shade) end end)
  shingles(sroof, P.wood, false, 20, 3)
  -- board-and-batten walls (lit left, crimson shade right)
  wall:each(function(x, y)
    local col = x < 40 and P.ember.base or P.ember.shade
    if (x - x0) % 4 == 0 then col = x < 40 and P.ember.shade or P.ember.deep end
    if x <= x0 + 1 and (x - x0) % 4 ~= 0 then col = P.ember.hi end
    c:px(x, y, col)
  end)
  -- big shingle gable roof
  shingles(gable, P.wood, true, 20, 6)
  gable:each(function(x, y) if x > 36 + (y - 20) * .3 and (y - 20) % 3 ~= 2 then c:px(x, y, P.wood.shade) end end)
  R(x0 - 3, 51, x1 + 5, 51, P.wood.deep)
  -- steam cupola
  c:fillMask(cup, P.ember.shade) R(32, 12, 33, 22, P.ember.base)
  for x = 34, 39, 2 do R(x, 15, x, 19, P.wood.deep) end
  shingles(cupr, P.wood, true, 8, 8)
  -- loft hatch + lit window
  window(33, 37, 5, 6, false)
  window(42, 58, 5, 6, true)
  window(22, 58, 4, 6, false)
  -- wide double door on the dot (32,75)
  door(32, base, 10, 14, P.wood)
  R(32, 69, 32, base - 1, P.wood.deep)
  -- syrup jug sign on bracket
  sign(40, 66, 51, ICON.jug)
  -- woodpile for the evaporator fire (left)
  for k = 0, 2 do for j = 0, 2 - k do
    local lx, ly = 13 + j * 3 + k, 80 - k * 2
    c:px(lx, ly, P.wood.base) c:px(lx + 1, ly, P.wood.shade) c:px(lx, ly - 1, P.wood.hi) c:px(lx + 1, ly - 1, P.gold.hi)
  end end
end

------------------------------------------------------------ HERBALIST GUILD (dot 208,75)
do
  building{ x0 = 194, x1 = 224, base = 82, g = 63, u = 44, peak = 22, lean = 2, ov = 2, side = -1, t = .14,
    wall = { lit = P.moss.hi, sh = P.moss.base, up = P.cream }, beam = P.moss.deep, roof = P.dusk, chim = 214 }
  window(197, 48, 6, 8, true) window(214, 48, 6, 8, true)
  window(216, 68, 5, 6, true)
  door(208, 82, 9, 14, P.moss)
  sign(195, 66, 194, ICON.herb)
  -- drying herb bundles under the jetty
  for _, x in ipairs{ 200, 218 } do c:px(x, 64, P.wood.deep) c:px(x, 65, P.ember.base) R(x - 1, 66, x + 1, 67, P.moss.shade) c:px(x, 68, P.moss.base) end
end

------------------------------------------------------------ bunting strung between the shops (high, off the street)
local LEAFC = { P.ember.base, P.gold.base, P.gold.shade, P.ember.shade }
local function leafFlag(x, y, col)
  c:px(x, y, col) c:px(x - 1, y + 1, col) c:px(x, y + 1, col) c:px(x + 1, y + 1, col) c:px(x, y + 2, col)
  c:px(x - 1, y, col) c:px(x + 1, y, col)
end
local function bunting(x0, y0, x1, y1, sag, every)
  local n = floor(abs(x1 - x0))
  for i = 0, n do
    local t = i / n
    local x = floor(x0 + (x1 - x0) * t + .5)
    local y = floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) + .5)
    c:px(x, y, P.wood.deep)
    if i % every == every // 2 and i > 1 and i < n - 1 then leafFlag(x, y + 1, LEAFC[1 + (i // every) % 4]) end
  end
end
bunting(80, 42, 54, 38, 4, 5)
bunting(162, 40, 141, 46, 3, 5)
bunting(104, 42, 112, 37, 1, 4)

------------------------------------------------------------ PLAZA: syrup fountain (dot 120,95)
do
  c:groundShadow(121, 102, 13, 3)
  local basin = c:rrect(109, 93, 131, 101, 3)
  local water = c:rrect(111, 93, 129, 96, 1)
  local ped = c:rect(118, 84, 122, 93)
  local bowl = c:poly{ { 113, 85 }, { 127, 85 }, { 124, 88 }, { 116, 88 } }
  local barrel = c:rrect(116, 76, 124, 84, 2)
  local all = basin:copy():add(ped):add(bowl):add(barrel)
  c:rim(all, P.stone.deep)
  c:fillMask(basin, P.stone.base)
  for x = 109, 131, 4 do R(x, 97, x, 101, P.stone.shade) end
  R(109, 97, 131, 97, P.stone.shade) R(110, 93, 130, 93, P.stone.hi) R(130, 94, 131, 101, P.stone.shade)
  c:fillMask(water, P.gold.shade) R(112, 94, 116, 94, P.gold.base) c:px(124, 95, P.gold.hi)
  c:fillMask(ped, P.stone.hi) R(121, 84, 122, 92, P.stone.base)
  c:fillMask(bowl, P.stone.base) R(113, 85, 127, 85, P.stone.hi)
  -- syrup barrel on top, hoops, spout pouring amber syrup
  c:part(barrel, "wood", { band = 2, pop = { 117, 77 } })
  R(116, 78, 124, 78, P.stone.shade) R(116, 82, 124, 82, P.stone.shade)
  R(125, 80, 126, 80, P.stone.base)
  R(127, 81, 127, 87, P.gold.shade) c:px(127, 82, P.gold.hi)
  R(114, 89, 114, 92, P.gold.shade)
  c:px(113, 88, P.gold.base)
  -- maple leaf on the barrel lid
  leafFlag(120, 75, P.ember.base)
end

------------------------------------------------------------ lamp posts with hanging lanterns (plaza edge)
for _, l in ipairs{ { 104, 66 }, { 138, 70 } } do
  local x, y = l[1], l[2]
  local post = c:rect(x, y - 12, x, y):add(c:rect(x, y - 12, x + 3, y - 12))
  c:rim(post, P.wood.deep, nil) c:fillMask(post, P.wood.shade)
  local ln = c:rect(x + 2, y - 10, x + 4, y - 7)
  c:rim(ln, P.wood.deep) c:fillMask(ln, P.gold.base) c:px(x + 2, y - 10, P.gold.hi)
end

------------------------------------------------------------ NOTICE BOARD (dot 66,107)
do
  c:groundShadow(66, 117, 11, 2)
  local posts = c:rect(57, 101, 58, 117):add(c:rect(74, 101, 75, 117))
  local board = c:rect(58, 101, 74, 113)
  local roof = c:poly{ { 55, 102 }, { 78, 102 }, { 72, 97 }, { 61, 97 } }
  local all = posts:copy():add(board):add(roof)
  c:rim(all, P.ink)
  c:fillMask(posts, P.wood.shade) R(57, 101, 57, 117, P.wood.base)
  c:fillMask(board, P.wood.base)
  for y = 101, 113, 3 do R(58, y, 74, y, P.wood.shade) end
  R(58, 100, 58, 113, P.wood.hi)
  shingles(roof, P.ember, true, 97, 11)
  R(55, 102, 78, 102, P.ember.deep)
  -- pinned papers, no text: blank notes with folded corners and pins
  local notes = { { 60, 104, 64, 109, P.cream, P.ember.base }, { 66, 104, 72, 107, P.sky.hi, P.gold.base }, { 66, 109, 70, 112, P.petal.hi, P.moss.base }, { 61, 110, 64, 112, P.gold.hi, P.dusk.base } }
  for _, n in ipairs(notes) do
    R(n[1], n[2], n[3], n[4], n[5])
    c:px(n[3], n[4], P.stone.hi) c:px(n[1], n[4], P.stone.hi)
    R(n[3], n[2] + 1, n[3], n[4], P.stone.hi)
    c:px(floor((n[1] + n[3]) / 2), n[2], n[6])
  end
  -- a pinned maple leaf (souvenir)
  leafFlag(72, 109, P.ember.base)
end

------------------------------------------------------------ ORCHARD (dot 186,109): gate arch + path into apple trees
do
  -- grass verge on the right foreground
  local verge = c:poly{ { 168, 135 }, { 162, 122 }, { 176, 100 }, { 205, 92 }, { 240, 88 }, { 240, 135 } }
  c:fillMask(verge, P.gold.shade)
  verge:each(function(x, y) local h = H(x, y, 13) if x >= 212 and y >= 108 then return end if h < .07 then c:px(x, y, P.ember.shade) elseif h < .12 then c:px(x, y, P.gold.base) end end)
  -- path through the gate into the orchard (dirt)
  local path = c:poly{ { 178, 122 }, { 194, 122 }, { 206, 100 }, { 200, 100 } }
  c:fillMask(path:clip(verge), P.wood.hi)
  -- apple trees behind the fence
  for _, t in ipairs{ { 209, 93, 8, 7 }, { 224, 97, 10, 8 }, { 236, 90, 8, 8 } } do
    local tr = c:rect(t[1] - 1, t[2] + 4, t[1] + 1, t[2] + t[4] + 4)
    local cr = E(t[1], t[2], t[3], t[4]):add(E(t[1] - t[3] * .5, t[2] + 2, t[3] * .6, t[4] * .6))
    c:rim(cr:copy():add(tr), P.moss.deep)
    c:fillMask(tr, P.wood.shade)
    c:part(cr, "moss", { band = 2, nopop = true })
    cr:each(function(x, y) local h = H(x, y, 21) if h < .1 then c:px(x, y, P.moss.hi) elseif h < .16 then c:px(x, y, P.gold.base) end end)
    for k = 0, 3 do local ax, ay = t[1] - t[3] + 3 + floor(H(k, t[1], 3) * (t[3] * 2 - 5)), t[2] - t[4] + 3 + floor(H(t[1], k, 4) * (t[4] * 2 - 4))
      c:px(ax, ay, P.ember.base) c:px(ax + 1, ay, P.ember.shade) c:px(ax, ay - 1, P.ember.hi) end
  end
  -- fence (stops before the compass corner)
  local fence = HP.mask()
  for x = 196, 213, 4 do fence:add(c:rect(x, 104, x + 1, 112)) end
  fence:add(c:rect(196, 106, 213, 106)):add(c:rect(196, 109, 213, 109))
  -- gate arch: two posts + curved top hung with apple leaves
  local posts = c:rect(176, 101, 178, 121):add(c:rect(194, 101, 196, 121))
  local arch = c:line({ { 176, 102 }, { 180, 100 }, { 186, 99 }, { 192, 100 }, { 196, 102 } }, 2)
  local gate = c:poly{ { 179, 108 }, { 186, 109 }, { 186, 120 }, { 179, 121 } }
  local all = fence:copy():add(posts):add(arch):add(gate)
  c:rim(all, P.ink)
  c:fillMask(fence, P.wood.base) for x = 197, 213, 4 do R(x, 104, x, 112, P.wood.shade) end
  c:fillMask(posts, P.wood.base) R(178, 101, 178, 121, P.wood.shade) R(196, 101, 196, 121, P.wood.shade) R(176, 101, 176, 121, P.wood.hi) R(194, 101, 194, 121, P.wood.hi)
  c:fillMask(arch, P.wood.shade) for _, p in ipairs{ { 180, 99 }, { 186, 98 }, { 192, 99 } } do c:px(p[1], p[2], P.wood.hi) end
  -- vine leaves + apples on the arch
  for i, p in ipairs{ { 177, 100 }, { 181, 98 }, { 185, 97 }, { 189, 97 }, { 193, 98 }, { 196, 100 } } do
    c:px(p[1], p[2], P.moss.base) c:px(p[1] + 1, p[2], P.moss.shade)
    if i % 2 == 0 then c:px(p[1], p[2] + 3, P.ember.base) c:px(p[1], p[2] + 2, P.moss.shade) end
  end
  -- gate leaf swung half open (inward)
  c:fillMask(gate, P.wood.hi) R(179, 112, 186, 112, P.wood.shade) R(179, 117, 186, 117, P.wood.shade) R(182, 109, 182, 120, P.wood.base)
  -- basket of apples by the post (left of gate, foreground)
  local bs = c:rrect(169, 116, 174, 121, 1) c:rim(bs, P.wood.deep) c:fillMask(bs, P.gold.shade)
  for x = 169, 174, 2 do R(x, 117, x, 121, P.wood.base) end
  c:px(170, 115, P.ember.base) c:px(172, 115, P.ember.base) c:px(171, 114, P.ember.hi) c:px(173, 115, P.ember.shade)
end

------------------------------------------------------------ LEFT foreground: leaf piles, pumpkins, barrels
do
  local verge = c:poly{ { 0, 135 }, { 0, 84 }, { 52, 84 }, { 66, 92 }, { 56, 135 } }
  verge:cut(c:ellipse(120, 96, 64, 20)):cut(c:poly{ { 70, 135 }, { 170, 135 }, { 125, 56 }, { 115, 56 } })
  c:fillMask(verge, P.gold.shade)
  verge:each(function(x, y) local h = H(x, y, 17) if h < .07 then c:px(x, y, P.ember.shade) elseif h < .12 then c:px(x, y, P.gold.base) end end)
  -- leaf pile (speckled crimson/orange/gold)
  local pile = E(28, 124, 15, 6):add(E(38, 127, 9, 5))
  c:rim(pile, P.ember.deep)
  c:fillMask(pile, P.ember.base)
  pile:each(function(x, y)
    local h = H(x, y, 23)
    local v = (x - 28) / 15 + (y - 124) / 6
    if v > .9 then c:px(x, y, P.ember.shade) elseif v < -.8 then c:px(x, y, P.gold.hi) end
    if h < .14 then c:px(x, y, P.gold.base) elseif h < .24 then c:px(x, y, P.gold.shade) elseif h < .3 then c:px(x, y, P.ember.hi) end
  end)
  -- pumpkins
  for i, p in ipairs{ { 46, 116, 4, 3 }, { 40, 113, 3, 2 }, { 18, 104, 4, 3 } } do
    local m = E(p[1], p[2], p[3], p[4])
    c:rim(m, P.gold.deep) c:part(m, "gold", { band = 2, pop = { p[1] - p[3] + 1, p[2] - 1 } })
    for x = p[1] - p[3] + 2, p[1] + p[3] - 1, 2 do c:fillMask(c:rect(x, p[2] - p[4] + 1, x, p[2] + p[4] - 1):clip(m), P.gold.shade) end
    c:px(p[1], p[2] - p[4] - 1, P.moss.shade)
  end
  -- barrels of syrup tins by the shack
  for _, bx in ipairs{ 26, 34 } do
    local b = c:rrect(bx, 88, bx + 6, 97, 2)
    c:rim(b, P.wood.deep) c:part(b, "wood", { band = 2, pop = { bx + 1, 89 } })
    R(bx, 90, bx + 6, 90, P.stone.shade) R(bx, 95, bx + 6, 95, P.stone.shade)
  end
  for k = 0, 2 do local x = 27 + k * 4 R(x, 85, x + 2, 87, P.gold.shade) R(x, 85, x + 2, 85, P.stone.hi) c:px(x, 86, P.gold.hi) end
end

------------------------------------------------------------ NEAR: sap-bucket maple (left), behind the gate pillar
do
  local tr = c:poly{ { 11, 100 }, { 19, 100 }, { 17, 40 }, { 13, 40 } }
  local br = c:line({ { 15, 44 }, { 24, 32 }, { 30, 26 } }, 2)
  local cr = maple(24, 22, 16, 12, 1.1)
  c:rim(tr:copy():add(br):add(cr), P.ember.deep)
  c:fillMask(tr, P.wood.shade) c:fillMask(br, P.wood.shade)
  for y = 42, 99, 3 do c:px(14 + (y % 2), y, P.wood.deep) c:px(16, y + 1, P.wood.base) end
  R(12, 40, 12, 99, P.wood.base)
  c:fillMask(cr, P.ember.base)
  cr:each(function(x, y)
    local v = (x - 24) / 16 + (y - 22) / 12 * 1.2
    if v < -.6 then c:px(x, y, P.gold.base) elseif v < 0 then c:px(x, y, P.ember.hi) elseif v > 1 then c:px(x, y, P.ember.shade) end
    local h = H(x, y, 31)
    if h < .1 then c:px(x, y, P.gold.hi) elseif h < .16 then c:px(x, y, P.ember.shade) elseif h < .19 then c:px(x, y, P.dusk.base) end
  end)
  -- sap bucket on a spile, lid
  c:px(19, 70, P.stone.shade) c:px(20, 70, P.stone.shade)
  local bk = c:poly{ { 19, 72 }, { 25, 72 }, { 24, 79 }, { 20, 79 } }
  c:rim(bk, P.stone.deep) c:fillMask(bk, P.stone.base) R(19, 72, 20, 79, P.stone.hi) R(24, 72, 25, 79, P.stone.shade)
  R(18, 71, 26, 71, P.stone.shade) c:px(22, 74, P.gold.base)
  c:px(21, 71, P.gold.shade) -- a drip
end

------------------------------------------------------------ QUIRK: the shack's steam puff has cat ears
do
  local puff = E(39, 4, 3, 2):add(E(44, 3, 4, 3))
  c:fillMask(E(35, 9, 2, 1), P.stone.hi) c:fillMask(puff, P.cream)
  c:px(41, -1, P.cream) c:px(41, 0, P.cream) c:px(47, -1, P.cream) c:px(47, 0, P.cream)
  c:px(42, 3, P.stone.base) c:px(45, 3, P.stone.base) c:px(43, 5, P.petal.hi) c:px(44, 5, P.petal.hi)
end

------------------------------------------------------------ falling leaves (off the street centre + stand points)
local stands = { { 98, 85 }, { 143, 83 }, { 84, 108 }, { 150, 113 }, { 60, 93 }, { 190, 93 } }
local function clearOf(x, y)
  for _, s in ipairs(stands) do if abs(x - s[1]) < 10 and abs(y - s[2]) < 10 then return false end end
  if y > 56 and abs(x - 120) < 30 + (y - 56) * .5 then return false end
  if x >= 210 and y >= 108 then return false end
  return true
end
for _, l in ipairs{ { 70, 30 }, { 96, 14 }, { 148, 30 }, { 186, 12 }, { 205, 38 }, { 60, 50 }, { 150, 46 }, { 88, 34 }, { 200, 58 }, { 50, 64 }, { 172, 34 }, { 66, 86 }, { 40, 108 }, { 158, 92 }, { 108, 30 }, { 130, 6 } } do
  if clearOf(l[1], l[2]) then
    local col = LEAFC[1 + (l[1] + l[2]) % 4]
    c:px(l[1], l[2], col) c:px(l[1] + 1, l[2], col) c:px(l[1], l[2] + 1, col) c:px(l[1] + 1, l[2] - 1, P.gold.hi)
  end
end

------------------------------------------------------------ NEAR: stone-and-timber entrance arch (ink edge)
do
  local pl = c:rect(0, 0, 9, 134)
  local pr = c:rect(230, 0, 239, 134)
  local beam = c:rect(0, 0, 239, 6)
  local cap = c:rect(0, 0, 239, 2)
  local kl = c:poly{ { 10, 7 }, { 26, 7 }, { 26, 9 }, { 12, 21 }, { 10, 21 } }
  local kr = c:poly{ { 229, 7 }, { 213, 7 }, { 213, 9 }, { 227, 21 }, { 229, 21 } }
  local all = pl:copy():add(pr):add(beam):add(kl):add(kr)
  c:rim(all, P.ink)
  -- pillars: stone blocks, lit left; the right pillar goes plain under y 108 (compass corner)
  local function stones(m, lit)
    c:fillMask(m, lit and P.stone.base or P.stone.shade)
    local x0, y0, x1, y1 = m:bbox()
    for y = y0 + 8, y1, 6 do
      local k = (y // 6) % 2
      for x = x0, x1 do
        if lit or y < 106 then c:px(x, y, lit and P.stone.shade or P.stone.deep) end
      end
      local jx = x0 + 3 + k * 3
      for yy = y + 1, min(y + 5, y1) do if lit or yy < 106 then c:px(jx, yy, lit and P.stone.shade or P.stone.deep) end end
      if lit then R(x0, y + 1, x0 + 1, min(y + 5, y1), P.stone.hi) end
    end
  end
  stones(pl, true) stones(pr, false)
  R(230, 8, 230, 105, P.stone.base)
  -- timber beam with shingle cap
  c:fillMask(beam, P.wood.base)
  for x = 0, 239 do if H(x, 4, 41) < .2 then c:px(x, 4, P.wood.shade) end end
  R(0, 6, 239, 6, P.wood.shade) R(0, 3, 239, 3, P.wood.hi)
  shingles(cap, P.ember, true, 0, 43)
  c:fillMask(kl, P.wood.base) c:fillMask(kr, P.wood.shade)
  for _, s in ipairs{ { 16, 10 }, { 223, 10 } } do c:px(s[1], s[2], P.wood.deep) end
  -- maple-leaf bunting along the arch
  bunting(10, 7, 120, 7, 9, 7)
  bunting(120, 7, 229, 7, 9, 7)
  -- hanging lantern (top-left corner)
  R(20, 7, 20, 13, P.wood.deep)
  local ln = c:rrect(18, 14, 22, 21, 1)
  local top = c:rect(17, 13, 23, 13)
  c:rim(ln:copy():add(top), P.ink)
  c:fillMask(top, P.wood.shade) c:fillMask(ln, P.gold.base)
  R(19, 15, 19, 19, P.gold.hi) c:px(19, 15, P.cream) R(22, 15, 22, 20, P.gold.shade) R(18, 21, 22, 21, P.wood.shade)
  -- tiny maple leaf on the right pillar plaque
  leafFlag(234, 40, P.ember.base) c:px(234, 43, P.wood.deep)
end

c:finish{ outline = false }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "here-market-maplewold.aseprite", png = out .. "here-market-maplewold.png", scale = 2 }
