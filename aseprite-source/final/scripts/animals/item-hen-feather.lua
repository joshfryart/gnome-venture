-- animals/item-hen-feather : plump brown hen feather, diagonal
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local P0x, P0y = 14, 51              -- quill end
local P1x, P1y = 50, 13              -- tip
local L = math.sqrt((P1x - P0x)^2 + (P1y - P0y)^2)
local ux, uy = (P1x - P0x) / L, (P1y - P0y) / L
local nx, ny = -uy, ux               -- normal (towards lower right)
local function bow(t) return -2.5 * math.sin(math.pi * t / L) end
local T0 = 8
local function half(t)
  if t < T0 or t > L then return -1 end
  local f = (t - T0) / (L - T0)
  return 10.5 * math.sin(math.pi * (f ^ 0.75)) ^ 0.8
end

local vane = c:mask()
for y = 0, 63 do for x = 0, 63 do
  local px, py = x - P0x, y - P0y
  local t = px * ux + py * uy
  local d = px * nx + py * ny
  local h = half(t)
  -- slightly fuller on the upper-left side
  local dd = d - bow(t)
  if dd < 0 then h = h * 1.05 end
  if h > 0 and math.abs(dd) <= h then vane:set(x, y) end
end end
-- two little splits in the vane edges
local function at(t, off) local b = bow(t) + off; return P0x + ux * t + nx * b, P0y + uy * t + ny * b end
for _, s in ipairs({ { 22, 1 }, { 30, -1 } }) do
  local t, side = s[1], s[2]
  local h = half(t)
  local ax, ay = at(t + 1, side * (h + 2))
  local bx, by = at(t - 4, side * (h - 4.5))
  local cx2, cy2 = at(t + 4, side * (h + 2))
  vane:cut(c:poly({ { math.floor(ax), math.floor(ay) }, { math.floor(bx), math.floor(by) }, { math.floor(cx2), math.floor(cy2) } }))
end

local spts = {}
for t = 0, L - 3, 2 do local x, y = at(t, 0); spts[#spts + 1] = { math.floor(x + 0.5), math.floor(y + 0.5) } end

c:build{
  { "vane",  vane, "wood" },
  { "spine", c:line(spts, 2), GV.ramp("#8a4f2a"), { flat = true } },
}
-- barbs: thin strokes from spine angled towards the tip
for _, b in ipairs({ { 16, 1 }, { 26, 1 }, { 36, 1 }, { 20, -1 }, { 32, -1 } }) do
  local t, side = b[1], b[2]
  local x0, y0 = at(t, side * 2)
  local x1, y1 = at(t + 5, side * (half(t + 5) * 0.6))
  c:fill(c:line({ { math.floor(x0 + 0.5), math.floor(y0 + 0.5) }, { math.floor(x1 + 0.5), math.floor(y1 + 0.5) } }, 1):clip(vane:shrink(1)), "#a8582f")
end
-- quill tip pale
local qx, qy = at(1, 0)
c:fill(c:rect(math.floor(qx), math.floor(qy), math.floor(qx) + 1, math.floor(qy) + 1), "#d9a660")

local t = c:save(O .. "aseprite/animals/item-hen-feather.aseprite", O .. "png/animals/item-hen-feather.png")
print(GV.report(t))
