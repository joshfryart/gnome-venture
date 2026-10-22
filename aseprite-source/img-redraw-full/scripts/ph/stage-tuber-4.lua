local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function leaf(bx, by, tx, ty, w)
  local mx, my = (bx + tx) / 2, (by + ty) / 2
  local dx, dy = tx - bx, ty - by
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / L * w, dx / L * w
  local qx, qy = bx + dx * 0.4, by + dy * 0.4
  return c:poly({ {bx - nx * 0.25, by - ny * 0.25}, {qx + nx, qy + ny}, {tx, ty},
                  {qx - nx, qy - ny}, {bx + nx * 0.25, by + ny * 0.25} })
end

local soil = c:ellipse(31.5, 45, 20, 6.5)
c:part(soil, GV.ramp("#8c4a1a"))
c:fill(c:ellipse(31.5, 43, 15, 3):clip(soil), "#a5663a")
local p = c:build{
  { "l1", leaf(25, 44, 10, 27, 5), GV.ramp("#7ab55c") },
  { "l2", leaf(28, 44, 18, 15, 5), GV.ramp("#58a03e") },
  { "l3", leaf(32, 44, 33, 12, 5), GV.ramp("#7ab55c") },
  { "l4", leaf(36, 44, 46, 21, 5), GV.ramp("#58a03e") },
}
-- leaf midribs
c:fill(c:line({ {24, 42}, {14, 31} }, 1), "#4a8a3e")
c:fill(c:line({ {27, 41}, {20, 21} }, 1), "#2f5a2a")
c:fill(c:line({ {32, 41}, {33, 18} }, 1), "#4a8a3e")
c:fill(c:line({ {36, 41}, {43, 26} }, 1), "#2f5a2a")
c:build{
  { "t1", c:ellipse(23, 47, 6, 4), GV.ramp("#dcb06a") },
  { "t2", c:ellipse(41, 47.5, 6, 4), GV.ramp("#dcb06a") },
}
-- tuber eyes
c:px(21, 47, "#8a4f2a"); c:px(25, 49, "#8a4f2a"); c:px(40, 49, "#8a4f2a"); c:px(44, 47, "#8a4f2a")
local t = c:save(O .. "aseprite/ph/stage-tuber-4.aseprite", O .. "png/ph/stage-tuber-4.png")
print(GV.report(t))
