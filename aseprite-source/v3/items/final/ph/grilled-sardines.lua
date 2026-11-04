-- grilled-sardines (lean W2_5)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "grilled-sardines" }
local sin, pi, abs, floor = math.sin, math.pi, math.abs, math.floor
local WOOD = { "#4a2c1e", "#6e4428", "#8f5d34", "#b07c46", "#cc9a5e", "#e3b97a" }
local SIL = { "#3a4a66", "#6c7e9c", "#9fb2c8", "#c8d6e0", "#e8f0f2", "#f4fbff" }
c:groundShadow(30, 52, 24, 2)
-- board + handle
local board = c:rrect(5, 21, 47, 49, 3):add(c:rect(46, 30, 57, 36)):add(c:ellipse(57, 33, 3, 3))
local hole = c:ellipse(54, 33, 1, 1)
local bn = X.pillow(board, 6)
G.tone(c, board, X.light(bn, { amb = 0.35, wrap = 0.5 }), WOOD, { 0.2, 0.35, 0.5, 0.65, 0.85 }, nil, { r = { name = "board" } })
board:each(function(x, y) if (y % 5 == 0) and X.hash(x, y, 1) > 0.35 then c:px(x, y, WOOD[2]) end end)
hole:each(function(x, y) c:px(x, y, WOOD[1]) end)
local function fish(p, w, y0)
  local m, n, T, S = G.tube(p, function(t) return w * (0.25 + 0.75 * sin(pi * math.min(1, t * 0.9 + 0.08)) ^ 0.7) end)
  local tx, ty = p[4][1], p[4][2]
  local tail = c:poly{ {tx - 1, ty}, {tx + 5, ty - 5}, {tx + 4, ty}, {tx + 5, ty + 5} }
  G.tone(c, tail, X.light(X.pillow(tail, 3), {}), SIL, nil, nil, { r = { name = "fin" } })
  G.tone(c, m, X.light(n, { amb = 0.2, wrap = 0.4 }), SIL, { 0.18, 0.34, 0.5, 0.68, 0.86 }, nil, { r = { name = "fish" } })
  m:each(function(x, y) local k = K(x, y)
    if S[k] < -0.55 and T[k] > 0.1 then c:px(x, y, S[k] < -0.75 and SIL[1] or SIL[2]) end
    local d = ((x - p[1][1]) * 0.7 + (y - p[1][2])) % 6
    if d < 1.2 and T[k] > 0.2 and T[k] < 0.9 then c:px(x, y, "#2b1c26") end   -- grill marks
  end)
  c:px(p[1][1] + 3, p[1][2] - 1, SIL[6]) c:px(p[1][1] + 2, p[1][2] - 1, "#2b1c26")  -- eye
  c:px(p[1][1] + 5, p[1][2], SIL[1]) c:px(p[1][1] + 5, p[1][2] + 1, SIL[1])          -- gill
  c:px(p[1][1] + 10, p[1][2] - 3, SIL[6]) c:px(p[1][1] + 11, p[1][2] - 3, SIL[5])    -- glint
end
fish({ {9,29},{18,26},{28,32},{37,28} }, 4.2)
fish({ {9,41},{18,44},{28,38},{37,42} }, 4.0)
-- lemon wedge
local lem = c:poly{ {40,24},{51,24},{47,29} }
G.tone(c, lem, X.light(X.pillow(lem, 3), { amb = 0.4 }), { "#b88a12", "#e0b020", "#f4d238", "#fbe670", "#fff3a0", "#fffbd0" }, nil, nil, { r = { name = "lemon" } })
c:px(43, 25, "#fffbd0") c:px(46, 25, "#fffbd0")
-- quirk: curl of steam
for i, p in ipairs{ {26,18},{27,16},{26,14},{27,12},{26,10},{27,8} } do c:px(p[1], p[2], i % 2 == 0 and "#e8f0f2" or "#c8d6e0") end
c:px(27, 18, "#c8d6e0") c:px(26, 12, "#c8d6e0")
G.fin(c, "grilled-sardines")
