-- clove (final, Opus single pass). One long dried clove on the diagonal: a slim four-sided stem (ridged edges,
-- wrinkle grain) flaring to a crown of four pointed sepals that cup a round bud ball (lit cap, waxy bloom,
-- specular, cool bounce). A second, shorter clove lies at its foot. AO where sepals meet ball and stem.
-- quirk: the little clove's bud is still blushing pink, picked a day too early.
local NAME = "clove"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local CL = { "#22121a", "#3d1d1e", "#5a2a22", "#7a3d28", "#9c5634", "#c27c48" }
local BALL = { "#3a2020", "#5a3024", "#7e482c", "#a2663a", "#c48a52", "#e2b47a" }
local CUTSD = { 0.3, 0.46, 0.6, 0.74, 0.88 }
local PINK = { "#4c1c2c", "#7a2a3c", "#a83f4c", "#cf5f62", "#ec8a80", "#ffbfa6" }
local COOL = "#6a5a7a"

local function clove(base, ctrl1, ctrl2, top, sc, ballR, name)
  local tok = { r = { name = name } }
  local pts = { base, ctrl1, ctrl2, top }
  -- axis at the top
  local x1, y1 = A.bez(pts, 0.97) local x2, y2 = A.bez(pts, 1)
  local ux, uy = x2 - x1, y2 - y1 local l = sqrt(ux*ux + uy*uy) ux, uy = ux / l, uy / l
  local cx, cy = top[1] + ux * 1.5 * sc, top[2] + uy * 1.5 * sc
  local bx, by = cx + ux * 5.0 * sc, cy + uy * 5.0 * sc
  -- ball
  local bm = A.rell(bx, by, ux, uy, 3.3 * sc, 3.5 * sc)
  -- sepals: four, two outer (spread) and two inner (behind ball)
  local seps = {}
  for _, a in ipairs{ -1.05, 1.05, -0.42, 0.42 } do
    local dx, dy = A.rot(ux, uy, a)
    local L = (abs(a) > 0.5 and 6.4 or 6.8) * sc
    local ex, ey = cx + dx * L, cy + dy * L
    local m, n = A.blade(cx, cy, cx + dx * L * 0.5 + ux * sc, cy + dy * L * 0.5 + uy * sc, ex, ey, function(t)
      if t > 0.97 then return -1 end return max(0.35, 2.0 * sc * (1 - t) ^ 0.9 + 0.25) end, { fold = 0.4 })
    seps[#seps + 1] = { m = m, n = n, a = a }
  end
  -- stem
  local sm, sn, ST, SS = A.tube(pts, function(t) return (0.9 + 1.1 * t ^ 1.3) * sc end)
  local front = HP.mask()
  for i = 1, 2 do front:add(seps[i].m) end
  local back = HP.mask()
  for i = 3, 4 do back:add(seps[i].m) end
  -- draw order: stem, back sepals, ball, front sepals
  sm:cut(bm)
  local sb = {}
  X.ao(sb, sm, front, 2, -1) X.ao(sb, sm, back, 1, -1)
  local sidx = A.shade(c, sm, sn, CL, { bias = sb, tok = tok, amb = 0.12, wrap = 0.3, cuts = CUTSD })
  -- four-sided rod: ridge lines and wrinkle grain
  sm:each(function(x, y) local k = K(x, y) local s, t = SS[k], ST[k]
    if not sidx[k] then return end
    if abs(s + 0.42) < 0.13 and t < 0.92 then c:put(x, y, CL[min(6, sidx[k] + 1)], tok) end
    if abs(s - 0.4) < 0.13 and t < 0.92 then c:put(x, y, CL[max(1, sidx[k] - 1)], tok) end
    if X.hash(x, y, 7) > 0.86 and t > 0.06 and t < 0.85 and abs(s) < 0.75 then c:put(x, y, CL[max(1, sidx[k] - 1)], tok) end
  end)
  -- stem foot: blunt, paler cut end
  do local x, y = A.bez(pts, 0) c:put(floor(x + .5), floor(y + .5), CL[5], tok) end
  for i = 3, 4 do local s = seps[i] s.m:cut(bm) A.shade(c, s.m, s.n, CL, { tok = tok, amb = 0.12, wrap = 0.3, cuts = CUTSD, bias = X.ao({}, s.m, bm, 1, -1) }) end
  -- ball
  local bn = X.sphere(bx - ux * 0.6, by - uy * 0.6, 3.6 * sc, bm)
  local bb = {}
  X.ao(bb, bm, front, 1, -2)
  local R = ballR or BALL
  local bidx = A.shade(c, bm, bn, R, { bias = bb, tok = tok, amb = 0.1, wrap = 0.3, cuts = CUTSD })
  -- petal seams on the ball (it is a closed bud of four petals)
  bm:each(function(x, y) local k = K(x, y)
    local dx, dy = x - bx, y - by
    local a = dx * ux + dy * uy local p = -dx * uy + dy * ux
    if abs(p + a * 0.25) < 0.5 and a > -1 and bidx[k] > 2 then c:put(x, y, R[bidx[k] - 1], tok) end
  end)
  local rim = X.rim(bn)
  bm:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.75 and not bb[k] then c:put(x, y, COOL, tok) end end)
  -- spec 2x1 on the ball cap
  local sx, sy = A.specAt(bm, bn, 30)
  c:put(sx, sy, "#fff4d6", tok) c:put(sx + 1, sy, R[6], tok)
  -- front sepals over everything at the crown
  for i = 1, 2 do local s = seps[i]
    local idx = A.shade(c, s.m, s.n, CL, { tok = tok, amb = 0.12, wrap = 0.3, cuts = CUTSD })
    -- lit tip edge
    s.m:edge():each(function(x, y) local k = K(x, y) if idx[k] and idx[k] >= 4 and X.hash(x, y, 3) > 0.5 then c:put(x, y, CL[min(6, idx[k] + 1)], tok) end end)
    -- separation line where the sepal lies on the ball / its twin
    s.m:edge():each(function(x, y)
      for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do local qx, qy = x + d[1], y + d[2]
        if (bm:has(qx, qy) or seps[3 - i].m:has(qx, qy)) and not s.m:has(qx, qy) and (qx - x) * ux + (qy - y) * uy > -0.2 then c:put(x, y, CL[1], tok) break end end end)
  end
  return sm, bm, front
end

-- small clove lying at the foot (drawn first: behind)
local sm2, bm2 = clove({ 30, 56 }, { 37, 56 }, { 43, 55 }, { 48, 54 }, 0.9, PINK, "clove2")
-- main clove
local sm1 = clove({ 9, 56 }, { 16, 46 }, { 25, 34 }, { 33, 25 }, 1.35, nil, "clove1")

A.save(c, NAME)
