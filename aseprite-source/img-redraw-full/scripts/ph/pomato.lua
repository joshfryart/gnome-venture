local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- lumpy body: main round + right shoulder bump + slight lower-left lobe
local body = c:ellipse(31, 38, 17, 15)
body:add(c:ellipse(44, 33, 6, 6))
body:add(c:ellipse(22, 44, 9, 8))
local sp = {}
for i = 0, 9 do
  local a = -math.pi/2 + i * math.pi / 5
  local r = (i % 2 == 0) and 13 or 5
  sp[#sp+1] = { 32 + r * math.cos(a) * 1.15, 25 + r * math.sin(a) * 0.75 }
end
local crown = c:poly(sp)
local stalk = c:rrect(30, 9, 33, 20, 1)
local p = c:build{
  { "body", body, GV.ramp("#9ab85e") },
  { "stalk", stalk, GV.ramp("#4a8a3e"), { flat = true } },
  { "crown", crown, GV.ramp("#3f7a34"), { gloss = false } },
}
-- potato dents (beans)
for _, d in ipairs({ {22,40}, {36,46}, {44,36}, {27,50} }) do
  c:spot(c:ellipse(d[1], d[2], 1.5, 1), "#5f8a3a")
end
local t = c:save(O .. "aseprite/ph/pomato.aseprite", O .. "png/ph/pomato.png")
print(GV.report(t))
