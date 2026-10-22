local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local paper = GV.ramp("#f1ece0")
local body = c:rrect(15, 14, 48, 54, 2)
local flap = c:poly({ {15, 14}, {49, 14}, {32, 33} })
local label = c:rrect(22, 36, 41, 51, 3)

local p = c:build{
  { "body",  body,  paper },
  { "flap",  flap,  GV.ramp("#dcb06a"), { light = body } },
  { "label", label, GV.ramp("#f4f0e0"), { gloss = false } },
}
-- label border (moss rim)
local inner = label:shrink(2)
local ring = label:copy():cut(inner)
c:fill(ring, "#b0bc66")
-- nut
local nut = c:ellipse(31.5, 44.5, 5, 5.5)
c:part(nut, "moss", { gloss = { 29, 42 } })
local shell = c:ellipse(31.5, 40, 4, 2):clip(nut:copy():grow(1))
c:part(shell, GV.ramp("#dcb06a"), { flat = true })
c:fill(c:rect(31, 41, 32, 47), "#4a8a3e")
c:fill(c:rect(31, 41, 32, 41), "#2f5a2a")
-- seams along flap slants
c:seam({ {18, 16}, {31, 30} })
c:seam({ {46, 16}, {33, 30} })
c:button(30, 26)

local t = c:save(O .. "aseprite/ph/pistachio-seed.aseprite", O .. "png/ph/pistachio-seed.png")
print(GV.report(t))
