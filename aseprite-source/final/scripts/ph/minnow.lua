local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- forked tail: two swept lobes meeting at the peduncle
local tail = c:poly({ {42, 31}, {55, 21}, {58, 22}, {50, 33}, {58, 43}, {55, 45}, {42, 36} })
-- slim spindle body, pointed head on the left
local body = c:poly({ {7, 33}, {12, 28}, {20, 25}, {32, 25}, {41, 28}, {46, 31}, {46, 35}, {41, 38}, {32, 41}, {20, 41}, {12, 39} })
local fin = c:poly({ {25, 26}, {29, 20}, {33, 20}, {35, 26} })
local belly = c:poly({ {12, 36}, {20, 37}, {32, 37}, {42, 35}, {41, 38}, {32, 41}, {20, 41}, {12, 39} }):clip(body)

local p = c:build{
  { "fin", fin, GV.ramp("#d0862a"), { gloss = false } },
  { "tail", tail, GV.ramp("#d0862a"), { gloss = false } },
  { "body", body, "gold", { gloss = { 18, 27 } } },
}
c:fill(belly, "#f4f0e0")
c:fill(belly:copy():clip(c:rect(0, 40, 63, 63)), "#f5b860")
-- side stripe
c:fill(c:line({ {15, 33}, {28, 33}, {40, 32} }, 2), "#b07a10")
c:eye(14, 30, true)
c:px(10, 35, "#4a2c1a")
c:px(11, 35, "#4a2c1a")

local t = c:save(O .. "aseprite/ph/minnow.aseprite", O .. "png/ph/minnow.png")
print(GV.report(t))
