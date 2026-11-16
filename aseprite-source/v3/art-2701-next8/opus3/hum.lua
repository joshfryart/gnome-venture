-- hum (Opus third pass, richness). Built on opus2: jade mottling + bounce line + gold inlay on the beam, smooth
-- ribbon wavelets, a bigger fuzzy bee with a lit head. -- hum (Opus second pass). Tag "hum" (Hum: charm that also calms). Keeps Haiku's idea (two beamed notes) but gives
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
local BOUNCE = "#4aa0a8"
local GOLDI = { "#a8601e", "#f0b23a", "#ffe28a" }

-- calming wavelets under each head (drawn first, behind): one smooth sine each, bright middle, softer ends
do
  local tok = O.tok("wave")
  for i, w in ipairs{ { 6, 57, 21, 0.6 }, { 31, 51, 17, 2.4 } } do
    local py
    for x = w[1], w[1] + w[3] do
      local f = (x - w[1]) / w[3]
      local y = w[2] + floor(sin((x - w[1]) * 0.45 + w[4]) * 1.25 + .5)
      local col = (f > 0.2 and f < 0.8) and SKY[3] or SKY[2]
      c:put(x, y, col, tok)
      if py and abs(y - py) > 1 then c:put(x, floor((y + py) / 2), col, tok) end
      py = y
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
    -- bounce line: a cool reflected light one pixel inside the dark lower-right rim
    H[1]:each(function(x, y)
      if H[1]:has(x + 1, y + 1) and not H[1]:has(x + 2, y + 2) and (x - H[3]) + (y - H[4]) > 7 then c:put(x, y, BOUNCE, tok) end
    end)
    c:put(H[3], H[4], JADE[6], tok) c:put(H[3] + 1, H[4], JADE[6], tok) c:put(H[3], H[4] + 1, JADE[5], tok)
    -- rim light on the upper-left edge of the head
    H[1]:each(function(x, y) if (not H[1]:has(x - 1, y) or not H[1]:has(x, y - 1)) and (x - H[3]) + (y - H[4]) < -1 and (x - H[3]) + (y - H[4]) > -6 then c:put(x, y, JADE[5], tok) end end)
  end
  -- jade mottling: soft pale clouds and dark veins inside the stone (hash, only on mid tones)
  local all = bars:copy():add(h1):add(h2)
  all:each(function(x, y)
    local k = K(x, y)
    local cur = c.pix[y * c.w + x]
    if cur == JADE[3] or cur == JADE[4] then
      local h = O.hash(floor(x / 2), floor(y / 2), 11)
      local g = O.hash(x, y, 3)
      if h > 0.78 and g > 0.35 then c:put(x, y, cur == JADE[3] and "#35a098" or "#5cc8b6", tok)
      elseif h < 0.12 and g > 0.5 then c:put(x, y, cur == JADE[3] and "#24767c" or "#349e98", tok) end
    end
  end)
  -- gold inlay line along the beam's middle, with a tiny lit stud at each end
  for x = 26, 44 do
    local yt = 22 + (21 - x) * 8 / 27
    local y = floor(yt + 2.6 + .5)
    if beam:has(x, y) then c:put(x, y, (x % 5 == 0) and GOLDI[3] or GOLDI[2], tok) if beam:has(x, y + 1) then c:put(x, y + 1, GOLDI[1], tok) end end
  end
end

-- quirk: a fat fuzzy bumblebee perched on the beam, humming along
do
  local tok = O.tok("bee")
  local FUZZ = { "#6e3a1c", "#c07420", "#f0b02c", "#ffd860", "#fff0b0" }
  local DK = { "#2e2030", "#4a3440", "#6a4c50" }
  -- wings first (behind): two slim glassy wings swept back, lit edge, cool lower edge, one vein
  for _, W in ipairs{ { 32.5, 5.5, 3.2, 1.5, 0.55 }, { 37, 5, 2.4, 1.3, -0.25 } } do
    local wm = O.oval(W[1], W[2], W[3], W[4], W[5])
    wm:each(function(x, y)
      local col = "#d4eef8"
      if not wm:has(x - 1, y) or not wm:has(x, y - 1) then col = SKY[3] elseif not wm:has(x + 1, y) or not wm:has(x, y + 1) then col = SKY[1] end
      c:put(x, y, col, tok)
    end)
  end
  c:put(32, 5, SKY[1], tok) c:put(33, 6, SKY[1], tok)
  -- body
  local body, bn = O.oval(36, 12.5, 5.2, 3.7)
  local bidx = O.shade(c, body, bn, FUZZ, { tok = tok, amb = 0.2, cuts = { 0.25, 0.45, 0.66, 0.86 } })
  -- two dark fur bands following the body's curve (lit on top, darker underneath)
  body:each(function(x, y)
    if x == 33 or x == 34 or x == 38 then
      c:put(x, y, (y < 11) and DK[3] or ((y < 14) and DK[2] or DK[1]), tok)
    end
  end)
  -- fuzz: ragged lit pixels on the top edge, stinger tip
  for _, p in ipairs{ { 35, 8 }, { 39, 9 }, { 31, 10 } } do c:put(p[1], p[2], FUZZ[4], tok) end
  c:put(30, 13, DK[1], tok)
  -- head: dark plush with a lit crown, big eye glint, rosy cheek
  local head, hn = O.oval(42.5, 12, 2.6, 2.6)
  head:each(function(x, y) local d = (x - 42.5) + (y - 12) c:put(x, y, d < -1.5 and DK[3] or (d < 1.5 and DK[2] or DK[1]), tok) end)
  c:put(43, 11, "#fff4d6", tok) c:put(43, 12, "#5a3a4a", tok) c:put(44, 13, "#e88aa4", tok)
  -- antennae with knobbed tips
  c:put(42, 9, DK[2], tok) c:put(42, 8, DK[2], tok) c:put(41, 7, DK[3], tok)
  c:put(45, 9, DK[2], tok) c:put(46, 8, DK[2], tok) c:put(47, 7, DK[3], tok)
  -- little legs gripping the beam
  c:put(36, 16, DK[1], tok) c:put(39, 16, DK[1], tok)
  -- hum arcs off its wings
  c:put(28, 4, SKY[2], tok) c:put(27, 5, SKY[2], tok) c:put(27, 6, SKY[3], tok) c:put(27, 7, SKY[2], tok)
end

O.save(c, "hum")
