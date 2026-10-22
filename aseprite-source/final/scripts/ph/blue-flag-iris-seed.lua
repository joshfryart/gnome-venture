local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cream = GV.ramp("#f1ece0")
local tan = GV.ramp("#dcb06a")
local potm = c:rrect(16, 20, 47, 55, 7)
local p = c:build{
  { "pot", potm, cream },
  { "knob", c:rrect(28, 7, 35, 12, 2), tan },
  { "lid", c:rrect(13, 11, 50, 21, 4), cream },
  { "window", c:rrect(21, 27, 42, 50, 5), GV.ramp("#f4f0e0"), { flat = true } },
  { "seed", c:ellipse(31.5, 40, 7, 7), GV.ramp("#e8a317", { shade = "#b07a10" }) },
}
c:fill(c:rrect(21, 27, 42, 50, 5):edge(), "#e8a317")
c:fill(c:rect(14, 20, 49, 21), "#dcb06a")
c:fill(c:rect(31, 28, 32, 33), "#2e5a2c")
c:paint({ "..ll.", ".llll", "llll.", ".ll.." }, 33, 27, { l = "#58a03e" })
c:paint({ "..ll", ".lll", "lll.", ".l.." }, 27, 28, { l = "#4a8a3e" })
c:seam({ {15,19}, {48,19} })
c:button(30, 13)
for _, x in ipairs({ 24, 30, 36 }) do c:paint({ ".d.", "ddd", ".d." }, x, 52, { d = "#8c4a1a" }) end
local t = c:save(O .. "aseprite/ph/blue-flag-iris-seed.aseprite", O .. "png/ph/blue-flag-iris-seed.png")
print(GV.report(t))
