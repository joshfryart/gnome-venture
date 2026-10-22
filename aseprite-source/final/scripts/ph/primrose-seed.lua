local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- sagging pouch body: wider at bottom
local body = c:ellipse(32, 41, 18, 14)
body:add(c:ellipse(32, 34, 13, 10))
-- pinched neck
local neck = c:poly({ {26, 14}, {38, 14}, {36, 26}, {28, 26} })
-- ruffle: three scallops
local ruff = c:ellipse(26, 13, 4, 3)
ruff:add(c:ellipse(32, 11, 4, 3.5))
ruff:add(c:ellipse(38, 13, 4, 3))
local linen = GV.ramp("#f1ece0")

local p = c:build{
  { "body", body, linen, { stitch = { side = "lit" } } },
  { "neck", neck, linen, { gloss = false } },
  { "ruff", ruff, linen, { gloss = false } },
}
-- fold lines on neck
c:fill(c:rect(29, 17, 29, 21), "#dcb06a")
c:fill(c:rect(32, 16, 32, 21), "#dcb06a")
c:fill(c:rect(35, 17, 35, 21), "#dcb06a")

-- drawstring band and bow
local orange = GV.ramp("#f08a24")
local cord = c:rect(24, 23, 40, 25)
local bowL = c:ellipse(27, 23, 3, 2.5):cut(c:ellipse(27, 23, 1, 0.5))
local bowR = c:ellipse(37, 23, 3, 2.5):cut(c:ellipse(37, 23, 1, 0.5))
local tails = c:line({ {30, 26}, {25, 32} }, 2)
tails:add(c:line({ {34, 26}, {39, 32} }, 2))
c:part(cord, orange, { flat = true })
c:part(tails, orange, { flat = true })
c:part(bowL, orange, { flat = true })
c:part(bowR, orange, { flat = true })
c:part(c:rrect(30, 21, 34, 26, 1), orange, { flat = true })

-- badge: orange berry with leaf
c:part(c:ellipse(32, 42, 7, 7), orange, { gloss = { 29, 39 } })
c:part(c:poly({ {32, 33}, {37, 33}, {36, 36}, {32, 36} }), "leaf", { flat = true })

-- seed dots
for _, x in ipairs({ 24, 31, 38 }) do
  c:fill(c:rrect(x, 50, x + 2, 52, 1), "#8c4a1a")
end

c:ground(32, 57, 17, 2.5)
local t = c:save(O .. "aseprite/ph/primrose-seed.aseprite", O .. "png/ph/primrose-seed.png")
print(GV.report(t))
