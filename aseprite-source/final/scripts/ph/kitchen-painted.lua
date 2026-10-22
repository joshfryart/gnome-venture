local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local p = c:build{
  { "smoke", c:ellipse(44, 10, 3.5, 3):add(c:ellipse(48, 8, 2.5, 2)), GV.ramp("#d6c9b6"), { gloss = false } },
  { "chimney", c:rect(40, 16, 47, 30), "stone", { gloss = false } },
  { "cap", c:rrect(38, 13, 49, 17, 1), GV.ramp("#6a6070"), { flat = true } },
  { "wall", c:rect(11, 34, 53, 56), GV.ramp("#f6b8cf"), { gloss = { 14, 40 } } },
  { "roof", c:poly({ {7,37},{32,18},{58,37} }), "water", { gloss = { 24, 28 } } },
  { "eave", c:rrect(8, 35, 56, 38, 1), GV.ramp("#c66b50"), { gloss = false } },
  { "door", c:rect(17, 45, 25, 56):add(c:ellipse(21, 45, 4, 4)), "wood", { gloss = false, contact = false } },
  { "window", c:rrect(34, 42, 45, 50, 2), "gold", { gloss = { 36, 44 } } },
}
-- dark arch inside the door frame
c:fill(c:rect(19, 46, 23, 56):add(c:ellipse(21, 46, 2, 2)), "#5e2f1e")
c:paint({ "kk", "kk" }, 22, 50, { k = "#e8a317" })
-- window cross
c:fill(c:rect(39, 42, 40, 50), "#2a1a10")
c:fill(c:rect(34, 45, 45, 46), "#2a1a10")

c:seam({ {10, 36}, {55, 36} })
c:ground(32, 57, 25, 2)
local t = c:save(O .. "aseprite/ph/kitchen-painted.aseprite", O .. "png/ph/kitchen-painted.png")
print(GV.report(t))
