-- EE coats: 5 concepts (see concepts.md). Run: AppRun -b --script-param png=<dir>/ --script coat.lua
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R = C.HP, C.X, C.K, C.R
local floor, max, min, abs = math.floor, math.max, math.min, math.abs

-- sleeves as tubes from shoulder to wrist (left, right), painted behind the body
local OCHRE = { "#5a2e1c", "#84461e", "#aa6626", "#c88a34", "#dcaa4c", "#ecca74" }
local function sleeves(c, ramp, l, r, w, o)
  o = o or {}
  local ml, il = C.tube(c, l, function(t) return w + t * (o.flare or 0) end, ramp, { bias = o.bias })
  local mr, ir = C.tube(c, r, function(t) return w + t * (o.flare or 0) end, ramp, { bias = (o.bias or 0) - 1 })
  if o.tex then C.retone(c, ml, il, ramp, o.tex) C.retone(c, mr, ir, ramp, o.tex) end
  return ml, mr
end

---------------------------------------------------------------- 1 sheepskin longcoat
if C.want("coat-1") then
  local c = C.new("coat-1-sheepskin-longcoat")
  local body = c:poly{ {22, 7}, {42, 7}, {47, 13}, {52, 57}, {12, 57}, {17, 13} }
  local sl, sr = sleeves(c, R.leather, { {19, 12}, {13, 20}, {10, 30}, {9, 41} }, { {45, 12}, {51, 20}, {54, 30}, {55, 41} }, 4.5, { flare = 1 })
  local cuffL = c:ellipse(9, 42, 6, 3.5)
  local cuffR = c:ellipse(55, 42, 6, 3.5)
  C.sep(c, body, sl:copy():add(sr), C.ink)
  local bi = C.part(c, body, R.leather, { R = 5, cuts = { .2, .36, .52, .7, .9 } })
  -- front opening + hem fleece band
  for y = 14, 51 do c:put(32, y, R.leather[1]) c:put(33, y, R.leather[3]) end
  local hem = body:copy():clip(c:rect(0, 52, 64, 64)):add(c:rrect(11, 51, 53, 58, 2))
  local fleece = function(x, y, i) if (x + (floor(y / 2) % 2) * 2) % 4 == 0 then return -1 elseif (x + y) % 4 == 1 then return 1 end end
  C.part(c, hem, R.fleece, { R = 2, tex = fleece })
  C.part(c, cuffL:copy():add(cuffR), R.fleece, { R = 2, tex = fleece })
  -- big shawl collar, crossing into a V
  local collar = c:poly{ {17, 6}, {47, 6}, {44, 14}, {33, 28}, {31, 28}, {20, 14} }:cut(c:poly{ {24, 9}, {40, 9}, {32, 20} })
  C.ring(c, collar, R.leather[1], body)
  C.part(c, collar, R.fleece, { R = 3, tex = fleece })
  local neck = c:poly{ {24, 9}, {40, 9}, {32, 20} }
  C.fill(c, neck, R.leather[1]) C.dots(c, { {28, 10}, {29, 10}, {30, 10} }, R.sole[3])
  -- wooden toggles
  for _, ty in ipairs({ 33, 40, 47 }) do
    local t = c:rrect(29, ty, 36, ty + 2, 1)
    C.part(c, t, R.wood, { R = 1 })
    c:put(30, ty, R.wood[6])
    c:put(37, ty + 1, R.leather[1])
  end
  -- side seams / pockets
  C.dots(c, { {18, 40}, {19, 40}, {20, 40}, {21, 40}, {22, 40}, {23, 40} }, R.leather[2])
  C.dots(c, { {41, 40}, {42, 40}, {43, 40}, {44, 40}, {45, 40}, {46, 40} }, R.leather[1])
  -- quirk: a small red flower stitched on the chest
  C.dots(c, { {41, 23}, {40, 24}, {42, 24}, {41, 25} }, R.ember[4])
  c:put(41, 24, R.brass[5]) C.dots(c, { {41, 26}, {41, 27} }, R.leaf[3]) c:put(42, 27, R.leaf[4])
  -- hide pop
  C.dots(c, { {19, 20}, {19, 21}, {20, 22} }, R.leather[6])
  C.save(c, "coat-1-sheepskin-longcoat")
end

