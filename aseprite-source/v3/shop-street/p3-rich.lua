-- Shop Street pass 3 (richness): warm lit windows with stepped halos, shop pictograms on the blank Mossbottom boards,
-- door props per shop type, regional local props (X.look), wall grain / moss / cracks / drainpipes, cap spots, chimneys,
-- gantries, bunting and laundry across the street, a snail-shell bell and a spire nest, stepped clouds, depth mist,
-- light shafts from the upper right, glowing terrace mushrooms and a mushroom arch at the stair head.
-- Opaque ramp colours and mixes of ramp colours only. Stand points and compass_clear stay uncluttered.
-- Signature: return function(c, L, X) ... end
return function(c, L, X)
  local floor, max, min, abs, sqrt, sin = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin
  local RA, look, hub, hash, mix = X.RAMPS, X.look, X.HUB, X.hash, X.mix
  local INK, GLOW, BASE = "#2b1c26", hub.glow, 250
  local sky = look.sky
  local byk = L.byk
  local function R(r, i) return X.R(r, floor(i + .5)) end
  local function put(x, y, col) c:put(floor(x), floor(y), col) end
  local function tint(x, y, col, t) X.tint(c, floor(x), floor(y), col, t) end
  local function fm(m, col) c:fillMask(m, col) return m end
  local function rect(x0, y0, x1, y1) return X.rect(c, x0, y0, x1, y1) end
  local function line(pts) return c:line(pts, 1) end
  local OAK, CREAM, MUST, GREEN, ROSE, TEAL, IRON, MOSS, STONE = RA.OAK, RA.CREAM, RA.MUST, RA.GREEN, RA.ROSE, RA.TEAL, RA.IRON, RA.MOSS, RA.STONE
  local W_DEEP, W_MID, W_HI, W_WHT = MUST[4], mix(MUST[5], GLOW, .5), GLOW, mix(GLOW, CREAM[6], .6)

  -- keep-clear zones: a figure stands on each point (feet), plus the compass corner
  local CLR = {}
  for _, s in ipairs(L.stand) do CLR[#CLR + 1] = { s[1] - 10, s[2] - 26, s[1] + 10, s[2] + 4 } end
  CLR[#CLR + 1] = { 378, 260, 480, 300 }
  local function free(x, y)
    for _, b in ipairs(CLR) do if x >= b[1] and x <= b[3] and y >= b[2] and y <= b[4] then return false end end
    return true
  end

  -- sprite: rows of chars, map char -> colour; (x,y) top-left; optional slope (px per px) to follow a tilted board
  local function spr(x, y, rows, map, slope, guard)
    for j, row in ipairs(rows) do
      for i = 1, #row do
        local col = map[row:sub(i, i)]
        if col then
          local px, py = floor(x) + i - 1, floor(y) + j - 1 + (slope and floor(slope * (i - 1) + .5) or 0)
          if not guard or free(px, py) then c:put(px, py, col) end
        end
      end
    end
  end
  local function sprB(cx, by, rows, map, guard) spr(floor(cx) - floor(#rows[1] / 2), floor(by) - #rows + 1, rows, map, nil, guard) end

  -- stepped radial glow (tint toward col in three steps; outer step dithered)
  local function glow(cx, cy, r, col, amt, ry, guard)
    ry = ry or r
    for y = floor(cy - ry), floor(cy + ry) do for x = floor(cx - r), floor(cx + r) do
      local d = sqrt(((x - cx) / r) ^ 2 + ((y - cy) / ry) ^ 2)
      if d < 1 and (not guard or free(x, y)) then
        local st = floor((1 - d) * 3 + .999) / 3
        if not (st < .4 and (x + y) % 2 == 1) then tint(x, y, col, amt * st) end
      end
    end end
  end

  -- glass colours left by p2
  local GL = { [RA.SLATE[1]] = 1, [RA.SLATE[2]] = 2, [RA.SLATE[3]] = 3 }

  -- background mask (deep-street gradient visible between masses) captured before anything is added
  local G = { X.mix(sky[3], STONE[5], .5), STONE[5], STONE[4], STONE[3], STONE[2], STONE[1] }
  local Gs = {} for _, h in ipairs(G) do Gs[h] = true end
  local tower = c:poly(X.P({ { 202, BASE }, { 258, BASE }, { 250, 26 }, { 202, 26 } }))
  local function inBox(x, y)
    for _, sp in pairs(byk) do local b = sp.box if x >= b[1] and x <= b[3] and y >= b[2] - 4 and y <= b[4] then return true end end
    return false
  end
  local bg = X.HP.mask()
  for y = 96, BASE - 1 do for x = 0, 479 do
    if Gs[c:get(x, y)] and not inBox(x, y) and not tower:has(x, y) then bg:set(x, y) end
  end end

  ---------------------------------------------------------------------------------------------------------
  -- 0. building geometry (mirrors the p2 painter so props land on the planes)
  local HUBO = { mirror = true, vx = 300, vy = 0, k = 0.16, tk = 0.17 }
  local LOCO = { mirror = false, vx = 240, vy = 20, k = 0.12, tk = 0.17, roof = 10 }
  local function geom(k, o)
    local box = byk[k].box
    local g = { k = k, box = box, o = o }
    local x0, y0, x1, y1 = box[1], box[2], box[3], box[4]
    local m, yb = o.mirror, y1
    local yt = o.roof and (y0 + o.roof) or y0
    local HH = yb - yt
    local xc = (x0 + x1) / 2
    local frac = (yb - y0) / (yb - o.vy)
    local D = max(2, floor((x1 - x0) * 0.30 + .5))
    local d = floor(min(abs((o.vx - xc) * o.k * frac), D * 0.9) + .5)
    local FW = x1 - D - x0
    local denom = max(60, abs(o.vx - xc))
    local function T(x) if m then return x0 + x1 - x end return x end
    g.T, g.HH, g.D, g.d, g.FW, g.yt, g.x0, g.y0, g.x1, g.yb = T, HH, D, d, FW, yt, x0, y0, x1, yb
    function g.M(u, v)
      local lx = x0 + u + d * v / HH
      local yy = yb - v
      local s = o.tk * (96 - yy) / denom
      return T(lx), yy + s * u * min(1, v / 90)
    end
    function g.S(w, v)
      local lx = x1 - D + d * v / HH + w
      local yy = yb - v
      local s = 0.8 * (96 - yy) / max(40, o.vx - lx)
      return T(lx), yy + s * w
    end
    function g.px(u, v) local x, y = g.M(u + .5, v + .5) return floor(x), floor(y) end
    function g.sx(w, v) local x, y = g.S(w + .5, v + .5) return floor(x), floor(y) end
    function g.Q(u0, v0, u1, v1) local M = g.M return c:poly({ { M(u0, v0) }, { M(u1, v0) }, { M(u1, v1) }, { M(u0, v1) } }) end
    function g.SQ(w0, v0, w1, v1) local S = g.S return c:poly({ { S(w0, v0) }, { S(w1, v0) }, { S(w1, v1) }, { S(w0, v1) } }) end
    g.du0 = floor(FW * 0.3)
    g.dw = max(5, floor(FW * 0.34))
    g.nc = (FW >= 38) and 3 or ((FW >= 28) and 2 or 1)
    g.ww = (g.nc == 3) and 7 or 8
    g.top = HH - (o.roof and 12 or 15)
    g.wins = {}
    local v, rowi = 47, 0
    while v + 15 <= g.top do
      for i = 0, g.nc - 1 do
        local uc = floor((i + .5) * FW / g.nc + .5)
        local ul = uc - floor(g.ww / 2)
        g.wins[#g.wins + 1] = { ul = ul, ur = ul + g.ww, v0 = v, v1 = v + 14, row = rowi, i = i, uc = uc }
      end
      v = v + 36 rowi = rowi + 1
    end
    g.shop = {}
    if g.du0 - 2 >= 5 then g.shop[#g.shop + 1] = { ul = 3, ur = g.du0 - 3, v0 = 7, v1 = 18 } end
    local ru0, ru1 = g.du0 + g.dw + 3, FW - 3
    if ru1 - ru0 >= 5 then g.shop[#g.shop + 1] = { ul = ru0, ur = ru1 - 1, v0 = 7, v1 = 18 } end
    local uc = g.du0 + g.dw / 2
    local sw = min(FW - 4, 30)
    g.su0 = max(2, floor(uc - sw / 2 + .5))
    g.su1 = min(FW - 2, g.su0 + sw)
    return g
  end

  -- light a window (glass pixels only) and spread a stepped halo on the wall around it
  local WARM = { [W_DEEP] = true, [W_MID] = true, [W_HI] = true, [W_WHT] = true }
  local function lightRegion(mask, opt)
    local bx0, by0, bx1, by1 = mask:bbox()
    if not bx0 then return end
    mask:each(function(x, y)
      local gi = GL[c:get(x, y)]
      if not gi then return end
      local fy = (y - by0) / max(1, by1 - by0)
      local col
      if gi == 3 then col = W_WHT
      elseif gi == 2 then col = W_DEEP
      elseif fy > .55 then col = W_HI
      elseif fy > .25 then col = ((x + y) % 2 == 0) and W_HI or W_MID
      else col = W_MID end
      c:put(x, y, col)
    end)
    if opt and opt.curtain then   -- curtain on the inner jamb
      local cx = opt.curtainRight and bx1 - 1 or bx0 + 1
      for y = by0 + 1, by1 - 1 do
        local cur = c:get(cx, y)
        if WARM[cur] then c:put(cx, y, R(opt.curtain, (y % 3 == 0) and 3 or 4)) end
      end
      local cy = by0 + floor((by1 - by0) * .6)
      local cx2 = opt.curtainRight and cx - 1 or cx + 1
      if WARM[c:get(cx2, cy)] then c:put(cx2, cy, R(opt.curtain, 5)) end
    end
    if opt and opt.sill then      -- a dark silhouette on the inner sill (pot / jar)
      local sx = floor((bx0 + bx1) / 2) + opt.sill
      for _, p in ipairs({ { 0, 0 }, { 1, 0 }, { 0, -1 }, { 1, -1 }, { 0, -2 } }) do
        if WARM[c:get(sx + p[1], by1 - 1 + p[2])] then c:put(sx + p[1], by1 - 1 + p[2], OAK[2]) end
      end
    end
    -- halo
    local amt = (opt and opt.amt) or .3
    for y = by0 - 4, by1 + 4 do for x = bx0 - 4, bx1 + 4 do
      local dx = max(bx0 - x, x - bx1, 0)
      local dy = max(by0 - y, y - by1, 0)
      local dd = max(dx, dy)
      if dd >= 2 and dd <= 4 then
        local cur = c:get(x, y)
        if cur and not GL[cur] and not WARM[cur] and cur ~= INK then
          local t = ({ 0, .9, .55, .3 })[dd]
          if not (dd == 4 and (x + y) % 2 == 1) then tint(x, y, GLOW, amt * t) end
        end
      end
    end end
  end
  -- darken a dark window a touch and add a glint, so unlit ones read as glass at night-ish dusk
  local function darkRegion(mask)
    local bx0, by0, bx1, by1 = mask:bbox()
    if not bx0 then return end
    mask:each(function(x, y)
      if GL[c:get(x, y)] and (x - bx0) == (by1 - y) - 2 then c:put(x, y, RA.SLATE[3]) end
    end)
  end

  -- wall weathering on a front face: streaks under sills, cracks, lichen, moss tufts
  local function weather(g, wallR, seed, opt)
    -- streaks under each window
    for _, w in ipairs(g.wins) do
      local len = 4 + floor(hash(w.ul, w.v0, seed) * 7)
      for u = w.ul, w.ur - 1 do
        if hash(u, w.v0, seed + 1) > .45 then
          for vv = w.v0 - 4, w.v0 - 3 - len, -1 do
            local x, y = g.px(u, vv)
            if (x + y) % 2 == 0 or vv > w.v0 - 6 then tint(x, y, wallR[1], .22) end
          end
        end
      end
    end
    -- cracks
    for n = 0, 2 do
      local u = 3 + floor(hash(n, seed, 41) * (g.FW - 6))
      local v = 26 + floor(hash(seed, n, 42) * max(4, g.HH - 50))
      local ok = true
      for _, w in ipairs(g.wins) do if u > w.ul - 3 and u < w.ur + 3 and v > w.v0 - 5 and v < w.v1 + 7 then ok = false end end
      if v > 30 and v < 45 then ok = false end
      if ok then
        for s = 0, 5 do
          local x, y = g.px(u + ((s % 3 == 1) and 1 or 0) + floor(s / 3), v - s)
          put(x, y, R(wallR, 2))
          if s % 2 == 0 then put(x + 1, y, R(wallR, 5)) end
        end
      end
    end
    -- lichen dots (accent of the ramp + moss)
    for n = 0, 10 do
      local u = 1 + floor(hash(n, seed, 43) * (g.FW - 2))
      local v = 10 + floor(hash(seed, n, 44) * max(4, g.HH - 24))
      local x, y = g.px(u, v)
      local cur = c:get(x, y)
      if cur and cur ~= INK and not GL[cur] then
        put(x, y, (n % 3 == 0) and RA.LEAFG[5] or MOSS[4])
        if n % 2 == 0 then put(x + 1, y, MOSS[3]) end
      end
    end
  end

  -- crooked drainpipe down a front face column u
  local function drainpipe(g, u, seed, guard)
    local off, lastx = 0, nil
    for v = g.HH - 3, 0, -1 do
      if v % 23 == 11 and hash(v, seed, 51) > .35 then off = off + ((hash(seed, v, 52) > .5) and 1 or -1) end
      local x, y = g.px(u + off, v)
      if not guard or free(x, y) then
        put(x, y, IRON[4]) put(x + 1, y, IRON[2])
        if v % 18 == 5 then put(x - 1, y, IRON[1]) put(x + 2, y, IRON[1]) end
      end
      lastx = x
    end
    local x, y = g.px(u + off, 0)
    put(x - 1, y, IRON[4]) put(x - 2, y, IRON[3]) put(x - 1, y - 1, IRON[2])
    -- hopper at the top
    local hx, hy = g.px(u, g.HH - 3)
    fm(rect(hx - 1, hy - 1, hx + 2, hy), IRON[3]) put(hx - 1, hy - 1, IRON[5])
  end

  -- catenary helper
  local function sagPts(xa, ya, xb, yb, sag)
    local pts = {}
    local n = max(2, floor(abs(xb - xa)))
    for i = 0, n do
      local t = i / n
      pts[#pts + 1] = { xa + (xb - xa) * t, ya + (yb - ya) * t + sag * 4 * t * (1 - t) }
    end
    return pts
  end
  local FLAG = { ROSE, MUST, TEAL, RA.LEAFG, RA.PLUM, RA.ORANGE }
  local function bunting(xa, ya, xb, yb, sag, seed, skip)
    local pts = sagPts(xa, ya, xb, yb, sag)
    for i, p in ipairs(pts) do
      local x, y = floor(p[1] + .5), floor(p[2] + .5)
      if not (skip and skip(x, y)) then put(x, y, OAK[2]) end
    end
    local k = 0
    for i = 3, #pts - 3, 6 do
      local p = pts[i]
      local x, y = floor(p[1] + .5), floor(p[2] + .5) + 1
      if not (skip and skip(x, y)) then
        local fr = FLAG[(k + seed) % #FLAG + 1]
        for j = 0, 3 do
          local half = ({ 2, 1, 1, 0 })[j + 1]
          for dx = -half, half do
            local col = (dx == half and half > 0) and R(fr, 3) or R(fr, 5)
            if j == 0 and dx < 0 then col = R(fr, 6) end
            put(x + dx, y + j, col)
          end
        end
        put(x, y + 4, R(fr, 2))
      end
      k = k + 1
    end
  end

  ---------------------------------------------------------------------------------------------------------
  -- 1. sky: stepped clouds at the top, horizon haze (only where the pixel is still sky)
  local SKY = { [sky[1]] = 1, [sky[2]] = 2, [sky[3]] = 3 }
  local haze = X.mix(sky[3], STONE[5], .35)
  local CL_HI, CL_MID, CL_LO = mix(sky[1], CREAM[6], .9), mix(sky[1], CREAM[6], .55), mix(sky[2], STONE[5], .25)
  local function cloud(x, y, w, h)
    local m = X.HP.mask()
    for _, p in ipairs({ { .16, .45, .17 }, { .38, .95, .26 }, { .62, .75, .22 }, { .84, .42, .15 } }) do
      local r = max(2, floor(w * p[3] + .5))
      local hh = max(2, floor(h * p[2] + .5))
      m:add(c:ellipse(x + w * p[1], y - hh + r * .6, r, hh))
    end
    m:clip(rect(x - 2, y - h - 6, x + w + 2, y))
    m:each(function(px, py)
      if not SKY[c:get(px, py)] then return end
      local col = CL_MID
      local edgeTop = not m:has(px, py - 1) or not m:has(px, py - 2)
      local edgeR = not m:has(px + 1, py) or not m:has(px + 2, py - 1)
      if edgeTop or edgeR then col = CL_HI end
      if not m:has(px, py + 1) or not m:has(px, py + 2) then col = CL_LO end
      if not m:has(px - 1, py) and not edgeTop then col = CL_LO end
      c:put(px, py, col)
    end)
  end
  cloud(6, 24, 48, 14) cloud(118, 16, 38, 11) cloud(156, 34, 24, 7) cloud(258, 22, 56, 15) cloud(332, 12, 30, 8)
  cloud(404, 28, 52, 14) cloud(456, 13, 22, 7)
  -- long stepped streaks lower down
  for _, s in ipairs({ { 60, 46, 70 }, { 300, 50, 60 }, { 170, 58, 40 }, { 420, 60, 54 } }) do
    for x = s[1], s[1] + s[3] do
      if SKY[c:get(x, s[2])] then c:put(x, s[2], CL_LO) end
      if x > s[1] + 6 and x < s[1] + s[3] - 10 and SKY[c:get(x, s[2] - 1)] then c:put(x, s[2] - 1, CL_MID) end
    end
  end
  -- horizon haze: dithered lightening of the far ridge and lowest sky band
  for y = 66, 95 do for x = 0, 479 do
    local cur = c:get(x, y)
    if SKY[cur] or cur == haze then
      local f = (y - 66) / 30
      local thr = X.hash(x, y, 77)
      if thr < f * .8 then tint(x, y, CREAM[6], .18) end
    end
  end end

  ---------------------------------------------------------------------------------------------------------
  -- 2. depth mist in the deep-street gaps (dither of two mixes), heavier near the ground
  local bay = { { 0, 8, 2, 10 }, { 12, 4, 14, 6 }, { 3, 11, 1, 9 }, { 15, 7, 13, 5 } }
  local MIST = mix(sky[2], STONE[5], .4)
  bg:each(function(x, y)
    local f = 0
    if y >= 118 and y <= 140 then f = .45 - abs(y - 129) / 24 end
    if y >= 168 and y <= 200 then f = max(f, .55 - abs(y - 184) / 30) end
    if y >= 214 then f = max(f, (y - 214) / 50) end
    local thr = (bay[y % 4 + 1][x % 4 + 1] + .5) / 16
    if f > thr then tint(x, y, MIST, .38) elseif f > thr * .5 then tint(x, y, MIST, .16) end
  end)
  -- low mist sliding off the upper Mossbottom row onto the ledge (separates the two depths)
  for y = 124, 139 do for x = 300, 479 do
    local f = (y - 124) / 22
    local thr = (bay[y % 4 + 1][x % 4 + 1] + .5) / 16
    if f > thr then tint(x, y, mix(sky[1], CREAM[5], .5), .22) end
  end end

  ---------------------------------------------------------------------------------------------------------
  -- 3. gantries / plank bridges between towers (behind the bunting, in front of the gaps)
  local function gantry(xa, xb, y, roofed)
    fm(rect(xa, y, xb, y + 1), OAK[4]) fm(rect(xa, y + 2, xb, y + 2), OAK[2])
    for x = xa, xb do if (x - xa) % 3 == 0 then put(x, y, OAK[5]) end end
    -- rails + posts
    for _, px in ipairs({ xa + 1, xb - 1, floor((xa + xb) / 2) }) do fm(rect(px, y - 4, px, y - 1), OAK[3]) end
    for x = xa + 1, xb - 1 do put(x, y - 4 + ((x == xa + 1 or x == xb - 1) and 0 or ((x + 1) % 2)), OAK[2]) end
    -- underside struts
    put(xa + 1, y + 3, OAK[2]) put(xa + 2, y + 4, OAK[2]) put(xb - 1, y + 3, OAK[2]) put(xb - 2, y + 4, OAK[2])
    if roofed then
      fm(rect(xa - 1, y - 9, xb + 1, y - 8), R(look.roof, 3)) fm(rect(xa - 1, y - 9, xb + 1, y - 9), R(look.roof, 5))
      put(xa, y - 7, OAK[2]) put(xb, y - 7, OAK[2]) put(xa, y - 6, OAK[2]) put(xb, y - 6, OAK[2]) put(xa, y - 5, OAK[2]) put(xb, y - 5, OAK[2])
    end
    c:rim(rect(xa, y, xb, y + 2), INK, bg:copy():grow(1))
  end
  gantry(52, 64, 112, true)       -- loc-1 <-> loc-2
  gantry(108, 120, 150, false)    -- loc-2 <-> loc-3
  gantry(160, 172, 184, true)     -- loc-3 <-> loc-4
  gantry(197, 209, 156, false)    -- loc-4 <-> clock tower
  gantry(355, 371, 66, false)     -- dyes <-> pets
  gantry(420, 434, 112, false)    -- pets <-> more

  ---------------------------------------------------------------------------------------------------------
  -- 4. local shops: weathering, roof ridge + chimney, lit windows, drainpipes, regional props
  local LK = { "loc-1", "loc-2", "loc-3", "loc-4" }
  local lname = look.name
  local locG = {}
  for i, k in ipairs(LK) do
    local g = geom(k, LOCO)
    locG[k] = g
    local alt = (i % 2 == 0)
    local trim = alt and look.frame or look.trim
    weather(g, look.wall, 100 + i * 7)
    -- roof ridge: crest tiles + moss tufts on the eave + a chimney stack inside the roof block
    local x0, y0, x1 = g.x0, g.y0, g.x1
    for x = x0 + g.d + 1, x1 - 1 do
      if (x - x0) % 4 == 0 then put(x, y0, R(look.roof, 6)) put(x, y0 + 1, R(look.roof, 5)) end
      if hash(x, y0, 61) > .72 then put(x, g.yt - 1, MOSS[(x % 2 == 0) and 4 or 3]) if hash(x, 9, 62) > .5 then put(x, g.yt, MOSS[2]) end end
    end
    local chx = x1 - 6 - (i % 2) * 6
    local cht = y0
    local stack = c:poly(X.P({ { chx, y0 + 8 }, { chx + 5, y0 + 8 }, { chx + 6, cht + 1 }, { chx + 1, cht + 1 } }))
    fm(stack, R(look.wall, 3))
    stack:each(function(x, y) if x <= chx + 1 + floor((y0 + 8 - y) / 8) then put(x, y, R(look.wall, 5)) end if (y - cht) % 3 == 0 then put(x, y, R(look.wall, 2)) end end)
    fm(rect(chx, cht, chx + 7, cht + 1), R(look.wall, 2)) fm(rect(chx, cht, chx + 7, cht), R(look.wall, 4))
    c:rim(stack:copy():add(rect(chx, cht, chx + 7, cht + 1)), INK)
    -- smoke: wisps drifting left with the breeze, thinning
    for s = 0, 4 do
      local sx, sy = chx + 3 - s * 2 - floor(s * s * .4), cht - 3 - s * 3
      local r = (s < 1) and 1 or 2
      local m = c:ellipse(sx, sy, r + .3, r * .8 + .3)
      m:each(function(x, y)
        if (s >= 3 and (x + y) % 2 == 1) then return end
        local top = not m:has(x, y - 1) or not m:has(x + 1, y)
        tint(x, y, top and CREAM[6] or CREAM[4], .8 - s * .1)
      end)
    end
    -- windows: most lit, a few dark
    for wi, w in ipairs(g.wins) do
      local mk = g.Q(w.ul, w.v0, w.ur, w.v1)
      if hash(wi, i, 71) < .62 then
        lightRegion(mk, { curtain = (hash(wi, i, 72) > .4) and look.accent or nil, curtainRight = (wi % 2 == 0), sill = (hash(i, wi, 73) > .6) and -2 or nil, amt = .26 })
      else darkRegion(mk) end
    end
    for _, w in ipairs(g.shop) do lightRegion(g.Q(w.ul, w.v0, w.ur, w.v1), { amt = .34 }) end
    lightRegion(g.Q(g.du0 + 2, 15, g.du0 + g.dw - 2, 20), { amt = .15 })
    -- warm spill on the pavement under the shop front
    for x = x0, x1 - g.D do for y = BASE + 2, BASE + 5 do
      local t = ({ .28, .2, .12, .06 })[y - BASE - 1]
      if (y < BASE + 4 or (x + y) % 2 == 0) and free(x, y) then tint(x, y, GLOW, t) end
    end end
    drainpipe(g, g.FW - 2, 200 + i)
  end

  -- regional props on the local side
  local function crate(cx, by) sprB(cx, by, { "oooooo", "oLLLLo", "oLlxLo", "oLxlLo", "oLLLLo", "oooooo" },
    { o = OAK[1], L = OAK[5], l = OAK[4], x = OAK[3] }) end
  local function barrel(cx, by) sprB(cx, by, { ".ooo.", "oBbBo", "oiiio", "oBbBo", "oBbBo", "oiiio", ".ooo." },
    { o = OAK[1], B = OAK[4], b = OAK[6], i = IRON[3] }) end
  local function pot(cx, by, flower) sprB(cx, by, { ".f.f.", "gGgGg", ".gGg.", "ooooo", "oTTto", ".oto." },
    { f = flower or ROSE[5], g = GREEN[3], G = GREEN[5], o = OAK[1], T = RA.BARN[5], t = RA.BARN[4] }) end
  local function sack(cx, by, heap) sprB(cx, by, { ".hHh.", "ohHho", "oSsSo", "oSSso", "oSSSo", ".ooo." },
    { h = heap[4], H = heap[6], o = OAK[1], S = OAK[5], s = OAK[6] }) end
  local function basket(cx, by) sprB(cx, by, { ".fgfrf.", "frfgfrf", "oWWWWWo", "oWwWwWo", ".ooooo." },
    { f = RA.ORANGE[5], g = RA.LEAFG[5], r = ROSE[4], o = OAK[1], W = OAK[4], w = OAK[6] }) end
  local function lantern(cx, ty, col)
    sprB(cx, ty + 6, { ".o.", "ooo", "oYo", "oyo", "oYo", "ooo", ".o." }, { o = IRON[2], Y = col or W_HI, y = W_WHT })
    glow(cx, ty + 3, 7, GLOW, .3)
  end
  local function herbs(cx, ty, r)
    sprB(cx, ty + 5, { ".o.", "gGg", "GgG", "gGg", ".g." }, { o = OAK[2], g = R(r, 3), G = R(r, 5) })
  end

  for i, k in ipairs(LK) do
    local g = locG[k]
    local dl, dr = g.du0 - 1, g.du0 + g.dw + 1         -- door jambs (face u)
    local lx, by = g.px(max(1, dl - 4), 0)
    local rx = g.px(min(g.FW - 2, dr + 3), 0)
    by = g.yb - 1
    local aL = g.px(g.du0 - 3, 23)
    local aR = g.px(g.du0 + g.dw + 2, 23)
    local _, ay = g.px(g.du0 - 3, 23)
    if lname == "timber" then
      if i % 2 == 1 then barrel(lx, by) crate(rx, by) else crate(lx, by) pot(rx, by, MUST[5]) end
      herbs(aL, ay + 1, RA.LEAFG) herbs(aR, ay + 1, RA.MAPLE)
      -- flower pots on the first-floor sills
      for _, w in ipairs(g.wins) do
        if w.row == 0 and (w.i + i) % 2 == 0 then local px, py = g.px(w.uc, w.v0 - 1) pot(px, py - 1, (i % 2 == 0) and ROSE[5] or MUST[5]) end
      end
    elseif lname == "adobe" then
      if i % 2 == 1 then crate(lx, by) pot(rx, by, RA.ORANGE[5]) else pot(lx, by, ROSE[5]) crate(rx, by) end
      -- drying chilli strings hanging from upper-window lintels
      for _, w in ipairs(g.wins) do
        if (w.i + w.row) % 2 == 0 then
          for _, du in ipairs({ -1, w.ur - w.ul + 1 }) do
            local px, py = g.px(w.ul + du, w.v1 + 2)
            put(px, py - 1, GREEN[3])
            for s = 0, 9 do put(px + ((s % 2 == 0) and 0 or 1), py + s, (s % 3 == 0) and RA.BARN[3] or RA.BARN[5]) end
            put(px, py + 10, RA.BARN[2])
          end
        end
      end
      -- rug thrown over a rail under one window per building
      local w = g.wins[1 + (i % #g.wins)]
      if w then
        local A = look.accent
        local rows = { R(A, 3), R(A, 5), RA.CREAM[5], R(RA.ORANGE, 4), R(RA.ORANGE, 5), RA.CREAM[5], R(A, 4), R(A, 3), R(RA.ORANGE, 4), R(A, 2) }
        for r = 0, #rows - 1 do
          local vv = w.v0 - 3 - r
          for u = w.ul - 1, w.ur do
            local col = rows[r + 1]
            if (r == 4 or r == 5) and (u + r) % 3 == 0 then col = R(A, 5) end
            local px, py = g.px(u, vv)
            put(px, py, col)
          end
        end
        for u = w.ul - 1, w.ur, 2 do local px, py = g.px(u, w.v0 - 3 - #rows) put(px, py, CREAM[4]) end
        for u = w.ul - 2, w.ur + 1 do local px, py = g.px(u, w.v0 - 2) put(px, py, IRON[2]) end
      end
    elseif lname == "tropic" then
      basket(lx, by) if i % 2 == 0 then barrel(rx, by) else basket(rx, by) end
      herbs(aR, ay + 1, RA.LEAFG)
      -- fishing net draped on the side face with cork floats
      local ok = g.D >= 6
      if ok then
        for v = 26, 44 do for w = 1, g.D - 2 do
          if (w + v) % 4 == 0 or (w - v) % 4 == 0 then
            local px, py = g.sx(w, v)
            put(px, py, ((w + v) % 8 == 0) and CREAM[5] or CREAM[3])
          end
        end end
        for _, v in ipairs({ 44, 26 }) do for w = 1, g.D - 2, 3 do local px, py = g.sx(w, v) put(px, py, RA.ORANGE[5]) end end
      end
      -- hanging fruit bunch under the awning
      local px, py = aL, ay + 1
      put(px, py, OAK[2]) fm(rect(px - 1, py + 1, px + 1, py + 3), MUST[5]) put(px - 1, py + 1, MUST[6]) put(px + 1, py + 3, MUST[3]) put(px, py + 4, MUST[4])
    else -- spice
      local heaps = { RA.ORANGE, MUST, RA.BARN, RA.LEAFG }
      sack(lx, by, heaps[(i % 4) + 1]) sack(lx + 5, by, heaps[((i + 1) % 4) + 1]) sack(rx, by, heaps[((i + 2) % 4) + 1])
      lantern(aL, ay + 1, W_HI) lantern(aR, ay + 1, RA.ORANGE[6])
    end
  end

  -- laundry line across loc-1 / loc-2 facades
  do
    local pts = sagPts(34, 170, 88, 178, 6)
    for _, p in ipairs(pts) do put(p[1], p[2], CREAM[3]) end
    local items = {
      { 40, { "sSs", "sss", "sss" }, ROSE },
      { 47, { "ss", "ss", "s.", "s." }, MUST },
      { 54, { "sSSs", "ssss", "ssss", "ssss" }, RA.SBLUE },
      { 63, { "s.s", "s.s" }, RA.LEAFG },
      { 70, { "sSs", "sss", ".s." }, TEAL },
      { 79, { "sSSSs", "sssss", "sssss", "sssss", "sssss" }, CREAM },
    }
    for _, it in ipairs(items) do
      local t = (it[1] - 34) / 54
      local y = floor(170 + 8 * t + 6 * 4 * t * (1 - t) + 1.5)
      spr(it[1], y, it[2], { s = R(it[3], 5), S = R(it[3], 3) })
      put(it[1], y - 1, OAK[3])
    end
  end

  ---------------------------------------------------------------------------------------------------------
  -- 5. clock tower: ivy, lichen, lit belfry, snail-shell bell, spire nest, tower lantern
  do
    -- ivy up the left foot of the tower
    for n = 0, 70 do
      local y = 248 - floor(hash(n, 3, 81) * 80)
      local x = 209 + floor(hash(n, 4, 82) * (5 + (248 - y) / 20)) - floor((248 - y) / 45)
      if c:get(x, y) ~= INK and free(x, y) then put(x, y, (n % 3 == 0) and RA.LEAFG[4] or MOSS[(n % 2 == 0) and 3 or 4]) end
    end
    for n = 0, 18 do
      local x, y = 212 + floor(hash(n, 5, 83) * 36), 140 + floor(hash(n, 6, 84) * 60)
      local cur = c:get(x, y)
      if cur and STONE[3] ~= cur and cur ~= INK and not GL[cur] then put(x, y, (n % 2 == 0) and MUST[5] or RA.LEAFG[5]) end
    end
    -- right belfry arch lit from inside
    local ax = 233
    for y = 76, 94 do for x = ax, ax + 7 do
      local cur = c:get(x, y)
      if cur == look.frame[1] or GL[cur] then put(x, y, (y > 88) and W_HI or (((x + y) % 2 == 0) and W_HI or W_MID)) end
    end end
    glow(ax + 4, 86, 11, GLOW, .3)
    -- snail-shell bell in the left arch
    local bx = 216
    for y = 76, 80 do put(bx + 3, y, OAK[2]) end
    spr(bx, 81, { ".oooo.", "oGgggo", "oGoogo", "oGgogo", "oGGgo.", ".oooo.", "...o.." },
      { o = RA.GOLDL[2], G = RA.GOLDL[4], g = RA.GOLDL[5] })
    put(bx + 2, 82, RA.GOLDL[6])
    -- twig nest with two eggs on the spire's left slope
    spr(214, 42, { ".e.e..", "tTtTtT", ".tTtt." }, { t = OAK[3], T = OAK[5], e = CREAM[6] })
    put(213, 43, OAK[2]) put(220, 43, OAK[2])
    -- spire ridge tiles catch the light
    for y = 34, 70, 4 do put(225, y, R(look.roof, 6)) end
    -- lantern on a bracket by the arch
    fm(rect(244, 226, 248, 226), IRON[2]) put(248, 227, IRON[2])
    lantern(248, 228, W_HI)
    -- moss on the cornice
    for x = 204, 249 do if hash(x, 72, 85) > .6 then put(x, 73, MOSS[3]) if hash(x, 1, 86) > .6 then put(x, 74, MOSS[2]) end end end
  end

  ---------------------------------------------------------------------------------------------------------
  -- 6. Mossbottom: cap spots, lit windows, sign pictograms, door props
  local HK = { "hub-dyes", "hub-pets", "hub-more", "hub-seeds", "hub-food", "hub-florist", "hub-decor" }
  local CAPK = { ["hub-seeds"] = "moss", ["hub-food"] = "ember", ["hub-florist"] = "petal", ["hub-decor"] = "moss",
    ["hub-dyes"] = "petal", ["hub-pets"] = "ember", ["hub-more"] = "moss" }
  local hubG = {}
  for hi, k in ipairs(HK) do
    local g = geom(k, HUBO)
    hubG[k] = g
    local kind = CAPK[k]
    local CR = hub.cap[kind]
    -- cap spots
    local cx = g.T((g.x0 + g.d + g.x1) / 2)
    local rx = floor((g.x1 - g.x0 - g.d) / 2) + 2
    local cy = g.y0 + 4
    local CRs = {} for _, h in ipairs(CR) do CRs[h] = true end
    local spots = (kind == "ember") and 6 or 4
    for n = 0, spots - 1 do
      local sxp = cx - rx + 4 + floor(hash(n, hi, 91) * (2 * rx - 8))
      local syp = cy - 5 + floor(hash(hi, n, 92) * 4)
      local big = (kind == "ember") and (n % 2 == 0)
      local pts = big and { { 0, 0 }, { 1, 0 }, { -1, 1 }, { 0, 1 }, { 1, 1 }, { 2, 1 }, { 0, 2 }, { 1, 2 } } or { { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 } }
      for _, p in ipairs(pts) do
        local x, y = sxp + p[1], syp + p[2]
        if CRs[c:get(x, y)] and y < cy then
          local col = (kind == "moss") and RA.LEAFG[6] or CREAM[6]
          if p[2] == (big and 2 or 1) then col = (kind == "moss") and MOSS[5] or CREAM[4] end
          put(x, y, col)
        end
      end
    end
    weather(g, hub.wall, 300 + hi * 5)
    -- windows: mostly lit
    for wi, w in ipairs(g.wins) do
      local mk = g.Q(w.ul, w.v0, w.ur, w.v1)
      if hash(wi, hi, 93) < .78 then lightRegion(mk, { curtain = CR, curtainRight = (wi % 2 == 1), amt = .28 }) else darkRegion(mk) end
    end
    for _, w in ipairs(g.shop) do lightRegion(g.Q(w.ul, w.v0, w.ur, w.v1), { amt = .34 }) end
    lightRegion(g.Q(g.du0 + 2, 15, g.du0 + g.dw - 2, 20), { amt = .15 })
    -- glow spill on the ground in front
    for x = g.x0 + g.D, g.x1 do for y = g.yb + 1, g.yb + 3 do
      local t = ({ .26, .16, .08 })[y - g.yb]
      if (y < g.yb + 3 or (x + y) % 2 == 0) and free(x, y) then tint(x, y, GLOW, t) end
    end end
  end

  -- sign pictograms (blank boards, no letters): screen sprites centred on the board, following its tilt
  local o1 = OAK[1]
  local PICT = {
    ["hub-seeds"] = { { "ooooo", "oMMMo", "oMgMo", "ogGgo", "oMgMo", "oMMMo", "ooooo" }, { "g...g", "Gg.gG", ".gGg.", "..g..", "ooooo", "oTTto", ".oto." } },
    ["hub-food"] = { { "...c.c...", "..c.c....", ".ooooooo.", "oPpPpPpPo", "oPPPPPPPo", ".ooooooo." } },
    ["hub-florist"] = { { ".R.R.", "RryrR", ".RrR.", "..G..", "gGG..", "..Gg.", "..G.." }, { ".V.V.", "VvyvV", ".VvV.", "..G..", "..GGg", ".gG..", "..G.." } },
    ["hub-decor"] = { { ".ooo.", "oYYYo", "oYyYo", "ooooo", "..o..", "..o..", ".ooo." }, { "FFFFFFF", "FsssssF", "FssSssF", "FsGSGsF", "FGGGGGF", "FFFFFFF" } },
    ["hub-dyes"] = { { ".A.", ".A.", "AAA", "AaA", ".A." }, { ".B.", ".B.", "BBB", "BbB", ".B." }, { ".C.", ".C.", "CCC", "CcC", ".C." } },
    ["hub-pets"] = { { "...o...", "..ooo..", ".o.o.o.", "o.o.o.o", "o.o.o.o", "o.o.o.o", "ooooooo" }, { ".w.w.", "w...w", "..w..", ".www.", ".www." } },
    ["hub-more"] = { { "..o..", ".ooo.", "oYYYo", "oYyYo", "oYYYo", ".ooo.", "..o.." }, { "........", "........", "........", "dd.dd.dd", "dd.dd.dd" } },
  }
  local PMAP = { o = o1, M = MUST[5], g = GREEN[3], G = GREEN[5], T = RA.BARN[5], t = RA.BARN[3], c = CREAM[6],
    P = MUST[4], p = MUST[6], R = ROSE[5], r = ROSE[3], y = RA.GOLDL[6], V = RA.PLUM[5], v = RA.PLUM[3],
    Y = W_HI, F = RA.GOLDL[4], s = RA.SBLUE[5], S = CREAM[6], A = ROSE[4], a = ROSE[6], B = TEAL[4], b = TEAL[6],
    C = MUST[5], w = OAK[3], d = OAK[1] }
  for _, k in ipairs(HK) do
    local g = hubG[k]
    local ax, ay = g.M(g.su0 + 1, 37)
    local bx, byy = g.M(g.su1 - 1, 37)
    local slope = (byy - ay) / (bx - ax)
    local mx, my = g.M((g.su0 + g.su1) / 2, 37.5)
    local icons = PICT[k]
    local tot = 0 for _, ic in ipairs(icons) do tot = tot + #ic[1] end
    tot = tot + 2 * (#icons - 1)
    local x = floor(mx - tot / 2 + .5)
    -- a lighter plaque behind the icons so they read at 1x
    local pu0 = max(g.su0 + 2, floor((g.su0 + g.su1) / 2 - tot / 2) - 3)
    local pu1 = min(g.su1 - 2, floor((g.su0 + g.su1) / 2 + tot / 2 + .5) + 3)
    fm(g.Q(pu0, 33, pu1, 41), CREAM[4]) fm(g.Q(pu0, 40, pu1, 41), CREAM[5]) fm(g.Q(pu0, 33, pu1, 34), CREAM[3])
    for _, ic in ipairs(icons) do
      local h = #ic
      local y = floor(my - h / 2 + .5) + floor(slope * (x - mx) + .5)
      spr(x, y, ic, PMAP, slope)
      x = x + #ic[1] + 2
    end
  end

  -- shop-type door props
  local function hp(k, u, v) return hubG[k].px(u, v) end
  local HUBFLOW = { ROSE[5], MUST[6], RA.PLUM[5], ROSE[6], RA.ORANGE[5], TEAL[5] }
  do -- seeds: sprout pot + seed sack + packets in the window
    local g = hubG["hub-seeds"]
    local x, y = hp("hub-seeds", g.du0 - 4, 0)
    sprB(x, y, { "g.G.g", "GgGgG", ".gGg.", "..G..", "ooooo", "oTTto", "oTTto", ".oto." },
      { g = GREEN[4], G = GREEN[5], o = o1, T = RA.BARN[5], t = RA.BARN[3] })
    local x2 = hp("hub-seeds", g.du0 - 9, 0)
    sack(x2, y, RA.LEAFG)
    local w = g.shop[1]
    if w then for n = 0, 2 do local px, py = g.px(w.ul + 1 + n * 3, 13) fm(rect(px - 1, py, px, py + 2), ({ MUST[5], ROSE[4], RA.LEAFG[5] })[n + 1]) put(px - 1, py, CREAM[6]) end end
  end
  do -- food: pie cooling on the first-floor sill, crooked chimney with smoke
    local g = hubG["hub-food"]
    local w = g.wins[1]
    if w then
      local px, py = g.px(w.uc, w.v0 - 1)
      sprB(px, py - 1, { ".ooooo.", "oPpPpPo", "oPPPPPo", ".ooooo." }, { o = o1, P = MUST[4], p = MUST[6] })
      put(px - 1, py - 6, CREAM[6]) put(px, py - 7, CREAM[5]) put(px + 1, py - 8, CREAM[6])
    end
    -- loaf basket by the door
    local bx, by = hp("hub-food", g.du0 - 4, 0)
    sprB(bx, by, { ".lLl.", "lLlLl", "oWWWo", "oWwWo", ".ooo." }, { l = MUST[4], L = MUST[6], o = o1, W = OAK[4], w = OAK[6] })
    -- crooked chimney rising through the cap
    local chx = g.T(g.x0 + 9)
    local base = g.y0 + 6
    local stack = c:poly(X.P({ { chx - 2, base }, { chx + 2, base }, { chx + 4, g.y0 - 1 }, { chx, g.y0 - 1 } }))
    fm(stack, RA.BARN[4])
    stack:each(function(x, y) if (y + floor(x / 3)) % 3 == 0 then put(x, y, RA.BARN[3]) end end)
    stack:each(function(x, y) if not stack:has(x - 1, y) then put(x, y, RA.BARN[5]) end end)
    local pot = rect(chx - 1, g.y0 - 3, chx + 4, g.y0 - 2)
    fm(pot, RA.BARN[2]) put(chx - 1, g.y0 - 3, RA.BARN[5])
    c:rim(stack:copy():add(pot), INK)
    for s = 0, 6 do
      local sx, sy = chx + 2 + s * 2 + floor(sin(s * 1.3) * 2), g.y0 - 6 - s * 4
      local r = (s < 1) and 1 or 2
      local m = c:ellipse(sx, sy, r + .3, r * .8 + .3)
      m:each(function(x, y)
        if s >= 4 and (x + y) % 2 == 1 then return end
        tint(x, y, (m:has(x, y - 1) and m:has(x + 1, y)) and CREAM[4] or CREAM[6], .85 - s * .09)
      end)
    end
  end
  do -- florist: window boxes spilling flowers, flower buckets at the door
    local g = hubG["hub-florist"]
    for _, w in ipairs(g.wins) do
      g.Q(w.ul - 2, w.v0 - 7, w.ur + 2, w.v0 - 4):each(function(x, y) put(x, y, (y % 2 == 0) and OAK[3] or OAK[4]) end)
      for u = w.ul - 2, w.ur + 1 do
        local px, py = g.px(u, w.v0 - 3)
        local fc = HUBFLOW[1 + floor(hash(u, w.v0, 94) * #HUBFLOW)]
        put(px, py, GREEN[4]) put(px, py - 1, (u % 2 == 0) and fc or GREEN[5])
        if u % 3 == 0 then put(px, py - 2, fc) end
        if u % 4 == 1 then put(px, py + 4, GREEN[3]) put(px, py + 5, GREEN[4]) end
      end
    end
    for n = 0, 1 do
      local x, y = hp("hub-florist", (n == 0) and (g.du0 - 4) or (g.du0 - 9), 0)
      sprB(x, y, { "aRbRa", "RbGaR", ".GGG.", "oIIIo", "oIiIo", ".ooo." },
        { a = HUBFLOW[1 + n], b = HUBFLOW[3 + n], R = HUBFLOW[5 - n], G = GREEN[4], o = o1, I = IRON[4], i = IRON[5] })
    end
  end
  do -- decor: wall lamp beside the door, framed picture in the window, a hanging pendant lamp
    local g = hubG["hub-decor"]
    local x, y = hp("hub-decor", g.du0 - 3, 17)
    put(x + 1, y, IRON[2]) put(x, y, IRON[2])
    spr(x - 1, y + 1, { ".o.", "oYo", "oyo", ".o." }, { o = IRON[2], Y = W_HI, y = W_WHT })
    glow(x, y + 2, 8, GLOW, .32)
    local w = g.shop[1]
    if w then local px, py = g.px(floor((w.ul + w.ur) / 2), 15) spr(px - 2, py, { "FFFFF", "FsSsF", "FGGGF", "FFFFF" }, PMAP) end
    local w2 = g.shop[2]
    if w2 then local px, py = g.px(floor((w2.ul + w2.ur) / 2), 18) put(px, py, OAK[2]) put(px, py + 1, OAK[2]) spr(px - 2, py + 2, { ".ooo.", "oYYYo" }, { o = MUST[3], Y = W_HI }) end
  end
  do -- dyes: cloth banners hanging off a pole by the inner corner, a dye vat at the door
    local g = hubG["hub-dyes"]
    local px0, py0 = g.sx(0, 72)
    local pxl = g.x0 + 1
    for x = pxl, px0 do put(x, py0, OAK[2]) end
    put(px0 + 1, py0, OAK[1]) put(pxl, py0 + 1, OAK[1])
    local cloths = { ROSE, TEAL, MUST, RA.PLUM }
    for n = 0, 3 do
      local cxp = pxl + 1 + n * 4
      if cxp + 2 <= px0 then
        local len = 16 + floor(hash(n, 7, 95) * 12)
        local cr = cloths[n + 1]
        for yy = py0 + 1, py0 + len do
          local sway = floor(sin((yy - py0) / 6 + n) * .8 + .5)
          put(cxp + sway, yy, R(cr, 5)) put(cxp + 1 + sway, yy, R(cr, 4)) put(cxp + 2 + sway, yy, R(cr, 3))
          if yy == py0 + len then put(cxp + 1 + sway, yy, R(cr, 2)) end
        end
        put(cxp + 1, py0 + len + 2, R(cr, 4))  -- a drip
      end
    end
    local vx, vy = hp("hub-dyes", g.du0 - 6, 0)
    sprB(vx, vy, { ".ooooooo.", "oTTtTTPTo", "oWWWWWWWo", "oiiiiiiio", "oWWAWWWWo", ".ooooooo." },
      { o = o1, T = TEAL[4], t = TEAL[6], P = RA.PLUM[4], W = OAK[4], i = IRON[3], A = ROSE[4] })
    -- laundry of dyed cloth to the pets tower
    local pts = sagPts(342, 74, 372, 76, 4)
    for _, p in ipairs(pts) do put(p[1], p[2], CREAM[3]) end
    for n, cx2 in ipairs({ 346, 352, 362, 367 }) do
      local t = (cx2 - 342) / 30
      local yy = floor(74 + 2 * t + 16 * t * (1 - t) + 1.5)
      local cr = cloths[(n % 4) + 1]
      fm(rect(cx2, yy, cx2 + 3, yy + 5 + (n % 2) * 2), R(cr, 5)) fm(rect(cx2 + 3, yy, cx2 + 3, yy + 5 + (n % 2) * 2), R(cr, 3))
      put(cx2, yy, R(cr, 6))
    end
  end
  do -- pets: cage-bar balcony under the windows, a hanging cage on a bracket
    local g = hubG["hub-pets"]
    local floorM = g.Q(0, 42, g.FW - 1, 45)
    fm(floorM, OAK[3]) fm(g.Q(0, 44, g.FW - 1, 45), OAK[5])
    for u = 0, g.FW - 1, 2 do fm(g.Q(u, 45, u + 1, 53), IRON[2]) end
    fm(g.Q(0, 53, g.FW - 1, 54), IRON[4])
    c:rim(floorM, INK)
    local bx, by = g.px(1, 82)
    for x = bx - 6, bx do put(x, by, IRON[2]) end
    put(bx - 6, by + 1, IRON[2])
    spr(bx - 9, by + 2, { "...o...", "..ooo..", ".oYoYo.", "o.oYo.o", "oYoYoYo", "o.o.o.o", "ooooooo" }, { o = RA.GOLDL[3], Y = W_MID })
    local dx, dy = hp("hub-pets", g.du0 - 4, 0)
    sprB(dx, dy, { ".ooooo.", "oFsFsFo", "oFFFFFo", ".ooooo." }, { o = o1, F = OAK[5], s = MUST[5] })   -- feed tray
  end
  do -- more: lantern on a bracket by the door
    local g = hubG["hub-more"]
    local x, y = hp("hub-more", g.du0 - 3, 26)
    for xx = x - 3, x do put(xx, y, IRON[2]) end
    lantern(x - 3, y + 1, W_HI)
  end

  ---------------------------------------------------------------------------------------------------------
  -- 7. bunting across the street (avoids the clock face)
  local function avoidFace(x, y) return (x - 227) ^ 2 + (y - 118) ^ 2 <= 13 * 13 end
  bunting(162, 112, 302, 104, 36, 0, avoidFace)
  bunting(110, 70, 207, 90, 10, 2, avoidFace)
  bunting(251, 90, 302, 60, 9, 4, avoidFace)
  bunting(424, 112, 432, 108, 2, 1)
  bunting(56, 196, 116, 200, 6, 3)

  ---------------------------------------------------------------------------------------------------------
  -- 8. street lamps (posts on the local pavement, one on the terrace) with pools of light
  local function streetLamp(x, by, h)
    local top = by - h
    fm(rect(x, top + 6, x + 1, by), IRON[2]) fm(rect(x, top + 6, x, by), IRON[4])
    fm(rect(x - 1, by - 2, x + 2, by), IRON[2]) put(x - 1, by - 2, IRON[4])
    put(x - 1, top + 6, IRON[2]) put(x + 2, top + 6, IRON[2])
    spr(x - 2, top, { "..oo..", ".oooo.", "oYYYYo", "oYyyYo", "oYYYYo", ".oooo." }, { o = IRON[1], Y = W_HI, y = W_WHT })
    glow(x + .5, top + 3, 14, GLOW, .3)
    glow(x + .5, by + 2, 14, GLOW, .3, 4, true)
  end
  streetLamp(57, 268, 44)
  streetLamp(165, 256, 36)
  streetLamp(379, 250, 34)

  ---------------------------------------------------------------------------------------------------------
  -- 9. terrace: hanging moss, glowing mushrooms along the wedge and stair foot, mushroom arch at the stair head
  local function strand(x, y0, len)
    for y = y0, y0 + len - 1 do
      if free(x, y) then put(x, y, (y == y0 + len - 1) and MOSS[5] or ((y - y0) % 2 == 0 and MOSS[3] or MOSS[4])) end
    end
  end
  for x = 307, 479 do
    if hash(x, 250, 101) > .55 then strand(x, 251, 1 + floor(hash(x, 1, 102) * ((x > 380) and 6 or 8))) end
  end
  for _, gx in ipairs({ { 287, 299 }, { 330, 334 }, { 378, 382 }, { 426, 430 } }) do   -- moss off the ledge in the gaps
    for x = gx[1], gx[2] do if hash(x, 149, 103) > .35 then strand(x, 150, 2 + floor(hash(x, 2, 104) * 6)) end end
  end
  local GCAP = { TEAL, ROSE, MUST }
  local function glowShroom(x, by, kind, big)
    local cr = GCAP[kind]
    if big then
      sprB(x, by, { ".hHh.", "hHcHh", "ooSoo", "..S..", "..s.." }, { h = R(cr, 6), H = mix(R(cr, 6), CREAM[6], .5), c = CREAM[6], o = R(cr, 3), S = CREAM[5], s = CREAM[4] }, true)
      glow(x, by - 3, 9, R(cr, 6), .6, 7, true)
    else
      sprB(x, by, { "hHh", ".S.", ".s." }, { h = R(cr, 6), H = CREAM[6], S = CREAM[5], s = CREAM[4] }, true)
      glow(x, by - 2, 6, R(cr, 6), .5, 5, true)
    end
  end
  -- along the wedge edge from the stair foot up to the compass corner
  local n = 0
  for x = 316, 372, 7 do
    local yEdge = floor(292 - (x - 318) * 32 / 62 + .5)
    glowShroom(x + floor(hash(x, 1, 105) * 3), yEdge + 1, (n % 3) + 1, true)
    if n % 2 == 1 then glowShroom(x + 3, yEdge + 2, ((n + 1) % 3) + 1, false) end
    n = n + 1
  end
  -- ring of tiny glow-caps on the terrace lip by the doors
  for _, p in ipairs({ { 334, 252 }, { 340, 253 }, { 346, 252 }, { 420, 253 }, { 427, 252 }, { 470, 253 } }) do
    glowShroom(p[1], p[2], (p[1] % 3) + 1, false)
  end
  -- mushroom arch over the stair head
  do
    local ax0, ax1, top = 292, 310, 222
    local stemL = rect(ax0, 233, ax0 + 2, 249)
    local stemR = rect(ax1 - 2, 233, ax1, 249)
    local inner = rect(ax0 + 3, 233, ax1 - 3, 249)
    -- warm light inside the arch
    inner:each(function(x, y) if (x + y) % 2 == 0 or y > 240 then tint(x, y, GLOW, .3) else tint(x, y, GLOW, .18) end end)
    for _, s in ipairs({ stemL, stemR }) do
      s:each(function(x, y)
        local bx = s:bbox()
        local i = x - bx
        put(x, y, (i == 0) and CREAM[5] or ((i == 1) and CREAM[4] or CREAM[3]))
        if (y % 5 == 0) and i == 1 then put(x, y, CREAM[3]) end
      end)
    end
    local cap = c:ellipse((ax0 + ax1) / 2, 233, (ax1 - ax0) / 2 + 3, 10):clip(rect(ax0 - 4, top, ax1 + 4, 233))
    local open = c:ellipse((ax0 + ax1) / 2, 236, (ax1 - ax0) / 2 - 3, 5):clip(rect(ax0, 228, ax1, 236))
    cap:cut(open)
    local cxm = (ax0 + ax1) / 2
    cap:each(function(x, y)
      local nn = (x - cxm) / 12
      local idx = 4
      if nn > .4 then idx = 3 end
      if y <= top + 3 and nn < 0 then idx = 5 end
      if y >= 232 then idx = 2 end
      put(x, y, R(ROSE, idx))
    end)
    for _, p in ipairs({ { -6, 226 }, { 0, 224 }, { 5, 227 }, { -9, 230 }, { 9, 230 } }) do
      local x, y = floor(cxm + p[1]), p[2]
      if cap:has(x, y) then put(x, y, W_WHT) if cap:has(x + 1, y) then put(x + 1, y, W_HI) end end
    end
    -- gill fringe under the cap opening
    open:each(function(x, y) if not open:has(x, y - 1) and x % 2 == 0 then put(x, y, ROSE[2]) end end)
    open:each(function(x, y) if open:has(x, y - 1) then tint(x, y, GLOW, .35) end end)
    c:rim(cap:copy():add(stemL):add(stemR), INK)
    glow(cxm, 236, 16, GLOW, .22, 12)
  end
  -- glowing caps tucked at the stair foot (below the figure zone)
  glowShroom(289, 291, 1, false)
  glowShroom(313, 291, 3, false)

  ---------------------------------------------------------------------------------------------------------
  -- 10. drifting leaves / petals: in the deep street air and along the kerb edges (never in the clear zones)
  local LEAFC = { { RA.MAPLE[4], RA.MAPLE[5] }, { ROSE[5], ROSE[6] }, { RA.LEAFG[4], RA.LEAFG[5] }, { RA.ORANGE[4], RA.ORANGE[5] } }
  local placed = 0
  for s = 0, 200 do
    if placed >= 26 then break end
    local x = floor(hash(s, 1, 111) * 470) + 4
    local y = 252 + floor(hash(s, 2, 112) * 46)
    local ok = free(x, y) and free(x + 1, y + 1) and (x < 205 or (x > 318 and x < 376 and y > 292 - (x - 318) * 32 / 62 + 4))
    if ok then
      local lc = LEAFC[1 + (s % 4)]
      put(x, y, lc[1]) put(x + 1, y, lc[2]) if s % 3 == 0 then put(x + 1, y + 1, lc[1]) end
      placed = placed + 1
    end
  end
  for s = 0, 11 do
    local x = 260 + floor(hash(s, 3, 113) * 26)
    local y = 150 + floor(hash(s, 4, 114) * 90)
    local lc = LEAFC[1 + (s % 2) * 1]
    if free(x, y) then put(x, y, lc[2]) if s % 2 == 0 then put(x + 1, y - 1, lc[1]) end end
  end
  for s = 0, 7 do
    local x = 384 + floor(hash(s, 5, 115) * 40)
    local y = 160 + floor(hash(s, 6, 116) * 40)
    put(x, y, ROSE[6]) if s % 2 == 0 then put(x + 1, y, ROSE[5]) end
  end

  ---------------------------------------------------------------------------------------------------------
  -- 11. light shafts from the upper right (diagonal bands, stepped: core + dithered edge, fading downward)
  local SHAFT = mix(GLOW, CREAM[6], .5)
  local bands = { { 600, 16 }, { 548, 8 }, { 500, 20 }, { 440, 6 }, { 395, 12 } }
  for y = 0, BASE - 1 do
    local fade = 1 - y / 270
    for x = 0, 479 do
      local q = x + 0.62 * y
      for _, b in ipairs(bands) do
        local dq = abs(q - b[1])
        if dq < b[2] / 2 then
          if dq < b[2] / 2 - 2 then tint(x, y, SHAFT, .17 * fade)
          elseif (x + y) % 2 == 0 then tint(x, y, SHAFT, .09 * fade) end
          break
        end
      end
    end
  end

  return c
end
