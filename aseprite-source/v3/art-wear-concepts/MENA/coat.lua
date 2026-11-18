-- coat.lua: MENA "Dunewhisper" coat concepts, 5 icons (see concepts.md).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local floor, sqrt, abs, min, max = math.floor, math.sqrt, math.abs, math.min, math.max
-- mirror a polygon across the vertical centre line (x -> 64 - x)
local function mir(pts) local o = {} for i = #pts, 1, -1 do o[#o + 1] = { 64 - pts[i][1], pts[i][2] } end return o end
local function both(c, pts) return c:poly(pts):add(c:poly(mir(pts))) end

---------------------------------------------------------------- 1 loom-stripe vest
do
  local c = C.new("coat-1-loom-stripe-vest")
  local L = { {19,6}, {27,4}, {31,24}, {31,55}, {13,55}, {13,28}, {16,26}, {19,22}, {20,17}, {20,11} }
  local left, right = c:poly(L), c:poly(mir(L))
  -- back of the vest seen between the open fronts (inside)
  local inside = c:poly{ {25,4}, {39,4}, {35,24}, {34,55}, {30,55}, {29,24} }
  c:fillMask(inside, R.madder[1])
  inside:each(function(x, y) if y > 30 and (x + y) % 3 == 0 then c:put(x, y, R.madder[2]) end end)
  C.hline(c, 27, 37, 5, R.madder[2])
  local function panel(m, b)
    local idx = C.lay(c, m, R.linen, { R = 4, bias = b, cuts = { .2, .36, .52, .7, .88 } })
    m:each(function(x, y)
      local i = idx[K(x, y)]
      local s = x % 7
      if s == 2 then c:put(x, y, R.madder[min(6, i)])
      elseif s == 3 then c:put(x, y, R.madder[min(6, i + 1)])
      elseif s == 5 then c:put(x, y, R.indigo[min(6, i + 1)])
      elseif y % 2 == 0 and s == 0 and X.hash(x, y, 3) < 0.5 then c:put(x, y, R.linen[max(1, i - 1)]) end
    end)
    -- woven border along the front edge and hem
    m:edge():each(function(x, y)
      if not m:has(x, y + 1) or (abs(x - 31.5) < 3 and (not m:has(x + 1, y) or not m:has(x - 1, y))) then
        c:put(x, y, R.ochre[(x < 32) and 4 or 3])
      end
    end)
  end
  panel(left, 0) panel(right, -1)
  -- armhole binding
  local ah = c:line({ {20,7}, {20,17}, {19,22}, {16,26}, {13,28} }, 1)
  ah:each(function(x, y) if left:has(x, y) then c:put(x, y, R.ochre[5]) end end)
  local ah2 = c:line({ {43,7}, {43,17}, {44,22}, {47,26}, {50,28} }, 1)
  ah2:each(function(x, y) if right:has(x, y) then c:put(x, y, R.ochre[3]) end end)
  -- quirk: single tassel on the right front corner
  C.stroke(c, { {33,55}, {33,57} }, R.ochre[2])
  local t = c:poly{ {31.5,58}, {35.5,58}, {36,63}, {31,63} }
  C.lay(c, t, R.madder, { R = 1 })
  C.vline(c, 33, 59, 62, R.madder[2]) c:put(32, 58, R.madder[6])
  C.hline(c, 32, 35, 58, R.ochre[5])
  C.save(c, "coat-1-loom-stripe-vest")
end

