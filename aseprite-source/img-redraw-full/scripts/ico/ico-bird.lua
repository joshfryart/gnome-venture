local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local tail = c:poly({ {20, 40}, {8, 33}, {7, 44}, {11, 53}, {22, 47} })
local legs = c:line({ {27, 50}, {26, 56} }, 3):add(c:line({ {37, 50}, {38, 56} }, 3))
local feet = c:rect(23, 55, 29, 57):add(c:rect(36, 55, 42, 57))
legs:add(feet)
local body = c:ellipse(31.5, 34, 18, 17)
local belly = c:ellipse(35, 42, 11, 7):clip(body)
local wing = c:ellipse(25, 37, 10, 6):add(c:poly({ {15, 38}, {20, 46}, {26, 42} }))
local beak = c:poly({ {48, 27}, {58, 32}, {48, 37} })

c:build{
  { "tail", tail, GV.ramp("#8c4a1a") },
  { "legs", legs, GV.ramp("#e8892a"), { flat = true } },
  { "body", body, "wood" },
  { "belly", belly, GV.ramp("#f8eed2"), { gloss = false } },
  { "wing", wing, GV.ramp("#8c4a1a"), { gloss = false } },
  { "beak", beak, GV.ramp("#e8892a"), { gloss = false } },
}
-- feather tips on wing and tail
c:paint({ "d.d.d" }, 21, 40, { d = "#5e2f1e" })
c:paint({ "d", ".", "d" }, 12, 40, { d = "#5e2f1e" })
-- beak split
c:fill(c:rect(49, 32, 53, 32), "#b8661a")
c:eye(38, 25, true)
local t = c:save(O .. "aseprite/ico/ico-bird.aseprite", O .. "png/ico/ico-bird.png")
print(GV.report(t))
