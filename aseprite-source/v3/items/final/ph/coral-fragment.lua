-- coral-fragment (final pass, Opus single pass). A snapped-off sprig of branching staghorn coral: slim tapering
-- tubes forking from one trunk (per-pixel cylinder light, 6-tone coral ramp from cool plum shade to peach highs),
-- pale fresh growing tips, a staggered field of corallite pits (dark pit + lit lower lip), AO in each fork, and a
-- flat broken base showing the porous cream skeleton inside.
-- quirk: a tiny violet sea snail has tucked itself into the left fork.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "coral-fragment"
local c = A.new(NAME)
local CO = { "#5a1f3e", "#8f2e4c", "#c94a5c", "#ec6e66", "#ff9c84", "#ffcfae" }
local TIP = { "#c96a72", "#f0a090", "#ffd2b8", "#fff0dc" }
local BONE = { "#9a7a6e", "#d8c0a6", "#f6e8cc" }
local SN = { "#35295f", "#5a459e", "#8a6fd0", "#c9b2f0" }
local tok = { r = { name = "coral" } }

-- branches back to front: {bezier, w0, w1}
local br = {
  { { { 31, 38 }, { 37, 32 }, { 42, 25 }, { 47, 15 } }, 2.4, 1.5 },   -- right
  { { { 41, 27 }, { 46, 27 }, { 50, 25 }, { 53, 22 } }, 1.6, 1.3 },   -- right twig
  { { { 30, 38 }, { 30, 30 }, { 30, 22 }, { 32, 11 } }, 2.5, 1.6 },   -- middle
  { { { 29, 42 }, { 24, 36 }, { 19, 28 }, { 15, 18 } }, 2.6, 1.6 },   -- left
  { { { 20, 31 }, { 16, 32 }, { 13, 31 }, { 11, 28 } }, 1.5, 1.2 },   -- left twig
  { { { 30, 55 }, { 30, 50 }, { 30, 44 }, { 30, 37 } }, 3.3, 2.7 },   -- trunk
}
local all = HP.mask()
local parts = {}
for i, b in ipairs(br) do
  local w0, w1 = b[2], b[3]
  local m, n, T, S = A.tube(b[1], function(t) return w0 + (w1 - w0) * t end)
  parts[i] = { m = m, n = n, T = T, S = S, tip = (i ~= 6) }
end
-- trunk bottom: flat break
parts[6].m:each(function(x, y) if y > 55 then parts[6].m.s[K(x, y)] = nil end end)

local idxAll = {}
for i, p in ipairs(parts) do
  local bias = {}
  -- AO where later (front) parts will sit: pixels of this part right next to later parts darken
  for j = i + 1, #parts do X.ao(bias, p.m, parts[j].m, 1, -1) end
  local vis = p.m:copy()
  local idx = A.shade(c, vis, p.n, CO, { tok = tok, bias = bias, amb = 0.08, wrap = 0.26, cuts = { 0.22, 0.4, 0.56, 0.72, 0.9 } })
  -- pale growing tips
  if p.tip then vis:each(function(x, y) local k = K(x, y)
    if p.T[k] > 0.84 then local i2 = idx[k] or 3
      c:put(x, y, TIP[max(1, min(4, i2 - 2))], tok) idx[k] = 10 end end) end
  for k, v in pairs(idx) do idxAll[k] = v end
  all:add(vis)
end
-- crotch AO: deepen the inner fork pixels (pixels with mask on both left and right within 2 px, below a fork)
-- corallite pits: staggered grid, dark pit + lit lower-right lip, only on interior non-tip pixels
local edge = all:edge()
all:each(function(x, y) local k = K(x, y)
  local i = idxAll[k]
  if i and i < 10 and not edge:has(x, y) and y < 54 then
    if (y % 3 == 0 and x % 4 == (y // 3) % 2 * 2) then
      c:put(x, y, CO[max(1, i - 2)], tok)
      if all:has(x + 1, y + 1) and not edge:has(x + 1, y + 1) and (idxAll[K(x + 1, y + 1)] or 10) < 10 then
        c:put(x + 1, y + 1, CO[min(6, (idxAll[K(x + 1, y + 1)]) + 1)], tok) end
    end
  end
end)
-- specular on the trunk's lit side + one glint on the middle branch
for y = 44, 50 do c:put(28, y, CO[6], tok) end
c:put(29, 27, "#fff1dc", tok) c:put(29, 28, CO[6], tok)
-- cool reflected light along the right edge of the trunk
for y = 44, 53 do if all:has(33, y) and not all:has(34, y) then c:put(33, y, "#a85a8a", tok) end end

-- broken base: porous cream skeleton cross-section
local bt = { r = { name = "break" } }
for x = 27, 33 do
  c:put(x, 55, BONE[(x < 30) and 3 or 2], bt)
  c:put(x, 56, BONE[(x == 27 or x == 33) and 1 or 2], bt)
end
c:put(28, 55, BONE[1], bt) c:put(31, 56, BONE[1], bt) c:put(32, 55, BONE[1], bt) c:put(30, 56, BONE[3], bt)
-- chip: tiny shard knocked off at the break
c:put(36, 56, BONE[2], bt) c:put(37, 56, BONE[1], bt)

-- quirk: small violet sea snail in the left fork
local sx, sy = 19, 29
local snail = {
  ".aab.",
  "acdab",
  "adcdb",
  ".bbbe",
}
local sp = { a = SN[3], b = SN[2], c = SN[4], d = SN[1], e = "#ffd2b8" }
for yy, row in ipairs(snail) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if sp[ch] then c:put(sx + xx - 1, sy + yy - 1, sp[ch], { r = { name = "snail" } }) end end end

A.save(c, NAME)
