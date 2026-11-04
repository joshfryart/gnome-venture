-- wild-berry-jam (lean D3o_12)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan2 = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function shade(c, m, ramp, R, o) o = o or {}
  local n = X.pillow(m, R or 4)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias, o.tok)
  return n, v
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wild-berry-jam" }
-- squat jar of dark berry jam, gingham cloth lid tied with twine, hand label with a berry. quirk: a drip down the glass.
local GLASS = { "#3a5f78", "#4f84a0", "#7ab4c8", "#a9d9e0", "#d6f2ee", "#f2fffa" }
local JAM = { "#3a0f33", "#5c1445", "#862250", "#b13555", "#d5566a", "#ef8a8c" }
local CLOTH = { "#8e2e3c", "#b84552", "#d9707a", "#f0a3a8" }
local gp = c:rrect(16, 26, 47, 54, 6)
c:groundShadow(32, 56, 14, 2)
shade(c, gp, GLASS, 6, { amb = 0.2, wrap = 0.35 })
local inner = c:rrect(18, 28, 45, 52, 5)
local n, v = shade(c, inner, JAM, 7, { amb = 0.08, wrap = 0.2 })
inner:each(function(x, y) if v[K(x, y)] > 0.8 and X.hash(x, y, 3) > 0.75 then c:px(x, y, JAM[6]) end end)
-- glass glint strip + rim
c:line({ {20, 31}, {20, 44} }, 1):each(function(x, y) c:px(x, y, GLASS[6]) end)
c:px(21, 30, GLASS[5]) c:px(21, 46, GLASS[5])
-- neck rim
local neck = c:rrect(20, 21, 43, 26, 2)
shade(c, neck, GLASS, 3, { amb = 0.2 })
-- cloth lid, scalloped
local lid = c:rrect(15, 12, 48, 22, 3)
for _, x in ipairs{ 17, 24, 31, 38, 45 } do lid:add(c:ellipse(x, 23, 3, 3)) end
local ln = shade(c, lid, CLOTH, 4, { amb = 0.25, wrap = 0.3 })
lid:each(function(x, y) if (floor((x + 1) / 3) + floor(y / 3)) % 2 == 0 then c:px(x, y, CLOTH[1 + (y > 18 and 1 or 0)]) end end)
c:fillMask(c:rect(19, 12, 44, 12), CLOTH[4])
-- twine
c:fillMask(c:rect(18, 24, 45, 24), "#c9a05a") c:fillMask(c:rect(18, 25, 45, 25), "#8a6234")
c:px(40, 26, "#c9a05a") c:px(41, 27, "#c9a05a") c:px(41, 28, "#8a6234") c:px(21, 26, "#c9a05a") c:px(20, 27, "#8a6234")
-- label
local lab = c:rrect(22, 35, 41, 47, 2)
shade(c, lab, { "#a58a64", "#cdb68a", "#e8d8ae", "#f6ecc8" }, 5, { amb = 0.3 })
-- berry on label
c:fillMask(c:ellipse(31, 42, 3, 3), "#a82a4c") c:px(30, 41, "#ef7a8a") c:px(33, 43, "#6e1a3a")
c:px(30, 38, "#4b9650") c:px(31, 39, "#4b9650") c:px(32, 39, "#32764b") c:px(33, 38, "#4b9650")
c:fillMask(c:rect(25, 36, 38, 36), "#e8d8ae")
-- drip (quirk)
c:fillMask(c:rect(44, 29, 44, 40), JAM[3]) c:px(44, 41, JAM[2]) c:px(44, 42, JAM[2]) c:px(43, 43, JAM[2]) c:px(44, 43, JAM[3]) c:px(44, 44, JAM[2])
c:px(44, 31, JAM[6])
G.fin(c, "wild-berry-jam")
