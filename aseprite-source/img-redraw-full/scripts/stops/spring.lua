local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 48, h = 48, mode = "icon", margin = 3 }
local pool = c:ellipse(23.5, 28, 17, 13):cut(c:rect(0, 0, 47, 27))
local rim = c:rrect(6, 25, 41, 30, 2)
local w1 = c:line({{15,25},{13,22},{13,19},{16,16},{16,13},{14,11}}, 3)
local w2 = c:line({{24,25},{26,22},{26,18},{23,15},{23,11},{25,9}}, 3)
local w3 = c:line({{33,25},{31,22},{31,19},{34,16},{34,12}}, 3)
c:build{
  { "pool", pool, "water" },
  { "rim", rim, "stone" },
  { "w1", w1, "#c8ecdc", { flat = true } },
  { "w2", w2, "#c8ecdc", { flat = true } },
  { "w3", w3, "#c8ecdc", { flat = true } },
  { "peb", c:ellipse(31, 35, 2.5, 2.5), "#5b6470", { gloss = false } },
}
c:paint({ "ww..ww..ww" }, 14, 34, { w = "#8fcbd8" })
local t = c:save(O .. "aseprite/stops/spring.aseprite", O .. "png/stops/spring.png")
print(GV.report(t))
