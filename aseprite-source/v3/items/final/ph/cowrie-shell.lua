-- cowrie-shell (final, Opus single pass). A tiger-style cowrie seen in 3/4 from the side: a long glossy egg-dome,
-- honey-to-umber six-tone ramp with mottled chestnut spots and a pale mantle line down the back, a cool violet
-- reflected rim on the shade side, two hard specular glints (porcelain gloss). Below the dome the flat underside
-- shows as a cream lip band with the toothed aperture slit (ink slot, pale teeth, AO under the dome's overhang).
-- quirk: a hole drilled at the right end carries a short loop of twisted twine, like a cowrie once used as coin.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB22_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "cowrie-shell"
local c = A.new(NAME)
local DOME = { "#4a2a3a", "#7a3e34", "#b0683c", "#d8964e", "#f0c070", "#ffe4a6" }
local SPOT = { "#3e2230", "#5e3030", "#80452e" }
local LIP = { "#8a7a8a", "#bcaea8", "#e2d4c0", "#f6ecd8", "#fff8ea" }
local ROPE = { "#5e3a2e", "#8a5a3a", "#b8864e", "#dcb47a" }
local VIO = "#7a5a8a"

local CX, CY, ANG = 30, 33, -0.18
local ca, sa = cos(ANG), sin(ANG)
-- underside lip (drawn first), dome on top
local lipm = A.rell(CX + 1, CY + 6, ca, sa, 19.5, 8.6)
local dm, dn = A.oval(CX, CY - 1, 20, 10.5, ANG, 0.8)
-- flatten the dome's belly so the lip band shows
local lipv = lipm:copy():cut(dm)
local ltok = { r = { name = "lip" } }
lipv:each(function(x, y)
  local dx, dy = x - CX - 1, y - CY - 6
  local u = (dx * ca + dy * sa) / 19.5
  local v = (-dx * sa + dy * ca) / 8.6
  local i = (v > 0.75) and 2 or ((u < -0.3) and 4 or 3)
  c:put(x, y, LIP[i], ltok)
end)
-- AO under dome overhang
dm:shift(0, 1):each(function(x, y) if lipv:has(x, y) and not dm:has(x, y) then c:put(x, y, LIP[1], ltok) end end)
-- aperture slit: per column, midway through the visible lip band, with pale teeth ticks on both sides
do
  for x = 0, 63 do
    local ys = {}
    for y = 0, 63 do if lipv:has(x, y) then ys[#ys + 1] = y end end
    if #ys >= 4 then
      local y = ys[1] + floor(#ys / 2)
      c:put(x, y, "#2b1c26", ltok)
      if x % 3 == 0 then
        c:put(x, y - 1, LIP[5], ltok) c:put(x, y + 1, LIP[4], ltok)
      else
        c:put(x, y + 1, LIP[2], ltok)
      end
    end
  end
end

-- dome
local dtok = { r = { name = "dome" } }
local idx = A.shade(c, dm, dn, DOME, { tok = dtok, amb = 0.08, wrap = 0.22, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
-- mottled spots (sizes vary), dimmer in shade
dm:each(function(x, y) local k = K(x, y)
  local dx, dy = x - CX, y - CY
  local u = (dx * ca + dy * sa) / 20
  local v = (-dx * sa + dy * ca) / 11.5
  -- mantle line: pale wavy stripe along the back
  local ml = -0.18 + 0.05 * sin(u * 9)
  if abs(v - ml) < 0.06 and abs(u) < 0.82 then c:put(x, y, DOME[min(6, idx[k] + 1)], dtok) return end
  local h = X.hash(floor((x + 1) / 3), floor((y + 2) / 3), 5)
  local h2 = X.hash(x, y, 9)
  if h > 0.62 and h2 > 0.35 and abs(v - ml) > 0.12 and u * u + v * v < 0.86 then
    local i = idx[k]
    c:put(x, y, SPOT[i >= 5 and 3 or (i >= 3 and 2 or 1)], dtok)
  end
end)
-- cool reflected rim on the lower right
dm:edge():each(function(x, y) local k = K(x, y)
  local dx, dy = x - CX, y - CY
  if dx * 0.5 + dy > 3 and idx[k] <= 3 then c:put(x, y, VIO, dtok) end end)
-- porcelain gloss: big spec streak + small secondary
for _, q in ipairs{ { 20, 25 }, { 21, 25 }, { 22, 24 }, { 23, 24 }, { 21, 26 } } do c:put(q[1], q[2], "#fff8e6", dtok) end
c:put(35, 23, "#ffeec8", dtok) c:put(36, 23, "#ffeec8", dtok)

-- quirk: drilled hole + twisted twine loop at the right end
do
  local hx, hy = 46, 28
  c:put(hx, hy, "#2b1c26", dtok) c:put(hx + 1, hy, "#2b1c26", dtok) c:put(hx, hy + 1, "#3e2230", dtok) c:put(hx - 1, hy - 1, DOME[6], dtok)
  local rtok = { r = { name = "twine" } }
  local rm, rn, RT = A.tube({ { hx + 1, hy - 1 }, { hx + 7, hy - 9 }, { hx + 12, hy - 3 }, { hx + 6, hy + 3 } }, function(t) return 1.0 end)
  rm:cut(dm)
  local ri = A.shade(c, rm, rn, ROPE, { tok = rtok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
  -- twist: diagonal dark ticks
  rm:each(function(x, y) if (x + y) % 3 == 0 then c:put(x, y, ROPE[max(1, ri[K(x, y)] - 1)], rtok) end end)
  -- frayed tail
  c:put(hx + 5, hy + 4, ROPE[2], rtok) c:put(hx + 4, hy + 5, ROPE[3], rtok)
end

A.save(c, NAME)
