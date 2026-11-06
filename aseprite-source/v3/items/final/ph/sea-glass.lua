-- sea-glass (final, single pass by artist aD14_5). A little beach find: a big tumbled seafoam-green lozenge standing
-- upright in a dune of fine sand, a cobalt-blue pebble in front of it and a milky white sliver leaning behind.
-- Glass material: 6-tone ramps lit per pixel, dark thick rim, pale core, bright upper-left rim line, a darker inner
-- back-face edge, a diagonal refraction band, frosted speckle (hard pixels), one specular each, cool bounce light.
-- Sand: 6-tone dune with ripple line, grains and contact shadows under every piece.
-- quirk: a trapped air bubble ring (with two tiny followers) glints inside the green glass.
local NAME = "sea-glass"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD14_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local SAND = { "#7e5f46", "#a98258", "#cfa56c", "#e8c98c", "#f6e2ae", "#fff3d2" }
local GREEN = { "#1b5560", "#2a7f80", "#45a898", "#74ccb0", "#a9ead0", "#e0fbe6" }
local COBALT = { "#14245e", "#1f3d96", "#2f62c4", "#5a8fe0", "#92bcf2", "#d2e6fc" }
local MILK = { "#6e82a0", "#98aac2", "#c4d2e0", "#e2ebf0", "#f4f8f6", "#fffcf0" }

local function rounded(pts, r) return HP.poly(pts):shrink(r):grow(r) end
-- glass painter. m mask; ramp; o.R bevel; o.band: refraction band offset
local function glass(m, ramp, name, o)
  local tok = { r = { name = name } }
  local n, d = X.pillow(m, o.R or 5, 1)
  local v = X.light(n, { amb = 0.16, wrap = 0.35 })
  local bias = o.bias or {}
  m:each(function(x, y) local k = K(x, y)
    local dd = d[k] or 0
    -- thick rim reads darker, thin core reads pale (glass)
    if dd > o.core then bias[k] = (bias[k] or 0) + 1 end
    if dd < 1.2 then bias[k] = (bias[k] or 0) - 1 end
    local h = G.hash(x, y, o.seed)
    if dd > 1.5 then
      if h > 0.9 then bias[k] = (bias[k] or 0) + 1 elseif h < 0.07 then bias[k] = (bias[k] or 0) - 1 end
    end
    -- refraction band: diagonal pale stripe across the lower-right body
    local bd = (x - m.bx0) * 0.7 + (y - m.by0) * 0.7 - o.band
    if abs(bd) < 1.3 and dd > 2.5 then bias[k] = (bias[k] or 0) + 1 end
  end)
  X.tone(c, m, v, ramp, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias = bias, tok = tok })
  -- bright rim upper-left; inner back-face edge (dark line 2px inside lower-right)
  m:edge():each(function(x, y)
    if not m:has(x - 1, y) or not m:has(x, y - 1) then c:put(x, y, ramp[5], tok) end
  end)
  local inner = m:shrink(2):edge()
  inner:each(function(x, y)
    if not m:shrink(2):has(x + 1, y) or not m:shrink(2):has(x, y + 1) then c:put(x, y, ramp[2], tok) end
  end)
  return tok, n
end
local function bounds(m) m.bx0, m.by0 = m:bbox() end

-- sand dune
local dune = c:ellipse(32, 52, 24, 6.5)
local dn = X.pillow(dune, 5, 1.4)
local sandtok = { r = { name = "sand" } }
local sbias = {}
-- contact shadows go in after the pieces are masks
-- pieces
local milk = rounded({ { 40, 10 }, { 51, 14 }, { 56, 34 }, { 52, 46 }, { 42, 44 }, { 38, 26 } }, 2)
local green = rounded({ { 14, 26 }, { 22, 12 }, { 36, 8 }, { 46, 22 }, { 46, 40 }, { 36, 52 }, { 20, 50 }, { 11, 40 } }, 3)
local cobalt = rounded({ { 36, 42 }, { 44, 36 }, { 55, 40 }, { 56, 50 }, { 47, 55 }, { 38, 52 } }, 2)
bounds(milk) bounds(green) bounds(cobalt)
for _, p in ipairs{ milk, green, cobalt } do
  -- ground-contact shadow (lower-right) onto the dune
  p:shift(2, 1):each(function(x, y) if dune:has(x, y) and not p:has(x, y) then local k = K(x, y) sbias[k] = (sbias[k] or 0) - 2 end end)
