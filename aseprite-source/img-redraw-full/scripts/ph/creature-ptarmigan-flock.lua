local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pale = GV.ramp("#f8eed2")
local tan = GV.ramp("#dcb06a", { rim = "#d9a660" })

-- feet (gold prongs)
local feet = c:mask()
for _, f in ipairs({ {15,35}, {22,35}, {42,33}, {49,33}, {31,52}, {39,52} }) do
  feet:add(c:rect(f[1], f[2], f[1] + 1, f[2] + 3))
  feet:add(c:rect(f[1] - 1, f[2] + 3, f[1] + 2, f[2] + 3))
end

local bl = c:ellipse(19.5, 27, 9.5, 9)
local br = c:ellipse(44.5, 25, 9.5, 9)
local fr = c:ellipse(35.5, 42, 11.5, 10.5)

-- wings: tilted wedges on the outer side of each bird
local wBL = c:poly({ {10,25}, {15,26}, {16,34}, {12,36} })
local wBR = c:poly({ {49,24}, {54,23}, {56,32}, {51,32} })
local wF1 = c:poly({ {23,41}, {29,42}, {29,50}, {25,52} })
local wF2 = c:poly({ {42,42}, {48,41}, {47,52}, {43,50} })

c:build{
  { "feet", feet, "gold", { flat = true } },
  { "bl", bl, pale, { pale = true } },
  { "wbl", wBL, tan, { flat = true } },
  { "br", br, pale, { pale = true } },
  { "wbr", wBR, tan, { flat = true } },
  { "fr", fr, pale, { pale = true } },
  { "wf1", wF1, tan, { flat = true } },
  { "wf2", wF2, tan, { flat = true } },
}

-- beaks (gold triangles)
local beak = { "gggg", ".gg." }
c:paint(beak, 18, 26, { g = "#e8a317" })
c:paint(beak, 43, 24, { g = "#e8a317" })
c:paint({ "ggggg", ".ggg.", "..g.." }, 34, 40, { g = "#e8a317" })
c:px(18, 26, "#f5cf6a"); c:px(43, 24, "#f5cf6a"); c:px(34, 40, "#f5cf6a")

-- eyes
c:eye(15, 22, true); c:eye(22, 22, true)
c:eye(40, 20, true); c:eye(47, 20, true)
c:eye(30, 35); c:eye(37, 35)

local t = c:save(O .. "aseprite/ph/creature-ptarmigan-flock.aseprite", O .. "png/ph/creature-ptarmigan-flock.png")
print(GV.report(t))
