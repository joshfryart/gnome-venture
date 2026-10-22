local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local DG = GV.ramp("#b8661a")

local hub = c:ellipse(25, 30, 5, 5)
c:build{
  { "legL",  c:rect(15, 36, 18, 49), DG, { gloss = false } },
  { "legR",  c:rect(36, 36, 39, 49), DG, { gloss = false } },
  { "spout", c:line({ {41, 27}, {51, 16} }, 7), "wood" },
  { "body",  c:rrect(10, 20, 44, 39, 5), "gold" },
  { "hub",   hub, DG, { gloss = { 22, 27 } } },
}
c:paint({ "dd", "dd" }, 24, 29, { d = "#7a3a14" })
-- body seam in gold shade, skipping the hub
local i = 0
for x = 13, 41 do
  if not hub:grow(1):has(x, 30) then
    if i % 3 ~= 2 then c:px(x, 30, "#b8661a") end
    i = i + 1
  else
    i = 0
  end
end
c:ground(27, 50, 17, 1.5)
local t = c:save(B .. "aseprite/ph/masterwork-gnome-seeder.aseprite", B .. "png/ph/masterwork-gnome-seeder.png")
print(GV.report(t))
