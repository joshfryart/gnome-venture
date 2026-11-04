-- cosmos-seed (ph, Opus single pass): slim, slightly curved black-brown cosmos achenes (lit lengthwise ridge, dark
-- groove, paler blunt foot, a beak tip with two barbed golden awns) on a torn scrap of ferny cosmos leaf (a rachis with
-- thread-thin alternate pinnae, the torn end snapped short). The right seed has germinated: a pale stem, two long
-- strap cotyledons and a first feathery true leaf of thread lobes - the cosmos frond in miniature.
-- quirk: one seed has hooked its barbed awns over the leaf edge and dangles below it, like a burr on a sock.
local NAME = "cosmos-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB22_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new(NAME)
local LEAF = { "#173e2e", "#225c38", "#307e40", "#4aa048", "#76c058", "#ace078" }
local SEED = { "#1c1218", "#31202a", "#4b322f", "#6a4637", "#8e6446", "#b88c62" }
local AWN = { "#6e4a24", "#b0843a", "#e2bc66" }
local STEM = { "#4a8250", "#82b468", "#b6d88c", "#e0f0b8" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local ltok = { r = { name = "leaf" } }

-- leaf scrap: rachis + alternate thread pinnae
local ra = { 8, 49, 30, 49, 54, 41 }
local function rq(t) local u = 1 - t
  return u*u*ra[1] + 2*u*t*ra[3] + t*t*ra[5], u*u*ra[2] + 2*u*t*ra[4] + t*t*ra[6] end
local leaf, ln = HP.mask(), {}
local rm, rn = G.blade(ra[1], ra[2], ra[3], ra[4], ra[5], ra[6], function(t) if t > 0.97 then return -1 end return 1.0 - 0.35 * t end, { fold = 0.2 })
leaf:add(rm) for k, v in pairs(rn) do ln[k] = v end
local pinnae = {}
local NP = 9
for i = 1, NP do
  local t = (i - 0.4) / (NP + 0.3)
  local side = (i % 2 == 0) and 1 or -1
  local x, y = rq(t)
  local x2, y2 = rq(min(1, t + 0.01))
  local tx, ty = x2 - x, y2 - y local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
  local ang = side * 0.95
  local ux, uy = G.rot(tx, ty, ang)
  local L = (9.5 - 5.0 * t) * (i == 1 and 0.35 or 1)      -- first pinna snapped at the tear
  -- slight curl toward the tip: two straight segments
  local mx, my = x + ux * L * 0.55, y + uy * L * 0.55
  local vx, vy = G.rot(ux, uy, -side * 0.35)
  local ex, ey = mx + vx * L * 0.5, my + vy * L * 0.5
  for _, seg in ipairs{ { x, y, mx, my, 0.85 }, { mx, my, ex, ey, 0.6 } } do
    local m, n = X.cyl(seg[1], seg[2], seg[3], seg[4], function(tt) return seg[5] + 0.3 - 0.25 * tt end)
    m:add(c:ellipse(seg[3], seg[4], 0.4, 0.4))
    m:each(function(px, py) local k = K(px, py) if not leaf:has(px, py) then leaf:set(px, py) ln[k] = n[k] or { 0, 0, 1 } end end)
  end
  pinnae[#pinnae + 1] = { x = ex, y = ey }
end
-- tiny secondary threadlets off the longer pinnae
for i = 2, 6 do local p = pinnae[i] local s = (i % 2 == 0) and 1 or -1
  local x, y = floor(p.x + .5), floor(p.y + .5)
end

-- seeds (curved needles). beak at t=1 unless flipped
local seeds = {
  { { 11, 52 }, { 15, 49 }, { 20, 46 }, { 25, 44 } },
  { { 13, 43 }, { 17, 41 }, { 21, 40 }, { 26, 40 } },
  { { 47, 42 }, { 43, 44 }, { 38, 45 }, { 34, 46 } },          -- sprouting: foot at t=0 (47,42)
  { { 31, 59 }, { 31, 56 }, { 30, 53 }, { 30, 49 } },          -- quirk: dangling, beak up at the leaf edge
}
local function sw(t) return max(0.35, 1.45 * sin(pi * (0.18 + 0.82 * t)) ^ 0.6 - 0.15 * t) end
for _, s in ipairs(seeds) do s.m, s.n, s.T, s.S = G.tube(s, sw) end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, leaf, s.m, 1, -1) G.cast(bias, leaf, s.m, 1, 2, -1) end
G.toneN(c, leaf, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.28, 0.44, 0.6, 0.8 }, amb = 0.18, wrap = 0.3 })
-- rachis groove: lit top line
rm:each(function(x, y) local k = K(x, y) if not bias[k] and not rm:has(x, y - 1) then c:put(x, y, LEAF[6], ltok) end end)
-- snapped torn end: pale broken pith
c:put(8, 49, LEAF[6], ltok) c:put(8, 48, LEAF[5], ltok) c:put(8, 50, LEAF[2], ltok)

