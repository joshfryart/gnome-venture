-- tangelo (lean D2o_19)
-- Squat orange fruit with a pronounced neck-knob, short twig stem and one glossy leaf.
-- quirk: a small peeled flap on the lower right showing pale pith and a juicy segment.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tangelo" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local ORG  = { "#7a2a1c", "#b0381a", "#d95a1c", "#f2851f", "#fbae33", "#ffd877" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local TWIG = { "#4a2f22", "#6b4630", "#8f6540" }
local PITH = { "#c9a46a", "#e8cf98", "#f7ecc8" }
local ltok = { r = { name = "leaf" } }
local cuts = { 0.2, 0.38, 0.55, 0.72, 0.87 }

-- leaf (right, upward)
local lm, ln, T, S = X.cyl(33, 17, 55, 9, function(t)
  if t > 0.985 then return -1 end
  if t < 0.12 then return 0.7 end
  return max(0.7, 4.2 * sin(pi * min(1, (t - 0.1) / 0.9)) ^ 0.7)
end)
G.tone(c, lm, X.light(ln, { amb = 0.12, wrap = 0.25 }), LEAF, cuts, nil, ltok)
lm:each(function(x, y) local k = K(x, y)
  local s, t = S[k], T[k]
  if t > 0.12 and abs(s) < 0.2 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok)
  elseif t > 0.3 and t < 0.9 then
    local d = (t * 6) % 1
    if d < 0.2 and abs(s) > 0.3 and abs(s) < 0.8 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
  end
end)

-- fruit body: squat ellipse + neck knob
local body = c:ellipse(31, 38, 18, 15)
local knob = c:ellipse(31, 22, 7, 5)
local neck = c:rect(26, 23, 36, 28)
local fruit = HP.mask(); fruit:add(body); fruit:add(knob); fruit:add(neck)
local n = X.pillow(fruit, 12)
local v = X.light(n, { amb = 0.08, wrap = 0.2 })
local bias = {}
X.ao(bias, body, knob, 2, -1)
G.tone(c, fruit, v, ORG, cuts, bias)
-- crease where knob meets body
for x = 25, 37 do c:px(x, 27 + (abs(x - 31) > 4 and 1 or 0), ORG[2]) end
-- pores (dimple texture)
fruit:copy():shrink(2):each(function(x, y)
  local h = X.hash(x, y, 7)
  if h > 0.9 then c:px(x, y, v[K(x, y)] > 0.55 and ORG[5] or ORG[2]) end
end)
-- cool-warm rim (bounce lower right)
local rim = X.rim(n)
fruit:edge():each(function(x, y) if rim[K(x, y)] > 0.7 and y > 40 then c:px(x, y, ORG[5]) end end)
-- specular
c:px(21, 33, "#fff6e0") c:px(22, 33, "#fff6e0") c:px(21, 34, ORG[6]) c:px(23, 32, ORG[6])
c:px(28, 19, ORG[6]) c:px(27, 20, ORG[5])
-- quirk: peeled flap lower right
local flap = c:ellipse(41, 46, 5, 4)
G.tone(c, flap, X.light(X.pillow(flap, 4), { amb = 0.2, wrap = 0.3 }), PITH, { 0.35, 0.7 })
local seg = c:ellipse(40, 46, 3, 2)
c:fillMask(seg, ORG[5]); c:px(39, 45, ORG[6]); c:px(41, 47, ORG[3])
c:px(45, 43, ORG[1]) c:px(46, 44, ORG[1])
-- twig stem on knob
local tm, tn = G.tube({ {31, 19}, {31, 16}, {32, 13}, {34, 11} }, function(t) return 1.6 - 0.5 * t end)
G.tone(c, tm, X.light(tn, { amb = 0.15, wrap = 0.3 }), TWIG, { 0.35, 0.7 })
c:px(30, 21, ORG[1]) c:px(31, 21, ORG[1]) c:px(32, 21, ORG[1])
c:fillMask(c:rect(29, 20, 33, 20), ORG[1])
G.fin(c, "tangelo")