---------------------------------------------------------------- 2 stitched felt vest
if C.want("coat-2") then
  local c = C.new("coat-2-stitched-felt-vest")
  local body = c:poly{ {18, 6}, {25, 6}, {32, 26}, {39, 6}, {46, 6}, {47, 16}, {52, 22}, {52, 50}, {46, 56}, {33, 52}, {31, 52}, {18, 56}, {12, 50}, {12, 22}, {17, 16} }
  -- back panel visible through the neck V
  local backp = c:poly{ {25, 6}, {39, 6}, {32, 26} }
  C.fill(c, backp, R.plum[1]) C.dots(c, { {28, 8}, {29, 8}, {30, 8}, {31, 8}, {32, 8}, {33, 8} }, R.plum[2])
  C.sep(c, body, backp, C.ink)
  local felt = function(x, y, i) local h = C.hash(x, y, 9) if h < .1 then return -1 elseif h > .95 then return 1 end end
  C.part(c, body, R.plum, { R = 5, tex = felt, cuts = { .2, .36, .52, .7, .9 } })
  -- armhole shading (curved inner edge)
  for y = 16, 24 do c:put(12 + floor((24 - y) / 3), y, R.plum[1]) c:put(52 - floor((24 - y) / 3), y, R.plum[1]) end
  -- front opening
  for y = 27, 51 do c:put(32, y, R.plum[1]) end
  -- embroidered border: vine of flowers along both front edges and the hem
  local function flower(x, y, ramp)
    C.dots(c, { {x, y - 1}, {x - 1, y}, {x + 1, y}, {x, y + 1} }, ramp[4])
    c:put(x, y, R.brass[5]) c:put(x - 1, y - 1, ramp[6])
  end
  local function vine(pts)
    local m = c:line(pts, 1)
    m:each(function(x, y) c:put(x, y, R.leaf[4]) end)
  end
  vine{ {26, 9}, {30, 20}, {30, 50} } vine{ {38, 9}, {34, 20}, {34, 50} }
  for i, y in ipairs({ 14, 22, 30, 38, 46 }) do
    local lx = (y < 22) and (26 + floor((y - 9) * 4 / 11)) or 30
    local rx = (y < 22) and (38 - floor((y - 9) * 4 / 11)) or 34
    flower(lx - 1, y, (i % 2 == 0) and R.yarnB or R.ember)
    flower(rx + 1, y + 4, (i % 2 == 0) and R.ember or R.yarnB)
    c:put(lx + 1, y + 2, R.leaf[5]) c:put(rx - 1, y + 2, R.leaf[3])
  end
  -- hem border band
  for x = 14, 50 do
    local y = (x < 32) and (51 + floor((32 - x) / 3)) or (51 + floor((x - 32) / 3))
    if body:has(x, y - 1) then c:put(x, y - 1, (x % 4 == 0) and R.brass[4] or R.yarnA[3]) end
  end
  -- quirk: embroidered sunflower on the left pocket
  local pk = c:rrect(16, 36, 25, 45, 1)
  for x = 16, 25 do c:put(x, 36, R.plum[1]) end
  local sf = c:ellipse(20.5, 40.5, 3, 3)
  C.fill(c, sf, R.brass[4])
  C.dots(c, { {18, 38}, {19, 38}, {18, 39} }, R.brass[6])
  C.dots(c, { {20, 40}, {21, 40}, {20, 41}, {21, 41} }, R.wood[2]) c:put(20, 40, R.wood[4])
  C.dots(c, { {23, 43}, {24, 44} }, R.leaf[4])
  -- shoulder seams
  C.dots(c, { {18, 7}, {19, 7}, {20, 7}, {21, 7}, {22, 7}, {23, 7} }, R.plum[6])
  C.dots(c, { {41, 7}, {42, 7}, {43, 7}, {44, 7}, {45, 7} }, R.plum[4])
  C.save(c, "coat-2-stitched-felt-vest")
end

