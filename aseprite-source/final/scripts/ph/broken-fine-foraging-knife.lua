local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- knife axis: handle lower-right, tip upper-left
local ux, uy = -0.707, -0.707   -- along the knife toward the tip
local nx, ny = 0.707, -0.707    -- spine side (up-right)
local ox, oy = 40, 40           -- bolster point
local function P(s, t, dx, dy) return { ox + s * ux + t * nx + (dx or 0), oy + s * uy + t * ny + (dy or 0) } end
local function inv(x, y) local dx, dy = x - ox, y - oy; return dx * ux + dy * uy, dx * nx + dy * ny end
local function sm(f) local m = c:mask(); for y = 0, 63 do for x = 0, 63 do local s, t = inv(x, y); if f(s, t) then m:set(x, y) end end end; return m end

-- handle capsule s -16..-3, radius 4
local handle = sm(function(s, t)
  local cs = math.max(-11, math.min(-3, s))
  return (s - cs) ^ 2 + t * t <= 13
end)
-- chipped handle end
handle:cut(sm(function(s, t) return s < -11 and t > 1 end))
local bolster = sm(function(s, t) return s >= -3.5 and s <= -1 and math.abs(t) <= 5 end)

-- blade stump with jagged break
local stump = c:poly({ P(-1.5, 4), P(16, 4), P(18.5, 2), P(15, 0), P(17.5, -2), P(14.5, -4), P(-1.5, -4) })
-- loose tip, knocked away up-left and off-axis
local tdx, tdy = -3, 2
local tip = c:poly({ P(21, 4, tdx, tdy), P(36, 4, tdx, tdy), P(30, -1.5, tdx, tdy), P(21.5, -4, tdx, tdy), P(24, -2, tdx, tdy), P(20.5, 0, tdx, tdy), P(23, 2, tdx, tdy) })

local steel = GV.ramp("#d6c9b6")
c:build{
  { "handle", handle, GV.ramp("#b6814d") },
  { "bolster", bolster, "gold", { gloss = false } },
  { "stump", stump, steel, { pale = true } },
  { "tip", tip, steel, { pale = true } },
}

-- leather wrap bands
for _, s0 in ipairs({ -4.5, -7.5, -10.5 }) do
  local band = sm(function(s, t) return s <= s0 and s > s0 - 2 end):clip(handle)
  c:fill(band, "#8a4f2a")
end

-- hairline crack running back from the break
c:line({ { P(13, 1)[1], P(13, 1)[2] }, { P(10, 2)[1], P(10, 2)[2] }, { P(8, 1)[1], P(8, 1)[2] } }, 1):each(function(x, y)
  if stump:has(x, y) then c:px(x, y, "#4a2c1a") end
end)
-- edge bevel line on the blade
c:line({ { P(0, -2.5)[1], P(0, -2.5)[2] }, { P(13, -2.5)[1], P(13, -2.5)[2] } }, 1):each(function(x, y)
  if stump:has(x, y) then c:px(x, y, steel.shade) end
end)

local t = c:save(O .. "aseprite/ph/broken-fine-foraging-knife.aseprite", O .. "png/ph/broken-fine-foraging-knife.png")
print(GV.report(t))
