local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-hybrid/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local W = GV.R.water
-- body: neck + shoulder + round belly, flat base
local body = c:ellipse(31.5, 39, 18, 15):cut(c:rect(0, 54, 63, 63))
body:add(c:rrect(25, 12, 38, 28, 1))
body:add(c:poly({ {25, 22}, {39, 22}, {45, 28}, {18, 28} }))
body:add(c:rrect(20, 50, 43, 53, 2))
local p = c:build{
  { "body", body, "water", { gloss = false } },
  { "lip",  c:ellipse(31.5, 11, 10, 3.5), "water", { gloss = false, cres = 2, deep = 1 } },
}
-- dark oval mouth
c:fill(c:ellipse(31.5, 11, 7, 1.5), W.deep)
c:fill(c:rect(27, 10, 36, 10), "#1f2c52")
-- glass streak + dot
c:fill(c:line({ {20, 31}, {19, 35}, {19, 40}, {20, 45} }, 2), W.gloss)
c:fill(c:line({ {27, 15}, {27, 21} }, 1), W.rim)
c:px(23, 29, W.gloss); c:px(22, 49, W.gloss)
-- gold dotted band, bowed across the belly
for x = 15, 48, 3 do
  local u = (x - 31.5) / 17
  local y = math.floor(32 + 3 * (1 - u * u) + 0.5)
  if body:has(x, y) and body:has(x, y + 1) then c:px(x, y, "#f5cf6a") end
end
c:ground(31.5, 56, 14, 1.5)
local t = c:save(O .. "aseprite/flowers/vase.aseprite", O .. "png/flowers/vase.png")
print(GV.report(t))
