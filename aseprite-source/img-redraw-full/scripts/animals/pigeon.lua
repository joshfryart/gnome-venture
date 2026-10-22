local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local feet = c:line({ {34, 46}, {34, 51}, {36, 51} }, 2):add(c:line({ {39, 46}, {39, 51}, {41, 51} }, 2))
local body = c:ellipse(29, 36, 15, 11):add(c:poly({ {19, 31}, {10, 41}, {12, 46}, {26, 45} }))
local wing = c:ellipse(28, 35, 10, 5.5):add(c:poly({ {10, 41}, {12, 46}, {22, 44}, {17, 39} })):clip(body)
local head = c:ellipse(41, 21, 7.5, 7.5):add(c:rrect(34, 22, 47, 32, 4))
local band = c:rect(33, 27, 48, 30):clip(head)
local beak = c:poly({ {47, 18}, {53, 21}, {47, 24} })
local parcel = c:rrect(19, 40, 30, 49, 1)

local grey = GV.ramp("#8a93a6")
c:build{
  { "feet", feet, GV.ramp("#d9707a"), { flat = true } },
  { "body", body, grey },
  { "wing", wing, GV.ramp("#6c7487"), { gloss = false } },
  { "head", head, grey },
  { "band", band, GV.ramp("#5fae9c"), { gloss = false } },
  { "beak", beak, GV.ramp("#d9a066"), { flat = true } },
  { "parcel", parcel, GV.ramp("#f1e6d2"), { gloss = false } },
}
c:fill(c:line({ {19, 41}, {24, 45}, {25, 45}, {30, 41} }, 1), "#b49b6e")
c:eye(41, 18, true)
local t = c:save(O .. "aseprite/animals/pigeon.aseprite", O .. "png/animals/pigeon.png")
print(GV.report(t))
