-- picket-fence-cross (lean W2_13)
-- Plan view from above: a plus of four picket runs meeting at a blue-capped centre post; pickets are pointed tops seen from above.
-- quirk: a ladybug walks on one picket.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sqrt = math.floor, math.abs, math.sqrt
local WOOD  = { "#3d2418", "#5e3a22", "#8a5a32", "#b0804a", "#d3a766" }
local WHITE = { "#5d5a84", "#8d8aae", "#bdbcd2", "#e4e1e6", "#fbf6ea" }
local BLUE  = { "#223a6e", "#31569a", "#4c7cc4", "#7aaae0", "#b4d6f5" }
local function shade(x, y, x0, y0, x1, y1, R, base)
  local i = base or 3
  if x == x0 then i = i + 1 elseif x == x1 then i = i - 1 end
  if y == y0 then i = i + 1 elseif y == y1 then i = i - 1 end
  return R[math.max(1, math.min(#R, i))]
end
local function box(c, x0, y0, x1, y1, R, base, grain)
  for y = y0, y1 do for x = x0, x1 do
    local col = shade(x, y, x0, y0, x1, y1, R, base)
    if grain and X.hash(x, y, grain) > 0.82 and x > x0 and x < x1 then col = R[math.max(1, (base or 3) - 1)] end
    c:put(x, y, col)
  end end
end
local NAME = "picket-fence-cross"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
-- ground shadow
c:fillMask(c:rect(9, 33, 59, 38), "#9a94a8") c:fillMask(c:rect(35, 9, 38, 59), "#9a94a8")
-- rails
box(c, 7, 29, 56, 34, WOOD, 3, 5)
box(c, 29, 7, 34, 56, WOOD, 3, 6)
-- pickets as pointed square tops (lit from upper-left)
local function pk(cx, cy)
  for dy = -2, 2 do for dx = -2, 2 do
    local x, y = cx + dx, cy + dy
    local col = WHITE[4]
    if dx + dy < -1 then col = WHITE[5] elseif dx + dy > 1 then col = WHITE[3] end
    if dx == 0 and dy == 0 then col = WHITE[5] end
    if dx == 2 or dy == 2 then col = WHITE[2] end
    c:put(x, y, col)
  end end
  c:px(cx - 1, cy - 1, WHITE[5])
end
for _, p in ipairs{ 10, 16, 22, 41, 47, 53 } do pk(p, 31) pk(31, p) end
-- centre post + pyramid cap
box(c, 26, 26, 37, 37, WOOD, 3)
for y = 27, 36 do for x = 27, 36 do
  local dx, dy = x - 31.5, y - 31.5
  local col
  if abs(dx) > abs(dy) then col = dx < 0 and BLUE[4] or BLUE[2] else col = dy < 0 and BLUE[5] or BLUE[1] end
  c:put(x, y, col)
end end
c:px(31, 31, BLUE[5]) c:px(32, 32, BLUE[3]) c:px(30, 30, "#fff6f2")
-- ladybug quirk
c:px(47, 30, "#d6303a") c:px(48, 30, "#d6303a") c:px(47, 31, "#d6303a") c:px(48, 31, "#a01e2c") c:px(46, 30, "#2b1c26")
G.save(c, NAME)
