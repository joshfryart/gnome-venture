local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(B .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local soil = GV.ramp("#7a4a1f", { rim = "#9a6b3f", shade = "#3d2a1c", deep = "#2a1a10" })
local soilL = GV.ramp("#9a6b3f", { shade = "#7a4a1f", deep = "#3d2a1c" })

-- main lumpy mound (right hump bigger), flat bottom
local mound = c:ellipse(35, 42, 19, 13)
mound:add(c:ellipse(46, 45, 8, 7))
mound:add(c:ellipse(18, 46, 8, 6))
mound:cut(c:rect(0, 51, 63, 63))
mound:add(c:rrect(12, 46, 53, 51, 3))
-- second hump on the left
local hump = c:ellipse(22, 38, 10, 9)
hump:cut(c:mask():add(c:rect(0, 44, 63, 63)))
hump:add(c:rrect(14, 40, 30, 45, 4))

local p = c:build{
  { "mound", mound, soil, { gloss = false } },
  { "hump", hump, soilL, { gloss = false } },
}
-- leaf flakes (angular)
local leaf1 = GV.ramp("#c9a96e")
local leaf2 = GV.ramp("#b07a45")
c:part(c:poly({ {14, 39}, {20, 35}, {25, 37}, {19, 41} }), leaf1, { flat = true })
c:line({ {16, 39}, {22, 37} }, 1):each(function(x, y) c:px(x, y, "#5e2f1e") end)
c:part(c:poly({ {32, 33}, {38, 30}, {42, 32}, {36, 36} }), leaf2, { flat = true })
c:line({ {34, 34}, {39, 32} }, 1):each(function(x, y) c:px(x, y, "#5e2f1e") end)
c:part(c:poly({ {41, 42}, {46, 39}, {51, 41}, {45, 45} }), leaf1, { flat = true })
c:line({ {43, 43}, {48, 41} }, 1):each(function(x, y) c:px(x, y, "#5e2f1e") end)
-- crumbs
for _, q in ipairs({ { 28, 42 }, { 36, 46 }, { 22, 47 }, { 46, 34 } }) do
  c:fill(c:rect(q[1], q[2], q[1] + 1, q[2] + 1), "#3d2a1c")
end
-- mushroom sprout
c:part(c:rect(39, 24, 40, 29), "cream", { flat = true })
c:part(c:ellipse(39.5, 22, 3.5, 2):cut(c:rect(0, 23, 63, 63)):add(c:rect(36, 23, 43, 23)), "petal", { flat = true })
c:px(38, 21, "#f6b8cf")
-- small gloss dot
c:px(19, 32, "#c9a96e"); c:px(20, 32, "#c9a96e"); c:px(19, 33, "#c9a96e")

local t = c:save(B .. "img-redraw-full/aseprite/ph/leaf-mould-clump.aseprite", B .. "img-redraw-full/png/ph/leaf-mould-clump.png")
print(GV.report(t))
