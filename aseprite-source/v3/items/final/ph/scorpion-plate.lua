-- scorpion-plate (final, artist D14_3, Sonnet high). One carapace plate off a desert scorpion: a slim tapering shield
-- with a notched front edge, a raised central keel and two diagonal ridges forming a Y, two curved suture furrows,
-- a finely granulated surface and a serrated margin. Lit from a real height field (ridges, furrows and every granule
-- get their own highlight and shadow), amber-brown chitin in a 6-tone ramp, waxy specular on the left shoulder.
-- quirk: the two glossy median eyes sit on a little raised mound at the front, so the plate seems to stare back.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_aD14_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, sqrt, max, min = math.floor, math.abs, math.sin, math.cos, math.sqrt, math.max, math.min
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "scorpion-plate" }

local CHIT = A.ramp("#bc7430")
local EYE  = A.ramp("#3a2840")
local CREAM, SPEC = "#fff4d6", "#ffefb0"
local tok = { r = { name = "chit" } }

-- outline mask
local Y0, Y1 = 8, 50
local function hw(y) return 10.2 + 7.4 * (max(0, y - 9) / 38) ^ .8 end
local function ytop(x) return 8 + 4.2 * (min(1, abs(x - 32) / 12) ^ 2.2) end
local function ybot(x) return 50 - 2.6 * (1 - min(1, abs(x - 32) / 18) ^ 2) end
local pl = HP.mask()
for y = Y0, Y1 do
  local w = hw(y)
  for x = floor(32 - w + .5), floor(32 + w - .5) do
    if y >= ytop(x) and y <= ybot(x) then pl:set(x, y) end
  end
end
-- round the four corners a touch
for _, p in ipairs{ { 22, 8 }, { 42, 8 }, { 22, 9 }, { 42, 9 } } do end
local function corner(x, y) pl:cut(c:rect(x, y, x, y)) end
local bx0, by0, bx1, by1 = pl:bbox()
-- serrated margin on the lower side edges
pl:each(function(x, y) end)
local ser = {}
for y = 27, 46, 6 do
  local w = hw(y)
  local lx, rx = floor(32 - w + .5), floor(32 + w - .5)
  corner(lx, y) corner(rx, y)
  corner(lx, y + 1) corner(rx, y + 1)
  if lx + 1 <= 32 then corner(lx, y + 2) corner(rx, y + 2) end
end
-- soften pixel stair at rear corners
pl:each(function(x, y) end)

---------------------------------------------------------------- height field
local dist = X.dist(pl)
local R = 6.5
local function h0(x, y)
  local d = dist[K(x, y)]
  if not d then return 0 end
  local t = min(d + .5, R) / R
  return R * sqrt(1 - (1 - t) ^ 2)
end
local function segd(px, py, ax, ay, bx, by)
  local vx, vy = bx - ax, by - ay
  local t = max(0, min(1, ((px - ax) * vx + (py - ay) * vy) / (vx * vx + vy * vy)))
  local dx, dy = px - (ax + vx * t), py - (ay + vy * t)
  return sqrt(dx * dx + dy * dy), t
