local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local green = GV.ramp("#8fb85a")
local shellR = GV.ramp("#8a4f2a")
local rimR = GV.ramp("#5e2f1e")

-- shell dome: wide, tall arch with flat bottom
local shell = c:ellipse(28, 41, 17, 19):clip(c:rect(0, 0, 63, 42))
local plastron = c:rrect(10, 40, 46, 46, 3)
local feet = c:ellipse(17.5, 47, 4, 2.5):add(c:ellipse(38.5, 47, 4, 2.5))
local tail = c:poly({ {12, 40}, {8, 44}, {10, 45}, {13, 44} })
local head = c:ellipse(48, 34, 5, 4.5):add(c:rrect(40, 33, 48, 42, 2))
local crown = c:poly({ {20, 25}, {20, 13}, {24, 18}, {28, 10}, {32, 18}, {36, 13}, {36, 25} })

local p = c:build{
  { "feet", feet, green },
  { "tail", tail, green, { flat = true } },
  { "plastron", plastron, rimR },
  { "shell", shell, shellR },
  { "head", head, green },
  { "crown", crown, "gold" },
}

-- scute lines (2 px, deep brown), only on the shell
local sc = c:line({ {28, 24}, {28, 39} }, 2)
sc:add(c:line({ {14, 31}, {42, 31} }, 2))
sc:add(c:line({ {19, 25}, {22, 31}, {19, 39} }, 2))
sc:add(c:line({ {37, 25}, {34, 31}, {37, 39} }, 2))
sc:clip(p.shell.m:shrink(2))
c:fill(sc, "#5e2f1e")

-- crown hem seam + red jewel
c:seam({ {20, 21}, {35, 21} })
c:paint({ "rr", "rr" }, 27, 15, { r = "#d6322b" })
c:px(27, 15, "#f08a24")

-- seam on plastron lip
c:seam({ {13, 43}, {44, 43} })

-- face: small locked eye, grumpy brow, mouth
c:eye(47, 30, true)
c:paint({ "uu...", "..uu." }, 46, 28, { u = "#2a1a10" })
c:paint({ "..uuu", "uu..." }, 48, 36, { u = "#2a1a10" })

c:ground(28, 50, 19, 1.5)
local t = c:save(O .. "aseprite/ph/creature-ancient-snapper.aseprite", O .. "png/ph/creature-ancient-snapper.png")
print(GV.report(t))
