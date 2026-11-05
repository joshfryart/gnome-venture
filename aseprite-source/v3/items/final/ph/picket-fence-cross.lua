-- picket-fence-cross (lean P1b_O6)
local NAME = "picket-fence-cross"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function paint(m, ramp, R, o) o = o or {} local n = X.pillow(m, R) local _, v = G.toneN(c, m, n, ramp, o) return n, v end

local WOOD = { "#2f1c14", "#53321e", "#7a4d2a", "#a1713c", "#c79a5c" }
local PK   = { "#5a5f92", "#9097c4", "#cfd2e6", "#f1eee4", "#fbf6e8" }
local CAP  = { W = "#dbe6f6", N = "#8fabdc", E = "#5a72b0", S = "#34457f" }
local function board(x0, y0, x1, y1)
  c:fillMask(c:rect(x0, y0, x1, y1), PK[3])
  for x = x0, x1 do c:px(x, y0, PK[5]) c:px(x, y1, PK[2]) end
  for y = y0, y1 do c:px(x0, y, PK[5]) c:px(x1, y, PK[2]) end
  c:px(x0, y1, PK[1]) c:px(x1, y1, PK[1]) c:px(x1, y0, PK[3]) c:px(x0, y0, PK[5])
  c:px((x0 + x1) // 2, (y0 + y1) // 2, PK[4])
end
local function shadow(x0, y0, x1, y1) c:fillMask(c:rect(x0 + 1, y0 + 1, x1 + 1, y1 + 1), WOOD[1]) end
-- rails
local function railH(xa, xb) for x = xa, xb do
  c:px(x, 30, WOOD[5]) c:px(x, 31, WOOD[4]) c:px(x, 32, WOOD[3]) c:px(x, 33, WOOD[2])
  if X.hash(x, 31, 5) > 0.7 then c:px(x, 31, WOOD[3]) end end end
local function railV(ya, yb) for y = ya, yb do
  c:px(30, y, WOOD[5]) c:px(31, y, WOOD[4]) c:px(32, y, WOOD[3]) c:px(33, y, WOOD[2])
  if X.hash(31, y, 5) > 0.7 then c:px(31, y, WOOD[3]) end end end
railH(6, 57) railV(6, 57)
local pos = { 6, 12, 18, 42, 48, 54 }
for _, p in ipairs(pos) do shadow(p, 28, p + 3, 35) shadow(28, p, 35, p + 3) end
for _, p in ipairs(pos) do board(p, 28, p + 3, 35) board(28, p, 35, p + 3) end
-- central post with pyramid cap
for y = 27, 36 do for x = 27, 36 do
  local col
  if x == 27 or y == 27 then col = WOOD[4] elseif x == 36 or y == 36 then col = WOOD[2]
  else local dx, dy = x - 31.5, y - 31.5
    if abs(dx) > abs(dy) then col = dx < 0 and CAP.W or CAP.E
    elseif abs(dy) > abs(dx) then col = dy < 0 and CAP.N or CAP.S
    else col = dx < 0 and CAP.W or CAP.S end end
  c:px(x, y, col)
end end
c:px(31, 31, "#fffaf0") c:px(32, 31, CAP.W) c:px(30, 30, "#fffaf0")
-- ladybird quirk on a picket
c:fillMask(c:rect(19, 30, 21, 32), "#d8342c") c:px(19, 30, "#f2705a") c:px(20, 31, "#2b1c26") c:px(19, 32, "#2b1c26") c:px(21, 32, "#8e1c24") c:px(20, 29, "#2b1c26")
G.save(c, NAME)
