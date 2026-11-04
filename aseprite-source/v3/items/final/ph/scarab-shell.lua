-- scarab-shell (lean W2_17)
-- Empty scarab carapace seen from above: toothed clypeus, pronotum cap, split elytra with striae and a central suture,
-- iridescent green-gold lit side shifting to blue-violet shade, spiny legs and amber wing tips peeking from below.
-- Quirk: a chipped notch in the lower right edge showing pale cream inner shell.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function lit(m, R, amb, wrap) return X.light(X.pillow(m, R), { amb = amb or 0.08, wrap = wrap or 0.25 }) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "scarab-shell" }
local EM = { "#14463e", "#1f6e52", "#2f9a5a", "#58c068", "#98dc7a", "#d6f29a" }
local BV = { "#1c2056", "#2e3a8a", "#3f66b0", "#4f93c6", "#7fc4d8", "#c4eaec" }
local LEG = { "#1a2a30", "#2c4a46", "#4a7a62", "#7aa88a" }
local AMB = { "#7a4a1c", "#b0762a", "#dca040", "#f4cc6c" }
local CRM = { "#c9b496", "#e8d9b8", "#fff0d4" }
c:groundShadow(32, 57, 12, 2)
-- legs
local function leg(p)
  local m, n = G.tube(p, function(t) return 1.1 * (1 - t) + 0.5 end)
  G.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.3 }), LEG, { 0.3, 0.55, 0.8 })
  local ex, ey = G.bez(p, 0.9) c:px(floor(ex + 0.5), floor(ey + 0.5), LEG[1])
end
leg({ {20, 30}, {12, 26}, {8, 32}, {7, 38} })
leg({ {44, 30}, {52, 26}, {56, 32}, {57, 38} })
leg({ {18, 40}, {10, 40}, {7, 46}, {8, 51} })
leg({ {46, 40}, {54, 40}, {57, 46}, {56, 51} })
leg({ {21, 49}, {15, 53}, {14, 55}, {17, 56} })
leg({ {43, 49}, {49, 53}, {50, 55}, {47, 56} })
-- wing tips
local wing = c:ellipse(32, 56, 10, 3.2)
G.tone(c, wing, lit(wing, 4, 0.2, 0.4), AMB, { 0.3, 0.55, 0.8 })
wing:each(function(x, y) if (x % 3 == 0) and y > 54 then c:px(x, y, AMB[1]) end end)
-- elytra
local ely = c:ellipse(32, 38, 15.5, 18.5)
local bite = c:ellipse(46, 52, 3.5, 3)
local ev = lit(ely, 14, 0.04, 0.15)
local bias = {}
ely:each(function(x, y)
  local d = (x - 32) * 0.7 + (y - 34) * 0.6 + (X.hash(x, y, 3) - 0.5) * 4
  bias[K(x, y)] = 0
  if d > 5 then bias[K(x, y)] = 0 end
end)
local lo, hi = HP.mask(), HP.mask()
ely:each(function(x, y)
  local d = (x - 32) * 0.7 + (y - 34) * 0.6 + (X.hash(x, y, 3) - 0.5) * 3.5
  if d > 4 then hi:set(x, y) else lo:set(x, y) end
end)
G.tone(c, lo, ev, EM, { 0.2, 0.38, 0.55, 0.72, 0.88 })
G.tone(c, hi, ev, BV, { 0.16, 0.32, 0.48, 0.66, 0.84 })
-- striae and suture
ely:each(function(x, y)
  local hwid = 15.5 * sqrt(max(0, 1 - ((y - 38) / 18.5)^2))
  local rel = (x - 32) / max(hwid, 1)
  local isb = hi:has(x, y)
  if y > 24 then
    if abs(rel) < 0.07 then c:px(x, y, isb and BV[1] or EM[1])
    else
      for _, kk in ipairs{ 0.36, 0.68 } do
        if abs(abs(rel) - kk) < 0.045 and y % 4 ~= 3 then c:px(x, y, isb and BV[2] or EM[2]) end
      end
    end
  end
end)
-- chip (quirk)
local chip = ely:copy()
chip:cut(c:ellipse(45, 49, 4.5, 4))
local gone = ely:copy():cut(chip)
gone:each(function(x, y) c:px(x, y, CRM[2]) end)
gone:copy():shrink(1):each(function(x, y) c:px(x, y, CRM[3]) end)
gone:each(function(x, y) if not gone:copy():shrink(1):has(x, y) and x > 44 then c:px(x, y, CRM[1]) end end)
-- gloss streak
for i = 0, 7 do c:px(22 + floor(i * 0.15), 28 + i, EM[6]) end
c:px(23, 30, EM[6]) c:px(22, 29, "#fffaf0")
-- pronotum
local pro = c:ellipse(32, 22, 11.5, 6.2)
local pv = lit(pro, 7, 0.08, 0.25)
G.tone(c, pro, pv, EM, { 0.2, 0.38, 0.55, 0.72, 0.88 })
pro:each(function(x, y) if (x * 3 + y * 5) % 7 == 0 and pv[K(x, y)] > 0.4 then c:px(x, y, EM[2]) end end)
for x = 24, 40 do if pro:has(x, 26) then c:px(x, 27, EM[1]) end end
-- head with teeth
local head = c:ellipse(32, 14.5, 7, 3.6)
G.tone(c, head, lit(head, 4, 0.1, 0.3), EM, { 0.2, 0.38, 0.55, 0.72, 0.88 })
for _, x in ipairs{ 27, 30, 33, 36 } do c:px(x, 10, EM[3]) c:px(x, 11, EM[2]) end
c:px(29, 12, EM[1]) c:px(32, 12, EM[1]) c:px(35, 12, EM[1])
c:sparkle(46, 14)
G.fin(c, "scarab-shell")
