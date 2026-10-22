local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- small squat crate (wider than tall)
local box = c:rect(10, 22, 53, 54)
local slatT = c:rect(16, 22, 47, 32)
local slatM = c:rect(16, 33, 47, 43)
local slatB = c:rect(16, 44, 47, 54)
local postL = c:rect(10, 18, 16, 55)
local postR = c:rect(47, 18, 53, 55)
local rim = c:rect(14, 16, 49, 22)
local hole = c:rect(17, 18, 46, 20)

local p = c:build{
  { "slatT", slatT, "wood", { light = box, gloss = false } },
  { "slatM", slatM, "wood", { light = box, gloss = false } },
  { "slatB", slatB, "wood", { light = box, gloss = false } },
  { "rim", rim, GV.ramp("#d9a660"), { gloss = false } },
  { "postL", postL, GV.ramp("#a8582f"), { light = box } },
  { "postR", postR, GV.ramp("#a8582f"), { light = box, gloss = false } },
}
c:fill(hole, "#5e2f1e")
c:fill(c:rect(17, 18, 46, 18), "#3d1e14")

-- label
local label = c:rrect(21, 27, 42, 50, 3)
c:part(label, GV.ramp("#f1ece0"), { cres = 2, deep = 1, gloss = false })
-- kale leaf (frilly teardrop)
local leaf = c:ellipse(31.5, 39, 6, 8):add(c:ellipse(31.5, 33, 3, 3))
leaf:add(c:ellipse(26, 37, 1.5, 1.5)):add(c:ellipse(37, 37, 1.5, 1.5))
leaf:add(c:ellipse(26, 42, 1.5, 1.5)):add(c:ellipse(37, 42, 1.5, 1.5))
c:part(leaf, GV.ramp("#5a9e44"), { cres = 2, deep = 1, gloss = { 28, 35 } })
c:fill(c:rect(31, 32, 32, 48), "#2e5a2c")
c:paint({ "v....v", ".v..v.", "..vv.." }, 29 - 1, 36, { v = "#2e5a2c" })
c:paint({ "v....v", ".v..v.", "..vv.." }, 29 - 1, 41, { v = "#2e5a2c" })
-- nails
for _, xy in ipairs({ {13, 25}, {50, 25}, {13, 50}, {50, 50} }) do c:px(xy[1], xy[2], "#5e2f1e") end

local t = c:save(O .. "aseprite/ph/kale-seed.aseprite", O .. "png/ph/kale-seed.png")
print(GV.report(t))
