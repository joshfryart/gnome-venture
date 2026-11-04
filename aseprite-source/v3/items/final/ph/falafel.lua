-- falafel (final, Opus single pass). Three crunchy falafel balls threaded on a slim wooden skewer on the diagonal,
-- with air between them so the skewer shows. Balls: lumpy crust silhouette, per-pixel sphere light on a 6-tone
-- golden-brown ramp, crumb texture (dark pits + toasted flecks), sesame seeds, one specular each, cool reflected rim.
-- Skewer: grain lines, pale cut end, sharp tip, AO where it enters each ball. A tahini drizzle zig-zags over the
-- middle ball and drips once. Draft by Sonnet replaced.
-- quirk: the top ball has a bite out of it, showing the bright green herb inside.
local NAME = "falafel"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)

local CRUST = { "#3a1a14", "#5c2a16", "#86441c", "#b06a26", "#d4943a", "#edc068" }
local WOOD  = { "#5a3424", "#8a5a36", "#b98a56", "#e2bd82" }
local HERB  = { "#2c5220", "#467e2c", "#6fa83c", "#a3d066" }
local TAH   = { "#c9b088", "#ecdcb6", "#fbf2da" }
local SES, COOL, SPEC = "#f6e6b8", "#6e5a7a", "#fff2c8"

-- skewer from lower-left handle to upper-right tip
local skm, skn, SKT, SKS = A.tube({ { 10, 56 }, { 24, 42 }, { 40, 26 }, { 55, 11 } }, function(t)
  if t > 0.94 then return 1.2 * (1 - t) / 0.06 + 0.2 end return 1.2 end)
local balls = {
  { 21, 45, 6.6, seed = 1 },
  { 33, 33, 6.8, seed = 2 },
  { 45, 21, 6.4, seed = 3 },
}
local bm = HP.mask()
for _, b in ipairs(balls) do
  local m = HP.mask()
  for y = floor(b[2] - b[3] - 2), floor(b[2] + b[3] + 2) do for x = floor(b[1] - b[3] - 2), floor(b[1] + b[3] + 2) do
    local dx, dy = x - b[1], y - b[2]
    local a = atan(dy, dx)
    local r = b[3] + 0.45 * sin(a * 5 + b.seed * 1.7) + 0.35 * sin(a * 9 + b.seed)
    if dx * dx + dy * dy <= r * r then m:set(x, y) end
  end end
  b.m = m bm:add(m)
end
-- bite out of the top ball (upper-right): scalloped tooth arcs
local bite = HP.mask()
for _, q in ipairs{ { 50.5, 16.5, 3.4 }, { 48.2, 14.6, 2.3 }, { 52.2, 19.6, 2.3 } } do bite:add(c:ellipse(q[1], q[2], q[3], q[3])) end
balls[3].m:cut(bite) bm:cut(bite)

-- skewer (under balls)
local wtok = { r = { name = "skewer" } }
local skVis = skm:copy():cut(bm)
local skb = {}
X.ao(skb, skVis, bm, 2, -1)
local widx = A.shade(c, skVis, skn, WOOD, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = wtok, bias = skb })
skVis:each(function(x, y) local k = K(x, y)
  if abs(SKS[k]) < 0.25 and (x * 3 + y) % 7 < 3 and not skb[k] then c:put(x, y, WOOD[max(1, widx[k] - 1)], wtok) end end)
-- pale cut end at the handle
c:put(10, 56, WOOD[4]) c:put(9, 56, WOOD[3]) c:put(10, 57, WOOD[3]) c:put(9, 57, WOOD[2])

