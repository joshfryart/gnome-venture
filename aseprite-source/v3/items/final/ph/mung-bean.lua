-- mung-bean (final, Opus). A slim, gently S-curved mature mung pod (near-black brown, fine pale hairs, a raised
-- suture ridge, a beaked tip and a short green stalk) split open along the middle: cream concave lining, five glossy
-- olive-green beans seated in a row, each with a white hilum dash, AO in the cavity and a contact shadow per bean.
-- quirk: one bean has rolled out and sits on its own just under the pod.
local NAME = "mung-bean"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local POD = { "#1c1218", "#2e1d1e", "#452c25", "#5f402e", "#7e5a3c", "#a07c52" }
local LIN = { "#6e5c3c", "#9a8458", "#bfaa74", "#dccb92", "#efe2b0", "#fff4d6" }
local BEAN = { "#1d3622", "#2c5229", "#437332", "#5f913a", "#86b24a", "#bcd872" }
local STK = { "#2e4a2c", "#4a6e34", "#6e9446", "#9cbc62" }
local HAIR, HIL = "#b89a6e", "#f4eed0"

local P = { { 12, 50 }, { 24, 50 }, { 40, 39 }, { 52, 16 } }
local function pw(t)
  if t > 0.995 then return 0 end
  return 0.6 + 3.5 * sin(pi * min(1, t * 0.97 + 0.02)) ^ 0.55
end
local pod, pn, PT, PS = A.tube(P, pw)
-- beaked tip: a short hooked spur
for _, q in ipairs{ { 52, 15 }, { 53, 14 }, { 54, 14 } } do pod:set(q[1], q[2]) pn[K(q[1], q[2])] = { -0.3, -0.4, 0.86 } PT[K(q[1], q[2])] = 1 PS[K(q[1], q[2])] = 0 end

-- cavity (the split): centred on the axis, t 0.27..0.82
local function cw(t)
  if t < 0.27 or t > 0.82 then return 0 end
  local u = (t - 0.27) / 0.55
  return 2.4 * sin(pi * u) ^ 0.45
end
local cav = HP.mask()
pod:each(function(x, y) local k = K(x, y)
  local w = cw(PT[k])
  if w > 0 and abs(PS[k]) * (pw(PT[k]) + 0.5) <= w then cav:set(x, y) end end)

-- stalk (drawn first, under the pod's foot)
local sm = A.stem(c, { { 7, 52 }, { 9, 51 }, { 11, 51 }, { 14, 50 } }, function(t) return 1.05 end, STK, { cut = pod, tok = { r = { name = "stalk" } } })

-- pod shell
local bias = {}
X.ao(bias, pod, cav, 1, -1)
local ptok = { r = { name = "pod" } }
local pidx = A.shade(c, pod:copy():cut(cav), pn, POD, { amb = 0.1, wrap = 0.3, bias = bias, tok = ptok })
-- suture ridge along the lit side of the shell, lighter line; hairs as pale flecks near the rim
pod:each(function(x, y) local k = K(x, y)
  if cav:has(x, y) then return end
  local s, t = PS[k], PT[k]
  if s < -0.42 and s > -0.62 and t > 0.06 and t < 0.95 then c:put(x, y, POD[min(6, (pidx[k] or 3) + 1)], ptok) end
  if abs(s) > 0.7 and X.hash(x, y, 7) > 0.8 and t > 0.05 and t < 0.97 then c:put(x, y, s < 0 and HAIR or POD[4], ptok) end
end)
-- cavity lining (concave: lit on the lower-right wall)
local ln = {}
cav:each(function(x, y) local n = pn[K(x, y)] ln[K(x, y)] = { -n[1] * 0.8, -n[2] * 0.8, n[3] } end)
local lbias = {}
-- beans
local beans = {}
for i, t in ipairs{ 0.35, 0.45, 0.555, 0.66, 0.76 } do
  local x, y = A.bez(P, t)
  local x2, y2 = A.bez(P, t + 0.01)
  local ang = math.atan(y2 - y, x2 - x)
  local r = 2.4 - (i == 1 and 0.3 or 0) - (i == 5 and 0.4 or 0)
  local m, n = A.oval(x - 0.3, y - 0.3, r + 0.3, r - 0.2, ang, 0.9)
  beans[i] = { m = m, n = n, x = x, y = y, ang = ang }
  A.cast(lbias, cav, m, 1, 1, -2)
end
for _, b in ipairs(beans) do X.ao(lbias, cav, b.m, 1, -1) end
A.shade(c, cav, ln, LIN, { amb = 0.2, wrap = 0.35, bias = lbias, tok = { r = { name = "lining" } } })

local function bean(b, i, tok)
  local bb = {}
  for j = i + 1, #beans do A.cast(bb, b.m, beans[j].m, 0, 0, 0) end
  local idx = A.shade(c, b.m, b.n, BEAN, { amb = 0.1, wrap = 0.3, bias = bb, tok = tok })
  -- hilum: short white dash on the lower-right flank, along the bean
  local ca, sa = math.cos(b.ang), math.sin(b.ang)
  for _, u in ipairs{ -0.6, 0.6 } do
    local hx, hy = floor(b.x + u * ca + 0.9 * (-sa) + 0.2), floor(b.y + u * sa + 0.9 * ca + 0.2)
    if b.m:has(hx, hy) then c:put(hx, hy, HIL, tok) end
  end
  local sx, sy = A.specAt(b.m, b.n, 40)
  if sx then c:put(sx, sy, "#e8f4b0", tok) end
end
for i, b in ipairs(beans) do bean(b, i, { r = { name = "bean" .. i } }) end

-- quirk: a loose bean that rolled out under the pod
local lb = { }
lb.m, lb.n = A.oval(41.5, 48.5, 2.6, 2.1, -0.5, 0.9)
lb.x, lb.y, lb.ang = 41.2, 48.2, -0.5
bean(lb, 1, { r = { name = "loose" } })

A.save(c, NAME)
