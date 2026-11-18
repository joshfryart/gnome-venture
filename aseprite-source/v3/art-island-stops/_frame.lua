-- _frame.lua : ISLAND gate-view frame for the stop-type looks, palette "island_palm".
-- A copy of art-forest-stops/_frame.lua (itself a copy of the Maplewold opus3 frame) with the same API and
-- composition compass (horizon y=112, slab road, gate, bunting, lanterns, compass corner, depth planes, rim light),
-- re-skinned for a volcanic / coral island: hot clear blue sky with big white cumulus and a bright sun upper left,
-- a deep-blue sea on the horizon with a far volcano, a reef surf line and a turquoise lagoon (instead of the
-- treeline), low palm motu (islets), coral-sand ground (shells, coral bits, black lava pebbles, beach grass,
-- fallen hibiscus / plumeria), coral-stone slabs with sand in the seams, palm fronds and flowers on the gate.
-- F.tree now draws coconut palms / banana / plumeria; F.maple, F.crown, F.bush stay broadleaf clumps.
-- New helpers: F.palm, F.banana, F.plumeria, F.hibiscus, F.flower, F.frond, F.shell, F.coral, F.lavaRock,
-- F.bamboo, F.net, F.coconut, F.crab, F.parrot, F.outrigger. Forest helpers (conifer, pine, birch, fern, mushroom,
-- logs, logEnd, moss, ridge) are kept for compatibility, re-coloured (conifer = casuarina / ironwood).
--   local F = dofile(DIR .. "_frame.lua").build{ name = "mill", out = DIR [, roadTop = 124] [, noRoad = true] }
--   ... draw back -> front on F.c ...
--   F.finish()
local M = {}

