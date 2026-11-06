-- sardine (final, Opus-level single pass). A slim silver sardine, side view, head left, tail swept up in a gentle arc.
-- Material: per-pixel cylinder light over four colour bands (indigo back, teal shoulder, silver flank, cream belly),
-- diamond scale lattice on the flank, lateral iridescent line, gold-ringed eye, bright gill-cover arc, row of dark
-- spots, fin rays (forked tail, dorsal, pectoral, pelvic, anal), AO under fins and at the gill, silver sheen glint.
-- quirk: one scale on the flank has lifted like a tiny hatch and shows the pink flesh under it.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD14_2.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new("sardine")
local floor, sin, cos, sqrt, pi, max, min, abs = math.floor, math.sin, math.cos, math.sqrt, math.pi, math.max, math.min, math.abs

-- ramps (dark -> light)
local BK = { "#0e2234", "#163a52", "#1f5870", "#2a7a8a", "#3f9aa0", "#6cc0b8" }   -- indigo/teal back
local TL = { "#1a4a60", "#24687a", "#34889a", "#4eaaae", "#80ccc4", "#b4e6d8" }   -- shoulder teal
local SV = { "#6a76a0", "#8d9abc", "#b0bdd4", "#cdd8e6", "#e4ecf4", "#f6fafc" }   -- silver flank, violet shade
local BL = { "#8a86ae", "#aea8c4", "#cfc8d6", "#e8e0dc", "#f6efe2", "#fffaf0" }   -- belly
local FIN = { "#2e4670", "#46628e", "#6682ac", "#8aa4c6", "#aec4dc", "#d4e2f0" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }

-- body profile: head at x=7, tail root at x=47
local X0, X1 = 7, 44
local topY, botY, cyA, hA = {}, {}, {}, {}
local body = HP.mask()
for x = X0, X1 do
  local t = (x - X0) / (X1 - X0)
  local base
  if t < 0.36 then base = 6.3 * max(0, 1 - ((0.36 - t) / 0.36) ^ 2.3) ^ 0.55
  else base = 6.3 * max(0, 1 - ((t - 0.36) / 0.64) ^ 2) ^ 0.75 end
  local h = max(base, 0) + 1.7 * t ^ 4
  if t < 0.03 then h = max(h, 1.8) end
  local cy = 33 - 3.4 * t ^ 1.7
  cyA[x], hA[x] = cy, h
  topY[x], botY[x] = cy - h * 0.98, cy + h * 1.04
  for y = floor(topY[x] + 0.5), floor(botY[x] - 0.5) do body:set(x, y) end
end

-- ---- far-side pelvic fin first (behind), then tail ----
local function ray(x0, y0, x1, y1, hex)
  local n = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, n do local t = n == 0 and 0 or i / n
    c:px(floor(x0 + (x1 - x0) * t + 0.5), floor(y0 + (y1 - y0) * t + 0.5), hex) end
end
-- forked tail: peduncle (47, cy), tips well out, deep notch
local tcy = cyA[X1]
local tailM = HP.mask()
local tips = { up = { X1 + 12, tcy - 10.5 }, dn = { X1 + 11, tcy + 9.5 }, notch = { X1 + 6, tcy + 0.2 } }
for y = floor(tcy - 12), floor(tcy + 11) do for x = X1 - 1, X1 + 14 do
  -- inside the fork: between upper edge line and lower edge line, outside the notch wedge
  local fx = (x - (X1 - 0.5)) / 11.5
  if fx >= 0 and fx <= 1 then
    local uy = tcy - 1.4 - (tcy - 1.4 - tips.up[2]) * fx ^ 0.95
    local dy = tcy + 1.5 + (tips.dn[2] - tcy - 1.5) * fx ^ 0.95
    local inside = y >= uy and y <= dy
    -- fork notch: remove a wedge pointing back to the notch
    if x > tips.notch[1] - 1 then
      local w = (x - (tips.notch[1] - 1)) / (62 - (tips.notch[1] - 1))
      if abs(y - (tcy + 0.2)) < w * 6.2 + 0.2 then inside = false end
    end
    if inside then tailM:set(x, y) end
  end
