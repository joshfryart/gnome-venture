local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local moss = GV.ramp("#7ab55c")
local p = c:build{
  { "stem", c:rect(30, 13, 32, 22), GV.ramp("#2f5a2a"), { flat = true } },
  { "body", c:ellipse(31.5, 36.5, 17, 16), moss, { gloss = { 22, 27 } } },
  { "leaf", c:poly({ {32, 19}, {35, 14}, {40, 10}, {47, 8}, {45, 13}, {40, 18}, {35, 20} }), GV.ramp("#58a03e"), { gloss = false } },
}
-- netted rind: pale diamond mesh over the belly, skipping gloss
local inner = p.body.m:shrink(3)
inner:each(function(x, y)
  if x >= 20 and x <= 43 and y >= 28 and y <= 48 and ((x + y) % 6 == 0 or (x - y) % 6 == 0) then
    local v = c:get(x, y)
    if v == moss.base then c:px(x, y, "#c8d77a")
    elseif v == moss.shade then c:px(x, y, moss.base) end
  end
end)
-- leaf vein
c:line({ {36, 18}, {44, 11} }, 1); for _, q in ipairs({ {37,17},{38,16},{39,15},{40,14},{41,13},{42,12} }) do c:px(q[1], q[2], "#2f5a2a") end
local t = c:save(O .. "aseprite/ph/melon.aseprite", O .. "png/ph/melon.png")
print(GV.report(t))
