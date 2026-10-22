local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- handle: thick diagonal to lower right
local handle = c:line({ { 36, 33 }, { 49, 54 } }, 7)
-- bowl: sideways teardrop pointing left
local bowl = c:poly({
  { 9, 23 }, { 14, 18 }, { 20, 15 }, { 27, 14 }, { 34, 16 }, { 40, 21 }, { 43, 27 },
  { 41, 34 }, { 36, 39 }, { 29, 41 }, { 22, 40 }, { 16, 36 }, { 12, 30 },
})
-- snapped chip out of the lower-left rim
bowl:cut(c:poly({ { 12, 32 }, { 18, 33 }, { 16, 38 }, { 11, 36 } }))
local p = c:build{
  { "handle", handle, GV.ramp("#b6814d", { gloss = "#f0d49a" }) },
  { "bowl", bowl, "wood" },
}
-- hollow of the scoop
c:fill(c:ellipse(27, 25, 9, 5):clip(bowl), GV.R.wood.shade)
c:fill(c:ellipse(27, 24, 7, 3):clip(bowl), GV.R.wood.deep)
-- zigzag crack
c:fill(c:line({ { 29, 14 }, { 34, 23 }, { 28, 30 }, { 35, 38 } }, 2):clip(bowl), "#2a1a10")
-- loose chips
c:part(c:poly({ { 9, 42 }, { 14, 41 }, { 15, 45 }, { 10, 45 } }), "wood", { flat = true })
c:part(c:poly({ { 51, 46 }, { 55, 45 }, { 56, 49 }, { 52, 50 } }), "wood", { flat = true })
-- splinter on the handle
c:px(44, 41, GV.R.wood.deep); c:px(45, 42, GV.R.wood.deep); c:px(45, 43, GV.R.wood.deep)
c:ground(34, 55, 16, 1.5)
local t = c:save(O .. "aseprite/ph/broken-seed-scoop.aseprite", O .. "png/ph/broken-seed-scoop.png")
print(GV.report(t))
