-- footwear.lua: EA Blossomreach footwear concepts 1..5 (see concepts.md).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local floor = math.floor

---------------------------------------------------------------- 1 hemp-cord sandals
do
  local c = C.canvas("footwear-1-hemp-sandals")
  local function sole(x0, y0)
    local cx = x0 + 8
    return c:ellipse(cx, y0 + 9, 8, 9):add(c:ellipse(cx - .5, y0 + 30, 6.5, 7.5))
      :add(c:poly{ {cx - 8, y0 + 10}, {cx + 8.5, y0 + 10}, {cx + 7, y0 + 30}, {cx - 7, y0 + 30} })
  end
  local function sandal(x0, y0, b, tails)
    local top = sole(x0, y0)
    local edge = top:shift(0, 3):cut(top)
    C.part(c, edge, R.straw, { R = 1, b = b - 2 })
    local i = C.part(c, top, R.hemp, { R = 4, b = b })
    -- braided rows: grooves every 4 px, staggered stitches

    C.retone(c, top, i, R.hemp, function(x, y)
      local r = (y - y0) % 4
      if r == 0 then return -1 end
      if (x + floor((y - y0) / 4) * 2) % 4 == 0 and r == 2 then return -1 end
      if r == 1 and (x + floor((y - y0) / 4) * 2) % 4 == 2 then return 1 end
    end)
    -- rim lip around the top surface
    top:edge():each(function(x, y) if top:has(x, y + 1) == false or x > x0 + 13 then c:put(x, y, R.hemp[2 + (b < 0 and 0 or 1)]) end end)
    -- cords: toe knot to both sides, then along the edges to heel loops
    local cx = x0 + 8
    local cord = R.ember
    local function rope(p, w) local m = C.tube(c, p, w or 1.5, cord, { b = b, cuts = { .2, .4, .6, .78, .92 } }) return m end
    -- heel loop (behind the V)
    rope({ {cx - 6, y0 + 26}, {cx - 5, y0 + 33}, {cx + 5, y0 + 33}, {cx + 6, y0 + 26} }, 1.1)
    -- side holes
    for _, sx in ipairs({ cx - 7, cx + 7 }) do c:fillMask(c:rect(sx - 1, y0 + 19, sx, y0 + 20), R.hemp[1]) end
    rope{ {cx, y0 + 6}, {cx - 5, y0 + 6}, {cx - 7, y0 + 13}, {cx - 7, y0 + 19} }
    rope{ {cx, y0 + 6}, {cx + 5, y0 + 6}, {cx + 8, y0 + 13}, {cx + 7, y0 + 19} }
    -- toe knot
    local kn = c:ellipse(cx, y0 + 6, 2, 2)
    C.part(c, kn, cord, { R = 1, b = b })
    c:put(cx - 1, y0 + 5, cord[6])
    -- loose tie tails trailing off the outer side
    if tails then
      rope({ {cx - 7, y0 + 20}, {cx - 11, y0 + 23}, {cx - 10, y0 + 29}, {cx - 13, y0 + 33} }, .9)
      local ts = c:ellipse(cx - 13, y0 + 34, 1.2, 1.6)
      C.part(c, ts, cord, { R = 1, b = b - 1 })
    end
    return top
  end
  local back = sole(30, 8):add(sole(30, 8):shift(0, 3))
  sandal(30, 8, -1)
  local fm = sole(10, 18):add(sole(10, 18):shift(0, 3))
  C.sep(c, fm, back, C.ink)
  sandal(10, 18, 0, true)
  -- quirk: a fallen plum petal on the front toe
  local pet = c:poly{ {13,20}, {16,18.5}, {18.5,20}, {16.5,23}, {13.5,22.5} }
  C.part(c, pet, R.petal, { R = 1, b = 1 })
  c:put(14, 20, R.petal[6]) c:put(16, 21, R.petal[3]) c:put(15, 21, R.petal[2])
  C.save(c, "footwear-1-hemp-sandals")
end

