local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local ears = c:poly({ {18, 10}, {28, 14}, {31, 21}, {24, 22} })
ears:add(c:poly({ {46, 10}, {36, 14}, {33, 21}, {40, 22} }))
local neck = c:poly({ {26, 15}, {38, 15}, {41, 27}, {23, 27} })
local body = c:ellipse(32, 39, 19, 14):cut(c:rect(0, 52, 63, 63))
c:build{
  { "ears", ears, "#9a6b3f" },
  { "neck", neck, "#c9a96e", { gloss = false } },
  { "body", body, "#c9a96e", { stitch = true } },
  { "seed", c:ellipse(32, 42, 8, 6.5), "#e8a317" },
}
-- twine wrap, knot, tails
c:fill(c:rect(24, 22, 40, 23), "#7a4a1f")
c:fill(c:line({ {31, 24}, {28, 29} }, 2), "#7a4a1f")
c:fill(c:line({ {33, 24}, {36, 29} }, 2), "#7a4a1f")
c:paint({ ".kk.", "kkkk", "kkkk", ".kk." }, 30, 21, { k = "#9a6b3f" })
c:px(31, 22, "#c9a96e")
-- sprout above the seed badge
c:fill(c:rect(31, 32, 32, 36), "#4a8a3e")
c:fill(c:ascii({ ".xx.", "xxxx", ".xx." }, 33, 31), "#7ab55c")
-- burlap weave flecks
c:px(20, 40, "#7a4a1f"); c:px(44, 36, "#7a4a1f"); c:px(41, 48, "#7a4a1f")
local t = c:save(O .. "aseprite/ph/hollyhock-seed.aseprite", O .. "png/ph/hollyhock-seed.png")
print(GV.report(t))
