-- mini-dew-leech (61x23 still, side view, faces right). Opus third pass (richness).
-- Same creature as opus2: the bog leech's sea-blue sibling, a lower flatter loop, teal rear sucker disc,
-- small front sucker, pale dew-bead stripe, eye on the narrow head, a dew drop on the front sucker (quirk).
-- Richness: the body is lit as a round, glassy-wet tube (per-pixel normals from the spine, 6-tone hue-shifted
-- sea ramp), a long broken specular streak, a stripe of separate dew beads each with its own glint, quiet
-- annulation rings on the shaded half, a paler belly and a warm-green moss bounce line underneath; ridged
-- rear sucker and tooth ring. The dew drop is now a proper 4x5 glass drop (opus2 weakness: 3-4 px) with a
-- bright rim, a pale core and a glint; look closer and the drop reflects the leech's own eye (a dark dot).
local NAME = "mini-dew-leech"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local Q = dofile(DIR .. "/_rich.lua").init(HP)
local P = HP.P
local out = app.params.out or (DIR .. "/")
local W, H = 61, 23
local BODY6 = { "#1f2f5c", "#274a7a", "#33729e", "#4aa6cc", "#7ccce0", "#c0ecf2" }
local BELLY6 = { "#3e5a84", "#56789e", "#6a9cc0", "#94c8dc", "#b4dcea", "#d8f0f4" }
local STRIPE6 = { "#5a86b0", "#7aa8cc", "#a8d8ea", "#d4f2fa", "#e8f8fa", "#f4fcf6" }
local SUCK6 = { "#244a6a", "#2a6a80", "#3e9aa8", "#6ccac4", "#9ae0d0", "#c8f2e2" }
local BOUNCE = "#6aa89a"
local SPOT = "#274a7a"
local SPEC = "#f4fcf6"

local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
c:groundShadow(30, 20, 26, 1.5)
for y = 0, c.h - 1 do for x = 0, c.w - 1 do local i = y * c.w + x
  if c.pix[i] and not c.pix[i - 1] and not c.pix[i + 1] then c.pix[i], c.own[i] = nil, nil end end end

-- spine: cubic Bezier from the rear sucker (left) over the arch to the front sucker (right)
local P0, P1, P2, P3 = { 11, 15 }, { 15, 2 }, { 42, 2 }, { 50, 15 }
local function bez(t)
  local u = 1 - t
  return u^3 * P0[1] + 3 * u^2 * t * P1[1] + 3 * u * t^2 * P2[1] + t^3 * P3[1],
         u^3 * P0[2] + 3 * u^2 * t * P1[2] + 3 * u * t^2 * P2[2] + t^3 * P3[2]