---------------------------------------------------------------- 2 braided cord jacket
do
  local c = C.new("coat-2-braided-cord-jacket")
  local body = c:rrect(19, 10, 45, 45, 3)
  local SL = { {22,10}, {17,12}, {9,36}, {8,44}, {16,45}, {17,38}, {21,24} }
  local slL, slR = c:poly(SL), c:poly(mir(SL))
  C.lay(c, slR, R.teal, { R = 3, bias = -1 })
  C.lay(c, slL, R.teal, { R = 3 })
  C.sep(c, body, slL:copy():add(slR), R.teal[1])
  local bi = C.lay(c, body, R.teal, { R = 5, cuts = { .22, .4, .56, .72, .88 }, tex = C.wool })
  -- neckline
  local neck = c:ellipse(32, 9, 6, 4):clip(body)
  c:fillMask(neck, R.teal[1])
  neck:each(function(x, y) if not neck:has(x, y + 1) then c:put(x, y, R.teal[2]) end end)
  -- front opening line
  C.vline(c, 32, 13, 45, R.teal[1])
  -- gold cord braid: hem, cuffs, front edges, neckline (twisted look: alternating tones)
  local braid = HP.mask()
  body:each(function(x, y) if y >= 43 then braid:set(x, y) end end)
  for y = 12, 45 do braid:set(30, y) braid:set(31, y) braid:set(33, y) braid:set(34, y) end
  slL:each(function(x, y) if y >= 41 then braid:set(x, y) end end)
  slR:each(function(x, y) if y >= 41 then braid:set(x, y) end end)
  neck:grow(1):cut(neck):clip(body):each(function(x, y) braid:set(x, y) end)
  braid:each(function(x, y)
    local tw = (x + y) % 3
    local lit = x < 32
    c:put(x, y, R.brass[tw == 0 and 2 or (lit and (tw == 1 and 5 or 4) or (tw == 1 and 4 or 3))])
  end)
  -- braid swirl loops on the chest
  for _, s in ipairs({ { 25, 22, 1 }, { 39, 22, -1 }, { 25, 32, 1 }, { 39, 32, -1 } }) do
    local ring = c:ellipse(s[1], s[2], 2.5, 2.5):cut(c:ellipse(s[1], s[2], 1.2, 1.2))
    ring:each(function(x, y) c:put(x, y, R.brass[(x + y < s[1] + s[2]) and 5 or 3]) end)
    C.stroke(c, { {s[1] + 3 * s[3], s[2]}, {s[1] + 5 * s[3], s[2]} }, R.brass[4])
  end
  -- shoulder seams
  C.stroke(c, { {21,12}, {20,26} }, R.teal[2]) C.stroke(c, { {43,12}, {44,26} }, R.teal[1])
  -- quirk: pomegranate button at the throat
  local pb = c:ellipse(32, 15, 2.4, 2.4)
  C.lay(c, pb, R.madder, { R = 1 })
  C.put(c, { {31,12}, {32,12}, {33,12}, {32,11} }, R.ochre[4])
  c:put(31, 14, R.madder[6]) c:put(31, 13, R.madder[5])
  C.save(c, "coat-2-braided-cord-jacket")
end

---------------------------------------------------------------- 3 sand-robe coat
do
  local c = C.new("coat-3-sand-robe-coat")
  local robe = c:poly{ {23,6}, {41,6}, {44,14}, {47,40}, {51,61}, {13,61}, {17,40}, {20,14} }
  local SL = { {22,7}, {17,10}, {6,34}, {5,42}, {19,44}, {20,26} }
  local slL, slR = c:poly(SL), c:poly(mir(SL))
  C.lay(c, slR, R.linen, { R = 4, bias = -1 })
  C.lay(c, slL, R.linen, { R = 4 })
  -- sleeve mouths (inside shadow)
  local mL = c:poly{ {6,40}, {18,42}, {19,44}, {5,42} }
  c:fillMask(mL, R.sand[2])
  local mR = c:poly(mir({ {6,40}, {18,42}, {19,44}, {5,42} }))
  c:fillMask(mR, R.sand[1])
  -- sleeve folds
  C.stroke(c, { {16,14}, {10,36} }, R.linen[3], slL) C.stroke(c, { {48,14}, {54,36} }, R.linen[2], slR)
  C.sep(c, robe, slL:copy():add(slR), R.linen[2])
  local ri = C.lay(c, robe, R.linen, { R = 6, hs = 0.6, cuts = { .22, .4, .56, .72, .88 } })
  -- long folds
  for _, f in ipairs({ { {27,30}, {24,60} }, { {37,30}, {41,60} }, { {32,40}, {32,60} } }) do C.stroke(c, f, R.linen[3], robe) end
  C.stroke(c, { {26,31}, {23,59} }, R.linen[5], robe)
  -- front overlap edge + neck
  local neck = c:ellipse(32, 6, 5, 3):clip(robe)
  c:fillMask(neck, R.sand[2])
  C.stroke(c, { {35,9}, {36,60} }, R.sand[3], robe)
  C.stroke(c, { {34,9}, {35,60} }, R.linen[6], robe)
  -- side slit on the left
  local slit = c:poly{ {14,61}, {17,50}, {18,61} }
  c:fillMask(slit, R.sand[1])
  -- sand-coloured hem band
  robe:each(function(x, y) if y >= 58 then c:put(x, y, R.sand[(y == 58) and 5 or 4]) end end)
  -- sash at the waist
  local sash = c:poly{ {17,32}, {47,32}, {47,36}, {17,36} }:clip(robe)
  C.lay(c, sash, R.sand, { R = 1 })
  C.hline(c, 18, 46, 32, R.sand[6])
  C.stroke(c, { {38,36}, {40,43} }, R.sand[3]) C.stroke(c, { {40,36}, {43,42} }, R.sand[4])
  -- quirk: darkling beetle walking up the hem
  local bx, by = 42, 52
  local beetle = c:ellipse(bx, by, 2.2, 3):add(c:ellipse(bx, by - 3.5, 1.2, 1))
  local legs = { {bx - 3, by - 2}, {bx + 3, by - 2}, {bx - 3, by}, {bx + 3, by}, {bx - 3, by + 2}, {bx + 3, by + 2}, {bx - 1, by - 5}, {bx + 1, by - 5} }
  local bm = beetle:copy() for _, l in ipairs(legs) do bm:set(l[1], l[2]) end
  C.lay(c, beetle, R.goat, { R = 1 })
  for _, l in ipairs(legs) do c:put(l[1], l[2], R.goat[2]) end
  C.vline(c, bx, by - 2, by + 3, R.goat[1])
  c:put(bx - 1, by - 1, R.goat[6]) c:put(bx - 1, by, R.goat[5]) c:put(bx + 1, by - 1, R.indigo[4])
  C.save(c, "coat-3-sand-robe-coat")
