local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- low lumpy mound: wide base + a peaked top with a side lump
local mound = c:ellipse(31.5, 46, 20, 16):cut(c:rect(0, 47, 63, 63))
mound:add(c:ellipse(28, 32, 9, 7))
mound:add(c:ellipse(38, 36, 9, 6))
mound:add(c:rrect(12, 40, 51, 46, 4))
mound = mound:closed(3)
c:build{
  { "mound", mound, GV.ramp("#f1ece0"), { pale = true, gloss = { 22, 30 } } },
}
-- darker ridge arc
local ridge = {}
for x = 16, 48, 2 do
  local u = (x - 32) / 16
  ridge[#ridge + 1] = { x, math.floor(35 + 8 * u * u + 0.5) }
end
local rm = c:line(ridge, 2):clip(mound:shrink(2))
c:fill(rm, "#d6c9b6")
-- sparkles: plus shapes white with gold edge
local function spark(x, y)
  c:paint({
    ".g.",
    "gwg",
    ".g.",
  }, x - 1, y - 1, { g = "#f5cf6a", w = "#ffffff" })
end
local function big(x, y)
  c:paint({
    "..g..",
    ".gwg.",
    "gwwwg",
    ".gwg.",
    "..g..",
  }, x - 2, y - 2, { g = "#f5cf6a", w = "#ffffff" })
end
big(26, 36); big(38, 32); spark(33, 41); spark(19, 41); spark(45, 41)
-- floating flecks above
spark(14, 27); spark(49, 22); c:px(42, 17, "#f5cf6a"); c:px(20, 20, "#f5cf6a")
c:ground(31.5, 48, 17, 1.5)
local t = c:save(O .. "aseprite/ph/wing-dust.aseprite", O .. "png/ph/wing-dust.png")
print(GV.report(t))
