-- backpack.lua: Maplewold (NA) backpack concepts 1-5. See concepts.md.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local N = dofile(DIR .. "/common.lua")
local W, HP, X, K, R, G = N.W, N.HP, N.X, N.K, N.R, N.G
local ink, cream = W.ink, W.cream
local only = app.params.only
local floor, max, min = math.floor, math.max, math.min

---------------------------------------------------------------- 1 splint pack basket
local function basket()
  local c = N.canvas("backpack-1-splint-pack-basket")
  local body = c:poly{ {11,16}, {53,16}, {47,57}, {17,57} }:add(c:rrect(17, 53, 47, 58, 2))
  local bi = N.lay(c, body, R.lining, 0, { R = 7, hs = 0.6 })
  -- over/under weave: stakes converge to the base, weavers are rows of 4
  body:each(function(x, y)
    local t = (y - 16) / 42
    local half = 21 - t * 6
    local u = (x - 32) / half * 21 + 32
    local col = floor((u - 11) / 4)
    local row = floor((y - 17) / 4)
    local i = bi[K(x, y)]
    if (y - 17) % 4 == 3 then i = i - 2
    elseif (col + row) % 2 == 0 then i = i - 1
    elseif floor(u - 11) % 4 == 0 then i = i - 1 end
    c:put(x, y, R.lining[max(1, min(6, i))])
  end)
  -- thick wrapped rim
  local rim, rn = X.cyl(10, 15, 54, 15, function() return 3 end)
  local ri = W.toneN(c, rim, rn, R.wood)
  rim:each(function(x, y) if (x + y) % 3 == 0 then c:put(x, y, R.wood[max(1, ri[K(x, y)] - 1)]) end end)
  -- base skid
  W.hline(c, 18, 46, 57, R.lining[1])
  -- leather lid strap over the rim, with a brass stud
  local strap = c:rect(38, 9, 42, 30)
  W.sep(c, strap, body:copy():add(rim), R.lining[1])
  W.vcyl(c, strap, R.strap, 38, 42)
  local bk = c:rect(37, 25, 43, 30)
  N.lay(c, bk, R.brass, 0, { R = 1 })
  c:fillMask(c:rect(39, 27, 41, 28), R.strap[2])
  c:put(38, 26, cream)
  -- linen cover bulging out of the top
  local cover = c:ellipse(28, 11, 13, 4):cut(rim)
  W.sep(c, cover, rim, R.canvas[1])
  N.lay(c, cover, R.canvas, 1, { R = 2 })
  -- quirk: fern frond poking out under the cover
  local pts = {}
  for i = 0, 10 do pts[#pts + 1] = { floor(21 - i * 1.5 + 0.5), floor(13 - i * 1.3 - (i * i) * 0.02 + 0.5) } end
  for k, p in ipairs(pts) do
    if k > 1 and k < 11 then
      local L = (k < 8) and 3 or 2
      for j = 1, L do c:put(p[1] - j, p[2] - j + (k % 2), N.pine[4 + (j == 1 and 1 or 0)]) c:put(p[1] + j, p[2] - j + 1 - (k % 2), N.pine[3]) end
    end
  end
  for _, p in ipairs(pts) do c:put(p[1], p[2], N.pine[2]) end
  c:put(pts[11][1], pts[11][2], N.pine[6])
  -- pop
  c:put(14, 19, R.lining[6]) c:put(15, 19, cream)
  N.save(c, "backpack-1-splint-pack-basket")
end

---------------------------------------------------------------- 2 firewood pack frame
local function frame()
  local c = N.canvas("backpack-2-firewood-pack-frame")
  local poles = c:rrect(15, 4, 19, 60, 2):add(c:rrect(45, 4, 49, 60, 2))
  local rungs = c:rect(17, 9, 47, 12):add(c:rect(17, 51, 47, 54))
  N.lay(c, rungs, R.wood, -1, { R = 1 })
  W.sep(c, poles, rungs, R.wood[1])
  W.vcyl(c, poles:copy():clip(c:rect(15, 0, 19, 63)), R.wood, 15, 19)
  W.vcyl(c, poles:copy():clip(c:rect(45, 0, 49, 63)), R.wood, 45, 49, { bias = (function() local b = {} poles:each(function(x, y) b[K(x, y)] = -1 end) return b end)() })
  -- stack of logs: birch and split maple, end grain on the left
  local logs = {
    { y = 20, r = 4.5, x0 = 11, x1 = 54, bark = N.birch },
    { y = 29, r = 4.5, x0 = 9, x1 = 52, bark = R.wood },
    { y = 38, r = 4.5, x0 = 12, x1 = 55, bark = N.birch },
    { y = 46, r = 3.5, x0 = 10, x1 = 50, bark = R.wood },
  }
  local prev
  for _, L in ipairs(logs) do
    local m, n = X.cyl(L.x0, L.y, L.x1, L.y, function() return L.r end)
    if prev then W.sep(c, m, prev, ink) end
    local idx = W.toneN(c, m, n, L.bark)
    if L.bark == N.birch then
      for i = 0, 7 do local x = L.x0 + 4 + i * 5 + (i % 2) local y = L.y - 2 + (i * 3) % 5
        if m:has(x, y) and m:has(x + 1, y) then c:put(x, y, N.dkcheck[2]) c:put(x + 1, y, N.dkcheck[3]) end end
    else
      W.retone(c, m, idx, R.wood, function(x, y, i) if (y - L.y) % 2 == 0 and X.hash(x // 3, y, 4) < 0.5 then return -1 end end)
    end
    -- end grain disc on the left
    local e = c:ellipse(L.x0, L.y, 2.2, L.r)
    c:fillMask(e, R.lining[5])
    e:edge():each(function(x, y) c:put(x, y, L.bark[3]) end)
    c:put(L.x0, L.y, R.lining[3])
    prev = (prev or HP.mask()):add(m):add(e)
  end
  -- rope lashings
  for _, rx in ipairs({ 24, 39 }) do
    for y = 14, 51 do
      if prev:has(rx, y) then c:put(rx, y, (y % 2 == 0) and R.canvas[5] or R.canvas[3]) c:put(rx + 1, y, R.canvas[2]) end
    end
  end
  -- quirk: pinecone dangling from the bottom rung
  W.vline(c, 33, 55, 57, R.canvas[3])
  local cone = c:ellipse(33, 60.5, 2.4, 3)
  W.lit(c, cone, R.felt, { R = 1.5 })
  W.put(c, { {32,59}, {34,60}, {32,61}, {34,62} }, R.felt[1]) c:put(32, 58, R.felt[6])
  -- pole tops
  c:put(16, 5, R.wood[6]) c:put(46, 5, R.wood[5])
  N.save(c, "backpack-2-firewood-pack-frame")
end

---------------------------------------------------------------- 3 portage sack
local function portage()
  local c = N.canvas("backpack-3-portage-sack")
  local tump = G.tube({ {13,24}, {14,2}, {50,2}, {51,24} }, function() return 1.8 end)
  local body = c:poly{ {14,18}, {50,18}, {54,48}, {52,57}, {12,57}, {10,48} }:add(c:rrect(13, 15, 51, 24, 4))
  local ti = N.lay(c, tump, R.strap, -1, { R = 1 })
  W.sep(c, body, tump, R.strap[1])
  local bi = N.lay(c, body, N.duck, 0, { R = 6, hs = 0.7 })
  W.retone(c, body, bi, N.duck, function(x, y) if (x + 2 * y) % 5 == 0 and X.hash(x, y, 9) < 0.5 then return -1 end end)
  -- slouch creases at the base
  W.put(c, { {16,52}, {17,51}, {18,51} }, N.duck[2]) W.put(c, { {46,51}, {47,52}, {48,52} }, N.duck[1])
  -- big rounded flap
  local flap = c:poly{ {13,16}, {51,16}, {52,34}, {46,40}, {18,40}, {12,34} }
  for x = 17, 47 do c:put(x, 41, N.duck[1]) end
  local fi = N.lay(c, flap, N.duck, 1, { R = 3, cuts = { .2, .36, .52, .7, .86 } })
  N.bottom(flap, function(x, y) c:put(x, y, N.duck[2]) end)
  flap:shrink(2):edge():each(function(x, y) if y > 30 and (x + y) % 3 ~= 0 then c:put(x, y, N.duck[3]) end end)
  -- two leather straps with brass buckles
  for _, sx in ipairs({ 20, 41 }) do
    local s = c:rect(sx, 33, sx + 3, 53)
    W.vcyl(c, s, R.strap, sx, sx + 3)
    local bk = c:rect(sx - 1, 44, sx + 4, 48)
    N.lay(c, bk, R.brass, 0, { R = 1 })
    c:fillMask(c:rect(sx + 1, 45, sx + 2, 47), R.strap[2])
    c:put(sx - 1, 44, R.brass[6])
  end
  -- tumpline lit edge
  tump:each(function(x, y) if not tump:has(x, y - 1) and y < 6 then c:put(x, y, R.strap[5]) end end)
  -- quirk: feathered fishing fly hooked on the flap
  W.put(c, { {33,21}, {34,22}, {34,23}, {33,24}, {32,23} }, R.steel[4])
  c:put(33, 21, R.steel[6])
  local fly = c:poly{ {33,23}, {39,24}, {43,27}, {38,29}, {33,28} }
  N.lay(c, fly, N.maple, 1, { R = 1 })
  W.put(c, { {36,26}, {37,26}, {38,26} }, R.brass[5]) W.put(c, { {33,25}, {33,26} }, N.dkcheck[2])
  -- canvas pop
  c:put(16, 20, N.duck[6]) c:put(17, 20, N.duck[6])
  N.save(c, "backpack-3-portage-sack")
end

---------------------------------------------------------------- 4 sap-run bucket
local function bucket()
  local c = N.canvas("backpack-4-sap-run-bucket")
  local body = c:poly{ {13,15}, {49,15}, {46,57}, {16,57} }
  local bi = W.vcyl(c, body, R.wood, 13, 49)
  -- staves
  body:each(function(x, y)
    local t = (y - 15) / 42
    local x0, x1 = 13 + 3 * t, 49 - 3 * t
    local u = (x - x0) / (x1 - x0)
    local s = u * 7
    if s - floor(s) < 0.12 then c:put(x, y, R.wood[max(1, bi[K(x, y)] - 2)]) end
  end)
  -- iron hoops
  for _, hy in ipairs({ 19, 36, 52 }) do
    local hoop = body:copy():clip(c:rect(0, hy, 63, hy + 2))
    W.vcyl(c, hoop, R.steel, 13, 49, { bias = (function() local b = {} hoop:each(function(x, y) b[K(x, y)] = -1 end) return b end)() })
    N.top(hoop, function(x, y) c:put(x, y, R.steel[5]) end)
    N.bottom(hoop, function(x, y) c:put(x, y + 1, R.wood[1]) end)
    for x = 17, 46, 9 do if hoop:has(x, hy + 1) then c:put(x, hy + 1, R.steel[1]) end end
  end
  -- lid + knob
  local lid = c:ellipse(31, 14, 19, 3.2)
  W.sep(c, lid, body, R.wood[1])
  N.lay(c, lid, R.wood, 1, { R = 2 })
  local knob = c:ellipse(31, 10, 3, 2)
  N.lay(c, knob, R.wood, 1, { R = 1 })
  -- rope bail over the top
  local bail = G.tube({ {14,15}, {14,0}, {48,0}, {48,15} }, function() return 1 end)
  bail:cut(lid):cut(knob)
  bail:each(function(x, y) c:put(x, y, ((x + y) % 2 == 0) and R.canvas[5] or R.canvas[3]) end)
  -- spile (sap spout) on the right with a hook
  local sp = c:rect(48, 27, 56, 29)
  W.sep(c, sp, body, ink)
  N.lay(c, sp, R.steel, 0, { R = 1 })
  W.hline(c, 49, 56, 27, R.steel[6])
  -- quirk: amber drop of syrup
  local drop = c:poly{ {55.5,30}, {58,34}, {57.5,36}, {53.5,36}, {53,34} }
  N.lay(c, drop, R.brass, -1, { R = 1.5 })
  c:put(54, 33, R.brass[6]) c:put(54, 34, cream)
  -- wood pop
  W.vline(c, 17, 24, 33, R.wood[6]) c:put(17, 25, cream)
  N.save(c, "backpack-4-sap-run-bucket")
end

---------------------------------------------------------------- 5 toboggan pack
local function toboggan()
  local c = N.canvas("backpack-5-toboggan-pack")
  -- side view: long bent-ash board, front curled up and back over the load
  local board = c:rrect(3, 45, 48, 50, 1)
  local P = { {46,47.5}, {62,46}, {62,22}, {48,26} }
  local curl, cn = G.tube(P, function(t) return 2.9 - t * 0.6 end)
  local bundle = c:rrect(8, 25, 44, 46, 7)
  local bi = N.lay(c, bundle, N.maple, 0, { R = 6, hs = 0.7 })
  -- wool check blanket bundle
  bundle:each(function(x, y)
    local vx, hy = (x % 7 < 2), (y % 7 == 2 or y % 7 == 3)
    if vx or hy then c:put(x, y, N.dkcheck[max(1, min(6, bi[K(x, y)] - ((vx and hy) and 2 or 0)))]) end
  end)
  -- rope lashings down to the side rail
  for _, rx in ipairs({ 15, 36 }) do
    for y = 24, 47 do if bundle:has(rx, y) then c:put(rx, y, (y % 2 == 0) and R.canvas[5] or R.canvas[3]) c:put(rx + 1, y, R.canvas[2]) end end
  end
  -- side rail rope along the board
  local rail = c:rect(4, 44, 47, 44)
  W.sep(c, board:copy():add(curl), bundle, ink)
  N.lay(c, board, R.wood, 0, { R = 2 })
  W.hline(c, 4, 47, 45, R.wood[5]) W.hline(c, 4, 47, 48, R.wood[2])
  for x = 9, 45, 9 do W.vline(c, x, 46, 49, R.wood[1]) end
  W.toneN(c, curl, cn, R.wood)
  local mid = G.tube(P, function() return 0.5 end)
  mid:each(function(x, y) if curl:has(x, y) and y < 45 then c:put(x, y, R.wood[2]) end end)
  -- quirk: brass sleigh bell hanging off the curl tip
  W.vline(c, 49, 28, 31, R.strap[2])
  local bell = c:ellipse(49, 34, 3, 3)
  W.sep(c, bell, bundle, ink)
  W.lit(c, bell, R.brass, { R = 2 })
  W.hline(c, 48, 50, 35, R.brass[1]) c:put(48, 33, R.brass[6]) c:put(48, 32, cream)
  c:put(12, 28, N.maple[6]) c:put(13, 28, N.maple[6])
  N.save(c, "backpack-5-toboggan-pack")
end

local all = { basket, frame, portage, bucket, toboggan }
for i, f in ipairs(all) do if not only or tonumber(only) == i then f() end end
