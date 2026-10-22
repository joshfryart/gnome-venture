local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(32, 34, 21, 17)
body:add(c:ellipse(25, 31, 13, 13)); body:add(c:ellipse(39, 31, 13, 13))
-- tilted almond stone
local function tilted(cx, cy, rx, ry, a)
  local m = c:mask()
  local ca, sa = math.cos(a), math.sin(a)
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x + 0.5 - cx, y + 0.5 - cy
    local u = dx * ca + dy * sa; local v = -dx * sa + dy * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local flesh = tilted(35, 34, 11, 13, 0.35)
local stone = tilted(35, 34, 6, 8.5, 0.35)
local stripe = c:line({ {13, 40}, {20, 32}, {28, 27}, {40, 23}, {50, 22} }, 3):clip(body):cut(flesh:grow(1))
local leaf = c:poly({ {31, 15}, {35, 9}, {42, 7}, {47, 8}, {43, 13}, {36, 16} })
local stem = c:rrect(30, 10, 32, 17, 1)
c:build{
  { "stem", stem, "wood", { flat = true } },
  { "body", body, GV.ramp("#f08a24", { rim = "#ffc27a" }), { gloss = { 19, 23 } } },
  { "stripe", stripe, GV.ramp("#e46a9b"), { flat = true } },
  { "flesh", flesh, GV.ramp("#f5cf6a"), { gloss = false } },
  { "stone", stone, "wood", { gloss = { 32, 29 } } },
  { "leaf", leaf, "leaf" },
}
c:paint({ "d", "d", "d", "d", ".d", ".d", ".d", ".d", "..d", "..d" }, 34, 29, { d = "#5e2f1e" })
c:seam({ {35, 10}, {44, 9} })
local t = c:save(O .. "aseprite/ph/almond-peach.aseprite", O .. "png/ph/almond-peach.png")
print(GV.report(t))
