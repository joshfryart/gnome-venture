local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tilted tail ellipse
local function tilted(cx, cy, rx, ry, deg)
  local m = c:mask()
  local a = math.rad(deg)
  local ca, sa = math.cos(a), math.sin(a)
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - cx, y - cy
    local u = dx * ca + dy * sa
    local v = -dx * sa + dy * ca
    if (u * u) / (rx * rx) + (v * v) / (ry * ry) <= 1 then m:set(x, y) end
  end end
  return m
end

local fur  = GV.ramp("#8f7060")
local pale = GV.ramp("#a38f80")
local dark = "soil"
local cream = GV.ramp("#f8eed2")
local vine = GV.ramp("#58a03e")
local berry = GV.ramp("#d9667f")

local tail = tilted(49, 42, 5, 12, 25)
local tip  = tilted(53, 33, 3.5, 4.5, 25):clip(tail:copy():add(tilted(53, 33, 3.5, 4.5, 25)))
local earL = c:poly({ {17, 23}, {18, 8}, {29, 16} })
local earR = c:poly({ {35, 16}, {46, 8}, {47, 23} })
local innerL = c:poly({ {20, 19}, {21, 12}, {26, 16} })
local innerR = c:poly({ {38, 16}, {43, 12}, {44, 19} })
local pawL = c:ellipse(22, 52, 6.5, 3.5)
local pawR = c:ellipse(42, 52, 6.5, 3.5)
local body = c:ellipse(32, 42, 17, 13)
local belly = c:ellipse(32, 46, 10, 8)
local head = c:ellipse(32, 27, 13, 12.5)
local muzzle = c:ellipse(32, 33, 6, 6)

local p = c:build{
  { "tail", tail, fur },
  { "tip", tip, cream, { flat = true } },
  { "earL", earL, fur, { gloss = false } },
  { "earR", earR, fur, { gloss = false } },
  { "inL", innerL, dark, { flat = true, contour = false } },
  { "inR", innerR, dark, { flat = true, contour = false } },
  { "body", body, fur, { stitch = { side = "lit" } } },
  { "belly", belly, pale, { gloss = false } },
  { "pawL", pawL, fur, { gloss = false } },
  { "pawR", pawR, fur, { gloss = false } },
  { "head", head, fur },
  { "muzzle", muzzle, pale, { gloss = false } },
}

-- nose
c:paint({ ".nnnnn.", "nnnnnnn", ".nnnnn.", "...n..." }, 29, 28, { n = "#2a1a10" })
c:px(30, 28, "#5e2a3a")
-- toe lines
for _, x in ipairs({ 20, 24, 40, 44 }) do c:px(x, 53, "#5e3a2e"); c:px(x, 54, "#5e3a2e") end

-- bramble vines (2px) with thorns and berries
local vines = {
  { {13, 37}, {17, 39}, {21, 39}, {24, 37} },
  { {51, 34}, {47, 37}, {43, 37}, {40, 35} },
  { {21, 50}, {25, 52}, {29, 52}, {32, 50} },
}
for _, pts in ipairs(vines) do
  c:part(c:line(pts, 2), vine, { flat = true, contour = false, contact = false })
end
local thorn = "#2f5a2a"
for _, t in ipairs({ {17, 41}, {21, 36}, {47, 39}, {43, 34}, {25, 54}, {29, 49} }) do c:px(t[1], t[2], thorn) end
-- leaves
c:paint({ "ll", ".l" }, 14, 35, { l = "#7ab55c" })
c:paint({ "ll", "l." }, 49, 31, { l = "#7ab55c" })
-- berries 3x3 + 1
for _, b in ipairs({ {24, 37}, {39, 34}, {32, 49} }) do
  c:paint({ ".b.", "bbb", ".bd" }, b[1], b[2], { b = "#d9667f", d = "#ae2a4a" })
  c:px(b[1], b[2] + 1, "#f6b8cf")
end

c:eye(23, 20); c:eye(36, 20)
c:ground(32, 55.5, 18, 1)
local t = c:save(O .. "aseprite/ph/creature-bramble-wolf.aseprite", O .. "png/ph/creature-bramble-wolf.png")
print(GV.report(t))
