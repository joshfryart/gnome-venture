-- feast-maplewold-table (final, Opus single pass). A small slim-legged maplewood table set for breakfast: a stack of four
-- golden pancakes on a cream plate with a butter pat and maple syrup pooling and running down the sides, and a glass
-- syrup jug with a cork, a loop handle and a label. Material: wood grain on the top (wavy darker lines), pale end grain on
-- the cut end, turned legs with a bead, AO under the top and where legs meet it; pancakes lit per pixel with a crisp
-- browned rim and a dark seam between layers; syrup glossy; glass with a bright rim and a pale core.
-- quirk: a red maple leaf has drifted down onto the table corner.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, sqrt, max, min = math.floor, math.abs, math.sin, math.cos, math.sqrt, math.max, math.min
local norm = A.norm
local c = A.new("feast-maplewold-table")

local WOOD = { "#3a1d1e", "#653426", "#91532f", "#b8773e", "#d69e58", "#efc787" }
local PAN  = { "#5c2818", "#8e4a22", "#c27a32", "#e2a44c", "#f2c870", "#fde6a8" }
local SYR  = { "#3e140c", "#6e2610", "#a04414", "#cc6c1e", "#eb9a36", "#ffd27a" }
local PLATE = { "#4a4566", "#7a7795", "#a8a7bd", "#cfd0da", "#ebe7e2", "#fdf8ee" }
local BUT  = { "#c69a2e", "#f0cc56", "#fde88e", "#fff6c8" }
local LEAF = { "#5a0f1c", "#8c1a22", "#c2302a", "#e85a34", "#ff9450" }
local SPEC = "#fff4d6"

c:groundShadow(32, 57, 23, 2)

-- legs: back pair first (in shadow), then front pair, turned with a bead
local function leg(x0, y0, y1, dark)
  local m = c:rect(x0, y0, x0 + 2, y1)
  m:add(c:rect(x0 - 1, y0 + 3, x0 + 3, y0 + 4))
  local b = {}
  m:each(function(x, y) local k = K(x, y) b[k] = (dark and -2 or 0) + ((y <= y0 + 1) and -1 or 0) end)
  A.vcyl(c, m, WOOD, x0 - 1, x0 + 3, { amb = 0.08, wrap = 0.25, bias = b })
  c:put(x0, y1, WOOD[2]) c:put(x0 + 1, y1, WOOD[2]) c:put(x0 + 2, y1, WOOD[1])
end
leg(17, 46, 52, true) leg(44, 46, 52, true)
leg(10, 46, 57) leg(51, 46, 57)

-- table top: top face + front edge + end grain
local top = c:rrect(8, 37, 56, 42, 1)
local tb = {}
top:each(function(x, y) local k = K(x, y)
  local g = (y * 2.3 + sin(x * 0.21 + y) * 1.4 + (x > 30 and 0.8 or 0)) % 3
  if g < 0.55 then tb[k] = -1 end
  if y == 37 then tb[k] = (tb[k] or 0) + 1 end
end)
local tn = X.pillow(top, 2)
local tidx = A.shade(c, top, tn, WOOD, { amb = 0.18, wrap = 0.35, bias = tb, cuts = { 0.15, 0.3, 0.45, 0.62, 0.86 } })
local edge = c:rect(8, 43, 56, 45)
local eb = {}
edge:each(function(x, y) local k = K(x, y) eb[k] = (y == 45 and -1 or 0) + ((x % 11 == 3) and -1 or 0) end)
A.shade(c, edge, (function() local n = {} edge:each(function(x, y) n[K(x, y)] = { 0, 0.55, 0.83 } end) return n end)(), WOOD, { amb = 0.05, bias = eb })
-- pale end grain on the right end of the slab, with growth rings
for y = 43, 45 do c:put(56, y, WOOD[5]) c:put(55, y, y == 44 and WOOD[4] or WOOD[5]) end
c:put(56, 44, WOOD[4])
-- top front edge lit lip
for x = 9, 55 do c:put(x, 42, WOOD[5]) end
-- AO under the slab onto the legs (already dark) and a cast shadow on the top from the stack and jug added below