---------------------------------------------------------------- 2 rain clogs (two-tooth)
do
  local c = C.canvas("footwear-2-rain-clogs")
  local function clog(dx, dy, b)
    local function P(x, y) return { x + dx, y + dy } end
    local A, B, Cc, D = P(6, 26), P(40, 18), P(51, 24), P(17, 32)
    local TH = 5
    local top = c:poly{ A, B, Cc, D }
    local front = c:poly{ D, Cc, { Cc[1], Cc[2] + TH }, { D[1], D[2] + TH } }
    local toe = c:poly{ A, D, { D[1], D[2] + TH }, { A[1], A[2] + TH } }
    local teeth, parts = HP.mask(), {}
    for _, t in ipairs({ .16, .72 }) do
      local px, py = D[1] + t * (Cc[1] - D[1]), D[2] + t * (Cc[2] - D[2])
      local qx, qy = px - (D[1] - A[1]) + 1, py - (D[2] - A[2]) + .5
      local side = c:poly{ { px, py + 2 }, { qx, qy + 2 }, { qx, qy + 10 }, { px, py + 12 } }
      local fr = c:poly{ { px, py + 2 }, { px + 3.5, py + 1.2 }, { px + 3.5, py + 11.2 }, { px, py + 12 } }
      teeth:add(side):add(fr)
      parts[#parts + 1] = { side = side, fr = fr, px = px, py = py }
    end
    local all = top:copy():add(front):add(toe):add(teeth)
    return {
      all = all,
      paint = function()
        for _, p in ipairs(parts) do
          C.part(c, p.side, R.wood, { R = 1, b = b + 1 })
          C.part(c, p.fr, R.wood, { R = 1, b = b - 1 })
          p.fr:each(function(x, y) if not p.fr:has(x - 1, y) then c:put(x, y, R.wood[2 + b]) end end)
          p.side:each(function(x, y) if not p.side:has(x, y + 1) and not p.fr:has(x, y) then c:put(x, y, R.wood[3 + b]) end end)
        end
        C.part(c, toe, R.lacq, { R = 1, b = b + 1 })
        C.part(c, front, R.lacq, { R = 1, b = b - 1 })
        -- glossy lacquer streaks on the faces
        for i = 0, 6 do c:put(D[1] + 3 + i, floor(D[2] + 1 - i * .18 + .5), R.lacq[5 + b]) end
        c:put(A[1] + 2, A[2] + 2, R.lacq[6 + b]) c:put(A[1] + 3, A[2] + 2, R.lacq[6 + b])
        local i = C.part(c, top, R.wood, { R = 3, b = b + 1, cuts = { .2, .36, .52, .7, .88 } })
        C.retone(c, top, i, R.wood, function(x, y) if floor(y - dy + (x - dx) * 0.235) % 3 == 0 and X.hash(x, y, 9) < .7 then return -1 end end)
        top:edge():each(function(x, y) if not top:has(x, y + 1) then c:put(x, y, R.lacq[4 + b]) end end)
        top:edge():each(function(x, y) if not top:has(x, y - 1) and not top:has(x - 1, y) then c:put(x, y, R.wood[6]) end end)
        -- thong: toe knot to the two side holes, standing up as a tent
        local T = { A[1] + 13, A[2] + 1.4 }
        local S1 = { A[1] + 20, A[2] - 2.6 }
        local S2 = { A[1] + 27.5, A[2] + 1.6 }
        c:put(floor(S1[1]), floor(S1[2]) + 1, R.wood[1]) c:put(floor(S2[1]), floor(S2[2]) + 1, R.wood[1])
        C.tube(c, { T, { T[1] + 1, T[2] - 8 }, { S1[1] - 3, S1[2] - 7 }, S1 }, 1.2, R.jade, { b = b - 1 })
        C.tube(c, { T, { T[1] + 2, T[2] - 8 }, { S2[1] - 4, S2[2] - 9 }, S2 }, 1.4, R.jade, { b = b })
        local kn = c:ellipse(T[1], T[2], 1.8, 1.5)
        C.part(c, kn, R.ember, { R = 1, b = b })
        c:put(floor(T[1]) - 1, floor(T[2]) - 1, R.ember[6 + b])
      end,
    }
  end
  local back = clog(8, -11, -1)
  local fr = clog(0, 0, 0)
  back.paint()
  C.sep(c, fr.all, back.all, C.ink)
  fr.paint()
  -- quirk: snail climbing the front tooth
  local sx, sy = 17, 37
  local body = c:poly{ {sx - 3, sy + 4}, {sx + 3, sy + 4}, {sx + 4, sy + 2}, {sx + 5, sy - 1}, {sx + 3, sy + 2}, {sx - 3, sy + 2} }
  c:fillMask(body, "#b8c49a") C.hline(c, sx - 3, sx + 2, sy + 4, "#8a9a74")
  c:put(sx + 5, sy - 2, "#8a9a74") c:put(sx + 6, sy - 2, "#8a9a74")
  local shell = c:ellipse(sx - 1, sy, 3, 3)
  C.part(c, shell, R.autumn, { R = 2, b = -1 })
  C.put(c, { {sx - 1, sy}, {sx, sy - 1}, {sx - 1, sy - 2}, {sx - 2, sy - 1} }, R.autumn[1])
  c:put(sx - 3, sy - 2, R.autumn[6])
  C.save(c, "footwear-2-rain-clogs")
end

---------------------------------------------------------------- 3 indigo stitch boots
do
  local c = C.canvas("footwear-3-indigo-boots")
  local function boot(dx, dy, b)
    local shaft = c:poly{ {12+dx,22+dy}, {27+dx,22+dy}, {28+dx,40+dy}, {12+dx,42+dy} }
    local foot = c:rrect(12+dx, 36+dy, 30+dx, 49+dy, 3):add(c:ellipse(33+dx, 44+dy, 7, 5.5))
      :add(c:poly{ {24+dx,35+dy}, {31+dx,37+dy}, {37+dx,40+dy}, {27+dx,44+dy} })
    local body = shaft:copy():add(foot)
    local sole = c:rrect(11+dx, 48+dy, 41+dx, 53+dy, 2)
    local all = body:copy():add(sole)
    return { all = all, paint = function()
      C.part(c, sole, R.oat, { R = 1, b = b })
      C.hline(c, 12+dx, 40+dx, 48+dy, R.oat[5 + b])
      for x = 13+dx, 39+dx, 2 do c:put(x, 53+dy, R.oat[1]) end
      local bm = C.bias(body, b)
      local i = C.vcyl(c, shaft, R.indigo, 12+dx, 28+dx, { bias = bm, cuts = { .2, .36, .52, .7, .9 } })
      C.lit(c, foot:copy():cut(shaft), R.indigo, { R = 6, hs = .6, bias = bm, cuts = { .2, .36, .52, .7, .9 } })
      -- running-stitch rows (2 on 1 off, staggered)
      for row, y in ipairs({ 27, 31, 35, 39, 43, 46 }) do
        for x = 13 + dx, 40 + dx do
          if body:has(x, y + dy) and body:has(x, y + dy - 1) and body:has(x, y + dy + 1) and (x + row) % 3 ~= 0 then
            c:put(x, y + dy, R.indigoL[(x < 22 + dx) and 5 + b or 4 + b])
          end
        end
      end
      -- split toe
      for y = 41, 47 do c:put(34 + dx, y + dy, R.indigo[1]) end
      c:put(35 + dx, 40 + dy, R.indigo[2])
      -- collar opening and rim
      local op = c:ellipse(19.5+dx, 22+dy, 7, 1.6)
      c:fillMask(op, R.indigo[1])
      C.hline(c, 13+dx, 26+dx, 24+dy, R.indigoL[3 + b])
      C.hline(c, 13+dx, 21+dx, 25+dy, R.indigoL[4 + b])
      -- brass hooks at the back of the ankle
      for _, y in ipairs({ 29, 33, 37 }) do c:put(12+dx, y+dy, R.brass[4 + b]) c:put(13+dx, y+dy, R.brass[3 + b]) end
    end }
  end
  local bk = boot(11, -5, -1)
  local fr = boot(0, 0, 0)
  bk.paint()
  C.sep(c, fr.all, bk.all, C.ink)
  fr.paint()
  C.vline(c, 14, 27, 37, R.indigo[6]) c:put(15, 28, R.indigoL[5])
  -- quirk: golden ginkgo leaf tucked into the front cuff
  local fan = c:poly{ {13,14}, {16,10}, {21,8.5}, {26,10}, {29,13}, {23,19}, {21,19} }
  C.part(c, fan, R.brass, { R = 2, b = 0 })
  C.put(c, { {21,9}, {21,10}, {21,11}, {20,9} }, R.brass[1])  -- notch
  C.put(c, { {17,13}, {19,15}, {25,13}, {23,15} }, R.brass[3])
  c:put(15, 12, R.brass[6]) c:put(16, 11, R.brass[6])
  C.vline(c, 22, 20, 23, R.straw[2]) c:put(23, 19, R.straw[3])
  C.save(c, "footwear-3-indigo-boots")
end

---------------------------------------------------------------- 4 steppe felt boots (upturned toe)
do
  local c = C.canvas("footwear-4-felt-boots")
  local function boot(dx, dy, b)
    local shaft = c:poly{ {13+dx,8+dy}, {29+dx,8+dy}, {30+dx,42+dy}, {13+dx,44+dy} }
    local foot = c:rrect(13+dx, 36+dy, 34+dx, 50+dy, 5)
    local toe, tn, TT = G.tube({ {29+dx,45.5+dy}, {37+dx,47+dy}, {43+dx,44+dy}, {44+dx,36.5+dy} }, function(t) return 4.6 - t * 2.4 end)
    local body = shaft:copy():add(foot):add(toe)
    local sole = G.tube({ {13+dx,50.5+dy}, {28+dx,52+dy}, {40+dx,51+dy}, {47+dx,42+dy} }, function(t) return 1.5 - t * .5 end)
    sole:cut(body)
    local all = body:copy():add(sole)
    return { all = all, paint = function()
      C.part(c, sole, R.sole, { R = 1, b = b + 1 })
      local bm = C.bias(body, b)
      local i = C.vcyl(c, shaft, R.fleece, 13+dx, 30+dx, { bias = bm })
      C.lit(c, foot:copy():add(toe):cut(shaft), R.fleece, { R = 6, hs = .6, bias = bm })
      C.speckle(c, body, i, R.fleece, .06, 3)
      -- rust leather toe cap on the curl
      local cap = HP.mask() toe:each(function(x, y) if TT[K(x, y)] > .55 and not foot:has(x, y) then cap:set(x, y) end end)
      cap:edge():each(function(x, y) if not cap:has(x + 1, y) or not cap:has(x, y + 1) then c:put(x, y, R.fleece[2 + b]) end end)
      -- rust bands: top and ankle, each with a cream zigzag stitch
      for _, yy in ipairs({ { 8, 14 }, { 30, 34 } }) do
        local band = shaft:copy():clip(c:rect(10+dx, yy[1]+dy, 32+dx, yy[2]+dy))
        C.vcyl(c, band, R.yarnA, 13+dx, 30+dx, { bias = C.bias(band, b) })
        local zy = floor((yy[1] + yy[2]) / 2)
        for x = 14+dx, 29+dx do c:put(x, ((x % 2 == 0) and zy or zy + 1) + dy, R.lining[5 + b]) end
        C.hline(c, 13+dx, 29+dx, yy[2] + 1 + dy, R.fleece[2 + b])
      end
      C.hline(c, 14+dx, 28+dx, 8+dy, R.yarnA[6 + b])
    end }
  end
  local bk = boot(11, -8, -1)
  local fr = boot(0, 0, 0)
  bk.paint()
  C.sep(c, fr.all, bk.all, C.ink)
  fr.paint()
  C.vline(c, 15, 17, 28, R.fleece[6]) C.vline(c, 15, 37, 40, R.fleece[6])
  -- quirk: wool pompom on the curled toe tip
  local pom = c:ellipse(44.5, 34, 2.8, 2.8)
  C.part(c, pom, R.yarnA, { R = 2, b = 0 })
  c:put(43, 32, R.yarnA[6]) c:put(44, 32, R.yarnA[6]) c:put(46, 36, R.yarnA[2])
  C.save(c, "footwear-4-felt-boots")
end

---------------------------------------------------------------- 5 snow straw boots
do
  local c = C.canvas("footwear-5-snow-straw-boots")
  local function boot(dx, dy, b)
    local shaft = c:poly{ {16+dx,10+dy}, {29+dx,10+dy}, {34+dx,46+dy}, {11+dx,46+dy} }
    local foot = c:rrect(10+dx, 38+dy, 36+dx, 51+dy, 5):add(c:ellipse(37+dx, 46+dy, 7, 5))
    local body = shaft:copy():add(foot)
    -- shaggy jagged hems hang below each tier: add fringe teeth along the bottom
    local fr = HP.mask()
    for x = 10+dx, 44+dx do if (x % 3) ~= 0 then local yb = 51 + dy if x > 36 + dx then yb = 50 + dy end if body:has(x, yb) then fr:set(x, yb + 1) end end end
    body:add(fr)
    return { all = body, paint = function()
      local bm = C.bias(body, b)
      local i = C.vcyl(c, shaft:copy():add(fr), R.straw, 11+dx, 34+dx, { bias = bm })
      C.lit(c, foot:copy():cut(shaft), R.straw, { R = 5, hs = .6, bias = bm })
      -- vertical straw strands
      body:each(function(x, y)
        if (x * 2 + floor(y / 8)) % 5 == 0 then local p = c:get(x, y) for j = 2, 6 do if p == R.straw[j] then c:put(x, y, R.straw[j - 1]) end end end
      end)
      -- tiers: jagged dark hem line then a lit lip under it
      for _, ty in ipairs({ 19, 28, 37 }) do
        for x = 8+dx, 46+dx do
          local y = ty + dy + ((x % 3 == 0) and 1 or 0) + ((x % 3 == 1) and -1 or 0)
          if body:has(x, y) and body:has(x, y - 2) then
            c:put(x, y, R.straw[1]) if body:has(x, y + 1) then c:put(x, y + 1, R.straw[(x < 22 + dx) and 5 + b or 4 + b]) end
          end
        end
      end
      -- top opening
      local op = c:ellipse(22.5+dx, 10+dy, 6.5, 1.6)
      c:fillMask(op, R.straw[1])
      C.hline(c, 17+dx, 28+dx, 12+dy, R.straw[6 + b])
      -- shin tie rope with knot and tails
      C.tube(c, { {16+dx,15+dy}, {21+dx,16.5+dy}, {26+dx,16.5+dy}, {30+dx,15+dy} }, 1.1, R.strap, { b = b + 1 })
      local kn = c:ellipse(18+dx, 16+dy, 1.6, 1.6)
      C.part(c, kn, R.strap, { R = 1, b = b + 1 })
      C.tube(c, { {17+dx,17+dy}, {15+dx,20+dy}, {16+dx,22+dy}, {15+dx,24+dy} }, .8, R.strap, { b = b + 1 })
    end }
  end
  local bk = boot(11, -5, -1)
  local fr = boot(0, 0, 0)
  bk.paint()
  C.sep(c, fr.all, bk.all, C.ink)
  fr.paint()
  -- quirk: a tuft of snow resting on the front boot's rim and toe
  local sn = c:ellipse(20, 9, 5, 2.2):add(c:ellipse(25, 8.5, 3, 2)):add(c:ellipse(16.5, 10, 2, 1.5))
  C.part(c, sn, R.snow, { R = 2, b = 1 })
  c:put(19, 8, R.snow[6]) c:put(24, 7, R.snow[6])
  local sn2 = c:ellipse(39, 41, 3, 1.4)
  C.part(c, sn2, R.snow, { R = 1, b = 1 })
  C.save(c, "footwear-5-snow-straw-boots")
end
