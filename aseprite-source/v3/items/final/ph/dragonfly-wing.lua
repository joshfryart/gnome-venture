-- dragonfly-wing (final, Opus single pass). A shed pair: slim forewing laid over a broader hindwing, both fanning
-- up-right from one dark wing-root knuckle. Material: per-pixel pillow light on glassy membrane (6-tone ramps that
-- drift amber at the root -> sky -> lilac at the tip = iridescence), heavy dark costa on the leading edge, fanning
-- longitudinal veins + staggered cross-veins (cells), hindwing veins ghosting through the overlap, contact shadow
-- under the forewing, AO at the root, brown pterostigma, one glassy specular streak.
-- quirk: a dewdrop on the hindwing magnifies the vein beneath it.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("dragonfly-wing")

local AMB = { "#5a4a6a", "#8a6a5a", "#c49a62", "#e2c27e", "#f2e0a8", "#fff6d8" }
local SKY = { "#4a5a92", "#6f8cc4", "#97bce0", "#bfdcef", "#dff0f6", "#f6fdfb" }
local LIL = { "#5a4a8a", "#7f72b8", "#a89ad6", "#cbc0ea", "#e6defa", "#fbf6ff" }
local VR  = { "#1f2240", "#2c3462", "#3c4a84", "#5a6aa4", "#7e8ec4" }
local PT  = { "#3a1a26", "#6a2c2a", "#9a4a2e", "#c87440" }

local function wing(rx, ry, ang, L, Wl, Wt, broad)
  local ux, uy = cos(ang), sin(ang)
  local vx, vy = -uy, ux
  if vx + vy < 0 then vx, vy = -vx, -vy end
  local W = {}
  W.ux, W.uy, W.vx, W.vy, W.rx, W.ry, W.L = ux, uy, vx, vy, rx, ry, L
  local function prof(t) if t <= 0 or t >= 1 then return 0 end return sqrt(sin(pi * t ^ 0.72)) end
  function W.wl(t) return 0.9 + Wl * prof(t) end
  function W.wt(t) local p = prof(t) return 0.8 + Wt * p * (broad and (0.75 + 0.5 * (1 - t) ^ 2) or 1) end
  function W.pt(t, b) local a = t * L return rx + ux * a + vx * b, ry + uy * a + vy * b end
  local m, T, B = HP.mask(), {}, {}
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - rx, y - ry
    local a, b = dx * ux + dy * uy, dx * vx + dy * vy
    local t = a / L
    if t >= -0.02 and t <= 1 then
      local tt = max(0.001, t)
      if b >= -W.wl(tt) and b <= W.wt(tt) then
        m:set(x, y) local k = K(x, y) T[k] = t B[k] = b < 0 and b / W.wl(tt) or b / W.wt(tt)
      end
    end
  end end
  W.m, W.T, W.B = m, T, B
  return W
end

local RX, RY = 14, 48
local hw = wing(RX + 1, RY - 1, -0.28, 38, 3.0, 9.8, true)
local fw = wing(RX, RY - 2, -0.78, 43, 2.6, 7.4, false)
local hm, fm = hw.m, fw.m:copy()

-- tone a wing with ramps chosen by position along it
local tok = { h = { r = { name = "hind" } }, f = { r = { name = "fore" } } }
local function paint(W, bias, tk)
  local n = X.pillow(W.m, 3)
  local v = X.light(n, { amb = 0.16, wrap = 0.35 })
  local idx = {}
  W.m:each(function(x, y) local k = K(x, y)
    local i = 1
    for j, cut in ipairs{ 0.24, 0.4, 0.56, 0.72, 0.87 } do if v[k] >= cut then i = j + 1 end end
    i = max(1, min(6, i + (bias[k] or 0)))
    idx[k] = i
    local t = W.T[k]
    local R = (t < 0.13 and AMB) or (t > 0.62 + 0.06 * W.B[k] and LIL) or SKY
    c:put(x, y, R[i], tk)
  end)
  return idx
end
local hb = {}
-- contact shadow from the forewing onto the hindwing; AO by the root
A.cast(hb, hm, fm, 1, 2, -1)
local root = HP.ellipse(RX, RY - 1, 3, 3)
X.ao(hb, hm, root, 3, -1)
local fb = {}
X.ao(fb, fm, root, 2, -1)
local hidx = paint(hw, hb, tok.h)
local fidx = paint(fw, fb, tok.f)

local function plot(W, idx, x, y, d, mask, tk, keep)
  if not W.m:has(x, y) then return end
  if mask and mask:has(x, y) then return end
  local k = K(x, y)
  if keep and keep[k] then return end
  local i = idx[k] or 3
  local t = W.T[k] local R = (t < 0.13 and AMB) or (t > 0.62 + 0.06 * W.B[k] and LIL) or SKY
  if d >= 2 then c:put(x, y, i >= 4 and VR[4] or VR[3], tk) else c:put(x, y, i >= 4 and VR[5] or R[2], tk) end
end

