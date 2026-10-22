local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bark = GV.ramp("#f1ece0", { shade = "#c9a96e", deep = "#9a6b3f", rim = "#f5b860" })
c:build{
  { "lower", c:rrect(18, 32, 53, 44, 4), bark },
  { "upper", c:rrect(10, 20, 48, 31, 4), bark },
}
-- end ring on the lower log's right end
c:fill(c:ellipse(49.5, 38, 2.5, 4.5), "#d9a660")
c:fill(c:ellipse(49.5, 38, 1.5, 3), "#ecc58a")
c:fill(c:rect(49, 37, 50, 39), "#b07a45")
local S = "#2a1a10"
-- birch scars: short dark dashes
for _, d in ipairs({ {14, 24, 5}, {24, 27, 4}, {33, 23, 6}, {42, 27, 3},
                     {22, 36, 6}, {32, 40, 4}, {39, 35, 4} }) do
  c:fill(c:rect(d[1], d[2], d[1] + d[3] - 1, d[2] + 1), S)
end
c:ground(32, 47, 22, 1.5)
local t = c:save(O .. "aseprite/ph/birch-log.aseprite", O .. "png/ph/birch-log.png")
print(GV.report(t))
