-- sunrise-lime (lean D2o_17)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function L(c, pts, hex) c:line(pts, 1):each(function(x, y) c:px(x, y, hex) end) end
local function shade(c, m, ramp, R, tok, bias, o)
  o = o or {} o.tok = tok o.bias = bias
  local n = X.pillow(m, R) local idx, v = G.toneN(c, m, n, ramp, o) return idx, v, n
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "sunrise-lime" }
local LIME = { "#1f4a2a", "#2f6e34", "#4c9a3c", "#7ac148", "#a8dc5c", "#d6f08a" }
local YEL  = { "#5a7a22", "#8aa82c", "#b8c83a", "#d8dc4a", "#eef06a", "#fbfaa0" }
local SUN  = { "#7a2a2a", "#b0402a", "#d96a26", "#f3962c", "#ffc24a", "#ffe58a" }
local LF   = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
c:groundShadow(27, 54, 15, 2)
local fruit = c:ellipse(27, 34, 16, 15)
local n = X.pillow(fruit, 14)
local v = X.light(n, { amb = 0.06, wrap = 0.25 })
local g, y2, o = HP.mask(), HP.mask(), HP.mask()
fruit:each(function(x, y)
  local edge = 36 + floor(2 * sin(x * 0.45))
  if y < edge - 3 then g:set(x, y) elseif y < edge then y2:set(x, y) else o:set(x, y) end
end)
local cuts = { cuts = { 0.22, 0.4, 0.56, 0.72, 0.86 } }
X.tone(c, g, v, LIME, { cuts = cuts.cuts, tok = { r = { name = "lime" } } })
X.tone(c, y2, v, YEL, { cuts = cuts.cuts, tok = { r = { name = "dawn" } } })
X.tone(c, o, v, SUN, { cuts = cuts.cuts, tok = { r = { name = "sun" } } })
-- pores
fruit:each(function(x, y) if v[K(x, y)] > 0.3 and X.hash(x, y, 9) > 0.93 then
  c:px(x, y, g:has(x, y) and LIME[2] or (o:has(x, y) and SUN[2] or YEL[2])) end end)
-- spec
c:px(17, 26, "#fff6f2") c:px(18, 26, "#fff6f2") c:px(17, 27, LIME[6]) c:px(19, 25, LIME[6])
-- stem nub + leaf
L(c, { {27, 19}, {27, 17}, {28, 16} }, "#5a3a24") c:px(27, 18, "#8a5a34")
local lm, ln = G.oval(36, 14, 7, 2.8, -0.35, 1)
shade(c, lm, LF, 3, { r = { name = "leaf" } })
for i = -5, 5 do c:px(floor(36 + i * 0.95), floor(14 + i * -0.33), LF[6]) end
-- quirk: lime half-wheel
local wedge = c:ellipse(47, 49, 9, 9):cut(c:rect(0, 0, 63, 48))
c:fillMask(wedge, LIME[2])
for y = 49, 58 do for x = 37, 57 do if wedge:has(x, y) then
  local dx, dy = x - 47, y - 49
  local d = sqrt(dx*dx + dy*dy)
  local a = atan(dy, dx)
  if d <= 8 and d > 7 then c:px(x, y, LIME[1])
  elseif d <= 7 and d > 5.8 then c:px(x, y, "#e6f0b0")
  elseif d <= 5.8 then
    local seg = abs(sin(a * 3)) < 0.18 and d > 1.5
    c:px(x, y, seg and "#e6f0b0" or ((dx + dy < -1) and "#e2ee6a" or "#b6d44a"))
  end
end end end
c:px(43, 51, "#fbfaa0")
G.save(c, "sunrise-lime")
