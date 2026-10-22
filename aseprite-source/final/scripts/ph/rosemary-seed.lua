local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local sage = GV.ramp("#b0bc66")
local sage2 = GV.ramp("#a4b86a")
-- leaf tip poking out of the top
local tip = c:ellipse(31.5, 13, 3, 6)
-- two fanned gathered corners
local corners = c:poly({ {17, 13}, {27, 16}, {33, 27}, {25, 28} })
corners:add(c:poly({ {47, 13}, {37, 16}, {31, 27}, {39, 28} }))
corners:add(c:rrect(25, 20, 38, 28, 2))
-- lumpy bundle body
local body = c:ellipse(31.5, 42, 19, 15)
body:add(c:ellipse(22, 36, 8, 7)); body:add(c:ellipse(41, 36, 8, 7))
local string = c:rect(23, 26, 40, 27)
local p = c:build{
  { "tip", tip, "moss", { gloss = false } },
  { "corners", corners, sage2 },
  { "body", body, sage, { stitch = { side = "lit" } } },
  { "string", string, "#7a4a1f", { flat = true } },
}
-- bow loops
c:paint({ "sss..", "s..s.", "sss..", }, 23, 23, { s = "#7a4a1f" })
c:paint({ "..sss", ".s..s", "..sss", }, 36, 23, { s = "#7a4a1f" })
c:button(30, 25)
-- leaf printed on the front
local leaf = c:poly({ {32, 31}, {38, 37}, {39, 43}, {36, 50}, {32, 54}, {28, 50}, {25, 43}, {26, 37} })
c:part(leaf, "moss", { cres = 2, deep = 1, contact = false, gloss = { 29, 38 } })

for i = 0, 2 do
  c:px(31 - i, 39 + i * 4, "#2e5a2c"); c:px(30 - i, 40 + i * 4, "#2e5a2c")
  c:px(33 + i, 39 + i * 4, "#2e5a2c"); c:px(34 + i, 40 + i * 4, "#2e5a2c")
end
c:fill(c:line({ {32, 35}, {32, 51} }, 1), "#2e5a2c")
c:seam({ {47, 33}, {45, 48} })
local t = c:save(O .. "aseprite/ph/rosemary-seed.aseprite", O .. "png/ph/rosemary-seed.png")
print(GV.report(t))
