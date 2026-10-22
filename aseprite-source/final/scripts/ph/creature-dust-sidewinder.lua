local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tan = GV.ramp("#dcb06a")
-- flat coil loop
local coil = c:ellipse(33.5, 47, 21, 10):cut(c:ellipse(34, 46, 11, 3.5))
-- neck rising from the left of the loop
local neck = c:line({ {16, 51}, {14, 45}, {14, 40}, {16, 35} }, 7)
-- head + snout
local head = c:ellipse(18, 29, 7.5, 6.5)
head:add(c:poly({ {21, 25}, {29, 29}, {29, 33}, {21, 35} }))
local tongue = c:line({ {28, 32}, {33, 35} }, 3)
tongue:add(c:line({ {33, 34}, {38, 33} }, 3)):add(c:line({ {33, 35}, {36, 39} }, 3))
local all = coil:copy():add(neck):add(head)
local p = c:build{
  { "coil", coil, tan, { cres = 3, deep = 1 } },
  { "neck", neck, tan, { light = all, cres = 2, deep = 1 } },
  { "head", head, tan, { cres = 2, deep = 1 } },
  { "tongue", tongue, GV.ramp("#d6322b"), { flat = true, contour = false, contact = false } },
}
-- cream top stripe along the back of the loop
local top = coil:copy():cut(coil:shift(0, 2)):cut(neck:grow(1))
top:each(function(x, y) if y < 44 then c:px(x, y, "#f8eed2") end end)
-- seam along the coil spine (front half)
local sp = {}
for a = 15, 165, 10 do
  local r = math.rad(a)
  sp[#sp + 1] = { math.floor(34 + 16 * math.cos(r) + 0.5), math.floor(47 + 6.5 * math.sin(r) + 0.5) }
end
c:seam(sp)
-- six tick marks across the band
local D = "#4a2c1a"
c:fill(c:rect(22, 50, 23, 54), D)
c:fill(c:rect(31, 52, 32, 56), D)
c:fill(c:rect(40, 52, 41, 56), D)
c:fill(c:rect(48, 48, 49, 52), D)
c:fill(c:rect(43, 38, 44, 41), D)
c:fill(c:rect(30, 38, 31, 41), D)
-- face
c:eye(13, 26, true); c:eye(19, 26, true)
c:paint({ "m...", ".mmm" }, 22, 32, { m = "#4a2c1a" })
local t = c:save(O .. "aseprite/ph/creature-dust-sidewinder.aseprite", O .. "png/ph/creature-dust-sidewinder.png")
print(GV.report(t))
