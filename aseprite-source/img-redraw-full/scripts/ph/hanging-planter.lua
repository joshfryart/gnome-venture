local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local stem = c:rect(31, 16, 32, 26)
local leafL = c:poly({{32, 24}, {26, 22}, {21, 18}, {19, 12}, {25, 12}, {30, 16}, {32, 21}})
local leafR = c:poly({{32, 22}, {38, 20}, {43, 16}, {45, 10}, {39, 10}, {34, 14}, {32, 19}})
local pot = c:poly({{17, 30}, {48, 30}, {44, 53}, {21, 53}})
local rim = c:rrect(14, 25, 49, 32, 3)
c:build{
  { "stem", stem, "#2f5a2a", { flat = true } },
  { "leafL", leafL, "#58a03e" },
  { "leafR", leafR, "#58a03e" },
  { "pot", pot, "#e0501f", { gloss = { 24, 37 } } },
  { "rim", rim, "#d6322b" },
}
for _, y in ipairs({39, 44, 49}) do
  local w = math.floor((y - 30) * 4 / 23)
  for x = 22 + w, 30 + w, 1 do if x % 3 ~= 0 then c:px(x, y, "#b8452f") end end
  for x = 35 - w, 43 - w, 1 do if x % 3 ~= 0 then c:px(x, y, "#b8452f") end end
end
c:seam({ {16, 29}, {48, 29} })
c:button(30, 27)
local t = c:save(O .. "aseprite/ph/hanging-planter.aseprite", O .. "png/ph/hanging-planter.png")
print(GV.report(t))
