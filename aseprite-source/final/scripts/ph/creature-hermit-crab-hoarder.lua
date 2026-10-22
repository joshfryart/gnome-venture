local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local red   = GV.ramp("#d6322b")
local shellR = GV.ramp("#dcb06a")
local armR  = GV.ramp("#bf6f4f")
local belly = GV.ramp("#f6b8cf")

-- legs
c:limb({ {21,48}, {15,51}, {12,55} })
c:limb({ {42,48}, {48,51}, {51,55} })
c:limb({ {24,51}, {19,54}, {17,55} })
c:limb({ {39,51}, {44,54}, {46,55} })

-- spiral shell behind (dome + apex knob)
local shell = c:ellipse(31.5, 25, 15, 13)
shell:add(c:ellipse(39, 14, 5, 4.5))
-- claws: lobes with differing notches
local clawL = c:ellipse(14.5, 26, 4.5, 7):cut(c:poly({ {12,18}, {16,18}, {14,25} }))
local clawR = c:ellipse(49.5, 26, 4.5, 7):cut(c:poly({ {49,18}, {54,18}, {50,24} }))
local armL = c:line({ {20,43}, {16,38}, {15,32} }, 3)
local armR2 = c:line({ {43,43}, {47,38}, {48,32} }, 3)
local body = c:ellipse(31.5, 44, 14, 8.5)
local bel = c:ellipse(31.5, 47, 7, 3.5)
local stalkL = c:rect(27, 29, 28, 37)
local stalkR = c:rect(36, 29, 37, 37)

c:build{
  { "shell", shell, shellR },
  { "armL", armL, armR, { flat = true } },
  { "armR", armR2, armR, { flat = true } },
  { "clawL", clawL, red },
  { "clawR", clawR, red },
  { "body", body, red },
  { "belly", bel, belly, { gloss = false } },
  { "stalkL", stalkL, "dusk", { flat = true } },
  { "stalkR", stalkR, "dusk", { flat = true } },
}
-- spiral swirl on shell
local sw = c:line({ {34,18}, {36,18}, {36,20}, {33,21}, {30,19}, {30,16}, {33,13}, {37,12}, {40,14} }, 1)
c:fill(sw, "#5e2f1e")
-- shell lip seam where crab emerges
c:seam({ {19,34}, {44,34} })
-- eyes on stalks
c:eye(25, 25); c:eye(34, 25)
-- small wary mouth
c:paint({ "u.u", ".u." }, 30, 41, { u = "#6b1b2c" })
c:ground(31.5, 55, 16, 1.5)
local t = c:save(O .. "aseprite/ph/creature-hermit-crab-hoarder.aseprite", O .. "png/ph/creature-hermit-crab-hoarder.png")
print(GV.report(t))
