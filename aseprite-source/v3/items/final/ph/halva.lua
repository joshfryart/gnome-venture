-- halva (final pass, Opus aC10_5). A slim slab of marbled sesame halva in 3/4 view on a torn square of wax paper:
-- lit top face with a cocoa marble swirl, chopped pistachio and sesame seeds; front face with the flaky, fibrous
-- striations halva breaks into; shaded right end. Crumbly broken top edges, bevel-lit front edge, contact shadow on the
-- paper, AO where slab meets paper, ground shadow.
-- quirk: one bite taken out of the top-left corner, the exposed crumb rougher and darker, a flake fallen on the paper.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin
local c = A.new("halva")

local HV  = { "#6e4a3c", "#9c6e4e", "#c39463", "#dcb47e", "#eccf9c", "#f9e9c6" }
local COC = { "#3d2026", "#5c3029", "#7d4532", "#9c5f3e", "#b97c52" }
local PIS = { "#2c5236", "#4c8640", "#84b84e", "#c0e07e" }
local PAP = { "#7f7790", "#aba3b6", "#d3cbcf", "#ebe3d8", "#faf4e6" }

-- geometry: front face x0..x1, y FT..FB; top face skewed up-right by D rows (1:1)
local x0, x1, FT, FB, D = 11, 41, 30, 43, 9
local function inTop(x, y) local r = FT - y return r >= 1 and r <= D and x >= x0 + r and x <= x1 + r end
local function inFront(x, y) return y >= FT and y <= FB and x >= x0 and x <= x1 end
local function inSide(x, y) local r = x - x1 return r >= 1 and r <= D and y >= FT - r and y <= FB - r end

-- paper scrap first (under everything), torn left edge
c:groundShadow(30, 50, 21, 2)
local paper = A.maskF(4, 34, 60, 50, function(x, y)
  local yl = 46 + floor((x - 4) * 0.0)
  if y > 49 or y < 37 then return false end
  local skewT = 37 + floor((60 - x) / 7)        -- far edge slants
  if y < skewT - 2 then return false end
  local tear = 9 + ((y * 7) % 3) - (y % 2)       -- ragged torn left edge
  if x < tear then return false end
  if x > 53 - ((y + 1) % 2) then return false end
  return true
end)
local tokP = A.tok("paper")
local nPp = X.pillow(paper, 1.2)
local biasP = {}
-- contact shadow of the slab on the paper (down-right of the footprint)
paper:each(function(x, y) local k = K(x, y)
  if y >= FB + 1 and y <= FB + 2 and x >= x0 + 1 and x <= x1 + 3 then biasP[k] = (y == FB + 1) and -2 or -1 end
  if x >= x1 + 1 and x <= x1 + D + 2 and y >= FT - (x - x1) + 2 and y <= FB + 2 then biasP[k] = -1 end
end)
local idxP = A.shade(c, paper, nPp, PAP, { amb = 0.35, wrap = 0.5, cuts = { 0.3, 0.5, 0.7, 0.88 }, bias = biasP, tok = tokP })
-- wax paper crease line + a fold
for x = 45, 52 do if paper:has(x, 46) then A.step(c, idxP, PAP, x, 46, -1, tokP) end end
for x = 45, 52 do if paper:has(x, 45) then A.step(c, idxP, PAP, x, 45, 1, tokP) end end

-- slab mask with crumbly broken top-back edge and the bite
local slab = HP.mask()
for y = 0, 63 do for x = 0, 63 do if inTop(x, y) or inFront(x, y) or inSide(x, y) then slab:set(x, y) end end end
-- crumbly back edge: nibble a few pixels along the far top edge
for _, p in ipairs{ { 24, 21 }, { 25, 21 }, { 33, 21 }, { 41, 21 }, { 42, 21 }, { 50, 21 }, { 50, 22 }, { 50, 26 }, { 50, 30 } } do slab:cut(HP.rect(p[1], p[2], p[1], p[2])) end
-- the bite: three scalloped tooth arcs out of the top-left corner
local bite = HP.mask()
for _, b in ipairs{ { 12.5, 27.5, 4.2 }, { 17.5, 25.8, 3.4 }, { 10.5, 32.2, 2.6 } } do bite:add(HP.ellipse(b[1], b[2], b[3], b[3])) end
slab:cut(bite)
local biteRim = bite:grow(1):clip(slab)

