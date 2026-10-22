local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = c:rrect(17, 21, 47, 54, 8)
local honey = c:rrect(20, 28, 44, 52, 6)
local lid = c:rrect(14, 12, 50, 23, 4)
local label = c:rrect(23, 35, 41, 46, 2)
c:build{
  { "glass", glass, GV.ramp("#a9d6ea") },
  { "honey", honey, "gold", { light = glass, gloss = false } },
  { "lid", lid, GV.ramp("#d0862a"), { cres = 3 } },
  { "label", label, "cream", { gloss = false, cres = 2 } },
}
-- honey drip from under lid
c:paint({ "hh", "hh", "h." }, 37, 24, { h = "#e8a317" })
-- label squiggle
c:paint({ ".ww...ww...ww.", "w..w.w..w.w..w" }, 25, 39, { w = "#7a3a14" })
c:paint({ "...b...", "..bbb..", "...b..." }, 29, 41, { b = "#e8a317" })
-- lid ridges
for x = 18, 46, 4 do c:px(x, 15, GV.R.gold.rim) end
c:seam({ {16, 21}, {48, 21} })
c:button(30, 18)
-- glass gloss streak
c:paint({ "g", "g", "g", "g" }, 21, 29, { g = "#fff1c8" })
c:px(21, 35, "#fff1c8")
local t = c:save(B .. "aseprite/ph/garden-honey.aseprite", B .. "png/ph/garden-honey.png")
print(GV.report(t))
