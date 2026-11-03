-- ico-lizard (final, Opus). A slim gecko seen from above, scampering up the diagonal: wedge head upper-right, a
-- narrow neck, long body, four bent splayed legs with sticky toe pads and a tapering tail sweeping into a curl.
-- Material: per-pixel lit scaly skin (6 greens, cool-teal shade), cylinder body, pillow legs, a row of gold dorsal
-- spots, a pebbled scale texture, a dark spine groove at the neck, AO where the legs tuck under the body, bulging
-- eyes with a cream glint and two nostrils on the snout tip.
-- quirk: it is flicking out a little forked pink tongue.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_3.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, abs, floor, max, min, pi, sin, cos = math.sqrt, math.abs, math.floor, math.max, math.min, math.pi, math.sin, math.cos
local c = A.new("ico-lizard")
local LZ = { "#15373a", "#1c5646", "#287a48", "#43a14a", "#77c853", "#b8e56c" }
local SPOT = { "#a8601e", "#e09a2c", "#ffd35a" }
local INK, CREAM = A.INK, A.CREAM
local TONG = { "#b52e5a", "#f07a9a" }
local tok = { r = { name = "lizard" } }

local pb = { { 50, 10 }, { 43, 19 }, { 37, 28 }, { 31, 38 } }
local pt = { { 31, 38 }, { 26, 50 }, { 12, 56 }, { 11, 44 } }
local function bw(t)
  if t < 0.1 then return 1.6 + t / 0.1 * 2.4 end            -- snout
  if t < 0.24 then return 4.0 + sin((t - 0.1) / 0.14 * pi) * 0.8 end -- head
  if t < 0.33 then return 4.0 - (t - 0.24) / 0.09 * 1.4 end  -- neck
  if t < 0.42 then return 2.6 + (t - 0.33) / 0.09 * 2.1 end  -- shoulders
  return 4.7 - max(0, t - 0.75) * 4.0                       -- body to hips
end
local function tw(t) return 3.6 * (1 - t) ^ 0.9 + 1.15 * t end
local mBody, nBody, TBd, SBd, sBd = A.tube(pb, bw)
local mTail, nTail, TTl, STl, sTl = A.tube(pt, tw)
local function at(samp, t) return samp[floor(t * 160) + 1] end

