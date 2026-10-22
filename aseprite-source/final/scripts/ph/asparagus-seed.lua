local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local crate = c:poly({ {17, 13}, {47, 13}, {51, 17}, {51, 54}, {13, 54}, {13, 17} })
local panel = c:rrect(18, 22, 45, 47, 3)
local toprail = c:rect(13, 17, 50, 21)
local botrail = c:rect(13, 48, 50, 53)

-- diagonal pill seed
local ax, ay, bx, by, R = 25, 41, 38, 30, 4.2
local dx, dy = bx - ax, by - ay
local L2 = dx * dx + dy * dy
local seed, tip = c:mask(), c:mask()
for y = 0, 63 do for x = 0, 63 do
  local t = ((x - ax) * dx + (y - ay) * dy) / L2
  local tc = math.max(0, math.min(1, t))
  local px, py = ax + tc * dx, ay + tc * dy
  if (x - px) ^ 2 + (y - py) ^ 2 <= R * R then
    seed:set(x, y)
    if t > 0.85 then tip:set(x, y) end
  end
end end
seed:cut(tip)

c:build{
  { "crate", crate,   GV.ramp("#d9a660") },
  { "panel", panel,   GV.ramp("#f4f0e0") },
  { "top",   toprail, "wood" },
  { "bot",   botrail, "wood" },
  { "seed",  seed,    GV.ramp("#dcb06a") },
  { "tip",   tip,     GV.ramp("#4a8a3e") },
}
c:fill(c:line({ {27, 42}, {36, 35} }, 1), "#c4925f")
c:seam({ {15, 19}, {48, 19} })
c:fill(c:rect(24, 50, 25, 51), "#8c4a1a")
c:fill(c:rect(31, 50, 32, 51), "#8c4a1a")
c:fill(c:rect(38, 50, 39, 51), "#8c4a1a")

local t = c:save(O .. "aseprite/ph/asparagus-seed.aseprite", O .. "png/ph/asparagus-seed.png")
print(GV.report(t))
