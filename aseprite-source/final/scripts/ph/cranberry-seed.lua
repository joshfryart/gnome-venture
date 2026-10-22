local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:ellipse(31.5, 39, 21, 15)
local foot = c:rrect(21, 50, 42, 55, 2)
local lid = c:ellipse(31.5, 25, 17, 9):cut(c:rect(0, 26, 63, 63))
local rim = c:rrect(11, 25, 52, 29, 2)
local knob = c:ellipse(31.5, 13.5, 4, 4)

local p = c:build{
  { "foot", foot, "wood" },
  { "body", body, "#e9d9b0" },
  { "knob", knob, "gold", { cres = 2 } },
  { "lid",  lid,  "#d6322b" },
  { "rim",  rim,  GV.ramp("#ae2a2a"), { gloss = false, cres = 2 } },
}
c:seam({ {14,27}, {49,27} })
-- sprig
c:fill(c:line({ {31,33}, {32,30} }, 2), "#2f5a2a")
c:paint({ "..l..", ".lll.", "lllll", ".lll." , "..l.."}, 33, 29, { l = "#58a03e" })
c:px(35, 30, "#a4b86a")
-- berries
local reds = { GV.ramp("#d6322b"), GV.ramp("#a8241f") }
local berries = { {26,37}, {37,37}, {31.5,34}, {22,43}, {31.5,43}, {41,43} }
for i, b in ipairs(berries) do
  local m = c:ellipse(b[1], b[2], 3.5, 3.5)
  local r = reds[(i % 2) + 1]
  c:fill(m:grow(1), "#4a2c1a")
end
for i, b in ipairs(berries) do
  local m = c:ellipse(b[1], b[2], 3.5, 3.5)
  local r = reds[(i % 2) + 1]
  c:fill(m, r.base)
  c:fill(m:cut(m:shift(-1, -1)), r.shade)
  c:px(math.floor(b[1]) - 1, b[2] - 2, r.gloss)
end
c:ground(32, 57, 17, 2.5)

local t = c:save(O .. "aseprite/ph/cranberry-seed.aseprite", O .. "png/ph/cranberry-seed.png")
print(GV.report(t))
