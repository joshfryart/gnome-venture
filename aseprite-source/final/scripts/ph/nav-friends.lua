local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local function hat(x0, x1, tx, ty) return c:poly({ {x0,27}, {tx,ty}, {tx+3,ty}, {x1,27} }) end
local p = c:build{
  { "lface", c:ellipse(21.5, 35, 7.5, 7), GV.ramp("#dcb06a") },
  { "lbeard", c:poly({ {16,40}, {28,40}, {23,51}, {21,51} }), GV.ramp("#f1ece0"), { pale = true } },
  { "lhat", hat(13, 31, 19, 11), GV.ramp("#58a03e") },
  { "lbrim", c:rrect(11, 25, 32, 29, 2), GV.ramp("#2e5a2c") },
  { "rface", c:ellipse(42.5, 35, 7.5, 7), GV.ramp("#f1ece0"), { pale = true } },
  { "rbeard", c:poly({ {37,40}, {49,40}, {44,51}, {42,51} }), GV.ramp("#d6c9b6"), { pale = true } },
  { "rhat", hat(34, 52, 42, 9), GV.ramp("#7a5cc0") },
  { "rbrim", c:rrect(33, 25, 53, 29, 2), GV.ramp("#4e3a8a") },
}
c:seam({ {12, 27}, {31, 27} })
c:seam({ {34, 27}, {52, 27} })
c:eye(16, 32); c:eye(23, 32)
c:eye(37, 32); c:eye(44, 32)
local t = c:save(O .. "aseprite/ph/nav-friends.aseprite", O .. "png/ph/nav-friends.png")
print(GV.report(t))
