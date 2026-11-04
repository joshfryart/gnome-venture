-- rye (final D step, Sonnet high). Three tall slim rye stalks bound with a twisted straw band: jointed straw with
-- green leaf sheaths, long narrow ears of paired zig-zag grains each ending in a fan of fine pale awns (the beard),
-- and three ribbon leaves of blue-green at the base.
-- Material: 6-tone straw tube light, node rings, per-grain sphere light (right-hand grains one tone darker so the
-- ear reads as a 3D zigzag), twisted band (diagonal rope twist, gold ramp), leaf midrib + parallel veins, AO under
-- the band and where leaves cross the stalks.
-- quirk: the right-hand ear is so heavy with grain that it bows over and hangs its beard toward the ground.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_4.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = G.new2("rye")

local STRAW = { "#6b4f22", "#946f30", "#bf9540", "#dcb858", "#efd27e", "#fbeeb0" }
local GR    = { "#5e4a24", "#86693a", "#b09248", "#d0b062", "#e8cd82", "#fbeab0" }
local AWN   = { "#b8984e", "#e0c880", "#f6e6b4", "#fffbe8" }
local LEAF  = { "#22392f", "#34564a", "#4c7a5c", "#6c9a6e", "#92b88a", "#bcd6aa" }
local SHEATH = { "#3d6244", "#5d8a58", "#86b072", "#b4d494" }
local BAND  = { "#8f4a1f", "#c9731f", "#f5b82e", "#ffe38a" }
local tok = function(n) return { r = { name = n } } end

local function split(p, t)   -- de Casteljau: left part of a cubic up to t
  local function lerp(a, b) return { a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t } end
  local a, b, cc = lerp(p[1], p[2]), lerp(p[2], p[3]), lerp(p[3], p[4])
  local d, e = lerp(a, b), lerp(b, cc)
  return { p[1], a, d, lerp(d, e) }
end

-- ---------- ribbon leaves ----------
local function leaf(ax, ay, cx, cy, bx, by, w, name)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.99 then return -1 end
    return max(0.45, w * sin(pi * min(1, 0.1 + t * 0.9) ^ 0.9) ^ 0.45)
  end, { fold = 0.5 })
  local tk = tok(name)
  G.toneN(c, m, n, LEAF, { tok = tk, cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if t < 0.05 or t > 0.95 then return end
    if abs(s) < 0.14 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], tk)
    elseif abs(s - 0.55) < 0.08 or abs(s + 0.55) < 0.08 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], tk) end
  end)
  return m, S, T
end
leaf(33, 57, 46, 56, 50, 45, 2.2, "leafR")
leaf(31, 57, 14, 55, 9, 41, 2.3, "leafL")

-- ---------- stalks ----------
local stalks = {
  { { 28, 57 }, { 29, 47 }, { 25, 38 }, { 22, 32 } },
  { { 32, 57 }, { 32, 47 }, { 33, 37 }, { 33, 29 } },
  { { 36, 57 }, { 36, 45 }, { 44, 36 }, { 48, 28 } },
}
local stalkM = {}
for i, p in ipairs(stalks) do
  local m, n, T, S = G.tube(p, function(t) return 1.2 - 0.15 * t end)
  stalkM[i] = m
  local idx = X.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.3 }), STRAW, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, tok = tok("straw" .. i) })
  -- node ring (dark row + pale lip above) at t=0.55
  m:each(function(x, y) local k = K(x, y)
    if T[k] > 0.52 and T[k] < 0.585 then c:put(x, y, STRAW[max(1, (idx[k] or 3) - 2)], tok("node")) end
    if T[k] > 0.585 and T[k] < 0.62 and S[k] < 0.2 then c:put(x, y, STRAW[min(6, (idx[k] or 3) + 1)], tok("node")) end
  end)
  -- green leaf sheath over the lower stalk
  local sp = split(p, 0.26)
  local sm, sn, sT = G.tube(sp, function(t) return 1.5 - 0.3 * t end)
  local sidx = X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), SHEATH, { cuts = { 0.3, 0.55, 0.8 }, tok = tok("sheath") })
  sm:each(function(x, y) local k = K(x, y)
    if sT[k] > 0.9 then c:put(x, y, SHEATH[1], tok("sheath")) end             -- ligule line
    if sT[k] > 0.1 and abs(sn[k][1]) < 0.12 and sT[k] < 0.88 then c:put(x, y, SHEATH[min(4, (sidx[k] or 2) + 1)], tok("sheath")) end
  end)
end

