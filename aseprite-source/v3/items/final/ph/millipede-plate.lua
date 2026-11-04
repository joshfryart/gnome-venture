-- millipede-plate (final, Opus single pass). A shed millipede armour plate: a slim arch of nine overlapping
-- chitin rings (glossy plum-brown, each ring barrel-lit with a bright leading lip, a deep groove and AO where it
-- tucks under the next), bright orange keel edges along the outer rim, a cool reflected light on the inner curve,
-- a white specular streak over the crown, pale hollow ends where it stands, 2-tone ground shadow.
-- quirk: one tiny jointed orange leg is still hanging on, near the right foot.
local NAME = "millipede-plate"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC23_3.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, abs, sin, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local CH = { "#1e1222", "#38192a", "#5a2630", "#803a36", "#aa5a40", "#d88a5a" }
local KEEL = { "#7a2a1e", "#b8461e", "#e6702a", "#ffa24a", "#ffd486" }
local COOL = "#5a5a8a"
local HOLE = { "#3a1a24", "#5a3036", "#d8a87a" }

c:groundShadow(32, 53, 22, 1.5)

local NSEG = 9
local am, an, AT, AS, AAL, ATG, alen, AD = A.tube({ { 12, 52 }, { 10, 6 }, { 54, 6 }, { 52, 52 } }, function(t)
  return 3.9 - 0.5 * abs(t - 0.5)
end)
local seg = alen / NSEG
local tok = { r = { name = "plate" } }
local n2, bias, F = {}, {}, {}
am:each(function(x, y) local k = K(x, y)
  local a = AAL[k]
  local i = floor(a / seg)
  local f = a / seg - i
  F[k] = f
  local g, nn = ATG[k], an[k]
  local bump = (f - 0.42) * 1.1                              -- each ring bulges like a barrel
  n2[k] = { G.norm(nn[1] + g.tx * bump, nn[2] + g.ty * bump, nn[3]) }
  if f > 0.86 then bias[k] = -1 end                          -- tucked under the next ring
end)
local idx = G.toneN(c, am, n2, CH, { tok = tok, bias = bias, cuts = { 0.12, 0.26, 0.42, 0.6, 0.78 }, amb = 0.08, wrap = 0.3 })
-- outer side = away from the arch centre
local function outward(x, y, k)
  local g = ATG[k]
  local cx, cy = 32, 44
  local ox, oy = g.x - cx, g.y - cy
  return AD[k] * ((g.px * ox + g.py * oy) > 0 and 1 or -1)
end
local rimL = X.rim(n2)
local spec = X.spec(n2, 24)
am:each(function(x, y) local k = K(x, y)
  local f, o, w = F[k], outward(x, y, k), ATG[k].w
  local a = AAL[k]
  if a < 0.6 or a > alen - 0.6 then return end
  -- groove between rings (1 px, deep), lit lip right after it
  if f < 1 / seg * 1.0 and a > 1 then c:put(x, y, CH[1], tok) return end
  if f < 2 / seg and a > 1 then c:put(x, y, CH[min(6, (idx[k] or 3) + 1)], tok) end
  -- orange keels on the outer rim
  if o > w - 1.6 then
    local ki = 3 + ((idx[k] or 3) >= 4 and 1 or 0) - ((f > 0.8) and 1 or 0)
    if f < 2 / seg then ki = ki + 1 end
    c:put(x, y, KEEL[max(1, min(5, ki))], tok)
    return
  end
  if o < -(w - 1.3) and (rimL[k] or 0) > 0.35 and f < 0.8 then c:put(x, y, COOL, tok) return end
  if (spec[k] or 0) > 0.55 and f > 0.15 and f < 0.75 then c:put(x, y, A.CREAM, tok) end
end)
-- hollow ends where the arch stands: dark inside with a pale cut rim, one row
for _, e in ipairs { { 0, 1 }, { 1, -1 } } do
  am:each(function(x, y) local k = K(x, y)
    local a = AAL[k]
    local near = e[1] == 0 and a < 1.2 or e[1] == 1 and a > alen - 1.2
    if near then
      local o = outward(x, y, k)
      local w = ATG[k].w
      if abs(o) > w - 1.2 then c:put(x, y, HOLE[3], tok) else c:put(x, y, HOLE[1], tok) end
    end
  end)
end

-- quirk: one tiny jointed leg on the inner side of the right foot
local ltok = { r = { name = "leg" } }
for _, p in ipairs { { 45, 41, 3 }, { 44, 42, 4 }, { 43, 43, 3 }, { 43, 44, 2 }, { 44, 45, 3 }, { 44, 46, 2 } } do
  if not am:has(p[1], p[2]) then c:put(p[1], p[2], KEEL[p[3]], ltok) end
end

G.save2(c, NAME)
