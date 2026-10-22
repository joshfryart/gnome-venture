local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local Y = -3
local wood = GV.ramp("#b07a10")
-- handle: left half intact up to the crown, right half snapped and drooping
local hl = c:line({ { 16, 34 }, { 18, 26 }, { 23, 21 }, { 29, 18 } }, 4)
local hr = c:line({ { 50, 34 }, { 49, 28 }, { 46, 24 } }, 4)
local body = c:poly({ { 11, 32 }, { 54, 32 }, { 50, 56 }, { 16, 56 } })
-- chipped top-right corner of the rim
body:cut(c:poly({ { 47, 32 }, { 55, 32 }, { 55, 37 } }))
local chip = c:poly({ { 37, 20 }, { 42, 18 }, { 44, 22 }, { 39, 24 } })
local p = c:build{
  { "handleL", hl, wood },
  { "handleR", hr, wood },
  { "chip", chip, wood, { flat = true } },
  { "body", body, wood },
}
-- gold slat bands
local b1 = c:rect(14, 39, 50, 40)
local b2 = c:rect(15, 47, 49, 48)
c:fill(b1:clip(p.body.m), "#f5cf6a"); c:fill(b2:clip(p.body.m), "#f5cf6a")
for x = 14, 50 do if p.body.m:has(x, 40) then c:px(x, 40, "#e8a317") end end
for x = 15, 49 do if p.body.m:has(x, 48) then c:px(x, 48, "#e8a317") end end
-- splintered slat ends
c:paint({ "g.", ".g" }, 49, 49, { g = "#f5cf6a" })
-- rim lip line
for x = 12, 49 do if p.body.m:has(x, 34) then c:px(x, 34, wood.shade) end end
-- rivets on handle feet
c:part(c:ellipse(18, 35.5, 2, 2), "#8c4a1a", { flat = true })
c:part(c:ellipse(48, 35.5, 2, 2), "#8c4a1a", { flat = true })
-- jagged crack through the basket
c:paint({
  "k.",
  "kk",
  ".k",
  ".k",
  "kk",
  "k.",
  "kk",
  ".k",
  ".kk",
  "..k",
  ".kk",
  ".k.",
  "kk.",
  "k..",
}, 31, 35, { k = "#2a1a10" })
-- splinters at the snapped crown
c:px(30, 17, wood.base); c:px(31, 19, wood.shade)
c:px(45, 22, wood.base)
local t = c:save(O .. "aseprite/ph/broken-harvest-trug.aseprite", O .. "png/ph/broken-harvest-trug.png")
print(GV.report(t))
