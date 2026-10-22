local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- slumped sack body, flat bottom
local body = c:ellipse(32, 43, 19, 14):cut(c:rect(0, 56, 63, 63))
body:add(c:rrect(15, 46, 49, 55, 4))
-- crumpled top: neck flaring into two ears
local top = c:poly({ {26, 33}, {39, 33}, {37, 26}, {40, 20}, {41, 12}, {36, 16}, {32, 21}, {28, 16}, {21, 11}, {22, 19}, {27, 26} })
local twine = c:rect(25, 26, 39, 28)

local p = c:build{
  { "top", top, "#c9a96e" },
  { "body", body, "#c9a96e", { stitch = { side = "lit" } } },
  { "twine", twine, "#7a4a1f", { flat = true } },
  { "string", c:line({ {38, 25}, {43, 19} }, 2), "#7a4a1f", { flat = true } },
  { "pennant", c:poly({ {41, 20}, {53, 20}, {48, 8} }), "#2e5a2c", { flat = true } },
}
-- inner fold between ears
c:paint({ "f...f", ".f.f.", "..f.." }, 30, 20, { f = "#9a6b3f" })
-- twine knot and loose ends
c:fill(c:rect(31, 26, 33, 29), "#5e2f1e")
c:fill(c:line({ {31, 29}, {27, 33} }, 1), "#7a4a1f")
c:fill(c:line({ {33, 29}, {37, 34} }, 1), "#7a4a1f")
-- stencilled jujube fruit
c:fill(c:ellipse(32, 45, 7, 6), "#7ab55c")
c:fill(c:ellipse(33, 46, 6, 5):cut(c:ellipse(31, 44, 6, 5)), "#58a03e")
c:px(29, 42, "#c8d77a"); c:px(30, 41, "#c8d77a")
-- sprout
c:fill(c:rect(32, 36, 33, 39), "#4a8a3e")
c:fill(c:ellipse(36, 36, 2.5, 1.5), "#58a03e")
-- pennant tag on a string
c:px(47, 13, "#4a8a3e"); c:px(47, 14, "#4a8a3e")
-- weave ticks
c:paint({ "w.w" }, 20, 50, { w = "#9a6b3f" })
c:paint({ "w.w" }, 42, 51, { w = "#9a6b3f" })
c:paint({ "w" }, 24, 53, { w = "#9a6b3f" })
c:paint({ "w" }, 38, 54, { w = "#9a6b3f" })
c:ground(32, 57, 15, 1.5)
local t = c:save(O .. "aseprite/ph/jujube-seed.aseprite", O .. "png/ph/jujube-seed.png")
print(GV.report(t))
