local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- pod: curved lens rising to the upper right
local pod = c:poly({ {9,41},{14,36},{22,31},{32,26},{42,21},{50,17},{56,16},{55,21},{50,28},{42,35},{32,41},{22,45},{14,45} })
local back = c:poly({ {12,38},{20,32},{30,27},{40,22},{50,17},{55,16},{52,22},{44,28},{34,33},{24,37},{16,40} })
local p = c:build{
  { "pod", pod, "moss", { gloss = false } },
  { "tail", c:line({ {11,41},{6,46} }, 3), GV.ramp("#2e5a2c"), { flat = true } },
  { "lip", back, GV.ramp("#58a03e"), { gloss = false, contact = false } },
  { "pea1", c:ellipse(24, 33, 4.5), GV.ramp("#a4b86a"), { gloss = { 22, 31 } } },
  { "pea2", c:ellipse(33.5, 28.5, 4.5), GV.ramp("#a4b86a"), { gloss = { 31, 26 } } },
  { "pea3", c:ellipse(43, 24, 4.5), GV.ramp("#a4b86a"), { gloss = { 41, 22 } } },
}
c:ground(32, 47, 18, 1.5)
local t = c:save(O .. "aseprite/ph/pea.aseprite", O .. "png/ph/pea.png")
print(GV.report(t))
