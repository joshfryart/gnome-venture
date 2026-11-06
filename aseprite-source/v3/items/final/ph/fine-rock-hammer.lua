-- fine-rock-hammer (aB31_4, Opus single pass). A slim geologist's hammer on the diagonal: forged steel head across
-- the top with a square striking face (flat, polished, bevelled rim) on the left and a long chisel pick curving down
-- to a point on the right; hickory handle with grain, a stacked-leather washer grip and a steel butt cap.
-- Steel: per-pixel cylinder light, bright top bevel, specular streak along the pick, dark underside, AO where the
-- handle enters the eye. quirk: a little red survey ribbon is tied round the neck, its two tails fluttering.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local c = A.new("fine-rock-hammer")
local WOOD    = { "#3e2226", "#5e3328", "#86502f", "#ad713f", "#cf9757", "#ecc386" }
local LEATHER = { "#2f1a22", "#55302a", "#7c4a30", "#a46a3c", "#c98f52", "#e8b878" }
local STEEL   = { "#2b2d46", "#464a6a", "#6a7090", "#959db6", "#c3cadb", "#eef1f7" }
local RIB     = { "#5e1834", "#b52e3f", "#e8493b", "#ff8a5c" }

-- handle first (head paints over its top)
local hp = { { 16, 55 }, { 22, 45 }, { 29, 31 }, { 36, 15 } }
local hm, hn, HT, HS, hs, HL = A.tube(hp, function(t) return 1.75 + 0.25 * (1 - t) end, { flat1 = true })
-- head
local p = { { 26, 10 }, { 35, 13.5 }, { 45, 17 }, { 55, 25 } }
local function hw(t)
  if t < 0.13 then return 3.3 end
  if t < 0.22 then return 3.3 - (t - 0.13) / 0.09 * 1.1 end
  if t < 0.3 then return 2.2 + (t - 0.22) / 0.08 * 0.9 end
  if t < 0.44 then return 3.1 end
  return 0.35 + 2.75 * ((1 - t) / 0.56) ^ 0.9
end
local m, n, T, S, sm, LEN = A.tube(p, hw, { flat0 = true })
hm:cut(m)
local hb = {}
X.ao(hb, hm, m, 2, -1)
local grip, wood, cap = HP.mask(), HP.mask(), HP.mask()
hm:each(function(x, y) local t = HT[K(x, y)]
  if t < 0.05 then cap:set(x, y) elseif t < 0.36 then grip:set(x, y) else wood:set(x, y) end end)
local widx = A.tone(c, wood, hn, WOOD, { bias = hb })
wood:each(function(x, y) local k = K(x, y)
  if abs(HS[k] + 0.1) < 0.28 and floor(HT[k] * HL + 2) % 6 ~= 0 then A.step(c, widx, WOOD, x, y, -1) end
  if abs(HS[k] - 0.55) < 0.2 and floor(HT[k] * HL) % 7 < 3 then A.step(c, widx, WOOD, x, y, -1) end
end)
-- stacked leather washers: 2 px bands with a dark seam between
local gidx = A.tone(c, grip, hn, LEATHER, { bias = hb })
grip:each(function(x, y) local k = K(x, y)
  local u = floor(HT[k] * HL)
  if u % 3 == 0 then A.step(c, gidx, LEATHER, x, y, -2) elseif u % 6 == 1 then A.step(c, gidx, LEATHER, x, y, 1) end
end)
local cidx = A.tone(c, cap, hn, STEEL, { bias = hb })

-- head steel
local b = {}
m:each(function(x, y) local k = K(x, y) if S[k] > 0.75 then b[k] = -1 end end)
local idx = A.tone(c, m, n, STEEL, { bias = b, amb = 0.1, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
local ht = A.tok("head")
m:each(function(x, y) local k = K(x, y)
  local d = (x - sm[1].x) * sm[1].tx + (y - sm[1].y) * sm[1].ty
  if d < 1.3 then
    -- striking face: flat polished end, lit, with a darker bevel rim
    if abs(S[k]) > 0.72 then c:put(x, y, STEEL[3], ht) else c:put(x, y, (S[k] < -0.1) and STEEL[6] or STEEL[5], ht) end
  elseif d < 2.3 then c:put(x, y, STEEL[2], ht)                        -- bevel step behind the face
  elseif S[k] < -0.62 and T[k] > 0.1 then A.step(c, idx, STEEL, x, y, 1, ht) -- bright top edge
  end
  -- eye block seams
  if abs(T[k] - 0.235) < 0.012 or abs(T[k] - 0.445) < 0.012 then A.step(c, idx, STEEL, x, y, -1, ht) end
  -- chisel bevel line along the pick
  if T[k] > 0.62 and abs(S[k] - 0.15) < 0.18 then A.step(c, idx, STEEL, x, y, -1, ht) end
end)
-- specular streak along the pick + one glint
for _, q in ipairs{ { 0.5, -0.45 }, { 0.55, -0.45 }, { 0.6, -0.42 }, { 0.65, -0.4 } } do
  local s = sm[floor(q[1] * 160) + 1]
  c:put(floor(s.x + s.px * s.w * q[2] + .5), floor(s.y + s.py * s.w * q[2] + .5), STEEL[6], ht)
end
do local s = sm[floor(0.52 * 160) + 1] c:put(floor(s.x + s.px * s.w * -0.45 + .5), floor(s.y + s.py * s.w * -0.45 + .5), A.CREAM, ht) end
-- wood top end showing through the eye (end grain + wedge)
c:put(35, 13, WOOD[5], ht) c:put(36, 13, WOOD[6], ht) c:put(36, 14, WOOD[4], ht)

-- quirk: red survey ribbon round the neck under the head, two tails flutter right
local rt = A.tok("ribbon")
local s0 = hs[floor(0.8 * 160) + 1]
for i = -2, 2 do
  local x, y = floor(s0.x + s0.px * i * 0.9 + .5), floor(s0.y + s0.py * i * 0.9 + .5)
  c:put(x, y, i < 0 and RIB[3] or RIB[2], rt) c:put(x, y + 1, RIB[1], rt)
end
local kx, ky = floor(s0.x + s0.px * 2.6 + .5), floor(s0.y + s0.py * 2.6 + .5)
A.map(c, {
  "ab...",
  "abbc.",
  ".ccbb",
  "..c.ab",
  "...c.b",
}, kx, ky - 1, { a = RIB[4], b = RIB[3], c = RIB[2] }, rt)
A.save(c, "fine-rock-hammer")