local function veins(W, idx, tk, skip, ghost)
  -- trailing rim (membrane edge a touch darker)
  W.m:edge():each(function(x, y) local k = K(x, y)
    if W.B[k] > 0.6 and W.T[k] > 0.06 and not (skip and skip:has(x, y)) then
      local t = W.T[k] local R = (t < 0.13 and AMB) or (t > 0.62 and LIL) or SKY
      c:put(x, y, R[max(1, (idx[k] or 3) - 1)], tk)
    end end)
  -- longitudinal veins
  local lines = { -0.45, 0.12, 0.58 }
  local onv = {}
  for li, f in ipairs(lines) do
    local t1 = f < 0 and 0.97 or (1.0 - 0.18 * f)
    for s = 0, 200 do
      local t = 0.02 + (t1 - 0.02) * s / 200
      local b = f < 0 and f * W.wl(t) or f * W.wt(t) * (0.35 + 0.65 * min(1, t * 3))
      local x, y = W.pt(t, b)
      local xi, yi = floor(x + .5), floor(y + .5)
      plot(W, idx, xi, yi, li == 1 and 3 or 2, skip, tk)
      onv[K(xi, yi)] = true
    end
  end
  -- costa: leading edge 1px inside, darkest
  W.m:edge():each(function(x, y) local k = K(x, y)
    if W.B[k] < -0.4 and not (skip and skip:has(x, y)) then c:put(x, y, VR[(idx[k] or 3) >= 4 and 2 or 1], tk) onv[k] = true end end)
  -- cross veins, staggered, between neighbour longitudinals
  local LEN = W.L
  for li = 1, #lines - 1 do
    local f0, f1 = lines[li], lines[li + 1]
    local step = 5.0 / LEN
    local t = 0.12 + (li % 2) * step * 0.5
    while t < 0.94 - 0.15 * f1 do
      local function bat(f) return f < 0 and f * W.wl(t) or f * W.wt(t) * (0.35 + 0.65 * min(1, t * 3)) end
      local xa, ya = W.pt(t, bat(f0)) local xb, yb = W.pt(t + 0.012, bat(f1))
      A.ln(xa, ya, xb, yb, function(x, y) plot(W, idx, x, y, 1.5, skip, tk) end)
      t = t + step
    end
  end
  -- ghost veins seen through the overlap (one step darker membrane, not full vein)
  return onv
end
veins(hw, hidx, tok.h, fm)
-- hindwing longitudinals ghosting through the forewing
for _, f in ipairs{ 0.12, 0.58 } do
  for s = 0, 200 do
    local t = 0.05 + 0.85 * s / 200
    local x, y = hw.pt(t, f * hw.wt(t) * (0.35 + 0.65 * min(1, t * 3)))
    local xi, yi = floor(x + .5), floor(y + .5)
    if fm:has(xi, yi) then A.step(c, fidx, SKY, xi, yi, -1, tok.f) end
  end
end
veins(fw, fidx, tok.f, nil)

-- pterostigma on the forewing leading edge near the tip
fm:each(function(x, y) local k = K(x, y)
  local t, b = fw.T[k], fw.B[k]
  if t > 0.8 and t < 0.88 and b < -0.05 and b > -0.95 then
    c:put(x, y, PT[(t < 0.83 and b < -0.5) and 4 or (b < -0.5 and 3 or 2)], tok.f)
  end end)
-- hindwing stigma (smaller)
hm:each(function(x, y) local k = K(x, y)
  if not fm:has(x, y) then local t, b = hw.T[k], hw.B[k]
  if t > 0.8 and t < 0.86 and b < -0.05 and b > -0.95 then c:put(x, y, PT[b < -0.5 and 3 or 2], tok.h) end end end)

-- specular streak along the forewing near the costa + glint
for s = 0, 5 do
  local x, y = fw.pt(0.3 + s * 0.022, -0.1)
  c:put(floor(x + .5), floor(y + .5), s == 2 and "#fffdf0" or "#f0fbff", tok.f)
end

-- wing-root knuckle: chitin, dark teal metallic
local km = HP.ellipse(RX - 1, RY, 3, 2):add(HP.ellipse(RX + 1, RY - 1, 2, 2))
local kn = A.body(km, RX - 1, RY - 1, 3.2, 2, 0.7)
local KR = { "#1a1a30", "#22304a", "#2a4a62", "#33707a", "#4ea29a", "#8ad6c0" }
local kidx = A.shade(c, km, kn, KR, { tok = { r = { name = "knuckle" } }, amb = 0.05, wrap = 0.2 })
-- articulation groove + broken stub tip
c:put(RX - 3, RY + 1, KR[1], { r = { name = "knuckle" } })
c:put(RX - 2, RY - 1, KR[6], { r = { name = "knuckle" } })

-- quirk: dewdrop on the hindwing, magnifying a cross vein
local dx, dy = hw.pt(0.56, 0.5 * hw.wt(0.56))
dx, dy = floor(dx + .5), floor(dy + .5)
local dm, dn = A.oval(dx, dy, 2.4, 2.1, 0, 1)
local DR = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#8edcd8", "#c4f4ea", "#f4fffa" }
local didx = A.shade(c, dm, dn, DR, { tok = tok.h, amb = 0.1, wrap = 0.3 })
-- magnified vein: a fat 2px bar through the drop, refracted (shifted)
for x = dx - 2, dx + 2 do if dm:has(x, dy + 1) then c:put(x, dy + 1, VR[3], tok.h) end end
dm:edge():each(function(x, y) if x >= dx and y >= dy then c:put(x, y, DR[2], tok.h) end end)
c:put(dx + 1, dy + 2, DR[5], tok.h)
c:put(dx - 1, dy - 1, "#fff4d6", tok.h)
A.save(c, "dragonfly-wing")
