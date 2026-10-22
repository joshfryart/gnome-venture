local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- stalk with a flared foot
local stalk = c:rrect(24, 36, 40, 55, 5)
stalk:add(c:rrect(22, 51, 42, 56, 2))

-- tall pointed cap: ellipse body + pointed crown
local cap = c:ellipse(32, 29, 17, 15)
cap:add(c:poly({ {32, 6}, {19, 20}, {45, 20} }))
cap:add(c:ellipse(32, 16, 10, 10))
cap:cut(c:rect(0, 44, 63, 63))

local p = c:build{
  { "stalk", stalk, "#f1ece0" },
  { "cap", cap, "#c99a45", { gloss = { 22, 15 } } },
}

-- skirt lip
local skirt = c:rect(0, 42, 63, 43):clip(cap)
c:fill(skirt, "#a8582f")

-- honeycomb ridges (light lines between pit rows)
c:fill(c:rect(17, 21, 47, 21):clip(cap:shrink(2)), "#e8c070")
c:fill(c:rect(16, 30, 48, 30):clip(cap:shrink(2)), "#e8c070")

-- 7 pits in staggered rows: 2 / 3 / 2
local pits = { {27.5, 15}, {36.5, 15}, {21.5, 25}, {31.5, 25}, {41.5, 25}, {25.5, 35}, {37.5, 35} }
for _, q in ipairs(pits) do
  local m = c:ellipse(q[1], q[2], 1.5, 2)
  c:fill(m, "#7a4a1f")
  local x0 = math.floor(q[1] - 1.5 + 0.5)
  c:px(x0 + 1, math.floor(q[2]) + 3, "#e8c070")
  c:px(x0 + 2, math.floor(q[2]) + 3, "#e8c070")
end

local t = c:save(O .. "aseprite/ph/morel.aseprite", O .. "png/ph/morel.png")
print(GV.report(t))