-- balls
for i, b in ipairs(balls) do
  local tok = { r = { name = "ball" .. i } }
  local n = A.body(b.m, b[1] - 0.3, b[2] - 0.3, b[3], 3, 0.75)
  local bias = {}
  if i < 3 then X.ao(bias, b.m, balls[i + 1].m:grow(1), 1, -1) end
  local idx, v = A.shade(c, b.m, n, CRUST, { amb = 0.06, wrap = 0.22, bias = bias, tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
  -- crumb texture: dark pits and toasted flecks, kept off the outer edge
  b.m:shrink(1):each(function(x, y) local k = K(x, y)
    local h = X.hash(x, y, 13 + i)
    if h > 0.84 then c:put(x, y, CRUST[max(1, idx[k] - 2)], tok)
    elseif h < 0.1 and idx[k] >= 3 then c:put(x, y, CRUST[min(6, idx[k] + 1)], tok) end
  end)
  -- cool bounce on the lower-right rim
  local rim = X.rim(n)
  b.m:edge():each(function(x, y) if rim[K(x, y)] > 0.72 then c:put(x, y, COOL, tok) end end)
  -- sesame seeds (2x1 / 1x2 cream grains with a shade pixel)
  for j, q in ipairs{ { -3, -2, 1 }, { 1, -4, 0 }, { 2, 1, 1 }, { -2, 2, 0 } } do
    local sx, sy = b[1] + q[1] + (i % 2), b[2] + q[2]
    if b.m:shrink(1):has(sx, sy) and b.m:shrink(1):has(sx + q[3], sy + 1 - q[3]) then
      c:put(sx, sy, SES, tok) c:put(sx + q[3], sy + 1 - q[3], j % 2 == 0 and TAH[1] or SES, tok)
    end
  end
  -- one specular
  c:put(b[1] - 3, b[2] - 4, SPEC, tok) c:put(b[1] - 2, b[2] - 4, CRUST[6], tok)
end

-- bite: green herb crumb inside a crust ring, tooth scallops
local B = balls[3]
local tokH = { r = { name = "herb" } }
local herb = B.m:copy()
B.m:each(function(x, y)
  local inside = false
  for _, d in ipairs{ { 1, 0 }, { 0, -1 }, { 1, -1 }, { 2, 0 }, { 0, -2 }, { 2, -1 }, { 1, -2 } } do
    if bite:has(x + d[1], y + d[2]) then inside = true end
  end
  if not inside then herb.s[K(x, y)] = nil end
end)
herb:each(function(x, y)
  local edge = false
  for _, d in ipairs{ { 1, 0 }, { 0, -1 } } do if bite:has(x + d[1], y + d[2]) then edge = true end end
  local i = 3
  if edge then i = 4 end
  local h = X.hash(x, y, 21)
  if h > 0.78 then i = 2 elseif h < 0.12 then i = 4 end
  if not edge and (x + y) % 5 == 0 then i = 1 end
  c:put(x, y, HERB[i], tokH)
end)
-- crust lip around the bite (dark)
B.m:each(function(x, y) if not herb:has(x, y) then
  for _, d in ipairs{ { 1, 0 }, { 0, -1 }, { 1, -1 } } do
    if herb:has(x + d[1], y + d[2]) then c:put(x, y, CRUST[2]) return end end end end)

-- tahini drizzle zig-zag over the middle ball, one drip
local tt = { r = { name = "tahini" } }
local zig = { { 27, 30 }, { 30, 27 }, { 32, 31 }, { 35, 27 }, { 37, 31 }, { 39, 29 } }
local M = balls[2].m:shrink(1)
for i = 1, #zig - 1 do
  local a, b = zig[i], zig[i + 1]
  local n = max(abs(b[1] - a[1]), abs(b[2] - a[2]))
  for s = 0, n do
    local x = floor(a[1] + (b[1] - a[1]) * s / n + 0.5)
    local y = floor(a[2] + (b[2] - a[2]) * s / n + 0.5)
    if M:has(x, y) then c:put(x, y, TAH[2], tt) if M:has(x, y + 1) then c:put(x, y + 1, TAH[1], tt) end end
  end
end
c:put(29, 28, TAH[3]) c:put(34, 28, TAH[3])
for y = 32, 35 do c:put(32, y, TAH[2], tt) end
c:put(33, 32, TAH[1]) c:put(33, 34, TAH[1]) c:put(32, 36, TAH[1]) c:put(31, 36, TAH[2]) c:put(32, 37, TAH[1]) c:put(31, 33, TAH[3])
A.save(c, NAME)
