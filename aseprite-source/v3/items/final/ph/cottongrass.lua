-- cottongrass (ph, Opus single pass): bog cotton. Three slim olive stems rise from a tuft of thin grass blades
-- (rust-tipped) set in a small clod of wet peat with moss specks. Each stem ends in a dark scaly bract and a round,
-- silky cotton head: radial fibre texture, cool lavender shade, warm cream light, a frayed strand edge.
-- quirk: the tallest head has been wind-combed - its fibres stream off to the right in a long silky tail.
local NAME = "cottongrass"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB22_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = G.new(NAME)
local COT = { "#5c567a", "#8a84a6", "#b6b2cc", "#dcd8e8", "#f3efe6", "#fff8e6" }
local STEM = { "#28402c", "#3c5a32", "#587a3a", "#7c9a48", "#a6bc62", "#cedc8a" }
local GR = { "#203c2e", "#2c5a38", "#42803e", "#64a048", "#90c05c", "#c0dc82" }
local RUST = { "#7a3428", "#b0522e", "#d8783e" }
local PEAT = { "#22151a", "#3a2420", "#56352a", "#744a34", "#946446", "#b88462" }
local BRACT = { "#2e2224", "#4e3a32", "#7a5c44" }

c:groundShadow(32, 57, 11, 1.5)

-- peat clod
local clod = c:ellipse(32, 54, 8.5, 3.5):add(c:ellipse(28, 55, 5, 2.5)):add(c:ellipse(36.5, 55, 4.5, 2.5))
G.toneN(c, clod, X.pillow(clod, 3), PEAT, { cuts = { 0.16, 0.3, 0.46, 0.64, 0.84 }, amb = 0.08 })
clod:each(function(x, y) local h = X.hash(x, y, 4)
  if h < 0.07 then c:put(x, y, PEAT[2]) elseif h > 0.94 and y < 55 then c:put(x, y, GR[5]) end end)

-- grass blades (behind stems): tapered curved tubes
local blades = {
  { { 30, 52 }, { 27, 47 }, { 22, 44 }, { 17, 45 }, rust = true },
  { { 31, 52 }, { 29, 45 }, { 26, 39 }, { 24, 35 } },
  { { 33, 52 }, { 34, 46 }, { 37, 40 }, { 40, 37 }, rust = true },
  { { 34, 52 }, { 38, 48 }, { 43, 45 }, { 48, 46 } },
  { { 32, 52 }, { 32, 46 }, { 31, 41 }, { 29, 37 } },
  { { 29, 52 }, { 24, 50 }, { 19, 50 }, { 15, 52 } },
  { { 35, 52 }, { 40, 51 }, { 45, 51 }, { 49, 53 }, rust = true },
}
local grass = HP.mask()
for i, b in ipairs(blades) do
  local m, n, T, S = G.tube(b, function(t) return 1.15 * (1 - t) ^ 0.7 + 0.2 end, 80)
  m:cut(clod)
  local tok = { r = { name = "blade" .. i } }
  local idx = X.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.35 }), GR, { cuts = { 0.15, 0.3, 0.46, 0.64, 0.84 }, bias = (i % 2 == 0) and nil or {}, tok = tok })
  m:each(function(x, y) local k = K(x, y)
    if b.rust and T[k] > 0.78 then c:put(x, y, RUST[T[k] > 0.9 and 3 or 2], tok) end
    if grass:has(x, y) then c:put(x, y, GR[2], tok) end
  end)
  grass:add(m)
end
-- ambient: blades darken where they enter the clod
clod:edge():each(function(x, y) if y <= 52 and grass:has(x, y - 1) then c:put(x, y, PEAT[2]) end end)

