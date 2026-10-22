local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local p = c:build{
  { "seed",  c:ellipse(30, 23, 6.5, 6.5), "#dcb06a" },
  { "stem",  c:rect(29, 13, 31, 17), "#2e5a2c", { flat = true } },
  { "leaf",  c:ellipse(35.5, 13.5, 3.5, 2.5), "#58a03e", { gloss = false } },
  { "env",   c:poly({{20,29},{30,25},{45,32},{45,56},{20,56}}), "#f1ece0", { pale = true } },
  { "panel", c:rrect(20, 36, 44, 55, 2), "#f4f0e0", { pale = true, gloss = false } },
  { "stamp", c:rect(37, 39, 42, 44), "petal", { gloss = false } },
}
c:fill(c:line({{21,30},{30,27},{44,34}}, 2), "#c9a96e")
c:fill(c:rect(25, 48, 34, 49), "#dcb06a")
c:fill(c:rect(25, 52, 32, 53), "#dcb06a")
c:button(30, 37)
c:seam({ {23, 42}, {23, 53} }, { free = true })
local t = c:save(O .. "aseprite/ph/spring-adonis-seed.aseprite", O .. "png/ph/spring-adonis-seed.png")
print(GV.report(t))
