-- bamboo-shoot (final, aR3_2 single pass). A slim conical bamboo shoot on the diagonal: overlapping papery sheaths
-- (mottled brown-tan, fine lengthwise hairs, a lit lip and a dark crease row at every sheath edge, a pointed sheath
-- blade at each apex, alternating sides), greening toward a tight leafy tip; the base is a fresh cut showing pale
-- cream flesh with concentric end-grain rings inside a thin rind of sheath layers.
-- quirk: one sheath has come loose and peels back in a curl, showing its glossy pale inner face.
local NAME = "bamboo-shoot"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR3_2.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)

local SH = { "#2f1f24", "#4f3029", "#774a33", "#9e6d40", "#c69552", "#e8c27c" }   -- sheath brown-tan
local GR = { "#203f36", "#33603f", "#4c8344", "#73a64c", "#a3c860", "#d6e88e" }   -- young green
local OL = { "#2e3430", "#4c5236", "#71733f", "#99984e", "#c2bd68", "#e6dc92" }   -- olive transition
local FL = { "#7a5a3c", "#b8955e", "#dcc088", "#efdcaa", "#fff0cc" }              -- cut flesh
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

local P = { { 17, 51 }, { 25, 41 }, { 36, 26 }, { 46, 11 } }
local function W(t) return 0.5 + 6.6 * (1 - t ^ 1.8) end
local m, n, T, S = G.tube(P, W)
do -- flatten the base: drop the round cap behind the cut
  local ax, ay = G.bez(P, 0) local bx, by = G.bez(P, 0.02) local l = sqrt((bx-ax)^2 + (by-ay)^2)
  local cut = {} m:each(function(x, y) if ((x - ax) * (bx - ax) + (y - ay) * (by - ay)) / l < -0.2 then cut[#cut+1] = K(x, y) end end)
  for _, k in ipairs(cut) do m.s[k] = nil end
end
local len = 0
do local lx, ly = G.bez(P, 0) for i = 1, 60 do local x, y = G.bez(P, i / 60) len = len + sqrt((x - lx)^2 + (y - ly)^2) lx, ly = x, y end end

-- sheath scales: each sheath's top edge is a chevron pointing up the shoot, apex alternating left/right of centre
local B = { { 0.13, 0.3 }, { 0.26, -0.35 }, { 0.39, 0.3 }, { 0.51, -0.3 }, { 0.62, 0.3 }, { 0.72, -0.25 }, { 0.81, 0.2 } }
local SL = 0.12
local function bnd(i, s) return B[i][1] + SL * (1 - min(1, abs(s - B[i][2]) * 1.3)) end
local function sheathOf(t, s) local j = 0 for i = 1, #B do if t > bnd(i, s) then j = i end end return j end
local function rampOf(j) if j <= 3 then return SH elseif j <= 4 then return OL else return GR end end
local function frame(t) local x, y = G.bez(P, t) local x2, y2 = G.bez(P, min(1, t + 0.01)) local x1, y1 = G.bez(P, max(0, t - 0.01))
  local tx, ty = x2 - x1, y2 - y1 local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
  local px, py = -ty, tx if px + py < 0 then px, py = -px, -py end return x, y, tx, ty, px, py end

local v = X.light(n, { amb = 0.1, wrap = 0.3 })
local tok = { r = { name = "sheath" } }
local SJ = {}
m:each(function(x, y) local k = K(x, y)
  local t, s = T[k], S[k]
  local j = sheathOf(t, s)
  SJ[k] = j
  local R = rampOf(j)
  local i = 1 for q, cu in ipairs(CUTS) do if v[k] >= cu then i = q + 1 end end
  if j % 2 == 1 and j <= 4 then i = i - 0 end
  local crease, lip = false, false
  if j < #B then local d = (bnd(j + 1, s) - t) * len if d < 1.0 then lip = true end end
  if j > 0 then local d = (t - bnd(j, s)) * len if d < 1.0 then crease = true elseif d < 2.2 then i = i - 1 end end
  -- lengthwise hair striations on the brown sheaths
  if j <= 4 and not lip and abs(s) < 0.75 then local f = (s * 3.2 + 10) % 1 if f < 0.12 and i > 3 then i = i - 1 end end
  -- dark hairy mottling on the lower sheaths
  local speck = j <= 3 and X.hash(x, y, 11) > 0.94 and not lip
  if lip then i = i + 2 end
  if speck then i = i - 2 end
  i = max(1, min(6, i))
  if crease then i = (s > -0.2) and 1 or 2 end
  c:put(x, y, R[i], tok)
end)
-- sheath blades: a small pointed green blade lying on the shoot above each chevron apex
local btok = { r = { name = "blade" } }
for i = 2, #B do
  local ta = B[i][1] + SL
  local x, y, tx, ty, px, py = frame(ta)
  local o = B[i][2] * W(ta)
  local ax, ay = x + px * o - tx * 0.6, y + py * o - ty * 0.6
  local L = 2.6 + (1 - ta) * 3.5
  local bm, bn = G.tube({ { ax, ay }, { ax + tx * L * 0.35, ay + ty * L * 0.35 }, { ax + tx * L * 0.7, ay + ty * L * 0.7 }, { ax + tx * L, ay + ty * L } },
    function(t) return 1.05 * (1 - t) ^ 0.8 + 0.15 end)
  bm:clip(m)
  local R = (i <= 3) and OL or GR
  X.tone(c, bm, X.light(bn, { amb = 0.2, wrap = 0.3 }), R, { cuts = CUTS, tok = btok })
  bm:each(function(xx, yy) local k = K(xx, yy) if bm:has(xx + 1, yy) == false and m:has(xx + 1, yy) then c:put(xx + 1, yy, rampOf(SJ[K(xx+1,yy)] or 0)[1], tok) end end)
end

-- tip: tight rolled leaf point with a second blade peeking out
do
  local x, y, tx, ty, px, py = frame(0.93)
  local tm, tn = G.tube({ { x, y }, { x + tx * 2, y + ty * 2 }, { x + tx * 4 - px * 1.5, y + ty * 4 - py * 1.5 }, { x + tx * 6 - px * 2.5, y + ty * 6 - py * 2.5 } },
    function(t) return 1.2 * (1 - t) + 0.25 end)
  tm:cut(m)
  X.tone(c, tm, X.light(tn, { amb = 0.15, wrap = 0.3 }), GR, { cuts = CUTS, tok = btok })
end

-- cut base: flat elliptical face (faces lower-left, a little turned from the light) with end-grain rings
do
  local x, y, tx, ty, px, py = frame(0)
  local cx, cy = x - tx * 0.6, y - ty * 0.6
  local ra, rb = W(0) + 0.35, 3.0
  local cm = G.rell(cx, cy, px, py, ra, rb)
  local ftok = { r = { name = "flesh" } }
  cm:each(function(xx, yy)
    local dx, dy = xx - cx, yy - cy
    local a, b = (dx * px + dy * py) / ra, (dx * tx + dy * ty) / rb
    local r = sqrt(a * a + b * b)
    local hex
    if r > 0.86 then hex = (a > 0.2) and SH[2] or SH[3]
    elseif r > 0.72 then hex = FL[2]
    elseif r > 0.56 then hex = (a > 0.3) and FL[2] or FL[3]
    elseif r > 0.44 then hex = FL[2]
    elseif r > 0.16 then hex = (a < -0.1 and b < 0.3) and FL[5] or FL[4]
    else hex = FL[3] end
    if a > 0.45 and r <= 0.86 and r > 0.16 and hex ~= FL[2] then hex = FL[3] end
    c:put(xx, yy, hex, ftok)
  end)
  -- dark seat row where the cut face meets the sheath body (ambient)
  local rim = cm:grow(1):cut(cm) rim:each(function(xx, yy) if m:has(xx, yy) then
    local d = (xx - cx) * tx + (yy - cy) * ty if d > 0 then c:put(xx, yy, SH[1], tok) end end end)
end

-- quirk: a loose sheath peeling back off the lit side, curling out and down
do
  local t0 = 0.33
  local x, y, tx, ty, px, py = frame(t0)
  local w = W(t0)
  local ax, ay = x - px * (w - 0.6), y - py * (w - 0.6)
  local pp = { { ax + tx * 1, ay + ty * 1 }, { ax - px * 3 + tx * 3, ay - py * 3 + ty * 3 }, { ax - px * 6 + tx * 2, ay - py * 6 + ty * 2 }, { ax - px * 6.5 - tx * 1.5, ay - py * 6.5 - ty * 1.5 } }
  local qm, qn, QT, QS = G.tube(pp, function(t) return 2.5 * (1 - t) ^ 0.9 + 0.35 end)
  qm:cut(m)
  local qtok = { r = { name = "peel" } }
  local qv = X.light(qn, { amb = 0.15, wrap = 0.3 })
  local INNER = { "#6a4a38", "#a3815c", "#d0b384", "#ead2a0", "#f8e8c0", "#fff4d6" }
  qm:each(function(xx, yy) local k = K(xx, yy)
    local i = 1 for q, cu in ipairs(CUTS) do if qv[k] >= cu then i = q + 1 end end
    -- outer (brown) face where it still faces away, glossy pale inner face on the curl
    local R = (QT[k] < 0.55) and SH or INNER
    if QT[k] > 0.85 then i = i - 1 end
    c:put(xx, yy, R[max(1, min(6, i))], qtok)
  end)
  -- contact shadow on the body under the peel's root
  qm:shift(1, 1):each(function(xx, yy) if m:has(xx, yy) and not qm:has(xx, yy) then
    local k = K(xx, yy) if T[k] and T[k] < 0.4 then c:put(xx, yy, SH[1], tok) end end end)
  local gx, gy = G.bez(pp, 0.55) c:put(floor(gx + .5), floor(gy - .5), "#fff4d6", qtok)
end

-- one specular glint on the waxy upper sheath
do local bx, by = G.specAt(m, n, 60) if bx then c:put(bx, by, "#fff4d6", tok) end end

G.save2(c, NAME)
