local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local SCUTE = "#2a1a10"
local cream = GV.ramp("#f8eed2")
local shellR = GV.ramp("#a5663a")
local skinR = GV.ramp("#b0bc66")

-- backdrop disc
c:part(c:ellipse(40, 50, 35, 35), "petal", { gloss = false })

-- jacket, bleeds off the bottom
local body = c:ellipse(40, 101, 34, 25):cut(c:rect(0, 100, 79, 140))
c:part(body, GV.ramp("#d6322b", { shade = "#9c2a1e" }))

-- bib + straps (one cream part)
local bib = c:poly({ {26, 83}, {55, 83}, {59, 100}, {21, 100} })
bib:add(c:line({ {28, 78}, {31, 83} }, 2))
bib:add(c:line({ {51, 78}, {48, 83} }, 2))
local pb = c:part(bib, cream, { gloss = false })

-- shell dome: wide shallow arch with a marginal lip
local shell = c:ellipse(40, 50, 30, 34):cut(c:rect(0, 51, 79, 99))
local ps = c:part(shell, shellR, { gloss = { 18, 30 } })
-- scute lines (clipped to the shell)
local function sl(pts) c:fill(c:line(pts, 2):clip(shell:shrink(1)), SCUTE) end
sl({ {12, 41}, {22, 37}, {31, 35}, {49, 35}, {58, 37}, {68, 41} }) -- belt
sl({ {31, 35}, {28, 23}, {33, 17} })                                -- left of central scute
sl({ {49, 35}, {52, 23}, {47, 17} })                                -- right of central scute
sl({ {22, 37}, {16, 30} })
sl({ {58, 37}, {64, 30} })
sl({ {28, 23}, {19, 25} })
sl({ {52, 23}, {61, 25} })
sl({ {39, 35}, {39, 50} })
sl({ {24, 38}, {22, 50} })
sl({ {56, 38}, {58, 50} })
-- marginal lip line along the base
c:fill(c:rect(11, 47, 69, 47):clip(shell:shrink(1)), SCUTE)
c:gloss(shell, shellR, { 18, 29 })

-- head
local head = c:ellipse(40, 61, 17, 16)
c:part(head, skinR, { gloss = { 27, 49 } })
-- muzzle
c:part(c:ellipse(40, 69, 9, 6), cream, { gloss = false })

-- bib top stitch + strap button
c:seam({ {24, 86}, {57, 86} }, { on = 2, off = 1 })
c:button(27, 80)

-- face
c:eye(30, 54); c:eye(46, 54)
c:paint({ ".bbbb.", "b....b" }, 29, 50, { b = "#58a03e" })
c:paint({ ".bbbb.", "b....b" }, 46, 50, { b = "#58a03e" })
c:paint({ "m.....m", ".mmmmm." }, 37, 69, { m = "#4a2c1a" })

local t = c:save(O .. "aseprite/ph/npc-nettle-fernsway.aseprite", O .. "png/ph/npc-nettle-fernsway.png")
print(GV.report(t))
