local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 48, h = 48, mode = "sticker" }

-- tent: pointed triangle, lit left half, shaded right half
local tent = c:poly({ {16.5, 9}, {8, 38}, {26, 38} })
local tentL = tent:copy():clip(c:rect(0, 0, 16, 47))
local tentR = tent:copy():cut(c:rect(0, 0, 16, 47))
local door  = c:poly({ {16.5, 18}, {13, 38}, {21, 38} })
local pole  = c:rect(16, 11, 17, 37)

-- campfire: teardrop flame on crossed logs
local flame = c:ellipse(31.5, 28, 4.5, 5):add(c:poly({ {31.5, 14}, {27, 28}, {37, 28} }))
local inner = c:ellipse(31.5, 30, 2, 3):add(c:poly({ {31.5, 21}, {29, 30}, {34.5, 30} }))
local log1 = c:line({ {25, 36}, {36, 33} }, 3)
local log2 = c:line({ {25, 33}, {36, 36} }, 3)

local soilL = GV.ramp("#c9a96e")
local soilR = GV.ramp("#9a6b3f")
local p = c:build{
  { "tentL", tentL, soilL, { light = tent, stitch = { side = "lit" } } },
  { "tentR", tentR, soilR, { light = tent, contour = false, gloss = false } },
  { "door",  door,  GV.ramp("#3d2a1c"), { flat = true, gloss = false } },
  { "pole",  pole,  "wood", { flat = true } },
  { "flame", flame, GV.ramp("#e0501f") },
  { "inner", inner, GV.ramp("#f08a24"), { flat = true, contour = false, contact = false } },
  { "log2",  log2,  "wood", { flat = true } },
  { "log1",  log1,  "wood", { flat = true } },
}
c:seam({ {15, 13}, {9, 36} })
c:button(15, 8)
-- tiny glow core in the flame
c:paint({ ".y.", "yyy" }, 30, 28, { y = "#f5cf6a" })

local t = c:save(D .. "img-redraw-hybrid/aseprite/stops/camp.aseprite", D .. "img-redraw-hybrid/png/stops/camp.png")
print(GV.report(t))
