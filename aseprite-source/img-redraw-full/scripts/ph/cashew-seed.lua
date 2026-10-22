local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local lid = c:poly({ {15, 31}, {50, 31}, {54, 14}, {19, 14} })
local body = c:rrect(12, 30, 51, 54, 3)
local hinge = c:rrect(14, 28, 49, 32, 1)
local label = c:rrect(21, 37, 42, 49, 2)

local p = c:build{
  { "lid",   lid,   GV.ramp("#c9c5bc") },
  { "body",  body,  GV.ramp("#8b8f96") },
  { "hinge", hinge, GV.ramp("#5b6470"), { flat = true } },
  { "label", label, GV.ramp("#f4f0e0"), { gloss = false } },
}

-- dark underside band on the lid (inside of the open lid)
local under = c:poly({ {16, 28}, {50, 28}, {52, 19}, {18, 19} }):clip(lid:shrink(2))
c:fill(under, "#5b6470")
c:fill(c:poly({ {18, 19}, {52, 19}, {52, 18}, {18, 18} }):clip(lid:shrink(2)), "#4a5260")
c:fill(c:poly({ {16, 28}, {50, 28}, {50, 27}, {16, 27} }):clip(lid:shrink(2)), "#3f4652")

-- cashew: kidney crescent
local nut = c:ellipse(32, 42, 7, 5)
nut:cut(c:ellipse(32, 38.5, 3.5, 3))
local np = c:part(nut, GV.ramp("#dcb06a"), { gloss = { 27, 41 } })
local cap = c:ellipse(32, 42, 7, 5):clip(c:rect(0, 37, 63, 39)):cut(c:ellipse(32, 38.5, 3.5, 3))
c:fill(cap, "#e8a317")
c:fill(c:rect(31, 34, 33, 36), "#2e5a2c")
c:px(31, 34, "#4a8a3e")

-- rivets
for _, r in ipairs({ {16, 50}, {45, 50}, {16, 35}, {45, 35} }) do
  c:paint({ ".r.", "rrr", ".r." }, r[1], r[2], { r = "#8c4a1a" })
  c:px(r[1] + 1, r[2], "#c87a3a")
end

c:seam({ {15, 31}, {28, 31} }); c:seam({ {35, 31}, {49, 31} })
c:button(30, 29)

c:ground(31.5, 56, 19, 1.5)
local t = c:save(O .. "aseprite/ph/cashew-seed.aseprite", O .. "png/ph/cashew-seed.png")
print(GV.report(t))
