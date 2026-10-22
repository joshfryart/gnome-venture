local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local stone = GV.ramp("#8b8f96")

-- keep with a battlemented top (3 small merlons)
local keep = c:rect(19, 30, 45, 55)
for _, x in ipairs({ 22, 30, 38 }) do keep:add(c:rect(x, 25, x + 4, 30)) end

-- towers with two merlons each
local lt = c:rect(9, 17, 20, 55)
lt:add(c:rect(8, 10, 12, 17)); lt:add(c:rect(17, 10, 21, 17))
local rt = c:rect(44, 17, 55, 55)
rt:add(c:rect(43, 10, 47, 17)); rt:add(c:rect(52, 10, 56, 17))

local door = c:rect(26, 43, 38, 55):add(c:ellipse(32, 43, 6, 6))

local p = c:build{
  { "keep", keep, GV.ramp("#e8dcc0") },
  { "lt", lt, stone },
  { "rt", rt, stone },
  { "door", door, GV.ramp("#6a4528"), { gloss = false } },
}

-- mortar seams under the battlements
c:seam({ {9,18}, {20,18} }); c:seam({ {44,18}, {55,18} })
-- stone brick dashes
local M = stone.shade
for _, b in ipairs({ {11,26,15},{14,34,18},{11,42,15},{14,49,18},{46,26,50},{49,34,53},{46,42,50},{49,49,53} }) do
  c:fill(c:rect(b[1], b[2], b[3], b[2]), M)
end
-- arrow-slit windows
c:fill(c:rect(14, 22, 15, 25), "#2a1a10"); c:fill(c:rect(49, 22, 50, 25), "#2a1a10")
c:fill(c:rect(31, 33, 33, 37), "#3e2f66")
-- door planks and knob
c:fill(c:line({ {32,39},{32,55} }, 1), "#3e2614")
c:px(35, 49, "#e8a317"); c:px(29, 49, "#e8a317")

local t = c:save(O .. "aseprite/ico/ico-castle.aseprite", O .. "png/ico/ico-castle.png")
print(GV.report(t))
