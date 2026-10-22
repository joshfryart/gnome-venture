local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local metal = GV.R.stone
local handle = c:rrect(28, 33, 35, 57, 3)
local head = c:line({ {18, 24}, {22, 30}, {28, 33}, {35, 33}, {41, 30}, {45, 24} }, 5)
local tl = c:line({ {18, 8}, {18, 25} }, 5)
local tm = c:line({ {31, 7}, {31, 32} }, 5)
-- snapped right tine: jagged top with notch
local tr = c:rect(43, 16, 47, 26)
tr:del(45, 16); tr:del(45, 17); tr:del(46, 16); tr:del(43, 16)
local loose = c:line({ {50, 47}, {55, 51} }, 4)

local p = c:build{
  { "handle", handle, "#b6814d" },
  { "head",   head,   "#b07a45", { light = head:copy():add(tl):add(tm):add(tr) } },
  { "tl",     tl,     "#b07a45", { cres = 2, deep = 1 } },
  { "tm",     tm,     "#b07a45", { cres = 2, deep = 1 } },
  { "tr",     tr,     "#b07a45", { cres = 2, deep = 1, gloss = false } },
  { "loose",  loose,  "#b07a45", { gloss = false, cres = 1 } },
}
-- tine points
-- crack zigzag over middle tine and shaft
c:paint({ "k.", "k.", ".k", ".k", "k.", "k." }, 31, 14, { k = "#2a1a10" })
c:paint({ ".k", "k.", "k.", ".k", ".k" }, 30, 34, { k = "#2a1a10" })
c:px(32, 39, "#2a1a10"); c:px(31, 40, "#2a1a10"); c:px(31, 41, "#2a1a10")
-- splinter edge on stub
c:px(44, 17, "#8a4f2a"); c:px(46, 17, "#8a4f2a")
c:ground(32, 58, 9, 1.5)

local t = c:save(O .. "aseprite/ph/broken-garden-fork.aseprite", O .. "png/ph/broken-garden-fork.png")
print(GV.report(t))
