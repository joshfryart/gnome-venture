local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local leaf = c:poly({ {33, 13}, {36, 7}, {43, 5}, {44, 7}, {40, 12}, {34, 14} })
local stem = c:rect(31, 7, 32, 13)
local fruit = c:ellipse(31.5, 23, 11, 10.5)
local crate = c:rect(12, 30, 51, 55)
local postL = c:rect(12, 30, 16, 55)
local postR = c:rect(47, 30, 51, 55)

local p = c:build{
  { "stem", stem, "#2e5a2c", { flat = true } },
  { "leaf", leaf, "#58a03e", { gloss = false } },
  { "fruit", fruit, "#e46a9b" },
  { "crate", crate, "wood", { gloss = false, light = crate } },
  { "postL", postL, GV.ramp("#a8582f"), { gloss = false } },
  { "postR", postR, GV.ramp("#a8582f"), { gloss = false } },
}
-- plank lines
c:fill(c:rect(17, 38, 46, 39), "#8a4f2a")
c:fill(c:rect(17, 46, 46, 47), "#8a4f2a")
c:fill(c:rect(17, 40, 46, 40), "#d9a660")
c:fill(c:rect(17, 48, 46, 48), "#d9a660")
-- green scale tips on fruit
local tip = { ".gg", "gg." }
c:paint(tip, 23, 18, { g = "#58a03e" })
c:paint({ "gg.", ".gg" }, 37, 16, { g = "#58a03e" })
c:paint(tip, 33, 25, { g = "#58a03e" })
c:paint({ "gg.", ".gg" }, 25, 26, { g = "#58a03e" })
-- nails
for _, n in ipairs({ {13, 33}, {48, 33}, {13, 51}, {48, 51} }) do
  c:fill(c:rect(n[1], n[2], n[1] + 1, n[2] + 1), "#5e2f1e")
  c:px(n[1], n[2], "#d9a660")
end
c:ground(31.5, 57, 20, 1.5)
local t = c:save(O .. "aseprite/ph/dragon-fruit-seed.aseprite", O .. "png/ph/dragon-fruit-seed.png")
print(GV.report(t))
