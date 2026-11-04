-- rhubarb-chutney (lean W2_16)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function cyl(m, cx, hw) local n = {} m:each(function(x, y) local nx = max(-0.97, min(0.97, (x - cx) / hw)); n[K(x, y)] = { nx, -0.1, sqrt(1 - nx * nx) } end) return n end
local function shade(c, m, n, ramp, bias, amb) G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, nil, bias) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "rhubarb-chutney" }
c:groundShadow(32, 54, 16, 3)
local GL = { "#3d6b86", "#5d93ad", "#86bfd0", "#b3e0e6", "#dff5f2", "#f3fffb" }
local CH = { "#3a1420", "#5c1b2a", "#8a2a36", "#b04542", "#d06a52", "#e8946a" }
local CL = { "#5a1424", "#8a1f34", "#b8324a", "#d9566a", "#ef8090", "#ffb4bc" }
local glass = c:rrect(19, 26, 45, 52, 4):add(c:rect(23, 21, 41, 27))
shade(c, glass, cyl(glass, 32, 13), GL)
local ch = c:rrect(21, 29, 43, 50, 3)
shade(c, ch, cyl(ch, 32, 11), CH)
ch:each(function(x, y)
  local h = X.hash(x, y, 7)
  if y > 30 and x > 22 and x < 42 then
    if h > 0.93 then c:px(x, y, "#e88aa0") elseif h > 0.88 then c:px(x, y, "#e0a040") end
  end
end)
for x = 22, 42 do c:px(x, 29, CH[5]) end
for y = 32, 48 do c:px(20, y, GL[5]) end
for y = 33, 47 do c:px(43, y, GL[1]) end
c:px(20, 30, GL[6]) c:px(20, 31, GL[6])
-- label
c:fillMask(c:rect(25, 36, 38, 46), "#f2e4c4")
for x = 25, 38 do c:px(x, 46, "#c9ad82") end
for y = 36, 46 do c:px(38, y, "#c9ad82") end
c:fillMask(c:line({ { 28, 43 }, { 33, 38 } }, 1), "#d04868")
c:px(34, 38, "#4b9650") c:px(35, 37, "#4b9650") c:px(34, 37, "#70b45a")
for x = 28, 35, 2 do c:px(x, 44, "#a88a66") end
-- cloth cap with scalloped hem
local cl = c:ellipse(32, 18, 12, 5):add(c:rect(20, 18, 44, 25))
for x = 20, 44 do if (x - 20) % 6 >= 4 then for y = 24, 26 do cl:cut(c:rect(x, y, x, y)) end end end
local bias = {}
cl:each(function(x, y) if (floor(x / 3) + floor(y / 3)) % 2 == 0 then bias[K(x, y)] = -1 end end)
shade(c, cl, X.pillow(cl, 6), CL, bias, 0.12)
c:px(27, 14, CL[6]) c:px(28, 14, CL[6]) c:px(26, 15, CL[5])
-- twine, bow and tag
c:fillMask(c:line({ { 21, 25 }, { 43, 25 } }, 1), "#c9a468")
for x = 22, 42, 2 do c:px(x, 26, "#8a6a3c") end
c:fillMask(c:ellipse(18, 23, 2, 1.5), "#c9a468") c:fillMask(c:ellipse(18, 27, 2, 1.5), "#c9a468")
c:px(20, 25, "#8a6a3c") c:px(19, 25, "#c9a468")
c:fillMask(c:line({ { 18, 27 }, { 15, 31 } }, 1), "#8a6a3c")
c:fillMask(c:rect(11, 31, 17, 38), "#d9b27a")
for x = 11, 17 do c:px(x, 38, "#a07c4c") end
c:px(14, 32, "#5a3a22") c:fillMask(c:rect(13, 34, 14, 36), "#d04868") c:px(15, 34, "#4b9650")
G.fin(c, "rhubarb-chutney")
