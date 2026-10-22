local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local outer = c:ellipse(31.5, 45, 21.5, 8)
local inner = c:ellipse(31.5, 43, 17, 5.5)
local mound = c:ellipse(31.5, 41, 13, 13):cut(c:rect(0, 43, 63, 63))
mound:add(c:ellipse(31.5, 41, 13, 2))
local lumpL = c:ellipse(25, 36, 4, 4)
local lumpR = c:ellipse(38.5, 34, 4.5, 4.5)
local fruit = c:ellipse(31.5, 27.5, 3.5, 3.5)

local star = {}
for i = 0, 9 do
  local a = math.rad(-90 + i * 36)
  local r = (i % 2 == 0) and 7.5 or 3.2
  star[#star + 1] = { 31.5 + r * math.cos(a), 16 + r * math.sin(a) }
end

local p = c:build{
  { "outer", outer, GV.ramp("#d6c9b6"), { gloss = false } },
  { "inner", inner, GV.ramp("#f4f0e0"), { gloss = { 20, 42 } } },
  { "mound", mound, "moss", { gloss = false } },
  { "lumpL", lumpL, GV.ramp("#58a03e"), { gloss = false } },
  { "lumpR", lumpR, "moss", { gloss = false } },
  { "fruit", fruit, "gold", { gloss = false } },
  { "star", c:poly(star), "gold", { gloss = false } },
}
c:px(30, 26, GV.R.gold.gloss); c:px(29, 27, GV.R.gold.gloss)
c:px(30, 13, GV.R.gold.gloss)
c:seam({ {14, 49}, {22, 52}, {32, 53}, {42, 52}, {49, 49} })

local t = c:save(O .. "aseprite/ph/feast-steppe-table.aseprite", O .. "png/ph/feast-steppe-table.png")
print(GV.report(t))
