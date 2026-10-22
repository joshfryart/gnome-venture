local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- tapered blades: wide at pivot, 3 px at tip
local bl = c:poly({ {28,36}, {33,33}, {20,11}, {16,11} })
local br = c:poly({ {31,33}, {36,36}, {48,11}, {44,11} })
local hl = c:line({ {31,34}, {22,50} }, 8):add(c:ellipse(21.5, 50.5, 4.5, 4))
local hr = c:line({ {33,34}, {42,50} }, 8):add(c:ellipse(42.5, 50.5, 4.5, 4))
local all = bl:copy():add(br):add(hl):add(hr)
local p = c:build{
  { "hl", hl, "wood", { light = all } },
  { "hr", hr, "wood", { light = all } },
  { "bl", bl, "stone", { light = all } },
  { "br", br, "stone", { light = all } },
}
-- lit grip strips on the handles
c:fill(c:line({ {27,41}, {21,51} }, 2):clip(hl), "#ecc58a")
c:fill(c:line({ {37,41}, {41,49} }, 2):clip(hr), "#d9a660")
local bolt = c:ellipse(32, 34, 5, 5)
c:part(bolt, "#c9c5bc", { gloss = false })
c:fill(c:ellipse(32, 34, 1.5, 1.5), "#5b6470")
c:px(29, 31, "#fff1c8"); c:px(30, 31, "#fff1c8")
local t = c:save(O .. "aseprite/ico/ico-shears.aseprite", O .. "png/ico/ico-shears.png")
print(GV.report(t))
