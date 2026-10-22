local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local T = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local disc = c:ellipse(40, 50, 36, 36)
local body = c:ellipse(40, 100, 34, 24):cut(c:rect(0, 0, 79, 75))
local sash = c:line({ {28, 79}, {34, 83}, {40, 85}, {46, 83}, {52, 79} }, 4)
sash:add(c:poly({ {45, 82}, {52, 82}, {49, 97} }))
sash:clip(body)
local earL = c:ellipse(23, 34, 11, 11)
local earR = c:ellipse(57, 34, 11, 11)
local face = c:ellipse(40, 54, 22, 20)
local muzzle = c:ellipse(40, 62, 12, 9)
local nose = c:ellipse(40, 59, 4.5, 3)

local p = c:build{
  { "disc",  disc, GV.ramp("#8fcbd8"), { gloss = false, contact = false } },
  { "body",  body, "red", { stitch = { side = "lit" } } },
  { "sash",  sash, GV.ramp("#c4925f") },
  { "earL",  earL, "gold" },
  { "earR",  earR, "gold" },
}
c:part(c:ellipse(23, 34, 6.5, 6.5), "petal", { flat = true, contact = false })
c:part(c:ellipse(57, 34, 6.5, 6.5), "petal", { flat = true, contact = false })
c:build{
  { "face",   face, "gold", { gloss = { 25, 40 } } },
  { "muzzle", muzzle, GV.ramp("#f5cf6a"), { gloss = false, contact = false } },
  { "nose",   nose, GV.ramp("#e46a9b"), { gloss = { 38, 57 }, contact = false } },
}

-- collar V
c:paint({ "d.......d", ".d.....d.", "..d...d..", "...d.d...", "....d...." }, 36, 82, { d = "#6b1b2c" })
c:seam({ {12, 90}, {30, 79} })
c:seam({ {50, 79}, {68, 90} })
c:button(38, 77)

-- eyes (sleepy: wide set)
c:eye(28, 47); c:eye(47, 47)
-- whiskers
local W = "#2a1a10"
local wm = c:line({ {26, 61}, {17, 60} }, 1):add(c:line({ {26, 64}, {18, 67} }, 1))
wm:add(c:line({ {53, 61}, {62, 60} }, 1)):add(c:line({ {53, 64}, {61, 67} }, 1))
c:fill(wm, W)
-- smile
c:paint({ "u.....u", ".u...u.", "..uuu.." }, 37, 65, { u = "#4a2c1a" })

local t = c:save(T .. "aseprite/ph/npc-quill-brambleby.aseprite", T .. "png/ph/npc-quill-brambleby.png")
print(GV.report(t))
