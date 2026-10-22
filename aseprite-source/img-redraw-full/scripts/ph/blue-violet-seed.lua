local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local cloth = GV.ramp("#f1ece0", { shade = "#dcb06a" })

-- round-bellied pouch
local body = c:ellipse(32, 41, 19, 15)
body:add(c:rrect(20, 22, 44, 36, 6))

-- gathered ruffled neck: a fan of scallops
local neck = c:poly({ {24,21},{40,21},{45,11},{19,11} })
for _, x in ipairs({ 19, 26, 33, 40 }) do neck:add(c:ellipse(x + 2.5, 11, 3.5, 2.5)) end

-- cord tails hanging out of the cinch
local cordL = c:line({ {23,20},{19,24},{17,28} }, 2)
local cordR = c:line({ {41,20},{45,24},{47,28} }, 2)

local p = c:build{
  { "body", body, cloth, { stitch = { side = "lit" } } },
  { "neck", neck, cloth },
  { "cordL", cordL, GV.ramp("#dcb06a"), { flat = true } },
  { "cordR", cordR, GV.ramp("#dcb06a"), { flat = true } },
}

-- ruffle folds
for _, x in ipairs({ 24, 30, 36, 41 }) do c:fill(c:line({ {x,14},{x,18} }, 1), "#dcb06a") end
-- cord knots
c:fill(c:rect(16, 28, 18, 30), "#a5663a"); c:fill(c:rect(46, 28, 48, 30), "#a5663a")

-- drawstring cinch band with seam
c:fill(c:rect(21, 20, 43, 21), "#dcb06a")
c:seam({ {22,20}, {42,20} }, { free = true })

-- patch window
local win = c:rrect(21, 26, 43, 50, 6)
c:part(win, GV.ramp("#f4f0e0", { rim = "#dcb06a" }), { gloss = false, contact = false })

-- seed
local seed = c:ellipse(32, 41, 6, 6)
c:part(seed, GV.ramp("#dcb06a", { shade = "#a5663a" }), { gloss = { 29, 38 } })
-- sprout
c:fill(c:line({ {32,30},{32,35} }, 2), "#2e5a2c")
c:fill(c:ellipse(36, 30, 2.5, 1.5), "#58a03e")
c:fill(c:ellipse(28.5, 31, 2, 1.2), "#58a03e")

-- hem dots
for _, x in ipairs({ 25, 31, 37 }) do c:fill(c:rect(x, 52, x + 2, 54), "#8c4a1a") end

c:button(30, 12)
c:ground(32, 57, 14, 1.5)
local t = c:save(O .. "aseprite/ph/blue-violet-seed.aseprite", O .. "png/ph/blue-violet-seed.png")
print(GV.report(t))
