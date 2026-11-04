-- tritordeum (lean D3o_7)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tritordeum" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CU = { 0.2, 0.38, 0.55, 0.72, 0.87 }
local function sh(m, ramp, R, bias, tok)
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = 0.1, wrap = 0.25 })
  G.tone(c, m, v, ramp, CU, bias, tok)
  return n, v
end
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local GR = { "#59431a", "#876820", "#b88f2c", "#dcb73e", "#f2dc66", "#fff6ac" }
local ST = { "#4a5a2a", "#6a7e38", "#8fa04c", "#b4c068", "#d4dc8c", "#eef2b4" }
local sm, sn = G.tube({ {19,54},{19,50},{17,44},{16,40} }, function(t) return 1.4 end)
G.tone(c, sm, X.light(sn, { amb = 0.12, wrap = 0.3 }), ST, CU)
local lm, ln = G.tube({ {19,49},{28,45},{37,48},{44,54} }, function(t) return 0.8 + 2.4 * sin(pi * min(1, t * 1.05 + 0.04)) ^ 0.7 end)
G.tone(c, lm, X.light(ln, { amb = 0.12, wrap = 0.3 }), LEAF, CU)
c:px(18, 46, ST[1]) c:px(19, 46, ST[1]) c:px(20, 46, ST[2])
local ux, uy = 0.84, -0.54
local px_, py_ = 0.54, 0.84
local st = {}
for i = 0, 7 do st[#st + 1] = { 17 + ux * 3.6 * i, 38 + uy * 3.6 * i, i } end
for _, s in ipairs(st) do
  for _, sd in ipairs{ -1, 1 } do
    local sx, sy = s[1] + px_ * sd * 1.6 + ux * 4, s[2] + py_ * sd * 1.6 + uy * 4
    G.line(c, { {sx, sy}, {sx + ux * 12 + px_ * sd * 3, sy + uy * 12 + py_ * sd * 3} }, (s[3] % 2 == 0) and GR[5] or GR[3])
  end
end
for i = #st, 1, -1 do
  local s = st[i]
  for _, sd in ipairs{ 1, -1 } do
    local dx, dy = ux - sd * px_ * 0.5, uy - sd * py_ * 0.5
    local l = sqrt(dx * dx + dy * dy)
    sh(G.rell(s[1] + px_ * sd * 1.8, s[2] + py_ * sd * 1.8, dx / l, dy / l, 5, 2.6), GR, 2.6)
  end
end
local last = st[#st]
sh(G.rell(last[1] + ux * 4, last[2] + uy * 4, ux, uy, 4, 2.2), GR, 2.4)
for _, s in ipairs(st) do c:px(floor(s[1] + 0.5), floor(s[2] + 0.5), GR[2]) end
c:px(22, 34, GR[6]) c:px(23, 33, GR[6])
c:px(50, 12, "#bfe6ff") c:px(50, 11, "#f4fbff")
G.fin(c, "tritordeum")
