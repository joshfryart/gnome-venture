-- _frame.lua : RAINFOREST gate-view frame for the stop-type looks, palette "rainforest_canopy".
-- A copy of art-forest-stops/_frame.lua (itself from the Maplewold opus3 frame) with the same API and composition
-- compass (horizon y=112, slab road, gate, bunting, lanterns, compass corner, depth planes, rim light), re-skinned:
-- saturated emerald / teal canopy palette, humid golden-green sky with a misted sun, rounded canopy ridges and mist,
-- a broadleaf canopy tree line, wet red-brown leaf-litter ground (fallen leaves, seedlings, ferns, heliconia,
-- orchids, puddles, wet-shine pebbles), wet slabs with shine and moss, a vine-and-leaf draped gate, palm-leaf
-- thatch on every roof, golden light shafts. F.tree draws broadleaf canopy trees / palms / tree ferns;
-- F.conifer, F.pine and F.birch are kept (same signatures) but now draw rainforest trees, so forest scripts port.
-- New helpers: F.canopy, F.palm, F.treeFern, F.bigLeaf, F.vine, F.vines, F.heliconia, F.orchid, F.bamboo,
-- F.bambooWall, F.palmThatch, F.shine, F.puddle, F.buttress.
--   local F = dofile(DIR .. "_frame.lua").build{ name = "mill", out = DIR [, roadTop = 124] [, noRoad = true] [, noShafts = true] }
--   ... draw back -> front on F.c ...
--   F.finish()
local M = {}