-- sprout from the foot of seed 3
local stok = { r = { name = "stem" } }
local sp = { { 47, 41 }, { 48, 35 }, { 47, 29 }, { 47, 23 } }
local sm, sn = G.tube(sp, function(t) return 1.0 end)
sm:cut(seeds[3].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function strap(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * min(1, t * 6) * (1 - 0.35 * t))
  end, { fold = 0.3 })
  m:cut(sm)
  G.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.16, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.12 and T[k] < 0.85 then
    c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
local cl = strap(46, 25, 41, 23, 35, 18, 1.6)
local cr = strap(48, 25, 53, 23, 58, 17, 1.6)
-- feathery true leaf: rachis up, three pairs of thread lobes + a terminal thread
local tok2 = { r = { name = "trueleaf" } }
local tlm = HP.mask()
local tpts = { { 47, 23 }, { 47, 19 }, { 46, 15 }, { 46, 11 } }
for i = 0, 24 do local x, y = G.bez(tpts, i / 24) tlm:set(floor(x + .5), floor(y + .5)) end
for _, q in ipairs{ { 0.3, -1, 4 }, { 0.38, 1, 4 }, { 0.58, -1, 3 }, { 0.66, 1, 3 }, { 0.84, -1, 2 }, { 0.88, 1, 2 } } do
  local x, y = G.bez(tpts, q[1])
  for r = 1, q[3] do
    tlm:set(floor(x + q[2] * r + .5), floor(y - r * 0.75 - 0.2 + .5))
  end
end
tlm:cut(cl):cut(cr)
tlm:each(function(x, y)
  local col = LEAF[4]
  if not tlm:has(x, y - 1) and not tlm:has(x - 1, y) then col = LEAF[5] end
  if x > 47 then col = LEAF[3] end
  c:put(x, y, col, tok2)
end)
c:put(46, 10, LEAF[6], tok2)

-- seeds last
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  if i == 3 then vis:cut(sm) end
  local tok = { r = { name = "seed" .. i } }
  local v = X.light(s.n, { amb = 0.1, wrap = 0.25 })
  local idx = X.tone(c, vis, v, SEED, { cuts = { 0.16, 0.3, 0.46, 0.64, 0.84 }, bias = sb, tok = tok })
  vis:each(function(x, y) local k = K(x, y) local S, T = s.S[k], s.T[k]
    if S > -0.55 and S < -0.15 and T > 0.15 and T < 0.85 then c:put(x, y, SEED[min(6, (idx[k] or 3) + 1)], tok) end  -- ridge
    if S > 0.1 and S < 0.4 and T > 0.12 and T < 0.9 then c:put(x, y, SEED[max(1, (idx[k] or 3) - 1)], tok) end      -- groove
    if T < 0.1 then c:put(x, y, SEED[max(3, min(5, (idx[k] or 3) + 1))], tok) end                                     -- paler foot
  end)
  -- awns at the beak (t = 1): two barbed golden prongs
  local bx, by = G.bez(s, 1)
  local x2, y2 = G.bez(s, 0.97)
  local tx, ty = bx - x2, by - y2 local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
  for _, a in ipairs{ -0.45, 0.45 } do
    local ux, uy = G.rot(tx, ty, a)
    local lx, ly
    for r = 1, 4 do
      local x, y = floor(bx + ux * r + .5), floor(by + uy * r + .5)
      if not s.m:has(x, y) then c:put(x, y, AWN[r == 1 and 1 or (r == 4 and 3 or 2)], tok) lx, ly = x, y end
    end
    -- barb: one px hooked back at the tip
    if lx then local bx2, by2 = G.rot(-ux, -uy, a > 0 and 0.9 or -0.9)
      c:put(floor(lx + bx2 + .5), floor(ly + by2 + .5), AWN[2], tok) end
  end
  local gx, gy = G.specAt(vis, s.n, 40)
  if gx then c:put(gx, gy, SEED[6], tok) end
end
-- quirk: the dangling seed's awns grip over the leaf edge - re-darken the leaf just under its hook
c:put(31, 47, LEAF[2], ltok)

G.saveTo(c, "ph", NAME)
