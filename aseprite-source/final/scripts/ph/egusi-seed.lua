local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local cloth = GV.ramp("#f1ece0")
local ruff  = GV.ramp("#e6dcc4")
local seedR = GV.ramp("#dcb06a", { shade = "#a5663a" })
local leafR = GV.ramp("#58a03e")
local cord  = GV.ramp("#8a4f2a")

-- pouch body: round belly
local body = c:ellipse(31.5, 40, 16, 12)
-- ruffle: puffed scalloped top
local ruffle = c:rrect(20, 20, 43, 27, 3)
ruffle:add(c:ellipse(22, 21, 3, 3)):add(c:ellipse(28, 19, 3, 3)):add(c:ellipse(35, 19, 3, 3)):add(c:ellipse(41, 21, 3, 3))
local neck = c:rrect(24, 25, 39, 31, 2)

local p = c:build{
  { "seed",  c:ellipse(31.5, 16, 6, 4), seedR },
  { "body",  body, cloth, { light = body } },
  { "neck",  neck, cloth, { gloss = false } },
  { "ruffle", ruffle, ruff },
  { "patch", c:rrect(25, 35, 38, 47, 3), GV.ramp("#f4f0e0"), { gloss = false } },
}
-- sprout
c:part(c:line({ {32, 12}, {32, 10} }, 2), "#2e5a2c", { flat = true })
c:part(c:ellipse(36, 11, 3, 1.5), leafR, { flat = true })

-- ruffle fold lines
for _, x in ipairs({ 26, 32, 38 }) do
  c:fill(c:line({ {x, 19}, {x, 25} }, 1):clip(p.ruffle.m), "#b9a77f")
end
-- cord band with bow and tails
c:part(c:rect(22, 28, 41, 29), cord, { flat = true })
c:part(c:ellipse(28, 28.5, 2.5, 2), cord, { flat = true })
c:part(c:ellipse(36, 28.5, 2.5, 2), cord, { flat = true })
c:part(c:line({ {31, 30}, {28, 35} }, 2), cord, { flat = true })
c:part(c:line({ {33, 30}, {36, 34} }, 2), cord, { flat = true })
c:fill(c:rect(31, 28, 33, 30), cord.shade)

c:seam({ {20, 26}, {44, 26} })
c:stitch(p.patch.m)
c:ground(31.5, 53, 14, 1.5)
local t = c:save(O .. "aseprite/ph/egusi-seed.aseprite", O .. "png/ph/egusi-seed.png")
print(GV.report(t))
