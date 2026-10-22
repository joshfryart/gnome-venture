local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local paper = GV.ramp("#f1ece0")
local cone = c:poly({ {15, 24}, {50, 24}, {34, 56}, {31, 56} }):closed(2)
local bloom = c:ellipse(24, 16, 6, 5.5):add(c:ellipse(32, 12, 6.5, 6)):add(c:ellipse(40, 16, 6, 5.5))
bloom:add(c:ellipse(28, 19, 5, 3)):add(c:ellipse(36, 19, 5, 3))
local tail = c:poly({ {44, 15}, {49, 10}, {54, 4}, {57, 6}, {52, 12}, {47, 18} })

local p = c:build{
  { "tail",  tail, paper, { gloss = false } },
  { "bloom", bloom, GV.ramp("#7a5cc0", { rim = "#a894dc", gloss = "#c8b4f0" }) },
  { "cone",  cone, paper },
  { "rim",   c:rrect(13, 20, 51, 26, 2), paper, { gloss = false } },
}
-- twist bands on the tail
c:fill(c:line({ {46, 12}, {50, 16} }, 1):clip(p.tail.m), "#dcb06a")
c:fill(c:line({ {50, 8}, {54, 11} }, 1):clip(p.tail.m), "#dcb06a")
-- fold lines on the cone
c:fill(c:line({ {32, 54}, {25, 28} }, 1):clip(p.cone.m), "#dcb06a")
c:fill(c:line({ {33, 54}, {41, 28} }, 1):clip(p.cone.m), "#dcb06a")
-- rim lower edge
c:fill(c:rect(15, 26, 49, 26):clip(p.rim.m), "#dcb06a")
-- statice florets
for _, q in ipairs({ {21, 15}, {26, 13}, {35, 9}, {38, 15}, {43, 17}, {30, 18} }) do
  c:px(q[1], q[2], "#4e3a8a")
end
c:px(31, 13, "#c8b4f0"); c:px(23, 18, "#c8b4f0")
c:ground(32, 58, 10, 1.5)
local t = c:save(O .. "aseprite/ph/statice-seed.aseprite", O .. "png/ph/statice-seed.png")
print(GV.report(t))
