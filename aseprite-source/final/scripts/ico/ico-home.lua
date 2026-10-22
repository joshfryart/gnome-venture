local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local p = c:build{
  { "chimney", c:rect(42, 12, 49, 26), GV.ramp("#968f96") },
  { "walls", c:rect(13, 29, 51, 55), "cream" },
  { "roof", c:poly({ {32, 8}, {58, 34}, {6, 34} }), GV.ramp("#d6322b") },
  { "door", c:rrect(26, 38, 37, 55, 3), GV.ramp("#a5663a") },
  { "window", c:rect(16, 38, 22, 44), "water", { gloss = false } },
}
-- window cross
c:fill(c:rect(19, 38, 19, 44), "#74462a")
c:fill(c:rect(16, 41, 22, 41), "#74462a")
c:px(17, 39, "#c8ecdc")
-- chimney cap
c:fill(c:rect(42, 12, 49, 12), "#c9c5bc")
-- door knob
c:fill(c:rect(34, 46, 35, 47), "#e8a317")
c:px(34, 46, "#fff1c8")
-- eaves seam
c:seam({ {9, 32}, {55, 32} })
local t = c:save(R .. "aseprite/ico/ico-home.aseprite", R .. "png/ico/ico-home.png")
print(GV.report(t))
