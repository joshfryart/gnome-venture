local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local disc = c:ellipse(40, 50, 36, 36)

-- wings: big upper lobe + smaller lower lobe each side
local wl = c:ellipse(19, 40, 13, 14)
wl:add(c:ellipse(22, 62, 11, 9))
wl:add(c:poly({ {26, 34}, {36, 46}, {36, 66}, {24, 60} }))
local wr = c:mask()
wl:each(function(x, y) wr:set(79 - x, y) end)
local wings = wl:copy(); wings:add(wr)

-- antennae with a curl, ending in 4x4 clubs
local ant = c:line({ {35, 38}, {32, 32}, {28, 27}, {24, 24} }, 2)
ant:add(c:line({ {44, 38}, {47, 32}, {51, 27}, {55, 24} }, 2))
ant:add(c:rrect(20, 21, 23, 24, 1)); ant:add(c:rrect(56, 21, 59, 24, 1))

local jacket = c:ellipse(39.5, 102, 33, 26):clip(c:rect(0, 76, 79, 99))
local scarf = c:line({ {28, 79}, {34, 83}, {40, 85}, {46, 83}, {52, 79} }, 3)
local tie = c:poly({ {37, 85}, {43, 85}, {44, 95}, {40, 99}, {36, 95} })

local face = c:ellipse(39.5, 57, 15, 18)
local cap = c:ellipse(39.5, 45, 18, 15):cut(c:rect(0, 45, 79, 99))
cap:add(c:rrect(19, 42, 60, 47, 2))

local pink = GV.ramp("#d9667f")
c:build{
  { "disc", disc, GV.ramp("#b8d8d2"), { gloss = false } },
  { "wings", wings, pink },
  { "ant", ant, "dusk", { flat = true } },
  { "jacket", jacket, "gold", { stitch = { side = "lit" } } },
  { "scarf", scarf, GV.ramp("#c4925f"), { flat = true } },
  { "tie", tie, GV.ramp("#a5663a") },
  { "face", face, GV.ramp("#f5cf6a") },
  { "cap", cap, GV.ramp("#a5663a") },
}
-- cream wing spots
c:spot(c:ellipse(16, 40, 4, 4), "#f8eed2", "#fff3c8")
c:spot(c:ellipse(63, 40, 4, 4), "#f8eed2", "#fff3c8")
c:spot(c:ellipse(20, 63, 2, 2), "#f8eed2", "#fff3c8")
c:spot(c:ellipse(59, 63, 2, 2), "#f8eed2", "#fff3c8")

c:seam({ {21, 44}, {58, 44} })
c:button(38, 28)
c:eye(31, 51); c:eye(45, 51)
c:paint({ "u.......u", ".uuuuuuu." }, 36, 62, { u = "umber" })

local t = c:save(O .. "aseprite/ph/npc-burdock-puddlejump.aseprite", O .. "png/ph/npc-burdock-puddlejump.png")
print(GV.report(t))
