local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local soil = c:ellipse(32, 50, 21, 6)
local function leaf(tx, ty)
  local bx, by = 32, 47
  local mx, my = (bx + tx) / 2, (by + ty) / 2
  local dx, dy = tx - bx, ty - by
  local L = math.sqrt(dx*dx + dy*dy)
  local nx, ny = -dy / L * 3.5, dx / L * 3.5
  return c:poly({ {bx - 1, by}, {mx + nx, my + ny}, {tx, ty}, {mx - nx, my - ny}, {bx + 2, by} })
end
local lA = leaf(10, 35); lA:add(leaf(54, 35))
local lB = leaf(15, 24); lB:add(leaf(49, 24))
local lC = leaf(32, 9)
local head = c:ellipse(32, 28, 11, 11)
local fr = c:mask()
for _, p in ipairs({ {17.5, 35.5}, {46.5, 35.5}, {24.5, 43.5}, {39.5, 43.5} }) do
  fr:add(c:ellipse(p[1], p[2], 3.5, 3.5))
end
local p = c:build{
  { "soil", soil, GV.ramp("#8c4a1a") },
  { "leafC", lC, GV.ramp("#58a03e"), { gloss = false } },
  { "leafB", lB, "moss", { gloss = false } },
  { "leafA", lA, GV.ramp("#58a03e"), { gloss = false } },
  { "head", head, GV.ramp("#58a03e") },
  { "fruit", fr, GV.ramp("#d6322b"), { gloss = false } },
}
-- lighter soil top
c:fill(c:ellipse(32, 49, 15, 3):cut(lA:copy():add(lB):add(lC):add(head):add(fr)), "#a5663a")
for _, p in ipairs({ {16, 34}, {45, 34}, {23, 42}, {38, 42} }) do
  c:px(p[1], p[2], "#ffc27a")
end
local t = c:save(O .. "aseprite/ph/stage-vegetable-4.aseprite", O .. "png/ph/stage-vegetable-4.png")
print(GV.report(t))
