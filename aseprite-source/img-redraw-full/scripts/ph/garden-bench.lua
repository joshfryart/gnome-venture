local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local legs = c:rrect(13, 22, 18, 54, 1):add(c:rrect(45, 22, 50, 54, 1))
local wood2 = GV.ramp("#c4925f")
local p = c:build{
  { "legs", legs, GV.ramp("#5e2f1e"), { gloss = false } },
  { "seat", c:rrect(9, 35, 54, 43, 3), "wood" },
  { "back", c:rrect(7, 17, 56, 27, 3), wood2 },
}
-- back posts hidden: gap between planks shows legs? keep a clean gap; grain lines

for _, s in ipairs({ { {14,21},{28,21} }, { {34,24},{50,24} } }) do
  for x = s[1][1], s[2][1] do c:px(x, s[1][2], "#8a4f2a") end
end
for _, s in ipairs({ { {16,38},{30,38} }, { {36,40},{48,40} } }) do
  for x = s[1][1], s[2][1] do c:px(x, s[1][2], "#8a4f2a") end
end
-- gold pins near plank ends
c:paint({ "gg", "gG" }, 10, 21, { g = "#f5cf6a", G = "#e8a317" })
c:paint({ "gg", "gG" }, 52, 21, { g = "#f5cf6a", G = "#e8a317" })
c:paint({ "gg", "gG" }, 12, 38, { g = "#f5cf6a", G = "#e8a317" })
c:paint({ "gg", "gG" }, 50, 38, { g = "#f5cf6a", G = "#e8a317" })
c:ground(31.5, 55, 24, 1.5)
local t = c:save(O .. "aseprite/ph/garden-bench.aseprite", O .. "png/ph/garden-bench.png")
print(GV.report(t))