end
local ridges = {
  { 32, 14, 32, 47, 2.8, 3.6 },       -- keel
  { 31, 18, 17.5, 42, 2.4, 2.7 },     -- left diagonal
  { 33, 18, 46.5, 42, 2.4, 2.7 },     -- right diagonal
}
local bumps = {}
pl:each(function(x, y)
  -- granules on a loose lattice, hashed; kept off the ridges and the far margin
  local gx, gy = x % 3, (y + (x // 3) % 2 * 1) % 3
  if (x % 4 == 1) and ((y + (x // 4) * 2) % 4 == 1) and A.hash(x, y, 7) > .3 then bumps[K(x, y)] = .75 end
end)
local function furrow(x, y)
  -- two curved transverse sutures (concave grooves)
  local f = 0
  for _, yy in ipairs{ 28, 38 } do
    local cy = yy + 3.4 * (abs(x - 32) / 17) ^ 2
    local d = abs(y - cy)
    if d < 1.9 and abs(x - 32) > 4 then f = f - 2.4 * (1 - d / 1.9) end
  end
  return f
end
local function hf(x, y)
  if not pl:has(x, y) then return 0 end
  local h = h0(x, y)
  for _, r in ipairs(ridges) do
    local d = segd(x, y, r[1], r[2], r[3], r[4])
    if d < r[5] then h = h + r[6] * (1 - (d / r[5]) ^ 2) end
  end
  h = h + furrow(x, y) + (bumps[K(x, y)] or 0)
  return h
end
-- eye mound
local MX, MY = 32, 15
local function mound(x, y)
  local d = sqrt((x - MX) ^ 2 + ((y - MY) * 1.25) ^ 2)
  if d < 5.2 then return 2.4 * (1 - (d / 5.2) ^ 2) end
  return 0
end

local n, v = {}, nil
local hcache = {}
pl:each(function(x, y) hcache[K(x, y)] = hf(x, y) + mound(x, y) end)
local function H(x, y) local k = K(x, y) return hcache[k] or (pl:has(x, y) and 0 or (hcache[K(x, y)] or 0)) end
local S = 1.5
pl:each(function(x, y)
  local gx = (H(x + 1, y) - H(x - 1, y)) / 2 * S
  local gy = (H(x, y + 1) - H(x, y - 1)) / 2 * S
  local l = sqrt(gx * gx + gy * gy + 1)
  n[K(x, y)] = { -gx / l, -gy / l, 1 / l }
end)

local bias = {}
-- ambient: darker toward the lower right margin and in the furrows
pl:each(function(x, y)
  local k = K(x, y)
  if furrow(x, y) < -.6 then bias[k] = -1 end
end)
local _, idx = A.paint(c, pl, n, CHIT, { amb = .06, wrap = .22, cuts = { .22, .4, .56, .72, .87 }, tok = tok, adj = function(x, y, i)
  local k = K(x, y)
  local d = dist[k] or 9
  -- margin: one dark row on the shade edges, one lit chamfer row on the upper-left
  if d < 1.2 and (not pl:has(x + 1, y + 1) or not pl:has(x + 1, y) or not pl:has(x, y + 1)) then i = i - 1 end
  return i + (bias[k] or 0)
end })

-- keel centre: bright seam stripe with dark flank shown by the height field already; add a polished edge line
for y = 18, 45 do
  if (y % 5) ~= 0 then c:px(31, y, CHIT[5]) end
end
-- granule glints on the lit side only (pairs of 1px)
pl:each(function(x, y)
  if bumps[K(x, y)] and x < 30 and y < 30 and A.hash(x, y, 2) > .55 then c:px(x, y, CHIT[6]) end
end)

---------------------------------------------------------------- front: eye mound + median eyes (quirk)
do
  local mm = HP.mask()
  for y = 8, 22 do for x = 24, 40 do if mound(x, y) > .9 then mm:set(x, y) end end end
  -- the mound is already lit by the height field; ambient ring where it meets the plate
  local ring = mm:grow(1):cut(mm)
  ring:each(function(x, y) if pl:has(x, y) then c:px(x, y, CHIT[1]) end end)
  -- eyes: two glossy dark beads with a bright glint
  for _, ex in ipairs{ 29.5, 34.5 } do
    local em = c:ellipse(ex, 15, 2, 2)
    local en = X.sphere(ex - .5, 14.5, 2.2, em)
    A.paint(c, em, en, EYE, { amb = .05, wrap = .15, cuts = { .25, .45, .62, .78, .9 } })
    c:px(floor(ex - 1.5), 14, CREAM)
  end
  -- under-lip shadow of the mound
  for x = 28, 36 do if pl:has(x, 19) then c:px(x, 19, CHIT[2]) end end
end

---------------------------------------------------------------- side eyes: three tiny beads each flank (reads as a cluster)
for _, p in ipairs{ { 23, 13 }, { 22, 15 }, { 24, 16 } } do
  if pl:has(p[1], p[2]) then c:px(p[1], p[2], EYE[2]) c:px(p[1] - 0, p[2] - 0, EYE[2]) end
end
for _, p in ipairs{ { 41, 13 }, { 42, 15 }, { 40, 16 } } do
  if pl:has(p[1], p[2]) then c:px(p[1], p[2], EYE[2]) end
end


-- waxy specular on the left shoulder
c:px(21, 24, SPEC) c:px(22, 24, SPEC) c:px(21, 25, CHIT[6])
c:px(20, 33, SPEC) c:px(20, 34, CHIT[6])
-- cool bounce light on the lower right rim
local rim = X.rim(n)
pl:edge():each(function(x, y) if (rim[K(x, y)] or 0) > .72 and y > 28 then c:px(x, y, "#8a7ab8") end end)

A.fin(c, "scorpion-plate")
