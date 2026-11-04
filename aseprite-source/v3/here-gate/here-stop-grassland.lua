-- here-stop-grassland: GRASSLAND ROAD REST STOP seen from the entrance gate, looking in (one-point, VP 120,55).
-- 240x135 grid, x2 = 480x270. Layout: here-stop-grassland.layout.json (all coords halved here).
-- Planes: far = sky, puff clouds, violet/green hills, golden fields with hedgerows + tiny bales, windmill;
--         mid = thatched cottage row, wild-trail tree wall (right), haystack, scarecrow;
--         near-mid = dirt clearing with the stop's activities (forage, seeds, trader wagon, well, long table,
--                    notice board, rest bench, fishing pond);
--         near = the gate: big oak trunk (left post) + log post, beam, knee brace, lantern (right), pennant string,
--                low fence + wheelbarrow at the bottom-left; bottom-right kept calm for UI icons.
-- quirks: scarecrow wearing a teapot hat; snail-shaped mailbox; a sign pointing both ways; a haystack with a tiny door
--         and stovepipe; a kite stuck in the oak; a wheelbarrow of pumpkins growing a beanstalk up the oak.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local NAME = "here-stop-grassland"
local c = HP.canvas{ w = 240, h = 135, scale = 2, name = NAME }
local floor, sin, cos, abs, min, max, pi = math.floor, math.sin, math.cos, math.abs, math.min, math.max, math.pi
local INK = P.ink
local function E(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry or rx) end
local function Rm(x0, y0, x1, y1) return c:rect(x0, y0, x1, y1) end
local function fm(m, hex) c:fillMask(m, hex) return m end
local function hash(a, b) return ((a * 73856093) ~ (b * 19349663) ~ (a * b * 83492791)) % 1000 end
local function px(x, y, h) c:px(x, y, h) end
local function rim(m, hex) return c:rim(m, hex or INK) end
local function clampb(v) return max(0, min(255, floor(v + .5))) end
-- darker, cooler copy of a colour (cast shadows on whatever is already painted)
local function D(hex, f)
  f = f or .8
  local r, g, b = tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
  return string.format("#%02x%02x%02x", clampb(r * f - 4), clampb(g * (f - .04)), clampb(b * f + (1 - f) * 70))
end
local function shadow(m, f) m:each(function(x, y) local h = c:get(x, y) if h then px(x, y, D(h, f or .8)) end end) end

-- ramps
local WOOD = P.wood
local DARKW = { hi = "#c08a5a", base = "#8a5a3c", shade = "#64402e", deep = "#3e2826" }
local GREYW = { hi = "#d8c8b0", base = "#a89480", shade = "#7a6858", deep = "#4a3c3a" }
local TH = { hi = "#f8de90", base = "#e2b862", shade = "#bb8c44", deep = "#7c5634" }
local WALL = { hi = P.cream, base = "#f6e2bc", shade = "#dcc09a", deep = "#a88a6e" }
local TEAL = { hi = "#9ad8d0", base = "#4fa9b0", shade = "#3a7f96", deep = "#2a4a6a" }
local PUMP = { hi = "#ffc46b", base = "#f59a32", shade = "#d0632a", deep = "#7e3524" }
local TERRA = { hi = "#f0a070", base = "#d0704a", shade = "#a04a3a", deep = "#5e2a2a" }
local OAK = { hi = "#c4e07a", base = "#86c05a", shade = "#4f9450", deep = "#2e5e46" }
local OAKL = { hi = "#e8ee96", base = "#b0d266", shade = "#74aa54", deep = "#3f7448" }
local OAKD = { hi = "#7cb85a", base = "#468a50", shade = "#2e6448", deep = "#22443c" }
local FOR = { hi = "#8cc46a", base = "#4f9a58", shade = "#35704e", deep = "#22463e" }
local BARK = { hi = "#c79868", base = "#9a6a44", shade = "#6e4632", deep = "#45291f" }
local STONE = P.stone
local DIRT = { hi = "#ecca96", base = "#d6a96e", shade = "#b8865a", deep = "#8a5e42" }

-- form painter (from region-maplewold): base, lit crescent, shade crescent, deep underside
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

