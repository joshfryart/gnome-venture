local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- wide flat paper packet, triangle flap folded down over the front
local packet = c:rrect(13, 13, 51, 53, 2)
local flap = c:poly({ {13, 13}, {52, 13}, {32, 30} })
local label = c:rrect(20, 31, 44, 50, 3)
local corm = c:ellipse(32, 42, 5.5, 5):add(c:poly({ {27, 43}, {38, 43}, {32, 50} }))
local leafL = c:ellipse(28, 34.5, 3, 2)
local leafR = c:ellipse(36, 34.5, 3, 2)

local lav = GV.ramp("#c3b2ea")
c:build{
  { "packet", packet, "cream" },
  { "label", label, GV.ramp("#f4f0e0"), { gloss = false } },
  { "leafL", leafL, "moss", { flat = true } },
  { "leafR", leafR, "moss", { flat = true } },
  { "corm", corm, lav },
  { "flap", flap, "wood" },
}
-- lavender label border
c:fill(label:edge():cut(label:shrink(1):shrink(1):grow(0)), lav.base)
-- corm marks
c:fill(c:rect(29, 41, 30, 41), "#2a1a10")
c:fill(c:rect(34, 45, 35, 45), "#2a1a10")
c:px(32, 37, "#2f5a2a"); c:px(32, 38, "#2f5a2a")
c:seam({ {15, 14}, {32, 28}, {50, 14} }, { free = true })
c:button(30, 26)
local t = c:save(O .. "aseprite/ph/taro-seed.aseprite", O .. "png/ph/taro-seed.png")
print(GV.report(t))
