-- garden-patch: the Garden picture page art (Hearth Pop v3). 240x135 grid, x2 = 480x270.
-- Cottage garden, side view, three depth planes: far (hills, wall, no ink), mid (lawn, path, back and middle
-- rows, ink-edged objects), near (front row, fence with the neighbour animals). All 16 garden buildings are
-- drawn once each, plus the fence, and the script writes the tap boxes next to the PNG.
-- Run: AppRun -b --script-param out=<dir>/ --script-param look=golden|morning|dusk --script garden-patch.lua
-- quirk: a gnome naps on the compost heap with his hat over his face.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local look = app.params.look or "golden"
local c = HP.canvas{ w = 240, h = 135, scale = 2, name = "garden-patch-" .. look }
local sin, abs, floor = math.sin, math.abs, math.floor
local R = function(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
local E = function(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local px = function(x, y, hex) c:px(x, y, hex) end

------------------------------------------------------------ LOOKS
local L = {
  golden = {
    sky = { P.sky.shade, "#e9a1a8", P.petal.hi, P.gold.hi, "#ffe9b0" }, skyw = { 3, 3, 3, 3, 4 },
    sun = { 196, 40, P.gold.base, P.gold.hi }, cloud = { P.cream, P.petal.hi },
    far1 = P.dusk.hi, far2 = "#a98fc6", wall = "#c9a77a", wallTop = P.wood.hi,
    g1 = "#9fcf62", g2 = "#8ac156", g3 = "#6fa84f", gShade = P.moss.shade, path = "#e8c88c", pathD = "#c99c62",
    lit = false, flowers = { P.petal.base, P.gold.base, P.ember.hi }, fire = true,
  },
  morning = {
    sky = { P.sky.shade, P.sky.base, P.sky.hi, P.sky.hi, "#f4fbff" }, skyw = { 3, 3, 3, 3, 4 },
    sun = { 40, 18, P.gold.hi, P.cream }, cloud = { P.cream, P.sky.hi },
    far1 = P.sea.hi, far2 = P.moss.hi, wall = P.stone.hi, wallTop = P.cream,
    g1 = P.moss.base, g2 = "#6dbb52", g3 = P.moss.shade, gShade = P.moss.deep, path = P.cream, pathD = P.stone.hi,
    lit = false, flowers = { P.petal.hi, P.cream, P.dusk.hi }, fire = false, blossom = true,
  },
  dusk = {
    sky = { P.dusk.deep, P.dusk.shade, "#7a5fb8", "#b57ac0", "#f09ab0" }, skyw = { 3, 3, 3, 3, 4 },
    sun = { 196, 24, P.cream, "#ffeec0" }, cloud = { "#7a5fb8", "#9a82d0" },
    far1 = "#5a459e", far2 = "#463a86", wall = "#6a5a8c", wallTop = "#8a78b0",
    g1 = "#3f9150", g2 = "#37834a", g3 = "#2d6f48", gShade = P.moss.deep, path = "#b8a0c0", pathD = "#8a72a0",
    lit = true, flowers = { P.petal.base, P.gold.hi, P.sea.hi }, fire = true, stars = true,
  },
}
local K = L[look]
local ROOF = { hi = P.ember.hi, base = P.ember.base, shade = P.ember.shade, deep = P.ember.deep }
local PLASTER = { hi = P.cream, base = "#f0d9a8", shade = P.wood.hi, deep = P.wood.base }
local WIN = K.lit and { hi = P.gold.hi, base = P.gold.hi, shade = P.gold.base, deep = P.gold.shade } or { hi = P.sky.hi, base = P.sea.hi, shade = P.sea.base, deep = P.sea.shade }


------------------------------------------------------------ SKY (top 34 px) AND BACK HEDGE
c:stripes(0, 36, K.sky, K.skyw)
c:fillMask(E(K.sun[1], K.sun[2], 8, 8), K.sun[3]) c:fillMask(E(K.sun[1] - 1, K.sun[2] - 1, 5, 5), K.sun[4])
c:cloud(36, 14, 30, K.cloud[1], K.cloud[2]) c:cloud(110, 9, 22, K.cloud[1], K.cloud[2]) c:cloud(196, 20, 24, K.cloud[1], K.cloud[2])
c:terrain(function(x) return 28 + 4 * sin(x / 29 + .5) + 2 * sin(x / 11) end, K.far1)
c:terrain(function(x) return 33 + 3 * sin(x / 21 + 2) + 2 * sin(x / 8) end, K.far2)
local hedge0 = HP.mask()
for x = 0, 239, 10 do hedge0:add(E(x + 4, 35, 7, 4)) end
c:fillMask(hedge0, P.moss.shade) c:fillMask(hedge0:copy():shift(-1, -1), P.moss.base)
for x = 6, 236, 10 do px(x, 33, P.moss.hi) px(x + 3, 35, P.moss.hi) end

------------------------------------------------------------ PATCHWORK GROUND: one region per building, blended at the seams
local function hsh(x, y)
  local h = (x * 374761393 + y * 668265263) & 0xffffffff
  h = ((h ~ (h >> 13)) * 1274126177) & 0xffffffff
  return (h ~ (h >> 16)) % 100
end
local function hexrgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
local function lerp(a, b, t)
  local r1, g1, b1 = hexrgb(a); local r2, g2, b2 = hexrgb(b)
  return string.format("#%02x%02x%02x", floor(r1 + (r2 - r1) * t + .5), floor(g1 + (g2 - g1) * t + .5), floor(b1 + (b2 - b1) * t + .5))
end
-- zone seeds: {key, cx, cy, weight, style}. Three rows of six, kitchen takes two cells; centres are jittered so nothing lines up like a grid.
local ZONES = {
  { "greenhouse", 20, 54, 1, "lawn" }, { "tailor", 57, 54, 1, "cobble" }, { "kitchen", 120, 52, 1.3, "flag" }, { "tool_shed", 183, 54, 1, "dirt" }, { "compost_bin", 221, 55, 1, "loam" },
  { "beehive", 24, 88, 1, "meadow" }, { "root_cellar", 58, 86, 1, "furrow" }, { "worm_farm", 99, 88, 1, "soil" }, { "ladybird_lodge", 141, 86, 1, "tall" }, { "snail_jar", 181, 88, 1, "moss" }, { "rain_barrel", 218, 86, 1, "wet" },
  { "fence", 20, 119, 1, "lawn2" }, { "quail_coop", 60, 118, 1, "sand" }, { "silk_shelf", 100, 120, 1, "shade" }, { "tortoise_run", 140, 118, 1, "sun" }, { "butterfly_bush", 180, 120, 1, "bed" }, { "frog_pond", 219, 118, 1, "lawn2" },
}
local STYLE = {
  lawn   = { "#9fcf62", "#8ac156", "#b8e07c", 9 },
  lawn2  = { "#86c25a", "#79b650", "#a4d672", 8 },
  cobble = { "#dcc9a0", "#c4a97c", "#b49a76", 7, "cobble" },
  flag   = { "#e0d2ac", "#cdb98c", "#f2e8c8", 6, "cobble" },
  dirt   = { "#c9a066", "#b58a54", "#8a5a2b", 10 },
  loam   = { "#7d5a38", "#6a4a2e", "#4a3a1a", 12 },
  meadow = { "#93c85e", "#85bb55", P.petal.hi, 16 },
  furrow = { "#8fbf56", "#7a5634", "#b8e07c", 6, "furrow" },
  soil   = { "#7a5634", "#624327", "#a07848", 8, "furrow" },
  tall   = { "#6fb04d", "#5da043", "#c4e07a", 14 },
  moss   = { "#59a76a", "#47935c", "#c4e07a", 10 },
  wet    = { "#b4b3c4", "#9d9cb2", P.sea.hi, 6, "cobble" },
  sand   = { "#e6cc84", "#d6b866", "#f6e4a8", 9 },
  shade  = { "#4f9a52", "#418a4a", "#7cc35a", 8 },
  sun    = { "#aed466", "#9cc95c", "#c8e68a", 8 },
  bed    = { "#8cc25b", "#7fb654", P.dusk.hi, 13 },
}
local function ground(zi, x, y)
  local z = ZONES[zi]; local s = STYLE[z[5]]; local h = hsh(x, y)
  local base, alt, sp, dens, kind = s[1], s[2], s[3], s[4], s[5]
  if kind == "cobble" then
    local row = y // 4
    if y % 4 == 0 or (x + (row % 2) * 3) % 6 == 0 then return alt end
    if h < dens then return sp end
    return base
  elseif kind == "furrow" then
    if y % 6 < 2 then return alt end
    if h < dens then return sp end
    return base
  end
  if (y // 5) % 2 == 0 and h < 40 then base = alt end
  if h < dens then return sp end
  return base
end
local seeds = {}
for i, z in ipairs(ZONES) do seeds[i] = { z[2], z[3], z[4] } end
for y = 35, 134 do
  for x = 0, 239 do
    local wx = x + 5 * sin(y / 8 + x / 37)
    local wy = y + 4 * sin(x / 10 + y / 29)
    local d1, d2, i1, i2 = 1e9, 1e9, 0, 0
    for i, s in ipairs(seeds) do
      local dx, dy = (wx - s[1]) * .8, (wy - s[2]) * 1.45
      local d = math.sqrt(dx * dx + dy * dy) / s[3]
      if d < d1 then d2, i2, d1, i1 = d1, i1, d, i elseif d < d2 then d2, i2 = d, i end
    end
    local col = ground(i1, x, y)
    local m = d2 - d1   -- distance into the seam, in pixels
    if m < 3.2 then
      local other = ground(i2, x, y)
      col = (m < 1.6) and lerp(col, other, .5) or lerp(col, other, .25)   -- three hard steps: own, 3/4 own, half and half
    end
    px(x, y, col)
  end
end

------------------------------------------------------------ THE SNAKING PATH (joins every row) AND THE STREAM
local function ribbon(pts, w, col, edge)
  for _, p in ipairs(pts) do
    R(p[1] - w, p[2] - 1, p[1] + w, p[2] + 1, edge)
  end
  for _, p in ipairs(pts) do R(p[1] - w, p[2] - 1, p[1] + w, p[2], col) end
end
do
  local pts = {}
  local function add(x, y) pts[#pts + 1] = { x, y } end
  for x = 4, 232, 2 do add(x, 69 + floor(1.5 * sin(x / 13))) end          -- row 0 lane
  for y = 69, 99, 2 do add(232 + floor(1.5 * sin(y / 7)), y) end            -- down the right
  for x = 232, 8, -2 do add(x, 99 + floor(1.5 * sin(x / 11))) end           -- row 1 lane
  for y = 99, 129, 2 do add(8 + floor(1.5 * sin(y / 7)), y) end             -- down the left
  for x = 8, 236, 2 do add(x, 129 + floor(1.2 * sin(x / 12))) end           -- row 2 lane
  ribbon(pts, 2, "#f0e2bc", "#c9ad7e")
  for i = 1, #pts, 3 do local p = pts[i]; px(p[1] + (i % 3) - 1, p[2], "#c9ad7e") end   -- pebbles in the path
end

------------------------------------------------------------ helper for small surrounding props
local function flowerpx(x, y, col) px(x, y, col) px(x, y - 1, P.moss.base) end

------------------------------------------------------------ helpers
local boxes = {}
local function box(key, name, x, y, w, h) boxes[#boxes + 1] = { k = key, n = name, box = { x - w // 2 - 1, y - h - 1, x + w // 2 + 1, y + 1 } } end
local function shadow(x, y, rx) c:fillMask(E(x, y, rx, 2), K.gShade) end
-- an object made of several masks: one ink rim round the union, then each part shaded
local function obj(parts)
  local u = HP.mask()
  for _, p in ipairs(parts) do u:add(p[1]:copy()) end
  c:rim(u, P.ink)
  for _, p in ipairs(parts) do c:part(p[1], p[2], p[3] or {}) end
end
local function lamp(x, y)
  local post = c:rect(x, y - 24, x + 1, y)
  local head = c:rect(x - 2, y - 30, x + 3, y - 25)
  c:rim(post:copy():add(head), P.ink)
  c:part(post, "stone", { nopop = true, noshade = true })
  c:fillMask(head, K.lit and P.gold.hi or P.gold.base)
  px(x, y - 28, P.cream)
  if K.lit then c:fillMask(E(x, y, 11, 3), K.g2) end
end

------------------------------------------------------------ BACK ROW (feet y 76)
local function greenhouse(x, y)
  shadow(x, y + 1, 16)
  local body = c:rect(x - 13, y - 14, x + 13, y)
  local roof = c:poly{ {x - 15, y - 14}, {x, y - 23}, {x + 15, y - 14} }
  obj{ { body, WIN, { nopop = true } }, { roof, WIN, { nopop = true } } }
  for xx = x - 13, x + 13, 6 do R(xx, y - 14, xx, y, P.cream) end
  R(x - 13, y - 14, x + 13, y - 14, P.cream) R(x - 13, y - 1, x + 13, y, P.stone.base)
  for _, p in ipairs{ {x - 10, 8}, {x - 3, 11}, {x + 6, 9} } do R(p[1], y - p[2], p[1] + 2, y - 1, P.moss.base) px(p[1] + 1, y - p[2] - 1, P.petal.base) end
  px(x - 11, y - 12, P.cream) px(x - 10, y - 13, P.cream)
  box("greenhouse", "Greenhouse", x, y, 30, 24)
end
local function tailor(x, y)
  shadow(x, y + 1, 13)
  local wall = c:rect(x - 10, y - 14, x + 10, y)
  local roof = c:poly{ {x - 13, y - 14}, {x, y - 24}, {x + 13, y - 14} }
  obj{ { wall, "dusk", { band = 2 } }, { roof, "gold", { band = 2, nopop = true } } }
  R(x - 3, y - 9, x + 3, y, P.wood.deep)
  R(x - 8, y - 11, x - 5, y - 7, WIN.base) R(x + 5, y - 11, x + 8, y - 7, WIN.base)
  R(x - 1, y - 21, x + 1, y - 18, P.petal.base) px(x, y - 22, P.cream)   -- a little dress on the gable
  c:stitch{ { x - 9, y - 1 }, { x + 9, y - 1 } }
  box("tailor", "Tailor", x, y, 26, 26)
end
local function beehive(x, y)
  shadow(x, y + 1, 9)
  local legs = c:rect(x - 6, y - 5, x + 6, y)
  local m = HP.mask()
  m:add(E(x, y - 6, 7, 4)) m:add(E(x, y - 11, 6, 3)) m:add(E(x, y - 15, 4, 3))
  obj{ { m, "gold", { band = 2 } } }
  R(x - 6, y - 4, x - 5, y, P.wood.base) R(x + 5, y - 4, x + 6, y, P.wood.base)
  R(x - 1, y - 6, x + 1, y - 5, P.ink)
  R(x - 5, y - 9, x + 5, y - 9, P.gold.shade) R(x - 4, y - 13, x + 4, y - 13, P.gold.shade)
  px(x + 10, y - 14, P.ink) px(x + 11, y - 14, P.gold.hi) px(x + 12, y - 15, P.cream)
  px(x + 14, y - 9, P.ink) px(x + 15, y - 9, P.gold.hi)
  box("beehive", "Beehive", x, y, 14, 20)
end
local function kitchen(x, y)
  shadow(x, y + 1, 26)
  local wall = c:rect(x - 20, y - 24, x + 20, y)
  local roof = c:poly{ {x - 26, y - 24}, {x, y - 43}, {x + 26, y - 24} }
  local chim = c:rect(x + 9, y - 45, x + 15, y - 28)
  obj{ { wall, PLASTER, { band = 3, nopop = true } }, { roof, ROOF, { band = 3 } }, { chim, "stone", { nopop = true } } }
  for r = 0, 4 do   -- tile courses
    local yy = y - 27 - r * 3
    local half = 24 - r * 4
    R(x - half, yy, x + half, yy, P.ember.shade)
    for xx = x - half, x + half, 5 do px(xx + (r % 2) * 2, yy + 1, P.ember.deep) end
  end
  R(x + 8, y - 46, x + 16, y - 45, P.stone.hi)
  for _, s in ipairs{ {x + 12, y - 49, 3}, {x + 14, y - 53, 2}, {x + 11, y - 57, 2} } do R(s[1], s[2], s[1] + s[3], s[2] + 1, K.lit and P.stone.base or P.stone.hi) end
  for _, xx in ipairs{ x - 18, x - 8, x + 6, x + 16 } do R(xx, y - 22, xx, y - 1, P.wood.base) end   -- timber
  R(x - 4, y - 16, x + 4, y, P.wood.shade) R(x - 3, y - 15, x + 3, y, P.wood.base) px(x + 2, y - 8, P.gold.hi)
  R(x - 15, y - 19, x - 10, y - 12, WIN.base) R(x - 15, y - 15, x - 10, y - 15, P.wood.base) R(x - 13, y - 19, x - 13, y - 12, P.wood.base)
  R(x + 10, y - 19, x + 15, y - 12, WIN.base) R(x + 10, y - 15, x + 15, y - 15, P.wood.base) R(x + 12, y - 19, x + 12, y - 12, P.wood.base)
  R(x - 16, y - 11, x - 9, y - 10, P.wood.base) px(x - 15, y - 12, P.petal.base) px(x - 12, y - 12, P.gold.base) px(x - 10, y - 12, P.petal.hi)   -- flower box
  box("kitchen", "Kitchen", x, y, 52, 46)
end
local function shed(x, y)
  shadow(x, y + 1, 14)
  local wall = c:rect(x - 11, y - 14, x + 11, y)
  local roof = c:poly{ {x - 14, y - 14}, {x - 11, y - 20}, {x + 11, y - 20}, {x + 14, y - 14} }
  obj{ { wall, "wood", { band = 2, nopop = true } }, { roof, { hi = P.wood.base, base = P.wood.shade, shade = P.wood.deep, deep = P.ink }, { band = 2, nopop = true } } }
  for xx = x - 8, x + 8, 4 do R(xx, y - 13, xx, y - 1, P.wood.shade) end
  R(x - 4, y - 10, x + 4, y, P.wood.deep) R(x - 3, y - 9, x + 3, y, P.wood.shade) px(x + 2, y - 5, P.gold.hi)
  R(x + 14, y - 16, x + 14, y, P.wood.base) R(x + 12, y - 17, x + 16, y - 17, P.stone.base) px(x + 12, y - 16, P.stone.hi)   -- a rake
  box("tool_shed", "Tool Shed", x, y, 34, 24)
end
local function compost(x, y)
  shadow(x, y + 1, 13)
  local bin = c:rect(x - 10, y - 8, x + 10, y)
  local heap = E(x, y - 9, 9, 4)
  obj{ { bin, "wood", { band = 2, nopop = true } }, { heap, { hi = P.wood.base, base = P.wood.shade, shade = P.wood.deep, deep = P.ink }, { band = 1, nopop = true } } }
  for xx = x - 7, x + 7, 4 do R(xx, y - 7, xx, y - 1, P.wood.shade) end
  R(x - 4, y - 12, x - 3, y - 11, P.moss.base) R(x + 3, y - 12, x + 4, y - 11, P.ember.base) px(x, y - 13, P.gold.base)
  -- the quirk: a napping gnome, hat over his face
  local hat = c:poly{ {x + 7, y - 9}, {x + 15, y - 11}, {x + 12, y - 16} }
  c:rim(hat, P.ink) c:part(hat, "ember", { band = 1, nopop = true })
  R(x + 6, y - 9, x + 14, y - 8, P.cream)
  box("compost_bin", "Compost Bin", x, y, 28, 20)
end

------------------------------------------------------------ MIDDLE ROW (feet y 100)
local function barrel(x, y)
  shadow(x, y + 1, 8)
  local b = c:rrect(x - 6, y - 14, x + 6, y, 2)
  local top = E(x, y - 14, 6, 2)
  obj{ { b, "wood", { band = 2 } }, { top, "sea", { band = 1, nopop = true } } }
  R(x - 6, y - 11, x + 6, y - 10, P.stone.deep) R(x - 6, y - 4, x + 6, y - 3, P.stone.deep)
  px(x - 2, y - 15, P.cream) px(x + 3, y - 14, P.sea.hi)
  px(x + 8, y - 5, P.sea.base) px(x + 8, y - 4, P.sea.base) px(x + 8, y - 3, P.sea.hi)   -- dripping tap
  box("rain_barrel", "Rain Barrel", x, y, 14, 18)
end
local function cellar(x, y)
  shadow(x, y + 1, 16)
  local mound = E(x, y - 6, 15, 8):clip(c:rect(x - 20, y - 20, x + 20, y))
  local door = c:rrect(x - 5, y - 10, x + 5, y, 3)
  obj{ { mound, "moss", { band = 2 } } }
  c:fillMask(c:rect(x - 7, y - 12, x + 7, y), P.stone.base) R(x - 7, y - 12, x + 7, y - 11, P.stone.hi)
  c:part(door, "wood", { band = 1, nopop = true })
  R(x - 1, y - 9, x - 1, y - 1, P.wood.deep) px(x + 2, y - 5, P.gold.hi)
  for _, p in ipairs{ {x - 11, y - 7}, {x + 9, y - 9}, {x + 3, y - 12} } do px(p[1], p[2], P.petal.base) px(p[1] + 1, p[2], P.gold.hi) end
  box("root_cellar", "Root Cellar", x, y, 32, 16)
end
local function worm(x, y)
  shadow(x, y + 1, 12)
  local crate = c:rect(x - 9, y - 9, x + 9, y)
  obj{ { crate, "wood", { band = 2, nopop = true } } }
  R(x - 8, y - 9, x + 8, y - 6, P.wood.deep)
  R(x - 6, y - 8, x - 3, y - 8, P.petal.base) R(x + 1, y - 7, x + 5, y - 7, P.petal.base) px(x - 3, y - 9, P.petal.hi)
  for xx = x - 6, x + 6, 4 do R(xx, y - 5, xx, y - 1, P.wood.shade) end
  px(x + 9, y - 6, P.moss.base) px(x + 10, y - 7, P.moss.base)   -- a worm waves from the side
  box("worm_farm", "Worm Farm", x, y, 24, 14)
end
local function lady(x, y)
  shadow(x, y + 1, 10)
  local wall = c:rect(x - 7, y - 11, x + 7, y)
  local roof = c:poly{ {x - 10, y - 11}, {x, y - 18}, {x + 10, y - 11} }
  obj{ { wall, "ember", { band = 2, nopop = true } }, { roof, { hi = P.stone.base, base = P.stone.shade, shade = P.stone.deep, deep = P.ink }, { band = 1, nopop = true } } }
  for _, p in ipairs{ {x - 5, y - 9}, {x + 3, y - 9}, {x - 2, y - 5}, {x + 4, y - 4} } do R(p[1], p[2], p[1] + 1, p[2] + 1, P.ink) end
  R(x - 2, y - 7, x + 1, y, P.wood.deep) px(x - 6, y - 4, P.cream)
  box("ladybird_lodge", "Ladybird Lodge", x, y, 20, 20)
end
local function snail(x, y)
  shadow(x, y + 1, 8)
  local jar = c:rrect(x - 6, y - 13, x + 6, y, 2)
  local lid = c:rect(x - 7, y - 16, x + 7, y - 13)
  obj{ { jar, WIN, { band = 2, nopop = true } }, { lid, "wood", { band = 1, nopop = true } } }
  R(x - 5, y - 4, x + 5, y - 1, P.wood.base) R(x - 5, y - 4, x + 5, y - 4, P.wood.shade)
  c:part(E(x - 1, y - 7, 3, 3), "gold", { band = 1, nopop = true }) px(x - 1, y - 7, P.gold.shade)
  R(x + 2, y - 5, x + 5, y - 5, P.cream) px(x + 5, y - 6, P.cream) px(x + 5, y - 8, P.cream)
  px(x - 3, y - 11, P.cream) px(x - 3, y - 10, P.cream)   -- glass glint
  box("snail_jar", "Snail Jar", x, y, 16, 20)
end
local function pond(x, y)
  local water = E(x, y - 4, 15, 5)
  c:rim(water, P.stone.deep)
  c:part(water, "sea", { band = 2, nopop = true })
  local ring = water:copy():grow(1):cut(water)
  c:fillMask(ring, P.stone.hi)
  R(x - 8, y - 5, x - 3, y - 4, P.sea.hi) R(x + 3, y - 3, x + 9, y - 3, P.sea.hi)
  c:part(E(x - 5, y - 3, 3, 1), "moss", { band = 1, nopop = true }) c:part(E(x + 6, y - 5, 3, 1), "moss", { band = 1, nopop = true })
  local frog = E(x + 6, y - 8, 3, 2)
  c:rim(frog, P.ink) c:part(frog, "moss", { band = 1, nopop = true })
  px(x + 5, y - 10, P.cream) px(x + 7, y - 10, P.cream)
  box("frog_pond", "Frog Pond", x, y, 34, 14)
end

------------------------------------------------------------ FRONT ROW (feet y 125)
local function quail(x, y)
  shadow(x, y + 1, 15)
  local coop = c:rect(x - 10, y - 12, x + 10, y)
  local roof = c:poly{ {x - 13, y - 12}, {x, y - 19}, {x + 13, y - 12} }
  obj{ { coop, "wood", { band = 2, nopop = true } }, { roof, ROOF, { band = 2, nopop = true } } }
  for xx = x - 7, x + 7, 4 do R(xx, y - 11, xx, y - 1, P.wood.shade) end
  R(x - 3, y - 9, x + 3, y, P.wood.deep)
  c:part(E(x + 14, y - 3, 3, 2), "wood", { band = 1, nopop = true }) px(x + 16, y - 5, P.ink) px(x + 17, y - 4, P.gold.hi)   -- a quail waits outside
  R(x - 10, y - 2, x - 14, y, P.wood.base)
  box("quail_coop", "Quail Coop", x, y, 32, 22)
end
local function silk(x, y)
  shadow(x, y + 1, 14)
  local p1 = c:rect(x - 12, y - 20, x - 10, y)
  local p2 = c:rect(x + 10, y - 20, x + 12, y)
  local s1 = c:rect(x - 12, y - 13, x + 12, y - 11)
  local s2 = c:rect(x - 12, y - 6, x + 12, y - 4)
  obj{ { p1, "wood", { nopop = true, noshade = true } }, { p2, "wood", { nopop = true, noshade = true } }, { s1, "wood", { nopop = true, noshade = true } }, { s2, "wood", { nopop = true, noshade = true } } }
  for _, t in ipairs{ {x - 9, y - 17}, {x + 1, y - 17}, {x - 6, y - 10}, {x + 3, y - 10}, {x - 9, y - 3}, {x + 2, y - 3} } do
    R(t[1], t[2], t[1] + 6, t[2] + 1, P.moss.base) px(t[1] + 1, t[2] - 1, P.moss.hi)
  end
  px(x - 4, y - 5, P.cream) px(x - 3, y - 5, P.cream) px(x + 7, y - 12, P.cream) px(x + 8, y - 12, P.cream)   -- cocoons
  box("silk_shelf", "Silkworm Shelf", x, y, 28, 24)
end
local function tortoise(x, y)
  shadow(x, y + 1, 16)
  local lawn = c:rect(x - 14, y - 7, x + 14, y)
  obj{ { lawn, "moss", { band = 1, nopop = true } } }
  R(x - 14, y - 8, x + 14, y - 7, P.wood.base) R(x - 14, y - 1, x + 14, y, P.wood.base)
  for xx = x - 14, x + 14, 5 do R(xx, y - 11, xx, y - 7, P.wood.shade) end
  local shell = E(x - 1, y - 4, 5, 3)
  c:rim(shell, P.ink) c:part(shell, "moss", { band = 1, nopop = true })
  c:fillMask(E(x - 1, y - 5, 3, 1), P.gold.base)
  R(x + 4, y - 4, x + 6, y - 3, P.wood.hi) px(x + 6, y - 4, P.ink)
  box("tortoise_run", "Tortoise Run", x, y, 32, 18)
end
local function butterfly(x, y)
  shadow(x, y + 1, 12)
  local m = HP.mask()
  m:add(E(x, y - 8, 11, 7)) m:add(E(x - 6, y - 12, 6, 5)) m:add(E(x + 6, y - 13, 6, 5))
  obj{ { m, "moss", { band = 3 } } }
  for _, f in ipairs{ {x - 7, y - 11}, {x + 2, y - 9}, {x + 7, y - 14}, {x - 2, y - 16}, {x - 4, y - 5} } do R(f[1], f[2], f[1] + 1, f[2] + 1, P.dusk.base) px(f[1], f[2], P.dusk.hi) end
  px(x + 11, y - 19, P.dusk.base) px(x + 12, y - 20, P.dusk.hi) px(x + 14, y - 19, P.dusk.base) px(x + 13, y - 18, P.ink)
  box("butterfly_bush", "Butterfly Bush", x, y, 26, 24)
end
local function fence(x, y)
  shadow(x, y + 1, 20)
  local rail1 = c:rect(x - 20, y - 12, x + 20, y - 10)
  local rail2 = c:rect(x - 20, y - 5, x + 20, y - 3)
  local posts = HP.mask()
  for xx = x - 19, x + 19, 13 do posts:add(c:rect(xx, y - 16, xx + 2, y)) end
  obj{ { rail1, "wood", { nopop = true, noshade = true } }, { rail2, "wood", { nopop = true, noshade = true } }, { posts, "wood", { nopop = true } } }
  -- Biddy the hen, Clementine the goat, Percy the pigeon
  local hen = E(x - 14, y - 8, 4, 3)
  c:rim(hen, P.ink) c:part(hen, "ember", { band = 1, nopop = true }) R(x - 18, y - 13, x - 17, y - 12, P.ember.base) px(x - 11, y - 11, P.gold.hi)
  local goat = c:rect(x - 3, y - 12, x + 5, y - 6)
  local gh = c:rect(x + 5, y - 15, x + 9, y - 10)
  c:rim(goat:copy():add(gh), P.ink) c:part(goat, "cream" == nil and "stone" or { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }, { band = 1, nopop = true })
  c:part(gh, { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }, { band = 1, nopop = true })
  px(x + 6, y - 17, P.wood.base) px(x + 8, y - 17, P.wood.base) px(x + 8, y - 13, P.ink)
  local pig = E(x + 15, y - 19, 3, 2)
  c:rim(pig, P.ink) c:part(pig, "stone", { band = 1, nopop = true }) px(x + 17, y - 20, P.ink) px(x + 12, y - 18, P.cream)
  box("fence", "The fence", x, y, 44, 28)
end


------------------------------------------------------------ BIGGER POND (this zone is its own water garden)
local function bigpond(x, y)
  local water = E(x, y - 7, 18, 9)
  c:rim(water, P.stone.deep)
  c:part(water, "sea", { band = 3, nopop = true })
  c:fillMask(water:copy():grow(1):cut(water), P.stone.hi)
  R(x - 11, y - 10, x - 5, y - 10, P.sea.hi) R(x + 3, y - 6, x + 11, y - 6, P.sea.hi) R(x - 7, y - 4, x - 2, y - 4, P.sea.hi)
  c:part(E(x - 8, y - 6, 4, 2), "moss", { band = 1, nopop = true }) c:part(E(x + 7, y - 9, 4, 2), "moss", { band = 1, nopop = true })
  px(x - 8, y - 8, P.petal.base) px(x - 9, y - 8, P.petal.hi)
  local frog = E(x + 8, y - 11, 3, 2)
  c:rim(frog, P.ink) c:part(frog, "moss", { band = 1, nopop = true }) px(x + 7, y - 13, P.cream) px(x + 9, y - 13, P.cream)
  for _, xx in ipairs{ x - 18, x - 15, x + 16 } do R(xx, y - 16, xx, y - 9, P.moss.base) px(xx, y - 17, P.wood.base) end   -- reeds with cattails
  boxes[#boxes + 1] = { k = "frog_pond", n = "Frog Pond", box = { x - 21, y - 19, x + 21, y + 3 } }
end

------------------------------------------------------------ PLACE THEM (far row first) + one gentle surrounding detail each
local FEET = { 62, 92, 122 }
local function at(k) for _, z in ipairs(ZONES) do if z[1] == k then return z[2], (z[3] < 70 and FEET[1]) or (z[3] < 105 and FEET[2]) or FEET[3] end end end
-- stream: rain barrel overflow runs down into the pond (drawn under the buildings)
do
  local bx = ZONES[11][2] + 2
  for y = 96, 108 do local xx = bx + floor(2 * sin(y / 4)); R(xx - 1, y, xx + 1, y, P.sea.base) px(xx, y, P.sea.hi) end
end
local function deco(k, x, y)
  if k == "greenhouse" then R(x + 15, y - 3, x + 19, y, P.wood.base) px(x + 16, y - 4, P.moss.base) px(x + 18, y - 4, P.petal.base)
  elseif k == "tailor" then R(x - 19, y - 14, x - 19, y, P.wood.base) R(x - 19, y - 14, x - 14, y - 14, P.wood.hi) R(x - 17, y - 13, x - 15, y - 9, P.petal.base) px(x - 16, y - 8, P.petal.hi)
  elseif k == "kitchen" then R(x - 31, y - 4, x - 25, y, P.wood.base) px(x - 30, y - 5, P.moss.base) px(x - 28, y - 6, P.moss.hi) px(x - 26, y - 5, P.petal.base) R(x + 26, y - 4, x + 31, y, P.wood.base) px(x + 27, y - 5, P.ember.base) px(x + 29, y - 5, P.gold.base)
  elseif k == "tool_shed" then R(x - 19, y - 6, x - 14, y - 2, P.wood.base) R(x - 19, y - 6, x - 14, y - 6, P.wood.hi) R(x - 18, y - 3, x - 15, y - 3, P.wood.shade)
  elseif k == "compost_bin" then c:fillMask(E(x - 13, y - 1, 3, 2), P.moss.shade) px(x - 14, y - 2, P.ember.base)
  elseif k == "beehive" then for _, f in ipairs{ { x - 13, y - 1 }, { x + 12, y - 3 }, { x + 8, y }, { x - 9, y - 2 } } do flowerpx(f[1], f[2], P.petal.base) end
  elseif k == "root_cellar" then R(x - 19, y - 4, x - 14, y, P.wood.base) px(x - 18, y - 5, P.ember.base) px(x - 16, y - 5, P.moss.base)
  elseif k == "worm_farm" then c:fillMask(E(x - 14, y, 3, 1), P.wood.deep) px(x - 15, y - 1, P.petal.base)
  elseif k == "ladybird_lodge" then R(x - 14, y - 4, x - 14, y, P.cream) c:fillMask(E(x - 14, y - 5, 3, 2), P.ember.base) px(x - 15, y - 6, P.cream) px(x + 13, y, P.ink)
  elseif k == "snail_jar" then c:fillMask(E(x + 13, y - 3, 3, 3), P.moss.base) px(x + 12, y - 5, P.moss.hi) px(x + 14, y - 5, P.moss.hi)
  elseif k == "rain_barrel" then R(x - 15, y - 5, x - 11, y, P.stone.base) R(x - 15, y - 5, x - 11, y - 5, P.stone.hi)
  elseif k == "fence" then c:fillMask(E(x - 12, y - 2, 4, 2), P.moss.shade)
  elseif k == "quail_coop" then for i = 0, 3 do px(x + 14 + i, y - (i % 2), P.gold.hi) end px(x + 16, y - 2, P.cream) px(x + 17, y - 2, P.cream)
  elseif k == "silk_shelf" then c:fillMask(E(x + 16, y - 7, 4, 5), P.moss.base) R(x + 16, y - 3, x + 16, y, P.wood.base) px(x + 14, y - 8, P.moss.hi) px(x + 18, y - 5, P.dusk.base)
  elseif k == "tortoise_run" then c:part(E(x - 17, y - 2, 3, 2), "stone", { band = 1, nopop = true }) c:fillMask(E(x + 17, y - 1, 3, 1), P.moss.hi)
  elseif k == "butterfly_bush" then for _, f in ipairs{ { x - 15, y }, { x + 14, y - 1 }, { x + 16, y - 3 } } do flowerpx(f[1], f[2], P.dusk.base) end
  end
end
local DRAW = { greenhouse = greenhouse, tailor = tailor, kitchen = kitchen, tool_shed = shed, compost_bin = compost, beehive = beehive, root_cellar = cellar, worm_farm = worm,
  ladybird_lodge = lady, snail_jar = snail, rain_barrel = barrel, fence = fence, quail_coop = quail, silk_shelf = silk, tortoise_run = tortoise, butterfly_bush = butterfly }
for _, z in ipairs(ZONES) do
  local k = z[1]
  local x, y = at(k)
  if k == "frog_pond" then bigpond(x, y + 4) elseif DRAW[k] then DRAW[k](x, y); deco(k, x, y) end
end

------------------------------------------------------------ OUT
c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = out .. "garden-patch-" .. look .. ".aseprite", png = out .. "garden-patch-" .. look .. ".png", scale = 2 }
local f = io.open(out .. "garden-patch-" .. look .. ".json", "w")
local parts = {}
for _, b in ipairs(boxes) do
  parts[#parts + 1] = string.format('{"k":"%s","n":"%s","box":[%d,%d,%d,%d]}', b.k, b.n, b.box[1] * 2, b.box[2] * 2, b.box[3] * 2, b.box[4] * 2)
end
f:write("[" .. table.concat(parts, ",") .. "]") f:close()
print(look, "ok", #boxes, "spots")
