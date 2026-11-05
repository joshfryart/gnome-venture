-- pear (lean P1b_O6)
local NAME = "pear"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function line(pts, hex) c:line(pts, 1):each(function(x, y) c:px(x, y, hex) end) end
local function paint(m, ramp, R, o) o = o or {} local n = X.pillow(m, R) local _, v = G.toneN(c, m, n, ramp, o) return n, v end

local GREEN = { "#27431c", "#477a21", "#78aa2b", "#a9cc3d", "#d4e468", "#f2f5a4" }
local ORNG  = { "#6a2a18", "#b0401e", "#dc5c2c", "#f08a3c", "#fab45c" }
local LEAF  = { "#17392c", "#1f5a34", "#2f7d3a", "#4a9c42", "#74bb4e", "#a3d664" }
c:groundShadow(33, 56, 13, 2)
local body = c:ellipse(32, 43, 15, 13):add(c:ellipse(32, 28, 8, 11)):add(c:ellipse(32, 35, 11.5, 9))
local n, v = paint(body, GREEN, 10, { amb = 0.08, wrap = 0.2 })
-- blush on lit-away side
local bl = c:ellipse(41, 46, 8, 9):clip(body)
bl:each(function(x, y) if X.hash(x, y, 2) > 0.18 or bl:copy():shrink(1):has(x, y) then
  local t = v[K(x, y)] or 0.5
  local i = t < 0.3 and 1 or t < 0.5 and 2 or t < 0.72 and 3 or t < 0.88 and 4 or 5
  c:px(x, y, ORNG[i]) end end)
-- lenticels
body:each(function(x, y) if X.hash(x, y, 7) > 0.955 and (v[K(x, y)] or 0) > 0.3 then c:px(x, y, GREEN[2]) end end)
-- bloom + spec
c:px(26, 40, "#fffbe0") c:px(26, 41, "#fffbe0") c:px(27, 39, GREEN[6]) c:px(27, 42, GREEN[6])
c:px(28, 27, GREEN[6]) c:px(28, 28, GREEN[6])
-- calyx dimple at base
c:px(32, 55, GREEN[1]) c:px(31, 54, GREEN[2]) c:px(33, 54, GREEN[2])
-- stem + leaf
local sm, sn = G.tube({ {32,18}, {32,13}, {34,10}, {37,7} }, function(t) return 1.5 - 0.4 * t end)
G.toneN(c, sm, sn, { "#2e1a10", "#5a3a22", "#8a5e36", "#b88a52" })
local lm, ln = G.blade(35, 11, 43, 2, 57, 11, function(t) return 5.2 * sin(pi * t) ^ 0.75 end, { fold = 0.3 })
G.toneN(c, lm, ln, LEAF)
line(c, { {36,11},{42,7},{50,8},{55,10} }, LEAF[6])
-- ladybird quirk
c:fillMask(c:rect(37, 31, 39, 33), "#d8342c") c:px(37, 31, "#f2705a") c:px(38, 33, "#8e1c24") c:px(39, 33, "#8e1c24")
c:px(38, 32, "#2b1c26") c:px(37, 32, "#2b1c26") c:px(38, 30, "#2b1c26") c:px(39, 30, "#2b1c26")
G.save(c, NAME)
