-- front-pack: Trail Pack avatar layer, front view (Opus pass, art-2701). 512x80 = 8 frames of 64x80, lined up with gnome25.
-- This layer is drawn FIRST (behind the whole gnome), so only what peeks past the body shows:
--  * the pack's two top corners over the shoulders: oat canvas with a leather flap, a strap and a brass buckle;
--  * the dusk-wool blanket roll under the pack (same colours as back-pack): only its rolled ends peek out at the hips,
--    2-3 px past the hands (Sonnet's roll stuck out about 7 px each side), each end showing the spiral of the roll.
-- Bob and the one-frame cloth lag match the old layer. quirk: a lavender sprig poking up behind the right shoulder.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_o.lua")
local W = O.W
local CANVAS = { "#5b5142", "#877a5c", "#b3a57e", "#d3c7a2", "#ece4c8" }
local STRAP = { "#51302b", "#7c4a31", "#a96a40", "#d69a62" }
local BLANKET = { "#35295f", "#5a459e", "#8a6fd0", "#b9a2ea" }
local GOLD = { "#d9a33a", "#ffe38a" }
local LAV = { "#5a459e", "#8a6fd0", "#c9b2f0" }
local STEM = { "#3f9150", "#7cc35a" }

local function rr(x0, y0, x1, y1, r)   -- rounded rect as a set
  local m = {}
  for y = y0, y1 do for x = x0, x1 do
    local dx = math.max(x0 + r - x, 0, x - (x1 - r))
    local dy = math.max(y0 + r - y, 0, y - (y1 - r))
    if dx * dx + dy * dy <= r * r + r * 0.6 then m[y * W + x] = { x, y } end
  end end
  return m
end

local frames = {}
for f = 0, 7 do
  local p = O.F[f + 1]
  local b, s = -p.bob, O.SWAY[f + 1]
  local px = {}
  -- pack body: canvas, lit left, shade right
  local x0, x1, y0 = 17 + s, 48 + s, 41 + b
  for k, q in pairs(rr(x0, y0, x1, 58 + b, 3)) do
    local x, y = q[1], q[2]
    local u = (x - x0) / (x1 - x0)
    local t = 3
    if u < 0.12 then t = 4 end
    if u > 0.86 then t = 2 end
    if x == x0 then t = 3 end
    -- leather flap over the top: 3 rows, its lower edge dips at the corners
    local flap = y <= y0 + 2 or (y == y0 + 3 and (x <= x0 + 2 or x >= x1 - 2))
    if flap then
      local c = STRAP[3]
      if y == y0 then c = (u < 0.5) and STRAP[4] or STRAP[3] end
      if u > 0.86 then c = STRAP[2] end
      if (y == y0 + 2 and x > x0 + 2 and x < x1 - 2) or y == y0 + 3 then c = STRAP[1] end   -- flap edge
      px[k] = c
    else
      px[k] = CANVAS[t]
      if y == y0 + 3 or y == y0 + 4 and (x == x0 + 1 or x == x1 - 1) then px[k] = CANVAS[math.max(1, t - 1)] end -- under-flap shadow
    end
  end
  -- buckle straps down from the flap on both corners
  for _, sx in ipairs{ x0 + 2, x1 - 2 } do
    for y = y0 + 3, y0 + 6 do px[y * W + sx] = (sx < 32) and STRAP[2] or STRAP[1] end
    px[(y0 + 4) * W + sx] = (sx < 32) and GOLD[2] or GOLD[1]
  end
  -- canvas seam stitch near the outer edges (2 on 1 off)
  for y = y0 + 4, y0 + 12 do if (y - y0) % 3 ~= 0 then
    px[y * W + x0 + 1] = CANVAS[5]
    px[y * W + x1 - 1] = CANVAS[2]
  end end
  -- blanket roll under the pack
  local ry0, ry1 = 57 + b, 62 + b
  local bx0, bx1 = 15 + s, 50 + s
  for k, q in pairs(rr(bx0, ry0, bx1, ry1, 2)) do
    local x, y = q[1], q[2]
    local c = BLANKET[3]
    if y == ry0 then c = BLANKET[4] end
    if y >= ry1 - 1 then c = BLANKET[2] end
    if y == ry1 then c = BLANKET[1] end
    px[k] = c
  end
  -- rolled ends: spiral (dark core, lit turn) and a gold stripe one pixel in
  for _, e in ipairs{ { bx0, 1 }, { bx1, -1 } } do
    local ex, d = e[1], e[2]
    for y = ry0 + 1, ry1 - 1 do px[y * W + ex] = (d > 0) and BLANKET[3] or BLANKET[2] end
    px[(ry0 + 2) * W + ex + d] = BLANKET[1]
    px[(ry0 + 3) * W + ex + d] = BLANKET[2]
    px[(ry0 + 2) * W + ex] = (d > 0) and BLANKET[4] or BLANKET[3]
    for y = ry0, ry1 - 1 do px[y * W + ex + 3 * d] = (y == ry0) and GOLD[2] or GOLD[1] end
    px[(ry1) * W + ex + 3 * d] = BLANKET[1]
    -- leather tie just inside
    for y = ry0, ry1 do px[y * W + ex + 5 * d] = (y == ry1) and STRAP[1] or STRAP[2] end
  end
  -- quirk: a lavender sprig tucked under the right flap, leaning out past the shoulder
  local lx, ly = x1 - 1, y0
  local stem = { { 0, -1 }, { 1, -2 }, { 1, -3 }, { 2, -4 }, { 3, -5 } }
  for _, q in ipairs(stem) do px[(ly + q[2]) * W + lx + q[1]] = STEM[1] end
  px[(ly - 3) * W + lx + 2] = STEM[2]   -- leaf
  O.paint(px, { ".a.", "bcb", "aba", ".a." }, lx + 2, ly - 9, { a = LAV[1], b = LAV[2], c = LAV[3] })
  frames[#frames + 1] = O.finish(px, nil)
end
O.saveStrip("front-pack", frames)
