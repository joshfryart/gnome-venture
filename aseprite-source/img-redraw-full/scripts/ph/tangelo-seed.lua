local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- squat round-bellied pot
local body = c:ellipse(32, 40, 19, 15):add(c:rrect(16, 26, 48, 52, 8))
local rim = c:rrect(15, 23, 49, 28, 2)
local lid = c:ellipse(32, 23, 15, 8):cut(c:rect(0, 24, 63, 63)):add(c:rrect(17, 19, 47, 23, 2))
local knob = c:ellipse(32, 12.5, 3.5, 3.5)
local fruit = c:ellipse(32, 41, 8, 8)
local leaf = c:ellipse(37.5, 31.5, 3, 2)

local p = c:build{
  { "body", body, "cream" },
  { "fruit", fruit, GV.ramp("#f08a24") },
  { "leaf", leaf, "moss", { flat = true } },
  { "rim", rim, "wood" },
  { "lid", lid, "wood" },
  { "knob", knob, GV.ramp("#4a8a3e") },
}
-- leaf stem
c:px(33, 32, "#2f5a2a"); c:px(33, 33, "#2f5a2a")
c:seam({ {18, 25}, {46, 25} })
c:button(30, 19)
c:ground(32, 56, 16, 1.5)
local t = c:save(O .. "aseprite/ph/tangelo-seed.aseprite", O .. "png/ph/tangelo-seed.png")
print(GV.report(t))
