-- fox-fang (lean E2_01)
local NAME = "fox-fang"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, ceil = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.ceil
local CUTS = { 0.18, 0.34, 0.5, 0.66, 0.82 }
local function inter(a, b) local r = HP.mask() a:each(function(x, y) if b:has(x, y) then r:set(x, y) end end) return r end

local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local IVORY = { "#6a5a78", "#9a88a0", "#c8bcc0", "#e6dcd0", "#f6f0e4", "#fffaf0" }
local CORD = { "#5a2018", "#8c3a24", "#c4642c", "#e89a4a" }
local FUR = { "#7a2a14", "#b5481c", "#e0742c", "#f2a050", "#fbd08a", "#fff0cc" }
c:groundShadow(30, 58, 15, 2.5)
-- fur tuft behind the wrap
local tuft = c:poly{ {30,14}, {28,8}, {32,10}, {33,5}, {36,9}, {39,5}, {40,10}, {44,8}, {43,14} }
local ftok = { r = { name = "fur" } }
local fi = X.tone(c, tuft, X.light(X.pillow(tuft, 3), { amb = 0.1, wrap = 0.25 }), FUR, { cuts = CUTS, tok = ftok })
tuft:each(function(x, y) local k = K(x, y) if y < 11 and X.hash(x, 0, 4) > 0.6 then c:put(x, y, FUR[min(6, fi[k] + 1)], ftok) end end)
local m, n, T, S, len = G.blade(36, 13, 47, 38, 20, 56, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 7.2 * (1 - t) ^ 0.85)
end)
local tok = { r = { name = "fang" } }
local idx = X.tone(c, m, X.light(n, { amb = 0.08, wrap = 0.22 }), IVORY, { cuts = CUTS, tok = tok })
m:each(function(x, y) local k = K(x, y) local t, s = T[k], S[k]
  if t > 0.22 and t < 0.8 and abs(s + 0.45) < 0.1 then c:put(x, y, IVORY[6], tok)
  elseif t > 0.22 and t < 0.85 and s > 0.55 then c:put(x, y, "#8a78a0", tok) end
  if t >= 0.04 and t <= 0.2 then
    local ci = max(1, ceil(idx[k] * 4 / 6))
    c:put(x, y, (x + y) % 4 == 0 and CORD[1] or CORD[ci], tok)
  end
end)
-- root cut: dark pulp rim at the top
m:each(function(x, y) if T[K(x, y)] < 0.04 then c:put(x, y, "#7a5a50", tok) end end)
local gx, gy = G.specAt(m, n, 30)
if gx then c:put(gx, gy, IVORY[6], tok) end
c:sparkle(45, 48)
G.save(c, NAME)
