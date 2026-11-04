-- broken-fine-felling-axe (aB11_0, Opus single pass). A fine felling axe: long slender hickory haft with a gentle
-- S-curve and a swelled fawn-foot knob, a narrow forged head (square poll, slim cheeks, flared bit) with the haft end
-- and wedge showing through the eye. Material: tube light + grain streaks on the haft, 6-tone steel with a ground
-- bevel band, bright honed edge, specular glint, darker poll face, AO under the head.
-- broken: a chip is knocked out of the edge (the steel chip flies off) and the haft is split along the grain just
-- under the head (real gap) with a splinter lifting. quirk: a red leather thong loops through the knob.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_0.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.start("broken-fine-felling-axe")
local WD, ST = A.HICK, A.STEEL

-- haft
local hp = { { 15, 55 }, { 23, 45 }, { 34, 30 }, { 43, 15 } }
local function hw(t)
  if t < 0.06 then return 2.3 end
  if t < 0.1 then return 2.3 - (t - 0.06) / 0.04 * 0.9 end
  return 1.4 + (t > 0.85 and (t - 0.85) * 1.5 or 0)
end
local hm, hn, HT, HS, hsm = G.tube(hp, hw)
local hb = {}
hm:each(function(x, y) local k = K(x, y) if HT[k] > 0.97 then hb[k] = 1 end end)
local hidx = A.toneN(c, hm, hn, WD, { bias = hb, amb = 0.1 })
A.grain(c, hm, HT, HS, 50, WD, 5, hidx)
-- pale end grain on the knob bottom
for _, p in ipairs{ { 13, 56 }, { 14, 57 } } do if hm:has(p[1], p[2]) then c:px(p[1], p[2], WD[5]) end end

-- head frame
local ux, uy = hp[4][1] - hp[3][1], hp[4][2] - hp[3][2]
local l = sqrt(ux * ux + uy * uy) ux, uy = ux / l, uy / l          -- up the haft
local ax, ay = -uy, ux                                             -- toward the bit (right / down)
if ax < 0 then ax, ay = -ax, -ay end
local ox, oy = hp[4][1] - ux * 4.2, hp[4][2] - uy * 4.2
-- frame b axis is (-ay, ax): down the haft
local function edgeA(b) return 14.2 - 0.04 * b * b end
local function shape(a, b)
  if a < -6 then return false end
  if a < -2.5 then return abs(b) <= 2.6 end
  if a < 2.5 then return abs(b) <= 3.0 end
  if a < 8 then return abs(b) <= 2.1 + (a - 2.5) * 0.05 end
  if a > edgeA(b) then return false end
  return b >= -(2.4 + (a - 8) * 0.6) and b <= 2.4 + (a - 8) * 0.85
end
local head, U, V = A.frame(ox, oy, ax, ay, shape, 22)
local n = X.pillow(head, 2)
local bias = {}
head:each(function(x, y) local k = K(x, y)
  local a, b = U[k], V[k]
  local e = edgeA(b)
  if a > e - 3.2 and a <= e - 1 then bias[k] = 1 end
  if a > e - 4.2 and a <= e - 3.2 then bias[k] = -1 end
  if a < -5 then bias[k] = (bias[k] or 0) + 1 end
end)
local hidx2 = A.toneN(c, head, n, ST, { bias = bias, amb = 0.12, wrap = 0.3 })
-- honed edge
head:each(function(x, y) local k = K(x, y) if U[k] > edgeA(V[k]) - 1 then c:px(x, y, ST[6]) end end)
-- poll face line, eye ridge
head:each(function(x, y) local k = K(x, y)
  if U[k] >= -6 and U[k] < -5.2 then c:px(x, y, ST[5]) end
  if U[k] >= 2.5 and U[k] < 3.3 and abs(V[k]) < 2.4 then c:px(x, y, ST[max(1, (hidx2[k] or 3) - 1)]) end
end)
-- glint on the cheek
local function at(a, b) return floor(ox + a * ax - b * ay + 0.5), floor(oy + a * ay + b * ax + 0.5) end
local gx, gy = at(6, -1.2) c:px(gx, gy, A.CREAM)
local gx2, gy2 = at(7, -1.2) c:px(gx2, gy2, ST[6])
-- haft end + wedge through the eye (top side)
local ex, ey = at(0, -3.6)
c:px(ex, ey, WD[6]) c:px(ex - 1, ey, WD[5]) c:px(ex + 1, ey, WD[4])
c:px(ex, ey - 1, WD[5])
-- AO on the haft just under the head
hm:each(function(x, y) local k = K(x, y)
  if not head:has(x, y) and head:grow(1):has(x, y) and HT[k] < 0.97 then c:px(x, y, WD[1]) end end)

-- broken: chip knocked out of the edge
local notch = A.frame(ox, oy, ax, ay, function(a, b) return abs(b - 4.2) < 1.8 and a > 12.0 + abs(b - 4.2) * 0.9 end, 22)
A.erase(c, notch)
local cx, cy = at(18, 6.5)
A.map(c, cx, cy, { "ab", "bcd" }, { a = ST[6], b = ST[4], c = ST[3], d = ST[2] })
-- haft split along the grain (real gap) + lifting splinter
local pts = {}
for i = 0, 6 do
  local s = hsm[floor((0.64 + i * 0.022) * 160) + 1]
  pts[#pts + 1] = { floor(s.x + s.px * s.w * 0.15 + 0.5), floor(s.y + s.py * s.w * 0.15 + 0.5) }
end
A.gap(c, pts, 1)
do
  local s = hsm[floor(0.635 * 160) + 1]
  local x, y = floor(s.x - s.px * (s.w + 1) + 0.5), floor(s.y - s.py * (s.w + 1) + 0.5)
  c:px(x, y, WD[6]) c:px(x - 1, y + 1, WD[5])
end

-- quirk: red leather thong through the knob
A.map(c, 10, 57, {
  ".ab..",
  "a..c.",
  "b..c.",
  ".bcd.",
}, { a = "#ff8a5c", b = "#e8493b", c = "#b52e3f", d = "#6e2038" })
A.save(c, "broken-fine-felling-axe")