end end
tailM:cut(body)
local tn = X.pillow(tailM, 2.5)
local tv = X.light(tn, { amb = 0.2, wrap = 0.5 })
X.tone(c, tailM, tv, FIN, { cuts = { 0.28, 0.44, 0.58, 0.72, 0.86 } })
-- rays fanning from the peduncle
for i = -4, 4 do
  local fy = tcy + i * 0.5
  local ex = X1 + 12.2 - abs(i) * 0.3
  local ey = i < 0 and (tips.up[2] + (i + 4) * 1.9) or (tips.dn[2] - (4 - i) * 1.9)
  if i == 0 then ex = X1 + 5.5 ey = tcy + 0.2 end
  local n = 40
  for s = 0, n do
    local t = s / n
    local x, y = floor((X1 - 0.5) + (ex - (X1 - 0.5)) * t + 0.5), floor(fy + (ey - fy) * t + 0.5)
    if tailM:has(x, y) then c:px(x, y, (i % 2 == 0) and FIN[2] or FIN[5]) end
  end
end
tailM:edge():each(function(x, y) if x > X1 + 9 then c:px(x, y, FIN[6]) end end)  -- bright trailing edge
-- peduncle keel pinch (dark crease where the body meets the tail)
for y = floor(topY[X1]) + 1, floor(botY[X1]) - 1 do c:px(X1 - 1, y, SV[1]) end

-- pelvic fin (far side, behind belly), small
local pel = HP.mask()
for _, p in ipairs{ {26, 38}, {27, 38}, {28, 38}, {29, 38}, {26, 39}, {27, 39}, {28, 39}, {27, 40}, {28, 40}, {26, 41} } do pel:set(p[1], p[2]) end
pel:cut(body)
X.tone(c, pel, X.light(X.pillow(pel, 1.2), { amb = 0.2, wrap = 0.5 }), FIN, { cuts = { 0.3, 0.45, 0.6, 0.75, 0.88 } })

-- dorsal fin: one triangular fin with rays
local dor = HP.mask()
for x = 24, 33 do
  local t = (x - 24) / 9
  local hgt = floor(5.6 * max(0, 1 - abs(t * 2 - 0.85)) ^ 0.9 + 0.5) + 1
  for y = floor(topY[x]) - hgt, floor(topY[x]) + 1 do dor:set(x, y) end
end
dor:cut(body)
X.tone(c, dor, X.light(X.pillow(dor, 1.8), { amb = 0.2, wrap = 0.5 }), FIN, { cuts = { 0.28, 0.44, 0.58, 0.72, 0.86 } })
for x = 25, 32, 2 do
  local t = (x - 24) / 9
  ray(x, floor(topY[x]), x - 1 + floor(t * 2), floor(topY[x]) - floor(5.6 * max(0, 1 - abs(t * 2 - 0.85)) ^ 0.9 + 0.5), FIN[2])
end

-- anal fin (near the tail, below)
local an = HP.mask()
for x = 36, 41 do
  local t = (x - 36) / 5
  local hgt = floor(3.3 * (1 - t) ^ 0.8 + 1.2)
  for y = floor(botY[x]) - 1, floor(botY[x]) + hgt do an:set(x, y) end
end
an:cut(body)
X.tone(c, an, X.light(X.pillow(an, 1.5), { amb = 0.2, wrap = 0.5 }), FIN, { cuts = { 0.3, 0.45, 0.6, 0.75, 0.88 } })
for x = 37, 40, 2 do ray(x, floor(botY[x]), x - 1, floor(botY[x]) + 3, FIN[2]) end

