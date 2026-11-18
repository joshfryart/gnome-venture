-- _frame.lua : WETLAND gate-view frame for the stop-type looks, palette "wetland_reed".
-- A copy of art-forest-stops/_frame.lua (itself a copy of the Maplewold art-2701-batch3/stops/opus3/_frame.lua)
-- with the same API and composition compass (horizon y=112, slab road, gate, bunting, lanterns, compass corner,
-- depth planes, rim light), re-skinned for a fen: soft grey-gold overcast sky with a low misted sun, a flat carr of
-- alders and willows on the back rows with mist banks, a reed-bed horizon, wet sedge ground with peat patches and
-- still dark pools that mirror the sky (lilies, rushes, marsh marigolds), a raised slab causeway with a stone flank,
-- willow fronds on the gate. F.tree now draws weeping willow / alder / pollard willow; F.maple stays a broadleaf crown.
-- The forest helpers (F.conifer, F.pine, F.birch, F.fern, F.mushroom, F.logs, F.logEnd, F.moss) are kept.
-- New helpers: F.willow, F.alder, F.pollard, F.reeds, F.cattail, F.lily, F.dragonfly, F.frog, F.heron, F.goose,
-- F.punt, F.stilts, F.boardwalk, F.mist, F.poolAt.
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
  -- wetland_reed: same keys as Maplewold / forest so type scripts keep working; the MEANING of a few keys shifts:
  -- roof = golden water-reed thatch, roof2 = old dark sedge thatch (also the thatch ridge cap), plaster = clay daub,
  -- wall2 = tarred grey-green weatherboard, foliage = dark alder green, foliage2 = silvery willow green,
  -- board = silver-weathered boardwalk planks, timber = wet grey-brown stilt timber, water = still dark fen water.
  local L = {
    sky = { "#a8aa9e", "#b9b8a2", "#cbc5a8", "#dbd1ae", "#e6dab4" },
    cloud = { top = "#ece4c6", under = "#cbc4a8" },
    hillFar = "#aeae9c", hillMid = "#8f967c", hillMidShade = "#7b846e",
    ridgeFar = "#9da190", ridgeMid = "#6e7a64", mist = "#d6d2be", mist2 = "#e2dcc4",
    farTree = rp("#b4b8a0 #96a088 #7a8874 #606e62 #46544e"),
    ground = rp("#c8bc84 #a69862 #807444 #5a5034 #3a3426"), groundFar = "#b8b28e",
    road = rp("#d6d0b8 #b2ab92 #8e8874 #6a6656 #46443a"), slabRatio = 1.06, slabK = 15,
    stone = rp("#d2d2c2 #aaaa9a #86887c #626660 #3e4444"),
    plaster = rp("#f0e4c8 #dccdaa #baa886 #8e7e66 #5c5044"),
    wall2 = rp("#b6c0aa #8e9a86 #6c786a #4e5850 #323a38"),
    timber = rp("#9c8c74 #766852 #584c3e #3e362e #26201e"),
    roof = rp("#e4d08e #c2a86a #9a8250 #6c5c3c #44392a"),
    roof2 = rp("#b2a274 #8c7e54 #6a6040 #4a4430 #2e2a20"),
    awnA = rp("#f08a78 #d6524a #aa3a3e #7a2a38 #4a1a28"),
    awnB = rp("#f4eedc #e2dac4 #c2b8a2 #989284 #5e5a54"),
    accent = rp("#9cc4b8 #5c9488 #42746c #2e5656 #1e383c"),
    foliage = rp("#a8b86c #78904c #546e40 #3a5236 #24362a"),
    foliage2 = rp("#cdd494 #a6b46e #7e9256 #5a7042 #3a4a30"),
    leaf = rp("#c4cc7a #98aa58 #6e8644 #4e6438 #30422c"),
    water = rp("#dcd6b4 #8e9c90 #5e7072 #43545a #2c3a40"),
    glow = rp("#fff6c0 #ffd870 #f6aa42 #d27a30 #8a4a24"),
    soil = rp("#a07a58 #7e5a40 #604430 #463024 #2c1c18"),
    board = rp("#d8ccaa #b4a684 #8e8264 #6a604c #443e34"),
    produce = rp("#ffb04a #f07c22 #c85a1e #943e1c #5e2618"),
    lav = rp("#d0c4ec #a28ad4 #7862b0 #554484 #362a58"),
    iron = rp("#b0b4b8 #7c8288 #5a6068 #3e444e #262c36"),
    skin = rp("#ffe0bd #f0b98d #c98462 #7a4036 #4a2620"),
    apple = rp("#ff8a6c #e23c3a #b02436 #741c30 #4a1222"),
    petal = rp("#f8c4cc #ec8c9c #c86478 #94485e #5e2c40"),
    gold = rp("#f6e08a #e2be52 #b8923a #86662c #563f22"),
    -- forest ramps, kept for the forest helpers (re-tinted toward the fen)
    moss = rp("#c8d07a #9aaa52 #72843e #52643a #36462c"),
    birch = rp("#f0ecdc #d8d4c4 #ada99c #7c7a72 #4a4a46"),
    birchLeaf = rp("#e6e490 #c4cc62 #98aa48 #6c823c #46582e"),
    redbark = rp("#dc8c5e #b2603e #884434 #5e2e2a #3a1c1e"),
    needle = rp("#d4a268 #b0763e #8a5632 #643c28 #40281e"),
    fern = rp("#b8c87a #8aa252 #64803e #466034 #2c3e28"),
    mossGround = rp("#b0b46e #8e9656 #6e7a44 #505a36 #343c28"), duff = "#7e6448",
    -- wetland-only ramps
    reed = rp("#e8d89e #c8b270 #a08a52 #74643e #4a402c"),        -- dry golden reed stems and plumes
    reedGreen = rp("#c0c87c #96a458 #6e8044 #4e5c36 #303a28"),   -- green reed / sedge / rush blades
    plume = rp("#d8c4b0 #b49a8a #8e7468 #6a5450 #463838"),       -- reed seed-head plumes (mauve-brown)
    cattail = rp("#b07c52 #8a5a3c #68422e #4a2e24 #2e1c1a"),     -- bulrush heads
    peat = rp("#a88a66 #84684a #644c38 #48362a #2e2220"),        -- mud and peat banks
    willow = rp("#d4daa0 #aeba78 #869a5c #627446 #3e4c32"),      -- weeping willow fronds (silvery)
    willowBark = rp("#a49a84 #7e7462 #5e564a #423c36 #2a2624"),  -- fissured grey willow / alder bark
    lily = rp("#b8c470 #8aa04e #66803e #485e34 #2e3e28"),        -- lily pads
    heron = rp("#eceae0 #c4c6c0 #9a9ea0 #6e7478 #44484e"),       -- grey heron plumage
    goose = rp("#dcd4c2 #b2a894 #8a8172 #645c52 #403a36"),       -- greylag goose plumage
    marigold = rp("#fff0a0 #f6d04a #d8a634 #a87828 #6e4c20"),    -- marsh marigold / iris yellow
    sedgeGround = rp("#b4b676 #92985a #747c46 #565e38 #383e2a"),
    shadow = "#6a654c", shadowRoad = "#7c7866",
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
  local HAZE = "#dad5bf" -- wetland: soft grey-gold fen mist

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
  -- wetland: a weeping willow. Short leaning grey trunk, a domed crown, and a curtain of hanging fronds that falls
  -- almost to the ground: vertical strands lit on the left, a dark gap every few strands, ragged tips.
  -- h = full height (ground yb to crown top). Returns the crown + curtain mask.
  local function willow(x, yb, h, seed, r)
    r = r or L.willow
    local cy = yb - h * .74
    local rx, ry = h * .4, h * .24
    local trunk = poly{ { x - 3, yb }, { x + 3, yb }, { x + 2, floor(cy + ry * .4) }, { x - 1, floor(cy + ry * .5) } }
    local br = line({ { x, floor(cy + ry * .6) }, { x - floor(rx * .5), floor(cy) } }, 2)
      :add(line({ { x + 1, floor(cy + ry * .7) }, { x + floor(rx * .5), floor(cy - ry * .1) } }, 2))
    local wb = L.willowBark
    rimOf(union(trunk, br), wb)
    part(trunk, wb, { nopop = true })
    trunk:each(function(xx, yy) if xx <= x - 2 then px(xx, yy, wb.hi) elseif hash(xx, yy // 2, seed) < .25 then px(xx, yy, wb.deep) end end)
    part(br, wb, { nopop = true, noshade = true })
    -- curtain: strands 2 px wide every 3 px, hanging from under the dome, longest mid-crown. The upper part is a
    -- solid curtain (dark gaps); lower down the strands part and the background shows between them.
    local solid, strands = HP.mask(), {}
    local x0, x1 = floor(x - rx * 1.08), floor(x + rx * 1.08)
    for s = x0, x1, 3 do
      local u = (s + .5 - x) / (rx * 1.08)
      local top = floor(cy + ry * .25 * (1 - u * u))
      local len = floor((yb - top) * (.45 + .5 * (1 - u * u)) * (.8 + .35 * hash(s, 5, seed)))
      if hash(s, 6, seed) < .15 then len = floor(len * .55) end
      local sol = floor(len * (.3 + .25 * hash(s, 4, seed)))
      strands[#strands + 1] = { s, top, len, sol, u }
      for yy = top, top + sol do solid:set(s, yy) solid:set(s + 1, yy) solid:set(s + 2, yy) end
    end
    local dome = crown(x, floor(cy), floor(rx), floor(ry), r, seed, true)
    local sil = union(dome, solid)
    c:rim(sil, r.edge)
    newObj()
    local glint = r.glint or shift(r.hi, .3, 1.05)
    for _, st in ipairs(strands) do
      local s, top, len, sol, u = st[1], st[2], st[3], st[4], st[5]
      for yy = top, top + len do
        local f = (yy - cy) / math.max(1, yb - cy)
        local lit = -u * .9 - f * .5 + (hash(s, yy // 3, seed) - .5) * .5
        local a, b
        if lit > .7 then a, b = glint, r.hi elseif lit > .15 then a, b = r.hi, r.base elseif lit > -.4 then a, b = r.base, r.shade
        elseif lit > -.85 then a, b = r.shade, r.deep else a, b = r.deep, r.edge end
        if (yy + s) % 4 == 0 then a = b end -- leaf notches
        px(s, yy, a) px(s + 1, yy, b)
        if yy <= top + sol then px(s + 2, yy, (yy - top) % 3 == 0 and b or r.deep) end
      end
      px(s, top + len + 1, r.shade) -- a tip leaf
      if hash(s, 8, seed) < .5 then px(s + 1, top + len + 1, r.deep) end
    end
    -- dome on top, with droop arcs, and a dark band under it so the curtain reads as hanging from it
    crown(x, floor(cy), floor(rx), floor(ry), r, seed, true)
    for k = -2, 2 do
      local sx = x + k * rx * .35
      for t = 0, floor(ry * .9) do
        local xx = floor(sx + (k >= 0 and 1 or -1) * t * .6 + .5)
        local yy = floor(cy - ry * .55 + t * 1.1 + (k * k) * .6)
        if dome:has(xx, yy) and dome:has(xx, yy + 1) then px(xx, yy, (k < 0 or (k == 0 and t < 3)) and r.base or r.shade) end
      end
    end
    for xx = x0, x1 + 2 do local u = (xx - x) / (rx * 1.08) local yy = floor(cy + ry * .55 * math.sqrt(math.max(0, 1 - u * u))) + 1
      if solid:has(xx, yy) and hash(xx, 9, seed) < .7 then px(xx, yy, r.shade) end end
    return sil
  end
  -- an alder: slim dark trunk, an upright oval crown in dark alder green, a few brown catkins / cones
  local function alder(x, yb, h, seed, r)
    r = r or L.foliage
    local wb = L.willowBark
    local t = poly{ { x - 2, yb }, { x + 2, yb }, { x + 1, floor(yb - h * .55) }, { x - 1, floor(yb - h * .55) } }
    rimOf(t, wb) part(t, wb, { nopop = true }) vline(x - 1, floor(yb - h * .5), yb - 1, wb.hi)
    local m = crown(x, floor(yb - h * .62), math.max(4, floor(h * .3)), math.max(4, floor(h * .38)), r, seed)
    if h >= 26 then crown(x - floor(h * .16), floor(yb - h * .45), floor(h * .14) + 2, floor(h * .13) + 2, r, seed + 5) end
    for k = 1, math.max(2, h // 10) do
      local cx, cy = floor(x + (hash(k, 1, seed) - .5) * h * .5), floor(yb - h * (.45 + .4 * hash(k, 2, seed)))
      if m:has(cx, cy) then px(cx, cy, L.cattail.shade) px(cx, cy + 1, L.cattail.deep) end
    end
    return m
  end
  -- a pollard willow: a squat fat trunk with a knuckled head and a fan of straight whippy shoots, leafy tips
  local function pollard(x, yb, h, seed, r)
    r = r or L.willow
    local wb = L.willowBark
    local th = floor(h * .42)
    local trunk = poly{ { x - 4, yb }, { x + 4, yb }, { x + 4, yb - th + 2 }, { x + 5, yb - th }, { x - 5, yb - th }, { x - 4, yb - th + 2 } }
    local shoots = HP.mask()
    local tips = {}
    for k = 0, 9 do
      local a = -math.pi / 2 + (k - 4.5) / 4.5 * 1.0 + (hash(k, 1, seed) - .5) * .2
      local len = h - th - 2 - floor(hash(k, 2, seed) * h * .25)
      local x0 = x - 4 + k
      local tx, ty = floor(x0 + cos(a) * len + .5), floor(yb - th + sin(a) * len + .5)
      shoots:add(line({ { x0, yb - th }, { tx, ty } }, 1))
      tips[#tips + 1] = { tx, ty, a }
    end
    rimOf(union(trunk, shoots), wb)
    part(trunk, wb, { nopop = true })
    trunk:each(function(xx, yy) if xx <= x - 3 then px(xx, yy, wb.hi) elseif hash(xx, yy // 3, seed) < .3 then px(xx, yy, wb.deep) end end)
    hline(x - 5, x + 5, yb - th, wb.hi) px(x + 4, yb - th + 1, wb.deep)
    shoots:each(function(xx, yy) px(xx, yy, xx < x and r.shade or r.deep) end)
    for i, t in ipairs(tips) do -- leafy sprays along the upper part of each shoot
      for s = 0, floor(h * .3) do
        local xx, yy = floor(t[1] - cos(t[3]) * s), floor(t[2] - sin(t[3]) * s)
        if s % 2 == 0 then
          local col = (xx < x) and (hash(i, s, seed) < .5 and r.hi or r.base) or (hash(i, s, seed) < .5 and r.base or r.shade)
          px(xx - 1, yy, col) px(xx + 1, yy, xx < x and r.base or r.deep)
        end
      end
      px(t[1], t[2] - 1, r.hi)
    end
    return trunk
  end
  -- F.tree: wetland default. seed%4: 0,2 = weeping willow, 1 = alder, 3 = pollard willow. far = hazed little carr tree.
  local function tree(x, yb, h, seed, far)
    if far then
      local tr = L.farTree
      fill(rect(x, yb - h // 3, x + 1, yb), tr.shade)
      local m = crown(x, floor(yb - h * .58), math.max(3, floor(h * .34)), math.max(3, floor(h * .32)), tr, seed)
      return m
    end
    local k = seed % 4
    if k == 3 then return pollard(x, yb, floor(h * .8), seed) end
    if k == 1 then return alder(x, yb, h, seed) end
    return willow(x, yb, h, seed)
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
  -- water (wetland): still, dark fen water mirroring the grey-gold sky. Far rows carry the pale sky reflection,
  -- near rows go dark; long thin horizontal sky streaks (not ripples), a few cream-gold glints, a dark lip under the bank.
  local SKYREF = "#c2bc9e" -- the sky's gold seen in dark water
  function F_water(m, r, o)
    o = o or {}
    local bb = { m:bbox() }
    m:each(function(x, y)
      local ytop = bb[2] or y
      local f = (y - ytop) / math.max(1, (bb[4] or y) - ytop)
      if o.dark then f = .45 + f * .55 end -- shaded water (under a deck or stilts): no sky band
      local h = f < .18 and r.hi or (f < .32 and SKYREF or (f < .7 and r.base or r.shade))
      if f >= .18 and f < .32 and hash(x // 4, y, 71) < .35 then h = r.hi end
      if f >= .32 and f < .7 and hash(x // 5, y, 71) < .2 then h = mix(SKYREF, r.base, .55) end
      px(x, y, h)
    end)
    local rows = o.step or 4
    m:each(function(x, y)
      if y % rows == 0 then
        local seg = (x + y * 5) // (9 + (y % 5) * 2)
        local v = hash(seg, y, 72)
        if v < .22 then px(x, y, mix(SKYREF, r.hi, .5))
        elseif v > .92 and m:has(x, y + 1) then px(x, y, r.deep) end
      end
      if hash(x, y, 73) < .004 then px(x, y, "#f2eac8") end
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
    if b.shingle then courses(roofM, top - rh, 3, 5, rr)
    else
      F_thatch(roofM, rr, top - rh, cx)
      -- wetland: a sedge ridge cap over the reed thatch, with a scalloped lower edge and cross-hazel (liggers)
      if not b.noRidge then
        local rc = b.ridge or L.roof2
        roofM:each(function(x, y)
          local d = y - (top - rh)
          local sc = 7 + ((x // 3) % 2)
          if d >= 0 and d < sc then
            local h = (d >= sc - 1) and rc.deep or ((x + y) % 4 == 0 and rc.hi or (x < cx and rc.base or rc.shade))
            if d == 1 and (x % 6 == 0) then h = L.timber.hi end
            px(x, y, h)
          end
        end)
      end
    end
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

  ---------------------------------------------------------------- BACKGROUND (wetland: soft grey-gold overcast, low misted sun, alder carr, mist banks)
  c:stripes(0, HZ, L.sky, { 3, 3, 3, 2, 2 })
  -- a pale low sun behind the overcast, upper left (the light source of every scene), with a gold halo
  if not o.noSun then
    local sx, sy = o.sunX or 92, o.sunY or 52
    fill(c:ellipse(sx, sy, 15, 13), "#ddd2ac") fill(c:ellipse(sx, sy, 12, 11), "#e6dab2") fill(c:ellipse(sx, sy, 9, 8), "#eee2b8") fill(c:ellipse(sx, sy, 6, 6), "#f6ecc6")
  end
  for _, cl in ipairs(o.clouds or { { 120, 44, 40 }, { 300, 30, 52 }, { 400, 66, 30 }, { 40, 80, 26 } }) do
    local x, y, w = cl[1], cl[2], cl[3]
    -- overcast: long low banks, flat bottoms, soft under-band
    local m = c:rrect(x - w // 4, y - 5, x + w + w // 4, y, 2):add(c:rrect(x + w // 6, y - 10, x + w * 3 // 4, y - 3, 4)):add(c:rrect(x + w // 2, y - 13, x + w * 3 // 4 + 6, y - 7, 3))
    fill(m, L.cloud.top)
    hline(x - w // 4 + 2, x + w + w // 4 - 2, y, L.cloud.under) hline(x - w // 4 + 6, x + w + w // 4 - 8, y - 1, L.cloud.under)
    m:each(function(xx, yy) if hash(xx // 3, yy, 9) < .08 and yy < y - 1 then px(xx, yy, L.sky[5]) end end)
  end
  local function fFar(x) return HZ - 16 + 6 * sin(x / 37) + 4 * sin(x / 13 + 1) end
  local function fMid(x) return HZ - 6 + 4 * sin(x / 29 + 2) + 3 * sin(x / 11) end
  -- wetland: a carr ridge, a row of low rounded alder / willow clumps along a line (domes 4-12 px across),
  -- lit on the upper left when colLit is given. Same signature as the forest spire ridge.
  local function ridge(f, col, colLit, seed, hmin, hmax)
    local x = -4
    while x < W + 4 do
      local hh = hmin + floor(hash(x, 1, seed) * (hmax - hmin))
      local yb = floor(f(x)) + 2
      local rw = math.max(2, floor(hh * .7))
      for yy = yb - hh, yb do
        local t = (yy - (yb - hh)) / math.max(1, hh)
        local half = floor(rw * math.sqrt(math.max(0, 1 - (1 - t) * (1 - t))) + .5)
        if yy == yb - hh then half = math.max(1, half - 1) end
        for xx = x - half, x + half do px(xx, yy, (colLit and xx < x - half // 3 and t < .6) and colLit or col) end
      end
      x = x + 4 + floor(hash(x, 2, seed) * 7)
    end
  end
  -- flat fen: the far line is low and long
  local function fFarW(x) return fFar(x) + 5 end
  c:terrain(fFarW, L.hillFar, HZ)
  ridge(fFarW, L.ridgeFar, nil, 21, 3, 9)
  -- mist banks lying on the far carr
  for y = HZ - 12, HZ - 6 do for x = 0, W - 1 do if hash(x // 11, y, 23) < .42 then px(x, y, (y % 3 == 0) and L.mist2 or L.mist) end end end
  if o.beforeMid then o.beforeMid() end
  setDepth(1)
  ridge(function(x) return fMid(x) + 2 end, L.ridgeMid, L.hillMidShade, 27, 3, 8)
  for i, tx in ipairs(o.farTrees or { 24, 52, 196, 290, 318, 352, 440 }) do tree(tx, floor(fMid(tx)) + 3, 20, i, true) end
  setDepth(0)
  local midM = c:terrain(function(x) return fMid(x) + 2 end, L.hillMid, HZ)
  midM:each(function(x, y) if (x + y * 3) % 23 == 0 then px(x, y, L.hillMidShade) end end)
  -- far open water: thin bright lagoon strips catching the sky, along the foot of the carr
  for y = HZ - 3, HZ do
    for x = 0, W - 1 do
      local v = vnoise(x / 26, y / 2, 29)
      if v > .6 then px(x, y, (v > .72 and y % 2 == 0) and "#e8deb8" or L.sky[4]) end
    end
  end
  -- mist lying in the back rows: long soft banks along the foot of the carr
  for y = HZ - 7, HZ - 2 do
    for x = 0, W - 1 do
      local v = hash(x // 16, y, 25)
      if v < .5 - (HZ - y) * .05 then px(x, y, (y % 2 == 0) and L.mist or L.mist2) end
    end
  end

  local groundCol = {}
  local SKYREF2 = "#bdb798" -- sky gold mirrored in the ground pools
  -- wetland: still pools in the sedge, from a second value noise (flattened by perspective). o.poolK = threshold
  -- (default .75, higher = fewer pools), o.noPools = no pools. F.poolAt(x, y) tells a script where they are.
  local POOLK = o.poolK or .75
  local function poolV(x, y)
    local d = y - HZ + 2
    local sy = 2 + d * .1
    return vnoise(x / (sy * 7), y / (sy * 2.6), 41)
  end
  local function poolAt(x, y)
    if o.noPools or y < HZ + 6 then return false end
    return poolV(x, y) > POOLK
  end
  local function groundAt(x, y)
    local d = y - HZ + 2
    local base
    local f = (y - HZ - 1) / (H - 1 - HZ)
    if f < 1 / 13 then base = L.groundFar elseif f < 3 / 13 then base = L.ground.hi else base = L.ground.base end
    -- wetland: low-frequency patches of green sedge and dark wet peat, flattened by perspective
    local sy = 2 + d * .1
    local nv = vnoise(x / (sy * 5), y / sy, 5) + (hash(x, y, 6) - .5) * .08
    if f >= 1 / 13 then
      if nv < .36 then base = f < 3 / 13 and L.sedgeGround.hi or L.sedgeGround.base
      elseif nv > .7 then base = f < 3 / 13 and L.ground.base or L.peat.base end
    end
    -- still pools: a dark lip under the far bank, the sky's gold in long streaks, a muddy margin all round
    if not o.noPools and y >= HZ + 6 then
      local pv = poolV(x, y)
      if pv > POOLK then
        local up1, up2 = poolAt(x, y - 1), poolAt(x, y - 2)
        if not up1 then return L.water.deep end
        if not up2 then return L.water.shade end
        if not poolAt(x, y + 1) then return L.peat.shade end
        local s = hash((x + y * 3) // (5 + d // 12), y, 43)
        if pv > POOLK + .05 and s < .32 then return SKYREF2 end
        if s > .93 then return L.water.hi end
        return pv > POOLK + .08 and L.water.shade or L.water.base
      elseif pv > POOLK - .025 then
        return (hash(x, y, 44) < .3) and L.peat.hi or L.peat.base
      end
    end
    local u = (x - VX) / d * 7
    if y < 168 and abs(u - floor(u + .5)) < .06 + 1.2 / d then return L.ground.shade end
    if hash(x, y, 1) < .02 + y / 9000 then return L.ground.shade end
    if hash(x, y + 1, 1) < .02 + (y + 1) / 9000 then return L.ground.hi end
    return base
  end
  -- wetland: the ground is painted per pixel by groundAt (so eraseGround matches it exactly, pools included)
  for y = HZ + 1, H - 1 do for x = 0, W - 1 do px(x, y, groundAt(x, y)) end end
  -- kept from the forest frame (sedge-tinted): fern and mushroom
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
  -- wetland small things ---------------------------------------------------------------
  -- a sedge tuft: a fan of blades from one root, lit blades on the left. s = height
  local function sedge(x, y, s, r)
    r = r or L.reedGreen
    local n = s >= 5 and 5 or 3
    for k = 1, n do
      local lean = (k - (n + 1) / 2) * (s >= 5 and .55 or .7)
      for t = 0, s - 1 - math.abs(k - (n + 1) / 2) do
        local xx = floor(x + lean * t / 2 + .5)
        local col = lean < 0 and r.hi or (lean == 0 and r.base or r.shade)
        if t == 0 then col = r.deep end
        px(xx, y - t, col)
      end
    end
  end
  -- a bulrush (cattail): green stem, brown sausage head with a lit left edge, a thin spike on top
  local function cattail(x, yb, h, big)
    vline(x, yb - h, yb, L.reedGreen.shade)
    local hh = big and 5 or 3
    local top = yb - h + 1
    fill(rect(x, top, x + (big and 1 or 0), top + hh), L.cattail.base)
    vline(x, top, top + hh, L.cattail.hi)
    if big then vline(x + 1, top + 1, top + hh, L.cattail.shade) px(x + 1, top + hh, L.cattail.deep) end
    px(x, top - 1, L.reedGreen.deep) px(x, top - 2, L.reedGreen.shade)
    -- a long blade beside it
    for t = 0, floor(h * .7) do px(x - 1 - floor(t / 5), yb - t, t > h * .5 and L.reedGreen.hi or L.reedGreen.base) end
  end
  -- a lily pad (notched oval), optional flower: white-pink cup or yellow
  local function lily(x, y, big, flower)
    local rx, ry = big and 4 or 2, big and 2 or 1
    local m = c:ellipse(x, y, rx, ry)
    m:cut(line({ { x, y }, { x + rx, y - 1 } }, 1))
    fill(m, L.lily.base)
    m:each(function(xx, yy) if not m:has(xx, yy - 1) and xx < x + 1 then px(xx, yy, L.lily.hi) elseif not m:has(xx, yy + 1) then px(xx, yy, L.lily.deep) end end)
    if flower then
      local fr = flower == "yellow" and L.marigold or L.awnB
      px(x - 1, y - 1, fr.hi) px(x, y - 1, fr.base) px(x - 1, y - 2, fr.base) px(x, y - 2, flower == "yellow" and fr.shade or L.petal.base)
      if big then px(x + 1, y - 1, fr.shade) px(x - 2, y - 1, fr.base) px(x, y - 3, L.petal.hi) end
    end
    return m
  end
  local function groundDetail(x0, x1, y0, y1, seed)
    for i = 1, 760 do
      local x = x0 + floor(hash(i, 1, seed) * (x1 - x0))
      local y = y0 + floor(hash(i, 2, seed) ^ .7 * (y1 - y0))
      local near = (y - HZ) / (H - HZ)
      local kind = hash(i, 3, seed)
      if hash(i, 4, seed) < near * 1.25 then
        if poolAt(x, y) then
          if poolAt(x - 3, y) and poolAt(x + 4, y) and poolAt(x, y - 2) and poolAt(x, y + 2) and kind < .5 then
            lily(x, y, near > .45, hash(i, 9, seed) < .25 and (hash(i, 10, seed) < .3 and "yellow" or "white") or nil)
          end
        elseif kind < .30 then
          local th = 2 + floor(near * 5 * hash(i, 5, seed))
          sedge(x, y, th + 1, hash(i, 7, seed) < .3 and L.reed or L.reedGreen)
        elseif kind < .44 then -- a little reed clump: 2-3 straight stems, plumes when near
          local th = 3 + floor(near * 9 * hash(i, 5, seed))
          for k = 0, (near > .4 and 2 or 1) do
            local hh = th - k * 2
            vline(x + k * 2 - 1, y - hh, y, k == 0 and L.reed.hi or (k == 1 and L.reed.base or L.reed.shade))
            if near > .35 then px(x + k * 2 - 1, y - hh - 1, L.plume.base) px(x + k * 2, y - hh, L.plume.shade) end
          end
        elseif kind < .58 then -- fallen reed straws
          local col = ({ L.reed.hi, L.reed.base, L.reed.shade, L.ground.deep })[1 + floor(hash(i, 6, seed) * 4)]
          local dir = hash(i, 8, seed) < .5 and 1 or -1
          px(x, y, col) px(x + dir, y, col) px(x + 2 * dir, y - 1, col)
          if near > .4 then px(x + 3 * dir, y - 1, col) px(x + 1, y + 1, L.reed.deep) end
        elseif kind < .66 then -- marsh marigold / cuckooflower / forget-me-not
          if near > .2 then
            local k2 = hash(i, 9, seed)
            local fr = k2 < .55 and L.marigold or (k2 < .8 and L.petal or L.accent)
            px(x, y, L.reedGreen.shade) px(x - 1, y, L.reedGreen.base)
            px(x, y - 1, fr.base) px(x - 1, y - 1, fr.hi)
            if near > .55 then px(x + 1, y - 1, fr.shade) px(x, y - 2, fr.hi) px(x + 1, y, L.reedGreen.deep) end
          end
        elseif kind < .73 then -- a peat clod / mud pock
          if near > .3 then local r = L.peat
            px(x, y - 1, r.hi) px(x + 1, y - 1, r.base) px(x, y, r.shade) px(x + 1, y, r.deep) px(x - 1, y, r.base)
            if near > .6 then px(x + 2, y, r.shade) px(x - 1, y - 1, r.hi) end
          end
        elseif kind < .82 then -- sphagnum / moss cushion (green with a rusty heart)
          local mr = L.moss
          px(x, y, mr.base) px(x + 1, y, mr.shade) px(x - 1, y, mr.hi) px(x, y - 1, mr.hi)
          if near > .5 then px(x + 2, y, mr.shade) px(x - 2, y + 1, mr.base) px(x + 1, y + 1, mr.deep) px(x + 1, y - 1, L.needle.base) end
        elseif kind < .9 then
          if near > .4 then cattail(x, y, 6 + floor(near * 10), near > .7) end
        else -- a mossy stone half sunk in mud
          px(x, y, L.stone.base) px(x + 1, y, L.stone.shade) px(x, y - 1, L.moss.base) px(x - 1, y + 1, L.peat.shade)
          if near > .5 then px(x + 2, y, L.stone.deep) px(x + 1, y - 1, L.stone.hi) end
        end
      end
    end
  end
  groundDetail(0, W - 1, HZ + 8, H - 1, 401)
  -- wetland: a misted reed-bed horizon with alder / willow clumps (plane 1, hazed). Skips the road end;
  -- o.noTreeLine turns it off, o.treeLineGap = { x0, x1 } changes the gap (default 220..260).
  if not o.noTreeLine then
    local g0, g1 = (o.treeLineGap or { 220, 260 })[1], (o.treeLineGap or { 220, 260 })[2]
    setDepth(1)
    local x, i = 6, 0
    while x < W - 2 do
      i = i + 1
      if x < g0 - 6 or x > g1 + 6 then
        local hh = 14 + floor(hash(x, 3, 31) * 12)
        local yb = HZ + 4 + floor(hash(x, 4, 31) * 2)
        if hash(x, 7, 31) < .45 then alder(x, yb, hh, 300 + i, hash(x, 5, 31) < .5 and L.foliage or L.farTree)
        else willow(x, yb, hh, 300 + i, L.willow) end
      end
      x = x + 22 + floor(hash(x, 6, 31) * 30)
    end
    -- the reed bed in front: a dense fringe of stems, plumes on top, darker roots
    for xx = 0, W - 1 do
      if xx < g0 or xx > g1 then
        local yb = HZ + 5 + floor(hash(xx // 5, 8, 31) * 2)
        local hh = 3 + floor(vnoise(xx / 7, 1, 33) * 6 + hash(xx, 9, 31) * 3)
        for yy = yb - hh, yb do
          local col
          if yy >= yb - 1 then col = L.reed.deep
          elseif (xx % 2 == 0) then col = (yy < yb - hh + 2) and L.reed.hi or L.reed.base
          else col = L.reed.shade end
          px(xx, yy, col)
        end
        if hash(xx, 10, 31) < .3 then px(xx, yb - hh - 1, L.plume.base) px(xx + 1, yb - hh, L.plume.shade) end
      end
    end
    -- mist banks drifting through the reeds
    for yy = HZ + 1, HZ + 3 do for xx = 0, W - 1 do
      if (xx < g0 or xx > g1) and hash(xx // 13, yy, 34) < .3 then px(xx, yy, yy % 2 == 0 and L.mist or L.mist2) end
    end end
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
      -- wetland: peat silt and moss in the slab seams, damp dark slabs here and there, a few puddles
      if h == L.road.deep then
        local v = hash(x, y, 24)
        if v < .2 then h = L.moss.shade elseif v < .34 then h = L.peat.shade end
      elseif hash(r1, u1, 26) < .3 and hash(x, y, 27) < .12 then h = L.moss.base
      elseif hash(r1, u1, 28) < .07 then h = (hash(x, y, 29) < .5) and L.water.hi or L.road.shade end
      px(x, y, h)
    end)
    -- wetland: the causeway is raised. A stone flank face on each side (1-3 px, wider nearer), a wet peat line at
    -- its foot, and a narrow ditch of dark water beside it nearer the viewer, with timber stakes now and then.
    for y = yTop, math.min(H - 1, yBot) do
      local t = (y - yTop) / math.max(1, H - 1 - yTop)
      local fw = 1 + floor(t * 2.6)
      local dw = floor(t * 3.2)
      local xa, xb = floor(xl(y)), floor(xr(y) + .99)
      px(xa, y, L.road.edge) px(xb, y, L.road.edge)
      for k = 1, fw do
        local face = (y % 4 == 0) and L.stone.deep or (k == 1 and L.stone.shade or L.stone.base)
        px(xa - k, y, face)
        px(xb + k, y, (y % 4 == 0) and L.stone.deep or L.stone.shade)
      end
      px(xa - fw - 1, y, L.peat.deep) px(xb + fw + 1, y, L.peat.deep)
      for k = 1, dw do
        local wcol = (hash(y, k, 35) < .2) and SKYREF2 or (k == 1 and L.water.deep or L.water.shade)
        px(xa - fw - 1 - k, y, wcol) px(xb + fw + 1 + k, y, wcol)
      end
      if dw > 0 then px(xa - fw - 2 - dw, y, L.peat.shade) px(xb + fw + 2 + dw, y, L.peat.shade) end
      if y % 23 == 5 and t > .15 then -- revetment stakes
        for _, sx in ipairs({ xa - fw - 1, xb + fw + 1 }) do
          vline(sx, y - 3 - floor(t * 3), y, L.timber.base) px(sx, y - 3 - floor(t * 3), L.timber.hi)
        end
      end
    end
    return m
  end
  if not o.noRoad then drawRoad(ROAD_TOP, H - 1) end

  ---------------------------------------------------------------- gate frame (drawn in finish)
  local function gate()
    local G = L.stone
    -- wetland: willow fronds draped over the beam (clumped, lit shading), long leafy strands trailing from their
    -- undersides, and a tied reed bundle with cattails at each corner
    local boughs = { { 56, 19, 34, 10, L.willow, 91 }, { 110, 16, 22, 7, L.foliage2, 92 }, { 428, 19, 34, 10, L.foliage2, 93 }, { 378, 16, 20, 7, L.willow, 94 } }
    for _, b in ipairs(boughs) do
      local m = crown(b[1], b[2], b[3], b[4], b[5], b[6])
      local r = b[5]
      m:each(function(x, y)
        if not m:has(x, y + 1) and y > 12 and hash(x, y, b[6]) < .75 and x % 3 == 0 then
          local len = 4 + floor(hash(x, 1, b[6]) * hash(x, 2, b[6]) * 26)
          local lit = (x - b[1]) < 0
          for k = 1, len do
            local yy = y + k
            local a1 = lit and (yy % 4 == 0 and r.base or r.hi) or (yy % 4 == 0 and r.shade or r.base)
            local a2 = lit and r.base or r.deep
            if k == len then a1, a2 = r.shade, r.deep end
            px(x, yy, a1) px(x + 1, yy, a2)
            if yy % 5 == 0 and k < len - 1 then px(x + (lit and -1 or 2), yy, lit and r.base or r.shade) end
          end
        elseif (x + y * 2) % 5 == 0 and hash(x, y, b[6] + 1) < .5 then px(x, y, (x - b[1]) < 0 and r.hi or r.shade) end
      end)
    end
    local function sheaves() for _, bx in ipairs({ 22, W - 23 }) do -- reed sheaves bound to the brace corners
      local sh = poly{ { bx - 4, 13 }, { bx + 4, 13 }, { bx + 2, 30 }, { bx - 2, 30 } }
      c:rim(sh, L.reed.edge) fill(sh, L.reed.base)
      sh:each(function(x, y) if x % 2 == 0 then px(x, y, x < bx and L.reed.hi or L.reed.shade) end end)
      hline(bx - 3, bx + 3, 20, L.timber.deep) hline(bx - 3, bx + 3, 21, L.timber.base)
      for k = -1, 1 do local cx = bx + k * 2 fill(rect(cx, 31, cx, 33 + (k + 1) % 2), L.plume.base) px(cx, 31, L.plume.hi) px(cx, 34 + (k + 1) % 2, L.plume.deep) end
    end end
    flatCrown = true
    local beam = rect(0, 0, W - 1, 12)
    local postL, postR = rect(0, 0, 15, 222), rect(W - 16, 0, W - 1, 222)
    local plL, plR = rect(0, 218, 18, 228), rect(W - 19, 218, W - 1, 228)
    local brL = poly{ { 16, 13 }, { 34, 13 }, { 16, 31 } }
    local brR = poly{ { W - 17, 13 }, { W - 35, 13 }, { W - 17, 31 } }
    rimOf(union(beam, postL, postR, plL, plR, brL, brR), L.timber)
    part(postL, G) part(postR, G)
    courses(union(postL, postR), 0, 9, 16, G)
    -- forest: moss cushions on the top of the stone courses, thicker low down and on the shaded inner faces
    union(postL, postR):each(function(x, y)
      local ry = y % 9
      local wet = y / 222
      if ry == 1 and hash(x // 2, y // 9, 97) < .25 + wet * .35 then px(x, y, hash(x, y, 98) < .4 and L.moss.hi or L.moss.base)
      elseif ry == 2 and hash(x // 2, y // 9, 97) < .12 + wet * .3 then px(x, y, L.moss.shade) end
    end)
    part(plL, G, { sep = true }) part(plR, G, { sep = true }) hline(0, 18, 218, G.hi) hline(W - 19, W - 1, 218, G.hi)
    for x = 0, W - 1 do if (x < 19 or x > W - 20) and hash(x, 219, 96) < .5 then px(x, 219, L.moss.base) end end
    part(brL, L.timber, { nopop = true }) part(brR, L.timber, { nopop = true })
    sheaves()
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
    -- forest additions
    conifer = conifer, pine = pine, birch = birch, fern = fern, mushroom = mushroom, logs = F_logs, logEnd = logEnd, moss = moss,
    ridge = ridge,
    -- wetland additions
    willow = willow, alder = alder, pollard = pollard, sedge = sedge, cattail = cattail, lily = lily, poolAt = poolAt,
    SKYREF = SKYREF,
  }

  ---------------------------------------------------------------- wetland furniture
  -- a reed bed between x0..x1 standing on yb: dense stems h tall (taller in the middle), lit stems on the left
  -- half, dark roots, mauve plumes on top, bulrushes when o.cattails. o.green = more green blades (young reed).
  -- Returns the mask.
  function F.reeds(x0, x1, yb, h, seed, ro)
    ro = ro or {}
    seed = seed or 1
    local m = HP.mask()
    local cx = (x0 + x1) / 2
    local half = math.max(1, (x1 - x0) / 2)
    local stems = {}
    for x = x0, x1 do
      local u = (x - cx) / half
      local hh = floor(h * (.55 + .45 * (1 - u * u)) * (.75 + .35 * hash(x, 1, seed)))
      local lean = (hash(x, 2, seed) - .5) * .25
      stems[#stems + 1] = { x, hh, lean }
      for t = 0, hh do m:set(floor(x + lean * t + .5), yb - t) end
    end
    newObj()
    for _, s in ipairs(stems) do
      local x, hh, lean = s[1], s[2], s[3]
      local green = ro.green and hash(x, 3, seed) < .5
      local r = green and L.reedGreen or L.reed
      local lit = x < cx and hash(x, 4, seed) < .7
      for t = 0, hh do
        local xx, yy = floor(x + lean * t + .5), yb - t
        local col
        if t <= 1 then col = r.deep elseif t < hh * .25 then col = r.shade
        elseif lit then col = (t % 5 == 0) and r.base or r.hi
        else col = (x % 3 == 0) and r.shade or r.base end
        if t > 2 and t % 6 == 3 then col = r.deep end -- nodes
        px(xx, yy, col)
      end
      local tx, ty = floor(x + lean * hh + .5), yb - hh
      if not green and hash(x, 5, seed) < .45 then -- plume
        px(tx, ty - 1, L.plume.hi) px(tx + 1, ty, L.plume.base) px(tx, ty, L.plume.base) px(tx + 1, ty + 1, L.plume.shade)
        if h > 18 then px(tx + 1, ty - 1, L.plume.base) px(tx + 2, ty + 1, L.plume.shade) px(tx - 1, ty, L.plume.hi) end
      elseif green and h > 10 and hash(x, 6, seed) < .4 then -- a bent blade
        for k = 1, 3 do px(tx + k, ty + k, L.reedGreen.shade) end
      end
    end
    if ro.cattails then
      for k = 1, ro.cattails do
        local x = floor(x0 + hash(k, 7, seed) * (x1 - x0))
        cattail(x, yb, floor(h * (.7 + .3 * hash(k, 8, seed))), h > 16)
      end
    end
    return m
  end
  -- a dragonfly: needle body, two pairs of glassy wings, a bright eye. r = body ramp (default accent blue-green)
  function F.dragonfly(x, y, r, flip)
    r = r or L.accent
    local s = flip and -1 or 1
    for k = 0, 6 do px(x - k * s, y, k < 2 and r.hi or (k % 2 == 0 and r.base or r.shade)) end
    px(x + s, y, r.deep)
    local wing = "#e4e2d0"
    for k = 1, 3 do px(x - s, y - k, wing) px(x - 2 * s, y - k, k == 3 and "#c8c8b8" or wing) px(x - s, y + k, "#c8c8b8") px(x - 2 * s, y + k, wing) end
  end
  -- a little green frog sitting, facing left or right (flip), on (x, y) = feet
  function F.frog(x, y, flip, r)
    r = r or L.leaf
    local rows = { "..eb.eb.", ".bbbbbbb", "bhbbbbsb", "bbbbsssy", ".ff..ff." }
    if flip then for i, row in ipairs(rows) do rows[i] = row:reverse() end end
    return F.sprite(rows, x - 4, y - 4, { e = L.gold.base, b = r.base, h = r.hi, s = r.shade, y = L.marigold.hi, f = r.deep })
  end
  -- a grey heron standing (or with o.wade, wading), 30 px tall, facing left (flip = right). (x, yb) = feet.
  function F.heron(x, yb, flip)
    local rows = {
      ".....KKKKKk......",
      "....WWWWWWkKK....",
      "...WWeKKWWW......",
      "YYYYYYWWWW.......",
      "......WWWW.......",
      "......WkWW.......",
      ".......WkW.......",
      ".......WkWw......",
      ".......WWkw......",
      "......WWkww......",
      "......WWWwGG.....",
      ".....WWwGGGGGG...",
      ".....WwGGGGGGGGG.",
      ".....wGGgGGGGGGGG",
      ".....wGGGgGGGGKKK",
      "......GGGGGgGKKKK",
      ".......GGGGGKKK..",
      "........GGGgg....",
      ".........ggg.....",
      ".........Y.Y.....",
      ".........Y.Y.....",
      ".........Y.Y.....",
      ".........Y..Y....",
      ".........Y..Y....",
      ".........Y..Y....",
      "........YY.YY....",
    }
    if flip then for i, row in ipairs(rows) do rows[i] = row:reverse() end end
    local hr = L.heron
    return F.sprite(rows, x - 9, yb - #rows + 1, { W = hr.hi, w = hr.base, G = hr.shade, g = hr.deep, k = hr.deep, K = L.timber.edge,
      e = L.gold.base, Y = L.marigold.shade })
  end
  -- a greylag goose, swimming (o.swim) or standing. flip = facing right. (x, yb) = belly / feet
  function F.goose(x, yb, flip, swim)
    local rows = {
      "........ob.",
      ".......bbbO",
      ".......bk..",
      "......bb...",
      "......bg...",
      ".gGGGGbg...",
      "gGGhhhhGG..",
      "GGGhhhGGGG.",
      ".GGGGGGGGg.",
      "..ggggggg..",
    }
    if not swim then rows[#rows + 1] = "....O.O...." rows[#rows + 1] = "...OO.OO..." end
    if not flip then for i, row in ipairs(rows) do rows[i] = row:reverse() end end
    local hr = L.goose
    local m = F.sprite(rows, x - 5, yb - #rows + 1, { b = hr.shade, G = hr.base, g = hr.deep, h = hr.hi, k = L.timber.edge, o = L.produce.base, O = L.produce.shade })
    if swim then for xx = x - 7, x + 7 do if hash(xx, yb, 77) < .7 then px(xx, yb + 1, (xx < x) and L.water.hi or SKYREF) end end end
    return m
  end
  -- a flat-bottomed punt: long low hull with square ends, from x0 to x1, waterline yw. A pole leaning on it when o.pole.
  function F.punt(x0, x1, yw, r, po)
    r = r or L.timber
    po = po or {}
    local hull = poly{ { x0, yw - 4 }, { x1, yw - 4 }, { x1 - 3, yw }, { x0 + 3, yw } }
    local inner = rect(x0 + 2, yw - 4, x1 - 2, yw - 3)
    c:rim(hull, r.edge)
    part(hull, r, { nopop = true })
    hline(x0, x1, yw - 4, r.hi) hline(x0 + 2, x1 - 2, yw - 2, r.deep)
    fill(inner, L.board.shade) hline(x0 + 2, x1 - 2, yw - 4, L.board.base)
    for xx = x0 + 6, x1 - 6, 7 do px(xx, yw - 4, r.deep) end -- thwarts
    for xx = x0 + 3, x1 - 3 do if hash(xx, yw, 78) < .6 then px(xx, yw + 1, xx % 3 == 0 and L.water.hi or L.water.deep) end end -- reflection
    if po.pole then line({ { po.pole[1], po.pole[2] }, { po.pole[3], po.pole[4] } }):each(function(xx, yy) px(xx, yy, L.board.base) end) end
    return hull
  end
  -- stilts: posts from yTop down to yb (into water / mud) at xs; wet dark lower part below wl, a ring at the waterline
  function F.stilts(xs, yTop, yb, wl, r, w)
    r = r or L.timber
    w = w or 2
    local m = HP.mask()
    for _, x in ipairs(xs) do m:add(rect(x, yTop, x + w - 1, yb)) end
    rimOf(m, r)
    m:each(function(x, y)
      local h = (y >= (wl or yb)) and r.deep or ((x == floor(x) and not m:has(x - 1, y)) and r.hi or r.base)
      if y < (wl or yb) and y >= (wl or yb) - 3 then h = L.moss.shade end
      px(x, y, h)
    end)
    if wl then for _, x in ipairs(xs) do hline(x - 2, x + w + 1, wl, L.water.hi) end end
    return m
  end
  -- a boardwalk deck in silver-weathered planks across the mask (vertical = boards run up/down), moss at the seams
  function F.boardwalk(m, vertical, seed)
    rimOf(m, L.board)
    part(m, L.board, { nopop = true })
    F_planks(m, L.board, 4, vertical, seed or 3)
    moss(m, .05, (seed or 3) + 1)
    return m
  end
  -- a mist bank: long ragged horizontal streaks in mist colours over whatever is below, x0..x1, rows y0..y1
  function F.mist(x0, x1, y0, y1, seed, k)
    k = k or .45
    for y = y0, y1 do for x = x0, x1 do
      local edge = math.min(x - x0, x1 - x) / math.max(1, (x1 - x0) * .2)
      if hash(x // 9, y, seed or 5) < k * math.min(1, edge) then px(x, y, (y % 2 == 0) and L.mist or L.mist2) end
    end end
  end

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
    local cols = { "#ada898", "#c0baa8", "#d2cbb6", "#e2dac4" } -- wetland: warm grey peat smoke
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
    m:each(function(x, y) if not m:has(x - 1, y) or not m:has(x, y - 1) then local v = c:get(x, y) if v then rawput(c, x, y, mix(v, "#f4eec4", k or .4)) end end end)
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
      if v then local _, _, l = toHsl(v) if l < .86 then rawput(c, x, y, mix(v, "#f2ecc0", .32)) end end
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
