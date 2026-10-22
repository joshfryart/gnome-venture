local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local wood = GV.ramp("#a8582f")
local moss = GV.ramp("#b0bc66")
local roof = c:poly({ {7, 32}, {32, 7}, {58, 32} })
c:build{
  { "box",  c:rrect(18, 26, 46, 55, 3), wood },
  { "roof", roof, moss },
  { "door", c:ellipse(32, 41, 6.5, 6.5), "#44281c", { gloss = false, rim = false, bounce = false } },
  { "peg",  c:rect(28, 50, 36, 52), "#d9a660", { flat = true } },
}
-- ridge band along both slopes (2 px, darker moss)
c:fill(c:line({ {9, 30}, {32, 8}, {55, 30} }, 2):clip(roof), "#4a8a3e")
c:fill(c:line({ {11, 30}, {32, 10}, {53, 30} }, 1):clip(roof), "#7a9a4a")
-- plank lines
for _, x in ipairs({ 24, 40 }) do
  c:fill(c:rect(x, 34, x, 53):cut(c:ellipse(32, 41, 7.5, 7.5)), "#8a4f2a")
end
-- butterfly in the door
c:paint({ "gg.gg", "gGuGg", ".g.g." }, 30, 39, { g = "#f5cf6a", G = "#e8a317", u = "umber" })
-- eave seam and button
c:seam({ {12, 30}, {32, 12}, {52, 30} })
c:button(30, 15)
local t = c:save(O .. "aseprite/ph/butterfly-house.aseprite", O .. "png/ph/butterfly-house.png")
print(GV.report(t))
