local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 96, mode = "sticker" }

local function stemx(y) return 32 + math.floor(math.sin((86 - y) / 74 * math.pi) * 1.5 + 0.5) end

local function leaf(rx, ry, side, L, hw)
  local a = math.rad(58)
  local dx, dy = math.sin(a) * side, -math.cos(a)
  local px, py = -dy, dx
  local function P(t, w) return { rx + dx * L * t + px * w, ry + dy * L * t + py * w } end
  return c:poly({ P(0, -hw * 0.6), P(0.4, -hw), P(0.75, -hw * 0.6), P(1, 0), P(0.75, hw * 0.6), P(0.4, hw), P(0, hw * 0.6) }),
         { dx = dx, dy = dy, L = L }
end

local parts, ribs = {}, {}
local rightY = { 80, 70, 60, 50, 40, 30 }
local leftY  = { 75, 65, 55, 45, 35, 26 }
for i = 1, 6 do
  local L = 18 - (i - 1) * 1.8
  local y = rightY[i]
  local m, d = leaf(stemx(y) + 1, y, 1, L, 2.4)
  parts[#parts + 1] = { "r" .. i, m, GV.ramp("#79b86a"), { cres = 1, deep = 0, gloss = false, contact = false } }
  if L >= 14 then ribs[#ribs + 1] = { stemx(y) + 1, y, d } end
  y = leftY[i]
  m, d = leaf(stemx(y) - 1, y, -1, L - 0.9, 2.4)
  parts[#parts + 1] = { "l" .. i, m, GV.ramp("#4f9d5d"), { cres = 1, deep = 0, gloss = false, contact = false } }
  if L - 0.9 >= 14 then ribs[#ribs + 1] = { stemx(y) - 1, y, d } end
end
local tip = c:poly({ {32, 11}, {34, 15}, {34, 19}, {32, 21}, {30, 19}, {30, 15} })
parts[#parts + 1] = { "tip", tip, GV.ramp("#79b86a"), { cres = 1, deep = 0, gloss = false } }
local stemPts = {}
for y = 86, 18, -4 do stemPts[#stemPts + 1] = { stemx(y), y } end
parts[#parts + 1] = { "stem", c:line(stemPts, 3), GV.ramp("#3b8250"), { flat = true } }
c:build(parts)

for _, r in ipairs(ribs) do
  local x0, y0, d = r[1], r[2], r[3]
  for s = 3, math.floor(d.L * 0.7) do
    c:px(math.floor(x0 + d.dx * s + 0.5), math.floor(y0 + d.dy * s + 0.5), "#3b8250")
  end
end

local t = c:save(O .. "aseprite/flowers/sprig-fern.aseprite", O .. "png/flowers/sprig-fern.png")
print(GV.report(t))
