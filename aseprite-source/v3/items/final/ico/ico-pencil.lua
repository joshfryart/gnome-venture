local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-pencil: chunky yellow pencil on the diagonal, wood cone with a graphite point, steel ferrule, pink eraser.
-- quirk: a few eraser crumbs and a tiny pencil squiggle trail off the tip.
local c = D.new("ico-pencil")
local function seg(ax, ay, bx, by, w, ramp, taper)
  return D.cyl(c, ax, ay, bx, by, function(t) if taper == "pt" then return max(0.5, w * t) end return w end, ramp, { amb = 0.1 })
end
seg(26, 40, 17, 49, 4.6, D.TAN, "pt")
seg(17, 49, 12, 54, 2.8, D.GRY, "pt")
seg(13, 53, 9, 57, 1.6, { "#1c1620", "#2b2432", "#3d3445", "#524a5e", "#6a6278", "#867e94" }, "pt")
local body = seg(26, 40, 44, 22, 4.6, D.YEL)
for i = -1, 1 do
  local ox = i * 2
  D.ln(c, 27 - ox / 2 + ox, 40 - ox / 2 - ox, 43 + ox, 22 - ox, i == 0 and D.YEL[2] or D.YEL[5], body)
end
seg(44, 22, 48, 18, 4.6, D.GRY)
D.ln(c, 45, 21, 47, 19, D.GRY[1])
seg(48, 18, 53, 13, 4.6, D.PINK)
c:px(50, 14, D.PINK[6]) c:px(51, 14, D.PINK[6])
c:px(55, 20, D.PINK[3]) c:px(57, 17, D.PINK[4]) c:px(58, 22, D.PINK[3])
D.pts(c, { {5, 52}, {5, 51}, {6, 50}, {7, 50} }, D.GRY[2])
D.fin()
