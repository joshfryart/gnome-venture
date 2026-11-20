-- beehive state sprites v2 (Hearth Pop v3). 56x64, ground contact centre (28,54).
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "/tmp/ase/states2/beehive/"
local floor = math.floor
local W_, H_ = 56, 64
local X, Y = 28, 54
local c
local INK, CREAM = P.ink, P.cream
local INTERIOR, DUSKSH = "#3b2c48", "#5a4660"
local SHD_A = "#7d6a84"
local THATCH = { hi = P.gold.hi, base = P.gold.base, shade = P.gold.shade, deep = P.gold.deep }
local WAX = { hi = P.cream, base = "#f6dfae", shade = "#e8c48a", deep = "#b97a4a" }
local function hexrgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
local function lerp(a, b, t)
  local r1, g1, b1 = hexrgb(a); local r2, g2, b2 = hexrgb(b)
  return string.format("#%02x%02x%02x", floor(r1 + (r2 - r1) * t + .5), floor(g1 + (g2 - g1) * t + .5), floor(b1 + (b2 - b1) * t + .5))
end
local function px(x, y, hex) c:px(x, y, hex) end
local function R(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
local function E(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local function ink(...) local u = HP.mask() for _, m in ipairs{ ... } do u:add(m) end c:rim(u, INK) return u end
local function seg(x0, y0, x1, y1, hex)
  local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0))
  for i = 0, n do local t = n == 0 and 0 or i / n; px(floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5), hex) end
end
local function shadeUnder(m, t) m:each(function(x, y) local v = c:get(x, y); if v then px(x, y, lerp(v, DUSKSH, t)) end end) end
local function newc(n) c = HP.canvas{ w = W_, h = H_, scale = 1, name = n or "beehive" } return c end

local LX, LY, LZ = -0.55, -0.62, 0.56
local function ball(m, cx, cy, rx, ry, T)
  m:each(function(x, y)
    local u, v = (x + .5 - cx - .5) / (rx + .5), (y + .5 - cy - .5) / (ry + .5)
    local q = 1 - u * u - v * v; if q < 0 then q = 0 end
    local l = LX * u + LY * v + LZ * math.sqrt(q)
    px(x, y, (l > .62 and T.hi) or (l > .2 and T.base) or (l > -.18 and T.shade) or T.deep)
  end)
  m:each(function(x, y) if (not m:has(x + 1, y) or not m:has(x, y + 1)) and c:get(x, y) == T.deep and (x - cx) + (y - cy) * (rx / math.max(ry, 1)) > rx * .5 then px(x, y, T.shade) end end)
end
local function strands(m, y0, y1, every, gap)
  for y = y0, y1, gap or 2 do for x = 0, W_ - 1 do
    if m:has(x, y) and m:has(x - 1, y) and m:has(x + 1, y) and m:has(x, y + 1) and (x + y) % every == 0 then
      local v = c:get(x, y)
      if v == THATCH.hi then px(x, y, THATCH.base) elseif v == THATCH.base then px(x, y, THATCH.shade) elseif v == THATCH.shade then px(x, y, lerp(THATCH.shade, THATCH.deep, .45)) end
    end
  end end
end
local function laterHas(ms, i, x, y) for j = i + 1, #ms do if ms[j]:has(x, y) then return true end end return false end
-- tiers top to bottom { cx, cy, rx, ry }
local function skep(tiers)
  local ms, u = {}, HP.mask()
  for i, t in ipairs(tiers) do ms[i] = E(t[1], t[2], t[3], t[4]); u:add(ms[i]) end
  ink(u)
  for i, t in ipairs(tiers) do ball(ms[i], t[1], t[2], t[3] + 1, t[4] + 1, THATCH) end
  for i = 1, #ms - 1 do ms[i]:each(function(x, y) if not laterHas(ms, i, x, y) and laterHas(ms, i, x, y + 1) then px(x, y, P.gold.deep) end end) end
  strands(u, Y - 30, Y - 3, 4, 2)
  return u
end
local function band(u, y0, y1)
  u:each(function(x, y) if y >= y0 and y <= y1 then px(x, y, (x % 4 == 0) and CREAM or P.ember.base) end end)
  u:each(function(x, y) if y == y1 + 1 and c:get(x, y) then px(x, y, P.ember.shade) end end)
end
local function hole(cx, y0, y1)
  R(cx - 1, y0, cx + 1, y1, INTERIOR)
  R(cx - 1, y1 + 1, cx + 1, y1 + 1, P.gold.hi)
