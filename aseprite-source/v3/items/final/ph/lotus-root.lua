-- lotus-root (final, Opus single pass). Two slim segments of lotus rhizome on a diagonal, pinched at a node.
-- Upper-left end is cut and faces the light: pale cream flesh disc with a peel rim, the classic ring of air canals
-- (seven around, two in the centre) as deep violet holes with a lit lower lip. Skin: 6-tone blush-beige cylinder
-- light, faint lengthwise fibre lines, brown lenticel freckles, cool reflected light on the lower-right edge.
-- Node: dark ring with AO both sides, root nubs and a papery scale. Far end tapers to a rounded tip with a bud.
-- quirk: lotus silk, two fine pale threads pulled from the cut face and drifting off in a loop.
local NAME = "lotus-root"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)
local SKIN = { "#4e2a3c", "#7e4652", "#a8666a", "#c88a80", "#e2ae9a", "#f4d0b8" }
local FLESH = { "#d6bc98", "#eedcbc", "#faefd4", "#fff8e6" }
local HOLE = { "#3a2236", "#5e3a4a", "#8a6466" }
local NODE = { "#3e2430", "#62383e", "#86564e" }
local BUD = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local COOL = "#8a7e98"

local AX, AY, BX, BY = 15, 18, 50, 45
local L = sqrt((BX - AX)^2 + (BY - AY)^2)
local ux, uy = (BX - AX) / L, (BY - AY) / L
local TN = 0.5                                   -- node position
local function w(t)
  if t < TN - 0.035 then return 6.6 - 0.6 * (t / TN) ^ 2 - 2.8 * max(0, (t - (TN - 0.12)) / 0.085) ^ 2 end
  if t <= TN + 0.035 then return 3.2 end
  local u = (t - TN - 0.035) / (1 - TN - 0.035)
  local base = 6.2 * min(1, 0.55 + (u / 0.18) ^ 0.5 * 0.45)
  if u > 0.62 then base = base * sqrt(max(0, 1 - ((u - 0.62) / 0.38) ^ 2)) end
  return u > 0.995 and -1 or max(0.8, base)
end
local m, n, T, S = X.cyl(AX, AY, BX, BY, w)
-- slight bow: none; lighting + bias
local bias = {}
m:each(function(x, y) local k = K(x, y)
  local t = T[k]
  local d = abs(t - TN) * L
  if d < 2.6 and d >= 1.5 then bias[k] = -1 end      -- AO beside the node
end)
local stok = { r = { name = "skin" } }
local idx = A.shade(c, m, n, SKIN, { amb = 0.1, wrap = 0.35, bias = bias, tok = stok })
-- fibre lines + freckles
m:each(function(x, y) local k = K(x, y)
  local s, t = S[k], T[k]
  if abs(t - TN) * L < 1.5 then return end
  if (abs(s + 0.45) < 0.07 or abs(s - 0.3) < 0.06) and X.hash(x, y, 2) > 0.35 and idx[k] > 2 then c:put(x, y, SKIN[idx[k] - 1], stok) end
  local h = X.hash(x, y, 9)
  if h > 0.94 and idx[k] >= 3 and abs(s) < 0.8 then c:put(x, y, NODE[3], stok) end
end)
-- cool bounce on the lower-right edge
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.5 and S[k] > 0.6 and idx[k] <= 2 then c:put(x, y, COOL, stok) end end)
-- node ring: dark band across, root nubs under it, papery scale on top
local ntok = { r = { name = "node" } }
m:each(function(x, y) local k = K(x, y)
  if abs(T[k] - TN) * L < 1.5 then
    local i = S[k] < -0.4 and 3 or (S[k] < 0.4 and 2 or 1)
    c:put(x, y, NODE[i], ntok)
  end
end)
local nx, ny = AX + ux * TN * L, AY + uy * TN * L
local px, py = -uy, ux                              -- +perp = lower-left? choose shade side
if px + py < 0 then px, py = -px, -py end
for _, r in ipairs{ { 4.4, -0.8, 2 }, { 4.6, 0.6, 3 }, { 4.2, 1.6, 2 } } do        -- root nubs on the underside
  for s = 0, r[3] - 1 do
    local x, y = floor(nx + px * (r[1] + s) + ux * (r[2] + s * 0.6) + 0.5), floor(ny + py * (r[1] + s) + uy * (r[2] + s * 0.6) + 0.5)
    if not m:has(x, y) then c:put(x, y, s == 0 and NODE[3] or NODE[2], ntok) end
  end
