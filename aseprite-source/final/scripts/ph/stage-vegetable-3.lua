local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function blade(bx, by, tx, ty, w)
  local dx, dy = tx - bx, ty - by
  local len = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / len * w, dx / len * w
  local mx, my = bx + dx * 0.55, by + dy * 0.55
  return c:poly({ { bx - nx * 0.4, by - ny * 0.4 }, { mx - nx, my - ny }, { tx, ty }, { mx + nx, my + ny }, { bx + nx * 0.4, by + ny * 0.4 } })
end

local soil = c:ellipse(32, 48, 21, 7)
local leafA = GV.ramp("#7ab55c")
local leafB = GV.ramp("#58a03e")
c:build{
  { "soil", soil, GV.ramp("#8c4a1a") },
  { "l1", blade(31, 46, 12, 32, 5), leafA },
  { "l4", blade(33, 46, 52, 32, 5), leafB },
  { "l2", blade(30, 46, 19, 24, 5), leafB },
  { "l3", blade(34, 46, 45, 24, 5), leafA },
  { "head", c:ellipse(32, 29, 9.5, 9), leafB },
}
-- lighter soil top
c:fill(c:ellipse(32, 46, 15, 2):cut(c:ellipse(32, 42, 10, 5)), "#a5663a")
c:px(18, 48, "#5e2f1e"); c:px(46, 49, "#5e2f1e"); c:px(26, 52, "#5e2f1e")
local t = c:save(O .. "aseprite/ph/stage-vegetable-3.aseprite", O .. "png/ph/stage-vegetable-3.png")
print(GV.report(t))
