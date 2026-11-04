-- garlic (final pass, Opus single pass). A whole garlic bulb, slightly onion-shaped with a flat root plate, divided into
-- curved clove lobes by grooves; papery skin with faint violet streaks; a slim dried neck that twists up to a pale
-- cut end; a tuft of wiry pale roots underneath.
-- Material: per-pixel sphere light with per-clove bulges (each lobe rounds on its own), grooves = dark line + lit lip,
-- paper streaks, one soft specular, cool violet reflected light lower-right; neck = twisted papery tube with diagonal
-- twist bands and AO where it sinks into the bulb; roots = 2-tone wiry lines.
-- quirk: a flake of papery skin is peeling off the right side and curling away from the bulb.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = A.new("garlic")
local SKIN = { "#5a3f58", "#8a6c84", "#b8a0a8", "#dccbc4", "#f1e6d8", "#fff8ec" }
local NECK = { "#6a4a3e", "#987056", "#c49e78", "#e2c8a0", "#f6e6c4" }
local ROOT = { "#9a8070", "#d8c4a4", "#f2e2c4" }
local VIO, VIOD = "#a87ab8", "#7a4f8e"
local CX, CY, RX, RY = 31.5, 38, 13.5, 12

-- roots first (bulb overlaps their tops)
local rtok = { r = { name = "root" } }
for i, r in ipairs{ { 26, -2 }, { 28, -1 }, { 30, -1 }, { 32, 0 }, { 34, 1 }, { 36, 1 }, { 38, 2 } } do
  local x0, dx = r[1], r[2]
  for j = 0, 4 do
    local x = x0 + floor(dx * j / 4 + 0.5)
    c:put(x, 49 + j, (j % 2 == 0) and ROOT[2] or ROOT[1], rtok)
  end
  c:put(x0 + dx, 54, ROOT[3], rtok)
end

-- bulb: ellipse slightly fuller low, flattened root plate, pointed top
local bulb = HP.mask()
for y = CY - RY - 3, CY + RY do for x = floor(CX - RX - 1), floor(CX + RX + 1) do
  local v = (y - CY) / RY
  local rx = RX * (v < 0 and (1 - 0.32 * v * v * (1 + 0.6 * -v)) or 1)
  local u = (x - CX) / (rx + 0.3)
  if u * u + v * v <= 1 and y <= CY + 10 then bulb:set(x, y) end
end end
-- tapering tip up into the neck
bulb:add(HP.poly{ { 27, 28 }, { 36, 28 }, { 33, 22 }, { 30, 22 } })
-- clove lobes: angular position across the bulb; each lobe bulges
local NL = 5
local n = {}
local lobe, lobeU = {}, {}
local base = A.body(bulb, CX - 1, CY - 2, 15, 4, 0.7)
bulb:each(function(x, y) local k = K(x, y)
  local v = (y - CY) / RY
  local hw = RX * sqrt(max(0.05, 1 - min(1, v * v)))
  local u = max(-0.999, min(0.999, (x - CX) / (hw + 0.5)))
  local ang = math.asin(u)                     -- -pi/2..pi/2
  local f = (ang + pi / 2) / pi * NL           -- 0..NL
  local li = floor(f) local fr = f - li         -- position within lobe
  lobe[k], lobeU[k] = li, fr
  local b = base[k]
  local bulge = (fr - 0.5) * 0.9               -- each lobe tilts its own way
  n[k] = { A.norm(b[1] + bulge * 0.8, b[2], b[3]) }
end)
-- AO near the neck and at the root plate
local bias = {}
bulb:each(function(x, y) local k = K(x, y)
  if y >= CY + 9 then bias[k] = -1 end
  if y <= 26 then bias[k] = (bias[k] or 0) - 1 end
end)
local btok = { r = { name = "bulb" } }
local idx = A.shade(c, bulb, n, SKIN, { tok = btok, amb = 0.12, wrap = 0.32, bias = bias })
-- grooves between lobes: dark line on the boundary, lit lip on its left
bulb:each(function(x, y) local k = K(x, y)
  local fr, li = lobeU[k], lobe[k]
  if li >= 1 and li <= NL - 1 and y > 24 and y < CY + 9 then
    if fr < 0.09 then c:put(x, y, SKIN[max(1, (idx[k] or 3) - 2)], btok)
    elseif fr > 0.91 and (idx[k] or 3) >= 3 then c:put(x, y, SKIN[min(6, idx[k] + 1)], btok) end
  end
end)
-- violet streaks on the paper (lower lobes, along the lobe centres)
bulb:each(function(x, y) local k = K(x, y)
  local fr = lobeU[k]
  if y > CY + 1 and y < CY + 9 and abs(fr - 0.42) < 0.05 and (lobe[k] == 1 or lobe[k] == 3 or lobe[k] == 4) then
    c:put(x, y, (idx[k] or 3) >= 4 and VIO or VIOD, btok) end
  if y > CY + 4 and y < CY + 9 and abs(fr - 0.7) < 0.04 and lobe[k] == 2 then c:put(x, y, VIO, btok) end
end)
-- root plate: flat dark base row with a pale scar
for x = 22, 41 do if bulb:has(x, CY + 10) then c:put(x, CY + 10, x < 30 and SKIN[2] or SKIN[1], btok) end end
for x = 29, 34 do c:put(x, CY + 10, NECK[3], btok) end
-- cool reflected light lower-right
local rim = X.rim(n)
bulb:edge():each(function(x, y) if rim[K(x, y)] > 0.55 and x > CX + 5 and y > CY - 2 and y < CY + 9 then c:put(x, y, "#9c8fc4", btok) end end)
-- soft specular on the upper-left lobe
c:put(23, 31, SKIN[6], btok) c:put(24, 31, SKIN[6], btok) c:put(23, 32, A.CREAM, btok)

-- neck: slim twisted papery tube
local nm, nn, nT, nS, nidx = A.stem(c, { { 31.5, 24 }, { 31, 18 }, { 32.5, 13 }, { 31.5, 8 } },
  function(t) return 2.6 - t * 1.0 end, NECK, { amb = 0.15, wrap = 0.3, tok = { r = { name = "neck" } }, cuts = { 0.3, 0.5, 0.7, 0.86 } })
nm:each(function(x, y) local k = K(x, y)
  -- twist: diagonal bands
  local d = (y + nS[k] * 3) % 4
  if d < 1 and nT[k] < 0.92 then c:put(x, y, NECK[max(1, (nidx[k] or 3) - 1)]) end
end)
-- pale cut end on top
c:put(31, 7, NECK[5]) c:put(32, 7, NECK[4]) c:put(30, 8, NECK[4])
-- AO where the neck sinks into the bulb
for x = 29, 34 do if bulb:has(x, 24) then c:put(x, 24, SKIN[2], btok) end end

-- quirk: a flake of skin peeling off the right side, curling away
local flake = {
  "..ab",
  ".ab.",
  "abc.",
  "ab..",
  ".a..",
}
A.map(c, flake, 44, 30, { a = SKIN[5], b = SKIN[3], c = SKIN[2] })
c:put(43, 33, SKIN[4]) c:put(43, 34, SKIN[3])
A.save(c, "garlic")