function M.build(o)
  local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
  local floor, sin, cos, abs, pi = math.floor, math.sin, math.cos, math.abs, math.pi

  local function rp(s) -- "hi base shade deep edge"
    local t = {} for h in s:gmatch("#%x+") do t[#t + 1] = h end
    return { hi = t[1], base = t[2], shade = t[3], deep = t[4], edge = t[5] or t[4] }
  end
  -- rainforest_canopy: same keys as Maplewold / forest so type scripts keep working; the MEANING of some keys shifts:
  -- roof = golden dried palm thatch, roof2 = fresh green palm-leaf thatch, plaster = woven palm mat / pale clay,
  -- foliage = deep emerald broadleaf, foliage2 = teal canopy, board = split bamboo (pale straw), timber = wet dark hardwood.
  local L = {
    sky = { "#93c2a6", "#acd0a6", "#c4daa2", "#d8e0a0", "#e8e4a8" },
    cloud = { top = "#eef0d2", under = "#c4dab4" },
    hillFar = "#88b8a2", hillMid = "#4f9278", hillMidShade = "#3e7c68",
    ridgeFar = "#76aa96", ridgeMid = "#3a7a62", mist = "#cfe2c6", mist2 = "#e2eccc",
    farTree = rp("#9ed2b4 #72b298 #52927e #3c766c #285858"),
    ground = rp("#c08458 #9a5c3a #74402c #522c22 #321c18"), groundFar = "#6e9e62",
    road = rp("#c4cdb8 #9aa694 #768474 #56645a #36443e"), slabRatio = 1.06, slabK = 15,
    stone = rp("#c8d2bc #9caa96 #788878 #56665c #36463f"),
    plaster = rp("#f0e2b2 #d8c48c #b4a068 #8a7a4e #5a4e34"),
    wall2 = rp("#a8dccc #66b4a2 #468e82 #326864 #204646"),
    timber = rp("#b07e5a #86563a #643e2c #462a22 #2c1a18"),
    roof = rp("#ecd282 #c4a456 #9a7c3e #6e5630 #46361f"),
    roof2 = rp("#bcd870 #88b04a #5e883a #40642e #283f22"),
    awnA = rp("#ff8c6a #e8423a #b82a36 #7e1e32 #4c1226"),
    awnB = rp("#f4f0d8 #e2dcbc #c0b898 #948e78 #5c584a"),
    accent = rp("#7cdcc4 #30aa94 #208478 #185e5c #0e3c42"),
    foliage = rp("#9ade70 #4eb05a #2a8a50 #1a6446 #0f4034"),
    foliage2 = rp("#76d0aa #36a48c #20826e #165e58 #0c3c40"),
    leaf = rp("#cdea6a #8ccc48 #58a63c #3a7c36 #22522a"),
    water = rp("#cdeedc #80d0bc #44a69e #2a7c82 #1a5262"),
    glow = rp("#fff6c0 #ffd870 #f6aa42 #d27a30 #8a4a24"),
    soil = rp("#b0704a #8a4c34 #6a3428 #4a2420 #2e1618"),
    board = rp("#eee0a0 #d2c070 #ac9850 #80703a #524628"),
    produce = rp("#ffbc4a #f48422 #ca5c1c #943e1c #5e2618"),
    lav = rp("#f4b8ec #d87cd0 #ac54aa #7a3a80 #4c2252"),
    iron = rp("#b0b8b6 #7c8688 #5a6468 #3e464e #262c36"),
    skin = rp("#ffe0bd #f0b98d #c98462 #7a4036 #4a2620"),
    apple = rp("#ff8a6c #e23c3a #b02436 #741c30 #4a1222"),
    petal = rp("#fcc4d4 #f088a8 #cc5c84 #964062 #5e2840"),
    gold = rp("#f8e486 #e6c04e #bc9438 #88662a #563f22"),
    -- forest keys kept so forest-derived scripts still run (re-meant for the rainforest)
    moss = rp("#bce26c #7cba48 #54943c #386c32 #224a28"),
    birch = rp("#e6e6d2 #c8ccb6 #a0a690 #767c6c #4a4e46"),          -- pale fig / kapok bark
    birchLeaf = rp("#d6ee7a #a6d454 #74b040 #4e8638 #305a2a"),      -- bright young canopy
    redbark = rp("#e0885a #b65a3a #8a3e30 #5e2a28 #3a1a1c"),        -- mahogany / red bark
    needle = rp("#e0a462 #bc7438 #94522c #6a3824 #42241c"),         -- dry fallen leaf / palm fibre
    fern = rp("#acea7c #66be52 #3e963e #286c34 #184628"),
    mossGround = rp("#86b45c #62964a #48783e #325a32 #203e26"), duff = "#5c3428",
    -- rainforest-only ramps
    vine = rp("#b2dc72 #72b246 #4a8a38 #32642e #1e4022"),
    bamboo = rp("#e2ea8a #b4cc5a #86a240 #5e7832 #3a4c24"),
    palmTrunk = rp("#ccb48e #a08866 #7a644c #544436 #342a22"),
    litter = rp("#e29a5a #c06c38 #94482a #663022 #401c18"),
    orchid = rp("#fcd2f4 #e890dc #c060b4 #8a3c86 #54245a"),
    helic = rp("#ffe070 #ffa43a #f05a2c #b8302c #6e1a24"),
    teal = rp("#8ae6cc #3cbca0 #24947e #186c62 #0e4644"),
    wet = "#e8f4e6", shine = "#d6ecdc",
    shaft = "#f6eeb2",
    shadow = "#5c3c2e", shadowRoad = "#66746a",
  }

  local W, H, HZ, VX = 480, 270, 112, 240
  local ROAD_TOP = o.roadTop or 124
  local function xl(y) return 234 - (y - 124) * 0.3 end
  local function xr(y) return 246 + (y - 124) * 0.3 end

  local c = HP.canvas{ w = W, h = H, scale = 1, name = o.name or "stop" }
  local roadM = HP.mask()

  -- opus3: every write records a depth plane and an object id (a new id per c:rim call / F.depth call);
  -- rim pixels are flagged. finish() uses them for atmospheric haze (far, mid) and an upper-left rim light (near).
  local DEP, OID, RIMF = {}, {}, {}
  local curD, curId, inRim = 0, 0, false
  local rawput = c.put
  c.put = function(self, x, y, hex, owner)
    if x >= 0 and y >= 0 and x < W and y < H then
      local i = y * W + x
      DEP[i] = curD OID[i] = curId RIMF[i] = inRim or nil
    end
    rawput(self, x, y, hex, owner)
  end
  local rawrim = c.rim
  c.rim = function(self, m, hex, clip)
    curId = curId + 1 inRim = true
    local r = rawrim(self, m, hex, clip)
    inRim = false
    return r
  end
  local function setDepth(d) curD = d curId = curId + 1 end
  local function newObj() curId = curId + 1 end

  -- colour utils (hard pixels: every result is one opaque colour)
  local function h2rgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
  local function rgb2h(r, g, b)
    local function cl(v) v = floor(v + .5) if v < 8 then v = 8 end if v > 250 then v = 250 end return v end
    return string.format("#%02x%02x%02x", cl(r), cl(g), cl(b))
  end
  local function mix(a, b, t)
    local r1, g1, b1 = h2rgb(a) local r2, g2, b2 = h2rgb(b)
    return rgb2h(r1 + (r2 - r1) * t, g1 + (g2 - g1) * t, b1 + (b2 - b1) * t)
  end
  local function toHsl(h)
    local r, g, b = h2rgb(h) r, g, b = r / 255, g / 255, b / 255
    local mx, mn = math.max(r, g, b), math.min(r, g, b)
    local l = (mx + mn) / 2
    if mx == mn then return 0, 0, l end
    local d = mx - mn
    local s = l > .5 and d / (2 - mx - mn) or d / (mx + mn)
    local hh
    if mx == r then hh = (g - b) / d + (g < b and 6 or 0) elseif mx == g then hh = (b - r) / d + 2 else hh = (r - g) / d + 4 end
    return hh * 60, s, l
  end
  local function fromHsl(hh, s, l)
    hh = (hh % 360) / 360
    local function f(p, q, t) if t < 0 then t = t + 1 end if t > 1 then t = t - 1 end
      if t < 1 / 6 then return p + (q - p) * 6 * t end if t < 1 / 2 then return q end
      if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end return p end
    if s == 0 then return rgb2h(l * 255, l * 255, l * 255) end
    local q = l < .5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    return rgb2h(f(p, q, hh + 1 / 3) * 255, f(p, q, hh) * 255, f(p, q, hh - 1 / 3) * 255)
  end
  local function toward(hh, target, deg) -- rotate hue hh toward target by deg
    local d = ((target - hh + 540) % 360) - 180
    if math.abs(d) < deg then return target end
    return hh + (d > 0 and deg or -deg)
  end
  -- shift: dl = lightness change (-1..1 of headroom), hue moves toward yellow when lighter, violet when darker
  local function shift(hex, dl, ds)
    local hh, s, l = toHsl(hex)
    if dl > 0 then hh = toward(hh, 48, 14 * dl * 2) l = l + (1 - l) * dl
    else hh = toward(hh, 265, 14 * -dl * 2) l = l * (1 + dl) end
    s = math.max(0, math.min(1, s * (ds or 1)))
    return fromHsl(hh, s, math.min(.94, l))
  end
  local HAZE = "#d4e2bc" -- rainforest: humid golden-green haze

  local function hash(a, b, s)
    local n = (a * 374761393 + b * 668265263 + (s or 0) * 1442695041) & 0x7fffffff
    n = ((n ~ (n >> 13)) * 1274126177) & 0x7fffffff
    return (n % 10007) / 10007
  end
  -- smooth value noise 0..1 (bilinear over hashed lattice), for ground patches
  local function vnoise(x, y, seed)
    local x0, y0 = floor(x), floor(y)
    local fx, fy = x - x0, y - y0
    fx, fy = fx * fx * (3 - 2 * fx), fy * fy * (3 - 2 * fy)
    local a, b = hash(x0, y0, seed), hash(x0 + 1, y0, seed)
    local cc, d = hash(x0, y0 + 1, seed), hash(x0 + 1, y0 + 1, seed)
    return (a + (b - a) * fx) * (1 - fy) + (cc + (d - cc) * fx) * fy
  end
  local function px(x, y, h) c:put(x, y, h) end
  local function rect(a, b, cc, d) return c:rect(a, b, cc, d) end
  local function poly(t) return c:poly(t) end
  local function line(t, w) return c:line(t, w or 1) end
  local function fill(m, h) c:fillMask(m, h) return m end
  local function part(m, r, op) return c:part(m, r, op) end
  local function hline(x0, x1, y, h) for x = x0, x1 do px(x, y, h) end end
  local function vline(x, y0, y1, h) for y = y0, y1 do px(x, y, h) end end
  local function union(...) local m = HP.mask() for _, a in ipairs({ ... }) do m:add(a) end return m end
  local function rimOf(m, r) c:rim(m, r.edge) end

  local function shadow(x0, x1, yb, dx, dy)
    local m = poly{ { x0, yb - 2 }, { x1, yb - 2 }, { x1 + dx, yb + dy }, { x0 + dx, yb + dy } }
    m:each(function(x, y) px(x, y, roadM:has(x, y) and L.shadowRoad or L.shadow) end)
  end
  local function shadowM(m) m:each(function(x, y) px(x, y, roadM:has(x, y) and L.shadowRoad or L.shadow) end) end
  local function courses(m, y0, rowH, bw, r, seed)
    m:each(function(x, y)
      local row = (y - y0) // rowH
      local off = (row % 2) * (bw // 2) + (seed or 0)
      local ry, rx = (y - y0) % rowH, (x + off) % bw
      if ry == 0 or rx == 0 then px(x, y, r.deep)
      elseif ry == 1 and rx == 1 then px(x, y, r.hi)
      elseif ry == rowH - 1 and hash(x // bw, row, 7) < .5 then px(x, y, r.shade) end
    end)
  end
  local function hrows(m, y0, step, h) m:each(function(x, y) if (y - y0) % step == 0 then px(x, y, h) end end) end
  local function speckle(m, r, dens, seed)
    m:each(function(x, y)
      local v = hash(x, y, seed or 3)
      if v < dens then px(x, y, r.hi) elseif v > 1 - dens then px(x, y, r.deep) end
    end)
  end
  local function window(x0, y0, x1, y1, fr, arched)
    local f = arched and c:rrect(x0 - 1, y0 - 1, x1 + 1, y1 + 4, 3):clip(rect(x0 - 1, y0 - 1, x1 + 1, y1 + 1)) or rect(x0 - 1, y0 - 1, x1 + 1, y1 + 1)
    fill(f, fr.deep)
    local g = f:shrink(1)
    fill(g, L.glow.base)
    g:each(function(x, y) if not g:has(x + 1, y + 1) then px(x, y, L.glow.shade) end end)
    px(x0 + 1, y0 + 1, L.glow.hi) px(x0 + 2, y0 + 1, L.glow.hi)
    vline((x0 + x1) // 2, y0, y1, fr.base)
    if y1 - y0 > 5 then hline(x0, x1, (y0 + y1) // 2, fr.base) end
    hline(x0 - 2, x1 + 2, y1 + 2, fr.hi) hline(x0 - 2, x1 + 2, y1 + 3, fr.deep)
  end
  local function door(x0, y0, x1, y1, r, arched)
    local m = arched and c:rrect(x0, y0, x1, y1 + 6, 4):clip(rect(x0, y0, x1, y1)) or rect(x0, y0, x1, y1)
    part(m, r, { inner = false })
    c:edgeIn(m, r.edge)
    for x = x0 + 3, x1 - 2, 3 do vline(x, y0 + 3, y1 - 1, r.shade) end
    px(x1 - 2, (y0 + y1) // 2 + 2, L.glow.hi)
    return m
  end
  local flatCrown = false
  local F_thatch, F_planks, F_water, F_palmThatch
  local function crown(cx, cy, rx, ry, r, seed, noRim)
    local pts, n = {}, 16
    for i = 0, n - 1 do
      local a = i / n * 2 * math.pi
      local k = .78 + .34 * hash(i, seed, 11)
      pts[#pts + 1] = { cx + cos(a) * rx * k, cy + sin(a) * ry * k }
    end
    local m = poly(pts)
    if not noRim then rimOf(m, r) end
    part(m, r)
    if flatCrown or rx < 7 then
      m:each(function(x, y)
        local v = hash(x, y, seed)
        local ul = (x - cx) / rx + (y - cy) / ry < -.2
        if v < .10 then px(x, y, ul and r.hi or r.base)
        elseif v > .88 then px(x, y, ul and r.base or r.deep) end
      end)
      return m
    end
    -- opus3: clumped foliage. Leaf clumps each lit from the upper left, 6 tones (glint, hi, base, shade, deep, edge),
    -- the whole crown darker to the lower right, speckled leaf texture.
    local glint = r.glint or shift(r.hi, .35, 1.05)
    local blobs, nb = {}, math.max(5, floor(rx * ry / 28))
    for i = 1, nb do
      local a, d = hash(i, seed, 31) * 2 * math.pi, math.sqrt(hash(i, seed, 32)) * .78
      blobs[i] = { cx + cos(a) * rx * d, cy + sin(a) * ry * d, (.28 + .2 * hash(i, seed, 33)) * math.min(rx, ry) + 2 }
    end
    m:each(function(x, y)
      local best, bi = 1e9, 1
      for i = 1, nb do local b = blobs[i] local d = ((x - b[1]) ^ 2 + (y - b[2]) ^ 2) / (b[3] * b[3]) if d < best then best, bi = d, i end end
      local b = blobs[bi]
      local nx, ny = (x - b[1]) / b[3], (y - b[2]) / b[3]
      local lit = -(nx * .6 + ny * .8) * .9 - ((x - cx) / rx * .5 + (y - cy) / ry * .6) * .7
      lit = lit + (hash(x, y, seed) - .5) * .5
      local h
      if lit > .95 then h = glint elseif lit > .45 then h = r.hi elseif lit > -.25 then h = r.base
      elseif lit > -.85 then h = r.shade else h = r.deep end
      if best > .85 and best < 1.25 and lit < .2 then h = r.deep end -- clump underside
      px(x, y, h)
    end)
    for _, e in ipairs({ m:edge() }) do e:each(function(x, y) if (x - cx) / rx + (y - cy) / ry > .3 then px(x, y, r.deep) end end) end
    return m
  end
  local function maple(x, yb, h, r, seed, far)
    local tr = far and L.farTree or L.timber
    local t = rect(x - 2, yb - h // 2, x + 1, yb)
    if not far then rimOf(t, tr) end
    part(t, tr, { nopop = true })
    return crown(x, yb - h * .62, h * .45, h * .36, far and L.farTree or r, seed)
  end
  -- rainforest: a hanging vine from (x,y) down len px: a wandering stem with alternate leaves, optional flower tip.
  local function vine(x, y, len, seed, r, flower)
    r = r or L.vine
    newObj()
    local tip
    for k = 0, len do
      local xx = x + floor(sin((k + seed) / 3.3) * 1.2 + .5)
      local yy = y + k
      px(xx, yy, (k % 4 == 0) and r.deep or r.shade)
      if k > 1 and k % 3 == 0 then
        local s = (k // 3) % 2 == 0 and -1 or 1
        px(xx + s, yy, s < 0 and r.hi or r.base)
        px(xx + s, yy + 1, s < 0 and r.base or r.shade)
        if len > 9 and hash(k, seed, 5) < .5 then px(xx + 2 * s, yy + 1, s < 0 and r.shade or r.deep) end
      end
      tip = { xx, yy }
    end
    if flower then
      px(tip[1], tip[2] + 1, flower.base) px(tip[1] - 1, tip[2] + 1, flower.hi) px(tip[1] + 1, tip[2] + 1, flower.shade) px(tip[1], tip[2] + 2, flower.deep)
    end
    return tip
  end
  -- vines dropping from the underside of a mask: k = chance per bottom pixel, maxLen = longest vine
  local function vines(m, k, seed, maxLen, r)
    maxLen = maxLen or 12
    local list = {}
    m:each(function(x, y) if not m:has(x, y + 1) and hash(x, y, seed) < k then list[#list + 1] = { x, y } end end)
    table.sort(list, function(a, b) return a[1] * 1000 + a[2] < b[1] * 1000 + b[2] end)
    local last = -99
    for _, p in ipairs(list) do
      if p[1] - last > 2 then
        last = p[1]
        local len = 3 + floor(hash(p[1], 1, seed) * (maxLen - 3))
        local fl = hash(p[1], 2, seed) < .22 and (hash(p[1], 3, seed) < .5 and L.orchid or L.helic) or nil
        vine(p[1], p[2] + 1, len, p[1] + seed, r, fl)
      end
    end
  end
  -- a crown of arching fronds from (tx,ty): n fronds, each about len px, drooping under their weight.
  -- kind "palm": long leaflets hanging from the rachis; kind "fern": short fine leaflets and curled tips.
  local function fronds(tx, ty, n, len, r, seed, kind)
    local col, order = {}, {}
    local function put(x, y, h) local k = y * W + x if not col[k] then order[#order + 1] = k end col[k] = h end
    for i = 1, n do
      local a = -pi - .5 + (i - .5) / n * (pi + 1.0) + (hash(i, seed, 1) - .5) * .3
      local dx, dy = cos(a), sin(a)
      local ln = len * (.75 + .35 * hash(i, seed, 2))
      local droop = kind == "fern" and .7 or .6
      local steps = floor(ln * 1.6)
      local lit = dx < .35
      local lx, ly
      for s = 0, steps do
        local t = s / steps
        local x = floor(tx + dx * ln * t + .5)
        local y = floor(ty + dy * ln * t + droop * ln * t * t + .5)
        if x ~= lx or y ~= ly then
          lx, ly = x, y
          local sx = dx >= 0 and 1 or -1
          if kind == "fern" then
            local ll = floor(1 + 2.2 * (1 - t))
            for q = 1, ll do put(x + floor(q * .4 * sx + .5), y + q, q == ll and r.deep or r.shade) end
            put(x, y - 1, lit and r.hi or r.base)
            put(x, y, lit and r.base or r.shade)
            if t > .93 then put(x - sx, y + 1, r.hi) end
          else
            local ll = floor(1 + 4.5 * sin(pi * math.min(1, t * 1.1)))
            for q = 1, ll do
              local h = q == ll and r.deep or ((s % 2 == 0) and r.shade or (lit and r.base or r.shade))
              put(x + floor(q * .3 * sx + .5), y + q, h)
            end
            put(x, y, lit and (t < .6 and r.hi or r.base) or r.base)
          end
        end
      end
    end
    local m = HP.mask()
    for _, k in ipairs(order) do m:set(k % W, k // W) end
    c:rim(m, r.edge)
    for _, k in ipairs(order) do px(k % W, k // W, col[k]) end
    return m
  end
  -- a coconut / royal palm: a gently curving ringed trunk, a frond crown, a coconut cluster. o.ramp, o.lean, o.far
  local function palm(x, yb, h, seed, o)
    o = o or {}
    local r = o.ramp or (o.far and L.farTree or L.foliage)
    local lean = o.lean or (hash(seed, 1, 91) - .5) * h * .35
    local tx, ty = floor(x + lean + .5), yb - h
    local trunk = HP.mask()
    local tw = h >= 40 and 1 or 0
    for y = ty + 1, yb do
      local t = (yb - y) / h
      local cx = floor(x + lean * t * t + .5)
      for xx = cx - tw, cx + 1 + (y > yb - 3 and 1 or 0) do trunk:set(xx, y) end
    end
    local bark = o.far and L.farTree or L.palmTrunk
    rimOf(trunk, bark)
    trunk:each(function(xx, yy)
      local h2 = trunk:has(xx - 1, yy) and (trunk:has(xx + 1, yy) and bark.base or bark.shade) or bark.hi
      if (yy - ty) % 3 == 0 then h2 = bark.deep end
      px(xx, yy, h2)
    end)
    local m = fronds(tx, ty, h >= 30 and 9 or 7, h * .36 + 3, r, seed, "palm")
    if not o.far and h >= 26 then
      for k, d in ipairs({ { -2, 2 }, { 1, 2 }, { -1, 4 } }) do
        local nut = c:ellipse(tx + d[1], ty + d[2], 1, 1)
        c:rim(nut, L.soil.edge) fill(nut, k == 3 and L.gold.shade or L.soil.base) px(tx + d[1] - 1, ty + d[2] - 1, L.soil.hi)
      end
    end
    return m
  end
  -- a tree fern: a slim dark fibrous trunk and a shuttlecock of fern fronds with a fiddlehead in the middle
  local function treeFern(x, yb, h, seed, r)
    r = r or L.fern
    local ty = yb - h
    local trunk = rect(x - 1, ty, x, yb)
    rimOf(trunk, L.timber)
    trunk:each(function(xx, yy) px(xx, yy, (hash(xx, yy, seed) < .35) and L.timber.deep or (xx < x and L.timber.base or L.timber.shade)) end)
    local m = fronds(x, ty, 8, h * .5 + 3, r, seed, "fern")
    px(x, ty - 2, r.hi) px(x + 1, ty - 3, r.hi) px(x + 1, ty - 2, r.base) -- fiddlehead
    return m
  end
  -- a broadleaf canopy tree: straight trunk (pale or dark bark), buttress-root fins at the foot, two limbs, an
  -- umbrella crown of three clumped lobes, vines hanging off the crown. o.w = crown half width, o.far, o.bark,
  -- o.small (no fins, no vines). Returns the crown mask.
  local function canopy(x, yb, h, r, seed, o)
    o = o or {}
    r = r or L.foliage
    local far = o.far
    local bark = far and L.farTree or (o.bark or (seed % 2 == 0 and L.birch or L.timber))
    local cw = o.w or floor(h * .48)
    local cy = floor(yb - h * .68)
    local ch = math.max(3, floor(h * .2))
    local tw = h >= 44 and 2 or (h >= 22 and 1 or 0)
    local trunk = poly{ { x - tw - 1, yb }, { x + tw + 1, yb }, { x + tw, cy + ch }, { x - tw, cy + ch } }
    local fins = HP.mask()
    if not far and not o.small and h >= 30 then
      local fh = floor(h * .16)
      for k, s in ipairs({ -1, 1, -1, 1 }) do
        local spread = floor(h * (k <= 2 and .13 or .07)) + 1
        local fy = floor(fh * (k <= 2 and 1 or .6))
        fins:add(poly{ { x + s * tw, yb - fy }, { x + s * (tw + spread * .3), yb - fy * .3 }, { x + s * (tw + spread), yb }, { x + s * tw, yb } })
      end
    end
    local br = HP.mask()
    if not far and h >= 26 then
      br:add(line({ { x, cy + ch + 3 }, { x - floor(cw * .5), cy + 2 } }, 1))
      br:add(line({ { x, cy + ch + 1 }, { x + floor(cw * .55), cy + 1 } }, 1))
    end
    local wood = union(trunk, fins, br)
    rimOf(wood, bark)
    part(trunk, bark, { nopop = true })
    if not far then
      trunk:each(function(xx, yy)
        if not trunk:has(xx - 1, yy) then px(xx, yy, bark.hi) end
        if hash(xx, yy // 3, seed) < .14 then px(xx, yy, bark.shade) end
        if bark == L.birch and hash(xx // 2, yy // 4, seed + 1) < .1 then px(xx, yy, L.moss.base) end
      end)
      fins:each(function(xx, yy)
        local h2 = xx < x and bark.base or bark.shade
        if not fins:has(xx, yy - 1) and xx < x then h2 = bark.hi end
        if (xx == x - tw - 1 or xx == x + tw + 1) and yy < yb - 1 then h2 = bark.deep end
        px(xx, yy, h2)
      end)
      br:each(function(xx, yy) px(xx, yy, bark.shade) end)
    end
    local cr = far and L.farTree or r
    local m = HP.mask()
    local lobes = {
      { x + floor(cw * .08), cy - floor(ch * .35), floor(cw * .62) + 1, floor(ch * .85) + 1 },
      { x - floor(cw * .5), cy + floor(ch * .35), floor(cw * .5) + 1, floor(ch * .75) + 1 },
      { x + floor(cw * .5), cy + floor(ch * .3), floor(cw * .5) + 1, floor(ch * .8) + 1 },
    }
    for i, lb in ipairs(lobes) do m:add(crown(lb[1], lb[2], lb[3], lb[4], cr, seed * 7 + i)) end
    if not far and not o.small and h >= 24 and not o.noVines then vines(m, .07, seed, floor(h * .4)) end
    if not far and h >= 36 then -- a red bromeliad perched in the fork
      local bx, by = x - floor(cw * .25), cy + ch
      px(bx, by, L.helic.base) px(bx - 1, by - 1, L.helic.hi) px(bx + 1, by - 1, L.helic.shade) px(bx, by - 1, L.helic.base) px(bx, by + 1, L.vine.deep)
    end
    return m
  end
  -- F.tree: rainforest default. seed%4: 0 = teal canopy, 1 = emerald canopy, 2 = palm, 3 = pale fig with lime crown.
  -- far = hazed little umbrella tree. Crown half width = 0.4*h (a conifer was 0.32*h).
  local function tree(x, yb, h, seed, far)
    if far then return canopy(x, yb, h, L.farTree, seed, { far = true, w = floor(h * .42) }) end
    local k = seed % 4
    if k == 2 then return palm(x, yb, h, seed) end
    if k == 3 then return canopy(x, yb, h, L.leaf, seed, { w = floor(h * .4), bark = L.birch }) end
    return canopy(x, yb, h, k == 1 and L.foliage or L.foliage2, seed, { w = floor(h * .4) })
  end
  -- forest-API compatibility: same signatures, rainforest trees
  local function conifer(x, yb, h, r, seed, o)
    o = o or {}
    return canopy(x, yb, h, o.far and L.farTree or (r or L.foliage2), seed, { far = o.far, bark = o.bark, w = o.w or math.max(3, floor(h * (o.slim and .26 or .34))) })
  end
  local function pine(x, yb, h, r, seed) return palm(x, yb, h, seed, { ramp = r }) end
  local function birch(x, yb, h, seed) return canopy(x, yb, h, L.birchLeaf, seed, { w = floor(h * .3) + 2, bark = L.birch }) end

  -- a giant leaf (banana / elephant ear / philodendron): blade from the stem point (x,y) along angle ang
  -- (radians, 0 = right, pi/2 = down), len long, wid half width. Pale midrib, slanting veins, the half facing the
  -- upper left lit, ink rim. o.droop bends it down, o.torn splits it (banana), o.stem = {sx, sy} draws a petiole.
  local function bigLeaf(x, y, len, ang, r, seed, wid, o)
    o = o or {}
    r = r or L.leaf
    seed = seed or 1
    wid = wid or math.max(2, floor(len * .28))
    local dx, dy = cos(ang), sin(ang)
    local nx, ny = -dy, dx
    if o.stem then
      local st = line({ { o.stem[1], o.stem[2] }, { x, y } }, 1)
      rimOf(st, r) fill(st, r.shade)
    end
    local lp, rq = {}, {}
    local n = 14
    for i = 0, n do
      local t = i / n
      local w = wid * (sin(pi * math.min(1, t * 1.04)) ^ .65)
      if o.heart and t < .25 then w = math.max(w, wid * .85) end
      local cx_, cy_ = x + dx * len * t, y + dy * len * t + (o.droop or 0) * len * t * t
      lp[#lp + 1] = { cx_ + nx * w, cy_ + ny * w }
      table.insert(rq, 1, { cx_ - nx * w, cy_ - ny * w })
    end
    local pts = {}
    for _, p in ipairs(lp) do pts[#pts + 1] = p end
    for _, p in ipairs(rq) do pts[#pts + 1] = p end
    local m = poly(pts)
    rimOf(m, r)
    local litN = (nx * -.6 + ny * -.8) > 0 and 1 or -1
    m:each(function(xx, yy)
      local rx_, ry_ = xx - x, yy - y
      local along = rx_ * dx + ry_ * dy
      local tt = math.max(0, along / len)
      local cyo = (o.droop or 0) * len * tt * tt
      ry_ = ry_ - cyo
      local across = rx_ * nx + ry_ * ny
      local d = math.abs(across)
      local lit = across * litN > 0
      local h
      if d < .75 then h = r.hi
      else
        h = lit and ((d < wid * .55 and tt < .7) and r.hi or r.base) or ((d > wid * .7) and r.deep or r.shade)
        if floor(along - d * 1.1) % 4 == 0 then h = lit and r.shade or r.deep end
        if o.torn and lit == false and hash(floor(along - d * 1.1) // 4, 0, seed) < .35 and floor(along - d * 1.1) % 4 == 0 then h = r.edge end
        if lit and h == r.hi and hash(xx, yy, seed) < .08 then h = L.shine end
      end
      px(xx, yy, h)
    end)
    return m
  end
  -- heliconia: two paddle leaves and an upright zigzag of red-to-yellow lobster-claw bracts (base at x, yb)
  local function heliconia(x, yb, h, seed)
    seed = seed or 1
    bigLeaf(x - 1, yb - floor(h * .3), floor(h * .75), -pi * .64, L.leaf, seed, nil, { stem = { x, yb } })
    bigLeaf(x + 1, yb - floor(h * .2), floor(h * .62), -pi * .28, L.foliage, seed + 1, nil, { stem = { x, yb } })
    local stalk = rect(x, yb - h, x, yb)
    local n = math.max(3, floor(h / 6))
    local br_ = HP.mask()
    local bl = {}
    for k = 0, n - 1 do
      local y = yb - h + 2 + k * 3
      local s = k % 2 == 0 and -1 or 1
      local bw = 3 - floor(k / n * 1.6)
      bl[#bl + 1] = { y, s, bw }
      for q = 1, bw do br_:set(x + s * q, y) end
      for q = 1, bw - 1 do br_:set(x + s * q, y + 1) end
      br_:set(x + s * bw, y - 1)
    end
    rimOf(union(stalk, br_), L.helic)
    fill(stalk, L.vine.shade)
    for _, b in ipairs(bl) do
      local y, s, bw = b[1], b[2], b[3]
      for q = 1, bw do px(x + s * q, y, q == 1 and L.helic.shade or L.helic.base) end
      for q = 1, bw - 1 do px(x + s * q, y + 1, L.helic.deep) end
      px(x + s * bw, y - 1, L.helic.hi)
    end
    return br_
  end
  -- an orchid spray: an arching stem from (x,y) with n flowers (petals, a pale column, a dark lip)
  local function orchid(x, y, r, n, flip)
    r = r or L.orchid
    n = n or 3
    local s = flip and -1 or 1
    newObj()
    for k = 0, n * 3 do local t = k / (n * 3) px(x + s * k, y - floor(sin(t * pi * .8) * 4 + .5), L.vine.shade) end
    for k = 1, n do
      local t = k * 3 / (n * 3)
      local fx, fy = x + s * k * 3, y - floor(sin(t * pi * .8) * 4 + .5) + 2
      px(fx - 1, fy, r.hi) px(fx + 1, fy, r.base) px(fx, fy - 1, r.hi) px(fx, fy, L.gold.hi) px(fx, fy + 1, r.deep)
      px(fx - 1, fy + 1, r.shade) px(fx + 1, fy - 1, r.base)
    end
  end
  -- a bamboo clump: n culms (nodes every 8 px, lit left), leaf sprays from the upper nodes
  local function bamboo(x, yb, h, n, seed, r)
    r = r or L.bamboo
    seed = seed or 1
    local culms, list = HP.mask(), {}
    local w = h >= 50 and 3 or 2
    for i = 1, n do
      local cx = x + floor((i - (n + 1) / 2) * (w + 2) + (hash(i, seed, 1) - .5) * 3)
      local chh = floor(h * (.7 + .3 * hash(i, seed, 2)))
      local lean = (hash(i, seed, 3) - .5) * .2 + (cx - x) * .015
      list[i] = { cx, chh, lean }
      for y = yb - chh, yb do local xx = floor(cx + (yb - y) * lean + .5) for q = 0, w - 1 do culms:set(xx + q, y) end end
    end
    rimOf(culms, r)
    local leaves = {}
    for i, cl in ipairs(list) do
      local cx, chh, lean = cl[1], cl[2], cl[3]
      local off = floor(hash(i, seed, 4) * 8)
      for y = yb - chh, yb do
        local xx = floor(cx + (yb - y) * lean + .5)
        local nd = (y + off) % 8
        for q = 0, w - 1 do
          local h2 = q == 0 and r.hi or (q == w - 1 and r.shade or r.base)
          if nd == 0 then h2 = q == 0 and r.shade or r.deep elseif nd == 1 and q == 0 then h2 = L.shine end
          px(xx + q, y, h2)
        end
        if nd == 0 and y < yb - chh * .45 then leaves[#leaves + 1] = { xx + (((y + i) // 8) % 2 == 0 and -1 or w), y, ((y + i) // 8) % 2 == 0 and -1 or 1 } end
      end
    end
    newObj()
    for _, lf in ipairs(leaves) do
      local lx, ly, s = lf[1], lf[2], lf[3]
      for q = 0, 5 do
        local yy = ly + floor(q * .45 + .5)
        px(lx + s * q, yy, q == 5 and L.leaf.deep or (q < 2 and L.leaf.hi or L.leaf.base))
        if q > 0 and q < 5 then px(lx + s * q, yy + 1, L.leaf.shade) end
      end
    end
  end
  -- bamboo-culm wall texture over a mask: culms w px wide (vertical, or horizontal poles with horiz=true),
  -- staggered nodes, lit lip on each culm
  local function bambooWall(m, r, w, horiz, seed)
    r = r or L.bamboo
    w = w or 3
    seed = seed or 3
    m:each(function(x, y)
      local a, b = horiz and y or x, horiz and x or y
      local k, idx = a % w, a // w
      local off = floor(hash(idx, 0, seed) * 9)
      local nd = (b + off) % 9
      local h
      if k == 0 then h = r.deep elseif k == 1 then h = r.hi elseif k == w - 1 then h = r.shade else h = r.base end
      if nd == 0 and k ~= 0 then h = r.deep elseif nd == 1 and k == 1 then h = L.shine end
      px(x, y, h)
    end)
  end
  -- wet specular glints on the upper-left part of a mask (stones, slabs, leaves after rain)
  local function shine(m, k, seed)
    local x0, y0, x1, y1 = m:bbox()
    if not x0 then return end
    local w, h = math.max(1, x1 - x0), math.max(1, y1 - y0)
    m:each(function(x, y)
      if (x - x0) / w + (y - y0) / h < .8 and m:has(x - 1, y) and m:has(x, y - 1) and m:has(x + 1, y) and hash(x // 2, y, seed or 5) < (k or .1) then
        px(x, y, L.wet) if m:has(x + 1, y) and hash(x, y, (seed or 5) + 1) < .5 then px(x + 1, y, L.shine) end
      end
    end)
  end
  -- a rain puddle on the ground at (x,y): sky reflection, a dark far lip with a canopy reflection, glints
  local function puddle(x, y, w, seed)
    local m = c:ellipse(x, y, w, math.max(1, floor(w / 4)))
    c:rim(m, L.ground.deep)
    m:each(function(xx, yy)
      local h = yy <= y - 1 and L.foliage2.shade or (yy == y and L.sky[2] or L.sky[4])
      if hash(xx, yy, seed or 8) < .12 then h = L.shine end
      px(xx, yy, h)
    end)
    px(x - floor(w / 2), y, L.wet) px(x - floor(w / 2) + 1, y, L.wet)
    return m
  end

  -- opus3 material helpers ----------------------------------------------------------------
  -- thatch: layered courses 4 px tall, combed strands, each course's lower lip dark with a ragged drip, sunlit ticks
  function F_thatch(m, r, y0, cx)
    m:each(function(x, y)
      local row = (y - y0) // 4
      local ry = (y - y0) % 4
      local drip = hash(x, row, 61) < .35 and 1 or 0
      local h
      if ry == 3 or (ry == 0 and drip == 1 and hash(x, row - 1, 61) < .35) then h = r.deep
      elseif (x + row * 2) % 3 == 0 then h = r.shade
      elseif ry == 0 and hash(x, y, 62) < .4 then h = r.hi
      else h = nil end
      if h then px(x, y, h) end
      if x > (cx or 9999) + 2 and ry == 2 and hash(x, y, 63) < .5 then px(x, y, r.deep) end
    end)
  end
  -- rainforest: palm-leaf thatch. Rows 5 px tall of overlapping fronds: slanted leaflet strands, a lit upper lip,
  -- a dark ragged underside per row, the slope right of cx in shade. On golden (L.roof) thatch some blocks are
  -- fresh green palm (L.roof2) so the roof reads as leaves, not straw.
  function F_palmThatch(m, r, y0, cx, seed)
    seed = seed or 61
    m:each(function(x, y)
      local row = (y - y0) // 5
      local ry = (y - y0) % 5
      local rr = r
      if r == L.roof and hash(x // 6, row, seed + 3) < .14 then rr = L.roof2 end
      local strand = (x + row * 2 + ((x // 2) % 2)) % 3
      local h
      if ry == 4 or (ry == 3 and hash(x, row, seed) < .3) then h = rr.deep
      elseif ry == 0 then h = hash(x, y, seed + 1) < .55 and rr.hi or rr.base
      elseif strand == 0 then h = rr.shade
      elseif ry == 1 and hash(x, y, seed + 2) < .25 then h = rr.hi
      else h = rr.base end
      if x > (cx or 9999) + 2 and (ry == 2 or ry == 3) and hash(x, y, seed + 4) < .45 then h = rr.deep end
      if x > (cx or 9999) + 2 and h == rr.hi then h = rr.base end
      px(x, y, h)
    end)
  end
  -- planks: seams every w px (vertical boards when o.vertical), grain streaks, knots, a lit lip per board
  function F_planks(m, r, w, vertical, seed)
    seed = seed or 5
    m:each(function(x, y)
      local a, b = vertical and x or y, vertical and y or x
      local k = a % w
      local board = a // w
      local h
      if k == 0 then h = r.deep
      elseif k == 1 then h = r.hi
      else
        local g = hash(board * 7 + k, b // 5, seed)
        if g < .16 then h = r.shade elseif g > .96 then h = r.hi end
        if hash(board, b // 9, seed + 1) < .05 and k == w // 2 then h = r.deep end
      end
      if h then px(x, y, h) end
    end)
  end
  -- water: far rows lighter, ripple dashes (hi above, shade below), cream glints, a dark lip under the bank
  function F_water(m, r, o)
    o = o or {}
    local bb = { m:bbox() }
    m:each(function(x, y)
      local ytop = bb[2] or y
      local f = (y - ytop) / math.max(1, (bb[4] or y) - ytop)
      local h = f < .25 and r.hi or (f < .7 and r.base or r.shade)
      if f >= .25 and f < .7 and hash(x // 3, y, 71) < .25 then h = mix(r.hi, r.base, .5) end
      px(x, y, h)
    end)
    local rows = o.step or 3
    m:each(function(x, y)
      if y % rows == 0 then
        local seg = (x + y * 7) // (5 + (y % 4))
        local v = hash(seg, y, 72)
        if v < .28 then px(x, y, r.hi) if m:has(x, y + 1) then px(x, y + 1, r.shade) end
        elseif v > .9 and m:has(x, y + 1) then px(x, y, r.shade) end
      end
      if hash(x, y, 73) < .006 then px(x, y, "#eef6e6") end
      if not m:has(x, y - 1) or not m:has(x, y - 2) then px(x, y, r.deep) end
    end)
  end

  -- forest: log-wall texture. Horizontal round logs `step` px tall (lit top, dark underside, bark flecks,
  -- chinking line), with end-grain stubs sticking out past the corners when o.ends = {x0, x1}.
  local function F_logs(m, r, y0, step, o)
    o = o or {}
    step = step or 4
    m:each(function(x, y)
      local k = (y - y0) % step
      local row = (y - y0) // step
      local h
      if k == 0 then h = r.hi elseif k == step - 1 then h = r.deep elseif k == step - 2 and step > 3 then h = r.shade else h = r.base end
      if k > 0 and k < step - 1 and hash(x // 3, row, 64) < .12 then h = r.shade end
      if k == 1 and hash(x // 2, row, 65) < .15 then h = r.hi end
      px(x, y, h)
    end)
    if o.ends then
      local b = { m:bbox() }
      for yy = y0, (b[4] or y0) - step + 1, step do
        for _, ex in ipairs(o.ends) do
          local e = c:ellipse(ex, yy + step // 2, math.max(1, step // 2), math.max(1, step // 2 - (step > 3 and 0 or 0)))
          c:rim(e, r.edge) fill(e, L.board.base)
          px(ex, yy + step // 2, L.board.shade) px(ex - 1, yy + step // 2 - 1, L.board.hi)
        end
      end
    end
  end
  -- end grain of a sawn log seen face-on: bark ring, pale wood, growth rings, a lit upper-left
  local function logEnd(x, y, rr, bark)
    bark = bark or L.timber
    local m = c:ellipse(x, y, rr, rr)
    c:rim(m, bark.edge)
    fill(m, bark.base)
    local inner = c:ellipse(x, y, math.max(1, rr - 1), math.max(1, rr - 1))
    fill(inner, L.board.base)
    inner:each(function(xx, yy)
      local d = math.sqrt((xx - x) ^ 2 + (yy - y) ^ 2)
      if rr > 3 and floor(d + .5) % 2 == 0 and d > .8 then px(xx, yy, L.board.shade) end
      if (xx - x) + (yy - y) < -rr * .7 then px(xx, yy, L.board.hi) end
    end)
    px(x, y, L.board.deep)
    return m
  end
  -- moss patch spread over a mask (k = coverage 0..1), thicker on upper faces (pixels with nothing above)
  local function moss(m, k, seed)
    m:each(function(x, y)
      local top = not m:has(x, y - 1)
      local v = hash(x // 2, y // 2, seed or 66)
      if v < (top and k * 1.8 or k) then px(x, y, top and L.moss.hi or (hash(x, y, 67) < .5 and L.moss.base or L.moss.shade)) end
    end)
  end

  -- pilot building: gable thatch (or shingle) roof, timber frame with braces, chimney, attic window
  local function building(b)
    local x0, x1, yb, wh, rh, wr = b.x0, b.x1, b.yb, b.wh, b.rh, b.wall
    local top, cx = yb - wh, (x0 + x1) // 2
    local wallM = rect(x0, top, x1, yb)
    local rr = b.roof or L.roof
    local roofM = poly{ { x0 - 3, top + 3 }, { cx, top - rh }, { x1 + 3, top + 3 } }
    roofM:add(rect(x0 - 3, top, x1 + 3, top + 3))
    local gableM = poly{ { x0 + 5, top }, { cx, top - rh + 8 }, { x1 - 5, top } }
    roofM:cut(gableM)
    local chim = b.chimney and rect(x1 - 12, top - rh + 2, x1 - 7, top + 2) or nil
    local sil = union(wallM, roofM, gableM)
    if chim then sil:add(chim) end
    if not b.noShadow then shadow(x0 + 2, x1, yb, 10, 5) end
    rimOf(sil, wr)
    if chim then part(chim, L.stone) courses(chim, top - rh + 2, 4, 6, L.stone) end
    part(wallM, wr)
    part(gableM, wr, { nopop = true })
    part(roofM, rr, { sep = true })
    -- rainforest: every roof is palm-leaf thatch (shingle=true is accepted and also gives palm thatch)
    F_palmThatch(roofM, rr, top - rh, cx)
    -- plaster wall texture: lime wash patches, a lath crack, damp darker base
    wallM:each(function(x, y)
      local v = hash(x, y, 41)
      if y <= top + 3 then return end
      if y >= yb - 3 and hash(x // 2, y, 42) < .4 then px(x, y, wr.shade)
      elseif hash(x // 4, y, 41) < .03 then px(x, y, wr.hi)
      elseif wr == L.plaster and ((x + y) // 2) % 2 == ((x - y) // 2) % 2 and (x + y) % 2 == 0 then px(x, y, wr.shade) end -- woven palm mat
    end)
    line({ { x0 - 2, top + 2 }, { cx, top - rh + 1 } }):each(function(x, y) if roofM:has(x, y) then px(x, y, rr.hi) end end)
    hline(x0 - 3, x1 + 3, top + 3, rr.deep)
    -- ragged leaf edge where the thatch overhangs the gable
    roofM:each(function(x, y)
      if gableM:has(x, y + 1) or gableM:has(x - 1, y) or gableM:has(x + 1, y) then
        px(x, y, rr.deep)
        if gableM:has(x, y + 1) and hash(x, y, 65) < .45 then px(x, y + 1, rr.shade) end
      end
    end)
    -- ragged leaf fringe hanging off the eave
    for x = x0 - 3, x1 + 3 do
      local len = 1 + floor(hash(x, top, 64) * 3)
      for k = 1, len do px(x, top + 3 + k, k == len and rr.edge or (k == 1 and rr.deep or rr.shade)) end
    end
    -- bamboo ridge pole on the apex
    px(cx, top - rh - 1, L.bamboo.hi) px(cx - 1, top - rh, L.bamboo.shade) px(cx + 1, top - rh, L.bamboo.shade)
    vline(cx, top - rh + 10, top - 1, L.bamboo.base)
    if rh >= 18 and not b.noAttic then window(cx - 3, top - rh // 2 + 1, cx + 2, top - rh // 2 + 5, L.timber) end
    if not b.noFrame then
      local beams = union(rect(x0, top, x1, top + 1), rect(x0, yb - 2, x1, yb), rect(x0, top, x0 + 1, yb), rect(x1 - 1, top, x1, yb))
      local mid = top + floor(wh * .45)
      beams:add(rect(x0, mid, x1, mid + 1))
      for x = x0 + 12, x1 - 10, 14 do beams:add(rect(x, top, x + 1, yb)) end
      beams:add(line({ { x0 + 2, mid - 1 }, { x0 + 10, top + 2 } })):add(line({ { x1 - 2, mid - 1 }, { x1 - 10, top + 2 } }))
      -- rainforest: a bamboo frame with node rings
      part(beams, L.bamboo, { nopop = true, noshade = true })
      beams:each(function(x, y) if (x + y) % 7 == 0 then px(x, y, L.bamboo.deep) elseif hash(x // 3, y, 43) < .14 then px(x, y, L.bamboo.shade) end end)
    end
    return top, cx, wallM, roofM
  end

  ---------------------------------------------------------------- BACKGROUND (rainforest: humid golden-green sky, misted sun, canopy ridges)
  c:stripes(0, HZ, L.sky, { 3, 3, 3, 2, 2 })
  -- a hazy golden sun in the humid air, upper left (the light source of every scene)
  if not o.noSun then
    local sx, sy = o.sunX or 92, o.sunY or 52
    fill(c:ellipse(sx, sy, 14, 13), "#e2e6ae") fill(c:ellipse(sx, sy, 11, 10), "#eceab2") fill(c:ellipse(sx, sy, 8, 7), "#f4eebc") fill(c:ellipse(sx, sy, 5, 5), "#faf2c8")
  end
  for _, cl in ipairs(o.clouds or { { 120, 44, 40 }, { 300, 30, 52 }, { 400, 66, 30 }, { 40, 80, 26 } }) do
    local x, y, w = cl[1], cl[2], cl[3]
    -- humid: soft piled banks with a rounded tower, a damp green-grey under-band
    local m = c:rrect(x - w // 4, y - 5, x + w + w // 4, y, 2):add(c:rrect(x + w // 6, y - 10, x + w * 3 // 4, y - 3, 4)):add(c:ellipse(x + w // 2, y - 11, w // 6 + 2, 5))
    fill(m, L.cloud.top)
    m:each(function(xx, yy) if not m:has(xx - 1, yy - 1) and not m:has(xx, yy - 1) then px(xx, yy, "#f6f4dc") end end)
    hline(x - w // 4 + 2, x + w + w // 4 - 2, y, L.cloud.under) hline(x - w // 4 + 6, x + w + w // 4 - 8, y - 1, L.cloud.under)
    m:each(function(xx, yy) if hash(xx // 3, yy, 9) < .08 and yy < y - 1 then px(xx, yy, L.sky[5]) end end)
  end
  local function fFar(x) return HZ - 16 + 6 * sin(x / 37) + 4 * sin(x / 13 + 1) end
  local function fMid(x) return HZ - 6 + 4 * sin(x / 29 + 2) + 3 * sin(x / 11) end
  -- rainforest canopy ridge: rounded crown bumps along a hill line (lit on the upper left), now and then an
  -- emergent palm silhouette poking above. Same signature as the forest spire ridge.
  local function ridge(f, col, colLit, seed, hmin, hmax, skip)
    local x = -6
    while x < W + 6 do
      if skip and skip(x) then x = x + 3 goto continue end
      local hh = hmin + floor(hash(x, 1, seed) * (hmax - hmin))
      local yb = floor(f(x)) + 2
      local rr = math.max(2, floor(hh * .55))
      local cy = yb - hh + rr
      for yy = yb - hh, yb do
        for xx = x - rr, x + rr do
          local ddx, ddy = (xx - x) / (rr + .5), (yy - cy) / (rr + .5)
          if yy >= cy or ddx * ddx + ddy * ddy <= 1 then
            px(xx, yy, (colLit and ddx + ddy < -.55 and yy < yb - 1) and colLit or col)
          end
        end
      end
      if hash(x, 7, seed) < .1 then
        local th = hh + 6
        vline(x, yb - th, yb - hh + 1, col)
        hline(x - 2, x + 2, yb - th, col) px(x - 3, yb - th + 1, col) px(x + 3, yb - th + 1, col) px(x - 4, yb - th + 2, col) px(x + 4, yb - th + 2, col)
        px(x, yb - th - 1, col)
      end
      x = x + rr + 1 + floor(hash(x, 2, seed) * rr)
      ::continue::
    end
  end
  c:terrain(fFar, L.hillFar, HZ)
  ridge(fFar, L.ridgeFar, mix(L.ridgeFar, L.mist, .35), 21, 6, 14)
  for y = HZ - 15, HZ - 9 do for x = 0, W - 1 do if hash(x // 9, y, 23) < .38 then px(x, y, L.mist) end end end
  if o.beforeMid then o.beforeMid() end
  setDepth(1)
  ridge(function(x) return fMid(x) + 1 end, L.ridgeMid, L.hillMidShade, 27, 5, 12)
  for i, tx in ipairs(o.farTrees or { 24, 52, 196, 290, 318, 352, 440 }) do tree(tx, floor(fMid(tx)) + 2, 24, i, true) end
  setDepth(0)
  local midM = c:terrain(fMid, L.hillMid, HZ)
  midM:each(function(x, y) if (x + y * 3) % 23 == 0 then px(x, y, L.hillMidShade) end end)
  -- humid mist lying in the back rows: long soft streaks along the foot of the mid hills
  for y = HZ - 7, HZ - 1 do
    for x = 0, W - 1 do
      local v = hash(x // 14, y, 25)
      if v < .5 - (HZ - y) * .05 then px(x, y, (y % 2 == 0) and L.mist or L.mist2) end
    end
  end

  local groundCol = {}
  local function groundAt(x, y)
    local d = y - HZ + 2
    local base
    local f = (y - HZ - 1) / (H - 1 - HZ)
    if f < 1 / 13 then base = L.groundFar elseif f < 3 / 13 then base = L.ground.hi else base = L.ground.base end
    -- rainforest: wet red-brown leaf litter with low-frequency patches of green understorey, orange fresh-fallen
    -- leaves and dark wet humus, flattened by perspective
    local sy = 2 + d * .1
    local nv = vnoise(x / (sy * 5), y / sy, 5) + (hash(x, y, 6) - .5) * .08
    local nv2 = vnoise(x / (sy * 3), y / (sy * .8), 9) + (hash(x, y, 7) - .5) * .1
    local green = true
    if f < 1 / 13 then base = L.groundFar
    elseif f < 3 / 13 then
      if nv > .62 then base = L.ground.hi green = false else base = nv < .35 and L.mossGround.base or L.mossGround.hi end
    else
      if nv < .28 then base = L.mossGround.shade elseif nv < .52 then base = L.mossGround.base
      elseif nv < .76 then base = (nv2 > .7) and L.ground.hi or L.ground.base green = false
      else base = L.duff green = false end
    end
    local u = (x - VX) / d * 7
    if y < 150 and abs(u - floor(u + .5)) < .03 + .8 / d then return green and L.mossGround.shade or L.ground.shade end
    if hash(x, y, 1) < .02 + y / 9000 then return green and L.mossGround.deep or L.ground.shade end
    if hash(x, y + 1, 1) < .02 + (y + 1) / 9000 then return green and L.mossGround.hi or L.litter.base end
    return base
  end
  -- the ground is painted per pixel by groundAt (so eraseGround matches it exactly, patches included)
  for y = HZ + 1, H - 1 do for x = 0, W - 1 do px(x, y, groundAt(x, y)) end end
  -- rainforest floor: fallen leaves (orange, brown, yellow, green), seedlings and fern tufts (taller nearer),
  -- roots, orange and red fungi, moss, fallen heliconia / orchid petals, tiny puddles, wet-shine pebbles.
  local function fern(x, y, s, r)
    r = r or L.fern
    s = s or 4
    vline(x, y - s, y, r.shade)
    for k = 1, s do
      local yy = y - s + k
      local reach = math.min(k, s - k + 2) // 2 + 1
      for d = 1, reach do px(x - d, yy - (d > 1 and 1 or 0), d == reach and r.base or r.hi) px(x + d, yy - (d > 1 and 1 or 0), d == reach and r.deep or r.shade) end
    end
    px(x, y - s - 1, r.hi)
  end
  local function mushroom(x, y, r, big)
    r = r or L.produce
    if big then
      fill(rect(x - 1, y - 2, x, y), L.awnB.base) px(x - 1, y - 2, L.awnB.hi)
      hline(x - 3, x + 2, y - 3, r.shade) hline(x - 2, x + 1, y - 4, r.base) px(x - 2, y - 4, r.hi) px(x - 1, y - 5, r.base) px(x, y - 5, r.base)
      px(x - 1, y - 4, L.wet) px(x + 1, y - 3, r.base) hline(x - 3, x + 2, y - 2, r.edge)
    else
      px(x, y, L.awnB.shade) px(x, y - 1, r.base) px(x - 1, y - 1, r.hi) px(x + 1, y - 1, r.shade)
    end
  end
  local function groundDetail(x0, x1, y0, y1, seed)
    for i = 1, 760 do
      local x = x0 + floor(hash(i, 1, seed) * (x1 - x0))
      local y = y0 + floor(hash(i, 2, seed) ^ .7 * (y1 - y0))
      local near = (y - HZ) / (H - HZ)
      local kind = hash(i, 3, seed)
      if hash(i, 4, seed) < near * 1.2 then
        if kind < .28 then
          local th = 2 + floor(near * 4 * hash(i, 5, seed))
          if near > .5 and hash(i, 7, seed) < .45 then fern(x, y, th + 1)
          else
            vline(x, y - th, y, L.fern.shade) px(x, y - th, L.fern.hi)
            if near > .45 then -- a seedling with two round leaves
              px(x - 1, y - th, L.fern.hi) px(x - 2, y - th, L.fern.base) px(x + 1, y - th + 1, L.fern.base) px(x + 2, y - th + 1, L.fern.deep)
            end
          end
        elseif kind < .58 then
          local lr = L.litter
          local pick = floor(hash(i, 6, seed) * 6)
          local col = ({ lr.hi, lr.base, lr.shade, L.gold.base, L.leaf.shade, L.ground.deep })[1 + pick]
          local colHi = ({ L.gold.hi, lr.hi, lr.base, L.gold.hi, L.leaf.base, L.ground.shade })[1 + pick]
          local dir = hash(i, 8, seed) < .5 and 1 or -1
          px(x, y, col) px(x + dir, y - 1, colHi)
          if near > .4 then px(x + dir, y, col) px(x + 2 * dir, y - 1, col) px(x + 3 * dir, y - 2, col) px(x + dir, y + 1, L.ground.deep) end
        elseif kind < .63 then
          if near > .35 then local r = L.timber
            px(x - 2, y, r.shade) px(x - 1, y - 1, r.base) px(x, y - 1, r.hi) px(x + 1, y - 1, r.base) px(x + 2, y, r.shade) px(x, y, r.deep)
          end
        elseif kind < .69 then
          if near > .3 then mushroom(x, y, hash(i, 9, seed) < .6 and L.produce or L.apple, near > .6) end
        elseif kind < .77 then
          local mr = L.moss
          px(x, y, mr.base) px(x + 1, y, mr.shade) px(x - 1, y, mr.hi) px(x, y - 1, mr.hi)
          if near > .5 then px(x + 2, y, mr.shade) px(x - 2, y + 1, mr.base) px(x + 1, y + 1, mr.deep) end
        elseif kind < .83 then
          local fr = ({ L.helic, L.orchid, L.petal, L.helic })[1 + floor(hash(i, 10, seed) * 4)]
          px(x, y, fr.base) px(x + 1, y, fr.shade) if near > .45 then px(x, y - 1, fr.hi) px(x - 1, y + 1, fr.deep) end
        elseif kind < .89 then
          if near > .45 then
            hline(x - 2, x + 2, y, L.sky[3]) px(x - 1, y, L.wet) px(x + 1, y, L.shine)
            px(x - 3, y, L.ground.deep) px(x + 3, y, L.ground.deep) hline(x - 2, x + 2, y + 1, L.ground.deep) hline(x - 1, x + 1, y - 1, L.ground.shade)
          end
        else
          px(x, y, L.stone.base) px(x + 1, y, L.stone.shade) px(x, y - 1, L.wet)
          if near > .5 then px(x + 2, y, L.stone.deep) px(x + 1, y - 1, L.stone.hi) px(x - 1, y, L.moss.base) end
        end
      end
    end
  end
  groundDetail(0, W - 1, HZ + 8, H - 1, 401)
  -- rainforest: a misted canopy tree line along the horizon (plane 1, hazed): umbrella crowns and palms, mist
  -- at their feet. Skips the road end; o.noTreeLine turns it off, o.treeLineGap = { x0, x1 } moves the gap (220..260).
  if not o.noTreeLine then
    local g0, g1 = (o.treeLineGap or { 220, 260 })[1], (o.treeLineGap or { 220, 260 })[2]
    setDepth(1)
    -- a continuous canopy wall behind the tree line, so the jungle reads dense
    ridge(function(xx) return HZ + 3 + 2 * sin(xx / 17) end, mix(L.foliage2.shade, L.farTree.base, .4), L.foliage2.base, 41, 9, 17,
      function(xx) return xx > g0 - 2 and xx < g1 + 2 end)
    local x, i = 2, 0
    while x < W - 2 do
      i = i + 1
      if x < g0 or x > g1 then
        local hh = 14 + floor(hash(x, 3, 31) * 18)
        local yb = HZ + 3 + floor(hash(x, 4, 31) * 3)
        local kv = hash(x, 5, 31)
        if kv < .2 then palm(x, yb, hh + 8, 300 + i, { ramp = L.foliage2 })
        else canopy(x, yb, hh, kv < .55 and L.foliage2 or (kv < .8 and L.farTree or L.foliage), 300 + i, { w = floor(hh * .5) + 2, small = true, bark = L.timber }) end
      end
      x = x + 8 + floor(hash(x, 6, 31) * 9)
    end
    for y = HZ + 1, HZ + 6 do
      for xx = 0, W - 1 do
        if (xx < g0 - 4 or xx > g1 + 4) and hash(xx // 11, y, 33) < .5 - (y - HZ) * .07 then px(xx, y, (y % 2 == 0) and L.mist or L.mist2) end
      end
    end
    setDepth(0)
  end
  -- erase an area back to plain ground (keeps the fan lines and litter flecks)
  local function eraseGround(m) m:each(function(x, y) if y > HZ then px(x, y, groundAt(x, y)) end end) end

  local function drawRoad(yTop, yBot)
    local m = poly{ { xl(yTop), yTop }, { xr(yTop), yTop }, { xr(yBot + 2), yBot + 2 }, { xl(yBot + 2), yBot + 2 } }
    m:clip(rect(0, yTop, W - 1, math.min(H - 1, yBot)))
    roadM:add(m)
    local function cell(x, y)
      local d = y - HZ + 6
      local row = floor(math.log(d) / math.log(L.slabRatio))
      local u = (x - VX) / d * L.slabK + (row % 2) * .5
      return row, floor(u)
    end
    m:each(function(x, y)
      local r1, u1 = cell(x, y)
      local r2, u2 = cell(x - 1, y)
      local r3, u3 = cell(x, y - 1)
      local h
      if r1 ~= r3 or u1 ~= u2 then h = L.road.deep
      else
        local v = hash(r1, u1, 21)
        h = v < .18 and L.road.hi or (v > .8 and L.road.shade or L.road.base)
        local r4, u4 = cell(x - 1, y - 1)
        if (r4 ~= r1 or u4 ~= u1) and cell(x - 2, y) == r1 then h = L.road.hi end
      end
      -- rainforest: moss in the seams, rain puddles on a few slabs (sky reflection), wet shine on the lit lips
      if h == L.road.deep then
        if hash(x, y, 24) < .32 then h = L.moss.shade end
      elseif hash(r1, u1, 26) < .3 and hash(x, y, 27) < .12 then h = L.moss.base
      elseif hash(r1, u1, 29) < .09 and cell(x, y - 1) == r1 and cell(x, y - 2) == r1 and hash(x // 2, y, 30) < .8 then
        h = hash(x, y, 31) < .1 and L.wet or L.shine
      elseif h == L.road.hi and hash(x, y, 28) < .3 then h = L.wet
      elseif hash(x, y, 28) < .02 then h = L.wet end
      px(x, y, h)
    end)
    for y = yTop, math.min(H - 1, yBot) do
      px(floor(xl(y)), y, L.road.edge) px(floor(xl(y)) - 1, y, L.ground.deep)
      px(floor(xr(y) + .99), y, L.road.edge) px(floor(xr(y) + .99) + 1, y, L.ground.deep)
    end
    return m
  end
  if not o.noRoad then drawRoad(ROAD_TOP, H - 1) end

  ---------------------------------------------------------------- gate frame (drawn in finish)
  local function gate()
    local G = L.stone
    -- rainforest: canopy drapes over the beam: giant leaves poking down behind, clumped broadleaf crowns, vines
    -- hanging from their undersides, orchid sprays and hanging heliconia bracts (Maplewold had flat maple crowns)
    for _, gl in ipairs({ { 40, 18, 20, pi * .62, L.leaf, 1 }, { 86, 20, 18, pi * .38, L.foliage, 2 }, { 132, 16, 14, pi * .3, L.leaf, 3 },
      { 446, 18, 20, pi * .38, L.leaf, 4 }, { 398, 20, 18, pi * .62, L.foliage2, 5 }, { 352, 16, 13, pi * .7, L.leaf, 6 } }) do
      bigLeaf(gl[1], gl[2], gl[3], gl[4], gl[5], gl[6], nil, { droop = .25 })
    end
    local boughs = { { 56, 18, 36, 12, L.foliage, 91 }, { 112, 14, 24, 8, L.foliage2, 92 }, { 426, 18, 36, 12, L.foliage2, 93 }, { 376, 14, 22, 8, L.foliage, 94 } }
    local drape = HP.mask()
    for _, b in ipairs(boughs) do
      local m = crown(b[1], b[2], b[3], b[4], b[5], b[6])
      drape:add(m)
      local r = b[5]
      m:each(function(x, y)
        if not m:has(x, y + 1) and y > 12 and hash(x, y, b[6]) < .4 then
          local len = 1 + floor(hash(x, 1, b[6]) * 2)
          for k = 1, len do px(x, y + k, k == len and r.edge or r.deep) end -- leaf tips
        elseif (x + y * 2) % 5 == 0 and hash(x, y, b[6] + 1) < .5 then px(x, y, (x - b[1]) < 0 and r.hi or r.shade) end
      end)
    end
    vines(drape, .09, 95, 22)
    -- hanging heliconia (lobster claw) chains and orchid sprays under the drapes
    for _, hc in ipairs({ { 70, 28, 5 }, { 418, 28, 5 }, { 120, 21, 3 } }) do
      local hx, hy, n = hc[1], hc[2], hc[3]
      local hm = HP.mask()
      for k = 0, n - 1 do local s = k % 2 == 0 and -1 or 1 local y = hy + k * 3 hm:set(hx, y) hm:set(hx, y + 1) hm:set(hx + s, y + 1) hm:set(hx + 2 * s, y + 1) hm:set(hx + 2 * s, y) hm:set(hx + s, y + 2) end
      c:rim(hm, L.helic.edge)
      for k = 0, n - 1 do local s = k % 2 == 0 and -1 or 1 local y = hy + k * 3
        px(hx, y, L.vine.shade) px(hx, y + 1, L.vine.deep) px(hx + s, y + 1, L.helic.base) px(hx + 2 * s, y + 1, L.helic.base) px(hx + 2 * s, y, L.helic.hi) px(hx + s, y + 2, L.helic.shade) end
    end
    orchid(36, 26, L.orchid, 3) orchid(444, 26, L.orchid, 3, true) orchid(96, 25, L.petal, 2) orchid(386, 25, L.orchid, 2, true)
    flatCrown = true
    local beam = rect(0, 0, W - 1, 12)
    local postL, postR = rect(0, 0, 15, 222), rect(W - 16, 0, W - 1, 222)
    local plL, plR = rect(0, 218, 18, 228), rect(W - 19, 218, W - 1, 228)
    local brL = poly{ { 16, 13 }, { 34, 13 }, { 16, 31 } }
    local brR = poly{ { W - 17, 13 }, { W - 35, 13 }, { W - 17, 31 } }
    rimOf(union(beam, postL, postR, plL, plR, brL, brR), L.timber)
    part(postL, G) part(postR, G)
    courses(union(postL, postR), 0, 9, 16, G)
    -- rainforest: moss cushions on the stone courses (thicker low down), wet shine on the course lips,
    -- a climbing vine with orchids up the inner face of each post
    union(postL, postR):each(function(x, y)
      local ry = y % 9
      local wet = y / 222
      if ry == 1 and hash(x // 2, y // 9, 97) < .25 + wet * .35 then px(x, y, hash(x, y, 98) < .4 and L.moss.hi or L.moss.base)
      elseif ry == 2 and hash(x // 2, y // 9, 97) < .12 + wet * .3 then px(x, y, L.moss.shade)
      elseif ry <= 2 and hash(x, y, 99) < .07 then px(x, y, L.wet) end
    end)
    for _, pv in ipairs({ { 13, 1 }, { W - 14, -1 } }) do
      newObj()
      for y = 40, 216 do
        local vx = pv[1] + floor(sin(y / 7 + pv[1]) * 1.5 + .5)
        px(vx, y, L.vine.shade)
        if y % 5 == 0 then local s = ((y // 5) % 2 == 0) and -1 or 1 px(vx + s, y, s < 0 and L.vine.hi or L.vine.base) px(vx + s, y + 1, L.vine.base) px(vx + 2 * s, y + 1, L.vine.deep) end
        if y % 37 == 11 then px(vx - 1, y - 1, L.orchid.hi) px(vx, y - 1, L.orchid.base) px(vx, y - 2, L.orchid.hi) px(vx - 1, y, L.orchid.deep) end
      end
    end
    part(plL, G, { sep = true }) part(plR, G, { sep = true }) hline(0, 18, 218, G.hi) hline(W - 19, W - 1, 218, G.hi)
    for x = 0, W - 1 do if (x < 19 or x > W - 20) and hash(x, 219, 96) < .5 then px(x, 219, L.moss.base) end end
    part(brL, L.timber, { nopop = true }) part(brR, L.timber, { nopop = true })
    part(beam, L.timber, { band = 2 })
    flatCrown = false
    beam:each(function(x, y) if y > 1 and y < 11 and hash(x // 7, y, 95) < .12 then px(x, y, L.timber.shade) end end)
    hline(0, W - 1, 1, L.timber.hi)
    for x = 30, W - 30, 60 do fill(rect(x, 4, x + 2, 6), L.timber.deep) px(x, 4, L.timber.hi) end
    local function by(x) local t = (x - VX) / 224 return 15 + 16 * (1 - t * t) end
    for x = 16, W - 17 do px(x, floor(by(x)), L.timber.deep) end
    local cols = { L.awnA, L.awnB, L.accent, L.roof }
    local i = 0
    for x = 20, W - 28, 12 do
      i = i + 1
      local y = floor(by(x + 4))
      local tri = poly{ { x, y }, { x + 8, y }, { x + 4, y + 7 } }
      local r = cols[i % 4 + 1]
      fill(tri, r.base) hline(x, x + 8, y, r.hi)
      tri:each(function(xx, yy) if not tri:has(xx + 1, yy) then px(xx, yy, r.deep) end end)
    end
    for _, lx in ipairs({ 34, W - 35 }) do
      vline(lx, 13, 19, L.timber.edge)
      local cap = rect(lx - 5, 20, lx + 5, 22)
      local body = rect(lx - 4, 23, lx + 4, 33)
      local base = rect(lx - 5, 34, lx + 5, 35)
      rimOf(union(cap, body, base), L.timber)
      part(cap, L.timber, { nopop = true }) part(base, L.timber, { nopop = true })
      fill(body, L.glow.base) vline(lx - 4, 23, 33, L.timber.base) vline(lx + 4, 23, 33, L.timber.base)
      fill(rect(lx - 3, 24, lx - 1, 32), L.glow.hi) vline(lx + 3, 24, 33, L.glow.shade) vline(lx, 23, 33, L.timber.deep)
      for yy = 37, 41 do px(lx, yy, L.glow.shade) end
    end
    -- compass corner: plain ground (the groundAt pattern, no detail), so it blends with the green-and-litter floor
    for y = 230, H - 1 do for x = 380, W - 1 do px(x, y, groundAt(x, y)) end end
  end

  local F = {
    c = c, L = L, HP = HP, W = W, H = H, HZ = HZ, VX = VX, ROAD_TOP = ROAD_TOP, rp = rp,
    px = px, rect = rect, poly = poly, line = line, fill = fill, part = part, hline = hline, vline = vline,
    union = union, rimOf = rimOf, hash = hash, shadow = shadow, shadowM = shadowM, courses = courses, hrows = hrows,
    speckle = speckle, window = window, door = door, crown = crown, maple = maple, tree = tree,
    building = building, roadM = roadM, xl = xl, xr = xr, fFar = fFar, fMid = fMid,
    groundAt = groundAt, eraseGround = eraseGround, drawRoad = drawRoad,
    mix = mix, shift = shift, depth = setDepth, obj = newObj, thatch = F_palmThatch, planks = F_planks, water = F_water,
    groundDetail = groundDetail,
    -- forest additions (kept; conifer / pine / birch now draw rainforest trees)
    conifer = conifer, pine = pine, birch = birch, fern = fern, mushroom = mushroom, logs = F_logs, logEnd = logEnd, moss = moss,
    ridge = ridge,
    -- rainforest additions
    canopy = canopy, palm = palm, treeFern = treeFern, fronds = fronds, bigLeaf = bigLeaf, vine = vine, vines = vines,
    heliconia = heliconia, orchid = orchid, bamboo = bamboo, bambooWall = bambooWall, palmThatch = F_palmThatch,
    shine = shine, puddle = puddle, strawThatch = F_thatch,
  }

  ---------------------------------------------------------------- stop furniture
  -- a small gnome, front 3/4, feet at (x, yb). o.hat / o.coat ramps, o.flip mirrors, o.arm = "up"|"out"|nil
  function F.gnomeSmall(x, yb, g)
    g = g or {}
    local s = g.flip and -1 or 1
    local hat = poly{ { x - 5, yb - 12 }, { x + 5, yb - 12 }, { x + 3 * s, yb - 18 }, { x + 4 * s + s * 3, yb - 21 } }
    local face = rect(x - 3, yb - 12, x + 3, yb - 9)
    local beard = poly{ { x - 4, yb - 10 }, { x + 4, yb - 10 }, { x + 1, yb - 4 }, { x - 1, yb - 4 } }
    local body = c:rrect(x - 5, yb - 9, x + 5, yb - 2, 2)
    local boots = rect(x - 4, yb - 1, x - 1, yb):add(rect(x + 1, yb - 1, x + 4, yb))
    local sil = union(hat, face, beard, body, boots)
    if not g.noShadow then shadowM(c:ellipse(x + 2, yb + 1, 6, 1)) end
    c:rim(sil, L.timber.edge)
    part(boots, L.timber, { nopop = true, noshade = true })
    part(body, g.coat or L.accent, { nopop = true })
    vline(x, yb - 8, yb - 2, (g.coat or L.accent).shade)
    hline(x - 5, x + 5, yb - 3, L.timber.deep) px(x + 2, yb - 3, L.gold.hi)
    part(face, L.skin, { nopop = true, noshade = true })
    part(beard, L.awnB, { nopop = true })
    px(x - 2, yb - 11, L.timber.edge) px(x + 2, yb - 11, L.timber.edge) -- eyes
    px(x, yb - 10, L.skin.shade) px(x + 1, yb - 10, L.skin.deep)         -- nose
    part(hat, g.hat or L.awnA, { nopop = true })
    hline(x - 5, x + 5, yb - 12, (g.hat or L.awnA).deep)
    px(x - 2 * s, yb - 15, (g.hat or L.awnA).hi)
    -- arms
    if g.arm == "up" then fill(rect(x + 6 * s - (s < 0 and 1 or 0), yb - 13, x + 6 * s + (s > 0 and 1 or 0), yb - 7), (g.coat or L.accent).base) px(x + 6 * s, yb - 14, L.skin.base)
    elseif g.arm == "out" then fill(rect(math.min(x + 5 * s, x + 9 * s), yb - 7, math.max(x + 5 * s, x + 9 * s), yb - 6), (g.coat or L.accent).base) px(x + 10 * s, yb - 7, L.skin.base) px(x + 10 * s, yb - 6, L.skin.shade)
    else px(x + 6 * s, yb - 5, L.skin.base) end
    px(x - 6 * s, yb - 5, L.skin.shade)
    return sil
  end

  -- opus3 gnome: 28 px tall, reads at 50%: tall floppy cone hat, eyes, a round lit nose, cream beard, belted coat,
  -- sleeves and hands. g.hat / g.coat ramps, g.flip mirrors, g.arm = "up"|"out"|"hold"|nil (the working arm).
  -- returns sil, handX, handY (the working hand) so a scene can put a tool in it.
  function F.gnome(x, yb, g)
    g = g or {}
    if g.small then return F.gnomeSmall(x, yb, g) end
    local s = g.flip and -1 or 1
    local function P(dx, dy) return { x + dx * s, yb + dy } end
    local hr, cr = g.hat or L.awnA, g.coat or L.accent
    local hat = poly{ P(-6, -15), P(6, -15), P(4, -20), P(5, -24), P(9, -27), P(3, -26), P(-1, -22), P(-4, -18) }
    local face = rect(x - 4, yb - 15, x + 4, yb - 11)
    local beard = poly{ P(-5, -11), P(5, -11), P(4, -7), P(1, -3), P(-1, -3), P(-4, -7) }
    local body = c:rrect(x - 6, yb - 10, x + 6, yb - 2, 3)
    local boots = rect(x - 5, yb - 1, x - 1, yb):add(rect(x + 1, yb - 1, x + 5, yb))
    local back = rect(math.min(x - 7 * s, x - 6 * s), yb - 9, math.max(x - 7 * s, x - 6 * s), yb - 5)
    local backHand = rect(math.min(x - 7 * s, x - 6 * s), yb - 4, math.max(x - 7 * s, x - 6 * s), yb - 3)
    local arm, hx, hy
    local a = g.arm
    if a == "up" then arm = line({ P(6, -8), P(8, -14), P(8, -17) }, 2) hx, hy = x + 8 * s, yb - 19
    elseif a == "out" then arm = line({ P(6, -8), P(10, -8) }, 2) hx, hy = x + 12 * s, yb - 8
    elseif a == "hold" then arm = line({ P(5, -8), P(3, -6) }, 2) hx, hy = x + 2 * s, yb - 5
    else arm = rect(math.min(x + 6 * s, x + 7 * s), yb - 9, math.max(x + 6 * s, x + 7 * s), yb - 5) hx, hy = x + 7 * s, yb - 4 end
    local hand = rect(math.min(hx, hx - s), hy - 1, math.max(hx, hx - s), hy)
    local sil = union(hat, face, beard, body, boots, back, backHand, arm, hand)
    if not g.noShadow then shadowM(c:ellipse(x + 3, yb + 1, 8, 1)) end
    c:rim(sil, L.timber.edge)
    part(boots, L.timber, { nopop = true, noshade = true }) hline(x - 5, x - 2, yb - 1, L.timber.hi) hline(x + 2, x + 4, yb - 1, L.timber.base)
    part(back, cr, { nopop = true, noshade = true }) fill(backHand, L.skin.shade)
    part(body, cr, { nopop = true })
    body:each(function(xx, yy) if (xx - x) * s < -3 and yy < yb - 4 then px(xx, yy, cr.hi) end end)
    hline(x - 6, x + 6, yb - 4, L.timber.deep) px(x + 2 * s, yb - 4, L.gold.hi) px(x + 2 * s, yb - 5, L.gold.base)
    part(arm, cr, { nopop = true, noshade = true })
    fill(hand, L.skin.base) px(hx, hy, L.skin.shade)
    part(face, L.skin, { nopop = true, noshade = true })
    px(x - 3, yb - 12, "#ec8c84") px(x + 3, yb - 12, "#ec8c84") -- cheeks
    part(beard, L.awnB, { nopop = true })
    beard:each(function(xx, yy) if (xx + yy) % 3 == 0 and yy > yb - 10 then px(xx, yy, L.awnB.shade) end end)
    vline(x - 2, yb - 14, yb - 13, L.timber.edge) vline(x + 2, yb - 14, yb - 13, L.timber.edge) -- eyes
    px(x - 2, yb - 14, L.timber.deep) px(x + 2, yb - 14, L.timber.deep)
    fill(rect(x - 1, yb - 12, x + 1, yb - 10), L.skin.base) px(x - 1, yb - 12, L.skin.hi) px(x + 1, yb - 10, L.skin.shade)
    px(x, yb - 10, L.skin.shade) hline(x - 1, x + 1, yb - 9, L.skin.deep) -- nose and its shadow
    part(hat, hr, { nopop = true })
    hat:each(function(xx, yy) if (xx - x) * s < -1 and yy > yb - 22 and (xx - x) * s > -5 then px(xx, yy, hr.hi) end end)
    hline(x - 6, x + 6, yb - 15, hr.deep) hline(x - 5, x + 5, yb - 16, hr.shade)
    if g.hatBand then hline(x - 5, x + 5, yb - 17, g.hatBand) end
    return sil, hx, hy
  end

  -- sky life: little birds (v strokes); w = wing span 1..3
  function F.birds(list)
    for _, b in ipairs(list) do
      local x, y, w = b[1], b[2], b[3] or 2
      local col = b[4] or "#56544e"
      px(x, y, col)
      for k = 1, w do px(x - k, y - (k == w and 1 or 0) - (k > 1 and 1 or 0) + (k == 1 and 0 or 0), col) px(x + k, y - (k > 1 and 1 or 0), col) end
    end
  end
  -- smoke column: puffs rising and drifting, lighter and smaller as they rise
  function F.smoke(x, y, n, drift, big)
    drift = drift or 1
    local cols = { "#b2bca6", "#c6ceb6", "#d8dec6", "#e6ead4" } -- rainforest: humid green-grey smoke
    for i = 0, n - 1 do
      local t = i / math.max(1, n - 1)
      local r = floor((big or 3) + 2 * sin(i * 1.3) * .5 + (1 - t) * 0 + t * 2)
      local cx, cy = x + floor(drift * i * i * .5 + 2 * sin(i * 1.7)), y - i * 5
      local m = c:ellipse(cx, cy, r, math.max(1, r - 1))
      local ci = math.min(4, 1 + floor(t * 3.5))
      fill(m, cols[ci])
      m:each(function(xx, yy) if not m:has(xx + 1, yy + 1) then px(xx, yy, cols[math.max(1, ci - 1)]) end end)
      px(cx - r + 1, cy - 1, cols[math.min(4, ci + 1)])
    end
  end
  -- washing line: rope sagging between (x0,y0) and (x1,y1), items = { {kind, ramp}, ... } spread along it
  function F.washing(x0, y0, x1, y1, items, sag)
    sag = sag or 4
    local function ly(xx) local t = (xx - x0) / (x1 - x0) return floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) + .5) end
    for xx = x0, x1 do px(xx, ly(xx), L.board.deep) end
    local n = #items
    for i, it in ipairs(items) do
      local cx = floor(x0 + (x1 - x0) * (i - .5) / n)
      local yy = ly(cx) + 1
      local k, r = it[1], it[2]
      local m
      if k == "shirt" then m = rect(cx - 4, yy, cx + 4, yy + 2):add(rect(cx - 3, yy, cx + 3, yy + 9))
      elseif k == "sock" then m = rect(cx - 1, yy, cx + 1, yy + 5):add(rect(cx - 1, yy + 5, cx + 3, yy + 7))
      elseif k == "trousers" then m = rect(cx - 3, yy, cx + 3, yy + 3):add(rect(cx - 3, yy, cx - 1, yy + 10)):add(rect(cx + 1, yy, cx + 3, yy + 10))
      elseif k == "hat" then m = poly{ { cx - 4, yy + 7 }, { cx + 4, yy + 7 }, { cx + 1, yy } }
      else m = rect(cx - 6, yy, cx + 6, yy + 11) end
      c:rim(m, r.edge) part(m, r, { nopop = true })
      if k == "sheet" then for q = cx - 4, cx + 4, 3 do vline(q, yy + 2, yy + 10, r.shade) end end
      if k == "sock" then hline(cx - 1, cx + 1, yy + 1, L.awnB.base) end
      px(cx - 2, yy - 1, L.timber.base) px(cx + 2, yy - 1, L.timber.base) -- pegs
    end
  end
  -- a hen: body, tail, comb, beak, legs. r = feather ramp
  function F.hen(x, yb, r, flip)
    local s = flip and -1 or 1
    r = r or L.awnB
    local body = c:ellipse(x, yb - 4, 4, 3):add(poly{ { x - 3 * s, yb - 5 }, { x - 6 * s, yb - 9 }, { x - 5 * s, yb - 4 } })
    local head = c:ellipse(x + 3 * s, yb - 8, 2, 2)
    local m = union(body, head)
    c:rim(m, L.timber.edge) part(m, r, { nopop = true })
    px(x + 3 * s, yb - 11, L.apple.base) px(x + 2 * s, yb - 11, L.apple.base) px(x + 4 * s, yb - 10, L.apple.shade)
    px(x + 6 * s, yb - 8, L.gold.base) px(x + 4 * s, yb - 9, L.timber.edge)
    px(x - 1, yb - 4, r.shade) px(x, yb - 3, r.shade) px(x + 1, yb - 4, r.shade)
    px(x - 1, yb, L.gold.shade) px(x + 1, yb, L.gold.shade)
    return m
  end
  -- explicit rim light on a mask's upper-left lip (for objects that sit on others)
  function F.rimLight(m, k)
    m:each(function(x, y) if not m:has(x - 1, y) or not m:has(x, y - 1) then local v = c:get(x, y) if v then rawput(c, x, y, mix(v, "#f6eeb6", k or .4)) end end end)
  end

  -- hand-placed pixel sprite: rows of chars, map char -> hex; rimmed with ink-brown (o.rim=false to skip)
  function F.sprite(rows, x0, y0, map, o)
    o = o or {}
    local m = HP.mask()
    for j, row in ipairs(rows) do for i = 1, #row do local ch = row:sub(i, i) if map[ch] then m:set(x0 + i - 1, y0 + j - 1) end end end
    if o.rim ~= false then c:rim(m, o.rimCol or L.timber.edge) else newObj() end
    for j, row in ipairs(rows) do for i = 1, #row do local ch = row:sub(i, i) if map[ch] then px(x0 + i - 1, y0 + j - 1, map[ch]) end end end
    return m
  end

  function F.sack(x, yb, r, w)
    w = w or 6
    r = r or L.awnB
    local m = c:rrect(x - w, yb - w - 3, x + w, yb, 3):add(rect(x - 2, yb - w - 5, x + 2, yb - w - 3))
    c:rim(m, r.edge) part(m, r)
    hline(x - 2, x + 2, yb - w - 3, L.timber.base)
    px(x + w - 2, yb - 3, r.deep) px(x - w + 2, yb - w, r.hi)
    return m
  end
  function F.crate(x0, yb, w, h, fillR)
    local m = rect(x0, yb - h, x0 + w, yb)
    rimOf(m, L.timber) part(m, L.board)
    c:edgeIn(m, L.board.deep)
    line({ { x0 + 1, yb - 1 }, { x0 + w - 1, yb - h + 1 } }):each(function(x, y) px(x, y, L.board.shade) end)
    if fillR then
      for k = 0, w - 2, 3 do
        local fx = x0 + 1 + k
        local fy = yb - h - 1 - (k // 3) % 2
        fill(rect(fx, fy, fx + 2, yb - h), fillR.base) px(fx, fy, fillR.hi) px(fx + 2, yb - h, fillR.deep)
      end
    end
    return m
  end
  function F.barrel(x, yb, r, hgt)
    hgt = hgt or 10
    local m = c:rrect(x - 5, yb - hgt, x + 5, yb, 3)
    rimOf(m, L.timber) part(m, r or L.timber)
    hline(x - 5, x + 5, yb - hgt + 2, L.iron.shade) hline(x - 5, x + 5, yb - 2, L.iron.shade)
    vline(x - 2, yb - hgt + 3, yb - 3, (r or L.timber).hi)
    return m
  end
  function F.rock(x, yb, w, h, r)
    r = r or L.stone
    local m = poly{ { x - w, yb }, { x - w + 2, yb - h + 2 }, { x - w // 3, yb - h }, { x + w // 2, yb - h + 1 }, { x + w, yb - 2 }, { x + w, yb } }
    c:rim(m, r.edge) part(m, r)
    return m
  end
  function F.bush(x, yb, w, h, r, seed)
    local m = crown(x, yb - h // 2, w, h // 2 + 1, r or L.leaf, seed or 7)
    return m
  end
  function F.fence(x0, x1, yb, step)
    step = step or 8
    local m = HP.mask()
    for x = x0, x1, step do m:add(rect(x, yb - 9, x + 1, yb)) end
    m:add(rect(x0, yb - 7, x1 + 1, yb - 6)):add(rect(x0, yb - 3, x1 + 1, yb - 2))
    rimOf(m, L.bamboo) part(m, L.bamboo, { nopop = true, noshade = true }) -- rainforest: bamboo fence
    for x = x0, x1, step do px(x, yb - 9, L.bamboo.hi) px(x, yb - 4, L.bamboo.deep) end
    hline(x0, x1 + 1, yb - 7, L.bamboo.hi)
    return m
  end
  -- a fence that recedes along a ground line (x0,y0) -> (x1,y1), post height scales with depth
  function F.fenceP(x0, y0, x1, y1, n)
    local m, tops = HP.mask(), {}
    for i = 0, n do
      local t = i / n
      local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)
      local h = floor(4 + (y - HZ) * .09)
      m:add(rect(x, y - h, x + 1, y))
      tops[#tops + 1] = { x, y - h }
    end
    for i = 1, #tops - 1 do
      local a, b = tops[i], tops[i + 1]
      m:add(line({ { a[1], a[2] + 1 }, { b[1], b[2] + 1 } })):add(line({ { a[1], a[2] + 3 + (a[2] - HZ) // 25 }, { b[1], b[2] + 3 + (b[2] - HZ) // 25 } }))
    end
    rimOf(m, L.bamboo) part(m, L.bamboo, { nopop = true, noshade = true })
    return m
  end
  function F.sign(x, yTop, w, h, r)
    local post = rect(x, yTop + h, x + 1, yTop + h + 12)
    local board = rect(x - w // 2, yTop, x + w // 2, yTop + h)
    rimOf(union(post, board), L.timber)
    part(post, L.timber, { nopop = true }) part(board, r or L.board, { sep = true })
    hline(x - w // 2 + 2, x + w // 2 - 2, yTop + h // 2, (r or L.board).deep)
  end

  function F.finish()
    if o.beforeGate then o.beforeGate() end
    -- opus3 post: atmospheric depth then rim light, before the gate frame goes on top
    local hazeK = { [1] = .30, [2] = .13 }
    for i, d in pairs(DEP) do
      local k = hazeK[d]
      if k then local x, y = i % W, i // W local v = c:get(x, y) if v then rawput(c, x, y, mix(v, HAZE, k)) end end
    end
    local function same(i, j) return OID[j] == OID[i] and DEP[j] == 3 end
    local lit = {}
    for i, d in pairs(DEP) do
      if d == 3 and not RIMF[i] then
        local x, y = i % W, i // W
        local function edgeTo(j, j2) return (not same(i, j)) or RIMF[j] end
        local L1 = x > 0 and (i - 1) or i
        local U1 = y > 0 and (i - W) or i
        local hit = false
        if edgeTo(L1) and x < W - 1 and same(i, i + 1) and not RIMF[i + 1] then hit = true end
        if edgeTo(U1) and y < H - 1 and same(i, i + W) and not RIMF[i + W] then hit = true end
        if hit then lit[#lit + 1] = i end
      end
    end
    for _, i in ipairs(lit) do
      local x, y = i % W, i // W local v = c:get(x, y)
      if v then local _, _, l = toHsl(v) if l < .86 then rawput(c, x, y, mix(v, "#f6eeb6", .32)) end end
    end
    -- rainforest: golden light shafts slanting down from the upper left through the humid air (hard pixels:
    -- each shaft pixel is one opaque mix, a checker dither on the shaft edges). o.noShafts, o.shafts = {{u, width}, ...}
    if not o.noShafts then
      local shafts = o.shafts or { { 30, 16 }, { 118, 9 }, { 292, 20 }, { 396, 11 } }
      for y = 14, 214 do
        local fade = .3 * math.min(1, (y - 14) / 40) * (1 - y / 215)
        for x = 0, W - 1 do
          local u = x - y * .62
          for _, sh in ipairs(shafts) do
            local d, hw = abs(u - sh[1]), sh[2] / 2
            local k = 0
            if d < hw then k = fade elseif d < hw + 3 and (x + y) % 2 == 0 then k = fade * .5 end
            if k > .012 then local v = c:get(x, y) if v then rawput(c, x, y, mix(v, L.shaft, k)) end break end
          end
        end
      end
    end
    setDepth(4)
    gate()
    c:finish{ outline = false }
    local rep = HP.assertClean(c)
    local base = o.out .. o.name
    c:save{ aseprite = base .. ".aseprite", png = base .. ".png", scale = 1 }
    print("saved " .. base .. " distinct=" .. tostring(rep.distinct))
  end

  return F
end

return M
