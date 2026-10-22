local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- scallop fan: dome with hinge ears at the apex and a scalloped lower rim
local shell = c:ellipse(31.5, 44, 25, 27):cut(c:rect(-16, 48, 80, 80))
for _, x in ipairs({ 10, 17, 25, 31.5, 38, 46, 53 }) do
  shell:add(c:ellipse(x, 47, 3.5, 3))
end
shell:cut(c:rect(-16, 51, 80, 80))
shell:add(c:rrect(24, 16, 39, 22, 2))          -- hinge ears
local shellR = GV.ramp("#e6d2ae")

local mouthO = c:ellipse(31.5, 40, 21, 6)
local mouthI = c:ellipse(31.5, 41.5, 15.5, 4)

local p = c:build{
  { "shell", shell, shellR },
}
-- ribs radiating from the hinge
local rib = c:mask()
for _, x in ipairs({ 10, 17, 25, 38, 46, 53 }) do
  rib:add(c:line({ {31.5 + (x - 31.5) * 0.12, 22}, {x, 50} }, 2))
end
rib:add(c:line({ {31, 23}, {31, 33} }, 2))
rib:clip(shell:shrink(1))
rib:cut(c:ellipse(18, 30, 3, 2))               -- keep the gloss clear
c:fill(rib, "#a38f80")

local q = c:build{
  { "mouth", mouthO, GV.ramp("#d9667f") },
  { "maw",   mouthI, GV.ramp("#9c2a1e"), { gloss = false } },
}
-- four cream teeth, tips up from the lower lip of the maw
local T = { "....", ".tt.", "tttt", "tttt" }
local Tr = { ".t..", ".tt.", "ttt.", "tttt" }
for i, x in ipairs({ 21, 27, 33, 39 }) do
  c:paint({ ".tt.", ".tt.", "tttt", "tttt" }, x, 40 + ((i == 1 or i == 4) and 0 or 1), { t = "#fff3c8" })
end
c:seam({ {13, 37}, {20, 35}, {32, 34}, {43, 35}, {50, 37} })
c:eye(22, 26); c:eye(37, 26)
local t = c:save(O .. "aseprite/ph/creature-clam-lurker.aseprite", O .. "png/ph/creature-clam-lurker.png")
print(GV.report(t))
