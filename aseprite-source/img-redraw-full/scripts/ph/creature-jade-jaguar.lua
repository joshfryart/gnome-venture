local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local jade  = GV.ramp("#58a03e")
local pale  = GV.ramp("#b0bc66")
local dark  = GV.ramp("#2e5a2c")
local band  = GV.ramp("#b07a10")

local tail = c:line({ {38,47},{43,47},{47,44},{49,40},{49,36},{47,33},{44,33},{43,36} }, 3)
local ears = c:ellipse(16.5, 19, 4.5, 4.5):add(c:ellipse(35.5, 19, 4.5, 4.5))
local inner = c:ellipse(16.5, 19.5, 2, 2):add(c:ellipse(35.5, 19.5, 2, 2))
local crown = c:ascii({
  "#......#......#",
  "##.....#.....##",
  "##....###....##",
  "###..#####..###",
  "###############",
}, 19, 10)
local p = c:build{
  { "tail",  tail, dark },
  { "ears",  ears, jade },
  { "inner", inner, pale, { flat = true } },
  { "body",  c:ellipse(26, 42, 14, 9), jade },
  { "belly", c:ellipse(26, 44, 7, 6), pale, { flat = true } },
  { "feet",  c:ellipse(19.5, 49, 4.5, 2.5):add(c:ellipse(32.5, 49, 4.5, 2.5)), dark },
  { "head",  c:ellipse(26, 26, 10.5, 10), jade },
  { "muzzle",c:ellipse(26, 31, 5.5, 3.5), pale },
  { "crown", crown, "gold" },
  { "band",  c:rrect(18, 15, 34, 17, 1), band },
}
local function diamond(x, y) return c:ascii({ ".#.", "###", ".#." }, x, y) end
c:spot(diamond(14, 38)); c:spot(diamond(35, 37)); c:spot(diamond(15, 44))
c:spot(diamond(36, 43)); c:spot(diamond(25, 19))
c:seam({ {19, 16}, {33, 16} })
c:paint({ ".r.", "rrr", ".r." }, 25, 11, { r = "#d6322b" })
c:px(26, 11, "#ff9158")
c:eye(18, 22); c:eye(29, 22)
c:paint({ "nnn", ".n." }, 25, 29, { n = "#2a1a10" })
c:paint({ "n...n", ".n.n." }, 24, 32, { n = "#2a1a10" })
c:ground(26, 51.5, 15, 1.5)
local t = c:save(O .. "aseprite/ph/creature-jade-jaguar.aseprite", O .. "png/ph/creature-jade-jaguar.png")
print(GV.report(t))
