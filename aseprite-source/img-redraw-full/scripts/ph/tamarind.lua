local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- quadratic spine from lower-left up and over to the right
local P0, C, P2 = { 14, 42 }, { 20, 20 }, { 52, 22 }
local function B(t)
  local a, b, d = (1 - t) ^ 2, 2 * t * (1 - t), t * t
  return a * P0[1] + b * C[1] + d * P2[1], a * P0[2] + b * C[2] + d * P2[2]
end
local function N(t) -- upward normal
  local dx = 2 * (1 - t) * (C[1] - P0[1]) + 2 * t * (P2[1] - C[1])
  local dy = 2 * (1 - t) * (C[2] - P0[2]) + 2 * t * (P2[2] - C[2])
  local l = math.sqrt(dx * dx + dy * dy)
  local nx, ny = dy / l, -dx / l
  if ny > 0 then nx, ny = -nx, -ny end
  return nx, ny
end
local function R(t) return 2.2 + 4.3 * math.sin(math.pi * t) end

local pod = c:mask()
for i = 0, 60 do
  local t = i / 60
  local x, y = B(t)
  pod:add(c:ellipse(x, y, R(t), R(t)))
end
-- seed bumps riding the top edge
local bumps = {}
for _, t in ipairs({ 0.36, 0.55, 0.74 }) do
  local x, y = B(t)
  local nx, ny = N(t)
  local r = R(t)
  local bx, by = x + nx * (r - 1), y + ny * (r - 1)
  bumps[#bumps + 1] = c:ellipse(math.floor(bx) + 0.5, math.floor(by) + 0.5, 4, 4)
end
local stem = c:line({ { 14, 43 }, { 12, 46 }, { 11, 48 } }, 3)

local body = GV.ramp("#3f93b2", { shade = "#2f6290", deep = "#2a3c6c" })
local seed = GV.ramp("#3f93b2", { rim = "#8fcbd8", shade = "#256a80", deep = "#2a3c6c" })
local whole = pod:copy()
for _, b in ipairs(bumps) do whole:add(b) end

local parts = {
  { "stem", stem, "#2f5a2a", { flat = true } },
  { "pod", pod, body, { cres = 4, deep = 2, light = whole, gloss = false } },
}
for i, b in ipairs(bumps) do
  parts[#parts + 1] = { "bump" .. i, b, seed, { gloss = false, cres = 2, deep = 1, light = whole } }
end
local p = c:build(parts)
-- enamel gloss on the middle bump and a comma on the pod shoulder
c:gloss(p.bump1.m, seed)
c:gloss(p.bump2.m, seed)
c:gloss(p.bump3.m, seed)

local t = c:save(D .. "img-redraw-full/aseprite/ph/tamarind.aseprite", D .. "img-redraw-full/png/ph/tamarind.png")
print(GV.report(t))
