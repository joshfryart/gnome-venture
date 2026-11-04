-- picket-fence-tee (lean W2_13)
-- Side elevation: a back run of pointed pickets on two rails, with a stem run coming toward the viewer (foreshortened) at a tall finial post.
-- quirk: a tiny bluebird perched on the finial.
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
local NAME = "picket-fence-tee"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
c:fillMask(c:ellipse(32, 56, 12, 2), "#9a94a8") c:fillMask(c:ellipse(32, 56, 6, 1), "#7c7690")
-- back run
box(c, 6, 17, 57, 19, WOOD, 3, 2) box(c, 6, 28, 57, 30, WOOD, 3, 3)
local function picket(x0)
  local x1 = x0 + 4
  for y = 11, 36 do for x = x0, x1 do
    local row = y - 11
    local half = (row == 0) and 0 or (row == 1) and 1 or 2
    if abs(x - (x0 + 2)) <= half then
      local col = WHITE[4]
      if x == x0 then col = WHITE[5] elseif x == x1 then col = WHITE[2] elseif x == x1 - 1 then col = WHITE[3] end
      if y >= 35 then col = WHITE[2] end
      if (y == 17 or y == 18 or y == 28 or y == 29) and x ~= x0 then col = WHITE[3] end
      if X.hash(x, y, 8) > 0.95 then col = WHITE[3] end
      c:put(x, y, col)
    end
  end end
end
for _, x in ipairs{ 6, 12, 18, 24, 40, 46, 52 } do picket(x) end
-- front-coming run: stem rail foreshortened, picket ends stepping down and widening
box(c, 29, 37, 34, 55, WOOD, 3, 4)
for i, y in ipairs{ 38, 43, 48 } do
  local w = 3 + i
  box(c, 31 - w - 1, y, 28, y + 2, WHITE, 3) box(c, 35, y, 35 + w + 1, y + 2, WHITE, 3)
  c:px(31 - w - 1, y, WHITE[2])
end
-- junction post with ball finial
box(c, 28, 8, 35, 38, WOOD, 3, 9)
c:fillMask(c:ellipse(31.5, 6, 3.5, 3.5), WOOD[4]) c:px(30, 4, WOOD[5]) c:px(31, 4, WOOD[5]) c:px(33, 8, WOOD[2])
box(c, 28, 8, 35, 9, WOOD, 2)
-- front end post cap
box(c, 28, 53, 35, 56, WOOD, 4)
-- bluebird
c:fillMask(c:ellipse(37, 2, 3, 2), BLUE[3]) c:px(35, 1, BLUE[4]) c:px(36, 1, BLUE[5]) c:px(39, 2, "#e8a63c") c:px(36, 3, "#f1b072") c:px(38, 1, "#2b1c26")
G.save(c, NAME)
