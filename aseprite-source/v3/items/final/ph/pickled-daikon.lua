-- pickled-daikon (C34, Opus single pass). Takuan: a whole slim sun-dried daikon pickled bright yellow, lying on the
-- diagonal (crown upper-right with a dried leaf stub, fine tip lower-left), plus three cut coins in front.
-- Material: per-pixel cylinder light on a 6-tone yellow, crosswise drying wrinkles (dark groove + lit lip), rice-bran
-- (nuka) flecks, waxy streak on the shoulder, cool reflected light on the underside; coins show rind ring, translucent
-- flesh with a faint core ring and a 2px cut side, AO where they overlap.
-- quirk: somebody has already taken a bite out of the front coin.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = A.new("pickled-daikon")

local YEL = { "#6e3a24", "#b06a1a", "#dc9a1e", "#f2c232", "#fade66", "#fff4b0" }
local FLESH = { "#a07a2a", "#d8b448", "#f0d878", "#fbeaa4", "#fff4cc", "#fffbe8" }
local STUB = { "#3a3a22", "#62602e", "#8c8a40", "#b4b060" }
local BOUNCE, SPEC = "#c48a5c", A.SPEC

-- leaf stub at the crown (behind the root)
A.ln(c, 46, 13, 49, 8, STUB[3]) A.ln(c, 47, 13, 50, 9, STUB[2])
A.ln(c, 45, 12, 45, 7, STUB[4]) A.ln(c, 46, 12, 46, 8, STUB[2])
A.ln(c, 47, 14, 52, 12, STUB[3]) c:put(52, 11, STUB[4]) c:put(49, 7, STUB[4]) c:put(45, 6, STUB[3])

-- root
local p = { { 46, 14 }, { 39, 22 }, { 28, 33 }, { 13, 50 } }
local function hw(t)
  if t < .05 then return 4.2 + t / .05 * 1.2 end
  return 5.4 * ((1 - t) / .95) ^ .85 + .45
end
local rm, rn, RT, RS, samp = A.tube(p, hw, 160)
local bias = {}
rm:each(function(x, y) if RT[K(x, y)] < .025 then bias[K(x, y)] = -1 end end)
local tok = { r = { name = "root" } }
local idx = A.tone(c, rm, rn, YEL, { amb = .08, wrap = .25, tok = tok, bias = bias, cuts = { .18, .34, .5, .66, .82 } })
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end
-- drying wrinkles: irregular, partial grooves that bow with the cylinder
local wr = { { .12, -.7, .5 }, { .19, -.2, .9 }, { .27, -.8, .3 }, { .33, -.4, .9 }, { .41, -.9, .2 }, { .47, -.1, .9 },
  { .55, -.7, .6 }, { .63, -.5, .9 }, { .71, -.8, .4 }, { .8, -.3, .8 } }
rm:each(function(x, y) local k = K(x, y)
  local t, s = RT[k], RS[k]
  for _, r in ipairs(wr) do
    local d = (t - r[1]) * LEN + s * s * 1.3 - s * .4
    if s > r[2] and s < r[3] then
      local cur = idx[k] or 3
      if d > -.5 and d < .5 then c:put(x, y, YEL[max(1, cur - 2)], tok)
      elseif d >= -1.5 and d <= -.5 and cur >= 3 then c:put(x, y, YEL[min(6, cur + 1)], tok) end
    end
  end
end)
-- nuka bran flecks
rm:each(function(x, y) local h = X.hash(x, y, 5) local k = K(x, y)
  if h > .955 and abs(RS[k]) < .8 then c:put(x, y, h > .985 and "#7a4a2a" or "#c08a4a", tok) end end)
-- cool reflected light on the underside edge
local rim = X.rim(rn)
rm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > .6 and RS[k] > .8 and RT[k] > .08 and RT[k] < .85 then c:put(x, y, BOUNCE, tok) end end)
-- waxy streak on the lit shoulder + glint
for _, q in ipairs{ { .1, -.5 }, { .14, -.52 }, { .18, -.5 }, { .23, -.48 } } do
  local s = samp[floor(q[1] * 160) + 1]
  c:put(floor(s.x + s.px * s.w * q[2] + .5), floor(s.y + s.py * s.w * q[2] + .5), YEL[6], tok)
end
do local s = samp[floor(.15 * 160) + 1]
  c:put(floor(s.x + s.px * s.w * -.55 + .5), floor(s.y + s.py * s.w * -.55 + .5), SPEC, tok) end
-- crown: dark sunken ring + stub base
c:put(46, 12, STUB[1]) c:put(47, 13, STUB[2]) c:put(45, 13, YEL[2])

-- coins (sliced rounds): face ellipse + 2px cut side below
local occ = rm:copy()
local function coin(cx, cy, rx, ry, bite)
  local face = c:ellipse(cx, cy, rx, ry)
  local side = face:shift(0, 1):add(face:shift(0, 2)):cut(face)
  if bite then local b = c:ellipse(bite[1], bite[2], bite[3], bite[3]) face:cut(b) side:cut(b) end
  local all = face:copy():add(side)
  side:each(function(x, y) c:put(x, y, (x < cx - rx * .4) and YEL[3] or (x > cx + rx * .4 and YEL[1] or YEL[2]), tok) end)
  face:each(function(x, y)
    local dx, dy = (x + .5 - cx - .5) / rx, (y + .5 - cy - .5) / ry
    local d = sqrt(dx*dx + dy*dy)
    local lit = (dx + dy) < -.15
    local col
    if d > .8 then col = lit and YEL[4] or YEL[3]
    elseif d > .62 then col = lit and FLESH[6] or FLESH[5]
    elseif d > .38 and d < .52 then col = FLESH[3]
    else col = lit and FLESH[5] or FLESH[4] end
    c:put(x, y, col, tok)
  end)
  c:put(floor(cx), floor(cy), FLESH[4], tok)
  -- translucent sheen: a 2x1 pale mark upper-left of the flesh
  c:put(floor(cx - rx * .45), floor(cy - ry * .35), FLESH[6], tok) c:put(floor(cx - rx * .45) + 1, floor(cy - ry * .35), FLESH[6], tok)
  if bite then
    -- tooth scallops: the bitten edge is fresh, pale flesh with dark notches
    local b = c:ellipse(bite[1], bite[2], bite[3] + 1, bite[3] + 1)
    local e = 0
    face:each(function(x, y) if b:has(x, y) then e = e + 1 c:put(x, y, ((x + y) % 3 == 0) and FLESH[2] or FLESH[6], tok) end end)
    side:each(function(x, y) if b:has(x, y) then c:put(x, y, FLESH[3], tok) end end)
  end
  -- separation from what is behind, and contact shadow
  all:edge():each(function(x, y)
    if occ:has(x, y - 1) or occ:has(x - 1, y) or occ:has(x + 1, y) or occ:has(x, y + 1) then
      if not occ:has(x, y) then local h = c:get(x, y) if h then c:put(x, y, A.mix(h, "#5a2a1c", .4), tok) end end end end)
  local sh = all:shift(1, 1):add(all:shift(0, 1)):cut(all)
  sh:each(function(x, y) if occ:has(x, y) then local h = c:get(x, y) if h then c:put(x, y, A.mix(h, "#4a2018", .35), tok) end end end)
  occ:add(all)
end
coin(43.5, 38.5, 5.6, 3.6)
coin(49.5, 45.5, 5.4, 3.5)
coin(39.5, 48.5, 5.8, 3.7, { 46.2, 47.2, 2.4 })

A.fin(c, "pickled-daikon")