end
local function legs()
  local l = c:rect(X - 6, Y - 3, X - 5, Y):add(c:rect(X + 4, Y - 3, X + 5, Y))
  return l
end
local function drawLegs(l)
  R(X - 6, Y - 3, X - 5, Y, P.wood.base) R(X + 4, Y - 3, X + 5, Y, P.wood.shade) px(X - 6, Y - 3, P.wood.hi)
end
local function bee(x, y)   -- 4x2 body + wing, top-left (x,y)
  local body = c:rect(x, y, x + 3, y + 1)
  local wing = c:rect(x + 1, y - 2, x + 2, y - 1)
  ink(body, wing)
  c:fillMask(wing, P.sky.hi) px(x + 1, y - 1, CREAM)
  c:fillMask(body, P.gold.base)
  px(x, y, P.gold.hi); px(x + 1, y, INK); px(x + 1, y + 1, INK); px(x + 3, y, INK); px(x + 3, y + 1, P.gold.shade)
  px(x + 2, y, P.gold.hi)
end
local function flower(x, y, col)
  local head = HP.mask():set(x, y - 1):set(x - 1, y):set(x, y):set(x + 1, y):set(x, y + 1)
  local stem = c:rect(x, y + 2, x, y + 3)
  ink(head, stem)
  c:fillMask(stem, P.moss.base); c:fillMask(head, col); px(x, y, P.gold.hi)
end
local function jar(x, y)
  local lid = c:rect(x + 1, y, x + 3, y + 1)
  local body = c:rrect(x, y + 2, x + 4, y + 6, 1)
  ink(lid, body)
  c:part(body, "gold", { band = 2, pop = { x = x + 1, y = y + 3, horizontal = true } })
  c:part(lid, "wood", { band = 1, nopop = true })
  px(x + 2, y + 5, P.ember.shade)
end
local function candle(x, y)
  local body = c:rect(x, y, x + 1, y + 4)
  local flame = c:rect(x, y - 3, x, y - 2)
  ink(body, flame)
  c:part(body, WAX, { band = 1, pop = { x = x, y = y + 1, horizontal = true } })
  c:fillMask(flame, P.gold.base); px(x, y - 3, P.gold.hi)
end
local function cast(rx) shadeUnder(E(X + 3, Y + 1, rx, 2), .38) end

------------------------------------------------------------ BUILD lettering
local GL = {
  B = { "110", "101", "110", "101", "110" }, U = { "101", "101", "101", "101", "111" },
  I = { "111", "010", "010", "010", "111" }, L = { "100", "100", "100", "100", "111" },
  D = { "110", "101", "101", "101", "110" },
}
local function build(x, y, col)
  for i = 1, 5 do
    local ch = ("BUILD"):sub(i, i)
    for r = 1, 5 do for q = 1, 3 do if GL[ch][r]:sub(q, q) == "1" then px(x + (i - 1) * 4 + q - 1, y + r - 1, col) end end end
  end
end

------------------------------------------------------------ pieces
local L1T = { { X, Y - 15, 4, 3 }, { X, Y - 11, 6, 3 }, { X, Y - 6, 7, 4 } }
local L2T = { { X, Y - 23, 4, 3 }, { X, Y - 19, 6, 3 }, { X, Y - 14, 7, 4 }, { X, Y - 8, 9, 5 } }
local L3T = { { X - 2, Y - 21, 4, 3 }, { X - 2, Y - 17, 6, 3 }, { X - 2, Y - 13, 8, 4 }, { X - 2, Y - 8, 9, 5 } }

local function level1()
  newc("beehive-l1")
  cast(9)
  local l = legs(); ink(l)
  drawLegs(l)
  skep(L1T)
  hole(X, Y - 5, Y - 4)
  bee(40, Y - 28)
  return c
end
local function level2()
  newc("beehive-l2")
  cast(10)
  local l = legs(); ink(l); drawLegs(l)
  local u = skep(L2T)
  band(u, Y - 17, Y - 16)
  R(X - 1, Y - 5, X + 1, Y - 3, INTERIOR) R(X - 1, Y - 2, X + 1, Y - 2, P.gold.hi)
  -- honey tray: a little table at the front right with two jars
  local tray = c:rect(X + 4, Y - 8, X + 12, Y - 7)
  local tl = c:rect(X + 5, Y - 6, X + 5, Y):add(c:rect(X + 11, Y - 6, X + 11, Y))
  ink(tray, tl)
  c:fillMask(tl, P.wood.deep)
  c:part(tray, "wood", { band = 1 })
  jar(X + 4, Y - 14) jar(X + 9, Y - 14)
  flower(X - 11, Y - 2, P.petal.base)
  bee(X - 17, Y - 22)
  return c