-- plate under the stack
local px, py = 23, 37
local pl = A.emask(px, py, 12.5, 2.6)
local pln = {}
pl:each(function(x, y) local u, v = (x - px) / 12.5, (y - py) / 2.6 local rr = sqrt(u*u + v*v) pln[K(x, y)] = rr > 0.7 and { norm(-u * 0.5, -v * 0.5, 1) } or { 0, 0, 1 } end)
A.shade(c, pl, pln, PLATE, { amb = 0.18, wrap = 0.35 })
local plu = A.emask(px, py + 1, 12, 2.4):cut(pl)
plu:each(function(x, y) c:put(x, y, x < px and PLATE[3] or PLATE[2]) end)
-- contact shadow of the plate on the table
for x = px - 10, px + 13 do local y = py + 3 + (abs(x - px) > 9 and -1 or 0) if top:has(x, y) and not pl:has(x, y) and not plu:has(x, y) then c:put(x, y, WOOD[max(1, (tidx[K(x, y)] or 3) - 2)]) end end

-- pancake stack
local PRX, PRY = 9.5, 2.4
local stack = HP.mask()
for i = 0, 3 do
  local cy = 34 - i * 3
  local ox = (i % 2 == 0) and 0 or (i == 1 and 0.6 or -0.5)
  local tp = A.emask(px + ox, cy, PRX - (i == 3 and 0.4 or 0), PRY)
  local side = HP.mask()
  for d = 0, 2 do tp:shift(0, d):each(function(x, y) side:set(x, y) end) end
  side:cut(tp)
  local sb = {}
  side:each(function(x, y) if not side:has(x, y + 1) then sb[K(x, y)] = -1 end if X.hash(x, y, i) > 0.85 then sb[K(x, y)] = (sb[K(x, y)] or 0) - 1 end end)
  A.vcyl(c, side, PAN, px + ox - PRX, px + ox + PRX, { amb = 0.1, wrap = 0.3, bias = sb, ny = function() return 0.2 end })
  local tnn, tbb = {}, {}
  tp:each(function(x, y) local u, v = (x - px - ox) / PRX, (y - cy) / PRY local rr = sqrt(u*u + v*v)
    tnn[K(x, y)] = { norm(u * max(0, rr - 0.6) * 1.5, v * max(0, rr - 0.6) * 1.2, 1) }
    if rr > 0.86 then tbb[K(x, y)] = -1 end end)
  A.shade(c, tp, tnn, PAN, { amb = 0.2, wrap = 0.35, bias = tbb, cuts = { 0.15, 0.3, 0.45, 0.6, 0.9 } })
  stack:add(tp):add(side)
end
-- syrup pool on top + drips down the sides
local ty = 34 - 9
local pool = A.emask(px + 0.6, ty + 0.3, 6.5, 1.6)
local pn = {}
pool:each(function(x, y) pn[K(x, y)] = { norm((x - px) / 14, (y - ty) / 6, 1) } end)
A.shade(c, pool, pn, SYR, { amb = 0.2, wrap = 0.3, cuts = { 0.15, 0.3, 0.45, 0.6, 0.85 } })
local drips = { { px - 5, 2, 7 }, { px - 1, 2, 4 }, { px + 3, 2, 9 }, { px + 6, 1, 5 } }
for _, d in ipairs(drips) do
  local x = d[1]
  local y0 = ty + d[2]
  for y = y0, y0 + d[3] do if stack:has(x, y) then c:put(x, y, (x < px) and SYR[4] or SYR[3]) end end
  c:put(x, y0 + d[3] + 1, SYR[2])
  if d[3] > 6 then c:put(x + 1, y0 + d[3], SYR[2]) c:put(x, y0 + d[3], SYR[3]) end
end
c:put(px - 3, ty, SYR[6]) c:put(px - 2, ty, SPEC)
-- butter pat
c:put(px - 1, ty - 2, BUT[4]) c:put(px, ty - 2, BUT[3]) c:put(px + 1, ty - 2, BUT[3]) c:put(px + 2, ty - 2, BUT[2])
c:put(px - 1, ty - 1, BUT[2]) c:put(px, ty - 1, BUT[2]) c:put(px + 1, ty - 1, BUT[1]) c:put(px + 2, ty - 1, BUT[1])
c:put(px - 1, ty - 3, BUT[3]) c:put(px, ty - 3, BUT[4]) c:put(px + 1, ty - 3, BUT[3])

