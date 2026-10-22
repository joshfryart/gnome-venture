local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(32,37,16,15.5)
local belly = body:copy():clip(c:ellipse(32,57,22,14))
local leaf = c:poly({{34,19},{36,13},{41,9},{48,6},{46,12},{41,17}})
c:build{
  { "body", body, GV.ramp("#f0c040") },
  { "belly", belly, "gold", { rim = false, gloss = false, contour = false, contact = false } },
  { "stem", c:rrect(30,15,33,23,1), GV.ramp("#2f5a2a"), { flat = true } },
  { "leaf", leaf, GV.ramp("#58a03e"), { gloss = false } },
}
for _, p in ipairs({ {27,37},{40,31},{35,46},{23,44},{43,40} }) do c:px(p[1], p[2], "#d0862a") end
local t = c:save(O.."aseprite/ph/yuzu.aseprite", O.."png/ph/yuzu.png")
print(GV.report(t))
