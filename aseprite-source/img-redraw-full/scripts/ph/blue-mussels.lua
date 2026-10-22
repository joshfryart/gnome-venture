local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- water family, dark end
local backR  = GV.ramp("#33477a")
local frontR = GV.ramp("#3f6fa8")

-- back shell: tapered wedge, hinge at left, rounded wide end up-right
local back = c:poly({ {10, 34}, {20, 24}, {34, 16}, {48, 13}, {54, 17}, {55, 25}, {50, 32}, {36, 36}, {20, 38}, {12, 38} })
back:add(c:ellipse(49, 21, 7, 7))
-- front shell: lower, longer, pointing right
local front = c:poly({ {11, 42}, {22, 36}, {38, 33}, {52, 34}, {56, 39}, {55, 46}, {50, 51}, {36, 53}, {22, 51}, {13, 47} })
front:add(c:ellipse(49.5, 43, 6.5, 7.5))
-- pale inner lip peeking between shells
local lip = c:poly({ {18, 39}, {30, 35}, {44, 33}, {54, 32}, {54, 35}, {44, 36}, {30, 38}, {20, 41} })

c:build{
  { "back",  back,  backR },
  { "lip",   lip,   "cream", { flat = true, contour = false, contact = false } },
  { "front", front, frontR, { gloss = { 26, 39 } } },
}

-- growth lines: concentric arcs following the wide ends
c:paint({ "..ll", ".l..", "l...", "l...", ".l.." }, 40, 16, { l = "#5a7cb8" })
c:paint({ "..ll", ".l..", "l...", "l...", "l...", ".l.." }, 34, 19, { l = "#5a7cb8" })
c:paint({ "..lll", ".l...", "l....", "l....", "l....", ".l...", "..l.." }, 42, 37, { l = "#2a3c6c" })
c:paint({ "..ll", ".l..", "l...", "l...", "l...", "l...", ".l.." }, 34, 39, { l = "#2a3c6c" })
c:paint({ ".l", "l.", "l.", "l.", "l.", ".l" }, 26, 41, { l = "#2a3c6c" })

-- hinge nub and beard threads
c:part(c:rrect(8, 36, 13, 42, 2), "#3a2a20", { gloss = false, cres = 1, deep = 0 })
c:paint({ "b..", ".b.", "..b" }, 9, 43, { b = "#8a4f2a" })
c:paint({ "b", "b", "b" }, 12, 43, { b = "#8a4f2a" })
c:paint({ "..b", ".b.", "b.." }, 13, 43, { b = "#8a4f2a" })

local t = c:save(D .. "img-redraw-full/aseprite/ph/blue-mussels.aseprite", D .. "img-redraw-full/png/ph/blue-mussels.png")
print(GV.report(t))
