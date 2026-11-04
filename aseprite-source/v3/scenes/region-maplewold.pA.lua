-- region-maplewold PASS A (composition, big shapes, density). 300x200 grid, x6 = 1800x1200; thumb x1.5.
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
local NAME = app.params.name or "region-maplewold.pA"
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
-- geese V
for i, g in ipairs({ { 70, 34 }, { 77, 37 }, { 84, 40 }, { 77, 31 }, { 84, 28 } }) do
  px(g[1] - 1, g[2], P.stone.deep) px(g[1], g[2] + 1, P.stone.deep) px(g[1] + 1, g[2], P.stone.deep)
end
-- blue far mountains (2 ranges)
local function mt1(x) return 42 + 7 * sin(x / 23 + 0.6) + 4 * sin(x / 9) - 8 * math.exp(-((x - 120) / 30) ^ 2) end
c:terrain(mt1, "#a9b8e6")
local function mt2(x) return 52 + 4 * sin(x / 17 + 2) + 2 * sin(x / 7) end
c:terrain(mt2, "#8b9fd6")
-- snow-ish highlights on the near range ridge
for x = 0, 299 do local y = floor(mt2(x) + .5) if (x // 3) % 4 == 0 then px(x, y, "#b9c6ee") end end
-- windmill on a far knoll (r1 c1)
do
  local knoll = c:terrain(function(x) return 58 - 6 * math.exp(-((x - 82) / 14) ^ 2) end, "#9cc36a", 70, 55, 110)
  local tw = c:poly{ { 78, 40 }, { 86, 40 }, { 88, 56 }, { 76, 56 } }
  rim(tw, "#6f7aa8")
  fm(tw, "#efe6d6") fm(Rm(84, 41, 88, 56):clip(tw), "#cfc3c0")
  fm(c:poly{ { 77, 41 }, { 82, 35 }, { 87, 41 } }, P.ember.shade)
  fm(Rm(81, 50, 83, 55), P.wood.shade)
  for _, a in ipairs({ 0.5, 2.07, 3.64, 5.21 }) do
    local x2, y2 = 82 + 13 * cos(a), 40 + 13 * sin(a)
    fm(c:line({ { 82, 40 }, { x2, y2 } }, 1), P.wood.deep)
    local nx, ny = -sin(a), cos(a)
    for t = 4, 12 do fm(c:line({ { 82 + t * cos(a), 40 + t * sin(a) }, { 82 + t * cos(a) + 3 * nx, 40 + t * sin(a) + 3 * ny } }, 1), "#e9dfd0") end
  end
  px(82, 40, P.ink) px(81, 40, P.wood.deep)
end
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
  fm(c:line({ { x + w, top + 18 }, { x + w + 6, top + 12 } }, 1), P.stone.shade)
  fm(c:line({ { x - 1, top + 26 }, { x - 6, top + 20 } }, 1), P.stone.shade)
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
-- foliage(shape, pick, o): canopy built from many small leaf clumps (top first), each lit upper-left,
-- shaded lower-right, deep under-edge; whole canopy ink-rimmed. pick(cx,cy) -> ramp; o.dark(cx,cy) -> true = shadow side
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
    if shape:has(cx, cy) then blobs[#blobs + 1] = { cx, cy, r0 + hash(i, 95) % 3 - 1 } end
  end end
  local all = HP.mask()
  local ms = {}
  for k, b in ipairs(blobs) do ms[k] = E(b[1], b[2], b[3], b[3] * 0.85) all:add(ms[k]) end
  rim(all, o.rimc or INK)
  for k, b in ipairs(blobs) do
    local m, R = ms[k], pick(b[1], b[2])
    local dark = o.dark and o.dark(b[1], b[2])
    local hi, base, sh, dp = R.hi, R.base, R.shade, R.deep
    if dark then hi, base, sh = R.base, R.shade, R.deep end
    fm(m, base)
    m:each(function(x, y)
      if not m:has(x + 2, y + 2) then px(x, y, sh) end
      if not m:has(x - 1, y - 2) and not dark then px(x, y, hi) end
      if not m:has(x, y + 1) then px(x, y, dp) end
    end)
    -- 2px leaf marks
    for j = 0, 1 do
      local lx, ly = b[1] - 2 + hash(k, j + 101) % 4, b[2] - 2 + hash(j + 103, k) % 3
      if m:has(lx, ly) and m:has(lx + 1, ly - 1) then local col = (j == 0) and hi or (o.accent or sh) px(lx, ly, col) px(lx + 1, ly - 1, col) end
    end
  end
  return all
end
for _, b in ipairs({ { 6, 18, 112, 5 }, { 26, 28, 108, 4 }, { 46, 22, 115, 5 }, { -2, 30, 104, 4 } }) do birch(b[1], b[2], b[3], b[4]) end
do
  local sh = HP.mask()
  for _, k in ipairs({ { 4, 8, 16, 12 }, { 24, 2, 14, 10 }, { 40, 12, 15, 11 }, { 58, 6, 12, 10 }, { 14, 26, 12, 8 }, { 50, 28, 11, 8 }, { 30, 30, 10, 7 } }) do sh:add(E(k[1], k[2], k[3], k[4])) end
  foliage(sh, function(x, y) return (sin(x / 9) + cos(y / 7) > 1.1) and ORANGE or P.gold end,
    { r = 5, step = 7, accent = P.ember.base, dark = function(x, y) return y > 30 and x > 20 end })
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
  -- smoke puffs drifting up-left
  for i, s in ipairs({ { 152, 36, 3 }, { 148, 30, 4 }, { 142, 23, 4 }, { 136, 15, 5 }, { 128, 7, 5 } }) do
    local m = E(s[1], s[2], s[3], s[3] - 1)
    fm(m, P.stone.hi) m:each(function(x, y) if not m:has(x + 1, y + 1) then px(x, y, P.stone.base) end end)
  end
end

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
  local stack = Rm(176, 96, 196, 104)
  rim(stack, INK) fm(stack, P.wood.shade)
  for y = 96, 104, 3 do for x = 176 + (y % 2) * 1, 196, 3 do
    local l = E(x + 1, y + 1, 1, 1) fm(l, P.wood.hi) px(x + 1, y + 1, P.wood.base)
  end end
  -- hay bale left
  local hay = c:rrect(4, 100, 26, 114, 4)
  rim(hay, INK) form(hay, P.gold, { s = 2, l = 1 })
  for x = 7, 24, 4 do fm(Rm(x, 102, x, 112), P.gold.shade) end
  fm(Rm(4, 106, 26, 106), P.wood.shade)
end

------------------------------------------------------------------ MAPLE (hero tree, right)
do
  local trunk = c:poly{ { 252, 60 }, { 278, 60 }, { 282, 120 }, { 296, 150 }, { 300, 152 }, { 300, 154 }, { 236, 154 }, { 244, 140 }, { 250, 118 } }
  local branches = c:line({ { 258, 70 }, { 236, 52 }, { 222, 46 } }, 4):add(c:line({ { 272, 66 }, { 290, 48 } }, 4))
  local tr = trunk:copy():add(branches)
  rim(tr, INK)
  form(tr, P.wood, { s = 4, l = 2 })
  -- bark grain
  for i = 0, 50 do
    local x, y = 248 + hash(i, 61) % 40, 64 + hash(i, 63) % 88
    if tr:has(x, y) and tr:has(x, y + 5) then fm(c:line({ { x, y }, { x + (i % 3 - 1), y + 3 + i % 4 } }, 1), P.wood.deep) end
  end
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
  end, { r = 6, step = 8, accent = P.gold.hi, dark = function(x, y) return y > 56 or (x > 286 and y > 34) end })
  -- squirrel on the branch end
  local sq = E(287, 98, 2.5, 3.5):add(E(289, 93, 2, 2)):add(E(284, 92, 2, 4.5))
  rim(sq, INK) form(sq, ORANGE, { s = 1 }) fm(Rm(287, 97, 288, 100), P.cream) px(290, 92, INK) px(288, 91, ORANGE.shade)
  -- birdhouse on trunk
  local bh = Rm(276, 76, 282, 84) rim(bh, INK) form(bh, P.sea, { s = 1 })
  fm(c:poly{ { 274, 77 }, { 279, 71 }, { 284, 77 } }, P.ember.base) fm(E(279, 80, 1, 1), INK)
end

------------------------------------------------------------------ BALLOON (r0 c3)
do
  local env = E(172, 18, 11, 13):add(c:poly{ { 163, 24 }, { 181, 24 }, { 175, 34 }, { 169, 34 } })
  rim(env, INK)
  env:each(function(x, y)
    local band = floor((x - 161) / 4) % 2
    px(x, y, band == 0 and P.ember.base or P.gold.base)
  end)
  env:each(function(x, y) if not env:has(x + 3, y + 2) then px(x, y, c:get(x, y) == P.ember.base:lower() and P.ember.shade or P.gold.shade) end end)
  fm(Rm(163, 22, 181, 23):clip(env), P.sea.base)
  px(166, 10, P.cream) px(167, 10, P.cream)
  fm(c:line({ { 170, 34 }, { 170, 40 } }, 1), P.wood.deep) fm(c:line({ { 174, 34 }, { 174, 40 } }, 1), P.wood.deep)
  local bk = Rm(168, 40, 176, 45) rim(bk, INK) form(bk, P.wood, { s = 1 })
  fm(E(171, 38, 1.5, 1.5):add(c:poly{ { 170, 37 }, { 173, 37 }, { 172, 33 } }), P.ember.base)
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
  -- bear sits under the west end of the bridge (drawn before the deck so the deck shades him)
  local body = E(193, 149, 7, 6)
  local head = E(193, 139, 5.5, 4.5)
  local ears = E(189, 135, 1.5, 1.5):add(E(197, 135, 1.5, 1.5))
  local bear = body:copy():add(head):add(ears)
  rim(bear, INK)
  form(body, BEAR, { s = 2, l = 1 })
  form(head, BEAR, { s = 1, l = 1 })
  fm(ears, BEAR.shade)
  fm(E(195, 141, 2.5, 1.5), "#d9b48a") px(196, 140, INK) px(197, 140, INK)
  px(191, 138, INK) px(195, 138, INK)
  -- scarf
  local sc = Rm(188, 143, 198, 145):add(Rm(189, 146, 191, 151))
  form(sc, P.ember, { s = 1 }) px(189, 151, P.cream) px(191, 151, P.cream)
  fm(E(194, 152, 4, 2), "#d9b48a")
  -- rod + line + bobber
  fm(c:line({ { 198, 148 }, { 216, 128 } }, 1), P.wood.deep)
  fm(c:line({ { 216, 128 }, { 216, 142 } }, 1), P.stone.hi)
  px(216, 143, P.ember.base) px(216, 144, P.cream)
  -- bucket with a fish
  local bk = Rm(179, 150, 184, 155) rim(bk, INK) form(bk, P.stone, { s = 1 })
  fm(c:poly{ { 180, 149 }, { 183, 146 }, { 184, 149 } }, P.sea.shade)
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
  local hat = c:poly{ { x - 6, y - 18 }, { x + 6, y - 18 }, { x + 2 * f, y - 27 }, { x - 1 * f, y - 30 }, { x - 4 * f, y - 28 }, { x - 3, y - 23 } }
  hat:add(E(x, y - 18, 6.5, 1.5))
  local arms, hands = HP.mask(), HP.mask()
  local prop = HP.mask()
  if o.pose == "carry" then
    arms:add(c:line({ { x - 5, y - 12 }, { x - 6, y - 8 } }, 2)):add(c:line({ { x + 5, y - 12 }, { x + 6, y - 8 } }, 2))
    prop = E(x, y - 8, 6, 4.5)
    hands:add(E(x - 6, y - 7, 1, 1)):add(E(x + 6, y - 7, 1, 1))
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
  px(x - 2, y - 17, INK) px(x + 2, y - 17, INK)
  px(x - 3, y - 15, P.petal.base) px(x + 3, y - 15, P.petal.base)
  form(hat, P.ember, { s = 2, l = 1 })
  fm(Rm(x - 6, y - 18, x + 6, y - 18):clip(hat), P.ember.deep)
  form(hands, P.skinA, { s = 0 })
  if o.pose == "carry" then
    form(prop, PUMP, { s = 1, l = 1, deep = true })
    fm(Rm(x - 3, y - 11, x - 3, y - 5), PUMP.shade) fm(Rm(x + 3, y - 11, x + 3, y - 5), PUMP.shade)
    fm(Rm(x, y - 13, x + 1, y - 12), P.moss.shade)
    fm(hands, P.skinA.base)
  end
  return all
end
-- 1: carrying a pumpkin across the field
gnome(46, 146, { pose = "carry" })
-- 2: raking leaves beside the path, leaf pile
do
  local pile = E(108, 146, 10, 5):add(E(104, 143, 5, 3))
  rim(pile, P.ember.deep)
  form(pile, ORANGE, { s = 2, l = 1 })
  for i = 0, 24 do local x, y = 98 + hash(i, 71) % 20, 140 + hash(i, 73) % 10
    if pile:has(x, y) and pile:has(x + 1, y) then local col = ({ P.ember.base, P.gold.base, P.gold.hi, P.ember.shade })[i % 4 + 1] px(x, y, col) px(x + 1, y, col) end end
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
  gnome(254, 178, { pose = "fish", f = 1, noboots = true })
  rim(boat, INK)
  form(boat, P.wood, { s = 2, deep = true })
  fm(Rm(239, 176, 269, 177), P.wood.hi)
  fm(c:line({ { 262, 167 }, { 280, 150 } }, 1), P.wood.deep)
  fm(c:line({ { 280, 150 }, { 284, 160 }, { 284, 176 } }, 1), P.stone.hi)
  px(284, 177, P.ember.base) px(284, 178, P.cream)
  -- reflection
  fm(Rm(242, 186, 266, 187):clip(water), P.sea.shade)
  for x = 244, 264, 4 do px(x, 189, P.sea.hi) px(x + 1, 189, P.sea.hi) end
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
  local lodge = E(286, 186, 16, 11):clip(Rm(260, 170, 300, 196))
  rim(lodge, INK) form(lodge, P.wood, { s = 3, l = 1 })
  for i = 0, 26 do
    local x, y = 272 + hash(i, 81) % 28, 176 + hash(i, 83) % 20
    local l = 3 + hash(i, 85) % 5
    if lodge:has(x, y) then fm(c:line({ { x, y }, { x + l, y + (i % 3 - 1) * 2 } }, 1):clip(lodge), i % 2 == 0 and P.wood.deep or P.wood.hi) end
  end
  local door = E(284, 194, 4, 3):clip(Rm(270, 190, 300, 196)) fm(door, "#3a2228")
  -- beaver on top
  local bv = E(288, 172, 4, 3):add(E(292, 170, 2, 2)):add(E(283, 174, 2.5, 1.5))
  rim(bv, INK) form(bv, BEAR, { s = 1 }) px(293, 169, INK) fm(Rm(282, 173, 284, 175), "#5a3a2e")
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
