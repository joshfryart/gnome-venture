-- pale-scale.lua : one soft white olm scale, a rounded fan tilted on its rose-pink root (64x64 sticker)
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- the Pale Olm's own tones: pale flesh body, rose gill root, violet flank stripe
local pale = GV.ramp("#e8d8d0")
local rose = GV.ramp("#c98f8f")

-- a smooth teardrop: broad rounded free end at the upper right, tapering to its root at the lower left
local RX, RY, BX, BY, BR = 17, 48, 37, 25, 17
local fan = c:mask()
for i = 0, 20 do
  local k = i / 20
  fan:add(c:ellipse(BX + (RX - BX) * k, BY + (RY - BY) * k, BR + (3 - BR) * k))
end
-- scalloped free edge: three small notches round the broad end
local ax = math.atan(RY - BY, BX - RX)
for _, d in ipairs({ -0.62, 0, 0.62 }) do
  local a = ax + d
  fan:cut(c:ellipse(math.floor(BX + (BR + 1) * math.cos(a)) + 0.5, math.floor(BY - (BR + 1) * math.sin(a)) + 0.5, 2.5, 2.5))
end
-- rose root tip where the scale was set in the skin
local root = fan:copy():clip(c:ellipse(RX, RY, 7.5, 7.5))

local p = c:build{
  { "fan",  fan,  pale, { pale = true, gloss = { 24, 22 } } },
  { "root", root, rose, { gloss = false } },
}
-- growth lines: concentric arcs echoing the rim, faint violet like the olm's flank
local function arc(cx, cy, r, a0, a1, col)
  local pts = {}
  for i = 0, 16 do
    local a = a0 + (a1 - a0) * i / 16
    pts[#pts + 1] = { math.floor(cx + r * math.cos(a) + 0.5), math.floor(cy - r * math.sin(a) + 0.5) }
  end
  c:fill(c:line(pts, 1):clip(fan:shrink(2)), col)
end
for _, r in ipairs({ 14, 21, 28 }) do arc(RX, RY, r, ax - 0.75, ax + 0.75, r == 21 and "#8f7fc9" or "#b9acd8") end
-- the seam where the root is sewn onto the scale
local sp = {}
for i = 0, 10 do
  local a = ax - 1.3 + 2.6 * i / 10
  sp[#sp + 1] = { math.floor(RX + 9 * math.cos(a) + 0.5), math.floor(RY - 9 * math.sin(a) + 0.5) }
end
c:seam(sp)

local t = c:save(D .. "final/aseprite/ph/pale-scale.aseprite", PNG .. "pale-scale.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw <= 1 and t.margin >= 3)  -- bw 1 = the single #ffffff pale gloss dot (pale-subject rule)
