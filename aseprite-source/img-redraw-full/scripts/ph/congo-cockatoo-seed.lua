local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:rrect(14, 14, 50, 56, 2)
-- flap with a 3-step zigzag lower edge
local flap = c:poly({ {14, 14}, {51, 14}, {51, 24}, {45, 28}, {39, 24}, {33, 28}, {27, 24}, {21, 28}, {14, 24} })
local border = c:rrect(20, 31, 44, 51, 5)
local panel = border:shrink(2)
local seed = c:ellipse(32, 42, 7, 6.5)
local leaf = c:poly({ {34, 31}, {37, 28}, {41, 27}, {44, 28}, {41, 32}, {37, 33} })

local p = c:build{
  { "body", body, "cream" },
  { "flap", flap, GV.ramp("#f4f0e0"), { contact = true } },
  { "border", border, "moss", { gloss = false } },
  { "panel", panel, GV.ramp("#f4f0e0"), { gloss = false, contour = false } },
  { "seed", seed, "moss" },
}
-- sprout stem and leaf
c:fill(c:rect(31, 32, 32, 35), "#3f7a2e")
c:part(leaf, GV.ramp("#58a03e"), { flat = true })
c:px(38, 29, "#b8de8a"); c:px(39, 29, "#b8de8a")
-- seed line
c:paint({ "d..", ".d.", "..d" }, 34, 43, { d = "#2f5a2a" })
-- price dots
c:fill(c:rect(26, 53, 27, 54), "#8c4a1a")
c:fill(c:rect(31, 53, 32, 54), "#8c4a1a")
c:fill(c:rect(36, 53, 37, 54), "#8c4a1a")
-- fold seam and button
c:seam({ {16, 29}, {48, 29} })
c:button(30, 26)

local t = c:save(B .. "aseprite/ph/congo-cockatoo-seed.aseprite", B .. "png/ph/congo-cockatoo-seed.png")
print(GV.report(t))
