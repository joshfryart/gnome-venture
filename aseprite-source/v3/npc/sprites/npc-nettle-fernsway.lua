-- npc-nettle-fernsway sprite (npc2 P1_23) species: box turtle
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local function keep(c, x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
-- 4-tone form: base + shade band (part) + lit upper-left rim (hi) + deep underside (AO)
local function form(c, m, r, o)
  o = o or {}
  c:part(m, r, { band = o.band or 2, nopop = true, inner = o.inner, sep = o.sep })
  local x0, y0, x1, y1 = m:bbox()
  if not x0 then return m end
  local cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
  local B, Sh = r.base:lower(), r.shade:lower()
  local hl, dp = {}, {}
  m:each(function(x, y)
    local v = c:get(x, y)
    if v == B and not m:has(x - 1, y - 1) and x <= cx and y <= cy then hl[#hl + 1] = { x, y } end
    if o.under ~= false and not m:has(x, y + 1) and (v == B or v == Sh) then dp[#dp + 1] = { x, y } end
  end)
  for _, q in ipairs(hl) do keep(c, q[1], q[2], r.hi) end
  for _, q in ipairs(dp) do keep(c, q[1], q[2], r.deep) end
  if o.pop then for _, q in ipairs(o.pop) do keep(c, q[1], q[2], r.hi) end end
  return m
end
local function eyeS(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, P.ink) end return end
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs{ {0,1},{3,1},{0,2},{3,2},{1,3},{2,3} } do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
local function backdrop(c, r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade:lower() then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
-- fern frond along a polyline (base -> tip), opposite pinnae shrinking toward the tip
local function fernMask(c, pts, L, w, skipTip)
  local stem, leaves, sm = c:line(pts, 1), HP.mask(), {}
  for i = 1, #pts - 1 do local a, b = pts[i], pts[i + 1]
    local n = math.max(math.abs(b[1] - a[1]), math.abs(b[2] - a[2]), 1)
    for s = 0, n - 1 do sm[#sm + 1] = { a[1] + (b[1] - a[1]) * s / n, a[2] + (b[2] - a[2]) * s / n, (b[1] - a[1]) / n, (b[2] - a[2]) / n } end end
  local N = #sm - (skipTip or 0)
  for k = 2, N, 3 do local q = sm[k]
    local f = 1 - k / #sm
    local len = math.max(1, math.floor(L * (0.35 + 0.65 * f) + 0.5))
    local d = math.sqrt(q[3] ^ 2 + q[4] ^ 2) local dx, dy = q[3] / d, q[4] / d
    for _, s in ipairs{ -1, 1 } do
      leaves:add(c:line({ { q[1], q[2] }, { q[1] - dy * s * len + dx * len * 0.3, q[2] + dx * s * len + dy * len * 0.3 } }, w))
    end
  end
  return stem, leaves
end
local SKIN  = { hi = "#cfe08e", base = "#8fb35c", shade = "#5e8462", deep = "#3b5258" }
-- Elder box turtle hen-keeper: high domed shell humps over the shoulders, cream apron over a gold plastron,
-- red kerchief, hooded eyelids. Prop: a fern frond with a curled fiddlehead tip that sways.
local NAME = "npc-nettle-fernsway"
local SHELL = { hi = "#e0b071", base = "#a9733f", shade = "#7a4f4a", deep = "#4d3244" }
local RIM   = { hi = "#ffe38a", base = "#e2b04e", shade = "#b8834a", deep = "#7a4f4a" }
local BEAK  = { hi = P.cream, base = "#f0dca0", shade = "#c8ad88", deep = "#8a6c6a" }
local CR    = { hi = P.cream, base = "#f3e6c8", shade = "#c9c2cc", deep = "#8e8aa0" }
local FERN  = { hi = "#c4e07a", base = "#5fae4e", shade = "#3a7d58", deep = "#24544a" }
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, tw = p.b or 0, p.tw or 0
  c:groundShadow(32, 90, 15, 3)
  for _, fx in ipairs{ 26, 38 } do              -- stubby legs + clawed feet (fixed)
    form(c, c:rect(fx - 3, 79, fx + 3, 85), SKIN, { under = false })
    form(c, c:ellipse(fx, 87.5, 4.5, 2.5), SKIN)
    c:put(fx - 3, 89, BEAK.base) c:put(fx - 1, 90, BEAK.base) c:put(fx + 1, 90, BEAK.base)
  end
  -- domed shell behind (humps over shoulders), gold marginal rim, scute seams
  local sh = c:ellipse(32, 63 + b, 17, 13)
  form(c, sh, SHELL, { band = 3 })
  local rim = sh:copy():cut(sh:shrink(2)):clip(c:rect(0, 63 + b, 63, 95))
  c:part(rim, RIM, { band = 1, nopop = true, inner = false })
  for _, l in ipairs{ { {15,60},{21,57} }, { {16,69},{22,67} }, { {20,51},{21,57} }, { {49,60},{43,57} }, { {48,69},{42,67} }, { {44,51},{43,57} } } do
    c:line({ { l[1][1], l[1][2] + b }, { l[2][1], l[2][2] + b } }, 1):clip(sh:shrink(1)):each(function(x, y) keep(c, x, y, SHELL.deep) end)
  end
  keep(c, 17, 55 + b, SHELL.hi) keep(c, 18, 54 + b, SHELL.hi)
  -- plastron + apron
  form(c, c:ellipse(32, 70 + b, 11.5, 11), BEAK)
  form(c, c:line({ {26,66+b},{24,59+b} }, 2), CR, { under = false })
  form(c, c:line({ {38,66+b},{40,59+b} }, 2), CR, { under = false })
  form(c, c:rrect(25, 65 + b, 39, 81 + b, 3), CR)
  c:stitch{ {28, 74 + b}, {36, 74 + b} }
  -- arms
  form(c, c:ellipse(19, 67 + b, 3, 5), SKIN) form(c, c:ellipse(19, 72 + b, 2.5, 2), SKIN)
  form(c, c:ellipse(45, 67 + b, 3, 5), SKIN)
  -- neck + kerchief
  form(c, c:ellipse(32, 55 + b, 8, 3), SKIN)
  local kf = c:poly{ {21,54+b},{43,54+b},{32,64+b} }
  form(c, kf, P.ember) form(c, c:ellipse(41, 56 + b, 2, 1.5), P.ember)
  -- big round head, crown plates
  local hd = c:ellipse(32, 41 + b, 13.5, 12)
  form(c, hd, SKIN, { band = 3, pop = { {24,32+b},{25,32+b},{24,33+b} } })
  for _, q in ipairs{ {26,34}, {32,32}, {38,34} } do
    local pl = c:ellipse(q[1], q[2] + b, 3, 1.5)
    pl:edge():each(function(x, y) keep(c, x, y, SKIN.shade) end)
  end
  -- snout + o-mouth, nostrils
  form(c, c:ellipse(32, 47.5 + b, 6.5, 4), BEAK, { pop = { {28,45+b},{29,45+b} } })
  keep(c, 30, 45 + b, BEAK.deep) keep(c, 34, 45 + b, BEAK.deep)
  c:paint({ ".ii.", "iPPi", ".ii." }, 30, 48 + b, { i = "ink", P = "petal.shade" })
  -- hooded elder eyes
  for _, ex in ipairs{ 23, 37 } do
    eyeS(c, ex, 39 + b, p.blink)
    for i = -1, 4 do keep(c, ex + i, 38 + b, SKIN.deep) end
  end
  c:cheek(21, 45 + b) c:cheek(41, 45 + b)
  -- fern frond (prop) held in the right hand
  local stem, lv = fernMask(c, { {47,76+b},{50,64+b},{53,52+b},{54+tw,42+b},{53+tw,37+b},{51+tw,36+b},{50+tw,38+b} }, 3, 1, 4)
  form(c, lv, FERN, { band = 1 })
  c:fillMask(stem, FERN.deep)
  form(c, c:ellipse(46, 72 + b, 2.5, 2), SKIN)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = { frame{ b = 0 }, frame{ b = 1, tw = 1 }, frame{ b = 0 }, frame{ b = 0, blink = true, tw = -1 } }
HP.report(frames[1])
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
