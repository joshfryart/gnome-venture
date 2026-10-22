local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local leafL = c:poly({ {24, 31}, {29, 31}, {34, 36}, {34, 39}, {29, 39}, {25, 35} })
local leafR = c:poly({ {43, 29}, {38, 29}, {33, 34}, {33, 37}, {38, 37}, {42, 33} })
local p = c:build{
  { "cover",  c:rrect(11, 8, 53, 56, 4),  GV.ramp("#2e5a2c") },
  { "board",  c:rect(16, 8, 53, 54),      GV.ramp("#58a03e") },
  { "spine",  c:rrect(11, 8, 15, 56, 2),  GV.ramp("#2e5a2c"), { gloss = false } },
  { "panel",  c:rect(19, 12, 49, 51),     "cream" },
  { "medal",  c:ellipse(33.5, 31, 9, 9),  GV.ramp("#a4c86a"), { gloss = { 28, 25 } } },
  { "stem",   c:rect(33, 33, 34, 40),     GV.ramp("#2e5a2c"), { flat = true } },
  { "leafL",  leafL,                      GV.ramp("#4a8a3e"), { gloss = false } },
  { "leafR",  leafR,                      GV.ramp("#58a03e"), { gloss = false } },
}
c:fill(c:rect(23, 44, 44, 45), "#c9b9a0")
c:fill(c:rect(23, 47, 38, 48), "#c9b9a0")
c:seam({ {17, 13}, {17, 52} }, { free = true })
c:button(12, 10)
local t = c:save(O .. "aseprite/ph/nav-almanac.aseprite", O .. "png/ph/nav-almanac.png")
print(GV.report(t))
