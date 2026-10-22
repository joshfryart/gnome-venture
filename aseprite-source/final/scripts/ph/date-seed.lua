local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local cloth = GV.ramp("#f1ece0")
local cord  = GV.ramp("#dcb06a")
local brown = GV.ramp("#8c4a1a")
local tagR  = GV.ramp("#2e5a2c", { base = "#3f7a34" })

-- pennant on a little stick, tucked behind the neck
local tag = c:poly({ {43, 8}, {52, 17}, {40, 17} }):add(c:rect(39, 16, 41, 24))
-- ruffled neck: narrow at the cord, flaring to a scalloped lip
local neck = c:poly({ {22, 17}, {42, 17}, {36, 27}, {28, 27} })
for _, x in ipairs({ 24, 29, 34.5, 40 }) do neck:add(c:ellipse(x, 16, 3, 2.5)) end
local belly = c:ellipse(31.5, 41, 19, 15)
local band = c:rrect(25, 24, 39, 27, 1)
local ends = c:line({ {26, 27}, {24, 31}, {25, 34} }, 2):add(c:line({ {38, 27}, {40, 31}, {39, 34} }, 2))

local p = c:build{
  { "tag", tag, tagR, { gloss = false } },
  { "neck", neck, cloth },
  { "belly", belly, cloth, { stitch = { side = "lit" } } },
  { "band", band, cord, { gloss = false } },
  { "ends", ends, cord, { flat = true } },
  { "ring", c:ellipse(31.5, 42.5, 9), brown, { gloss = false } },
  { "patch", c:ellipse(31.5, 42.5, 7), GV.ramp("#f4f0e0"), { gloss = false } },
  { "stone", c:ellipse(31.5, 43, 4.5, 5.5), brown },
}
-- groove down the date stone
c:px(32, 41, "#44281c"); c:px(32, 42, "#44281c"); c:px(32, 43, "#44281c"); c:px(32, 44, "#44281c"); c:px(32, 45, "#44281c")
-- sprout from the top of the stone
c:paint({
  ".gg..",
  "gggg.",
  "..gg.",
  "..g..",
}, 30, 34, { g = "#7ab55c" })
c:seam({ {25, 25}, {39, 25} })
c:ground(31.5, 56, 15, 1.5)

local t = c:save(O .. "aseprite/ph/date-seed.aseprite", O .. "png/ph/date-seed.png")
print(GV.report(t))
