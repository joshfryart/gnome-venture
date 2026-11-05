-- rhubarb-chutney (lean P1b_O7)
-- Squat wide-mouth glass jar of chunky rhubarb chutney (rose-red sauce, pink stalk chunks, mustard seeds), red gingham
-- cloth cap tied with twine, cream label with a stalk. quirk: a kraft gift tag dangles from the twine.
local NAME = "rhubarb-chutney"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local SAUCE = { "#3a0e1e", "#661a2c", "#933040", "#bc4c4c", "#dc7458", "#f4a470" }
local CHUNK = { "#8a2a44", "#b84462", "#dc6c84", "#f4a0b0" }
local GLAS  = { "#3c6a84", "#74a8c0", "#b0d8e8", "#e4f6fa" }
local CL = { { "#b8a898", "#e8dcc8", "#fff6e4" }, { "#a8384a", "#d05864", "#ec8890" }, { "#6a1c34", "#8e2842", "#b43c52" } }
local KRAFT = { "#7e5a34", "#a87c46", "#cfa468", "#e8c88a" }
c:groundShadow(34, 56, 20, 2)
local jar = c:rrect(14, 24, 53, 54, 6)
local inner = jar:copy():shrink(2)
G.toneN(c, jar, X.pillow(jar, 7), GLAS, { cuts = { 0.4, 0.7, 0.9 }, amb = 0.3, wrap = 0.3 })
local bias = {}
X.ao(bias, inner, c:rect(0, 0, 63, 27), 2, -1)
local sn = X.pillow(inner, 10)
-- chunks first as mask for bias
local chunks = HP.mask()
for i = 1, 16 do
  local cx, cy = 18 + floor(X.hash(i, 1, 21) * 31), 29 + floor(X.hash(i, 2, 21) * 22)
  chunks:add(c:rrect(cx, cy, cx + 3, cy + 1 + floor(X.hash(i, 3, 21) * 2), 1))
end
chunks:clip(inner)
G.toneN(c, inner, sn, SAUCE, { bias = bias, amb = 0.05, wrap = 0.2 })
local cv = X.light(sn, { amb = 0.2, wrap = 0.3 })
X.tone(c, chunks, cv, CHUNK, { cuts = { 0.35, 0.6, 0.85 } })
inner:each(function(x, y) if not chunks:has(x, y) and X.hash(x, y, 7) > 0.95 then c:px(x, y, "#f0c040") end end)
-- label
local lab = c:rrect(21, 37, 46, 50, 2)
c:fillMask(lab, "#f2e6c8")
lab:edge():each(function(x, y) c:px(x, y, (x + y > 80) and "#a89478" or "#d0bc98") end)
c:fillMask(c:line({ { 26, 47 }, { 38, 40 } }, 2), "#d04860") c:px(27, 46, "#f08098") c:px(29, 45, "#f08098")
c:fillMask(c:line({ { 38, 40 }, { 42, 39 } }, 1), "#52a048") c:px(41, 38, "#7cc460") c:px(43, 40, "#3a7a3c")
for x = 24, 28 do c:px(x, 39, "#a89478") end
-- gingham cloth cap
local cap = c:ellipse(33, 17, 18, 8):add(c:rect(15, 17, 51, 25))
cap:clip(c:rect(14, 0, 52, 25)):cut(c:rect(0, 0, 63, 8))
for x = 15, 51 do if (floor(x / 3) % 2 == 0) then cap:cut(c:rect(x, 25, x, 25)) end end
local cn = X.pillow(cap, 8, 1.2)
local vv = X.light(cn, { amb = 0.3, wrap = 0.4 })
cap:each(function(x, y)
  local a, b = floor(x / 3) % 2, floor(y / 3) % 2
  local fam = (a == 0 and b == 0) and 3 or ((a == 1 and b == 1) and 1 or 2)
  local val = vv[K(x, y)] or 0.5
  local sh = (val < 0.4) and 1 or ((val < 0.72) and 2 or 3)
  c:px(x, y, CL[fam][sh])
end)
-- cap folds
for x = 17, 49, 4 do c:px(x, 23, CL[3][1]) c:px(x, 24, CL[3][1]) end
-- twine + knot
for x = 15, 51 do c:px(x, 26, ((x % 2 == 0) and KRAFT[2] or KRAFT[1])) end
for x = 15, 51 do c:px(x, 27, KRAFT[1]) end
c:fillMask(c:rect(14, 25, 17, 28), KRAFT[3]) c:px(15, 26, KRAFT[4])
-- tag (quirk)
c:fillMask(c:line({ { 15, 27 }, { 9, 31 } }, 1), KRAFT[2])
local tag = c:rect(4, 31, 11, 40) tag:cut(c:rect(4, 31, 4, 31))
c:fillMask(tag, KRAFT[3])
tag:edge():each(function(x, y) c:px(x, y, KRAFT[2]) end)
c:px(8, 32, KRAFT[1]) c:px(7, 33, KRAFT[4])
c:px(6, 38, "#d04860") c:px(7, 37, "#d04860") c:px(8, 36, "#d04860") c:px(8, 35, "#52a048") c:px(9, 35, "#7cc460")
-- glass highlights
for y = 30, 50 do c:px(16, y, GLAS[4]) end
c:px(17, 31, "#fff4f0") c:px(17, 32, "#fff4f0") c:px(18, 30, SAUCE[6])
for y = 29, 50 do c:px(51, y, "#7aa8c0") end
c:px(50, 47, SAUCE[6]) c:px(24, 52, SAUCE[1])
G.save(c, NAME)
