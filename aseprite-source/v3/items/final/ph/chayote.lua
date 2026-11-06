-- chayote (final, Opus aB1r1_3). A slim, slightly leaning pear-shaped chayote: pale waxy green with five soft
-- longitudinal furrows that deepen and pinch into a puckered mouth at the bottom, a few soft prickle bumps,
-- cool waxy bloom on the lit shoulder, one specular, cool reflected light on the lower-right; woody stem stub with
-- a paler cut end and ambient shading where it sits in the neck. Small ground shadow.
-- quirk: a curly vine tendril still springs from the stem in a tight spiral.
local NAME = "chayote"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r1_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, cos, pi, sqrt = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi, math.sqrt
local c = A.new(NAME)
local GR = { "#21483e", "#336a46", "#4f8e4e", "#77b45c", "#a3d277", "#d0eca2" }
local WOOD = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local TEN = { "#3f9150", "#7cc35a", "#c4e07a" }

c:groundShadow(32, 55, 11, 1.4)

-- body: half-width per row, top narrow neck, widest low; lean: centre shifts left toward the top
local YT, YBt = 16, 54
local function cx(y) return 32 + (y - 40) * 0.08 end
local function hw(y)
  local t = (y - YT) / (YBt - YT)
  local w
  if t > 0.62 then w = 13.2 * sqrt(max(0, 1 - ((t - 0.62) / 0.41) ^ 2))
  else w = 4 + 9.2 * sin(pi / 2 * t / 0.62) ^ 1.4 end
  if t < 0.06 then w = min(w, 2.5 + t * 30) end
  return w
end
local m = HP.mask()
for y = YT, YBt do local w, c0 = hw(y), cx(y)
  for x = floor(c0 - w - 1), floor(c0 + w + 1) do if abs(x + 0.5 - c0) <= w then m:set(x, y) end end end
-- bottom pucker: shallow notch in the base outline
m:cut(c:rect(31, 54, 33, 54))

-- normals: round pillow plus furrow ripple across (lower 2/3)
local pn = X.pillow(m, 8)
local U = {}
local n = {}
m:each(function(x, y) local k = K(x, y)
  local u = (x + 0.5 - cx(y)) / max(1, hw(y))
  U[k] = u
  local t = (y - YT) / (YBt - YT)
  local amp = 0.45 * max(0, (t - 0.25) / 0.75)
  local rip = sin(u * pi * 2.5) * amp
  local p = pn[k]
  n[k] = { A.norm(p[1] + rip, p[2], p[3]) }
end)
local tok = A.tok("chayote")
local stemm = c:rect(29, 12, 31, 17)
local b = {}
X.ao(b, m, stemm, 1, -1)
local idx = A.shade(c, m, n, GR, { bias = b, tok = tok, amb = 0.12, wrap = 0.3 })
-- furrows: dark grooves at u = -0.8,-0.4,0,0.4,0.8 converging to the pucker; deeper toward the bottom
m:each(function(x, y) local k = K(x, y)
  local t = (y - YT) / (YBt - YT)
  if t < 0.3 then return end
  local u = U[k] * 2.5
  local fr = abs(u - floor(u + 0.5))
  if fr < 0.11 + 0.06 * t then A.step(c, idx, GR, x, y, t > 0.7 and -2 or -1, tok) end
end)
-- puckered mouth
for _, q in ipairs{ { 31, 53, 1 }, { 32, 53, 1 }, { 33, 53, 1 }, { 30, 52, 2 }, { 34, 52, 2 }, { 32, 52, 2 }, { 31, 51, 4 }, { 33, 51, 3 } } do
  if m:has(q[1], q[2]) then c:put(q[1], q[2], GR[q[3]], tok) end end
-- soft prickle bumps (lit top pixel + dark under)
for _, q in ipairs{ { 25, 39 }, { 37, 44 }, { 28, 48 }, { 40, 36 } } do
  if m:has(q[1], q[2] + 1) then c:put(q[1], q[2], GR[6], tok) c:put(q[1], q[2] + 1, GR[2], tok) end end
-- waxy bloom: cool pale flecks on the lit shoulder
for _, q in ipairs{ { 24, 30 }, { 26, 27 }, { 22, 35 }, { 25, 33 }, { 28, 25 } } do if m:has(q[1], q[2]) then c:put(q[1], q[2], "#cfe8d6", tok) end end
-- cool reflected light on the lower-right edge
m:edge():each(function(x, y) if x > cx(y) + hw(y) * 0.55 and y > 34 and y < 53 then c:put(x, y, "#5f9a8a", tok) end end)
-- specular
c:put(24, 23, "#f2fbd8", tok) c:put(25, 23, GR[6], tok) c:put(24, 24, GR[6], tok)

-- stem stub: woody, flared foot, pale cut end
local wtok = A.tok("stem")
for y = 12, 17 do
  c:put(29, y, WOOD[3], wtok) c:put(30, y, WOOD[2], wtok) c:put(31, y, WOOD[1], wtok)
end
c:put(28, 17, WOOD[2], wtok) c:put(32, 17, WOOD[1], wtok)
c:put(29, 11, WOOD[4], wtok) c:put(30, 11, WOOD[4], wtok) c:put(31, 11, WOOD[3], wtok)
c:put(29, 14, WOOD[4], wtok)

-- quirk: tendril spiral from the stem to the upper right
local ttok = A.tok("tendril")
A.pline(c, { { 32, 13 }, { 34, 12 }, { 37, 11 } }, TEN[1], ttok)
local pts = {}
for i = 0, 34 do
  local a = i / 34 * 2.6 * pi
  local r = 4.2 - i / 34 * 2.8
  pts[#pts + 1] = { floor(41 + cos(a + pi) * r + 0.5), floor(11 + sin(a + pi) * r * 0.9 + 0.5) }
end
for i = 1, #pts do local p = pts[i]
  if not m:has(p[1], p[2]) then c:put(p[1], p[2], (i % 5 == 0) and TEN[3] or TEN[2], ttok) end end
A.save(c, NAME)
