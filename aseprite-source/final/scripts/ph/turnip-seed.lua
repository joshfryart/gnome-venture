local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leafR = GV.ramp("#58a03e")
local lL = c:poly({ {31,23},{24,18},{18,8},{25,9},{30,14},{34,21} })
local lR = c:poly({ {32,23},{36,14},{42,7},{47,9},{41,17},{35,23} })
local lC = c:poly({ {30,22},{31,10},{34,6},{35,12},{34,22} })
local bulb = c:ellipse(32, 31, 12, 10)
local back = c:rect(13, 32, 51, 37)
local front = c:rect(10, 37, 54, 56)
local postL = c:rect(10, 33, 14, 56)
local postR = c:rect(50, 33, 54, 56)
local p = c:build{
  { "leafL", lL, leafR },
  { "leafR", lR, leafR },
  { "leafC", lC, leafR },
  { "back", back, "#d9a660", { gloss = false } },
  { "bulb", bulb, "#f1ece0", { gloss = { 25, 25 } } },
  { "front", front, "wood" },
  { "postL", postL, "#8a4f2a", { gloss = false } },
  { "postR", postR, "#8a4f2a", { gloss = false } },
}
-- leaf veins
for _, v in ipairs({ {29,20},{28,19},{27,18},{26,16},{25,14},{24,12},{23,11} }) do c:px(v[1], v[2], "#2e5a2c") end
for _, v in ipairs({ {35,20},{36,18},{37,16},{38,14},{40,12},{42,10} }) do c:px(v[1], v[2], "#2e5a2c") end
for y = 12, 21 do c:px(32, y, "#2e5a2c") end
-- pink streaks on bulb
local pink = "#e46a9b"
for y = 23, 27 do c:px(22 + (y-23)//3, y, pink); c:px(23 + (y-23)//3, y, pink) end
for y = 28, 33 do c:px(38, y, pink); c:px(39, y, pink) end
for y = 22, 25 do c:px(33, y, pink); c:px(34, y, pink) end
-- slat grooves on front
local groove = "#5e2f1e"
for x = 15, 49 do c:px(x, 43, groove); c:px(x, 44, groove); c:px(x, 50, groove); c:px(x, 51, groove) end
-- back rim plank line
for x = 15, 49 do c:px(x, 34, "#b07a45") end
-- nails
for _, n in ipairs({ {11,39},{51,39},{11,52},{51,52} }) do
  c:px(n[1], n[2], "#c9c5bc"); c:px(n[1]+1, n[2], "#c9c5bc"); c:px(n[1], n[2]+1, "#8b8f96"); c:px(n[1]+1, n[2]+1, "#8b8f96")
end
local t = c:save(O .. "aseprite/ph/turnip-seed.aseprite", O .. "png/ph/turnip-seed.png")
print(GV.report(t))
