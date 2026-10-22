local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local lid = c:rrect(15, 11, 49, 31, 3)
local p = c:build{
  { "lid",   lid, "stone" },
  { "inner", c:rect(18, 14, 46, 27), "#c9c5bc", { gloss = false } },
  { "hinge", c:rrect(13, 29, 51, 33, 2), "#5b6470", { gloss = false } },
  { "seed",  c:ellipse(32, 30, 7.5, 7), "gold" },
  { "stem",  c:rect(31, 18, 33, 23), "#2e5a2c", { flat = true } },
  { "leaf",  c:ellipse(37.5, 18, 3.5, 2.5):add(c:poly({{34,18},{30,15},{35,16}})), "#58a03e", { gloss = false } },
  { "body",  c:rrect(12, 34, 52, 53, 3), "stone" },
  { "rim",   c:rect(12, 34, 52, 38), "#c9c5bc", { gloss = false } },
  { "latch", c:rrect(28, 40, 36, 46, 1), "gold", { gloss = false } },
}
c:px(30, 42, "#8a4a1c"); c:px(34, 42, "#8a4a1c")
c:seam({ {17, 50}, {47, 50} })
local t = c:save(O .. "aseprite/ph/spider-lily-seed.aseprite", O .. "png/ph/spider-lily-seed.png")
print(GV.report(t))
