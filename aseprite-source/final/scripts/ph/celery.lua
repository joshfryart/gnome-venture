local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local function frill(cx, cy, r)
  local m = c:ellipse(cx, cy, r, r - 1)
  m:add(c:ellipse(cx - r + 1, cy + 1, 2.5, 2.5)); m:add(c:ellipse(cx + r - 1, cy + 1, 2.5, 2.5))
  m:add(c:ellipse(cx, cy - r + 1, 2.5, 2.5))
  m:del(cx - 2, cy - r - 1); m:del(cx + 2, cy - r - 1)
  return m
end
local leafL = frill(19, 19, 6)
local leafR = frill(45, 19, 6)
local leafC = frill(32, 16, 5.5)
local stL = c:poly({ {21,52}, {28,52}, {24,20}, {16,20} })
local stR = c:poly({ {36,52}, {43,52}, {48,20}, {40,20} })
local stC = c:poly({ {26,54}, {36,54}, {37,17}, {27,17} })
local base = c:rrect(21, 49, 43, 57, 3)
local p = c:build{
  { "leafL", leafL, "#4a8a3e", { gloss = false } },
  { "leafR", leafR, "#4a8a3e", { gloss = false } },
  { "stL", stL, "#a4b86a", { gloss = false } },
  { "stR", stR, "#a4b86a", { gloss = false } },
  { "leafC", leafC, "#4a8a3e", { gloss = false } },
  { "stC", stC, "#c8d77a", { gloss = { 29, 24 } } },
  { "base", base, GV.ramp("#f1ece0"), { gloss = false } },
}
-- ribs on the centre stalk
for y = 23, 45 do
  if (y % 7) ~= 0 then c:px(31, y, "#7ab55c"); c:px(34, y, "#7ab55c") end
end
for y = 25, 45 do if y % 5 ~= 0 then
  c:px(math.floor(20 + (y - 20) * 4 / 32 + 1.5), y, "#7ab55c")
  c:px(math.floor(44 - (y - 20) * 4 / 32 - 1.5), y, "#7ab55c")
end end
-- cut ring on base
for x = 25, 39 do c:px(x, 55, "#e9b98a") end
c:px(24, 54, "#e9b98a"); c:px(40, 54, "#e9b98a")
-- binding band
local band = c:rect(20, 46, 44, 48)
c:part(band, "gold", { flat = true })
c:seam({ {21, 47}, {43, 47} }, { free = true })
c:button(40, 45)
local t = c:save(O .. "aseprite/ph/celery.aseprite", O .. "png/ph/celery.png")
print(GV.report(t))
