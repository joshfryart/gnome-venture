local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local cx, cy = 31.5, 31.5
-- gear body: fat disc + eight chunky square teeth
local gear = c:ellipse(cx, cy, 18.5, 18.5)
for i = 0, 7 do
  local a = i * math.pi / 4
  local dx, dy = math.cos(a), math.sin(a)
  local px, py = -dy, dx
  local hw, r0, r1 = 4.5, 12, 26
  local pts = {
    { cx + 0.5 + dx * r0 + px * hw, cy + 0.5 + dy * r0 + py * hw },
    { cx + 0.5 + dx * r1 + px * hw, cy + 0.5 + dy * r1 + py * hw },
    { cx + 0.5 + dx * r1 - px * hw, cy + 0.5 + dy * r1 - py * hw },
    { cx + 0.5 + dx * r0 - px * hw, cy + 0.5 + dy * r0 - py * hw },
  }
  for _, p in ipairs(pts) do p[1] = math.floor(p[1] + 0.5); p[2] = math.floor(p[2] + 0.5) end
  gear:add(c:poly(pts))
end
local hub = c:ellipse(cx, cy, 8, 8)
local p = c:build{
  { "gear", gear, GV.ramp("#968f96"), { gloss = { 17, 17 } } },
  { "hub", hub, GV.ramp("#f1ece0"), { contour = "#5b6470", contact = false } },
}
-- 1 px warm inner ring on the hub's shaded half
hub:shrink(2):edge():each(function(x, y)
  if (x - cx) + (y - cy) > 2 then c:px(x, y, "#d6c9b6") end
end)
local t = c:save(D .. "img-redraw-full/aseprite/ph/nav-account.aseprite", D .. "img-redraw-full/png/ph/nav-account.png")
print(GV.report(t))
