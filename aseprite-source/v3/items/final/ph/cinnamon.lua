-- cinnamon (final, Opus single pass). A slim bundle of three cinnamon quills on the diagonal, staggered in length,
-- rust-brown bark lit as round rolled tubes (6 tones), broken lengthwise striations and pale flecks, dark AO seams where
-- quills touch, each upper end showing the rolled scroll: pale curled bark lip around a dark hollow. Tied at the middle
-- with twisted jute twine (diagonal twist, AO either side) and a knot with two frayed tails.
-- quirk: one thin shaving of bark has curled off and lies beside the bundle.
local NAME = "cinnamon"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new(NAME)
local CN = { "#3a1a16", "#5e2c1e", "#843f26", "#a85a31", "#c97a44", "#e9a866" }
local HOLE, LIP, LIPS = "#2e1512", "#f0c08a", "#b8743e"
local TW = { "#6e5032", "#a4844e", "#d4b878", "#f0dca4" }

local ax, ay, bx, by = 9, 45, 52, 20
local L = sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
local ux, uy = (bx - ax) / L, (by - ay) / L
local px, py = -uy, ux if px + py < 0 then px, py = -px, -py end
local W = 2.45
-- quills back (upper-left) to front (lower-right): offset across, start/end trim along
local Q = { { -4.7, 3, -2 }, { 0, 0, 1.5 }, { 4.7, 1.5, -3.5 } }
local qs = {}
for i, q in ipairs(Q) do
  local o, s0, s1 = q[1], q[2], q[3]
  local x0, y0 = ax + px * o + ux * s0, ay + py * o + uy * s0
  local x1, y1 = bx + px * o + ux * s1, by + py * o + uy * s1
  qs[i] = { x0 = x0, y0 = y0, x1 = x1, y1 = y1, p = { { x0, y0 }, { x0 + (x1 - x0) / 3, y0 + (y1 - y0) / 3 }, { x0 + 2 * (x1 - x0) / 3, y0 + 2 * (y1 - y0) / 3 }, { x1, y1 } } }
  qs[i].m, qs[i].n, qs[i].T, qs[i].S = A.tube(qs[i].p, function(t) return W end)
  qs[i].len = sqrt((x1 - x0) ^ 2 + (y1 - y0) ^ 2)
end
-- twine band: across the bundle, 2 px along the axis, a hair wider than the bundle
local t0 = 0.47
local tx, ty = ax + (bx - ax) * t0, ay + (by - ay) * t0
local band, BA = HP.mask(), {}
for y = floor(ty) - 12, floor(ty) + 12 do for x = floor(tx) - 12, floor(tx) + 12 do
  local dx, dy = x - tx, y - ty
  local al, ac = dx * ux + dy * uy, dx * px + dy * py
  if abs(al) <= 1.05 and abs(ac) <= 7.9 then band:set(x, y) BA[K(x, y)] = ac end
end end

