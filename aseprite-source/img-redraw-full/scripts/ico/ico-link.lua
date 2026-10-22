local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local ux, uy = 0.7071, -0.7071 -- axis: lower left to upper right
local function stadium(cx, cy, half, r)
  local m = c:mask()
  for i = -half * 2, half * 2 do
    local t = i / 2
    m:add(c:ellipse(cx + ux * t, cy + uy * t, r, r))
  end
  return m
end
local function ring(cx, cy)
  return stadium(cx, cy, 6, 8.5):cut(stadium(cx, cy, 6, 4))
end

local grey = ring(39, 25)
local blue = ring(25, 39)
-- lower-right crossing: grey passes over blue
local over = grey:copy():clip(blue):clip(c:poly({ {64, -1}, {65, 65}, {-1, 65} }))

c:build{
  { "grey", grey, "stone" },
  { "blue", blue, GV.ramp("#3f93b2") },
  { "over", over, "stone", { gloss = false, rim = false } },
}

local t = c:save(O .. "aseprite/ico/ico-link.aseprite", O .. "png/ico/ico-link.png")
print(GV.report(t))
