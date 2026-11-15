-- Shop Street pass 2 (polish): repaints every mass from p1 with ink outlines, 4-tone light (upper-left), wall/roof
-- textures, perspective window grids, blank sign boards, awnings, mushroom caps, cobbles, deep-street haze gradient.
-- Panes stay cool and dark (warm light comes in p3). Ramp colours only, opaque, no pure black/white.
-- Signature: return function(c, L, X) ... end
return function(c, L, X)
  local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
  local RA, look, hub, hash = X.RAMPS, X.look, X.HUB, X.hash
  local INK = "#2b1c26"
  local BASE = 250
  local LOC_VP = { 240, 20, 0.12 }
  local HUB_VP = { 300, 0, 0.16 }
  local GLASS, GLASS2, GLASS3 = RA.SLATE[1], RA.SLATE[2], RA.SLATE[3]
  local function R(r, i) return X.R(r, floor(i + .5)) end
  local function fm(m, hex) c:fillMask(m, hex) return m end
  local function poly(pts) return c:poly(pts) end
  local function ppoly(pts) return c:poly(X.P(pts)) end
  local function rect(x0, y0, x1, y1) return c:rect(x0, y0, x1, y1) end
  local function line(pts) return c:line(pts, 1) end
  local function clipY(m, y0, y1) return m:clip(rect(-5, y0, 485, y1)) end
  local function ink(m) c:rim(m, INK) end

  -- 1. deep-street back gradient (far haze at the horizon sinking into shade), dithered through the STONE ramp
  local sky = look.sky
  local G = { X.mix(sky[3], RA.STONE[5], .5), RA.STONE[5], RA.STONE[4], RA.STONE[3], RA.STONE[2], RA.STONE[1] }
  local bay = { { 0, 8, 2, 10 }, { 12, 4, 14, 6 }, { 3, 11, 1, 9 }, { 15, 7, 13, 5 } }
  local function gtone(x, y, bias)
    local t = max(0, (y - 96) / 154)
    local f = 1 + 4.99 * t ^ 0.8 + (bias or 0)
    local i = floor(f)
    local thr = (bay[y % 4 + 1][x % 4 + 1] + .5) / 16
    return G[max(1, min(6, i + ((f - i > thr) and 1 or 0)))]
  end
  for y = 96, BASE + 2 do for x = 0, 479 do c:put(x, y, gtone(x, y)) end end
  -- far silhouettes in the gaps of the street (lighter = further)
  local function farBlock(x0, y0, x1, y1, bias)
    for y = y0, y1 do for x = x0, x1 do c:put(x, y, gtone(x, y, bias)) end end
    for x = x0, x1 do c:put(x, y0, gtone(x, y0, bias - 0.7)) end
  end
  farBlock(262, 128, 273, 250, 0.9) farBlock(274, 148, 285, 250, 1.3)
  farBlock(262, 128, 273, 131, 0.6)
  farBlock(60, 52, 64, 250, 0.9) farBlock(113, 82, 117, 250, 1.0) farBlock(165, 112, 169, 250, 1.1)
  farBlock(330, 150, 334, 250, 1.2) farBlock(378, 150, 382, 250, 1.2) farBlock(426, 150, 430, 250, 1.2)
  farBlock(330, 104, 366, 140, 1.0)
  for x = 0, 479 do for y = 96, 98 do if hash(x, y, 4) > .5 then c:put(x, y, G[1]) end end end

  -- 2. paving (perspective rows get shorter toward the horizon, joints fan out from the vanishing point)
  local function paving(area, ramp, cs, picks, yfrom, yto)
    local rows, y = {}, yfrom
    while y <= yto do
      local h = 2 + floor((y - BASE) / 16)
      rows[#rows + 1] = { y, min(yto, y + h - 1) } y = y + h
    end
    for ri, row in ipairs(rows) do
      local ym = (row[1] + row[2]) / 2 + .5
      local sc = 204 / (ym - 96)
      local off = (ri % 2) * .5
      for yy = row[1], row[2] do
        for x = 0, 479 do
          if area:has(x, yy) then
            local ka = floor((x - 240) * sc / cs + off)
            local kb = floor((x - 1 - 240) * sc / cs + off)
            local idx
            if yy == row[1] or ka ~= kb then idx = 3 - (ramp == RA.STONE and 1 or 0)
            else
              idx = picks[1 + floor(hash(ka, ri, 3) * #picks)]
              if yy == row[1] + 1 and row[2] - row[1] >= 2 then idx = idx + 1 end
            end
            c:put(x, yy, R(ramp, idx))
          end
        end
      end
    end
  end
  local allY = rect(0, BASE, 479, 299)
  local road = ppoly({ { 0, 300 }, { 480, 300 }, { 268, BASE }, { 212, BASE } }):clip(allY)
  local walk = allY:copy():cut(road)
  paving(walk, RA.STONE, 22, { 3, 4, 4, 5 }, BASE, 299)
  paving(road, RA.COB, 12, { 4, 5, 5, 6 }, BASE, 299)
  -- soft shade on the road beside the left kerb (buildings on that side)
  road:each(function(x, y)
    local ex = 212 - 212 * (y - BASE) / 50
    if x - ex < 9 and (x + y) % 2 == 0 then c:put(x, y, R(RA.COB, 3)) end
  end)
  -- kerbs: lit top ring, face ring
  local k1 = clipY(road:grow(1):cut(road), BASE, 299)
  local k2 = clipY(road:grow(2):cut(road:grow(1)), BASE, 299)
  fm(k2, RA.STONE[3]) fm(k1, RA.STONE[6])

  -- 3. terrace slab: ledge, front face, crooked stair (all ink outlined)
  local function blocks(m, ramp, y0, bh, bw, picks)
    m:each(function(x, y)
      local row = floor((y - y0) / bh)
      local ry = (y - y0) % bh
      local off = (row % 2) * floor(bw / 2)
      local rx = (x + off) % bw
      local col = floor((x + off) / bw)
      local idx
      if ry == 0 or rx == 0 then idx = 3 else
        idx = picks[1 + floor(hash(col, row, 7) * #picks)]
        if ry == 1 then idx = idx + 1 end
        if rx == bw - 1 or ry == bh - 1 then idx = idx - 1 end
      end
      c:put(x, y, R(ramp, idx))
    end)
  end
  local ledge = rect(286, 140, 479, 149)
  blocks(ledge, RA.STONE, 140, 5, 15, { 4, 4, 5 })
  for x = 286, 479 do c:put(x, 140, RA.STONE[6]) c:put(x, 149, RA.STONE[2]) end
  ink(ledge)
  local face = ppoly({ { 306, BASE }, { 480, BASE }, { 480, 260 }, { 380, 260 }, { 318, 292 }, { 306, 292 } })
  blocks(face, RA.STONE, BASE, 6, 14, { 4, 4, 5 })
  for x = 306, 479 do c:put(x, BASE, RA.STONE[6]) end
  face:each(function(x, y) -- lower edge and the wedge facing the street fall into shade
    if not face:has(x, y + 1) or not face:has(x + 1, y + 1) then c:put(x, y, RA.STONE[2]) end
    if (x + y) % 2 == 0 and y > 252 and face:has(x, y + 2) == false then c:put(x, y, RA.STONE[3]) end
  end)
  -- stair: stepped left edge, nose / tread / riser per step
  local stair = X.HP.mask()
  for y = BASE, 291 do for x = 286 + floor((y - BASE) / 6), 305 do stair:set(x, y) end end
  stair:each(function(x, y)
    local r = (y - BASE) % 6
    local idx = ({ 6, 5, 4, 4, 4, 3 })[r + 1]
    if x >= 303 then idx = idx - 1 end
    if x == 286 + floor((y - BASE) / 6) then idx = idx - 1 end
    c:put(x, y, R(RA.STONE, idx))
  end)
  for i = 0, 6 do for x = 286 + i, 305 do c:put(x, BASE + 6 * i, RA.STONE[6]) end end
  ink(stair:copy():add(face))

  -- 4. building painter ------------------------------------------------------------------------------
  local function building(box, o)
    local x0, y0, x1, y1 = box[1], box[2], box[3], box[4]
    local m, yb = o.mirror, y1
    local yt = o.roof and (y0 + o.roof) or y0
    local HH = yb - yt
    local xc = (x0 + x1) / 2
    local frac = (yb - y0) / (yb - o.vy)
    local D = max(2, floor((x1 - x0) * 0.30 + .5))
    local d = floor(min(abs((o.vx - xc) * o.k * frac), D * 0.9) + .5)
    local FW = x1 - D - x0
    local WR, FR, TR, AC = o.wall, o.frame, o.trim, o.accent
    local function T(x) if m then return x0 + x1 - x end return x end
    local function P(pts) local r = {} for i, p in ipairs(pts) do r[i] = { T(p[1]), p[2] } end return r end
    local frontM = poly(P{ { x0, yb }, { x1 - D, yb }, { x1 - D + d, yt }, { x0 + d, yt } })
    local sideM = poly(P{ { x1 - D, yb }, { x1, yb }, { x1, yt }, { x1 - D + d, yt } })
    local roofM = o.roof and poly(P{ { x0 + d - 2, yt }, { x0 + d + 1, y0 }, { x1, y0 }, { x1, yt } }) or X.HP.mask()
    frontM:cut(roofM) sideM:cut(roofM)
    local all = frontM:copy():add(sideM):add(roofM)
    local capTop = y0 + 7
    local denom = max(60, abs(o.vx - xc))
    -- wall-plane mapping: u across the front face (local, inner side to the right), v up from the foot.
    -- Verticals lean with the mass; horizontals tilt toward the horizon vanishing point (fades toward the foot).
    local function M(u, v)
      local lx = x0 + u + d * v / HH
      local yy = yb - v
      local s = o.tk * (96 - yy) / denom
      return T(lx), yy + s * u * min(1, v / 90)
    end
    local function Q(u0, v0, u1, v1) return poly({ { M(u0, v0) }, { M(u1, v0) }, { M(u1, v1) }, { M(u0, v1) } }) end
    local function Ln(u0, v0, u1, v1) local a, b = { M(u0, v0) }, { M(u1, v1) } return line({ a, b }) end
    -- side-plane mapping (w across the side face, converging hard toward the vanishing point)
    local function S(w, v)
      local lx = x1 - D + d * v / HH + w
      local yy = yb - v
      local s = 0.8 * (96 - yy) / max(40, o.vx - lx)
      return T(lx), yy + s * w
    end
    local function SQ(w0, v0, w1, v1) return poly({ { S(w0, v0) }, { S(w1, v0) }, { S(w1, v1) }, { S(w0, v1) } }) end

    -- wall texture index (float around 4) at face coords
    local function stoneT(u, v, bh)
      local row = floor(v / bh)
      local bw = 9 + ((row * 7) % 4)
      local off = (row % 2) * floor(bw / 2)
      local col = floor((u + off) / bw)
      if v % bh == 0 or (u + off) % bw == 0 then return 2 end
      local idx = 3 + ((hash(col, row, 5) > .5) and 1 or 0)
      if v % bh == bh - 1 then idx = idx + 1 end
      return idx
    end
    local function wallT(u, v)
      if v < 9 and o.kind ~= "spice" then return stoneT(u, v, 3) end
      if v == 9 and o.kind ~= "spice" then return 5 end
      if o.kind == "spice" then return stoneT(u, v, 5) end
      if o.kind == "tropic" then
        local row = floor(v / 3)
        if v % 3 == 0 or (u + row * 7) % 17 == 0 then return 3 end
        local idx = (row % 2 == 0) and 4 or 3.6
        if v % 3 == 2 then idx = idx + 1 end
        return idx
      end
      local r = hash(u, v, 1)
      local b = hash(floor(u / 3), floor(v / 2), 2)
      local idx = 4
      if o.kind == "adobe" then b = hash(floor(u / 4), floor(v / 3), 2) end
      if b > .88 then idx = 5 elseif b < .1 then idx = 3 end
      if r > .98 then idx = idx + 1 elseif r < .03 then idx = idx - 1 end
      return idx
    end
    local function eaveAdj(dist, x, y)
      if dist <= 1 then return -2 elseif dist <= 3 then return -1 elseif dist == 4 and (x + y) % 2 == 0 then return -1 end
      return 0
    end

    -- front face pixels
    frontM:each(function(x, y)
      local lxp = m and (x0 + x1 - 1 - x) or x
      local v = yb - 1 - y
      local u = floor(lxp + .5 - x0 - d * (v + .5) / HH)
      local idx = wallT(u, v)
      local adj = 0
      if u <= 1 then adj = adj + 1 end
      if u >= FW - 2 then adj = adj - 1 end
      if o.roof then adj = adj + eaveAdj(y - yt, x, y) else adj = adj + eaveAdj(y - capTop, x, y) end
      if v < 2 then adj = adj - 1 elseif v < 4 and (x + y) % 2 == 0 then adj = adj - 1 end
      local col = R(WR, idx + adj)
      if o.kind == "timber" then   -- half-timber posts and storey beams
        local bm = (v % 36 >= 38 - 36 and false)
        if u <= 1 then col = R(FR, (u == 0) and 4 or 3) elseif u >= FW - 2 then col = R(FR, 2) end
        if v >= 36 and v % 36 >= 0 and (v - 36) % 34 <= 1 then col = R(FR, ((v - 36) % 34 == 0) and 4 or 2) end
      end
      if o.hubBand then
        if u <= 1 then col = R(o.capR, (u == 0) and 5 or 4) elseif u >= FW - 2 then col = R(o.capR, 3) end
        local dB = HH - 14 - v
        if dB == 0 or dB == -1 then col = R(o.capR, 4) elseif dB == -2 then col = R(o.capR, 3) end
        -- moss / petal / ember growth along the foot and under the belt
        local mg = hash(floor(u / 2), floor(v / 2), 9)
        if v >= 4 and v < 10 and mg > .62 + (v - 4) * .06 then col = R(o.capR, 4 - ((x + y) % 2)) end
        if v >= 4 and v < 7 and mg > .5 and u > 1 and u < FW - 2 then col = R(o.capR, 3) end
      end
      c:put(x, y, col)
    end)

    -- side face pixels (darker; shade deepens toward lower right and under the eave)
    sideM:each(function(x, y)
      local lxp = m and (x0 + x1 - 1 - x) or x
      local v = yb - 1 - y
      local w = floor(lxp + .5 - (x1 - D) - d * (v + .5) / HH)
      local idx = wallT(FW + w, v) - 1
      local adj = 0
      if w <= 0 then adj = adj - 1 end
      if lxp >= x1 - 3 then adj = adj - 1 end
      if o.roof then adj = adj + eaveAdj(y - yt, x, y) else adj = adj + eaveAdj(y - capTop, x, y) end
      if v < 3 then adj = adj - 1 end
      c:put(x, y, R(WR, max(1.4, idx + adj)))
    end)

    -- roof: shingle courses tilted with the lean, lit left, eave edge in shade
    if o.roof then
      local RF = o.roofR
      roofM:each(function(x, y)
        local lxp = m and (x0 + x1 - 1 - x) or x
        local s = o.tk * (96 - y) / denom
        local ys = y - floor(s * (lxp - x0) + .5)
        local rel = ys - y0
        local course, row = floor(rel / 3), rel % 3
        local off = (course % 2) * 2
        local jt = (lxp + off) % 5 == 0
        local gv = hash(floor((lxp + off) / 5), course, 6) > .7 and 1 or 0
        local idx
        if row == 0 then idx = 4 + gv elseif row == 1 then idx = 3 + gv else idx = 2 end
        if jt and row ~= 2 then idx = idx - 1 end
        if y == y0 then idx = 5 end
        if lxp >= x1 - 5 then idx = idx - 1 end
        if lxp <= x0 + d + 1 then idx = idx + 1 end
        if y == yt - 1 then idx = 2 end
        c:put(x, y, R(RF, idx))
      end)
    end

    -- door, shop windows, windows, awning, sign
    if not o.skipFront then
      local du0 = floor(FW * 0.3)
      local dw = max(5, floor(FW * 0.34))
      -- door
      fm(Q(du0 - 1, 0, du0 + dw + 1, 23), R(FR, 3))
      fm(Q(du0, 0, du0 + dw, 22), R(FR, 2))
      for u = du0 + 2, du0 + dw - 1, 3 do fm(Ln(u, 0, u, 21), R(FR, 1)) end
      fm(Ln(du0, 21, du0 + dw - 1, 21), R(FR, 4))
      if dw >= 7 then fm(Q(du0 + 2, 15, du0 + dw - 2, 20), GLASS) fm(Q(du0 + 2, 15, du0 + 3, 16), GLASS3) end
      fm(Q(du0 + dw - 2, 9, du0 + dw - 1, 10), R(AC, 5))
      fm(Q(du0 - 3, 0, du0 + dw + 3, 2), R(WR, 5)) fm(Q(du0 - 3, 0, du0 + dw + 3, 1), R(WR, 4))
      -- window builder
      local function win(uc, v0, ww, wh, shut)
        local ul, ur = uc - floor(ww / 2), uc - floor(ww / 2) + ww
        local v1 = v0 + wh
        fm(Q(ul - 1, v0 - 1, ur + 1, v1 + 1), R(FR, 3))
        fm(Q(ur, v0 - 1, ur + 1, v1 + 1), R(FR, 2)) fm(Q(ul - 1, v0 - 1, ur + 1, v0), R(FR, 2))
        fm(Q(ul - 1, v0, ul, v1 + 1), R(FR, 4)) fm(Q(ul - 1, v1, ur + 1, v1 + 1), R(FR, 4))
        fm(Q(ul, v0, ur, v1), GLASS)
        fm(Q(ul, v0, ur, v0 + max(1, floor(wh / 3))), GLASS2)
        fm(Ln((ul + ur) / 2, v0, (ul + ur) / 2, v1 - 1), R(FR, 3))
        fm(Ln(ul, (v0 + v1) / 2, ur - 1, (v0 + v1) / 2), R(FR, 3))
        fm(Q(ul, v1 - 1, ul + 1, v1), GLASS3)
        fm(Q(ul - 2, v0 - 3, ur + 2, v0 - 1), R(o.sillR, 5)) fm(Q(ul - 2, v0 - 3, ur + 2, v0 - 2), R(o.sillR, 3))
        if o.lintel then fm(Q(ul - 1, v1 + 1, ur + 1, v1 + 3), R(o.lintel, 4)) fm(Q(ul - 1, v1 + 1, ur + 1, v1 + 2), R(o.lintel, 5)) end
        if shut then
          fm(Q(ul - 3, v0 - 1, ul - 1, v1 + 1), R(AC, 3)) fm(Q(ur + 1, v0 - 1, ur + 3, v1 + 1), R(AC, 2))
          fm(Q(ul - 3, v0 - 1, ul - 2, v1 + 1), R(AC, 4))
        end
      end
      -- shop windows beside the door
      if du0 - 2 >= 5 then fm(Q(2, 6, du0 - 2, 19), R(FR, 3)) fm(Q(3, 7, du0 - 3, 18), GLASS) fm(Q(3, 7, du0 - 3, 9), GLASS2) fm(Q(3, 17, 4, 18), GLASS3) end
      local ru0, ru1 = du0 + dw + 3, FW - 3
      if ru1 - ru0 >= 5 then fm(Q(ru0 - 1, 6, ru1, 19), R(FR, 3)) fm(Q(ru0, 7, ru1 - 1, 18), GLASS) fm(Q(ru0, 7, ru1 - 1, 9), GLASS2) fm(Q(ru0, 17, ru0 + 1, 18), GLASS3) end
      -- upper storeys
      local nc = (FW >= 38) and 3 or ((FW >= 28) and 2 or 1)
      local ww = (nc == 3) and 7 or 8
      local topLimit = HH - (o.roof and 12 or 15)
      local rowi = 0
      local v = 47
      while v + 15 <= topLimit do
        for i = 0, nc - 1 do
          local uc = floor((i + .5) * FW / nc + .5)
          win(uc, v, ww, 14, ((rowi + i) % 2 == 1) and o.shutters)
        end
        v = v + 36 rowi = rowi + 1
      end
      -- side-face windows (slivers that recede)
      if D >= 8 and not o.hubBand then
        local sv = 47
        while sv + 15 <= topLimit do
          local sw0 = 3
          local sw1 = max(sw0 + 3, floor(D * 0.62))
          fm(SQ(sw0 - 1, sv - 1, sw1 + 1, sv + 15), R(FR, 2))
          fm(SQ(sw0, sv, sw1, sv + 14), GLASS)
          fm(SQ(sw0, sv, sw1, sv + 4), GLASS2)
          sv = sv + 36
        end
      end
      -- awning (striped, scalloped fringe)
      local au0, au1 = du0 - 3, du0 + dw + 3
      local s = 0
      local ua = au0
      while ua < au1 do
        local ub = min(au1, ua + 3)
        local even = (s % 2 == 0)
        local base = even and AC or WR
        local bi = even and 4 or 6
        fm(Q(ua, even and 23 or 24, ub, 31), R(base, bi))
        fm(Q(ua, 29, ub, 31), R(base, bi + 1))
        if even then fm(Q(ua, 23, ub, 24), R(AC, 3)) else fm(Q(ua, 24, ub, 25), R(WR, 4)) end
        s = s + 1 ua = ub
      end
      fm(Q(au1 - 1, 24, au1, 31), R(AC, 2))
      fm(Q(du0 - 1, 21, du0 + dw + 1, 23), R(FR, 1))
      -- BLANK sign board over the awning
      local uc = du0 + dw / 2
      local sw = min(FW - 4, 30)
      local su0 = max(2, floor(uc - sw / 2 + .5))
      local su1 = min(FW - 2, su0 + sw)
      o.signBox = { su0, su1 }
      fm(Q(su0, 32, su1, 42), R(o.signEdge, 2))
      fm(Q(su0 + 1, 33, su1 - 1, 41), R(TR, 4))
      fm(Q(su0 + 1, 40, su1 - 1, 41), R(TR, 5))
      for vv = 34, 38, 2 do fm(Ln(su0 + 1, vv, su1 - 2, vv), R(TR, 3)) end
      fm(Q(su1 - 2, 33, su1 - 1, 41), R(TR, 3))
      fm(Q(su0, 31, su0 + 1, 32), R(o.signEdge, 3)) fm(Q(su1 - 1, 31, su1, 32), R(o.signEdge, 3))
    else
      if D >= 8 then
        local sv = 47
        while sv + 15 <= HH - 12 do
          fm(SQ(3, sv - 1, max(6, floor(D * 0.62)), sv + 15), R(FR, 2))
          fm(SQ(4, sv, max(5, floor(D * 0.62) - 1), sv + 14), GLASS)
          sv = sv + 36
        end
      end
    end

    -- mushroom cap: dome with lit upper left, lighter lip, gill underside
    if o.cap then
      local CR = o.capR
      local cx = T((x0 + d + x1) / 2)
      local rx = floor((x1 - x0 - d) / 2) + 2
      local cy = y0 + 4
      local dome = c:ellipse(cx, cy, rx, 7):clip(rect(x0 - 3, y0 - 4, x1 + 3, cy))
      local gill = c:ellipse(cx, cy, rx - 1, 3):clip(rect(x0 - 3, cy + 1, x1 + 3, cy + 3)):cut(dome)
      dome:each(function(x, y)
        local n = (x - cx) / rx
        local idx = 4
        if n > .35 then idx = 3 end
        if n > .8 then idx = 2 end
        local top = (y - (cy - 7))
        if n < -.1 and top <= 3 and top >= 1 then idx = 5 end
        if n < -.45 and top >= 1 and top <= 2 then idx = 6 end
        if y == cy then idx = max(idx, 4) + 1 end      -- lighter rim lip
        c:put(x, y, R(CR, idx))
      end)
      gill:each(function(x, y)
        local n = (x - cx) / rx
        local col = (x % 2 == 0) and 1 or 2
        if n > .3 and x % 2 == 1 then col = 1 end
        c:put(x, y, R(CR, col + ((n < -.5 and x % 2 == 1) and 1 or 0)))
      end)
      -- per-cap personality
      dome:each(function(x, y)
        if y >= cy then return end
        local n = (x - cx) / rx
        local h = hash(x, y, 31)
        if o.capKind == "moss" then
          if hash(floor(x / 4), floor(y / 3), 11) > .84 and (x + y) % 2 == 0 then c:put(x, y, RA.CREAM[5]) end
          if h > .9 then c:put(x, y, R(CR, 5)) end
        elseif o.capKind == "petal" then
          if (x - floor(cx)) % 4 == 0 and y > cy - 6 then c:put(x, y, R(CR, 3)) end
          if hash(floor(x / 5), floor(y / 4), 12) > .86 and y % 2 == 0 and x % 2 == 0 then c:put(x, y, RA.CREAM[6]) end
        else
          if h > .88 then c:put(x, y, RA.MAPLE[4]) end
          if hash(floor(x / 3), floor(y / 3), 13) > .9 and n > 0 then c:put(x, y, R(CR, 1)) end
        end
      end)
      if o.capKind == "petal" then   -- scalloped lip
        for x = floor(cx - rx + 1), floor(cx + rx - 1) do
          if (x - floor(cx)) % 4 == 0 then c:put(x, cy + 1, R(CR, 5)) end
        end
      end
      all:add(dome):add(gill)
    end
    ink(all)
    -- ground contact shade on the pavement under local shops
    if o.contact then
      for x = x0, x1 do if (x + yb) % 2 == 0 then c:put(x, yb + 2, RA.STONE[2]) end c:put(x, yb + 1, INK) end
    end
    return o
  end

  -- 5. Mossbottom (hub) rows ---------------------------------------------------------------------------
  local byk = L.byk
  local H = hub.wall
  local capsets = {
    ["hub-seeds"] = "moss", ["hub-food"] = "ember", ["hub-florist"] = "petal", ["hub-decor"] = "moss",
    ["hub-dyes"] = "petal", ["hub-pets"] = "ember", ["hub-more"] = "moss" }
  local function hubBuilding(k)
    local kind = capsets[k]
    local capR = hub.cap[kind]
    building(byk[k].box, { mirror = true, vx = HUB_VP[1], vy = HUB_VP[2], k = HUB_VP[3], tk = 0.17, kind = "plaster",
      wall = H, frame = RA.OAK, trim = RA.OAK, accent = capR, signEdge = capR, sillR = RA.CREAM, lintel = capR,
      cap = true, capR = capR, capKind = kind, hubBand = true, shutters = (kind ~= "moss") })
  end
  for _, k in ipairs({ "hub-dyes", "hub-pets", "hub-more" }) do hubBuilding(k) end
  -- re-lay the ledge and terrace over any upper-row rim bleed, then the front row on top
  local ledge2 = rect(286, 140, 479, 149)
  blocks(ledge2, RA.STONE, 140, 5, 15, { 4, 4, 5 })
  for x = 286, 479 do c:put(x, 140, RA.STONE[6]) c:put(x, 149, RA.STONE[2]) end
  ink(ledge2)
  for _, k in ipairs({ "hub-seeds", "hub-food", "hub-florist", "hub-decor" }) do hubBuilding(k) end

  -- 6. Local shops --------------------------------------------------------------------------------------
  local order = { "loc-4", "loc-3", "loc-2", "loc-1" }
  for i, k in ipairs(order) do
    local alt = (i % 2 == 0)
    building(byk[k].box, { mirror = false, vx = LOC_VP[1], vy = LOC_VP[2], k = LOC_VP[3], tk = 0.17, roof = 10, kind = look.name,
      wall = look.wall, frame = alt and look.trim or look.frame, trim = alt and look.frame or look.trim,
      accent = alt and look.roof or look.accent, signEdge = look.frame, sillR = look.wall, roofR = look.roof,
      shutters = alt, contact = true })
  end
  building(byk["loc-more"].box, { mirror = false, vx = LOC_VP[1], vy = LOC_VP[2], k = LOC_VP[3], tk = 0.17, roof = 10, kind = look.name,
    wall = look.wall, frame = look.frame, trim = look.trim, accent = look.accent, signEdge = look.frame, sillR = look.wall,
    roofR = look.roof, skipFront = true })

  -- 7. Clock tower ---------------------------------------------------------------------------------------
  local ST = RA.STONE
  local tf = ppoly({ { 210, BASE }, { 252, BASE }, { 246, 70 }, { 206, 70 } })
  local ts = ppoly({ { 252, BASE }, { 258, BASE }, { 250, 70 }, { 246, 70 } })
  local sp = ppoly({ { 202, 72 }, { 250, 72 }, { 226, 30 } })
  local function tl(y) return 210 - 4 * (BASE - y) / 180 end
  local function tower(m, side)
    m:each(function(x, y)
      local v = BASE - 1 - y
      local u = floor(x + .5 - tl(y))
      local row = floor(v / 5)
      local bw = 10 + (row * 3) % 4
      local off = (row % 2) * 5
      local rx2 = (u + off) % bw
      local idx
      if v % 5 == 0 or rx2 == 0 then idx = 2.4 else
        idx = 3.6 + (hash(floor((u + off) / bw), row, 8) - .5) * 1.6
        if v % 5 == 4 then idx = idx + 1 end
      end
      if side then idx = idx - 1.2 else
        if u <= 2 then idx = idx + 1 end
        if u >= 39 then idx = idx - 1 end
      end
      local dist = y - 72
      if dist >= 0 and dist <= 1 then idx = idx - 2 elseif dist == 2 or dist == 3 then idx = idx - 1 end
      if v < 3 then idx = idx - 1 end
      c:put(x, y, R(ST, idx))
    end)
  end
  tower(tf, false) tower(ts, true)
  -- cornice under the spire
  for x = 204, 249 do c:put(x, 72, R(ST, 5)) end
  -- spire shingles: lit left of the ridge, shaded right
  sp:each(function(x, y)
    local rel = y - 30
    local course, row = floor(rel / 3), rel % 3
    local off = (course % 2) * 2
    local jt = (x + off) % 5 == 0
    local idx = (row == 0) and 4 or ((row == 1) and 3.2 or 2)
    if x >= 227 then idx = idx - 1.2 end
    if x >= 240 then idx = idx - .8 end
    if x <= 224 then idx = idx + .8 end
    if jt and row ~= 2 then idx = idx - 1 end
    if y == 71 then idx = 2 end
    c:put(x, y, R(look.roof, idx))
  end)
  for y = 31, 71 do c:put(226, y, R(look.roof, 5)) end
  local fin = rect(225, 26, 226, 29)
  fm(fin, R(look.accent, 5)) c:put(225, 25, R(look.accent, 6)) c:put(226, 25, R(look.accent, 4))
  -- belfry arches
  for i = 0, 1 do
    local ax = 214 + i * 18 - floor(4 * (BASE - 86) / 180) + 4
    fm(rect(ax, 80, ax + 7, 94), R(look.frame, 1))
    fm(c:ellipse(ax + 3.5, 80, 4, 4):clip(rect(ax - 2, 74, ax + 10, 79)), R(look.frame, 1))
    for y = 80, 94 do c:put(ax, y, GLASS) end
    fm(rect(ax + 1, 88, ax + 6, 94), GLASS2)
    fm(rect(ax - 1, 95, ax + 8, 95), ST[5]) fm(rect(ax - 1, 96, ax + 8, 96), ST[2])
  end
  -- clock face: ring, cream dial, ticks, hands
  local ccx, ccy = 227, 118
  fm(c:ellipse(ccx, ccy, 11, 11), RA.OAK[2])
  fm(c:ellipse(ccx, ccy, 10, 10), RA.OAK[4])
  fm(c:ellipse(ccx, ccy, 8, 8), RA.CREAM[5])
  fm(c:ellipse(ccx, ccy, 8, 8):clip(rect(ccx - 9, ccy - 9, ccx + 9, ccy - 3)):clip(rect(ccx - 9, ccy - 9, ccx - 2, ccy + 9)):cut(c:ellipse(ccx, ccy, 7, 7)), RA.CREAM[6])
  c:put(ccx, ccy - 7, RA.OAK[1]) c:put(ccx, ccy + 7, RA.OAK[1]) c:put(ccx - 7, ccy, RA.OAK[1]) c:put(ccx + 7, ccy, RA.OAK[1])
  fm(line({ { ccx, ccy }, { ccx - 3, ccy - 4 } }), RA.OAK[1])
  fm(line({ { ccx, ccy }, { ccx + 4, ccy - 4 } }), RA.OAK[2])
  c:put(ccx, ccy, look.accent[5])
  -- slit windows
  for _, wy in ipairs({ 150, 190 }) do
    local wx = floor(tl(wy)) + 18
    fm(rect(wx - 1, wy - 1, wx + 4, wy + 15), ST[2])
    fm(rect(wx, wy, wx + 3, wy + 14), GLASS) fm(rect(wx, wy, wx + 3, wy + 4), GLASS2)
    fm(rect(wx - 2, wy + 15, wx + 5, wy + 16), ST[5]) fm(rect(wx - 2, wy + 16, wx + 5, wy + 16), ST[2])
    c:put(wx, wy + 2, GLASS3)
  end
  -- archway with voussoir ring, deep interior
  local arch = rect(222, 228, 238, 249):add(c:ellipse(230, 228, 8, 6):clip(rect(220, 218, 240, 228)))
  local r1 = arch:copy():grow(1):cut(arch)
  local r2 = arch:copy():grow(2):cut(arch:copy():grow(1))
  fm(r2, ST[3]) fm(r1, ST[5])
  r1:each(function(x, y) if y < 226 and (x + y) % 3 == 0 then c:put(x, y, ST[2]) end end)
  fm(arch, RA.IRON[1])
  fm(clipY(arch:copy(), 244, 249), RA.IRON[2])
  fm(clipY(arch:copy(), 247, 249), RA.COB[3])
  for y = 224, 249 do c:put(222, y, RA.IRON[2]) end
  -- blank sign board over the archway
  fm(rect(212, 204, 244, 214), RA.OAK[2]) fm(rect(213, 205, 243, 213), look.trim[4]) fm(rect(213, 212, 243, 213), look.trim[5])
  for y = 206, 210, 2 do fm(rect(214, y, 241, y), look.trim[3]) end
  fm(rect(242, 205, 243, 213), look.trim[3])
  c:put(213, 203, RA.OAK[3]) c:put(243, 203, RA.OAK[3]) c:put(213, 215, RA.OAK[3]) c:put(243, 215, RA.OAK[3])
  ink(tf:copy():add(ts):add(sp):add(fin):add(rect(225, 25, 226, 25)))
  -- tower foot shade on the cobbles
  for x = 210, 258 do if (x + BASE) % 2 == 0 then c:put(x, BASE + 2, RA.COB[3]) end end

  return c
end
