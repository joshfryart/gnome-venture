local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(31.5, 41, 20, 12)
body:add(c:rrect(26, 26, 37, 32, 2))
c:build{
  { "fruit", c:ellipse(31.5, 18, 7.5, 6.5), "moss" },
  { "stem",  c:rect(31, 10, 32, 12), "#2e5a2c", { flat = true } },
  { "leaf",  c:ellipse(36.5, 11.5, 3.5, 1.5), "#58a03e", { flat = true } },
  { "sack",  body, "#c9a96e" },
  { "flapL", c:poly({ {16,25},{22,22},{28,25},{31,30},{24,30} }), "#c9a96e", { gloss = false } },
  { "flapR", c:poly({ {48,25},{42,22},{36,25},{33,30},{40,30} }), "#c9a96e", { gloss = false } },
  { "twine", c:rrect(25, 27, 38, 29, 1), "#8a4f2a", { gloss = false } },
  { "patch", c:rect(18, 38, 27, 46), "#9a6b3f", { gloss = false } },
}
c:fill(c:line({ {37, 30}, {40, 34}, {42, 37} }, 2), "#8a4f2a")
c:fill(c:line({ {34, 30}, {35, 34}, {37, 38} }, 2), "#8a4f2a")
c:seam({ {19, 39}, {26, 39}, {26, 45}, {19, 45}, {19, 39} })
c:seam({ {46, 35}, {47, 41}, {46, 48} })
for _, p in ipairs({ {32, 44}, {37, 48}, {41, 41}, {29, 50}, {22, 34} }) do c:px(p[1], p[2], "#9a6b3f") end
local t = c:save(O .. "aseprite/ph/lucuma-seed.aseprite", O .. "png/ph/lucuma-seed.png")
print(GV.report(t))
