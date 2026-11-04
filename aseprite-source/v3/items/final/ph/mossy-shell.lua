-- mossy-shell (lean W2_10)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.2, 0.38, 0.55, 0.7, 0.86 }
local function slab(c, m, R, ramp, amb, bias) local n = X.pillow(m, R) G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, CUTS, bias) return n end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "mossy-shell" }
local SH = { "#4a3a4e", "#74607a", "#a08c94", "#c9b5a8", "#e6d6c0", "#f8ecd8" }
local MO = { "#1f4a30", "#2f6a3a", "#478a40", "#6aa84c", "#92c460", "#bddc7c" }
local PINK = { "#5a1e44", "#8e3a68", "#c0628c", "#e592b0", "#f8c4cc", "#fff0ec" }
-- spiral cone: apex upper-right, mouth lower-left
local m, n, T, S = X.cyl(51, 14, 19, 46, function(t) local w = 0.8 + 13.5 * t ^ 0.85 if t > 0.86 then w = w * sqrt(max(0, 1 - ((t - 0.86) / 0.14) ^ 2) * 0.9 + 0.1) end return w end)
G.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), SH, CUTS)
-- whorl grooves: slanted dark ridges + one rust stripe
m:each(function(x, y) local k = K(x, y)
  local t, s = T[k], S[k]
  local ph = (t * 5.2 + s * 0.12) % 1
  if ph < 0.1 and t > 0.06 and t < 0.9 then c:px(x, y, SH[1])
  elseif ph > 0.1 and ph < 0.17 and t > 0.06 then c:px(x, y, SH[3]) end
  if abs(s - 0.1) < 0.07 and t > 0.1 and t < 0.92 and (x + y) % 3 ~= 0 then c:px(x, y, "#9a4a3a") end
end)
-- mouth
local mouth = c:ellipse(23, 42, 6, 8):cut(c:rect(24, 0, 63, 63):add(c:rect(0, 0, 63, 12)))
mouth = HP.mask() mouth:add(c:ellipse(25, 41, 4, 6))
c:fillMask(mouth:copy():grow(1), SH[6])
G.tone(c, mouth, X.light(X.pillow(mouth, 4), { amb = 0.2, wrap = 0.3 }), PINK, CUTS)
c:fillMask(c:ellipse(24, 42, 2, 3), PINK[1]) c:px(27, 38, PINK[6]) c:px(26, 37, PINK[5])
-- moss cap on the upper-left shoulder
local moss = HP.mask()
m:each(function(x, y) local k = K(x, y)
  local lim = 0.42 + 0.22 * X.hash(floor(x / 2), floor(y / 2), 3)
  if S[k] < -0.1 and T[k] > 0.25 and T[k] < 0.82 and (T[k] - 0.25) < lim * (-S[k] + 0.2) * 1.4 then moss:set(x, y) end end)
local mn = X.pillow(moss, 4)
G.tone(c, moss, X.light(mn, { amb = 0.1, wrap = 0.3 }), MO, CUTS)
moss:each(function(x, y) if X.hash(x, y, 9) > 0.86 then c:px(x, y, MO[5]) end end)
-- quirk: tiny sprout curling out of the moss
G.line(c, { {30, 25}, {30, 22}, {31, 20}, {33, 20} }, MO[4])
c:px(33, 20, MO[6]) c:px(34, 21, MO[5]) c:px(32, 19, MO[5])
c:px(41, 26, SH[6]) c:px(42, 26, SH[6])
G.fin(c, "mossy-shell")
