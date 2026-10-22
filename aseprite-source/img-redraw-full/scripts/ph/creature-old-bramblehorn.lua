local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fur   = GV.ramp("#a5663a")
local cream = GV.ramp("#dcb06a")
local horn  = GV.ramp("#b6814d")
local hoof  = GV.ramp("#8c4a1a")
local band  = GV.ramp("#b07a10")

-- antlers: main beam plus two thorny forks each side
local antL = c:line({ {22, 22}, {20, 16}, {18, 11} }, 3)
antL:add(c:line({ {20, 16}, {14, 13} }, 2)):add(c:line({ {14, 13}, {13, 11} }, 2))
antL:add(c:line({ {21, 19}, {15, 19} }, 2)):add(c:line({ {15, 19}, {13, 17} }, 2))
local antR = c:mask()
antL:each(function(x, y) antR:set(63 - x, y) end)
local ant = antL:copy():add(antR)

local feet = c:ellipse(23.5, 50, 5, 2.5):add(c:ellipse(40.5, 50, 5, 2.5))
local ears = c:ellipse(20, 22, 4, 3.5):add(c:ellipse(44, 22, 4, 3.5))

local crown = c:poly({ {24, 18}, {24, 11}, {28, 15}, {32, 9}, {36, 15}, {40, 11}, {41, 11}, {41, 18} })

c:build{
  { "tail",   c:ellipse(47, 45, 3, 3), fur, { flat = true } },
  { "feet",   feet, hoof },
  { "antler", ant, horn },
  { "ears",   ears, fur },
  { "belly",  c:ellipse(32, 42, 15, 10), fur },
  { "patch",  c:ellipse(32, 45, 8, 6), cream, { gloss = false } },
  { "head",   c:ellipse(32, 28, 11, 11), fur },
  { "muzzle", c:ellipse(32, 34, 5, 4.5), cream, { gloss = false } },
  { "crown",  crown, "gold" },
  { "band",   c:rect(24, 17, 40, 19), band, { gloss = false } },
}
c:seam({ {25, 18}, {40, 18} })
c:spot(c:ellipse(32, 13, 1.5, 1.5), "#d6322b", "#ff9158")
c:eye(24, 23); c:eye(35, 23)
c:paint({ ".nnn.", "nnnnn", ".nnn." }, 30, 31, { n = "#2a1a10" })
c:px(31, 31, "#5e2a3a")
c:paint({ "m...m", ".mmm." }, 30, 35, { m = "#4a2c1a" })
c:ground(32, 51, 18, 1.5)
local t = c:save(O .. "aseprite/ph/creature-old-bramblehorn.aseprite", O .. "png/ph/creature-old-bramblehorn.png")
print(GV.report(t))
