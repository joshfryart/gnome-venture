local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(R .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- packet body: flat upright rectangle, slight clockwise lean via poly
local body = c:poly({ {15,9}, {51,11}, {50,57}, {13,55} })
local flap = c:poly({ {15,9}, {51,11}, {33,30} })
local win = c:ellipse(32, 42, 9, 9)
local seed = c:ellipse(32, 42, 5.5, 5.5)
local leaf = c:poly({ {36,38}, {39,33}, {43,32}, {41,36}, {37,39} })
local p = c:build{
  { "body", body, GV.ramp("#f1ece0") },
  { "flap", flap, GV.ramp("#dcb06a") },
  { "win",  win,  GV.ramp("#7a5cc0"), { gloss = false } },
}
-- window: violet rim ring then pale paper inside
c:fill(c:ellipse(32, 42, 7, 7), "#f4f0e0")
c:part(seed, GV.ramp("#7a5cc0", { shade = "#4e3a8a" }), { gloss = { 29, 39 } })
c:part(leaf, GV.ramp("#58a03e"), { flat = true })
c:px(37, 38, "#2f5a2a")
-- hem stitch along the flap V and packet bottom
c:seam({ {18,12}, {33,27}, {48,13} })
c:seam({ {16,52}, {48,54} })
local t = c:save(R .. "img-redraw-full/aseprite/ph/lapacho-seed.aseprite", R .. "img-redraw-full/png/ph/lapacho-seed.png")
print(GV.report(t))
