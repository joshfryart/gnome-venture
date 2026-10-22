local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = GV.ramp("#e0c9a0", { shade = "#bca373" })
local stalkR = GV.ramp("#c9b083")

-- long low foot with tapered tail and a raised neck
local foot = c:rrect(14, 44, 51, 53, 4)
foot:add(c:poly({ { 10, 54 }, { 16, 46 }, { 16, 54 } }))
foot:add(c:rrect(40, 29, 51, 50, 5))
-- eye stalks
c:part(c:line({ { 43, 31 }, { 42, 18 } }, 2), stalkR, { flat = true })
c:part(c:line({ { 48, 31 }, { 50, 18 } }, 2), stalkR, { flat = true })
c:part(c:ellipse(42.5, 16.5, 3, 3), body, { gloss = false, cres = 2 })
c:part(c:ellipse(50.5, 16.5, 3, 3), body, { gloss = false, cres = 2 })
local p = c:part(foot, body, { gloss = { 44, 33 } })

-- big cool blue-grey spiral shell
local shellR = GV.ramp("#8d98a3", { shade = "#5f6a75", gloss = "#c3ccd4" })
local shell = c:ellipse(26, 33, 15, 15)
c:part(shell, shellR, { gloss = false })
-- spiral line
local pts = {}
for i = 0, 26 do
  local a = i * 0.36 + 0.4
  local r = 1.5 + i * 0.42
  pts[#pts + 1] = { math.floor(26.5 + r * math.cos(a)), math.floor(33.5 + r * math.sin(a)) }
end
c:fill(c:line(pts, 2):clip(shell:shrink(2)), "#5f6a75")
-- gloss streak and dot
c:fill(c:line({ { 15, 27 }, { 18, 23 }, { 23, 20 } }, 2), "#c3ccd4")
c:px(14, 31, "#e4eaef")

-- tiny leaf tucked on the shell's upper left
local leafR = GV.ramp("#5d9a4b", { gloss = "#8cc874" })
local leaf = c:poly({ { 17, 21 }, { 21, 17 }, { 27, 16 }, { 30, 18 }, { 25, 21 } })
c:part(leaf, leafR, { gloss = false, flat = true })
c:fill(c:line({ { 20, 19 }, { 27, 17 } }, 1), "#8cc874")

-- locked eyes on the stalk tips (small head)
c:eye(41, 15, true); c:eye(49, 15, true)
-- smile
c:paint({ "m...m", ".mmm." }, 44, 38, { m = "#7a5a35" })

c:ground(30, 54, 20, 1.5)
local t = c:save(O .. "aseprite/games/snail-grey.aseprite", O .. "png/games/snail-grey.png")
print(GV.report(t))
