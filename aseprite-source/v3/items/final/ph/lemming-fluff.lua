-- lemming-fluff (lean W2_8)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w=64, h=64, scale=1, name="lemming-fluff" }
local sin, pi, abs = math.sin, math.pi, math.abs
local FUR = { "#5a3418", "#8a5424", "#b87a30", "#dca048", "#f2c670", "#fde4a0" }
local TIP = { "#2e1c14", "#4a2c1c", "#6a4024" }
local tok = { r = { name = "fur" } }
-- tufts: base ax,ay ; control ; tip ; width
local tufts = {
  {31,47, 18,40, 8,26, 4.6}, {32,47, 22,26, 24,10, 5.2}, {33,47, 36,28, 40,8, 5.6},
  {34,47, 46,34, 54,16, 5.0}, {34,48, 50,44, 57,34, 4.2},
}
for _, t in ipairs(tufts) do
  local w = t[7]
  local m, n, T, S = G.blade(t[1],t[2], t[3],t[4], t[5],t[6], function(u) return w * sin(pi * math.min(1, u*0.9+0.1)) ^ 0.7 + 0.4 end)
  G.toneN(c, m, n, FUR, { tok = tok })
  m:each(function(x, y) local k = K(x, y)
    local s, u = S[k], T[k]
    if u > 0.72 then c:put(x, y, u > 0.9 and TIP[1] or (u > 0.8 and TIP[2] or TIP[3]), tok)
    elseif abs(s) < 0.12 and u > 0.15 then c:put(x, y, s <= 0 and FUR[6] or FUR[2], tok) end
  end)
end
-- cream nub where tufts gather
local nub = HP.mask() nub:add(c:ellipse(33, 50, 6, 4))
G.toneN(c, nub, X.pillow(nub, 4), { "#8a7a78", "#b8a8a0", "#d8c8bc", "#efe2d0", "#fff4e0", "#fff6f2" }, { tok = tok })
-- red thread wraps (quirk: a loose thread end)
for i, y in ipairs{ 45, 47 } do
  for x = 27, 39 do c:put(x, y + (x % 2), (i == 1) and "#c8384a" or "#8c1f3a", tok) end
end
c:put(28, 46, "#f07080", tok) c:put(34, 45, "#f07080", tok)
for _, p in ipairs{ {39,47},{40,48},{40,49},{41,50},{40,51} } do c:put(p[1], p[2], "#c8384a", tok) end
-- glint
c:put(24, 15, "#fffbe8", tok) c:put(25, 16, "#fffbe8", tok)
G.save(c, "lemming-fluff")
