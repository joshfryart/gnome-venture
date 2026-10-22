local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- handle: thick pill angled to the lower right
local handle = c:line({ { 42, 44 }, { 49, 53 } }, 7)
handle:add(c:ellipse(49.5, 53.5, 3.5, 3.5))
-- ferrule collar at the handle top
local ferrule = c:line({ { 38, 40 }, { 40, 42 } }, 8)
-- curved hooked blade, tip curling left
local blade = c:poly({
  { 36, 41 }, { 41, 37 }, { 42, 30 }, { 41, 23 }, { 38, 17 }, { 33, 12 }, { 27, 9 }, { 21, 9 },
  { 23, 12 }, { 28, 15 }, { 31, 19 }, { 33, 25 }, { 33, 31 }, { 31, 37 },
})
-- chipped notch near the tip
blade:cut(c:poly({ { 26, 13 }, { 30, 11 }, { 29, 16 } }))
local bladeR = GV.ramp("#8c4a1a")
local p = c:build{
  { "handle", handle, GV.ramp("#b6814d", { rim = "#f0d49a" }), { gloss = { 45, 46 } } },
  { "ferrule", ferrule, GV.ramp("#8a4f2a"), { gloss = false } },
  { "blade", blade, bladeR, { gloss = { 37, 22 } } },
  { "chip1", c:poly({ { 53, 40 }, { 57, 39 }, { 56, 43 } }), bladeR, { flat = true } },
  { "chip2", c:poly({ { 11, 40 }, { 15, 41 }, { 12, 44 } }), bladeR, { flat = true } },
}
-- zigzag crack through the blade
local crack = c:line({ { 31, 14 }, { 36, 23 }, { 32, 29 }, { 36, 37 } }, 2):clip(p.blade.m:shrink(1))
c:fill(crack, "#2a1a10")
c:ground(33, 57, 15, 2, "#6a4528")
local t = c:save(O .. "aseprite/ph/broken-hooked-forager-s-knife.aseprite", O .. "png/ph/broken-hooked-forager-s-knife.png")
print(GV.report(t))
