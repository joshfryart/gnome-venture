-- cloak.lua: Maplewold (NA) cloak concepts 1-5. See concepts.md.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local N = dofile(DIR .. "/common.lua")
local W, HP, X, K, R, G = N.W, N.HP, N.X, N.K, N.R, N.G
local ink, cream = W.ink, W.cream
local only = app.params.only
local floor, max, min, abs = math.floor, math.max, math.min, math.abs

---------------------------------------------------------------- 1 maple mantle
local function mantle()
  local c = N.canvas("cloak-1-maple-mantle")
  -- dome over the shoulders, hem cut into five maple-leaf points
  local pts = { {25,12}, {39,12}, {50,18}, {57,28} }
  local segs = { 52, 42, 32, 22, 12 }
  local hem = {}
  for _, mx in ipairs(segs) do
    local base = 37 - abs(mx - 32) * 0.15
    for _, p in ipairs({ {5,-1}, {4.5,4}, {2.5,2}, {1.5,1.5}, {0.5,8}, {-0.5,8}, {-1.5,1.5}, {-2.5,2}, {-4.5,4}, {-5,-1} }) do
      hem[#hem + 1] = { mx + p[1], base + p[2] }
    end
  end
  for _, p in ipairs(hem) do pts[#pts + 1] = p end
  pts[#pts + 1] = { 6, 33 } pts[#pts + 1] = { 7, 28 } pts[#pts + 1] = { 14, 18 }
  local m = c:poly(pts)
  local idx = N.lay(c, m, N.maple, 0, { R = 6, hs = 0.6 })
  -- fade to autumn orange towards the hem
  m:each(function(x, y) if y > 32 then c:put(x, y, R.autumn[max(1, min(6, idx[K(x, y)] + (y > 37 and 0 or -1)))]) end end)
  -- leaf veins: a midrib into each centre point and two side ribs
  for _, mx in ipairs(segs) do
    local base = floor(37 - abs(mx - 32) * 0.15)
    local x = floor(mx)
    for y = base - 6, base + 6 do if m:has(x, y) then c:put(x, y, (y > 32) and R.autumn[2] or N.maple[2]) end end
    W.put(c, { {x - 1, base + 1}, {x - 2, base + 2}, {x - 3, base + 3}, {x + 1, base + 1}, {x + 2, base + 2}, {x + 3, base + 3} }, R.autumn[3])
  end
  -- segment notches between leaves
  for _, mx in ipairs({ 47, 37, 27, 17 }) do
    local base = floor(37 - abs(mx - 32) * 0.15)
    for y = base - 4, base - 1 do if m:has(mx, y) then c:put(mx, y, N.maple[2]) end end
  end
  -- stand collar
  local col = c:rrect(23, 7, 41, 14, 3)
  W.sep(c, col, m, ink)
  N.lay(c, col, N.maple, -1, { R = 2 })
  c:fillMask(c:ellipse(32, 9, 6, 1.6), N.maple[1])
  -- quirk: maple seed helicopter pinned at the throat
  W.put(c, { {31,15}, {32,15}, {31,16}, {32,16} }, R.wood[3]) c:put(31, 15, R.wood[5])
  local w1 = c:poly{ {33,15}, {38,11}, {43,10}, {42,14}, {34,17} }
  local w2 = c:poly{ {30,15}, {25,11}, {20,10}, {21,14}, {29,17} }
  for _, wg in ipairs({ w1, w2 }) do
    W.sep(c, wg, m:copy():add(col), ink)
    N.lay(c, wg, R.lining, 1, { R = 1 })
  end
  W.put(c, { {35,15}, {37,14}, {39,13}, {41,12} }, R.lining[3]) W.put(c, { {28,15}, {26,14}, {24,13}, {22,12} }, R.lining[3])
  -- pop
  c:put(16, 21, N.maple[6]) c:put(17, 21, N.maple[6]) c:put(18, 20, N.maple[6])
  N.save(c, "cloak-1-maple-mantle")
end

---------------------------------------------------------------- 2 birch poncho
local function poncho()
  local c = N.canvas("cloak-2-birch-poncho")
  local m = c:poly{ {22,10}, {42,10}, {60,42}, {32,60}, {4,42} }
  local idx = N.lay(c, m, N.birch, 0, { R = 7, hs = 0.6 })
  -- woven texture
  W.retone(c, m, idx, N.birch, function(x, y) if (x + y) % 4 == 0 and X.hash(x, y, 3) < 0.6 then return -1 end end)
  -- chevron bands following the lower edges
  m:each(function(x, y)
    local d = 60 - y - abs(x - 32) * 0.64
    if (d >= 6 and d < 9) or (d >= 11 and d < 12) then
      c:put(x, y, N.dkcheck[max(1, min(6, idx[K(x, y)] - 1))])
    elseif d >= 9 and d < 11 then c:put(x, y, N.maple[max(2, min(5, idx[K(x, y)] - 1))]) end
  end)
  -- centre fold
  for y = 18, 58 do if m:has(32, y) then c:put(32, y, N.birch[max(1, (y > 40) and 2 or 3)]) end end
  -- neck opening with a rolled edge
  local neck = c:ellipse(32, 12, 7, 3)
  local roll = c:ellipse(32, 12, 9, 4.5):cut(neck)
  N.lay(c, roll, N.birch, 1, { R = 1.5 })
  c:fillMask(neck, R.felt[1]) W.hline(c, 27, 37, 13, R.felt[2])
  -- corner tassels
  for _, t in ipairs({ {4,43}, {60,43}, {32,61} }) do
    local tm = c:rect(t[1] - 1, t[2], t[1] + 1, t[2] + 2)
    c:fillMask(tm, N.dkcheck[3]) c:put(t[1] - 1, t[2], N.dkcheck[5]) c:put(t[1], t[2] + 2, N.dkcheck[2])
  end
  -- quirk: a chickadee perched on the left shoulder
  local body = c:ellipse(15, 14, 5, 3.6)
  local head = c:ellipse(10, 9, 3.4, 3.4)
  local tail = c:poly{ {18,12}, {26,8}, {25,12}, {19,16} }
  local bird = body:copy():add(head):add(tail)
  W.sep(c, bird, m:copy():add(roll), ink)
  N.lay(c, tail, R.steel, -1, { R = 1 })
  N.lay(c, body, R.steel, 0, { R = 2 })
  -- buff flank + pale belly
  W.put(c, { {12,16}, {13,17}, {14,17}, {15,17}, {16,17}, {17,16} }, R.lining[5])
  W.put(c, { {11,14}, {12,15}, {11,15} }, N.snow[5])
  -- wing feathers
  W.put(c, { {16,12}, {17,12}, {18,13}, {16,14}, {17,14} }, R.steel[2])
  -- head: black cap and bib, white cheek
  N.lay(c, head, N.snow, 1, { R = 1 })
  head:each(function(x, y) if y <= 8 then c:put(x, y, N.dkcheck[1]) end end)
  W.put(c, { {9,11}, {10,11}, {9,12}, {10,12}, {11,12} }, N.dkcheck[1])
  c:put(10, 7, N.dkcheck[4]) c:put(9, 9, N.dkcheck[1])
  W.put(c, { {6,9}, {7,9} }, R.wood[2])
  W.put(c, { {14,18}, {15,18} }, R.wood[1])
  N.save(c, "cloak-2-birch-poncho")
end

---------------------------------------------------------------- 3 northern lights cloak
local function northern()
  local c = N.canvas("cloak-3-northern-lights-cloak")
  local body = c:poly{ {22,17}, {42,17}, {50,34}, {56,58}, {44,61}, {32,62}, {20,61}, {8,58}, {14,34} }
  local hood = c:ellipse(32, 14, 10, 10):add(c:poly{ {24,8}, {32,0}, {40,8} })
  local gap = c:poly{ {31,24}, {33,24}, {37,62}, {27,62} }
  local bi = N.lay(c, body, N.navy, 0, { R = 6, hs = 0.7 })
  -- long drape folds
  for _, f in ipairs({ { 22, 16 }, { 42, 48 }, { 26, 22 } }) do
    for y = 30, 60 do local x = floor(f[1] + (f[2] - f[1]) * (y - 30) / 30 + .5) if body:has(x, y) then c:put(x, y, N.navy[2]) end end
  end
  -- aurora border along the hem and front edges
  local edge = HP.mask()
  body:each(function(x, y)
    local nearHem = not body:has(x, y + 3)
    local nearGap = gap:grow(3):has(x, y) and not gap:has(x, y)
    if nearHem or nearGap then edge:set(x, y) end
  end)
  edge:each(function(x, y)
    local w = math.sin(x * 0.5 + y * 0.35)
    local i = max(1, min(6, bi[K(x, y)] + (w > 0.3 and 1 or 0)))
    c:put(x, y, (w > -0.2) and N.aurora[i] or R.yarnB[i])
  end)
  -- front opening: dark lining
  c:fillMask(gap, N.navy[1])
  gap:each(function(x, y) if not gap:has(x - 1, y) then c:put(x, y, N.dkcheck[1]) end end)
  -- hood
  W.sep(c, hood, body, ink)
  local hi = N.lay(c, hood, N.navy, 0, { R = 4 })
  local face = c:ellipse(32, 16, 6, 6)
  c:fillMask(face, N.navy[1])
  face:each(function(x, y) if not face:has(x, y - 1) then c:put(x, y, N.dkcheck[1]) end end)
  -- aurora rim round the face
  face:grow(1):cut(face):each(function(x, y) if hood:has(x, y) then c:put(x, y, (x < 32) and N.aurora[5] or N.aurora[3]) end end)
  -- quirk: snowflake clasp at the throat
  local cx, cy = 32, 25
  local fl = { {0,-3}, {0,-2}, {0,-1}, {0,0}, {0,1}, {0,2}, {0,3}, {-3,0}, {-2,0}, {-1,0}, {1,0}, {2,0}, {3,0}, {-2,-2}, {2,2}, {2,-2}, {-2,2}, {-1,-1}, {1,1}, {1,-1}, {-1,1} }
  local fm = HP.mask() for _, p in ipairs(fl) do fm:set(cx + p[1], cy + p[2]) end
  W.sep(c, fm, body:copy():add(hood), ink)
  for _, p in ipairs(fl) do c:put(cx + p[1], cy + p[2], (p[1] + p[2] < 0) and N.snow[6] or N.snow[4]) end
  c:put(cx, cy, N.snow[3])
  -- stars? no: a soft gloss on the hood
  W.put(c, { {26,8}, {27,7}, {28,6} }, N.navy[6])
  N.save(c, "cloak-3-northern-lights-cloak")
end

---------------------------------------------------------------- 4 harbour slicker cape
local function slicker()
  local c = N.canvas("cloak-4-harbour-slicker-cape")
  local body = c:poly{ {22,22}, {42,22}, {54,40}, {58,53}, {32,56}, {6,53}, {10,40} }
  local bi = N.lay(c, body, N.slicker, 0, { R = 6, hs = 0.7 })
  -- waxed creases
  for _, f in ipairs({ { 20, 12 }, { 44, 52 } }) do
    for y = 34, 54 do local x = floor(f[1] + (f[2] - f[1]) * (y - 34) / 20 + .5) if body:has(x, y) then c:put(x, y, N.slicker[2]) end end
  end
  -- front opening, edges turned back to show the blue lining
  local lapL = c:poly{ {28,26}, {32,26}, {30,55}, {24,55} }
  local lapR = c:poly{ {32,26}, {36,26}, {40,55}, {34,55} }
  N.lay(c, lapL, R.jay, 1, { R = 1.5 }) N.lay(c, lapR, R.jay, 0, { R = 1.5 })
  W.vline(c, 32, 26, 55, N.slicker[1])
  W.put(c, { {31,40}, {32,40}, {33,40} }, R.jay[1])
  N.bottom(body, function(x, y) if not lapL:has(x, y) and not lapR:has(x, y) then c:put(x, y, N.slicker[2]) end end)
  -- toggles
  for _, ty in ipairs({ 31, 39 }) do
    local t = c:rrect(29, ty, 35, ty + 2, 1)
    W.lit(c, t, R.wood, { R = 1 }) c:put(29, ty, R.wood[6])
  end
  -- hood with a broad sou'wester brim
  local brim = c:ellipse(32, 20, 17, 5)
  local hood = c:ellipse(32, 12, 10, 9)
  W.sep(c, brim, body, ink)
  N.lay(c, brim, N.slicker, 0, { R = 2 })
  N.bottom(brim, function(x, y) c:put(x, y, N.slicker[2]) end)
  W.sep(c, hood, brim, N.slicker[1])
  N.lay(c, hood, N.slicker, 1, { R = 4 })
  -- dark face under the brim
  local face = c:ellipse(32, 20, 8, 2.6)
  c:fillMask(face, R.jay[1]) W.hline(c, 26, 38, 19, N.dkcheck[1])
  -- hood seam + chin strap
  W.vline(c, 32, 4, 15, N.slicker[2])
  -- quirk: silver fish charm hanging from the top toggle
  W.vline(c, 36, 33, 35, R.steel[3])
  local fish = c:poly{ {35,36}, {41,37}, {43,35}, {43,40}, {41,38}, {35,39}, {34,37.5} }
  W.sep(c, fish, body:copy():add(lapR), ink)
  N.lay(c, fish, R.steel, 1, { R = 1 })
  c:put(36, 37, ink) c:put(37, 36, R.steel[6])
  -- gloss streaks on the oilskin
  W.put(c, { {16,34}, {17,33}, {18,32}, {14,38} }, N.slicker[6]) c:put(17, 33, cream)
  W.put(c, { {24,7}, {25,6}, {26,5} }, N.slicker[6])
  N.save(c, "cloak-4-harbour-slicker-cape")
end

---------------------------------------------------------------- 5 pine-needle shawl
local function shawl()
  local c = N.canvas("cloak-5-pine-needle-shawl")
  -- big triangle, top edge gently curved; lace scallops on the two lower edges
  local m = c:poly{ {3,12}, {32,15}, {61,12}, {32,50} }
  local function eL(y) return 3 + (y - 12) * 29 / 38 end
  local function eR(y) return 61 - (y - 12) * 29 / 38 end
  local lace = HP.mask()
  for i = 0, 8 do
    local t = (i + 0.5) / 9
    local y = 12 + t * 38
    lace:add(c:ellipse(eL(y) - 0.5, y + 1, 2.2, 2.2)):add(c:ellipse(eR(y) + 0.5, y + 1, 2.2, 2.2))
  end
  lace:cut(m)
  local all = m:copy():add(lace)
  local idx = N.lay(c, m, N.pine, 0, { R = 7, hs = 0.6 })
  -- knit chevrons (pine needle / feather stitch)
  m:each(function(x, y)
    local v = (y - abs(x - 32) * 0.45) % 5
    if v < 1 then c:put(x, y, N.pine[max(1, idx[K(x, y)] - 1)]) end
  end)
  -- lace edging + eyelets
  N.lay(c, lace, N.pine, 1, { R = 1 })
  for i = 0, 8 do
    local y = floor(12 + (i + 0.5) / 9 * 38)
    c:put(floor(eL(y) + 3), y, N.pine[1]) c:put(floor(eR(y) - 3), y, N.pine[1])
  end
  -- top edge band, rolled
  for x = 3, 61 do
    local y = floor(12 + (1 - ((x - 32) / 29) ^ 2) * 3 + 0.5)
    if all:has(x, y) then c:put(x, y, N.pine[5]) end
    if all:has(x, y + 1) then c:put(x, y + 1, N.pine[3]) end
  end
  -- quirk: pinecone tassel at the point
  W.vline(c, 32, 51, 53, R.lining[3])
  local cone = c:ellipse(32, 57.5, 3, 4)
  W.lit(c, cone, R.felt, { R = 2 })
  W.put(c, { {31,55}, {33,56}, {31,57}, {33,58}, {31,59}, {33,60}, {32,61} }, R.felt[1])
  W.put(c, { {30,55}, {30,57}, {31,54} }, R.felt[6])
  -- wool pop
  c:put(10, 16, N.pine[6]) c:put(11, 16, N.pine[6])
  N.save(c, "cloak-5-pine-needle-shawl")
end

local all = { mantle, poncho, northern, slicker, shawl }
for i, f in ipairs(all) do if not only or tonumber(only) == i then f() end end
