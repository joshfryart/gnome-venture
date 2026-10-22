local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:rrect(14, 14, 50, 56, 3)
local flap = c:poly({ {14, 13}, {51, 13}, {32, 33} })
local win = c:rrect(20, 35, 44, 53, 5)
local winIn = c:rrect(22, 37, 42, 51, 4)
local nut = c:ellipse(32, 44.5, 7, 6.5)
local p = c:build{
  { "body", body, "#f1ece0", { pale = true } },
  { "window", win, "#8c4a1a", { flat = true } },
  { "glass", winIn, "#f4f0e0", { pale = true, gloss = false, contact = false } },
  { "nut", nut, "#8c4a1a", { gloss = { 28, 41 } } },
  { "flap", flap, "#dcb06a" },
  { "dot", c:ellipse(32, 25, 3, 3), "#8c4a1a", { flat = true } },
}
-- pecan ridge lines
c:paint({ "d.....d", ".d...d.", "..ddd.." }, 29, 46, { d = "#44281c" })
c:paint({ "..d..", ".d.d.", "d...d" }, 30, 39, { d = "#44281c" })
-- stem poking out
c:fill(c:rect(31, 34, 32, 37), "#2e5a2c")
c:px(33, 35, "#58a03e"); c:px(34, 35, "#58a03e"); c:px(34, 34, "#58a03e")
-- seam along flap edges
c:seam({ {16, 15}, {32, 31}, {48, 15} })
-- bottom dots
for _, x in ipairs({ 26, 32, 38 }) do c:fill(c:rect(x - 1, 54, x, 55), "#8c4a1a") end
local t = c:save(O .. "aseprite/ph/pecan-seed.aseprite", O .. "png/ph/pecan-seed.png")
print(GV.report(t))
