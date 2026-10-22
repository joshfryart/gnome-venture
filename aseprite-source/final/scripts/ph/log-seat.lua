local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local legs = c:rrect(13, 42, 19, 54, 2):add(c:rrect(45, 42, 51, 54, 2))
local p = c:build{
  { "legs", legs, GV.ramp("#5e2f1e") },
  { "lower", c:rrect(11, 35, 53, 43, 4), GV.ramp("#b07a45") },
  { "top", c:rrect(7, 24, 56, 34, 5), GV.ramp("#c4925f"), { gloss = { 22, 27 } } },
}
-- cut-end rings on the left ends
local function ring(x, y, rx, ry)
  c:fill(c:ellipse(x, y, rx, ry), "#f0d49a")
  c:fill(c:ellipse(x, y, rx - 1, ry - 1):cut(c:ellipse(x, y, rx - 2, ry - 2)), "#d9a660")
  c:px(math.floor(x), math.floor(y), "#8a4f2a")
end
ring(12, 29, 4, 5)
ring(16, 39, 3.5, 4)
-- bark ticks
for _, x in ipairs({ 26, 36, 46 }) do
  c:line({ { x, 27 }, { x, 30 } }, 1) ; end
for _, t in ipairs({ { 26, 27, 30 }, { 36, 28, 31 }, { 46, 27, 30 }, { 22, 37, 40 }, { 32, 38, 41 }, { 42, 37, 40 } }) do
  for y = t[2], t[3] do c:px(t[1], y, "#8a4f2a") end
end
c:seam({ { 20, 34 }, { 50, 34 } })
c:ground(32, 55, 24, 1.5)
local t = c:save(O .. "aseprite/ph/log-seat.aseprite", O .. "png/ph/log-seat.png")
print(GV.report(t))
