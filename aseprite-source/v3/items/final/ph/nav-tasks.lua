-- nav-tasks (lean W2_10)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.2, 0.38, 0.55, 0.7, 0.86 }
local function slab(c, m, R, ramp, amb, bias) local n = X.pillow(m, R) G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, CUTS, bias) return n end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "nav-tasks" }
local WD = { "#3e2418", "#6a3e24", "#945a32", "#b87a44", "#d49c5c", "#ecc27c" }
local PA = { "#9a8e9a", "#c4baa8", "#e4dac4", "#f4ecd8", "#fcf6e6", "#fffdf4" }
local GD = { "#6a3e1c", "#a06a24", "#d49a30", "#f0c850", "#fce48a", "#fff6c4" }
local GR = { "#1f5a34", "#2f8a44", "#58b85a", "#92dc7c" }
local BU = { "#2a4a8a", "#3f6cc0", "#7ca4e8", "#c4dcfa" }
-- board
local board = c:rrect(14, 9, 49, 57, 2)
slab(c, board, 4, WD, 0.1)
board:each(function(x, y) if (y * 3 + floor(x / 5) * 7) % 11 == 0 and X.hash(x, y, 2) > 0.3 then c:px(x, y, WD[2]) end end)
-- paper
local paper = c:rect(18, 15, 45, 53)
slab(c, paper, 3, PA, 0.35)
c:fillMask(c:rect(45, 16, 45, 53), PA[2])
-- rows: checkbox + text line
local rows = { {21, true}, {30, true}, {39, false} }
for _, r in ipairs(rows) do
  local y = r[1]
  c:fillMask(c:rect(21, y, 27, y + 6), BU[1]) c:fillMask(c:rect(22, y + 1, 26, y + 5), r[2] and BU[3] or PA[6])
  c:px(22, y + 1, BU[4]) c:px(23, y + 1, BU[4])
  if r[2] then G.line(c, { {22, y + 3}, {24, y + 5}, {28, y - 1} }, GR[2]) c:px(24, y + 4, GR[3]) c:px(27, y, GR[4]) end
  c:fillMask(c:rect(30, y + 1, 41, y + 2), r[2] and PA[1] or "#4a3a4e")
  c:fillMask(c:rect(30, y + 4, 37, y + 4), PA[2])
end
-- clip
local clip = c:rrect(24, 5, 39, 14, 2)
slab(c, clip, 4, GD, 0.1)
c:fillMask(c:rect(28, 8, 35, 10), GD[1]) c:fillMask(c:rect(29, 9, 34, 9), "#2b1c26")
c:px(26, 7, GD[6]) c:px(27, 7, GD[5])
-- quirk: stub pencil tucked behind lower-right corner
local pen = c:poly{ {42, 56}, {52, 46}, {54, 48}, {44, 58} }
G.tone(c, pen, X.light(X.pillow(pen, 2), { amb = 0.3, wrap = 0.3 }), { "#a8721c", "#d49a30", "#f0c850", "#fce48a", "#fce48a", "#fff6c4" }, CUTS)
c:px(53, 47, "#e592b0") c:px(52, 46, "#c0628c") c:px(42, 57, "#3e2418")
G.fin(c, "nav-tasks")
