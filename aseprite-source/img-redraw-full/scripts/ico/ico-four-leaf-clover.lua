local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local CX, CY = 31.5, 29.5
local function inHeart(u, v)
  local L, R, S = 15, 6.2, 4.6
  if (u - L) ^ 2 + (v - S) ^ 2 <= R * R then return true end
  if (u - L) ^ 2 + (v + S) ^ 2 <= R * R then return true end
  if u >= 1.5 and u <= L and math.abs(v) <= (u - 1.5) * (S + R - 0.6) / (L - 1.5) then return true end
  return false
end
local function heart(dir)
  local m = c:mask()
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - CX, y - CY
    local u, v
    if dir == "up" then u, v = -dy, dx
    elseif dir == "down" then u, v = dy, dx
    elseif dir == "left" then u, v = -dx, dy
    else u, v = dx, dy end
    if inHeart(u, v) then m:set(x, y) end
  end end
  return m
end

local stem = c:line({ {33, 33}, {37, 37}, {41, 41}, {44, 45}, {46, 49}, {46, 52}, {44, 54} }, 4)

local p = c:build{
  { "stem", stem, GV.ramp("#2f5a2a") },
  { "bottom", heart("down"), GV.ramp("#4a8a3e") },
  { "right", heart("right"), GV.ramp("#4a8a3e") },
  { "left", heart("left"), GV.ramp("#4a8a3e") },
  { "top", heart("up"), GV.ramp("#4a8a3e") },
}
-- centre dot hiding the seams
c:part(c:rrect(30, 28, 33, 31, 1), GV.ramp("#6a9a3a"), { flat = true })
-- leaf veins (pale midribs)
local vein = "#7ab55c"
c:fill(c:rect(31, 15, 32, 23), vein)
c:fill(c:rect(15, 29, 23, 30), vein)
c:fill(c:rect(40, 29, 48, 30), vein)
c:fill(c:rect(31, 36, 32, 44), vein)

local t = c:save(B .. "aseprite/ico/ico-four-leaf-clover.aseprite", B .. "png/ico/ico-four-leaf-clover.png")
print(GV.report(t))
