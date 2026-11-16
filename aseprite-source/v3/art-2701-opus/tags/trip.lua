-- trip (Opus). Tag "trip" (Trip: it loses its next move). A gnome's teal leather boot caught mid-stride: the curled
-- toe has gone under a gnarled tree root that arches out of a clod of earth, so the boot pitches forward with its
-- heel kicked up; two wobble arcs behind the heel show the stumble. Material: lit leather with a turned-down cuff,
-- gold buckle, dark sole and stitched welt; bark ridges on the root, crumbly soil with grass tufts.
-- quirk: a tiny orange mushroom grows on top of the root arch, watching.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_o.lua")
local HP, X, K = O.HP, O.X, O.K
local floor, max, min, abs, sqrt, sin, cos = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos
local c = O.new("trip")

local LEA  = { "#173a4e", "#1f5868", "#2a7a82", "#3c9e9a", "#6cc8b8", "#b0eedc" }
local CUFF = { "#3a2a52", "#5a459e", "#7a62c0", "#9a86de", "#c9b2f0" }
local SOLE = { "#2b1c26", "#4a2e2c", "#6e4436" }
local BARK = { "#3a221e", "#51302b", "#6e4234", "#864c33", "#a86c48", "#cf9a6a" }
local SOIL = { "#3a2622", "#56372c", "#74503a", "#94704e" }
local GRAS = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local MUSH = { "#8f3a1f", "#d9662a", "#f5933e", "#ffc27a" }

-- ground clod
do
  local tok = O.tok("soil")
  local m = O.oval(36, 52, 20, 4.5)
  local n = {}
  m:each(function(x, y) n[K(x, y)] = { (x - 32) / 40, -0.6, 0.8 } end)
  local b = {}
  m:each(function(x, y) if O.hash(x, y, 7) > 0.8 then b[K(x, y)] = -1 end if y >= 55 then b[K(x, y)] = (b[K(x, y)] or 0) - 1 end end)
  O.shade(c, m, n, SOIL, { tok = tok, bias = b, amb = 0.25, cuts = { 0.3, 0.55, 0.8 } })
  -- crumbs
  for _, p in ipairs{ { 19, 51 }, { 54, 50 }, { 26, 49 } } do c:put(p[1], p[2], SOIL[4], tok) end
end

-- boot (drawn in its own frame: bx forward, by down; origin = ankle at the sole line)
local BOX, BOY, BA = 23, 34, 0.6
local ca, sa = cos(BA), sin(BA)
local function toLocal(x, y)
  local dx, dy = x - BOX, y - BOY
  return dx * ca + dy * sa, -dx * sa + dy * ca
end
local function inBoot(bx, by)
  -- shaft (slightly flared at the top)
  if by >= -19 and by <= 0.5 then
    local hw = 5 + max(0, -by - 12) * 0.15
    if bx >= -hw - 0.5 and bx <= hw then return "shaft" end
  end
  -- instep: slope from the shaft front down to the foot
  if by > -4 and by <= 0.5 and bx > 5 and bx <= 5 + (by + 4) * 2.4 then return "foot" end
  -- foot + heel
  if by > 0.5 and by <= 7 then
    local front = 18 - max(0, by - 3.5) * 0.9
    if bx >= -6 and bx <= front then
      if by > 5.4 then return "sole" end
      return "foot"
    end
  end
  -- curled toe: a hook rising off the front of the foot
  local tx, ty = bx - 18, by - 1.5
  if tx >= -2 and tx <= 5 and ty >= -6 and ty <= 3.5 then
    local r = sqrt((tx - 0.3) ^ 2 + (ty + 0.4) ^ 2)
    if r <= 4 and not (tx < 1.0 and ty < -1.4) then return "toe" end
  end
  return nil
end
local boot, sole, cuff = HP.mask(), HP.mask(), HP.mask()
local BU, BV = {}, {}
for y = 10, 60 do for x = 0, 63 do
  local bx, by = toLocal(x, y)
  local p = inBoot(bx, by)
  if p then
    if p == "sole" then sole:set(x, y) else boot:set(x, y) end
    
    BU[K(x, y)], BV[K(x, y)] = bx, by
  end
end end
cuff = cuff:grow(1):clip(boot:copy():add(boot:grow(1)))
-- widen cuff 1px either side (turned-down flap)
local cuffWide = HP.mask()
for y = 0, 63 do for x = 0, 63 do local bx, by = toLocal(x, y)
  if by >= -21 and by <= -16 and bx >= -7.3 and bx <= 7 then cuffWide:set(x, y) end end end
boot:cut(cuffWide)

-- wobble arcs behind the heel (behind everything)
do
  local tok = O.tok("wobble")
  for i, a in ipairs{ { 12, 36, 5 }, { 9, 42, 4 } } do
    for t = -0.9, 0.9, 0.08 do
      local x, y = floor(a[1] + cos(t + 3.4) * a[3] + .5), floor(a[2] + sin(t + 3.4) * a[3] + .5)
      c:put(x, y, i == 1 and "#e4f6ff" or "#b9e2f5", tok)
    end
  end
end

