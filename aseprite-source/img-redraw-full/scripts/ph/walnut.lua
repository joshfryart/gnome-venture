local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local shell = c:ellipse(31.5, 37, 16, 16)
shell:add(c:ellipse(31.5, 47, 13, 6))
local cap = shell:copy():clip(c:ellipse(31.5, 22, 18, 9))
local stem = c:rrect(30, 12, 33, 20, 1)
local p = c:build{
  { "stem",  stem,  GV.ramp("#4a8a3e"), { flat = true } },
  { "shell", shell, GV.ramp("#a5663a"), { gloss = { 22, 34 } } },
  { "cap",   cap,   GV.ramp("#8c4a1a"), { light = shell, gloss = false } },
}
-- ridge grooves
local R = "#5e2f1e"
c:paint({ "r", "r", "r", "r", "r", "r" }, 25, 34, { r = R })
c:paint({ "r", "r", "r", "r", "r", "r", "r" }, 38, 33, { r = R })
c:paint({ "r", "r", "r", "r" }, 31, 32, { r = R })
c:paint({ "r", "r", "r", "r" }, 20, 39, { r = R })
c:paint({ "r", "r", "r", "r" }, 43, 39, { r = R })
-- smile seam
local S = "#2a1a10"
c:paint({
  "ss..........ss",
  ".sss......sss.",
  "...ssssssss...",
}, 25, 43, { s = S })
c:ground(31.5, 57, 16, 2, "#6a4528")
local t = c:save(O .. "aseprite/ph/walnut.aseprite", O .. "png/ph/walnut.png")
print(GV.report(t))
