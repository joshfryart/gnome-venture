local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local wood = GV.ramp("#a5663a", { gloss = "#ecc58a", shade = "#8a4f2a" })
local ys = { 12, 28, 44 }
c:build{
  { "top", c:rrect(9, 12, 55, 21, 4), wood },
  { "mid", c:rrect(9, 28, 55, 37, 4), wood },
  { "bot", c:rrect(9, 44, 55, 53, 4), wood },
}
-- grain: each slat its own line
local grain = {
  { {20, 17}, {29, 17}, {30, 16}, {40, 16} },
  { {24, 33}, {33, 33}, {34, 34}, {44, 34} },
  { {18, 49}, {26, 49}, {27, 50}, {36, 50} },
}
for _, g in ipairs(grain) do
  for i = 1, #g, 2 do
    local a, b = g[i], g[i + 1]
    for x = a[1], b[1] do c:px(x, a[2], "#8a4f2a") end
  end
end
-- end-cap dots (peg holes) at the right end
for _, y in ipairs(ys) do
  c:paint({ ".d.", "ddd", ".d." }, 49, y + 3, { d = "#5e2f1e" })
end
local t = c:save(O .. "aseprite/ico/ico-menu.aseprite", O .. "png/ico/ico-menu.png")
print(GV.report(t))
