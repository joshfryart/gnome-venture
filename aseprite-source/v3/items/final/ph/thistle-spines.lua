-- thistle-spines (lean D3o_1)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function clampi(i, a, b) if not b then a, b = 1, a end return max(a, min(b, i)) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "thistle-spines" }
local SP  = { "#5b3a1e", "#8a5a2a", "#b88a3e", "#dcb25a", "#f2d985", "#fff5c4" }
local GRN = { "#1f3a2e", "#2f5a3a", "#437a45", "#5f9a4e", "#88b95e", "#b9d77c" }
local TW  = { "#6a4326", "#946038", "#c08a50", "#e0b278" }
c:groundShadow(32, 56, 9, 2)
local defs = {
  { {32,49}, {26,44}, {16,38}, {7,30} },
  { {32,49}, {38,45}, {48,38}, {57,30} },
  { {32,49}, {28,38}, {18,26}, {13,14} },
  { {32,49}, {37,38}, {46,28}, {51,14} },
  { {32,49}, {31,36}, {33,22}, {32,10} },
}
local U = HP.mask()
for _, P in ipairs(defs) do
  local m, n, T, S = G.tube(P, function(t) return 2.4 * (1 - t) ^ 0.8 + 0.35 end)
  local idx = G.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), SP)
  m:each(function(x, y)
    local k = K(x, y)
    local t, s = T[k], S[k]
    if t < 0.2 then c:px(x, y, GRN[clampi(idx[k] or 3, 6)])
    elseif s < -0.25 and s > -0.6 and t > 0.25 and t < 0.92 then c:px(x, y, SP[6]) end
  end)
  U:add(m)
end
-- calyx stub
local sm, sn = G.tube({ {32,48}, {32,52}, {32,54}, {32,57} }, function(t) return 2.2 - t end)
G.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), GRN)
-- twine binding
local band = U:copy():clip(c:rect(24, 44, 40, 50)):add(sm:copy():clip(c:rect(24, 44, 40, 50)))
band:each(function(x, y)
  local d = (x + y) % 4
  c:px(x, y, d < 2 and TW[3] or TW[2])
  if y == 50 then c:px(x, y, TW[1]) end
  if y == 44 then c:px(x, y, TW[4]) end
end)
c:line({ {30,50}, {28,54}, {26,57} }, 1):each(function(x, y) c:px(x, y, TW[2]) end)
c:line({ {34,50}, {36,54}, {38,56} }, 1):each(function(x, y) c:px(x, y, TW[3]) end)
c:px(26, 58, TW[1]) c:px(38, 57, TW[1])
-- quirk: nectar bead on the tallest tip
c:px(32, 7, "#c8413a") c:px(33, 7, "#e86a5a") c:px(32, 8, "#8e2a3a")
G.fin(c, "thistle-spines")
