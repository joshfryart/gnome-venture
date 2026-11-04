-- shed-skin (D15, final pass, Sonnet). A whole snake slough meandering in a lazy S across the tile: papery bone-cream tube that
-- tapers from a blunt head (empty mouth slit with a curled ragged lip, nostril pits, a clear eye spectacle) to a frayed tail.
-- Per-pixel tube light (6 tones, cool-violet shade); a diamond scale lattice along the back with olive-tinted diamond centres; a
-- twisted stretch shows the belly side with broad transverse scutes; crumple creases across the body; a bright papery rim on the
-- lit edge and a dusky rolled edge on the shade side; dark ambient row where the head meets the body.
-- quirk: the clear eye cap is still intact, staring out with a glint.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD15_3.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new("shed-skin")

local SK = { "#4e4658", "#76687a", "#a09290", "#c8bc9e", "#e6dcb8", "#fbf2d4" }
local TINT = { "#807a48", "#a3a05e", "#c4c07e" }
local tok = { r = { name = "skin" } }

-- Catmull-Rom path through waypoints -> dense samples -----------------------------------------------------------------------
local W = { { 17, 49 }, { 25, 55 }, { 37, 55 }, { 47, 48 }, { 47, 38 }, { 38, 31 }, { 24, 28 }, { 17, 20 }, { 21, 11 }, { 33, 8 }, { 46, 11 }, { 55, 17 } }
for _, w in ipairs(W) do w[2] = 30 + (w[2] - 30) * 0.92 end
local function cr(p0, p1, p2, p3, t)
  local t2, t3 = t * t, t * t * t
  return 0.5 * ((2 * p1) + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2 + (-p0 + 3 * p1 - 3 * p2 + p3) * t3)
