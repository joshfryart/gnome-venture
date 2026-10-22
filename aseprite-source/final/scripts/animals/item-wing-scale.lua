local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- pointed-top shield: rounded base + tapered top
local body = c:ellipse(32.5, 37, 20, 19)
body:add(c:poly({ {32, 7}, {34, 7}, {53, 34}, {12, 34} }))
body:add(c:poly({ {31, 8}, {35, 8}, {50, 26}, {15, 26} }))
body = body:closed(2)

local R = GV.ramp("#f08a24")   -- ember family
local p = c:build{
  { "scale", body, R, { gloss = { 20, 22 } } },
}

-- right-half shade overlay (two-tone shield)
body:each(function(x, y)
  if x >= 34 and c:get(x, y) == R.base then c:px(x, y, "#e0501f") end
end)

-- ribs: central spine + 3 vein pairs, gold rim colour
local G = "#f5cf6a"
c:fill(c:line({ {32.5, 14}, {32.5, 51} }, 2), G)
local veins = {
  { {32, 22}, {23, 15} },
  { {32, 32}, {19, 25} },
  { {32, 42}, {21, 35} },
}
for _, v in ipairs(veins) do
  c:fill(c:line(v, 2), G)
  c:fill(c:line({ {65 - v[1][1], v[1][2]}, {65 - v[2][1], v[2][2]} }, 2), G)
end

-- two dark spots
c:spot(c:ellipse(23.5, 32.5, 3, 3))
c:spot(c:ellipse(41.5, 32, 2.5, 2.5))

local t = c:save(D .. "img-redraw-hybrid/aseprite/animals/item-wing-scale.aseprite",
                 D .. "img-redraw-hybrid/png/animals/item-wing-scale.png")
print(GV.report(t))
