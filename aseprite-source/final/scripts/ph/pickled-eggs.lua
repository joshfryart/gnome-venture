local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = GV.ramp("#a9d6ea", { gloss = "#c8ecdc", rim = "#8fcbd8" })
local brine = GV.ramp("#e6dcae")
local egg = GV.ramp("#f4f0e0")
local p = c:build{
  { "jar", c:rrect(17, 21, 46, 54, 7), glass, { gloss = { 20, 26 } } },
  { "brine", c:rrect(20, 29, 43, 52, 5), brine, { gloss = false } },
  { "egg1", c:ellipse(25.5, 33.5, 4.5, 4), egg, { gloss = { 23, 31 } } },
  { "egg2", c:ellipse(36, 33, 4, 4), egg, { gloss = { 34, 31 } } },
  { "egg3", c:ellipse(26, 48.5, 4, 3.5), egg, { gloss = false } },
  { "egg4", c:ellipse(36.5, 48, 4, 3.5), egg, { gloss = false } },
  { "label", c:rrect(21, 37, 42, 45, 2), "#f4f0e0", { gloss = false } },
  { "lid", c:rrect(16, 13, 47, 22, 4), "gold" },
}
-- label: wavy blue line and a tiny egg glyph
c:paint({ ".bb...bb...bb...", "b..b.b..b.b..b.b" }, 23, 40, { b = "#5a9ec0" })
c:paint({ ".yy.", "yyyy", ".yy." }, 36, 39, { y = "#e8a317" })
-- lid ridges
for x = 20, 44, 3 do c:px(x, 16, GV.R.gold.shade); c:px(x, 17, GV.R.gold.shade); c:px(x, 18, GV.R.gold.shade) end
c:seam({ { 19, 23 }, { 44, 23 } }, { free = true })
local t = c:save(O .. "aseprite/ph/pickled-eggs.aseprite", O .. "png/ph/pickled-eggs.png")
print(GV.report(t))
