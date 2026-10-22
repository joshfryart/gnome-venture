local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local thumb = c:line({ {21, 46}, {12, 34} }, 8)
thumb:add(c:ellipse(12, 33, 4, 4))
local palm  = c:rrect(18, 32, 51, 56, 9)
local pinky = c:rrect(18, 19, 24, 40, 3)
local ring  = c:rrect(26, 12, 32, 40, 3)
local mid   = c:rrect(34, 11, 40, 40, 3)
local index = c:rrect(42, 17, 48, 40, 3)

local p = c:build{
  { "thumb", thumb, "skin" },
  { "palm",  palm,  "skin" },
  { "pinky", pinky, "skin", { light = palm:copy():add(pinky) } },
  { "ring",  ring,  "skin" },
  { "mid",   mid,   "skin" },
  { "index", index, "skin" },
}
-- knuckle creases
for _, x in ipairs({ 20, 28, 36, 44 }) do
  c:paint({ "ccc" }, x, 37, { c = "#c47a52" })
end
-- palm line
c:paint({ "c....", ".ccc.", "....cc" }, 26, 46, { c = "#c47a52" })
local t = c:save(O .. "aseprite/ico/ico-hand-stop.aseprite", O .. "png/ico/ico-hand-stop.png")
print(GV.report(t))