function M.build(o)
  local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
  local floor, sin, cos, abs = math.floor, math.sin, math.cos, math.abs

  local function rp(s) -- "hi base shade deep edge"
    local t = {} for h in s:gmatch("#%x+") do t[#t + 1] = h end
    return { hi = t[1], base = t[2], shade = t[3], deep = t[4], edge = t[5] or t[4] }
  end
  -- island_palm: same keys as Maplewold so type scripts keep working; the MEANING of a few keys shifts:
  -- roof = dried palm thatch (gold), roof2 = sun-faded rust tin / painted shingle, plaster = coral-lime whitewash,
  -- wall2 = sea-turquoise paint, timber = silver-brown driftwood, board = bamboo / fresh pale cane,
  -- stone = coral stone (cream), foliage = coconut-frond green, foliage2 = deep jungle teal-green, leaf = banana green.
  local L = {
    sky = { "#4f9ed8", "#66b0e0", "#80c2e6", "#9ed4ea", "#bce2ea" },
    cloud = { top = "#f6f6ee", mid = "#e4ecee", under = "#bed4e4", deep = "#a6c2dc" },
    hillFar = "#88a6c4", hillMid = "#6ea888", hillMidShade = "#5a9478",
    ridgeFar = "#7896b4", ridgeMid = "#4e8c6c", mist = "#d6eef0", mist2 = "#e6f4ee",
    farTree = rp("#a6d4b0 #78b496 #5a967e #44786c #305a56"),
    ground = rp("#fcecd2 #f2d8b4 #dcba92 #b8936e #7c5e4a"), groundFar = "#f2e2c6",
    road = rp("#f8eedc #e4d4be #c8b49c #a08c7a #6c5c52"), slabRatio = 1.06, slabK = 15,
    stone = rp("#f6ead6 #dccab0 #b8a48c #8c7a6a #5c4c46"),
    plaster = rp("#fcf4e2 #ecdec4 #cfbb9e #a08c78 #665648"),
    wall2 = rp("#a8e6dc #66c6c0 #46a0a6 #32787e #224e58"),
    timber = rp("#cab69c #a28a6a #7c664e #58483a #362c26"),
    roof = rp("#eecc80 #cc9e50 #a07636 #74522c #48341f"),
    roof2 = rp("#f2a676 #d8744e #ac543c #7c3a30 #4a2424"),
    awnA = rp("#ff9a82 #ec5a48 #c23c3e #8c2a38 #541a28"),
    awnB = rp("#fbf6e8 #ece2cc #cabea6 #9c9282 #625a52"),
    accent = rp("#94e8d8 #3ebeb2 #2a968e #1e706e #144a4e"),
    foliage = rp("#c8e474 #86c24a #4e9c3e #2e7238 #1a4a2e"),
    foliage2 = rp("#96d690 #4cb06e #2c8c5c #1c6648 #123e34"),
    leaf = rp("#daf088 #a4d256 #6caa40 #46823a #2a562e"),
    water = rp("#ccf6ee #72dcd4 #34b6be #22869e #1a5a78"),
    glow = rp("#fff6c0 #ffd870 #f6aa42 #d27a30 #8a4a24"),
    soil = rp("#b47c5c #8c5642 #6a3e34 #4c2c2a #2e1a1c"),
    board = rp("#f4e0a0 #dcc070 #b4984c #86723c #56482c"),
    produce = rp("#ffb04a #f07c22 #c85a1e #943e1c #5e2618"),
    lav = rp("#e0c4f0 #b48ade #8862bc #604490 #3c2a60"),
    iron = rp("#b4bcc0 #808a90 #5e666e #424a54 #282e38"),
    skin = rp("#ffe0bd #f0b98d #c98462 #7a4036 #4a2620"),
    apple = rp("#ff8a6c #e23c3a #b02436 #741c30 #4a1222"),
    petal = rp("#fdd8de #f69cb0 #da6a8a #a6486c #6c2c4a"),
    gold = rp("#f8e48a #e6c052 #bc943a #88682c #584022"),
    -- forest keys kept (re-coloured) so copied scripts still run
    moss = rp("#c4e4a0 #8cc678 #5ea062 #3e7852 #26503c"),
    birch = rp("#eee8de #d2c8ba #a89e92 #7a706a #4c4644"),
    birchLeaf = rp("#bee48c #88c45e #5a9c48 #3e763c #26522e"),
    redbark = rp("#d8bc94 #ac8e6a #84684a #5c4838 #3a2c24"),
    needle = rp("#ecca8c #c89e5e #9c7644 #705234 #483424"),
    fern = rp("#bae67c #7ec652 #4e9e42 #347838 #20502c"),
    mossGround = rp("#cce092 #a2c870 #7aa656 #568044 #365630"), duff = "#e2c29e",
    shadow = "#cba892", shadowRoad = "#bca898",
    -- island-only ramps
    sea = rp("#5cb6dc #2e8cc4 #2068a6 #1a4c86 #12345e"),
    lagoon = rp("#b8f2e6 #6edcd0 #3cc0c4 #2a9cb4 #1e7494"),
    surf = "#eef8f2",
    lava = rp("#86828c #5e5a66 #44404c #302c38 #1e1a24"),
    coral = rp("#ffc6b4 #fa8e7e #da6660 #aa4a52 #702e3e"),
    hibiscus = rp("#ffbe82 #ff8648 #e85a34 #ae3a2c #6c2222"),
    palmTrunk = rp("#dcc49c #b49672 #8c7052 #64503e #3e3028"),
    coconut = rp("#caa266 #94703e #6c4e2e #4a3420 #2e2016"),
    rope = rp("#f4e4ba #dcc290 #b49a6a #86724e #564834"),
    shell = rp("#fff2e6 #f8dac8 #e2b2a4 #b6867c #7c5852"),
    pinkwash = rp("#fde6e0 #f6cac4 #dca6a4 #a87478 #6e4a52"), -- pastel coral-pink limewash (hero walls)
    seagrass = rp("#b4e0a0 #7cc488 #4e9e74 #367a62 #22544a"),
  }
  L.bamboo = L.board
  L.driftwood = L.timber
  L.thatch = L.roof

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
  local HAZE = "#d4ecee" -- island: bright salt-air aqua haze

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
  local F_thatch, F_planks, F_water
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
  -- forest: a tiered conifer (spruce / fir). h = full height from the ground (yb) to the spire tip.
  -- Tiers overlap downward; each tier is lit from the upper left, the tier above casts a deep line on the one
  -- below. o.far (hazed ramp, no detail), o.w (half width of the lowest tier), o.slim, o.bark (trunk ramp).
  -- Returns the crown mask.
  local function conifer(x, yb, h, r, seed, o)
    o = o or {}
    r = r or L.foliage2
    local far = o.far
    local trunkH = math.max(2, floor(h * .13))
    local top, cb = yb - h, yb - trunkH
    local ch = cb - top
    local maxW = o.w or math.max(3, floor(h * (o.slim and .24 or .32)))
    local n = math.max(2, math.min(8, floor(h / 7)))
    local tiers = {}
    for i = 1, n do
      local yb_i = floor(top + ch * i / n + .5)
      local ty = (i == 1) and top or floor(top + ch * (i - 1) / n - ch / n * .95)
      local w = maxW * (.32 + .68 * i / n) * (.9 + .2 * hash(i, seed, 81))
      local j1, j2 = floor(hash(i, seed, 82) * 2), floor(hash(i, seed, 83) * 2)
      local p = poly{ { x, ty }, { x + w, yb_i + 1 }, { x + w * .55, yb_i - 1 - j1 }, { x + w * .2, yb_i },
        { x - w * .25, yb_i - 1 - j2 }, { x - w * .6, yb_i }, { x - w, yb_i + 1 } }
      tiers[i] = { m = p, ty = ty, yb = yb_i, w = w }
    end
    local m = HP.mask()
    for i = 1, n do m:add(tiers[i].m) end
    local tw = h >= 30 and 1 or 0
    local trunk = rect(x - tw, cb - 3, x + (h >= 18 and 1 or 0), yb)
    local bark = far and r or (o.bark or L.timber)
    rimOf(union(m, trunk), far and r or r)
    if not far then c:rim(trunk, bark.edge, trunk:grow(1)) end
    part(trunk, bark, { nopop = true })
    if not far and h >= 30 then vline(x - tw, cb - 2, yb - 1, bark.hi) end
    local own = {}
    for i = n, 1, -1 do tiers[i].m:each(function(xx, yy) own[yy * W + xx] = i end) end
    local glint = r.glint or shift(r.hi, .3, 1.05)
    m:each(function(xx, yy)
      local i = own[yy * W + xx]
      local t = tiers[i]
      local f = (yy - t.ty) / math.max(1, t.yb - t.ty)
      local wy = math.max(1, t.w * f)
      local u = (xx - x) / wy
      local lit = -u * .85 + (.35 - f) * .9 - (i / n) * .25 + (hash(xx // 2, yy, seed) - .5) * (far and .3 or .7)
      local hcol
      if far then hcol = lit > .35 and r.hi or (lit > -.45 and r.base or r.shade)
      else
        if lit > 1.0 then hcol = glint elseif lit > .4 then hcol = r.hi elseif lit > -.2 then hcol = r.base
        elseif lit > -.8 then hcol = r.shade else hcol = r.deep end
        local up = own[(yy - 1) * W + xx]
        if up and up < i then hcol = r.deep
        elseif own[(yy - 2) * W + xx] and own[(yy - 2) * W + xx] < i and lit < .5 then hcol = r.shade end
      end
      px(xx, yy, hcol)
    end)
    if not far and h >= 22 then -- drooping needle tips under each tier's lit side
      for i = 1, n do local t = tiers[i]
        for k = 1, floor(t.w * 1.6) do
          local xx = floor(x - t.w + hash(k, i, seed + 7) * t.w * 2)
          if m:has(xx, t.yb - 1) and not m:has(xx, t.yb + 1) and hash(xx, i, seed) < .5 then px(xx, t.yb, xx < x and r.shade or r.deep) end
        end
      end
    end
    return m
  end
  -- a red-bark (Scots) pine: tall bare orange trunk, a couple of branch stubs, a flat clumped crown up top
  local function pine(x, yb, h, r, seed)
    r = r or L.foliage
    local cy = yb - h * .82
    local trunk = poly{ { x - 2, yb }, { x + 2, yb }, { x + 1, cy }, { x - 1, cy } }
    local br = line({ { x, floor(cy + h * .12) }, { x + floor(h * .2), floor(cy + h * .02) } }, 1)
      :add(line({ { x, floor(cy + h * .2) }, { x - floor(h * .18), floor(cy + h * .08) } }, 1))
    rimOf(union(trunk, br), L.redbark)
    part(trunk, L.redbark, { nopop = true })
    trunk:each(function(xx, yy) if xx < x then px(xx, yy, L.redbark.hi) end if hash(xx, yy // 3, seed) < .2 then px(xx, yy, L.redbark.shade) end end)
    br:each(function(xx, yy) px(xx, yy, L.redbark.shade) end)
    local m = crown(x + 2, floor(cy), floor(h * .3), floor(h * .13) + 2, r, seed)
    crown(x - floor(h * .16), floor(cy + h * .09), floor(h * .15) + 2, floor(h * .07) + 2, r, seed + 1)
    crown(x + floor(h * .2), floor(cy + h * .03), floor(h * .13) + 2, floor(h * .06) + 2, r, seed + 2)
    return m
  end
  -- a birch: white trunk with dark lenticel dashes, a light yellow-green clumped crown
  local function birch(x, yb, h, seed)
    local top = yb - h
    local trunk = poly{ { x - 1, yb }, { x + 2, yb }, { x + 1, top + h * .25 }, { x, top + h * .25 } }
    rimOf(trunk, L.birch)
    part(trunk, L.birch, { nopop = true, noshade = true })
    trunk:each(function(xx, yy)
      if xx > x then px(xx, yy, L.birch.shade) end
      if hash(yy // 2, 0, seed) < .28 and hash(xx, yy, seed) < .7 then px(xx, yy, L.birch.edge) end
    end)
    local m = crown(x + 1, floor(top + h * .3), floor(h * .2) + 2, floor(h * .28), L.birchLeaf, seed)
    crown(x - floor(h * .1), floor(top + h * .5), floor(h * .13) + 2, floor(h * .13) + 2, L.birchLeaf, seed + 3)
    return m
  end
  -- island: one palm frond from (x0, y0): direction ang (radians, 0 = right, -pi/2 = up), length len, droop
  -- (fraction of len the tip falls). Returns a table of { x, y, tone } (tone = ramp key) in draw order, plus the mask.
  -- Leaflets hang off both sides of the rachis; the upper side is lit, the lower side shaded, tips darkest.
  local function frondPix(x0, y0, ang, len, droop, seed, o)
    o = o or {}
    local out, m = {}, HP.mask()
    local n = math.max(4, floor(len * 1.25))
    local dx, dy = cos(ang), sin(ang)
    local litDir = (-dx * .7 - dy * .5) -- fronds pointing left / up face the light
    local function add(xx, yy, tone) xx, yy = floor(xx + .5), floor(yy + .5) out[#out + 1] = { xx, yy, tone } m:set(xx, yy) end
    local tones = { "deep", "shade", "base", "hi", "glint" }
    local function tone(i) i = i + (litDir > .35 and 1 or (litDir < -.35 and -1 or 0)) return tones[math.max(1, math.min(o.far and 4 or 5, i))] end
    for k = 0, n do
      local t = k / n
      local sx = x0 + dx * len * t
      local sy = y0 + dy * len * t + droop * len * t * t
      local tx, ty = dx * len, dy * len + 2 * droop * len * t
      local tl = math.sqrt(tx * tx + ty * ty) tx, ty = tx / tl, ty / tl
      local nx, ny = -ty, tx
      if ny < 0 or (ny == 0 and nx < 0) then nx, ny = -nx, -ny end -- normal pointing down
      local env = math.sin(math.pi * math.min(1, t * 1.08)) ^ .55
      local ll = len * (o.wide or .34) * env * (.75 + .5 * hash(k, 1, seed))
      if t > .1 and not o.bare and k % 2 == 0 then
        -- lower leaflets
        local ax, ay = nx * .55 + tx * .45, ny * .55 + .7 + ty * .45
        local al = math.sqrt(ax * ax + ay * ay) ax, ay = ax / al, ay / al
        for j = 1, floor(ll + .5) do
          local u = j / math.max(1, ll)
          local st = (k % 2 == 0 and u > .3) and -1 or 0 -- alternate leaflets darker: reads as a comb of leaflets
          add(sx + ax * j, sy + ay * j, tone((u > .75 and 1 or (u > .35 and 2 or 3)) + st))
        end
        -- upper leaflets (shorter, drooping over the rachis)
        local bx, by = -nx * .55 + tx * .6, -ny * .55 + .35 + ty * .6
        local bl = math.sqrt(bx * bx + by * by) bx, by = bx / bl, by / bl
        for j = 1, floor(ll * .75 + .5) do
          local u = j / math.max(1, ll * .7)
          local st = (k % 2 == 1 and u > .4) and -1 or 0
          add(sx + bx * j, sy + by * j, tone((u > .8 and 2 or (u > .3 and 4 or 3)) + st))
        end
      end
      add(sx, sy, tone(o.bare and 3 or 4))
    end
    return out, m
  end
  local function paintPix(list, r)
    local glint = r.glint or shift(r.hi, .3, 1.05)
    for _, p in ipairs(list) do px(p[1], p[2], p[3] == "glint" and glint or r[p[3]]) end
  end
  -- F.frond: one frond on its own (gate drapes, roof ridges, a frond lying on the ground). Rimmed with r.edge.
  local function frond(x0, y0, ang, len, droop, r, seed, o)
    r = r or L.foliage
    local list, m = frondPix(x0, y0, ang, len, droop, seed or 1, o)
    if not (o and o.noRim) then c:rim(m, r.edge) end
    paintPix(list, r)
    return m
  end
  -- coconut palm: a curved ringed trunk (bends toward o.lean, default from seed), a crown of 7-9 drooping fronds,
  -- a cluster of coconuts, sometimes one dead brown frond hanging. o.far = hazed, simple. Returns crown mask, topX, topY.
  local function palm(x, yb, h, r, seed, o)
    o = o or {}
    r = r or L.foliage
    local far = o.far
    local lean = o.lean or (((seed % 2 == 0) and 1 or -1) * h * (.16 + .16 * hash(seed, 1, 87)))
    local tx, ty = x + lean, yb - h * .86
    local cx1, cy1 = x - lean * .1, yb - h * .45
    local half0 = math.max(1, math.min(2.6, h / 22))
    local trunk, cxAt = HP.mask(), {}
    local steps = floor(h * 3)
    for k = 0, steps do
      local t = k / steps
      local bx = (1 - t) ^ 2 * x + 2 * (1 - t) * t * cx1 + t * t * tx
      local by = (1 - t) ^ 2 * yb + 2 * (1 - t) * t * cy1 + t * t * ty
      local hw = half0 * (1 - .4 * t) + (t < .04 and .8 or 0)
      local yy = floor(by + .5)
      cxAt[yy] = bx
      for xx = floor(bx - hw + .5), floor(bx + hw + .5) do trunk:set(xx, yy) end
    end
    local bark = far and r or (o.bark or L.palmTrunk)
    local list, crownM = {}, HP.mask()
    local nf = o.fronds or (far and 6 or 8)
    local angs = { -2.75, -2.35, -1.95, -1.25, -.8, -.38, 2.95, .2, -1.6 }
    local order = { 4, 3, 9, 2, 5, 1, 6, 7, 8 }
    local flen = h * (o.frondLen or .5)
    for oi = 1, #order do
      local i = order[oi]
      if i <= nf or (i == 9 and nf >= 9) then
        local a = angs[i] + (hash(i, seed, 88) - .5) * .25
        local up = -math.sin(a)
        local len = flen * (.8 + .3 * hash(i, seed, 89)) * (up > .8 and .7 or 1)
        local droop = (.35 + .5 * hash(i, seed, 90)) * (up > .8 and .3 or 1) + (math.abs(math.cos(a)) > .9 and .25 or 0)
        local fl, fm = frondPix(tx, ty, a, len, droop, seed * 13 + i, { far = far })
        for _, p in ipairs(fl) do list[#list + 1] = p end
        crownM:add(fm)
      end
    end
    local dead = (not far) and (o.dead or (o.dead == nil and hash(seed, 2, 87) < .45))
    local deadL, deadM
    if dead then
      local a = lean > 0 and 1.9 or 1.25
      deadL, deadM = frondPix(tx, ty + 1, a, flen * .55, .1, seed + 5, { wide = .2 })
    end
    local all = union(trunk, crownM)
    if deadM then all:add(deadM) end
    rimOf(all, far and r or bark)
    c:rim(crownM, r.edge)
    -- trunk: lit left side, shaded right, growth rings every 3 rows
    trunk:each(function(xx, yy)
      local bx = cxAt[yy] or x
      local d = xx - bx
      local hcol
      if far then hcol = d < 0 and r.base or r.shade
      else
        hcol = d < -half0 * .4 and bark.hi or (d > half0 * .45 and bark.shade or bark.base)
        local ring = (yy + seed) % 3 == 0
        if ring then hcol = d < -half0 * .4 and bark.base or bark.deep end
        if not trunk:has(xx + 1, yy) and not ring then hcol = bark.deep end
      end
      px(xx, yy, hcol)
    end)
    if deadL then paintPix(deadL, L.needle) end
    if far then
      for _, p in ipairs(list) do px(p[1], p[2], (p[3] == "glint" or p[3] == "hi") and r.hi or (p[3] == "deep" and r.shade or r.base)) end
    else
      paintPix(list, r)
      if o.nuts ~= false and h >= 22 then
        local nr = h >= 44 and 2 or 1
        for k, d in ipairs({ { -2, 2 }, { 1, 3 }, { -1, 5 }, { 3, 1 } }) do
          if k <= 2 + floor(hash(seed, 3, 87) * 3) then
            local nm = c:ellipse(floor(tx + d[1] * nr / 1.5), floor(ty + d[2] * nr / 1.5), nr, nr)
            local green = hash(seed, k, 86) < .5
            local cr = green and L.foliage or L.coconut
            c:rim(nm, cr.edge) fill(nm, cr.base)
            nm:each(function(xx, yy) if not nm:has(xx + 1, yy + 1) then px(xx, yy, cr.shade) end end)
            px(floor(tx + d[1] * nr / 1.5) - (nr > 1 and 1 or 0), floor(ty + d[2] * nr / 1.5) - (nr > 1 and 1 or 0), cr.hi)
          end
        end
      end
    end
    return crownM, floor(tx + .5), floor(ty + .5)
  end
  -- banana plant: a striped pseudo-stem, 5-6 broad paddle leaves with pale midribs and wind tears,
  -- a hanging bunch with its purple bud (o.noBunch to skip). Returns the leaf mask.
  local function banana(x, yb, h, seed, o)
    o = o or {}
    local r = o.ramp or L.leaf
    local stemTop = yb - floor(h * .42)
    local stem = poly{ { x - 2, yb }, { x + 2, yb }, { x + 1, stemTop }, { x - 1, stemTop } }
    local leaves = {}
    local angs = { -2.2, -1.75, -1.2, -.7, -2.7, -.25 }
    local nl = o.leaves or 6
    local allM = stem:copy()
    for i = 1, nl do
      local a = angs[i] + (hash(i, seed, 77) - .5) * .3
      local len = h * (.5 + .15 * hash(i, seed, 78))
      local dx, dy = cos(a), sin(a)
      local droop = .25 + .25 * hash(i, seed, 79)
      local lm, mid, ownT = HP.mask(), {}, {}
      local n = floor(len * 1.3)
      for k = 0, n do
        local t = k / n
        local sx, sy = x + dx * len * t, stemTop + dy * len * t + droop * len * t * t
        local tx, ty = dx, dy + 2 * droop * t
        local tl = math.sqrt(tx * tx + ty * ty) tx, ty = tx / tl, ty / tl
        local nx, ny = -ty, tx
        local wdt = h * .11 * math.sin(math.pi * math.min(1, .1 + t * .95)) ^ .7
        if t < .18 then wdt = 0 end -- bare petiole
        mid[#mid + 1] = { floor(sx + .5), floor(sy + .5) }
        lm:set(floor(sx + .5), floor(sy + .5))
        for s = -wdt, wdt, .5 do
          local xx, yy = floor(sx + nx * s + .5), floor(sy + ny * s + .5)
          lm:set(xx, yy)
          local side = (nx * s + ny * s * 1.4) -- which side faces up-left
          ownT[yy * W + xx] = { s, t, k }
        end
      end
      leaves[i] = { m = lm, mid = mid, own = ownT, a = a, len = len }
      allM:add(lm)
    end
    rimOf(allM, r)
    -- pseudo-stem
    part(stem, L.foliage2, { nopop = true })
    stem:each(function(xx, yy) if xx < x then px(xx, yy, L.foliage2.hi) end if (yy + xx) % 5 == 0 then px(xx, yy, L.foliage2.shade) end end)
    local glint = shift(r.hi, .3, 1.05)
    for i = 1, nl do
      local lf = leaves[i]
      if i > 1 then c:rim(lf.m, r.edge) end
      local lit = -cos(lf.a) * .5 - sin(lf.a) * .5
      lf.m:each(function(xx, yy)
        local ow = lf.own[yy * W + xx]
        local hcol = r.base
        if ow then
          local s, t, k = ow[1], ow[2], ow[3]
          local upper = s < 0
          if upper then hcol = (lit > .3 and t < .7) and r.hi or r.base else hcol = (lit > .5) and r.base or r.shade end
          if upper and t > .3 and t < .6 and lit > .3 and hash(xx, yy, seed) < .25 then hcol = glint end
          -- wind tears: thin dark slits along the vein direction
          if hash(k // 3, i, seed + 3) < .22 and (k % 3 == 0) and math.abs(s) > 1 then hcol = r.deep end
          if math.abs(s) > 1 and hash(xx, yy, seed + 9) < .06 then hcol = L.needle.base end -- dry brown spots / edges
        end
        px(xx, yy, hcol)
      end)
      for _, p in ipairs(lf.mid) do if lf.m:has(p[1], p[2]) then px(p[1], p[2], r.hi) end end
    end
    if not o.noBunch and h >= 26 then
      local s = hash(seed, 4, 77) < .5 and 1 or -1
      local bx = x + s * 3
      local stalk = line({ { x, stemTop }, { bx, stemTop + 3 }, { bx + s, stemTop + h * .32 } }, 1)
      c:rim(stalk, L.foliage2.edge) fill(stalk, L.foliage2.shade)
      local bunch = c:rrect(bx - 3, stemTop + 4, bx + 3, stemTop + 4 + floor(h * .16), 2)
      c:rim(bunch, L.leaf.edge) fill(bunch, L.leaf.base)
      bunch:each(function(xx, yy) if (yy - stemTop) % 3 == 0 then px(xx, yy, L.leaf.shade) elseif xx < bx then px(xx, yy, L.leaf.hi) end end)
      local by = stemTop + floor(h * .32)
      local bud = c:ellipse(bx + s, by, 1, 2)
      c:rim(bud, L.lav.edge) fill(bud, L.lav.deep) px(bx + s, by - 1, L.lav.shade)
    end
    return allM
  end
  -- 5-petal flower, ~5 px: kind "hibiscus" (red, gold stamen), "orange" (orange hibiscus), "plumeria" (pink/cream, gold eye), "white"
  local function flower(x, y, kind, small)
    local r = kind == "orange" and L.hibiscus or (kind == "plumeria" and L.petal or (kind == "white" and L.shell or L.awnA))
    if small then px(x, y, r.base) px(x - 1, y, r.hi) px(x, y - 1, r.hi) px(x + 1, y, r.shade) px(x, y + 1, r.shade)
      px(x, y, (kind == "plumeria" or kind == "white") and L.gold.base or r.deep) return end
    px(x, y - 2, r.hi) px(x - 1, y - 1, r.hi) px(x, y - 1, r.base) px(x + 1, y - 1, r.base)
    px(x - 2, y, r.hi) px(x - 1, y, r.base) px(x + 1, y, r.base) px(x + 2, y, r.shade)
    px(x - 1, y + 1, r.base) px(x + 1, y + 1, r.shade) px(x, y + 1, r.shade) px(x - 1, y + 2, r.shade) px(x + 1, y + 2, r.deep)
    if kind == "plumeria" or kind == "white" then px(x, y, L.gold.hi)
    else px(x, y, r.deep) px(x + 1, y - 2, L.gold.base) px(x + 2, y - 3, L.gold.hi) end
  end
  -- plumeria (frangipani): pale forked trunk, clumped light crowns, pink and cream flower clusters
  local function plumeria(x, yb, h, seed, o)
    o = o or {}
    local top = yb - h
    local trunk = poly{ { x - 1, yb }, { x + 2, yb }, { x + 1, yb - h * .4 }, { x, yb - h * .4 } }
    local br = line({ { x, floor(yb - h * .4) }, { x - floor(h * .2), floor(top + h * .35) } }, 2)
      :add(line({ { x + 1, floor(yb - h * .4) }, { x + floor(h * .22), floor(top + h * .3) } }, 2))
    rimOf(union(trunk, br), L.birch)
    part(union(trunk, br), L.birch, { nopop = true })
    trunk:each(function(xx, yy) if xx <= x then px(xx, yy, L.birch.hi) end end)
    local m = crown(x - floor(h * .2), floor(top + h * .28), floor(h * .2) + 2, floor(h * .16) + 2, L.birchLeaf, seed)
    m:add(crown(x + floor(h * .22), floor(top + h * .24), floor(h * .2) + 2, floor(h * .15) + 2, L.birchLeaf, seed + 1))
    m:add(crown(x + 1, floor(top + h * .12), floor(h * .18) + 2, floor(h * .14) + 2, L.birchLeaf, seed + 2))
    local kinds = { o.kind or "plumeria", "white" }
    local nfl = floor(h * .45)
    for k = 1, nfl do
      local fx = x + floor((hash(k, 1, seed) - .5) * h * .8)
      local fy = floor(top + h * .05 + hash(k, 2, seed) * h * .4)
      if m:has(fx, fy) and m:has(fx, fy + 2) then flower(fx, fy, kinds[1 + floor(hash(k, 3, seed) * 2)], h < 40 or hash(k, 4, seed) < .5) end
    end
    return m
  end
  -- hibiscus bush: a dark glossy clump with big red / orange flowers on its lit side
  local function hibiscus(x, yb, w, h, seed, kind)
    local m = crown(x, yb - h // 2, w, h // 2 + 1, L.foliage2, seed or 7)
    local n = math.max(2, floor(w * h / 40))
    for k = 1, n do
      local fx = x + floor((hash(k, 1, seed or 7) - .55) * w * 1.5)
      local fy = yb - h // 2 + floor((hash(k, 2, seed or 7) - .6) * h * .9)
      if m:has(fx - 2, fy) and m:has(fx + 2, fy + 2) then flower(fx, fy, kind or (hash(k, 3, seed or 7) < .7 and "hibiscus" or "orange"), w < 8) end
    end
    return m
  end
  -- F.tree: island default. seed%4: 0,2 = coconut palm (leaning opposite ways), 1 = banana, 3 = plumeria.
  -- far = small hazed palm.
  local function tree(x, yb, h, seed, far)
    if far then return palm(x, yb, h, L.farTree, seed, { far = true }) end
    local k = seed % 4
    if k == 1 then return banana(x, yb, math.floor(h * .75), seed) end
    if k == 3 then return plumeria(x, yb, math.floor(h * .8), seed) end
    return palm(x, yb, h, k == 0 and L.foliage or L.foliage2, seed)
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

  -- island material helpers ---------------------------------------------------------------
  -- bamboo canes: vertical (or o.horizontal) canes `step` px wide, lit left lip, dark right seam, nodes every 6-9 px
  local function F_bamboo(m, r, step, o)
    o = o or {}
    r = r or L.board
    step = step or 3
    m:each(function(x, y)
      local a, b = o.horizontal and y or x, o.horizontal and x or y
      local k, cane = a % step, a // step
      local h = r.base
      if k == step - 1 then h = r.deep elseif k == 0 then h = r.hi end
      local node = (b + floor(hash(cane, 0, 91) * 9)) % (6 + cane % 3)
      if node == 0 then h = r.shade elseif node == 1 and k ~= step - 1 then h = r.hi end
      px(x, y, h)
    end)
  end
  -- fishing net hung over a mask: diamond mesh of rope, the gaps keep what is behind; o.floats adds cork floats on top row
  local function F_net(m, r, o)
    o = o or {}
    r = r or L.rope
    local b = { m:bbox() }
    m:each(function(x, y)
      if (x + y) % 4 == 0 or (x - y) % 4 == 0 then px(x, y, ((x + y) % 4 == 0) and r.base or r.shade) end
    end)
    if o.floats and b[1] then
      for x = b[1] + 2, b[3] - 2, 6 do fill(rect(x, b[2], x + 2, b[2] + 1), L.hibiscus.base) px(x, b[2], L.hibiscus.hi) px(x + 2, b[2] + 1, L.hibiscus.deep) end
    end
  end
  -- a shell on the sand: kind "conch" (spiral, pink lip), "scallop" (fan), "cowrie" (speckled egg); big = 2x
  local function shell(x, y, kind, big)
    local r = L.shell
    if kind == "scallop" then
      local ramp = big and L.coral or r
      px(x - 1, y - 1, ramp.hi) px(x, y - 1, ramp.base) px(x + 1, y - 1, ramp.shade)
      px(x - 1, y, ramp.base) px(x, y, ramp.shade) px(x + 1, y, ramp.base) px(x, y + 1, ramp.deep)
      if big then px(x - 2, y, ramp.hi) px(x + 2, y, ramp.shade) px(x - 1, y - 2, ramp.hi) px(x + 1, y - 2, ramp.base) px(x, y - 2, ramp.hi) hline(x - 2, x + 2, y + 1, ramp.deep) end
    elseif kind == "cowrie" then
      px(x, y, L.coconut.hi) px(x + 1, y, L.coconut.base) px(x, y - 1, r.hi) px(x + 1, y - 1, L.coconut.hi) px(x + 2, y, L.coconut.shade)
    else
      px(x, y, r.base) px(x - 1, y, r.hi) px(x + 1, y, r.shade) px(x, y - 1, r.hi) px(x + 1, y + 1, L.petal.base)
      if big then px(x + 2, y, L.petal.base) px(x - 1, y - 1, r.hi) px(x - 2, y, r.base) px(x + 2, y + 1, L.petal.shade) px(x, y + 1, r.shade) px(x - 1, y + 1, r.deep) end
    end
  end
  -- branched coral piece (staghorn), standing up from (x, y), h tall
  local function coralBranch(x, y, h, r)
    r = r or L.coral
    local m = line({ { x, y }, { x, y - h } }, 1)
      :add(line({ { x, y - floor(h * .4) }, { x - floor(h * .5), y - floor(h * .8) } }, 1))
      :add(line({ { x, y - floor(h * .5) }, { x + floor(h * .45), y - h + 1 } }, 1))
    c:rim(m, r.edge)
    m:each(function(xx, yy) px(xx, yy, xx < x and r.hi or (xx > x and r.shade or r.base)) end)
    return m
  end
  -- black volcanic rock: a lumpy lava boulder, porous pits, a cool glint on the upper left
  local function lavaRock(x, yb, w, h, seed)
    local r = L.lava
    local m = poly{ { x - w, yb }, { x - w + 1, yb - h + 3 }, { x - w // 2, yb - h }, { x + w // 3, yb - h + 1 }, { x + w, yb - h // 2 }, { x + w, yb } }
    c:rim(m, r.edge) part(m, r)
    m:each(function(xx, yy)
      local v = hash(xx, yy, seed or 5)
      if v < .12 then px(xx, yy, r.deep) elseif v > .94 and (xx - x) + (yy - yb + h) < w * .3 then px(xx, yy, r.hi) end
    end)
    return m
  end
  local function coconutAt(x, y, rr, green)
    local cr = green and L.foliage or L.coconut
    local m = c:ellipse(x, y, rr or 2, rr or 2)
    c:rim(m, cr.edge) fill(m, cr.base)
    m:each(function(xx, yy) if not m:has(xx + 1, yy + 1) then px(xx, yy, cr.shade) end end)
    px(x - 1, y - 1, cr.hi)
    if not green and (rr or 2) >= 2 then px(x + 1, y, cr.deep) px(x, y + 1, cr.deep) end
    return m
  end
  -- a little red crab, claws up, (x, y) = its feet line centre
  local function crab(x, y, r, flip)
    r = r or L.awnA
    local rows = { "c.....c", "cc...cc", ".cBBBc.", "lBhBBBl", ".l.l.l." }
    local m = HP.mask()
    for j, row in ipairs(rows) do for i = 1, #row do if row:sub(i, i) ~= "." then m:set(x - 3 + i - 1, y - 5 + j) end end end
    c:rim(m, r.edge)
    for j, row in ipairs(rows) do for i = 1, #row do
      local ch = row:sub(i, i)
      local col = ({ c = r.base, B = r.base, h = r.hi, l = r.shade })[ch]
      if col then px(x - 3 + i - 1, y - 5 + j, col) end
    end end
    px(x - 1, y - 3, L.timber.edge) px(x + 1, y - 3, L.timber.edge)
    return m
  end
  -- a parrot (scarlet macaw / lorikeet), perched, ~6x11, facing right (flip faces left). kind "macaw" | "lory"
  local function parrot(x, y, kind, flip)
    local s = flip and -1 or 1
    local rows = kind == "lory" and {
      "..BB..", ".BBBk.", ".BeBy.", ".GGG..", "OGGGG.", "OOGGG.", ".RGGg.", "..GGg.", "..Gg..", "..g...", "..g...",
    } or {
      "..RR..", ".RRRk.", ".ReRy.", ".RRR..", "RRRRR.", "YRRRR.", "GYRRr.", "BGYRr.", ".BGr..", "..Rr..", "..r...",
    }
    local map = { R = L.awnA.base, r = L.awnA.shade, k = L.awnB.hi, y = L.timber.edge, e = L.timber.edge, Y = L.gold.base,
      G = L.foliage.base, g = L.foliage.shade, B = "#3c78c8", O = L.hibiscus.base }
    local m = HP.mask()
    for j, row in ipairs(rows) do for i = 1, #row do if map[row:sub(i, i)] then m:set(x + (i - 3) * s, y + j - 1) end end end
    c:rim(m, L.timber.edge)
    for j, row in ipairs(rows) do for i = 1, #row do local col = map[row:sub(i, i)] if col then px(x + (i - 3) * s, y + j - 1, col) end end end
    px(x - 1 * s, y + 1, kind == "lory" and "#6aa2e6" or L.awnA.hi)
    return m
  end
  -- an outrigger canoe on the water or beach: hull from x0 to x1 at waterline y (bow upturned at x1),
  -- two booms out to a float on the near side (o.side = 1 below, -1 above), o.hull ramp
  local function outrigger(x0, x1, y, o)
    o = o or {}
    local hr = o.hull or L.timber
    local hull = poly{ { x0, y - 4 }, { x1 - 2, y - 4 }, { x1 + 2, y - 7 }, { x1, y - 2 }, { x1 - 6, y + 1 }, { x0 + 4, y + 1 }, { x0 - 2, y - 6 } }
    local side = o.side or 1
    local fy = y + side * 7
    local float = c:rrect(x0 + 4, fy - 1, x1 - 6, fy + 1, 1)
    local booms = HP.mask()
    for _, bx in ipairs({ x0 + floor((x1 - x0) * .3), x0 + floor((x1 - x0) * .7) }) do booms:add(line({ { bx, y - 4 }, { bx + 1, fy } }, 1)) end
    local all = union(hull, float, booms)
    c:rim(all, hr.edge)
    if side < 0 then part(float, L.board, { nopop = true }) part(booms, L.board, { nopop = true, noshade = true }) end
    part(hull, hr, { nopop = true })
    hline(x0 - 1, x1, y - 4, hr.hi) hline(x0 + 4, x1 - 6, y - 1, hr.deep)
    -- a painted stripe along the gunwale
    hline(x0 + 1, x1 - 2, y - 3, (o.stripe or L.accent).base)
    if side > 0 then part(booms, L.board, { nopop = true, noshade = true }) part(float, L.board, { nopop = true }) end
    return hull
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
    if b.shingle then courses(roofM, top - rh, 3, 5, rr)
    else F_thatch(roofM, rr, top - rh, cx) end
    -- plaster wall texture: lime wash patches, a lath crack, damp darker base
    wallM:each(function(x, y)
      local v = hash(x, y, 41)
      if y <= top + 3 then return end
      if y >= yb - 3 and hash(x // 2, y, 42) < .4 then px(x, y, wr.shade)
      elseif hash(x // 4, y, 41) < .03 then px(x, y, wr.hi) end
    end)
    line({ { x0 - 2, top + 2 }, { cx, top - rh + 1 } }):each(function(x, y) if roofM:has(x, y) then px(x, y, rr.hi) end end)
    hline(x0 - 3, x1 + 3, top + 3, rr.deep)
    vline(cx, top - rh + 10, top - 1, L.timber.base)
    if rh >= 18 and not b.noAttic then window(cx - 3, top - rh // 2 + 1, cx + 2, top - rh // 2 + 5, L.timber) end
    if not b.noFrame then
      local beams = union(rect(x0, top, x1, top + 1), rect(x0, yb - 2, x1, yb), rect(x0, top, x0 + 1, yb), rect(x1 - 1, top, x1, yb))
      local mid = top + floor(wh * .45)
      beams:add(rect(x0, mid, x1, mid + 1))
      for x = x0 + 12, x1 - 10, 14 do beams:add(rect(x, top, x + 1, yb)) end
      beams:add(line({ { x0 + 2, mid - 1 }, { x0 + 10, top + 2 } })):add(line({ { x1 - 2, mid - 1 }, { x1 - 10, top + 2 } }))
      part(beams, L.timber, { nopop = true, noshade = true })
      beams:each(function(x, y) local v = hash(x // 3, y, 43) if v < .18 then px(x, y, L.timber.shade) elseif v > .93 then px(x, y, L.timber.hi) end end)
    end
    return top, cx, wallM, roofM
  end

  ---------------------------------------------------------------- BACKGROUND (island: hot clear sky, cumulus, sea, volcano, reef, lagoon, motu)
  c:stripes(0, HZ, L.sky, { 3, 3, 3, 2, 2 })
  -- a hot white sun, upper left (the light source of every scene), with a stepped pale halo
  if not o.noSun then
    local sx, sy = o.sunX or 92, o.sunY or 52
    for y = sy - 20, sy + 20 do for x = sx - 20, sx + 20 do
      local d = math.sqrt((x - sx) ^ 2 + (y - sy) ^ 2)
      local v = y >= 0 and c:get(x, y)
      if v and y < HZ then
        if d <= 6 then px(x, y, "#fffbe6") elseif d <= 9 then px(x, y, "#fff2c4")
        elseif d <= 13 then px(x, y, mix(v, "#f2f8ea", .55)) elseif d <= 18 then px(x, y, mix(v, "#eef6ee", .28)) end
      end
    end end
  end
  -- big white cumulus: stacked round puffs on a flat base, lit upper left, blue-grey undersides
  local function cumulus(x, y, w, seed)
    local n = 3 + floor(w / 12)
    local blobs, m = {}, HP.mask()
    for i = 1, n do
      local t = (i - .5) / n
      local bell = 1 - math.abs(t - .42) * 1.7
      local rr = math.max(4, w * (.13 + .2 * bell) * (.85 + .3 * hash(i, seed, 41)))
      local bx = x - w * .12 + t * w * 1.25
      local by = y - rr * (.45 + .5 * bell)
      blobs[i] = { bx, by, rr }
      m:add(c:ellipse(floor(bx), floor(by), floor(rr), floor(rr * .82)))
    end
    m:clip(rect(0, 0, W - 1, y))
    m:each(function(xx, yy)
      local best, bi = 1e9, 1
      for i = 1, n do local b = blobs[i] local d = ((xx - b[1]) ^ 2 + ((yy - b[2]) / .82) ^ 2) / (b[3] * b[3]) if d < best then best, bi = d, i end end
      local b = blobs[bi]
      local nx, ny = (xx - b[1]) / b[3], (yy - b[2]) / (b[3] * .82)
      local lit = -(nx * .55 + ny * .85) + (hash(xx // 2, yy // 2, seed) - .5) * .25
      local hcol
      if y - yy <= 1 then hcol = L.cloud.deep elseif y - yy <= 3 then hcol = L.cloud.under
      elseif lit > .25 then hcol = L.cloud.top elseif lit > -.35 then hcol = L.cloud.mid else hcol = L.cloud.under end
      if best > .8 and lit < -.2 and y - yy > 3 then hcol = L.cloud.under end
      px(xx, yy, hcol)
    end)
    return m
  end
  for i, cl in ipairs(o.clouds or { { 120, 44, 40 }, { 290, 34, 56 }, { 420, 60, 30 }, { 30, 80, 26 } }) do cumulus(cl[1], cl[2], cl[3], 40 + i) end
  local SEA = HZ - 17
  local REEF = HZ - 8
  local VXc, VPK = o.volcanoX or 376, o.volcanoTop or 58
  local function volcanoH(x)
    if o.noVolcano then return 0 end
    local d = math.abs(x - VXc)
    local hgt = (SEA - VPK) * math.max(0, 1 - d / 120) ^ 1.7
    if d < 9 then hgt = math.min(hgt, SEA - VPK - 1 - (d < 5 and 2 or 0)) end -- crater notch
    return hgt + (hgt > 2 and (1.2 * sin(x / 7) + .8 * sin(x / 3 + 1)) or 0)
  end
  local function fFar(x) return SEA - volcanoH(x) end
  -- the motu: low palm-scrub islets riding the reef, with a channel gap (o.motuGap = {x0,x1}, default 168..312)
  local mg = o.motuGap or { 168, 312 }
  local function onMotu(x) return not o.noMotu and (x < mg[1] or x > mg[2]) end
  local function fMid(x)
    if not onMotu(x) then return REEF end
    local e = math.min(math.abs(x - mg[1]), math.abs(x - mg[2]), 40) / 40
    return REEF - 1 - floor((2 + 2 * sin(x / 23) + 1.4 * sin(x / 9 + 2)) * math.min(1, e * 2 + .2))
  end
  -- sea, horizon haze line, sun glitter
  for y = SEA, HZ do for x = 0, W - 1 do
    local hcol
    if y == SEA then hcol = L.mist elseif y <= SEA + 2 then hcol = L.sea.hi elseif y <= SEA + 5 then hcol = L.sea.base else hcol = L.sea.shade end
    if y > SEA and y < REEF - 1 then
      local seg = (x + y * 5) // (6 + y % 3)
      local v = hash(seg, y, 31)
      if v < .16 then hcol = y <= SEA + 4 and L.mist2 or L.sea.hi elseif v > .93 then hcol = L.sea.deep end
      if math.abs(x - (o.sunX or 92)) < 14 - (y - SEA) and hash(x, y, 32) < .35 then hcol = "#f4f8e6" end
    end
    px(x, y, hcol)
  end end
  -- the far volcano: hazed violet-blue cone, lit left slope, old dark lava runs, jungle green skirts, a steam wisp
  if not o.noVolcano then
    local vm = c:terrain(fFar, L.hillFar, SEA)
    vm:each(function(x, y)
      local d = x - VXc
      local hgt = SEA - y
      local hcol = L.hillFar
      if d < -2 and hash(x // 2, y, 33) < .8 then hcol = mix(L.hillFar, "#e2eef2", .28) end
      if d > 4 then hcol = mix(L.hillFar, "#5a6a96", .22) end
      if (x * 3 + y) % 17 == 0 and hgt > 6 and hgt < 28 then hcol = mix(L.hillFar, "#4a4a6a", .3) end
      if hgt < 9 + 3 * sin(x / 11) then hcol = (d < 0 and hash(x // 2, y // 2, 34) < .7) and mix(L.ridgeMid, L.hillFar, .45) or mix(L.ridgeMid, L.hillFar, .6) end
      px(x, y, hcol)
    end)
    for k = 0, 4 do
      local wx, wy = VXc - 2 + k * 3 + floor(sin(k) * 2), VPK - 3 - k * 4
      fill(c:ellipse(wx, wy, 2 + k // 2, 1 + k // 3), k < 2 and L.cloud.mid or L.cloud.top)
      px(wx + 2 + k // 2, wy, L.cloud.under)
    end
  end
  -- a far islet on the left horizon
  if not o.noIslet then
    for x = 18, 66 do
      local hgt = floor(3 * math.max(0, 1 - math.abs(x - 42) / 24) ^ .6 + .5)
      for y = SEA - hgt, SEA do px(x, y, y == SEA and L.mist or mix(L.ridgeFar, L.hillFar, .3)) end
    end
    for _, ix in ipairs({ 30, 40, 52 }) do palm(ix, SEA - 1, 9, rp("#9cc0c8 #86aab8 #7898ac #6a88a0 #5c7a94"), ix, { far = true, lean = (ix - 40) * .1 }) end
  end
  -- the reef: a line of white breakers, spray above it
  for x = 0, W - 1 do
    local v = hash(x // 3, 1, 35)
    if v < .7 then px(x, REEF, L.surf) end
    if hash(x // 2, 2, 35) < .45 then px(x, REEF - 1, L.mist) end
    if hash(x, 3, 35) < .3 then px(x, REEF + 1, L.mist2) end
    if v < .25 and hash(x, 4, 35) < .5 then px(x, REEF - 2, L.mist2) end
  end
  -- lagoon: deeper teal at the reef, bright shallow turquoise toward the shore, ripple dashes
  for y = REEF + 2, HZ do for x = 0, W - 1 do
    local f = (y - REEF - 2) / math.max(1, HZ - REEF - 2)
    local hcol = f < .34 and L.lagoon.shade or (f < .7 and L.lagoon.base or L.lagoon.hi)
    local seg = (x + y * 7) // (5 + y % 4)
    if hash(seg, y, 36) < .14 then hcol = f < .5 and L.lagoon.base or L.surf end
    px(x, y, hcol)
  end end
  if o.beforeMid then o.beforeMid() end
  setDepth(1)
  if not o.noMotu then
    local mm = HP.mask()
    for x = 0, W - 1 do if onMotu(x) then for y = floor(fMid(x)), REEF do mm:set(x, y) end end end
    mm:each(function(x, y)
      local top = floor(fMid(x))
      local hcol = L.ridgeMid
      if y == REEF then hcol = L.groundFar elseif y == REEF - 1 then hcol = L.ground.base
      elseif y == top then hcol = L.hillMid elseif hash(x // 2, y, 37) < .25 then hcol = L.hillMidShade end
      px(x, y, hcol)
    end)
    for x = 0, W - 1 do if onMotu(x) and hash(x // 2, 5, 37) < .5 then px(x, REEF + 1, L.surf) end end
  end
  for i, tx in ipairs(o.farTrees or { 24, 52, 196, 290, 318, 352, 440 }) do
    if onMotu(tx) then palm(tx, floor(fMid(tx)) + 1, 20 + (i % 3) * 3, L.farTree, i + 1, { far = true }) end
  end
  setDepth(0)
  -- F.ridge kept from the forest frame: a row of spires along a hill line (here: casuarina tops on a headland)
  local function ridge(f, col, colLit, seed, hmin, hmax)
    local x = -4
    while x < W + 4 do
      local hh = hmin + floor(hash(x, 1, seed) * (hmax - hmin))
      local yb = floor(f(x)) + 2
      local w = math.max(2, floor(hh * .3))
      for yy = yb - hh, yb do
        local half = floor((yy - (yb - hh)) / hh * w + .5)
        if (yy - (yb - hh)) % 3 == 2 then half = half + 1 end
        for xx = x - half, x + half do px(xx, yy, (colLit and xx < x and yy < yb - 1) and colLit or col) end
      end
      x = x + 3 + floor(hash(x, 2, seed) * 5)
    end
  end

  local function groundAt(x, y)
    local d = y - HZ + 2
    local f = (y - HZ - 1) / (H - 1 - HZ)
    -- the wet sand edge where the lagoon laps the beach
    if y == HZ + 1 then return hash(x // 3, y, 7) < .55 and L.duff or L.ground.shade end
    if y == HZ + 2 and hash(x // 4, y, 8) < .35 then return L.duff end
    local base
    if f < 1 / 13 then base = L.groundFar elseif f < 3 / 13 then base = L.ground.hi else base = L.ground.base end
    -- island: low-frequency patches of beach grass / sea-grape (green) and bright wind-blown coral-sand drifts
    local sy = 2 + d * .1
    local nv = vnoise(x / (sy * 5), y / sy, 5) + (hash(x, y, 6) - .5) * .08
    if f >= 1 / 13 then
      if nv < .28 then base = f < 3 / 13 and L.mossGround.hi or L.mossGround.base
      elseif nv < .32 then base = hash(x, y, 9) < .5 and L.mossGround.hi or L.ground.hi
      elseif nv > .74 then base = f < 3 / 13 and L.ground.base or L.ground.hi end
    end
    local u = (x - VX) / d * 7
    if y > HZ + 6 and y < 160 and abs(u - floor(u + .5)) < .04 + .8 / d then return L.ground.shade end
    if hash(x, y, 1) < .01 + y / 16000 then return L.ground.shade end
    if hash(x, y + 1, 1) < .01 + (y + 1) / 16000 then return L.ground.hi end
    local g = hash(x, y, 2)
    if g < .003 then return L.coral.hi elseif g < .005 then return L.lava.base elseif g < .007 then return L.shell.hi end
    return base
  end
  -- island: the ground is painted per pixel by groundAt (so eraseGround matches it exactly, patches included)
  for y = HZ + 1, H - 1 do for x = 0, W - 1 do px(x, y, groundAt(x, y)) end end
  for x = 0, W - 1 do if hash(x // 2, HZ, 7) < .5 then px(x, HZ, L.surf) end end -- foam where the lagoon meets the sand
  -- fern / grass tuft (kept from the forest frame; island default ramp = tropical fern green)
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
    r = r or L.apple
    if big then
      fill(rect(x - 1, y - 2, x, y), L.awnB.base) px(x - 1, y - 2, L.awnB.hi)
      hline(x - 3, x + 2, y - 3, r.shade) hline(x - 2, x + 1, y - 4, r.base) px(x - 2, y - 4, r.hi) px(x - 1, y - 5, r.base) px(x, y - 5, r.base)
      px(x - 1, y - 4, L.awnB.hi) px(x + 1, y - 3, L.awnB.base) hline(x - 3, x + 2, y - 2, r.edge)
    else
      px(x, y, L.awnB.shade) px(x, y - 1, r.base) px(x - 1, y - 1, r.hi) px(x + 1, y - 1, r.shade)
    end
  end
  -- island ground detail: beach-grass tufts, shells, coral bits, black lava pebbles, fallen hibiscus / plumeria,
  -- beach morning-glory runners, crab holes, driftwood twigs. Far ground faint, near ground bigger.
  local function groundDetail(x0, x1, y0, y1, seed)
    for i = 1, 700 do
      local x = x0 + floor(hash(i, 1, seed) * (x1 - x0))
      local y = y0 + floor(hash(i, 2, seed) ^ .7 * (y1 - y0))
      local near = (y - HZ) / (H - HZ)
      local kind = hash(i, 3, seed)
      if hash(i, 4, seed) < near * 1.2 then
        if kind < .26 then
          local th = 2 + floor(near * 5 * hash(i, 5, seed))
          local r = hash(i, 7, seed) < .6 and L.mossGround or L.seagrass
          vline(x, y - th, y, r.shade) px(x, y - th, r.hi)
          px(x - 1, y - th + 1, r.hi) px(x + 1, y - th + 2, r.base)
          if near > .45 then vline(x - 2, y - th + 3, y, r.base) vline(x + 2, y - th + 2, y, r.deep) px(x + 2, y - th + 1, r.shade) px(x - 2, y - th + 2, r.hi) end
        elseif kind < .44 then
          local k2 = hash(i, 6, seed)
          if near > .3 then shell(x, y, k2 < .4 and "conch" or (k2 < .75 and "scallop" or "cowrie"), near > .62)
          else px(x, y, L.shell.hi) px(x + 1, y, L.shell.shade) end
        elseif kind < .50 then
          if near > .55 and hash(i, 10, seed) < .5 then coralBranch(x, y, 3 + floor(near * 3), hash(i, 9, seed) < .7 and L.coral or L.shell)
          else px(x, y, L.coral.base) px(x - 1, y, L.coral.hi) end
        elseif kind < .62 then
          local r = L.lava
          px(x, y, r.base) px(x + 1, y, r.shade) px(x, y - 1, r.hi)
          if near > .5 then px(x + 2, y, r.deep) px(x + 1, y - 1, r.base) px(x - 1, y, r.shade) px(x, y + 1, r.edge) px(x + 1, y + 1, r.edge) end
        elseif kind < .69 then
          if near > .4 then flower(x, y, ({ "hibiscus", "plumeria", "orange", "white" })[1 + floor(hash(i, 8, seed) * 4)], near < .7)
          else px(x, y, L.petal.base) end
        elseif kind < .77 then
          if near > .35 then -- beach morning glory runner: a trailing vine with round leaves and a lilac trumpet
            local dir = hash(i, 8, seed) < .5 and 1 or -1
            for k = 0, 6 do px(x + k * dir, y + (k % 3 == 0 and 0 or 1) - (k // 4), L.seagrass.shade) end
            for k = 0, 6, 3 do px(x + k * dir, y - 1, L.seagrass.base) px(x + k * dir + dir, y - 1, L.seagrass.hi) end
            px(x + 5 * dir, y - 2, L.lav.hi) px(x + 6 * dir, y - 2, L.lav.base) px(x + 5 * dir, y - 1, L.lav.shade)
          end
        elseif kind < .83 then
          if near > .3 then px(x, y, L.ground.deep) px(x + 1, y, L.ground.shade) px(x, y - 1, L.ground.shade) px(x - 1, y + 1, L.ground.hi) px(x + 2, y + 1, L.ground.hi) end
        else
          local r = L.timber
          local dir = hash(i, 8, seed) < .5 and 1 or -1
          px(x, y, r.hi) px(x + dir, y, r.base) px(x + 2 * dir, y - 1, r.shade)
          if near > .5 then px(x + 3 * dir, y - 1, r.deep) px(x + dir, y + 1, r.deep) end
        end
      end
    end
  end
  groundDetail(0, W - 1, HZ + 8, H - 1, 401)
  -- island: a sparse palm fringe along the shore (plane 1, hazed) so the lagoon still shows between the trunks.
  -- Skips the road end; o.noTreeLine turns it off, o.treeLineGap = { x0, x1 } changes the gap (default 220..260).
  if not o.noTreeLine then
    local g0, g1 = (o.treeLineGap or { 220, 260 })[1], (o.treeLineGap or { 220, 260 })[2]
    setDepth(1)
    local x, i = 6, 0
    while x < W - 2 do
      i = i + 1
      if (x < g0 or x > g1) and hash(x, 7, 31) < .72 then
        local hh = 18 + floor(hash(x, 3, 31) * 18)
        local yb = HZ + 3 + floor(hash(x, 4, 31) * 3)
        if hash(x, 8, 31) < .45 then crown(x + 4, yb - 2, 6, 3, L.foliage2, 500 + i) end -- naupaka scrub at the foot
        palm(x, yb, hh, hash(x, 5, 31) < .5 and L.foliage or L.farTree, 300 + i, { fronds = 7, nuts = false, dead = false })
      end
      x = x + 14 + floor(hash(x, 6, 31) * 22)
    end
    setDepth(0)
  end
  -- erase an area back to plain ground (keeps the fan lines and grass flecks)
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
      -- island: drifted sand in the slab seams, fossil shell / coral pores on some coral-stone slabs
      if h == L.road.deep and hash(x, y, 24) < .3 then h = L.ground.shade
      elseif h ~= L.road.deep and hash(r1, u1, 26) < .3 and hash(x, y, 27) < .10 then h = hash(x, y, 28) < .5 and L.road.shade or L.coral.hi end
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
    -- island: palm fronds tied over the beam, hanging down on both sides, with hibiscus and plumeria tucked in
    local fr = { { 30, 6, -.25, 50, .9, L.foliage, 91 }, { 70, 4, -2.9, 40, .8, L.foliage2, 92 }, { 96, 6, .15, 30, 1.0, L.foliage, 97 },
      { 450, 6, -2.9, 50, .9, L.foliage, 93 }, { 410, 4, -.25, 40, .8, L.foliage2, 94 }, { 384, 6, 2.95, 30, 1.0, L.foliage, 98 } }
    for _, f in ipairs(fr) do frond(f[1], f[2], f[3], f[4], f[5], f[6], f[7]) end
    for _, fl in ipairs({ { 22, 14, "hibiscus" }, { 52, 13, "plumeria" }, { 86, 12, "orange" }, { 458, 14, "hibiscus" }, { 428, 13, "plumeria" }, { 396, 12, "white" } }) do
      flower(fl[1], fl[2], fl[3])
    end
    flatCrown = true
    local beam = rect(0, 0, W - 1, 12)
    local postL, postR = rect(0, 0, 15, 222), rect(W - 16, 0, W - 1, 222)
    local plL, plR = rect(0, 218, 18, 228), rect(W - 19, 218, W - 1, 228)
    local brL = poly{ { 16, 13 }, { 34, 13 }, { 16, 31 } }
    local brR = poly{ { W - 17, 13 }, { W - 35, 13 }, { W - 17, 31 } }
    rimOf(union(beam, postL, postR, plL, plR, brL, brR), L.timber)
    part(postL, G) part(postR, G)
    courses(union(postL, postR), 0, 9, 16, G)
    -- island: coral-stone courses with pores, the odd black lava block set in, sea-salt bloom low down
    union(postL, postR):each(function(x, y)
      local row, col = y // 9, ((x + (y // 9 % 2) * 8) // 16)
      local ry = y % 9
      if hash(col, row, 97) < .16 and ry ~= 0 and ((x + (row % 2) * 8) % 16) ~= 0 then
        px(x, y, ry == 1 and L.lava.hi or (hash(x, y, 98) < .2 and L.lava.deep or L.lava.base))
      elseif hash(x, y, 99) < .05 then px(x, y, G.shade)
      elseif y > 180 and ry == 1 and hash(x // 2, row, 96) < .3 then px(x, y, L.shell.hi) end
    end)
    part(plL, L.lava, { sep = true }) part(plR, L.lava, { sep = true }) hline(0, 18, 218, L.lava.hi) hline(W - 19, W - 1, 218, L.lava.hi)
    for x = 0, W - 1 do if (x < 19 or x > W - 20) and hash(x, 221, 96) < .12 then px(x, 221, L.lava.deep) end end
    part(brL, L.timber, { nopop = true }) part(brR, L.timber, { nopop = true })
    part(beam, L.timber, { band = 2 })
    flatCrown = false
    beam:each(function(x, y) if y > 1 and y < 11 and hash(x // 7, y, 95) < .12 then px(x, y, L.timber.shade) end end)
    hline(0, W - 1, 1, L.timber.hi)
    for x = 30, W - 30, 60 do fill(rect(x, 4, x + 2, 6), L.timber.deep) px(x, 4, L.timber.hi) end
    local function by(x) local t = (x - VX) / 224 return 15 + 16 * (1 - t * t) end
    for x = 16, W - 17 do px(x, floor(by(x)), L.timber.deep) end
    local cols = { L.awnA, L.awnB, L.accent, L.hibiscus }
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
    for y = 230, H - 1 do for x = 380, W - 1 do
      px(x, y, hash(x, y, 99) < .04 and L.ground.shade or L.ground.base)
    end end
  end

  local F = {
    c = c, L = L, HP = HP, W = W, H = H, HZ = HZ, VX = VX, ROAD_TOP = ROAD_TOP, rp = rp,
    px = px, rect = rect, poly = poly, line = line, fill = fill, part = part, hline = hline, vline = vline,
    union = union, rimOf = rimOf, hash = hash, shadow = shadow, shadowM = shadowM, courses = courses, hrows = hrows,
    speckle = speckle, window = window, door = door, crown = crown, maple = maple, tree = tree,
    building = building, roadM = roadM, xl = xl, xr = xr, fFar = fFar, fMid = fMid,
    groundAt = groundAt, eraseGround = eraseGround, drawRoad = drawRoad,
    mix = mix, shift = shift, depth = setDepth, obj = newObj, thatch = F_thatch, planks = F_planks, water = F_water,
    groundDetail = groundDetail,
    -- forest additions (kept, re-coloured)
    conifer = conifer, pine = pine, birch = birch, fern = fern, mushroom = mushroom, logs = F_logs, logEnd = logEnd, moss = moss,
    ridge = ridge,
    -- island additions
    palm = palm, banana = banana, plumeria = plumeria, hibiscus = hibiscus, flower = flower, frond = frond,
    shell = shell, coral = coralBranch, lavaRock = lavaRock, bamboo = F_bamboo, net = F_net, coconut = coconutAt,
    crab = crab, parrot = parrot, outrigger = outrigger, SEA = SEA, REEF = REEF, onMotu = onMotu,
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
      local col = b[4] or "#4a4a5a" -- island: frigatebird / tern slate
      px(x, y, col)
      for k = 1, w do px(x - k, y - (k == w and 1 or 0) - (k > 1 and 1 or 0) + (k == 1 and 0 or 0), col) px(x + k, y - (k > 1 and 1 or 0), col) end
    end
  end
  -- smoke column: puffs rising and drifting, lighter and smaller as they rise
  function F.smoke(x, y, n, drift, big)
    drift = drift or 1
    local cols = { "#c8c4bc", "#d8d6ce", "#e6e6de", "#f0f0ea" } -- island: pale warm wood smoke in bright air
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
    m:each(function(x, y) if not m:has(x - 1, y) or not m:has(x, y - 1) then local v = c:get(x, y) if v then rawput(c, x, y, mix(v, "#fff4cc", k or .4)) end end end)
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
    rimOf(m, L.timber) part(m, L.timber, { nopop = true, noshade = true })
    for x = x0, x1, step do px(x, yb - 9, L.timber.hi) end
    hline(x0, x1 + 1, yb - 7, L.timber.hi)
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
    rimOf(m, L.timber) part(m, L.timber, { nopop = true, noshade = true })
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
      if v then local _, _, l = toHsl(v) if l < .86 then rawput(c, x, y, mix(v, "#fff4cc", .34)) end end
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
