local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- jar: rounded body with tapered shoulders into a neck
local body = c:rrect(15, 26, 48, 54, 9)
body:add(c:poly({ {20, 30}, {24, 22}, {40, 22}, {44, 30} }))
local neck = c:rect(23, 17, 40, 25)
local p = c:build{
  { "jar",  body, "#c8ecdc" },
  { "neck", neck, "#c8ecdc", { gloss = false } },
  { "cork", c:rrect(21, 8, 42, 18, 3), "#d9a660", { cres = 3 } },
  { "seed", c:ellipse(31.5, 42, 10, 10), "#f08a24" },
}
-- sprout from the seed top
c:fill(c:line({ {31, 32}, {31, 29} }, 2), "#58a03e")
c:fill(c:ellipse(34, 29, 2, 1), "#58a03e")
c:px(34, 28, "#8fd06a")
-- cork grain
c:px(27, 12, "#a8582f"); c:px(36, 14, "#a8582f"); c:px(31, 11, "#a8582f")
-- glass highlight and base line
c:fill(c:rect(18, 32, 18, 46), "#e8f6ee")
c:fill(c:rect(20, 51, 43, 51), "#8fcbd8")
c:seam({ {22, 18}, {41, 18} })
c:ground(31.5, 57, 15, 1.5)
local t = c:save(O .. "aseprite/ph/giant-allium-seed.aseprite", O .. "png/ph/giant-allium-seed.png")
print(GV.report(t))
