local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pod = c:poly({ {11,40}, {13,32}, {18,25}, {26,20}, {36,16}, {46,14}, {54,14}, {58,17},
                     {56,24}, {50,32}, {42,39}, {32,45}, {22,47}, {15,45} })
pod:add(c:ellipse(21, 27, 6, 5)):add(c:ellipse(32, 21, 6, 5)):add(c:ellipse(43, 17, 6, 4.5))
c:build{
  { "stem", c:line({ {12,41}, {6,47} }, 3), "#2f5a2a", { flat = true } },
  { "pod", pod, "moss" },
  { "ridge", c:line({ {16,40}, {22,33}, {30,29}, {40,26}, {51,23} }, 2), "#58a03e", { flat = true, contour = false, contact = false } },
  { "k1", c:ellipse(24, 35, 4, 3.5), "#4a8a3e", { gloss = false } },
  { "k2", c:ellipse(34, 31, 4, 3.5), "#4a8a3e", { gloss = false } },
  { "k3", c:ellipse(44, 28, 4, 3.5), "#4a8a3e", { gloss = false } },
}
c:ground(32, 51, 17, 3, "#6a4528")
local t = c:save(O .. "aseprite/ph/ackee.aseprite", O .. "png/ph/ackee.png")
print(GV.report(t))
