-- footwear.lua: five ESA (Thornacre Savanna) footwear concepts. See concepts.md.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R = C.HP, C.X, C.K, C.R
local floor, sqrt, sin, max, min, abs = math.floor, math.sqrt, math.sin, math.max, math.min, math.abs
local ink = C.ink
local W = C
local W_sep

------------------------------------------------------------------ 1 acacia sandals (top-down pair)
local function sandals(c)
  local function fw(v)
    if v < -19 or v > 19 then return -1 end
    if v < -9 then local t = (v + 9) / 10.5 return 7.4 * sqrt(max(0, 1 - t * t)) end
    if v < 9 then return 7.4 - (v + 9) / 18 * 1.9 end
    local t = (v - 9) / 10.5 return 5.5 * sqrt(max(0, 1 - t * t))
  end
  local function make(cx, cy, ang, mir)
    return function(dx, dy, b)
      local S = {}
      local m, U, V = C.rot(cx + dx, cy + dy, ang, function(u, v) return abs(u) <= fw(v) end)
      local th = m:shift(1, 3):cut(m)
      S.all = m:copy():add(th)
      S.paint = function()
        -- stacked sole thickness: two layers
        th:each(function(x, y) c:put(x, y, (m:has(x, y - 2) or m:has(x - 1, y - 2)) and R.sole[3 + b] or R.sole[5 + b]) end)
        th:each(function(x, y) if not th:has(x, y + 1) then c:put(x, y, R.sole[2 + b]) end end)
        -- footbed
        local bias = C.bmap(m, b)
        m:each(function(x, y)
          local k = K(x, y) local u, v = U[k], V[k]
          if ((v + 11) / 5) ^ 2 + (u / 4.5) ^ 2 < 1 or ((v - 11) / 4.5) ^ 2 + (u / 3.5) ^ 2 < 1 then bias[k] = (bias[k] or 0) - 1 end
        end)
        C.lit(c, m, R.lining, { R = 3, bias = bias })
        m:edge():each(function(x, y) c:put(x, y, R.leather[3 + b]) end)
        -- crossed toe straps
        local function band(f)
          local s = HP.mask()
          m:grow(1):each(function(x, y)
            local k = K(x, y)
            local u, v = U[k], V[k]
            if not u then
              local xx, yy = x + .5 - (cx + dx), y + .5 - (cy + dy)
              u = xx * math.cos(ang) + yy * math.sin(ang)
              v = -xx * math.sin(ang) + yy * math.cos(ang)
            end
            if mir then u = -u end
            if f(u, v) then s:set(x, y) end
          end)
          return s
        end
        local sA = band(function(u, v) return v > -15 and v < -3 and abs(u - 0.75 * (v + 9)) < 1.6 end)
        local sB = band(function(u, v) return v > -15 and v < -3 and abs(u + 0.75 * (v + 9)) < 1.6 end)
        local sC = band(function(u, v) return v > 4.5 and v < 7.8 end)
        C.lit(c, sB, R.madder, { R = 1, b = b - 1 })
        W_sep(c, sA, sB)
        C.lit(c, sA, R.madder, { R = 1, b = b })
        W_sep(c, sC, m)
        C.lit(c, sC, R.madder, { R = 1, b = b })
        -- a lit stitch on the toe straps
        sA:each(function(x, y) if (x + y) % 3 == 0 and sA:shrink(1):has(x, y) then c:put(x, y, R.madder[6]) end end)
        -- brass buckle on the outer side of the ankle strap
        local bx0, by0, bx1, by1 = sC:bbox()
        local bk = mir and bx0 or bx1 - 2
        local buck = c:rect(bk, by0, bk + 2, by1)
        C.lit(c, buck, R.brass, { R = 1, b = b })
        c:put(bk + 1, floor((by0 + by1) / 2), R.strap[2])
        S.U, S.V, S.m = U, V, m
      end
      return S
    end
  end
  W_sep = function(cc, front, back) front:grow(1):cut(front):clip(back):each(function(x, y) cc:put(x, y, R.madder[1]) end) end
  local L = make(22, 30, -0.1, true)(0, 0, -1)
  local Rr = make(41, 34, 0.1, false)(0, 0, 0)
  L.paint()
  Rr.paint()
  -- quirk: a long acacia thorn stuck in the outer sole edge of the right sandal
  local th = c:line({ {48,31}, {58,26} }, 1):add(c:line({ {48,32}, {53,30} }, 1))
  C.paint(c, th, function(x, y) return (x < 51) and R.wool[3] or ((y < 28 or x > 55) and R.wool[6] or R.wool[5]) end)
  W.put(c, { {50,32}, {52,31} }, R.wool[3])
  c:put(19, 17, C.cream)
