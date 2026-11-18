-- cloak.lua: CB Sunsprinkle Isles cloak concepts (5 icons, 64x64). See concepts.md.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, W, G = C.HP, C.X, C.K, C.R, C, C.G
local only = app.params.only
local function want(n) return not only or only == n end
local mang = { "#14302e", "#1c4a44", "#26645a", "#34806c", "#4ea082", "#80c49c" }

------------------------------------------------------------------ 1 thatch rain cape
if want("1") then
  local c = C.new("cloak-1-thatch-rain-cape")
  local tiers = {
    { 41, 57, 22, 25, R.straw, -1 },
    { 30, 47, 18, 22, R.straw, 0 },
    { 20, 36, 13, 18, R.straw, 0 },
    { 11, 25, 8, 13, R.straw, 1 },
  }
  local prev
  for ti, t in ipairs(tiers) do
    local y0, y1, w0, w1, ramp, b = t[1], t[2], t[3], t[4], t[5], t[6]
    local m = c:poly{ {32 - w0, y0}, {32 + w0, y0}, {32 + w1, y1 - 2}, {32 - w1, y1 - 2} }
    -- ragged frond fringe on the bottom
    for x = 32 - w1, 32 + w1 do
      local d = (X.hash(x, ti, 3) < .5) and 1 or 0
      if x % 2 == 0 then m:set(x, y1 - 1) if d == 1 then m:set(x, y1) end end
    end
    if prev then C.sep(c, m, prev) end
    local i = C.lay(c, m, ramp, { R = 3, b = b, cuts = { .22, .4, .56, .72, .88 } })
    W.retone(c, m, i, ramp, function(x, y) if x % 2 == 0 then return -1 elseif X.hash(x, y // 3, ti) < .25 then return 1 end end)
    -- shade cast on the next tier is the sep line; lit lip at top
    for x = 32 - w0, 32 + w0 do if m:has(x, y0) then c:put(x, y0, ramp[x < 32 and 6 or 5]) end end
    prev = (prev or HP.mask()):add(m)
  end
  -- neck cord and tied ends with beads
  local cord = c:rect(26, 10, 38, 12)
  local ci = C.lay(c, cord, R.sisal, { R = 1 })
  W.retone(c, cord, ci, R.sisal, C.twist)
  C.tube(c, { {30,12}, {29,16}, {27,19}, {27,22} }, 1, R.sisal)
  C.tube(c, { {34,12}, {35,15}, {36,18}, {35,21} }, 1, R.sisal)
  C.ball(c, 27, 23, 1.4, R.hibis) C.ball(c, 35, 22, 1.4, R.hibis)
  -- quirk: tiny tree frog on the second tier
  local fb = c:ellipse(43, 20, 3, 2.2)
  C.sep(c, fb, prev)
  W.lit(c, fb, R.seaglass, { R = 1 })
  local fh = c:ellipse(40, 18, 2, 1.6)
  W.lit(c, fh, R.seaglass, { R = 1 })
  c:put(39, 17, R.sunset[5]) c:put(39, 17, R.sunset[5])
  W.put(c, { {39,16}, {41,16} }, R.sunset[4]) c:put(40, 17, W.ink) c:put(39, 17, W.ink)
  W.put(c, { {38,22}, {39,22}, {46,22}, {47,22}, {45,23} }, R.sunset[4])
  c:put(42, 18, R.seaglass[6])
  C.save(c, "cloak-1-thatch-rain-cape")
end

------------------------------------------------------------------ 2 hibiscus shawl
if want("2") then
  local c = C.new("cloak-2-hibiscus-shawl")
  local sh = c:poly{ {5,14}, {59,14}, {32,48} }
  -- fringe (behind): short strands off both lower edges
  for i = 0, 14 do
    local t = i / 14
    local lx, ly = 7 + (32 - 7) * t, 16 + (47 - 16) * t
    local rx = 57 - (57 - 32) * t
    c:line({ {lx - 1, ly + 1}, {lx - 3, ly + 5} }, 1):each(function(x, y) c:put(x, y, R.hibis[(i % 2 == 0) and 4 or 3]) end)
    c:line({ {rx + 1, ly + 1}, {rx + 2, ly + 5} }, 1):each(function(x, y) c:put(x, y, R.hibis[(i % 2 == 0) and 3 or 2]) end)
  end
  for x = 29, 35 do c:put(x, 50 + (x % 2), R.hibis[3]) end
  local si = C.lay(c, sh, R.cotton, { R = 4, cuts = { .22, .4, .56, .72, .88 }, tex = C.weave })
  -- red border band along the lower edges
  sh:edge():grow(1):clip(sh):each(function(x, y) if y > 16 then c:put(x, y, R.hibis[math.max(2, si[K(x, y)] - 1)]) end end)
  -- folded top band
  local fold = c:rect(5, 12, 59, 16):clip(c:poly{ {3,11}, {61,11}, {58,17}, {6,17} })
  C.lay(c, fold, R.hibis, { R = 2 })
  W.hline(c, 7, 57, 12, R.hibis[6]) W.hline(c, 7, 57, 17, R.hibis[1])
  -- hibiscus print with leaves
  for _, f in ipairs({ {18,23}, {32,22}, {46,23}, {25,32}, {39,32}, {32,41} }) do
    local lf = c:ellipse(f[1] + 3, f[2] + 2, 2, 1.2)
    c:fillMask(lf, R.palm[4]) c:put(f[1] + 4, f[2] + 3, R.palm[2])
    C.flower2(c, f[1], f[2], R.hibis, "#ffd25a")
  end
  -- quirk: yellow sulphur butterfly on the right corner
  W.put(c, { {53,8}, {54,8}, {52,9}, {53,9}, {54,9}, {53,10}, {54,10} }, R.brass[5])
  W.put(c, { {57,8}, {58,8}, {56,9}, {57,9}, {58,9}, {56,10}, {57,10} }, R.brass[4])
  W.put(c, { {55,9}, {55,10}, {55,11} }, R.wood[2])
  W.put(c, { {54,11}, {56,11} }, R.brass[3])
  c:put(53, 8, R.brass[6]) W.put(c, { {54,7}, {56,7} }, R.wood[2])
  C.save(c, "cloak-2-hibiscus-shawl")
end

------------------------------------------------------------------ 3 sea-breeze poncho
if want("3") then
  local c = C.new("cloak-3-sea-breeze-poncho")
  local po = c:poly{ {24,11}, {40,11}, {50,16}, {57,30}, {58,38}, {32,55}, {6,38}, {7,30}, {14,16} }
  -- fringe along the two lower edges (behind)
  for i = 0, 12 do
    local t = i / 12
    local lx, ly = 7 + (31 - 7) * t, 39 + (55 - 39) * t
    local rx = 57 - (57 - 33) * t
    c:line({ {lx, ly}, {lx - 1, ly + 4} }, 1):each(function(x, y) c:put(x, y, R.sisal[(i % 2 == 0) and 4 or 3]) end)
    c:line({ {rx, ly}, {rx + 1, ly + 4} }, 1):each(function(x, y) c:put(x, y, R.sisal[(i % 2 == 0) and 3 or 2]) end)
  end
  local bt = c:poly{ {30,55}, {34,55}, {35,60}, {29,60} }
  local bti = C.lay(c, bt, R.coral, { R = 1 })
  W.retone(c, bt, bti, R.coral, function(x) if x % 2 == 0 then return -1 end end)
  local idx = W.lit(c, po, R.turq, { R = 4, cuts = { .22, .4, .56, .72, .88 } })
  po:each(function(x, y)
    local i = idx[K(x, y)]
    local q = y - math.abs(x - 32) * .55   -- chevron stripes parallel to the hem
    local band = math.floor(q / 4) % 3
    local ramp = (band == 1) and R.sisal or R.turq
    if math.floor(q) % 12 == 0 then ramp = R.coral end
    local wv = (band == 2) and ((x % 4 == 0 and math.floor(q) % 4 == 1) or (x % 4 == 2 and math.floor(q) % 4 == 2))
    c:put(x, y, ramp[math.max(1, math.min(6, i - (wv and 1 or 0)))])
  end)
  -- arm folds
  for _, f in ipairs({ { {16,18}, {12,36} }, { {48,18}, {52,36} } }) do
    c:line(f, 1):each(function(x, y) if po:has(x, y) then c:put(x, y, R.turq[1]) end end)
  end
  -- rolled collar
  local col = c:rrect(23, 6, 41, 14, 3)
  C.sep(c, col, po)
  local coi = C.lay(c, col, R.coral, { R = 2 })
  W.retone(c, col, coi, R.coral, function(x, y) if x % 3 == 0 then return -1 end end)
  local neck = c:ellipse(32, 9, 6, 1.5)
  c:fillMask(neck, R.turq[1])
  W.hline(c, 26, 38, 13, R.coral[1])
  -- quirk: scallop shell tied to the bottom tassel
  local sm = c:poly{ {35,55}, {43,55}, {41,60}, {37,60} }:add(c:ellipse(39, 55, 4, 2.5))
  C.sep(c, sm, po:copy():add(bt))
  W.lit(c, sm, R.shell, { R = 1 })
  for _, x in ipairs({ 37, 39, 41 }) do c:put(x, 57, R.shell[2]) c:put(x, 58, R.shell[2]) end
  W.put(c, { {38,60}, {39,60}, {40,60} }, R.shell[3]) c:put(36, 54, W.cream)
  W.put(c, { {34,56}, {35,56} }, R.sisal[2])
  c:put(19, 20, R.turq[6]) c:put(20, 19, R.turq[6])
  C.save(c, "cloak-3-sea-breeze-poncho")
end

------------------------------------------------------------------ 4 mangrove hood
if want("4") then
  local c = C.new("cloak-4-mangrove-hood")
  -- root tabs (behind the hem)
  local roots = HP.mask()
  for i, x in ipairs({ 14, 19, 24, 29, 35, 40, 45, 50 }) do
    local L = ({ 6, 4, 7, 5, 6, 4, 7, 5 })[i]
    local dx = (i % 2 == 0) and 1 or -1
    roots:add(C.tube(c, { {x,50}, {x + dx,52}, {x + dx * 2,54}, {x + dx * 2, 50 + L} }, function(t) return 1.8 - t * .9 end, R.mahog, { b = 0 }))
  end
  local body = c:poly{ {23,18}, {41,18}, {52,52}, {12,52} }
  C.sep(c, body, roots, R.mahog[1])
  local bi = C.lay(c, body, mang, { R = 5, cuts = { .22, .4, .56, .72, .9 } })
  W.retone(c, body, bi, mang, function(x, y) if (x + y) % 4 == 0 and X.hash(x, y, 5) < .6 then return -1 end end)
  -- front opening + inner lining strip
  W.vline(c, 32, 26, 52, mang[1]) W.vline(c, 33, 26, 52, R.lining[3])
  -- folds
  for _, f in ipairs({ { {26,28}, {19,51} }, { {38,28}, {45,51} } }) do
    c:line(f, 1):each(function(x, y) if body:has(x, y) then c:put(x, y, mang[math.max(1, bi[K(x, y)] - 1)]) end end)
  end
  -- hem band
  for x = 12, 52 do if body:has(x, 51) then c:put(x, 51, mang[2]) c:put(x, 50, mang[4]) end end
  -- hood: pointed, tip bent to the right
  local hood = c:poly{ {22,24}, {22,14}, {27,7}, {34,4}, {42,3}, {48,5}, {42,8}, {42,14}, {43,24} }
  C.sep(c, hood, body)
  local hi = C.lay(c, hood, mang, { R = 4 })
  local face = c:ellipse(32, 17, 6, 5.5)
  c:fillMask(face, mang[1])
  face:grow(1):cut(face):each(function(x, y) if hood:has(x, y) then c:put(x, y, (x < 32) and mang[6] or mang[3]) end end)
  -- rope tie at the throat
  W.hline(c, 26, 38, 25, R.sisal[4]) W.hline(c, 26, 38, 26, R.sisal[2])
  C.ball(c, 32, 26, 1.6, R.wood, true)
  C.tube(c, { {31,27}, {30,30}, {29,32}, {29,34} }, .9, R.sisal)
  C.tube(c, { {33,27}, {35,30}, {35,32}, {36,35} }, .9, R.sisal)
  -- quirk: mangrove seed pod dangling from the hood point
  W.vline(c, 48, 6, 8, R.sisal[3])
  local pod = C.tube(c, { {48,9}, {49,12}, {49,15}, {48,19} }, function(t) return 1.4 - t * .6 end, R.palm)
  c:put(48, 9, R.mahog[3]) c:put(49, 9, R.mahog[2]) c:put(48, 10, R.mahog[4])
  c:put(28, 8, mang[6]) c:put(29, 7, mang[6])
  C.save(c, "cloak-4-mangrove-hood")
end

------------------------------------------------------------------ 5 shell-scallop capelet
if want("5") then
  local c = C.new("cloak-5-shell-scallop-capelet")
  -- shell fan: radial ribs from the collar, scalloped hem, two growth tiers
  local ox, oy, A, NR = 32, 4, 0.74, 9
  local m, v, rib = HP.mask(), {}, {}
  for y = 8, 56 do for x = 0, 63 do
    local dx, dy = x - ox, y - oy
    local r, a = math.sqrt(dx * dx + dy * dy), math.atan(dx, dy)
    if math.abs(a) <= A and r >= 7 then
      local f = (a + A) / (2 * A) * NR
      local k, u = math.floor(f), (f % 1) * 2 - 1
      local rmax = 41 + 2.4 * math.cos(u * math.pi / 2) - 2
      if r <= rmax and k < NR then
        m:set(x, y)
        local kk = K(x, y)
        rib[kk] = k
        local lit = .55 - .35 * u - (x - 32) / 70 - (r > rmax - 2 and 0 or 0) + (y < 20 and .08 or 0)
        v[kk] = math.max(0, math.min(1, lit))
      end
    end
  end end
  local tier = function(x, y) return math.sqrt((x - ox)^2 + (y - oy)^2) end
  m:each(function(x, y)
    local kk = K(x, y)
    local ramp = (tier(x, y) > 29) and R.coral or R.flam
    local i = 1
    for j, t in ipairs({ .18, .34, .5, .66, .82 }) do if v[kk] >= t then i = j + 1 end end
    c:put(x, y, ramp[i])
  end)
  -- rib grooves, growth line, pale scalloped lip
  m:each(function(x, y)
    local kk = K(x, y)
    if rib[K(x + 1, y)] and rib[K(x + 1, y)] ~= rib[kk] then c:put(x, y, R.coral[1]) end
    local r = tier(x, y)
    if r > 29 and r <= 30 then c:put(x, y, R.shell[(x < 32) and 6 or 4]) end
    if r > 28 and r <= 29 then c:put(x, y, R.flam[1]) end
    if not m:has(x, y + 1) then c:put(x, y, R.shell[(x < 32) and 5 or 3]) end
  end)
  local drawn = m
  -- high collar
  local col = c:rrect(24, 8, 40, 16, 3)
  C.sep(c, col, drawn)
  C.lay(c, col, R.coral, { R = 2, b = -1 })
  W.hline(c, 26, 38, 9, R.coral[5])
  W.vline(c, 32, 10, 16, R.coral[1])
  -- quirk: cowrie-shell clasp at the throat
  local cw = c:ellipse(32, 17, 3.2, 2.3)
  C.sep(c, cw, drawn:copy():add(col))
  W.lit(c, cw, R.shell, { R = 1 })
  W.hline(c, 30, 34, 17, R.shell[1])
  W.put(c, { {30,16}, {32,16}, {34,16}, {31,18}, {33,18} }, R.shell[2])
  c:put(30, 15, W.cream) c:put(31, 15, R.shell[6])
  C.save(c, "cloak-5-shell-scallop-capelet")
end
