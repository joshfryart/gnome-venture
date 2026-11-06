-- soy-sauce (lean D2o_3)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "soy-sauce" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(m, R, ramp, o) o = o or {}
  local n = X.pillow(m, R) local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias) return v, n end
local function fill(m, hex) c:fillMask(m, hex) end
-- tall dark glass bottle, red spout cap with a drip (quirk), kanji-ish label, puddle in a saucer
local GL = { "#1a0f14", "#2c1a1a", "#4a2a1e", "#6e3d22", "#95582c", "#c98a4a" }
local CAP = { "#5a1420", "#8a1f2a", "#b8322e", "#dc5a3c", "#f08a5e" }
local SAU = { "#8e92b0", "#b4b8cc", "#d6d8e4", "#eceef4", "#fbfbfd" }
local saucer = c:ellipse(32, 56, 17, 4)
shade(saucer, 4, SAU, { cuts = { 0.2, 0.4, 0.6, 0.8 } })
fill(c:ellipse(32, 56, 11, 2), "#2c1a1a") fill(c:ellipse(30, 55, 5, 1), "#4a2a1e") c:px(28, 55, "#95582c") c:px(29, 55, "#c98a4a")
local bottle = HP.mask() bottle:add(c:rrect(21, 27, 43, 55, 3)) bottle:add(c:poly{ {21,29}, {27,20}, {37,20}, {43,29} })
bottle:add(c:rect(27, 14, 37, 22))
shade(bottle, 9, GL, { amb = 0.12 })
-- glass rim light (left) and amber glow (bottom right)
for y = 31, 52 do c:px(23, y, "#c98a4a") c:px(24, y, "#95582c") end
for y = 26, 29 do c:px(25 - (y - 26), y, "#95582c") end
for x = 33, 41 do c:px(x, 53, "#6e3d22") end for y = 40, 53 do c:px(41, y, "#4a2a1e") end
-- label
fill(c:rect(25, 34, 39, 47), "#f3e6c8") fill(c:rect(25, 47, 39, 47), "#c4a876") fill(c:rect(39, 34, 39, 47), "#d9c8a0")
fill(c:rect(25, 34, 39, 35), "#c8352e")
-- little bean mark + text
fill(c:ellipse(30, 40, 2, 1), "#6f9a3f") fill(c:ellipse(34, 40, 2, 1), "#6f9a3f") c:px(29, 39, "#a8cc70") c:px(33, 39, "#a8cc70")
for x = 27, 37 do c:px(x, 43, "#7a5a3a") end for x = 28, 35 do c:px(x, 45, "#a98a58") end
-- cap + spout
fill(c:rect(26, 9, 37, 15), CAP[3]) fill(c:rect(26, 9, 37, 10), CAP[5]) fill(c:rect(26, 14, 37, 15), CAP[2])
fill(c:rect(37, 10, 43, 13), CAP[3]) fill(c:rect(37, 10, 43, 10), CAP[5]) fill(c:rect(37, 13, 43, 13), CAP[1])
for y = 10, 15 do c:px(26, y, CAP[4]) end for y = 11, 15 do c:px(36, y, CAP[2]) end
fill(c:rect(25, 16, 38, 16), "#2c1a1a")
-- drip off the spout
c:px(43, 14, "#4a2a1e") c:px(43, 15, "#2c1a1a") c:px(43, 16, "#2c1a1a") c:px(43, 17, "#4a2a1e") c:px(42, 18, "#2c1a1a") c:px(43, 18, "#6e3d22") c:px(43, 19, "#2c1a1a")
c:px(22, 29, "#e0c08a") c:px(22, 30, "#e0c08a")
G.fin(c, "soy-sauce")