end

------------------------------------------------------------------ 2 highland trek boots
local function trek(c)
  local function make(dx, dy, b)
    local B = {}
    local shaft = c:poly{ {13+dx,17+dy}, {28+dx,17+dy}, {29+dx,40+dy}, {12+dx,42+dy} }
    local foot = c:rrect(12+dx, 36+dy, 31+dx, 49+dy, 3):add(c:ellipse(35+dx, 45+dy, 6.5, 4.5))
      :add(c:poly{ {25+dx,32+dy}, {32+dx,36+dy}, {39+dx,41+dy}, {28+dx,44+dy} })
    local body = shaft:copy():add(foot)
    local sole = c:rrect(11+dx, 49+dy, 42+dx, 52+dy, 1)
    local cuff = c:rrect(11+dx, 12+dy, 30+dx, 19+dy, 2)
    B.all = body:copy():add(sole):add(cuff)
    B.paint = function()
      C.vcyl(c, shaft, R.coffee, 12+dx, 29+dx, { b = b })
      C.lit(c, foot:copy():cut(shaft), R.coffee, { R = 6, hs = 0.6, b = b })
      -- suede nap speckle
      body:each(function(x, y) if X.hash(x, y, 7) < 0.08 then local v = c:get(x, y) end end)
      -- toe cap seam + heel counter seam
      for x = 30+dx, 40+dx do if foot:has(x, 44+dy) then c:put(x, 44+dy, R.coffee[2 + max(b, -1)]) end end
      for y = 38+dy, 48+dy do c:put(16+dx, y, R.coffee[2]) end
      -- laces: eyelets down the instep with cream criss-cross
      for i = 0, 5 do
        local x, y = floor(26 + i * 1.3 + .5) + dx, 21 + i * 3 + dy
        c:put(x, y, R.brass[3 + b]) c:put(x + 1, y, R.brass[5 + b])
        if i < 5 then c:put(x - 1, y + 1, R.canvas[6 + b]) c:put(x, y + 1, R.canvas[5 + b]) c:put(x + 1, y + 2, R.canvas[4 + b]) end
      end
      -- sole with tread
      C.lit(c, sole, R.sole, { R = 1 })
      for x = 12+dx, 41+dx, 3 do c:put(x, 52+dy, R.sole[1]) end
      W.hline(c, 12+dx, 41+dx, 49+dy, R.sole[5])
      W.hline(c, 12+dx, 29+dx, 20+dy, R.coffee[1])
      -- striped handloom cuff
      local idx = C.lit(c, cuff, R.yarnA, { R = 2, b = b })
      local rows = { R.yarnA, R.yarnA, R.canvas, R.yarnB, R.yarnB, R.canvas, R.yarnA, R.yarnA }
      cuff:each(function(x, y) local r = rows[(y - 12 - dy) + 1] or R.yarnA c:put(x, y, r[idx[K(x, y)]]) end)
    end
    return B
  end
  local f = C.pair(c, make, 11, -5)
  -- suede lit streak
  W.vline(c, 14, 22, 36, R.coffee[6]) c:put(14, 23, R.suede[6])
  -- quirk: a pair of red coffee cherries tied to the lace end
  W.put(c, { {31,20}, {32,21}, {33,22}, {33,23} }, R.canvas[5])
  C.bead(c, 33, 26, 1.7, R.ember, R.ember[6])
  C.bead(c, 36, 25, 1.7, R.ember, R.ember[6])
  W.put(c, { {34,22}, {35,21}, {36,21} }, R.leafg[4]) c:put(37, 20, R.leafg[5])
end

