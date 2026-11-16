-- front-pack (Trail Pack avatar layer, front view) redo. 512x80 = 8 frames of 64x80, lined up with the gnome25 body.
-- Was: only the two top corners of a canvas bag peeking over the shoulders. Now the pack reads from the front:
-- wider canvas bag with leather flap + tie at the shoulders, a stitched side pocket on each flank (sky-blue patch on the
-- right one), a leather strap down each side with a brass buckle, and the rolled striped blanket sticking out both
-- sides under the arms. Sways one frame behind the body like the old layer (SWAY), bobs with the body.
-- The layer sits BEHIND the gnome (first in the stack), so only what is wider than the body shows.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local S = dofile(DIR .. "/_strip.lua")
local W = S.W
local floor = math.floor
local CANVAS = { hi="#ece4c8", lt="#d3c7a2", base="#b3a57e", sh="#877a5c", dp="#5b5142" }
local STRAP  = { hi="#d69a62", base="#a96a40", sh="#7c4a31", dp="#51302b" }
local BLANKET = { hi="#b9a2ea", base="#8a6fd0", sh="#5a459e", dp="#35295f", st="#ffe38a" }
local BUCKLE = { hi="#ffe38a", base="#d9a33a" }
local PATCH = { base="#8bc4ea", sh="#5f9ad0", hi="#e4f6ff" }
local SWAY = { 0, 0, 0, -1, -1, 0, 1, 1 }

local function rrect(x0, y0, x1, y1, r)   -- same rasterisation as hp.lua
  local m = {}
  for y = y0, y1 do for x = x0, x1 do
    local cx, cy
    if x < x0 + r then cx = x0 + r elseif x > x1 - r then cx = x1 + 1 - r end
    if y < y0 + r then cy = y0 + r elseif y > y1 - r then cy = y1 + 1 - r end
    if cx == nil or cy == nil or (x + .5 - cx) ^ 2 + (y + .5 - cy) ^ 2 <= r * r then m[y * W + x] = true end
  end end
  return m
end
local function bounds(m)
  local rows = {}
  for k in pairs(m) do local x, y = k % W, k // W
    local a = rows[y]; if not a then a = { x, x }; rows[y] = a end
    if x < a[1] then a[1] = x end; if x > a[2] then a[2] = x end end
  return rows
end
local function canvas(px, m, frac)
  local rows = bounds(m)
  for k in pairs(m) do
    local x, y = k % W, k // W
    local t = rows[y]; local u = (x - t[1] + .5) / (t[2] - t[1] + 1)
    local c = CANVAS.base
    if u < 0.12 then c = CANVAS.lt end
    if u > 1 - frac then c = CANVAS.sh end
    if not m[(y + 1) * W + x] then c = CANVAS.dp end
    px[k] = c
  end
end
local function K(x, y) return y * W + x end

local frames = {}
for f = 0, 7 do
  local p = S.FRAMES[f + 1]
  local b, s = -(p.bob or 0), SWAY[f + 1]
  local px = {}
  local bag = rrect(12 + s, 41 + b, 52 + s, 58 + b, 4)
  canvas(px, bag, 0.2)
  -- leather flap over the top, curved lower edge, tie knot in the middle
  for k in pairs(bag) do
    local x, y = k % W, k // W
    local edge = 45 + b + ((x > 20 + s and x < 44 + s) and 1 or 0)
    if y <= edge then
      local c = STRAP.base
      if (x - 12 - s) < 5 or not bag[K(x, y - 1)] then c = STRAP.hi end
      if x > 48 + s then c = STRAP.sh end
      if y == edge then c = STRAP.dp end
      px[k] = c
    end
  end
  -- side pockets, one on each flank, with a stitched top seam
  for _, side in ipairs{ -1, 1 } do
    local x0 = (side < 0) and (10 + s) or (50 + s)
    local pocket = rrect(x0, 50 + b, x0 + 3, 58 + b, 2)
    for k in pairs(pocket) do
      local x, y = k % W, k // W
      local c = (side < 0) and ((x == x0) and CANVAS.hi or CANVAS.lt) or ((x == x0 + 3) and CANVAS.sh or CANVAS.base)
      if y == 50 + b then c = CANVAS.hi end
      if not pocket[K(x, y + 1)] then c = CANVAS.dp end
      px[k] = c
    end
    for y = 52 + b, 56 + b, 2 do px[K(side < 0 and (11 + s) or (51 + s), y)] = STRAP.hi end   -- stitch dashes
  end
  -- sky-blue patch on the right pocket (quirk), two tack stitches
  px[K(51 + s, 54 + b)] = PATCH.base; px[K(52 + s, 54 + b)] = PATCH.base
  px[K(51 + s, 55 + b)] = PATCH.base; px[K(52 + s, 55 + b)] = PATCH.sh
  px[K(51 + s, 54 + b)] = PATCH.hi
  -- rolled striped blanket, sticking out both sides under the arms
  local roll = rrect(7 + s, 60 + b, 56 + s, 65 + b, 2)
  for k in pairs(roll) do
    local x, y = k % W, k // W
    local r = y - (60 + b)
    local c = BLANKET.base
    if r == 0 then c = BLANKET.hi elseif r >= 4 then c = BLANKET.sh end
    if r == 5 then c = BLANKET.dp end
    if (x - 7 - s) % 6 == 4 and r < 5 then c = BLANKET.st end
    px[k] = c
  end
  -- leather straps down each flank, tying bag and roll, brass buckle on the roll
  for _, sx in ipairs{ 13 + s, 49 + s } do
    for y = 46 + b, 65 + b do
      for dx = 0, 1 do
        if bag[K(sx + dx, y)] or roll[K(sx + dx, y)] then
          px[K(sx + dx, y)] = (dx == 0) and STRAP.base or STRAP.sh
          if y == 65 + b then px[K(sx + dx, y)] = STRAP.dp end
        end
      end
    end
    px[K(sx, 62 + b)] = BUCKLE.hi; px[K(sx + 1, 62 + b)] = BUCKLE.base
    px[K(sx, 63 + b)] = BUCKLE.base; px[K(sx + 1, 63 + b)] = BUCKLE.base
  end
  local body = S.mask("front", S.BODY, f)
  frames[#frames + 1] = S.finish(px, body)
end
S.save("front-pack", frames)