-- foliage (from region-maplewold): canopy of leaf clumps over a dark interior
local function foliage(shape, pick, o)
  o = o or {}
  local step, r0 = o.step or 7, o.r or 5
  local blobs = {}
  local x0, y0, x1, y1 = shape:bbox()
  local i = o.seed or 0
  for y = y0, y1, step - 1 do for x = x0, x1, step do
    i = i + 1
    local cx = x + (hash(i, 91) % 5) - 2 + ((y // (step - 1)) % 2) * floor(step / 2)
    local cy = y + (hash(i, 93) % 3) - 1
    if shape:has(cx, cy) then
      local edge = not shape:has(cx - step, cy) or not shape:has(cx + step, cy) or not shape:has(cx, cy - step) or not shape:has(cx, cy + step)
      local r = r0 + hash(i, 95) % 4 - 1
      if edge then r = r - 1 end
      blobs[#blobs + 1] = { cx, cy, max(2, r) }
    end
  end end
  local all = HP.mask()
  local ms = {}
  for k, b in ipairs(blobs) do ms[k] = E(b[1], b[2], b[3], b[3] * 0.8) all:add(ms[k]) end
  local hull = shape:copy():clip(all:grow(2)):add(all)
  if o.clip then hull:clip(o.clip) end
  if o.rimc then rim(hull, o.rimc) end
  fm(hull, o.inner or OAK.deep)
  for k, b in ipairs(blobs) do
    local m, R = ms[k]:clip(hull), pick(b[1], b[2])
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
  for j = 0, floor(hull:count() / 50) do
    local lx, ly = x0 + hash(j, 107 + (o.seed or 0)) % (x1 - x0 + 1), y0 + hash(109, j + (o.seed or 0)) % (y1 - y0 + 1)
    if hull:has(lx - 2, ly) and hull:has(lx + 2, ly) and hull:has(lx, ly + 2) and hull:has(lx, ly - 2) then
      local col = (j % 3 == 0) and (o.accent2 or o.accent) or o.accent
      if col then px(lx - 1, ly, col) px(lx, ly + 1, col) px(lx + 1, ly, col) end
    end
  end
  return hull
end

-- thatch texture: straw courses, lit left slope, shaded right slope, dark eave underside
local function thatch(m, ax, R)
  R = R or TH
  local x0, y0 = m:bbox()
  m:each(function(x, y)
    local row = (y - y0) % 3
    local h = hash(x * 3 + 1, y * 5 + 2) % 11
    local lit = x < ax
    local col = lit and R.base or R.shade
    if row == 0 then col = lit and R.hi or R.base end
    if row == 2 and h < 6 then col = lit and R.shade or R.deep end
    if h == 0 then col = R.hi elseif h == 10 then col = lit and R.shade or R.deep end
    if not m:has(x, y + 1) then col = R.deep
    elseif not m:has(x, y + 2) then col = lit and R.base or R.shade end
    if not m:has(x - 1, y) and lit then col = R.hi end
    px(x, y, col)
  end)
end

-- spoked wheel; background shows between the spokes
local function wheel(cx, cy, r, R, edge)
  local outer = E(cx, cy, r, r)
  local ring = outer:copy():cut(E(cx, cy, r - 1.6, r - 1.6))
  rim(outer, edge)
  local sp = HP.mask()
  for k = 0, 2 do
    local a = k * pi / 3 + 0.35
    sp:add(c:line({ { cx - (r - 1) * cos(a), cy - (r - 1) * sin(a) }, { cx + (r - 1) * cos(a), cy + (r - 1) * sin(a) } }, 1))
  end
  fm(sp:clip(outer), R.shade)
  fm(ring, R.base)
  ring:each(function(x, y) if x + y > cx + cy + 1 then px(x, y, R.shade) elseif x + y < cx + cy - r then px(x, y, R.hi) end end)
  fm(E(cx, cy, 1, 1), R.deep) px(floor(cx) - 1, floor(cy) - 1, R.hi)
end

------------------------------------------------------------------ SKY
c:stripes(0, 48, { "#8cc8ee", P.sky.shade, P.sky.base, "#cdebf8" }, { 2, 3, 3, 3 })
c:cloud(124, 22, 30, P.cream, P.sky.hi)
c:cloud(160, 14, 18, P.cream, P.sky.hi)
c:cloud(94, 40, 18, P.cream, P.sky.hi)
c:cloud(174, 36, 16, P.sky.hi, P.sky.base)
c:cloud(140, 34, 12, P.sky.hi, P.sky.base)

------------------------------------------------------------------ FAR HILLS + FIELDS
c:terrain(function(x) return 38 + 4 * sin(x / 23 + 0.4) + 2 * sin(x / 9) end, "#aab8e2")
c:terrain(function(x) return 43 + 3 * sin(x / 17 + 2) + 1.5 * sin(x / 6) end, "#9cbf9a")
for x = 0, 239 do local y = floor(43 + 3 * sin(x / 17 + 2) + 1.5 * sin(x / 6) + .5) if (x // 2) % 3 == 0 then px(x, y, "#b4d2a6") end end
local function gyF(x) return 47 + 1.2 * sin(x / 19) end
-- golden ground: depth bands + perspective mown rows converging on the VP + noise
local GF = { { "#f2df9a", "#e8d185", "#dcc06e" }, { "#eed37c", "#e0bd60", "#cba24c" }, { "#e6c564", "#d4ab50", "#bb8e40" } }
for y = 44, 134 do for x = 0, 239 do
  if y >= gyF(x) then
    local band = y < 58 and 1 or y < 82 and 2 or 3
    local R = GF[band]
    local col = R[2]
    if y > 51 then
      local a = (x - 120) / (y - 50)
      local s = floor(a * 3.2 + 100)
      if s % 2 == 0 then col = R[1] end
    end
    local h = hash(x, y) % 23
    if h == 0 then col = R[3] elseif h == 1 then col = R[1] end
    if band == 3 and hash(y, x) % 9 == 0 then col = "#c9b456" end
    px(x, y, col)
  end
end end
-- far hedgerows (dotted dark green) and tiny round bales
for _, hr in ipairs({ { 48, 0, 239 }, { 51, 0, 239 } }) do
  for x = hr[2], hr[3] do
    local y = hr[1] + floor(0.8 * sin(x / 13 + hr[1]) + .5)
    if hash(x, hr[1]) % 5 ~= 0 then px(x, y, hr[1] == 48 and "#8aa86a" or "#7a9a58") if hash(hr[1], x) % 3 == 0 then px(x, y - 1, "#9cbc72") end end
  end
end
for _, b in ipairs({ { 22, 46 }, { 34, 47 }, { 84, 49 }, { 108, 50 }, { 138, 47 }, { 152, 49 }, { 186, 47 }, { 200, 49 } }) do
  local m = E(b[1], b[2], 1.5, 1.2) fm(m, TH.base) px(b[1] - 1, b[2] - 1, TH.hi) px(b[1] + 1, b[2] + 1, TH.shade) px(b[1], b[2] + 1, TH.shade)
end

------------------------------------------------------------------ WINDMILL (far hill, low contrast)
do
  local hx, hy = 100, 25
  local tw = c:poly{ { 97, 26 }, { 103, 26 }, { 105, 49 }, { 95, 49 } }
  rim(tw, "#7f86a8")
  fm(tw, "#efe6d6") fm(c:poly{ { 101, 26 }, { 103, 26 }, { 105, 49 }, { 102, 49 } }, "#cfc3c0")
  for y = 31, 47, 4 do fm(Rm(95, y, 105, y):clip(tw), "#ddd2c8") end
  fm(Rm(99, 43, 101, 49), "#9a7a68") px(99, 43, "#b88a6a")
  fm(Rm(99, 35, 101, 36), "#e8b04a")
  local cap = c:poly{ { 96, 27 }, { 100, 22 }, { 104, 27 } } rim(cap, "#7f86a8") fm(cap, "#d9604a") fm(c:poly{ { 100, 22 }, { 104, 27 }, { 101, 27 } }, "#b04a44")
  for _, a in ipairs({ 0.5, 2.07, 3.64, 5.21 }) do
    local x2, y2 = hx + 12 * cos(a), hy + 12 * sin(a)
    local nx, ny = -sin(a), cos(a)
    local sail = c:poly{ { hx + 3 * cos(a), hy + 3 * sin(a) }, { x2, y2 }, { x2 + 3 * nx, y2 + 3 * ny }, { hx + 3 * cos(a) + 3 * nx, hy + 3 * sin(a) + 3 * ny } }
    fm(sail, "#f3ead8") c:edgeIn(sail, "#c8bcb8")
    fm(c:line({ { hx, hy }, { x2, y2 } }, 1), "#8a6a5a")
  end
  fm(E(hx, hy, 1, 1), "#6a4a44")
end

------------------------------------------------------------------ DIRT: road, clearing, side paths, wild trail
local dirt = c:poly{ { 117, 53 }, { 123, 53 }, { 160, 135 }, { 80, 135 } }
do
  local cl = HP.mask()
  for y = 70, 134 do for x = 0, 239 do
    local n = (hash(x // 3, y // 2) % 100) / 100 * 0.07
    local dx, dy = (x - 122) / 104, (y - 104) / 21
    if dx * dx + dy * dy < 1 - n then cl:set(x, y) end
    local ex, ey = (x - 120) / 30, (y - 80) / 11
    if ex * ex + ey * ey < 1 - n then cl:set(x, y) end
  end end
  dirt:add(cl)
  dirt:add(E(92, 86, 16, 5)):add(E(156, 88, 18, 5))
  dirt:add(c:line({ { 186, 94 }, { 196, 84 } }, 6)):add(c:line({ { 196, 84 }, { 205, 75 } }, 5))
    :add(c:line({ { 205, 75 }, { 213, 66 } }, 4)):add(c:line({ { 213, 66 }, { 219, 58 } }, 3))
end
for y = 53, 134 do for x = 0, 239 do
  if dirt:has(x, y) then
    local col = y < 70 and "#e2bb84" or y < 100 and DIRT.base or "#cf9f64"
    local h = hash(x * 7, y * 3) % 29
    if h < 2 then col = DIRT.shade elseif h == 2 then col = DIRT.hi elseif h == 3 and y > 90 then col = "#c49060" end
    if not dirt:has(x, y - 1) then col = DIRT.deep elseif not dirt:has(x, y - 2) then col = DIRT.shade end
    px(x, y, col)
  end
end end
-- worn pale centre of the road + wheel ruts converging on the VP
for y = 56, 134 do
  local t = (y - 53) / 82
  for _, dx in ipairs({ -15, 15 }) do
    local xr = 120 + dx * t
    local w = 0.5 + t * 1.3
    for x = floor(xr - w - 1), floor(xr + w + 1) do
      if dirt:has(x, y) then
        if abs(x - xr) <= w then px(x, y, (hash(x, y) % 7 == 0) and DIRT.deep or DIRT.shade)
        elseif x < xr then px(x, y, DIRT.hi) end
      end
    end
  end
  local cw = t * 6
  for x = floor(120 - cw), floor(120 + cw) do if dirt:has(x, y) and hash(x, y * 3) % 4 == 0 then px(x, y, "#e6c08c") end end
end
-- pebbles scattered on the clearing (sparse, small)
for i = 0, 70 do
  local x, y = 20 + hash(i, 501) % 205, 72 + hash(i, 503) % 62
  if dirt:has(x, y) and dirt:has(x + 1, y) and not (x > 190 and y > 112) then
    local big = y > 100 and hash(i, 505) % 3 == 0
    px(x, y, STONE.base) if big then px(x + 1, y, STONE.shade) px(x, y - 1, STONE.hi) else px(x + 1, y, DIRT.shade) end
  end
end

------------------------------------------------------------------ GRASS TEXTURE: tufts, blades, wildflowers (not in the calm corner)
local function tuft(x, y, s, calm)
  local base, mid, tip = "#b08a3a", "#c9a24a", "#f2dc8a"
  if hash(x, y + 7) % 3 == 0 then base, mid, tip = "#7a9a48", "#9cb856", "#d2e08a" end
  if calm then base, mid, tip = "#c9a24a", "#d4ab50", "#e0bd60" end
  for k = -1, 1 do
    local h = s + (k == 0 and 1 or 0)
    for j = 0, h - 1 do
      local xx = x + k * (1 + floor(j / 2))
      px(xx, y - j, j == h - 1 and tip or j == 0 and base or mid)
    end
  end
end
for i = 0, 900 do
  local x, y = hash(i, 11) % 240, 52 + hash(i, 13) % 83
  local here = c:get(x, y)
  if here and not dirt:has(x, y) or (here and dirt:has(x, y) and not dirt:has(x, y + 2) and not dirt:has(x, y - 3) and false) then
    local calm = x >= 188 and y >= 112
    local s = 1 + floor((y - 50) / 26)
    local r = hash(i, 17) % 12
    if calm then
      if r < 3 then px(x, y, "#c9a24a") px(x + 1, y - 1, "#c9a24a") end
    elseif r < 7 then tuft(x, y, s)
    elseif r < 9 then px(x, y, P.cream) if y > 80 then px(x + 1, y, P.gold.hi) px(x, y - 1, P.cream) end
    elseif r < 10 then px(x, y, P.petal.base) if y > 80 then px(x + 1, y, P.petal.hi) end
    elseif r < 11 then px(x, y, "#9a86d8") if y > 80 then px(x, y - 1, P.dusk.hi) end
    else px(x, y, "#c9a24a") end
  end
end
-- grass fringe hanging over the top edge of the dirt
for x = 0, 239 do for y = 54, 133 do
  if dirt:has(x, y) and not dirt:has(x, y - 1) and hash(x, y) % 4 == 0 and not (x >= 188 and y >= 112) then
    tuft(x, y, 1 + floor((y - 50) / 34))
  end
end end

------------------------------------------------------------------ FISHING POND (flat ground feature)
local pond = E(210, 90, 15, 6)
do
  local bank = pond:grow(1)
  rim(bank, "#a8823e")
  fm(bank, "#8a6a44")
  fm(pond, P.sea.base)
  pond:each(function(x, y)
    if not pond:has(x, y - 2) then px(x, y, "#3f8fa8")
    elseif y > 93 then px(x, y, "#7ad2d0") end
  end)
  for i = 0, 26 do
    local x, y = 196 + hash(i, 61) % 28, 86 + hash(i, 63) % 10
    local w = 1 + hash(i, 65) % 3
    if pond:has(x, y) and pond:has(x + w, y) and pond:has(x, y - 2) then fm(Rm(x, y, x + w, y), hash(i, 67) % 3 == 0 and P.sea.shade or P.sea.hi) end
  end
  -- lily pads + one flower
  for _, l in ipairs({ { 202, 92 }, { 206, 87 }, { 221, 92 } }) do
    local m = E(l[1], l[2], 2.5, 1.2):cut(c:poly{ { l[1], l[2] }, { l[1] + 3, l[2] - 1 }, { l[1] + 3, l[2] } })
    fm(m, P.moss.base) px(l[1] - 2, l[2], P.moss.shade) px(l[1] - 1, l[2] - 1, P.moss.hi)
  end
  px(202, 91, P.petal.base) px(203, 91, P.petal.hi)
  -- glints
  px(214, 88, P.cream) px(215, 88, P.sea.hi) px(198, 94, P.cream)
end

------------------------------------------------------------------ WILD TRAIL tree wall (right) + tunnel
do
  -- trunks and dark undergrowth under the canopy
  local under = c:poly{ { 196, 44 }, { 240, 40 }, { 240, 63 }, { 228, 63 }, { 220, 60 }, { 210, 62 }, { 198, 61 } }
  fm(under, "#2c4a3a")
  under:each(function(x, y) if hash(x, y) % 6 == 0 then px(x, y, "#3a5e44") end end)
  for _, t in ipairs({ { 201, 45, 61, 2 }, { 210, 46, 62, 2 }, { 230, 44, 63, 3 }, { 236, 44, 62, 2 } }) do
    local m = Rm(t[1], t[2], t[1] + t[4], t[3]) fm(m, BARK.shade) fm(Rm(t[1], t[2], t[1], t[3]), BARK.base)
    px(t[1] + t[4], t[3] - 3, BARK.deep)
  end
  -- tunnel into the wood where the trail goes
  local tun = E(220, 54, 6, 8)
  fm(tun, "#1f3530")
  fm(E(220, 57, 3.5, 5), "#16282a")
  -- canopy
  local sh = HP.mask()
  for _, k in ipairs({ { 206, 28, 12, 14 }, { 222, 20, 14, 16 }, { 238, 28, 10, 18 }, { 199, 42, 8, 6 }, { 213, 40, 7, 6 }, { 232, 44, 9, 5 }, { 244, 8, 10, 10 }, { 212, 8, 8, 8 } }) do
    sh:add(E(k[1], k[2], k[3], k[4]))
  end
  sh:cut(E(220, 52, 6, 7))
  foliage(sh, function(x, y) return ((x + y) % 5 == 0) and OAK or FOR end,
    { r = 5, step = 6, seed = 300, accent = "#a8d470", accent2 = P.gold.hi, inner = "#22403a", rimc = "#22403a",
      lit = function(x, y) return y < 22 and x < 222 end, dark = function(x, y) return y > 40 end })
  -- ferns at the tunnel mouth + trail markers
  for _, f in ipairs({ { 212, 62 }, { 226, 62 }, { 215, 60 } }) do
    for k = -2, 2 do px(f[1] + k, f[2] - 2 + abs(k) // 2, P.moss.base) px(f[1] + k, f[2] - 1 + abs(k) // 2, P.moss.shade) end
    px(f[1], f[2] - 3, P.moss.hi)
  end
  for _, s in ipairs({ { 208, 72 }, { 203, 79 }, { 214, 64 } }) do px(s[1], s[2], STONE.hi) px(s[1] + 1, s[2], STONE.base) px(s[1] + 1, s[2] + 1, STONE.shade) end
end

------------------------------------------------------------------ HAYSTACK with a tiny door (quirk)
do
  shadow(E(50, 58, 10, 1.5), .82)
  local hs = E(49, 50, 8, 8):clip(Rm(40, 40, 58, 57)):add(Rm(41, 50, 57, 57))
  rim(hs, TH.deep)
  thatch(hs, 47)
  for x = 42, 56, 3 do px(x, 57, TH.deep) px(x + 1, 56, TH.shade) end
  -- stovepipe with a puff
  local pipe = Rm(53, 39, 54, 44) rim(pipe, STONE.deep) fm(pipe, STONE.shade) px(53, 39, STONE.hi)
  fm(E(55, 35, 2, 1.5), STONE.hi) fm(E(57, 32, 1.5, 1), P.cream)
  -- round-top door + step + tiny window
  local dr = Rm(47, 52, 51, 57):add(E(49, 52, 2, 2))
  rim(dr, DARKW.deep) fm(dr, DARKW.base) fm(Rm(50, 51, 51, 57):clip(dr), DARKW.shade) px(47, 51, DARKW.hi)
  px(50, 55, P.gold.base)
  fm(Rm(46, 57, 52, 57), STONE.base) px(46, 57, STONE.hi)
  local w = E(44, 49, 1.2, 1.2) fm(w, P.gold.hi) px(44, 49, P.gold.base)
end

------------------------------------------------------------------ SCARECROW with a teapot hat (quirk)
do
  local post = Rm(111, 44, 111, 57)
  local arms = Rm(104, 46, 118, 46)
  local shirt = c:poly{ { 108, 45 }, { 114, 45 }, { 115, 52 }, { 107, 52 } }
  local head = E(111, 42, 2.5, 2.5)
  local pot = E(111, 38, 3.5, 2.5):add(Rm(109, 35, 113, 36))
  local spout = c:line({ { 114, 38 }, { 117, 35 } }, 1)
  local handle = Rm(106, 37, 107, 39)
  local all = post:copy():add(arms):add(shirt):add(head):add(pot):add(spout):add(handle)
  rim(all, "#5a4a5a")
  fm(post, WOOD.shade) fm(arms, WOOD.base)
  form(shirt, TEAL, { s = 1, l = 1 }) fm(Rm(112, 48, 113, 49), P.ember.base) px(109, 47, P.gold.base)
  for _, s in ipairs({ 103, 119 }) do px(s, 46, P.gold.base) px(s, 47, P.gold.hi) end
  px(108, 53, P.gold.base) px(111, 53, P.gold.base) px(114, 53, P.gold.base) px(110, 54, P.gold.hi)
  form(head, { hi = "#ffe9b0", base = "#f2cf7a", shade = "#d1a34e", deep = "#8f6a2e" }, { s = 1 })
  px(110, 42, INK) px(112, 42, INK) px(111, 43, "#8f6a2e")
  form(pot, { hi = P.cream, base = "#e8f2f4", shade = "#a8c8d8", deep = "#5f7a9a" }, { s = 1, l = 1 })
  px(110, 38, P.sea.shade) px(112, 38, P.sea.shade) px(111, 39, P.sea.base) -- blue china pattern
  fm(spout, "#c8dce6") fm(handle, "#a8c8d8") px(111, 34, "#5f7a9a") px(109, 37, P.cream)
end

------------------------------------------------------------------ COTTAGES (row of three, thatched)
local function cottage(x0, x1, base, wallH, top, o)
  o = o or {}
  local wy = base - wallH
  local mid = floor((x0 + x1) / 2)
  local wall = Rm(x0 + 2, wy, x1 - 2, base)
  local roof = c:poly{ { x0 - 3, wy + 3 }, { x0 + 1, top + 6 }, { mid - 3, top }, { mid + 3, top }, { x1 - 1, top + 6 }, { x1 + 3, wy + 3 } }
  local chim = o.ch and Rm(o.ch, top - 2, o.ch + 3, top + 8) or HP.mask()
  local all = wall:copy():add(roof):add(chim)
  rim(all, "#5a3c2a")
  form(wall, WALL, { s = 0 })
  fm(Rm(x1 - 5, wy, x1 - 2, base), WALL.shade)
  fm(Rm(x0 + 2, base - 1, x1 - 2, base), STONE.base) for x = x0 + 2, x1 - 2, 3 do px(x, base, STONE.shade) end
  fm(Rm(x0 + 2, base - 1, x0 + 3, base), STONE.hi)
  -- timber corners + eave shadow
  fm(Rm(x0 + 2, wy, x0 + 2, base - 2), WOOD.shade) fm(Rm(x1 - 2, wy, x1 - 2, base - 2), WOOD.deep)
  fm(Rm(x0 + 3, wy + 4, x1 - 3, wy + 4), WALL.deep)
  if o.ch then
    form(chim, STONE, { s = 0 })
    for y = top - 1, top + 8, 2 do fm(Rm(o.ch, y, o.ch + 3, y), STONE.shade) end
    fm(Rm(o.ch - 1, top - 3, o.ch + 4, top - 2), STONE.deep)
    for i, s in ipairs({ { o.ch + 2, top - 6, 1.5 }, { o.ch, top - 10, 2 }, { o.ch - 3, top - 14, 2.5 } }) do
      local m = E(s[1], s[2], s[3], s[3] * .8) fm(m, STONE.hi) m:each(function(x, y) if not m:has(x + 1, y + 1) then px(x, y, STONE.base) end end)
    end
  end
  thatch(roof, mid)
  -- door (round top) on one side, window on the other
  local dx = o.doorX or (x0 + 4)
  local door = Rm(dx, base - 7, dx + 4, base - 1):add(E(dx + 2, base - 7, 2, 2))
  rim(door, WOOD.deep) form(door, o.doorR or TEAL, { s = 0 }) fm(Rm(dx + 3, base - 9, dx + 4, base - 1):clip(door), (o.doorR or TEAL).shade)
  px(dx + 3, base - 4, P.gold.hi)
  local wx = o.winX or (x1 - 9)
  local win = Rm(wx, wy + 6, wx + 4, wy + 9)
  rim(win, WOOD.deep) fm(win, P.gold.base) fm(Rm(wx, wy + 6, wx + 1, wy + 7), P.gold.hi) fm(Rm(wx + 3, wy + 6, wx + 4, wy + 9), P.gold.shade)
  fm(Rm(wx + 2, wy + 6, wx + 2, wy + 9), WOOD.deep)
  fm(Rm(wx - 1, wy + 10, wx + 5, wy + 10), WOOD.shade)
  for k = 0, 3 do px(wx + k * 2 - 1 + 1, wy + 10 - 1 + 0, k % 2 == 0 and P.petal.base or P.ember.base) end
  if o.round then -- round attic window in the thatch
    local rw = E(mid, top + 8, 1.5, 1.5) rim(rw, TH.deep) fm(rw, P.gold.base) px(mid - 1, top + 7, P.gold.hi)
  end
end
cottage(145, 162, 61, 10, 38, { ch = 156, doorX = 148, winX = 154, doorR = WOOD })
cottage(128, 147, 64, 11, 39, { doorX = 131, winX = 139, round = true, doorR = TEAL })
cottage(162, 179, 63, 10, 40, { ch = 165, doorX = 172, winX = 165, doorR = { hi = "#ff8a5c", base = "#e8493b", shade = "#b52e3f", deep = "#6e2038" } })
-- a rose bush between cottages + picket fence bit
for _, b in ipairs({ { 148, 62 }, { 161, 63 } }) do
  local m = E(b[1], b[2], 2.5, 2) fm(m, P.moss.shade) px(b[1] - 1, b[2] - 1, P.moss.base) px(b[1], b[2] - 1, P.petal.base) px(b[1] + 1, b[2], P.ember.base)
end

------------------------------------------------------------------ FORAGE PATCH (berry bushes, mushrooms, herbs)
do
  shadow(E(30, 71, 16, 2), .82)
  -- lavender + rosemary sprigs (back)
  for i, x in ipairs({ 42, 44, 46, 18 }) do
    local top = 55 + (i * 3) % 5
    fm(Rm(x, top, x, 69), P.moss.shade)
    for y = top, top + 5 do if y % 2 == 0 then px(x - 1, y, "#9a86d8") px(x + 1, y, P.dusk.base) else px(x, y, "#b8a4ea") end end
    px(x - 1, 64, P.moss.base) px(x + 1, 66, P.moss.base)
  end
  local function bush(cx, cy, rx, ry, berry, seed)
    local sh = E(cx, cy, rx, ry)
    local hull = foliage(sh, function() return OAK end, { r = 3, step = 4, seed = seed, inner = OAK.deep, rimc = "#24463c",
      lit = function(x, y) return x - cx + y - cy < -2 end, dark = function(x, y) return y > cy + ry - 3 end })
    for i = 0, 9 do
      local bx, by = cx - rx + 1 + hash(i, seed) % (2 * rx - 1), cy - ry + 2 + hash(seed, i) % (2 * ry - 2)
      if hull:has(bx, by) and hull:has(bx + 1, by + 1) then
        px(bx, by, berry.base) px(bx + 1, by, berry.shade) px(bx, by + 1, berry.shade) px(bx + 1, by + 1, berry.deep) px(bx, by, berry.hi)
      end
    end
  end
  bush(26, 59, 9, 8, P.ember, 11)
  bush(38, 63, 7, 6, P.dusk, 23)
  -- mushrooms
  local function shroom(x, y, s, R)
    local cap = E(x, y - s, s + 1, s * 0.7):clip(Rm(x - s - 2, y - 2 * s, x + s + 2, y - s + 1))
    local st = Rm(x - floor(s / 3), y - s + 1, x + floor(s / 3), y)
    local m = cap:copy():add(st)
    rim(m, R.deep) form(st, WALL, { s = 1 }) form(cap, R, { s = 1, l = 1 })
    if R == P.ember then px(x - 1, y - s - 1, P.cream) px(x + 1, y - s, P.cream) end
  end
  shroom(18, 71, 3, P.ember) shroom(23, 72, 2, P.ember) shroom(33, 71, 2, WOOD)
  -- a little basket of picked berries
  local bk = c:poly{ { 38, 68 }, { 45, 68 }, { 44, 72 }, { 39, 72 } }
  rim(bk, WOOD.deep) form(bk, WOOD, { s = 1 }) for y = 69, 71, 2 do fm(Rm(39, y, 44, y):clip(bk), WOOD.shade) end
  fm(c:line({ { 38, 68 }, { 41, 65 }, { 45, 68 } }, 1), WOOD.shade)
  for _, b in ipairs({ { 40, 67 }, { 42, 67 }, { 43, 66 } }) do px(b[1], b[2], P.ember.base) end px(40, 66, P.ember.hi)
end

------------------------------------------------------------------ SEED SWAP shelf-cart (packets + seedling pots)
do
  shadow(E(62, 70, 11, 1.5), .8)
  local posts = Rm(54, 47, 55, 68):add(Rm(69, 47, 70, 68))
  local back = Rm(56, 48, 68, 62)
  local roof = c:poly{ { 51, 44 }, { 73, 44 }, { 71, 48 }, { 53, 48 } }
  local sh1, sh2, sh3 = Rm(55, 54, 69, 55), Rm(55, 61, 69, 62), Rm(55, 67, 69, 68)
  local all = posts:copy():add(back):add(roof):add(sh1):add(sh2):add(sh3)
  rim(all, DARKW.deep)
  fm(back, DARKW.base) for x = 57, 68, 3 do fm(Rm(x, 48, x, 62), DARKW.shade) end
  form(posts, WOOD, { s = 0 }) fm(Rm(55, 47, 55, 68), WOOD.shade) fm(Rm(70, 47, 70, 68), WOOD.shade)
  -- striped roof (moss / cream)
  roof:each(function(x, y) px(x, y, ((x - 51) // 3) % 2 == 0 and P.moss.base or P.cream) end)
  roof:each(function(x, y) if y == 47 then px(x, y, ((x - 51) // 3) % 2 == 0 and P.moss.shade or "#dcd0b0") end end)
  px(53, 44, P.moss.hi) px(54, 44, P.moss.hi)
  for _, s in ipairs({ sh1, sh2, sh3 }) do form(s, WOOD, { s = 0 }) local x0, y0, x1, y1 = s:bbox() fm(Rm(x0, y1, x1, y1), WOOD.shade) end
  -- seed packets (top + middle shelf)
  local PK = { P.ember, P.gold, P.petal, P.sky, P.moss, P.dusk, ORANGE or PUMP }
  local k = 0
  for _, row in ipairs({ { 49, 53 }, { 56, 60 } }) do
    local x = 56
    while x <= 66 do
      k = k + 1
      local R = PK[k % 7 + 1]
      local tilt = (k % 3 == 0) and 1 or 0
      local pk = Rm(x, row[1] + tilt, x + 2, row[2])
      fm(pk, R.base) fm(Rm(x, row[1] + tilt, x + 2, row[1] + tilt), P.cream) px(x + 2, row[2], R.shade) px(x + 2, row[2] - 1, R.shade)
      px(x + 1, row[1] + 2 + tilt, R.hi) px(x + 1, row[1] + 3 + tilt, R.deep)
      x = x + 4
    end
  end
  -- seedling pots on the bottom shelf
  for i, x in ipairs({ 56, 61, 66 }) do
    local pot = c:poly{ { x, 64 }, { x + 3, 64 }, { x + 3, 66 }, { x, 66 } }
    fm(pot, TERRA.base) fm(Rm(x, 64, x + 3, 64), TERRA.hi) px(x + 3, 65, TERRA.shade) px(x + 3, 66, TERRA.shade)
    fm(Rm(x + 1, 61 + (i % 2), x + 1, 63), P.moss.shade)
    px(x, 61 + (i % 2), P.moss.base) px(x + 2, 61 + (i % 2), P.moss.hi) px(x + 2, 62 + (i % 2), P.moss.base)
  end
  -- tiny watering can on the ground
  local can = Rm(48, 66, 51, 69) rim(can, TEAL.deep) form(can, TEAL, { s = 1 }) px(48, 66, TEAL.hi)
  fm(c:line({ { 52, 68 }, { 53, 66 } }, 1), TEAL.shade) px(50, 65, TEAL.shade)
end

------------------------------------------------------------------ SNAIL MAILBOX (quirk) in front of the left cottage
do
  local post = Rm(137, 65, 137, 73)
  local shell = E(139, 61, 3.5, 3.5)
  local foot = c:poly{ { 131, 64 }, { 144, 64 }, { 143, 66 }, { 132, 66 } }
  local head = E(132, 62, 1.5, 2)
  local stalks = Rm(131, 58, 131, 60):add(Rm(133, 58, 133, 60))
  local all = post:copy():add(shell):add(foot):add(head):add(stalks)
  rim(all, "#4a2c3a")
  fm(post, WOOD.shade)
  form(foot, { hi = "#c4d8a0", base = "#9cbc7a", shade = "#6e9a5a", deep = "#3e6a4a" }, { s = 1 })
  form(head, { hi = "#c4d8a0", base = "#9cbc7a", shade = "#6e9a5a", deep = "#3e6a4a" }, { s = 0 })
  fm(stalks, "#6e9a5a") px(131, 57, INK) px(133, 57, INK)
  form(shell, P.petal, { s = 1, l = 1 })
  -- spiral
  for _, q in ipairs({ { 139, 59 }, { 141, 60 }, { 141, 62 }, { 139, 63 }, { 137, 62 }, { 138, 61 } }) do px(q[1], q[2], P.petal.deep) end
  px(139, 61, P.petal.hi)
  -- a letter sticking out of the shell mouth + flag
  fm(Rm(141, 63, 144, 64), P.cream) px(144, 63, "#e2d8c0")
  fm(Rm(143, 57, 143, 60), STONE.shade) fm(Rm(144, 57, 145, 58), P.ember.base)
end

------------------------------------------------------------------ NOTICE BOARD
do
  shadow(E(188, 77, 10, 1.5), .8)
  local posts = Rm(181, 51, 182, 77):add(Rm(194, 51, 195, 77))
  local board = Rm(179, 54, 197, 68)
  local roof = c:poly{ { 176, 53 }, { 188, 48 }, { 200, 53 }, { 200, 54 }, { 176, 54 } }
  local all = posts:copy():add(board):add(roof)
  rim(all, DARKW.deep)
  form(posts, WOOD, { s = 0 }) fm(Rm(182, 51, 182, 77), WOOD.shade) fm(Rm(195, 51, 195, 77), WOOD.shade)
  form(board, WOOD, { s = 0 })
  for y = 57, 68, 4 do fm(Rm(179, y, 197, y), WOOD.shade) end
  fm(Rm(179, 54, 179, 68), WOOD.hi) fm(Rm(197, 54, 197, 68), WOOD.shade) fm(Rm(179, 68, 197, 68), WOOD.deep)
  roof:each(function(x, y) px(x, y, (y % 2 == 0) and TH.base or TH.shade) if x < 188 and y % 2 == 0 then px(x, y, TH.hi) end end)
  fm(Rm(176, 54, 200, 54), TH.deep)
  -- pinned papers (blank), each with a coloured pin and a folded corner
  local function paper(x, y, w, h, col, pin)
    local m = Rm(x, y, x + w - 1, y + h - 1)
    rim(m:copy():shift(1, 1):cut(m), WOOD.deep)
    fm(m, col) fm(Rm(x, y + h - 1, x + w - 1, y + h - 1), D(col, .9))
    px(x + w - 1, y + h - 1, WOOD.shade) px(x + w - 2, y + h - 1, D(col, .8))
    px(x + floor(w / 2), y, pin)
  end
  paper(181, 56, 6, 5, P.cream, P.ember.base)
  paper(188, 55, 5, 6, P.petal.hi, P.sea.shade)
  paper(184, 62, 5, 5, P.sky.hi, P.gold.shade)
  paper(191, 62, 5, 4, P.gold.hi, P.moss.shade)
  paper(193, 57, 3, 3, "#e8f0d8", P.ember.base)
end

------------------------------------------------------------------ WILD TRAIL foreground ferns at the trail mouth (right)
for _, f in ipairs({ { 199, 74 }, { 210, 70 } }) do
  for k = -3, 3 do px(f[1] + k, f[2] - 2 + abs(k) // 2, P.moss.base) px(f[1] + k, f[2] - 1 + abs(k) // 2, P.moss.shade) end
  px(f[1], f[2] - 3, P.moss.hi) px(f[1] - 1, f[2] - 3, P.moss.hi)
end

------------------------------------------------------------------ TRADER WAGON (striped awning, goods, baskets)
do
  shadow(E(89, 84, 19, 2.5), .78)
  local body = Rm(73, 63, 103, 76)
  local counter = Rm(71, 61, 105, 63)
  local posts = Rm(73, 50, 74, 61):add(Rm(102, 50, 103, 61))
  local awn = c:poly{ { 69, 46 }, { 107, 46 }, { 109, 53 }, { 67, 53 } }
  local cap = E(88, 46, 19, 3):clip(Rm(60, 40, 120, 46))
  local scal = HP.mask()
  for x = 67, 107, 4 do scal:add(E(x + 1.5, 53, 2, 1.5):clip(Rm(60, 53, 120, 55))) end
  local all = body:copy():add(counter):add(posts):add(awn):add(cap):add(scal)
  rim(all, "#3e2430")
  -- shelf behind the counter: jars and hanging peppers
  fm(Rm(75, 54, 101, 60), DARKW.shade)
  fm(Rm(75, 57, 101, 57), DARKW.deep)
  for i, x in ipairs({ 76, 80, 84, 92, 96, 99 }) do
    local R = ({ P.gold, P.ember, P.moss, P.petal, P.sea, P.dusk })[i]
    fm(Rm(x, 54, x + 1, 56), R.base) px(x, 54, R.hi) px(x + 1, 56, R.shade) px(x, 53, P.cream)
  end
  form(posts, WOOD, { s = 0 })
  -- body: teal painted planks with wood trim, a wheel arch and a gold scroll
  form(body, TEAL, { s = 0 })
  for x = 76, 102, 4 do fm(Rm(x, 64, x, 75), TEAL.shade) end
  fm(Rm(73, 64, 73, 76), TEAL.hi)
  fm(Rm(73, 75, 103, 76), DARKW.base) fm(Rm(73, 76, 103, 76), DARKW.deep)
  fm(Rm(98, 63, 103, 76), TEAL.shade)
  for _, q in ipairs({ { 84, 69 }, { 85, 68 }, { 86, 68 }, { 87, 69 }, { 88, 70 }, { 89, 70 }, { 90, 69 }, { 91, 68 }, { 92, 68 }, { 93, 69 } }) do px(q[1], q[2], P.gold.base) end
  px(88, 71, P.gold.hi)
  -- counter flap
  form(counter, WOOD, { s = 0 }) fm(Rm(71, 63, 105, 63), WOOD.shade) fm(Rm(71, 61, 105, 61), WOOD.hi)
  -- goods on the counter: apple basket, honey jars, cloth bolts
  local bsk = c:poly{ { 75, 58 }, { 83, 58 }, { 82, 61 }, { 76, 61 } }
  rim(bsk, WOOD.deep) form(bsk, WOOD, { s = 1 }) fm(Rm(76, 59, 82, 59), WOOD.shade)
  for _, a in ipairs({ { 77, 57 }, { 79, 56 }, { 81, 57 }, { 79, 58 } }) do
    local m = E(a[1], a[2], 1, 1) fm(m, P.ember.base) px(a[1] - 1, a[2] - 1, P.ember.hi) px(a[1] + 1, a[2] + 1, P.ember.shade)
  end
  for _, x in ipairs({ 86, 89 }) do
    local j = Rm(x, 57, x + 2, 60) rim(j, P.gold.deep) fm(j, P.gold.base) px(x, 58, P.gold.hi) px(x, 59, "#fff0b0") fm(Rm(x + 2, 57, x + 2, 60), P.gold.shade)
    fm(Rm(x, 56, x + 2, 56), P.cream) px(x + 2, 56, "#dcd0b0")
  end
  for i, b in ipairs({ { 94, 58, P.petal }, { 94, 60, P.dusk }, { 99, 59, P.sky } }) do
    local m = Rm(b[1], b[2], b[1] + 4, b[2] + 1) rim(m, b[3].deep) fm(m, b[3].base) fm(Rm(b[1], b[2], b[1] + 4, b[2]), b[3].hi) px(b[1] + 4, b[2] + 1, b[3].shade)
  end
  -- awning: ember / cream stripes, lit left, shaded right, scallops
  local function stripe(x, y) return ((x - 67) // 4) % 2 == 0 end
  awn:each(function(x, y)
    local s = stripe(x, y)
    local col = s and P.ember.base or P.cream
    if x > 98 then col = s and P.ember.shade or "#e8dcc0" end
    if y == 46 then col = s and P.ember.hi or P.cream end
    if y == 52 or y == 53 then col = s and P.ember.shade or "#e2d4b4" end
    px(x, y, col)
  end)
  cap:each(function(x, y) px(x, y, stripe(x, y) and P.ember.hi or P.cream) end)
  scal:each(function(x, y) px(x, y, stripe(x, y) and P.ember.shade or "#d8c8a8") end)
  -- dried peppers hanging from the awning
  for _, x in ipairs({ 78, 97 }) do fm(Rm(x, 54, x, 55), WOOD.deep) px(x, 56, P.ember.base) px(x, 57, P.ember.shade) px(x + 1, 56, P.ember.hi) end
  -- wheels
  wheel(79, 78, 5.5, WOOD, "#3e2430")
  wheel(98, 78, 5.5, WOOD, "#3e2430")
  -- crate of carrots + a pumpkin by the wagon
  local cr = Rm(104, 76, 110, 81) rim(cr, DARKW.deep) form(cr, WOOD, { s = 1 }) fm(Rm(104, 78, 110, 78), WOOD.shade)
  for _, x in ipairs({ 105, 107, 109 }) do px(x, 75, PUMP.base) px(x, 74, P.moss.base) px(x + 1, 74, P.moss.shade) end
  local pk = E(70, 81, 3, 2.2) rim(pk, PUMP.deep) form(pk, PUMP, { s = 1, l = 1 }) px(70, 78, P.moss.shade) fm(Rm(70, 80, 70, 82), PUMP.shade)
end

------------------------------------------------------------------ WISHING WELL (stone, thatched hood, bucket, coins)
do
  shadow(E(121, 87, 13, 2.2), .78)
  local cyl = Rm(110, 74, 130, 85):add(E(120, 85, 10, 2))
  local lip = E(120, 74, 10.5, 3)
  local posts = Rm(111, 61, 112, 74):add(Rm(128, 61, 129, 74))
  local roof = c:poly{ { 106, 63 }, { 114, 57 }, { 126, 57 }, { 134, 63 } }
  local all = cyl:copy():add(lip):add(posts):add(roof)
  rim(all, STONE.deep)
  form(posts, WOOD, { s = 0 }) fm(Rm(112, 61, 112, 74), WOOD.shade) fm(Rm(129, 61, 129, 74), WOOD.shade)
  -- crank axle + rope + hanging bucket
  fm(Rm(111, 65, 129, 65), WOOD.deep) fm(Rm(130, 64, 131, 67), WOOD.shade) px(131, 68, WOOD.deep)
  fm(Rm(120, 66, 120, 69), "#d8c49a")
  local bk = c:poly{ { 117, 69 }, { 123, 69 }, { 122, 73 }, { 118, 73 } }
  rim(bk, "#3e2430") form(bk, WOOD, { s = 1 }) fm(Rm(117, 70, 123, 70), STONE.shade) fm(Rm(118, 72, 122, 72), STONE.shade)
  px(118, 69, WOOD.hi)
  -- stone cylinder: staggered courses, lit left, shaded right, moss tuft
  cyl:each(function(x, y)
    local row = (y - 75) // 3
    local col = STONE.base
    if x < 115 then col = STONE.hi elseif x > 125 then col = STONE.shade end
    if (y - 75) % 3 == 2 then col = (x > 125) and STONE.deep or STONE.shade end
    if ((x + row * 3) % 6 == 0) then col = (x > 125) and STONE.deep or STONE.shade end
    px(x, y, col)
  end)
  cyl:each(function(x, y) if not cyl:has(x, y + 1) then px(x, y, STONE.deep) end end)
  for _, m in ipairs({ { 113, 81 }, { 114, 82 }, { 112, 82 }, { 126, 84 } }) do px(m[1], m[2], P.moss.base) end px(113, 80, P.moss.hi)
  -- lip + dark water opening
  form(lip, STONE, { s = 1, l = 1 })
  local hole = E(120, 74, 8, 1.5) fm(hole, "#2a3a5a") fm(Rm(116, 74, 124, 74):clip(hole), "#3a5a86") px(122, 74, P.sea.hi)
  -- thatched hood
  thatch(roof, 119)
  fm(Rm(108, 63, 132, 63), TH.deep)
  -- coins: on the rim and glinting in the grass around
  for _, q in ipairs({ { 127, 72 }, { 113, 72 }, { 108, 86 }, { 132, 85 } }) do px(q[1], q[2], P.gold.base) px(q[1] + 1, q[2], P.gold.shade) px(q[1], q[2] - 1, P.gold.hi) end
  c:sparkle(127, 70)
  px(110, 84, P.cream)
end

------------------------------------------------------------------ LONG TABLE (bread, jam, cups, pie)
do
  shadow(E(156, 84, 19, 2.5), .78)
  local top = c:poly{ { 142, 69 }, { 170, 69 }, { 173, 73 }, { 139, 73 } }
  local edge = Rm(139, 74, 173, 75)
  local legs = c:line({ { 142, 76 }, { 145, 83 } }, 2):add(c:line({ { 146, 76 }, { 143, 83 } }, 2))
    :add(c:line({ { 166, 76 }, { 169, 83 } }, 2)):add(c:line({ { 170, 76 }, { 167, 83 } }, 2))
  local bench = Rm(140, 79, 172, 80):add(Rm(141, 81, 142, 85)):add(Rm(170, 81, 171, 85))
  local all = top:copy():add(edge):add(legs):add(bench)
  rim(all, "#3e2430")
  form(legs, WOOD, { s = 0 }) legs:each(function(x, y) if (x + y) % 2 == 0 then px(x, y, WOOD.shade) end end)
  form(top, WOOD, { s = 0 })
  top:each(function(x, y) if y == 71 then px(x, y, WOOD.shade) end end)
  fm(edge, WOOD.shade) fm(Rm(139, 75, 173, 75), WOOD.deep)
  -- checked runner hanging over the front edge
  local run = Rm(147, 69, 165, 75):clip(top:copy():add(edge))
  run:add(Rm(147, 76, 165, 76))
  run:each(function(x, y) px(x, y, ((x // 2 + y // 2) % 2 == 0) and P.ember.base or P.cream) end)
  for x = 147, 165, 3 do px(x, 76, P.ember.shade) end
  fm(Rm(147, 74, 165, 74), P.ember.shade)
  form(bench, WOOD, { s = 0 }) fm(Rm(140, 80, 172, 80), WOOD.shade)
  -- loaf
  local loaf = E(145, 68, 3.5, 2) rim(loaf, WOOD.deep) form(loaf, { hi = "#f2c47c", base = "#d89a52", shade = "#b06e3a", deep = "#6e3e2a" }, { s = 1, l = 1 })
  px(144, 67, "#ffe0a0") px(146, 68, "#b06e3a") px(147, 67, "#b06e3a")
  -- jam jars (strawberry, plum)
  for _, j in ipairs({ { 151, 66, P.ember }, { 163, 66, P.dusk } }) do
    local m = Rm(j[1], j[2], j[1] + 2, j[2] + 3) rim(m, j[3].deep) fm(m, j[3].base) px(j[1], j[2] + 1, j[3].hi) fm(Rm(j[1] + 2, j[2], j[1] + 2, j[2] + 3), j[3].shade)
    fm(Rm(j[1] - 1, j[2] - 1, j[1] + 3, j[2] - 1), P.cream) fm(Rm(j[1], j[2] - 1, j[1] + 2, j[2] - 1), P.petal.hi)
  end
  -- pie with lattice
  local pie = E(157, 68, 3.5, 1.5) rim(pie, WOOD.deep) fm(pie, "#e8b06a") px(155, 68, "#a83a4a") px(157, 67, "#a83a4a") px(159, 68, "#a83a4a") px(156, 67, "#ffd890")
  -- cups
  for _, x in ipairs({ 168, 141 }) do
    local m = Rm(x, 67, x + 1, 69) rim(m, P.sea.deep) fm(m, P.cream) px(x + 1, 69, "#d8d0c0") px(x + 2, 68, P.sea.shade)
  end
  px(168, 66, STONE.hi) -- steam
end

------------------------------------------------------------------ REST BENCH (cushions, quilt, teapot on a stump)
do
  shadow(E(46, 92, 16, 2), .78)
  -- stump + teapot
  local stump = Rm(26, 84, 33, 92)
  rim(stump:copy():add(E(29.5, 84, 4, 1.5)), BARK.deep)
  form(stump, BARK, { s = 1 }) for x = 27, 33, 2 do fm(Rm(x, 86, x, 91), BARK.shade) end fm(Rm(26, 85, 26, 92), BARK.hi)
  local top = E(29.5, 84, 4, 1.5) fm(top, "#e8c48e") px(29, 84, "#c9a06a") px(30, 84, "#c9a06a") px(27, 84, "#f2d8a8")
  local pot = E(29, 80, 3, 2.5)
  local spout = c:line({ { 32, 80 }, { 34, 77 } }, 1)
  local handle = Rm(25, 79, 25, 81)
  local lid = Rm(28, 77, 30, 77)
  local tp = pot:copy():add(spout):add(handle):add(lid)
  rim(tp, P.ember.deep)
  form(pot, P.ember, { s = 1, l = 1 }) fm(spout, P.ember.shade) fm(handle, P.ember.shade) fm(lid, P.ember.hi) px(29, 76, P.gold.base)
  px(28, 81, P.cream) px(30, 79, P.cream) -- polka dots
  px(35, 75, P.cream) px(36, 74, P.cream) px(35, 73, P.cream) -- steam curl
  -- bench
  local bposts = Rm(37, 73, 38, 91):add(Rm(58, 73, 59, 91))
  local slats = Rm(37, 74, 59, 75):add(Rm(37, 77, 59, 78))
  local seat = Rm(35, 82, 61, 84)
  local legs = Rm(36, 85, 37, 91):add(Rm(59, 85, 60, 91))
  local all = bposts:copy():add(slats):add(seat):add(legs)
  rim(all, "#3e2430")
  form(bposts, WOOD, { s = 0 }) form(legs, WOOD, { s = 0 }) fm(Rm(38, 73, 38, 91), WOOD.shade) fm(Rm(59, 73, 59, 91), WOOD.shade)
  form(slats, WOOD, { s = 0 }) fm(Rm(37, 75, 59, 75), WOOD.shade) fm(Rm(37, 78, 59, 78), WOOD.shade)
  form(seat, WOOD, { s = 0 }) fm(Rm(35, 82, 61, 82), WOOD.hi) fm(Rm(35, 84, 61, 84), WOOD.deep)
  px(36, 82, P.cream) px(37, 82, WOOD.hi)
  -- cushions (tufted)
  for _, cu in ipairs({ { 47, 80, P.petal }, { 55, 80, P.sea } }) do
    local m = E(cu[1], cu[2], 4, 2.2) rim(m, cu[3].deep) form(m, cu[3], { s = 1, l = 1 })
    px(cu[1], cu[2], cu[3].deep) px(cu[1] - 2, cu[2] - 1, cu[3].hi)
  end
  -- patchwork quilt draped over the left end
  local q = c:poly{ { 35, 73 }, { 44, 73 }, { 44, 84 }, { 42, 89 }, { 38, 90 }, { 35, 88 } }
  rim(q, "#4a2c3a")
  local QC = { P.gold.base, P.petal.base, P.sky.shade, P.moss.base, P.cream, P.ember.base }
  q:each(function(x, y)
    local k = ((x - 35) // 3) + ((y - 73) // 3) * 2
    local col = QC[k % 6 + 1]
    if (x - 35) % 3 == 2 or (y - 73) % 3 == 2 then col = D(col, .82) end
    if x > 42 then col = D(col, .86) end
    px(x, y, col)
  end)
  for y = 76, 88, 3 do px(35, y, P.gold.hi) end -- stitched hem
end

------------------------------------------------------------------ SIGN pointing both ways (quirk)
do
  shadow(E(66, 96, 4, 1), .8)
  local post = Rm(65, 79, 66, 96)
  local plank = c:poly{ { 57, 81 }, { 60, 78 }, { 71, 78 }, { 74, 81 }, { 71, 84 }, { 60, 84 } }
  local all = post:copy():add(plank)
  rim(all, "#3e2430")
  form(post, GREYW, { s = 0 }) fm(Rm(66, 79, 66, 96), GREYW.shade)
  form(plank, WOOD, { s = 0 })
  fm(Rm(60, 79, 71, 79), WOOD.hi) fm(Rm(60, 83, 71, 83), WOOD.shade) px(58, 82, WOOD.shade) px(73, 82, WOOD.shade) px(59, 83, WOOD.shade)
  fm(Rm(62, 81, 69, 81), WOOD.shade) px(63, 81, WOOD.base) -- grain
  px(61, 80, STONE.base) px(70, 80, STONE.base) -- nails
  -- a little flower tied to the post
  px(67, 88, P.petal.base) px(67, 87, P.petal.hi) px(68, 88, P.moss.base)
end

------------------------------------------------------------------ POND props: reeds, jetty, propped rod
do
  for i, x in ipairs({ 194, 196, 198, 225, 227 }) do
    local top = 80 + (i * 5) % 5
    fm(Rm(x, top, x, 91), P.moss.shade) px(x, top - 1, P.moss.shade)
    if i % 2 == 1 then local h = Rm(x, top + 1, x + 1, top + 4) fm(h, WOOD.shade) px(x, top + 1, WOOD.base) px(x + 1, top + 4, WOOD.deep) end
    fm(c:line({ { x, 89 }, { x + (i % 2 == 0 and -2 or 2), 83 } }, 1), P.moss.base)
  end
  -- jetty: planks from the near bank out into the pond
  local deck = c:poly{ { 212, 87 }, { 219, 87 }, { 223, 101 }, { 208, 101 } }
  local postsJ = Rm(212, 87, 212, 90):add(Rm(219, 87, 219, 90)):add(Rm(209, 101, 210, 103)):add(Rm(221, 101, 222, 103))
  shadow(c:poly{ { 213, 88 }, { 221, 88 }, { 222, 92 }, { 211, 92 } }:clip(pond), .75)
  local all = deck:copy():add(postsJ)
  rim(all, "#3e2430")
  fm(postsJ, DARKW.shade)
  deck:each(function(x, y)
    local col = GREYW.base
    if (y - 87) % 2 == 1 then col = GREYW.shade end
    if x < 211 + (y - 87) * -0.25 + 1 then col = GREYW.hi end
    if hash(x, y) % 13 == 0 then col = GREYW.deep end
    px(x, y, col)
  end)
  -- tackle box + bucket on the jetty
  local tb = Rm(211, 96, 214, 98) rim(tb, P.ember.deep) form(tb, P.ember, { s = 1 }) fm(Rm(211, 96, 214, 96), P.ember.hi)
  -- rod propped on a forked stick, line to a bobber with a ripple
  fm(c:line({ { 220, 99 }, { 202, 80 } }, 1), WOOD.deep)
  px(219, 97, STONE.hi) px(218, 97, STONE.base)
  fm(c:line({ { 216, 99 }, { 216, 95 } }, 1), WOOD.shade) px(215, 94, WOOD.shade) px(217, 94, WOOD.shade)
  fm(c:line({ { 202, 80 }, { 201, 85 }, { 201, 89 } }, 1), STONE.hi)
  px(201, 89, P.ember.base) px(201, 90, P.cream)
  for _, q in ipairs({ { 198, 91 }, { 199, 91 }, { 203, 91 }, { 204, 91 }, { 200, 92 }, { 202, 92 } }) do px(q[1], q[2], P.sea.hi) end
end

------------------------------------------------------------------ GATE: oak trunk (left post), beanstalk, wheelbarrow, fence
do
  -- oak trunk with flaring roots
  local trunk = c:poly{ { -1, 0 }, { 12, 0 }, { 12, 30 }, { 13, 60 }, { 14, 92 }, { 15, 104 }, { 17, 113 }, { 23, 120 }, { 26, 123 }, { -1, 123 } }
  local branch = c:line({ { 10, 30 }, { 24, 34 }, { 40, 34 } }, 3)
  local tr = trunk:copy():add(branch)
  rim(tr, BARK.deep)
  form(tr, BARK, { s = 3, l = 2 })
  for k = 0, 3 do
    local pts = {}
    for y = 4, 120, 3 do
      local spread = y > 100 and (y - 100) * (k - 1) * 0.15 or 0
      pts[#pts + 1] = { 2 + k * 3 + spread + 1.2 * sin(y / 7 + k), y }
    end
    local ln = c:line(pts, 1):clip(trunk:shrink(1))
    ln:each(function(x, y) if hash(x * 7 + k, y) % 7 ~= 0 then
      local was = c:get(x, y)
      px(x, y, was == BARK.shade:lower() and BARK.deep or BARK.shade)
      if c:get(x - 1, y) == BARK.base:lower() and hash(y, k) % 3 == 0 then px(x - 1, y, BARK.hi) end
    end end)
  end
  -- knot hole
  local kn = E(7, 70, 2, 3) fm(kn, BARK.deep) px(7, 71, "#2a1a20") px(6, 68, BARK.hi)
  -- moss on the root flare
  for x = 0, 22 do if trunk:has(x, 118) and hash(x, 3) % 3 ~= 0 then px(x, 117 + hash(x, 5) % 3, x < 12 and P.moss.base or P.moss.shade) end end
  -- beanstalk climbing out of the wheelbarrow and up the trunk
  local stalk = {}
  for _, p in ipairs({ { 27, 115 }, { 21, 112 }, { 16, 106 }, { 12, 99 }, { 14, 91 }, { 10, 84 }, { 13, 76 }, { 9, 68 }, { 12, 60 }, { 8, 52 }, { 11, 44 }, { 9, 38 } }) do stalk[#stalk + 1] = p end
  local st = c:line(stalk, 2)
  rim(st, OAK.deep) fm(st, OAK.base)
  st:each(function(x, y) if not st:has(x + 1, y) then px(x, y, OAK.shade) end end)
  for i, p in ipairs(stalk) do
    if i > 1 and i < #stalk then
      local s = (i % 2 == 0) and 1 or -1
      local lx, ly = p[1] + s * 4, p[2] - 1
      local lf = E(lx, ly, 2.5, 2):add(c:poly{ { lx - s * 2, ly - 1 }, { lx + s * 3, ly - 3 }, { lx + s * 2, ly } })
      rim(lf, OAK.deep) form(lf, OAKL, { s = 1, l = 1 }) px(lx, ly, OAKL.shade)
      if i % 3 == 0 then px(p[1] - s * 2, p[2] - 2, OAK.hi) px(p[1] - s * 3, p[2] - 3, OAK.base) end -- tendril
    end
  end
  local pod = c:line({ { 17, 94 }, { 19, 98 } }, 1) fm(pod, OAKL.base) px(18, 95, OAKL.hi)
  -- wheelbarrow of pumpkins
  local tray = c:poly{ { 17, 121 }, { 40, 121 }, { 37, 129 }, { 21, 129 } }
  local wh = E(41, 130, 4, 4)
  local leg = Rm(21, 129, 22, 134)
  local handle = c:line({ { 19, 124 }, { 5, 131 } }, 2)
  local wb = tray:copy():add(wh):add(leg):add(handle)
  rim(wb, TEAL.deep)
  form(handle, WOOD, { s = 0 }) fm(leg, WOOD.shade)
  form(tray, TEAL, { s = 2, deep = true }) fm(Rm(17, 121, 40, 121), TEAL.hi)
  for x = 22, 36, 5 do px(x, 125, TEAL.deep) end
  form(wh, STONE, { s = 1 }) fm(E(41, 130, 1, 1), STONE.deep) px(39, 128, STONE.hi)
  for _, p in ipairs({ { 22, 119, 4 }, { 30, 118, 5 }, { 37, 120, 3 } }) do
    local m = E(p[1], p[2], p[3], p[3] * 0.75):cut(Rm(0, 122, 60, 135))
    rim(m, PUMP.deep) form(m, PUMP, { s = 1, l = 1 })
    fm(c:line({ { p[1], p[2] - floor(p[3] * .6) }, { p[1], p[2] + 1 } }, 1):clip(m:shrink(1)), PUMP.shade)
    px(p[1] + 1, p[2] - floor(p[3] * .75) - 1, P.moss.shade)
  end
  -- low rustic fence on the bottom-left
  local fence = c:line({ { 44, 124 }, { 86, 125 } }, 2):add(c:line({ { 44, 129 }, { 86, 130 } }, 2))
  for _, x in ipairs({ 46, 64, 82 }) do fence:add(Rm(x, 119 + (x - 46) // 30, x + 2, 135)) end
  rim(fence, GREYW.deep)
  form(fence, GREYW, { s = 0 })
  for _, x in ipairs({ 46, 64, 82 }) do fm(Rm(x + 2, 120, x + 2, 135), GREYW.shade) px(x, 119 + (x - 46) // 30, GREYW.hi) end
  fm(c:line({ { 44, 125 }, { 86, 126 } }, 1), GREYW.shade) fm(c:line({ { 44, 130 }, { 86, 131 } }, 1), GREYW.shade)
  -- foreground grass + flowers along the bottom-left edge
  for i = 0, 40 do
    local x, y = hash(i, 701) % 84, 128 + hash(i, 703) % 7
    if not dirt:has(x, y) then tuft(x, y, 4 + hash(i, 705) % 3) end
  end
  for _, f in ipairs({ { 52, 127 }, { 58, 131 }, { 72, 128 }, { 12, 128 } }) do px(f[1], f[2], P.petal.base) px(f[1] + 1, f[2], P.petal.hi) px(f[1], f[2] + 1, P.moss.shade) end
  px(76, 132, P.cream) px(77, 132, P.gold.base)
end

------------------------------------------------------------------ GATE: right log post, beam, knee brace, ivy
do
  local post = Rm(230, 0, 239, 110)
  local foot = E(234, 111, 7, 3):clip(Rm(220, 100, 240, 114))
  local beam = Rm(178, 2, 239, 7)
  local brace = c:line({ { 230, 30 }, { 212, 8 } }, 3)
  local all = post:copy():add(beam):add(brace)
  shadow(E(232, 114, 9, 1):clip(Rm(220, 113, 240, 114)), .8)
  rim(foot, STONE.deep) form(foot, STONE, { s = 1, l = 1 }) fm(Rm(229, 110, 239, 110), STONE.shade)
  rim(all, BARK.deep)
  form(brace, BARK, { s = 1, l = 1 })
  form(beam, BARK, { s = 0 }) fm(Rm(178, 2, 239, 2), BARK.hi) fm(Rm(178, 6, 239, 7), BARK.shade) fm(Rm(178, 7, 239, 7), BARK.deep)
  for x = 182, 236, 7 do px(x, 4, BARK.shade) px(x + 1, 4, BARK.shade) end
  -- cut end grain on the beam
  local eg = Rm(178, 2, 179, 7) fm(eg, "#e8c48e") px(178, 4, "#c9a06a") px(179, 5, "#c9a06a")
  form(post, BARK, { s = 0 })
  fm(Rm(230, 0, 231, 110), BARK.hi) fm(Rm(236, 0, 239, 110), BARK.shade) fm(Rm(239, 0, 239, 110), BARK.deep)
  for y = 3, 108, 5 do local x = 232 + hash(y, 9) % 4 px(x, y, BARK.shade) px(x, y + 1, BARK.shade) px(x - 1, y + 2, BARK.deep) end
  fm(Rm(230, 8, 239, 8), BARK.deep) -- joint under the beam
  -- ivy twisting up the post
  for y = 108, 34, -3 do
    local x = 232 + floor(2.5 * sin(y / 6))
    px(x, y, OAK.deep) px(x, y - 1, OAK.shade)
    if y % 2 == 0 then px(x - 1, y - 1, OAK.base) px(x - 2, y - 1, OAK.hi) else px(x + 1, y, OAK.base) px(x + 2, y - 1, OAKL.base) end
  end
  px(233, 60, P.petal.base) px(232, 84, P.cream)
end

------------------------------------------------------------------ OAK CANOPY (top-left corner) + kite stuck in it (quirk)
do
  local sh = HP.mask()
  for _, k in ipairs({ { 8, 6, 22, 14 }, { 34, 2, 20, 10 }, { 58, 4, 16, 9 }, { 76, 0, 10, 6 }, { 14, 24, 16, 10 },
    { 40, 20, 14, 9 }, { 60, 16, 9, 6 }, { 2, 36, 10, 8 }, { 28, 30, 12, 6 }, { 44, 33, 6, 4 } }) do
    sh:add(E(k[1], k[2], k[3], k[4]))
  end
  foliage(sh, function(x, y)
    local v = sin(x / 11 + y / 17) + cos(y / 9 - x / 23)
    return v > 0.8 and OAKL or OAK
  end, { r = 6, step = 7, seed = 50, accent = OAKL.hi, accent2 = "#f2e8a0", inner = "#244a3e", rimc = "#22403a",
    lit = function(x, y) return x + y * 1.3 < 40 end, dark = function(x, y) return y > 30 or (x > 60 and y > 14) end })
  -- acorns
  for _, a in ipairs({ { 30, 37 }, { 50, 26 }, { 20, 32 } }) do px(a[1], a[2], WOOD.shade) px(a[1], a[2] + 1, PUMP.shade) px(a[1] + 1, a[2] + 1, WOOD.base) end
  -- kite: diamond with cross sticks, bow tail dangling
  local kite = c:poly{ { 63, 17 }, { 68, 12 }, { 73, 17 }, { 68, 25 } }
  rim(kite, P.ember.deep)
  kite:each(function(x, y)
    local l, top = x < 68, y < 17
    px(x, y, (l == top) and P.ember.base or P.gold.hi)
  end)
  kite:each(function(x, y) if not kite:has(x + 1, y + 1) then px(x, y, c:get(x, y) == P.ember.base:lower() and P.ember.shade or P.gold.base) end end)
  fm(c:line({ { 68, 12 }, { 68, 25 } }, 1), WOOD.deep) fm(c:line({ { 63, 17 }, { 73, 17 } }, 1), WOOD.deep)
  local tail = { { 68, 25 }, { 70, 28 }, { 68, 31 }, { 71, 34 }, { 69, 37 }, { 72, 40 } }
  fm(c:line(tail, 1), STONE.base)
  for i, t in ipairs({ { 70, 28 }, { 68, 31 }, { 71, 34 }, { 69, 37 } }) do
    local col = (i % 2 == 0) and P.sky.shade or P.petal.base
    px(t[1] - 1, t[2], col) px(t[1] + 1, t[2], col) px(t[1] - 1, t[2] - 1, col) px(t[1] + 1, t[2] + 1, col)
  end
end

------------------------------------------------------------------ PENNANT STRING from the oak to the beam
do
  local x0, y0, x1, y1 = 56, 24, 178, 5
  local pts = {}
  local function sy(x) local t = (x - x0) / (x1 - x0) return y0 + (y1 - y0) * t + 7 * sin(pi * t) end
  for x = x0, x1 do pts[#pts + 1] = { x, sy(x) } end
  fm(c:line(pts, 1), WOOD.deep)
  local cols = { P.ember, P.gold, P.sea, P.petal, P.moss }
  local k = 0
  for x = x0 + 4, x1 - 6, 9 do
    k = k + 1
    local R = cols[k % 5 + 1]
    local y = floor(sy(x + 2) + .5)
    local pen = c:poly{ { x, y + 1 }, { x + 5, y + 1 }, { x + 2.5, y + 6 } }
    fm(pen, R.base)
    pen:each(function(xx, yy) if xx >= x + 3 then px(xx, yy, R.shade) end end)
    px(x + 1, y + 1, R.hi) px(x + 2, y + 1, R.hi)
    px(x + 2, y + 6, R.deep)
  end
end

------------------------------------------------------------------ LANTERN hanging from the beam
do
  local hx = 200
  fm(Rm(hx, 8, hx, 11), STONE.deep) px(hx, 9, STONE.base)
  local capL = c:poly{ { hx - 4, 14 }, { hx, 11 }, { hx + 4, 14 } }
  local body = Rm(hx - 3, 15, hx + 3, 22)
  local bot = Rm(hx - 4, 23, hx + 4, 24)
  local all = capL:copy():add(body):add(bot)
  rim(all, "#3a2a3a")
  fm(capL, "#5a4a5e") px(hx - 1, 12, "#8a7a8e") px(hx - 2, 13, "#8a7a8e")
  fm(body, P.gold.base)
  fm(Rm(hx - 2, 16, hx, 19), "#fff0b0") px(hx - 2, 16, P.cream)
  fm(Rm(hx + 2, 15, hx + 3, 22), P.gold.shade)
  fm(Rm(hx - 3, 15, hx - 3, 22), "#5a4a5e") fm(Rm(hx + 3, 15, hx + 3, 22), "#3a2a3a") fm(Rm(hx, 15, hx, 22), "#5a4a5e")
  fm(Rm(hx - 1, 20, hx + 1, 21), P.ember.base) px(hx, 19, P.gold.hi) -- flame
  fm(bot, "#5a4a5e") fm(Rm(hx - 4, 24, hx + 4, 24), "#3a2a3a")
  px(hx, 25, "#3a2a3a")
  -- warm glow sparkle
  c:sparkle(hx - 6, 17)
end

c:finish{ outline = false }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 2 }
