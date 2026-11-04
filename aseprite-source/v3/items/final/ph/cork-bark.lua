-- cork-bark (final pass, Opus single pass). A long, slim curved plank of cork-oak bark lying on its back like a
-- half-pipe: cylinder-lit outer bark in cool grey-brown with deep wavy lengthwise fissures (dark crack + lit lip),
-- knobbly lenticel specks and a torn, ragged left end. The thickness shows as a honey cork lip along the lower edge
-- and a crescent cut face on the right (growth layers, pores) above the dark reddish hollow of the pipe.
-- quirk: a round bottle-cork has been punched straight out of the plank and stands beside the hole it came from.
local NAME = "cork-bark"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local BK  = { "#2a1f24", "#45332f", "#62493e", "#816450", "#a08368", "#c2a88a" }
local HON = { "#7a4224", "#a05c32", "#c47a44", "#de9c5c", "#f0be7e", "#fadca8" }
local HOL = { "#3e1c18", "#5c2a20", "#7e3c28" }
local btok, htok, ktok = { r = { name = "bark" } }, { r = { name = "cork" } }, { r = { name = "stopper" } }

-- stopper shadow first (standing object)
c:groundShadow(50, 54, 6, 1.4)

-- plank: tube along a gentle S curve, lower-left to upper-right
local P = { { 13, 44 }, { 23, 37 }, { 38, 33 }, { 51, 25 } }
local W = 7.2
local m, n, T, S, samp = A.tube(P, function(t)
  if t > 0.995 then return -1 end
  local w = W
  if t < 0.06 then w = W - (0.06 - t) * 40 * (0.5 + 0.5 * X.hash(floor(t * 200), 3, 1)) end -- ragged torn end
  return w
end)
-- ragged left end: bite notches
local cutl = {}
m:each(function(x, y) local k = K(x, y) if T[k] < 0.07 and X.hash(x, y, 9) > 0.55 and abs(S[k]) > 0.3 then cutl[#cutl + 1] = k end end)
for _, k in ipairs(cutl) do m.s[k] = nil end

-- end geometry
local E = samp[#samp]
local ex, ey, px, py, tx, ty = E.x, E.y, E.px, E.py, E.tx, E.ty
local function inEll(x, y, cx, cy, ra, rb)
  local dx, dy = x - cx, y - cy
  local a, b = dx * tx + dy * ty, dx * px + dy * py
  return (a / ra) ^ 2 + (b / rb) ^ 2 <= 1
end
local endface, hollow = HP.mask(), HP.mask()
for y = floor(ey) - 12, floor(ey) + 12 do for x = floor(ex) - 12, floor(ex) + 12 do
  if inEll(x, y, ex, ey, 3.4, W + 0.5) then
    if inEll(x, y, ex + px * 3.6 - tx * 0.4, ey + py * 3.6 - ty * 0.4, 2.6, W - 1.5) then hollow:set(x, y) else endface:set(x, y) end
  end
end end
-- hollow only below the arch (on the +p side of centre)
local hcut = {}
hollow:each(function(x, y) if (x - ex) * px + (y - ey) * py < -1 then hcut[#hcut + 1] = { x, y } end end)
for _, q in ipairs(hcut) do hollow.s[K(q[1], q[2])] = nil endface:set(q[1], q[2]) end
m:cut(endface):cut(hollow)

-- punched hole
local HX, HY = 33, 33
local hole = c:ellipse(HX, HY, 2.6, 2.1)
m:cut(hole)

-- outer bark: cylinder light, fissures, lenticels
local bias = {}
X.ao(bias, m, endface, 1, -1)
local idx = A.shade(c, m, n, BK, { amb = 0.1, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, tok = btok, bias = bias })
local len = 0 for i = 2, #samp do len = len + sqrt((samp[i].x - samp[i - 1].x) ^ 2 + (samp[i].y - samp[i - 1].y) ^ 2) end
local fis = { -0.62, -0.2, 0.22, 0.55 }
local crack = {}
m:each(function(x, y) local k = K(x, y)
  local s, t = S[k], T[k]
  if s > 0.74 then return end
  for i, f in ipairs(fis) do
    local w = f + 0.09 * sin(t * len / 5.5 + i * 1.7) + 0.05 * sin(t * len / 2.1 + i)
    -- break fissures into segments so they read as cracked plates
    local seg = (t * len / 9 + i * 0.37) % 1
    if abs(s - w) < 0.075 and seg < 0.82 and t > 0.04 then crack[k] = true end
  end
end)
for k in pairs(crack) do local x, y = k % 1024 - 256, k // 1024 - 256
  c:put(x, y, BK[1], btok)
  if m:has(x, y - 1) and not crack[K(x, y - 1)] then c:put(x, y - 1, BK[min(6, (idx[K(x, y - 1)] or 3) + 1)], btok) end
  if m:has(x, y + 1) and not crack[K(x, y + 1)] then c:put(x, y + 1, BK[max(1, (idx[K(x, y + 1)] or 3) - 1)], btok) end
end
m:each(function(x, y) local k = K(x, y)
  if crack[k] or S[k] > 0.74 then return end
  local h = X.hash(x, y, 21)
  if h > 0.93 then c:put(x, y, BK[min(6, (idx[k] or 3) + 1)], btok)
  elseif h < 0.05 then c:put(x, y, BK[max(1, (idx[k] or 3) - 1)], btok) end
end)
-- honey cork lip along the lower edge (thickness), darker toward the shade end
m:each(function(x, y) local k = K(x, y)
  if S[k] > 0.74 then
    local i = (S[k] > 0.88) and 3 or 4
    if T[k] > 0.7 then i = i - 1 end
    if X.hash(x, y, 5) > 0.82 then i = i - 1 end
    c:put(x, y, HON[max(1, i)], htok)
  end
end)
-- one dark row where bark meets the lip
m:each(function(x, y) local k = K(x, y) if S[k] > 0.62 and S[k] <= 0.74 and not crack[k] then c:put(x, y, BK[2], btok) end end)
-- specular streak on the bark crest (upper-left)
for i = 0, 3 do local s = samp[floor(#samp * (0.25 + i * 0.03))]
  local x, y = floor(s.x - s.px * W * 0.55 + 0.5), floor(s.y - s.py * W * 0.55 + 0.5)
  if m:has(x, y) and not crack[K(x, y)] then c:put(x, y, BK[6], btok) end end

-- cut end: crescent of cork with growth layers + pores, hollow interior below
endface:each(function(x, y)
  local d = (x - ex) * px + (y - ey) * py          -- across the arch
  local a = (x - ex) * tx + (y - ey) * ty
  local i = 4
  if a > 1.2 then i = 3 end
  if abs(d) > W - 1 then i = i - 1 end
  if (floor(d + 20) % 3) == 0 then i = i - 1 end   -- growth layers
  if X.hash(x, y, 13) > 0.86 then i = 2 end        -- pores
  if a < -1.5 and d < -2 then i = 5 end            -- lit rim
  c:put(x, y, HON[max(1, min(6, i))], htok)
end)
-- bark skin rim on the outer arch of the end
endface:each(function(x, y) local d = (x - ex) * px + (y - ey) * py
  if d < -(W - 1.2) or (not endface:has(x - 1, y) and not m:has(x - 1, y) and d < 0) then c:put(x, y, BK[3], btok) end end)
hollow:each(function(x, y) local d = (x - ex) * px + (y - ey) * py
  c:put(x, y, HOL[(d > 4) and 3 or ((d > 2) and 2 or 1)], htok) end)

-- hole: dark depth upper-left, honey wall lower-right
hole:each(function(x, y)
  local dx, dy = x - HX, y - HY
  local col = HOL[1]
  if dx + dy > 0.6 then col = HON[3] end
  if dx + dy > 2.2 then col = HON[4] end
  c:put(x, y, col, htok)
end)
-- AO rim around the hole top edge
hole:grow(1):cut(hole):each(function(x, y) if m:has(x, y) and (x - HX) + (y - HY) < 0 then c:put(x, y, BK[2], btok) end end)

-- quirk: the punched bottle-cork standing in front, lower right
local KX0, KX1, KY0, KY1 = 46, 54, 44, 53
local body = c:rect(KX0, KY0 + 1, KX1, KY1)
body:add(c:rect(KX0 + 1, KY1 + 1, KX1 - 1, KY1 + 1))
local nk = {}
body:each(function(x, y) local t = max(-0.95, min(0.95, ((x - KX0) / (KX1 - KX0)) * 2 - 1))
  nk[K(x, y)] = { t, 0, sqrt(1 - t * t) } end)
local kb = {}
X.ao(kb, body, c:rect(KX0, KY0 - 2, KX1, KY0), 1, -1)
local kidx = A.shade(c, body, nk, HON, { amb = 0.1, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, tok = ktok, bias = kb })
body:each(function(x, y) local k = K(x, y)
  if X.hash(x, y, 31) > 0.84 then c:put(x, y, HON[max(1, (kidx[k] or 3) - 2)], ktok) end end)
-- top face: ellipse, lighter, growth ring and pores
local top = c:ellipse(50, KY0 + 0.5, 4.4, 1.7)
top:each(function(x, y) c:put(x, y, (x < 49) and HON[6] or HON[5], ktok) end)
for _, q in ipairs{ { 48, KY0 }, { 52, KY0 + 1 }, { 50, KY0 + 1 } } do c:put(q[1], q[2], HON[4], ktok) end
-- tiny bark skin band near the top (it came from the outer face)
for x = KX0, KX1 do c:put(x, KY0 + 2, (x < 49) and BK[4] or BK[3], ktok) end
c:put(47, 47, HON[6], ktok) c:put(47, 48, HON[6], ktok)

A.save(c, NAME)