------------------------------------------------------------------ 3 sisal slippers
local function slippers(c)
  local herring = function(x, y)
    if floor(x / 3) % 2 == 0 then if (x + y) % 3 == 0 then return -1 end
    elseif (x - y) % 3 == 0 then return -1 end
  end
  local function make(dx, dy, b)
    local S = {}
    local up = c:ellipse(33+dx, 40+dy, 16, 12):add(c:rrect(8+dx, 31+dy, 30+dx, 48+dy, 5))
    up:cut(c:rect(0, 48+dy, 63, 63))
    local open = c:ellipse(19+dx, 32+dy, 9, 2.4)
    local sole = c:rrect(7+dx, 47+dy, 50+dx, 51+dy, 2)
    up:cut(c:rect(0, 0, 30+dx, 30+dy))
    S.all = up:copy():add(sole)
    S.paint = function()
      local idx = C.lit(c, up, R.sisal, { R = 5, b = b, cuts = { .22, .38, .54, .7, .88 } })
      W.retone(c, up, idx, R.sisal, herring)
      -- opening: dark inside with a madder-stitched rim
      local inside = open:copy():clip(up)
      c:fillMask(inside, R.sisal[1])
      inside:each(function(x, y) if y >= 33 + dy then c:put(x, y, R.umber[3]) end end)
      inside:grow(1):cut(inside):clip(up):each(function(x, y) c:put(x, y, R.madder[(x % 2 == 0) and 4 + b or 3 + b]) end)
      -- madder band across the vamp
      up:each(function(x, y) local d = abs((x - dx - 36) + (y - dy - 40) * 0.35) if d < 1 then c:put(x, y, R.madder[3 + b + ((y % 2 == 0) and 1 or 0)]) end end)
      -- coiled rope sole
      local si = C.lit(c, sole, R.sisal, { R = 1, b = b - 1 })
      sole:each(function(x, y) if (x + y) % 3 == 0 then c:put(x, y, R.sisal[2 + b + 1]) end end)
      W.hline(c, 8+dx, 49+dx, 47+dy, R.sisal[5 + b])
    end
    return S
  end
  C.pair(c, make, 9, -8)
  -- quirk: green aloe sprig tucked into the heel
  local function spike(pts, light)
    local m = c:line(pts, 1)
    m:each(function(x, y) c:put(x, y, R.leafg[light]) end)
  end
  local leaf = HP.mask()
  for _, p in ipairs({ { {14,32}, {12,26}, {10,21} }, { {16,32}, {17,26}, {19,21} }, { {15,32}, {15,25}, {14,19} } }) do leaf:add(c:line(p, 2)) end
  leaf:cut(c:rect(0, 33, 63, 63))
  C.lit(c, leaf, R.leafg, { R = 1 })
  W.put(c, { {10,20}, {14,18}, {19,20} }, R.leafg[5])
  W.put(c, { {11,24}, {18,24}, {13,22} }, R.leafg[6])
  c:put(16, 28, R.leafg[2])
  c:put(28, 31, C.cream) c:put(29, 31, R.sisal[6])
end

------------------------------------------------------------------ 4 stripe gaiters
local function gaiters(c)
  local function make(dx, dy, b)
    local S = {}
    local tube = c:poly{ {11+dx,9+dy}, {29+dx,9+dy}, {28+dx,41+dy}, {12+dx,41+dy} }
    local shoe = c:rrect(11+dx, 38+dy, 30+dx, 49+dy, 3):add(c:ellipse(33+dx, 45+dy, 6, 4.5))
    local sole = c:rrect(10+dx, 49+dy, 40+dx, 51+dy, 1)
    local rim = c:rrect(10+dx, 6+dy, 30+dx, 10+dy, 2)
    S.all = tube:copy():add(shoe):add(sole):add(rim)
    S.paint = function()
      C.lit(c, shoe, R.leather, { R = 5, hs = .6, b = b - 1 })
      W.hline(c, 31+dx, 38+dx, 45+dy, R.leather[2])
      C.lit(c, sole, R.sole, { R = 1 })
      W.hline(c, 11+dx, 39+dx, 49+dy, R.sole[5])
      W.sep(c, tube, shoe, R.leather[1])
      local idx = C.vcyl(c, tube, R.umber, 11+dx, 29+dx, { b = b, cuts = { .2, .36, .52, .68, .86 } })
      tube:each(function(x, y)
        local band = floor((y - dy + (x - dx - 11) * 0.35) / 3) % 2
        local i = idx[K(x, y)]
        c:put(x, y, band == 0 and R.umber[min(6, i + 1)] or R.canvas[i])
      end)
      -- lower edge flares over the shoe
      W.hline(c, 12+dx, 28+dx, 41+dy, R.umber[2])
      -- rolled top rim
      C.lit(c, rim, R.canvas, { R = 2, b = b })
      W.hline(c, 11+dx, 29+dx, 9+dy, R.canvas[2 + b])
      -- tie cord around the top
      for x = 12+dx, 28+dx do c:put(x, 13+dy, ((x % 3) == 0) and R.strap[2] or R.strap[4 + b]) end
    end
    return S
  end
  C.pair(c, make, 11, -5)
  -- knot + tail-hair tassel on the front gaiter
  C.bead(c, 29, 13, 1.4, R.strap)
  local tas = HP.mask()
  for i, p in ipairs({ { {29,15}, {30,24} }, { {30,15}, {32,23} }, { {31,14}, {33,22} } }) do tas:add(c:line(p, 1)) end
  W.sep(c, tas, c:rect(30, 4, 50, 60), ink)
  tas:each(function(x, y) c:put(x, y, (y > 20) and R.sand[6] or ((x + y) % 2 == 0 and R.sand[4] or R.sand[3])) end)
  W.hline(c, 29, 32, 16, R.madder[3])
  W.vline(c, 13, 15, 36, R.canvas[6])
  c:put(13, 7, C.cream)
