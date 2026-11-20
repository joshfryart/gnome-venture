-- shared kit for the BUILD-sign pass of tool_shed, compost_bin, rain_barrel, root_cellar (empty state only)
dofile("/tmp/ase/states2/kit_tc.lua")   -- globals: HP, P, c, px, R, E, lerp, hsh, ink, flower, pebble, SHD_A, SHD_B, DUSKSH ...
SF = dofile("/tmp/ase/states2/signfont.lua")
function word(x, y, col, sh) SF.text(px, x, y, col, sh) end

EARTH = { hi = P.wood.base, base = P.wood.shade, shade = lerp(P.wood.shade, P.wood.deep, .5), rim = P.wood.deep, cut = "#3a2430" }

function shadeUnder(m, t)
  m:each(function(x, y) local v = c:get(x, y); if v then px(x, y, lerp(v, DUSKSH, t)) end end)
end

-- cleared, raked, flush patch of earth: 3 tones, a dark cut rim, a 2 px cut face on the far edge
function plot(x0, y0, x1, y1, seed)
  local m = HP.mask()
  local cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
  local ax, ay = (x1 - x0) / 2 + .5, (y1 - y0) / 2 + .5
  for y = y0, y1 do for x = x0, x1 do
    local u, v = (x - cx) / ax, (y - cy) / ay
    local d = u ^ 4 + v ^ 4
    local j = (hsh(x // 3 + seed, y // 2 + seed) % 12) / 100
    if d < 1 - j then m:set(x, y) end
  end end
  c:fillMask(m, EARTH.base)
  local inner = m:shrink(2)
  -- raked furrows (short dark dashes on every third row) and lit clods (upper-left of each clod)
  inner:each(function(x, y)
    local h = hsh(x * 7 + seed, y * 3 + seed)
    if (y - y0) % 3 == 1 and h < 38 then px(x, y, EARTH.shade)
    elseif (y - y0) % 3 == 0 and h > 90 then px(x, y, EARTH.hi); if inner:has(x + 1, y) then px(x + 1, y, EARTH.hi) end; if inner:has(x + 1, y + 1) then px(x + 1, y + 1, EARTH.shade) end end
  end)
  -- rim: dark cut edge all round, a 2 px cut face along the far (top) edge
  m:edge():each(function(x, y) px(x, y, EARTH.rim) end)
  m:each(function(x, y)
    if not m:has(x, y - 1) then px(x, y, EARTH.cut); if m:has(x, y + 1) then px(x, y + 1, EARTH.rim) end end
  end)
  return m
end

-- grass tuft overlapping the rim (blends the plot into the lawn)
function tuft(x, y, flip)
  local m = HP.mask():set(x - 1, y):set(x, y):set(x + 1, y):set(x, y - 1):set(x - 1, y - 1)
  if flip then m:set(x + 1, y - 2) else m:set(x - 1, y - 2) end
  ink(m)
  c:fillMask(m, P.moss.base)
  px(x - 1, y, P.moss.shade); px(x, y, P.moss.shade); px(x + 1, y, P.moss.shade)
  if flip then px(x + 1, y - 2, P.moss.hi) else px(x - 1, y - 2, P.moss.hi) end
end

-- corner stake: 1 px wood post, ink rim, lit top, pointed into the ground
function cstake(x, ytop, yb)
  local m = c:rect(x, ytop, x, yb)
  ink(m)
  c:fillMask(m, P.wood.base); px(x, ytop, P.wood.hi); px(x, yb, P.wood.shade)
  px(x + 1, yb + 1, lerp(EARTH.base, DUSKSH, .45))   -- tiny cool shadow
end
-- footprint string: cream line joining 4 stake tops (pts = {BL, BR, FR, FL}), then the stakes over it
function footprint(pts, h)
  for i = 1, 4 do
    local a, b = pts[i], pts[i % 4 + 1]
    c:fillMask(c:line({ { a[1], a[2] - h + 1 }, { b[1], b[2] - h + 1 } }, 1), P.cream)
  end
  -- string sag shadow on the earth, one row lower and only on the front run
  for i = 1, 4 do local p = pts[i]; cstake(p[1], p[2] - h, p[2]) end
end

function daisy(x, y) flower(x, y, P.cream) end
function chip(x, y, col) px(x, y, col or P.wood.hi); px(x + 1, y, col or P.wood.hi) end

-- plate with visible thickness: depth = mask shifted (1,1); returns depth mask
function slab(M, faceCol, depthCol)
  local D = M:copy():shift(1, 1):cut(M)
  ink(M, D)
  c:fillMask(D, depthCol)
  c:fillMask(M, faceCol)
  return D
end

function saveEmpty(frames, W, H, out, b)
  for _, f in ipairs(frames) do HP.assertClean(f) end
  HP.sheet{ cellw = W, cellh = H, frames = frames, tags = { { name = "empty", from = 1, to = 4 } } }
    :save{ aseprite = out .. b .. "-empty.aseprite", png = out .. b .. "-empty.png", scale = 1 }
end
