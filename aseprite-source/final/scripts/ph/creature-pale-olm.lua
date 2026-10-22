local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pale = GV.ramp("#e8d8d0")
local rose = GV.ramp("#c98f8f")
-- legs: short bent stubs
local legs = c:line({ {16, 37}, {15, 41}, {13, 42} }, 3)
legs:add(c:line({ {24, 38}, {23, 42}, {21, 43} }, 3))
legs:add(c:line({ {35, 37}, {36, 41}, {38, 42} }, 3))
legs:add(c:line({ {42, 35}, {44, 39}, {46, 40} }, 3))
-- wavy eel body: tail tip curls up at left, dips, rises to the head
local body = c:ellipse(14.5, 33, 3, 2)
body:add(c:ellipse(20, 35, 6, 3))
body:add(c:ellipse(28, 35, 7, 4))
body:add(c:ellipse(37, 33, 7, 4.5))
body:add(c:ellipse(43, 31, 5, 4))
local head = c:ellipse(47.5, 29, 6, 5)
-- gills: three fronds fanning out behind the head
local gills = c:line({ {50, 25}, {53, 22}, {54, 20} }, 2)
gills:add(c:line({ {52, 28}, {55, 27}, {56, 26} }, 2))
gills:add(c:line({ {51, 31}, {54, 33}, {55, 34} }, 2))
local p = c:build{
  { "legs", legs, pale, { flat = true } },
  { "body", body, pale, { pale = true, light = body:copy():add(head) } },
  { "gills", gills, rose, { flat = true } },
  { "head", head, pale, { pale = true, gloss = { 45, 26 } } },
}
-- gill frond tips: little feathery nubs
c:paint({ "r.r" }, 53, 20, { r = "#c98f8f" })
c:px(57, 26, "#c98f8f"); c:px(56, 35, "#c98f8f")
-- back highlight and violet flank stripe
c:line({ {16, 33}, {26, 32}, {36, 30} }, 1)
for _, q in ipairs({ {17,33},{19,33},{21,32},{23,32},{25,32},{29,31},{31,31},{33,30} }) do c:px(q[1], q[2], "#f7efe9") end
for x = 22, 31 do if x % 3 ~= 0 then c:px(x, 35, "#8f7fc9") end end
-- tiny blind eye
c:eye(47, 27, true)
c:px(52, 31, GV.C.umber)
c:ground(30, 45, 18, 1.5)
local t = c:save(O .. "aseprite/ph/creature-pale-olm.aseprite", O .. "png/ph/creature-pale-olm.png")
print(GV.report(t))
