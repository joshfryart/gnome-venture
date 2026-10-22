local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 50, h = 45, out = 2, mode = "sticker" }

-- tapered stave body (bottom edge slightly curved)
local body = c:poly({ {10, 12}, {41, 12}, {35, 37}, {16, 37} })
body:cut(c:rect(0, 36, 17, 36)):cut(c:rect(33, 36, 49, 36))
local bodyAll = body:copy()
local metal = GV.ramp("#7e8c94", { rim = "#c9d3da" })
-- hoops: curved bands slightly proud of the staves
local hoopU = c:poly({ {9.5, 16}, {41.5, 16}, {40.5, 20}, {10.5, 20} })
hoopU:add(c:rect(12, 20, 38, 20))
local hoopL = c:poly({ {13.5, 29}, {37.5, 29}, {36.5, 33}, {14.5, 33} })
hoopL:add(c:rect(16, 33, 34, 33))
-- dark inner panel between hoops (front stave panel)
local panel = c:poly({ {17, 22}, {34, 22}, {32.5, 28}, {18.5, 28} }):cut(c:rect(18,27,18,27)):cut(c:rect(32,27,32,27))
-- wide curved rim lip
local rim = c:ellipse(25.5, 11, 17, 3)

local p = c:build{
  { "body",  body,  "wood" },
  { "panel", panel, GV.ramp("#8a5a30"), { gloss = false } },
  { "hoopU", hoopU, metal, { gloss = false, light = bodyAll } },
  { "hoopL", hoopL, metal, { gloss = false, light = bodyAll } },
  { "rim",   rim,   GV.ramp("#e2b072", { gloss = "#fff1c8" }), { light = bodyAll } },
}
-- inner opening dark sliver inside rim
c:fill(c:ellipse(25.5, 11, 13.5, 1), "#5e2f1e")
for x = 14, 37 do c:px(x, 10, "#8a4f2a") end
-- stave seams
for _, x in ipairs({ 15, 36 }) do
  for y = 14, 15 do c:px(x, y, "#a8582f") end
  for y = 22, 27 do if not panel:has(x, y) then c:px(x, y, "#a8582f") end end
end
-- hoop top light line
for x = 11, 39 do c:px(x, 16, "#c9d3da") end
for x = 15, 35 do c:px(x, 29, "#c9d3da") end
-- panel gloss dash
c:px(19, 23, "#fff1c8"); c:px(20, 23, "#fff1c8"); c:px(21, 23, "#fff1c8")
-- rim glint left
c:px(12, 10, "#f0cc90"); c:px(13, 9, "#f0cc90"); c:px(14, 9, "#f0cc90")

c:ground(25.5, 38, 11, 1.5)
local t = c:save(O .. "aseprite/gather/calm-bucket-front.aseprite", O .. "png/gather/calm-bucket-front.png")
print(GV.report(t))
