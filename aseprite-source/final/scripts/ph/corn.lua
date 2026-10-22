local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cob = c:ellipse(31.5, 31, 11, 22)
local left = cob:copy():clip(c:rect(0, 0, 31, 63))
local right = cob:copy():clip(c:rect(32, 0, 63, 63))
local husk = c:poly({ {33, 58}, {24, 57}, {16, 53}, {11, 46}, {12, 41}, {17, 46}, {23, 49}, {28, 46}, {31, 40}, {35, 44}, {36, 52} })
local husk2 = c:poly({ {32, 58}, {36, 46}, {41, 40}, {45, 42}, {44, 50}, {39, 57} })
local p = c:build{
  { "left", left, GV.ramp("#f5cf6a"), { light = cob, gloss = { 25, 16 } } },
  { "right", right, GV.ramp("#e8a317"), { light = cob, gloss = false, rim = false } },
  { "husk2", husk2, "moss", { gloss = false } },
  { "husk", husk, GV.ramp("#58a03e"), { gloss = { 16, 46 } } },
}
-- kernel gaps: horizontal rows and the centre split
local cobIn = cob:copy():cut(husk):cut(husk2)
for y = 13, 50, 5 do
  local row = c:line({ {18, y}, {45, y} }, 1):clip(cob:shrink(2)):cut(husk):cut(husk2)
  c:fill(row, "#d0862a")
end
for y = 13, 50, 5 do
  for _, x in ipairs({ 26, 37 }) do
    local xx = x + ((y // 5) % 2) * 2
    if cobIn:shrink(2):has(xx, y + 2) then c:px(xx, y + 1, "#d0862a"); c:px(xx, y + 2, "#d0862a"); c:px(xx, y + 3, "#d0862a") end
  end
end
local mid = c:line({ {31, 12}, {31, 50} }, 1):clip(cob:shrink(1)):cut(husk):cut(husk2)
c:fill(mid, "#7a3a14")
-- keep gloss bright
c:px(24, 15, "#fff1c8"); c:px(24, 16, "#fff1c8"); c:px(25, 14, "#fff1c8"); c:px(23, 18, "#fff1c8")
local t = c:save(O .. "aseprite/ph/corn.aseprite", O .. "png/ph/corn.png")
print(GV.report(t))
