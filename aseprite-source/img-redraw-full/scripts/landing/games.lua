local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "img-redraw-full/"
-- half-size grid 120x80, written at 2x -> 240x160
local c = GV.canvas{ w = 120, h = 80, mode = "scene", out = 2 }

-- 1. sky: pale meadow-green hard bands
c:bands(nil, { "#eef3d4", "#e7eec9", "#dfe8bd", "#d7e2b1", "#cfdca6" })

-- 2. wavy hill
local hill = c:poly({ {-2, 60}, {10, 58}, {22, 57}, {36, 55}, {52, 54}, {66, 55}, {80, 53}, {94, 51}, {108, 51}, {122, 52},
                      {122, 82}, {-2, 82} })
c:part(hill, "moss", { cres = 3, gloss = false, rim = true })
-- grass tufts on the hill
for _, p in ipairs({ {8, 63}, {24, 66}, {84, 60}, {110, 58}, {74, 72}, {14, 74} }) do
  c:paint({ "g.g", ".g." }, p[1], p[2], { g = "#a4b86a" })
end

-- 3. snail shadow
c:fill(c:ellipse(41, 66, 21, 1.5), "#4a8a3e")

-- 4. snail body: long foot with a raised head at the front
local body = c:ellipse(41, 62, 20, 3.5)
body:add(c:rrect(58, 49, 69, 64, 5))
body:add(c:poly({ {50, 59}, {60, 52}, {64, 58}, {56, 64} }))
local skin = GV.ramp("#f2c28e")
c:part(body, skin, { cres = 3, gloss = { 61, 52 } })

-- 6. eyestalks (behind nothing, in front of the sky) and eyes
local stalks = c:line({ {61, 50}, {60, 43} }, 2):add(c:line({ {67, 50}, {70, 44} }, 2))
c:part(stalks, skin, { flat = true })
local eyeL = c:rrect(58, 40, 61, 43, 1)
local eyeR = c:rrect(69, 41, 72, 44, 1)
c:part(eyeL:copy():add(eyeR), GV.ramp("#2a1a10", { base = "#2a1a10", rim = "#3e2f66" }), { flat = true, rim = false })
c:px(59, 41, "#f2e4c0"); c:px(70, 42, "#f2e4c0")
-- smile
c:paint({ "m...m", ".mmm." }, 62, 56, { m = "#8a4234" })

-- 5. gold shell (the hero)
local shell = c:ellipse(40, 49, 15, 13):cut(c:rect(0, 61, 119, 79))
local shellR = GV.ramp("#e8a317")
local sp = c:build{
  { "shell", shell, GV.ramp("#dcb06a"), { cres = 4, gloss = false } },
  { "inner", c:ellipse(40.5, 50, 10, 9):cut(c:rect(0, 60, 119, 79)), shellR, { cres = 3, gloss = { 34, 44 } } },
}
-- spiral
local spiral = c:line({ {33, 56}, {33, 51}, {36, 46}, {41, 45}, {46, 47}, {47, 52}, {45, 55}, {41, 55}, {39, 52}, {41, 50} }, 2)
spiral:clip(sp.inner.m:shrink(1))
c:fill(spiral, "#b07a10")
-- rim seam where the shell sits on the foot
c:seam({ {26, 60}, {54, 60} })

-- 7. tumbling die, upper right
local die = c:rrect(79, 18, 101, 40, 4)
c:part(die, GV.ramp("#f4f0e0"), { cres = 4, pale = true, gloss = { 82, 21 } })
for _, d in ipairs({ {84, 23}, {94, 23}, {89, 28}, {84, 33}, {94, 33} }) do
  c:paint({ ".pp.", "pppp", "pppp", ".pp." }, d[1], d[2], { p = "#2a1a10" })
end
-- motion swooshes behind the die
for _, s in ipairs({ { {68, 22}, {74, 22} }, { {66, 29}, {74, 29} }, { {69, 36}, {74, 36} } }) do
  c:fill(c:line(s, 1), "#a4b86a")
end

-- 8. toadstool, upper left
local stem = c:rrect(17, 26, 22, 33, 1)
local cap = c:ellipse(19.5, 27, 8, 8):cut(c:rect(0, 28, 119, 79))
cap:add(c:rrect(11, 25, 28, 28, 1))
c:build{
  { "stem", stem, GV.ramp("#f1ece0"), { pale = true, cres = 2, gloss = false } },
  { "cap",  cap,  GV.ramp("#d6322b"), { cres = 3, gloss = { 15, 22 } } },
}
c:paint({ ".cc.", "cccc", ".cc." }, 20, 21, { c = "#f1ece0" })
c:paint({ "cc", "cc" }, 24, 24, { c = "#f1ece0" })
c:paint({ "cc", "cc" }, 14, 25, { c = "#f1ece0" })
-- tufts at its foot
c:paint({ "g.g.g", ".g.g." }, 16, 33, { g = "#4a8a3e" })

-- 9. gold sparkle
local star = c:poly({ {7, 4}, {9, 10}, {14, 12}, {9, 14}, {7, 20}, {5, 14}, {0, 12}, {5, 10} })
c:part(star, GV.ramp("#f5cf6a"), { flat = true })
c:px(7, 11, "#fff1c8"); c:px(7, 12, "#fff1c8")

-- 10. little red flag, lower right
local pole = c:rect(98, 56, 99, 66)
local flag = c:poly({ {100, 56}, {109, 56}, {106, 59}, {109, 62}, {100, 62} })
c:build{
  { "pole", pole, GV.ramp("#a8703c"), { flat = true } },
  { "flag", flag, GV.ramp("#d6322b"), { cres = 2, gloss = false } },
}

-- hem stitch top and bottom
c:seam({ {0, 1}, {119, 1} }, { free = true })
c:seam({ {0, 78}, {119, 78} }, { free = true })

local t = c:save(O .. "aseprite/landing/games.aseprite", O .. "png/landing/games.png")
print(GV.report(t))
