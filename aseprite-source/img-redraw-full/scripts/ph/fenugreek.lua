local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- pointed teardrop leaf, tip up
local leaf = c:mask()
local y0, y1, cx = 10, 50, 31.5
for y = y0, y1 do
  local t = (y - y0) / (y1 - y0)
  local w = 16.5 * math.sin(math.pi * (t ^ 1.5)) ^ 0.7
  if t > 0.9 then w = w * 1.0 end
  for x = 0, 63 do
    if math.abs(x - cx) <= w then leaf:set(x, y) end
  end
end
leaf:set(31, y0); leaf:set(32, y0); leaf:set(31, y0 + 1); leaf:set(32, y0 + 1)
local p = c:build{
  { "leaf", leaf, GV.ramp("#58a03e"), { gloss = { 22, 22 } } },
}
local V = "#2e5a2c"
local function vein(pts) local m = c:line(pts, 2); m:clip(leaf:shrink(2)); c:fill(m, V) end
vein({ {31, 16}, {31, 48} })
for _, v in ipairs({ {28, 9}, {36, 9}, {43, 7} }) do
  local y, d = v[1], v[2]
  vein({ {30, y}, {30 - d, y - 6} })
  vein({ {32, y}, {32 + d, y - 6} })
end
c:ground(31.5, 53, 14, 2)
local t = c:save(O .. "aseprite/ph/fenugreek.aseprite", O .. "png/ph/fenugreek.png")
print(GV.report(t))
