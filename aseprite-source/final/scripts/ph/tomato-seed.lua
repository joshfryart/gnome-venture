local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local ring = c:rrect(17, 46, 46, 52, 2)
local pot  = c:rrect(12, 22, 51, 49, 11)
local tom  = c:ellipse(31.5, 39, 8.5, 8)
local calyx = c:ascii({
  "...xx...",
  "x..xx..x",
  "xxxxxxxx",
  ".xxxxxx.",
  "xx....xx",
}, 28, 28)
local lid  = c:ellipse(31.5, 20, 18, 6)
local knob = c:rrect(28, 11, 35, 16, 2)

c:build{
  { "ring",  ring,  "#d9a660", { gloss = false } },
  { "pot",   pot,   "#f1ece0" },
  { "tom",   tom,   GV.ramp("#d6322b", { shade = "#ae2a2a" }) },
  { "calyx", calyx, "#4a8a3e", { flat = true } },
  { "lid",   lid,   "#b07a45" },
  { "knob",  knob,  "#7a3a14" },
}
c:seam({ {16, 27}, {47, 27} })

local t = c:save(O .. "aseprite/ph/tomato-seed.aseprite", O .. "png/ph/tomato-seed.png")
print(GV.report(t))
