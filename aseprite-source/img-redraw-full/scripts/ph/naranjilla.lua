local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local ember = GV.ramp("#f08a24", { shade = "#e0501f" })
local leaf = GV.ramp("#6a9a3a", { shade = "#4a8a3e" })

local fruit = c:ellipse(31.5, 37, 17, 16)

-- four-point sepal star: two lying left/right, two angled up
local cal = c:poly({ {32, 18}, {17, 22}, {30, 25} })
cal:add(c:poly({ {32, 18}, {47, 22}, {33, 25} }))
cal:add(c:poly({ {30, 20}, {22, 13}, {33, 22} }))
cal:add(c:poly({ {33, 20}, {42, 13}, {31, 22} }))
cal:add(c:ellipse(31.5, 21, 4, 3))

local stem = c:rrect(30, 11, 33, 17, 1)

local p = c:build{
  { "fruit", fruit, ember, { gloss = { 23, 28 } } },
  { "calyx", cal, leaf, { cres = 2, deep = 1, gloss = false } },
  { "stem", stem, GV.ramp("#2f5a2a"), { flat = true } },
}
-- sepal tips darker
c:px(18, 22, "#4a8a3e"); c:px(45, 22, "#4a8a3e")
c:px(23, 14, "#4a8a3e"); c:px(41, 14, "#4a8a3e")
-- fuzz along the left rim
for _, q in ipairs({ {17, 33}, {16, 38}, {17, 43}, {20, 47}, {19, 28} }) do
  c:px(q[1], q[2], "#f6b36a")
end

c:ground(31.5, 54, 13, 1.5)
local t = c:save(O .. "aseprite/ph/naranjilla.aseprite", O .. "png/ph/naranjilla.png")
print(GV.report(t))
