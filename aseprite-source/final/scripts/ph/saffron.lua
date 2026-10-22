local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- fanned saffron threads (3 fat curved strands)
local th = c:line({ {31, 50}, {24, 44}, {17, 38}, {11, 31} }, 4)
th:add(c:line({ {32, 50}, {32, 40}, {32, 30} }, 3))
th:add(c:line({ {33, 50}, {40, 44}, {47, 38}, {53, 31} }, 4))
th:add(c:line({ {31, 50}, {27, 42}, {22, 33} }, 2))
th:add(c:line({ {33, 50}, {37, 42}, {42, 33} }, 2))

-- crocus cup with two petal notches
local cup = c:ellipse(32, 23, 11, 9)
cup:cut(c:poly({ {26, 13}, {31, 13}, {28.5, 19} }))
cup:cut(c:poly({ {34, 13}, {39, 13}, {36.5, 19} }))

local p = c:build{
  { "threads", th, "#e0501f", { flat = true } },
  { "sheath", c:rrect(29, 30, 35, 37, 2), "#6a9a3a", { gloss = false } },
  { "cup", cup, "#7a5cc0" },
  { "tie", c:rrect(27, 44, 37, 48, 1), "gold", { gloss = false } },
}
-- stamen tips peeking from the notches and the top
local st = c:rect(27, 16, 29, 18); st:add(c:rect(35, 16, 37, 18)); st:add(c:rect(31, 11, 33, 13))
c:part(st, "#f08a24", { flat = true })
-- petal lines on the cup
c:paint({ "d", "d", "d", "d" }, 28, 21, { d = GV.ramp("#7a5cc0").shade })
c:paint({ "d", "d", "d", "d" }, 36, 21, { d = GV.ramp("#7a5cc0").shade })
c:seam({ {27, 46}, {37, 46} })

local t = c:save(O .. "aseprite/ph/saffron.aseprite", O .. "png/ph/saffron.png")
print(GV.report(t))
