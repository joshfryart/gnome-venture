local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local door = c:rect(26, 38, 37, 51):add(c:ellipse(31.5, 38, 5.5, 5.5))
local p = c:build{
  { "roof",  c:poly({ {10, 31}, {32, 12}, {54, 31} }), GV.ramp("#a85a3a") },
  { "wall",  c:rect(13, 31, 50, 51), "wood" },
  { "eave",  c:rect(10, 29, 53, 31), GV.ramp("#8c4a2c"), { gloss = false } },
  { "door",  door, GV.ramp("#4a3322"), { gloss = false } },
}
-- plank lines on the wall
local planks = c:rect(14, 39, 49, 40):add(c:rect(14, 46, 49, 47)):cut(door:grow(1))
c:fill(planks, "#a87a3d")
local q = c:build{
  { "quail", c:ellipse(43.5, 48, 5.5, 3.5), GV.ramp("#a8825a") },
  { "head",  c:ellipse(47, 43, 3, 3), GV.ramp("#a8825a"), { gloss = false } },
}
c:spot(c:ellipse(41, 48, 1, 1)); c:spot(c:ellipse(44, 49, 1, 1))
c:paint({ "gg.", "ggg" }, 50, 43, { g = "gold" })
c:paint({ ".k", "k." }, 46, 38, { k = "#2a1a10" })   -- topknot plume
c:eye(46, 42, true)
c:seam({ {12, 30}, {52, 30} }, { free = true })
c:ground(31.5, 52, 20, 1)

local t = c:save(O .. "aseprite/animals/quail_coop.aseprite", O .. "png/animals/quail_coop.png")
print(GV.report(t))