end
local pts = {}
for i = 1, #W - 1 do
  local a, b, c0, d = W[max(1, i - 1)], W[i], W[i + 1], W[min(#W, i + 2)]
  for s = 0, 19 do local t = s / 20
    pts[#pts + 1] = { cr(a[1], b[1], c0[1], d[1], t), cr(a[2], b[2], c0[2], d[2], t) } end
end
pts[#pts + 1] = { W[#W][1], W[#W][2] }
local function wfn(t)
  local w = 3.9 * (1 - t) ^ 0.8 + 0.8
  return w * (1 + 0.08 * sin(t * 41))                  -- slightly puckered width
end
local sm = {}
for i, p in ipairs(pts) do
  local q, r = pts[max(1, i - 1)], pts[min(#pts, i + 1)]
  local tx, ty = r[1] - q[1], r[2] - q[2]
  local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
  local px, py = -ty, tx
  if px + py < 0 then px, py = -px, -py end
  local t = (i - 1) / (#pts - 1)
  sm[i] = { x = p[1], y = p[2], t = t, px = px, py = py, tx = tx, ty = ty, w = wfn(t) }
end
local len = 0
for i = 2, #sm do len = len + sqrt((sm[i].x - sm[i-1].x)^2 + (sm[i].y - sm[i-1].y)^2) end
local m, n, T, S = HP.mask(), {}, {}, {}
do
  local bx0, by0, bx1, by1 = 1e9, 1e9, -1e9, -1e9
  for _, s in ipairs(sm) do bx0 = min(bx0, s.x) by0 = min(by0, s.y) bx1 = max(bx1, s.x) by1 = max(by1, s.y) end
  for y = floor(by0) - 6, floor(by1) + 6 do for x = floor(bx0) - 6, floor(bx1) + 6 do
    local best, bs
    for _, s in ipairs(sm) do local q = (x - s.x)^2 + (y - s.y)^2 if not best or q < best then best, bs = q, s end end
    if sqrt(best) <= bs.w then
      local sd = (x - bs.x) * bs.px + (y - bs.y) * bs.py
      local sn = max(-0.97, min(0.97, sd / (bs.w + 0.5)))
      local k = K(x, y)
      m:set(x, y) n[k] = { bs.px * sn, bs.py * sn, sqrt(1 - sn * sn) }
      T[k], S[k] = bs.t, sn
    end
  end end
end
-- frayed tail tip: nibble the last stretch
local cut = HP.mask()
m:each(function(x, y) local k = K(x, y)
  if T[k] > 0.9 and X.hash(x, y, 7) > 0.5 + (1 - T[k]) * 4 then cut:set(x, y) end
  if T[k] > 0.97 then cut:set(x, y) end end)
m:cut(cut)

-- tube pass ---------------------------------------------------------------------------------------------------------------------
local idx = G.shade(c, m, n, SK, { amb = 0.1, wrap = 0.22, cuts = { 0.28, 0.44, 0.6, 0.76, 0.9 }, tok = tok })
local function at(k, d) return SK[max(1, min(6, (idx[k] or 3) + d))] end
m:each(function(x, y) local k = K(x, y)
  local t, s = T[k], S[k]
  local a, b = t * len, s * (wfn(t) + 0.3)
  if t > 0.43 and t < 0.52 then
    -- twisted: belly side, broad transverse scutes
    local r = a % 2.7
    if r < 0.9 then c:put(x, y, at(k, -2), tok) elseif r < 1.8 then c:put(x, y, at(k, 1), tok) end
  else
    local u, v = (a + b * 1.15) / 3.4, (a - b * 1.15) / 3.4
    local fu, fv = u - floor(u), v - floor(v)
    if fu < 0.24 or fv < 0.24 then c:put(x, y, at(k, -2), tok)
    elseif fu > 0.36 and fu < 0.64 and fv > 0.36 and fv < 0.64 then
      c:put(x, y, TINT[min(3, max(1, (idx[k] or 3) - 1))], tok)
    end
  end
end)
-- crumple creases across the body
for _, cr_ in ipairs{ { 0.17, 0.0 }, { 0.33, 1.4 }, { 0.62, 0.7 }, { 0.8, 2.1 } } do
  m:each(function(x, y) local k = K(x, y)
    local t, s = T[k], S[k]
    local d = (t - cr_[1]) * len + 0.9 * sin(s * 3 + cr_[2])
    if abs(d) < 0.55 and s > -0.8 and s < 0.5 then c:put(x, y, SK[max(1, (idx[k] or 3) - 3)], tok)
    elseif d > 0.55 and d < 1.5 and s < -0.1 and s > -0.7 then c:put(x, y, at(k, 1), tok) end
  end)
end
-- papery rim: bright lit edge, dusky rolled shade edge
m:edge():each(function(x, y) local k = K(x, y)
  local s = S[k]
  if s < -0.6 then c:put(x, y, SK[6], tok) elseif s > 0.6 then c:put(x, y, SK[1], tok) end end)

-- head ------------------------------------------------------------------------------------------------------------------------
local s0 = sm[1]
local fx, fy = -s0.tx, -s0.ty                       -- snout direction (away from the body)
local ux, uy = fy, -fx                              -- perpendicular, flipped so +v is up on screen
if uy > 0 then ux, uy = -ux, -uy end
local CX, CY = s0.x + fx * 2.6, s0.y + fy * 2.6
local function hp(u, v) return floor(CX + fx * u + ux * v + 0.5), floor(CY + fy * u + uy * v + 0.5) end
local hm = G.rell(CX, CY, fx, fy, 6.4, 4.6)
local hn = G.body(hm, CX, CY, 5.4, 4, 0.55)
local hidx = G.shade(c, hm, hn, SK, { amb = 0.1, wrap = 0.22, cuts = { 0.28, 0.44, 0.6, 0.76, 0.9 }, tok = tok })
hm:each(function(x, y) local k = K(x, y)
  local u = (x - CX) * fx + (y - CY) * fy
  local v = (x - CX) * ux + (y - CY) * uy
  local du, dv = (u + v * 1.15) / 3.4, (u - v * 1.15) / 3.4
  local fu, fv = du - floor(du), dv - floor(dv)
  if u < 3.6 and (fu < 0.24 or fv < 0.24) then c:put(x, y, SK[max(1, (hidx[k] or 3) - 2)], tok) end
end)
-- shaded rim of the head, lit rim on the upper side
hm:edge():each(function(x, y)
  local v = (x - CX) * ux + (y - CY) * uy
  if v > 2.4 then c:px(x, y, SK[6]) elseif v < -2.6 then c:px(x, y, SK[2]) end end)
-- ambient dark row where the head meets the body
for _, d in ipairs{ -1.6, -0.9, 0, 0.9, 1.6 } do
  local x, y = floor(s0.x - fx * 1.2 + ux * d * 2.4 + 0.5), floor(s0.y - fy * 1.2 + uy * d * 2.4 + 0.5)
  if hm:has(x, y) then c:px(x, y, SK[2]) end
end
-- empty mouth slit with a rolled lip
local mo = G.rell(CX + fx * 5.2, CY + fy * 5.2, fx, fy, 1.5, 2.9)
local mrx, mry = fx, fy
mo:each(function(x, y) c:px(x, y, "#34263c") end)
mo:grow(1):cut(mo):each(function(x, y) if hm:has(x, y) then c:px(x, y, (x + y) % 2 == 0 and SK[6] or SK[4]) end end)
do local x, y = hp(4.4, -1) c:px(x, y, "#5c4a60") end
-- torn lip flaps
do local x, y = hp(6.4, 3.4) c:px(x, y, SK[5]) x, y = hp(7.4, 3.0) c:px(x, y, SK[3])
   x, y = hp(6.2, -3.4) c:px(x, y, SK[3]) x, y = hp(7.2, -2.8) c:px(x, y, SK[2]) end
-- nostril pits
do local x, y = hp(4.6, 2.6) c:px(x, y, SK[1]) x, y = hp(2.8, 3.4) c:px(x, y, SK[2]) end
-- quirk: intact eye spectacle, clear and round, with a glint
do
  local ex, ey = hp(0.9, 2.5)
  local eye = G.rell(ex, ey, 1, 0, 2.0, 2.0)
  eye:each(function(x, y) c:px(x, y, "#c6dcdc") end)
  eye:edge():each(function(x, y) if x + y > ex + ey then c:px(x, y, "#7a9aaa") else c:px(x, y, "#9cbcc4") end end)
  c:px(ex + 1, ey + 1, "#4a5a72") c:px(ex, ey + 1, "#4a5a72")
  c:px(ex - 1, ey - 1, "#fff4d6") c:px(ex, ey - 1, "#f4ffff")
end
A.save(c, "shed-skin")
