-- dried-apricots (final, Opus single pass). A loose little heap of three flattened, puckered apricot halves: one
-- lying back, two leaning in front, plus the stone that came out of one of them. Material: per-pixel oval light
-- (6-tone amber-orange, cool plum shade), wrinkle bumps that follow each half's pucker, a dark crease where the stone
-- was, sticky glossy specular + sugar glint, cool reflected light lower-right, contact shadows where halves overlap.
-- quirk: the leftover apricot stone, ridged like a tiny walnut, has rolled off to the side.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new("dried-apricots")

local AP = { "#5e2236", "#9a3a2c", "#cf5e26", "#ee8a2a", "#ffb446", "#ffdc86" }
local BOUNCE = "#b8566a"
local ST = { "#3a2026", "#5e3428", "#86502e", "#b07440", "#d49a5e", "#f0c48a" }

-- halves: centre, radii, angle, pucker centre offset (unit), seed
local H = {
  { x = 27, y = 25, rx = 10.5, ry = 7.5, a = -0.35, px = 0.15, py = 0.1, s = 1 },
  { x = 21, y = 37, rx = 10, ry = 7, a = 0.25, px = 0.2, py = -0.1, s = 2 },
  { x = 39, y = 35, rx = 10, ry = 7.2, a = -0.6, px = -0.1, py = 0.05, s = 3 },
}
local masks = {}
local tokens = {}
for i, h in ipairs(H) do
  local m = HP.mask()
  local ca, sa = cos(h.a), sin(h.a)
  for y = floor(h.y - 13), floor(h.y + 13) do for x = floor(h.x - 13), floor(h.x + 13) do
    local dx, dy = x - h.x, y - h.y
    local u, v = (dx * ca + dy * sa), (-dx * sa + dy * ca)
    local ang = atan(v, u)
    local rr = 1 + 0.05 * sin(ang * 5 + h.s * 2) + 0.03 * sin(ang * 9 + h.s)
    if (u / (h.rx * rr + .4)) ^ 2 + (v / (h.ry * rr + .4)) ^ 2 <= 1 then m:set(x, y) end
  end end
  masks[i] = m
  tokens[i] = { r = { name = "apricot" .. i } }
end
-- later halves sit in front: cut nothing, just paint in order with contact shadow from the ones in front
for i, h in ipairs(H) do
  local m = masks[i]
  local tok = tokens[i]
  local _, nO = A.oval(h.x, h.y, h.rx, h.ry, h.a, 1.6)
  local n = {}
  local np = X.pillow(m, 3.5)
  for k, a in pairs(np) do local b = nO[k] or a
    n[k] = { A.norm(a[1] * 0.5 + b[1] * 0.5, a[2] * 0.5 + b[2] * 0.5, a[3] * 0.5 + b[3] * 0.5) } end
  -- pucker: wrinkles radiating from the pit dimple
  local ca, sa = cos(h.a), sin(h.a)
  local pcx, pcy = h.x + (h.px * h.rx) * ca - (h.py * h.ry) * sa, h.y + (h.px * h.rx) * sa + (h.py * h.ry) * ca
  A.bump(n, function(x, y)
    local dx, dy = x - pcx, y - pcy
    local d = sqrt(dx * dx + dy * dy) + 0.01
    local a = atan(dy, dx)
    local w = sin(a * 7 + h.s * 1.3 + d * 0.25) * 0.35 * min(1, d / 3)
    local dent = d < 3.2 and 0.5 or 0
    return (-dy / d) * w - dx / d * dent, (dx / d) * w - dy / d * dent
  end)
  local bias = {}
  for j = i + 1, #H do A.cast(bias, m, masks[j], 1, 2, -1) X.ao(bias, m, masks[j], 1, -1) end
  local idx = A.shade(c, m, n, AP, { tok = tok, amb = 0.06, wrap = 0.24, bias = bias })
  -- pit crease: curved dark seam with lit lip above
  for t = -1, 1, 0.08 do
    local cx = pcx + t * 2.6 * ca - (0.6 * t * t) * sa
    local cy = pcy + t * 2.6 * sa + (0.6 * t * t) * ca
    local x, y = floor(cx + .5), floor(cy + .5)
    if m:has(x, y) and not (masks[i + 1] and masks[i + 1]:has(x, y)) and not (masks[i + 2] and masks[i + 2]:has(x, y)) then
      c:put(x, y, AP[max(1, min(2, (idx[K(x, y)] or 3) - 2))], tok)
      if m:has(x, y - 1) then c:put(x, y - 1, AP[min(6, (idx[K(x, y - 1)] or 3) + 1)], tok) end
    end
  end
  -- cool reflected light lower-right
  local rim = X.rim(n)
  m:edge():each(function(x, y) local k = K(x, y)
    if rim[k] and rim[k] > 0.55 then c:put(x, y, BOUNCE, tok) end end)
  -- sticky gloss: brightest spec + one neighbour
  local sx, sy = A.specAt(m, n, 50)
  if sx then c:put(sx, sy, "#fff6dc", tok) if m:has(sx + 1, sy) then c:put(sx + 1, sy, AP[6], tok) end end
end
-- 1px separation in the darker tone where a front half overlaps one behind
for i = 2, #H do
  masks[i]:edge():each(function(x, y)
    for j = i + 1, #H do if masks[j]:has(x, y) then return end end
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
      local qx, qy = x + d[1], y + d[2]
      if not masks[i]:has(qx, qy) then
        for j = 1, i - 1 do if masks[j]:has(qx, qy) then c:put(x, y, AP[2], tokens[i]) return end end
      end
    end
  end)
end
-- sugar glint sparkle on the back half
c:put(23, 22, "#fff4d6", tokens[1])

-- quirk: the stone, rolled off lower-right
local sx, sy = 51, 45
c:groundShadow(sx, sy + 3, 3, 1) -- contact shadow under the stone
local sm, sn = A.oval(sx, sy, 3.6, 2.6, -0.4, 1)
-- ridges
A.bump(sn, function(x, y) local d = (x - sx) * 0.4 + (y - sy) * 0.9 return sin(d * 2.4) * 0.5, 0 end)
local stok = { r = { name = "stone" } }
local sidx = A.shade(c, sm, sn, ST, { tok = stok, amb = 0.06, wrap = 0.24 })
-- seam along its keel
for x = sx - 3, sx + 3 do local y = floor(sy + (x - sx) * -0.42 + 0.5) if sm:has(x, y) then c:put(x, y, ST[2], stok) end end
c:put(sx - 2, sy - 2, ST[6], stok)
A.save(c, "dried-apricots")
