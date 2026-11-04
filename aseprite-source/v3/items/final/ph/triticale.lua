-- triticale (lean D3o_7)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "triticale" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CU = { 0.2, 0.38, 0.55, 0.72, 0.87 }
local function sh(m, ramp, R, bias, tok)
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = 0.1, wrap = 0.25 })
  G.tone(c, m, v, ramp, CU, bias, tok)
  return n, v
end
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local GR = { "#3e2132", "#6a2e3c", "#964a3a", "#c47a3e", "#e6aa52", "#f8d27e" }
local ST = { "#5c5a2a", "#807a3a", "#a6a050", "#c8c070", "#e2dc94", "#f6f0bc" }
local sm, sn = G.tube({ {26,54},{27,48},{30,42},{31,36} }, function(t) return 1.5 - 0.3 * t end)
G.tone(c, sm, X.light(sn, { amb = 0.12, wrap = 0.3 }), ST, CU)
local lm, ln = G.tube({ {27,49},{20,45},{14,39},{10,33} }, function(t) return 0.7 + 2.2 * sin(pi * min(1, t * 1.1 + 0.05)) ^ 0.7 * (1 - t * 0.5) end)
G.tone(c, lm, X.light(ln, { amb = 0.12, wrap = 0.3 }), LEAF, CU)
local grains, awns = {}, {}
for i = 0, 5 do
  local t = i / 5
  local ax, ay = 31 + 3 * t, 36 - 16 * t
  for _, s in ipairs{ -1, 1 } do
    local ux, uy = s * 0.3, -1
    local l = sqrt(ux * ux + uy * uy); ux, uy = ux / l, uy / l
    local cx, cy = ax + s * 2.4, ay
    grains[#grains + 1] = { cx, cy, ux, uy }
    awns[#awns + 1] = { cx + ux * 4, cy + uy * 4, cx + ux * 4 + s * 5, cy + uy * 4 - 11, s, i }
  end
end
local top = { 34, 20 }
awns[#awns + 1] = { 34, 16, 34, 7, 0, 9 }
awns[#awns + 1] = { 34, 16, 31, 8, 0, 8 }
awns[#awns + 1] = { 34, 16, 37, 8, 0, 8 }
for _, a in ipairs(awns) do G.line(c, { {a[1], a[2]}, {a[3], a[4]} }, (a[6] % 2 == 0) and GR[5] or GR[3]) end
for i = #grains, 1, -1 do
  local g = grains[i]
  sh(G.rell(g[1], g[2], g[3], g[4], 4.2, 2.5), GR, 2.6)
end
sh(G.rell(34, 18, 0, -1, 3.6, 2.2), GR, 2.4)
-- crease on grains
for _, g in ipairs(grains) do c:px(floor(g[1] + 0.5), floor(g[2] + 0.5), GR[1]) end
c:px(30, 33, GR[6]) c:px(34, 25, GR[6])
c:px(40, 6, "#bfe6ff") c:px(40, 5, "#f4fbff")   -- dewdrop on an awn tip
G.fin(c, "triticale")
