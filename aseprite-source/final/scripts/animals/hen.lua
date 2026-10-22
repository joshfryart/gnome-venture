local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local hen = GV.ramp("#b5651d")
local red = GV.ramp("#d6322b")

-- body: big round egg on the left plus head bump at upper right
local body = c:ellipse(30, 40, 18, 12)
body:add(c:ellipse(38, 24, 9, 9))
body:add(c:poly({ {28, 30}, {36, 18}, {46, 26}, {46, 40}, {30, 42} }))
body = body:closed(3)

local tail = c:poly({ {9, 26}, {16, 31}, {20, 40}, {12, 40}, {8, 33} })

local comb = c:ellipse(32, 15, 3, 3):add(c:ellipse(37.5, 13, 3, 4)):add(c:ellipse(43, 15, 3, 3))
comb:add(c:rect(30, 15, 45, 18))

local beak = c:poly({ {46, 21}, {54, 25}, {46, 29} })
local wattle = c:ellipse(44, 31, 2, 3)

c:build{
  { "legL", c:line({ {26, 50}, {26, 55} }, 3), "#e8a317", { flat = true } },
  { "legR", c:line({ {34, 50}, {34, 55} }, 3), "#e8a317", { flat = true } },
  { "tail", tail, GV.ramp("#c9792c"), { cres = 2, deep = 1 } },
  { "body", body, hen, { stitch = { side = "lit" } } },
  { "comb", comb, red, { cres = 2, deep = 1 } },
  { "beak", beak, "gold", { flat = true } },
  { "wattle", wattle, red, { flat = true } },
}
-- feet toes
c:paint({ "ggggg" }, 24, 55, { g = "#b8661a" })
c:paint({ "ggggg" }, 32, 55, { g = "#b8661a" })

-- wing band and feather lines
local wing = GV.ramp("#8c4a12")
c:part(c:line({ {16, 38}, {24, 41}, {34, 41}, {40, 37} }, 3), wing, { flat = true, contact = false })
c:fill(c:line({ {20, 44}, {27, 46}, {35, 45} }, 2), "#8c4a12")
c:fill(c:line({ {23, 48}, {28, 49}, {33, 48} }, 2), "#8c4a12")

c:eye(36, 20, true)

c:ground(30, 56, 11, 1)
local t = c:save(O .. "aseprite/animals/hen.aseprite", O .. "png/animals/hen.png")
print(GV.report(t))
