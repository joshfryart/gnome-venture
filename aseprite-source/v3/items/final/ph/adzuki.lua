-- adzuki (final pass, Opus). A slim dried adzuki pod on the diagonal: straw-tan, fine lengthwise striations, a
-- twisted beak at the tip (dry bean pods coil), a dark pedicel with a little calyx at the stem end. The upper valve
-- has split along the seam, showing the pale papery lining and a row of glossy maroon beans nestled in the dark
-- interior (AO round each). Two loose beans in front: 6-tone glossy maroon, sharp specular, cream glint, the white
-- linear hilum ridge that marks an adzuki, cool reflected light on the lower-right rim.
-- quirk: one socket in the pod is empty -- its bean is the one that rolled out to the front.
local NAME = "adzuki"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR1_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)

local POD   = { "#432a24", "#66422e", "#8b5f37", "#b0824a", "#d2a965", "#ecd090" }
local LINE  = { "#c79c62", "#ead1a0", "#f8ecc8" }           -- papery lining: shade, base, lit
local INSIDE = "#2f1c1c"
local STALK = { "#2f2a1c", "#4c4626", "#6e6834", "#948c4a" }
local BEAN  = { "#2c0914", "#4a1020", "#6e1a2a", "#952634", "#bd3f42", "#e2705f" }
local SPEC, BOUNCE, HIL, HILD = "#ffd2c2", "#7d4a72", "#f4ead4", "#b9a48c"

-- pod spine
local P = { { 10, 50 }, { 21, 30 }, { 36, 19 }, { 55, 13 } }
local pod, pn, PT, PS, samples = A.tube(P, function(t)
  if t > 0.99 then return 0.3 end
  local w = 0.8 + 3.0 * sin(pi * (0.1 + 0.8 * t)) ^ 0.45
  if t > 0.82 then w = w * (1 - (t - 0.82) / 0.18) ^ 0.8 + 0.35 end   -- pointed beak
  return w
end)
local len = 0
for i = 2, #samples do len = len + sqrt((samples[i].x - samples[i - 1].x) ^ 2 + (samples[i].y - samples[i - 1].y) ^ 2) end

-- opening along the seam (upper-middle of the pod)
local T0, T1 = 0.2, 0.8
local open = HP.mask()
pod:each(function(x, y) local k = K(x, y)
  local t, s = PT[k], PS[k]
  local e = min(t - T0, T1 - t) / 0.06            -- slit narrows to a point at both ends
  if e > 0 and s > -0.74 and s < -0.74 + min(1, e) * 1.12 then open:set(x, y) end
end)

-- pedicel + calyx (drawn first, pod overlaps it)
local stem, sn2 = A.tube({ { 10, 50 }, { 9, 53 }, { 7, 55 }, { 5, 57 } }, function(t) return 1.05 - 0.3 * t end)
stem:cut(pod)
local stok = A.tok("stalk")
A.shade(c, stem, sn2, STALK, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15 })

