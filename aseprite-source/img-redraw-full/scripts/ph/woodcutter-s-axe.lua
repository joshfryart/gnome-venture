local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- long diagonal handle, lower left to upper right
local handle = c:line({ { 20, 52 }, { 36, 12 } }, 5)
-- steel head: socket around the handle top, single-bit blade bulging right
local head = c:poly({ { 31, 9 }, { 40, 11 }, { 44, 14 }, { 49, 10 }, { 53, 12 }, { 54, 20 }, { 53, 29 },
  { 49, 32 }, { 44, 27 }, { 39, 25 }, { 31, 22 } })
local p = c:build{
  { "handle", handle, "wood", { gloss = false } },
  { "head", head, GV.ramp("#8b8f96") },
}
c:part(c:ellipse(19, 53, 4, 4), GV.ramp("#8a4f2a"), { gloss = false })
-- bright honed edge along the curved blade
local edge = c:poly({ { 50, 11 }, { 53, 12 }, { 54, 20 }, { 53, 29 }, { 50, 31 }, { 51, 20 } })
c:fill(edge, "#c9c5bc")
c:px(52, 13, "#f1ece0"); c:px(52, 14, "#f1ece0")
-- gold grip wrap bands across the handle
for _, y in ipairs({ 44, 40, 36 }) do
  local x = math.floor(20 + (52 - y) * 16 / 40 + 0.5)
  c:fill(c:line({ { x - 3, y + 1 }, { x + 3, y - 1 } }, 1):clip(p.handle.m), "#e8a317")
end
c:ground(24, 57, 9, 1.5)

local t = c:save(O .. "aseprite/ph/woodcutter-s-axe.aseprite", O .. "png/ph/woodcutter-s-axe.png")
print(GV.report(t))
