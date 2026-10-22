-- flowers-pixel/sprig-leaf: broad ovate alternate leaves (bay/basil-like) on a straight stem, no halo
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/flowers-pixel/"
local c = GV.canvas{ w = 64, h = 96, mode = "sticker", halo = 0, close = 0, bleed = "b", margin = 0 }

-- ovate leaf: widest at ~1/3 from the base, pointed tip
local function axis(bx, by, deg, side)
  local a = math.rad(deg)
  return math.cos(a) * side, -math.sin(a)
end
local function leaf(bx, by, deg, L, hw, side)
  local dx, dy = axis(bx, by, deg, side)
  local px, py = -dy, dx
  local n, pts = 16, {}
  local function w(t) return hw * math.sin(math.pi * t ^ 0.72) ^ 0.9 end
  for i = 0, n do local t = i / n pts[#pts+1] = { bx + dx*L*t + px*w(t), by + dy*L*t + py*w(t) } end
  for i = n-1, 1, -1 do local t = i / n pts[#pts+1] = { bx + dx*L*t - px*w(t), by + dy*L*t - py*w(t) } end
  return c:poly(pts)
end

local MOSS = GV.R.moss
local LEAF = GV.R.leaf
local PALE = GV.ramp("#8cc266", { gloss = "#d8e08a", dot = "#eef2b0", rim = "#b4c874", shade = "#5a9a44", deep = "#2f5a2a", bounce = "#6a9a3a" })
local STEM = GV.ramp("#4a8a3e", { rim = "#7ab55c", shade = "#2f5a2a", deep = "#1f3f3a", bounce = "#3e6a30" })

-- leaf table: base x, base y, angle, length, half-width, side, ramp
local L = {
  { 33, 82, 38, 21, 7.0,  1, LEAF },
  { 31, 70, 44, 20, 6.6, -1, MOSS },
  { 33, 58, 50, 18, 6.0,  1, PALE },
  { 31, 46, 55, 16, 5.4, -1, LEAF },
  { 33, 35, 60, 13, 4.6,  1, MOSS },
}
local parts = { { "stem", c:rect(31, 22, 32, 95), STEM, { flat = true } } }
for i, s in ipairs(L) do
  parts[#parts+1] = { "l" .. i, leaf(s[1], s[2], s[3], s[4], s[5], s[6]), s[7] }
end
parts[#parts+1] = { "tip", leaf(32, 28, 90, 19.5, 4.6, 1), PALE }
c:build(parts)

-- midribs (shade) with two short side veins on the big leaves
local function vpx(x, y, r)
  local h = c:get(x, y)
  if h == r.base or h == r.rim or h == r.gloss or h == r.dot then c:px(x, y, r.shade)
  elseif h == r.shade or h == r.bounce then c:px(x, y, r.deep) end
end
local function rib(s, hex, side)
  local dx, dy = axis(s[1], s[2], s[3], s[6])
  local x0, y0, len = s[1], s[2], s[4]
  for t = 2, math.floor(len * 0.78) do
    vpx(math.floor(x0 + dx*t + 0.5), math.floor(y0 + dy*t + 0.5), hex)
  end
  if side then
    local px, py = -dy, dx
    for _, f in ipairs({ 0.35, 0.58 }) do
      local bx, by = x0 + dx*len*f, y0 + dy*len*f
      for k = 1, 2 do
        vpx(math.floor(bx + dx*k*0.8 + px*k + 0.5), math.floor(by + dy*k*0.8 + py*k + 0.5), hex)
        vpx(math.floor(bx + dx*k*0.8 - px*k + 0.5), math.floor(by + dy*k*0.8 - py*k + 0.5), hex)
      end
    end
  end
end
for i, s in ipairs(L) do rib(s, s[7], i <= 3) end
rib({ 32, 28, 90, 19.5, 4.6, 1 }, PALE, true)

-- tiny gold binding stitch wrapped round the stem near the base (2 on / 1 off)
c:paint({ "g.", ".s", "..", "g.", ".s" }, 31, 87, { g = "gold", s = "goldS" })

local t = c:save(O .. "aseprite/sprig-leaf.aseprite", O .. "png/sprig-leaf.png")
print(GV.report(t))
