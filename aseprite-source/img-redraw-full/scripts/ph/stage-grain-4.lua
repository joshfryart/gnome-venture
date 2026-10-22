local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(B .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local xs = { 15.5, 22, 28.5, 35, 41.5, 48 }
local ys = { 25, 20.5, 17, 17, 20.5, 25 }
local bx = { 26, 28, 30, 33, 35, 37 }

local stalks = c:mask()
for i = 1, 6 do
  local ex = math.floor(xs[i])
  local mx = math.floor((ex + bx[i]) / 2 + (i <= 3 and 1 or -1))
  stalks:add(c:line({ { bx[i], 44 }, { mx, 36 }, { ex, ys[i] + 4 } }, 2))
end
local ears = c:mask()
local whisk = c:mask()
for i = 1, 6 do
  ears:add(c:ellipse(xs[i], ys[i], 2.5, 5.5))
  local tx, ty = math.floor(xs[i]), math.floor(ys[i] - 5.5)
  whisk:add(c:line({ { tx, ty }, { tx - 1, ty - 3 } }, 1))
  whisk:add(c:line({ { tx + 1, ty }, { tx + 2, ty - 3 } }, 1))
end
local gold = GV.ramp("#e8a317")
local p = c:build{
  { "mound", c:ellipse(31.5, 48, 21, 5.5), "#8c4a1a" },
  { "topsoil", c:ellipse(31.5, 46, 16, 3), "#a5663a", { gloss = false } },
  { "whisk", whisk, "#b07a10", { flat = true } },
  { "stalks", stalks, "#d0862a", { flat = true } },
  { "ears", ears, gold },
}
-- kernel ticks on each ear
for i = 1, 6 do
  local x, y = math.floor(xs[i]), math.floor(ys[i])
  c:px(x + 1, y - 1, gold.shade); c:px(x, y + 2, gold.shade); c:px(x + 1, y + 4, gold.shade)
end
local t = c:save(B .. "img-redraw-full/aseprite/ph/stage-grain-4.aseprite", B .. "img-redraw-full/png/ph/stage-grain-4.png")
print(GV.report(t))
