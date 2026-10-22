local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- rotated leaf: ellipse whose base sits at the pivot
local function leaf(px, py, deg, rx, ry)
  local a = math.rad(deg)
  local dx, dy = math.sin(a), -math.cos(a)
  local cx, cy = px + dx * ry, py + dy * ry
  local m = c:mask()
  for y = 0, 63 do for x = 0, 63 do
    local u, v = x - cx, y - cy
    local along = u * dx + v * dy
    local across = u * dy - v * dx
    local t = along / ry
    local w = rx * math.sqrt(math.max(0, 1 - t * t)) * (t > 0 and (1 - 0.25 * t) or 1)
    if t * t <= 1 and math.abs(across) <= w + 0.25 then m:set(x, y) end
  end end
  return m
end
local P = { 32, 35 }
local outerL = leaf(P[1], P[2], -66, 6.5, 10.5)
local outerR = leaf(P[1], P[2], 66, 6.5, 10.5)
local midL = leaf(P[1], P[2], -34, 6.5, 12)
local midR = leaf(P[1], P[2], 34, 6.5, 12)
local mid = leaf(P[1], P[2], 0, 6.5, 13)
local all = outerL:copy():add(outerR):add(midL):add(midR):add(mid)
local p = c:build{
  { "stem", c:line({ { 31, 55 }, { 31, 36 } }, 3), "#2e5a2c", { flat = true } },
  { "outerL", outerL, "moss", { light = all } },
  { "outerR", outerR, "moss", { light = all } },
  { "midL", midL, "moss", { light = all } },
  { "midR", midR, "moss", { light = all } },
  { "mid", mid, "#58a03e", { light = all } },
  { "berry", c:ellipse(32, 34, 5, 5), "#7a5cc0" },
}
-- leaf veins
c:fill(c:line({ { 32, 30 }, { 32, 15 } }, 1), "#3f7a30")
c:ground(32, 56, 10, 1.5)
local t = c:save(O .. "aseprite/ph/sea-grapes.aseprite", O .. "png/ph/sea-grapes.png")
print(GV.report(t))
