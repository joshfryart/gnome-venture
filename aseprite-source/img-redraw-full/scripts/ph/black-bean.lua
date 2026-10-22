local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local bean = GV.ramp("#3a2a22", { rim = "#6a4a3a", gloss = "#b08a72", dot = "#e0c0a8" })
local sprout = GV.ramp("#4a8a3e", { rim = "#7ab55c" })

-- kidney bean lying diagonally: two lobes with a dent on the lower-left inner side
local body = c:mask()
local arc = { { 19, 38, 9 }, { 23, 33, 10 }, { 29, 28, 11 }, { 36, 26, 11.5 }, { 43, 27, 11 }, { 46, 30, 9 } }
for _, a in ipairs(arc) do body:add(c:ellipse(a[1], a[2], a[3], a[3])) end
body:cut(c:ellipse(36, 45, 8, 6))
body = body:closed(3)

local sp = c:line({ { 13, 41 }, { 9, 45 }, { 7, 49 } }, 3)

local p = c:build{
  { "sprout", sp, sprout, { flat = true } },
  { "bean", body, bean, { gloss = { 23, 22 } } },
}
-- sprout tip
c:fill(c:rect(6, 48, 8, 50), "#7ab55c")
c:px(6, 48, "#a4b86a")

-- curved sheen band across the top-left
c:fill(c:line({ { 14, 37 }, { 17, 31 }, { 24, 24 }, { 33, 19 }, { 43, 18 } }, 1), "#6a4a3a")

-- hilum (eye scar) just above the inner dent
c:fill(c:rect(31, 34, 38, 38), "#4a2c1a")
c:fill(c:rect(32, 35, 37, 37), "#f2e4c0")
c:px(31, 34, bean.base); c:px(38, 34, bean.base); c:px(31, 38, bean.base); c:px(38, 38, bean.base)
c:fill(c:rect(33, 36, 36, 36), "#c9a96e")

local t = c:save(O .. "aseprite/ph/black-bean.aseprite", O .. "png/ph/black-bean.png")
print(GV.report(t))
