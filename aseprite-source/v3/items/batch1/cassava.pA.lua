-- cassava (pass A, Opus). Slim single root lying on the diagonal: fresh cut end top-right, tapering to a root thread.
-- Material: cylinder light (6-tone bark), knobbly ring scars with a lit ridge, lengthwise bark streaks,
-- cut face = bark rim, pink cortex ring, cream starch with the fibrous core.
-- quirk: a strip of bark peels off and curls away, baring the pink under-skin.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "cassava" }
local floor, abs = math.floor, math.abs

local BARK  = { "#33192a", "#4f2a27", "#6d3d2b", "#8c5634", "#ab7243", "#c9925c" }
local PINK  = { "#a8505a", "#cf7a7a", "#eaa59a", "#f8cbb8" }
local FLESH = { "#cbbd9c", "#e6dcbd", "#f6f0da", "#fffbec" }
local bt = { r = { name = "bark" } }

local CP = { {50, 12}, {40, 20}, {27, 36}, {14, 51} }
local RING = 5.5
local function W0(t)
  if t < 0.25 then return 4.4 + 0.5 * t / 0.25 end
  return math.max(0.6, 4.9 * ((1 - t) / 0.75) ^ 0.6)
end
-- arc length approx for ring positions
local _, _, _, _, sm0 = G.tube(CP, function() return 0 end, { steps = 200 })
local len = 0
for i = 2, #sm0 do len = len + math.sqrt((sm0[i].x - sm0[i-1].x)^2 + (sm0[i].y - sm0[i-1].y)^2) end
local function W(t)   -- slight waist at each ring scar: knobbly silhouette
  local ph = (t * len) % RING
  local dip = (ph < 1.2 and t > 0.08 and t < 0.85) and 0.45 or 0
  return W0(t) - dip
end
local m, n, T, S, sm = G.tube(CP, W)
local v = X.light(n, { amb = 0.1, wrap = 0.3 })
local bias = {}
local rings, ridge = {}, {}
m:each(function(x, y)
  local k = K(x, y)
  local t, s = T[k], S[k]
  local d = t * len
  local ph = (d - abs(s) * 0.9) % RING
  if t > 0.06 and t < 0.86 then
    if ph < 0.9 and X.hash(x, y, 2) > 0.15 then rings[k] = true
    elseif ph >= 0.9 and ph < 1.9 and s < -0.15 then ridge[k] = true end
  end
  if abs(s - 0.4 - 0.12 * math.sin(d * 0.35)) < 0.11 and X.hash(x, y, 5) > 0.35 then bias[k] = -1 end
  if abs(s + 0.25 - 0.1 * math.sin(d * 0.5 + 1)) < 0.1 and X.hash(x, y, 6) > 0.5 then bias[k] = 1 end
end)
local idx = G.tone(c, m, v, BARK, nil, bias, bt)
for k in pairs(rings) do local x, y = k % 1024 - 256, k // 1024 - 256 c:put(x, y, BARK[math.max(1, idx[k] - 2)], bt) end
for k in pairs(ridge) do local x, y = k % 1024 - 256, k // 1024 - 256 c:put(x, y, BARK[math.min(6, idx[k] + 1)], bt) end

-- root thread off the tail
G.line(c, { {14, 51}, {12, 54}, {9, 56}, {7, 56}, {6, 58} }, BARK[2])

-- cut face
local tx, ty = sm[1].x - sm[3].x, sm[1].y - sm[3].y
local tl = math.sqrt(tx*tx + ty*ty) tx, ty = tx / tl, ty / tl
local face = G.rell(sm[1].x - tx * 0.3, sm[1].y - ty * 0.3, tx, ty, 2.6, 5.0)
local fe = face:edge()
face:each(function(x, y)
  if fe:has(x, y) then c:px(x, y, (x + y < 60) and PINK[3] or PINK[2])
  else c:px(x, y, FLESH[3]) end
end)
local fc = face:copy():shrink(1)
fc:edge():each(function(x, y) if x + y > 61 then c:px(x, y, FLESH[2]) end end)
c:px(floor(sm[1].x + .5), floor(sm[1].y + .5), FLESH[1])
c:px(floor(sm[1].x - 2), floor(sm[1].y - 1.5), FLESH[4])

-- quirk: peeled patch on the lit side + bark ribbon curling up and back
local P0, P1 = 13, 20
m:each(function(x, y) local k = K(x, y)
  local d, s = T[k] * len, S[k]
  if d > P0 and d < P1 and s < -0.2 then
    local col = PINK[2]
    if s < -0.75 then col = PINK[3] end
    if d < P0 + 1 then col = PINK[1] end            -- torn bark lip casts a dark line
    c:px(x, y, col)
  end
end)
local i0 = floor(#sm * (P1 - 0.5) / len)
local b = sm[i0]
local ex, ey = b.x - b.px * (b.w + 0.4), b.y - b.py * (b.w + 0.4)
local tvx, tvy = -b.py, b.px
if tvx > 0 then tvx, tvy = -tvx, -tvy end                  -- tangent toward the tail (down-left)
local curlO = {}
for _, ab in ipairs{ {0, 0}, {2, 0.6}, {4, 0.4}, {5.2, -1}, {5, -2.8}, {3.6, -3.6} } do
  curlO[#curlO + 1] = { ex - b.px * ab[1] + tvx * ab[2], ey - b.py * ab[1] + tvy * ab[2] }
end
for i, p in ipairs(curlO) do p[1], p[2] = floor(p[1] + .5), floor(p[2] + .5) end
local rib = c:line(curlO, 2)
rib:each(function(x, y) c:px(x, y, BARK[4]) end)
c:line(curlO, 1):each(function(x, y) c:px(x, y, BARK[5]) end)
c:px(curlO[5][1], curlO[5][2], PINK[3])
G.fin(c, "cassava.pA")
