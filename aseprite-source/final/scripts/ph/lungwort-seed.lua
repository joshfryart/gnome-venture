local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:rrect(19, 10, 44, 56, 3)
local flap = c:poly({ {19, 10}, {45, 10}, {32, 25} })
local ring = c:rrect(22, 29, 41, 50, 6)
local win  = c:rrect(24, 31, 39, 48, 4)
local seed = c:ellipse(31.5, 41, 6, 6)
local leaf = c:ellipse(36, 30, 3, 2):add(c:rect(34, 29, 36, 31))
local p = c:build{
  { "body", body, GV.ramp("#f1ece0") },
  { "flap", flap, GV.ramp("#e6dcc4"), { gloss = false } },
  { "ring", ring, GV.ramp("#7a5cc0"), { gloss = false, cres = 2, deep = 1 } },
  { "win",  win,  GV.ramp("#f4f0e0"), { gloss = false, cres = 2, deep = 1 } },
  { "seed", seed, GV.ramp("#7a5cc0", { rim = "#7b66b4", shade = "#4e3a8a" }) },
  { "stem", c:rect(31, 31, 32, 35), "#2e5a2c", { flat = true } },
  { "leaf", leaf, "#58a03e", { flat = true } },
}
c:seam({ {20, 11}, {32, 24}, {44, 11} })
c:button(30, 21)
for _, x in ipairs({ 25, 31, 37 }) do c:fill(c:rect(x, 52, x + 1, 53), "#8c4a1a") end
c:ground(31.5, 57, 12, 1.5)
local t = c:save(O .. "aseprite/ph/lungwort-seed.aseprite", O .. "png/ph/lungwort-seed.png")
print(GV.report(t))
