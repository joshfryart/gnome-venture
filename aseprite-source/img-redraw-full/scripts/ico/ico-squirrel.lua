local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- bushy S-tail: chain of discs along a curve, thick at the base, curling at the tip
local pts = { { 23, 50, 6 }, { 17, 44, 6.5 }, { 14, 35, 7 }, { 15, 26, 7 }, { 19, 18, 6.5 },
              { 25, 14, 6 }, { 31, 14, 5 }, { 33, 18, 4 }, { 30, 21, 3 } }
local tail = c:mask()
for i = 1, #pts - 1 do
  local a, b = pts[i], pts[i + 1]
  for s = 0, 4 do
    local f = s / 5
    tail:add(c:ellipse(a[1] + (b[1] - a[1]) * f, a[2] + (b[2] - a[2]) * f, a[3] + (b[3] - a[3]) * f))
  end
end
tail:add(c:ellipse(30, 20, 3))

local body = c:ellipse(34, 43, 12, 12)
local foot = c:rrect(34, 51, 47, 55, 2)
local belly = c:ellipse(39, 45, 5, 6):clip(body)
local ear  = c:poly({ { 36, 17 }, { 40, 7 }, { 47, 15 } })
local head = c:ellipse(42, 23, 10, 9)
local snout = c:ellipse(49, 26, 5, 4)
local nose = c:ellipse(54, 24, 2.5, 2.5)
local paw  = c:rrect(44, 36, 49, 40, 1)

c:build{
  { "tail", tail, "#a5663a" },
  { "body", body, "#a5663a", { gloss = false } },
  { "belly", belly, "#d9a660", { gloss = false, flat = true } },
  { "foot", foot, "#8a4f2a", { gloss = false } },
  { "ear", ear, "#a5663a", { gloss = false } },
  { "head", head, "#a5663a" },
  { "snout", snout, "#a5663a", { gloss = false, rim = false } },
  { "nose", nose, "#2a1a10", { flat = true } },
  { "paw", paw, "#8a4f2a", { flat = true } },
}
-- lighter inner stripe on the tail
c:fill(c:line({ { 18, 43 }, { 16, 35 }, { 17, 27 }, { 20, 21 }, { 26, 17 } }, 3):clip(tail:shrink(2)), "#d9a660")
c:eye(44, 19, true)
local t = c:save(O .. "aseprite/ico/ico-squirrel.aseprite", O .. "png/ico/ico-squirrel.png")
print(GV.report(t))
