local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local stem = c:line({ {31, 22}, {31, 13} }, 3)
-- long narrow leaf angled up-right
local leaf = c:poly({ {32, 16}, {37, 10}, {44, 6}, {52, 5}, {49, 10}, {43, 15}, {35, 18} })
local fruit = c:ellipse(31.5, 38, 14, 16)
local pim = c:ellipse(32.5, 50.5, 3.5, 2.5)

c:build{
  { "stem",  stem,  GV.ramp("#2f5a2a"), { flat = true } },
  { "leaf",  leaf,  GV.ramp("#6a9a3a") },
  { "fruit", fruit, "moss" },
  { "pim",   pim,   "red", { gloss = false } },
}
-- vein down the leaf
c:paint({ ".....vv", "..vvv..", "vv....." }, 37, 9, { v = "#4a8a3e" })

local t = c:save(O .. "aseprite/ph/olive.aseprite", O .. "png/ph/olive.png")
print(GV.report(t))
