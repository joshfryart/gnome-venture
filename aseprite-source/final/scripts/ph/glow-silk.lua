local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local kite = c:poly({ {32, 5}, {51, 23}, {32, 50}, {13, 23} })
local p = c:build{
  { "tail", c:line({ {32, 47}, {33, 51}, {34, 53} }, 2), "#f5cf6a", { flat = true } },
  { "kite", kite, "#b0bc66", { gloss = { 22, 17 } } },
}
-- lit left facet (upper-left triangle), keep rim/outline intact
local facet = c:poly({ {32, 7}, {32, 23}, {16, 23} }):clip(kite:shrink(1))
c:fill(facet, "#c8d77a")
-- centre facet edges
c:fill(c:line({ {32, 6}, {25, 23}, {32, 47} }, 1), "#a4b86a")
c:fill(c:line({ {32, 6}, {39, 23}, {32, 47} }, 1), "#8a9a4a")
-- thread-wind strands across lower half
local inner = kite:shrink(2)
local wind = c:mask()
for k = 0, 5 do
  local y0 = 28 + k * 4
  for i = 0, 40 do
    local x, y = 12 + i, y0 + math.floor(i * 0.35) - 7
    wind:set(x, y); wind:set(x, y + 1)
  end
end
wind:clip(inner):cut(c:rect(0, 0, 63, 25))
c:fill(wind, "#6a9a3a")
-- girdle
c:fill(c:rect(14, 23, 50, 24):clip(kite:shrink(1)), "#4a8a3e")
c:gloss(kite, GV.ramp("#b0bc66"), { 22, 16 })
-- thread tail at bottom tip
c:px(33, 52, "#e8a317")
local t = c:save(O .. "aseprite/ph/glow-silk.aseprite", O .. "png/ph/glow-silk.png")
print(GV.report(t))
