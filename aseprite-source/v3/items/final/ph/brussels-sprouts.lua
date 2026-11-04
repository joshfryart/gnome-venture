-- brussels-sprouts (final, Opus aB13_1 single pass). A slim cut length of brussels stalk on the diagonal, four tight
-- sprouts set alternately up it (smaller toward the crown), each wrapped in cupped leaves (fan seams with a lit lip,
-- veins from the base, waxy bloom, cool bounce on the shade side), AO + contact shadow where sprouts meet the stalk,
-- a pale ringed end grain at the cut foot and a two-leaf crown on top.
-- quirk: the lowest sprout is shedding its outer leaf, which flops loose off its base.
local NAME = "brussels-sprouts"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB13_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local c = A.new(NAME)

local SP = { "#173f33", "#245a3a", "#367a3e", "#55a047", "#86c55a", "#bfe283" }
local STALK = { "#1d3d34", "#2f5e45", "#4f8a55", "#78ac66", "#a6cc84", "#d4e8a8" }
local CROWN = { "#163a3a", "#1f5446", "#2d7050", "#468f5c", "#6cb06a", "#a2d48a" }
local BLOOM, COOL = "#a9d6a8", "#3e7d6e"
local ENDG = { "#9dbf78", "#c4dc98", "#e6f0c4" }

-- stalk
local SPTS = { { 26, 57 }, { 28, 44 }, { 33, 29 }, { 37, 16 } }
local stm, stn, ST, SS = A.tube(SPTS, function(t) return 2.3 - 0.6 * t end)

-- sprouts: t on stalk, side (+1 right / -1 left), radius
local defs = { { 0.24, -1, 5.8 }, { 0.43, 1, 5.6 }, { 0.62, -1, 5.0 }, { 0.80, 1, 4.4 } }
local spr = {}
for i, d in ipairs(defs) do
  local bx, by = A.bez(SPTS, d[1])
  local bx2, by2 = A.bez(SPTS, d[1] + 0.01)
  local tx, ty = bx2 - bx, by2 - by local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
  local px, py = -ty * d[2], tx * d[2]             -- outward from stalk
  -- tilt the sprout axis upward a little (sprouts point up the stalk)
  local ux, uy = px * 0.9 + tx * 0.4, py * 0.9 + ty * 0.4
  -- stalk runs up (ty<0), so tx,ty points up the stalk already when t increases
  local ul = sqrt(ux * ux + uy * uy) ux, uy = ux / ul, uy / ul
  local r = d[3]
  local cx, cy = bx + ux * (r + 1.2), by + uy * (r + 1.2)
  local ang = math.atan(uy, ux)
  local m, n = A.oval(cx, cy, r, r * 0.9, ang, 0.9)
  spr[i] = { m = m, n = n, cx = cx, cy = cy, r = r, ux = ux, uy = uy, bx = bx, by = by }
end

-- quirk leaf (drawn first, under the lowest sprout)
local q = spr[1]
local qtok = { r = { name = "looseleaf" } }
local qm = A.leaf(c, q.bx - 1, q.by + 1, q.bx - 9, q.by + 6, q.bx - 13, q.by + 1, 3.0, SP, { tok = qtok, fold = 0.5, vs = 2.6 })

-- stalk paint with AO from sprouts
local sb = {}
for _, s in ipairs(spr) do X.ao(sb, stm, s.m, 1, -1) A.cast(sb, stm, s.m, 1, 1, -1) end
local sidx = A.shade(c, stm, stn, STALK, { amb = 0.14, wrap = 0.3, bias = sb, tok = { r = { name = "stalk" } } })
-- fibre lines along the stalk on the lit half
stm:each(function(x, y) local k = K(x, y)
  if not sb[k] and SS[k] < -0.2 and SS[k] > -0.5 and ST[k] > 0.08 and (floor(ST[k] * 40) % 5 ~= 0) then c:put(x, y, STALK[min(6, (sidx[k] or 3) + 1)]) end end)
-- cut end grain at the foot: pale ringed ellipse
do
  local em = HP.mask()
  for y = 55, 59 do for x = 23, 29 do
    if ((x - 26) / 2.7) ^ 2 + ((y - 57.0) / 1.5) ^ 2 <= 1 then em:set(x, y) end end end
  em:each(function(x, y)
    local d = ((x - 26.2) / 2.7) ^ 2 + ((y - 57.0) / 1.5) ^ 2
    c:put(x, y, d > 0.62 and ENDG[2] or (d > 0.2 and ENDG[3] or ENDG[1]))
  end)
  c:put(24, 57, ENDG[3])
