-- tempeh (lean D3o_1)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function clampi(i, a, b) if not b then a, b = 1, a end return max(a, min(b, i)) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tempeh" }
local CRM  = { "#7d6a58", "#a99882", "#cfc2a6", "#e8dfc6", "#f7f0dc", "#fffdf0" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local TW   = { "#6a4326", "#946038", "#c08a50", "#e0b278" }
c:groundShadow(34, 51, 24, 3)
local top   = c:poly{ {9,28}, {16,21}, {57,21}, {51,28} }
local front = c:rect(9, 28, 50, 47)
local side  = c:poly{ {51,28}, {57,21}, {57,40}, {51,47} }
local all = top:copy():add(front):add(side)
all:cut(c:ellipse(55, 23, 3, 3))   -- quirk: one bite
all:cut(c:rect(9,47,9,47)):cut(c:rect(57,21,57,21))
local function paint(x, y)
  local face = front:has(x, y) and "f" or (side:has(x, y) and "s" or "t")
  local base = face == "t" and 4 or (face == "f" and 3 or 2)
  local leaf
  if face == "t" then leaf = (x + y) < 58 elseif face == "f" then leaf = x < 30 + (y - 28) * 0.4 else leaf = false end
  local col
  if leaf then
    local i = base
    if (y + (face == "t" and x or 0)) % 6 == 1 then i = i + 1 elseif (y + (face == "t" and x or 0)) % 6 == 4 then i = i - 1 end
    if X.hash(x, y, 3) > 0.93 then i = i - 1 end
    if face == "f" and y == 28 then i = i + 1 end
    if face == "f" and y >= 46 then i = i - 1 end
    if face == "f" and x < 12 then i = i - 1 end
    local bx = 30 + (y - 28) * 0.4
    if face == "f" and x >= bx - 1.2 then i = 6 end
    if face == "t" and x + y >= 56.5 then i = 6 end
    col = LEAF[clampi(i, 6)]
  else
    local off = (floor(y / 4) % 2) * 2
    local lx, ly = (x + off) % 4, y % 4
    local i = base + 1
    if lx == 0 or ly == 0 then i = base - 1 end
    if lx == 1 and ly == 1 then i = base + 2 end
    if X.hash(x, y, 7) > 0.9 then i = i - 1 end
    if face == "f" and y >= 46 then i = i - 1 end
    if face == "s" and x >= 56 then i = i - 1 end
    col = CRM[clampi(i, 6)]
  end
  if (face == "t" and (x + y == 52 or x + y == 53)) or (face == "f" and (x == 24 or x == 25)) then
    col = TW[((x + y) % 2 == 0) and 3 or 2]
    if face == "f" and y == 46 then col = TW[1] end
  end
  c:px(x, y, col)
end
all:each(paint)
-- twine tails
c:px(24, 48, TW[2]) c:px(23, 49, TW[2]) c:px(22, 50, TW[1]) c:px(26, 48, TW[2]) c:px(27, 49, TW[1])
-- crumbs
c:px(55, 49, CRM[3]) c:px(57, 48, CRM[2]) c:px(53, 50, CRM[4])
G.fin(c, "tempeh")
