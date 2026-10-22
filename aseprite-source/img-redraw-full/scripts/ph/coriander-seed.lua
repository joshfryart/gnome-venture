local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local glass = GV.ramp("#8fcbd8", { gloss = "#f4fff8", dot = "#e8fff4" })
local cork = GV.ramp("#d9a660", { shade = "#a8582f" })

local jar = c:rrect(13, 22, 51, 56, 8)
local p = c:build{
  { "jar",  jar, glass, { gloss = false } },
  { "neck", c:rect(22, 15, 42, 23), glass, { gloss = false } },
  { "cork", c:rrect(24, 6, 40, 16, 2), cork },
  { "lip",  c:rrect(20, 15, 44, 18, 1), glass, { gloss = false } },
}
-- glass interior: paler fill inside the walls
c:fill(jar:shrink(3):cut(c:rect(0, 0, 63, 25)), "#c8ecdc")
-- cork grain
c:px(28, 10, "#a8582f"); c:px(33, 9, "#a8582f"); c:px(36, 12, "#a8582f"); c:px(30, 13, "#a8582f")

-- label with gold ring
local lab = c:rrect(20, 28, 44, 52, 5)
c:part(lab, "#f4f0e0", { gloss = false })
c:fill(lab:copy():cut(lab:shrink(2)), "#e8a317")

-- coriander leaf (lens)
local leaf = c:poly({ {32, 30}, {37, 35}, {39, 41}, {37, 47}, {32, 50}, {27, 47}, {25, 41}, {27, 35} })
c:part(leaf, GV.ramp("#58a03e"), { gloss = { 28, 37 } })
c:fill(c:line({ {32, 32}, {32, 48} }, 1), "#2e5a2c")
c:fill(c:line({ {32, 42}, {27, 38} }, 1), "#2e5a2c")
c:fill(c:line({ {32, 39}, {36, 36} }, 1), "#2e5a2c")

-- big glass gloss comma on the jar, upper left (brightest thing)
c:paint({
  ".gg",
  "ggg",
  "gg.",
  "gg.",
  "gg.",
  "gg.",
  "g..",
  "g..",
  "...",
  "g..",
}, 15, 26, { g = "#f4fff8" })
-- lip glint
c:paint({ "gggg" }, 23, 16, { g = "#f4fff8" })

local t = c:save(O .. "aseprite/ph/coriander-seed.aseprite", O .. "png/ph/coriander-seed.png")
print(GV.report(t))
