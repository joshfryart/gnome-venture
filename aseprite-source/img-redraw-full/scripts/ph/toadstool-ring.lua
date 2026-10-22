local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cup = c:poly({ {17,31}, {48,31}, {43,56}, {22,56} }):add(c:rrect(20,50,43,55,3))
local cap = c:rrect(13, 25, 50, 35, 3)
local stem = c:rrect(30, 14, 33, 27, 1)
local lleaf = c:poly({ {31,22}, {22,9}, {18,15} }):add(c:ellipse(24, 16, 5, 4)):add(c:poly({ {23,10}, {30,20}, {20,18} }))
local rleaf = c:poly({ {32,21}, {42,7}, {46,13} }):add(c:ellipse(39.5, 14, 5, 4)):add(c:poly({ {41,8}, {33,19}, {44,17} }))
local red = GV.ramp("#d6322b")
c:build{
  { "cup",   cup,   "#e0501f", { light = cup:copy():add(cap) } },
  { "stem",  stem,  "#2f5a2a", { flat = true } },
  { "lleaf", lleaf, "#58a03e" },
  { "rleaf", rleaf, "#58a03e" },
  { "cap",   cap,   "#d6322b", { gloss = { 20, 28 } } },
}
-- cup grooves
local G = "#b8452f"
for _, g in ipairs({ {38, 22, 30}, {44, 24, 31}, {50, 26, 32} }) do
  for x = g[2] + 3, g[3] + 9 do if cup:has(x, g[1]) and not cap:has(x, g[1]) then c:px(x, g[1], G) end end
end
-- leaf veins
c:line({ {29,20}, {23,13} }, 1):each(function(x, y) if lleaf:has(x, y) then c:px(x, y, "#3a6e2c") end end)
c:line({ {34,19}, {40,11} }, 1):each(function(x, y) if rleaf:has(x, y) then c:px(x, y, "#3a6e2c") end end)
c:seam({ {16, 36}, {47, 36} })
local t = c:save(O .. "aseprite/ph/toadstool-ring.aseprite", O .. "png/ph/toadstool-ring.png")
print(GV.report(t))
