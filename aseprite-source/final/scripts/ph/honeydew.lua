local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- teardrop: round lower body plus a tapered top
local body = c:ellipse(32, 41, 18, 15)
body:add(c:poly({ {32, 10}, {16, 36}, {49, 36} }))
body:add(c:ellipse(32, 30, 13, 12))
local stem = c:rrect(30, 6, 34, 12, 1)

local ramp = GV.ramp("#d6e0a0", { rim = "#f2f0c0", shade = "#a4b86a", deep = "#7ab55c", bounce = "#b8c87a" })
local p = c:build{
  { "stem", stem, GV.ramp("#8a4f2a") },
  { "body", body, ramp, { pale = true } },
}
-- faint vertical ridges
local R = "#a4b86a"
for y = 16, 52, 2 do
  local f = (y - 14) / 40
  local bulge = math.sin(math.min(f, 1) * math.pi * 0.85)
  c:px(22 + math.floor((1 - bulge) * 8 + 0.5), y, R)
  c:px(42 - math.floor((1 - bulge) * 8 + 0.5), y, R)
end
for y = 15, 50, 2 do c:px(32, y, R) end
-- blossom-end dimple
c:paint({ ".ddd.", "d...d", ".ddd." }, 30, 51, { d = "#a4b86a" })

local t = c:save(O .. "aseprite/ph/honeydew.aseprite", O .. "png/ph/honeydew.png")
print(GV.report(t))
