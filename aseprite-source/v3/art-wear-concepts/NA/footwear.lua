-- footwear.lua: Maplewold (NA) footwear concepts 1-5. See concepts.md.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local N = dofile(DIR .. "/common.lua")
local W, HP, X, K, R, G = N.W, N.HP, N.X, N.K, N.R, N.G
local ink, cream = W.ink, W.cream
local only = app.params.only

local function biasMap(m, b) local t = {} m:each(function(x, y) t[K(x, y)] = b end) return t end

---------------------------------------------------------------- 1 sugarbush snow boots
local function snowBoots()
  local c = N.canvas("footwear-1-sugarbush-snow-boots")
  local function boot(dx, dy, bias)
    local B = {}
    local upper = c:rect(14+dx, 13+dy, 28+dx, 37+dy)
    local shell = c:poly{ {12+dx,33+dy}, {29+dx,33+dy}, {31+dx,37+dy}, {38+dx,39+dy}, {42+dx,43+dy}, {42+dx,50+dy}, {12+dx,50+dy} }
    local sole = c:rrect(11+dx, 49+dy, 43+dx, 53+dy, 1)
    local cuff = c:rrect(11+dx, 7+dy, 31+dx, 15+dy, 2)
    B.all = upper:copy():add(shell):add(sole):add(cuff)
    B.paint = function()
      local b = bias or 0
      W.vcyl(c, upper, R.leather, 14+dx, 28+dx, { bias = biasMap(upper, b - 1) })
      -- tongue + criss-cross laces on the front edge
      local tongue = c:rect(24+dx, 16+dy, 28+dx, 34+dy)
      N.lay(c, tongue, R.lining, b - 1, { R = 1 })
      for y = 17+dy, 33+dy, 4 do
        c:put(24+dx, y, R.brass[4 + b]) c:put(28+dx, y, R.brass[3 + b])
        W.put(c, { {25+dx,y+1}, {26+dx,y+2}, {27+dx,y+3} }, R.lining[6 + b])
        W.put(c, { {27+dx,y+1}, {25+dx,y+3} }, R.lining[4 + b])
      end
      W.vline(c, 23+dx, 16+dy, 34+dy, R.leather[2 + b])
      -- rubber shell
      local si = N.lay(c, shell, N.rubber, b, { R = 4, hs = 0.7 })
      -- shell top lip and toe cap seam
      N.top(shell, function(x, y) c:put(x, y, N.rubber[5 + b]) c:put(x, y + 1, N.rubber[3 + b]) end)
      for x = 31+dx, 41+dx do if shell:has(x, 45+dy) then c:put(x, 45+dy, N.rubber[2 + b]) end end
      W.vline(c, 13+dx, 35+dy, 48+dy, N.rubber[4 + b])
      -- sole with chunky tread
      N.lay(c, sole, N.rubber, -2, { R = 1 })
      W.hline(c, 12+dx, 42+dx, 49+dy, N.rubber[3])
      for x = 13+dx, 41+dx, 4 do c:put(x, 53+dy, N.rubber[1]) c:put(x + 1, 53+dy, N.rubber[1]) end
      -- contact shadow below the cuff
      W.hline(c, 14+dx, 28+dx, 16+dy, R.leather[1])
      -- red check wool cuff
      local ci = N.lay(c, cuff, N.maple, b, { R = 2 })
      cuff:each(function(x, y)
        local vx = ((x - dx) % 6 < 2) local hy = ((y - dy) % 6 == 1 or (y - dy) % 6 == 2)
        if vx or hy then
          local i = ci[K(x, y)] - ((vx and hy) and 2 or 0)
          c:put(x, y, N.dkcheck[math.max(1, math.min(6, i))])
        end
      end)
      N.bottom(cuff, function(x, y) c:put(x, y, N.dkcheck[1]) end)
    end
    return B
  end
  local back = boot(12, -5, -1)
  local front = boot(0, 0, nil)
  back.paint()
  W.sep(c, front.all, back.all, ink)
  front.paint()
  -- leather pop + rubber gloss
  W.vline(c, 16, 18, 30, R.leather[6]) c:put(16, 19, cream)
  W.put(c, { {33,40}, {34,40}, {35,41} }, N.rubber[6])
  -- quirk: maple-leaf tag hanging off the top lace
  W.put(c, { {29,17}, {30,18}, {31,19} }, R.strap[2])
  local leaf = c:poly{ {33,19}, {35,20}, {37,19}, {36,22}, {38,23}, {35,25}, {34,27}, {32,25}, {29,24}, {31,22}, {30,20} }
  W.sep(c, leaf, front.all, ink)
  N.lay(c, leaf, N.maple, 1, { R = 1 })
  W.put(c, { {34,22}, {34,23}, {34,24} }, N.maple[2]) c:put(32, 21, N.maple[6])
  N.save(c, "footwear-1-sugarbush-snow-boots")
