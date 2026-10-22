local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cloth = c:ellipse(32, 42, 20, 14)
cloth:add(c:poly({ {27,19}, {38,19}, {47,34}, {17,34} }))
local puff = c:ellipse(32, 15, 8, 5)
local p = c:build{
  { "puff",  puff,  "#f1ece0" },
  { "cloth", cloth, "#f1ece0", { stitch = true } },
  { "tie",   c:rrect(25, 20, 39, 23, 1), "wood" },
  { "tag",   c:poly({ {45,8}, {51,18}, {39,18} }), GV.ramp("#2e5a2c"), { flat = true } },
  { "patch", c:rrect(20, 30, 44, 52, 6), "#f4f0e0", { gloss = false } },
  { "fig",   c:ellipse(32, 42.5, 7.5, 7), GV.ramp("#7a5cc0", { shade = "#4e3a8a" }) },
}
c:fill(c:line({ {39,21}, {42,18} }, 2), "#b07a45")
c:fill(c:line({ {28,24}, {26,28} }, 2), "#b07a45")
c:fill(c:line({ {36,24}, {38,28} }, 2), "#b07a45")
c:fill(c:line({ {28,10}, {28,18} }, 2), "#dcb06a")
c:fill(c:line({ {36,10}, {36,18} }, 2), "#dcb06a")
c:fill(c:rect(31, 33, 33, 35), "#2e5a2c")
c:px(34, 33, "#4a8a3e"); c:px(35, 33, "#4a8a3e")
c:seam({ {22,32}, {42,32}, {42,50}, {22,50}, {22,33} })
c:button(30, 20)
local t = c:save(O .. "aseprite/ph/fig-seed.aseprite", O .. "png/ph/fig-seed.png")
print(GV.report(t))
