local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- hooked blade: straight spine on the upper-left, bulging belly on the lower-right, tip at upper left
local blade = c:poly({
  { 12, 8 }, { 17, 11 }, { 23, 16 }, { 29, 22 }, { 34, 28 }, { 36, 31 },
  { 31, 36 }, { 27, 34 }, { 21, 29 }, { 16, 23 }, { 13, 17 }, { 11, 11 },
})
-- add belly bulge on the right side of the curve
blade:add(c:ellipse(28, 26, 6, 5):cut(c:poly({ { 0, 0 }, { 40, 0 }, { 40, 4 }, { 18, 30 }, { 0, 30 } })))
local handle = c:line({ { 37, 37 }, { 50, 50 } }, 7):add(c:ellipse(50, 50, 4.5, 4.5))
local ferrule = c:line({ { 31, 39 }, { 39, 31 } }, 3)

local p = c:build{
  { "handle", handle, "wood" },
  { "blade", blade, GV.ramp("#8a4f2a"), { gloss = { 15, 13 } } },
  { "ferrule", ferrule, "gold", { flat = true } },
}
-- handle seam groove and rivets
c:button(42, 41)
c:seam({ { 38, 34 }, { 52, 48 } }, { on = 2, off = 1 })
local t = c:save(O .. "aseprite/ph/foraging-knife.aseprite", O .. "png/ph/foraging-knife.png")
print(GV.report(t))
