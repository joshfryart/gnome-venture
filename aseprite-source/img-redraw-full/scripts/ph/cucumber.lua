local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- axis of the pill: -35 deg, lower left to upper right
local ax, ay = 0.819, -0.574          -- along
local nx, ny = 0.574, 0.819           -- across (toward lower right = underside)
local cx, cy, half, r = 31, 33, 13, 8.5
local function along(x, y) return (x - cx) * ax + (y - cy) * ay end
local function across(x, y) return (x - cx) * nx + (y - cy) * ny end
local body, stripe = c:mask(), c:mask()
for y = 0, 63 do for x = 0, 63 do
  local a, d = along(x + 0.5, y + 0.5), across(x + 0.5, y + 0.5)
  local ca = math.max(-half, math.min(half, a))
  local dd = math.sqrt((a - ca) ^ 2 + d ^ 2)
  if dd <= r then body:set(x, y) end
  if d >= 2 and d <= 5.5 and math.abs(a) <= half + 3 then stripe:set(x, y) end
end end
stripe:clip(body:shrink(2))
-- stem nub at the upper-right tip
local tx, ty = cx + ax * (half + r - 1), cy + ay * (half + r - 1)
local stem = c:poly({ {tx - 2, ty - 1}, {tx + 1, ty - 5}, {tx + 5, ty - 3}, {tx + 3, ty + 2} })
c:build{
  { "body",   body, "moss", { stitch = false } },
  { "stripe", stripe, "#a4b86a", { flat = true, rim = false } },
  { "stem",   stem, GV.ramp("#2f5a2a"), { flat = true } },
}
-- warts along the top edge
for _, a in ipairs({ -9, -2, 5, 11 }) do
  local x, y = math.floor(cx + ax * a + nx * -5.5), math.floor(cy + ay * a + ny * -5.5)
  c:fill(c:rect(x, y, x + 1, y), "#4a8a3e")
end
c:ground(31, 49, 17, 1.5)
local t = c:save(D .. "img-redraw-full/aseprite/ph/cucumber.aseprite", D .. "img-redraw-full/png/ph/cucumber.png")
print(GV.report(t))
