local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local frill = c:ellipse(25, 16, 6, 6):add(c:ellipse(39, 16, 6, 6)):add(c:ellipse(32, 14, 5, 5)):add(c:rect(21, 17, 43, 24))
local body = c:ellipse(32, 43, 18, 12):add(c:poly({ {22, 25}, {43, 25}, {51, 43}, {14, 43} }))
local pill = c:ellipse(26.7, 46.7, 4.5):add(c:ellipse(37.3, 39.3, 4.5))
pill:add(c:poly({ {29, 50}, {40, 43}, {35, 35}, {24, 43} }))
local cap = pill:copy():clip(c:poly({ {28.7, 28.8}, {44.3, 51}, {52.5, 45.3}, {36.9, 23.1} }))
local p = c:build{
  { "frill", frill, "#c9a96e" },
  { "body",  body, "#c9a96e", { stitch = { side = "lit" } } },
  { "band",  c:rect(21, 22, 43, 26), "#7a4a1f", { flat = true } },
  { "tails", c:line({ {30, 27}, {28, 31} }, 2):add(c:line({ {35, 27}, {37, 30} }, 2)), "#7a4a1f", { flat = true } },
  { "knot",  c:ellipse(32, 24, 3), "#7a4a1f" },
  { "pill",  pill, "#e46a9b" },
  { "cap",   cap, "#2e5a2c", { gloss = false } },
}
c:seam({ {45, 31}, {45, 50} })
local t = c:save(O .. "aseprite/ph/rhubarb-seed.aseprite", O .. "png/ph/rhubarb-seed.png")
print(GV.report(t))
