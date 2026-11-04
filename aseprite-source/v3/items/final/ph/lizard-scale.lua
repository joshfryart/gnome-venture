-- lizard-scale (lean W2_8)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w=64, h=64, scale=1, name="lizard-scale" }
local abs, sin, pi, sqrt = math.abs, math.sin, math.pi, math.sqrt
local MINT = { "#1e5a58", "#2f8a76", "#4fb890", "#82dcaa", "#b8f0c4", "#e8fff0" }
local NAVY = { "#161a44", "#232a6c", "#34409a", "#4c60c4", "#7c92e6", "#b8c8ff" }
local tok = { r = { name = "scale" } }
-- upright-leaning shield: tip top-right, rounded base bottom-left; keel along spine
local m, n, T, S = G.blade(22,50, 22,30, 44,10, function(u) return 11 * sin(pi * math.min(1, u*0.92+0.04)) ^ 0.75 + 0.3 end)
G.toneN(c, m, n, MINT, { tok = tok })
-- right half is navy (iridescent shift), keel ridge line, overlapping scale arcs
m:each(function(x, y) local k = K(x, y)
  local s, u = S[k], T[k]
  if s > 0.06 and u > 0.1 then
    local v = (s > 0.6) and 1 or 0
    c:put(x, y, NAVY[ (u > 0.6 and 3 or 2) + v * 0 + ((x + y) % 7 == 0 and 1 or 0) ], tok)
    if s > 0.7 then c:put(x, y, NAVY[2], tok) end
    if s > 0.9 then c:put(x, y, NAVY[1], tok) end
  end
  if abs(s) <= 0.06 and u > 0.08 then c:put(x, y, s <= 0 and MINT[6] or NAVY[5], tok) end
  -- growth arcs
  local a = (u * 26) % 6
  if a < 0.9 and abs(s) > 0.2 and u > 0.12 and u < 0.88 then c:put(x, y, s < 0 and MINT[2] or NAVY[1], tok) end
end)
-- spec and rainbow glint (quirk: a tiny pink shimmer fleck)
c:put(25, 31, "#fff6f2", tok) c:put(26, 31, "#fff6f2", tok) c:put(25, 32, MINT[6], tok)
c:put(33, 25, "#ff9ac8", tok) c:put(34, 24, "#ffd878", tok)
-- torn root stub
local st = HP.mask() st:add(c:rrect(19, 50, 24, 55, 1))
G.toneN(c, st, X.pillow(st, 3), { "#5a4a48", "#8a7a74", "#b0a094", "#d4c6b4", "#ece0d0", "#fff6f2" }, { tok = tok })
G.save(c, "lizard-scale")