local tokH, tokC = A.tok("halva"), A.tok("cocoa")
-- per-face flat normals, slight pillow so edges bevel
local nPl = X.pillow(slab, 1.4)
local n, bias = {}, {}
slab:each(function(x, y) local k = K(x, y) local a = nPl[k]
  local f
  if inTop(x, y) then f = { 0, -0.75, 0.66 }
  elseif inSide(x, y) then f = { 0.85, -0.1, 0.5 }
  else f = { 0, 0.12, 1 } end
  n[k] = { A.norm(f[1] * 0.75 + a[1] * 0.25, f[2] * 0.75 + a[2] * 0.25, f[3] * 0.75 + a[3] * 0.25) }
  if inFront(x, y) and y >= FB - 1 then bias[k] = -1 end     -- AO where slab sits on paper
  if inSide(x, y) and y >= FB - (x - x1) - 1 then bias[k] = -1 end
end)
local idx = A.shade(c, slab, n, HV, { amb = 0.18, wrap = 0.3, cuts = { 0.22, 0.4, 0.56, 0.7, 0.84 }, bias = bias, tok = tokH })

-- front face: fibrous, flaky striations (broken horizontal lines, lighter lips above dark seams)
slab:each(function(x, y) local k = K(x, y)
  if inFront(x, y) and y > FT and y < FB - 1 then
    local seam = (y + floor(sin(x * 0.45 + y) * 0.9 + 0.5)) % 3 == 0
    if seam and X.hash(floor(x / 3), y, 7) > 0.3 then A.step(c, idx, HV, x, y, -1, tokH)
    elseif X.hash(x, y, 9) > 0.93 then A.step(c, idx, HV, x, y, 1, tokH) end
  elseif inSide(x, y) then
    local r = x - x1
    if (y + r) % 3 == 0 and X.hash(r, y, 2) > 0.35 then A.step(c, idx, HV, x, y, -1, tokH) end
  end
end)
-- bevel: lit front-top edge row, shaded right corner
for x = x0, x1 do if slab:has(x, FT) then A.step(c, idx, HV, x, FT, 2, tokH) end end

-- cocoa marble swirl: a ribbon on the top face that wraps down the front
local function swirlTop(x) return 25.5 + 2.6 * sin((x - 14) * 0.32) end
slab:each(function(x, y) local k = K(x, y)
  if inTop(x, y) then
    local d = y - swirlTop(x)
    local d2 = y - (23 + 1.4 * sin((x - 30) * 0.5))
    if abs(d) < 0.9 and x > 22 then c:put(x, y, (d < 0) and COC[5] or COC[4], tokC)
    elseif abs(d2) < 0.6 and x > 32 and x < 46 then c:put(x, y, COC[4], tokC) end
  elseif inFront(x, y) and y < FB - 1 then
    local d = y - (36 + 3.2 * sin((x - 10) * 0.28))
    if abs(d) < 1.0 then
      local t = (d < -0.3) and COC[4] or COC[3]
      if (idx[k] or 3) <= 2 then t = COC[2] end
      c:put(x, y, t, tokC)
    elseif abs(d) < 1.6 and X.hash(x, y, 5) > 0.6 then c:put(x, y, COC[3], tokC) end
  elseif inSide(x, y) then
    local r = x - x1
    local d = (y + r) - (34 + 2 * sin(r * 0.6))
    if abs(d) < 0.9 then c:put(x, y, COC[1], tokC) end
  end
end)

-- bite interior: rougher, a step darker, crumbly lit lip
biteRim:each(function(x, y) local k = K(x, y)
  if inTop(x, y) or inFront(x, y) then
    local v = (X.hash(x, y, 11) > 0.5) and -1 or -2
    if not bite:has(x - 1, y) and not bite:has(x, y - 1) then v = 1 end
    A.step(c, idx, HV, x, y, v, tokH)
  end
end)

-- pistachio chips (2x2 / 3x2, lit corner) and sesame seeds on the top face
local tokG = A.tok("pistachio")
for _, p in ipairs{ { 27, 25, 3 }, { 36, 27, 2 }, { 44, 23, 2 }, { 33, 23, 2 }, { 40, 29, 2 } } do
  local x, y, w = p[1], p[2], p[3]
  if slab:has(x, y) and slab:has(x + w - 1, y + 1) then
    for i = 0, w - 1 do c:put(x + i, y, PIS[3], tokG) c:put(x + i, y + 1, PIS[2], tokG) end
    c:put(x, y, PIS[4], tokG) c:put(x + w - 1, y + 1, PIS[1], tokG)
  end
end
for _, p in ipairs{ { 30, 28 }, { 47, 26 }, { 24, 23 }, { 38, 24 }, { 43, 27 } } do
  if slab:has(p[1], p[2]) and slab:has(p[1] + 1, p[2]) then c:put(p[1], p[2], A.CREAM, tokH) c:put(p[1] + 1, p[2], HV[5], tokH) end
end
-- specular: one cream glint on the oily lit corner
c:put(22, 30, A.CREAM, tokH)

-- fallen flake on the paper (quirk crumb)
local tokF = A.tok("flake")
c:put(10, 45, HV[5], tokF) c:put(11, 45, HV[4], tokF) c:put(10, 46, HV[3], tokF) c:put(11, 46, HV[2], tokF)
c:put(13, 47, HV[4], tokF)
A.save(c, "halva")
