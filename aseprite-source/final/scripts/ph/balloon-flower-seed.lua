local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local R = GV.R
local belly = c:ellipse(31.5, 39, 17, 15)
local top = c:poly({ {23,13}, {41,13}, {36,25}, {28,25} })
local p = c:build{
  { "belly", belly, "cream" },
  { "top",   top, "cream", { gloss = false } },
  { "bowL",  c:ellipse(23.5, 20, 3.5, 2.5), GV.ramp("#c9a96e"), { gloss = false, flat = true } },
  { "bowR",  c:ellipse(40.5, 20, 3.5, 2.5), GV.ramp("#c9a96e"), { gloss = false, flat = true } },
  { "tie",   c:rrect(26, 22, 38, 25, 1), GV.ramp("#c9a96e"), { gloss = false } },
  { "bud",   c:ellipse(31.5, 42, 6.5, 6.5), "petal" },
  { "leaf",  c:poly({ {34,32}, {38,30}, {41,31}, {38,35} }), "moss", { flat = true } },
}
c:stitch(p.belly.m:copy():cut(c:rect(0, 0, 63, 27)))
-- gathered folds on the top
c:paint({ "f..f", "f..f", ".ff." }, 29, 15, { f = "#dcb06a" })
c:px(26, 15, "#dcb06a"); c:px(37, 15, "#dcb06a")
c:fill(c:line({ {32, 35}, {32, 33} }, 2), "#2f5a2a")
-- bud petal creases
c:paint({ "..s..", "..s..", "sssss" }, 30, 40, { s = R.petal.shade })
local t = c:save(O .. "aseprite/ph/balloon-flower-seed.aseprite", O .. "png/ph/balloon-flower-seed.png")
print(GV.report(t))
