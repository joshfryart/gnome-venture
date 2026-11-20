-- small-sign kit (pass 2, SMALLER) for tool_shed, compost_bin, rain_barrel, root_cellar
dofile("/tmp/ase/states2/_sk4_kit.lua")

-- small flat cleared patch: 3 earth tones, dark rim, a 1 px cut on the far edge, a few furrow dashes
function smallPlot(x0, y0, x1, y1, seed)
  local m = HP.mask()
  local cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
  local ax, ay = (x1 - x0) / 2 + .5, (y1 - y0) / 2 + .5
  for y = y0, y1 do for x = x0, x1 do
    local u, v = (x - cx) / ax, (y - cy) / ay
    if u ^ 4 + v ^ 4 < 1 then m:set(x, y) end
  end end
  c:fillMask(m, EARTH.base)
  local inner = m:shrink(1)
  inner:each(function(x, y)
    local h = hsh(x * 5 + seed, y * 3 + seed)
    if (y - y0) % 3 == 2 and h < 30 then px(x, y, EARTH.shade)
    elseif (y - y0) % 3 == 1 and h > 88 then px(x, y, EARTH.hi) end
  end)
  m:edge():each(function(x, y) px(x, y, EARTH.rim) end)
  m:each(function(x, y) if not m:has(x, y - 1) then px(x, y, EARTH.cut) end end)
  return m
end

-- four little corner stakes and the cream string (h = stake height)
function smallFootprint(x0, yb, x1, yf, h)
  footprint({ { x0 + 1, yb }, { x1 - 1, yb }, { x1, yf }, { x0, yf } }, h)
end

-- glyph painter: rows of chars, map char -> colour; ink outline round the whole glyph
function glyph(rows, x, y, map)
  local m = HP.mask()
  for r = 1, #rows do for q = 1, #rows[r] do if rows[r]:sub(q, q) ~= "." then m:set(x + q - 1, y + r - 1) end end end
  ink(m)
  for r = 1, #rows do for q = 1, #rows[r] do
    local ch = rows[r]:sub(q, q); if ch ~= "." then px(x + q - 1, y + r - 1, map[ch]) end
  end end
  return m
end
