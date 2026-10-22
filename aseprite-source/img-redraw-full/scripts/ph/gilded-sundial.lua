local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local plinth = c:poly({ {20,40}, {45,40}, {49,55}, {16,55} })
local lip = c:rrect(17, 38, 47, 42, 1)
local ring = c:ellipse(32, 27, 14, 14)
local dial = c:ellipse(32, 27, 12, 12)
local gnomon = c:poly({ {32,16}, {34,16}, {40,28}, {32,28} })
local p = c:build{
  { "plinth", plinth, GV.ramp("#968f96") },
  { "lip", lip, GV.ramp("#8b8f96") },
  { "ring", ring, "gold" },
  { "dial", dial, GV.ramp("#d6c9b6"), { cres = 3, deep = 1, gloss = false, contact = false } },
  { "gnomon", gnomon, GV.ramp("#b8661a"), { cres = 2, deep = 1 } },
}
-- hour ticks
for i = 0, 11 do
  local a = i * math.pi / 6
  local x = math.floor(32 + math.cos(a) * 10 + 0.5)
  local y = math.floor(27 + math.sin(a) * 10 + 0.5)
  if not gnomon:has(x, y) then c:px(x, y, "#7a3a14") end
end
c:gloss(dial, GV.ramp("#d6c9b6"), { 25, 20 })
c:seam({ {18, 40}, {46, 40} })
c:ground(32.5, 56, 19, 1.5)
local t = c:save(O .. "aseprite/ph/gilded-sundial.aseprite", O .. "png/ph/gilded-sundial.png")
print(GV.report(t))
