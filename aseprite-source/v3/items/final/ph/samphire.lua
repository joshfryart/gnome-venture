-- samphire (final, single pass). A slim fan of six jointed sea-asparagus stems rising from a low mound of wet salt mud.
-- Each stem is a chain of swollen, glassy segments pinched at the nodes (dark node band, opposite branchlets that
-- fork upward), tips fading to pale lime. Back stems are shaded by the ones in front.
-- Material: cylinder light on a 6-tone green ramp (lit ridge, cool shade), node scale marks, wet mud with specular
-- ripples, pebbles, AO where stems meet the mud.
-- quirk: a tiny spiral periwinkle shell rests on the mud at the foot of the bunch.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD14_1.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("samphire")
local hash = A.hash

local GREEN = { "#10352d", "#1b5636", "#2a783e", "#43a042", "#6fc44e", "#a8e072" }
local TIP   = { "#3f7a36", "#6aa83e", "#94c84e", "#bfe16c", "#dcf08c", "#f0fab0" }
local MUD   = { "#2a2228", "#40343a", "#5c4a49", "#7a655d", "#9c8678", "#c2ad9a" }
local STN   = { "#4a4e6a", "#6e728c", "#9496ac", "#bdbdca", "#e0dfe6", "#f4f2f2" }
local SHL   = { "#4e2e34", "#7c4a46", "#b06c58", "#d8946e", "#f0b88a", "#ffe0b8" }
local mtok = { r = { name = "mud" } }

c:groundShadow(32, 57, 18, 2)
-- mud mound
local mud = c:ellipse(32, 54, 19, 5.2)
mud:add(c:ellipse(32, 52, 13, 3.4))
local mb = {}
local mn = A.ellN(mud, 31, 51, 20, 7, 1.0)
local midx = A.shade(c, mud, mn, MUD, { tok = mtok, amb = 0.1, wrap = 0.28, bias = mb })
mud:each(function(x, y) local k = K(x, y)
  local r = hash(x, y, 9)
  if r < 0.12 then c:put(x, y, MUD[max(1, midx[k] - 1)], mtok) elseif r > 0.93 then c:put(x, y, MUD[min(6, midx[k] + 1)], mtok) end
end)
-- wet ripples: short pale specular streaks along the mud
for _, q in ipairs{ { 17, 55, 3 }, { 40, 56, 3 }, { 46, 53, 2 }, { 22, 58, 2 } } do
  for i = 0, q[3] - 1 do if mud:has(q[1] + i, q[2]) then c:put(q[1] + i, q[2], MUD[6], mtok) end end
end
mud:edge():each(function(x, y) if y > 54 then c:put(x, y, MUD[2], mtok) end end)

