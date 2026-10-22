local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function leaf(bx, by, tx, ty, w)
  local dx, dy = tx - bx, ty - by
  local len = math.sqrt(dx * dx + dy * dy)
  local px, py = -dy / len * w, dx / len * w
  local mx, my = bx + dx * 0.45, by + dy * 0.45
  return c:poly({ {bx, by}, {mx + px, my + py}, {tx, ty}, {mx - px, my - py} })
end

local mossA = "moss"
local mossB = GV.ramp("#58a03e")
local soil = GV.ramp("#8c4a1a")
local top = GV.ramp("#a5663a")

local parts = {
  { "mound", c:ellipse(31.5, 49, 20, 7), soil },
  { "top", c:ellipse(31.5, 47, 15, 3.5), top, { flat = true, contact = false } },
  { "l1", leaf(29, 47, 10, 41, 3.5), mossA },
  { "l5", leaf(34, 47, 53, 41, 3.5), mossA },
  { "l2", leaf(30, 46, 13, 28, 3.5), mossB },
  { "l4", leaf(33, 46, 50, 28, 3.5), mossB },
  { "l3", leaf(31.5, 48, 31.5, 30, 5), mossA },
  { "canopy", c:ellipse(31.5, 23, 9, 9), mossB },
}
local fruits = { {22, 39}, {41, 38}, {31.5, 43}, {27, 27}, {36, 19} }
for i, f in ipairs(fruits) do
  parts[#parts + 1] = { "f" .. i, c:ellipse(f[1], f[2], 3, 3), "petal", { gloss = false, cres = 2, deep = 1 } }
end
c:build(parts)
for _, f in ipairs(fruits) do
  local x, y = math.floor(f[1]) - 1, math.floor(f[2]) - 1
  c:px(x, y, "#f6b8cf"); c:px(x + 1, y, "#f6b8cf"); c:px(x, y + 1, "#f6b8cf")
end
local t = c:save(O .. "aseprite/ph/stage-fruit-4.aseprite", O .. "png/ph/stage-fruit-4.png")
print(GV.report(t))
