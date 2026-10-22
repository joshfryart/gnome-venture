-- ph/guide-ca (REDO, unique): shield badge, teal field, smoking volcano, quetzal feather, stitched gold edge
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local OUT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- shield: flat top with rounded corners, straight sides, tapering to a point
local shield = c:rrect(13, 9, 50, 34, 4)
shield:add(c:poly({ {13, 30}, {51, 30}, {51, 38}, {32, 58}, {31, 58}, {13, 38} }))
local field = shield:shrink(3)

-- volcano cone sits on the bottom of the field
local cone = c:poly({ {27, 24}, {37, 24}, {49, 48}, {49, 60}, {14, 60}, {14, 48} }):clip(field)
-- smoke puffs above the crater
local smoke = c:ellipse(31, 20, 3.5, 2.5)
smoke:add(c:ellipse(25.5, 16, 4, 3))
smoke:add(c:ellipse(31, 13, 3.5, 2.5))
smoke:clip(field)

-- quetzal tail feather: long curve from lower left, across the shield, out top right
local vane = c:line({ {21, 47}, {27, 46}, {33, 45}, {39, 42}, {44, 37}, {48, 31}, {51, 24}, {53, 17} }, 4)
vane:add(c:line({ {53, 18}, {55, 11} }, 3))
local red = c:line({ {9, 52}, {13, 50}, {17, 48}, {22, 47} }, 4)

local p = c:build{
  { "rim",   shield, "gold" },
  { "field", field,  GV.ramp("#2f9a8a"), { cres = 4 } },
  { "cone",  cone,   GV.ramp("#3e6e36"), { light = field } },
  { "smoke", smoke,  GV.ramp("#e6e0d0"), { flat = true } },
  { "red",   red,    "red" },
  { "vane",  vane,   GV.ramp("#2fb85a") },
}

-- crater glow
c:paint({ "eooooe", ".eeee." }, 29, 24, { e = "#e0501f", o = "#f08a24" })
-- feather rachis (1 px accent down the vane)
for _, q in ipairs({ {25,48},{27,47},{29,47},{31,47},{33,46},{35,46},{37,45},{39,44},{41,42},{43,40},{44,39},{46,37},{47,35},{48,33},{49,31},{50,29},{51,27},{52,25},{53,22},{54,19} }) do
  c:px(q[1], q[2], "#1f6a3a")
end
-- red barbs at the feather base
c:px(13, 52, "#6b1b2c"); c:px(17, 50, "#6b1b2c")

-- stitched gold edge: ring of thread just inside the gold rim
c:stitch(field)

local t = c:save(OUT .. "aseprite/ph/guide-ca.aseprite", OUT .. "png/ph/guide-ca.png")
print(GV.report(t))
