local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local stem = c:rect(31, 14, 33, 28)
local leafL = c:poly({ {32, 21}, {27, 18}, {23, 13}, {22, 8}, {27, 9}, {31, 13}, {33, 19} })
local leafR = c:poly({ {32, 21}, {37, 18}, {41, 13}, {42, 8}, {37, 9}, {33, 13}, {31, 19} })
local body = c:poly({ {16, 32}, {49, 32}, {44, 55}, {21, 55} }):cut(c:rect(20,53,21,55)):cut(c:rect(43,53,45,55))
body:add(c:rrect(21, 50, 43, 54, 3))
local rim = c:rrect(13, 25, 50, 34, 3)
local p = c:build{
  { "stem", stem, "#4a8a3e", { flat = true } },
  { "leafL", leafL, "moss", { gloss = false } },
  { "leafR", leafR, "moss", { gloss = false } },
  { "body", body, "#e0501f", { gloss = { 22, 37 } } },
  { "rim", rim, "#d6322b", { gloss = { 17, 27 } } },
}
-- leaf veins
c:fill(c:line({ {31, 19}, {25, 11} }, 1), "#4a8a3e")
c:fill(c:line({ {33, 19}, {39, 11} }, 1), "#4a8a3e")
-- glaze band (wavy)
local band = c:mask()
for x = 19, 46 do
  local y = 43 + ((x % 6 < 3) and 0 or 1)
  band:set(x, y); band:set(x, y + 1)
end
band:clip(body:shrink(1))
c:fill(band, "#f08a24")
local t = c:save(O .. "aseprite/ph/glazed-garden-pot.aseprite", O .. "png/ph/glazed-garden-pot.png")
print(GV.report(t))
