local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local h1 = c:line({ {36, 26}, {55, 15} }, 4)
local h2 = c:line({ {28, 40}, {53, 50} }, 4)
local tub = c:poly({ {6, 20}, {43, 20}, {34, 43}, {16, 43} })
local lip = c:rrect(5, 18, 44, 22, 1)
local wheel = c:ellipse(21, 47, 7, 7)
local hub = c:ellipse(21, 47, 2.5, 2.5)
local p = c:build{
  { "h1", h1, GV.ramp("#b07a45"), { gloss = false } },
  { "h2", h2, GV.ramp("#b07a45"), { gloss = false } },
  { "tub", tub, "gold", { gloss = { 13, 26 } } },
  { "lip", lip, GV.ramp("#f5cf6a"), { gloss = false } },
  { "wheel", wheel, GV.ramp("#5e2f1e", { base = "#4a2a1c", rim = "#8a4f2a" }), { gloss = false } },
  { "hub", hub, GV.ramp("#d0962a"), { flat = true } },
}
-- tyre tread ring
c:outline(c:mask())
for _, q in ipairs({ {21, 42}, {16, 47}, {26, 47}, {21, 52} }) do c:px(q[1], q[2], "#8a4f2a") end
-- brackets
c:fill(c:rect(36, 22, 38, 25), "#d0862a")
c:fill(c:rect(29, 38, 31, 41), "#d0862a")
-- rivets
c:px(10, 20, "#fff1c8"); c:px(38, 20, "#fff1c8")
c:px(20, 46, "#fff1c8")
c:ground(30, 56, 17, 2.5)
local t = c:save(D .. "img-redraw-full/aseprite/ph/masterwork-barrow.aseprite", D .. "img-redraw-full/png/ph/masterwork-barrow.png")
print(GV.report(t))