end

---------------------------------------------------------------- 4 quilted night coat
do
  local c = C.new("coat-4-quilted-night-coat")
  local body = c:rrect(17, 12, 47, 50, 5)
  local SL = { {21,13}, {14,15}, {8,30}, {7,42}, {16,44}, {18,32}, {21,24} }
  local slL, slR = c:poly(SL), c:poly(mir(SL))
  local collar = c:rrect(22, 5, 42, 14, 3)
  local quilt = function(m, b)
    local idx = C.lay(c, m, R.indigo, { R = 4, bias = b, cuts = { .2, .36, .52, .7, .88 } })
    m:each(function(x, y)
      local u, v = (x + y) % 8, (x - y) % 8
      local i = idx[K(x, y)]
      if u == 0 or v == 0 then
        c:put(x, y, R.indigo[max(1, i - 2)])
        if u == 0 and v == 0 then c:put(x, y, R.linen[(x < 32) and 5 or 4]) end
      elseif u == 1 or v == 1 then c:put(x, y, R.indigo[min(6, i + 1)]) end
    end)
  end
  quilt(slR, -1) quilt(slL, 0)
  -- puffy sleeve cuffs
  for _, s in ipairs({ { 7, 41, 16, 45, 0 }, { 48, 41, 57, 45, -1 } }) do
    local cf = c:rrect(s[1], s[2], s[3], s[4], 2)
    C.lay(c, cf, R.indigo, { R = 2, bias = s[5] })
  end
  C.sep(c, body, slL:copy():add(slR), R.indigo[1])
  quilt(body, 0)
  -- front closing + toggles
  C.vline(c, 32, 14, 50, R.indigo[1]) C.vline(c, 31, 14, 50, R.indigo[5])
  for _, y in ipairs({ 20, 28, 36 }) do C.hline(c, 29, 35, y, R.linen[4]) c:put(29, y, R.linen[6]) end
  -- hem band
  body:each(function(x, y) if y >= 47 then c:put(x, y, R.indigo[(y == 47) and 5 or 3]) end end)
  -- high collar
  C.sep(c, collar, body, R.indigo[1])
  C.lay(c, collar, R.indigo, { R = 3 })
  C.hline(c, 24, 40, 6, R.indigo[6])
  C.vline(c, 32, 7, 14, R.indigo[1])
  for x = 23, 41, 2 do c:put(x, 12, R.linen[4]) end
  -- quirk: patch with a fennec fox face
  local patch = c:rrect(19, 33, 28, 43, 1)
  c:fillMask(patch, R.sand[5])
  patch:edge():each(function(x, y) c:put(x, y, ((x + y) % 2 == 0) and R.sand[2] or R.sand[4]) end)
  -- ears
  C.put(c, { {20,35}, {21,35}, {20,36}, {21,36}, {22,37}, {25,37}, {26,36}, {27,36}, {26,35}, {27,35} }, R.ochre[4])
  C.put(c, { {21,36}, {26,36} }, R.madder[5])
  -- face
  C.put(c, { {22,38}, {23,38}, {24,38}, {25,38}, {21,38}, {26,38}, {22,39}, {23,39}, {24,39}, {25,39}, {23,40}, {24,40} }, R.ochre[5])
  C.put(c, { {22,38}, {25,38} }, C.ink)
  C.put(c, { {23,41}, {24,41} }, R.linen[6]) c:put(23, 40, C.ink) c:put(24, 40, C.ink)
  C.save(c, "coat-4-quilted-night-coat")
