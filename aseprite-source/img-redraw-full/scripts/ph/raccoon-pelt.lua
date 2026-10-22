local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local hide = c:rrect(19, 15, 45, 51, 6)
hide:cut(c:ellipse(15, 34, 5, 4)):cut(c:ellipse(49, 34, 5, 4))
hide:add(c:line({ {22, 21}, {14, 18}, {10, 16} }, 6))
hide:add(c:line({ {42, 21}, {50, 18}, {54, 16} }, 6))
hide:add(c:line({ {22, 44}, {14, 48}, {11, 51} }, 6))
hide:add(c:line({ {42, 44}, {50, 48}, {53, 51} }, 6))
for _, x in ipairs({ 23, 28, 33, 38, 42 }) do
  hide:add(c:ellipse(x, 14.5, 2.5, 2))
  hide:add(c:ellipse(x, 51.5, 2.5, 2))
end
hide:add(c:ellipse(32, 54, 2.5, 2.5))
c:build{ { "hide", hide, "wood", { gloss = { 21, 19 } } } }
local band = "#5e2f1e"
local function ring(y)
  local m = c:line({ {18, y}, {25, y + 2}, {32, y + 3}, {39, y + 2}, {46, y} }, 3):clip(hide:shrink(2))
  c:fill(m, band)
  c:fill(c:line({ {17, y - 1}, {24, y + 1}, {32, y + 2}, {40, y + 1}, {47, y - 1} }, 1):clip(m:grow(1)):cut(m):clip(hide:shrink(2)), "#8a4f2a")
end
ring(23); ring(31); ring(39)
c:fill(c:ellipse(32, 53.5, 1.5, 1.5):clip(hide:shrink(1)), band)
c:paint({ "f.f.f.f.f.f.f.f.f" }, 24, 17, { f = "#d9a660" })
c:seam({ {32, 17}, {32, 49} })
local t = c:save(O .. "aseprite/ph/raccoon-pelt.aseprite", O .. "png/ph/raccoon-pelt.png")
print(GV.report(t))
