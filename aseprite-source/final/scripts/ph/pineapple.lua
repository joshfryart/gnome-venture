local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leaf = c:poly({ {30,21},{31,15},{35,10},{41,6},{45,5},{44,9},{40,14},{36,19},{34,22} })
local p = c:build{
  { "stalk", c:rect(30, 13, 33, 22), GV.ramp("#2f5a2a",{base="#3a6a2e"}), { flat = true } },
  { "leaf", leaf, GV.ramp("#58a03e") },
  { "body", c:ellipse(31.5, 37, 17, 16.5), GV.ramp("#e0441f") },
}
local inner = p.body.m:shrink(3)
local lat = c:mask()
for y = 0, 63 do for x = 0, 63 do
  local u, v = (x + y) % 8, (x - y + 64) % 8
  if (u == 0 or v == 0) and inner:has(x, y) and not ((x - 22)^2 + (y - 28)^2 < 30) then lat:set(x, y) end
end end
c:fill(lat, "#ae2a2a")
local t = c:save(O .. "aseprite/ph/pineapple.aseprite", O .. "png/ph/pineapple.png")
print(GV.report(t))
