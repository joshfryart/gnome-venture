local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- flat paper packet, sharp corners, triangular flap folded down with a seal dot
local body  = c:rrect(15, 12, 48, 54, 1)
local flap  = c:poly({ {15, 12}, {49, 12}, {32, 30} })
local label = c:rrect(20, 31, 43, 50, 4)
local fruit = c:ellipse(31.5, 42, 6.5, 6.5)
local stem  = c:rect(31, 33, 32, 36)
local leaf  = c:poly({ {33, 34}, {36, 32}, {39, 33}, {37, 36}, {34, 36} })
local seal  = c:ellipse(31.5, 29, 2.5, 2.5)

local paper = GV.ramp("#f1ece0")
c:build{
  { "body",  body,  paper },
  { "flap",  flap,  GV.ramp("#dcb06a"), { contour = "#4a2c1a" } },
  { "label", label, GV.ramp("#e8a317"), { flat = true } },
}
c:fill(label:shrink(2), "#f4f0e0")
c:build{
  { "fruit", fruit, GV.ramp("#e8a317", { shade = "#b8661a" }) },
  { "stem",  stem,  "moss", { flat = true } },
  { "leaf",  leaf,  GV.ramp("#58a03e"), { flat = true } },
  { "seal",  seal,  GV.ramp("#a8582f"), { flat = true } },
}
-- three seed dashes
for _, x in ipairs({ 26, 32, 38 }) do c:px(x - 1, 52, "#8c4a1a"); c:px(x, 52, "#8c4a1a") end
c:ground(31.5, 57, 13, 1)
local t = c:save(O .. "aseprite/ph/ixora-seed.aseprite", O .. "png/ph/ixora-seed.png")
print(GV.report(t))