---------------------------------------------------------------- 3 red-stitch linen smock
if C.want("coat-3") then
  local c = C.new("coat-3-red-stitch-linen-smock")
  local body = c:poly{ {21, 6}, {43, 6}, {46, 12}, {49, 58}, {15, 58}, {18, 12} }
  local sl, sr = sleeves(c, R.linen, { {20, 11}, {14, 17}, {10, 26}, {9, 34} }, { {44, 11}, {50, 17}, {54, 26}, {55, 34} }, 4.5, { flare = 1.5 })
  C.sep(c, body, sl:copy():add(sr), C.ink)
  local folds = function(x, y, i) if (x == 22 or x == 41) and y > 34 then return -1 end if x == 27 and y > 40 then return -1 end end
  C.part(c, body, R.linen, { R = 5, tex = folds, cuts = { .2, .36, .52, .7, .9 } })
  -- cross-stitch band helper: rows of little x's
  local function band(x0, x1, y0, mask)
    for x = x0, x1 do
      for dy = 0, 2 do
        local yy = y0 + dy
        if not mask or mask:has(x, yy) then
          local on = ((x - x0) % 4 == dy) or ((x - x0) % 4 == 2 - dy and dy ~= 1) or (dy == 1 and (x - x0) % 4 == 1)
          if on then c:put(x, yy, R.ember[(dy == 0) and 4 or 3]) end
        end
      end
      if not mask or mask:has(x, y0 - 1) then c:put(x, y0 - 1, R.ember[2]) end
    end
  end
  -- neck slit and collar band
  local neck = c:ellipse(32, 7, 5, 2):clip(body)
  C.fill(c, neck, R.linen[1])
  for y = 8, 20 do c:put(32, y, R.linen[1]) end
  for y = 9, 19 do c:put(30, y, R.ember[4]) c:put(34, y, R.ember[3]) if y % 2 == 0 then c:put(29, y, R.ember[3]) c:put(35, y, R.ember[2]) end end
  band(20, 44, 9, body)
  -- cuffs
  band(2, 16, 33, sl) band(48, 62, 33, sr)
  -- hem band
  band(15, 49, 53, body)
  -- woven sash at the waist with tassels
  local sash = c:rect(16, 30, 48, 34):clip(body:copy():add(c:rect(15, 30, 49, 34)))
  C.part(c, sash, R.jay, { R = 1, tex = function(x, y) if (x + y) % 3 == 0 then return -1 end end })
  for x = 16, 48 do c:put(x, 30, R.jay[5]) end
  local knot = c:rrect(21, 29, 26, 35, 1)
  C.part(c, knot, R.jay, { R = 2, bias = 1 })
  -- quirk: sash tassels hanging at the hip
  for i, tx in ipairs({ 21, 25 }) do
    local ex = tx + (i == 1 and -2 or 2)
    local t = c:line({ {tx + 1, 36}, {ex, 42} }, 1)
    C.fill(c, t, R.jay[2])
    local tf = c:poly{ {ex - 1, 42}, {ex + 2, 42}, {ex + 3, 47}, {ex - 2, 47} }
    C.part(c, tf, R.jay, { R = 1, tex = function(x, y) if x % 2 == 0 then return -1 end end })
    C.dots(c, { {ex, 42}, {ex + 1, 42} }, R.ember[4])
  end
  C.dots(c, { {19, 14}, {19, 15}, {20, 16} }, R.linen[6])
  C.save(c, "coat-3-red-stitch-linen-smock")
end

---------------------------------------------------------------- 4 quilted steppe coat
if C.want("coat-4") then
  local c = C.new("coat-4-quilted-steppe-coat")
  local body = c:poly{ {20, 9}, {44, 9}, {48, 14}, {51, 47}, {13, 47}, {16, 14} }
  local sl, sr = sleeves(c, OCHRE, { {18, 13}, {12, 20}, {9, 29}, {8, 40} }, { {46, 13}, {52, 20}, {55, 29}, {56, 40} }, 5.5)
  -- quilting on the sleeves: horizontal channels
  sl:add(sr):each(function(x, y) if y % 4 == 0 and y > 16 then c:put(x, y, OCHRE[2]) end end)
  -- quirk: teal patch on the left elbow, with stitches
  local patch = c:rrect(6, 26, 13, 32, 1):clip(sl)
  C.part(c, patch, R.yarnB, { R = 1 })
  patch:edge():each(function(x, y) if (x + y) % 2 == 0 then c:put(x, y, R.yarnB[6]) end end)
  C.sep(c, body, sl:copy():add(sr), C.ink)
  -- padded vertical channels: each column lit as a little cylinder
  local idx = C.part(c, body, OCHRE, { R = 4, cuts = { .22, .4, .56, .72, .9 } })
  C.retone(c, body, idx, OCHRE, function(x, y, i)
    local lx = (x - 13) % 5
    if lx == 0 then return -2 elseif lx == 1 then return 1 elseif lx == 4 then return -1 end
  end)
  -- wrap front: diagonal overlap edge from right shoulder to left hip, with leather trim
  local trim = c:line({ {40, 11}, {28, 30}, {22, 46} }, 3)
  local under = c:poly{ {40, 11}, {28, 30}, {22, 46}, {13, 47}, {13, 10} }
  trim:clip(body):each(function(x, y) c:put(x, y, R.strap[(x + y) % 2 == 0 and 4 or 3]) end)
  local trimEdge = c:line({ {41, 11}, {29, 30}, {23, 46} }, 1):clip(body)
  trimEdge:cut(trim):each(function(x, y) c:put(x, y, OCHRE[1]) end)
  -- hem trim
  for x = 14, 50 do c:put(x, 46, R.strap[3]) c:put(x, 47, R.strap[2]) end
  -- stand collar
  local col = c:rrect(21, 5, 43, 11, 2)
  C.ring(c, col, OCHRE[1], body)
  C.part(c, col, R.strap, { R = 2 })
  local nk = c:rrect(25, 6, 39, 9, 1)
  C.fill(c, nk, R.strap[1])
  -- brass button where the wrap closes
  local bt = c:ellipse(30, 28, 1.6, 1.6)
  C.part(c, bt, R.brass, { R = 1 }) c:put(29, 27, R.brass[6])
  C.save(c, "coat-4-quilted-steppe-coat")
