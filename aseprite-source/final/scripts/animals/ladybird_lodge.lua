-- animals/ladybird_lodge : wooden bug hotel with red roof and two ladybirds
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- six cubbies: 2 columns x 3 rows, mixed round and square holes
local holes = c:mask()
holes:add(c:ellipse(22.5, 31.5, 4.5, 3.5))   -- round, ladybird
holes:add(c:rrect(35, 29, 46, 34, 1))
holes:add(c:rrect(18, 37, 27, 42, 1))
holes:add(c:ellipse(40.5, 39.5, 5.5, 3.5))   -- round, ladybird
holes:add(c:rrect(17, 44, 28, 49, 1))
holes:add(c:ellipse(40.5, 46.5, 4.5, 3))

c:build{
  { "legs",  c:rect(15, 50, 18, 53):add(c:rect(45, 50, 48, 53)), GV.ramp("#5e2f1e"), { flat = true } },
  { "body",  c:rect(13, 26, 50, 51), "wood" },
  { "holes", holes, GV.ramp("#3d2a1c"), { flat = true, rim = false } },
  { "bug1",  c:ellipse(22.5, 32.5, 3, 2.5), "red", { gloss = { 21, 32 } } },
  { "bug2",  c:ellipse(40.5, 40.5, 3.5, 2.5), "red", { gloss = { 39, 39 } } },
  { "roof",  c:poly({ {32, 10}, {32, 10}, {55, 27}, {9, 27} }), "red" },
  { "eave",  c:rect(10, 25, 53, 27), GV.ramp("#8a4f2a"), { gloss = false } },
}
-- frame grid between cubbies (thin dividers)
c:fill(c:rect(31, 28, 31, 49), "#5e2f1e")
c:fill(c:rect(15, 35, 48, 35), "#8a4f2a")
c:fill(c:rect(15, 43, 48, 43), "#8a4f2a")
-- ladybird heads and wing split
c:paint({ "hhh" }, 21, 30, { h = "#35161f" })
c:px(22, 34, "#35161f")
c:paint({ "hhh" }, 39, 38, { h = "#35161f" })
c:px(40, 42, "#35161f")
-- eave seam
c:seam({ {12, 26}, {51, 26} })

local t = c:save(O .. "aseprite/animals/ladybird_lodge.aseprite", O .. "png/animals/ladybird_lodge.png")
print(GV.report(t))
