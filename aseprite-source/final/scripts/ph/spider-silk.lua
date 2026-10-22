local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local cream = GV.ramp("#f4f0e0")
local twist = GV.ramp("#d6c9b6")
local function ring(cx, cy, rx, ry, t)
  return c:ellipse(cx, cy, rx, ry):cut(c:ellipse(cx, cy, rx - t, ry - t))
end
-- loose wisps (behind loops)
local wispA = c:line({ { 21, 46 }, { 16, 50 }, { 12, 50 }, { 11, 47 }, { 13, 45 } }, 2)
local wispB = c:line({ { 43, 15 }, { 49, 12 }, { 53, 12 }, { 54, 15 } }, 2)
local upper = ring(32, 20, 15, 10, 5)
local lower = ring(32, 43, 15, 10, 5)
-- cross twist: two bands crossing at the waist
local x1 = c:line({ { 26, 26 }, { 38, 38 } }, 4)
local x2 = c:line({ { 38, 26 }, { 26, 38 } }, 4)
local tie = c:rrect(25, 29, 39, 35, 1)
c:build{
  { "wispA", wispA, twist, { flat = true } },
  { "wispB", wispB, twist, { flat = true } },
  { "upper", upper, cream, { stitch = { side = "lit" } } },
  { "lower", lower, cream, { stitch = { side = "lit" } } },
  { "x1", x1, twist, { gloss = false, cres = 2 } },
  { "x2", x2, twist, { gloss = false, cres = 2 } },
  { "tie", tie, "gold", { cres = 2, gloss = { 27, 30 } } },
}
-- binding wraps on the tie
c:paint({ "u.u.u.u.u.u.u" }, 26, 33, { u = "#b8661a" })
c:button(30, 30)
local t = c:save(O .. "aseprite/ph/spider-silk.aseprite", O .. "png/ph/spider-silk.png")
print(GV.report(t))
