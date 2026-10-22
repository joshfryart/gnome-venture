local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- pointed lens petal pivoting at (px,py), rotated a degrees from straight up
local function petal(px, py, a, len, wid)
  local m = c:mask()
  local r = math.rad(a)
  local sx, sy = math.sin(r), -math.cos(r)
  local h = len / 2
  local cx, cy = px + sx * h, py + sy * h
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x + 0.5 - (cx + 0.5), y + 0.5 - (cy + 0.5)
    local v = dx * sx + dy * sy
    local u = dx * sy - dy * sx
    if math.abs(v) <= h then
      local t = v / h
      local w = wid * (1 - t * t) ^ 0.7
      if t < 0 then w = math.max(w, wid * 0.55) end
      if math.abs(u) <= w then m:set(x, y) end
    end
  end end
  return m
end

local stem = c:rect(31, 36, 33, 54)
local p = c:build{
  { "stem", stem, GV.ramp("#2f5a2a"), { flat = true } },
  { "pL2", petal(32, 34, -66, 22, 5), "moss" },
  { "pR2", petal(32, 34, 66, 22, 5), "moss" },
  { "pL1", petal(32, 34, -33, 23, 5), "moss" },
  { "pR1", petal(32, 34, 33, 23, 5), "moss" },
  { "pC", petal(32, 35, 0, 25, 5), GV.ramp("#6a9a3a") },
  { "disc", c:ellipse(32, 33, 5, 5), GV.ramp("#3f93b2") },
}
-- fuzz at petal tips
for _, q in ipairs({ {32, 12}, {19, 17}, {45, 17}, {13, 25}, {51, 25} }) do c:px(q[1], q[2], "#c8d77a") end
c:ground(32, 55, 7, 1)
local t = c:save(O .. "aseprite/ph/edelweiss.aseprite", O .. "png/ph/edelweiss.png")
print(GV.report(t))
