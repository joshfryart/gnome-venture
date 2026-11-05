-- thorn-fang (lean P1b_O16)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function pick(r, v, cuts) cuts = cuts or {.22,.4,.56,.72,.86} local i = 1 for _, t in ipairs(cuts) do if v > t then i = i + 1 end end return r[min(i, #r)] end

local c = HP.canvas{ w=64, h=64, scale=1, name="thorn-fang" }
local IV = { "#5e4a52", "#8c7a7c", "#bfae9c", "#e4d8bf", "#f8f0d8", "#fffaf0" }
local BARK = { "#2e1d18", "#4f3224", "#74492f", "#9a6a40" }
local ROPE = { "#7a5a2a", "#b48a42", "#e0b862" }
local MOSS = { "#1f4a2a", "#3a7a3a", "#6cae48" }
c:groundShadow(34, 58, 14, 2)
local P = { {14,16}, {44,11}, {57,34}, {38,55} }
local m, n, T, S = G.tube(P, function(t) return 7.2 * (1 - t) ^ 0.85 + 0.5 end)
local v = X.light(n, { amb = 0.1, wrap = 0.25 })
m:each(function(x, y)
  local k = K(x, y)
  local t = T[k]
  local col
  if t < 0.2 then
    col = pick(BARK, v[k] + 0.08 * sin(x * 0.9)) -- bark socket
    if floor(t * 60) % 3 == 0 then col = pick(ROPE, v[k] + 0.1) end
  else
    col = pick(IV, v[k] + 0.07 * cos(t * 40))
    if abs(S[k] + 0.1) < 0.15 and t > 0.3 and t < 0.85 then col = IV[5] end
    if floor(t * 36) % 5 == 0 and t < 0.8 then col = pick(IV, v[k] - 0.25) end
    if t > 0.9 then col = pick(MOSS, 0.8 - (t - 0.9) * 4) end
  end
  c:px(x, y, col)
end)
-- moss patch near base (quirk)
for _, p in ipairs{ {26,18}, {27,18}, {28,19}, {27,19}, {29,20}, {26,19} } do if m:has(p[1], p[2]) then c:px(p[1], p[2], MOSS[(p[1] + p[2]) % 3 + 1]) end end
c:px(32, 22, "#fffaf0")
G.save(c, "thorn-fang")
