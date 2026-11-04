-- here-stop-grassland-persp (attempt 2B): GRASSLAND ROAD REST STOP, gate view, ONE-POINT perspective.
-- Native 480x270 (scale 1). Horizon y=112, vanishing point (240,112). Dirt road from bottom centre to the VP.
-- Layout (no overlaps, >=12 px ground between objects, objects 48-72 px wide at their tier):
--   LEFT  near  : Rest Bench under a small tree (x18-90, base 222)
--         mid   : Trader Stall (x103-167, base 186)
--         far   : Wishing Well (x171-219, base 144)     far-left: Forage Patch (x20-80, base 134)
--         far+  : Seed Swap cart (x110-160, base 120)
--   RIGHT near  : Fishing Pond 84 px + small jetty + propped rod (x380-464, base 226)
--         mid   : Long Table (x322-382, base 186)
--         far   : Notice Board (x262-310, base 144)     far-right: Wild Trail grove + signpost (x400-466, base 168)
--         far+  : Cottages x2 (x320-390, base 122)
--   Foreground (in front of the gate line y=228): wheelbarrow of pumpkins (beanstalk up the left post), haystack.
--   Quirks: scarecrow with a teapot hat, snail-shaped mailbox, haystack with a tiny door, kite caught in the oak,
--           wheelbarrow of pumpkins sprouting a beanstalk.
-- Gate: low rustic log frame at the edges, bunting, a hanging lantern. Bottom-right 100x40 kept calm.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local NAME = "here-stop-grassland-persp"
local W, H = 480, 270
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local floor, sin, cos, abs, min, max, pi = math.floor, math.sin, math.cos, math.abs, math.min, math.max, math.pi
local HZ, VX = 112, 240
local function E(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry or rx) end
local function Rm(x0, y0, x1, y1) return c:rect(x0, y0, x1, y1) end
local function Pg(t) return c:poly(t) end
local function Ln(t, w) return c:line(t, w or 1) end
local function fm(m, hex) c:fillMask(m, hex) return m end
local function hash(a, b)
  local h = (a * 374761393 + b * 668265263 + 97) % 2147483647
  h = (h ~ (h >> 13)) * 1274126177 % 2147483647
  h = h ~ (h >> 16)
  return h % 1000
end
local function px(x, y, h) c:px(x, y, h) end
local function rim(m, hex) return c:rim(m, hex) end
local function clampb(v) return max(0, min(255, floor(v + .5))) end
-- darker, cooler (violet) copy of a colour, for cast shadows
local function D(hex, f)
  f = f or .8
  local r, g, b = tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
  return string.format("#%02x%02x%02x", clampb(r * f - 6), clampb(g * (f - .07)), clampb(b * f + (1 - f) * 90))
end
local function shadowM(m, f) m:each(function(x, y) local h = c:get(x, y) if h then px(x, y, D(h, f or .8)) end end) end
local function shadowE(cx, cy, rx, ry)
  shadowM(E(cx, cy, rx, ry), .82)
  shadowM(E(cx, cy, rx * .72, max(1, ry * .6)), .9)
end
-- form painter: base, lit crescent upper-left, cool shade crescent lower-right, deep underside
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
  if o.pop then px(o.pop[1], o.pop[2], R.pop or P.cream) px(o.pop[1] + 1, o.pop[2], R.pop or P.cream) end
  return m
end
-- solid: 1px dark edge in its own deep tone, then the form
local function solid(m, R, o) rim(m, R.deep) return form(m, R, o) end

-- ramps (shade = cool violet-leaning)
local WOOD  = { hi = "#e2ab72", base = "#b07040", shade = "#7c4a46", deep = "#4a2a34" }
local HONEY = { hi = "#f6d08a", base = "#dca15a", shade = "#a8704e", deep = "#6a3e3a" }
local DARKW = { hi = "#b98660", base = "#86563e", shade = "#5e3c42", deep = "#36222e" }
local GREYW = { hi = "#e2d6c2", base = "#b4a490", shade = "#86788a", deep = "#4e4456" }
local LOG   = { hi = "#c79868", base = "#946240", shade = "#664050", deep = "#3a2430" }
local CUSH  = { hi = "#ff8a5c", base = "#e8493b", shade = "#b02e4a", deep = "#6a1e3e" }
local TEAL  = { hi = "#9ae2d8", base = "#43b0b4", shade = "#337aa6", deep = "#22406a" }
local LEAF  = { hi = "#d2ec84", base = "#86c858", shade = "#4a8c5c", deep = "#264e4c" }
local OAKD  = { hi = "#7cbc5c", base = "#3f8a52", shade = "#2c6052", deep = "#1c3a40" }
local PETAL = P.petal
local STONE = { hi = "#eceaf0", base = "#b4b2c2", shade = "#7e7c9a", deep = "#46465e" }
local ROOF  = { hi = "#c2a8f0", base = "#8a6cd0", shade = "#5a449e", deep = "#33275e" }
local CORK  = { hi = "#e8b07a", base = "#c98a52", shade = "#985a4e", deep = "#5c3434" }
local MOSSR = { hi = "#a8d870", base = "#5aa850", shade = "#3a7856", deep = "#22484a" }
local TH    = { hi = "#f0bc66", base = "#cc8c44", shade = "#985e4c", deep = "#5a3436" }
local WALL  = { hi = "#fff4d6", base = "#f4dfba", shade = "#c8b2b4", deep = "#86708a" }
local TERRA = { hi = "#f4a678", base = "#d4704a", shade = "#a04a4e", deep = "#5c2a36" }
local PUMP  = { hi = "#ffc46b", base = "#f59a32", shade = "#c86040", deep = "#7a3430" }
local GOLD  = P.gold
local SEA   = { hi = "#c4f2ea", base = "#62c2d2", shade = "#3c86be", deep = "#24467e" }
local STRAW = { hi = "#fbe08a", base = "#e8bc52", shade = "#b8844e", deep = "#6e4a3a" }
local DUSK  = P.dusk
local IRON  = { hi = "#8a8aa6", base = "#545470", shade = "#3a3a54", deep = "#24223a" }

------------------------------------------------------------------ SKY
c:stripes(0, 100, { "#86c3ee", "#9fd1f2", "#b9def5", "#d4ecf9" }, { 3, 3, 3, 2 })
c:cloud(36, 64, 46, P.cream, P.sky.hi)
c:cloud(96, 50, 22, P.cream, P.sky.hi)
c:cloud(286, 56, 58, P.cream, P.sky.hi)
c:cloud(356, 44, 24, P.cream, P.sky.hi)
c:cloud(170, 76, 30, P.cream, P.sky.hi)
c:cloud(400, 84, 34, "#f2f6fa", P.sky.base)

