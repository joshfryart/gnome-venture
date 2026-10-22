local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/"
local GV = dofile(D .. "gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-hybrid/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:rrect(13, 19, 51, 56, 2)
local flap = c:poly({ {16, 11}, {49, 11}, {52, 18}, {52, 21}, {13, 21}, {13, 18} })
local frame = c:rrect(18, 24, 46, 51, 5)
local win = c:rrect(20, 26, 44, 49, 4)
local bulb = c:ellipse(32, 41.5, 8, 6.5)
bulb:add(c:poly({ {29, 34}, {36, 34}, {33, 31}, {32, 31} }))
local stem = c:line({ {32, 27}, {32, 33} }, 2)
local leaf = c:poly({ {34, 31}, {38, 27}, {40, 27}, {40, 29}, {36, 32} })

c:build{
  { "body",  body,  "#f1ece0" },
  { "flap",  flap,  "#e6d6b4", { pale = true } },
  { "frame", frame, "moss" },
  { "win",   win,   "#f4f0e0", { light = frame, gloss = false } },
  { "stem",  stem,  GV.ramp("#2f5a2a"), { flat = true } },
  { "leaf",  leaf,  "leaf", { flat = true } },
  { "bulb",  bulb,  GV.ramp("#b0bc66") },
}
c:seam({ {14, 22}, {50, 22} })
c:button(30, 14)
for _, x in ipairs({ 25, 31, 37 }) do c:fill(c:rect(x, 53, x + 1, 54), "#8c4a1a") end
local t = c:save(O .. "aseprite/ph/bukhara-iris-seed.aseprite", O .. "png/ph/bukhara-iris-seed.png")
print(GV.report(t))
