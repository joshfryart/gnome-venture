-- picket-fence-tee (lean P1b_O6)
local NAME = "picket-fence-tee"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function paint(m, ramp, R, o) o = o or {} local n = X.pillow(m, R) local _, v = G.toneN(c, m, n, ramp, o) return n, v end

local WOOD = { "#2f1c14", "#53321e", "#7a4d2a", "#a1713c", "#c79a5c" }
local PK   = { "#5a5f92", "#9097c4", "#cfd2e6", "#f1eee4", "#fbf6e8" }
local CAP  = { W = "#dbe6f6", N = "#8fabdc", E = "#5a72b0", S = "#34457f" }
local P = 10
local function board(x0, y0, x1, y1)
  c:fillMask(c:rect(x0, y0, x1, y1), PK[3])
  for x = x0, x1 do c:px(x, y0, PK[5]) c:px(x, y1, PK[2]) end
  for y = y0, y1 do c:px(x0, y, PK[5]) c:px(x1, y, PK[2]) end
  c:px(x0, y1, PK[1]) c:px(x1, y1, PK[1]) c:px(x1, y0, PK[3]) c:px(x0, y0, PK[5])
  c:px((x0 + x1) // 2, (y0 + y1) // 2, PK[4])
end
local function shadow(x0, y0, x1, y1) c:fillMask(c:rect(x0 + 1, y0 + 1, x1 + 1, y1 + 1), WOOD[1]) end
local ry = P + 3
for x = 6, 57 do
  c:px(x, ry, WOOD[5]) c:px(x, ry + 1, WOOD[4]) c:px(x, ry + 2, WOOD[3]) c:px(x, ry + 3, WOOD[2])
  if X.hash(x, 5, 5) > 0.7 then c:px(x, ry + 1, WOOD[3]) end end
for y = P + 8, P + 43 do
  c:px(30, y, WOOD[5]) c:px(31, y, WOOD[4]) c:px(32, y, WOOD[3]) c:px(33, y, WOOD[2])
  if X.hash(5, y, 5) > 0.7 then c:px(31, y, WOOD[3]) end end
local xs = { 6, 12, 18, 42, 48, 54 }
local ys = {}
for i = 0, 5 do ys[#ys + 1] = P + 15 + i * 6 end
for _, p in ipairs(xs) do shadow(p, P + 1, p + 3, P + 8) end
for _, p in ipairs(ys) do shadow(28, p, 35, p + 3) end
for _, p in ipairs(xs) do board(p, P + 1, p + 3, P + 8) end
for _, p in ipairs(ys) do board(28, p, 35, p + 3) end
for y = P, P + 9 do for x = 27, 36 do
  local col
  if x == 27 or y == P then col = WOOD[4] elseif x == 36 or y == P + 9 then col = WOOD[2]
  else local dx, dy = x - 31.5, y - (P + 4.5)
    if abs(dx) > abs(dy) then col = dx < 0 and CAP.W or CAP.E
    elseif abs(dy) > abs(dx) then col = dy < 0 and CAP.N or CAP.S
    else col = dx < 0 and CAP.W or CAP.S end end
  c:px(x, y, col)
end end
-- bluebird perched on the cap (quirk)
local bird = c:ellipse(31, P + 4, 3.4, 2.4)
paint(bird, { "#1f2f78", "#2f4ca8", "#4673d4", "#78a2ee", "#b0cdfa" }, 3, { amb = 0.15 })
c:px(34, P + 3, "#f2b632") c:px(35, P + 3, "#f2b632") c:px(33, P + 3, "#fffaf0") c:px(33, P + 2, "#2b1c26")
c:px(28, P + 5, "#1f2f78") c:px(27, P + 6, "#1f2f78") c:px(28, P + 6, "#2f4ca8")
G.save(c, NAME)
