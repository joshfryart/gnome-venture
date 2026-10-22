local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tall narrow envelope
local env = c:rrect(19, 9, 45, 56, 1)
local flap = c:poly({ {19, 9}, {46, 9}, {32.5, 27} })
local root = c:poly({ {25, 33}, {40, 33}, {37, 48}, {33, 55}, {29, 48} })

local p = c:build{
  { "env", env, "#f1ece0" },
  { "flap", flap, "#dcb06a", { gloss = { 23, 11 } } },
}
c:seam({ {21, 11}, {32, 25} }); c:seam({ {44, 11}, {33, 25} })

-- shoots behind the root
c:fill(c:ellipse(28, 29, 3, 1.5), "#58a03e")
c:fill(c:ellipse(37, 29, 3, 1.5), "#58a03e")
c:px(26, 28, "#a4d070"); c:px(35, 28, "#a4d070")
c:fill(c:line({ {31, 31}, {29, 29} }, 1), "#3e7a2e")
c:fill(c:line({ {34, 31}, {36, 29} }, 1), "#3e7a2e")
c:part(root, "gold", { cres = 3, deep = 1 })
-- rings across the rhizome
c:fill(c:rect(27, 38, 37, 38):clip(root), "#f08a24")
c:fill(c:rect(29, 44, 36, 44):clip(root), "#f08a24")
c:fill(c:rect(31, 49, 35, 49):clip(root), "#f08a24")

-- wax seal on the flap tip
c:part(c:ellipse(32.5, 26, 3.5, 3.5), "#d6322b", { gloss = false })
c:px(31, 25, "#ff9158")

c:ground(32, 57, 14, 1.5)
local t = c:save(O .. "aseprite/ph/turmeric-seed.aseprite", O .. "png/ph/turmeric-seed.png")
print(GV.report(t))
