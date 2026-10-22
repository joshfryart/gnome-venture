local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local cx = 39.5
local SC = "#6b3a22"
-- shell dome
local shell = c:ellipse(cx, 51, 30, 35):cut(c:rect(0, 52, 79, 99))
local ps = c:part(shell, GV.ramp("#a5663a"), { stitch = { side = "lit" } })
-- scute lines (clipped to shell, inset from its edge)
local inner = shell:shrink(2)
local L = c:line({ {39, 17}, {39, 51} }, 2)
L:add(c:line({ {22, 26}, {27, 51} }, 2))
L:add(c:line({ {57, 26}, {52, 51} }, 2))
L:add(c:line({ {12, 44}, {20, 40}, {30, 38}, {49, 38}, {59, 40}, {67, 44} }, 2))
c:fill(L:clip(inner), SC)
-- vest body
local vest = c:ellipse(cx, 101, 34, 25)
local pv = c:part(vest, GV.ramp("#a38f80"))
-- collar band
local collar = c:ellipse(cx, 80, 15, 5):clip(vest)
c:part(collar, GV.ramp("#8f7060"), { flat = true })
-- placket + seam + buttons
c:fill(c:rect(39, 84, 40, 99):clip(vest), "#2a1a10")
c:seam({ {43, 85}, {43, 99} })
c:button(38, 87); c:button(38, 93)
-- head
local head = c:ellipse(cx, 60, 18, 17)
c:part(head, GV.ramp("#b0bc66"))
-- muzzle
local muz = c:ellipse(cx, 67, 10, 7)
c:part(muz, GV.ramp("#f8eed2"), { cres = 2, gloss = false })
-- brows (thick)
local bw = c:line({ {28, 51}, {30, 49}, {35, 49} }, 2)
bw:add(c:line({ {44, 49}, {49, 49}, {51, 51} }, 2))
c:fill(bw, "#4a8a3e")
-- eyes
c:eye(31, 53); c:eye(44, 53)
-- mouth
c:paint({ "m.......m", ".mmmmmmm." }, 35, 67, { m = "#4a2c1a" })
local t = c:save(O .. "aseprite/ph/npc-tobias-trundle.aseprite", O .. "png/ph/npc-tobias-trundle.png")
print(GV.report(t))
