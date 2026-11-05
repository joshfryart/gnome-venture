-- snake-skin (lean P1b_O9)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local NAME = "snake-skin"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local SKIN = { "#46603a", "#6c8a4a", "#98b45c", "#c3d481", "#e4ecaa", "#f8fad0" }
local DIA = { "#3a2a2e", "#5c3c30", "#8a5a38" }
c:groundShadow(32, 56, 20, 2)
local function seg(p, wf, off)
  local m, n, T, S = G.tube(p, wf)
  G.toneN(c, m, n, SKIN, { amb = 0.1, wrap = 0.2 })
  m:each(function(x, y)
    local k = K(x, y)
    local u = (T[k] * 70 + off) % 8 - 4
    local d = abs(u) + abs(S[k]) * 4.5
    if d < 3.4 then c:px(x, y, S[k] < 0 and DIA[2] or DIA[1])
    if d < 1.8 and S[k] < 0.4 then c:px(x, y, DIA[3]) end
    elseif d < 4.2 and S[k] < 0 then c:px(x, y, SKIN[5]) end
  end)
  return m, n, T, S
end
local m1, n1, T1, S1 = seg({ {13, 20}, {28, 4}, {54, 10}, {50, 30} }, function(t) return 5.4 - 0.4 * t end, 0)
local m2, n2, T2, S2 = seg({ {50, 30}, {47, 46}, {26, 40}, {12, 54} }, function(t) return 5 * (1 - t) ^ 0.7 + 0.4 end, 10)
-- head: blunt, wider
local hm, hn = G.oval(15, 20, 6.6, 5, 0.5, 0.9)
G.toneN(c, hm, hn, SKIN, { amb = 0.1 })
-- empty eye cap (quirk): translucent bump with hole
c:px(13, 18, SKIN[6]) c:px(14, 18, SKIN[6]) c:px(13, 19, DIA[1]) c:px(14, 19, SKIN[1])
c:px(12, 22, DIA[1]) c:px(11, 22, DIA[1])
for x = 17, 19 do c:px(x, 22, SKIN[2]) end
-- rim glint along upper-left of the loop
c:px(24, 6, SKIN[6]) c:px(25, 5, SKIN[6]) c:px(26, 5, SKIN[6])
G.save(c, NAME)