-- stems: base, ctrl1, ctrl2, tip. Back to front.
local stems = {
  { p = { { 28, 53 }, { 25, 41 }, { 20, 29 }, { 21, 15 } }, w = 1.55, br = { 0.66 } },
  { p = { { 36, 53 }, { 39, 42 }, { 42, 30 }, { 44, 16 } }, w = 1.55, br = { 0.68 } },
  { p = { { 31, 53 }, { 30, 40 }, { 31, 26 }, { 32, 8 } }, w = 1.6, br = { 0.46, 0.72 } },
  { p = { { 24, 54 }, { 19, 46 }, { 15, 38 }, { 13, 28 } }, w = 1.5, br = { 0.62 } },
  { p = { { 40, 54 }, { 45, 46 }, { 49, 38 }, { 51, 28 } }, w = 1.5, br = { 0.62 } },
  { p = { { 33, 55 }, { 28, 47 }, { 25, 40 }, { 24, 32 } }, w = 1.45, br = { 0.6 } },
}
-- build every mask first (branchlets included) so back stems can be shaded by front ones
local parts = {}
local function addPart(p, w, seg, off, depth)
  local m, n, T, S, sm, L = A.segtube(p, w, seg, 0.64, { off = off })
  parts[#parts + 1] = { m = m, n = n, T = T, S = S, sm = sm, L = L, w = w, seg = seg, off = off, depth = depth, p = p }
  return sm
end
for si, s in ipairs(stems) do
  local sm = addPart(s.p, s.w, 4.6, 0.5, si)
  for bi, t in ipairs(s.br) do
    local best, bs = 1e9
    for _, q in ipairs(sm) do local d = abs(q.t - t) if d < best then best, bs = d, q end end
    for side = -1, 1, 2 do
      local ang = side * (0.62 + 0.1 * bi)
      local ux, uy = bs.tx * cos(ang) - bs.ty * sin(ang), bs.tx * sin(ang) + bs.ty * cos(ang)
      local Lb = 8.5 - bi * 1.3
      local x0, y0 = bs.x, bs.y
      local p = { { x0, y0 }, { x0 + ux * Lb * 0.35, y0 + uy * Lb * 0.35 }, { x0 + ux * Lb * 0.7 + side * 0.4, y0 + uy * Lb * 0.7 - 1 }, { x0 + ux * Lb + side * 0.8, y0 + uy * Lb - 2.5 } }
      addPart(p, 1.0, 3.6, 0.5, si + 0.5 + (side > 0 and 0.1 or 0))
    end
  end
end
table.sort(parts, function(a, b) return a.depth < b.depth end)
for i, pt in ipairs(parts) do
  local bias = {}
  for j = i + 1, #parts do
    local o = parts[j]
    if abs(o.depth - pt.depth) >= 0.45 or true then X.ao(bias, pt.m, o.m, 1, -2) end
  end
  X.ao(bias, pt.m, c:rect(0, 51, 63, 56), 1, -1)
  local tok = { r = { name = "stem" .. i } }
  local v = X.light(pt.n, { amb = 0.12, wrap = 0.3 })
  local idx = X.tone(c, pt.m, v, GREEN, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = bias, tok = tok })
  -- tips fade to lime
  pt.m:each(function(x, y) local k = K(x, y)
    if pt.T[k] > 0.84 then c:put(x, y, TIP[min(6, max(1, idx[k] + 1))], tok) end
  end)
  -- node bands (scale joints)
  A.joints(c, pt.sm, pt.L, pt.seg, pt.w, GREEN[1], tok, pt.off)
  -- lit nodes: bright dot on the lit side of each segment middle
  local nj = floor(pt.L / pt.seg)
  for j = 0, nj do
    local tt = (j - pt.off + 0.5) * pt.seg / pt.L
    if tt > 0.1 and tt < 0.85 and pt.w > 1.2 then
      local best, bs = 1e9
      for _, q in ipairs(pt.sm) do local d = abs(q.t - tt) if d < best then best, bs = d, q end end
      local x, y = floor(bs.x - bs.px * pt.w * 0.45 + 0.5), floor(bs.y - bs.py * pt.w * 0.45 + 0.5)
      if pt.m:has(x, y) and not bias[K(x, y)] then c:put(x, y, GREEN[6], tok) end
    end
  end
end
-- foreground mud grips the stem feet
local fm = c:ellipse(32, 54.5, 11, 3.2)
local fb = {}
local fn = A.ellN(fm, 31, 52, 12, 5, 1.0)
local fidx = A.shade(c, fm, fn, MUD, { tok = mtok, amb = 0.1, wrap = 0.28 })
fm:each(function(x, y) local k = K(x, y) local r = hash(x, y, 4)
  if r < 0.12 then c:put(x, y, MUD[max(1, fidx[k] - 1)], mtok) elseif r > 0.94 then c:put(x, y, MUD[6], mtok) end end)
fm:edge():each(function(x, y) if y < 54 then c:put(x, y, MUD[2], mtok) end end)
-- pebbles
local function pebble(cx, cy, rx, ry)
  local m = c:ellipse(cx, cy, rx, ry)
  local n = A.ellN(m, cx - 0.4, cy - 0.4, rx, ry, 1.0)
  A.shade(c, m, n, STN, { tok = { r = { name = "peb" } }, amb = 0.1, wrap = 0.25 })
end
pebble(45, 56, 2, 1.2) pebble(18, 56, 1.4, 1)
-- quirk: periwinkle shell
local sh = c:ellipse(23, 56, 2.6, 2.1)
local shn = A.ellN(sh, 22.4, 55.4, 2.6, 2.1, 1.0)
local sidx = A.shade(c, sh, shn, SHL, { tok = { r = { name = "shell" } }, amb = 0.1, wrap = 0.25 })
for _, q in ipairs{ { 22, 55, 3 }, { 23, 55, 2 }, { 24, 56, 2 }, { 23, 57, 2 } } do c:put(q[1], q[2], SHL[q[3]], { r = { name = "shell" } }) end
c:put(21, 55, SHL[6], { r = { name = "shell" } })
A.save(c, "samphire")
