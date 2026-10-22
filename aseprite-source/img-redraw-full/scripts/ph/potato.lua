local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(32, 39, 21, 11)
body:add(c:ellipse(43, 33, 10, 8)):add(c:ellipse(21, 43, 10, 8))
local lump = c:ellipse(43, 42, 8, 6):clip(body:shrink(2))
local s1 = c:line({ {28, 29}, {26, 22}, {24, 15} }, 2)
local s2 = c:line({ {36, 27}, {38, 21}, {40, 15} }, 2)
local l1 = c:ellipse(22, 13, 3, 2)
local l2 = c:ellipse(42, 13, 3, 2)
local p = c:build{
  { "s1", s1, GV.ramp("#7ab55c"), { flat = true } },
  { "s2", s2, GV.ramp("#7ab55c"), { flat = true } },
  { "body", body, GV.ramp("#c9a96e"), { cres = 4 } },
  { "lump", lump, GV.ramp("#b8935a"), { gloss = false, rim = false, cres = 2 } },
  { "l1", l1, GV.ramp("#4a8a3e"), { cres = 2, gloss = false } },
  { "l2", l2, GV.ramp("#4a8a3e"), { cres = 2, gloss = false } },
}
-- eye dimples: dark pit with lit bottom rim
for _, d in ipairs({ {18, 42}, {33, 45}, {45, 29} }) do
  local x, y = d[1], d[2]
  c:paint({ "ppp", ".rr" }, x, y, { p = "#7a4a1f", r = "#f9d49c" })
end
c:px(26, 36, "#9a6b3f"); c:px(38, 35, "#9a6b3f"); c:px(48, 37, "#9a6b3f")
local t = c:save(O .. "aseprite/ph/potato.aseprite", O .. "png/ph/potato.png")
print(GV.report(t))
