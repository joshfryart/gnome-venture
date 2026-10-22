local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local sac = c:mask()
local top, mid, bot, R = 9, 38, 52, 17
for y = top, bot do
  local hw
  if y >= mid then hw = R * math.sqrt(math.max(0, 1 - ((y + 0.5 - mid) / (bot + 1 - mid))^2))
  else local t = (y - top) / (mid - top); hw = 1.6 + (R - 1.6) * (t ^ 1.25) end
  for x = 0, 63 do if math.abs(x + 0.5 - 32) <= hw then sac:set(x, y) end end
end
local skin = GV.ramp("#dcb06a", { rim = "#d9a660", shade = "#b07a45", gloss = "#fff1c8" })
local fold = c:ellipse(31.5, 45, 12, 4):cut(c:ellipse(31.5, 42.5, 12, 3.5))
local p = c:build{
  { "sac", sac, skin },
}
c:fill(fold:clip(sac:shrink(2)), "#a5663a")
for _, q in ipairs({ {25, 35}, {37, 33}, {31, 28} }) do c:spot(c:rect(q[1], q[2], q[1] + 1, q[2] + 1), "#b07a45") end
local t = c:save(O .. "aseprite/ph/croak-sac.aseprite", O .. "png/ph/croak-sac.png")
print(GV.report(t))
