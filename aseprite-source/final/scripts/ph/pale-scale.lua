-- pale-scale.lua : one soft white olm scale, a rounded fan tilted on its rose-pink root (64x64 sticker)
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- the Pale Olm's own tones: pale flesh body, rose gill root, violet flank stripe
local pale = GV.ramp("#e8d8d0")
local rose = GV.ramp("#c98f8f")

-- a rounded fan: wide scalloped top edge at the upper right, tapering to a root at the lower left
local fan = c:ellipse(35.5, 27.5, 18, 16)
fan:add(c:poly({ { 15, 47 }, { 20, 24 }, { 40, 42 } }))
fan:add(c:ellipse(22, 40, 8, 8))
-- scalloped rim: three small notches along the outer edge
for _, q in ipairs({ { 45, 11 }, { 54, 20 }, { 55, 32 } }) do fan:cut(c:ellipse(q[1], q[2], 1.5, 1.5)) end
-- rose root where the scale was set in the skin
local root = c:ellipse(15.5, 48.5, 5.5, 5)

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
arc(18, 46, 18, -0.05, 1.62, "#b9acd8")
arc(18, 46, 26, 0.02, 1.52, "#b9acd8")
-- the seam where the root is sewn onto the scale
c:seam({ { 13, 43 }, { 21, 51 } }, { free = true })

local t = c:save(D .. "final/aseprite/ph/pale-scale.aseprite", PNG .. "pale-scale.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw <= 1 and t.margin >= 3)  -- bw 1 = the single #ffffff pale gloss dot (pale-subject rule)
