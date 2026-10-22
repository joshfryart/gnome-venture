local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "scene" }

local soil = c:rect(0, 38, 63, 44)
-- tileable: period 64 / 10 puffs = 6.4
local hedge = c:rect(0, 31, 63, 41)
for i = -1, 10 do
  local x = i * 6.4
  hedge:add(c:ellipse(x, 30, 4.5, 6))
end
hedge:clip(c:rect(0, 0, 63, 63))

local p = c:build{
  { "soil", soil, "soil", { rim = false, gloss = false } },
  { "hedge", hedge, "moss", { gloss = false, cres = 5, deep = 2 } },
}
-- clipped highlight line and puff glosses
for i = 0, 9 do
  local x = math.floor(i * 6.4 + 0.5)
  c:paint({ ".gg", "g.." }, x - 2, 26, { g = "#c8d77a" })
  c:px(x + 2, 27, "#a4b86a")
end
for x = 0, 63 do
  if c:get(x, 30) == GV.R.moss.base or true then
    if x % 3 ~= 2 then c:px(x, 32, "#a4b86a") end
  end
end
-- leaf ticks in the body for texture (sparse, regular)
for i = 0, 9 do
  local x = math.floor(i * 6.4 + 3.5)
  c:px(x, 35, "#4a8a3e"); c:px(x + 1, 34, "#4a8a3e")
end

local t = c:save(O .. "aseprite/ph/box-hedge-straight.aseprite", O .. "png/ph/box-hedge-straight.png")
print(GV.report(t))