-- stems
local heads = {
  { x = 19, y = 26, r = 5.0, stem = { { 30, 52 }, { 28, 44 }, { 21, 38 }, { 19, 32 } } },
  { x = 32, y = 18, r = 5.6, stem = { { 32, 52 }, { 33, 42 }, { 31, 32 }, { 32, 25 } }, tail = true },
  { x = 45, y = 28, r = 4.8, stem = { { 34, 52 }, { 38, 44 }, { 44, 39 }, { 45, 34 } } },
}
local stems = HP.mask()
for i, h in ipairs(heads) do
  local m, n = G.tube(h.stem, function(t) return 0.85 end, 100)
  m:cut(clod)
  X.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.3 }), STEM, { cuts = { 0.15, 0.3, 0.46, 0.64, 0.84 }, tok = { r = { name = "stem" .. i } } })
  stems:add(m)
  -- a node ring part way up
  local nx, ny = G.bez(h.stem, 0.45)
  m:each(function(x, y) if abs(y - floor(ny)) < 0.5 then c:put(x, y, STEM[2]) end end)
end

-- heads: fibrous cotton balls
for i, h in ipairs(heads) do
  local tok = { r = { name = "head" .. i } }
  -- bract under the head
  local bt = HP.mask()
  for dy = 0, 3 do for dx = -1, 0 do bt:set(floor(h.x) + dx + (dy > 1 and 0 or 0), floor(h.y + h.r) + dy - 1) end end
  bt:set(floor(h.x) + 1, floor(h.y + h.r))
  bt:each(function(x, y) c:put(x, y, (x + y) % 2 == 0 and BRACT[2] or BRACT[1], tok) end)
  c:put(floor(h.x) - 1, floor(h.y + h.r) - 1, BRACT[3], tok)
  -- body + frayed strands
  local m = c:ellipse(h.x, h.y, h.r, h.r * 0.95)
  local N = 28
  for a = 0, N - 1 do
    local ang = a / N * 2 * pi + 0.1
    local ext = floor(X.hash(a, i, 7) * 2.6)
    if h.tail and cos(ang) > 0.3 then ext = ext + floor(4 + 6 * cos(ang) ^ 3 + X.hash(a, 3, 3) * 3) end
    for r = h.r, h.r + ext do
      local sx, sy = h.x + cos(ang) * r, h.y + sin(ang) * r
      if h.tail and cos(ang) > 0.3 then sy = sy + (r - h.r) * 0.15 - (r - h.r) ^ 1.2 * 0.08 end
      m:set(floor(sx + .5), floor(sy + .5))
    end
  end
  m:cut(bt)
  local n = {}
  m:each(function(x, y)
    local dx, dy = (x - h.x) / (h.r + 0.6), (y - h.y) / (h.r + 0.6)
    local q = dx*dx + dy*dy
    n[K(x, y)] = { G.norm(dx, dy, sqrt(max(1 - min(q, 1), 0.05)) + (q > 1 and 0.15 or 0)) }
  end)
  local bias = {}
  X.ao(bias, m, bt, 1, -1)
  local idx = X.tone(c, m, X.light(n, { amb = 0.18, wrap = 0.35 }), COT, { cuts = { 0.12, 0.26, 0.42, 0.6, 0.82 }, bias = bias, tok = tok })
  -- radial silk texture: every few degrees a strand one tone darker, and a lit strand beside it
  m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - h.x, y - h.y
    local d = sqrt(dx*dx + dy*dy)
    if d < 1.5 then return end
    local a = (atan(dy, dx) / (2 * pi) * 22) % 1
    if a < 0.18 and idx[k] then c:put(x, y, COT[max(1, idx[k] - 1)], tok)
    elseif a > 0.5 and a < 0.62 and idx[k] and d < h.r - 1 then c:put(x, y, COT[min(6, idx[k] + 1)], tok) end
    -- tail fibres: thin, cooler
    if h.tail and d > h.r + 0.5 and dx > 0 then c:put(x, y, (y % 2 == 0) and COT[5] or COT[4], tok) end
  end)
  -- soft glint upper-left
  c:put(floor(h.x - h.r * 0.4), floor(h.y - h.r * 0.45), COT[6], tok)
  c:put(floor(h.x - h.r * 0.4) + 1, floor(h.y - h.r * 0.45), COT[6], tok)
end

G.saveTo(c, "ph", NAME)