end

-- crown leaves at the top
local ctok = { r = { name = "crown" } }
local tx0, ty0 = A.bez(SPTS, 1)
local cm1 = A.leaf(c, tx0, ty0 + 1, tx0 - 6, ty0 - 3, tx0 - 11, ty0 - 2, 2.8, CROWN, { tok = ctok, vs = 2.6 })
local cm2 = A.leaf(c, tx0, ty0 + 1, tx0 + 4, ty0 - 5, tx0 + 9, ty0 - 6, 2.6, CROWN, { tok = ctok, vs = 2.6, cut = cm1 })

-- sprouts, back to front (lower sprouts overlap upper ones? keep order: top first so lower ones sit in front)
for i = #spr, 1, -1 do
  local s = spr[i]
  local tok = { r = { name = "sprout" .. i } }
  local bias = {}
  for j = i - 1, 1, -1 do X.ao(bias, s.m, spr[j].m, 1, -1) A.cast(bias, s.m, spr[j].m, 1, 1, -1) end
  local vis = s.m:copy()
  for j = i - 1, 1, -1 do vis:cut(spr[j].m) end
  -- base AO where the sprout joins the stalk
  vis:each(function(x, y) local k = K(x, y)
    local du = (x - s.cx) * s.ux + (y - s.cy) * s.uy
    if du < -s.r * 0.72 then bias[k] = (bias[k] or 0) - 1 end end)
  local n = A.body(s.m, s.cx, s.cy, s.r, 3, 0.65)
  local idx = A.shade(c, vis, n, SP, { amb = 0.08, wrap = 0.25, bias = bias, tok = tok })
  -- wrapper-leaf seams: fan curves from the base toward the tip, with a lit lip on the overlapping edge
  local vx, vy = -s.uy, s.ux
  for _, o in ipairs{ -0.62, 0.05, 0.6 } do
    for st = 0, 40 do
      local u = -0.85 + st / 40 * 1.55
      local f = (u + 1) / 2
      local v = o * (0.3 + 0.7 * sqrt(f)) + 0.12 * sin(f * pi)
      local x = floor(s.cx + s.ux * u * s.r + vx * v * s.r + 0.5)
      local y = floor(s.cy + s.uy * u * s.r + vy * v * s.r + 0.5)
      if vis:has(x, y) and not bias[K(x, y)] then
        local k = K(x, y)
        local i0 = idx[k] or 3
        c:put(x, y, SP[max(1, i0 - 3)], tok)
        -- lip: the pixel on the lit side (toward upper-left) gets a brighter edge
        local lx, ly = x - 1, y
        if vis:has(lx, ly) and idx[K(lx, ly)] and idx[K(lx, ly)] >= 3 then c:put(lx, ly, SP[min(6, idx[K(lx, ly)] + 1)], tok) end
      end
    end
  end
  -- fine veins: short pale ticks from the base on the lit half
  for _, vv in ipairs{ -0.35, 0.32 } do
    for st = 0, 6 do
      local u = -0.75 + st * 0.07
      local x = floor(s.cx + s.ux * u * s.r + vx * vv * s.r * (0.5 + st * 0.07) + 0.5)
      local y = floor(s.cy + s.uy * u * s.r + vy * vv * s.r * (0.5 + st * 0.07) + 0.5)
      local k = K(x, y)
      if vis:has(x, y) and idx[k] and idx[k] >= 3 and not bias[k] then c:put(x, y, SP[min(6, idx[k] + 1)], tok) end
    end
  end
  -- waxy bloom: a few cool pale pixels on the lit shoulder
  local edge = vis:edge()
  vis:each(function(x, y) local k = K(x, y)
    if idx[k] == 5 and X.hash(x, y, i) > 0.72 then c:put(x, y, BLOOM, tok) end
    if edge:has(x, y) and n[k] and n[k][1] + n[k][2] > 0.9 and not bias[k] then c:put(x, y, COOL, tok) end
  end)
  -- specular
  local sx, sy = A.specAt(vis, n, 40)
  if sx then c:put(sx, sy, SP[6], tok) c:put(sx + 1, sy, SP[6], tok) end
  if i == 2 and sx then c:put(sx, sy, A.CREAM, tok) end
end

A.save(c, NAME)