-- syrup jug (glass, amber syrup)
local jx = 45
local function jh(y)
  if y < 21 then return -1 end
  if y <= 25 then return 1.6 end
  if y <= 29 then return 1.6 + (y - 25) * 1.05 end
  if y <= 35 then return 5.8 end
  local q = 1 - ((y - 35) / 3.2)^2 return q > 0 and 5.8 * sqrt(q) + 0.3 or -1
end
-- handle loop (behind body)
local hm = A.pmask(jx + 3, 24, jx + 10, 36, function(x, y) local d = sqrt(((x - jx - 5.2) * 1.1)^2 + ((y - 30) * 0.7)^2) return d <= 3.6 and d >= 2 and x > jx + 4 end)
local hn = {}
hm:each(function(x, y) local dx, dy = x - jx - 5.2, (y - 30) * 0.7 local d = sqrt(dx*dx + dy*dy) local s = (d - 2.8) hn[K(x, y)] = { norm(dx / d * s, dy / d * s, 1) } end)
A.shade(c, hm, hn, { "#5a2a12", "#8c4416", "#b8661e", "#e09636", "#f8c262", "#ffe6a8" }, { amb = 0.15, wrap = 0.3 })
local jug = A.pmask(jx - 7, 19, jx + 7, 39, function(x, y) local h = jh(y) return h > 0 and abs(x - jx) <= h end)
local jb = {}
jug:each(function(x, y) if y >= 38 then jb[K(x, y)] = -1 end end)
local jidx = A.vcyl(c, jug, SYR, jx - 6, jx + 6, { amb = 0.12, wrap = 0.3, bias = jb })
-- glass: bright rim (left), pale core streak, cool rim right
jug:edge():each(function(x, y) if x < jx and y > 22 then c:put(x, y, "#ffe0a0") elseif x > jx and y > 26 then c:put(x, y, "#b85a3a") end end)
for y = 28, 35 do c:put(jx - 3, y, y < 30 and SPEC or "#ffd890") end
c:put(jx - 1, 23, "#ffe0a0")
-- label with a tiny maple mark
for y = 31, 33 do for x = jx - 1, jx + 4 do if jug:has(x, y) then c:put(x, y, (x >= jx + 3) and "#d8c6a6" or "#f4e6c8") end end end
c:put(jx + 1, 31, LEAF[3]) c:put(jx, 32, LEAF[3]) c:put(jx + 1, 32, LEAF[4]) c:put(jx + 2, 32, LEAF[3]) c:put(jx + 1, 33, LEAF[2])
-- cork
local ck = c:rect(jx - 1, 18, jx + 1, 20)
A.vcyl(c, ck, WOOD, jx - 1, jx + 1, { amb = 0.2, wrap = 0.4, cuts = { 0.15, 0.3, 0.5, 0.7, 0.9 } })
c:put(jx - 1, 18, WOOD[6]) c:put(jx, 18, WOOD[5])
-- jug + stack contact shadow on the table top
for x = jx - 5, jx + 6 do if top:has(x, 39) and not jug:has(x, 39) then c:put(x, 39, WOOD[max(1, (tidx[K(x, 39)] or 3) - 2)]) end end

-- quirk: a red maple leaf on the table corner
local leaf = {
  "...a...",
  ".a.bb.a",
  ".bbbcbb",
  "abbccbb",
  ".bccdd.",
  "..bdd..",
  "...s...",
}
local LP = { a = LEAF[4], b = LEAF[3], c = LEAF[4], d = LEAF[2], s = "#5a2a1a" }
leaf = { "..a....", "..ab..a", "aabbcbb", ".bbccb.", "abccddd", "..bdd..", "..s...." }
A.map(c, leaf, 9, 36, LP)
c:put(11, 37, LEAF[5])
A.save(c, "feast-maplewold-table")
