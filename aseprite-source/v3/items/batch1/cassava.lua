-- cassava (pass B, final, Opus). Slim single root lying on the diagonal with a gentle S bend: fresh cut end
-- top-right, tapering through knobbly ring scars to a forked root thread bottom-left.
-- Material: cylinder light (6-tone bark, cool-violet shade), ring scars = 1 px dark crease + lit ridge on the
-- cut-end side and a notch in the silhouette, lengthwise bark streaks, flaky paler bark scales on the lit side.
-- Cut face = dark bark rim, pink cortex ring, cream starch (shaded lower-right), fibrous core, moist glint.
-- History: cassava.pA (pass A). Draft by Sonnet replaced.
-- quirk: a strip of bark peels off and rolls back into a curl (brown outside, pink inside), baring the pink under-skin.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "cassava" }
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local function XY(k) return k % 1024 - 256, k // 1024 - 256 end

local BARK  = { "#2f1729", "#4c2730", "#6c3a2f", "#8d5536", "#ad7343", "#cc955b" }
local FLAKE = "#dcb07a"
local PINK  = { "#8e3d50", "#c56877", "#e4949a", "#f6c2b6" }
local FLESH = { "#c4b28e", "#e2d5b3", "#f4ecd4", "#fffaea" }
local bt = { r = { name = "bark" } }

local CP = { {51, 11}, {41, 18}, {29, 37}, {15, 50} }
local RING = 5.4
local _, _, _, _, sm0 = G.tube(CP, function() return 0 end, { steps = 200 })
local len = 0
for i = 2, #sm0 do len = len + sqrt((sm0[i].x - sm0[i-1].x)^2 + (sm0[i].y - sm0[i-1].y)^2) end
local function W0(t)
  if t < 0.22 then return 4.1 + 0.7 * t / 0.22 end
  return max(0.7, 4.8 * ((1 - t) / 0.78) ^ 0.38)
end
local function W(t)
  local ph = (t * len) % RING
  local dip = (ph < 1.0 and t > 0.1 and t < 0.8) and 0.5 or 0
  return W0(t) - dip
end
local m, n, T, S, sm = G.tube(CP, W)
local v = X.light(n, { amb = 0.08, wrap = 0.3 })
local bias, rings, ridge, flakes = {}, {}, {}, {}
m:each(function(x, y)
  local k = K(x, y)
  local t, s = T[k], S[k]
  local d = t * len
  local ph = (d - abs(s) * 1.0) % RING
  if t > 0.07 and t < 0.84 then
    if ph < 0.8 then rings[k] = true
    elseif ph >= 4.6 and s < 0.2 then ridge[k] = true end          -- lit lip just before the crease (cut-end side)
  end
  if abs(s - 0.42 - 0.1 * math.sin(d * 0.35)) < 0.1 and X.hash(x, y, 5) > 0.3 then bias[k] = -1 end
  if s < -0.35 and s > -0.8 and X.hash(floor(d / 2), floor(s * 3), 8) > 0.72 and ph > 1.5 and ph < 4 then flakes[k] = true end
end)
local idx = G.tone(c, m, v, BARK, { 0.2, 0.38, 0.54, 0.7, 0.85 }, bias, bt)
for k in pairs(flakes) do local x, y = XY(k) c:put(x, y, idx[k] >= 5 and FLAKE or BARK[min(6, idx[k] + 1)], bt) end
for k in pairs(ridge) do local x, y = XY(k) c:put(x, y, BARK[min(6, idx[k] + 1)], bt) end
for k in pairs(rings) do local x, y = XY(k) c:put(x, y, BARK[max(1, idx[k] - 2)], bt) end
-- cool bounce on the lower-right rim, mid-body only
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y)
  if T[k] > 0.15 and T[k] < 0.7 and S[k] > 0.8 and not rings[k] then c:put(x, y, "#5c3a55", bt) end end)

-- forked root thread off the tail
G.line(c, { {15, 50}, {13, 53}, {10, 55}, {8, 55}, {6, 57} }, BARK[2])
c:px(13, 52, BARK[3])
G.line(c, { {11, 55}, {11, 58} }, BARK[1])

-- cut face (faces up-right toward the viewer)
local tx, ty = sm[1].x - sm[4].x, sm[1].y - sm[4].y
local tl = sqrt(tx*tx + ty*ty) tx, ty = tx / tl, ty / tl
local fx, fy = sm[1].x - tx * 0.2, sm[1].y - ty * 0.2
local face = G.rell(fx, fy, tx, ty, 3.0, 5.0)
local fe = face:edge()
local inner = face:copy():cut(fe)
local ie = inner:edge()
face:each(function(x, y)
  local col
  if fe:has(x, y) then
    local up = (x - fx) * -0.7 + (y - fy) * -0.7      -- upper-left part of the rim catches light
    col = up > 0.5 and PINK[4] or (up > -2.5 and PINK[3] or PINK[2])
  elseif ie:has(x, y) and (x - fx) + (y - fy) > 1.5 then
    col = FLESH[2]
  else
    col = FLESH[3]
  end
  c:px(x, y, col)
end)
local cx0, cy0 = floor(fx + .5), floor(fy + .5)
c:px(cx0, cy0, FLESH[1]) c:px(cx0 + 1, cy0, FLESH[1])
c:px(cx0 - 2, cy0 - 1, FLESH[4]) c:px(cx0 - 1, cy0 - 2, FLESH[4])

-- quirk: peeled patch on the lit side + bark strip rolled back into a curl
local P0, P1 = 13, 19
m:each(function(x, y) local k = K(x, y)
  local d, s = T[k] * len, S[k]
  if d > P0 and d < P1 and s < -0.15 then
    local col = PINK[2]
    if s < -0.6 and d > P0 + 1.5 then col = PINK[3] end
    if s < -0.85 and d > P0 + 2 and d < P1 - 1.5 then col = PINK[4] end
    if d < P0 + 1 or (s > -0.4) then col = PINK[1] end        -- shadow under the torn bark lips
    c:px(x, y, col)
  end
end)
-- the strip: lifts off the lit edge, rolls up-left into a loop; outside brown, inside (rolled over) pink
for _, q in ipairs{ {36,17,5}, {35,16,5}, {34,15,5}, {33,14,4}, {33,13,5}, {34,12,6}, {35,12,5} } do c:px(q[1], q[2], BARK[q[3]]) end
for _, q in ipairs{ {37,17}, {36,16}, {35,15} } do c:px(q[1], q[2], BARK[3]) end
c:px(36, 13, PINK[3]) c:px(36, 14, PINK[2]) c:px(35, 14, PINK[1])
G.fin(c, "cassava")
