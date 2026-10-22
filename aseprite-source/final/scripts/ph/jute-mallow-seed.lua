local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tall narrow envelope
local body = c:rrect(17, 8, 46, 55, 3)
local flap = c:poly({ {17, 8}, {47, 8}, {32, 25} })
local win = c:rrect(22, 29, 41, 50, 5)
local seed = c:ellipse(31.5, 41.5, 6, 6)

c:build{
  { "body", body, GV.ramp("#f1ece0") },
  { "flap", flap, GV.ramp("#dcb06a"), { cres = 2, deep = 1 } },
  { "win", win, GV.ramp("#e8d9a8"), { cres = 2, deep = 1, gloss = false } },
  { "seed", seed, GV.ramp("#c98f4a", { shade = "#a5663a" }) },
}
-- seed dimple
c:paint({ ".s.", "s.." }, 29, 39, { s = "#a5663a" })
-- sprout: stem + leaf
c:fill(c:rect(31, 31, 32, 35), "#2e5a2c")
local leaf = c:poly({ {33, 32}, {36, 28}, {40, 27}, {39, 30}, {35, 33} })
c:fill(leaf, "#58a03e")
c:px(36, 29, "#8cc860"); c:px(37, 28, "#8cc860")
c:fill(c:poly({ {31, 32}, {28, 29}, {26, 29}, {27, 31}, {30, 33} }), "#4a8a3e")
-- seam along flap fold
c:seam({ {18, 10}, {32, 24}, {46, 10} })
c:button(30, 22)
-- tally dots
for _, x in ipairs({ 25, 31, 37 }) do c:fill(c:rect(x, 52, x + 1, 53), "#8c4a1a") end

local t = c:save(O .. "aseprite/ph/jute-mallow-seed.aseprite", O .. "png/ph/jute-mallow-seed.png")
print(GV.report(t))
