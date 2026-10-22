local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dome = c:ellipse(32, 38, 22, 17):clip(c:rect(0, 0, 63, 42))
dome:add(c:rrect(10, 34, 54, 50, 6))
c:build{
  { "loaf", dome, GV.ramp("#dcb06a", { gloss = "#fff1c8" }), { cres = 4, gloss = { 18, 28 } } },
}
local function ridge(pts)
  c:fill(c:line(pts, 3), "#c4925f"); c:fill(c:line(pts, 1), "#a8582f")
  local hi = {}
  for i, p in ipairs(pts) do hi[i] = { p[1], p[2] - 1 } end
  c:fill(c:line(hi, 1), "#f0d49a")
end
ridge({ {17, 37}, {21, 34}, {28, 32} })
ridge({ {31, 28}, {36, 26}, {43, 27} })
ridge({ {40, 40}, {44, 37}, {48, 37} })
for _, q in ipairs({ {24, 42}, {35, 35}, {30, 45}, {45, 31} }) do c:px(q[1], q[2], "#a8582f") end
c:ground(32, 52, 22, 1.5)
local t = c:save(O .. "aseprite/ph/cornbread.aseprite", O .. "png/ph/cornbread.png")
print(GV.report(t))
