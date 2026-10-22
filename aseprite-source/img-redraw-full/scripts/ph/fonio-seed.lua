local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local p = c:build{
  { "env", c:rect(22, 12, 42, 52), GV.ramp("#f1ece0") },
  { "flap", c:poly({ {22, 12}, {43, 12}, {32.5, 30} }), GV.ramp("#d0a058"), { gloss = false } },
}
c:seam({ {23, 13}, {32, 28}, {41, 13} })
c:fill(c:ellipse(32.5, 29, 2.5), "#d6322b")
c:px(31, 28, "#f08a24")
c:fill(c:line({ {32, 49}, {32, 37} }, 2), "#2e5a2c")
local o1, o2 = "#f08a24", "#e0501f"
c:fill(c:ellipse(29, 37, 1.5, 2), o1); c:fill(c:ellipse(35, 39, 1.5, 2), o2)
c:fill(c:ellipse(29, 40, 1.5, 2.5), o2); c:fill(c:ellipse(35, 42, 1.5, 2.5), o1)
c:fill(c:ellipse(29, 45, 1.5, 2.5), o1)
c:fill(c:ellipse(32.5, 34.5, 1, 2), o1)
c:fill(c:ellipse(36, 48, 3, 1.5), "#58a03e")
c:ground(32, 54, 12, 1.5)
local t = c:save(O .. "aseprite/ph/fonio-seed.aseprite", O .. "png/ph/fonio-seed.png")
print(GV.report(t))
