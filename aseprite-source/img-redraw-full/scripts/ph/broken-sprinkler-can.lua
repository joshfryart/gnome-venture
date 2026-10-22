local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tin = GV.ramp("#8c4a1a", { shade = "#8a4f2a" })
local lite = GV.ramp("#c4925f", { rim = "#d9a660" })
local body = c:poly({ {9,29}, {37,29}, {33,54}, {13,54} })
body:cut(c:rect(9, 41, 10, 44))          -- chip left
body:cut(c:rect(32, 48, 36, 50))         -- chip lower right
body:cut(c:rect(34, 29, 37, 31))         -- chipped top corner
local handle = c:line({ {12,30}, {14,23}, {18,19}, {23,17}, {28,19}, {32,23}, {34,30} }, 3)
local spout = c:line({ {33,42}, {44,31} }, 4)
local tip = c:line({ {47,27}, {50,24} }, 3)  -- snapped loose end
local rimband = c:rect(10, 29, 35, 31)
local p = c:build{
  { "handle", handle, lite },
  { "spout", spout, lite },
  { "tip", tip, GV.ramp("#c4925f", { rim = "#f0d49a" }), { flat = true } },
  { "body", body, tin, { light = body } },
  { "band", rimband:clip(body), lite, { flat = true } },
  { "drop", c:ellipse(52, 19, 2, 2.5), GV.ramp("#a9d6ea", { gloss = "#c8ecdc" }), { flat = true } },
}
local crack = c:line({ {22,16}, {25,23}, {21,29}, {26,37}, {22,45}, {24,52} }, 1)
crack:add(c:line({ {26,37}, {29,39} }, 1))
crack:clip(p.body.m:copy():add(p.handle.m))
c:fill(crack, "#2a1a10")
local t = c:save(O .. "aseprite/ph/broken-sprinkler-can.aseprite", O .. "png/ph/broken-sprinkler-can.png")
print(GV.report(t))