-- ---- body: bands + cylinder light + lattice ----
local bn = {}
body:each(function(x, y)
  local v = (y - topY[x]) / (botY[x] - topY[x] + 0.01)
  local s = max(-0.97, min(0.97, v * 2 - 1))
  local tx = (x - X0) / (X1 - X0)
  -- slight x tilt: the head and tail both curve away
  local nx = (tx < 0.2) and -(0.2 - tx) * 1.5 or (tx - 0.6) * 0.5
  bn[K(x, y)] = { nx, s * 0.95, sqrt(max(0.05, 1 - s * s)) }
end)
local lv = X.light(bn, { amb = 0.1, wrap = 0.35 })
local function tone(v, off)
  local i = 1
  for j, t in ipairs{ 0.2, 0.38, 0.54, 0.7, 0.86 } do if v >= t then i = j + 1 end end
  return max(1, min(6, i + (off or 0)))
end
local band = {}
body:each(function(x, y)
  local k = K(x, y)
  local v = (y - topY[x]) / (botY[x] - topY[x] + 0.01)
  local l = lv[k]
  local hex
  if v < 0.1 then hex = BK[tone(l, -2)] band[k] = 1
  elseif v < 0.3 then hex = BK[tone(l, 0)] band[k] = 1
  elseif v < 0.4 then hex = TL[tone(l, 0)] band[k] = 2
  elseif v < 0.74 then hex = SV[tone(l, 1)] band[k] = 3
  else hex = BL[tone(l, 0)] band[k] = 4 end
  c:px(x, y, hex)
end)
-- scale lattice on shoulder + flank: lit lower-left rims of each scale, dark crescent upper-right
body:each(function(x, y)
  local k = K(x, y)
  local b = band[k]
  if b == 2 or b == 3 then
    local u = (x + y) % 4
    local w = (x - y + 400) % 4
    if u == 0 and w == 0 then
      local base = c.pix[y * c.w + x]
      c:px(x, y, b == 3 and SV[6] or TL[6])
    elseif (u == 1 and w == 3) then
      c:px(x, y, b == 3 and SV[2] or TL[2])
    end
  end
end)
-- iridescent lateral line: cyan -> violet blink along the shoulder/flank seam
for x = 16, X1 - 1 do
  local v = 0.385
  local y = floor(topY[x] + (botY[x] - topY[x]) * v + 0.5)
  c:px(x, y, (x % 6 < 3) and "#8fe0d8" or "#a69ce0")
end
-- belly keel edge: darker violet rim along the underside (shade side), pale scutes
body:each(function(x, y)
  if not body:has(x, y + 1) and x > 12 and x < X1 - 1 then c:px(x, y, BL[1]) end
  if not body:has(x, y - 1) and x > 12 then c:px(x, y, BK[1]) end
end)
-- dark spots along the flank (sardine trademark), just under the lateral line
for i, x in ipairs{ 19, 23, 27, 31, 35 } do
  local y = floor(topY[x] + (botY[x] - topY[x]) * 0.5 + 0.5)
  c:px(x, y, "#3b4f78") c:px(x + 1, y, "#55698f")
end

-- ---- head: cheek, gill cover arc, eye, mouth ----
-- snout shading: pale chin, lit crown
c:px(7, 33, "#d4dde8") c:px(8, 34, BL[3]) c:px(7, 32, BK[3])
-- gill cover arc (bright rim) and a pale golden cheek plate
for y = 26, 39 do
  local x = 16 + floor(((y - 32.5) ^ 2) / 9 + 0.5)
  if body:has(x, y) then c:px(x, y, "#fffaf0") end
  if body:has(x + 1, y) then c:px(x + 1, y, "#7a82ad") end   -- AO shadow behind the cover
end
for y = 28, 38 do
  for x = 10, 15 do
    local gx = 16 + floor(((y - 32.5) ^ 2) / 9 + 0.5)
    if x < gx and body:has(x, y) and y > topY[x] + 2.4 and y < botY[x] - 1.2 then
      local dd = (x - 10) * 0.6 + (y - 28) * 0.18
      c:px(x, y, (dd < 2.2) and "#e8e2d0" or "#d6d2c6")
    end
  end