end
local function level3()
  newc("beehive-l3")
  cast(12)
  -- second small skep behind, right
  skep({ { X + 11, Y - 9, 3, 2 }, { X + 11, Y - 4, 5, 3 } })
  R(X + 10, Y - 3, X + 12, Y - 2, INTERIOR)
  local l = c:rect(X - 8, Y - 3, X - 7, Y):add(c:rect(X + 2, Y - 3, X + 3, Y)); ink(l)
  R(X - 8, Y - 3, X - 7, Y, P.wood.base) R(X + 2, Y - 3, X + 3, Y, P.wood.shade) px(X - 8, Y - 3, P.wood.hi)
  local u = skep(L3T)
  band(u, Y - 17, Y - 16)
  R(X - 3, Y - 5, X - 1, Y - 3, INTERIOR) R(X - 3, Y - 2, X - 1, Y - 2, P.gold.hi)
  -- crown with finial
  local cb = c:rect(X - 5, Y - 28, X + 1, Y - 26)
  local pts = HP.mask():set(X - 5, Y - 29):set(X - 5, Y - 30):set(X - 2, Y - 29):set(X - 2, Y - 30):set(X - 2, Y - 31):set(X + 1, Y - 29):set(X + 1, Y - 30)
  ink(cb, pts)
  c:fillMask(pts, P.gold.hi); c:part(cb, "gold", { band = 1 })
  px(X - 5, Y - 27, P.ember.base) px(X - 2, Y - 27, P.sky.base) px(X + 1, Y - 27, P.ember.base)
  px(X - 2, Y - 31, CREAM)
  -- beeswax candles on a little stand at the left
  local top = c:rect(X - 20, Y - 8, X - 10, Y - 7)
  local tl = c:rect(X - 19, Y - 6, X - 19, Y):add(c:rect(X - 11, Y - 6, X - 11, Y))
  ink(top, tl)
  c:fillMask(tl, P.wood.deep); c:part(top, "wood", { band = 1 })
  candle(X - 19, Y - 13) candle(X - 16, Y - 14) candle(X - 13, Y - 13)
  flower(X + 20, Y - 2, P.petal.base)
  bee(X + 15, Y - 31) bee(X - 18, Y - 27)
  return c
end

local ORB = { { 14, 10 }, { 14, -10 }, { -14, -10 }, { -14, 10 } }
local function badge(dy)
  local m = E(51, 8 + dy, 4, 4)
  ink(m)
  c:part(m, "gold")
  R(50, 6 + dy, 51, 8 + dy, CREAM) R(50, 10 + dy, 51, 10 + dy, CREAM)
end
local DRIP = { { 0, 3 }, { 1, 6 }, { 2, 9 }, { 3, 11 } }
local function ready(k)
  level1()
  -- orbiting bees (remove the static one by redrawing is not needed: level1 bee sits at 40,26; keep out of the orbit)
  newc("beehive-ready")
  cast(9)
  local l = legs(); ink(l); drawLegs(l)
  skep(L1T)
  hole(X, Y - 5, Y - 4)
  -- honey drip runs down the front from the entrance
  local d = DRIP[k]
  local dy0 = Y - 3 + d[1]
  local trail = c:rect(X + 2, Y - 3, X + 2, math.max(dy0 - 1, Y - 3))
  local drop = c:rect(X + 2, dy0, X + 3, dy0 + 1)
  ink(trail, drop)
  c:fillMask(trail, P.gold.hi) c:fillMask(drop, P.gold.hi) px(X + 3, dy0 + 1, P.gold.base)
  -- bees circle the skep
  local cx, cy = X, Y - 17
  for j = 0, 2 do
    local o = ORB[(k - 1 + j * 1) % 4 + 1]
    if j == 2 then o = ORB[(k + 1) % 4 + 1]; o = { o[1] * 0.6, o[2] * 1.6 } end
    local bx, by = floor(cx + o[1] + .5) - 2, floor(cy + o[2] + .5)
    if j < 2 then bee(bx, by) else bee(bx, by) end
  end
  local sp = { { 10, Y - 28 }, { 44, Y - 22 }, { 9, Y - 12 }, { 45, Y - 33 } }
  c:sparkle(sp[k][1], sp[k][2])
  c:sparkle(sp[(k + 1) % 4 + 1][1], sp[(k + 1) % 4 + 1][2] + 1)
  badge(({ 0, -1, 0, 1 })[k])
  return c
