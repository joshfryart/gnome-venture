local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local cloth = GV.ramp("#f1ece0")
local body = c:ellipse(31.5, 40, 18, 15)
local top = c:ellipse(25, 17, 6, 6):add(c:ellipse(38, 17, 6, 6)):add(c:ellipse(31.5, 14, 4, 4))
top:add(c:poly({ {22, 19}, {42, 19}, {37, 27}, {27, 27} }))
local neck = c:rrect(25, 23, 38, 29, 2)

local p = c:build{
  { "body", body, cloth, { stitch = { side = "lit" } } },
  { "top",  top,  cloth },
  { "neck", neck, GV.ramp("#dcb06a") },
}
-- string wraps
local str = GV.ramp("#b07a45")
c:fill(c:rect(25, 24, 38, 25), str.base)
c:fill(c:rect(25, 27, 38, 28), str.base)
c:fill(c:rect(25, 25, 38, 25), str.shade)
c:fill(c:rect(25, 28, 38, 28), str.shade)
-- bow loops
c:part(c:ellipse(28, 23, 3, 2):cut(c:ellipse(28, 23, 1, 0.5)), str, { flat = true })
c:part(c:ellipse(35, 23, 3, 2):cut(c:ellipse(35, 23, 1, 0.5)), str, { flat = true })
c:part(c:rect(30, 22, 33, 25), str, { flat = true })
-- tails
c:part(c:line({ {29, 26}, {26, 34} }, 2), str, { flat = true })
c:part(c:line({ {34, 26}, {38, 34} }, 2), str, { flat = true })

-- pineapple motif
local pine = c:ellipse(31.5, 43, 6, 7)
local pp = c:part(pine, "gold", { gloss = false, contact = false })
for y = 37, 50 do for x = 25, 38 do
  if pine:has(x, y) and ((x + y) % 4 == 0 or (x - y) % 4 == 0) and not (x <= 28 and y <= 39) then
    c:px(x, y, GV.R.gold.shade)
  end
end end
local crown = c:line({ {28, 37}, {27, 33} }, 2):add(c:line({ {31, 36}, {31, 31} }, 2)):add(c:line({ {35, 37}, {36, 33} }, 2))
c:part(crown, "moss", { flat = true })

local t = c:save(O .. "aseprite/ph/pineapple-seed.aseprite", O .. "png/ph/pineapple-seed.png")
print(GV.report(t))
