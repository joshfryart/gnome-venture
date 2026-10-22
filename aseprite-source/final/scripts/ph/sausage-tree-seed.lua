local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local cream = GV.ramp("#f1ece0")
local glazeG = GV.ramp("#b0bc66")
local leafR = GV.ramp("#58a03e")

-- fat round-bellied pot, short neck under the lid
local body = c:ellipse(31.5, 40, 18, 14)
body:add(c:rrect(22, 25, 41, 32, 2))
local band = c:rect(12, 49, 52, 50):clip(c:ellipse(31.5, 40, 18, 14):shrink(1))
local lid = c:rrect(17, 19, 46, 27, 3)
local knob = c:ellipse(31.5, 15, 4, 3.5)
local ring = c:ellipse(31.5, 39, 9, 8):cut(c:ellipse(31.5, 39, 7, 6))
local win = c:ellipse(31.5, 39, 7, 6)
local seed = c:ellipse(31.5, 41, 5, 4.5)

c:build{
  { "body", body, cream },
  { "band", band, glazeG, { flat = true } },
  { "knob", knob, "wood" },
  { "lid", lid, GV.ramp("#d9a660") },
  { "win", win, GV.ramp("#f4f0e0"), { flat = true, gloss = false } },
  { "ring", ring, glazeG, { flat = true } },
  { "seed", seed, GV.ramp("#b0bc66", { shade = "#58a03e" }) },
}
-- stem and leaf
c:fill(c:rect(31, 34, 32, 36), "#2e5a2c")
c:paint({ ".ll.", "llll", ".ll." }, 33, 33, { l = "#58a03e" })
c:px(34, 33, leafR.rim)

c:seam({ { 19, 26 }, { 44, 26 } })
c:button(30, 20)

local t = c:save(O .. "aseprite/ph/sausage-tree-seed.aseprite", O .. "png/ph/sausage-tree-seed.png")
print(GV.report(t))
