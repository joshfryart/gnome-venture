local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local standR = GV.ramp("#c4925f")
local feetR = GV.ramp("#b6814d")
local p = c:build{
  { "feet",  c:rect(18, 53, 22, 57):add(c:rect(42, 53, 46, 57)), feetR, { flat = true } },
  { "stand", c:rrect(13, 48, 51, 54, 2), standR },
  { "ring1", c:rrect(14, 37, 50, 50, 6), "gold" },
  { "ring2", c:rrect(18, 27, 46, 40, 6), "gold" },
  { "ring3", c:rrect(22, 18, 42, 30, 5), "gold" },
  { "knob",  c:rrect(29, 9, 35, 14, 2), GV.ramp("#b8661a"), { flat = true } },
  { "cap",   c:ellipse(32, 17, 8.5, 5.5), "gold" },
}
-- entrance arch
c:fill(c:rrect(27, 41, 37, 49, 4):cut(c:rect(27, 46, 37, 49)):add(c:rect(27, 45, 37, 49)), "#44281c")
-- ring grooves
c:seam({ {17, 44}, {26, 44} }); c:seam({ {38, 44}, {47, 44} })
c:seam({ {21, 34}, {43, 34} })
c:seam({ {25, 24}, {39, 24} })
-- bees
local function bee(x, y)
  c:part(c:ellipse(x, y, 3, 2.5), GV.ramp("#f08a24"), { flat = true })
  c:fill(c:rect(x, y - 2, x + 1, y + 2), "#2a1a10")
  c:part(c:ellipse(x - 1, y - 3, 1.5, 1), "#c8ecdc", { flat = true })
  c:px(x - 2, y, "#2a1a10")
end
bee(10, 27); bee(54, 33)
c:ground(32, 58, 17, 1)
local t = c:save(O .. "aseprite/ph/beehive-1.aseprite", O .. "png/ph/beehive-1.png")
print(GV.report(t))
