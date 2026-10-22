local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(31.5, 37, 16.5, 15)
local stem = c:rect(31, 12, 33, 20)
-- flat four-petal calyx star, wider than the stem
local calyx = c:ellipse(31.5, 22, 8, 2.5)
calyx:add(c:poly({ {19,25}, {25,20}, {28,23} }))
calyx:add(c:poly({ {44,25}, {38,20}, {35,23} }))
calyx:add(c:poly({ {24,27}, {28,22}, {31,25} }))
calyx:add(c:poly({ {39,27}, {35,22}, {32,25} }))
c:build{
  { "body", body, "gold", { gloss = { 23, 30 } } },
  { "stem", stem, "#2f5a2a", { flat = true } },
  { "calyx", calyx, "#58a03e", { gloss = false } },
}
c:px(32, 11, "#4a8a3e")
-- calyx petal veins
c:px(26, 23, "#3e7a2e"); c:px(37, 23, "#3e7a2e"); c:px(28, 24, "#3e7a2e"); c:px(35, 24, "#3e7a2e")
-- faint navel at the bottom
c:paint({ ".nn.", "n..n", ".nn." }, 30, 46, { n = "#b8661a" })
local t = c:save(O .. "aseprite/ph/mangosteen.aseprite", O .. "png/ph/mangosteen.png")
print(GV.report(t))
