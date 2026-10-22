local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local ember = GV.ramp("#f08a24")
local vane = c:poly({
  { 18, 52 }, { 13, 46 }, { 11, 38 }, { 13, 30 }, { 18, 22 }, { 26, 15 }, { 36, 10 }, { 46, 7 }, { 52, 7 },
  { 51, 13 }, { 49, 22 }, { 45, 31 }, { 39, 39 }, { 31, 46 }, { 22, 52 },
})
-- three barb notches on the lower-left vane edge
vane:cut(c:poly({ { 10, 41 }, { 18, 39 }, { 10, 37 } }))
vane:cut(c:poly({ { 11, 33 }, { 20, 30 }, { 12, 29 } }))
vane:cut(c:poly({ { 14, 26 }, { 23, 22 }, { 16, 21 } }))
local spine = c:line({ { 14, 55 }, { 20, 48 }, { 30, 35 }, { 40, 22 }, { 47, 12 } }, 3)
c:build{
  { "vane",  vane,  ember, { gloss = { 22, 21 } } },
  { "spine", spine, GV.ramp("#e0501f"), { flat = true } },
}
-- barbs
for _, s in ipairs({ { { 33, 39 }, { 40, 35 } }, { { 38, 31 }, { 44, 27 } }, { { 25, 46 }, { 30, 44 } } }) do
  local a, b = s[1], s[2]
  local n = math.max(math.abs(b[1] - a[1]), math.abs(b[2] - a[2]))
  for i = 0, n do
    local x = math.floor(a[1] + (b[1] - a[1]) * i / n + 0.5)
    local y = math.floor(a[2] + (b[2] - a[2]) * i / n + 0.5)
    c:px(x, y, "#d6322b"); c:px(x, y + 1, "#d6322b")
  end
end
-- tip highlight
c:px(49, 9, "#ffc27a"); c:px(50, 9, "#ffc27a"); c:px(48, 10, "#ffc27a")
local t = c:save(O .. "aseprite/ph/storm-feather.aseprite", O .. "png/ph/storm-feather.png")
print(GV.report(t))