end
-- eye: gold ring, ink pupil, cream glint
local ex, ey = 11, floor(topY[11]) + 5
for dy = -2, 2 do for dx = -2, 2 do
  if not (abs(dx) == 2 and abs(dy) == 2) then c:px(ex + dx, ey + dy, GOLD[3]) end
end end
for dx = -2, 2 do c:px(ex + dx, ey + 2, GOLD[2]) end
c:px(ex + 2, ey + 1, GOLD[2])
for dy = -1, 1 do for dx = -1, 1 do c:px(ex + dx, ey + dy, "#2b1c26") end end
c:px(ex - 1, ey - 1, "#fff4d6")
c:px(ex - 2, ey - 1, GOLD[4]) c:px(ex - 1, ey - 2, GOLD[4])
-- mouth: lower jaw juts a little
c:px(7, 35, "#2b1c26") c:px(8, 36, "#2b1c26") c:px(9, 36, "#4a3a5a")
c:px(7, 34, "#7a82ad")

-- pectoral fin: fan behind the gill, over the flank
local pec = HP.mask()
for _, p in ipairs{ {18,34},{19,34},{20,34},{21,34},{18,35},{19,35},{20,35},{21,35},{22,35},{19,36},{20,36},{21,36},{22,36},{20,37},{21,37},{22,37},{23,37},{21,38},{22,38},{23,38},{22,39} } do pec:set(p[1], p[2]) end
X.tone(c, pec, X.light(X.pillow(pec, 1.6), { amb = 0.15, wrap = 0.5 }), FIN, { cuts = { 0.3, 0.45, 0.6, 0.75, 0.88 } })
ray(19, 34, 22, 39, FIN[2]) ray(21, 35, 23, 38, FIN[2])
pec:edge():each(function(x, y) if not pec:has(x - 1, y) and body:has(x, y) then c:px(x, y, FIN[1]) end end)
-- AO under the pectoral where it touches the flank
for x = 19, 24 do local y = 40 if body:has(x, y) and not pec:has(x, y) then c:px(x, y, SV[1]) end end

-- ---- quirk: one lifted scale (hatch) on the flank ----
local qx, qy = 29, floor(topY[29] + (botY[29] - topY[29]) * 0.62)
-- open window showing pink flesh
for _, p in ipairs{ {0,0,"#e88a9a"},{1,0,"#f4a6b0"},{2,0,"#e88a9a"},{0,1,"#b8506a"},{1,1,"#d8708a"},{2,1,"#c0607a"},{1,2,"#8a3c5c"} } do
  c:px(qx + p[1], qy + p[2], p[3]) end
-- the lifted scale flap, curling up-left, with a bright rim and a drop shadow
for _, p in ipairs{ {-1,-1,SV[6]},{0,-1,SV[5]},{1,-1,SV[4]},{2,-1,SV[3]},{3,-1,SV[2]},{-1,0,SV[4]},{3,0,SV[1]} } do
  c:px(qx + p[1], qy + p[2], p[3]) end
c:px(qx + 4, qy, "#7a82ad") c:px(qx + 3, qy + 1, "#6a76a0")
c:px(qx - 1, qy - 1, "#fffaf0")

-- ---- silver sheen glint: long bright streak on the shoulder, one cream sparkle ----
for x = 17, 30 do
  local y = floor(topY[x] + (botY[x] - topY[x]) * 0.31 + 0.5)
  if x % 7 ~= 3 then c:px(x, y, "#e8fff8") end
end
c:px(24, floor(topY[24] + 2.4), "#fffaf0") c:px(25, floor(topY[25] + 2.4), "#fffaf0")
c:px(14, floor(topY[14]) + 1, "#9ee0d4")
c:sparkle(12, floor(topY[12]) - 3)
A.save(c, "sardine")
