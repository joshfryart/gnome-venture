local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local D = -3

local mound = c:ellipse(32, 51 + D, 21, 7)
local top = c:ellipse(32, 49 + D, 17, 4)
local function leaf(tx, ty)
  return c:poly({ { 30, 47 + D }, { 34, 47 + D }, { tx + 3, ty + 1 + D }, { tx, ty - 1 + D }, { tx - 3, ty + 1 + D } })
end

local parts = {
  { "mound", mound, "#7a4a1f" },
  { "top", top, "#9a6b3f", { gloss = false } },
}
local tips = { { 13, 34 }, { 20, 29 }, { 51, 34 }, { 44, 29 }, { 32, 44 } }
for i, t in ipairs(tips) do
  parts[#parts + 1] = { "leaf" .. i, leaf(t[1], t[2]), (i % 2 == 1) and "moss" or GV.ramp("#4a8a3e"), { gloss = false } }
end
parts[#parts + 1] = { "head", c:ellipse(32, 26 + D, 11, 11), GV.ramp("#58a03e") }
local berries = { { 21, 39 }, { 43, 39 }, { 32, 44 }, { 27, 31 } }
for i, b in ipairs(berries) do
  parts[#parts + 1] = { "berry" .. i, c:ellipse(b[1], b[2] + D, 4, 4), GV.ramp("#e0501f", { gloss = "#ff9158" }) }
end
c:build(parts)
-- tendril curling off the head
c:fill(c:line({ { 41, 27 }, { 46, 28 }, { 48, 31 }, { 47, 34 }, { 45, 34 } }, 2), "#4a2c1a")
-- head leaf veins (diamond marks)
c:spot(c:ascii({ ".x.", "xxx", ".x." }, 34, 17), "#3f7a2e", "#7ab55c")
c:spot(c:ascii({ ".x.", "xxx", ".x." }, 28, 23), "#3f7a2e", "#7ab55c")

local t = c:save(O .. "aseprite/ph/stage-spice-4.aseprite", O .. "png/ph/stage-spice-4.png")
print(GV.report(t))
