local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- paper cone: narrow top, wide rounded base
local cone = c:poly({ {23,15}, {41,15}, {50,53}, {14,53} })
cone:add(c:rrect(14, 46, 50, 55, 4))
-- twisted tip: pinched waist, flared top
local tip = c:rrect(27, 11, 37, 17, 2)
tip:add(c:rrect(25, 6, 39, 11, 2))
-- window
local win = c:rrect(20, 24, 44, 48, 6)
local winIn = c:rrect(22, 26, 42, 46, 5)
-- pod: curved thick line
local pod = c:line({ {25,41}, {29,38}, {34,34}, {38,30}, {40,28} }, 9)
pod:clip(winIn:grow(1))

local p = c:build{
  { "cone", cone, "#f1ece0" },
  { "tip",  tip,  "#dcb06a", { cres = 2 } },
  { "win",  win,  "#7ab55c", { gloss = false, cres = 2 } },
  { "inner", winIn, "#f4f0e0", { gloss = false, rim = false, bounce = false, cres = 2 } },
  { "pod",  pod,  "#7ab55c" },
}
-- bean bumps
for _, b in ipairs({ {28,36}, {33,32}, {38,28} }) do
  c:fill(c:ellipse(b[1]+0.5, b[2]+0.5, 2.5, 2.5), "#58a03e")
  c:px(b[1], b[2], "#a4b86a")
end
-- midrib
c:fill(c:line({ {26,42}, {31,38}, {36,34}, {41,30} }, 1), "#4a8a3e")
-- stalk
c:fill(c:line({ {23,42}, {21,45} }, 2), "#2f5a2a")
-- twist lines on tip
c:paint({ "u..", ".u.", "..u" }, 28, 7, { u = "#8a4f2a" })
c:paint({ "u..", ".u.", "..u" }, 33, 7, { u = "#8a4f2a" })
c:fill(c:line({ {29,13}, {31,15} }, 1), "#8a4f2a")
c:fill(c:line({ {33,13}, {35,15} }, 1), "#8a4f2a")
-- seam down the right fold
c:seam({ {42,18}, {48,47} })
-- label dots
for _, x in ipairs({ 26, 31, 36 }) do c:fill(c:rect(x, 51, x+1, 52), "#8c4a1a") end
c:ground(32, 57, 17, 2.5)

local t = c:save(O .. "aseprite/ph/cowpea-seed.aseprite", O .. "png/ph/cowpea-seed.png")
print(GV.report(t))
