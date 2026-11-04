-- here-stop-grassland-flat: GRASSLAND ROAD REST STOP, attempt 2A. 480x270 NATIVE (scale 1).
-- View "flat": storybook / board-game diorama. No vanishing point, no foreshortening. Every object front-on,
-- big, in its own pocket of plain ground, set out in 3 loose rows (back row on the hill line, middle, front).
-- A winding dirt road: bottom-left -> rest bench pocket -> up to the back lane -> east to the Wild Trail hedge gap,
-- with a spur from the back lane down past the well to the pond / seed cart pocket.
-- Rows (x ranges, base y):
--   back  (base 110): Cottages 8-148 | snail mailbox | pumpkin wheelbarrow + beanstalk | Notice Board 216-268 |
--                     scarecrow (teapot hat) | oak + caught kite | hedge with Wild Trail gap + signpost 372-480
--   mid   (base 192): Forage Patch 8-74 | Trader Stall 138-208 | Wishing Well 220-274 | Long Table 342-410
--   front (base 262): Rest Bench 18-92 | Fishing Pond 164-250 | Seed Swap cart 318-378 | haystack w/ door (226)
-- Backdrop: sky + puff clouds, bunting between a left post and the tall signpost pole, violet ridge, golden hills
-- with field rows, windmill far away. Bottom-right 380-480 x 230-270 kept as plain meadow (UI icons).
-- quirks: scarecrow with a teapot hat; snail-shaped mailbox; haystack with a tiny door; kite caught in the oak;
--         wheelbarrow of pumpkins sprouting a beanstalk into the clouds.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local NAME = "here-stop-grassland-flat"
local W, H = 480, 270
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local floor, sin, cos, abs, min, max, pi = math.floor, math.sin, math.cos, math.abs, math.min, math.max, math.pi
local function Rm(x0, y0, x1, y1) return c:rect(x0, y0, x1, y1) end
local function fm(m, hex) c:fillMask(m, hex) return m end
local function hash(a, b) return ((a * 73856093) ~ (b * 19349663) ~ (a * b * 83492791)) % 1000 end
local function px(x, y, h) c:px(x, y, h) end
local function rim(m, hex) return c:rim(m, hex) end
local function clampb(v) return max(0, min(255, floor(v + .5))) end
local function D(hex, f)
  f = f or .8
  local r, g, b = tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
  return string.format("#%02x%02x%02x", clampb(r * f - 4), clampb(g * (f - .04)), clampb(b * f + (1 - f) * 70))
end
local function U(...) local m = HP.mask() for _, q in ipairs({ ... }) do m:add(q) end return m end

