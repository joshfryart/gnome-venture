local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- pod: fat crescent rising out of the crate, peas bulging on top
local pod = c:ellipse(32, 27, 20, 12):cut(c:ellipse(30, 39, 22, 9))
pod:add(c:ellipse(32, 30, 17, 4))
local peas = c:ellipse(23, 22, 4, 4):add(c:ellipse(32, 19, 4, 4)):add(c:ellipse(41, 20, 4, 4))
local stem = c:line({ {14, 28}, {10, 22} }, 3)

local back  = c:rrect(12, 30, 52, 55, 2)
local slats = c:rect(12, 33, 52, 39):add(c:rect(12, 42, 52, 47)):add(c:rect(12, 50, 52, 55))
local posts = c:rect(10, 30, 16, 56):add(c:rect(48, 30, 54, 56))

c:build{
  { "stem", stem, "#2e5a2c", { flat = true } },
  { "pod", pod, "gold" },
  { "peas", peas, "#e8a317", { gloss = false } },
  { "back", back, "#8a4f2a" },
  { "slats", slats, "#b07a45", { light = back } },
  { "posts", posts, "#a8582f", { light = back } },
}
-- top rail of crate (light lip)
for x = 17, 47 do c:px(x, 31, "#5e2f1e") end
-- nails
for _, p in ipairs{ {12, 35}, {51, 35}, {12, 51}, {51, 51} } do
  c:paint({ "nn", "nn" }, p[1], p[2], { n = "#5e2f1e" })
end
-- pea glints
c:px(21, 20, "#fff1c8"); c:px(30, 17, "#fff1c8"); c:px(39, 18, "#fff1c8")

local t = c:save(O .. "aseprite/ph/chickpea-seed.aseprite", O .. "png/ph/chickpea-seed.png")
print(GV.report(t))