end
X.tone(c, dune, X.light(dn, { amb = 0.2, wrap = 0.4 }), SAND, { cuts = { 0.22, 0.4, 0.58, 0.74, 0.88 }, bias = sbias, tok = sandtok })
dune:each(function(x, y) local k = K(x, y)
  local h = G.hash(x, y, 31)
  if not sbias[k] then
    if h > 0.93 then c:put(x, y, SAND[6], sandtok) elseif h < 0.06 then c:put(x, y, SAND[2], sandtok) end
  end
  -- wind ripple along the foot
  if y == 56 and (x % 7 < 4) and x > 14 and x < 50 then c:put(x, y, SAND[3], sandtok) end
end)
c:put(14, 52, SAND[1], sandtok) c:put(15, 53, SAND[2], sandtok)

-- milk sliver (behind)
local gm = HP.mask() gm:add(green)
local milkv = milk:copy():cut(green)
glass(milk, MILK, "milk", { R = 3.5, core = 3, band = 56, seed = 21, bias = {} })
-- repaint the hidden part: the green will overwrite anyway
-- green hero
local gtok = glass(green, GREEN, "green", { R = 7, core = 4, band = 58, seed = 22, bias = (function()
  local b = {}
  -- AO: milk's contact shadow falls on its own side
  return b
end)() })
-- cobalt in front
local cm = cobalt:copy()
local ctok = glass(cobalt, COBALT, "cobalt", { R = 5, core = 3, band = 70, seed = 23, bias = {} })
-- contact shadow of the cobalt on the green, and green on milk (dark row where parts meet)
cobalt:shift(-1, -1):each(function(x, y) if green:has(x, y) and not cobalt:has(x, y) then c:put(x, y, GREEN[1], gtok) end end)
green:shift(1, 0):each(function(x, y) if milk:has(x, y) and not green:has(x, y) then c:put(x, y, MILK[1], { r = { name = "milk" } }) end end)

-- speculars + sparkle
local function spec(x, y, hex, t) c:put(x, y, hex, t) c:put(x + 1, y, hex, t) end
spec(21, 20, "#f4fff6", gtok) c:put(21, 22, "#f4fff6", gtok)
spec(41, 40, "#eaf4ff", ctok)
c:put(45, 20, MILK[6], { r = { name = "milk" } })
-- cool bounce on the green's lower-right edge
green:edge():each(function(x, y) if not green:has(x + 1, y) and not green:has(x, y + 1) and not cobalt:has(x, y) and y > 36 then c:put(x, y, "#2f9fb0", gtok) end end)
-- quirk: trapped air bubble ring and two followers
do
  local bx, by = 29, 31
  c:fillMask(c:ellipse(bx, by, 2.9, 2.9), GREEN[2])
  c:fillMask(c:ellipse(bx, by, 2.1, 2.1):cut(c:ellipse(bx, by, 0.7, 0.7)), "#e6fff0")
  c:put(bx, by, GREEN[3], gtok)
  c:put(bx - 1, by - 1, "#ffffff" == nil and "" or "#f8fffa")
  c:put(bx + 4, by + 5, "#d4fbe6", gtok) c:put(bx + 6, by + 8, "#bfeedb", gtok)
end
-- a frosted scratch line and sand-pitted dots on the green
for _, p in ipairs{ { 33, 22 }, { 34, 23 }, { 35, 23 } } do c:put(p[1], p[2], GREEN[5], gtok) end
G.save2(c, NAME)
