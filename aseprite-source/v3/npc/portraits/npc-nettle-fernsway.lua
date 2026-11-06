-- npc-nettle-fernsway portrait (npc2 P1_23) species: box turtle
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
  for k = 2, N, 4 do local q = sm[k]
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
local NAME = "npc-nettle-fernsway"
local SHELL = { hi = "#e0b071", base = "#a9733f", shade = "#7a4f4a", deep = "#4d3244" }
local RIM   = { hi = "#ffe38a", base = "#e2b04e", shade = "#b8834a", deep = "#7a4f4a" }
local BEAK  = { hi = P.cream, base = "#f0dca0", shade = "#c8ad88", deep = "#8a6c6a" }
local CR    = { hi = P.cream, base = "#f3e6c8", shade = "#c9c2cc", deep = "#8e8aa0" }
local FERN  = { hi = "#c4e07a", base = "#5fae4e", shade = "#3a7d58", deep = "#24544a" }
local c = HP.canvas{ w = 80, h = 100, name = NAME }
local ALL = c:rect(0, 0, 79, 99)
-- shell dome behind the shoulders
local sh = c:ellipse(39.5, 88, 35, 22):clip(ALL)
form(c, sh, SHELL, { band = 3, under = false })
local inner = sh:shrink(3)
c:part(sh:copy():cut(inner), RIM, { band = 1, nopop = true, inner = false })
for _, l in ipairs{ { {12,80},{20,72} }, { {7,93},{17,86} }, { {67,80},{59,72} }, { {72,93},{62,86} }, { {20,72},{26,70} }, { {59,72},{53,70} } } do
  c:line(l, 1):clip(inner):each(function(x, y) keep(c, x, y, SHELL.deep) end)
end
for _, q in ipairs{ {13,77},{14,76},{15,76},{9,88},{10,87} } do keep(c, q[1], q[2], SHELL.hi) end
-- plastron + apron bib
form(c, c:ellipse(39.5, 104, 23, 26):clip(ALL), BEAK, { band = 3, under = false })
form(c, c:line({ {31,85},{28,77} }, 3), CR, { under = false }) form(c, c:line({ {48,85},{51,77} }, 3), CR, { under = false })
form(c, c:rrect(29, 84, 50, 99, 4), CR, { under = false })
form(c, c:rrect(34, 91, 45, 97, 2), CR) c:stitch{ {35, 92}, {44, 92} }
-- wrinkly neck
local nk = c:rrect(29, 58, 50, 80, 6)
form(c, nk, SKIN, { band = 3 })
for _, a in ipairs{ { {31,66},{39,68},{48,66} }, { {32,71},{39,73},{47,71} } } do c:line(a, 1):clip(nk:shrink(1)):each(function(x, y) keep(c, x, y, SKIN.shade) end) end
-- red kerchief with knot + tails
local kf = c:poly{ {24,74},{55,74},{39.5,89} }
form(c, kf, P.ember, { band = 2 })
form(c, c:poly{ {52,77},{59,85},{55,86} }, P.ember) form(c, c:ellipse(52, 76, 3, 2.5), P.ember, { pop = { {51,75},{52,75} } })
-- head
local hd = c:ellipse(39.5, 44, 20.5, 18)
form(c, hd, SKIN, { band = 3, pop = { {26,33},{27,33},{26,34} } })
for _, q in ipairs{ {31,34}, {39.5,31}, {48,34}, {35,39}, {44,39} } do
  local pl = c:ellipse(q[1], q[2], 4, 2.5)
  pl:edge():clip(hd:shrink(1)):each(function(x, y) keep(c, x, y, SKIN.shade) end)
  keep(c, math.floor(q[1]) - 1, math.floor(q[2]) - 1, SKIN.hi)
end
-- snout with nostrils and a little round o-mouth
form(c, c:ellipse(39.5, 53, 9, 6), BEAK, { band = 2, pop = { {33,49},{34,49} } })
keep(c, 37, 50, BEAK.deep) keep(c, 42, 50, BEAK.deep) keep(c, 37, 51, BEAK.shade) keep(c, 42, 51, BEAK.shade)
c:paint({ ".iiii.", "iDPPDi", "iDPPDi", ".iiii." }, 37, 54, { i = "ink", D = "ember.deep", P = "petal.base" })
-- hooded elder eyes
for _, ex in ipairs{ 27, 48 } do
  c:eyeLocked(ex, 40)
  for i = -1, 5 do keep(c, ex + i, 39, SKIN.deep) end
  for i = 0, 4 do keep(c, ex + i, 38, SKIN.shade) end
end
c:paint({ "PPP", "PPP" }, 23, 50, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 54, 50, { P = "petal.base" })
c:put(23, 50, P.petal.hi) c:put(54, 50, P.petal.hi)
-- fern frond with fiddlehead curl, held up at the left
local stem, lv = fernMask(c, { {17,99},{14,82},{12,64},{11,48},{13,37},{17,34},{19,37},{17,39} }, 6, 2, 9)
form(c, lv, FERN, { band = 1 })
c:fillMask(stem, FERN.deep)
c:fillMask(c:line({ {17,34},{19,37},{17,39} }, 2), FERN.shade)
form(c, c:ellipse(16, 90, 4, 3.5), SKIN, { pop = { {14,88},{15,88} } })
for _, y in ipairs{ 89, 91 } do keep(c, 19, y, SKIN.deep) end
c:finish{ outline = true }
backdrop(c, P.petal)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
