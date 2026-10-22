local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local horn = GV.ramp("#a8582f")
local husk = GV.ramp("#f6b8cf")

-- small pincer horns tucked at the top (behind the shell)
local horns = c:line({ { 23, 21 }, { 19, 15 }, { 21, 11 }, { 27, 11 } }, 3)
horns:add(c:line({ { 40, 21 }, { 44, 15 }, { 42, 11 }, { 36, 11 } }, 3))

-- wide rounded shield tapering to a point at the bottom centre
local shell = c:ellipse(31.5, 31, 21, 13)
shell:add(c:poly({ { 11, 31 }, { 53, 31 }, { 51, 40 }, { 44, 48 }, { 32, 55 }, { 31, 55 }, { 19, 48 }, { 12, 40 } }))

local p = c:build{
  { "horns", horns, horn, { gloss = false } },
  { "shell", shell, husk, { gloss = { 20, 23 } } },
}

-- ribs fanning from one point at the bottom
local inner = shell:shrink(3)
local P = { 31.5, 50 }
local ribs = c:mask()
for _, e in ipairs({ { 22, 21 }, { 41, 21 }, { 15, 30 }, { 48, 30 } }) do
  ribs:add(c:line({ { 31, 49 }, e }, 2))
end
ribs:clip(inner)
c:fill(ribs, "#e46a9b")
-- centre seam
local seam = c:rect(31, 20, 32, 50):clip(inner)
c:fill(seam, "#b07a45")
c:seam({ { 32, 21 }, { 32, 49 } }, { free = true })
c:gloss(p.shell.m:copy():clip(c:rect(14, 18, 28, 30)), husk, { 20, 23 })

local t = c:save(O .. "aseprite/ph/stag-beetle-shell.aseprite", O .. "png/ph/stag-beetle-shell.png")
print(GV.report(t))