end
local function rad(t) return 4.4 - 1.8 * t end
local body, samples = HP.mask(), {}
for i = 0, 200 do
  local t = i / 200
  local x, y = bez(t)
  samples[#samples + 1] = { x, y, t }
  body:add(HP.ellipse(x, y, rad(t), rad(t)))
end

-- rear sucker disc: a flat oval foot on the ground, radial ridges, dark rim underneath
local rear = c:ellipse(9, 17.5, 7, 2)
local rTok = { r = { name = "rear" } }
Q.body(c, rear, SUCK6, { R = 2, amb = 0.25, tok = rTok })
for _, x in ipairs{ 4, 7, 12, 15 } do if rear:has(x, 18) then c:put(x, 18, SUCK6[2], rTok) end end
c:fillMask(c:line({ { 4, 19 }, { 14, 19 } }, 1), SUCK6[1])
c:put(4, 17, SUCK6[6]) c:put(5, 17, SUCK6[6])

-- body as a lit tube: nearest spine sample gives the normal
local L = Q.X.L
local bTok = { r = { name = "body" } }
local info = {}
body:each(function(x, y)
  local best, bs
  for _, s in ipairs(samples) do
    local d = (x + .5 - s[1]) ^ 2 + (y + .5 - s[2]) ^ 2
    if not best or d < best then best, bs = d, s end
  end
  local r = rad(bs[3])
  local ox, oy = (x + .5 - bs[1]) / (r + .5), (y + .5 - bs[2]) / (r + .5)
  local q = math.max(0.03, 1 - ox * ox - oy * oy)
  local nz = math.sqrt(q)
  local v = 0.16 + 0.84 * math.max(0, (ox * L[1] + oy * L[2] + nz * L[3] + 0.3) / 1.3)
  info[#info + 1] = { x, y, v, ox, oy, bs[3], math.sqrt(ox * ox + oy * oy) }
end)
-- which side is the inside of the arch: the side pointing toward the arch centre (30, 26)
local function inner(x, y, ox, oy) local cx, cy = 30 - x, 19 - y return ox * cx + oy * cy > 0 end
local cuts = { .26, .44, .62, .78, .9 }
local function tone(v) local i = 1 for j, t in ipairs(cuts) do if v >= t then i = j + 1 end end return i end
local idx = {}
for _, p in ipairs(info) do
  local x, y, v, ox, oy, t, d = p[1], p[2], p[3], p[4], p[5], p[6], p[7]
  local i = tone(v)
  local col = BODY6[i]
  local isInner = inner(x, y, ox, oy)
  if isInner and d > 0.45 then col = BELLY6[math.max(1, i)] end
  -- side stripe: a band just above the spine on the outer side
  local outerOff = isInner and -d or d
  if t > 0.06 and t < 0.8 and outerOff > 0.0 and outerOff < 0.36 and math.floor(t * 46) % 3 ~= 2 then
    col = STRIPE6[math.min(6, i + ((math.floor(t * 46) % 3 == 0) and 1 or 0))] end
  idx[Q.X.K(x, y)] = i
  c:put(x, y, col, bTok)
end
-- annulation: one-step rings on the shaded half only
for si = 14, #samples - 24, 6 do
  local s = samples[si]
  for _, p in ipairs(info) do
    local x, y = p[1], p[2]
    local d = math.abs((x + .5 - s[1]) * (s[1] - samples[si - 2][1]) + (y + .5 - s[2]) * (s[2] - samples[si - 2][2]))
    local k = Q.X.K(x, y)
    if d < 0.45 and (idx[k] or 9) <= 3 and idx[k] >= 2 and (x - s[1]) ^ 2 + (y - s[2]) ^ 2 < 40 then
      local cur = c:get(x, y)
      if cur == BODY6[idx[k]] then c:put(x, y, BODY6[idx[k] - 1], bTok) end
    end
  end
end
-- olive mottling on the lit top, avoiding the stripe
for _, p in ipairs(info) do
  local x, y, t = p[1], p[2], p[6]
  local k = Q.X.K(x, y)
  if t > 0.1 and t < 0.75 and idx[k] >= 4 and Q.hash(math.floor(x / 2), math.floor(y / 2), 4) < 0.07 and Q.hash(x, y, 2) < 0.7 then
    local cur = c:get(x, y)
    if cur == BODY6[idx[k]] then c:put(x, y, idx[k] >= 5 and BODY6[3] or SPOT, bTok) end
  end
end
-- dew beads along the stripe: a pale bead with a shaded lower-right pixel
for si = 16, 160, 9 do
  local s = samples[si]
  local a, b = samples[si - 2], samples[si + 2]
  local dx, dy = b[1] - a[1], b[2] - a[2]
  local l = math.sqrt(dx * dx + dy * dy)
  local nx, ny = dy / l, -dx / l
  if ny > 0 then nx, ny = -nx, -ny end
  local r = rad(s[3])
  local x, y = math.floor(s[1] + nx * r * 0.25), math.floor(s[2] + ny * r * 0.25)
  if body:has(x + 1, y + 1) then c:put(x, y, STRIPE6[6], bTok) c:put(x + 1, y, STRIPE6[4], bTok) c:put(x + 1, y + 1, BODY6[2], bTok) end
end
-- wet specular: broken streak along the upper-left of the arch
for si = 22, 120, 1 do
  local s = samples[si]
  local r = rad(s[3])
  local x, y = math.floor(s[1] - 0.45 * r), math.floor(s[2] - 0.62 * r)
  if body:has(x, y) and (si // 6) % 3 ~= 2 then c:put(x, y, si % 2 == 0 and SPEC or BODY6[6], bTok) end
end
-- bounce line from the bog water under the belly side of the arch
Q.side(body, 0, 1):each(function(x, y) if x > 14 and x < 46 then c:put(x, y, BOUNCE, bTok) end end)

-- front sucker: a small cup with a pale tooth ring
local fs = c:ellipse(51.5, 17, 3.5, 1.5)
local fTok = { r = { name = "front" } }
Q.body(c, fs, SUCK6, { R = 1.5, amb = 0.25, tok = fTok })
c:put(51, 18, SUCK6[1]) c:put(52, 18, SUCK6[1])
c:put(50, 18, "#e8f4e0") c:put(53, 18, "#e8f4e0")
-- inner line between body and the suckers
Q.side(fs, 0, -1):each(function(x, y) if body:has(x, y - 1) then c:put(x, y, SUCK6[2], fTok) end end)
-- eye on the narrow head
local ex, ey = bez(0.88)
c:eyeSmall(math.floor(ex) - 1, math.floor(ey) - 2)

-- quirk: a glass dew drop hanging from the front sucker; it reflects the leech's eye
c:paint({ ".n..", ".hb.", "hcbs", "bbbs", ".ss." }, 55, 17, {
  n = SUCK6[3], d = STRIPE6[3], h = SPEC, b = "#a8e0ee", c = "#d8f4f6", s = "#5a9cc4" })
c:put(57, 19, BODY6[2]) -- the reflected eye
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
