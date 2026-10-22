local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local walls = c:rrect(14, 26, 50, 54, 3)
local roof = c:poly({ {5, 30}, {32, 6}, {59, 30} })
roof:add(c:rrect(6, 25, 57, 30, 1))
local door = c:ellipse(32, 40, 7, 7):add(c:rect(25, 40, 39, 54))
local win = c:rrect(17, 33, 24, 40, 1)
local p = c:build{
  { "walls", walls, GV.ramp("#a5663a") },
  { "door", door, GV.ramp("#44281c"), { gloss = false, cres = 2 } },
  { "win", win, GV.ramp("#ffc27a"), { flat = true } },
  { "roof", roof, GV.ramp("#7a5cc0"), { gloss = { 20, 18 } } },
}
-- shingle rows (inset from roof edge)
for _, y in ipairs({ 14, 19, 24 }) do
  for x = 0, 63 do
    if roof:has(x - 2, y) and roof:has(x + 2, y) and (x % 4 ~= 0) then
      local col = c:get(x, y)
      c:px(x, y, "#3e2f66")
    end
  end
end
-- window cross
c:paint({ "...w....", "...w....", "wwwwwwww", "...w....", "...w...." }, 17, 34, { w = "#8a4f2a" })
-- planks
for _, y in ipairs({ 35, 42, 49 }) do
  for x = 16, 48 do
    if walls:has(x, y) and not door:grow(1):has(x, y) and not win:grow(1):has(x, y) then
      c:px(x, y, "#5e2f1e")
    end
  end
end
-- doorknob
c:paint({ "kk", "kk" }, 35, 44, { k = "#f5cf6a" })
c:seam({ {10, 28}, {54, 28} })
c:button(30, 11)
c:ground(32, 55, 20, 1.5)
local t = c:save(O .. "aseprite/ph/fairy-house.aseprite", O .. "png/ph/fairy-house.png")
print(GV.report(t))
