local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- narrow spiky sprig: slim core plus needle teeth angled upward
local body = c:poly({ {32, 9}, {37, 20}, {38, 40}, {35, 52}, {29, 52}, {26, 40}, {27, 20} })
local reach = { [16] = 8, [22] = 12, [28] = 14, [34] = 15, [40] = 13, [46] = 9 }
for y, r in pairs(reach) do
  body:add(c:poly({ {31, y + 1}, {31, y + 6}, {32 - r, y - 3} }))
  body:add(c:poly({ {33, y + 1}, {33, y + 6}, {32 + r, y - 3} }))
end
local p = c:build{
  { "foot", c:rect(31, 51, 33, 56), GV.ramp("#5e2f1e"), { flat = true } },
  { "body", body, "moss", { gloss = { 22, 20 } } },
}
local dk = "#2e5a2c"
local function vein(pts) c:fill(c:line(pts, 2):clip(p.body.m:shrink(1)), dk) end
vein({ {32, 51}, {32, 14} })
vein({ {32, 44}, {24, 38} })
vein({ {32, 38}, {22, 30} })
vein({ {33, 30}, {41, 22} })
vein({ {33, 42}, {40, 36} })
local t = c:save(O .. "aseprite/ph/rosemary.aseprite", O .. "png/ph/rosemary.png")
print(GV.report(t))
