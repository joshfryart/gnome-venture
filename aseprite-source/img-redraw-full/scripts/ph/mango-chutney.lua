local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local glass = GV.ramp("#c8ecdc", { rim = "#8fcbd8", shade = "#3f8fb0" })
local fill  = GV.ramp("#e8a317", { shade = "#b8661a", deep = "#7a3a14" })

-- squat, straight-sided jar with a wide screw lid
local jar = c:rrect(14, 25, 50, 51, 7)
local chut = c:rrect(17, 31, 47, 48, 5)
local lid = c:rrect(13, 15, 51, 25, 3)
local label = c:rrect(21, 35, 43, 45, 2)

local p = c:build{
  { "jar", jar, glass, { gloss = { 18, 29 } } },
  { "fill", chut, fill, { gloss = false } },
  { "lid", lid, "gold", { gloss = { 16, 17 } } },
  { "label", label, "cream", { gloss = false, cres = 1, deep = 0, bounce = false } },
}
-- bubbles in the chutney
for _, b in ipairs({ { 19, 33 }, { 44, 39 }, { 20, 45 }, { 45, 33 } }) do
  c:paint({ "bb", "bb" }, b[1], b[2], { b = "#f5cf6a" })
end
-- label border
c:fill(label:edge(), "#c9a96e")
-- tiny mango crescent with leaf
c:paint({
  "...ll.",
  "..ll..",
  ".mmmm.",
  "mmmmmm",
  "mmmmmd",
  ".mmdd.",
}, 29, 37, { m = "#f08a24", d = "#c4501a", l = "#6a9a3a" })
-- lid ridges
for _, x in ipairs({ 24, 32, 40 }) do
  c:fill(c:rect(x, 17, x, 22), "#b8661a")
end
-- twine round the neck + lid seam
c:seam({ { 15, 27 }, { 49, 27 } }, { free = true })
c:seam({ { 15, 24 }, { 49, 24 } })
c:button(16, 18)

local t = c:save(O .. "aseprite/ph/mango-chutney.aseprite", O .. "png/ph/mango-chutney.png")
print(GV.report(t))