-- ---------- straw band (twisted) ----------
do
  local bm = c:rrect(26, 44, 38, 47, 1)
  local tk = tok("band")
  bm:each(function(x, y)
    local base = (y == 44) and 3 or ((y == 47) and 1 or 2)
    local tw = ((x * 2 + y) % 4 < 2) and 1 or 0
    c:put(x, y, BAND[max(1, min(4, base + tw))], tk)
  end)
  -- end caps shaded
  c:px(26, 45, BAND[1]) c:px(26, 46, BAND[1]) c:px(38, 45, BAND[2]) c:px(38, 46, BAND[1])
  -- AO under the band
  for x = 27, 37 do c:px(x, 48, STRAW[1]) end
  -- loose straw tail
  for _, q in ipairs{ { 36, 48, 3 }, { 37, 49, 2 }, { 37, 50, 2 }, { 38, 51, 1 } } do c:px(q[1], q[2], BAND[q[3]]) end
end

-- ---------- ears ----------
local function ear(path, nPair, awnL, name, drop)
  local N = 200
  local P = {}
  local acc = 0
  for i = 0, N do
    local x, y = G.bez(path, i / N)
    if i > 0 then acc = acc + sqrt((x - P[i - 1].x) ^ 2 + (y - P[i - 1].y) ^ 2) end
    P[i] = { x = x, y = y, s = acc }
  end
  local total = acc
  local function at(s)
    s = max(0, min(total, s))
    for i = 1, N do if P[i].s >= s then
      local a, b = P[i - 1], P[i]
      local f = (s - a.s) / max(1e-6, b.s - a.s)
      local dx, dy = b.x - a.x, b.y - a.y
      local l = sqrt(dx * dx + dy * dy)
      return a.x + dx * f, a.y + dy * f, dx / l, dy / l
    end end
    local b = P[N] local a = P[N - 1] local dx, dy = b.x - a.x, b.y - a.y local l = sqrt(dx * dx + dy * dy)
    return b.x, b.y, dx / l, dy / l
  end
  local step = total / nPair
  local tk = tok(name)
  -- rachis (dark spine) first
  -- grains: tip to base so the lower pairs overlap the upper
  for j = nPair, 0, -1 do
    local s = j * step
    local x, y, tx, ty = at(s)
    local nx, ny = -ty, tx
    local ang = atan(ty, tx)
    local taper = 1.25 - 0.6 * (j / nPair)
    for _, side in ipairs{ -1, 1 } do
      local off = taper * side
      local sh = (side > 0 and 0.8 or -0.4)
      local cx, cy = x + nx * off + tx * sh, y + ny * off + ty * sh
      local m, n = G.oval(cx, cy, 2.1, 1.0, ang - side * 0.32, 0.9)
      local bias = {}
      local lit = (nx * side) * -0.6 + (ny * side) * -0.7
      m:each(function(px, py) bias[K(px, py)] = lit < -0.1 and -1 or ((lit > 0.25) and 1 or 0) end)
      G.toneN(c, m, n, GR, { bias = bias, tok = tk, cuts = { 0.22, 0.4, 0.58, 0.74, 0.9 }, amb = 0.0, wrap = 0.05 })
      -- dark seam along the lower/right edge of each grain
      m:each(function(px, py)
        if not m:has(px + 1, py + 1) and not m:has(px, py + 1) then c:put(px, py, GR[1], tk)
        elseif not m:has(px - 1, py) and not m:has(px, py - 1) then c:put(px, py, GR[6], tk) end
      end)
    end
  end
  -- awns: one tapering beard of fine bristles streaming off the tip
  local ex, ey, tx, ty = at(total)
  local L = awnL
  local bend = (drop or 0)
  local ba = atan(ty, tx)
  local dx, dy = tx, ty
  local pts = { { ex, ey }, { ex + dx * L * 0.33, ey + dy * L * 0.33 }, { ex + dx * L * 0.66, ey + dy * L * 0.66 + bend }, { ex + dx * L, ey + dy * L + bend * 2 } }
  local m, n, T, S = G.tube(pts, function(t) return 1.8 * (1 - t) ^ 0.8 + 0.5 end)
  local btk = tok(name .. "beard")
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    local col
    if abs(s) > 0.55 and t < 0.7 then col = AWN[1]                      -- gap between bristles
    elseif abs(s - 0.0) < 0.2 then col = AWN[4]
    elseif s < 0 then col = AWN[3] else col = AWN[2] end
    if t > 0.8 then col = (s < 0) and AWN[3] or AWN[2] end
    c:put(x, y, col, btk)
  end)
end
ear({ { 22, 32 }, { 21.5, 29 }, { 21, 25 }, { 20.5, 21 } }, 5, 11, "earL", 0)
ear({ { 33, 29 }, { 33.4, 26 }, { 33.4, 22 }, { 33, 19 } }, 5, 10, "earC", 0)
ear({ { 48, 28 }, { 50, 22 }, { 56, 24 }, { 56, 34 } }, 5, 11, "earR", 1.5)

G.save2(c, "rye")
