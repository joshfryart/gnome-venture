local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local rim = c:poly({ {16, 12}, {49, 12}, {53, 16}, {53, 21}, {11, 21}, {11, 16} })
local p = c:build{
  { "body", c:rrect(13, 19, 51, 56, 3), "wood" },
  { "rim", rim, "#d9a660" },
}
-- plank lines on the body (outside the label)
local planks = c:rect(15, 31, 49, 32):add(c:rect(15, 44, 49, 45))
c:fill(planks, "#8a4f2a")
local lab = c:part(c:rrect(19, 24, 45, 50, 6), GV.ramp("#f4f0e0"), { gloss = { 22, 27 } })
c:fill(c:rrect(19, 24, 45, 50, 6):edge(), "#b0bc66")
c:part(c:ellipse(32, 40, 7, 7), GV.ramp("#b0bc66", { shade = "#58a03e" }))
c:fill(c:line({ {32, 33}, {32, 29} }, 2), "#2e5a2c")
c:paint({
  "..LLL",
  ".LLLLL",
  "LLLLLL",
  "LLLLL.",
  ".LL...",
}, 34, 26, { L = "#58a03e" })
c:px(36, 27, "#8fcf5e"); c:px(35, 28, "#8fcf5e")
for _, x in ipairs({ 24, 31, 38 }) do c:fill(c:rect(x, 52, x + 1, 53), "#8c4a1a") end
c:seam({ {15, 20}, {49, 20} })
local t = c:save(O .. "aseprite/ph/beach-hibiscus-seed.aseprite", O .. "png/ph/beach-hibiscus-seed.png")
print(GV.report(t))