do
  local tok = O.tok("boot")
  local n = X.pillow(boot, 3.5)
  local b = {}
  boot:each(function(x, y) local k = K(x, y)
    if BV[k] and BV[k] > -1 and BV[k] < 1 and BU[k] < 4 then b[k] = -1 end   -- ankle crease
  end)
  local idx = O.shade(c, boot, n, LEA, { tok = tok, bias = b, amb = 0.1, wrap = 0.3 })
  -- stitched welt line above the sole (gold dashes, the one stitch)
  local i = 0
  local pts = {}
  boot:each(function(x, y) if sole:has(x, y + 1) or sole:has(x + 1, y + 1) then pts[#pts + 1] = { x, y } end end)
  table.sort(pts, function(a, b2) return a[1] + a[2] * 0.01 < b2[1] + b2[2] * 0.01 end)
  for j, p in ipairs(pts) do if j % 3 ~= 0 then c:put(p[1], p[2], GOLD[3], tok) end end
  -- leather highlight on the toe curl
  local sp = X.spec(n, 20)
  boot:each(function(x, y) local k = K(x, y) if sp[k] > 0.85 and BU[k] and BU[k] > 6 then c:put(x, y, LEA[6], tok) end end)
end
do
  local tok = O.tok("sole")
  sole:each(function(x, y) c:put(x, y, (BU[K(x, y)] or 0) < 0 and SOLE[2] or SOLE[3], tok) end)
  -- heel block
  sole:each(function(x, y) local k = K(x, y) if BU[k] and BU[k] < -1.5 then c:put(x, y, SOLE[2], tok) end end)
end
do
  local tok = O.tok("cuff")
  local n = X.pillow(cuffWide, 2)
  local idx = O.shade(c, cuffWide, n, CUFF, { tok = tok, amb = 0.12, wrap = 0.3 })
  -- fold line under the flap
  cuffWide:each(function(x, y) local _, by = toLocal(x, y) if by > -16.6 then O.set(c, idx, CUFF, x, y, 1, tok) end end)
end
do
  -- ankle strap with a gold buckle
  local tok = O.tok("strap")
  for y = 0, 63 do for x = 0, 63 do local bx, by = toLocal(x, y)
    if by >= -7 and by <= -5 and bx >= -5.4 and bx <= 5.4 then c:put(x, y, by < -6 and CUFF[3] or CUFF[2], tok) end
  end end
  local cx, cy = floor(BOX + 1 * ca - (-6) * sa + .5), floor(BOY + 1 * sa + (-6) * ca + .5)
  O.map(c, { "ggg", "gdg", "ggg" }, cx - 1, cy - 1, { g = GOLD[3], d = GOLD[1] }, O.tok("buckle"))
  c:put(cx - 1, cy - 1, GOLD[4], O.tok("buckle"))
end

-- the root: arches over the toe (drawn in front of it)
local RP = { { 32, 54 }, { 31, 32 }, { 54, 31 }, { 53, 54 } }
local root, rn, RT, RS = O.tube(RP, function(t) return 3.2 - 0.9 * sin(t * math.pi) end)
do
  local tok = O.tok("root")
  local b = {}
  root:each(function(x, y) local k = K(x, y)
    -- bark ridges: dark streaks that run along the root
    local s = RS[k]
    if abs(s - 0.35) < 0.12 or abs(s + 0.3) < 0.1 then b[k] = -1 end
    if y >= 51 then b[k] = (b[k] or 0) - 2 end          -- buried ends darken into the soil
  end)
  local idx = O.shade(c, root, rn, BARK, { tok = tok, bias = b, amb = 0.1, wrap = 0.3 })
  -- knot
  local kx, ky = O.bez(RP, 0.72)
  kx, ky = floor(kx + .5), floor(ky + .5)
  O.map(c, { ".a.", "aba", ".a." }, kx - 1, ky - 1, { a = BARK[2], b = BARK[1] }, tok)
  c:put(kx - 1, ky - 2, BARK[6], tok)
end
-- soil lip over the root feet (root goes INTO the ground)
do
  local tok = O.tok("lip")
  for _, p in ipairs{ { 29, 52 }, { 50, 52 } } do
    O.map(c, { ".aaaab.", "aaaabbb" }, p[1], p[2], { a = SOIL[3], b = SOIL[2] }, tok)
    c:put(p[1] + 2, p[2], SOIL[4], tok)
  end
end
-- grass tufts
do
  local tok = O.tok("grass")
  for _, g in ipairs{ { 18, 50 }, { 41, 51 }, { 55, 51 } } do
    O.map(c, { "h..h", ".bhb.", "sbbbs" }, g[1], g[2] - 2, { h = GRAS[4], b = GRAS[3], s = GRAS[2] }, tok)
  end
end
-- quirk: mushroom on the arch
do
  local tok = O.tok("mush")
  local mx, my = O.bez(RP, 0.66)
  mx, my = floor(mx + .5), floor(my + .5) - 3
  O.map(c, {
    ".hcc.",
    "hcscs",
    "ccsss",
    ".dpd.",
    "..p..",
  }, mx - 2, my - 3, { h = MUSH[4], c = MUSH[3], s = MUSH[2], d = MUSH[1], p = "#f4e8cc" }, tok)
  c:put(mx - 1, my - 2, "#fff4d6", tok)
end

O.save(c, "trip")
