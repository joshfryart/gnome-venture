local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local ice = GV.ramp("#6fb6d6", { gloss = "#c8ecdc", shade = "#2f6290" })
local flake = c:mask()
local cx, cy = 31.5, 31.5
for i = 0, 5 do
  local a = math.rad(i * 60)
  local dx, dy = math.cos(a), math.sin(a)
  local ex, ey = cx + dx * 22, cy + dy * 22
  flake:add(c:line({ {cx, cy}, {ex, ey} }, 4))
  -- V barbs near tip
  local bx, by = cx + dx * 14, cy + dy * 14
  for _, s in ipairs({ 1, -1 }) do
    local b = a + s * math.rad(50)
    flake:add(c:line({ {bx, by}, {bx + math.cos(b) * 6, by + math.sin(b) * 6} }, 3))
  end
end
flake:add(c:ellipse(cx, cy, 8, 8))
c:build{ { "flake", flake, ice, { gloss = { 26, 26 } } } }
local t = c:save(O .. "aseprite/ico/ico-snowflake.aseprite", O .. "png/ico/ico-snowflake.png")
print(GV.report(t))
