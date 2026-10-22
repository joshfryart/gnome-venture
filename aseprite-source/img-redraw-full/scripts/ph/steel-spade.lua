local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- blade: flat top shoulders, rounded sides to a point
local blade = c:mask()
for y = 33, 58 do
  local tt = (y - 33) / 25
  local hw = 13 * math.sqrt(math.max(0, 1 - tt * tt * tt))
  if y >= 56 then hw = math.min(hw, (59 - y) * 1.5) end
  for x = math.floor(31.5 - hw + 0.5), math.floor(31.5 + hw + 0.5) - 1 do blade:set(x, y) end
end
blade = blade:closed(1)
local steel = GV.ramp("#8b8f96", { shade = "#5b6470", deep = "#3a424c" })
local p = c:build{
  { "shaft", c:rect(30, 9, 33, 32), "wood" },
  { "grip", c:rrect(25, 5, 38, 9, 2), GV.ramp("#8a4f2a") },
  { "blade", blade, steel, { gloss = { 22, 37 } } },
  { "collar", c:rrect(28, 29, 35, 35, 1), GV.ramp("#5b6470") },
}
-- centre ridge
c:fill(c:rect(31, 38, 32, 52), "#c9c5bc")
c:fill(c:rect(33, 39, 33, 52), "#5b6470")
-- rivet on collar
c:px(31, 31, "#c9c5bc")
local t = c:save(O .. "aseprite/ph/steel-spade.aseprite", O .. "png/ph/steel-spade.png")
print(GV.report(t))
