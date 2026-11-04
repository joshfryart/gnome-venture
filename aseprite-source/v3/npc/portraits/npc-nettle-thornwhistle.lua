-- npc-nettle-thornwhistle portrait (npc2 P1_23) species: field cricket
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
  for k = 2, N, 2 do local q = sm[k]
    local f = 1 - k / #sm
    local len = math.max(1, math.floor(L * (0.35 + 0.65 * f) + 0.5))
    local d = math.sqrt(q[3] ^ 2 + q[4] ^ 2) local dx, dy = q[3] / d, q[4] / d
    for _, s in ipairs{ -1, 1 } do
      leaves:add(c:line({ { q[1], q[2] }, { q[1] - dy * s * len + dx * len * 0.5, q[2] + dx * s * len + dy * len * 0.5 } }, w))
    end
  end
  return stem, leaves
end
local SKIN  = { hi = "#cfe08e", base = "#8fb35c", shade = "#5e8462", deep = "#3b5258" }
local NAME = "npc-nettle-thornwhistle"
local GRN  = { hi = "#c4e07a", base = "#76bb4e", shade = "#43885a", deep = "#2b5250" }
local PL   = { hi = "#eef5b0", base = "#c4e07a", shade = "#8fbf62", deep = "#43885a" }
local WING = { hi = "#d9c08a", base = "#a88a58", shade = "#76604e", deep = "#4c3c44" }
local GOLD = { hi = "#ffe38a", base = "#f5b82e", shade = "#c97a3a", deep = "#7d4a3e" }
local CR   = { hi = P.cream, base = "#f3e6c8", shade = "#c9c2cc", deep = "#8e8aa0" }
local TAN  = { hi = "#fbe8c4", base = "#efd6a8", shade = "#d2ab7e", deep = "#a07a5a" }
local c = HP.canvas{ w = 80, h = 100, name = NAME }
local ALL = c:rect(0, 0, 79, 99)
-- folded wings behind the shoulders
for _, s in ipairs{ -1, 1 } do
  local w = c:poly{ {39.5+s*8,72},{39.5+s*21,66},{39.5+s*35,92},{39.5+s*30,100},{39.5+s*16,90} }:clip(ALL)
  form(c, w, WING, { band = 2 })
  for _, l in ipairs{ { {39.5+s*18,70},{39.5+s*31,94} }, { {39.5+s*14,76},{39.5+s*24,96} } } do
    c:line(l, 1):clip(w:shrink(1)):each(function(x, y) keep(c, x, y, WING.shade) end)
  end
end
-- shirt, neck, collar
form(c, c:ellipse(39.5, 99, 26, 26):clip(ALL), GOLD, { band = 3, under = false })
form(c, c:rect(33, 60, 46, 76), GRN, { band = 2 })
form(c, c:poly{ {28,72},{39.5,72},{36,84} }, CR) form(c, c:poly{ {51,72},{39.5,72},{43,84} }, CR)
for _, y in ipairs{ 88, 94 } do form(c, c:rect(39, y, 40, y + 1), CR, { under = false }) end
-- antennae (behind head) with bobble tips
c:fillMask(c:line({ {34,32},{30,20},{25,10},{23,8} }, 1), GRN.shade)
c:fillMask(c:line({ {45,32},{49,20},{54,10},{56,8} }, 1), GRN.shade)
form(c, c:ellipse(22, 6, 2.5, 2.5), GRN) form(c, c:ellipse(57, 6, 2.5, 2.5), GRN)
-- head
local hd = c:ellipse(39.5, 46, 20, 17)
form(c, hd, GRN, { band = 3, pop = { {26,35},{27,35},{26,36} } })
-- bead circlet
local function cy(x) return 36 + math.floor(3.5 * math.sqrt(math.max(0, 1 - ((x - 39.5) / 20) ^ 2)) + .5) end
for x = 19, 60 do if hd:has(x, cy(x)) then keep(c, x, cy(x), P.wood.deep) end end
local BEAD = { P.petal, P.gold, CR, P.dusk, P.ember, P.sea }
for i, x in ipairs{ 24, 30, 36, 43, 49, 55 } do
  local bm = c:ellipse(x, cy(x), 2, 2)
  c:part(bm, BEAD[i], { band = 1, nopop = true })
  local bx, by = bm:bbox() c:put(bx + 1, by + 1, BEAD[i].hi)
end
-- compound-eye bulges around locked eyes
for _, e in ipairs{ {28.5,46.5}, {50.5,46.5} } do
  local ring = c:ellipse(e[1], e[2], 3.5, 3.5)
  c:fillMask(ring, GRN.shade) ring:edge():each(function(x, y) keep(c, x, y, GRN.deep) end)
  c:eyeLocked(math.floor(e[1]) - 2, math.floor(e[2]) - 2)
end
-- face plate snout + mandibles + smile
form(c, c:poly{ {35,47},{45,47},{43.5,55},{35.5,55} }, PL, { under = false, pop = { {36,48},{37,48} } })
for y = 49, 53 do keep(c, 40, y, PL.shade) end
form(c, c:poly{ {35,55},{38.5,55},{37,58} }, P.wood, { under = false }) form(c, c:poly{ {41,55},{44.5,55},{42,58} }, P.wood, { under = false })
for _, q in ipairs{ {34,59},{35,60},{36,60},{37,60},{38,60},{39,60},{40,60},{41,60},{42,60},{43,60},{44,60},{45,59} } do c:put(q[1], q[2], P.ink) end
c:paint({ "PPP", "PPP" }, 22, 52, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 55, 52, { P = "petal.base" })
c:put(22, 52, P.petal.hi) c:put(55, 52, P.petal.hi)
-- thorn-wood whistle held at the lower right
local wh = c:line({ {46,98},{63,74} }, 4)
for _, q in ipairs{ {52,87},{51,86},{58,79},{57,78} } do wh:set(q[1], q[2]) end
form(c, wh, P.wood, { band = 1 })
for _, q in ipairs{ {53,90},{56,86},{59,82} } do keep(c, q[1], q[2], P.wood.deep) end
form(c, c:rect(61, 73, 64, 76), CR)
form(c, c:ellipse(50, 92, 4, 3.5), GRN, { pop = { {48,90},{49,90} } })
c:finish{ outline = true }
backdrop(c, TAN)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
