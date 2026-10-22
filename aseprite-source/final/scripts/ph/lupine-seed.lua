local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leaf = c:ellipse(37, 9, 4, 2.5)
local p = c:build{
  { "stem", c:rect(31, 9, 32, 14), "#2e5a2c", { flat = true } },
  { "leaf", leaf, "#58a03e", { flat = true } },
  { "seed", c:ellipse(31.5, 22, 10, 9), GV.ramp("petal", { shade = "#a8241f" }) },
  { "crate", c:rect(12, 29, 51, 54), "wood" },
  { "postL", c:rect(12, 29, 16, 54), GV.ramp("#a8582f"), { gloss = false } },
  { "postR", c:rect(47, 29, 51, 54), GV.ramp("#a8582f"), { gloss = false } },
  { "rim", c:rect(10, 26, 53, 31), GV.ramp("#d9a660") },
}
c:fill(c:rect(17, 38, 46, 39), "#8a4f2a")
c:fill(c:rect(17, 46, 46, 47), "#8a4f2a")
for _, q in ipairs({ {14, 34}, {49, 34}, {14, 51}, {49, 51} }) do c:px(q[1], q[2], "#2a1a10") end
c:seam({ {13, 28}, {50, 28} })
c:ground(31.5, 56, 20, 1.5)
local t = c:save(O .. "aseprite/ph/lupine-seed.aseprite", O .. "png/ph/lupine-seed.png")
print(GV.report(t))
