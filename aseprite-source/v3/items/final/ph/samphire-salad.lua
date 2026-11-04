-- samphire-salad (lean W2_17)
-- Wide shallow stoneware bowl with a teal painted band, a tuft of jointed samphire sprigs (node rings, pale tips),
-- cherry tomato and lemon wedge on the rim. Quirk: one limp sprig drapes over the bowl lip.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function lit(m, R, amb, wrap) return X.light(X.pillow(m, R), { amb = amb or 0.08, wrap = wrap or 0.25 }) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "samphire-salad" }
local CER = { "#5a3f55", "#8a6674", "#b88f8a", "#dcb9a6", "#f2dcc2", "#fff3dc" }
local GRN = { "#1f4a3a", "#2c6a45", "#43904f", "#6cb35a", "#9ad06a", "#c9e68e" }
local TEAL = { "#1d4a5a", "#2a6f7c", "#3f98a0", "#6cc0b8" }
local RED = { "#5a1428", "#8e1f36", "#c0344a", "#e4566a", "#f58a92", "#ffd0cc" }
local LEM = { "#8a6a12", "#c29a1c", "#eec43a", "#fbe36a", "#fff3a8", "#fffbe0" }
local DRS = { "#6a4a22", "#8f6a32" }
c:groundShadow(32, 54, 17, 2)
-- bowl body
local body = c:ellipse(32, 35, 19, 18)
body:cut(c:rect(0, 0, 63, 35))
local bv = lit(body, 11, 0.06, 0.2)
G.tone(c, body, bv, CER, { 0.2, 0.38, 0.55, 0.72, 0.88 })
body:each(function(x, y)
  if y == 42 or y == 43 then c:px(x, y, (bv[K(x, y)] or 0) > 0.55 and TEAL[3] or TEAL[2]) end
  if y == 44 then c:px(x, y, TEAL[1]) end
end)
-- foot
local foot = c:rrect(24, 52, 40, 54, 1)
G.tone(c, foot, lit(foot, 3), CER, { 0.2, 0.38, 0.55, 0.72, 0.88 })
-- rim ring + interior
local outer = c:ellipse(32, 35, 19, 4.6)
local inner = c:ellipse(32, 35, 16.5, 3)
local ring = outer:copy():cut(inner)
local rv = lit(ring, 3, 0.15, 0.3)
G.tone(c, ring, rv, CER, { 0.2, 0.38, 0.55, 0.72, 0.86 })
c:fillMask(inner, DRS[1])
inner:each(function(x, y) if (x + y) % 3 == 0 and y > 35 then c:px(x, y, DRS[2]) end end)
-- sprigs
local function sprig(p, w0, nodes, tok)
  local m, n, T = G.tube(p, function(t) return w0 * (1 - t * 0.55) + 0.6 end)
  local v = X.light(n, { amb = 0.1, wrap = 0.25 })
  G.tone(c, m, v, GRN, { 0.2, 0.38, 0.55, 0.72, 0.88 }, nil, tok)
  m:each(function(x, y) local k = K(x, y)
    local t = T[k]
    if (t * nodes) % 1 < 0.12 and t > 0.1 and t < 0.92 then c:px(x, y, GRN[1]) end
    if t > 0.92 then c:px(x, y, GRN[5]) end
  end)
  -- side nubs at nodes
  for i = 1, nodes - 1 do
    local x, y = G.bez(p, i / nodes)
    local sd = (i % 2 == 0) and 1 or -1
    local px, py = floor(x + 0.5) + sd * (floor(w0) + 1), floor(y + 0.5) - 1
    c:px(px, py, GRN[4]) c:px(px + sd, py - 1, GRN[5])
  end
  return m
end
sprig({ {26, 36}, {21, 29}, {19, 22}, {14, 16} }, 1.9, 4, { r = { name = "s3" } })
sprig({ {38, 36}, {43, 30}, {47, 24}, {49, 17} }, 1.9, 4, { r = { name = "s4" } })
sprig({ {32, 36}, {36, 27}, {40, 19}, {42, 11} }, 1.9, 4, { r = { name = "s2" } })
sprig({ {32, 36}, {31, 28}, {27, 20}, {25, 11} }, 2.1, 5, { r = { name = "s1" } })
sprig({ {33, 36}, {33, 26}, {32, 16}, {33, 8} }, 2.2, 5, { r = { name = "s5" } })
sprig({ {31, 26}, {35, 23}, {37, 18}, {38, 13} }, 1.4, 2, { r = { name = "s6" } })
-- front lip repaint
local front = ring:copy():cut(c:rect(0, 0, 63, 34))
G.tone(c, front, rv, CER, { 0.2, 0.38, 0.55, 0.72, 0.88 })
-- drape sprig (quirk)
local dm, dn, dT = G.tube({ {26, 35}, {17, 31}, {12, 36}, {13, 43} }, function(t) return 1.7 * (1 - t * 0.5) + 0.5 end)
G.tone(c, dm, X.light(dn, { amb = 0.1, wrap = 0.25 }), GRN, { 0.2, 0.38, 0.55, 0.72, 0.88 }, nil, { r = { name = "drape" } })
dm:each(function(x, y) local t = dT[K(x, y)] if (t * 4) % 1 < 0.13 and t > 0.1 then c:px(x, y, GRN[1]) end end)
-- lemon wedge
local cx, cy = 47, 34
local wd = c:ellipse(cx, cy, 7, 7)
wd:cut(c:rect(0, 0, 63, cy - 1))
local rind = wd:copy():cut(wd:copy():shrink(1))
local pith = wd:copy():shrink(1):cut(wd:copy():shrink(2))
local flesh = wd:copy():shrink(2)
G.tone(c, flesh, lit(flesh, 6, 0.2, 0.4), LEM, { 0.2, 0.4, 0.6, 0.78, 0.92 })
c:fillMask(rind, LEM[2]) c:fillMask(pith, LEM[5])
rind:each(function(x, y) if x + y > cx + cy + 6 then c:px(x, y, LEM[1]) end end)
for _, a in ipairs{ 0.3, 0.5, 0.7 } do
  local ang = pi * a
  G.line(c, { {cx, cy + 1}, {floor(cx + cos(ang) * 5 + 0.5), floor(cy + sin(ang) * 5 + 0.5)} }, LEM[5])
end
c:px(cx - 3, cy + 3, LEM[6]) c:px(cx + 3, cy + 3, LEM[1])
-- cherry tomato
local tm = c:ellipse(37, 40, 5, 4.6)
local tv = lit(tm, 5, 0.06, 0.2)
G.tone(c, tm, tv, RED, { 0.18, 0.36, 0.54, 0.72, 0.88 })
c:px(35, 38, RED[6]) c:px(36, 38, RED[6]) c:px(35, 39, RED[5])
for _, p in ipairs{ {37, 36}, {36, 36}, {38, 36}, {37, 35} } do c:px(p[1], p[2], GRN[3]) end
c:px(37, 37, GRN[2]) c:px(35, 36, GRN[4]) c:px(39, 36, GRN[4])
-- salt glint
c:sparkle(52, 14)
G.fin(c, "samphire-salad")
