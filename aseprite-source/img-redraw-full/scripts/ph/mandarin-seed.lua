local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local packet = c:rrect(11, 12, 52, 52, 3)
local flap = c:poly({ {11, 12}, {53, 12}, {53, 21}, {32, 30}, {11, 21} }):clip(packet)
local p = c:build{
  { "packet", packet, "#f1ece0" },
  { "flap",   flap, "#e6dcc4", { contact = true } },
  { "ring",   c:ellipse(32, 39, 8.5), "#f08a24", { gloss = false } },
  { "window", c:ellipse(32, 39, 6.5), "#f4f0e0", { gloss = false, contact = false } },
  { "seed",   c:ellipse(32, 40, 4.5, 5), "#f08a24", { pale = false } },
  { "leaf",   c:ellipse(37.5, 31, 4, 2.5), "#58a03e" },
}
c:line({ {33, 35}, {34, 32} }, 2)
c:fill(c:line({ {33, 35}, {34, 33} }, 2), "#2e5a2c")
c:seam({ {12, 22}, {30, 30} })
c:seam({ {35, 29}, {52, 22} })
c:button(30, 26)
for _, x in ipairs({ 25, 31, 37 }) do c:fill(c:rect(x, 49, x + 1, 50), "#8c4a1a") end
local t = c:save(O .. "aseprite/ph/mandarin-seed.aseprite", O .. "png/ph/mandarin-seed.png")
print(GV.report(t))