------------------------------------------------------------------ FAR HILLS (violet), GOLDEN ROLLING GRASSLAND
local function h1(x) return 88 + 5 * sin(x / 41 + .4) + 3 * sin(x / 17) end
c:terrain(h1, "#aab2e2")
for x = 0, W - 1 do local y = floor(h1(x) + .5) if (x // 5) % 3 == 0 then px(x, y, "#c0c6ec") end end
local function h2(x) return 96 + 4 * sin(x / 33 + 2.1) + 2 * sin(x / 13 + 1) end
c:terrain(h2, "#9cc0a0")
local function h3(x) return 101 + 4 * sin(x / 27 + 4) + 1.5 * sin(x / 9) end
local gold = c:terrain(h3, "#eec45c")
-- field rows on the golden hills
gold:each(function(x, y)
  local t = y - h3(x)
  if t > 1 and floor(y + x * .18) % 4 == 0 then px(x, y, "#dcab4c") end
  if t >= 0 and t < 1 then px(x, y, "#f8da80") end
end)
-- hedgerow + tiny bales on the hill line
for x = 0, W - 1, 1 do
  local y = floor(h2(x) + .5)
  if hash(x, 4) % 7 < 3 then px(x, y, "#6f9c78") end
end
for _, b in ipairs({ { 60, 104 }, { 150, 106 }, { 330, 104 }, { 420, 105 } }) do
  fm(Rm(b[1], b[2], b[1] + 2, b[2] + 1), "#f0cc70") px(b[1] + 2, b[2] + 1, "#c8944c")
end

-- distant windmill on the hill at the road's end (x230-258)
do
  local tw = Pg{ { 239, 82 }, { 249, 82 }, { 252, 104 }, { 236, 104 } }
  rim(tw, "#6a6a96")
  fm(tw, "#efe4d4") fm(Pg{ { 246, 82 }, { 249, 82 }, { 252, 104 }, { 247, 104 } }, "#cbbec6")
  fm(Rm(242, 96, 245, 104), "#8a6a6a")
  fm(Rm(243, 88, 245, 90), "#8aa0d0")
  local cap = Pg{ { 237, 83 }, { 244, 76 }, { 251, 83 } } rim(cap, "#6a6a96") fm(cap, "#d86a5a")
  for _, a in ipairs({ .55, 2.12, 3.69, 5.26 }) do
    local x2, y2 = 244 + 15 * cos(a), 80 + 15 * sin(a)
    local nx, ny = -sin(a), cos(a)
    local s = Pg{ { 244 + 4 * cos(a), 80 + 4 * sin(a) }, { x2, y2 }, { x2 + 4 * nx, y2 + 4 * ny }, { 244 + 4 * cos(a) + 4 * nx, 80 + 4 * sin(a) + 4 * ny } }
    fm(s, "#f4eee2") c:edgeIn(s, "#b8aec4")
    fm(Ln({ { 244, 80 }, { x2, y2 } }, 1), "#7a5a5a")
  end
  px(244, 80, "#4a3440")
end

------------------------------------------------------------------ GROUND PLANE (horizon y=112)
local GB = { "#e2d074", "#d8ca6c", "#cec466", "#c4be60", "#bab85a" }
c:terrain(function() return HZ end, GB[1])
local bandY = { 118, 130, 152, 190 }
for i, by in ipairs(bandY) do
  c:terrain(function(x) return by + 1.5 * sin(x / 37 + i) end, GB[i + 1])
end
-- grass marks scaled with depth (tiny far, tufts near)
for i = 0, 5200 do
  local y = HZ + 1 + floor((hash(i, 7) / 1000) ^ 1.25 * (H - HZ - 1))
  local x = hash(i, 3) * W // 1000 + hash(i, 5) % 2
  local s = (y - HZ) / (H - HZ)
  local here = c:get(x, y)
  local base
  for k, g in ipairs(GB) do if here == g then base = k end end
  if base then
    local dk = D(GB[base], .86)
    local lt = "#f0e08a"
    local r = hash(i, 11) % 10
    if s < .15 then
      px(x, y, r < 6 and dk or lt)
    elseif s < .45 then
      px(x, y, dk) px(x + 1, y - 1, dk) if r < 3 then px(x + 1, y - 2, lt) end
    else
      px(x, y, dk) px(x + 1, y - 1, dk) px(x + 2, y, dk) px(x + 1, y - 2, r < 5 and lt or dk)
      if r == 9 then px(x + 4, y - 1, "#f5809f") px(x + 5, y - 1, "#f5809f") end
      if r == 8 then px(x + 4, y - 1, P.cream) end
    end
  end
end

------------------------------------------------------------------ ROAD to the vanishing point
local function rhw(y) return 82 * (y - HZ) / (H - HZ) end
local road = HP.mask()
for y = HZ, H - 1 do
  local hw = rhw(y)
  for x = floor(VX - hw - .5), floor(VX + hw + .5) do road:set(x, y) end
end
fm(road, "#e6c48e")
-- verge (darker edge) and worn tracks
for y = HZ + 1, H - 1 do
  local hw = rhw(y)
  local xl, xr = floor(VX - hw - .5), floor(VX + hw + .5)
  px(xl, y, "#b68a5e") px(xr, y, "#b68a5e")
  if hw > 10 then px(xl + 1, y, "#cfa676") px(xr - 1, y, "#cfa676") end
  -- two wheel ruts converging to the VP
  for _, f in ipairs({ -.55, .55 }) do
    local rx = VX + f * hw
    local w = max(1, floor(hw / 22))
    for k = 0, w - 1 do px(floor(rx + k - w / 2 + .5), y, "#d2a872") end
  end
  -- centre grass strip, thin and fading out far
  if hw > 18 then
    local w = floor(hw / 18)
    for k = -w, w do if hash(y, k + 50) % 3 > 0 then px(VX + k, y, "#cdbe66") end end
  end
end
-- pebbles scaled with depth
for i = 0, 420 do
  local y = HZ + 3 + floor((hash(i, 31) / 1000) ^ .8 * (H - HZ - 4))
  local hw = rhw(y)
  local x = floor(VX - hw + (hash(i, 33) / 1000) * 2 * hw)
  local s = (y - HZ) / (H - HZ)
  if road:has(x, y) and road:has(x + 2, y) then
    if s < .35 then px(x, y, "#c89c6c")
    else
      px(x, y, "#f6dcaa") px(x + 1, y, "#c49468")
      if s > .7 then px(x, y + 1, "#c49468") px(x + 1, y + 1, "#a87a5a") end
    end
  end
end

------------------------------------------------------------------ CAST SHADOWS (cool violet, before the objects)
shadowE(56, 220, 38, 5)    -- bench + tree
shadowE(137, 186, 34, 4)   -- trader
shadowE(197, 144, 25, 3)   -- well
shadowE(52, 134, 32, 3)    -- forage
shadowE(136, 120, 26, 2)   -- seed cart
shadowE(286, 144, 25, 3)   -- board
shadowE(353, 122, 36, 2)   -- cottages
shadowE(352, 186, 32, 4)   -- table
shadowE(436, 168, 34, 3)   -- trail grove
shadowE(313, 222, 13, 3)   -- mailbox
shadowE(76, 263, 22, 4)    -- haystack
shadowE(34, 263, 20, 4)    -- wheelbarrow

------------------------------------------------------------------ SCARECROW with a teapot hat (field, x89-103)
do
  fm(Rm(95, 92, 96, 112), WOOD.shade) px(95, 92, WOOD.hi)
  local arm = Rm(88, 97, 103, 98) fm(arm, WOOD.base)
  local shirt = Pg{ { 91, 95 }, { 100, 95 }, { 101, 104 }, { 90, 104 } }
  solid(shirt, { hi = "#9ad0f0", base = "#4f8ed8", shade = "#3c5eaa", deep = "#262e66" }, { s = 1 })
  for _, s in ipairs({ { 88, 99 }, { 103, 99 }, { 92, 105 }, { 99, 105 } }) do px(s[1], s[2], STRAW.base) end
  local head = Rm(93, 88, 98, 93) solid(head, STRAW, { s = 1 })
  px(94, 90, P.ink) px(97, 90, P.ink)
  -- teapot hat
  local pot = Pg{ { 92, 87 }, { 99, 87 }, { 98, 82 }, { 93, 82 } } solid(pot, TEAL, { s = 1 })
  px(95, 81, TEAL.deep) px(96, 81, TEAL.deep)
  fm(Ln({ { 100, 85 }, { 102, 83 } }, 1), TEAL.shade)
  px(91, 84, TEAL.shade) px(91, 85, TEAL.shade)
end

------------------------------------------------------------------ FORAGE PATCH (far-left, x20-80, base 134)
do
  -- soil bed
  local soil = Pg{ { 26, 121 }, { 76, 121 }, { 79, 128 }, { 23, 128 } }
  solid(soil, { hi = "#a87050", base = "#7a4c3a", shade = "#5a3640", deep = "#36202c" }, { s = 1, l = 0 })
  for x = 26, 76, 5 do px(x, 124, "#5a3640") px(x + 2, 126, "#a87050") end
  -- berry bush (left)
  local bush = E(36, 114, 10, 8):add(E(30, 118, 6, 5)):add(E(43, 118, 6, 5))
  solid(bush, MOSSR, { s = 2 })
  for i = 0, 14 do local bx, by = 27 + hash(i, 41) % 18, 107 + hash(i, 43) % 13
    if bush:has(bx, by) and bush:has(bx + 1, by + 1) then px(bx, by, MOSSR.shade) end end
  for _, b in ipairs({ { 31, 111 }, { 38, 109 }, { 42, 114 }, { 34, 117 }, { 28, 115 }, { 40, 119 }, { 45, 111 } }) do
    fm(Rm(b[1], b[2], b[1] + 1, b[2] + 1), CUSH.base) px(b[1], b[2], CUSH.hi) px(b[1] + 1, b[2] + 1, CUSH.deep)
  end
  -- mushrooms (centre)
  local function shroom(x, y, r)
    local st = Rm(x - 1, y - r, x + 1, y) solid(st, WALL, { s = 1, l = 0 })
    local cap = Pg{ { x - r - 1, y - r }, { x - r + 1, y - r - 3 }, { x + r - 1, y - r - 3 }, { x + r + 1, y - r } }
    solid(cap, CUSH, { s = 1 })
    px(x - 1, y - r - 2, P.cream) px(x + 2, y - r - 1, P.cream)
  end
  shroom(52, 125, 4) shroom(59, 126, 3) shroom(56, 121, 3)
  -- herbs (right): thin stems, leaves, lavender tips
  for i, hx in ipairs({ 64, 67, 70, 73, 76 }) do
    local top = 108 + (i * 3) % 6
    fm(Ln({ { hx, 126 }, { hx + (i % 2), top } }, 1), "#4a8c5c")
    for yy = top + 2, 124, 4 do px(hx - 1, yy, "#86c858") px(hx + 1, yy + 1, "#86c858") end
    if i % 2 == 1 then fm(Rm(hx, top - 3, hx + 1, top), DUSK.base) px(hx, top - 3, DUSK.hi)
    else px(hx + 1, top - 1, "#d2ec84") end
  end
  -- low picket fence along the front + corner posts
  local fence = HP.mask()
  for x = 21, 79, 4 do fence:add(Pg{ { x, 127 }, { x + 1, 125 }, { x + 2, 127 }, { x + 2, 133 }, { x, 133 } }) end
  fence:add(Rm(20, 119, 22, 133)):add(Rm(78, 119, 80, 133))
  fence:add(Rm(20, 129, 80, 130))
  solid(fence, GREYW, { s = 1, l = 0 })
end

------------------------------------------------------------------ SEED SWAP cart (far, x110-160, base 120)
do
  local CART = { hi = "#b0e8c0", base = "#5cbc8a", shade = "#3c8682", deep = "#22485a" }
  -- handles + prop leg
  local hd = Ln({ { 148, 106 }, { 160, 113 } }, 2):add(Rm(155, 111, 156, 119))
  solid(hd, WOOD, { s = 0 })
  local lg = Rm(113, 110, 114, 119) solid(lg, WOOD, { s = 0 })
  -- tray body
  local body = Pg{ { 110, 101 }, { 150, 101 }, { 148, 112 }, { 112, 112 } }
  solid(body, CART, { s = 2 })
  for x = 118, 144, 8 do fm(Rm(x, 103, x, 110), CART.shade) end
  fm(Rm(111, 101, 149, 101), CART.hi)
  -- seed packets
  local PK = { { "#f5809f", "#ffc4d8" }, { "#f5b82e", "#ffe38a" }, { "#8a6fd0", "#c9b2f0" }, { "#e8493b", "#ff8a5c" }, { "#5fc4c8", "#b6f0e0" } }
  for i, col in ipairs(PK) do
    local x = 112 + (i - 1) * 5
    local y = 94 + (i % 2)
    local m = Rm(x, y, x + 3, 100) rim(m, "#5c3a46") fm(m, P.cream)
    fm(Rm(x, y + 2, x + 3, y + 4), col[1]) px(x, y + 2, col[2])
  end
  -- sprout pots
  for i, x in ipairs({ 139, 145 }) do
    local pot = Pg{ { x, 95 }, { x + 5, 95 }, { x + 4, 100 }, { x + 1, 100 } } solid(pot, TERRA, { s = 1 })
    fm(Rm(x, 95, x + 5, 95), TERRA.hi)
    fm(Ln({ { x + 2, 94 }, { x + 2, 90 - i } }, 1), "#3f9150")
    px(x + 1, 90 - i, "#86c858") px(x, 89 - i, "#86c858") px(x + 3, 90 - i, "#86c858") px(x + 4, 89 - i, "#c4e07a")
  end
  -- wheel (octagon, spokes)
  local wh = Pg{ { 126, 107 }, { 131, 105 }, { 136, 107 }, { 138, 112 }, { 136, 117 }, { 131, 119 }, { 126, 117 }, { 124, 112 } }
  rim(wh, WOOD.deep) fm(wh, WOOD.base)
  fm(wh:edge(), WOOD.shade) fm(Pg{ { 127, 108 }, { 131, 106 }, { 128, 109 } }, WOOD.hi)
  local hub = Pg{ { 126, 110 }, { 131, 108 }, { 136, 110 }, { 136, 114 }, { 131, 116 }, { 126, 114 } }
  hub:shrink(1):each(function(x, y) px(x, y, "#6e8a5a") end)
  fm(Ln({ { 125, 112 }, { 137, 112 } }, 1), WOOD.shade) fm(Ln({ { 131, 106 }, { 131, 118 } }, 1), WOOD.shade)
  fm(Rm(130, 111, 132, 113), WOOD.deep) px(130, 111, WOOD.hi)
end

------------------------------------------------------------------ WISHING WELL (far, x171-219, base 144)
do
  -- posts
  local po = Rm(178, 104, 180, 128):add(Rm(210, 104, 212, 128))
  solid(po, WOOD, { s = 1 })
  -- axle + crank, rope, bucket
  fm(Rm(181, 112, 209, 113), WOOD.deep) fm(Rm(181, 112, 209, 112), WOOD.shade)
  fm(Rm(213, 112, 214, 117), IRON.base) fm(Rm(213, 117, 216, 118), IRON.base)
  fm(Rm(195, 114, 195, 118), "#e2c890")
  local bk = Pg{ { 191, 118 }, { 200, 118 }, { 199, 125 }, { 192, 125 } } solid(bk, WOOD, { s = 1 })
  fm(Rm(192, 120, 199, 120), IRON.base) fm(Rm(192, 123, 199, 123), IRON.base)
  -- roof (shingled trapezoid)
  local roof = Pg{ { 171, 108 }, { 219, 108 }, { 212, 96 }, { 178, 96 } }
  solid(roof, ROOF, { s = 1 })
  for y = 99, 107, 3 do
    roof:each(function(x, yy) if yy == y then px(x, yy, ROOF.shade) end end)
    for x = 172 + (y % 2) * 3, 218, 6 do if roof:has(x, y - 1) then px(x, y - 1, ROOF.shade) px(x, y - 2, ROOF.shade) end end
  end
  fm(Rm(179, 96, 211, 96), ROOF.hi) px(184, 97, P.cream) px(185, 97, P.cream)
  -- stone drum
  local drum = Rm(176, 127, 214, 141):add(E(195, 141, 19, 3)):add(E(195, 127, 19, 4))
  solid(drum, STONE, { s = 2 })
  for row = 0, 3 do
    local y = 130 + row * 4
    fm(Rm(177, y, 213, y), STONE.shade)
    for x = 177 + (row % 2) * 4, 213, 8 do px(x, y + 1, STONE.shade) px(x, y + 2, STONE.shade) px(x, y + 3, STONE.shade) end
  end
  for i = 0, 10 do local x = 178 + hash(i, 61) % 34 local y = 131 + hash(i, 63) % 10 if drum:has(x + 2, y) then px(x, y, STONE.hi) end end
  -- rim top + water hole
  local top = E(195, 127, 19, 4) fm(top, STONE.hi) c:edgeIn(top, STONE.shade)
  fm(E(195, 127, 15, 2), SEA.deep) fm(Rm(188, 127, 198, 127), SEA.shade) px(190, 126, SEA.hi)
  -- re-draw bucket + rope over the hole (it hangs above)
  fm(Rm(195, 114, 195, 118), "#e2c890")
  solid(bk, WOOD, { s = 1 })
  fm(Rm(192, 120, 199, 120), IRON.base) fm(Rm(192, 123, 199, 123), IRON.base)
  px(192, 119, WOOD.hi)
  fm(Rm(178, 125, 180, 127), WOOD.shade) fm(Rm(210, 125, 212, 127), WOOD.shade)
end

------------------------------------------------------------------ TRADER STALL (mid, x103-167, base 186)
do
  -- back panel (shadowed interior)
  local back = Rm(111, 148, 159, 166) fm(back, "#6a4a5a")
  for x = 115, 157, 6 do fm(Rm(x, 148, x, 166), "#5a3e52") end
  -- hanging garlands
  for x = 116, 154, 4 do px(x, 151 + (x // 4) % 2, P.gold.base) end
  -- posts
  local po = Rm(107, 140, 110, 185):add(Rm(160, 140, 163, 185))
  solid(po, HONEY, { s = 1 })
  -- awning: slanted top + striped scallops
  local aw = Pg{ { 107, 132 }, { 163, 132 }, { 168, 146 }, { 102, 146 } }
  local sc = HP.mask()
  for i = 0, 10 do local x0 = 102 + i * 6 sc:add(Pg{ { x0, 146 }, { x0 + 6, 146 }, { x0 + 5, 149 }, { x0 + 1, 149 } }) end
  local awn = aw:copy():add(sc)
  rim(awn, PETAL.deep)
  awn:each(function(x, y)
    local t = (y - 132) / 14
    local xl = 107 - 5 * min(t, 1)
    local xr = 163 + 5 * min(t, 1)
    local k = floor((x - xl) / ((xr - xl) / 11))
    if y > 146 then k = floor((x - 102) / 6) end
    local pink = k % 2 == 0
    local col = pink and PETAL.base or P.cream
    if y >= 145 then col = pink and PETAL.shade or "#e8d6c4" end
    if y == 132 then col = pink and PETAL.hi or "#fffaf0" end
    px(x, y, col)
  end)
  fm(Rm(108, 133, 116, 133), "#ffe4ee")
  -- counter
  local ct = Pg{ { 106, 164 }, { 164, 164 }, { 165, 168 }, { 105, 168 } }
  local cf = Rm(105, 168, 165, 184)
  rim(ct:copy():add(cf), HONEY.deep)
  fm(ct, HONEY.hi) fm(Rm(105, 168, 165, 168), HONEY.shade)
  form(cf, HONEY, { s = 2, l = 0 })
  for x = 112, 160, 7 do fm(Rm(x, 170, x, 183), HONEY.shade) px(x + 1, 170, HONEY.hi) end
  fm(Rm(105, 174, 165, 176), PETAL.base) fm(Rm(105, 176, 165, 176), PETAL.shade)
  -- baskets with produce
  local function basket(x0, x1, y0, fill)
    local b = Pg{ { x0, y0 }, { x1, y0 }, { x1 - 2, 164 }, { x0 + 2, 164 } }
    local heap = E((x0 + x1) / 2, y0, (x1 - x0) / 2 - 1, 4):clip(Rm(x0, y0 - 6, x1, y0))
    rim(heap, fill.deep) form(heap, fill, { s = 1 })
    solid(b, STRAW, { s = 1, l = 0 })
    for y = y0 + 2, 163, 2 do for x = x0 + 1, x1 - 1 do if b:has(x, y) and (x + y) % 3 == 0 then px(x, y, STRAW.shade) end end end
    fm(Rm(x0, y0, x1, y0), STRAW.hi)
    return heap
  end
  local ap = basket(113, 127, 158, CUSH)
  for _, p in ipairs({ { 116, 155 }, { 121, 154 }, { 124, 156 } }) do px(p[1], p[2], CUSH.hi) px(p[1] + 1, p[2] - 1, "#3f9150") end
  basket(131, 145, 157, PUMP)
  for x = 133, 143, 3 do fm(Rm(x, 151, x, 153), "#4a8c5c") px(x + 1, 150, "#86c858") end
  basket(149, 159, 158, LEAF)
  px(152, 155, LEAF.hi) px(153, 155, LEAF.hi)
  -- price flag (no text): tiny pennant on the right post
  fm(Pg{ { 164, 140 }, { 170, 142 }, { 164, 144 } }, P.gold.base)
end

------------------------------------------------------------------ REST BENCH under a small tree (near, x18-90, base 222)
do
  -- little tree behind the bench's left end
  local trunk = Pg{ { 22, 214 }, { 27, 214 }, { 26, 170 }, { 23, 170 } }:add(Ln({ { 25, 180 }, { 32, 170 } }, 2))
  solid(trunk, LOG, { s = 1 })
  for y = 176, 212, 5 do px(24, y, LOG.shade) px(24, y + 1, LOG.shade) end
  local can = E(40, 161, 20, 13):add(E(26, 166, 9, 8)):add(E(54, 166, 9, 8)):add(E(40, 152, 12, 7))
  solid(can, LEAF, { s = 3 })
  for i = 0, 70 do local x, y = 20 + hash(i, 71) % 44, 146 + hash(i, 73) % 30
    if can:has(x, y) and can:has(x + 1, y + 1) and can:has(x - 1, y - 1) then
      local hiSide = (x - 40) + (y - 161) < -8
      px(x, y, hiSide and LEAF.hi or LEAF.shade) px(x + 1, y, hiSide and LEAF.hi or LEAF.shade) end end
  px(30, 154, P.cream) px(31, 154, P.cream)
  -- back rest: posts + two planks (behind the seat)
  local bp = Rm(28, 180, 30, 197):add(Rm(81, 185, 83, 202))
  solid(bp, WOOD, { s = 1 })
  local pl1 = Pg{ { 29, 182 }, { 83, 187 }, { 83, 191 }, { 29, 186 } }
  local pl2 = Pg{ { 29, 189 }, { 83, 194 }, { 83, 198 }, { 29, 193 } }
  solid(pl1, WOOD, { s = 1, l = 0 }) fm(Ln({ { 30, 182 }, { 82, 187 } }, 1), WOOD.hi)
  solid(pl2, WOOD, { s = 1, l = 0 }) fm(Ln({ { 30, 189 }, { 82, 194 } }, 1), WOOD.hi)
  for x = 36, 78, 9 do px(x, 184 + (x - 29) * 5 // 54, WOOD.shade) end
  -- back legs (short, behind)
  local bl = Rm(29, 198, 30, 211):add(Rm(82, 203, 83, 216))
  solid(bl, WOOD, { s = 0 })
  -- seat top (parallelogram) + front face
  local seat = Pg{ { 32, 203 }, { 87, 208 }, { 83, 201 }, { 28, 196 } }
  local face = Pg{ { 32, 203 }, { 87, 208 }, { 87, 211 }, { 32, 206 } }
  rim(seat:copy():add(face), WOOD.deep)
  fm(seat, WOOD.base)
  fm(Ln({ { 30, 198 }, { 84, 203 } }, 1), WOOD.shade)
  fm(Ln({ { 31, 201 }, { 86, 206 } }, 1), WOOD.hi)
  fm(face, WOOD.shade) fm(Ln({ { 32, 206 }, { 87, 211 } }, 1), WOOD.deep)
  -- front legs
  local fl = Rm(32, 206, 34, 219):add(Rm(84, 211, 86, 222))
  solid(fl, WOOD, { s = 1 })
  fm(Rm(32, 207, 32, 218), WOOD.hi) fm(Rm(84, 212, 84, 221), WOOD.hi)
  -- cushion (red, tufted)
  local cu = Pg{ { 35, 202 }, { 63, 205 }, { 60, 197 }, { 32, 194 } }
  local cuF = Pg{ { 35, 202 }, { 63, 205 }, { 63, 207 }, { 35, 204 } }
  rim(cu:copy():add(cuF), CUSH.deep)
  form(cu, CUSH, { s = 1, l = 1 }) fm(cuF, CUSH.shade)
  px(42, 199, CUSH.shade) px(52, 200, CUSH.shade) px(37, 197, CUSH.hi) px(38, 197, CUSH.hi)
  -- arm rests (posts + rails)
  local arms = Rm(31, 193, 33, 203):add(Ln({ { 32, 193 }, { 28, 187 } }, 2))
    :add(Rm(85, 198, 87, 208)):add(Ln({ { 86, 198 }, { 82, 192 } }, 2))
  solid(arms, WOOD, { s = 1 })
  fm(Ln({ { 31, 193 }, { 27, 187 } }, 1), WOOD.hi) fm(Ln({ { 85, 198 }, { 81, 192 } }, 1), WOOD.hi)
  -- teapot on the seat (teal)
  local tp = Pg{ { 68, 198 }, { 69, 194 }, { 72, 192 }, { 76, 192 }, { 79, 194 }, { 80, 198 }, { 78, 201 }, { 70, 201 } }
  local sp = Ln({ { 80, 198 }, { 83, 194 } }, 2)
  local hdl = Rm(65, 194, 67, 198)
  rim(tp:copy():add(sp):add(hdl), TEAL.deep)
  fm(hdl, TEAL.shade) fm(Rm(66, 195, 66, 197), TEAL.deep)
  form(tp, TEAL, { s = 2 }) fm(sp, TEAL.base) px(83, 193, TEAL.shade)
  fm(Rm(71, 191, 77, 192), TEAL.shade) fm(Rm(73, 189, 75, 190), TEAL.base) px(73, 189, TEAL.hi)
  fm(Rm(69, 196, 79, 196), P.cream) px(71, 194, P.cream) px(72, 194, P.cream)
end

------------------------------------------------------------------ NOTICE BOARD (far, x262-310, base 144)
do
  local po = Rm(266, 116, 268, 143):add(Rm(304, 116, 306, 143))
  solid(po, DARKW, { s = 1 })
  local frame = Rm(263, 116, 309, 137)
  solid(frame, DARKW, { s = 1 })
  local cork = Rm(265, 118, 307, 135) form(cork, CORK, { s = 1, l = 0 })
  for i = 0, 30 do local x, y = 266 + hash(i, 81) % 41, 119 + hash(i, 83) % 16 px(x, y, CORK.shade) end
  -- small plank roof
  local rf = Pg{ { 261, 116 }, { 311, 116 }, { 307, 112 }, { 265, 112 } }
  solid(rf, MOSSR, { s = 1 })
  fm(Rm(266, 112, 306, 112), MOSSR.hi)
  -- pinned papers (no text: coloured header bands and a tiny drawing)
  local papers = {
    { 268, 120, 275, 130, P.cream, P.ember.base, "#e83a6a" },
    { 278, 119, 287, 127, "#ffe9a8", P.moss.shade, "#3a86b0" },
    { 290, 121, 297, 133, "#e0f0ff", P.sea.shade, "#e8493b" },
    { 300, 119, 305, 126, "#ffd6e2", P.petal.shade, "#f5b82e" },
    { 279, 129, 287, 134, "#f4f0e0", P.gold.shade, "#8a6fd0" },
  }
  for _, p in ipairs(papers) do
    local m = Rm(p[1], p[2], p[3], p[4])
    rim(m, "#7a5a5a") fm(m, p[5])
    fm(Rm(p[1], p[2] + 1, p[3], p[2] + 2), p[6])
    px(p[3], p[4], D(p[5], .85)) px(p[3] - 1, p[4], D(p[5], .85))
    px((p[1] + p[3]) // 2, p[2], p[7])
  end
  -- tiny drawings: a leaf and a house shape
  px(271, 125, P.moss.base) px(272, 124, P.moss.base) px(272, 126, P.moss.shade)
  fm(Pg{ { 292, 128 }, { 294, 126 }, { 296, 128 } }, P.ember.base) fm(Rm(293, 129, 295, 131), P.wood.base)
  -- second leaf on the yellow note
  px(283, 123, P.ember.base) px(284, 123, P.ember.base) px(284, 124, P.ember.shade)
end

------------------------------------------------------------------ COTTAGES x2 (far, x320-390, base 122)
do
  local function cottage(x0, x1, wy, by, rt, cx)
    -- chimney
    local ch = Rm(cx, rt - 5, cx + 3, rt + 6) solid(ch, STONE, { s = 1 })
    fm(Rm(cx - 1, rt - 6, cx + 4, rt - 5), STONE.deep)
    -- walls
    local wall = Rm(x0 + 2, wy, x1 - 2, by)
    solid(wall, WALL, { s = 2 })
    for y = wy + 3, by - 1, 3 do px(x0 + 3, y, WALL.shade) px(x1 - 4, y + 1, WALL.shade) end
    -- thatch roof (rounded trapezoid, row lines)
    local rf = Pg{ { x0 - 2, wy + 2 }, { x1 + 2, wy + 2 }, { x1 - 6, rt }, { x0 + 6, rt } }
    rf:add(Rm(x0 + 6, rt - 1, x1 - 6, rt))
    solid(rf, TH, { s = 2 })
    for y = rt + 3, wy, 3 do rf:each(function(x, yy) if yy == y and (x + y) % 5 ~= 0 then px(x, yy, TH.shade) end end) end
    for i = 0, 12 do local x = x0 + hash(i, x0) % (x1 - x0) local y = rt + 1 + hash(i, 91) % (wy - rt)
      if rf:has(x, y) and rf:has(x + 1, y) then px(x, y, TH.hi) end end
    -- door + window
    local dx = x0 + floor((x1 - x0) * .32)
    local door = Rm(dx, by - 8, dx + 5, by) solid(door, { hi = "#7ac0e0", base = "#3a80c0", shade = "#2c5a96", deep = "#1e3466" }, { s = 1 })
    px(dx + 4, by - 4, P.gold.base)
    local wx = dx + 10
    local win = Rm(wx, by - 9, wx + 5, by - 5)
    rim(win, WOOD.deep) fm(win, "#f7d36a") fm(Rm(wx + 2, by - 9, wx + 2, by - 5), WOOD.shade) fm(Rm(wx, by - 7, wx + 5, by - 7), WOOD.shade)
    fm(Rm(wx - 1, by - 4, wx + 6, by - 3), P.petal.base) px(wx + 1, by - 4, P.petal.hi)
  end
  cottage(322, 350, 109, 121, 95, 344)
  cottage(358, 388, 106, 121, 91, 362)
  -- chimney smoke curls
  for i, s in ipairs({ { 363, 82 }, { 366, 78 }, { 365, 73 }, { 345, 86 }, { 347, 82 } }) do
    fm(Rm(s[1], s[2], s[1] + 2, s[2] + 1), "#eef0f6") px(s[1] + 2, s[2] + 1, "#c8cce0")
  end
end

------------------------------------------------------------------ LONG TABLE (mid, x322-382, base 186)
do
  -- back bench (seen above the table's back edge)
  local bb = Pg{ { 330, 155 }, { 376, 155 }, { 377, 158 }, { 329, 158 } } solid(bb, HONEY, { s = 1, l = 0 })
  -- legs (A-frame, splayed)
  local legs = Ln({ { 334, 166 }, { 328, 185 } }, 2):add(Ln({ { 336, 166 }, { 342, 185 } }, 2))
    :add(Ln({ { 368, 166 }, { 362, 185 } }, 2)):add(Ln({ { 370, 166 }, { 376, 185 } }, 2))
  solid(legs, HONEY, { s = 0 })
  -- table top (trapezoid) + edge
  local top = Pg{ { 328, 159 }, { 378, 159 }, { 382, 167 }, { 324, 167 } }
  local edge = Rm(324, 168, 382, 170)
  rim(top:copy():add(edge), HONEY.deep)
  fm(top, HONEY.base)
  for y = 161, 166, 2 do fm(Ln({ { 326 - (y - 161) // 2, y }, { 380 + (y - 161) // 2, y } }, 1), HONEY.hi) end
  fm(edge, HONEY.shade) fm(Rm(324, 170, 382, 170), HONEY.deep)
  -- checked cloth runner (blue / cream)
  local cl = Pg{ { 340, 159 }, { 366, 159 }, { 368, 167 }, { 338, 167 } }:add(Rm(338, 168, 368, 171))
  cl:each(function(x, y) px(x, y, ((x // 2) + (y // 2)) % 2 == 0 and "#5a8ad8" or "#e8f0ff") end)
  fm(Rm(338, 171, 368, 171), "#3c5eaa")
  -- front bench
  local fb = Rm(322, 175, 384, 178) solid(fb, HONEY, { s = 1 })
  fm(Rm(323, 175, 383, 175), HONEY.hi)
  local fbl = Rm(326, 179, 328, 185):add(Rm(378, 179, 380, 185)) solid(fbl, HONEY, { s = 0 })
  -- bread loaf
  local br = E(333, 159, 6, 3) solid(br, { hi = "#f8d090", base = "#d8944c", shade = "#a8604a", deep = "#5e3434" }, { s = 1 })
  px(331, 158, "#a8604a") px(334, 157, "#a8604a") px(337, 158, "#a8604a") px(330, 157, P.cream)
  -- jam jar
  local jj = Rm(349, 155, 353, 161) solid(jj, CUSH, { s = 1 })
  fm(Rm(349, 154, 353, 155), P.cream) px(350, 157, "#ffd0c0")
  -- cups
  for _, x in ipairs({ 358, 366 }) do
    local cp = Rm(x, 157, x + 3, 161) solid(cp, TEAL, { s = 1 }) px(x + 4, 158, TEAL.deep) px(x + 4, 159, TEAL.deep)
    fm(Rm(x, 157, x + 3, 157), "#8a5a3e")
  end
  -- plate with a jam tart (petal)
  fm(Rm(372, 162, 378, 163), STONE.hi) fm(Rm(373, 161, 377, 161), PETAL.base)
end

------------------------------------------------------------------ WILD TRAIL grove + signpost (far-right, x400-466, base 168)
do
  -- path leaving into the trees at the right edge
  local path = Pg{ { 402, 170 }, { 424, 170 }, { 448, 158 }, { 470, 152 }, { 470, 146 }, { 450, 150 }, { 428, 160 }, { 412, 164 } }
  rim(path, "#b68a5e") fm(path, "#e6c48e")
  for i = 0, 12 do local x, y = 404 + hash(i, 101) % 64, 146 + hash(i, 103) % 24 if path:has(x, y) and path:has(x + 1, y) then px(x, y, "#c89c6c") end end
  -- small back tree
  local t2 = Rm(418, 128, 421, 154) solid(t2, LOG, { s = 1 })
  local c2 = E(418, 122, 14, 12):add(E(410, 128, 7, 6))
  solid(c2, OAKD, { s = 2 })
  -- big oak (kite caught in it)
  local tr = Pg{ { 440, 162 }, { 452, 162 }, { 449, 132 }, { 443, 132 } }:add(Ln({ { 446, 140 }, { 434, 126 } }, 3))
  solid(tr, LOG, { s = 2 })
  for y = 138, 160, 4 do px(446, y, LOG.shade) px(446, y + 1, LOG.shade) end
  fm(Rm(445, 152, 447, 156), LOG.deep)
  local can = E(446, 118, 20, 15):add(E(430, 124, 10, 9)):add(E(458, 126, 9, 9)):add(E(448, 104, 12, 8))
  solid(can, OAKD, { s = 3 })
  for i = 0, 110 do local x, y = 404 + hash(i, 107) % 64, 96 + hash(i, 109) % 46
    local inc = can:has(x, y) and can:has(x + 1, y + 1) and can:has(x - 1, y - 1)
    local in2 = c2:has(x, y) and c2:has(x + 1, y + 1) and c2:has(x - 1, y - 1)
    if inc or in2 then
      local lit = inc and ((x - 446) + (y - 118) < -10) or (in2 and (x - 418) + (y - 122) < -6)
      px(x, y, lit and OAKD.hi or OAKD.shade) px(x + 1, y, lit and OAKD.hi or OAKD.shade) end end
  -- acorns
  px(436, 128, WOOD.base) px(437, 128, WOOD.base) px(460, 120, WOOD.base)
  -- kite (diamond) caught at the canopy top + bow tail
  local kite = Pg{ { 452, 92 }, { 458, 99 }, { 452, 108 }, { 446, 99 } }
  rim(kite, CUSH.deep)
  kite:each(function(x, y) px(x, y, (x < 452) == (y < 99) and P.gold.base or CUSH.base) end)
  fm(Ln({ { 452, 93 }, { 452, 107 } }, 1), P.cream) fm(Ln({ { 447, 99 }, { 457, 99 } }, 1), P.cream)
  local tail = { { 452, 108 }, { 456, 113 }, { 452, 118 }, { 457, 123 }, { 454, 128 } }
  fm(Ln(tail, 1), P.cream)
  for _, b in ipairs({ { 456, 113 }, { 452, 118 }, { 457, 123 } }) do
    px(b[1] - 1, b[2], PETAL.base) px(b[1] + 1, b[2], PETAL.base) px(b[1], b[2], PETAL.shade) end
  -- signpost (two arrow boards, no text)
  local sp = Rm(406, 140, 408, 168) solid(sp, WOOD, { s = 1 })
  local a1 = Pg{ { 400, 142 }, { 416, 142 }, { 420, 145 }, { 416, 148 }, { 400, 148 } }
  local a2 = Pg{ { 413, 151 }, { 400, 151 }, { 397, 154 }, { 400, 157 }, { 413, 157 } }
  solid(a1, { hi = "#fff0c8", base = "#f0d494", shade = "#c8a07a", deep = "#6a4a4a" }, { s = 1 })
  solid(a2, { hi = "#fff0c8", base = "#f0d494", shade = "#c8a07a", deep = "#6a4a4a" }, { s = 1 })
  fm(Rm(403, 144, 413, 144), "#c8a07a") fm(Rm(402, 154, 410, 154), "#c8a07a")
  fm(Rm(406, 138, 408, 139), WOOD.deep)
end

------------------------------------------------------------------ FISHING POND (near-right, x380-464, base 226)
do
  local pond = E(422, 212, 41, 12):add(E(442, 206, 20, 7))
  -- grassy bank lip
  local bank = pond:grow(2):cut(pond)
  fm(bank, "#9aa850")
  rim(pond, SEA.deep)
  fm(pond, SEA.base)
  -- far bank reflection band, deeper water, sky glints
  pond:each(function(x, y) if not pond:has(x, y - 3) then px(x, y, SEA.shade) end end)
  fm(E(426, 215, 28, 6):clip(pond), "#4ea8c8")
  for i = 0, 40 do
    local x, y = 384 + hash(i, 111) % 78, 200 + hash(i, 113) % 24
    local w = 2 + hash(i, 115) % 5
    if pond:has(x, y) and pond:has(x + w, y) and pond:has(x, y - 3) then fm(Rm(x, y, x + w, y), hash(i, 117) % 3 == 0 and SEA.shade or SEA.hi) end
  end
  -- lily pads
  for _, l in ipairs({ { 430, 216 }, { 446, 210 }, { 416, 206 } }) do
    local m = E(l[1], l[2], 3, 1.5) fm(m, "#5aa850") px(l[1] + 1, l[2], "#3a7856") px(l[1] - 2, l[2] - 1, "#a8d870")
  end
  px(446, 208, P.petal.hi) px(447, 208, P.petal.base)
  -- reeds + cattails (back right)
  for i, rx in ipairs({ 450, 453, 456, 459, 462, 447 }) do
    local top = 184 + (i * 5) % 9
    fm(Ln({ { rx, 204 }, { rx + (i % 2 == 0 and 1 or -1), top } }, 1), i % 2 == 0 and "#3f9150" or "#5aa850")
    if i % 2 == 1 then fm(Rm(rx - 1, top + 1, rx, top + 5), WOOD.shade) px(rx - 1, top + 1, WOOD.base) end
  end
  -- small jetty from the front-left bank
  local jt = Pg{ { 386, 223 }, { 404, 223 }, { 406, 210 }, { 392, 210 } }
  local jf = Rm(386, 224, 404, 225)
  rim(jt:copy():add(jf), GREYW.deep)
  fm(jt, GREYW.base)
  for y = 212, 222, 3 do jt:each(function(x, yy) if yy == y then px(x, yy, GREYW.shade) end end) end
  for y = 211, 222, 3 do jt:each(function(x, yy) if yy == y and x < 394 + (y - 210) // 4 then px(x, yy, GREYW.hi) end end) end
  fm(jf, GREYW.shade)
  fm(Rm(392, 207, 393, 211), GREYW.shade) fm(Rm(405, 207, 406, 211), GREYW.shade)
  -- propped rod: forked stick + rod + line + float
  fm(Ln({ { 398, 216 }, { 400, 208 } }, 1), WOOD.deep) px(399, 207, WOOD.deep) px(401, 207, WOOD.deep)
  fm(Ln({ { 394, 219 }, { 400, 208 }, { 424, 190 } }, 1), "#5e3a2e")
  fm(Ln({ { 394, 219 }, { 397, 214 } }, 1), CUSH.base)
  fm(Ln({ { 424, 190 }, { 428, 208 } }, 1), "#e8f0f4")
  fm(Rm(427, 208, 429, 209), CUSH.base) px(427, 208, P.cream)
  -- tackle box on the jetty
  local tb = Rm(388, 216, 392, 219) solid(tb, TEAL, { s = 1 })
end

------------------------------------------------------------------ SNAIL MAILBOX (near road, x300-324, base 222)
do
  local post = Rm(311, 204, 313, 221) solid(post, WOOD, { s = 1 })
  -- snail body (foot) with eye stalks
  local foot = Pg{ { 302, 206 }, { 299, 198 }, { 300, 194 }, { 304, 193 }, { 306, 197 }, { 306, 201 }, { 318, 201 }, { 324, 205 }, { 318, 207 } }
  solid(foot, STRAW, { s = 1 })
  fm(Ln({ { 301, 194 }, { 299, 188 } }, 1), STRAW.deep) fm(Ln({ { 304, 194 }, { 305, 188 } }, 1), STRAW.deep)
  fm(Rm(298, 186, 299, 187), STRAW.deep) fm(Rm(305, 186, 306, 187), STRAW.deep) px(298, 186, P.cream) px(305, 186, P.cream)
  px(301, 196, STRAW.hi) px(302, 195, STRAW.hi)
  -- shell (mailbox): rounded blob + spiral groove
  local sh = Pg{ { 306, 200 }, { 306, 192 }, { 309, 187 }, { 315, 185 }, { 320, 188 }, { 323, 194 }, { 321, 201 } }
  solid(sh, DUSK, { s = 2 })
  fm(Ln({ { 314, 193 }, { 316, 192 }, { 317, 195 }, { 314, 197 }, { 311, 194 }, { 313, 190 }, { 318, 189 }, { 321, 194 } }, 1), DUSK.shade)
  px(309, 190, DUSK.hi) px(310, 189, DUSK.hi)
  -- mail slot + red flag
  fm(Rm(308, 196, 311, 196), DUSK.deep)
  fm(Rm(324, 190, 324, 197), IRON.base) fm(Rm(325, 190, 327, 192), CUSH.base)
end

------------------------------------------------------------------ FOREGROUND (in front of the gate line): wheelbarrow + haystack
do
  -- haystack with a tiny door + window + stovepipe (x56-94, base 262)
  local hs = E(75, 251, 18, 14):clip(Rm(50, 230, 100, 262)):add(Rm(57, 251, 93, 262))
  solid(hs, STRAW, { s = 3 })
  for i = 0, 50 do local x, y = 58 + hash(i, 121) % 34, 239 + hash(i, 123) % 22
    if hs:has(x, y) and hs:has(x + 2, y + 1) then fm(Ln({ { x, y }, { x + 2, y + 1 } }, 1), (x + y) % 3 == 0 and STRAW.hi or STRAW.shade) end end
  local door = Pg{ { 71, 262 }, { 71, 254 }, { 73, 252 }, { 77, 252 }, { 79, 254 }, { 79, 262 } }
  solid(door, CUSH, { s = 1 }) px(77, 258, P.gold.base)
  local win = Rm(83, 248, 86, 251) rim(win, WOOD.deep) fm(win, "#f7d36a")
  local pipe = Rm(64, 232, 65, 240) solid(pipe, IRON, { s = 0 }) fm(Rm(63, 231, 66, 231), IRON.deep)
  px(66, 228, "#eef0f6") px(67, 227, "#eef0f6") px(65, 225, "#eef0f6")
  -- wheelbarrow of pumpkins (x16-50, base 262)
  local hd = Ln({ { 17, 246 }, { 26, 250 } }, 2) solid(hd, WOOD, { s = 0 })
  local lg = Rm(25, 252, 26, 261) solid(lg, WOOD, { s = 0 })
  local tray = Pg{ { 22, 244 }, { 46, 244 }, { 42, 254 }, { 26, 254 } }
  solid(tray, CUSH, { s = 2 })
  fm(Rm(23, 245, 45, 245), CUSH.hi)
  local wh = Pg{ { 41, 252 }, { 45, 250 }, { 49, 252 }, { 50, 256 }, { 49, 260 }, { 45, 262 }, { 41, 260 }, { 40, 256 } }
  solid(wh, IRON, { s = 1 }) fm(Rm(44, 255, 46, 257), IRON.hi)
  for _, p in ipairs({ { 28, 240, 5, 4 }, { 38, 240, 5, 4 }, { 33, 237, 4, 3 } }) do
    local m = E(p[1], p[2], p[3], p[4]) solid(m, PUMP, { s = 1 })
    fm(Rm(p[1], p[2] - p[4] + 1, p[1], p[2] + p[4] - 1), PUMP.shade) px(p[1], p[2] - p[4] - 1, "#3f9150")
  end
  -- beanstalk sprouting from the pumpkins, winding up the left gate post
  local pts = {}
  for y = 236, 120, -2 do
    local x = 15 - 3 * sin((236 - y) / 9)
    if y > 226 then x = 15 + (y - 226) * 1.6 end
    pts[#pts + 1] = { x, y }
  end
  fm(Ln(pts, 2), "#3f9150")
  for i = 1, #pts, 5 do
    local p = pts[i]
    local side = (i // 5) % 2 == 0 and 1 or -1
    local lx, ly = floor(p[1] + side * 3), floor(p[2])
    local lf = Pg{ { p[1], p[2] }, { lx + side * 2, ly - 3 }, { lx + side * 3, ly }, { lx, ly + 1 } }
    fm(lf, "#7cc35a") px(lx, ly - 1, "#c4e07a")
  end
end

------------------------------------------------------------------ GATE FRAME (low rustic logs at the edges)
do
  local function post(x0, x1)
    local m = Rm(x0, 8, x1, 228)
    rim(m, LOG.deep)
    form(m, LOG, { s = 3, l = 2 })
    for y = 20, 226, 7 do px(x0 + 4 + (y // 7) % 3, y, LOG.shade) px(x0 + 4 + (y // 7) % 3, y + 1, LOG.shade) end
    for y = 26, 220, 23 do px(x0 + 3, y, LOG.hi) end
    -- rope binding under the beam
    for y = 19, 25, 2 do fm(Rm(x0, y, x1, y), "#e8c890") px(x1, y, "#b8945e") end
  end
  post(0, 12)
  post(467, 479)
  -- beam
  local beam = Rm(0, 6, 479, 16)
  rim(beam, LOG.deep)
  form(beam, LOG, { s = 3, l = 0 })
  fm(Rm(0, 7, 479, 7), LOG.hi)
  for x = 6, 474, 13 do px(x, 11, LOG.shade) px(x + 1, 11, LOG.shade) px(x + 2, 12, LOG.shade) end
  fm(Rm(0, 6, 479, 6), LOG.deep)
  -- knee braces
  local br = Ln({ { 12, 40 }, { 36, 16 } }, 3):add(Ln({ { 467, 40 }, { 443, 16 } }, 3))
  solid(br, LOG, { s = 1 })
  -- bunting: sagging string with pennants
  local pts = {}
  for x = 40, 410, 2 do pts[#pts + 1] = { x, 17 + 20 * sin((x - 40) / 370 * pi) } end
  fm(Ln(pts, 1), "#8a5a4a")
  local BC = { CUSH.base, P.gold.base, SEA.base, PETAL.base, MOSSR.base, DUSK.base }
  local k = 0
  for x = 48, 402, 15 do
    local y = 17 + 20 * sin((x - 40) / 370 * pi)
    local col = BC[k % #BC + 1]
    local f = Pg{ { x - 4, y }, { x + 4, y }, { x, y + 9 } }
    fm(f, col) fm(Ln({ { x, y + 1 }, { x + 3, y + 1 } }, 1), D(col, .8)) px(x - 2, y + 1, P.cream)
    k = k + 1
  end
  -- hanging lantern (x420-432)
  fm(Rm(426, 17, 426, 25), IRON.base)
  local cap = Pg{ { 421, 30 }, { 426, 25 }, { 431, 30 } } solid(cap, IRON, { s = 0 })
  local glass = Rm(422, 31, 430, 41)
  rim(glass, IRON.deep)
  fm(glass, "#ffd36a") fm(Rm(424, 33, 428, 39), "#fff0a8") fm(Rm(425, 35, 427, 38), "#ffb84a")
  fm(Rm(426, 31, 426, 41), IRON.base) fm(Rm(429, 31, 430, 41), "#e8a040")
  fm(Rm(421, 42, 431, 43), IRON.base) px(426, 44, IRON.deep)
  px(423, 32, P.cream)
end

------------------------------------------------------------------ CHECK + SAVE
c:finish{ outline = false }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
