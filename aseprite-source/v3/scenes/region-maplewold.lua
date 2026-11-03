-- region-maplewold PASS B (final polish). Pass A = region-maplewold.pA.lua. 300x200 grid, x6 = 1800x1200; thumb x1.5.
-- Rebuilt after owner feedback ("old region art was full; do that in the new style").
-- Layout (6x4 cells of 50x50):
--  r0: birch canopies | birch canopy + geese | chimney smoke + cloud | balloon + cloud | maple canopy | maple canopy + squirrel
--  r1: birch trunks + hay | windmill on far hill + tree line + fence | COTTAGE (gnome waving at window) | cottage + chimney + logs |
--      maple canopy + stream source | maple trunk + hollow + owl
--  r2: pumpkin field + gnome carrying a pumpkin | scarecrow + crow | stone path + gnome raking leaves | footbridge + BEAR |
--      stream + sheep | roots + mushrooms
--  r3: big pumpkins | wheelbarrow + basket | path stones + fox | cattails + duck | pond + gnome fishing in a rowboat | beaver lodge
-- quirk: a bear in a tiny scarf fishing under the footbridge.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local NAME = app.params.name or "region-maplewold"
local c = HP.canvas{ w = 300, h = 200, scale = 6, name = "region-maplewold" }
local floor, sin, cos, abs, min, max = math.floor, math.sin, math.cos, math.abs, math.min, math.max
local INK = P.ink
local function E(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry or rx) end
local function Rm(x0, y0, x1, y1) return c:rect(x0, y0, x1, y1) end
local function fm(m, hex) c:fillMask(m, hex) return m end
local function hash(a, b) return ((a * 73856093) ~ (b * 19349663) ~ (a * b * 83492791)) % 1000 end
local function px(x, y, h) c:px(x, y, h) end

-- extra ramps (off-palette allowed)
local ORANGE = { hi = "#ffb85c", base = "#f0882e", shade = "#c95a26", deep = "#7a3423" }
local PUMP = { hi = "#ffc46b", base = "#f59a32", shade = "#d0632a", deep = "#7e3524" }
local BEARD = { hi = P.cream, base = P.stone.hi, shade = P.stone.base, deep = P.stone.shade }
local BEAR = { hi = "#c48a58", base = "#9a6038", shade = "#6e3f2a", deep = "#43261f" }
local BIRCH = { hi = P.cream, base = "#efe8dc", shade = P.stone.hi, deep = P.stone.base }
local WALL = { hi = P.cream, base = "#f6e2bc", shade = "#dcc09a", deep = "#a88a6e" }
local GRASS = { hi = "#b4dc6e", base = P.moss.base, shade = "#5aa856", deep = P.moss.shade }