end
-- papery scale leaf wrapping the top of the node
for _, q in ipairs{ { -3.4, 0, 3 }, { -3.0, 1, 3 }, { -2.4, 2, 2 } } do
  local x, y = floor(nx - px * (-q[1]) + ux * q[2] + 0.5), floor(ny - py * (-q[1]) + uy * q[2] + 0.5)
  c:put(x, y, ({ "#a88466", "#d2b48a", "#efd6a8" })[q[3]], ntok)
end
-- bud at the far tip
local btok = { r = { name = "bud" } }
local tx, ty = BX + ux * 0.5, BY + uy * 0.5
for _, q in ipairs{ { 0, 0, 2 }, { 1, 0, 3 }, { 1, -1, 4 }, { 2, -1, 3 }, { 2, -2, 2 } } do
  local x, y = floor(tx + q[1] + 0.5), floor(ty + q[2] + 0.5)
  if not m:has(x, y) then c:put(x, y, BUD[q[3]], btok) end
end

-- cut face at the upper-left end: ellipse across the axis, flesh + air canals
local ftok = { r = { name = "face" } }
local FW = w(0)
local fm = HP.mask()
local fu, fv = {}, {}
for y = floor(AY - 9), floor(AY + 9) do for x = floor(AX - 9), floor(AX + 9) do
  local dx, dy = x - AX, y - AY
  local a = (dx * ux + dy * uy) / 4.6
  local b = (dx * px + dy * py) / (FW + 0.4)
  if a * a + b * b <= 1 then fm:set(x, y) local k = K(x, y) fu[k], fv[k] = a, b end
end end
fm:each(function(x, y) local k = K(x, y)
  local r = sqrt(fu[k]^2 + fv[k]^2)
  local i = 3
  if r > 0.82 then i = 2 end
  if r <= 0.82 and fv[k] - fu[k] < -0.3 then i = 4 end
  if r <= 0.82 and fv[k] + fu[k] > 0.75 then i = 2 end
  c:put(x, y, FLESH[i], ftok)
end)
-- peel rim (skin colour ring just inside the face edge, lower side darker)
fm:edge():each(function(x, y) local k = K(x, y) c:put(x, y, fv[k] > 0.2 and SKIN[3] or SKIN[5], ftok) end)
-- air canals: ring of 7 + 2 central, each a hole with a lit lower lip
local holes = {}
for i = 0, 5 do local a = i / 6 * 2 * pi + 0.5 holes[#holes + 1] = { 0.56 * cos(a), 0.6 * sin(a), 2 } end
holes[#holes + 1] = { -0.1, -0.08, 2 }
for _, h in ipairs(holes) do
  local hx = AX + ux * h[1] * 4.6 + px * h[2] * (FW + 0.4)
  local hy = AY + uy * h[1] * 4.6 + py * h[2] * (FW + 0.4)
  local x, y = floor(hx), floor(hy)
  c:put(x, y, HOLE[1], ftok)
  if h[3] == 2 then c:put(x + 1, y, HOLE[1], ftok) c:put(x, y + 1, HOLE[2], ftok) c:put(x + 1, y + 1, HOLE[3], ftok)
  else c:put(x + 1, y, HOLE[2], ftok) c:put(x, y + 1, FLESH[4], ftok) end
end
-- quirk: lotus silk, two pale threads drawn off the face rim in a drifting loop
local silk = "#f4ece8"
local thr = { { -1, -1 }, { -2, -2 }, { -3, -2 }, { -4, -3 }, { -5, -3 }, { -6, -3 }, { -7, -2 }, { -8, -1 } }
local thr2 = {}
local ex, ey = floor(AX - ux * 2 + 0.5), floor(AY - uy * 2 + 0.5)
for _, q in ipairs(thr) do local x, y = ex + q[1] - 2, ey + q[2] - 2 if not fm:has(x, y) and not m:has(x, y) then c:put(x, y, silk, ftok) end end
for _, q in ipairs(thr2) do local x, y = ex + q[1] + 3, ey + q[2] + 2 if not fm:has(x, y) and not m:has(x, y) then c:put(x, y, "#e2d4d8", ftok) end end
-- one specular on the lit skin of the long segment
local sx, sy = A.specAt(m, n, 50)
c:put(sx, sy, "#fff4e8", stok) c:put(sx + 1, sy, SKIN[6], stok)

A.save(c, NAME)