-- legs: {t, side(-1 upper-left / +1 lower-right), out, fore(+ toward head), bend}
local legs = {
  { 0.45, -1, 6.0, -0.2, 3.0 }, { 0.45, 1, 6.0, -0.2, 3.0 },
  { 0.90, -1, 5.0, -0.8, -3.6 }, { 0.90, 1, 5.0, -0.8, -3.6 },
}
local mLeg = HP.mask()
local toes = {}
for _, L in ipairs(legs) do
  local s = at(sBd, L[1])
  local sx, sy = s.x + s.px * L[2] * (s.w - 1.5), s.y + s.py * L[2] * (s.w - 1.5)
  local hx, hy = -s.tx, -s.ty                                      -- toward head
  local ex, ey = sx + s.px * L[2] * L[3] + hx * L[4], sy + s.py * L[2] * L[3] + hy * L[4]
  local fx, fy = ex + hx * L[5] + s.px * L[2] * 2.0, ey + hy * L[5] + s.py * L[2] * 2.0
  mLeg:add(c:line({ { sx, sy }, { ex, ey } }, 3)):add(c:line({ { ex, ey }, { fx, fy } }, 3))
  -- three splayed toes with round pads
  local dx, dy = fx - ex, fy - ey local l = sqrt(dx * dx + dy * dy) dx, dy = dx / l, dy / l
  for _, a in ipairs{ -0.95, 0, 0.95 } do
    local ux, uy = A.rot(dx, dy, a)
    toes[#toes + 1] = { fx + ux * 2.9 + .5, fy + uy * 2.9 + .5 }
    mLeg:add(c:line({ { fx, fy }, { fx + ux * 2.9, fy + uy * 2.9 } }, 1))
  end
end
for _, tpt in ipairs(toes) do mLeg:set(floor(tpt[1]), floor(tpt[2])) end
mLeg:cut(mBody)
local tokL = { r = { name = "legs" } }
local nL = X.pillow(mLeg, 1.4)
local iL = A.shade(c, mLeg, nL, LZ, { tok = tokL, amb = 0.06, wrap = 0.25 })
-- AO where legs tuck under body/tail
A.X.ao({}, mLeg, mBody, 1, -1)
mBody:grow(1):each(function(x, y) if mLeg:has(x, y) then A.step(c, iL, LZ, x, y, -2, tokL) end end)
-- toe pads: one tone lighter centres
for _, tpt in ipairs(toes) do local x, y = floor(tpt[1]), floor(tpt[2]) if mLeg:has(x, y) then A.step(c, iL, LZ, x, y, 1, tokL) end end

-- tail then body (body overlaps the tail root)
local bT = {}
local iT = A.shade(c, mTail, nTail, LZ, { tok = tok, amb = 0.06, wrap = 0.22, bias = bT, cuts = { 0.24, 0.4, 0.56, 0.72, 0.87 } })
-- tail bands (faint rings toward the tip)
mTail:each(function(x, y) local k = K(x, y) local t = TTl[k]
  if t > 0.25 and (t * 11) % 1 < 0.22 then A.step(c, iT, LZ, x, y, -1, tok) end end)
mTail:cut(mBody)
local bB = {}
local iB = A.shade(c, mBody, nBody, LZ, { tok = tok, amb = 0.06, wrap = 0.22, bias = bB, cuts = { 0.24, 0.4, 0.56, 0.72, 0.87 } })
-- separation line where body lies over legs
mBody:edge():each(function(x, y)
  for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do
    if mLeg:has(x + d[1], y + d[2]) then c:put(x, y, LZ[2], tok) break end
  end
end)
-- pebbled scales: hashed one-step dimples on the body and tail
local function pebble(m, idx)
  m:each(function(x, y) if X.hash(x, y, 7) > 0.9 and (idx[K(x, y)] or 1) > 2 then A.step(c, idx, LZ, x, y, -1, tok) end end)
end
pebble(mBody, iB) pebble(mTail, iT)
-- neck groove + dark crease behind the head
mBody:each(function(x, y) local k = K(x, y) local t = TBd[k]
  if t > 0.25 and t < 0.31 and abs(SBd[k]) < 0.8 then A.step(c, iB, LZ, x, y, -1, tok) end end)
-- gold dorsal spots along the spine (head to tail)
local spots = { { sBd, 0.48 }, { sBd, 0.6 }, { sBd, 0.72 }, { sBd, 0.84 }, { sTl, 0.12 }, { sTl, 0.28 }, { sTl, 0.44 } }
for _, sp in ipairs(spots) do
  local s = at(sp[1], sp[2])
  local x, y = floor(s.x - s.px * 0.4 + .5), floor(s.y - s.py * 0.4 + .5)
  c:put(x, y, SPOT[2], tok) c:put(x - 1, y, SPOT[3], tok) c:put(x, y + 1, SPOT[1], tok)
end
-- specular on the head top
local hs = at(sBd, 0.15)
c:put(floor(hs.x - hs.px * 1.6 + .5), floor(hs.y - hs.py * 1.6 + .5), LZ[6], tok)
c:put(floor(hs.x - hs.px * 1.6 + .5) + 1, floor(hs.y - hs.py * 1.6 + .5), CREAM, tok)

-- eyes bulge at both sides of the head (2x2 ink + cream glint)
local es = at(sBd, 0.17)
for _, side in ipairs{ -1, 1 } do
  local x, y = floor(es.x + es.px * side * (es.w - 0.6) + .5), floor(es.y + es.py * side * (es.w - 0.6) + .5)
  c:put(x, y, INK, tok) c:put(x + 1, y, INK, tok) c:put(x, y + 1, INK, tok) c:put(x + 1, y + 1, INK, tok)
  c:put(x, y, CREAM, tok)
  -- lit lid above each eye
  c:put(x, y - 1, LZ[5], tok)
end
-- snout tip: two nostrils
local ns = at(sBd, 0.05)
c:put(floor(ns.x - ns.px * 0.9 + .5), floor(ns.y - ns.py * 0.9 + .5), LZ[1], tok)
c:put(floor(ns.x + ns.px * 0.9 + .5), floor(ns.y + ns.py * 0.9 + .5), LZ[1], tok)

-- quirk: forked tongue flicking out of the snout tip
local tk = { r = { name = "tongue" } }
local s0 = sBd[1]
local hx, hy = -s0.tx, -s0.ty
local tx, ty = s0.x + hx * 1.8, s0.y + hy * 1.8
for i = 0, 2 do c:put(floor(tx + hx * i + .5), floor(ty + hy * i + .5), i == 0 and TONG[1] or TONG[2], tk) end
local fx, fy = tx + hx * 3, ty + hy * 3
c:put(floor(fx + s0.px * 0.8 + hx * 0.6 + .5), floor(fy + s0.py * 0.8 + hy * 0.6 + .5), TONG[2], tk)
c:put(floor(fx - s0.px * 0.8 + hx * 0.6 + .5), floor(fy - s0.py * 0.8 + hy * 0.6 + .5), TONG[2], tk)
A.save(c, "ico-lizard")