end

---------------------------------------------------------------- 5 hedgehog knit cardigan
if C.want("coat-5") then
  local c = C.new("coat-5-hedgehog-knit-cardigan")
  local body = c:poly{ {20, 7}, {44, 7}, {47, 13}, {49, 52}, {15, 52}, {17, 13} }
  local knit = function(x, y, i)
    -- knit v-stitches: chevrons in columns of 3
    local lx, ly = x % 3, y % 3
    if ly == 2 and lx == 1 then return -1 end
    if ly == 0 and lx ~= 1 then return -1 end
  end
  local sl, sr = sleeves(c, R.cloak, { {19, 12}, {13, 19}, {10, 29}, {9, 42} }, { {45, 12}, {51, 19}, {54, 29}, {55, 42} }, 5, { tex = knit })
  -- ribbed cuffs
  local cuffs = c:rect(3, 41, 15, 47):clip(sl):add(c:rect(49, 41, 61, 47):clip(sr))
  C.part(c, cuffs, R.cloak, { R = 1, bias = -1, tex = function(x, y) if x % 2 == 0 then return -1 else return 1 end end })
  C.sep(c, body, sl:copy():add(sr), C.ink)
  local bi = C.part(c, body, R.cloak, { R = 5, tex = knit, cuts = { .2, .36, .52, .7, .9 } })
  -- cable columns
  for _, cx in ipairs({ 22, 42 }) do
    for y = 14, 46 do
      local ph = y % 6
      local o = (ph < 3) and ph or (5 - ph)
      c:put(cx - 1 + o, y, R.cloak[6]) c:put(cx + 2 - o, y, R.cloak[2])
    end
  end
  -- ribbed hem
  local hem = c:rect(15, 47, 49, 52):clip(body)
  C.part(c, hem, R.cloak, { R = 1, bias = -1, tex = function(x, y) if x % 2 == 0 then return -1 else return 1 end end })
  -- open V front with a ribbed button band
  local vee = c:poly{ {26, 7}, {38, 7}, {32, 24} }
  C.fill(c, vee, R.linen[2]) C.dots(c, { {28, 8}, {29, 8}, {30, 8} }, R.linen[3])
  local band = c:line({ {25, 7}, {31, 25}, {31, 51} }, 2):add(c:line({ {39, 7}, {33, 25}, {33, 51} }, 2))
  band:each(function(x, y) c:put(x, y, R.cloak[(y % 2 == 0) and 3 or 4]) end)
  for y = 26, 51 do c:put(32, y, R.cloak[1]) end
  -- wooden toggles
  for _, ty in ipairs({ 28, 36, 44 }) do
    local t = c:ellipse(32, ty, 2, 1.5)
    C.part(c, t, R.wood, { R = 1 })
    c:put(31, ty - 1, R.wood[6])
  end
  -- quirk: tiny hedgehog brooch on the right chest
  local hh = c:ellipse(41, 20, 5, 3.5)
  C.ring(c, hh, R.cloak[1], body)
  C.part(c, hh, R.wood, { R = 1, bias = -1, tex = function(x, y) if (x + y) % 2 == 0 then return -1 end end })
  C.dots(c, { {37, 18}, {39, 16}, {41, 16}, {43, 16}, {45, 18}, {36, 20} }, C.ink)
  C.dots(c, { {39, 18}, {41, 17}, {43, 18} }, R.wood[5])
  local face = c:poly{ {44, 19}, {49, 22}, {44, 24} }
  C.ring(c, face, R.cloak[1], body)
  C.fill(c, face, R.lining[5]) c:put(45, 20, R.lining[6]) c:put(49, 22, C.ink) c:put(46, 21, C.ink)
  C.dots(c, { {39, 24}, {43, 24} }, R.wood[1])
  C.save(c, "coat-5-hedgehog-knit-cardigan")
end
