-- eel-skin (Opus single pass). A dried, flattened eel skin lying in a loose S from the cut head end (lower-left)
-- to the finned tail (upper-right). Ribbon lit per pixel as a flattened tube: dark olive back, bronze flank,
-- cream belly edge; tan cut end showing the hollow inside; soft cross creases (dark groove + lit lip); pale lateral
-- line dashes; mottled spots on the back; a thin rayed dorsal fin running along the upper edge into the tail fin.
-- Material: leathery sheen streak on the flank. A twisted twine tie wraps the skin near the head end.
-- quirk: the twine is finished with a tiny bow, one loop flopping over.
local NAME = "eel-skin"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB25_2.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local BACK  = { "#14231f", "#203a2e", "#2f523a", "#476b40", "#668650", "#93a868" }
local FLANK = { "#2f2a24", "#4f4428", "#7a6a32", "#a68f42", "#cbb35e", "#ecd894" }
local BELLY = { "#5a4632", "#8a7050", "#b49a6a", "#d6c08c", "#ece0b0", "#fbf3d2" }
local FIN   = { "#5a6648", "#97a476", "#c4cc98" }
local INSIDE = { "#8a5a36", "#c08a52", "#e2b77a" }
local TW = { "#6a4626", "#a8763e", "#dcae66", "#f4d896" }

local p = { { 10, 46 }, { 36, 62 }, { 28, 4 }, { 54, 18 } }
local function hw(t)
  local w = 3.3 + 0.4 * sin(t * pi * 0.6)
  if t > 0.5 then w = w * (1 - (t - 0.5) / 0.5) ^ 1.1 end
  return max(w, 0.4)
