local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cream = GV.ramp("#f1ece0")
local tan = GV.ramp("#d6cdb6")
local horn = GV.ramp("#8c7a55")
local leg = GV.ramp("#6b5a3a")
local legs = c:mask()
for _, x in ipairs({ 14, 21, 35, 42 }) do legs:add(c:rrect(x, 42, x + 3, 54, 1)) end
local head = c:ellipse(47.5, 27, 7.5, 7):add(c:rrect(48, 25, 57, 34, 3))
local hornL = c:line({ {44, 21}, {43, 16}, {41, 12}, {38, 11}, {36, 13} }, 3)
local hornR = c:line({ {49, 20}, {50, 15}, {48, 12}, {46, 11} }, 3)
local P = c:build{
  { "legs",  legs, leg, { cres = 2 } },
  { "tail",  c:ellipse(11, 28, 3, 2.5), tan, { flat = true } },
  { "body",  c:ellipse(29.5, 36, 18, 10.5), cream },
  { "hornL", hornL, horn, { flat = true } },
  { "head",  head, cream },
  { "hornR", hornR, horn, { flat = true } },
  { "ear",   c:poly({ {45, 24}, {41, 25}, {36, 28}, {41, 29}, {46, 28} }), tan, { flat = true } },
  { "beard", c:poly({ {51, 34}, {56, 34}, {55, 39}, {53, 42}, {52, 39} }), tan, { flat = true } },
}
c:fill(c:rect(14, 44, 46, 45):clip(P.body.m), GV.R.cream and tan.shade or "#c8bd9f")
c:paint({ "nn" }, 56, 28, { n = "#8a4234" })
c:eye(49, 24, true)
c:ground(30, 55, 19, 1.5)
local t = c:save(O .. "aseprite/animals/goat.aseprite", O .. "png/animals/goat.png")
print(GV.report(t))
