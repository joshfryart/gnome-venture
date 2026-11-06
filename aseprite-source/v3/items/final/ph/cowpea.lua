-- cowpea (final, Opus single pass). One long slim cowpea pod in a lazy S from a short peduncle at the top right
-- to a pointed beak at the lower left. Beaded: the wall swells over each of seven peas and pinches between them
-- (valley shading), waxy bloom flecks, a pale dorsal suture line on the lit edge, a darker ventral seam, a
-- six-tone lime-to-jade ramp with a cool reflected edge. Calyx cup with AO where the pod joins the stalk.
-- quirk: one pea has split its window open near the middle and peeks out, black eye and all.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB22_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local NAME = "cowpea"
local c = A.new(NAME)
local POD = { "#1f4a3e", "#2f6a46", "#4a8c4c", "#6eac56", "#98c862", "#c8e486" }
local BLOOM, COOL = "#dcefa8", "#4c8a86"
local STALK = { "#28503c", "#3e7444", "#5e9a4e", "#8cbc62" }
local PEA = { "#8a6a5a", "#c4a184", "#e8cfa6", "#fff0cc" }
local EYE = "#2b1c26"

local path = { { 48, 13 }, { 42, 34 }, { 29, 46 }, { 11, 53 } }
local NB = 7
local function bead(t) return cos((t * NB - 0.15) * 2 * pi) end -- +1 over a pea, -1 between
local pm, pn, PT, PS = A.tube(path, function(t)
  local taper = min(1, t / 0.08) ^ 0.6 * min(1, (1 - t) / 0.13) ^ 0.8
  return max(0.4, (2.9 + 0.55 * bead(t)) * taper + 0.35)
end)
-- beak: thin hooked tip beyond the end
local bm, bn = A.tube({ { 12, 53 }, { 8, 54 }, { 6, 53 }, { 5, 51 } }, function(t) return 0.9 - t * 0.5 end)
bm:cut(pm)
-- tone: base light + pinch valleys + calyx AO near the top
local bias = {}
pm:each(function(x, y) local k = K(x, y)
  local t, s = PT[k], PS[k]
  local b = bead(t)
  if b < -0.55 and abs(s) < 0.85 then bias[k] = -1 end
  if t < 0.07 then bias[k] = (bias[k] or 0) - 1 end
end)
local tok = { r = { name = "pod" } }
local idx = A.shade(c, pm, pn, POD, { bias = bias, tok = tok, amb = 0.1, wrap = 0.3 })
A.shade(c, bm, bn, POD, { tok = tok, amb = 0.12, wrap = 0.3 })
-- bulge highlight on each pea's lit shoulder, dorsal suture, ventral seam, cool rim, bloom flecks
pm:each(function(x, y) local k = K(x, y)
  local t, s = PT[k], PS[k]
  local b = bead(t)
  if t > 0.1 and t < 0.9 then
    if b > 0.6 and s > -0.6 and s < -0.25 then c:put(x, y, POD[min(6, idx[k] + 1)], tok) end
    if s < -0.82 and b > -0.4 then c:put(x, y, POD[6], tok) end
    if s > 0.84 then c:put(x, y, COOL, tok) end
    if s > 0.55 and s < 0.7 and b < -0.2 then c:put(x, y, POD[max(1, idx[k] - 1)], tok) end
  end
  if X.hash(x, y, 7) > 0.93 and s > -0.5 and s < 0.4 and idx[k] >= 3 and t > 0.12 and t < 0.88 then c:put(x, y, BLOOM, tok) end
end)
-- specular: 2x1 on the third pea
do local x, y = A.bez(path, (2 + 0.15) / NB) c:put(floor(x - 1.5), floor(y - 1.8), "#f4ffd8", tok) c:put(floor(x - 0.5), floor(y - 1.8), "#f4ffd8", tok) end

-- quirk: split window over the 4th pea with the pea peeking out
do
  local t = (3 + 0.15) / NB
  local x, y = A.bez(path, t)
  local x2, y2 = A.bez(path, t + 0.01)
  local ux, uy = x2 - x, y2 - y local l = math.sqrt(ux*ux + uy*uy) ux, uy = ux / l, uy / l
  local win = A.rell(x + 0.3, y - 0.2, ux, uy, 3.6, 2.0)
  local lip = win:grow(1):cut(win):clip(pm)
  lip:each(function(px, py) c:put(px, py, (px + py < x + y) and POD[1] or POD[2], tok) end)
  local pea, pnn = A.oval(x + 0.2, y - 0.4, 2.9, 1.9, math.atan(uy, ux), 0.9)
  pea:clip(win)
  local ptok = { r = { name = "pea" } }
  A.shade(c, pea, pnn, PEA, { tok = ptok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
  -- black eye with a pale hilum slit
  local ex, ey = floor(x + 0.5), floor(y - 0.4 + 0.5)
  for _, q in ipairs{ { 0, 0 }, { 1, 0 }, { -1, 0 }, { 0, 1 }, { 1, 1 } } do c:put(ex + q[1], ey + q[2], EYE, ptok) end
  c:put(ex, ey, "#6a4a5a", ptok)
  c:put(ex - 2, ey - 1, "#fff8e0", ptok)
end

-- calyx cup + peduncle
local stok = { r = { name = "stalk" } }
local sm, sn = A.tube({ { 48, 13 }, { 49, 10 }, { 51, 7 }, { 53, 6 } }, function(t) return 1.2 - t * 0.2 end)
sm:cut(pm)
A.shade(c, sm, sn, STALK, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
local cal = HP.mask()
for _, q in ipairs{ { 46, 13 }, { 47, 13 }, { 48, 13 }, { 49, 13 }, { 50, 13 }, { 47, 12 }, { 48, 12 }, { 49, 12 }, { 45, 14 }, { 51, 14 }, { 50, 15 } } do cal:set(q[1], q[2]) end
cal:each(function(x, y) c:put(x, y, (x < 48) and STALK[3] or STALK[2], stok) end)
c:put(46, 14, STALK[1], stok) c:put(49, 15, STALK[1], stok)
c:put(51, 7, STALK[4], stok)
-- cut end of the peduncle: pale ring
c:put(53, 6, "#c8e0a0", stok) c:put(54, 5, "#a8c888", stok)

A.save(c, NAME)