end

------------------------------------------------------------------ 5 baobab clogs
local function clogs(c)
  local function make(dx, dy, b)
    local S = {}
    local body = c:poly{ {10+dx,25+dy}, {24+dx,25+dy}, {31+dx,30+dy}, {40+dx,32+dy}, {46+dx,28+dy}, {50+dx,22+dy},
      {51.5+dx,26+dy}, {49+dx,36+dy}, {44+dx,44+dy}, {37+dx,48+dy}, {10+dx,48+dy} }
    body:add(c:rrect(9+dx, 25+dy, 22+dx, 48+dy, 3))
    S.all = body:copy()
    S.paint = function()
      local idx = C.lit(c, body, R.wood, { R = 5, b = b, cuts = { .22, .38, .54, .7, .88 } })
      W.retone(c, body, idx, R.wood, function(x, y) if (y + floor(sin((x - dx) / 4.5) * 1.6 + .5)) % 4 == 0 then return -1 end end)
      -- bark-textured lower band
      local band = body:copy():clip(c:rect(0, 42+dy, 63, 63))
      local bi = C.lit(c, band, R.barkg, { R = 1, b = b })
      band:each(function(x, y) if X.hash(x, y, 3) < .25 then c:put(x, y, R.barkg[2]) elseif X.hash(x, y, 9) < .15 then c:put(x, y, R.barkg[5 + b]) end end)
      W.hline(c, 10+dx, 41+dx, 42+dy, R.barkg[5 + b])
      -- foot opening: a dark oval at the top of the heel
      local op = c:ellipse(19+dx, 27+dy, 8, 1.6):clip(body)
      c:fillMask(op, R.wood[1])
      op:each(function(x, y) if not op:has(x, y - 1) then c:put(x, y, R.umber[2]) end end)
      -- leather heel band
      for x = 9+dx, 30+dx do for y = 31+dy, 33+dy do if body:has(x, y) then c:put(x, y, R.strap[(y == 31+dy) and 5 + b or 3 + b]) end end end
      c:put(26+dx, 32+dy, R.brass[5]) c:put(26+dx, 33+dy, R.brass[3])
      -- carved toe line
      for x = 41+dx, 47+dx do local y = floor(34 + (x - 41 - dx) * -1.1 + .5) + dy if body:has(x, y) then c:put(x, y, R.wood[2 + max(b, -1)]) end end
    end
    return S
  end
  C.pair(c, make, 3, -9)
  c:put(13, 29, R.wood[6]) c:put(14, 29, C.cream) W.vline(c, 12, 34, 40, R.wood[6])
  -- quirk: a velvety baobab seed pod hanging from the heel band
  W.put(c, { {9,33}, {8,34}, {7,35}, {6,36}, {6,37} }, R.strap[4])
  local pod = c:ellipse(5, 42, 2.8, 4.4)
  W.sep(c, pod, c:rect(9, 30, 40, 60), ink)
  C.lit(c, pod, R.khaki, { R = 2 })
  c:put(4, 40, R.khaki[6]) W.put(c, { {6,45}, {5,46} }, R.khaki[1])
end

C.run{
  { "footwear-1-acacia-sandals", sandals },
  { "footwear-2-highland-trek-boots", trek },
  { "footwear-3-sisal-slippers", slippers },
  { "footwear-4-stripe-gaiters", gaiters },
  { "footwear-5-baobab-clogs", clogs },
}
