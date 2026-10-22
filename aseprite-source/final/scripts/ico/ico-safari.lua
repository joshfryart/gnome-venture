local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local grey = GV.ramp("#968f96")
local legsB = c:rrect(13, 38, 21, 53, 2):add(c:rrect(35, 38, 42, 52, 2))
local legsF = c:rrect(8, 38, 16, 54, 2):add(c:rrect(29, 38, 37, 54, 2))
local body = c:ellipse(28, 33, 21, 14)
local head = c:ellipse(43, 24, 11, 11)
local trunk = c:line({ { 50, 30 }, { 53, 36 }, { 54, 43 }, { 53, 48 } }, 6)
trunk:add(c:ellipse(50, 49, 3, 2.5))
local ear = c:ellipse(34, 25, 7, 10)
local whole = body:copy():add(head):add(trunk)
c:build{
  { "legsB", legsB, GV.ramp("#7f7880") },
  { "body", body, grey, { light = whole } },
  { "legsF", legsF, grey },
  { "head", head, grey, { light = whole } },
  { "trunk", trunk, grey, { light = whole, gloss = false } },
  { "ear", ear, "cream", { contour = "#4a2c1a" } },
}
-- tusk
c:fill(c:poly{ { 47, 32 }, { 50, 32 }, { 47, 37 } }, "#fff3c8")
c:px(47, 36, "#f5b860"); c:px(48, 35, "#f5b860")
-- ear inner fold
c:paint({ ".ff", "f..", "f..", "f..", ".f." }, 35, 21, { f = "#e8c89a" })
-- trunk wrinkles
c:paint({ "ww" }, 51, 39, { w = grey.shade }); c:paint({ "ww" }, 51, 43, { w = grey.shade })
-- toes
for _, x in ipairs({ 9, 12, 30, 33 }) do c:px(x, 52, "#fff3c8") end
c:eye(43, 18)
local t = c:save(O .. "aseprite/ico/ico-safari.aseprite", O .. "png/ico/ico-safari.png")
print(GV.report(t))
