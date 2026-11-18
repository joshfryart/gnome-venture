-- _frame.lua : MOUNTAIN gate-view frame for the stop-type looks, palette "mountain_granite".
-- A copy of art-forest-stops/_frame.lua (itself a copy of the Maplewold art-2701-batch3/stops/opus3/_frame.lua)
-- with the same API and composition compass (horizon y=112, slab road, gate, bunting, lanterns, compass corner,
-- depth planes, rim light), re-skinned for the high mountains: pale cold sky with thin cloud banks and a small
-- crisp sun, two ranges of snow-capped granite peaks behind slate foothills, a sparse spruce / larch tree line
-- with boulders, alpine meadow ground (short blue-green / olive turf, scree patches, far snow patches, edelweiss,
-- gentian, arnica, scree pebbles, juniper), lichen on the granite slabs and gate posts, arolla boughs on the gate.
-- F.tree draws spruce / larch / arolla pine. All forest helpers are kept (F.conifer, F.pine, F.birch, F.fern,
-- F.mushroom, F.logs, F.logEnd, F.moss, F.ridge). New: F.larch, F.snow, F.lichen, F.boulder, F.juniper,
-- F.edelweiss, F.gentian, F.goat, F.marmot, F.range (extra peaks).
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
  -- mountain_granite: same keys as Maplewold / forest so type scripts keep working; the MEANING of a few keys shifts:
  -- roof = granite slab / slate roof (blue-grey), roof2 = larch shingle (red-brown), plaster = whitewashed stone,
  -- foliage = larch (light yellow-green), foliage2 = blue-green spruce, timber = sun-browned larch (chalet wood),
  -- accent = gentian blue, moss = grey-green / olive lichen, needle = dry alpine straw, fern = alpine grass blades,
  -- mossGround = lush meadow patch, duff = scree gravel, water = milky glacial turquoise.
  local L = {
    sky = { "#8eaccb", "#a2bbd5", "#b6c9dd", "#c8d6e4", "#d8e2ea" },
    cloud = { top = "#eef1f0", under = "#c6d2de" },
    hillFar = "#8a9cae", hillMid = "#7d9584", hillMidShade = "#6a8272",
    ridgeFar = "#728698", ridgeMid = "#4c6862", mist = "#cfd9e2", mist2 = "#dde5eb",
    peakFar = rp("#bccadb #9caec4 #8698b2 #72829e #606c88"),
    peak = rp("#b8c0ca #98a2ae #7a8592 #5e6876 #444c5c"),
    snow = rp("#f4f6f4 #e3eaef #c8d3e1 #a8b6ca #7c8ca6"),
    farTree = rp("#a0b6b4 #7c9a98 #607e7e #4a646c #38505e"),
    ground = rp("#bec68c #9aa86c #788858 #586848 #3a4836"), groundFar = "#aab894",
    road = rp("#d4d8da #b0b6ba #8c9398 #6a7078 #484e58"), slabRatio = 1.06, slabK = 15,
    stone = rp("#d6dadc #aeb4ba #8a9199 #666d78 #444a56"),
    plaster = rp("#eeeee4 #d8d9d0 #b6b9b4 #8e9394 #5c6268"),
    wall2 = rp("#c6d6e4 #9eb4ca #7a92aa #5c728a #3e4e64"),
    timber = rp("#b88e66 #8e6848 #6a4c36 #4a3428 #2e2020"),
    roof = rp("#aab4be #87939f #687482 #4e5866 #343c4a"),
    roof2 = rp("#cc946a #a26c48 #7e5038 #5a382c #3a2220"),
    awnA = rp("#f08a78 #d6524a #aa3a3e #7a2a38 #4a1a28"),
    awnB = rp("#f4f0dc #e2dec6 #c2bea6 #989686 #5e5c56"),
    accent = rp("#90b2ea #5880cc #3e5ea6 #2e447c #1e2c54"),
    foliage = rp("#c4ce7c #96ac56 #6e8846 #4e643c #30402c"),
    foliage2 = rp("#7ca698 #4c7e72 #345e58 #254446 #172c34"),
    leaf = rp("#bcd282 #8eb25c #668c48 #486a40 #2c4632"),
    water = rp("#dcf2f0 #a2dcdc #66b6c4 #4688a2 #2c5876"),
    glow = rp("#fff6c0 #ffd870 #f6aa42 #d27a30 #8a4a24"),
    soil = rp("#a48a70 #806a54 #625040 #463a30 #2c2420"),
    board = rp("#e8d0a0 #caa878 #a6845a #7c6048 #4e3e32"),
    produce = rp("#ffb04a #f07c22 #c85a1e #943e1c #5e2618"),
    lav = rp("#d0c4ec #a28ad4 #7862b0 #554484 #362a58"),
    iron = rp("#b0b4b8 #7c8288 #5a6068 #3e444e #262c36"),
    skin = rp("#ffe0bd #f0b98d #c98462 #7a4036 #4a2620"),
    apple = rp("#ff8a6c #e23c3a #b02436 #741c30 #4a1222"),
    petal = rp("#f8c4cc #ec8c9c #c86478 #94485e #5e2c40"),
    gold = rp("#f6e08a #e2be52 #b8923a #86662c #563f22"),
    -- forest keys kept (mountain meaning)
    moss = rp("#d0d48e #a8b064 #80894c #5c683e #3c482e"),
    birch = rp("#f0ecdc #d8d4c4 #ada99c #7c7a72 #4a4a46"),
    birchLeaf = rp("#e6e490 #c4cc62 #98aa48 #6c823c #46582e"),
    redbark = rp("#d88e62 #ae6440 #864836 #5e302a #3a1c1e"),
    needle = rp("#dcc88e #b89e62 #8e7848 #665638 #42382a"),
    fern = rp("#aec884 #80a45c #5c8048 #3e5e3c #283e30"),
    mossGround = rp("#a8c088 #88a66c #6a8858 #4e6848 #344636"), duff = "#a6a8a2",
    -- mountain-only ramps
    gentian = rp("#8eaef6 #4c6edc #3448b2 #283684 #1a2458"),
    edel = rp("#f2f2e8 #dcdfd4 #b8bdb0 #8e9488 #5e6460"),
    juniper = rp("#82a28e #5a7e6c #406254 #2e4642 #1e3032"),
    goat = rp("#f0eee2 #dad6c4 #b6b09e #8a8476 #5a564e"),
    chamois = rp("#cc9e6e #a27850 #7c583e #563c2e #362420"),
    cheese = rp("#f8e8a4 #eeca6a #ca9c46 #966e30 #5e4222"),
    lichenOrange = "#d6944e",
    shadow = "#6c7c70", shadowRoad = "#7c8590",
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
  local HAZE = "#d6e0e8" -- mountain: thin cold blue air

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
  -- a larch: slim, light yellow-green, ragged see-through tiers (sky / background shows through gaps)
  local function larch(x, yb, h, seed, o)
    o = o or {}
    local m = conifer(x, yb, h, o.r or L.foliage, seed, { slim = true, bark = L.redbark, far = o.far })
    if not o.far then
      local top = yb - h
      m:each(function(xx, yy)
        local f = (yy - top) / h
        if f > .15 and hash(xx // 2, yy, seed + 5) < .1 and abs(xx - x) > 1 then px(xx, yy, (o.r or L.foliage).deep) end
        if f > .1 and xx < x and hash(xx, yy, seed + 6) < .07 then px(xx, yy, shift((o.r or L.foliage).hi, .3, 1)) end
      end)
    end
    return m
  end
  -- F.tree: mountain default. seed%4: 0,2 = blue-green spruce, 1 = larch, 3 = arolla (stone) pine with a dark
  -- clumped crown on a red-brown trunk. far = hazed little conifer.
  local function tree(x, yb, h, seed, far)
    if far then return conifer(x, yb, h, L.farTree, seed, { far = true, slim = true }) end
    local k = seed % 4
    if k == 3 then return pine(x, yb, h, L.foliage2, seed) end
    if k == 1 then return larch(x, yb, h, seed) end
    return conifer(x, yb, h, L.foliage2, seed)
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

  -- mountain: snow lying on the upper faces of a mask (k = coverage 0..1): a cap on every top pixel run,
  -- thicker toward the upper left, lit snow above, cold blue shade on its lower lip
  local function snow(m, k, seed)
    m:each(function(x, y)
      if not m:has(x, y - 1) and hash(x // 3, y // 3, seed or 88) < k * 1.6 then
        local d = 1 + floor(hash(x, y, (seed or 88) + 1) * 2.4)
        for j = 0, d - 1 do if m:has(x, y + j) then px(x, y + j, j == 0 and L.snow.hi or (j == d - 1 and L.snow.shade or L.snow.base)) end end
      elseif hash(x, y, (seed or 88) + 2) < k * .05 then px(x, y, L.snow.base) end
    end)
  end
  -- mountain: lichen rosettes on stone (k = coverage): grey-green / olive blotches with a few orange map-lichen dots
  local function lichen(m, k, seed)
    seed = seed or 86
    m:each(function(x, y)
      local v = vnoise(x / 3, y / 3, seed)
      if v > 1 - k * .9 then
        local w = hash(x, y, seed + 1)
        px(x, y, w < .3 and L.moss.hi or (w < .75 and L.moss.base or L.moss.shade))
      elseif hash(x, y, seed + 2) < k * .06 then px(x, y, L.lichenOrange) end
    end)
  end
  -- a granite boulder: faceted, lit upper-left face, a dark crack, lichen; w/h = half width / height
  local function boulder(x, yb, w, h, seed, r)
    r = r or L.stone
    seed = seed or 1
    local j = function(k) return floor((hash(k, seed, 77) - .5) * 3) end
    local m = poly{ { x - w, yb }, { x - w + 1 + j(1), yb - h * .6 }, { x - w // 3 + j(2), yb - h }, { x + w // 3 + j(3), yb - h + 1 },
      { x + w, yb - h * .45 + j(4) }, { x + w, yb } }
    c:rim(m, r.edge) part(m, r)
    m:each(function(xx, yy)
      local u = (xx - x) / math.max(1, w) + (yy - (yb - h)) / math.max(1, h) * .8
      if u < -.35 and yy < yb - 1 then px(xx, yy, r.hi) elseif u > 1.05 then px(xx, yy, r.shade) end
    end)
    if w >= 4 then line({ { x + j(5), yb - h + 2 }, { x + 1 + j(6), yb - 1 } }):each(function(xx, yy) if m:has(xx, yy) and hash(xx, yy, seed) < .7 then px(xx, yy, r.deep) end end) end
    lichen(m, .3, seed + 40)
    return m
  end
  -- a juniper clump: low, spreading, dark blue-green, a few frosty blue berries
  local function juniper(x, yb, w, h, seed)
    local m = crown(x, yb - h // 2, w, math.max(2, h // 2 + 1), L.juniper, seed or 9)
    for k = 1, math.max(1, w // 3) do
      local bx, by = x + floor((hash(k, 1, seed or 9) - .5) * w * 1.4), yb - floor(hash(k, 2, seed or 9) * h)
      if m:has(bx, by) then px(bx, by, "#8c9cc8") end
    end
    return m
  end
  -- edelweiss: a woolly star (big) or a 2-pixel dot (small)
  local function edelweiss(x, y, big)
    if big then
      px(x, y + 2, L.fern.shade) px(x, y + 1, L.fern.shade)
      px(x, y - 1, L.edel.hi) px(x - 1, y, L.edel.hi) px(x + 1, y, L.edel.base) px(x, y + 1, L.edel.shade) px(x - 1, y - 1, L.edel.base)
      px(x + 1, y - 1, L.edel.base) px(x - 1, y + 1, L.edel.shade) px(x + 1, y + 1, L.edel.deep) px(x, y, L.gold.base)
    else px(x, y, L.edel.hi) px(x + 1, y, L.edel.shade) px(x, y + 1, L.fern.shade) end
  end
  -- gentian: a deep-blue trumpet on a rosette of leaves (big) or a 2-pixel dot (small)
  local function gentian(x, y, big)
    if big then
      px(x - 1, y + 2, L.fern.base) px(x + 1, y + 2, L.fern.shade) px(x, y + 2, L.fern.deep)
      px(x, y + 1, L.gentian.deep) px(x - 1, y, L.gentian.base) px(x, y, L.gentian.shade) px(x + 1, y, L.gentian.deep)
      px(x - 1, y - 1, L.gentian.hi) px(x + 1, y - 1, L.gentian.base) px(x, y - 1, L.gentian.edge)
    else px(x, y, L.gentian.base) px(x, y - 1, L.gentian.hi) end
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

  ---------------------------------------------------------------- BACKGROUND (mountain: pale cold sky, thin cloud banks, snowy granite ranges)
  c:stripes(0, HZ, L.sky, { 3, 3, 3, 2, 2 })
  -- a small crisp sun, upper left (the light source of every scene)
  if not o.noSun then
    local sx, sy = o.sunX or 86, o.sunY or 48
    fill(c:ellipse(sx, sy, 9, 9), "#dce5ec") fill(c:ellipse(sx, sy, 7, 7), "#e8eee9") fill(c:ellipse(sx, sy, 5, 5), "#f6f4e2")
    px(sx - 2, sy - 2, "#fbf8ea") px(sx - 1, sy - 2, "#fbf8ea")
  end
  -- thin cloud banks: long flat lenses, 2-4 px tall, a cold blue underline
  local function cloudBank(x, y, w)
    local m = c:rrect(x, y - 2, x + w, y, 1):add(c:rrect(x + w // 5, y - 4, x + w * 3 // 5, y - 2, 1))
    fill(m, L.cloud.top)
    hline(x + 2, x + w - 2, y, L.cloud.under)
    m:each(function(xx, yy) if yy < y and hash(xx // 4, yy, 9) < .1 then px(xx, yy, L.sky[5]) end end)
    hline(x + w // 5 + 2, x + w // 5 + 6, y - 4, "#f6f6f0")
    return m
  end
  for _, cl in ipairs(o.clouds or { { 100, 26, 64 }, { 280, 16, 80 }, { 392, 40, 52 }, { 12, 52, 40 }, { 196, 44, 30 } }) do cloudBank(cl[1], cl[2], cl[3]) end

  -- F.range(peaks, r, snowR, o): a mountain range. peaks = { {x, topY, slope[, snowDepth]}, ... }; each column takes
  -- the highest peak flank. Left flanks are lit, right flanks in shade; diagonal strata; a snow cap down to
  -- snowDepth below each summit (ragged), snow tongues down the gullies; o.yb = bottom (default HZ), o.seed,
  -- o.haze (0..1 mix toward the sky). Returns the mask and a function y(x) of its skyline.
  local function range(peaks, r, sr, ro)
    ro = ro or {}
    local seed, yb, hz = ro.seed or 1, ro.yb or HZ, ro.haze or 0
    local function hz1(h) return hz > 0 and mix(h, L.sky[4], hz) or h end
    local R = { hi = hz1(r.hi), base = hz1(r.base), shade = hz1(r.shade), deep = hz1(r.deep), edge = hz1(r.edge) }
    local S = { hi = hz1(sr.hi), base = hz1(sr.base), shade = hz1(sr.shade), deep = hz1(sr.deep) }
    local function surf(x)
      local best, bi = 1e9, 1
      for i, p in ipairs(peaks) do
        local dx = x - p[1]
        local jag = (vnoise(x / 5, i, seed) - .5) * 5 * math.min(1, abs(dx) / 8) + (hash(x, i, seed) < .2 and 1 or 0)
        local y = p[2] + abs(dx) * (p[3] or 1) * (dx < 0 and 1 or 1.15) + jag
        if y < best then best, bi = y, i end
      end
      return best, bi
    end
    local m = HP.mask()
    local tops = {}
    for x = 0, W - 1 do
      local t, i = surf(x)
      t = floor(t + .5)
      tops[x] = t
      local p = peaks[i]
      local lit = x < p[1]
      local sd = (p[4] or 22)
      for y = math.max(0, t), yb do
        m:set(x, y)
        local d = y - p[2]           -- depth below the summit
        local e = y - t              -- depth below the skyline here
        local st = vnoise((x + (lit and 1 or -1) * (y - p[2]) * .8) / 3, y / 14, seed + i)
        local h
        if lit then h = (st > .62) and R.hi or ((st < .3) and R.shade or R.base)
        else h = (st > .66) and R.base or ((st < .32) and R.deep or R.shade) end
        if e == 0 then h = lit and R.hi or R.shade end
        -- snow: the cap (ragged lower edge) and tongues down the gullies
        local cap = sd + (vnoise(x / 4, 1, seed + 3) - .5) * sd * .7
        local gully = st > .74 and d < sd * 2.2
        if d < cap or gully then
          if lit then h = (e < 2 or st > .55) and S.hi or S.base
          else h = (st > .8) and S.base or S.shade end
          if not gully and d > cap - 2 then h = lit and S.base or S.deep end
        elseif d < cap + 3 and hash(x, y, seed + 9) < .3 then h = lit and S.base or S.shade end
        px(x, y, h)
      end
    end
    -- outline the skyline on the shaded flanks only (crisp, not heavy)
    for x = 1, W - 1 do local t = tops[x] local _, i = surf(x) if x > peaks[i][1] and t >= 0 then px(x, t, R.edge) end end
    return m, function(x) return tops[floor(x)] or yb end
  end

  local function fFar(x) return HZ - 16 + 6 * sin(x / 37) + 4 * sin(x / 13 + 1) end
  local function fMid(x) return HZ - 6 + 4 * sin(x / 29 + 2) + 3 * sin(x / 11) end
  -- conifer silhouette ridge: a row of spires rising off a hill line (every ~4-7 px, hmin..hmax tall);
  -- gap (0..1) leaves bare stretches (mountain: open slopes between spruce stands)
  local function ridge(f, col, colLit, seed, hmin, hmax, gap)
    local x = -4
    while x < W + 4 do
      local hh = hmin + floor(hash(x, 1, seed) * (hmax - hmin))
      local yb = floor(f(x)) + 2
      local w = math.max(2, floor(hh * .3))
      if not gap or vnoise(x / 30, 0, seed) > gap then
        for yy = yb - hh, yb do
          local half = floor((yy - (yb - hh)) / hh * w + .5)
          if (yy - (yb - hh)) % 3 == 2 then half = half + 1 end -- tier tips
          for xx = x - half, x + half do px(xx, yy, (colLit and xx < x and yy < yb - 1) and colLit or col) end
        end
      end
      x = x + 3 + floor(hash(x, 2, seed) * 5)
    end
  end
  -- far range: high slate-blue peaks with deep snow caps
  if not o.noPeaks then
    range(o.peaksFar or { { 30, 40, 1.1, 16 }, { 112, 22, 1.0, 20 }, { 176, 46, 1.2, 13 }, { 240, 16, 1.05, 22 }, { 312, 36, 1.0, 17 },
      { 384, 20, 1.1, 20 }, { 458, 42, 1.2, 14 } }, L.peakFar, L.snow, { seed = 3, haze = .2 })
    -- a wisp of cloud lying across the far range
    for y = 64, 67 do for x = 0, W - 1 do
      local v = vnoise(x / 22, y / 3, 41)
      if v > .58 + (y == 64 and .1 or 0) then px(x, y, y == 67 and L.mist or "#e6ecf0") end
    end end
    -- near range: granite crags, lower, steeper, snow in patches and couloirs
    range(o.peaksNear or { { 64, 62, 1.5, 12 }, { 150, 56, 1.35, 14 }, { 336, 54, 1.4, 14 }, { 420, 66, 1.5, 10 } }, L.peak, L.snow, { seed = 7, haze = .08 })
  end
  c:terrain(fFar, L.hillFar, HZ)
  -- talus streaks down the far foothills
  for x = 0, W - 1 do local t = floor(fFar(x)) for y = t + 1, HZ do if (x + (y - t) * 2) % 17 < 2 and hash(x // 17, 1, 22) < .5 then px(x, y, mix(L.hillFar, L.peak.hi, .35)) end end end
  ridge(fFar, L.ridgeFar, nil, 21, 4, 10, .5)
  for y = HZ - 15, HZ - 10 do for x = 0, W - 1 do if hash(x // 9, y, 23) < .3 then px(x, y, L.mist) end end end
  if o.beforeMid then o.beforeMid() end
  setDepth(1)
  ridge(function(x) return fMid(x) + 1 end, L.ridgeMid, L.hillMidShade, 27, 4, 10, .38)
  for i, tx in ipairs(o.farTrees or { 24, 52, 196, 290, 318, 352, 440 }) do tree(tx, floor(fMid(tx)) + 2, 22, i, true) end
  setDepth(0)
  local midM = c:terrain(fMid, L.hillMid, HZ)
  midM:each(function(x, y) if (x + y * 3) % 23 == 0 then px(x, y, L.hillMidShade) elseif hash(x, y, 24) < .03 then px(x, y, L.mossGround.hi) end end)
  -- valley haze: long thin streaks along the foot of the mid hills
  for y = HZ - 6, HZ - 1 do
    for x = 0, W - 1 do
      local v = hash(x // 14, y, 25)
      if v < .32 - (HZ - y) * .05 then px(x, y, (y % 2 == 0) and L.mist or L.mist2) end
    end
  end

  local groundCol = {}
  local function groundAt(x, y)
    local d = y - HZ + 2
    local base
    local f = (y - HZ - 1) / (H - 1 - HZ)
    if f < 1 / 13 then base = L.groundFar elseif f < 3 / 13 then base = L.ground.hi else base = L.ground.base end
    -- mountain: low-frequency patches of lush turf (blue-green) and scree gravel (grey), flattened by perspective;
    -- far off, lingering snow patches
    local sy = 2 + d * .1
    local nv = vnoise(x / (sy * 5), y / sy, 5) + (hash(x, y, 6) - .5) * .08
    if f >= 1 / 13 then
      if nv < .36 then base = f < 3 / 13 and L.mossGround.hi or L.mossGround.base
      elseif nv > .75 then
        base = f < 3 / 13 and L.stone.hi or L.duff
        local g = hash(x, y, 7)
        if g < .16 then return L.stone.shade elseif g < .24 then return L.stone.hi elseif g < .27 then return L.stone.deep end
      end
    else
      local sv = vnoise(x / 9, y / 1.6, 8)
      if sv > .8 then return sv > .86 and L.snow.hi or L.snow.base end
      if sv > .77 then return L.snow.shade end
    end
    local u = (x - VX) / d * 7
    if y < 168 and abs(u - floor(u + .5)) < .06 + 1.2 / d then return L.ground.shade end
    if hash(x, y, 1) < .02 + y / 9000 then return L.ground.shade end
    if hash(x, y + 1, 1) < .02 + (y + 1) / 9000 then return L.ground.hi end
    return base
  end
  -- forest: the ground is painted per pixel by groundAt (so eraseGround matches it exactly, patches included)
  for y = HZ + 1, H - 1 do for x = 0, W - 1 do px(x, y, groundAt(x, y)) end end
  -- forest ground: needle carpet. Fallen needles (short diagonal strokes), fern / grass tufts (taller nearer),
  -- moss patches, pine cones, small mushrooms and mossy pebbles; far ground faint.
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
  -- mountain ground: short turf. Grass blades (blue-green and dry straw, taller nearer), edelweiss, gentian,
  -- arnica / alpine-rose dots, scree pebbles with lichen, little juniper cushions; far ground faint.
  local function groundDetail(x0, x1, y0, y1, seed)
    for i = 1, 700 do
      local x = x0 + floor(hash(i, 1, seed) * (x1 - x0))
      local y = y0 + floor(hash(i, 2, seed) ^ .7 * (y1 - y0))
      local near = (y - HZ) / (H - HZ)
      local kind = hash(i, 3, seed)
      if hash(i, 4, seed) < near * 1.2 then
        if kind < .34 then
          local th = 1 + floor(near * 4 * hash(i, 5, seed))
          local r = hash(i, 7, seed) < .3 and L.needle or L.fern
          vline(x, y - th, y, r.shade) px(x, y - th, r.hi)
          if near > .4 then px(x - 1, y - 1, r.base) px(x + 1, y, r.deep) if th > 2 then px(x + 1, y - th + 1, r.hi) vline(x + 2, y - 1, y, r.shade) end end
        elseif kind < .46 then
          edelweiss(x, y, near > .45)
        elseif kind < .56 then
          gentian(x, y, near > .45)
        elseif kind < .63 then
          local fr = hash(i, 6, seed) < .55 and L.gold or L.petal
          px(x, y, fr.base) px(x - 1, y - 1, fr.hi)
          if near > .5 then px(x + 1, y - 1, fr.base) px(x, y + 1, L.fern.shade) px(x + 1, y, fr.shade) end
        elseif kind < .8 then
          local r = L.stone
          px(x, y, r.base) px(x + 1, y, r.shade) px(x, y + 1, r.deep)
          if near > .4 then px(x - 1, y, r.hi) px(x, y - 1, r.hi) px(x + 1, y - 1, hash(i, 8, seed) < .4 and L.moss.base or r.base) px(x + 2, y, r.deep) px(x + 1, y + 1, r.edge) end
        elseif kind < .86 then
          if near > .4 then local r = L.juniper
            hline(x - 2, x + 2, y, r.shade) hline(x - 1, x + 1, y - 1, r.base) px(x - 1, y - 1, r.hi) px(x + 2, y, r.deep) px(x, y - 2, r.hi)
            if near > .65 then hline(x - 3, x + 3, y + 1, r.deep) px(x + 1, y - 1, "#8c9cc8") end
          end
        else
          local r = L.needle
          px(x, y, r.base) px(x - 1, y - 1, r.hi) px(x + 1, y - 1, r.shade)
          if near > .5 then px(x - 2, y - 2, r.hi) px(x + 2, y - 2, r.shade) px(x, y - 2, r.base) end
        end
      end
    end
  end
  groundDetail(0, W - 1, HZ + 8, H - 1, 401)
  -- mountain: a sparse tree line along the horizon (plane 1, hazed): stands of spruce and larch with open turf
  -- and granite boulders between. Skips the road end; o.noTreeLine turns it off, o.treeLineGap = { x0, x1 }
  -- changes the gap (default 220..260).
  if not o.noTreeLine then
    local g0, g1 = (o.treeLineGap or { 220, 260 })[1], (o.treeLineGap or { 220, 260 })[2]
    setDepth(1)
    local x, i = 2, 0
    while x < W - 2 do
      i = i + 1
      if x < g0 or x > g1 then
        local stand = vnoise(x / 40, 3, 31)
        local yb = HZ + 3 + floor(hash(x, 4, 31) * 3)
        if stand > .52 then
          local hh = 12 + floor(hash(x, 3, 31) * 16)
          local k = hash(x, 5, 31)
          if k < .3 then larch(x, yb, hh, 300 + i) else conifer(x, yb, hh, k < .7 and L.foliage2 or L.farTree, 300 + i, { slim = true }) end
        elseif hash(x, 7, 31) < .5 then
          boulder(x, yb, 2 + floor(hash(x, 8, 31) * 3), 2 + floor(hash(x, 9, 31) * 2), 300 + i)
        end
      end
      x = x + 7 + floor(hash(x, 6, 31) * 9)
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
      -- mountain: grass in some slab seams, lichen blotches and the odd orange lichen dot on the granite
      if h == L.road.deep and hash(x, y, 24) < .16 then h = L.fern.shade
      elseif h ~= L.road.deep and hash(r1, u1, 26) < .25 and vnoise(x / 2, y / 2, 27) > .72 then h = L.moss.base
      elseif h ~= L.road.deep and hash(x, y, 28) < .006 then h = L.lichenOrange end
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
    -- mountain: arolla-pine boughs over the beam (dark blue-green brushes with upturned needle tufts),
    -- a larch sprig on each side, short needle fringes, purple-brown arolla cones
    local boughs = { { 56, 18, 34, 12, L.foliage2, 91 }, { 110, 14, 22, 8, L.foliage, 92 }, { 428, 18, 34, 12, L.juniper, 93 }, { 378, 14, 20, 8, L.foliage, 94 } }
    for _, b in ipairs(boughs) do
      local m = crown(b[1], b[2], b[3], b[4], b[5], b[6])
      local r = b[5]
      m:each(function(x, y)
        if not m:has(x, y + 1) and y > 12 and hash(x, y, b[6]) < .55 then
          local len = 1 + floor(hash(x, 1, b[6]) * 2)
          for k = 1, len do px(x, y + k, k == len and r.edge or r.deep) end
        elseif (x + y * 2) % 5 == 0 and hash(x, y, b[6] + 1) < .5 then px(x, y, (x - b[1]) < 0 and r.hi or r.shade) end
      end)
      -- upturned needle brushes on the top edge
      m:each(function(x, y)
        if not m:has(x, y - 1) and y > 13 and hash(x, y, b[6] + 2) < .3 then px(x, y - 1, r.base) px(x - 1, y - 2, r.hi) px(x + 1, y - 2, r.shade) end
      end)
      for k = 1, 2 do
        local cx = b[1] + floor((hash(k, 2, b[6]) - .5) * b[3])
        local cy = b[2] + b[4] - 2
        if m:has(cx, cy) then fill(rect(cx, cy + 1, cx + 1, cy + 3), "#7a5a6a") px(cx, cy + 1, "#a07a86") px(cx + 1, cy + 3, "#4e3846") end
      end
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
    -- mountain: lichen rosettes on the granite courses (grey-green, a few orange map-lichen dots), more low down
    local posts = union(postL, postR)
    posts:each(function(x, y)
      local ry = y % 9
      local v = vnoise(x / 3, y / 3, 97)
      if ry ~= 0 and v > .78 - y / 222 * .12 then px(x, y, hash(x, y, 98) < .35 and L.moss.hi or (v > .86 and L.moss.shade or L.moss.base))
      elseif ry ~= 0 and hash(x, y, 99) < .006 then px(x, y, L.lichenOrange) end
    end)
    part(plL, G, { sep = true }) part(plR, G, { sep = true }) hline(0, 18, 218, G.hi) hline(W - 19, W - 1, 218, G.hi)
    for x = 0, W - 1 do if (x < 19 or x > W - 20) and hash(x, 219, 96) < .3 then px(x, 219, L.moss.base) end end
    part(brL, L.timber, { nopop = true }) part(brR, L.timber, { nopop = true })
    part(beam, L.timber, { band = 2 })
    flatCrown = false
    beam:each(function(x, y) if y > 1 and y < 11 and hash(x // 7, y, 95) < .12 then px(x, y, L.timber.shade) end end)
    hline(0, W - 1, 1, L.timber.hi)
    for x = 30, W - 30, 60 do fill(rect(x, 4, x + 2, 6), L.timber.deep) px(x, 4, L.timber.hi) end
    local function by(x) local t = (x - VX) / 224 return 15 + 16 * (1 - t * t) end
    for x = 16, W - 17 do px(x, floor(by(x)), L.timber.deep) end
    local cols = { L.awnA, L.awnB, L.accent, L.gold }
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
    -- mountain additions
    larch = larch, snow = snow, lichen = lichen, boulder = boulder, juniper = juniper, edelweiss = edelweiss, gentian = gentian,
    range = range, vnoise = vnoise,
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
      local col = b[4] or "#3e4250" -- mountain: alpine choughs
      px(x, y, col)
      for k = 1, w do px(x - k, y - (k == w and 1 or 0) - (k > 1 and 1 or 0) + (k == 1 and 0 or 0), col) px(x + k, y - (k > 1 and 1 or 0), col) end
    end
  end
  -- smoke column: puffs rising and drifting, lighter and smaller as they rise
  function F.smoke(x, y, n, drift, big)
    drift = drift or 1
    local cols = { "#a6aeb8", "#bcc3cb", "#cfd5db", "#e0e5e9" } -- mountain: cold blue-grey smoke
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
  -- mountain goat, side view, feet at (x, yb), facing right (g.flip faces left). g.r = coat ramp (L.goat white,
  -- L.chamois brown), g.k = size (1 = about 26 px tall to the horn tips, .6 for a kid), g.graze = head down,
  -- g.hat = a gnome-hat ramp (cone hat between the horns). Returns the silhouette mask.
  function F.goat(x, yb, g)
    g = g or {}
    local s, k = g.flip and -1 or 1, g.k or 1
    local r = g.r or L.goat
    local function P(dx, dy) return { x + floor(dx * k + .5) * s, yb + floor(dy * k + .5) } end
    local function R(dx0, dy0, dx1, dy1) local a, b = P(dx0, dy0), P(dx1, dy1) return rect(math.min(a[1], b[1]), math.min(a[2], b[2]), math.max(a[1], b[1]), math.max(a[2], b[2])) end
    local body = poly{ P(-10, -16), P(4, -17), P(8, -15), P(9, -10), P(6, -7), P(-8, -7), P(-11, -10) }
    local neck, head, beard
    if g.graze then
      neck = poly{ P(5, -16), P(9, -14), P(12, -7), P(9, -6) }
      head = poly{ P(9, -9), P(13, -10), P(15, -3), P(13, -1), P(10, -3) }
      beard = poly{ P(10, -3), P(12, -2), P(10, 0) }
    else
      neck = poly{ P(4, -17), P(8, -22), P(11, -21), P(9, -12) }
      head = poly{ P(8, -24), P(11, -25), P(16, -20), P(16, -18), P(12, -18), P(9, -20) }
      beard = poly{ P(11, -18), P(14, -18), P(12, -13) }
    end
    local legs = union(R(-9, -8, -8, 0), R(-6, -8, -5, -1), R(4, -8, 5, 0), R(7, -8, 8, -1))
    local tail = poly{ P(-10, -15), P(-13, -18), P(-12, -14) }
    local sil = union(body, neck, head, beard, legs, tail)
    if not g.noShadow then shadowM(c:ellipse(x + 2 * s, yb + 1, floor(11 * k), 1)) end
    c:rim(sil, r.edge)
    part(legs, r, { nopop = true, noshade = true })
    for _, d in ipairs({ -9, -6, 4, 7 }) do local a = P(d, 0) px(a[1], a[2], L.timber.edge) local b = P(d + 1, 0) px(b[1], b[2], L.timber.edge) end
    part(union(body, neck, tail), r, { nopop = true })
    -- shaggy coat: lit back, darker belly fringe, hair strands
    sil:each(function(xx, yy)
      if body:has(xx, yy) or neck:has(xx, yy) then
        if not sil:has(xx, yy - 1) or not sil:has(xx, yy - 2) then px(xx, yy, r.hi)
        elseif (xx * 2 + yy) % 5 == 0 and hash(xx, yy, 5) < .6 then px(xx, yy, r.shade) end
        if body:has(xx, yy) and not body:has(xx, yy + 1) and hash(xx, 1, 6) < .5 then px(xx, yy + 1, r.deep) end
      end
    end)
    part(head, r, { nopop = true, noshade = true })
    part(beard, r, { nopop = true, noshade = true }) beard:each(function(xx, yy) if (xx + yy) % 2 == 0 then px(xx, yy, r.shade) end end)
    if g.graze then
      local e = P(12, -7) px(e[1], e[2], L.timber.edge) local n = P(14, -2) px(n[1], n[2], r.deep)
      local h1, h2 = P(10, -9), P(7, -12)
      line({ h1, h2, P(5, -11) }):each(function(xx, yy) px(xx, yy, L.iron.deep) end) local hh = P(9, -10) px(hh[1], hh[2], L.iron.hi)
    else
      local e = P(12, -21) px(e[1], e[2], L.timber.edge) local n = P(16, -19) px(n[1], n[2], r.deep)
      local ear = line({ P(9, -21), P(6, -20) }) ear:each(function(xx, yy) px(xx, yy, r.shade) end)
      if g.hat then
        local hat = poly{ P(8, -24), P(12, -25), P(11, -31), P(7, -33) }
        c:rim(hat, g.hat.edge) part(hat, g.hat, { nopop = true }) local t = P(9, -27) px(t[1], t[2], g.hat.hi)
      else
        -- swept-back horns: outlined, ridged grey-brown, lit on the upper-left edge
        local horn = line({ P(9, -24), P(8, -28), P(5, -31), P(2, -31) }):add(line({ P(10, -24), P(9, -28), P(6, -30) }))
        c:rim(horn, r.edge, horn:grow(1):cut(sil))
        horn:each(function(xx, yy) px(xx, yy, (yy + xx) % 2 == 0 and "#9c9078" or "#7a6e5c") end)
        local hp = P(8, -27) px(hp[1], hp[2], "#c4b89c") local hq = P(6, -30) px(hq[1], hq[2], "#c4b89c")
      end
    end
    return sil
  end
  -- alpine marmot, sitting up (whistling), feet at (x, yb), ~11 px tall. g.flip mirrors.
  function F.marmot(x, yb, g)
    g = g or {}
    local rows = {
      "..dddd...",
      ".dSSSSd..",
      ".SeSSeS..",
      ".SSmmSS..",
      "..SnnS...",
      ".sSSSSs..",
      "sSScccSs.",
      "sSpcccpSs",
      "sSScccSs.",
      "sSScccSSs",
      ".sSSSSSs.",
      ".ff...ff.",
    }
    if g.flip then for i, r in ipairs(rows) do rows[i] = r:reverse() end end
    return F.sprite(rows, x - 4, yb - 11, { s = L.chamois.shade, S = L.chamois.base, c = L.chamois.hi, e = L.timber.edge, n = L.timber.edge,
      m = L.goat.base, d = L.chamois.deep, p = L.chamois.deep, f = L.chamois.deep })
  end
  -- explicit rim light on a mask's upper-left lip (for objects that sit on others)
  function F.rimLight(m, k)
    m:each(function(x, y) if not m:has(x - 1, y) or not m:has(x, y - 1) then local v = c:get(x, y) if v then rawput(c, x, y, mix(v, "#f2f0dc", k or .4)) end end end)
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
      if v then local _, _, l = toHsl(v) if l < .86 then rawput(c, x, y, mix(v, "#f2f0dc", .32)) end end
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