-- quills
for i, q in ipairs(qs) do
  local vis = q.m:copy()
  local b = {}
  for j = i + 1, #qs do vis:cut(qs[j].m) X.ao(b, q.m, qs[j].m, 1, -1) end
  X.ao(b, q.m, band, 1, -1)
  local tok = { r = { name = "quill" .. i } }
  local v = X.light(q.n, { amb = 0.1, wrap = 0.3 })
  local idx = {}
  vis:each(function(x, y) local k = K(x, y)
    local val = v[k] or 0
    local ii = 1
    for jj, cu in ipairs({ 0.2, 0.36, 0.52, 0.68, 0.84 }) do if val >= cu then ii = jj + 1 end end
    ii = max(1, min(6, ii + (b[k] or 0)))
    -- broken lengthwise striations and pale flecks (bark)
    local s, t = q.S[k], q.T[k]
    local al = floor(t * q.len)
    for _, r in ipairs{ -0.42, 0.12, 0.6 } do
      if abs(s - r) < 0.16 and X.hash(al // 3, floor(r * 10), i) > 0.3 then ii = max(1, ii - 1) end
    end
    if X.hash(x, y, 7 + i) > 0.93 and ii >= 3 and ii <= 5 then ii = ii + 1 end
    idx[k] = ii
    c:put(x, y, CN[ii], tok)
  end)
  -- scroll end at the upper-right: dark hollow, pale rolled lip
  local cap = A.rell(q.x1 + ux * 0.4, q.y1 + uy * 0.4, ux, uy, 1.25, W + 0.3)
  local hole = A.rell(q.x1 + ux * 0.4 + px * 0.5, q.y1 + uy * 0.4 + py * 0.5, ux, uy, 0.7, 1.3)
  local vcap = cap:copy() for j = i + 1, #qs do vcap:cut(qs[j].m) end
  vcap:each(function(x, y) local dx, dy = x - q.x1, y - q.y1
    local ac = dx * px + dy * py
    c:put(x, y, ac < 0.6 and LIP or LIPS, tok) end)
  hole:each(function(x, y) if vcap:has(x, y) then c:put(x, y, HOLE, tok) end end)
  -- rolled-in edge: one pale lip pixel curling into the hollow
  c:put(floor(q.x1 + ux * 0.4 + px * 1.6 + .5), floor(q.y1 + uy * 0.4 + py * 1.6 + .5), LIPS, tok)
  -- lower end: darker cut
  local e0 = A.rell(q.x0, q.y0, ux, uy, 0.9, W)
  e0:each(function(x, y) if vis:has(x, y) then c:put(x, y, CN[max(1, (idx[K(x, y)] or 3) - 1)], tok) end end)
end
-- glint on the front quill
do local q = qs[3] local x, y = q.x0 + (q.x1 - q.x0) * 0.72 - px * 1.2, q.y0 + (q.y1 - q.y0) * 0.72 - py * 1.2
  c:put(floor(x + .5), floor(y + .5), A.CREAM) c:put(floor(x + .5) + 1, floor(y + .5) - 1, CN[6]) end

-- twine: twisted band (diagonal twist pattern), knot and two frayed tails at the front
local ttok = { r = { name = "twine" } }
band:each(function(x, y) local k = K(x, y)
  local ac = BA[k]
  local dx, dy = x - tx, y - ty
  local al = dx * ux + dy * uy
  local ph = floor(ac + al * 1.2 + 20) % 3
  local i = (ph == 0) and 4 or (ph == 1 and 3 or 2)
  if ac > 4 then i = i - 1 end
  if ac < -6 then i = min(4, i + 1) end
  c:put(x, y, TW[max(1, i)], ttok)
end)
local kx, ky = tx + px * 8.6, ty + py * 8.6
local knot = A.rell(kx, ky, 1, 0, 1.6, 1.4)
local kn = X.sphere(kx - 0.3, ky - 0.3, 1.6, knot)
X.tone(c, knot, X.light(kn, { amb = 0.1, wrap = 0.2 }), TW, { cuts = { 0.3, 0.55, 0.8 }, tok = ttok })
for _, tl in ipairs{ { { kx, ky + 1 }, { kx - 1, ky + 3 }, { kx - 3, ky + 5 }, { kx - 3, ky + 7 } },
                     { { kx + 1, ky + 1 }, { kx + 2, ky + 3 }, { kx + 2, ky + 5 }, { kx + 4, ky + 7 } } } do
  for ii = 0, 14 do local x, y = A.bez(tl, ii / 14) c:put(floor(x + .5), floor(y + .5), (ii % 3 == 0) and TW[2] or TW[3], ttok) end
end

-- quirk: a curled shaving of bark beside the bundle (C-curl: pale inner face, dark outer)
local stok = { r = { name = "shaving" } }
local sp = { { 40, 47 }, { 46, 43 }, { 52, 46 }, { 48, 50 } }
local sm, sn, ST, SS = A.tube(sp, function(t) return 0.6 + 0.9 * math.sin(math.pi * t) end)
X.tone(c, sm, X.light(sn, { amb = 0.12, wrap = 0.3 }), CN, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = stok })
sm:each(function(x, y) local k = K(x, y) if SS[k] < -0.3 and ST[k] > 0.15 and ST[k] < 0.8 then c:put(x, y, LIP, stok) end end)
A.save(c, NAME)