-- form painter: base, lit crescent upper-left (offset l), shade crescent lower-right (offset s), deep underside row
local function form(m, R, o)
  o = o or {}
  fm(m, R.base)
  local s, l = o.s or 2, o.l or 1
  local sh, lt, dp = {}, {}, {}
  m:each(function(x, y)
    if l > 0 and not m:has(x - l, y - l) then lt[#lt + 1] = { x, y } end
    if s > 0 and not m:has(x + s, y + s) then sh[#sh + 1] = { x, y } end
    if o.deep and not m:has(x, y + 1) then dp[#dp + 1] = { x, y } end
  end)
  for _, p in ipairs(lt) do px(p[1], p[2], R.hi) end
  for _, p in ipairs(sh) do px(p[1], p[2], R.shade) end
  for _, p in ipairs(dp) do px(p[1], p[2], R.deep) end
  return m
end

-- object-relative helpers (ox = left, oy = base line; y negative goes up)
local function G(ox, oy)
  local g = {}
  function g.R(a, b, c2, d2) return Rm(ox + a, oy + b, ox + c2, oy + d2) end
  function g.RR(a, b, c2, d2, r) return c:rrect(ox + a, oy + b, ox + c2, oy + d2, r) end
  function g.P(t) local q = {} for i, p in ipairs(t) do q[i] = { ox + p[1], oy + p[2] } end return c:poly(q) end
  function g.L(t, w) local q = {} for i, p in ipairs(t) do q[i] = { ox + p[1], oy + p[2] } end return c:line(q, w or 1) end
  function g.E(a, b, rx, ry) return c:ellipse(ox + a, oy + b, rx, ry or rx) end
  function g.px(a, b, h) px(ox + a, oy + b, h) end
  return g
end

local OBJ = HP.mask() -- every object pixel (for the stand-point check)
local BOX = {}        -- named bboxes (for the gap check)
local function edge(name, m, hex) -- 1px edge in the object's own dark tone, registered
  local r = rim(m, hex)
  local all = U(m, r)
  OBJ:add(all)
  if name then BOX[#BOX + 1] = { name, { all:bbox() } } end
  return r
end
-- soft cast shadow on the ground (darkens what is there)
local function shadowE(cx, cy, rx, ry, f)
  c:ellipse(cx, cy, rx, ry):each(function(x, y) local h = c:get(x, y) if h then px(x, y, D(h, f or .82)) end end)
end

-- ramps
local WOOD = P.wood
local HONEY = { hi = "#f4c47c", base = "#d08d4a", shade = "#9a5a30", deep = "#5c3324" }
local DARKW = { hi = "#b0784c", base = "#86553a", shade = "#5e3a2c", deep = "#3a2422" }
local WALL = { hi = "#fff4d6", base = "#f6e2bc", shade = "#dcbf96", deep = "#9c7c62" }
local WALLP = { hi = "#ffe8dc", base = "#f4cdbd", shade = "#d9a698", deep = "#9a6466" }
local THATCH = { hi = "#f6d27c", base = "#dca248", shade = "#ae7432", deep = "#6a4126" }
local HAY = { hi = "#fbe48e", base = "#efc355", shade = "#c9923a", deep = "#7c5428" }
local HEDGE = { hi = "#79b85a", base = "#4f9448", shade = "#356f40", deep = "#1f4636" }
local LEAF = { hi = "#a6d468", base = "#68ad4e", shade = "#3f8446", deep = "#24543e" }
local PUMP = { hi = "#ffc46b", base = "#f59a32", shade = "#d0632a", deep = "#7e3524" }
local CHINA = { hi = "#fbfcff", base = "#dfe8f6", shade = "#a9badc", deep = "#5b6a9e" }
local TERRA = { hi = "#f4a070", base = "#d4704a", shade = "#a44c3a", deep = "#5e2a28" }
local CART = { hi = "#9ad8a8", base = "#4fae7c", shade = "#2f7e66", deep = "#1d4a48" }
local CORK = { hi = "#e2b47c", base = "#c58f58", shade = "#a06c42", deep = "#5e3a2a" }

----------------------------------------------------------------------------------------------- SKY
c:stripes(0, 95, { "#86c4ec", P.sky.shade, P.sky.base, "#cdebf8" }, { 2, 3, 3, 4 })
c:cloud(28, 40, 46, P.cream, P.sky.hi)
c:cloud(150, 28, 34, P.cream, P.sky.hi)
c:cloud(250, 46, 40, P.cream, P.sky.hi)
c:cloud(330, 24, 26, P.cream, P.sky.hi)
c:cloud(420, 44, 38, P.cream, P.sky.hi)
c:cloud(110, 58, 22, P.sky.hi, P.sky.base)
-- far birds-free: a few tiny glints of high cloud
for i = 0, 6 do fm(Rm(60 + i * 61, 14 + (i * 7) % 11, 66 + i * 61, 14 + (i * 7) % 11), P.sky.hi) end

----------------------------------------------------------------------------------------------- FAR HILLS
c:terrain(function(x) return 62 + 6 * sin(x / 41 + .3) + 3 * sin(x / 13) end, "#b6b2de")
for x = 0, W - 1 do local y = floor(62 + 6 * sin(x / 41 + .3) + 3 * sin(x / 13) + .5) if x % 5 < 3 then px(x, y, "#cbc6ea") end end
-- windmill far away (behind the hedge, upper right)
do
  local WX, WY = 398, 50
  local tw = c:poly{ { WX - 5, WY }, { WX + 5, WY }, { WX + 8, WY + 34 }, { WX - 8, WY + 34 } }
  fm(tw, "#efe2cf") fm(c:poly{ { WX + 2, WY }, { WX + 5, WY }, { WX + 8, WY + 34 }, { WX + 3, WY + 34 } }, "#d4c2b8")
  c:edgeIn(tw, "#9a8ca8")
  fm(c:poly{ { WX - 7, WY + 1 }, { WX, WY - 6 }, { WX + 7, WY + 1 } }, "#d07a72")
  fm(Rm(WX - 1, WY + 26, WX + 1, WY + 33), "#8c7088")
  for _, a in ipairs({ .5, 2.07, 3.64, 5.21 }) do
    local x2, y2 = WX + 19 * cos(a), WY + 19 * sin(a)
    local nx, ny = -sin(a), cos(a)
    local sail = c:poly{ { WX + 3 * cos(a), WY + 3 * sin(a) }, { x2, y2 }, { x2 + 4 * nx, y2 + 4 * ny }, { WX + 3 * cos(a) + 4 * nx, WY + 3 * sin(a) + 4 * ny } }
    fm(sail, "#f6eee0") c:edgeIn(sail, "#b8a8b8")
    fm(c:line({ { WX, WY }, { x2, y2 } }, 1), "#7e6474")
  end
  fm(Rm(WX - 1, WY - 1, WX + 1, WY + 1), "#5e4658")
end
-- golden hills, two layers, with field rows and hedgerow dots
local function h1(x) return 74 + 5 * sin(x / 57 + 1.1) + 2 * sin(x / 17) end
local function h2(x) return 84 + 4 * sin(x / 47 + 2.4) + 1.5 * sin(x / 11) end
c:terrain(h1, "#f2d27a")
for x = 0, W - 1 do local y0 = floor(h1(x) + .5)
  for y = y0 + 3, 96 do if (y - y0 + floor(x / 30)) % 5 == 0 then px(x, y, "#e6c066") end end
  px(x, y0, "#f8e098")
end
c:terrain(h2, "#e3b65a")
for x = 0, W - 1 do local y0 = floor(h2(x) + .5)
  px(x, y0, "#f0cc72")
  if hash(x // 9, 3) % 3 == 0 and x % 9 < 6 then px(x, y0 - 1, "#98a85a") px(x, y0, "#7e9050") end
end
-- tiny round bales on the hills (flat ovals, 3 tones)
for _, b in ipairs({ { 30, 79 }, { 196, 77 }, { 236, 86 }, { 470, 82 } }) do
  fm(Rm(b[1] - 2, b[2] - 1, b[1] + 2, b[2] + 1), "#f6d27c") fm(Rm(b[1] - 2, b[2] + 1, b[1] + 2, b[2] + 1), "#c9923a")
  px(b[1] + 2, b[2], "#c9923a")
end

----------------------------------------------------------------------------------------------- MEADOW
local GR = { hi = "#d6dc86", base = "#c3cc70", shade = "#adb862", deep = "#8f9c56" }
local function gy(x) return 94 + 2 * sin(x / 31) + sin(x / 9) end
c:terrain(gy, GR.base)
for x = 0, W - 1 do px(x, floor(gy(x) + .5), GR.hi) end

----------------------------------------------------------------------------------------------- ROADS
local SAND = { hi = "#f2dcaa", base = "#e6c78e", shade = "#cfa86e", deep = "#a8804e" }
local function spline(pts, step)
  local outp = {}
  local n = #pts
  for i = 1, n - 1 do
    local p0, p1, p2, p3 = pts[max(1, i - 1)], pts[i], pts[i + 1], pts[min(n, i + 2)]
    for s = 0, step - 1 do
      local t = s / step
      local t2, t3 = t * t, t * t * t
      local function cr(a, b, cc, dd) return .5 * ((2 * b) + (-a + cc) * t + (2 * a - 5 * b + 4 * cc - dd) * t2 + (-a + 3 * b - 3 * cc + dd) * t3) end
      outp[#outp + 1] = { cr(p0[1], p1[1], p2[1], p3[1]), cr(p0[2], p1[2], p2[2], p3[2]) }
    end
  end
  outp[#outp + 1] = pts[n]
  return outp
end
local function band(pts, rx, ry)
  local m = HP.mask()
  for _, p in ipairs(spline(pts, 24)) do m:add(c:ellipse(p[1], p[2], rx, ry)) end
  return m
end
local road = band({ { 126, 290 }, { 128, 240 }, { 112, 202 }, { 104, 168 }, { 122, 136 }, { 160, 127 }, { 200, 127 },
  { 260, 126 }, { 330, 126 }, { 385, 125 }, { 422, 120 }, { 430, 108 }, { 430, 98 } }, 12, 9)
road:add(band({ { 300, 126 }, { 308, 160 }, { 296, 200 }, { 282, 236 }, { 284, 290 } }, 11, 9))
road:add(band({ { 410, 124 }, { 438, 148 }, { 446, 170 } }, 9, 8))
-- clearings at the stand points (pockets of bare earth)
local STAND = { { 104, 170 }, { 306, 166 }, { 446, 172 }, { 128, 236 }, { 282, 236 }, { 190, 127 } }
for _, s in ipairs(STAND) do road:add(c:ellipse(s[1], s[2], 27, 15)) end
road:clip(Rm(0, 96, W - 1, H - 1))
rim(road, SAND.shade)
fm(road, SAND.base)
-- worn wheel tracks + pebbles (very sparse, keeps it calm)
road:each(function(x, y)
  local hsh = hash(x, y)
  if hsh % 97 == 0 then px(x, y, SAND.shade) px(x + 1, y, SAND.shade)
  elseif hsh % 131 == 0 then px(x, y, SAND.hi) end
end)
-- grass tufts on meadow, sparse, away from stand points and the UI corner
local function nearStand(x, y, r)
  for _, s in ipairs(STAND) do if ((x - s[1]) / r) ^ 2 + ((y - s[2]) / (r * .6)) ^ 2 <= 1 then return true end end
  return false
end
for i = 0, 900 do
  local x, y = hash(i, 3) % W, 98 + hash(i, 7) % 172
  if c:get(x, y) == GR.base and not nearStand(x, y, 34) and not (x >= 372 and y >= 224) then
    local r = hash(i, 11) % 10
    if r < 6 then px(x, y, GR.shade) px(x + 1, y - 1, GR.shade) px(x + 2, y, GR.shade)
    elseif r < 8 then px(x, y, GR.hi) px(x, y + 1, GR.hi)
    elseif r == 8 then px(x, y, P.cream) else px(x, y, "#f5d06a") end
  end
end

----------------------------------------------------------------------------------------------- BACK ROW (base 110)
-- COTTAGES (two thatched, the biggest objects)
do
  local function cottage(ox, wallR, doorR, tall, chim)
    local g = G(ox, 110)
    local walls = g.R(6, -32, 58, 0)
    local roof = g.P{ { -3, -28 }, { 2, -40 }, { 12, -53 - tall }, { 20, -57 - tall }, { 44, -57 - tall }, { 52, -53 - tall }, { 62, -40 }, { 67, -28 }, { 64, -25 }, { 0, -25 } }
    local ch = chim and g.R(44, -66 - tall, 51, -50) or HP.mask()
    shadowE(ox + 32, 110, 36, 3)
    edge(nil, U(walls, roof, ch), THATCH.deep)
    if chim then
      form(ch, P.stone, { s = 1 })
      for y = -64 - tall, -52, 3 do fm(g.R(44, y, 51, y):clip(ch), P.stone.shade) end
      fm(g.R(43, -67 - tall, 52, -66 - tall), P.stone.deep)
      -- smoke puffs
      for k, s in ipairs({ { 47, -72 - tall, 3, 2 }, { 50, -78 - tall, 4, 3 }, { 46, -85 - tall, 5, 3 } }) do
        fm(g.E(s[1], s[2], s[3], s[4]), k == 3 and "#eef4f8" or "#f6f4ee")
      end
    end
    form(walls, wallR, { s = 3, l = 1 })
    -- timber band + sill
    fm(g.R(6, -32, 58, -31), wallR.deep)
    -- door
    local door = g.RR(26, -20, 37, 0, 3)
    rim(door, doorR.deep) form(door, doorR, { s = 1 })
    fm(g.R(31, -19, 32, -1), doorR.shade)
    g.px(35, -10, P.gold.hi) g.px(35, -9, P.gold.shade)
    fm(g.R(24, 1, 39, 1), P.stone.base) -- step
    -- windows with cross frames + flower boxes
    for _, wx in ipairs({ 11, 44 }) do
      local wm = g.R(wx, -24, wx + 9, -14)
      rim(wm, DARKW.deep) fm(wm, P.sky.base)
      fm(g.R(wx, -24, wx + 3, -21), P.sky.hi)
      fm(g.R(wx + 4, -24, wx + 5, -14), DARKW.base) fm(g.R(wx, -19, wx + 9, -19), DARKW.base)
      fm(g.R(wx - 1, -13, wx + 10, -11), WOOD.shade)
      for k = 0, 5 do g.px(wx + k * 2, -14, ({ P.ember.base, P.petal.base, P.gold.base })[k % 3 + 1]) end
    end
    -- thatch: layered courses with ragged eaves
    fm(roof, THATCH.base)
    local top = -57 - tall
    roof:each(function(x, y)
      local ly = y - 110 - top
      if ly % 7 == 6 then px(x, y, THATCH.shade)
      elseif ly % 7 == 0 then px(x, y, THATCH.hi)
      elseif hash(x, y) % 9 == 0 then px(x, y, THATCH.shade) end
    end)
    roof:each(function(x, y) if not roof:has(x + 3, y) and not roof:has(x + 2, y + 2) then px(x, y, THATCH.shade) end end)
    roof:each(function(x, y) if not roof:has(x - 1, y - 1) then px(x, y, THATCH.hi) end end)
    for x = ox - 2, ox + 66 do if roof:has(x, 110 - 25) and (x - ox) % 4 ~= 1 then px(x, 110 - 24, THATCH.deep) end end
    -- ridge cap
    fm(g.R(20, top, 44, top + 1), THATCH.deep)
    return g
  end
  cottage(8, WALL, P.ember, 0, true)
  local g = cottage(82, WALLP, P.sea, 4, false)
  -- dormer window in the second roof
  local dm = g.R(26, -46, 37, -37)
  rim(dm, THATCH.deep) fm(dm, P.sky.base) fm(g.R(26, -46, 29, -43), P.sky.hi) fm(g.R(31, -46, 32, -37), DARKW.base)
  fm(g.R(24, -48, 39, -47), THATCH.shade)
  BOX[#BOX + 1] = { "Cottages", { 5, 39, 152, 112 } }
end

-- SNAIL MAILBOX (quirk)
do
  local g = G(152, 110)
  local post = g.R(6, -12, 8, 0)
  local body = g.P{ { -1, -12 }, { 2, -15 }, { 16, -15 }, { 18, -13 }, { 16, -12 } }
  local head = g.R(-1, -19, 2, -13)
  local shell = g.E(10, -21, 6, 6)
  shadowE(159, 110, 7, 2)
  edge("mailbox", U(post, body, head, shell), "#3e2e44")
  form(post, WOOD, { s = 1 })
  form(U(body, head), { hi = "#e6f2a0", base = "#c4dc72", shade = "#94b052", deep = "#5c7034" }, { s = 1 })
  fm(g.L({ { -1, -20 }, { -2, -23 } }, 1), "#5c7034") fm(g.L({ { 2, -20 }, { 3, -23 } }, 1), "#5c7034")
  g.px(-2, -24, P.ink) g.px(3, -24, P.ink)
  g.px(0, -17, P.ink)
  form(shell, P.dusk, { s = 2 })
  fm(g.L({ { 10, -21 }, { 12, -21 }, { 12, -24 }, { 8, -24 }, { 7, -20 }, { 9, -17 }, { 14, -18 }, { 15, -22 } }, 1), P.dusk.deep)
  fm(g.R(6, -27, 13, -27), P.dusk.hi) -- mail slot lip
  fm(g.R(7, -26, 12, -26), P.dusk.deep)
  g.px(16, -26, P.ember.base) g.px(16, -25, P.ember.base) g.px(16, -24, WOOD.deep) -- little flag
end

-- PUMPKIN WHEELBARROW + BEANSTALK (quirk)
do
  local g = G(176, 110)
  -- beanstalk first (behind pumpkins)
  local pts, leaves = {}, {}
  for i = 0, 40 do
    local y = -22 - i * 2
    local x = 19 + 4 * sin(i / 3.2)
    pts[#pts + 1] = { x, y }
    if i % 5 == 2 and i < 39 then leaves[#leaves + 1] = { x, y, (i // 5) % 2 == 0 and 1 or -1 } end
  end
  local stalk = g.L(pts, 3)
  local curl = g.L({ { 19, -104 }, { 22, -106 }, { 24, -104 }, { 22, -102 } }, 1)
  local lm = HP.mask()
  for _, l in ipairs(leaves) do
    local s = l[3]
    lm:add(g.P{ { l[1], l[2] }, { l[1] + s * 4, l[2] - 4 }, { l[1] + s * 8, l[2] - 3 }, { l[1] + s * 9, l[2] + 1 }, { l[1] + s * 4, l[2] + 2 } })
  end
  local tray = g.P{ { 2, -20 }, { 32, -20 }, { 28, -8 }, { 7, -8 } }
  local wheel = g.P{ { 1, -10 }, { 5, -12 }, { 9, -10 }, { 10, -6 }, { 9, -2 }, { 5, 0 }, { 1, -2 }, { 0, -6 } }
  local leg = g.R(25, -8, 27, 0)
  local handle = g.L({ { 28, -16 }, { 33, -12 } }, 2)
  local pk = { { 9, -22, 6, 5 }, { 25, -22, 6, 5 }, { 17, -25, 6, 5 } }
  local pm = HP.mask() for _, p in ipairs(pk) do pm:add(g.E(p[1], p[2], p[3], p[4])) end
  shadowE(194, 110, 18, 2)
  edge("wheelbarrow", U(stalk, curl, lm, tray, wheel, leg, handle, pm), LEAF.deep)
  form(stalk, LEAF, { s = 1 })
  fm(curl, LEAF.shade)
  form(lm, LEAF, { s = 1 })
  for _, l in ipairs(leaves) do fm(g.L({ { l[1], l[2] }, { l[1] + l[3] * 7, l[2] - 1 } }, 1), LEAF.shade) end
  form(U(handle, leg), WOOD, { s = 1 })
  form(tray, P.ember, { s = 2 })
  fm(g.R(4, -20, 31, -19), P.ember.hi)
  form(wheel, P.stone, { s = 2 }) fm(g.R(4, -7, 5, -5), P.stone.deep)
  for _, p in ipairs(pk) do
    local m = g.E(p[1], p[2], p[3], p[4])
    rim(m, PUMP.deep) form(m, PUMP, { s = 2 })
    fm(g.L({ { p[1] - 2, p[2] - 3 }, { p[1] - 3, p[2] }, { p[1] - 2, p[2] + 3 } }, 1):clip(m), PUMP.shade)
    fm(g.L({ { p[1] + 2, p[2] - 3 }, { p[1] + 3, p[2] }, { p[1] + 2, p[2] + 3 } }, 1):clip(m), PUMP.shade)
    fm(g.R(p[1], p[2] - p[4] - 2, p[1] + 1, p[2] - p[4]), LEAF.shade)
  end
  -- re-run the stalk over the top pumpkin so it sprouts out of it
  fm(g.L({ { 19, -26 }, { 19, -32 } }, 3), LEAF.base) fm(g.L({ { 20, -26 }, { 20, -32 } }, 1), LEAF.shade)
end

-- NOTICE BOARD
do
  local g = G(226, 110)
  local posts = U(g.R(6, -44, 10, 0), g.R(42, -44, 46, 0))
  local frame = g.R(0, -50, 52, -14)
  local cap = g.P{ { -4, -49 }, { 6, -58 }, { 46, -58 }, { 56, -49 } }
  shadowE(252, 110, 26, 3)
  edge("Notice Board", U(posts, frame, cap), DARKW.deep)
  form(posts, DARKW, { s = 1 })
  form(frame, DARKW, { s = 2 })
  local cork = g.R(3, -47, 49, -17)
  fm(cork, CORK.base)
  cork:each(function(x, y) local hh = hash(x, y) % 11 if hh == 0 then px(x, y, CORK.shade) elseif hh == 1 then px(x, y, CORK.hi) end end)
  fm(g.R(3, -47, 49, -47), CORK.deep) fm(g.R(3, -47, 3, -17), CORK.deep)
  -- cap: green shingles
  form(cap, LEAF, { s = 1 })
  for y = -56, -50, 3 do fm(g.R(-4, y, 56, y):clip(cap), LEAF.shade) end
  fm(g.R(-4, -49, 56, -49), LEAF.deep)
  -- pinned papers (no text: scribble bars)
  local papers = {
    { 6, -44, 18, -30, "#fff4d6", "#dcbf96" }, { 21, -45, 31, -36, "#ffe38a", "#d9a84e" },
    { 34, -43, 46, -27, "#cfeaf6", "#8bc4ea" }, { 19, -33, 31, -20, "#ffd2e0", "#d98aa8" },
    { 7, -27, 16, -19, "#e4f2b8", "#a8c070" } }
  for i, p in ipairs(papers) do
    local m = g.R(p[1], p[2], p[3], p[4])
    fm(g.R(p[1] + 1, p[4] + 1, p[3] + 1, p[4] + 1):cut(m), CORK.deep) -- drop shadow
    fm(g.R(p[3] + 1, p[2] + 1, p[3] + 1, p[4] + 1), CORK.deep)
    fm(m, p[5])
    fm(g.R(p[3], p[2], p[3], p[4]), p[6])
    g.px(p[3] - 1, p[4], p[6]) -- curled corner
    for y = p[2] + 4, p[4] - 2, 3 do
      local len = (p[3] - p[1] - 3) - hash(i, y) % 4
      fm(g.R(p[1] + 2, y, p[1] + 1 + len, y), p[6])
    end
    local pinc = ({ P.ember.base, P.sea.shade, P.ember.base, P.dusk.base, P.gold.shade })[i]
    local cx = floor((p[1] + p[3]) / 2)
    fm(g.R(cx, p[2] - 1, cx + 1, p[2]), pinc) g.px(cx, p[2] - 1, P.cream)
  end
end

-- SCARECROW with TEAPOT HAT (quirk)
do
  local g = G(288, 110)
  local pole = g.R(10, -40, 12, 0)
  local arms = g.R(0, -33, 22, -31)
  local shirt = g.P{ { 4, -35 }, { 18, -35 }, { 17, -18 }, { 5, -18 } }
  local hands = U(g.R(-2, -34, 1, -30), g.R(21, -34, 24, -30))
  local head = g.RR(6, -47, 16, -37, 3)
  local pot = g.RR(5, -57, 17, -48, 3)
  local spout = g.L({ { 4, -53 }, { 1, -56 }, { 0, -58 } }, 2)
  local handle = g.L({ { 17, -55 }, { 20, -55 }, { 20, -51 }, { 17, -50 } }, 1)
  local lid = g.R(9, -60, 13, -58)
  shadowE(299, 110, 9, 2)
  edge(nil, U(pole, arms, shirt, hands, head, pot, spout, handle, lid), "#3a3046")
  form(pole, WOOD, { s = 1 }) form(arms, WOOD, { s = 1 })
  form(shirt, P.sea, { s = 2 })
  fm(g.R(12, -27, 15, -24), P.ember.base) g.px(12, -27, P.ember.hi) -- patch
  fm(g.R(5, -19, 17, -18), P.sea.deep)
  for _, q in ipairs({ { 6, -17 }, { 9, -16 }, { 13, -17 }, { 16, -16 } }) do fm(g.R(q[1], q[2], q[1], q[2] + 2), HAY.base) end
  form(hands, HAY, { s = 1 }) g.px(-2, -29, HAY.shade) g.px(24, -29, HAY.shade)
  form(head, { hi = "#f2d8a8", base = "#dcb47c", shade = "#b08454", deep = "#6e4c32" }, { s = 1 })
  fm(g.R(8, -43, 9, -42), P.ink) fm(g.R(13, -43, 14, -42), P.ink)
  fm(g.R(9, -40, 13, -40), "#6e4c32")
  form(U(pot, spout, handle), CHINA, { s = 2 })
  fm(g.R(5, -53, 17, -52), P.sea.shade) -- blue band
  form(lid, CHINA, { s = 0 }) g.px(11, -61, CHINA.deep)
  fm(g.R(7, -56, 8, -56), CHINA.hi)
end

-- OAK with a KITE caught in it (quirk)
do
  local g = G(312, 110)
  local trunk = U(g.P{ { 20, 0 }, { 23, -30 }, { 29, -30 }, { 33, 0 } }, g.L({ { 25, -26 }, { 16, -36 } }, 2), g.L({ { 28, -26 }, { 36, -38 } }, 2))
  local can = U(g.E(14, -52, 13, 11), g.E(30, -60, 15, 12), g.E(39, -48, 10, 10), g.E(26, -44, 16, 9))
  local kite = g.P{ { 39, -76 }, { 46, -68 }, { 39, -57 }, { 33, -68 } }
  local tail = g.L({ { 39, -57 }, { 41, -50 }, { 38, -44 }, { 41, -38 }, { 39, -32 } }, 1)
  shadowE(338, 110, 22, 3)
  edge(nil, U(trunk, can, kite, tail), HEDGE.deep)
  BOX[#BOX + 1] = { "oak", { U(trunk, can):bbox() } }
  form(trunk, WOOD, { s = 2 })
  fm(g.R(25, -18, 25, -8), WOOD.deep) fm(g.R(29, -26, 29, -14), WOOD.shade)
  form(can, HEDGE, { s = 3, l = 2 })
  can:each(function(x, y)
    local hh = hash(x, y) % 17
    if hh == 0 and can:has(x + 1, y) then px(x, y, HEDGE.shade) px(x + 1, y, HEDGE.shade)
    elseif hh == 1 and can:has(x, y - 2) then px(x, y, HEDGE.hi) end
  end)
  fm(g.R(10, -58, 12, -58), HEDGE.hi) fm(g.R(24, -68, 27, -68), HEDGE.hi)
  -- kite: 4 quarters
  fm(kite, P.petal.base)
  fm(g.P{ { 39, -76 }, { 46, -68 }, { 39, -68 } }, P.gold.base)
  fm(g.P{ { 33, -68 }, { 39, -68 }, { 39, -57 } }, P.gold.shade)
  fm(g.P{ { 39, -68 }, { 46, -68 }, { 39, -57 } }, P.petal.shade)
  fm(g.L({ { 39, -76 }, { 39, -57 } }, 1), WOOD.deep) fm(g.L({ { 33, -68 }, { 46, -68 } }, 1), WOOD.deep)
  fm(tail, P.stone.deep)
  for _, b in ipairs({ { 41, -50, P.ember.base }, { 40, -43, P.sea.base }, { 40, -36, P.gold.base } }) do
    fm(g.R(b[1] - 2, b[2], b[1] - 1, b[2] + 1), b[3]) fm(g.R(b[1] + 1, b[2], b[1] + 2, b[2] + 1), b[3])
  end
end

-- HEDGE with the WILD TRAIL gap + signpost (right edge)
do
  local hedge = Rm(372, 82, 480, 120)
  for i = 0, 9 do hedge:add(c:ellipse(376 + i * 12, 84 + (i % 2) * 2, 8, 9)) end
  local gap = U(c:rrect(414, 84, 444, 124, 12))
  hedge:cut(gap)
  hedge:clip(Rm(372, 0, 479, 120))
  edge(nil, hedge, HEDGE.deep)
  BOX[#BOX + 1] = { "Wild Trail", { 371, 74, 479, 124 } }
  form(hedge, HEDGE, { s = 3, l = 2 })
  hedge:each(function(x, y)
    local hh = hash(x, y) % 13
    if hh == 0 and hedge:has(x + 1, y + 1) then px(x, y, HEDGE.shade) px(x + 1, y + 1, HEDGE.deep)
    elseif hh == 1 and hedge:has(x - 1, y) then px(x, y, HEDGE.hi) px(x - 1, y, HEDGE.hi)
    elseif hh == 2 then px(x, y, LEAF.base) end
  end)
  -- a few berries/flowers in the hedge
  for i = 0, 8 do local x, y = 378 + i * 11 + hash(i, 1) % 5, 96 + hash(i, 2) % 18
    if hedge:has(x, y) and hedge:has(x + 1, y) then px(x, y, P.petal.hi) end end
  -- tunnel inside the gap: dark leafy arch with the path running in and bending away
  local inner = c:rrect(415, 85, 443, 123, 12)
  fm(inner, HEDGE.deep)
  fm(c:rrect(419, 92, 439, 123, 9), "#2d5a3e")
  fm(c:poly{ { 418, 124 }, { 440, 124 }, { 436, 110 }, { 430, 104 }, { 424, 104 } }, SAND.shade)
  fm(c:poly{ { 421, 124 }, { 437, 124 }, { 433, 112 }, { 429, 107 }, { 425, 107 } }, SAND.base)
  for _, l in ipairs({ { 416, 88 }, { 420, 86 }, { 438, 87 }, { 441, 92 }, { 416, 98 } }) do px(l[1], l[2], HEDGE.base) px(l[1] + 1, l[2] + 1, HEDGE.shade) end
  -- signpost (its tall pole also carries the bunting)
  local pole = Rm(460, 6, 463, 126)
  local arrow = c:poly{ { 449, 78 }, { 469, 78 }, { 476, 84 }, { 469, 90 }, { 449, 90 } }
  local arrow2 = c:poly{ { 474, 94 }, { 456, 94 }, { 450, 99 }, { 456, 104 }, { 474, 104 } }
  shadowE(462, 126, 6, 2)
  edge(nil, U(pole, arrow, arrow2), DARKW.deep)
  form(pole, WOOD, { s = 1 })
  form(arrow, P.gold, { s = 2 }) fm(Rm(452, 83, 466, 84), P.gold.deep)
  fm(c:poly{ { 467, 81 }, { 471, 84 }, { 467, 87 } }, P.gold.deep)
  form(arrow2, P.sea, { s = 2 }) fm(Rm(458, 98, 470, 99), P.sea.deep)
  fm(Rm(461, 6, 462, 7), WOOD.hi)
end

----------------------------------------------------------------------------------------------- MIDDLE ROW (base 192)
-- FORAGE PATCH (fenced bed: berry bush, mushrooms, herbs)
do
  local g = G(8, 192)
  local bed = g.R(1, -14, 64, -3)
  local bush = U(g.E(16, -26, 13, 11), g.E(10, -20, 8, 7), g.E(23, -19, 8, 7))
  local caps = {}
  local mush = HP.mask()
  for _, m in ipairs({ { 36, -12, 5, 4 }, { 45, -9, 4, 3 }, { 30, -8, 3, 2 } }) do
    local cap = g.E(m[1], m[2], m[3], m[4]):clip(g.R(m[1] - m[3] - 1, m[2] - m[4] - 1, m[1] + m[3] + 1, m[2]))
    local stem = g.R(m[1] - 1, m[2], m[1] + 1, m[2] + m[4] + 2)
    caps[#caps + 1] = { cap, stem, m }
    mush:add(cap):add(stem)
  end
  local herbs = HP.mask()
  local sprigs = { { 52, -26 }, { 56, -30 }, { 60, -24 }, { 49, -20 } }
  for _, s in ipairs(sprigs) do herbs:add(g.L({ { s[1], -6 }, { s[1] + (s[1] % 2 == 0 and -1 or 1), s[2] } }, 2)) herbs:add(g.R(s[1] - 1, s[2] - 4, s[1] + 1, s[2])) end
  local fence = HP.mask()
  for x = 0, 62, 9 do fence:add(g.P{ { x, 0 }, { x, -12 }, { x + 1, -14 }, { x + 3, -12 }, { x + 3, 0 } }) end
  fence:add(g.R(0, -9, 65, -7)):add(g.R(0, -4, 65, -3))
  shadowE(41, 193, 36, 3)
  edge("Forage Patch", U(bed, bush, mush, herbs, fence), DARKW.deep)
  fm(bed, "#7a5038") bed:each(function(x, y) if hash(x, y) % 6 == 0 then px(x, y, "#5c3a2c") end end)
  fm(g.R(1, -14, 64, -14), "#9a6a48")
  -- berry bush
  form(bush, LEAF, { s = 3, l = 2 })
  bush:each(function(x, y) if hash(x, y) % 15 == 0 then px(x, y, LEAF.shade) end end)
  for i, b in ipairs({ { 9, -30 }, { 15, -34 }, { 21, -29 }, { 12, -23 }, { 19, -22 }, { 6, -19 }, { 25, -18 }, { 14, -15 }, { 22, -33 } }) do
    fm(g.R(b[1], b[2], b[1] + 1, b[2] + 1), P.ember.base) g.px(b[1], b[2], P.ember.hi) g.px(b[1] + 1, b[2] + 1, P.ember.deep)
  end
  -- mushrooms
  for _, q in ipairs(caps) do
    form(q[2], { hi = P.cream, base = "#f1e2c4", shade = "#cdb894", deep = "#8a7660" }, { s = 1 })
    form(q[1], P.ember, { s = 1 })
    local m = q[3]
    g.px(m[1] - 1, m[2] - m[4] + 1, P.cream) g.px(m[1] + 2, m[2] - 1, P.cream)
  end
  -- herbs with lavender tips
  form(herbs, { hi = "#c4e07a", base = "#8cc860", shade = "#5a9c50", deep = "#2e5a40" }, { s = 1 })
  for _, s in ipairs(sprigs) do fm(g.R(s[1] - 1, s[2] - 4, s[1] + 1, s[2] - 1), P.dusk.base) g.px(s[1] - 1, s[2] - 4, P.dusk.hi) end
  for _, s in ipairs({ { 50, -14 }, { 58, -16 } }) do fm(g.R(s[1] - 2, s[2], s[1] + 2, s[2]), "#8cc860") end
  -- picket fence over the bed
  form(fence, { hi = "#fff4d6", base = "#eadcc0", shade = "#c4b090", deep = "#7a6650" }, { s = 1 })
end

-- TRADER STALL (striped awning, baskets)
do
  local g = G(137, 192)
  local posts = U(g.R(3, -36, 6, 0), g.R(53, -36, 56, 0))
  local back = g.R(4, -36, 55, -16)
  local counter = g.R(0, -16, 59, 0)
  local awn = g.P{ { -3, -35 }, { 3, -47 }, { 56, -47 }, { 62, -35 } }
  local scal = HP.mask()
  for i = 0, 9 do scal:add(g.E(-1 + i * 7 + 3, -35, 3, 2):clip(g.R(-4, -35, 64, -32))) end
  -- baskets + fruit
  local bask, fruit = HP.mask(), {}
  for i, bx in ipairs({ 5, 22, 39 }) do
    bask:add(g.P{ { bx, -24 }, { bx + 15, -24 }, { bx + 13, -16 }, { bx + 2, -16 } })
    local f = U(g.E(bx + 4, -26, 3, 3), g.E(bx + 11, -26, 3, 3), g.E(bx + 7, -28, 3, 3))
    fruit[i] = f
    bask:add(f)
  end
  shadowE(167, 193, 33, 3)
  edge("Trader Stall", U(posts, back, counter, awn, scal, bask), "#5a2630")
  fm(back, "#6e4038")
  fm(g.R(4, -36, 65, -34), "#4e2c2e")
  -- shelf with jars at the back
  fm(g.R(6, -27, 53, -26), WOOD.shade)
  form(posts, WOOD, { s = 1 })
  form(counter, WOOD, { s = 2 })
  fm(g.R(0, -16, 59, -15), WOOD.hi) fm(g.R(0, -14, 59, -14), WOOD.deep)
  for x = 9, 56, 12 do fm(g.R(x, -13, x, -1), WOOD.shade) end
  -- painted counter sign plate (no text: a little apple emblem)
  local plate = g.R(22, -11, 37, -4)
  rim(plate, WOOD.deep) fm(plate, P.cream) fm(g.R(28, -9, 31, -6), P.ember.base) g.px(29, -10, LEAF.base) g.px(28, -9, P.ember.hi)
  -- awning stripes
  awn:each(function(x, y)
    local k = floor((x - 135) / 7)
    px(x, y, k % 2 == 0 and P.ember.base or P.cream)
  end)
  awn:each(function(x, y) if not awn:has(x, y - 1) then px(x, y, ((x - 135) // 7) % 2 == 0 and P.ember.hi or "#ffffe8") end end)
  for x = 134, 200 do if awn:has(x, 192 - 36) then px(x, 192 - 36, D(c:get(x, 192 - 36), .82)) end end
  scal:each(function(x, y) local k = floor((x - 135) / 7) px(x, y, k % 2 == 0 and P.ember.shade or "#e8d6b4") end)
  -- baskets
  for i, bx in ipairs({ 5, 22, 39 }) do
    local b = g.P{ { bx, -24 }, { bx + 15, -24 }, { bx + 13, -16 }, { bx + 2, -16 } }
    form(b, P.gold, { s = 1 })
    b:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, P.gold.shade) end end)
    fm(g.R(bx, -24, bx + 15, -24), P.gold.deep)
    local R = ({ P.ember, { hi = "#ffd07a", base = "#f59a32", shade = "#c96a2a", deep = "#7a3a22" }, LEAF })[i]
    form(fruit[i], R, { s = 1 })
    fruit[i]:each(function(x, y) if fruit[i]:has(x, y + 1) and not fruit[i]:has(x, y) then end end)
    g.px(bx + 3, -28, R.hi) g.px(bx + 6, -30, R.hi) g.px(bx + 10, -28, R.hi)
    g.px(bx + 7, -32, LEAF.deep)
  end
end

-- WISHING WELL (stone, roof, bucket)
do
  local g = G(220, 192)
  local roof = g.P{ { -2, -42 }, { 27, -56 }, { 56, -42 }, { 52, -39 }, { 2, -39 } }
  local posts = U(g.R(7, -40, 10, -18), g.R(44, -40, 47, -18))
  local bar = g.R(8, -33, 46, -31)
  local crank = U(g.R(48, -34, 49, -30), g.R(48, -30, 52, -29))
  local rope = g.R(27, -30, 27, -27)
  local bucket = g.P{ { 22, -27 }, { 32, -27 }, { 31, -19 }, { 23, -19 } }
  local lip = g.E(27, -18, 25, 4)
  local body = g.R(3, -18, 51, 0)
  shadowE(247, 193, 30, 3)
  edge("Wishing Well", U(roof, posts, bar, crank, rope, bucket, lip, body), P.stone.deep)
  form(posts, DARKW, { s = 1 })
  form(bar, DARKW, { s = 1 }) form(crank, DARKW, { s = 0 })
  -- stone body with brick courses
  fm(body, P.stone.base)
  body:each(function(x, y)
    local ly = y - (192 - 18)
    local row = ly // 5
    local off = (row % 2) * 6
    if ly % 5 == 4 or (x - 223 + off) % 12 == 0 then px(x, y, P.stone.shade)
    else
      local hh = hash((x - 223 + off) // 12, row) % 4
      px(x, y, hh == 0 and P.stone.hi or hh == 1 and "#bebdcc" or P.stone.base)
    end
  end)
  fm(g.R(47, -18, 51, 0), P.stone.shade) fm(g.R(3, -1, 51, 0), P.stone.deep)
  -- lip + dark water opening
  form(lip, P.stone, { s = 1 })
  fm(g.E(27, -18, 21, 2), "#2a3c5e")
  fm(g.R(18, -18, 30, -18), "#3a6290")
  -- moss tufts on the stones
  for _, m in ipairs({ { 6, -12 }, { 40, -5 }, { 14, -3 } }) do fm(g.R(m[1], m[2], m[1] + 3, m[2]), LEAF.base) g.px(m[1] + 1, m[2] - 1, LEAF.hi) end
  -- roof shingles
  form(roof, P.ember, { s = 2 })
  for y = -53, -41, 4 do
    for x = -2, 56 do if roof:has(220 + x, 192 + y) and (x + (y // 4) * 3) % 6 == 0 then g.px(x, y, P.ember.shade) g.px(x, y + 1, P.ember.shade) end end
    fm(g.R(-2, y + 2, 56, y + 2):clip(roof), P.ember.shade)
  end
  fm(g.R(2, -39, 52, -39), P.ember.deep)
  fm(rope, WOOD.hi)
  form(bucket, WOOD, { s = 1 })
  fm(g.R(22, -26, 32, -26), P.stone.shade) fm(g.R(23, -21, 31, -21), P.stone.shade)
  fm(g.L({ { 22, -27 }, { 27, -31 }, { 32, -27 } }, 1), P.stone.deep)
end

-- LONG TABLE (picnic table, bread, jam, cups)
do
  local g = G(342, 192)
  local top = g.P{ { 4, -27 }, { 64, -27 }, { 68, -21 }, { 0, -21 } }
  local drape = g.R(0, -21, 68, -16)
  local legs = U(g.L({ { 9, -16 }, { 6, 0 } }, 3), g.L({ { 59, -16 }, { 62, 0 } }, 3))
  local bench = g.R(-3, -9, 71, -6)
  local blegs = U(g.R(2, -6, 4, 0), g.R(64, -6, 66, 0))
  local bread = g.RR(6, -34, 24, -26, 4)
  local jar = g.R(30, -36, 37, -26)
  local cups = U(g.R(43, -32, 48, -26), g.R(55, -32, 60, -26), g.L({ { 49, -31 }, { 50, -30 }, { 50, -28 }, { 49, -27 } }, 1), g.L({ { 61, -31 }, { 62, -30 }, { 62, -28 }, { 61, -27 } }, 1))
  shadowE(376, 193, 38, 3)
  edge("Long Table", U(top, drape, legs, bench, blegs, bread, jar, cups), WOOD.deep)
  form(legs, WOOD, { s = 1 })
  -- gingham cloth
  local cloth = U(top, drape)
  cloth:each(function(x, y)
    local a, b = (x // 3) % 2, (y // 3) % 2
    px(x, y, (a == 0 and b == 0) and P.ember.shade or (a + b == 1) and "#f08a86" or P.cream)
  end)
  fm(g.R(0, -16, 68, -16), P.ember.deep)
  for x = 0, 68, 4 do g.px(x, -15, P.ember.deep) end
  form(U(bench, blegs), WOOD, { s = 1 }) fm(g.R(-3, -9, 71, -9), WOOD.hi)
  -- bread loaf with slashes
  rim(bread, "#6e3a20") form(bread, { hi = "#ffd590", base = "#e2a050", shade = "#b06a30", deep = "#6e3a20" }, { s = 2 })
  for _, sx in ipairs({ 10, 15, 20 }) do fm(g.L({ { sx, -31 }, { sx + 2, -33 } }, 1), "#fbe7b0") end
  -- jam jar
  form(jar, { hi = "#ff7a8a", base = "#c8283e", shade = "#8c1c34", deep = "#4e1428" }, { s = 1 })
  fm(g.R(29, -38, 38, -36), P.cream) fm(g.R(29, -36, 38, -36), "#e8a4b4") fm(g.R(31, -39, 36, -39), P.ember.base)
  fm(g.R(31, -33, 31, -29), "#ffc0c8")
  -- cups
  form(U(g.R(43, -32, 48, -26), g.L({ { 49, -31 }, { 50, -30 }, { 50, -28 }, { 49, -27 } }, 1)), P.sea, { s = 1 })
  form(U(g.R(55, -32, 60, -26), g.L({ { 61, -31 }, { 62, -30 }, { 62, -28 }, { 61, -27 } }, 1)), P.gold, { s = 1 })
  fm(g.R(44, -32, 47, -32), P.sea.deep) fm(g.R(56, -32, 59, -32), P.gold.deep)
  -- steam curl from the blue cup
  fm(g.L({ { 45, -35 }, { 46, -37 }, { 45, -39 }, { 46, -41 } }, 1), "#f6f6f0")
end

----------------------------------------------------------------------------------------------- FRONT ROW (base 262)
-- REST BENCH (slatted wooden park bench, cushion, teapot)
do
  local g = G(18, 262)
  -- side frames: back post rises above the backrest with a rounded cap; armrest over a front post
  local postL, postR = g.RR(2, -50, 7, -16, 2), g.RR(66, -50, 71, -16, 2)
  local slat1 = g.R(8, -46, 65, -42)
  local slat2 = g.R(8, -38, 65, -34)
  local seat = g.RR(-1, -22, 74, -16, 2)
  local armL, armR = g.RR(-4, -32, 10, -28, 2), g.RR(63, -32, 77, -28, 2)
  local frontL, frontR = g.R(-2, -28, 1, -22), g.R(72, -28, 75, -22)
  local legs = U(g.P{ { 2, -16 }, { 8, -16 }, { 7, 0 }, { 1, 0 } }, g.P{ { 65, -16 }, { 71, -16 }, { 72, 0 }, { 66, 0 } })
  local stretch = g.R(7, -7, 66, -5)
  local cushion = g.RR(12, -30, 34, -21, 4)
  local pot = g.RR(42, -33, 55, -23, 4)
  local spout = g.L({ { 41, -28 }, { 38, -31 }, { 37, -34 } }, 2)
  local handle = g.L({ { 55, -31 }, { 58, -31 }, { 58, -26 }, { 55, -25 } }, 2)
  local lid = U(g.R(45, -36, 51, -34), g.R(47, -38, 49, -37))
  shadowE(55, 263, 40, 3, .78)
  edge("Rest Bench", U(postL, postR, slat1, slat2, seat, armL, armR, frontL, frontR, legs, stretch, cushion, pot, spout, handle, lid), HONEY.deep)
  for _, s in ipairs({ slat1, slat2 }) do
    form(s, HONEY, { s = 1, deep = true })
    s:each(function(x, y) if hash(x, y) % 9 == 0 and s:has(x + 1, y) then px(x, y, HONEY.shade) px(x + 1, y, HONEY.shade) end end)
  end
  form(U(postL, postR), HONEY, { s = 1 })
  for _, y in ipairs({ -44, -36 }) do g.px(4, y, HONEY.deep) g.px(68, y, HONEY.deep) end -- bolts
  form(legs, HONEY, { s = 1 })
  form(stretch, HONEY, { s = 0 })
  fm(g.R(7, -5, 66, -5), HONEY.shade)
  -- seat: lit top face + darker front face with plank joints
  fm(seat, HONEY.base)
  fm(g.R(-1, -22, 74, -21):clip(seat), HONEY.hi)
  fm(g.R(-1, -19, 74, -16):clip(seat), HONEY.shade)
  fm(g.R(-1, -16, 74, -16):clip(seat), HONEY.deep)
  for x = 4, 70, 11 do fm(g.R(x, -19, x + 3, -19), HONEY.base) end
  -- armrests on front posts
  form(U(frontL, frontR), HONEY, { s = 1 })
  for _, a in ipairs({ armL, armR }) do form(a, HONEY, { s = 1, deep = true }) end
  -- cushion (blue, tufted)
  rim(cushion, P.sea.deep)
  form(cushion, P.sea, { s = 2, deep = true })
  fm(g.R(12, -26, 34, -26):clip(cushion:shrink(1)), P.sea.shade)
  for _, b in ipairs({ 18, 28 }) do g.px(b, -26, P.sea.deep) g.px(b, -27, P.cream) end
  fm(g.R(14, -29, 17, -29), P.sea.hi)
  -- teapot (red with cream polka dots)
  form(U(pot, spout, handle), P.ember, { s = 2 })
  form(lid, P.ember, { s = 0 }) g.px(48, -38, P.ember.hi)
  fm(g.R(42, -34, 55, -34):clip(lid:grow(1)), P.ember.deep)
  for _, dt in ipairs({ { 45, -30 }, { 51, -29 }, { 47, -26 }, { 52, -32 } }) do g.px(dt[1], dt[2], P.cream) end
  fm(g.R(44, -32, 45, -32), P.ember.hi)
  fm(g.L({ { 38, -38 }, { 39, -40 }, { 38, -42 } }, 1), "#f6f6f0") -- steam
end

-- FISHING POND (water, reeds, lily pad, rod + float)
do
  local g = G(164, 262)
  local water = U(g.E(44, -22, 40, 15), g.E(30, -16, 26, 13), g.E(60, -27, 22, 10))
  local bank = water:grow(2)
  local reeds = HP.mask()
  local rp = { { 6, -38 }, { 10, -44 }, { 14, -36 }, { 3, -30 } }
  for _, r in ipairs(rp) do reeds:add(g.L({ { r[1] + 1, -14 }, { r[1], r[2] } }, 1)) reeds:add(g.R(r[1] - 1, r[2] + 2, r[1] + 1, r[2] + 7)) end
  reeds:add(g.P{ { 0, -14 }, { 4, -24 }, { 6, -14 } }):add(g.P{ { 12, -10 }, { 18, -22 }, { 17, -10 } })
  local rod = g.L({ { 88, -4 }, { 66, -46 } }, 2)
  local stand = g.L({ { 82, -2 }, { 86, -14 } }, 1)
  shadowE(208, 263, 44, 3, .85)
  edge("Fishing Pond", U(bank, reeds, rod, stand), "#6a5236")
  fm(bank, "#a8875a")
  bank:each(function(x, y) if not water:has(x, y) and hash(x, y) % 4 == 0 then px(x, y, ({ P.stone.base, P.stone.hi, "#8a6a48" })[hash(y, x) % 3 + 1]) end end)
  -- water: lit far edge, deep core, ripples, reflections
  fm(water, P.sea.base)
  water:each(function(x, y) if not water:has(x, y - 2) then px(x, y, "#3f8fb4") end end) -- bank reflection
  fm(g.E(48, -18, 26, 7):clip(water), "#4aa8c0")
  fm(g.E(50, -16, 16, 4):clip(water), P.sea.shade)
  for i, r in ipairs({ { 20, -12, 6 }, { 60, -10, 8 }, { 34, -26, 7 }, { 70, -24, 5 }, { 12, -20, 4 } }) do
    fm(g.R(r[1], r[2], r[1] + r[3], r[2]):clip(water), P.sea.hi)
  end
  -- sky reflection glints
  fm(g.R(26, -30, 31, -30):clip(water), P.sky.hi) fm(g.R(64, -32, 66, -32):clip(water), P.sky.hi)
  -- lily pads with a pink flower
  for _, l in ipairs({ { 24, -20, 5, 3 }, { 66, -18, 4, 2 } }) do
    local pad = g.E(l[1], l[2], l[3], l[4]):cut(g.P{ { l[1], l[2] }, { l[1] + l[3] + 1, l[2] - 2 }, { l[1] + l[3] + 1, l[2] } })
    rim(pad:copy():clip(water:shrink(1)), LEAF.deep)
    form(pad, LEAF, { s = 1 })
  end
  fm(g.R(22, -22, 24, -21), P.petal.base) g.px(23, -23, P.petal.hi) g.px(22, -22, P.petal.hi)
  -- reeds + cattails
  form(reeds, LEAF, { s = 1 })
  for _, r in ipairs(rp) do fm(g.R(r[1] - 1, r[2] + 2, r[1] + 1, r[2] + 7), WOOD.shade) g.px(r[1] - 1, r[2] + 2, WOOD.hi) end
  -- fishing rod on a forked stick, line, red-cream float with ripple arcs
  form(rod, DARKW, { s = 0 })
  fm(stand, DARKW.shade)
  fm(g.L({ { 66, -46 }, { 62, -40 }, { 59, -32 }, { 58, -22 } }, 1), "#f0ecf6")
  fm(g.R(57, -24, 59, -23), P.ember.base) fm(g.R(57, -22, 59, -21), P.cream)
  fm(g.R(52, -20, 54, -20), P.sea.hi) fm(g.R(62, -20, 64, -20), P.sea.hi)
  fm(g.R(50, -19, 51, -19), P.sea.hi) fm(g.R(65, -19, 66, -19), P.sea.hi)
  -- reel
  fm(g.R(82, -12, 84, -10), P.stone.base) g.px(82, -12, P.stone.hi)
end

-- SEED SWAP CART (seed packets, sprout pots)
do
  local g = G(318, 260)
  local body = g.R(2, -26, 56, -10)
  local handle = g.L({ { 2, -16 }, { -2, -12 } }, 2)
  local wheels = {}
  local wm = HP.mask()
  for i, wx in ipairs({ 14, 44 }) do
    local w = g.P{ { wx - 3, -16 }, { wx + 3, -16 }, { wx + 8, -11 }, { wx + 8, -5 }, { wx + 3, 0 }, { wx - 3, 0 }, { wx - 8, -5 }, { wx - 8, -11 } }
    wheels[i] = { w, wx } wm:add(w)
  end
  local packs = HP.mask()
  local PK = { P.petal, P.gold, P.sky, P.ember, P.dusk }
  for i = 0, 4 do packs:add(g.R(4 + i * 7, -38 + (i % 2), 9 + i * 7, -26)) end
  local pots = U(g.P{ { 41, -34 }, { 49, -34 }, { 48, -26 }, { 42, -26 } }, g.P{ { 50, -32 }, { 57, -32 }, { 56, -26 }, { 51, -26 } })
  local sprouts = U(g.L({ { 45, -34 }, { 45, -40 } }, 1), g.P{ { 45, -40 }, { 40, -44 }, { 41, -40 } }, g.P{ { 45, -39 }, { 50, -43 }, { 49, -39 } },
    g.L({ { 53, -32 }, { 53, -36 } }, 1), g.P{ { 53, -36 }, { 50, -38 }, { 51, -35 } }, g.P{ { 53, -36 }, { 57, -39 }, { 56, -35 } })
  local flag = U(g.R(58, -46, 58, -26), g.P{ { 59, -46 }, { 59, -39 }, { 52, -42 } })
  shadowE(347, 261, 32, 3)
  edge("Seed Swap", U(body, handle, wm, packs, pots, sprouts, flag), CART.deep)
  form(body, CART, { s = 2 })
  fm(g.R(2, -26, 56, -25), CART.hi) fm(g.R(2, -11, 56, -10), CART.deep)
  for x = 12, 52, 10 do fm(g.R(x, -23, x, -13), CART.shade) end
  -- painted seed emblem on the side panel
  fm(g.R(26, -21, 31, -16), P.cream) fm(g.R(28, -20, 29, -17), WOOD.shade) g.px(30, -21, LEAF.base) g.px(31, -22, LEAF.base)
  form(handle, WOOD, { s = 0 })
  for i, w in ipairs(wheels) do
    form(w[1], WOOD, { s = 2 })
    local wx = w[2]
    fm(g.L({ { wx, -15 }, { wx, -1 } }, 1), WOOD.deep) fm(g.L({ { wx - 7, -8 }, { wx + 7, -8 } }, 1), WOOD.deep)
    fm(g.R(wx - 1, -9, wx + 1, -7), P.stone.base)
  end
  for i = 0, 4 do
    local R = PK[i + 1]
    local m = g.R(4 + i * 7, -38 + (i % 2), 9 + i * 7, -26)
    form(m, R, { s = 1 })
    fm(g.R(4 + i * 7, -38 + (i % 2), 9 + i * 7, -37 + (i % 2)), R.deep) -- folded top
    fm(g.R(5 + i * 7, -33 + (i % 2), 8 + i * 7, -30 + (i % 2)), P.cream)  -- picture window
    g.px(6 + i * 7, -32 + (i % 2), ({ P.ember.base, LEAF.base, P.gold.base, LEAF.shade, P.petal.base })[i + 1])
    g.px(7 + i * 7, -31 + (i % 2), LEAF.base)
  end
  form(pots, TERRA, { s = 1 }) fm(g.R(41, -34, 49, -33), TERRA.hi) fm(g.R(50, -32, 57, -31), TERRA.hi)
  form(sprouts, LEAF, { s = 0 })
  form(flag, P.gold, { s = 0 }) fm(g.R(58, -46, 58, -26), WOOD.shade)
end

-- HAYSTACK with a TINY DOOR (quirk), above the UI corner
do
  local g = G(398, 226)
  local stack = g.E(19, -10, 19, 15):clip(g.R(-1, -27, 39, 0))
  shadowE(417, 227, 22, 3)
  edge(nil, stack, HAY.deep)
  form(stack, HAY, { s = 3, l = 2 })
  stack:each(function(x, y)
    local hh = hash(x, y) % 7
    if hh == 0 and stack:has(x, y + 2) then px(x, y, HAY.shade) px(x, y + 1, HAY.shade)
    elseif hh == 1 then px(x, y, HAY.hi) end
  end)
  -- tiny door, step and window
  local door = g.RR(16, -12, 23, 0, 3)
  rim(door, P.ember.deep) form(door, P.ember, { s = 1 }) g.px(21, -6, P.gold.hi)
  fm(g.R(15, 1, 24, 1), P.stone.base)
  local win = g.R(28, -16, 31, -13) rim(win, HAY.deep) fm(win, "#ffe38a") g.px(28, -16, P.cream)
  -- stovepipe chimney
  fm(g.R(10, -29, 12, -23), P.stone.shade) fm(g.R(9, -30, 13, -30), P.stone.deep)
  fm(g.R(10, -33, 11, -32), "#f6f4ee") fm(g.R(12, -36, 14, -35), "#f6f4ee")
end

----------------------------------------------------------------------------------------------- BUNTING (top)
do
  local postL = Rm(1, 6, 4, 108)
  rim(postL, DARKW.deep) form(postL, WOOD, { s = 1 }) fm(Rm(1, 6, 4, 7), WOOD.hi)
  local x0, x1 = 4, 460
  local function by(x) return 9 + 16 * sin(pi * (x - x0) / (x1 - x0)) end
  local FL = { P.ember, P.gold, P.sea, P.petal, LEAF, P.dusk }
  for x = x0, x1 do px(x, floor(by(x) + .5), "#6a4a3a") end
  local k = 0
  for x = x0 + 8, x1 - 14, 15 do
    local y = floor(by(x + 4) + .5)
    local f = c:poly{ { x, y + 1 }, { x + 9, y + 1 }, { x + 4.5, y + 10 } }
    local R = FL[k % #FL + 1]
    rim(f, R.deep) fm(f, R.base)
    fm(c:poly{ { x + 5, y + 1 }, { x + 9, y + 1 }, { x + 5, y + 9 } }, R.shade)
    px(x + 1, y + 2, R.hi) px(x + 2, y + 2, R.hi)
    k = k + 1
  end
end

----------------------------------------------------------------------------------------------- CHECKS
-- stand points: plain ground radius 28 (circle) around each
local LAY = {
  spots = {
    { "rest", "Rest Bench", 55, 240 }, { "trader", "Trader Stall", 167, 168 }, { "well", "Wishing Well", 247, 164 },
    { "table", "Long Table", 376, 174 }, { "board", "Notice Board", 252, 80 }, { "seeds", "Seed Swap", 348, 238 },
    { "forage", "Forage Patch", 41, 172 }, { "pond", "Fishing Pond", 207, 242 }, { "homes", "Cottages", 78, 80 },
    { "wild", "Wild Trail", 430, 100 } },
}
for i, s in ipairs(STAND) do
  local hit, hitE = 0, 0
  for y = s[2] - 28, s[2] + 28 do for x = s[1] - 28, s[1] + 28 do
    if OBJ:has(x, y) then
      if (x - s[1]) ^ 2 + (y - s[2]) ^ 2 <= 28 * 28 then hit = hit + 1 end
      if ((x - s[1]) / 28) ^ 2 + ((y - s[2]) / 16) ^ 2 <= 1 then hitE = hitE + 1 end
    end
  end end
  print(string.format("stand %d (%d,%d): object px in r28 circle=%d, in 28x16 oval=%d", i, s[1], s[2], hit, hitE))
end
for i = 1, #BOX do for j = i + 1, #BOX do
  local a, b = BOX[i][2], BOX[j][2]
  local gx = max(a[1] - b[3], b[1] - a[3]) - 1
  local gyy = max(a[2] - b[4], b[2] - a[4]) - 1
  if max(gx, gyy) < 14 then print(string.format("gap %s / %s: %d,%d", BOX[i][1], BOX[j][1], gx, gyy)) end
end end
for _, b in ipairs(BOX) do print("box", b[1], table.concat(b[2], ",")) end
local cz = 0
OBJ:each(function(x, y) if x >= 380 and y >= 230 then cz = cz + 1 end end)
print("compass zone object px:", cz)

-- layout json
do
  local parts = {}
  for _, s in ipairs(LAY.spots) do parts[#parts + 1] = string.format('  {"k":"%s","name":"%s","x":%d,"y":%d}', s[1], s[2], s[3], s[4]) end
  local st = {}
  for _, s in ipairs(STAND) do st[#st + 1] = string.format('{"x":%d,"y":%d}', s[1], s[2]) end
  local js = '{"w":480,"h":270,"horizon":96,"view":"flat",\n "spots":[\n' .. table.concat(parts, ",\n") ..
    '\n ],\n "stand":[' .. table.concat(st, ",") .. '],\n "compass_clear":[380,230,480,270]}\n'
  local f = io.open(out .. NAME .. ".layout.json", "w") f:write(js) f:close()
end

c:finish{ outline = false }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
