local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 96, mode = "sticker" }

-- almond leaf from base (bx,by), direction angle (deg, from horizontal, up), length L, half-width hw
local function leaf(bx, by, deg, L, hw, side)
  local a = math.rad(deg)
  local dx, dy = math.cos(a) * side, -math.sin(a)
  local px, py = -dy, dx
  local pts = {}
  local n = 12
  for i = 0, n do
    local t = i / n
    local w = hw * math.sin(math.pi * t) ^ 0.8 * (1 - 0.25 * t)
    pts[#pts + 1] = { bx + dx * L * t + px * w, by + dy * L * t + py * w }
  end
  for i = n - 1, 1, -1 do
    local t = i / n
    local w = hw * math.sin(math.pi * t) ^ 0.8 * (1 - 0.25 * t)
    pts[#pts + 1] = { bx + dx * L * t - px * w, by + dy * L * t - py * w }
  end
  return c:poly(pts)
end

local G1, G2, G3 = GV.ramp("#79b86a"), GV.ramp("#4f9d5d"), GV.ramp("#3b8250")
local stem = c:line({ {32, 86}, {33, 76}, {32, 60}, {31, 44}, {32, 28}, {32, 20} }, 3)

local spec = {
  { 33, 82, 34, 16, 4.0,  1, G1 }, { 31, 78, 34, 16, 4.0, -1, G2 },
  { 33, 68, 42, 14, 3.6,  1, G2 }, { 31, 64, 42, 14, 3.6, -1, G3 },
  { 32, 54, 44, 12, 3.3,  1, G1 }, { 31, 50, 44, 12, 3.3, -1, G2 },
  { 32, 41, 47, 10, 3.0,  1, G2 }, { 31, 37, 47, 10, 3.0, -1, G3 },
  { 33, 29, 50, 8,  2.6,  1, G1 }, { 31, 26, 50, 8,  2.6, -1, G2 },
}
local parts = { { "stem", stem, G3, { gloss = false } } }
for i, s in ipairs(spec) do
  parts[#parts + 1] = { "l" .. i, leaf(s[1], s[2], s[3], s[4], s[5], s[6]), s[7], i > 6 and { gloss = false } or nil }
end
parts[#parts + 1] = { "tip", leaf(32.5, 25, 90, 12, 3.0, 1), G1, { gloss = false } }
local p = c:build(parts)

-- centre veins on the three largest leaves
local function vein(bx, by, deg, L, side, hex)
  local a = math.rad(deg)
  local dx, dy = math.cos(a) * side, -math.sin(a)
  local pts = {}
  for t = 2, math.floor(L * 0.7) do pts[#pts + 1] = { bx + dx * t, by + dy * t } end
  for _, q in ipairs(pts) do c:px(math.floor(q[1] + 0.5), math.floor(q[2] + 0.5), hex) end
end
vein(33, 82, 34, 16, 1, G1.shade)
vein(31, 78, 34, 16, -1, G2.shade)
vein(33, 68, 42, 14, 1, G2.shade)

local t = c:save(O .. "aseprite/flowers/sprig-leaf.aseprite", O .. "png/flowers/sprig-leaf.png")
print(GV.report(t))
