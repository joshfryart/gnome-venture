-- sunflower-butter (lean D2o_17)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function shade(c, m, ramp, R, tok, bias, o)
  o = o or {} o.tok = tok o.bias = bias
  local n = X.pillow(m, R) local idx, v = G.toneN(c, m, n, ramp, o) return idx, v, n
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "sunflower-butter" }
local GLASS = { "#5b6f94", "#8aa0bf", "#b4c8d8", "#d4e2e6", "#eaf2ee", "#f8fbf4" }
local BUT   = { "#6e4a1e", "#9a6a22", "#c68f2a", "#e6b83c", "#f6d964", "#fff0a0" }
local LAB   = { "#8a6a4a", "#b99468", "#dcc392", "#f0e0b4", "#f8eecb", "#fffbe6" }
local LID   = { "#5a2a2a", "#8a3b32", "#b5523d", "#d8774a", "#ec9a5c", "#f8c07c" }
c:groundShadow(32, 57, 17, 2)
local glass = c:rrect(14, 24, 49, 54, 5)
shade(c, glass, GLASS, 12, { r = { name = "glass" } })
local inner = c:rrect(16, 28, 47, 52, 4)
shade(c, inner, BUT, 11, { r = { name = "butter" } })
-- butter top swirl
c:fillMask(c:ellipse(31, 29, 13, 2), BUT[5])
c:fillMask(c:ellipse(29, 29, 7, 1), BUT[6])
-- label
local lab = c:rrect(23, 37, 40, 50, 2)
shade(c, lab, LAB, 7, { r = { name = "label" } })
-- sunflower on label
local cx, cy = 31.5, 43.5
for y = 37, 50 do for x = 23, 40 do
  local dx, dy = x - cx, y - cy
  local d = sqrt(dx*dx + dy*dy)
  local a = atan(dy, dx)
  if d <= 2.3 then c:px(x, y, (dx + dy < 0) and "#6a4020" or "#3e2414")
  elseif d <= 5.3 and (d < 3.6 or abs(sin(a * 4)) > 0.4) then
    c:px(x, y, (dx + dy < -1) and "#ffe270" or ((dx + dy > 2) and "#d98a1a" or "#f6c529"))
  end
end end
-- tin lid with ridges
local lid = c:rrect(16, 14, 47, 24, 2)
shade(c, lid, LID, 5, { r = { name = "lid" } })
for x = 18, 45, 3 do for y = 16, 22 do c:px(x, y, LID[2]) end end
c:fillMask(c:rect(18, 24, 45, 25), "#3a2a3a")
-- glass streak + lid glint
for y = 31, 46 do c:px(17, y, GLASS[6]) end
c:px(18, 31, GLASS[5]) c:px(18, 47, GLASS[5])
c:px(21, 16, "#fff6f2") c:px(22, 16, "#fff6f2") c:px(21, 17, LID[6])
-- quirk: butter drip over the lid edge
for y = 22, 29 do c:px(48, y, BUT[4]) c:px(47, y, BUT[3]) end
c:px(48, 30, BUT[5]) c:px(48, 31, BUT[4]) c:px(47, 31, BUT[3])
G.save(c, "sunflower-butter")
