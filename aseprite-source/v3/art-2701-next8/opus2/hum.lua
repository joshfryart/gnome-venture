-- hum (Opus second pass). Tag "hum" (Hum: charm that also calms). Keeps Haiku's idea (two beamed notes) but gives
-- them real form: glossy lacquered jade-teal notes (tilted oval heads, slim 3 px stems, a thick slanted beam with a
-- lit top bevel), each head with one hard specular and a dark rim on the shade side. Under them two soft sky-blue
-- wavelets drift off to the left (the calming hum). Replaces the meaningless green zigzag.
-- quirk: a fat little bumblebee has landed on the beam and is humming along (wing blur arcs).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_o.lua")
local HP, X, K = O.HP, O.X, O.K
local floor, max, min, abs, sqrt, sin, cos = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos
local c = O.new("hum")

local JADE = { "#123a48", "#1d5c68", "#2a8a8c", "#3fb4a8", "#7adcc4", "#d2fae8" }
local SKY  = { "#5f9ad0", "#8bc4ea", "#e4f6ff" }
local BEE  = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local INK  = "#2b1c26"

-- calming wavelets under each head (drawn first, behind)
do
  local tok = O.tok("wave")
  for i, w in ipairs{ { 7, 57, 20, 0 }, { 33, 51, 15, 2 } } do
    for x = w[1], w[1] + w[3] do
      local y = w[2] + floor(sin((x - w[1]) * 0.6 + w[4]) * 1.2 + .5)
      local f = (x - w[1]) / w[3]
      c:put(x, y, (f > 0.3 and f < 0.7) and SKY[3] or SKY[2], tok)
    end
  end
end

local notes = HP.mask()
local n = {}
-- beam: slanted bar, thicker toward the right
local beam = c:poly{ { 21, 22 }, { 48, 14 }, { 48, 20 }, { 21, 27 } }
-- stems
local st1 = c:rect(22, 24, 24, 47)
local st2 = c:rect(46, 17, 48, 41)
local h1, n1 = O.oval(18, 49, 6, 4.2, -0.42)
local h2, n2 = O.oval(42, 43, 6, 4.2, -0.42)
do
  local tok = O.tok("notes")
  local bars = beam:copy():add(st1):add(st2)
  local bn = X.pillow(bars, 2)
  -- the beam is a flat slab facing the viewer, tilted slightly to the light
  local idx = O.shade(c, bars, bn, JADE, { tok = tok, amb = 0.12 })
  -- beam top bevel (lit) and underside (dark)
  beam:each(function(x, y)
    if not beam:has(x, y - 1) then O.set(c, idx, JADE, x, y, 5, tok) O.set(c, idx, JADE, x, y + 1, 5, tok) end
    if not beam:has(x, y + 1) then O.set(c, idx, JADE, x, y, 2, tok) end
  end)
  -- stems: lit left column, dark right column
  for y = 24, 47 do O.set(c, idx, JADE, 22, y, 5, tok) O.set(c, idx, JADE, 23, y, 4, tok) O.set(c, idx, JADE, 24, y, 3, tok) end
  for y = 17, 41 do O.set(c, idx, JADE, 46, y, 5, tok) O.set(c, idx, JADE, 47, y, 4, tok) O.set(c, idx, JADE, 48, y, 3, tok) end
  -- AO where the stems meet the beam
  O.set(c, idx, JADE, 23, 28, 2, tok) O.set(c, idx, JADE, 24, 28, 2, tok) O.set(c, idx, JADE, 47, 21, 2, tok) O.set(c, idx, JADE, 48, 21, 2, tok)
  -- beam spec
  for _, p in ipairs{ { 25, 22 }, { 26, 22 }, { 27, 21 } } do O.set(c, idx, JADE, p[1], p[2], 6, tok) end
  -- heads: glossy ovals, one spec each, dark rim on the lower right
  for _, H in ipairs{ { h1, n1, 15, 47 }, { h2, n2, 39, 41 } } do
    local hi = O.shade(c, H[1], H[2], JADE, { tok = tok, amb = 0.1, wrap = 0.2 })
    H[1]:each(function(x, y) if not H[1]:has(x + 1, y + 1) then O.set(c, hi, JADE, x, y, 1, tok) end end)
    c:put(H[3], H[4], JADE[6], tok) c:put(H[3] + 1, H[4], JADE[6], tok) c:put(H[3], H[4] + 1, JADE[5], tok)
  end
end

-- quirk: a bumblebee perched on the beam, humming along
do
  local tok = O.tok("bee")
  -- wings first (behind), pale glass, the far one smaller
  local w1 = O.oval(34.5, 7.5, 2.6, 1.8, -0.5)
  local w2 = O.oval(38.5, 7, 1.8, 1.4, 0.3)
  w2:each(function(x, y) c:put(x, y, SKY[2], tok) end)
  w1:each(function(x, y) c:put(x, y, (x + y) % 3 == 0 and SKY[2] or SKY[3], tok) end)
  local body, bn = O.oval(36, 12.5, 4.4, 3.2)
  O.shade(c, body, bn, BEE, { tok = tok, amb = 0.2, cuts = { 0.3, 0.55, 0.8 } })
  -- two dark bands, fuzz tip on the tail
  for y = 9, 16 do if body:has(35, y) then c:put(35, y, INK, tok) end if body:has(38, y) then c:put(38, y, INK, tok) end end
  -- head (dark) with eye glint and an antenna
  local head = O.oval(42, 12, 2.2, 2.2)
  head:each(function(x, y) c:put(x, y, (x < 42 and y < 12) and "#5a3a3a" or "#3a2830", tok) end)
  c:put(43, 11, "#fff4d6", tok)
  c:put(43, 9, INK, tok) c:put(44, 8, INK, tok)
  c:put(32, 13, BEE[1], tok)
  -- hum arcs off its wings
  c:put(30, 5, SKY[2], tok) c:put(29, 6, SKY[2], tok) c:put(29, 7, SKY[3], tok) c:put(29, 8, SKY[2], tok)
end

O.save(c, "hum")
