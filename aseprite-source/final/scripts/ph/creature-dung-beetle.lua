local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- legs (behind shell): beetle at lower left, front-right legs braced on the ball
c:limb({ {19, 36}, {14, 33}, {12, 30} })
c:limb({ {18, 42}, {12, 43}, {11, 46} })
c:limb({ {19, 48}, {14, 51}, {13, 54} })
c:limb({ {32, 35}, {36, 32}, {38, 30} })
c:limb({ {34, 41}, {39, 41}, {41, 39} })
c:limb({ {33, 47}, {38, 50}, {40, 53} })

local shellRamp = GV.ramp("#8c4a1a")
local ballRamp  = GV.ramp("#a5663a")
local headRamp  = GV.ramp("#44281c", { rim = "#7a4a2c" })

local shell = c:ellipse(26, 42, 9, 10.5)
local p = c:build{
  { "ball",  c:ellipse(43.5, 23.5, 8, 8), ballRamp },
  { "shell", shell, shellRamp },
  { "head",  c:ellipse(26, 29, 5.5, 4.5), headRamp },
}
-- ball texture: a couple of darker lumps
c:spot(c:ellipse(46, 26, 1.5, 1), ballRamp.shade)
c:spot(c:ellipse(41, 28, 1, 1), ballRamp.shade)
c:spot(c:ellipse(47, 20, 1, 1), ballRamp.shade)

-- wing split seam
c:seam({ {26, 34}, {26, 51} })

-- antennae with clubs
c:limb({ {24, 25}, {21, 22}, {19, 20} })
c:limb({ {28, 25}, {31, 22}, {32, 20} })
c:part(c:rrect(17, 17, 20, 20, 1), headRamp, { flat = true })
c:part(c:rrect(31, 17, 34, 20, 1), headRamp, { flat = true })

c:eye(22, 28, true); c:eye(28, 28, true)

local t = c:save(O .. "aseprite/ph/creature-dung-beetle.aseprite", O .. "png/ph/creature-dung-beetle.png")
print(GV.report(t))