end
local m, n, T, S, samp = G.tube(p, hw)
-- square-cut head end: drop pixels behind the first sample
do local s = samp[1]
  local drop = {}
  m:each(function(x, y) if (x - s.x) * s.tx + (y - s.y) * s.ty < -0.2 then drop[#drop + 1] = { x, y } end end)
  for _, q in ipairs(drop) do m.s[K(q[1], q[2])] = nil end
end
-- flatten: normals mostly face the viewer, with rounded edges
for k, nn in pairs(n) do local s = S[k] or 0
  local e = abs(s) ^ 3
  n[k] = { G.norm(nn[1] * (0.25 + e), nn[2] * (0.25 + e), nn[3] + 0.4) } end
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end
-- dorsal fin: thin strip outside the lit (upper) edge, from t=0.3 into the tail
local fin = HP.mask()
local finT = {}
for i = 1, #samp do local s = samp[i]
  if s.t > 0.3 then
    local fw = 0.6 + 0.9 * min(1, (s.t - 0.3) / 0.4)
    if s.t > 0.86 then fw = fw + (s.t - 0.86) * 7 end
    for d = 0.6, fw + 0.4, 0.5 do
      local x, y = floor(s.x - s.px * (s.w + d) + .5), floor(s.y - s.py * (s.w + d) + .5)
      if not m:has(x, y) then fin:set(x, y) finT[K(x, y)] = s.t end
    end
  end
end
-- tail fin below the tail too (eels' fin wraps round)
for i = 1, #samp do local s = samp[i]
  if s.t > 0.82 then
    for d = 0.6, 0.6 + (s.t - 0.82) * 6, 0.5 do
      local x, y = floor(s.x + s.px * (s.w + d) + .5), floor(s.y + s.py * (s.w + d) + .5)
      if not m:has(x, y) then fin:set(x, y) finT[K(x, y)] = s.t end
    end
  end
end
local ftok = { r = { name = "fin" } }
fin:each(function(x, y) local t = finT[K(x, y)]
  local ray = floor(t * LEN / 2) % 2 == 0
  c:put(x, y, ray and FIN[2] or FIN[3], ftok) end)
fin:edge():each(function(x, y) if X.hash(x, y, 5) > 0.5 then c:put(x, y, FIN[1], ftok) end end)

local v = X.light(n, { amb = 0.08, wrap = 0.3 })
local stok = { r = { name = "skin" } }
local idx = {}
local CUTS = { 0.3, 0.45, 0.6, 0.74, 0.88 }
m:each(function(x, y) local k = K(x, y)
  local val = v[k] or 0
  local i = 1
  for j, tt in ipairs(CUTS) do if val >= tt then i = j + 1 end end
  local s, t = S[k], T[k]
  -- creases: soft cross wrinkles
  local d = (t * LEN) % 6.5
  if t > 0.12 and t < 0.92 and d < 0.9 then i = i - 2 elseif t > 0.12 and t < 0.92 and d < 1.9 then i = i + 1 end
  i = max(1, min(6, i))
  idx[k] = i
  local ramp = s < -0.3 and BACK or (s < 0.5 and FLANK or BELLY)
  -- mottling on the back
  if s < -0.3 and X.hash(floor(x / 2), floor(y / 2), 4) > 0.72 then i = max(1, i - 1) end
  c:put(x, y, ramp[i], stok)
  -- lateral line dashes
  if s > 0.12 and s < 0.3 and floor(t * LEN) % 3 ~= 0 and t > 0.12 and t < 0.85 then c:put(x, y, FLANK[min(6, i + 1)], stok) end
end)
-- leathery sheen streak along the upper flank, mid-body
for i = 0, 18 do local t = 0.36 + i * 0.012
  local s = samp[floor(t * 160) + 1]
  local x, y = floor(s.x + s.px * s.w * 0.0 + .5), floor(s.y + s.py * s.w * 0.0 + .5)
  if (t * LEN) % 6.5 > 2 then c:put(x, y, i == 7 and "#fff4d6" or FLANK[6], stok) end
end
-- cut head end: hollow inside showing (tan), dark rim
do local s = samp[1]
  m:each(function(x, y) local k = K(x, y)
    local a = (x - s.x) * s.tx + (y - s.y) * s.ty
    if a < 1.4 then local sn = S[k]
      c:put(x, y, abs(sn) > 0.7 and INSIDE[1] or (sn < -0.1 and INSIDE[3] or INSIDE[2]), stok) end
  end)
end
-- twine tie around the skin at t ~ 0.13, twisted (diagonal ply), standing 1 px proud of each edge
local ttok = { r = { name = "twine" } }
local tw = HP.mask()
for i = 1, #samp do local s = samp[i]
  if s.t > 0.11 and s.t < 0.155 then
    for d = -s.w - 1, s.w + 1, 0.5 do
      tw:set(floor(s.x + s.px * d + .5), floor(s.y + s.py * d + .5))
    end
  end
end
-- AO on the skin either side of the twine
local ring = tw:grow(1):cut(tw)
ring:each(function(x, y) if m:has(x, y) then local i = c:get(x, y)
  c:put(x, y, (S[K(x, y)] or 0) < -0.15 and BACK[1] or FLANK[2], stok) end end)
tw:each(function(x, y)
  local ply = (x + y) % 3
  local col = ply == 0 and TW[1] or (ply == 1 and TW[3] or TW[2])
  if (x + y) % 3 == 1 and x % 2 == 0 then col = TW[4] end
  c:put(x, y, col, ttok)
end)
-- quirk: small bow on the upper edge of the tie, one loop flopped over
do local s = samp[floor(0.135 * 160) + 1]
  local bx, by = floor(s.x - s.px * (s.w + 2) + .5), floor(s.y - s.py * (s.w + 2) + .5)
  local bow = {
    { -3, -2, 2 }, { -2, -2, 3 }, { -3, -1, 2 }, { -1, -1, 3 }, { -2, 0, 2 }, { -1, 0, 2 },
    { 0, 0, 1 }, { 0, -1, 2 },
    { 1, 0, 3 }, { 2, 0, 3 }, { 3, 1, 2 }, { 2, 2, 3 }, { 1, 1, 2 }, { 3, 2, 1 },
    { -2, 1, 2 }, { -3, 2, 1 }, { 1, 2, 2 }, { 1, 3, 1 },
  }
  for _, q in ipairs(bow) do local x, y = bx + q[1], by + q[2]
    if not m:has(x, y) or q[3] >= 2 then c:put(x, y, TW[q[3] + 1], ttok) end end
end
G.save2(c, NAME)