end

local function empty(f)
  newc("beehive-empty")
  local patch = c:ellipse(28, 49, 24, 5)
  ink(patch)
  c:part(patch, "wood", { nopop = true })
  for _, p in ipairs{ { 10, 50 }, { 34, 52 }, { 44, 48 }, { 20, 53 }, { 27, 46 } } do px(p[1], p[2], P.wood.deep) px(p[1] + 1, p[2], P.wood.shade) end
  local st = { { 8, 47 }, { 48, 47 }, { 52, 53 }, { 4, 53 } }
  for i = 1, 4 do local a, b = st[i], st[i % 4 + 1]; seg(a[1], a[2] - 5, b[1], b[2] - 5, CREAM) end
  -- post shadow
  shadeUnder(c:rect(16, 50, 26, 51), 0) R(16, 51, 27, 52, SHD_A)
  -- bent post: up, bend, arm with a down hook
  local post = c:line({ { 14, 50 }, { 14, 18 }, { 17, 14 }, { 44, 14 }, { 44, 17 } }, 1)
  ink(post)
  c:fillMask(post, P.wood.base)
  post:each(function(x, y) if x == 14 and y > 18 and y < 50 then px(x, y, P.wood.shade) end end)
  px(14, 30, P.wood.hi) px(14, 40, P.wood.hi)
  for xx = 18, 43 do px(xx, 14, P.wood.hi) end
  -- plaque swings 1 px
  local sx = ({ 0, 1, 0, -1 })[f]
  local ox, oy = 18 + sx, 21
  local hex = c:poly{ { ox, oy + 8 }, { ox + 6, oy }, { ox + 24, oy }, { ox + 30, oy + 8 }, { ox + 24, oy + 16 }, { ox + 6, oy + 16 } }
  seg(22, 14, ox + 7, oy, P.wood.hi) seg(44, 14, ox + 25, oy, P.wood.hi)   -- hanging cords
  ink(hex)
  c:fillMask(hex, WAX.base)
  -- honeycomb border: gold inner edge, corner cells
  hex:each(function(x, y) if not hex:shrink(1):has(x, y) then px(x, y, P.gold.base) end end)
  hex:each(function(x, y) if (x + y * 2) % 7 == 0 and hex:shrink(2):has(x, y) and (y < oy + 6 or y > oy + 12 or false) and not (x > ox + 7 and x < ox + 23) then px(x, y, WAX.shade) end end)
  px(ox + 8, oy + 1, P.gold.hi) px(ox + 9, oy + 1, P.gold.hi)
  -- tiny skep icon
  c:paint({
    "..III..",
    ".IgGGI.",
    ".IGGsI.",
    "IgGGGsI",
    "IGGDGsI",
    "IIIIIII" }, ox + 12, oy + 2, { I = INK, g = P.gold.hi, G = P.gold.base, s = P.gold.shade, D = INTERIOR })
  build(ox + 6, oy + 9, INK)
  -- tiny flowers and stones
  flower(12, 51, P.petal.base) flower(38, 53, P.sky.hi) flower(46, 51, P.gold.base)
  for _, p in ipairs{ { 22, 50 }, { 32, 47 } } do local m = c:ellipse(p[1], p[2], 1, 1); ink(m); c:part(m, "stone", { band = 1 }) end
  -- stakes over strings
  for _, s in ipairs(st) do local m = c:rect(s[1], s[2] - 5, s[1], s[2]); ink(m); c:fillMask(m, P.wood.base); px(s[1], s[2] - 5, P.wood.hi) end
  -- a bee drifting through
  local bp = { { 2, 38 }, { 6, 31 }, { 3, 25 }, { 7, 32 } }
  bee(bp[f][1], bp[f][2])
  return c
end

local function save(cv, name)
  HP.assertClean(cv)
  cv:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
local function strip(frames, name, tag)
  HP.sheet{ cellw = W_, cellh = H_, frames = frames, tags = { { name = tag, from = 1, to = 4 } } }:save{
    aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
save(level1(), "beehive-l1") save(level2(), "beehive-l2") save(level3(), "beehive-l3")
local fr = {}
for f = 1, 4 do fr[f] = empty(f); HP.assertClean(fr[f]) end
strip(fr, "beehive-empty", "empty")
fr = {}
for k = 1, 4 do fr[k] = ready(k); HP.assertClean(fr[k]) end
strip(fr, "beehive-ready", "ready")
