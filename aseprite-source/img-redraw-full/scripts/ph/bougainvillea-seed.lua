local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:rrect(22, 10, 42, 53, 2)
local flap = c:poly({ {22, 10}, {43, 10}, {32.5, 25} })
local win = c:ellipse(32, 39, 6, 6)
c:build{
  { "body", body, "#f1ece0" },
  { "flap", flap, GV.ramp("#dcb06a"), { gloss = false } },
  { "win", win, "moss" },
}
-- sprout: stem and leaf, over the window top
c:fill(c:rect(32, 30, 33, 35), "#4a8a3e")
c:paint({
  "....ll.",
  "..lllll",
  ".llllg.",
  "lllll..",
  "lll....",
}, 33, 26, { l = "#4a8a3e", g = "#7ab55c" })
c:px(32, 30, "#2f5a2a"); c:px(33, 35, "#2f5a2a")
-- seams along both flap edges
c:seam({ {24, 11}, {31, 22} })
c:seam({ {41, 11}, {34, 22} })
c:button(31, 20)
-- petal label
c:fill(c:rect(30, 47, 33, 50), "#e46a9b")
c:px(30, 47, "#f6b8cf"); c:px(26, 49, "#f6b8cf"); c:px(37, 48, "#f6b8cf")
local t = c:save(O .. "aseprite/ph/bougainvillea-seed.aseprite", O .. "png/ph/bougainvillea-seed.png")
print(GV.report(t))