-- pod body: striations + twisted beak + AO next to the opening
local bias = {}
pod:each(function(x, y) local k = K(x, y)
  local t, s = PT[k], PS[k]
  local u = t * len
  if abs(abs(s) - 0.58) < 0.12 and X.hash(floor(u / 2), s > 0 and 1 or 2, 5) > 0.3 then bias[k] = -1 end
  if t > 0.8 then                                   -- twist: diagonal bands across the beak
    local f = ((u + s * 3.2) / 3.0) % 1
    if f < 0.36 then bias[k] = -2 elseif f < 0.52 then bias[k] = 1 end
  end
  if t < 0.07 then bias[k] = (bias[k] or 0) - 1 end -- stem end in shadow of the calyx
end)
X.ao(bias, pod, open, 1, -1)
local ptok = A.tok("pod")
local pidx = A.shade(c, pod, pn, POD, { tok = ptok, bias = bias, amb = 0.1, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
-- calyx: three small dark sepals hugging the stem end
for _, q in ipairs{ { 9, 49, 1 }, { 10, 48, 2 }, { 8, 50, 2 }, { 11, 50, 1 }, { 12, 49, 2 }, { 9, 51, 1 } } do c:put(q[1], q[2], STALK[q[3]], ptok) end
c:put(10, 49, STALK[3], ptok)

-- interior + papery lining on the lower valve rim
open:each(function(x, y) c:put(x, y, INSIDE, ptok) end)
local lower = open:grow(1):cut(open):clip(pod)
lower:each(function(x, y) local k = K(x, y)
  if PS[k] > -0.3 then c:put(x, y, (PT[k] < 0.5) and LINE[3] or LINE[2], ptok)
  else c:put(x, y, POD[6], ptok) end             -- lit lip of the upper valve
end)

-- beans in the pod (one socket empty: the quirk)
local ptn = {}
for i, t in ipairs{ 0.3, 0.44, 0.58, 0.71 } do
  local x, y = A.bez(P, t)
  local x2, y2 = A.bez(P, t + 0.01)
  local ang = atan(y2 - y, x2 - x)
  local s0 = samples[floor(t * 160) + 1]
  local cx, cy = x - s0.px * 0.9, y - s0.py * 0.9
  if i ~= 3 then
    local bt = A.tok("pbean" .. i)
    local m, n = A.oval(c, cx, cy, 3.0, 2.5, ang, BEAN, { clip = open, tok = bt, amb = 0.04, wrap = 0.15, cuts = { 0.12, 0.28, 0.45, 0.62, 0.8 } })
    ptn[#ptn + 1] = { m = m, cx = cx, cy = cy }
  else
    -- empty dimple: pale lining at the bottom of the socket
    for _, d in ipairs{ { 0, 0 }, { 1, 0 }, { -1, 0 }, { 0, -1 } } do
      local xi, yi = floor(cx + d[1] + .5), floor(cy + d[2] + .5)
      if open:has(xi, yi) then c:put(xi, yi, d[2] < 0 and LINE[1] or "#5a3c30", ptok) end
    end
  end
end
for _, b in ipairs(ptn) do
  local hx, hy = floor(b.cx - 0.6), floor(b.cy - 0.8)
  if b.m:has(hx, hy) then c:put(hx, hy, SPEC) end
end

-- loose beans in front
local loose = {
  { 36, 46, 4.6, 3.1, -0.3, hil = 0.42 },
  { 47, 38, 4.4, 3.0, 0.75, hil = 0.5 },
}
for i, b in ipairs(loose) do
  local bt = A.tok("bean" .. i)
  local m, n, idx = A.oval(c, b[1], b[2], b[3], b[4], b[5], BEAN, { tok = bt, amb = 0.04, wrap = 0.16, cuts = { 0.12, 0.28, 0.45, 0.62, 0.8 } })
  A.bounce(c, m, n, BOUNCE, 0.62, bt)
  -- hilum: short white ridge along the bean, dark seam under it
  local ca, sa = cos(b[5]), sin(b[5])
  for u = -1.6, 1.6, 0.5 do
    local v = b.hil * b[4]
    local x, y = floor(b[1] + u * ca - v * sa + .5), floor(b[2] + u * sa + v * ca + .5)
    c:put(x, y, abs(u) > 1.4 and HILD or HIL, bt)
    local x2, y2 = floor(b[1] + u * ca - (v + 1) * sa + .5), floor(b[2] + u * sa + (v + 1) * ca + .5)
    if m:has(x2, y2) and not (x2 == x and y2 == y) and abs(u) < 1.2 then c:put(x2, y2, BEAN[2], bt) end
  end
  local sx, sy = A.specAt(m, n, 30)
  c:put(sx, sy, SPEC, bt) c:put(sx + 1, sy, BEAN[6], bt)
  if i == 1 then c:put(sx, sy - 1 >= 0 and sy or sy, "#fff4d6", bt) end
end

A.save(c, NAME)