end

---------------------------------------------------------------- 2 birchwood clog
local function clog()
  local c = N.canvas("footwear-2-birchwood-clog")
  local open = c:ellipse(21, 19, 12, 4)
  local body = c:poly{ {7,24}, {9,19}, {33,19}, {39,22}, {47,26}, {54,31}, {58,37}, {57,44}, {54,47}, {10,47}, {7,41} }:add(open)
  local band = body:copy():clip(c:rect(13, 0, 21, 63))
  local wood = body:copy():cut(band)
  local wi = N.lay(c, wood, R.wood, 0, { R = 6, hs = 0.8 })
  -- grain: long streaks following the toe
  W.retone(c, wood, wi, R.wood, function(x, y, i)
    local g = y - math.max(0, x - 36) * 0.35
    if (math.floor(g) % 4 == 0) and X.hash(x // 5, math.floor(g), 3) < 0.65 then return -1 end
  end)
  -- birch bark band with short dark lenticel dashes
  N.lay(c, band, N.birch, 0, { R = 2.5, hs = 0.6 })
  for _, d in ipairs({ {14,26,3}, {18,29,3}, {15,33,2}, {17,37,4}, {14,41,2}, {19,43,2}, {16,24,2}, {19,35,2} }) do
    for x = d[1], d[1] + d[3] - 1 do if band:has(x, d[2]) then c:put(x, d[2], N.dkcheck[2]) end end
  end
  W.vline(c, 12, 22, 46, R.wood[2]) W.vline(c, 22, 23, 46, R.wood[2])
  -- foot opening: dark hollow, shaded back wall, lit near lip
  local hole = c:ellipse(22, 19, 10, 2.6)
  c:fillMask(hole, R.wood[1])
  hole:each(function(x, y) if not hole:has(x, y - 1) and x > 17 then c:put(x, y, R.wood[2]) end end)
  hole:each(function(x, y) if not hole:has(x, y + 1) then c:put(x, y + 1, (x >= 13 and x <= 21) and N.birch[6] or R.wood[6]) end end)
  -- heel cup highlight
  W.vline(c, 8, 23, 34, R.wood[5])
  -- sole line + arch notch
  W.hline(c, 10, 56, 46, R.wood[2])
  local notch = c:ellipse(35, 48, 8, 2.4)
  notch:each(function(x, y) if body:has(x, y) then c.pix[y * c.w + x] = nil c.own[y * c.w + x] = nil end end)
  -- toe gloss + carved toe line
  W.put(c, { {42,25}, {43,25}, {44,26}, {45,26}, {46,27} }, R.wood[6]) c:put(43, 25, cream)
  for x = 41, 55 do local y = math.floor(34 + (x - 41) * 0.3) if body:has(x, y) then c:put(x, y, R.wood[3]) end end
  -- quirk: a curl of bark peeling off the band
  local curl = c:poly{ {22,27}, {26,25}, {29,27}, {28,31}, {25,30}, {22,29} }
  N.lay(c, curl, N.birch, 1, { R = 1 })
  W.put(c, { {25,27}, {26,28}, {27,29} }, N.birch[2]) c:put(23, 27, N.birch[6])
  W.put(c, { {23,30}, {24,31}, {25,31}, {26,31} }, R.wood[2])
  N.save(c, "footwear-2-birchwood-clog")
end

---------------------------------------------------------------- 3 lakeland snowshoe
local function snowshoe()
  local c = N.canvas("footwear-3-lakeland-snowshoe")
  local ang = 0.62
  local ca, sa = math.cos(ang), math.sin(ang)
  local cx, cy = 33, 27
  local function at(u, v) return cx + u * ca - v * sa, cy + u * sa + v * ca end
  local outer = G.oval(cx, cy, 14, 20, ang)
  local tx, ty = at(0, 33)
  local l1x, l1y = at(-10, 13) local r1x, r1y = at(10, 13)
  outer:add(c:poly{ {l1x,l1y}, {r1x,r1y}, {tx,ty} })
  local inner = G.oval(cx, cy, 11, 17, ang)
  local t2x, t2y = at(0, 28)
  local l2x, l2y = at(-8, 12) local r2x, r2y = at(8, 12)
  inner:add(c:poly{ {l2x,l2y}, {r2x,r2y}, {t2x,t2y} })
  local frame = outer:copy():cut(inner)
  -- lattice: dark gaps with a criss-cross of rawhide
  inner:each(function(x, y)
    local a, b = (x + y) % 4, (x - y) % 4
    if a == 0 or b == 0 then
      c:put(x, y, (a == 0 and b == 0) and R.canvas[6] or R.canvas[4])
    else c:put(x, y, N.dkcheck[2]) end
  end)
  -- crossbars
  for _, v in ipairs({ -7, 13 }) do
    local ax, ay = at(-13, v) local bx, by = at(13, v)
    local bar = c:line({ {ax,ay}, {bx,by} }, 2):clip(outer)
    N.lay(c, bar, R.wood, 0, { R = 1 })
  end
  N.lay(c, frame, R.wood, 0, { R = 1.5 })
  -- shoe (seen from above), along the same axis
  local shoe, sn = G.oval(cx - 1, cy + 1, 6.5, 11, ang)
  local hx, hy = at(0, 5)
  W.sep(c, shoe, inner:copy():add(frame), ink)
  W.toneN(c, shoe, sn, R.leather)
  -- ankle opening at the heel end: lining ring
  local ox, oy = at(-0.5, 6.5)
  local open = G.oval(ox - 1, oy, 4, 4.5, ang)
  N.lay(c, open, R.lining, 0, { R = 1 })
  c:fillMask(G.oval(ox - 1, oy, 2.4, 2.8, ang), R.leather[1])
  -- toe binding strap across the shoe
  local s1x, s1y = at(-9, -3) local s2x, s2y = at(9, -3)
  local strap = c:line({ {s1x,s1y}, {s2x,s2y} }, 2)
  W.sep(c, strap, shoe, R.leather[1])
  N.lay(c, strap, R.strap, 0, { R = 1 })
  local bx, by = at(5, -3)
  c:put(math.floor(bx), math.floor(by), R.brass[5])
  -- quirk: tuft of snow on the toe
  local tx2, ty2 = at(0, -10)
  local tuft = c:ellipse(tx2 + 1, ty2, 3.2, 2.2):add(c:ellipse(tx2 - 2, ty2 + 1, 2, 1.6))
  W.sep(c, tuft, shoe, N.snow[2])
  N.lay(c, tuft, N.snow, 1, { R = 1.5 })
  c:put(math.floor(tx2), math.floor(ty2) - 2, N.snow[6])
  N.save(c, "footwear-3-lakeland-snowshoe")
end

---------------------------------------------------------------- 4 prairie stitch boots
local function prairie()
  local c = N.canvas("footwear-4-prairie-stitch-boots")
  local function boot(dx, dy, bias)
    local B = {}
    local shaft = c:poly{ {14+dx,20+dy}, {20+dx,22+dy}, {29+dx,20+dy}, {29+dx,40+dy}, {14+dx,42+dy} }
    local foot = c:poly{ {14+dx,36+dy}, {28+dx,36+dy}, {36+dx,39+dy}, {44+dx,42+dy}, {47+dx,45+dy}, {44+dx,48+dy}, {14+dx,48+dy} }
    local tab = c:rrect(13+dx, 14+dy, 17+dx, 22+dy, 1)
    local heel = c:rect(14+dx, 48+dy, 21+dx, 52+dy)
    local sole = c:rect(21+dx, 48+dy, 46+dx, 49+dy)
    local body = shaft:copy():add(foot)
    B.all = body:copy():add(tab):add(heel):add(sole)
    B.paint = function()
      local b = bias or 0
      N.lay(c, tab, R.strap, b, { R = 1 })
      c:fillMask(c:rect(14+dx, 16+dy, 16+dx, 19+dy), R.strap[1])
      W.sep(c, body, tab, ink)
      local bi = N.lay(c, body, R.leather, b, { R = 5, hs = 0.7 })
      -- top welt + seam where shaft meets vamp
      N.top(shaft, function(x, y) c:put(x, y, R.leather[2 + (b < 0 and 0 or 1)]) end)
      for x = 15+dx, 28+dx do c:put(x, 37+dy, R.leather[2]) end
      W.put(c, { {29+dx,38+dy}, {30+dx,38+dy}, {31+dx,39+dy}, {32+dx,39+dy} }, R.leather[2])
      -- stitch row along the vamp
      for x = 17+dx, 41+dx, 3 do local y = (x < 30+dx) and 39+dy or math.floor(39+dy + (x - 30 - dx) * 0.3)
        if body:has(x, y) then c:put(x, y, R.brass[4 + b]) end end
      -- heel and sole
      N.lay(c, heel, N.rubber, b - 0, { R = 1 })
      W.hline(c, 14+dx, 21+dx, 48+dy, N.rubber[5 + b])
      c:fillMask(sole, N.rubber[2 + (b < 0 and 0 or 1)])
      W.hline(c, 22+dx, 45+dx, 48+dy, N.rubber[4 + b])
      return bi
    end
    return B
  end
  local back = boot(11, -5, -1)
  local front = boot(0, 0, nil)
  back.paint()
  W.sep(c, front.all, back.all, ink)
  front.paint()
  -- quirk: one golden wheat ear stitched up the front shaft
  W.vline(c, 21, 25, 35, R.brass[3])
  for i, y in ipairs({ 25, 28, 31 }) do
    W.put(c, { {20,y}, {19,y-1} }, R.brass[5]) W.put(c, { {22,y}, {23,y-1} }, R.brass[4])
  end
  c:put(21, 23, R.brass[6]) c:put(21, 24, R.brass[5])
  -- leather pop
  W.vline(c, 16, 25, 34, R.leather[6]) c:put(16, 26, cream)
  W.put(c, { {37,41}, {38,41}, {39,42} }, R.leather[6])
  N.save(c, "footwear-4-prairie-stitch-boots")
end

---------------------------------------------------------------- 5 loon-down slippers
local function slippers()
  local c = N.canvas("footwear-5-loon-down-slippers")
  local function slip(dx, dy, bias)
    local B = {}
    local body = c:ellipse(29+dx, 41+dy, 15, 8.5):add(c:ellipse(23+dx, 31+dy, 10, 11))
    local sole = c:rrect(13+dx, 47+dy, 44+dx, 51+dy, 2)
    local cuff = c:rrect(12+dx, 15+dy, 34+dx, 23+dy, 2)
    B.all = body:copy():add(sole):add(cuff)
    B.paint = function()
      local b = bias or 0
      N.lay(c, sole, N.dkcheck, b + 1, { R = 1 })
      W.sep(c, body, sole, ink)
      -- puffy baffles: each band lit on its own
      local y0 = 22 + dy
      while y0 < 50 + dy do
        local band = body:copy():clip(c:rect(0, y0, 63, y0 + 5))
        if band:count() > 0 then
          N.lay(c, band, N.slate, b, { R = 2.5, cuts = { .22, .4, .56, .72, .88 } })
          N.bottom(band, function(x, y) if body:has(x, y + 1) then c:put(x, y, N.slate[1]) end end)
        end
        y0 = y0 + 6
      end
      -- knit rib cuff
      local ci = N.lay(c, cuff, N.knit, b, { R = 2 })
      cuff:each(function(x, y) if (x - dx) % 3 == 0 then local i = ci[K(x, y)] c:put(x, y, N.knit[math.max(1, i - 1)]) end end)
      N.bottom(cuff, function(x, y) c:put(x, y, N.knit[1]) end)
    end
    return B
  end
  local back = slip(12, -6, -1)
  local front = slip(0, 0, nil)
  back.paint()
  W.sep(c, front.all, back.all, ink)
  front.paint()
  -- down gloss
  W.put(c, { {17,26}, {18,26}, {19,25} }, N.slate[6]) c:put(18, 25, cream)
  W.put(c, { {20,37}, {21,37}, {22,37} }, N.slate[6])
  -- quirk: a loon feather tucked in the cuff
  local f = G.tube({ {30,18}, {34,12}, {38,8}, {43,3} }, function(t) return 3.6 * math.sin(math.pi * math.min(0.97, t * 0.9 + 0.12)) end)
  W.sep(c, f, front.all, ink)
  f:each(function(x, y)
    local chk = ((x + y) % 3 == 0) and ((x - y) % 2 == 0)
    c:put(x, y, chk and N.snow[5] or N.dkcheck[2])
  end)
  local sh = c:line({ {30,19}, {34,13}, {38,9}, {43,4} }, 1)
  sh:each(function(x, y) if f:has(x, y) then c:put(x, y, N.dkcheck[5]) end end)
  W.put(c, { {29,20}, {28,21} }, N.dkcheck[5])
  N.save(c, "footwear-5-loon-down-slippers")
end

local all = { snowBoots, clog, snowshoe, prairie, slippers }
for i, f in ipairs(all) do if not only or tonumber(only) == i then f() end end
