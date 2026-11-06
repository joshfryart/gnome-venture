-- thistle-heart (lean D3o_1)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function clampi(i, a, b) if not b then a, b = 1, a end return max(a, min(b, i)) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "thistle-heart" }
local GR   = { "#1f3a2e", "#2f5a3a", "#437a45", "#5f9a4e", "#88b95e", "#b9d77c" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local PK   = { "#4a2a6a", "#7a3a9a", "#a85cc0", "#c98ae0", "#e6b4f0", "#fbe0ff" }
local function leaf(P)
  local m, nn = G.tube(P, function(t) return max(0.4, 3.4 * sin(pi * t) ^ 0.7 + 0.7 * sin(t * 38)) end)
  G.tone(c, m, X.light(nn, { amb = 0.12, wrap = 0.25 }), LEAF)
end
leaf({ {31,57}, {24,58}, {16,56}, {9,47} })
leaf({ {33,57}, {40,58}, {48,56}, {55,47} })
local sm, sn = G.tube({ {32,48}, {32,53}, {32,56}, {32,58} }, function(t) return 1.8 end)
G.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), GR)
local H = c:ellipse(25, 31, 9, 9):add(c:ellipse(39, 31, 9, 9)):add(c:poly{ {16,34}, {48,34}, {32,51} })
local n = X.pillow(H, 10)
local v = X.light(n, { amb = 0.08, wrap = 0.25 })
local idx = G.tone(c, H, v, GR, { 0.2, 0.38, 0.55, 0.72, 0.88 })
H:each(function(x, y)
  local r = floor((y - 22) / 4)
  local lx, ly = (x + (r % 2) * 2) % 5, (y - 22) % 4
  local k = K(x, y)
  local i = idx[k] or 3
  if (ly == 3 and lx >= 1 and lx <= 3) or (ly == 2 and (lx == 0 or lx == 4)) then c:px(x, y, GR[clampi(i - 2, 6)])
  elseif ly == 0 and lx >= 1 and lx <= 3 then c:px(x, y, GR[clampi(i + 1, 6)]) end
end)
-- dew + spec
c:px(21, 31, PK[6]) c:px(22, 31, PK[6]) c:px(21, 32, "#9fd0e0")
c:px(41, 38, GR[1]) 
-- purple tuft
for _, i in ipairs{ 0, 10, 1, 9, 2, 8, 3, 7, 4, 6, 5 } do
  local a = (i - 5) * 0.2
  local L = 12 + (5 - abs(i - 5)) * 0.9
  local sx, sy = 32 + (i - 5) * 1.3, 26
  local ex, ey = sx + sin(a) * L, sy - cos(a) * L
  c:line({ {sx, sy}, {ex, ey} }, 1):each(function(x, y)
    local t = sqrt((x - sx)^2 + (y - sy)^2) / L
    local j = t < 0.25 and 1 or (t < 0.5 and 2 or (t < 0.75 and 3 or (t < 0.92 and 4 or 5)))
    if i < 5 then j = j + 0 end
    c:px(x, y, PK[clampi(j + (i >= 5 and 1 or 0), 6)])
  end)
end
G.fin(c, "thistle-heart")
