local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- curved pod centreline (quadratic), bowing down-right
local P0, P1, P2 = { 12, 42 }, { 36, 38 }, { 54, 17 }
local function B(t)
  local u = 1 - t
  return u * u * P0[1] + 2 * t * u * P1[1] + t * t * P2[1],
         u * u * P0[2] + 2 * t * u * P1[2] + t * t * P2[2]
end
local function N(t) -- upward normal
  local dx = 2 * (1 - t) * (P1[1] - P0[1]) + 2 * t * (P2[1] - P1[1])
  local dy = 2 * (1 - t) * (P1[2] - P0[2]) + 2 * t * (P2[2] - P1[2])
  local l = math.sqrt(dx * dx + dy * dy)
  return dy / l, -dx / l
end
local function R(t) return 2.5 + 4.5 * math.sin(math.pi * t) ^ 0.6 end

local pod = c:mask()
for i = 0, 60 do
  local t = i / 60
  local x, y = B(t)
  pod:add(c:ellipse(x, y, R(t)))
end
local beanT = { 0.3, 0.5, 0.7 }
local beans = {}
for i, t in ipairs(beanT) do
  local x, y = B(t)
  x, y = math.floor(x + 0.5), math.floor(y + 0.5)
  beans[i] = { x, y }
  pod:add(c:ellipse(x, y, R(t) + 1.5))
end
local stalk = c:rect(7, 41, 10, 47)

local parts = {
  { "stalk", stalk, "moss", { flat = true } },
  { "pod",   pod,   "wood" },
}
local bean = GV.ramp("#c8d77a", { shade = "#7ab55c", deep = "#4a8a3e" })
for i, b in ipairs(beans) do
  parts[#parts + 1] = { "bean" .. i, c:ellipse(b[1], b[2], 3, 3), bean, { cres = 2, deep = 1 } }
end
c:build(parts)

-- pod seam along the top edge, thread gold over a dark crease
local pts = {}
for i = 0, 12 do
  local t = 0.14 + i / 12 * 0.74
  local x, y = B(t)
  local nx, ny = N(t)
  local o = R(t) - 2
  pts[#pts + 1] = { math.floor(x + nx * o + 0.5), math.floor(y + ny * o + 0.5) }
end
c:seam(pts, { gap = "#5e2f1e" })

local t = c:save(O .. "aseprite/ph/soybean.aseprite", O .. "png/ph/soybean.png")
print(GV.report(t))
