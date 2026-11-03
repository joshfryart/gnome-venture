-- ico-bone (final, Opus). A slim long-bone on the diagonal: a 7 px shaft that flares into a pair of round
-- condyles at each end. Modelled as a height field (capsule + four spheres, smooth union) so the fillets where the
-- knobs meet the shaft read as soft necks. Material: 6-tone warm ivory lit per pixel, AO in the notch between each
-- pair of condyles, a faint lengthwise grain line, porous pits on the knobs, cool reflected light lower-right,
-- one matte specular on the top knob.
-- quirk: a dog has had a go at it, two tooth notches bitten into the upper edge of the shaft.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = A.new("ico-bone")
local IV = { "#5a3a3e", "#8c624f", "#bb9068", "#dcb98a", "#efd9ad", "#fbeccb" }
local SPEC, BOUNCE = "#fff4d6", "#a7899a"
local tok = { r = { name = "bone" } }

local ax, ay, bx, by = 19.5, 44.5, 44.5, 19.5          -- shaft ends (lower-left, upper-right)
local ux, uy = (bx - ax), (by - ay) local L = sqrt(ux * ux + uy * uy) ux, uy = ux / L, uy / L
local px, py = -uy, ux if px + py < 0 then px, py = -px, -py end   -- +p = lower-right
local parts = { A.capsuleH(ax, ay, bx, by, 3.4) }
local knobs = {}
for _, e in ipairs{ { ax, ay, -1 }, { bx, by, 1 } } do
  for _, sd in ipairs{ -1, 1 } do
    local r = (sd < 0) and 5.0 or 4.7
    local kx, ky = e[1] + ux * e[3] * 2.2 + px * sd * 3.9, e[2] + uy * e[3] * 2.2 + py * sd * 3.9
    parts[#parts + 1] = A.sphereH(kx, ky, r)
    knobs[#knobs + 1] = { kx, ky, r }
  end
  -- neck flare
  parts[#parts + 1] = A.sphereH(e[1] - ux * e[3] * 1.5, e[2] - uy * e[3] * 1.5, 4.3)
end
local function hf(x, y)
  local h = -1e9
  for i, f in ipairs(parts) do local v = f(x, y) h = (i == 1) and v or A.smax(h, v, 2.6) end
  return h
end
local m, n, H, C = A.field(hf, 4, 4, 60, 60, 0.9)
-- quirk: tooth notches on the upper-left edge of the shaft (cut before shading so the outline follows)
local function along(t) return ax + (bx - ax) * t, ay + (by - ay) * t end
for _, t in ipairs{ 0.47, 0.6 } do
  local x, y = along(t)
  local nx, ny = floor(x - px * 3.2 + 0.5), floor(y - py * 3.2 + 0.5)
  for _, d in ipairs{ { 0, 0 }, { -1, 0 }, { 0, -1 }, { -1, -1 }, { 1, -1 }, { -1, 1 } } do
    local qx, qy = nx + d[1], ny + d[2]
    m.s[K(qx, qy)] = nil
  end
  -- dent shadow inside the bite
  for _, d in ipairs{ { 1, 0 }, { 0, 1 }, { 1, 1 } } do local k = K(nx + d[1], ny + d[2]) if m:has(nx + d[1], ny + d[2]) then n[k] = { 0.5, 0.6, 0.6 } end end
end
local bias = {}
m:each(function(x, y) local k = K(x, y)
  if C[k] > 1.2 then bias[k] = -2 elseif C[k] > 0.35 then bias[k] = -1 end
end)
local idx = A.shade(c, m, n, IV, { tok = tok, bias = bias, amb = 0.04, wrap = 0.22, cuts = { 0.2, 0.38, 0.56, 0.73, 0.89 } })
-- lengthwise grain: a faint darker line along the shaft on the lit side, and a paler one beside it
m:each(function(x, y) local k = K(x, y)
  local rx, ry = x - ax, y - ay
  local t = (rx * ux + ry * uy) / L
  local s = rx * px + ry * py
  if t > 0.22 and t < 0.78 then
    if abs(s + 0.6) < 0.5 and (floor(t * 30) % 4 ~= 0) then A.step(c, idx, IV, x, y, -1, tok) end
    if abs(s - 1.7) < 0.5 and t > 0.3 and t < 0.7 then A.step(c, idx, IV, x, y, -1, tok) end
  end
end)
-- porous pits on the knobs (only on lit-ish pixels, deterministic scatter)
for i, kb in ipairs(knobs) do
  local pts = { { -1, -1 }, { 1, 1 } }
  for j, p in ipairs(pts) do
    if (i + j) % 2 == 0 then
      local x, y = floor(kb[1] + p[1] + 0.5), floor(kb[2] + p[2] + 0.5)
      if m:has(x, y) and (idx[K(x, y)] or 0) >= 4 then A.step(c, idx, IV, x, y, -2, tok) end
    end
  end
end
-- cool reflected light lower-right
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y)
  if rim[k] and rim[k] > 0.72 and (idx[k] or 9) <= 2 and C[k] < 0.3 then c:put(x, y, BOUNCE, tok) end end)
-- matte specular on the top-left knob of the upper end
local sx, sy = A.specAt(m, n, 30)
c:put(sx, sy, SPEC, tok) c:put(sx + 1, sy, IV[6], tok)
A.save(c, "ico-bone")
