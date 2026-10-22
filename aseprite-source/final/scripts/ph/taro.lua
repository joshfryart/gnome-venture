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
      local hw = (W/2) * math.sin(math.pi * t^0.8) ^ 0.7
      if d <= hw then m:set(x, y) end
    end
  end end
  return m
end
-- corm: inverted teardrop, flat-ish top at y20, belly y~34, point at y57
local corm = c:mask()
for y = 20, 57 do
  local hw
  if y <= 33 then
    local u = (y - 20) / 13
    hw = 7.5 + 3 * math.sin(u * math.pi / 2)
  else
    local u = (y - 33) / 24
    hw = 10.5 * (1 - u^1.6) ^ 0.75
  end
  for x = 0, 63 do
    if math.abs(x + 0.5 - 32) <= hw then corm:set(x, y) end
  end
end
local lilac = GV.ramp("#b9a6e6", { shade = "#7b66b4", deep = "#3e2f66" })
local leafR = GV.ramp("#58a03e", { shade = "#4a8a3e" })
local p = c:build{
  { "corm", corm, lilac, { gloss = { 26, 26 } } },
  { "lleaf", leaf(31, 23, 25, 6, 7), leafR },
  { "rleaf", leaf(33, 23, 39, 6, 7), leafR },
}
-- ring bands (2px arcs)
local ring = "#5a4a8a"
c:line({ {25, 31}, {28, 32}, {32, 32} }, 2)
for _, q in ipairs({ {25,31},{26,31},{27,32},{28,32},{29,32},{30,32},{31,32},{25,32},{26,32},{27,33},{28,33},{29,33},{30,33},{31,33} }) do c:px(q[1], q[2], ring) end
for _, q in ipairs({ {33,41},{34,41},{35,41},{36,40},{37,40},{38,39},{33,42},{34,42},{35,42},{36,41},{37,41},{38,40} }) do c:px(q[1], q[2], ring) end
-- midribs
for y = 9, 21 do local x = math.floor(31 - (y - 23) * (-6/17) + 0.5) - 0; c:px(math.floor(25 + (y-6)*(6/17) + 0.5), y, "#2f5a2a") end
for y = 9, 21 do c:px(math.floor(39 - (y-6)*(6/17) + 0.5), y, "#2f5a2a") end
local t = c:save(O .. "aseprite/ph/taro.aseprite", O .. "png/ph/taro.png")
print(GV.report(t))
