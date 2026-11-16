-- mini-bog-leech (61x31 still, side view, faces right). Opus third pass (richness).
-- Same creature as opus2: moss-green leech loop, arched tapered body, big rear sucker disc on the ground,
-- small front sucker, orange medicinal-leech side stripe, eye on the narrow head, sprout on the back.
-- Richness: the body is lit as a round wet tube (per-pixel normals from the spine, 6-tone hue-shifted moss
-- ramp), a broken wet specular streak along the top, dark olive mottling, the stripe shaded with the body,
-- quiet annulation rings (only one tone step, only on the shaded half: the opus2 rings were busy), a paler
-- belly and a cool bog-water bounce line on the underside. Rear sucker has radial ridges, front sucker a
-- pale tooth ring. Quirk (look closer): the sprout now has a split seed husk and a leaf vein; it is moved down
-- so its outline no longer touches the top edge.
local NAME = "mini-bog-leech"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local Q = dofile(DIR .. "/_rich.lua").init(HP)
local P = HP.P
local out = app.params.out or (DIR .. "/")
local W, H = 61, 31
local BODY6 = { "#1f3f3c", "#2d5a48", "#3f8350", "#5fa452", "#8cc866", "#c4e48a" }
local BELLY6 = { "#4a5e48", "#6a8460", "#8aa66c", "#a8c07c", "#c4d692", "#dde8aa" }
local STRIPE6 = { "#6e3028", "#a64c2c", "#d0702e", "#f0943c", "#ffb45a", "#ffd890" }
local SUCK6 = { "#3a5246", "#567058", "#6a8a5c", "#98b874", "#bcd28a", "#dce8a8" }
local BOUNCE = "#5e9a8a"
local SPOT = "#2f4a2e"
local SPEC = "#f2f8d0"

local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
c:groundShadow(30, 27, 26, 2)
for y = 0, c.h - 1 do for x = 0, c.w - 1 do local i = y * c.w + x
  if c.pix[i] and not c.pix[i - 1] and not c.pix[i + 1] then c.pix[i], c.own[i] = nil, nil end end end

-- spine: cubic Bezier from the rear sucker (left) over the arch to the front sucker (right)
local P0, P1, P2, P3 = { 11, 21 }, { 17, 6 }, { 41, 5 }, { 51, 21 }
local function bez(t)
  local u = 1 - t
  return u^3 * P0[1] + 3 * u^2 * t * P1[1] + 3 * u * t^2 * P2[1] + t^3 * P3[1],
         u^3 * P0[2] + 3 * u^2 * t * P1[2] + 3 * u * t^2 * P2[2] + t^3 * P3[2]
end
local function rad(t) return 5.2 - 2.6 * t end
local body, samples = HP.mask(), {}
for i = 0, 200 do
  local t = i / 200
  local x, y = bez(t)
  samples[#samples + 1] = { x, y, t }
  body:add(HP.ellipse(x, y, rad(t), rad(t)))
end

-- rear sucker disc: a flat oval foot on the ground, radial ridges, dark rim underneath
local rear = c:ellipse(9, 24, 7, 2.5)
local rTok = { r = { name = "rear" } }
Q.body(c, rear, SUCK6, { R = 2, amb = 0.25, tok = rTok })
for _, x in ipairs{ 4, 7, 12, 15 } do if rear:has(x, 24) then c:put(x, 24, SUCK6[2], rTok) end end
c:fillMask(c:line({ { 4, 25 }, { 14, 25 } }, 1), SUCK6[1])
c:put(4, 23, SUCK6[6]) c:put(5, 23, SUCK6[6])

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
local function inner(x, y, ox, oy) local cx, cy = 30 - x, 26 - y return ox * cx + oy * cy > 0 end
local cuts = { .22, .38, .54, .70, .85 }
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
  if t > 0.06 and t < 0.8 and outerOff > 0.05 and outerOff < 0.32 then col = STRIPE6[math.min(6, i)] end
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
  if t > 0.1 and t < 0.75 and idx[k] >= 4 and Q.hash(math.floor(x / 2), math.floor(y / 2), 4) < 0.16 and Q.hash(x, y, 2) < 0.7 then
    local cur = c:get(x, y)
    if cur == BODY6[idx[k]] then c:put(x, y, idx[k] >= 5 and BODY6[3] or SPOT, bTok) end
  end
end
-- wet specular: broken streak along the upper-left of the arch
for si = 22, 120, 1 do
  local s = samples[si]
  local r = rad(s[3])
  local x, y = math.floor(s[1] - 0.45 * r), math.floor(s[2] - 0.62 * r)
  if body:has(x, y) and (si // 6) % 3 ~= 2 then c:put(x, y, si % 2 == 0 and SPEC or BODY6[6], bTok) end
end
-- bounce line from the bog water under the belly side of the arch
Q.side(body, 0, 1):each(function(x, y) if x > 14 and x < 47 then c:put(x, y, BOUNCE, bTok) end end)

-- front sucker: a small cup with a pale tooth ring
local fs = c:ellipse(52.5, 24, 3.5, 2)
local fTok = { r = { name = "front" } }
Q.body(c, fs, SUCK6, { R = 1.5, amb = 0.25, tok = fTok })
c:fillMask(c:line({ { 51, 25 }, { 54, 25 } }, 1), SUCK6[1])
c:put(52, 24, SUCK6[1]) c:put(53, 24, SUCK6[2])
c:put(51, 24, "#f2ecc8") c:put(54, 24, "#f2ecc8")
-- inner line between body and the suckers
Q.side(fs, 0, -1):each(function(x, y) if body:has(x, y - 1) then c:put(x, y, SUCK6[2], fTok) end end)
-- eye on the narrow head
local ex, ey = bez(0.88)
c:eyeSmall(math.floor(ex) - 1, math.floor(ey) - 2)

-- quirk: a sprout riding on the loop, growing from a split seed husk
c:put(27, 5, "#8a5a34") c:put(28, 5, "#c08a52") -- husk, sitting on the skin
c:fillMask(c:line({ { 27, 4 }, { 27, 3 } }, 1), P.moss.shade)
c:paint({ "hll.Lhh", "dlld.LLd" }, 24, 2, { h = "moss.hi", l = "moss.base", L = "moss.base", d = "moss.shade" })
c:put(25, 2, P.moss.hi) c:put(30, 3, P.moss.deep)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
