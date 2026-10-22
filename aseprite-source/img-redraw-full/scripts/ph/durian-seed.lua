local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local paper = GV.ramp("#f1ece0")
local durR = GV.ramp("#e8a317", { shade = "#b07a10" })
local spikeR = GV.ramp("#58a03e")
-- cone: wide mouth at y 24, tapering to a pinched twist near y 52, little twisted tail below
local cone = c:poly({ { 13, 28 }, { 51, 28 }, { 35, 49 }, { 29, 49 } })
local tail = c:poly({ { 29, 48 }, { 35, 48 }, { 34, 52 }, { 36, 55 }, { 28, 55 }, { 30, 52 } })
-- durian: round lump with spikes all around the upper arc
local dur = c:ellipse(32, 24, 13, 10)
local spikes = c:mask()
for _, s in ipairs({ { 19, 19 }, { 23, 14 }, { 29, 12 }, { 35, 12 }, { 41, 14 }, { 45, 19 } }) do
  local x, y = s[1], s[2]
  local dx = x < 32 and -1 or 1
  if x == 29 or x == 35 then dx = 0 end
  spikes:add(c:poly({ { x - 2, y + 3 }, { x + 3, y + 3 }, { x + 0.5 + dx * 2, y - 2 } }))
end
local p = c:build{
  { "tail", tail, paper, { gloss = false } },
  { "durian", dur:copy():add(spikes), durR, { light = dur } },
  { "cone", cone, paper, { light = cone:copy():add(tail) } },
  { "leaf", c:poly({ { 46, 6 }, { 51, 12 }, { 43, 12 } }), "#2e5a2c", { flat = true } },
}
-- rind bumps (little diamonds) on the visible durian
for _, b in ipairs({ { 25, 20 }, { 32, 18 }, { 39, 20 }, { 28, 24 }, { 36, 24 } }) do
  c:paint({ ".s.", "s.s", ".s." }, b[1] - 1, b[2] - 1, { s = "#b07a10" })
end
-- spike tips green
for _, s in ipairs({ { 19, 19 }, { 23, 14 }, { 29, 12 }, { 35, 12 }, { 41, 14 }, { 45, 19 } }) do
  local x, y = s[1], s[2]
  local dx = x < 32 and -1 or 1
  if x == 29 or x == 35 then dx = 0 end
  local tx = math.floor(x + 0.5 + dx * 2)
  c:px(tx, y - 1, "#58a03e"); c:px(tx, y, "#58a03e"); c:px(tx - dx, y, "#58a03e")
end
-- fold line seam down the cone
c:seam({ { 20, 30 }, { 32, 47 } })
-- twist creases on the tail
c:px(30, 50, "#dcb06a"); c:px(31, 51, "#dcb06a"); c:px(32, 53, "#dcb06a"); c:px(33, 54, "#dcb06a")
local t = c:save(O .. "aseprite/ph/durian-seed.aseprite", O .. "png/ph/durian-seed.png")
print(GV.report(t))
