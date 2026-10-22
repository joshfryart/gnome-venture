local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- smooth round coin hung from a clasp bar; inner ring with an embossed "2"
local p = c:build{
  { "rl", c:poly({ {19,9},{30,9},{37,30},{26,30} }), "red" },
  { "rr", c:poly({ {45,9},{34,9},{27,30},{38,30} }), GV.ramp("#3f93b2") },
  { "disc", c:ellipse(32, 41, 15), GV.ramp("#b9b4b9", { shade = "#968f96", gloss = "#fff3c8", dot = "#ffffff", rim = "#dcd8dc" }) },
  { "clasp", c:rrect(26, 23, 38, 27, 1), GV.ramp("#b9b4b9", { shade = "#968f96", rim = "#dcd8dc" }), { flat = true } },
  { "inner", c:ellipse(32, 42, 8), GV.ramp("#968f96", { rim = "#c9c5bc" }), { gloss = false } },
}
c:paint({ ".sss.", "s...s", "....s", "...s.", "..s..", ".s...", "sssss" }, 31, 40, { s = "#5b6470" })
c:paint({
  ".ttt.",
  "t...t",
  "....t",
  "...t.",
  "..t..",
  ".t...",
  "ttttt" }, 30, 39, { t = "#eeeaee" })
local t = c:save(O .. "aseprite/ico/ico-medal-silver.aseprite", O .. "png/ico/ico-medal-silver.png")
print(GV.report(t))
