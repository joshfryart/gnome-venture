local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local glassR = GV.ramp("#a9d6ea", { rim = "#c8ecdc", shade = "#5a86b8", deep = "#2f6290" })
local glass = c:rrect(18, 22, 46, 54, 6)
-- cabbage mass with a wavy top
local cab = c:rrect(22, 31, 42, 51, 3)
cab:add(c:ellipse(25, 31, 3, 2)); cab:add(c:ellipse(32, 30, 4, 2)); cab:add(c:ellipse(39, 31, 3, 2))
local label = c:rect(24, 37, 40, 45)
local lid = c:rrect(17, 14, 47, 24, 3)

local p = c:build{
  { "glass", glass, glassR, { gloss = false } },
  { "cab",   cab,   GV.ramp("#a4b86a"), { gloss = false } },
  { "label", label, GV.ramp("#f4f0e0"), { gloss = false } },
  { "lid",   lid,   "gold" },
}
-- chili flecks on the cabbage
local red = "#dd3a2a"
for _, f in ipairs({ { 25, 33 }, { 34, 32 }, { 39, 34 }, { 29, 35 }, { 23, 47 }, { 31, 48 }, { 38, 47 }, { 27, 50 }, { 35, 50 } }) do
  c:fill(c:rect(f[1], f[2], f[1] + 1, f[2] + 1), red)
end
-- red zigzag on label
c:paint({ "rr...rr...rr...", ".rr.rr.rr.rr.rr", "..rrr...rrr...r" }, 25, 40, { r = red })
-- glass glint streak (left side, over empty glass)
c:fill(c:rect(20, 27, 20, 46), "#c8ecdc"); c:fill(c:rect(20, 27, 20, 30), "#f0fbf4")
c:px(21, 26, "#f0fbf4")
-- lid seam and button
c:seam({ { 19, 22 }, { 45, 22 } })
c:button(30, 16)
c:ground(32, 55, 15, 1.5)

local t = c:save(O .. "aseprite/ph/fiery-pickled-cabbage.aseprite", O .. "png/ph/fiery-pickled-cabbage.png")
print(GV.report(t))
