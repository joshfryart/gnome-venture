local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local function leaf(ax, ay, bx, by, W)
  local m = c:mask()
  local dx, dy = bx - ax, by - ay
  local L = math.sqrt(dx*dx + dy*dy)
  for y = 0, 63 do for x = 0, 63 do
    local px, py = x + 0.5 - ax, y + 0.5 - ay
    local t = (px*dx + py*dy) / (L*L)
    local d = math.abs(px*dy - py*dx) / L
    if t >= 0 and t <= 1 then
      local hw = (W/2) * math.sin(math.pi * t^0.75) ^ 0.7
      if d <= hw then m:set(x, y) end
    end
  end end
  return m
end
local body = c:ellipse(32, 37, 15, 14.5)
local p = c:build{
  { "stem", c:rrect(30, 14, 33, 24, 1), "#2e5a2c", { flat = true } },
  { "fruit", body, GV.ramp("#f08a24", { rim = "#ffc27a" }), { gloss = { 24, 28 } } },
  { "leaf", leaf(33, 19, 44, 5, 9), GV.ramp("#58a03e", { shade = "#4a8a3e" }) },
}
-- pucker crescent along the bottom
c:paint({
  "..p.........p..",
  "...pp.....pp...",
  ".....ppppp.....",
}, 25, 45, { p = "#e0501f" })
-- leaf midrib
c:line({ {35, 16}, {38, 12}, {41, 8} }, 1)
local t = c:save(O .. "aseprite/ph/tangor.aseprite", O .. "png/ph/tangor.png")
print(GV.report(t))
