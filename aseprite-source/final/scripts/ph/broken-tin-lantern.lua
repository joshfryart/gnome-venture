local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tin = GV.ramp("#8b8f96")
local ring = c:ellipse(32, 10, 5.5, 5.5):cut(c:ellipse(32, 10, 2.5, 2.5)):cut(c:rect(0, 14, 63, 63))
ring:add(c:rect(27, 10, 29, 14)); ring:add(c:rect(35, 10, 37, 14))
local glass = c:rrect(22, 19, 42, 48, 4)
local flame = c:ellipse(32, 36, 5, 5)
flame:add(c:poly({ {28, 34}, {32, 26}, {37, 34} }))
local base = c:rrect(18, 47, 46, 54, 3):cut(c:poly({ {39, 55}, {47, 47}, {47, 55} }))
local tab = c:poly({ {46, 53}, {52, 50}, {54, 55}, {48, 58} })
local chip = c:poly({ {9, 45}, {13, 43}, {14, 47}, {10, 48} })
local p = c:build{
  { "ring", ring, tin, { flat = true } },
  { "glass", glass, GV.ramp("#f5cf6a", { shade = "#e8a317" }) },
  { "postL", c:rect(22, 20, 24, 47), tin, { flat = true } },
  { "postR", c:rect(40, 20, 42, 47), tin, { flat = true } },
  { "flame", flame, GV.ramp("#e8a317", { gloss = "#fff1c8" }) },
  { "cap", c:rrect(18, 13, 46, 20, 3), tin },
  { "base", base, tin },
  { "tab", tab, tin, { flat = true } },
  { "chip", chip, tin, { flat = true } },
}
local crack = c:line({ {30, 21}, {35, 27}, {29, 32}, {36, 40}, {32, 46} }, 2):clip(c:rect(25, 21, 39, 46))
c:fill(crack, "#2a1a10")
c:px(26, 23, "#fff1c8"); c:px(26, 24, "#fff1c8"); c:px(27, 22, "#fff1c8")
local t = c:save(O .. "aseprite/ph/broken-tin-lantern.aseprite", O .. "png/ph/broken-tin-lantern.png")
print(GV.report(t))
