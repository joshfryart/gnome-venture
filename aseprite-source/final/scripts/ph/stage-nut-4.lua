local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local mound = c:ellipse(31.5, 50, 20, 6)
local trunk = c:rrect(29, 26, 34, 47, 1)
local backL = c:ellipse(19, 26, 9, 8)
local backR = c:ellipse(44, 25, 9, 8)
local main  = c:ellipse(31.5, 18, 14, 12)

local p = c:build{
  { "mound", mound, "#8c4a1a" },
  { "trunk", trunk, "wood" },
  { "backL", backL, GV.ramp("#4a8a3e") },
  { "backR", backR, GV.ramp("#58a03e") },
  { "main",  main,  "moss" },
}
-- soil top lighter band
c:paint({ "..aaaaaaaaaaaaaaaaaaaaaa..", "aaaaaaaaaaaaaaaaaaaaaaaaaa" }, 19, 45, { a = "#a5663a" })
-- trunk lit edge and grain
for y = 31, 44 do c:px(30, y, "#d9a660") end
c:px(32, 36, "#8a4f2a"); c:px(32, 37, "#8a4f2a"); c:px(33, 42, "#8a4f2a")

-- nuts: 3x3 brown with gloss px
local nuts = { {16, 25}, {37, 11}, {31, 23}, {25, 13}, {45, 24} }
for _, n in ipairs(nuts) do
  local x, y = n[1], n[2]
  c:paint({ ".n.", "nnn", "nsn", ".s." }, x, y, { n = "#a5663a", s = "#7a4a1f" })
  c:px(x, y + 1, "#ecc58a")
end
local t = c:save(O .. "aseprite/ph/stage-nut-4.aseprite", O .. "png/ph/stage-nut-4.png")
print(GV.report(t))
