local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 100, h = 100, mode = "scene", out = 2 }

-- checked cloth
c:fill(c:rect(0, 0, 99, 99), "#efe6cf")
local chk = c:mask()
for y = 0, 99 do for x = 0, 99 do
  if (math.floor(x / 10) + math.floor(y / 10)) % 2 == 0 then chk:set(x, y) end
end end
c:fill(chk, "#e3d6b6")
-- hem stitches top and bottom
c:seam({ {0, 1}, {99, 1} }, { free = true }); c:seam({ {0, 98}, {99, 98} }, { free = true })

-- board shadow + board
c:fill(c:rrect(6, 8, 97, 97, 8), "#5a3d20")
local board = c:rrect(4, 4, 95, 94, 8)
c:fill(board, "#d6a96b")
c:fill(board:copy():clip(c:rect(0, 52, 99, 99)), "#bd8c52")
c:fill(board:copy():clip(c:rect(0, 86, 99, 99)):cut(board:shrink(2)), "#a97b42")
c:fill(c:rrect(4, 4, 95, 9, 4):clip(board):cut(board:shrink(2):shift(0, 0):clip(c:rect(0, 7, 99, 99))), "#e8c88e")
c:fill(board:edge():clip(c:rect(0, 0, 99, 50)), "#d9a660")
c:outline(board)

-- grain lines
for _, gy in ipairs({ 18, 37, 59, 75, 85 }) do
  local pts = {}
  for x = 12, 88 do pts[#pts + 1] = { x, gy + math.floor(0.5 + 1.2 * math.sin(x / 9 + gy)) } end
  c:fill(c:line(pts, 1), gy < 52 and "#bd8c52" or "#a97b42")
end
-- knots
c:fill(c:ellipse(80, 24, 4, 3), "#a97b42"); c:fill(c:ellipse(80, 24, 2, 1), "#8f6431")
c:fill(c:ellipse(20, 80, 3, 2), "#8f6431"); c:px(19, 80, "#a97b42")

-- leaves at the edges
local function leaf(m, hl)
  c:part(m, GV.ramp("#7fae4c", { rim = "#a3cf6a", gloss = "#a3cf6a" }), { gloss = false })
end
leaf(c:ellipse(4, 77, 8, 3):add(c:ellipse(1, 72, 4, 2)))
leaf(c:ellipse(3, 91, 7, 3))
leaf(c:ellipse(96, 15, 7, 3):add(c:ellipse(99, 21, 3, 2)))
-- leaf veins
c:fill(c:line({ {0, 77}, {9, 77} }, 1), "#4a8a3e")
c:fill(c:line({ {0, 91}, {7, 91} }, 1), "#4a8a3e")
c:fill(c:line({ {92, 15}, {99, 15} }, 1), "#4a8a3e")

-- red berry pair
c:part(c:ellipse(91, 93, 3), "red", { gloss = { 90, 92 } })
c:part(c:ellipse(96, 89, 3), "red", { gloss = { 95, 88 } })
c:fill(c:line({ {93, 87}, {95, 85}, {97, 86} }, 1), "#2f5a2a")

local t = c:save(O .. "aseprite/gather/knife-bg.aseprite", O .. "png/gather/knife-bg.png")
print(GV.report(t))