-- my form painter: base, lit crescent (upper-left, offset l), shade crescent (lower-right, offset s), deep underside
local function form(m, R, o)
  o = o or {}
  fm(m, R.base)
  local s, l = o.s or 2, o.l
  local sh, lt, dp = {}, {}, {}
  m:each(function(x, y)
    if l and not m:has(x - l, y - l) then lt[#lt + 1] = { x, y } end
    if s > 0 and not m:has(x + s, y + s) then sh[#sh + 1] = { x, y } end
    if o.deep and not m:has(x, y + 1) then dp[#dp + 1] = { x, y } end
  end)
  for _, p in ipairs(lt) do px(p[1], p[2], R.hi) end
  for _, p in ipairs(sh) do px(p[1], p[2], R.shade) end
  for _, p in ipairs(dp) do px(p[1], p[2], R.deep) end
  if o.pop then px(o.pop[1], o.pop[2], o.popc or R.hi) px(o.pop[1] + 1, o.pop[2], o.popc or R.hi) end
  return m
end
local function rim(m, hex) return c:rim(m, hex or INK) end

------------------------------------------------------------------ FAR: sky, clouds, birds, hills
c:stripes(0, 66, { "#8cc8ee", P.sky.shade, P.sky.base, "#cdebf8" }, { 2, 3, 3, 3 })
c:cloud(68, 22, 30, P.cream, P.sky.hi)
c:cloud(106, 14, 18, P.cream, P.sky.hi)
c:cloud(196, 30, 24, P.cream, P.sky.hi)
c:cloud(150, 50, 20, P.cream, P.sky.hi)
c:cloud(4, 58, 22, P.cream, P.sky.hi)
c:cloud(118, 40, 14, P.sky.hi, P.sky.base)
-- geese V
for i, g in ipairs({ { 92, 30 }, { 98, 33 }, { 104, 36 }, { 98, 27 }, { 104, 24 }, { 186, 44 }, { 192, 47 }, { 140, 58 } }) do
  px(g[1] - 1, g[2], P.stone.deep) px(g[1], g[2] + 1, P.stone.deep) px(g[1] + 1, g[2], P.stone.deep)
end
-- blue far mountains (2 ranges)
local function mt1(x) return 42 + 7 * sin(x / 23 + 0.6) + 4 * sin(x / 9) - 8 * math.exp(-((x - 120) / 30) ^ 2) end
c:terrain(mt1, "#a9b8e6")
local function mt2(x) return 52 + 4 * sin(x / 17 + 2) + 2 * sin(x / 7) end
c:terrain(mt2, "#8b9fd6")
-- snow-ish highlights on the near range ridge
for x = 0, 299 do local y = floor(mt2(x) + .5) if (x // 3) % 4 == 0 then px(x, y, "#b9c6ee") end end
-- far autumn tree line (blobs with leaf speckle)
local function hillY(x) return 64 + 2 * sin(x / 13) + 1.5 * sin(x / 5) end
do
  local cols = { { "#f6b15a", "#e0823a" }, { "#ef6d4a", "#c94a3a" }, { "#f5c84a", "#d99a2e" }, { "#e88a3e", "#b9582f" } }
  local x, k = -4, 0
  while x < 306 do
    local r = 5 + hash(k, 2) % 5
    local pr = cols[k % 4 + 1]
    local cy = floor(hillY(x)) - r + 3
    local m = E(x, cy, r, r * 0.9)
    fm(m, pr[1])
    m:each(function(xx, yy) if not m:has(xx + 2, yy + 2) then px(xx, yy, pr[2]) end end)
    for i = 0, 6 do local sx, sy = x - r + hash(k, i) % (2 * r), cy - r + hash(i, k + 9) % (2 * r)
      if m:has(sx, sy) and m:has(sx + 1, sy) then px(sx, sy, pr[2]) px(sx + 1, sy, pr[2]) end end
    x = x + r + 2 + hash(k, 5) % 4
    k = k + 1
  end
end

-- windmill on a green knoll that rises above the tree line (r1 c1)
do
  local knoll = c:terrain(function(x) return 66 - 12 * math.exp(-((x - 84) / 16) ^ 2) end, "#9fcd64", 72, 56, 112)
  knoll:each(function(x, y) if not knoll:has(x, y - 1) then px(x, y, "#b8dd7a") end end)
  local tw = c:poly{ { 78, 38 }, { 88, 38 }, { 91, 58 }, { 75, 58 } }
  rim(tw, "#5e6a96")
  fm(tw, "#efe6d6") fm(c:poly{ { 85, 38 }, { 88, 38 }, { 91, 58 }, { 86, 58 } }, "#cfc3c0")
  for y = 42, 56, 4 do fm(Rm(76, y, 90, y):clip(tw), "#ddd2c8") end
  local cap = c:poly{ { 76, 39 }, { 83, 31 }, { 90, 39 } } rim(cap, "#5e6a96") fm(cap, P.ember.base)
  fm(c:poly{ { 83, 31 }, { 90, 39 }, { 84, 39 } }, P.ember.shade)
  local dr = Rm(81, 51, 84, 58) fm(dr, P.wood.shade) px(81, 51, P.wood.base)
  fm(Rm(81, 44, 84, 46), P.gold.base)
  for _, a in ipairs({ 0.35, 1.92, 3.49, 5.06 }) do
    local x2, y2 = 83 + 17 * cos(a), 38 + 17 * sin(a)
    local nx, ny = -sin(a), cos(a)
    local sail = c:poly{ { 83 + 4 * cos(a), 38 + 4 * sin(a) }, { x2, y2 }, { x2 + 4 * nx, y2 + 4 * ny }, { 83 + 4 * cos(a) + 4 * nx, 38 + 4 * sin(a) + 4 * ny } }
    fm(sail, "#f3ead8")
    c:edgeIn(sail, "#d2c4b4")
    fm(c:line({ { 83, 38 }, { x2, y2 } }, 1), P.wood.deep)
  end
  fm(E(83, 38, 1.5, 1.5), P.wood.deep)
end

------------------------------------------------------------------ GROUND
local function gy(x) return 66 + 2 * sin(x / 21) end
c:terrain(gy, "#a8d46a")
-- mid meadow band and near meadow (lighter far, deeper near)
c:terrain(function(x) return 82 + 3 * sin(x / 31 + 1) end, GRASS.base)
-- grass texture: tufts + blades + fallen leaves + tiny flowers
local LEAFC = { P.ember.base, ORANGE.base, P.gold.base, P.ember.shade }
for i = 0, 1400 do
  local x, y = hash(i, 3) % 300, 68 + hash(i, 7) % 132
  local here = c:get(x, y)
  if here == GRASS.base:lower() or here == "#a8d46a" then
    local far = here == "#a8d46a"
    local r = hash(i, 11) % 10
    if r < 5 then -- tuft
      local t = far and "#86c05a" or GRASS.shade
      px(x, y, t) px(x + 1, y - 1, t) px(x + 2, y, t)
      if not far and r < 2 then px(x + 1, y - 2, GRASS.hi) end
    elseif r < 8 then -- fallen leaf
      local lc = LEAFC[hash(i, 13) % 4 + 1] px(x, y, lc) px(x + 1, y, lc)
    elseif r == 8 then px(x, y, GRASS.hi) px(x, y + 1, GRASS.hi)
    else px(x, y, P.cream) px(x + 1, y, P.petal.hi) end
  end
end

------------------------------------------------------------------ STREAM (from under the maple to the pond)
local streamPts = { { 222, 86 }, { 214, 98 }, { 206, 112 }, { 204, 126 }, { 210, 140 }, { 216, 154 } }
local stream = c:line(streamPts, 7)
local pond = E(240, 182, 64, 24):add(E(200, 190, 34, 14)):add(E(290, 168, 22, 16))
local water = stream:copy():add(pond)
rim(water, P.wood.shade)
fm(water, P.sea.base)
-- depth band and ripples
water:each(function(x, y) if not water:has(x - 3, y - 3) then end end)
fm(E(246, 188, 46, 12):clip(water), "#4ea9c4")
fm(E(250, 192, 34, 8):clip(water), P.sea.shade)
water:each(function(x, y) if not water:has(x, y - 2) then px(x, y, "#3f9aa8") end end) -- bank reflection band
for i = 0, 160 do
  local x, y = hash(i, 21) % 300, 86 + hash(i, 23) % 114
  local w = 2 + hash(i, 25) % 4
  if water:has(x, y) and water:has(x + w, y) and water:has(x, y - 2) then
    fm(Rm(x, y, x + w, y), hash(i, 27) % 3 == 0 and P.sea.shade or P.sea.hi)
  end
end

------------------------------------------------------------------ PATH (cottage door -> bottom; branch to bridge)
local path = c:line({ { 136, 116 }, { 140, 132 }, { 136, 150 }, { 144, 172 }, { 158, 200 } }, 13)
path:add(c:line({ { 140, 126 }, { 168, 124 }, { 192, 124 } }, 8))
rim(path, "#c99a62")
fm(path, "#e7c58e")
path:each(function(x, y) if hash(x, y) % 17 == 0 then px(x, y, "#d4ad74") end end)
-- stepping stones
for i, s in ipairs({ { 135, 121, 4, 2 }, { 140, 129, 5, 2 }, { 137, 138, 5, 3 }, { 134, 147, 6, 3 }, { 139, 157, 6, 3 },
  { 144, 167, 7, 3 }, { 149, 178, 7, 4 }, { 155, 190, 8, 4 }, { 155, 124, 4, 2 }, { 167, 123, 4, 2 }, { 178, 124, 4, 2 } }) do
  local m = E(s[1], s[2], s[3], s[4])
  rim(m, "#7d6a62") form(m, P.stone, { s = 1, l = 1 })
end

------------------------------------------------------------------ PUMPKIN FIELD (left, ploughed rows)
local field = c:poly{ { -1, 118 }, { 92, 113 }, { 112, 200 }, { -1, 200 } }
rim(field, P.wood.deep)
do
  local rows, y = {}, 116
  while y < 205 do local h = 6 + floor((y - 116) / 11) rows[#rows + 1] = { y, h } y = y + h end
  field:each(function(x, yy)
    local y2 = yy - 1.5 * sin(x / 30)
    for _, r in ipairs(rows) do
      if y2 >= r[1] and y2 < r[1] + r[2] then
        local f = (y2 - r[1]) / r[2]
        local col = f < 0.2 and "#c98c58" or f < 0.62 and P.wood.base or f < 0.84 and P.wood.shade or P.wood.deep
        if col == P.wood.base and hash(x, yy) % 13 == 0 then col = P.wood.shade end
        px(x, yy, col) break
      end
    end
  end)
  -- pumpkins on ridges with vines/leaves
  local pk = { { 12, 124, 4 }, { 38, 122, 4 }, { 66, 120, 4 }, { 22, 136, 5 }, { 52, 134, 5 }, { 80, 133, 4 },
    { 8, 152, 6 }, { 40, 151, 6 }, { 72, 150, 6 }, { 24, 174, 8 }, { 62, 172, 7 }, { 94, 176, 6 }, { 8, 194, 8 }, { 46, 194, 9 }, { 84, 196, 7 } }
  local function leaf(x, y, r, flip)
    for j, d in ipairs({ { 0, 0, 1 }, { -r + 1, -2, 0.7 }, { r - 1, -1, 0.75 } }) do
      local rr = math.max(2, floor(r * d[3]))
      local lx, ly = x + d[1], y + d[2]
      local m = c:poly{ { lx - rr, ly }, { lx - 1, ly - rr + 1 }, { lx + 1, ly - rr }, { lx + rr, ly - 1 }, { lx + 1, ly + rr - 1 } }
      rim(m, P.moss.deep) form(m, P.moss, { s = 1, l = 1 })
      fm(c:line({ { lx - rr + 1, ly }, { lx + rr - 2, ly - 1 } }, 1), P.moss.shade)
    end
  end
  for i, p in ipairs(pk) do
    local x, y, r = p[1], p[2], p[3]
    fm(c:line({ { x - r - 6, y + 1 }, { x - r, y } }, 1), P.moss.shade)
    leaf(x + r + 2 + floor(r / 2), y + 1, floor(r * 0.7) + 1)
  end
  for i, p in ipairs(pk) do
    local x, y, r = p[1], p[2], p[3]
    local m = E(x, y, r, r * 0.72)
    rim(m, INK)
    form(m, PUMP, { s = max(1, floor(r / 3)), l = 1, deep = true })
    -- ribs
    for _, dx in ipairs({ -floor(r / 2), floor(r / 2) }) do
      local rib = c:line({ { x + dx, y - floor(r * 0.5) }, { x + dx + (dx < 0 and -1 or 1), y }, { x + dx, y + floor(r * 0.5) } }, 1):clip(m:shrink(1))
      fm(rib, PUMP.shade)
    end
    fm(Rm(x - 1, y - floor(r * 0.72) - 2, x, y - floor(r * 0.72)), P.moss.shade)
    px(x, y - floor(r * 0.72) - 2, P.moss.deep)
  end
end

------------------------------------------------------------------ BIRCH GROVE (left, near-mid, tall)
local function birch(x, top, bot, w)
  local m = Rm(x, top, x + w - 1, bot)
  m:add(c:poly{ { x - 2, bot + 1 }, { x + w + 1, bot + 1 }, { x + w - 1, bot - 4 }, { x, bot - 4 } })
  rim(m, INK)
  form(m, BIRCH, { s = 2 })
  for y = top + 2, bot - 2, 5 do
    local o = hash(x, y) % (w - 1)
    local l = 1 + hash(y, x) % 2
    fm(Rm(x + o, y, min(x + w - 1, x + o + l), y), P.stone.deep)
    if hash(x + 1, y) % 3 == 0 then px(x + o, y + 1, INK) end
  end
  -- branch stubs
  local tw = c:line({ { x + w, top + 22 }, { x + w + 3, top + 19 } }, 2)
  rim(tw, INK) fm(tw, BIRCH.shade) px(x + w + 1, top + 21, P.stone.deep)
end
local function leafy(clumps, R, accent, rimc)
  local all = HP.mask()
  for _, k in ipairs(clumps) do all:add(E(k[1], k[2], k[3], k[4])) end
  if rimc then rim(all, rimc) end
  for ci, k in ipairs(clumps) do
    local m = E(k[1], k[2], k[3], k[4])
    form(m, R, { s = 3, l = 2 })
    -- clump separation line on lower edge
    m:each(function(x, y) if not m:has(x, y + 1) and all:has(x, y + 1) then px(x, y, R.deep) end end)
    -- leaf speckle (2px marks)
    for i = 0, floor(k[3] * k[4] / 5) do
      local x = floor(k[1] - k[3] + hash(ci * 31 + i, 41) % (2 * k[3] + 1))
      local y = floor(k[2] - k[4] + hash(i, ci * 17 + 43) % (2 * k[4] + 1))
      if m:has(x, y) and m:has(x + 1, y) then
        local r = hash(i, ci) % 5
        local col = r == 0 and accent or r == 1 and R.hi or R.shade
        px(x, y, col) px(x + 1, y + (r % 2), col)
      end
    end
  end
  return all
end
-- foliage(shape, pick, o): canopy of many leaf clumps of mixed size over a dark interior (gaps read as depth).
-- Clumps on the lit side (upper-left of the canopy) get a hi crescent; the shadow side drops one tone.
-- pick(cx,cy) -> ramp; o.dark(cx,cy) -> shadow side; o.lit(cx,cy) -> lit side; o.inner = interior colour.
local function foliage(shape, pick, o)
  o = o or {}
  local step, r0 = o.step or 7, o.r or 5
  local blobs = {}
  local x0, y0, x1, y1 = shape:bbox()
  local i = 0
  for y = y0, y1, step - 1 do for x = x0, x1, step do
    i = i + 1
    local cx = x + (hash(i, 91) % 5) - 2 + ((y // (step - 1)) % 2) * floor(step / 2)
    local cy = y + (hash(i, 93) % 3) - 1
    if shape:has(cx, cy) and (not o.skip or hash(i, 97) % o.skip ~= 0) then
      local edge = not shape:has(cx - step, cy) or not shape:has(cx + step, cy) or not shape:has(cx, cy - step) or not shape:has(cx, cy + step)
      local r = r0 + hash(i, 95) % 4 - 1
      if edge then r = r - 1 end
      blobs[#blobs + 1] = { cx, cy, r }
    end
  end end
  local all = HP.mask()
  local ms = {}
  for k, b in ipairs(blobs) do ms[k] = E(b[1], b[2], b[3], b[3] * 0.8) all:add(ms[k]) end
  -- interior fill = union of the blob hull (the original shape clipped to blobs grown 1)
  local hull = shape:copy():clip(all:grow(2)):add(all)
  rim(hull, o.rimc or INK)
  fm(hull, o.inner or P.wood.deep)
  for k, b in ipairs(blobs) do
    local m, R = ms[k], pick(b[1], b[2])
    local dark = o.dark and o.dark(b[1], b[2])
    local lit = (not dark) and o.lit and o.lit(b[1], b[2])
    local hi, base, sh, dp = R.hi, R.base, R.shade, R.deep
    if dark then hi, base, sh = R.base, R.shade, R.deep end
    fm(m, base)
    m:each(function(x, y)
      if not m:has(x + 2, y + 2) then px(x, y, sh) end
      if lit and not m:has(x - 1, y - 2) then px(x, y, hi) end
      if not m:has(x, y + 1) then px(x, y, dp) end
    end)
    if not lit and not dark then px(b[1] - 1, b[2] - 1, hi) px(b[1], b[2] - 1, hi) end
  end
  -- leaf glyphs: little "v" marks (3 px) scattered over the canopy, accent colour
  for j = 0, floor(hull:count() / 60) do
    local lx, ly = x0 + hash(j, 107) % (x1 - x0 + 1), y0 + hash(109, j) % (y1 - y0 + 1)
    if hull:has(lx - 2, ly) and hull:has(lx + 2, ly) and hull:has(lx, ly + 2) and hull:has(lx, ly - 2) then
      local R = pick(lx, ly)
      local col = (R == P.gold) and P.ember.base or (j % 3 == 0) and (o.accent2 or o.accent) or o.accent
      if col then px(lx - 1, ly, col) px(lx, ly + 1, col) px(lx + 1, ly, col) end
    end
  end
  return hull
end
for _, b in ipairs({ { 6, 18, 112, 5 }, { 26, 28, 108, 4 }, { 46, 22, 115, 5 }, { -2, 30, 104, 4 } }) do birch(b[1], b[2], b[3], b[4]) end
do
  local sh = HP.mask()
  for _, k in ipairs({ { 4, 8, 16, 12 }, { 24, 2, 14, 10 }, { 40, 12, 15, 11 }, { 58, 6, 12, 10 }, { 14, 26, 12, 8 }, { 50, 28, 11, 8 }, { 30, 30, 10, 7 } }) do sh:add(E(k[1], k[2], k[3], k[4])) end
  foliage(sh, function(x, y) return (sin(x / 9) + cos(y / 7) > 1.1) and ORANGE or P.gold end,
    { r = 6, step = 7, accent = P.gold.hi, accent2 = P.cream, inner = P.gold.shade,
      lit = function(x, y) return x + y < 34 end, dark = function(x, y) return y > 31 and x > 16 end })
end

------------------------------------------------------------------ COTTAGE (hero, centre)
do
  local X0, X1 = 102, 170
  local wall = Rm(X0 + 2, 84, X1 - 2, 113)
  local roof = c:poly{ { 96, 86 }, { 136, 46 }, { 176, 86 } }
  local chim = Rm(150, 42, 158, 66)
  local found = Rm(X0, 112, X1, 117)
  local all = wall:copy():add(roof):add(chim):add(found)
  rim(all, INK)
  form(wall, WALL, { s = 0 })
  fm(Rm(X1 - 9, 86, X1 - 2, 111), WALL.shade)
  -- timber frame
  for _, xx in ipairs({ X0 + 2, X1 - 2 }) do fm(Rm(xx - 1, 86, xx, 111), P.wood.shade) end
  fm(Rm(X0 + 2, 86, X1 - 2, 87), P.wood.deep)
  -- foundation stones
  form(found, P.stone, { s = 0 })
  for x = X0, X1, 6 do fm(Rm(x, 112, x, 117), P.stone.shade) end
  for x = X0 + 3, X1, 6 do fm(Rm(x, 115, x, 115), P.stone.shade) end
  fm(Rm(X0, 117, X1, 117), P.stone.deep)
  -- chimney (bricks)
  form(chim, P.ember, { s = 0 })
  for y = 43, 66, 3 do fm(Rm(150, y, 158, y), P.ember.deep) end
  for y = 44, 66, 3 do for x = 150 + ((y // 3) % 2) * 2, 158, 4 do px(x, y, P.ember.deep) px(x, y + 1, P.ember.deep) end end
  fm(Rm(149, 40, 159, 42), P.stone.shade)
  -- roof tiles: courses with staggered joints
  form(roof, P.ember, { s = 0 })
  roof:each(function(x, y)
    local row = (y - 46) % 4
    if row == 3 then px(x, y, P.ember.shade)
    elseif row == 0 and ((x + ((y - 46) // 4) * 3) % 6 == 0) then px(x, y, P.ember.shade) px(x, y + 1, P.ember.shade) end
    if x > 136 + (y - 46) * 0.4 and row ~= 3 and c:get(x, y) == P.ember.base:lower() then px(x, y, "#d43e3a") end
  end)
  -- eaves board
  fm(c:line({ { 96, 86 }, { 136, 46 } }, 2), P.wood.base) fm(c:line({ { 136, 46 }, { 176, 86 } }, 2), P.wood.shade)
  -- attic round window in the gable
  local aw = E(136, 68, 5, 5) rim(aw, P.wood.deep) fm(aw, P.gold.base) fm(E(136, 68, 5, 5):clip(Rm(136, 63, 141, 73)), P.gold.shade)
  fm(Rm(136, 63, 136, 73), P.wood.deep) fm(Rm(131, 68, 141, 68), P.wood.deep)
  -- round-top door
  local door = Rm(128, 94, 144, 112):add(E(136, 94, 8, 6))
  rim(door, P.wood.deep)
  form(door, P.wood, { s = 0 })
  for x = 130, 143, 3 do fm(Rm(x, 90, x, 112):clip(door), P.wood.shade) end
  px(141, 103, P.gold.hi) px(141, 104, P.gold.base)
  -- windows (lit), right one has the gnome waving
  local function win(x0, y0)
    local w = Rm(x0, y0, x0 + 13, y0 + 11)
    rim(w, P.wood.deep)
    fm(w, P.gold.base) fm(Rm(x0, y0, x0 + 4, y0 + 3), P.gold.hi)
    fm(Rm(x0 + 9, y0, x0 + 13, y0 + 11), P.gold.shade)
    -- shutters
    fm(Rm(x0 - 4, y0 - 1, x0 - 2, y0 + 12), P.moss.shade) fm(Rm(x0 + 15, y0 - 1, x0 + 17, y0 + 12), P.moss.shade)
    -- flower box
    fm(Rm(x0 - 1, y0 + 13, x0 + 14, y0 + 15), P.wood.shade)
    for i = 0, 6 do local fx = x0 + i * 2 px(fx, y0 + 12, i % 2 == 0 and P.petal.base or P.ember.base) end
    return w
  end
  win(110, 92)
  local w2 = win(150, 92)
  -- gnome at window: hat, face, beard, waving hand
  fm(c:poly{ { 152, 98 }, { 160, 98 }, { 157, 88 }, { 155, 87 } }, P.ember.base)
  fm(c:poly{ { 157, 98 }, { 160, 98 }, { 157, 88 } }, P.ember.shade)
  fm(E(156, 100, 3.5, 2), P.skinA.base) px(155, 100, INK) px(157, 100, INK)
  fm(c:poly{ { 152, 102 }, { 160, 102 }, { 156, 103 } }:add(Rm(153, 102, 159, 103)), BEARD.base)
  fm(Rm(162, 94, 163, 99), P.sea.base) fm(E(163, 93, 1.5, 1.5), P.skinA.base)
  fm(Rm(150, 97, 163, 97):clip(w2), P.wood.deep) fm(Rm(156, 92, 156, 96), P.wood.deep)
  fm(Rm(110, 97, 123, 97), P.wood.deep) fm(Rm(116, 92, 116, 103), P.wood.deep)
  -- ivy climbing the west corner
  local iv = {}
  for y = 112, 84, -2 do iv[#iv + 1] = { 104 + floor(1.5 * sin(y / 3)), y } end
  fm(c:line(iv, 1), P.moss.deep)
  for k, q in ipairs(iv) do
    local side = (k % 2 == 0) and 1 or -1
    px(q[1] + side, q[2], k % 3 == 0 and P.ember.base or P.moss.base) px(q[1] + side, q[2] - 1, P.moss.shade)
  end
  -- smoke puffs drifting up-left
  for i, s in ipairs({ { 152, 36, 3 }, { 148, 30, 4 }, { 142, 23, 4 }, { 136, 15, 5 }, { 128, 7, 5 } }) do
    local m = E(s[1], s[2], s[3], s[3] - 1)
    fm(m, P.stone.hi) m:each(function(x, y) if not m:has(x + 1, y + 1) then px(x, y, P.stone.base) end end)
  end
end

------------------------------------------------------------------ SUNFLOWERS behind the west fence + hens by the hay (r1 c1 / r1 c0)
for i, f in ipairs({ { 64, 86 }, { 72, 82 }, { 80, 88 }, { 89, 84 }, { 97, 90 } }) do
  local x, y = f[1], f[2]
  fm(Rm(x, y, x, 106), P.moss.shade)
  local lf = c:poly{ { x, y + 9 }, { x + 4, y + 7 }, { x + 1, y + 10 } }:add(c:poly{ { x, y + 13 }, { x - 4, y + 11 }, { x - 1, y + 14 } })
  fm(lf, P.moss.base)
  local head = E(x, y, 4, 3.5)
  rim(head, P.gold.deep)
  form(head, P.gold, { s = 1, l = 1 })
  head:edge():each(function(xx, yy) if (xx + yy) % 2 == 0 then px(xx, yy, P.gold.shade) end end)
  local ctr = E(x + 0.5, y + 0.5, 1.5, 1.5) fm(ctr, P.wood.deep) px(x, y, P.wood.shade)
end
local function hen(x, y, f)
  local body = E(x, y, 4, 3):add(c:poly{ { x - 4 * f, y - 1 }, { x - 7 * f, y - 4 }, { x - 5 * f, y + 1 } })
  local head = E(x + 3 * f, y - 4, 2, 2)
  local legs = Rm(x - 1, y + 3, x - 1, y + 4):add(Rm(x + 1, y + 3, x + 1, y + 4))
  local m = body:copy():add(head):add(legs)
  rim(m, INK)
  fm(legs, P.gold.shade)
  form(body, BEARD, { s = 1, l = 1 }) fm(head, P.stone.hi)
  fm(Rm(x - 1, y - 1, x + 1, y - 1), P.stone.base)
  px(x + 3 * f, y - 6, P.ember.base) px(x + 4 * f, y - 6, P.ember.base) px(x + 4 * f, y - 3, P.ember.base)
  px(x + 5 * f, y - 4, P.gold.base) px(x + 3 * f + f, y - 5, INK)
end
hen(36, 108, 1) hen(50, 112, -1)
for _, g in ipairs({ { 42, 114 }, { 45, 115 }, { 39, 116 } }) do px(g[1], g[2], P.gold.hi) end

------------------------------------------------------------------ FENCE (picket, both sides of cottage)
local function fence(x0, x1, y)
  local m = Rm(x0, y + 2, x1, y + 3):add(Rm(x0, y + 6, x1, y + 7))
  for x = x0, x1, 4 do m:add(Rm(x, y, x + 1, y + 10)) end
  rim(m, P.wood.deep) form(m, P.wood, { s = 0 })
  for x = x0, x1, 4 do px(x + 1, y + 1, P.wood.shade) fm(Rm(x + 1, y + 1, x + 1, y + 10), P.wood.shade) end
end
fence(64, 98, 104) fence(174, 196, 106)

------------------------------------------------------------------ FIREWOOD STACK + hay (r1 c3 / r1 c0)
do
  local logs = {}
  for row, n in ipairs({ 4, 3, 2 }) do
    for k = 0, n - 1 do logs[#logs + 1] = { 179 + (row - 1) * 2.5 + k * 5, 105 - (row - 1) * 4.5 } end
  end
  local all = HP.mask()
  for _, l in ipairs(logs) do all:add(E(l[1], l[2], 2.5, 2.5)) end
  rim(all, INK)
  for _, l in ipairs(logs) do
    local m = E(l[1], l[2], 2.5, 2.5) fm(m, P.wood.hi)
    m:edge():each(function(x, y) px(x, y, (x + y) % 3 == 0 and P.wood.shade or P.wood.base) end)
    px(floor(l[1] + .5), floor(l[2] + .5), P.wood.shade)
  end
  -- axe leaning on the pile
  fm(c:line({ { 200, 108 }, { 197, 96 } }, 1), P.wood.base)
  local head = c:poly{ { 195, 95 }, { 199, 94 }, { 200, 98 }, { 196, 98 } } rim(head, INK) fm(head, P.stone.hi) px(199, 97, P.stone.shade)
  -- gnome laundry line strung between two birches: hat, tunic, striped sock, scarf
  local ln = {}
  for x = 11, 45 do ln[#ln + 1] = { x, 74 + floor(4 * math.sin((x - 11) / 34 * math.pi) + .5) } end
  fm(c:line(ln, 1), P.stone.deep)
  local function ly(x) return 74 + floor(4 * math.sin((x - 11) / 34 * math.pi) + .5) end
  local hat = c:poly{ { 14, ly(14) + 1 }, { 21, ly(21) + 1 }, { 19, ly(14) + 9 }, { 17, ly(14) + 10 } }
  local tun = Rm(25, ly(25) + 1, 31, ly(25) + 9):add(Rm(23, ly(25) + 1, 33, ly(25) + 3))
  local sock = Rm(35, ly(35) + 1, 37, ly(35) + 7):add(Rm(35, ly(35) + 6, 40, ly(35) + 8))
  local scf = Rm(42, ly(42) + 1, 43, ly(42) + 10)
  local all = hat:copy():add(tun):add(sock):add(scf)
  rim(all, INK)
  form(hat, P.ember, { s = 1 }) form(tun, P.sea, { s = 1 }) form(scf, P.gold, { s = 0 })
  sock:each(function(x, y) px(x, y, (y % 2 == 0) and P.petal.base or P.cream) end)
  for _, q in ipairs({ 16, 20, 26, 30, 36, 42 }) do px(q, ly(q), P.wood.base) px(q, ly(q) - 1, P.wood.base) end
  -- hay bale left
  local hay = c:rrect(4, 100, 26, 114, 4)
  rim(hay, INK) form(hay, P.gold, { s = 2, l = 1 })
  for x = 7, 24, 4 do fm(Rm(x, 102, x, 112), P.gold.shade) end
  fm(Rm(4, 106, 26, 106), P.wood.shade)
end

------------------------------------------------------------------ MAPLE (hero tree, right)
do
  local trunk = c:poly{ { 254, 40 }, { 276, 40 }, { 282, 120 }, { 296, 150 }, { 300, 152 }, { 300, 154 }, { 236, 154 }, { 244, 140 }, { 250, 118 } }
  local branches = c:line({ { 258, 70 }, { 236, 52 }, { 222, 46 } }, 4):add(c:line({ { 272, 66 }, { 284, 54 } }, 4))
  local tr = trunk:copy():add(branches)
  rim(tr, INK)
  form(tr, P.wood, { s = 4, l = 2 })
  -- bark: wavy vertical furrows that follow the trunk flare, with lighter ridges beside them
  for k = 0, 9 do
    local x0 = 250 + k * 3.2
    local pts = {}
    for y = 62, 152, 3 do
      local spread = y > 118 and (y - 118) * (k - 4.5) * 0.12 or 0
      pts[#pts + 1] = { x0 + spread + 1.2 * sin(y / 6 + k), y }
    end
    local ln = c:line(pts, 1):clip(trunk:shrink(1))
    ln:each(function(x, y) if hash(x * 7 + k, y) % 9 ~= 0 then
      local was = c:get(x, y)
      px(x, y, was == P.wood.shade:lower() and P.wood.deep or P.wood.shade)
      if c:get(x - 1, y) == P.wood.base:lower() and hash(y, k) % 3 == 0 then px(x - 1, y, P.wood.hi) end
    end end)
  end
  -- knot
  local kn = E(258, 132, 2.5, 1.5) fm(kn, P.wood.deep) px(258, 132, "#3a2228")
  -- hollow with owl
  local hol = E(266, 104, 7, 9)
  rim(hol, P.wood.deep) fm(hol, "#3a2228")
  local owl = E(266, 107, 5, 5)
  form(owl, { hi = "#d9a46c", base = "#b97a4a", shade = "#8a5632", deep = "#51302b" }, { s = 1 })
  fm(E(264, 105, 1.5, 1.5), P.cream) fm(E(268, 105, 1.5, 1.5), P.cream) px(264, 105, INK) px(268, 105, INK)
  px(266, 107, P.gold.base) px(262, 101, "#8a5632") px(270, 101, "#8a5632")
  -- roots fanning
  for _, r in ipairs({ { 240, 150, 228, 158 }, { 258, 152, 252, 162 }, { 290, 150, 300, 160 } }) do
    local m = c:line({ { r[1], r[2] }, { r[3], r[4] } }, 3) rim(m, INK) form(m, P.wood, { s = 1 })
  end
  -- canopy
  local cl = {
    { 214, 10, 18, 14 }, { 240, 0, 20, 14 }, { 272, 4, 22, 15 }, { 296, 22, 14, 14 },
    { 208, 36, 16, 12 }, { 234, 30, 18, 13 }, { 262, 30, 18, 14 }, { 288, 46, 14, 12 },
    { 220, 60, 14, 10 }, { 246, 58, 13, 9 }, { 280, 66, 12, 9 }, { 200, 18, 10, 9 },
  }
  local shape = HP.mask()
  for _, k in ipairs(cl) do shape:add(E(k[1], k[2], k[3], k[4])) end
  foliage(shape, function(x, y)
    local v = sin(x / 14 + y / 30) + cos(y / 11 - x / 40)
    return v > 0.7 and P.gold or v < -0.5 and P.ember or ORANGE
  end, { r = 7, step = 8, skip = 23, accent = P.gold.hi, accent2 = P.ember.base, inner = "#5a2430",
    lit = function(x, y) return (x - 196) + y * 1.4 < 46 end, dark = function(x, y) return y > 58 or (x > 284 and y > 36) end })
  -- a few branch tips showing through the lower canopy
  for _, bl in ipairs({ { { 230, 66 }, { 224, 72 } }, { { 268, 70 }, { 262, 76 } } }) do
    local m = c:line(bl, 2) rim(m, INK) fm(m, P.wood.shade)
  end
  -- squirrel on the branch end
  local sqb = E(287, 99, 2.5, 3.5):add(E(288, 94, 2.5, 2))
  local sqe = c:poly{ { 287, 92 }, { 288, 89 }, { 289, 92 } }
  local sqt = E(283, 94, 3, 5):cut(E(284, 95, 1, 2))
  local sq = sqb:copy():add(sqe):add(sqt)
  rim(sq, INK)
  form(sqt, { hi = ORANGE.base, base = ORANGE.shade, shade = ORANGE.deep, deep = ORANGE.deep }, { s = 1, l = 1 })
  fm(E(284, 95, 1, 2), ORANGE.deep)
  form(sqb, ORANGE, { s = 1 }) fm(sqe, ORANGE.shade) fm(Rm(288, 98, 289, 101), P.cream)
  px(289, 93, INK) px(290, 95, INK) local ac = E(290, 98, 1, 1) fm(ac, P.wood.base) px(290, 97, P.moss.shade)
  -- ladder leaning on the trunk up to the owl's hollow
  local rails = c:line({ { 286, 152 }, { 274, 104 } }, 1):add(c:line({ { 293, 151 }, { 281, 103 } }, 1))
  local rungs = HP.mask()
  for t = 0.1, 0.95, 0.12 do rungs:add(c:line({ { 286 - 12 * t, 152 - 48 * t }, { 293 - 12 * t, 151 - 48 * t } }, 1)) end
  local lad = rails:copy():add(rungs)
  rim(lad, INK) fm(rungs, P.wood.shade) fm(rails, P.wood.hi)
  -- birdhouse on trunk
  local bh = Rm(276, 76, 282, 84) rim(bh, INK) form(bh, P.sea, { s = 1 })
  fm(c:poly{ { 274, 77 }, { 279, 71 }, { 284, 77 } }, P.ember.base) fm(E(279, 80, 1, 1), INK)
end

------------------------------------------------------------------ BALLOON (r0 c3)
do
  local env = E(172, 18, 11, 13):add(c:poly{ { 163, 24 }, { 181, 24 }, { 175, 34 }, { 169, 34 } })
  rim(env, INK)
  env:each(function(x, y)
    local hw = 0
    while env:has(172 + hw + 1, y) do hw = hw + 1 end
    local t = (x - 172) / (hw + 1)
    local band = floor((math.asin(math.max(-1, math.min(1, t))) / (math.pi / 2)) * 2.5 + 2.5) % 2
    px(x, y, band == 0 and P.ember.base or P.gold.base)
  end)
  env:each(function(x, y) if not env:has(x + 3, y + 2) then px(x, y, c:get(x, y) == P.ember.base:lower() and P.ember.shade or P.gold.shade) end end)
  fm(Rm(163, 22, 181, 23):clip(env), P.sea.base)
  px(166, 10, P.cream) px(167, 10, P.cream) px(166, 11, P.gold.hi)
  fm(c:line({ { 170, 34 }, { 170, 40 } }, 1), P.wood.deep) fm(c:line({ { 174, 34 }, { 174, 40 } }, 1), P.wood.deep)
  local bk = Rm(168, 40, 176, 45) rim(bk, INK) form(bk, P.wood, { s = 1 })
  -- a tiny gnome waving from the basket
  local tg = c:poly{ { 168, 38 }, { 174, 38 }, { 172, 32 }, { 170, 32 } }:add(Rm(169, 38, 173, 39)):add(Rm(176, 35, 176, 38))
  rim(tg, INK)
  fm(c:poly{ { 168, 38 }, { 174, 38 }, { 172, 32 }, { 170, 32 } }, P.ember.base) px(172, 34, P.ember.shade) px(173, 37, P.ember.shade)
  fm(Rm(169, 38, 173, 39), P.skinA.base) px(170, 38, INK) px(172, 38, INK) fm(Rm(170, 39, 172, 39), BEARD.base)
  fm(Rm(176, 36, 176, 38), P.sea.base) px(176, 35, P.skinA.base)
  fm(c:line({ { 169, 34 }, { 169, 40 } }, 1), P.wood.deep)
end

------------------------------------------------------------------ WELL + spring rocks (r1 c4)
do
  for _, r in ipairs({ { 216, 86, 4, 3 }, { 225, 85, 3, 2 }, { 213, 92, 3, 2 }, { 229, 90, 3, 2 } }) do
    local m = E(r[1], r[2], r[3], r[4]) rim(m, INK) form(m, P.stone, { s = 1, l = 1 })
  end
  local cyl = Rm(232, 88, 248, 100):add(E(240, 100, 8, 2))
  local posts = Rm(233, 76, 234, 88):add(Rm(246, 76, 247, 88))
  local roof = c:poly{ { 228, 78 }, { 240, 68 }, { 252, 78 } }
  local all = cyl:copy():add(posts):add(roof)
  rim(all, INK)
  form(posts, P.wood, { s = 0 })
  form(cyl, P.stone, { s = 3, l = 1 })
  for y = 90, 100, 3 do fm(Rm(232, y, 248, y):clip(cyl), P.stone.shade) end
  for y = 88, 100, 3 do for x = 232 + (y % 2) * 2, 248, 5 do px(x, y + 1, P.stone.shade) end end
  fm(E(240, 88, 8, 1.5), P.stone.deep) fm(Rm(234, 87, 246, 87), "#3a2228")
  form(roof, P.ember, { s = 2 }) roof:each(function(x, y) if (y - 68) % 3 == 2 then px(x, y, P.ember.shade) end end)
  fm(Rm(234, 80, 246, 80), P.wood.deep)
  fm(c:line({ { 240, 80 }, { 240, 84 } }, 1), P.stone.base)
  local bk = Rm(238, 84, 242, 87) rim(bk, INK) form(bk, P.wood, { s = 1 })
end

------------------------------------------------------------------ BRIDGE + BEAR (quirk)
do
  -- bear sits under the west end of the bridge, facing the stream (drawn before the deck)
  local body = E(191, 147, 7, 6.5)
  local head = E(193, 137, 6, 5)
  local ears = E(188, 132, 2, 2):add(E(198, 132, 2, 2))
  local feet = E(187, 154, 3, 1.5):add(E(197, 154, 3, 1.5))
  local paw = E(199, 146, 2, 2)
  local tailS = c:poly{ { 187, 143 }, { 191, 143 }, { 189, 152 }, { 186, 151 } }
  local bear = body:copy():add(head):add(ears):add(feet):add(paw):add(tailS)
  rim(bear, INK)
  form(body, BEAR, { s = 2, l = 1 })
  fm(E(193, 149, 3.5, 3.5):clip(body), "#d9b48a")
  form(feet, BEAR, { s = 1 }) px(186, 154, "#d9b48a") px(196, 154, "#d9b48a")
  form(ears, BEAR, { s = 0 }) px(188, 132, "#d9a08a") px(198, 132, "#d9a08a")
  form(head, BEAR, { s = 1, l = 1 })
  local mz = E(196, 139, 3, 2) fm(mz, "#e2bf94") px(198, 138, INK) px(199, 138, INK)
  px(196, 141, BEAR.deep) px(197, 141, BEAR.deep)
  fm(Rm(191, 135, 191, 136), INK) fm(Rm(195, 135, 195, 136), INK) px(191, 135, P.cream)
  -- scarf: band + hanging tail with fringe
  local band = Rm(187, 142, 199, 143)
  fm(band, P.ember.base) fm(Rm(187, 143, 199, 143), P.ember.shade)
  form(tailS, P.ember, { s = 1 }) fm(Rm(188, 146, 189, 146), P.gold.base)
  px(186, 152, P.ember.shade) px(188, 153, P.ember.shade)
  form(paw, BEAR, { s = 0 })
  -- rod + line + bobber with ripple ring
  fm(c:line({ { 200, 145 }, { 218, 127 } }, 1), P.wood.deep)
  fm(c:line({ { 218, 127 }, { 218, 141 } }, 1), P.stone.hi)
  px(218, 142, P.ember.base) px(218, 143, P.cream)
  fm(E(218, 143, 3.5, 1):edge():clip(stream), P.sea.hi)
  -- bucket with a fish tail sticking out
  local bk = Rm(178, 149, 183, 154) rim(bk, INK) form(bk, P.stone, { s = 1 })
  fm(Rm(178, 149, 183, 149), P.stone.deep)
  local fsh = c:poly{ { 179, 148 }, { 181, 145 }, { 183, 148 } } fm(fsh, P.sea.shade) px(181, 145, P.sea.base)
  -- bridge: humped deck + rails
  local deck = c:line({ { 188, 126 }, { 200, 119 }, { 214, 118 }, { 228, 124 } }, 4)
  local rails = c:line({ { 189, 118 }, { 200, 112 }, { 214, 111 }, { 227, 117 } }, 1)
  for _, x in ipairs({ 189, 196, 204, 212, 220, 227 }) do
    local yt = x < 200 and 118 - (x - 189) * 0.55 or x < 214 and 112 or 112 + (x - 214) * 0.45
    rails:add(Rm(x, floor(yt), x + 1, floor(yt) + 7))
  end
  local br = deck:copy():add(rails)
  rim(br, INK)
  form(deck, P.wood, { s = 1 }) deck:each(function(x, y) if x % 3 == 0 then px(x, y, P.wood.shade) end end)
  form(rails, P.wood, { s = 0 }) fm(rails:copy():clip(Rm(0, 0, 299, 199)):cut(rails:shift(0, -1)), P.wood.shade)
  -- shadow under the arch on water
  fm(c:line({ { 202, 124 }, { 214, 124 } }, 2):clip(stream), P.sea.shade)
end

------------------------------------------------------------------ SHEEP (r2 c4)
do
  local function sheep(x, y, f)
    local wool = E(x, y, 6, 4):add(E(x - 3, y - 2, 3, 3)):add(E(x + 3, y - 2, 3, 3))
    local head = E(x + 7 * f, y - 2, 2.5, 2)
    local legs = Rm(x - 4, y + 3, x - 3, y + 6):add(Rm(x + 3, y + 3, x + 4, y + 6))
    local m = wool:copy():add(head):add(legs)
    rim(m, INK)
    fm(legs, "#3a2a33")
    form(wool, BEARD, { s = 2, l = 1 })
    fm(head, "#3a2a33") px(x + 8 * f, y - 3, P.cream)
  end
  sheep(236, 118, 1) sheep(226, 140, -1)
end

------------------------------------------------------------------ GNOMES
-- gnome(x, y, o): feet centre at (x,y), ~30 px tall. o.f facing (1 right, -1 left), o.pose: "rake" | "carry" | "fish"
local function gnome(x, y, o)
  local f = o.f or 1
  local parts = {}
  local boots = E(x - 3, y - 1, 2.5, 1.5):add(E(x + 3, y - 1, 2.5, 1.5))
  local tunic = c:poly{ { x - 6, y - 2 }, { x + 6, y - 2 }, { x + 4, y - 13 }, { x - 4, y - 13 } }
  local beard = c:poly{ { x - 5, y - 15 }, { x + 5, y - 15 }, { x + 5, y - 11 }, { x + 1, y - 6 }, { x - 1, y - 6 }, { x - 5, y - 11 } }
  local face = E(x, y - 16, 4.5, 2.5)
  local hat = c:poly{ { x - 6 * f, y - 18 }, { x + 6 * f, y - 18 }, { x + 2 * f, y - 27 }, { x - 1 * f, y - 30 }, { x - 4 * f, y - 28 }, { x - 3 * f, y - 23 } }
  hat:add(E(x, y - 18, 6.5, 1.5))
  local arms, hands = HP.mask(), HP.mask()
  local prop = HP.mask()
  if o.pose == "carry" then
    arms:add(c:line({ { x - 5, y - 12 }, { x - 6, y - 7 } }, 2)):add(c:line({ { x + 5, y - 12 }, { x + 6, y - 7 } }, 2))
    prop = E(x, y - 6, 5.5, 4)
    hands:add(E(x - 6, y - 6, 1, 1)):add(E(x + 6, y - 6, 1, 1))
  elseif o.pose == "rake" then
    arms:add(c:line({ { x - 4 * f, y - 12 }, { x + 4 * f, y - 9 } }, 2)):add(c:line({ { x + 4 * f, y - 12 }, { x + 7 * f, y - 10 } }, 2))
    hands:add(E(x + 5 * f, y - 9, 1, 1)):add(E(x + 8 * f, y - 10, 1, 1))
  elseif o.pose == "fish" then
    arms:add(c:line({ { x + 4 * f, y - 12 }, { x + 7 * f, y - 11 } }, 2))
    hands:add(E(x + 8 * f, y - 11, 1, 1))
  end
  local all = boots:copy():add(tunic):add(beard):add(face):add(hat):add(arms):add(hands):add(prop)
  if not o.noboots then rim(all, INK) else rim(all:copy():cut(boots), INK) end
  if not o.noboots then form(boots, P.wood, { s = 1, deep = true }) end
  form(tunic, P.sea, { s = 2 })
  fm(Rm(x - 5, y - 6, x + 5, y - 6):clip(tunic), P.wood.shade) -- belt
  px(x, y - 6, P.gold.base)
  form(arms, P.sea, { s = 1 })
  form(beard, BEARD, { s = 1, l = 1 })
  form(face, P.skinA, { s = 1 })
  fm(E(x + f * 0.5, y - 15, 1.5, 1), P.skinA.shade) px(x + f * 0.5 - 0.5, y - 16, P.skinA.hi)
  form(hat, P.ember, { s = 2, l = 1 })
  fm(Rm(x - 6, y - 18, x + 6, y - 18):clip(hat), P.ember.deep)
  px(x - 2, y - 16, INK) px(x + 2, y - 16, INK)
  px(x - 3, y - 15, P.petal.base) px(x + 3, y - 15, P.petal.base)
  form(hands, P.skinA, { s = 0 })
  if o.pose == "carry" then
    form(prop, PUMP, { s = 1, l = 1, deep = true })
    fm(Rm(x - 3, y - 8, x - 3, y - 4), PUMP.shade) fm(Rm(x + 3, y - 8, x + 3, y - 4), PUMP.shade)
    fm(Rm(x, y - 11, x + 1, y - 10), P.moss.shade)
    fm(hands, P.skinA.base)
  end
  return all
end
-- 1: carrying a pumpkin across the field
gnome(46, 146, { pose = "carry" })
-- 2: raking leaves beside the path, leaf pile
do
  local pile = E(108, 146, 10, 5):add(E(104, 143, 6, 4)):add(E(112, 143, 4, 3))
  foliage(pile, function(x, y) return ((x + y) % 3 == 0) and P.gold or ((x * 3 + y) % 4 == 0) and P.ember or ORANGE end,
    { r = 3, step = 4, accent = P.gold.hi, inner = ORANGE.deep, lit = function(x, y) return y < 144 end, dark = function(x, y) return y > 148 end })
  -- rake
  fm(c:line({ { 131, 134 }, { 118, 150 } }, 1), P.wood.base)
  local tines = Rm(113, 150, 121, 151)
  fm(tines, P.stone.shade) for x = 113, 121, 2 do px(x, 152, P.stone.deep) end
  gnome(128, 150, { pose = "rake", f = -1 })
  -- a few flying leaves
  for _, l in ipairs({ { 118, 132 }, { 112, 136 }, { 124, 128 } }) do px(l[1], l[2], ORANGE.base) px(l[1] + 1, l[2] - 1, ORANGE.base) end
end
-- 4: fishing in a rowboat on the pond
do
  local boat = c:poly{ { 238, 176 }, { 270, 176 }, { 266, 184 }, { 242, 184 } }
  gnome(254, 178, { pose = "fish", f = -1, noboots = true })
  rim(boat, INK)
  form(boat, P.wood, { s = 2, deep = true })
  fm(Rm(239, 176, 269, 177), P.wood.hi)
  fm(c:line({ { 246, 167 }, { 230, 150 } }, 1), P.wood.deep)
  fm(c:line({ { 230, 150 }, { 228, 160 }, { 228, 177 } }, 1), P.stone.hi)
  px(228, 178, P.ember.base) px(228, 179, P.cream)
end

------------------------------------------------------------------ SCARECROW + CROW (r2 c1)
do
  local post = Rm(80, 104, 81, 140)
  local arms = Rm(68, 114, 93, 115)
  local body = c:poly{ { 75, 112 }, { 86, 112 }, { 88, 128 }, { 73, 128 } }
  local head = E(80.5, 107, 4.5, 4.5)
  local hat = Rm(73, 101, 88, 102):add(Rm(76, 96, 85, 101))
  local all = post:copy():add(arms):add(body):add(head):add(hat)
  rim(all, INK)
  form(post, P.wood, { s = 0 }) form(arms, P.wood, { s = 0 })
  form(body, P.moss, { s = 2 }) fm(Rm(82, 120, 85, 123), P.ember.base)
  for _, s in ipairs({ { 73, 128 }, { 76, 129 }, { 79, 128 }, { 82, 129 }, { 85, 128 }, { 87, 129 } }) do px(s[1], s[2], P.gold.base) px(s[1], s[2] + 1, P.gold.base) end
  for _, s in ipairs({ 67, 94 }) do px(s, 113, P.gold.base) px(s, 116, P.gold.base) px(s, 114, P.gold.hi) end
  form(head, { hi = "#ffe9b0", base = "#f2cf7a", shade = "#d1a34e", deep = "#8f6a2e" }, { s = 1 })
  px(78, 106, INK) px(83, 106, INK) fm(Rm(79, 109, 82, 109), P.wood.deep)
  form(hat, P.wood, { s = 1 }) fm(Rm(76, 100, 85, 100), P.ember.base)
  -- crow on the arm
  local crow = E(91, 111, 2.5, 2):add(E(93, 109, 1.5, 1.5))
  rim(crow, INK) fm(crow, "#3b3348") px(94, 109, P.gold.base) px(93, 108, P.cream)
end

------------------------------------------------------------------ POND LIFE: beaver lodge, cattails, duck, lily pads
do
  local lodge = E(286, 192, 18, 14):clip(Rm(262, 170, 300, 196))
  local sticks = {}
  for i = 0, 40 do
    local ang = (hash(i, 81) % 160 - 80) / 100
    local cx, cy = 270 + hash(i, 83) % 30, 180 + hash(i, 85) % 16
    if lodge:has(cx, cy) then
      local l = 4 + hash(i, 87) % 5
      sticks[#sticks + 1] = { { cx - l * cos(ang), cy - l * sin(ang) * 0.6 }, { cx + l * cos(ang), cy + l * sin(ang) * 0.6 }, i }
    end
  end
  local all = lodge:copy()
  for _, st in ipairs(sticks) do all:add(c:line({ st[1], st[2] }, 1)) end
  all:clip(Rm(0, 0, 299, 196))
  rim(all, INK)
  fm(all, "#4a2f26")
  for _, st in ipairs(sticks) do
    local col = ({ P.wood.base, P.wood.hi, P.wood.shade, "#a0683e" })[st[3] % 4 + 1]
    fm(c:line({ st[1], st[2] }, 1):clip(all), col)
  end
  -- mud waterline + doorway
  fm(Rm(262, 196, 299, 196):clip(lodge:grow(1)), P.wood.deep)
  local door = E(288, 196, 4, 4):clip(Rm(280, 190, 296, 196)) fm(door, "#2a1a20")
  -- beaver sitting on the lodge flank, flat tail
  local bvb = E(290, 175, 3.5, 4)
  local bvh = E(292, 170, 2.5, 2.5)
  local bvt = E(285, 181, 3.5, 1.5)
  local bv = bvb:copy():add(bvh):add(bvt)
  rim(bv, INK)
  fm(bvt, "#5a3a2e") px(284, 181, "#3e2822") px(286, 181, "#3e2822")
  form(bvb, BEAR, { s = 1, l = 1 }) form(bvh, BEAR, { s = 1 })
  px(293, 169, INK) px(294, 171, P.cream) px(294, 170, BEAR.deep) fm(Rm(289, 175, 291, 177), "#c48a58")
  -- cattails on the west bank
  for i, x in ipairs({ 170, 177, 183, 190 }) do
    local top = 160 + (i * 7) % 9
    fm(Rm(x, top, x, 192), P.moss.shade) px(x, top - 1, P.moss.shade)
    local h = Rm(x, top + 1, x + 1, top + 5) fm(h, P.wood.shade) px(x, top + 1, P.wood.base) px(x + 1, top + 5, P.wood.deep)
    fm(c:line({ { x, 186 }, { x - 3, 178 } }, 1), P.moss.base)
  end
  -- duck
  local duck = E(222, 170, 5, 3):add(E(226, 166, 2.5, 2.5))
  rim(duck, INK) form(duck, { hi = "#f2ead8", base = "#d9c9a8", shade = "#a8936f", deep = "#6e5a44" }, { s = 1 })
  fm(E(226, 166, 2.5, 2.5), "#3f9150") px(227, 165, INK) fm(Rm(229, 167, 230, 167), P.gold.base)
  -- lily pads
  for _, l in ipairs({ { 206, 186 }, { 214, 194 }, { 228, 190 }, { 196, 196 } }) do
    local m = E(l[1], l[2], 4, 2):cut(c:poly{ { l[1], l[2] }, { l[1] + 5, l[2] - 2 }, { l[1] + 5, l[2] } })
    rim(m, P.moss.deep) form(m, P.moss, { s = 1 })
  end
  px(214, 192, P.petal.base) px(215, 192, P.petal.hi)
end

------------------------------------------------------------------ WATER polish: broken mirror reflections, ripple rings
do
  local WATER = { [P.sea.base:lower()] = true, ["#4ea9c4"] = true, [P.sea.shade:lower()] = true, ["#3f9aa8"] = true, [P.sea.hi:lower()] = true }
  local function lum(h) local r, g, b = tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) return r * .3 + g * .59 + b * .11 end
  local function reflect(x0, x1, yw, h, wob)
    local put = {}
    for dy = 1, h do
      if dy % 3 ~= 0 then
        local sh = (wob and (dy % 2) or 0)
        for x = x0, x1 do
          local src, dst = c:get(x - sh, yw - dy + 1), c:get(x, yw + dy)
          if src and dst and WATER[dst] and not WATER[src] then
            local L = lum(src)
            put[#put + 1] = { x, yw + dy, L < 90 and "#2f6a96" or L < 170 and "#3a86b0" or "#8ad6d6" }
          end
        end
      end
    end
    for _, q in ipairs(put) do px(q[1], q[2], q[3]) end
  end
  reflect(236, 274, 184, 12, true)   -- rowboat + gnome
  reflect(214, 232, 173, 5, true)    -- duck
  reflect(186, 232, 126, 7, false)   -- bridge over the stream
  reflect(166, 194, 192, 6, true)    -- cattails
  -- ripple rings round the gnome's bobber and the boat
  local function wet(m) local r = HP.mask() m:each(function(x, y) if WATER[c:get(x, y) or ""] then r:set(x, y) end end) return r end
  fm(wet(E(228, 180, 4, 1):edge()):cut(Rm(227, 177, 229, 180)), P.sea.hi)
  fm(wet(E(228, 180, 7, 2):edge()):cut(Rm(225, 177, 231, 183)), "#8ad6d6")
  -- glints
  for _, g in ipairs({ { 200, 182 }, { 230, 196 }, { 210, 104 }, { 256, 160 } }) do
    if water:has(g[1], g[2]) then px(g[1], g[2], P.cream) px(g[1] + 1, g[2], P.sea.hi) end
  end
end

------------------------------------------------------------------ FOREGROUND props
do
  -- wheelbarrow of pumpkins (r3 c1)
  local tray = c:poly{ { 64, 170 }, { 92, 170 }, { 88, 182 }, { 68, 182 } }
  local wheel = E(66, 184, 4, 4)
  local handle = c:line({ { 90, 178 }, { 100, 186 } }, 2)
  local legs = Rm(84, 182, 85, 190)
  local wb = tray:copy():add(wheel):add(handle):add(legs)
  rim(wb, INK)
  form(handle, P.wood, { s = 0 }) form(legs, P.wood, { s = 0 })
  form(tray, P.sea, { s = 2, deep = true })
  form(wheel, P.stone, { s = 1 }) fm(E(66, 184, 1, 1), P.stone.deep)
  for _, p in ipairs({ { 70, 167, 4 }, { 78, 165, 5 }, { 87, 167, 4 } }) do
    local m = E(p[1], p[2], p[3], p[3] * 0.75):cut(Rm(60, 170, 100, 190))
    rim(m, INK) form(m, PUMP, { s = 1, l = 1 }) fm(Rm(p[1], p[2] - 4, p[1], p[2] - 3), P.moss.shade)
  end
  -- apple basket (r3 c2)
  local bs = c:poly{ { 106, 184 }, { 122, 184 }, { 120, 194 }, { 108, 194 } }
  rim(bs, INK) form(bs, P.wood, { s = 1 }) for y = 186, 193, 2 do fm(Rm(107, y, 121, y):clip(bs), P.wood.shade) end
  for _, a in ipairs({ { 109, 182 }, { 113, 181 }, { 117, 182 }, { 111, 179 }, { 115, 178 }, { 120, 183 } }) do
    local m = E(a[1], a[2], 2, 2) rim(m, P.ember.deep) form(m, P.ember, { s = 1 }) px(a[1] - 1, a[2] - 1, P.ember.hi)
  end
  -- fox sneaking toward the basket, one apple already in its mouth (r3 c2)
  local body = E(132, 178, 7, 3.5)
  local head = E(123, 175, 3.5, 3):add(c:poly{ { 121, 174 }, { 116, 177 }, { 121, 178 } })
  local ears = c:poly{ { 121, 173 }, { 122, 168 }, { 124, 172 } }:add(c:poly{ { 124, 172 }, { 126, 168 }, { 127, 173 } })
  local tail = c:line({ { 139, 177 }, { 144, 172 }, { 149, 171 } }, 4)
  local legs2 = Rm(127, 181, 127, 184):add(Rm(130, 181, 130, 183)):add(Rm(135, 181, 135, 184)):add(Rm(138, 181, 138, 183))
  local fx = body:copy():add(head):add(ears):add(tail):add(legs2)
  rim(fx, INK) fm(legs2, "#3a2a33")
  form(tail, ORANGE, { s = 1 }) fm(E(150, 171, 2, 2):clip(tail:grow(1)), P.cream)
  form(body, ORANGE, { s = 1, l = 1 }) form(head, ORANGE, { s = 1 }) fm(ears, ORANGE.shade)
  fm(Rm(118, 177, 122, 178), P.cream) fm(E(132, 180, 4, 1):clip(body), "#ffe0b8")
  px(116, 177, INK) px(122, 174, INK) px(122, 175, INK)
  local ap = E(116, 179, 1.5, 1.5) rim(ap, P.ember.deep) fm(ap, P.ember.base) px(116, 178, P.ember.hi)
  -- mushrooms (r3 c0/c2, r2 c5)
  local function shroom(x, y, s, R)
    local cap = E(x, y - s, s + 1, s * 0.7):clip(Rm(x - s - 2, y - 2 * s, x + s + 2, y - s + 1))
    local st = Rm(x - floor(s / 3), y - s + 1, x + floor(s / 3), y)
    local m = cap:copy():add(st)
    rim(m, INK) form(st, BIRCH, { s = 1 }) form(cap, R, { s = 1, l = 1 })
    if R == P.ember then px(x - 1, y - s - 1, P.cream) px(x + 2, y - s, P.cream) px(x - 3, y - s, P.cream) end
  end
  shroom(232, 158, 4, P.ember) shroom(240, 160, 3, P.ember) shroom(298, 158, 4, P.wood)
  shroom(166, 194, 4, P.ember) shroom(173, 196, 3, P.ember)
  shroom(36, 104, 3, P.ember) shroom(60, 108, 4, P.petal)
  -- barrel (r2 c3 near cottage)
  local barrel = c:rrect(158, 132, 170, 148, 3)
  rim(barrel, INK) form(barrel, P.wood, { s = 2, l = 1 })
  fm(Rm(158, 136, 170, 136):clip(barrel), P.stone.shade) fm(Rm(158, 144, 170, 144):clip(barrel), P.stone.shade)
  fm(E(164, 132, 5, 1), P.wood.deep)
end

HP.report(c) HP.assertClean(c)
HP.cells(c, 6, 4)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 6 }
c:save{ png = out .. NAME .. "-thumb.png", scale = 1.5 }
c:save{ png = out .. NAME .. "-x2.png", scale = 2 }
