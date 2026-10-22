local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local roof = c:poly({ {8,37}, {32,17}, {57,37} })
local door = c:rrect(17, 45, 25, 56, 4):add(c:rect(17, 50, 25, 56))
local p = c:build{
  { "smoke",  c:ellipse(44.5, 9.5, 3.5, 3), "#d6c9b6" },
  { "chimney", c:rect(41, 14, 47, 30), GV.ramp("#8b8f96") },
  { "cap",    c:rrect(39, 12, 49, 15, 1), GV.ramp("#5b6470") },
  { "pole",   c:rect(31, 9, 32, 19), "#44281c", { flat = true } },
  { "flag",   c:poly({ {33,9}, {41,12}, {33,16} }), "red", { flat = true } },
  { "wall",   c:rrect(11, 34, 53, 56, 2), "#d9a660" },
  { "roof",   roof, "red" },
  { "eave",   c:rrect(7, 35, 57, 38, 1), GV.ramp("#c66b50") },
  { "door",   door, GV.ramp("#44281c"), { gloss = false } },
  { "window", c:rect(34, 41, 44, 48), "gold", { gloss = false } },
  { "box",    c:rrect(33, 48, 46, 51, 1), "wood", { gloss = false } },
}
-- brick lines
for x = 13, 51 do
  if not door:has(x, 43) and not (x >= 33 and x <= 46) then c:px(x, 43, "#8a4f2a") end
end
-- window cross
for y = 41, 47 do c:px(39, y, "#2a1a10") end
for x = 34, 44 do c:px(x, 44, "#2a1a10") end
-- flowers
c:paint({ "p.g..q", "m.m..m" }, 36, 46, { p = "#e46a9b", g = "#e8a317", q = "#f6b8cf", m = "#4a8a3e" })
c:px(24, 51, "#e8a317")
c:seam({ {12, 54}, {52, 54} })
c:ground(32, 57, 24, 1.5)
local t = c:save(D .. "img-redraw-full/aseprite/ph/kitchen-2.aseprite", D .. "img-redraw-full/png/ph/kitchen-2.png")
print(GV.report(t))