end

---------------------------------------------------------------- 5 caravan leather jerkin
do
  local c = C.new("coat-5-caravan-leather-jerkin")
  local top = c:poly{ {22,8}, {42,8}, {46,13}, {46,37}, {18,37}, {18,13} }
  local skirt = c:poly{ {18,38}, {46,38}, {50,55}, {14,55} }
  local CAP = { {22,8}, {14,11}, {9,22}, {18,25} }
  local capL, capR = c:poly(CAP), c:poly(mir(CAP))
  C.lay(c, capR, R.camel, { R = 3, bias = -1 })
  C.lay(c, capL, R.camel, { R = 3 })
  -- cap sleeve hems
  C.stroke(c, { {9,22}, {18,25} }, R.camel[2]) C.stroke(c, { {55,22}, {46,25} }, R.camel[1])
  local body = top:copy():add(skirt)
  C.sep(c, body, capL:copy():add(capR), R.camel[1])
  C.lay(c, skirt, R.camel, { R = 4, bias = -1 })
  C.lay(c, top, R.camel, { R = 5, cuts = { .22, .4, .56, .72, .88 } })
  -- skirt panels
  for _, x in ipairs({ 24, 32, 40 }) do C.stroke(c, { {x,40}, {x + floor((x - 32) / 4), 55} }, R.camel[2], skirt) end
  -- V neck
  local neck = c:poly{ {26,8}, {38,8}, {32,18} }
  c:fillMask(neck, R.camel[1])
  -- front lacing
  for y = 19, 35, 4 do
    C.stroke(c, { {30,y}, {34,y + 3} }, R.linen[5]) C.stroke(c, { {34,y}, {30,y + 3} }, R.linen[4])
    c:put(29, y, R.camel[1]) c:put(35, y, R.camel[1])
  end
  -- edge stitching
  for y = 10, 34, 2 do c:put(20, y, R.camel[6]) c:put(44, y, R.camel[3]) end
  -- belt with buckle
  local belt = c:rect(17, 35, 47, 39)
  C.lay(c, belt, R.strap, { R = 1 })
  C.hline(c, 17, 47, 35, R.strap[5])
  local buck = c:rrect(29, 34, 35, 40, 1):cut(c:rect(31, 36, 33, 38))
  buck:each(function(x, y) c:put(x, y, R.brass[(x < 32 and y < 37) and 5 or 3]) end)
  c:fillMask(c:rect(31, 36, 33, 38), R.strap[3])
  -- two pouches on the belt
  for _, p in ipairs({ { 19, 0 }, { 39, -1 } }) do
    local x0 = p[1]
    local pm = c:rrect(x0, 39, x0 + 7, 47, 2)
    C.sep(c, pm, skirt, R.camel[1])
    C.lay(c, pm, R.leather, { R = 2, bias = p[2] })
    local fl = c:rrect(x0, 39, x0 + 7, 42, 1)
    C.lay(c, fl, R.leather, { R = 1, bias = p[2] - 1 })
    c:put(x0 + 3, 42, R.brass[4])
  end
  -- quirk: small brass compass hanging from the belt
  C.stroke(c, { {46,39}, {47,43} }, R.strap[2])
  local cp = c:ellipse(49, 47, 3.4, 3.4)
  local face = c:ellipse(49, 47, 2.2, 2.2)
  C.lay(c, cp, R.brass, { R = 1 })
  C.lay(c, face, R.linen, { R = 1, bias = 1 })
  c:put(49, 47, C.ink) c:put(50, 46, R.madder[4]) c:put(51, 45, R.madder[3]) c:put(48, 48, R.steel[2]) c:put(47, 49, R.steel[3])
  c:put(47, 44, R.brass[6]) c:put(49, 43, R.brass[4])
  -- leather shine
  C.put(c, { {22,14}, {22,15}, {23,13} }, R.camel[6])
  C.save(c, "coat-5-caravan-leather-jerkin")
end
