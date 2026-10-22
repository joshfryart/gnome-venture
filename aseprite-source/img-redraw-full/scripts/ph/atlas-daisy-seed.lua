local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local paper = GV.ramp("#f1ece0")
local cone = c:poly({{13,23},{51,23},{37,55},{27,55}})
cone:add(c:ellipse(32, 54, 5, 3))
cone:add(c:rrect(13,22,51,27,2))
local flap = c:poly({{14,24},{50,24},{32,37}})
local neck = c:poly({{28,12},{36,12},{37,24},{27,24}})
local fan = c:poly({{22,6},{30,11},{34,11},{42,6},{40,14},{24,14}})
local p = c:build{
  { "cone", cone, paper, { light = cone } },
  { "flap", flap, GV.ramp("#f4f0e0"), { gloss = false, bounce = false } },
  { "neck", neck, paper, { gloss = false } },
  { "fan", fan, paper, { gloss = {26,9} } },
  { "tie", c:rect(26,21,38,23), "#dcb06a", { flat = true } },
  { "label", c:ellipse(32, 42, 7.5, 7.5), "petal" },
  { "leaf", c:ellipse(42, 33, 3.5, 2), "moss", { flat = true } },
}
-- daisy petals hint + centre
c:paint({
 "..ww..",
 ".wggw.",
 "wggggw",
 "wggggw",
 ".wggw.",
 "..ww..",
}, 29, 39, { w = "#f6b8cf", g = "#f1c24a" })
c:px(31,40,"#fff1c8")
-- fold line and twist lines
c:line({{15,24},{32,36}},1); c:line({{32,36},{49,24}},1)
c:fill(c:line({{15,24},{32,36}},1):add(c:line({{32,36},{49,24}},1)), "#dcb06a")
c:fill(c:line({{29,14},{34,19}},1), "#dcb06a")
c:fill(c:line({{30,17},{35,21}},1), "#dcb06a")
c:seam({ {39,30}, {34,52} })
local t = c:save(O.."aseprite/ph/atlas-daisy-seed.aseprite", O.."png/ph/atlas-daisy-seed.png")
print(GV.report(t))
