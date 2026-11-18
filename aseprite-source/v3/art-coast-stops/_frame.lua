-- _frame.lua : COAST gate-view frame for the stop-type looks, palette "coast_driftwood".
-- A copy of art-forest-stops/_frame.lua (itself a copy of the Maplewold art-2701-batch3/stops/opus3/_frame.lua)
-- with the same API and composition compass (horizon y=112, slab road, gate, bunting, lanterns, compass corner,
-- depth planes, rim light), re-skinned for a temperate rocky / sandy coast: a big breezy blue sky with cumulus,
-- a sea band with whitecaps and sun glitter between two chalk headlands, a pale beach and golden marram dunes,
-- a dune line at the horizon (replaces the forest tree line), dune-turf ground (marram, sea thrift, shells,
-- shingle, driftwood, wrack), sand-drifted lichened slabs, a fishing net with cork floats on the gate.
-- F.tree now draws wind-bent coastal trees (hawthorn / sea-buckthorn / leaning pine).
-- New helpers: F.windTree, F.marram, F.thrift, F.shell, F.pebbles, F.driftwood, F.boat, F.gull, F.lobsterPot,
-- F.wrack, F.lichen, F.barnacles, F.seaWater, F.cork, F.netSwag (and the forest ones are kept).
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
  -- coast_driftwood: same keys as Maplewold / forest so type scripts keep working; the MEANING of a few keys shifts:
  -- roof = blue-grey slate (use shingle=true), roof2 = red pantile, plaster = salt-bleached whitewash,
  -- wall2 = sea-blue paint, timber = weathered grey driftwood, board = sun-bleached boards, foliage = silver
  -- sea-buckthorn green, foliage2 = dark wind-pruned hawthorn, leaf = dune turf, water = sea / tide-pool blue,
  -- petal = sea thrift pink, accent = fisherman navy.
  local L = {
    sky = { "#6eaad8", "#84b8e0", "#9ac6e6", "#b0d4ea", "#c6e0ec" },
    cloud = { top = "#f6f6ee", mid = "#e4eaea", shade = "#c8d6e0", under = "#b0c4d6" },
    hillFar = "#a6bcc4", hillMid = "#d2be7c", hillMidShade = "#b09c5e",
    ridgeFar = "#94acb6", ridgeMid = "#8aa47e", mist = "#dce8ec", mist2 = "#e8f0ee",
    farTree = rp("#b8c8b4 #98ae9e #7c9488 #627a74 #4a5e5e"),
    ground = rp("#e4d498 #c8b26c #a28c52 #76663e #4a402e"), groundFar = "#d8cc96",
    road = rp("#dedad0 #bcb8ac #989488 #72706a #4c4a48"), slabRatio = 1.06, slabK = 15,
    stone = rp("#dadcd6 #b2b6b2 #8c9290 #686e72 #444a52"),
    plaster = rp("#f4f2ea #e0e2dc #bec4c4 #92989e #5e646e"),
    wall2 = rp("#b8d6e0 #8cb6c8 #6892a8 #4c6e88 #34485e"),
    timber = rp("#bab2a6 #948c80 #706a62 #4e4a46 #2e2c30"),
    roof = rp("#a6aebc #7e8698 #5e6678 #444a5c #2a2c3c"),
    roof2 = rp("#ec9474 #cc644c #a2463a #76302e #4a1e24"),
    awnA = rp("#f08a78 #d6524a #aa3a3e #7a2a38 #4a1a28"),
    awnB = rp("#f6f2e2 #e2ddcc #c2bca8 #989486 #5e5c56"),
    accent = rp("#96bade #5c84b2 #42638e #30486c #1e2e48"),
    foliage = rp("#c6d2a6 #9aae82 #748c68 #54694e #34463a"),
    foliage2 = rp("#9cba84 #6a9262 #4c7050 #345240 #20362c"),
    leaf = rp("#c8d688 #9cb660 #709046 #4e6c3c #30462c"),
    water = rp("#c2e4e6 #7cb8cc #508caa #36688a #22445e"),
    glow = rp("#fff6c0 #ffd870 #f6aa42 #d27a30 #8a4a24"),
    soil = rp("#a6826a #82604a #644838 #48322a #2e1e1c"),
    board = rp("#eee6d2 #d2c8b0 #aea48c #827a66 #544e44"),
    produce = rp("#ffb04a #f07c22 #c85a1e #943e1c #5e2618"),
    lav = rp("#d0c4ec #a28ad4 #7862b0 #554484 #362a58"),
    iron = rp("#b0b6bc #7c848c #5a626c #3e4650 #262c38"),
    skin = rp("#ffe0bd #f0b98d #c98462 #7a4036 #4a2620"),
    apple = rp("#ff8a6c #e23c3a #b02436 #741c30 #4a1222"),
    petal = rp("#fad2de #f09cb6 #d06e92 #9a4a6c #623048"),
    gold = rp("#f6e08a #e2be52 #b8923a #86662c #563f22"),
    -- forest keys kept (re-tinted for the coast) so copied forest scripts still run
    moss = rp("#ccd496 #a8b276 #84905e #626e4a #404a36"),
    birch = rp("#f0ecdc #d8d4c4 #ada99c #7c7a72 #4a4a46"),
    birchLeaf = rp("#e6e490 #c4cc62 #98aa48 #6c823c #46582e"),
    redbark = rp("#dc8c5e #b2603e #884434 #5e2e2a #3a1c1e"),
    needle = rp("#c8a46c #a47c48 #7e5c38 #5a422c #3a2a20"),
    fern = rp("#b6d07a #80aa52 #5a8442 #3e6236 #26402a"),
    mossGround = rp("#b6c886 #94aa66 #76904e #58703e #3a4e2e"), duff = "#b8a678",
    -- coast-only ramps
    sand = rp("#f4ead0 #e4d6b0 #cabb90 #a69672 #766a50"),
    wetSand = rp("#d6ccb2 #bcae90 #9c8e74 #786c5a #50483e"),
    shingle = rp("#dcd8d0 #b4b0a8 #8e8a84 #6a6662 #46423f"),
    marram = rp("#eede9a #d2ba6a #ac9650 #806e3e #52482e"),
    chalk = rp("#f4f2e8 #dedfd6 #bec2bc #989ea0 #6e747c"),
    sea = rp("#a8d2de #6ca6c4 #4c84aa #365f88 #243e5e"),
    foam = "#eef4f0",
    kelp = rp("#bcaa5a #92823e #6c6230 #4a4626 #30301e"),
    tar = rp("#6e6866 #4c4848 #38363c #28282e #1a1a20"),
    lichen = rp("#f8dc74 #ecb844 #cc8e32 #9c6628 #66401e"),
    gull = rp("#f4f4f0 #dcdfde #b2babe #868e96 #565c66"),
    gorse = rp("#fae27a #eec23c #c8982c #8c6a26 #5a4420"),
    cork = rp("#e2b67e #c28e58 #9c6c42 #724c30 #4a301e"),
    glass = rp("#d4f0e4 #8ccab8 #5ea294 #3e7a74 #285454"),
    shadow = "#a8966c", shadowRoad = "#8e8c88",
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
  local HAZE = "#d4e2e8" -- coast: cool blue-grey sea haze

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
  -- coast: a wind-bent tree (hawthorn / sea-buckthorn). The trunk leans away from the sea wind (to the right),
  -- the crown is a flat wedge swept downwind with a clipped windward face. o.far = small hazed shrub, no detail;
  -- o.lean (default 1, use -1 to mirror); o.bark ramp. Returns the crown mask.
  local function windTree(x, yb, h, r, seed, o)
    o = o or {}
    r = r or L.foliage2
    local s = o.lean or 1
    local far = o.far
    local bark = far and r or (o.bark or L.timber)
    local tx, ty = x + floor(h * .28) * s, yb - floor(h * .58)
    local trunk = line({ { x, yb }, { floor(x + h * .1 * s), yb - floor(h * .3) }, { tx, ty } }, h >= 24 and 2 or 1)
    if h >= 20 then trunk:add(line({ { floor(x + h * .1 * s), yb - floor(h * .3) }, { floor(x - h * .06 * s), yb - floor(h * .52) } }, 1)) end
    rimOf(trunk, far and r or bark)
    part(trunk, bark, { nopop = true, noshade = far })
    -- crown: three flattened lobes streaming downwind, the windward one smallest
    local cx, cy = x + floor(h * .2) * s, yb - floor(h * .7)
    local m = HP.mask()
    local lobes = { { cx - floor(h * .16) * s, cy + floor(h * .06), h * .16 + 2, h * .12 + 2 },
      { cx + floor(h * .06) * s, cy, h * .28 + 2, h * .16 + 2 },
      { cx + floor(h * .3) * s, cy + floor(h * .1), h * .2 + 2, h * .12 + 2 } }
    flatCrown = far
    for i, lb in ipairs(lobes) do m:add(crown(floor(lb[1]), floor(lb[2]), floor(lb[3]), floor(lb[4]), r, seed + i)) end
    flatCrown = false
    if not far then
      -- windward edge clipped flat: a lit comb of twig tips, lee side drips darker
      m:each(function(xx, yy)
        if not m:has(xx, yy - 1) and hash(xx, yy, seed + 9) < .4 then px(xx, yy - 1, (xx - cx) * s < 0 and r.hi or r.shade) end
        if not m:has(xx, yy + 1) and (xx - cx) * s > 0 and hash(xx, yy, seed + 8) < .5 then px(xx, yy + 1, r.edge) end
      end)
    end
    return m
  end
  -- F.tree: coast default. seed%4: 0,2 = wind-bent hawthorn (foliage2), 1 = silver sea-buckthorn (foliage),
  -- 3 = leaning red-bark maritime pine. far = small hazed wind-bent shrub.
  local function tree(x, yb, h, seed, far)
    if far then return windTree(x, yb, h, L.farTree, seed, { far = true }) end
    local k = seed % 4
    if k == 3 then return pine(x, yb, h, L.foliage2, seed) end
    return windTree(x, yb, h, k == 1 and L.foliage or L.foliage2, seed)
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

  ---------------------------------------------------------------- coast helpers (used by the background and by type scripts)
  -- marram tuft: blades fanning from (x,y), h tall; lit blades left, shaded right
  local function marram(x, y, h, r)
    r = r or L.marram
    h = h or 4
    vline(x, y - h, y, r.base) px(x, y - h, r.hi)
    if h >= 3 then
      line({ { x - 1, y }, { x - 2, y - h + 1 }, { x - 3, y - h + 2 } }):each(function(xx, yy) px(xx, yy, r.hi) end)
      line({ { x + 1, y }, { x + 2, y - h + 2 }, { x + 3, y - h + 3 } }):each(function(xx, yy) px(xx, yy, r.shade) end)
    end
    if h >= 6 then
      line({ { x - 1, y - 1 }, { x - 4, y - h + 4 } }):each(function(xx, yy) px(xx, yy, r.base) end)
      line({ { x + 1, y - 1 }, { x + 4, y - h + 5 } }):each(function(xx, yy) px(xx, yy, r.deep) end)
      px(x + 1, y - h + 1, r.shade)
    end
    px(x, y, r.deep)
  end
  -- sea thrift: a green cushion with pink pom-poms on short stalks (big = 3 heads)
  local function thrift(x, y, big)
    local cu = big and c:ellipse(x, y - 1, 3, 1) or rect(x - 1, y - 1, x + 1, y)
    fill(cu, L.leaf.shade) px(x - 1, y - 1, L.leaf.base) px(x + 1, y, L.leaf.deep)
    local heads = big and { { -2, -5 }, { 1, -6 }, { 3, -4 } } or { { 0, -4 } }
    for _, hd in ipairs(heads) do
      local hx, hy = x + hd[1], y + hd[2]
      vline(hx, hy + 1, y - 2, L.leaf.deep)
      px(hx, hy, L.petal.base) px(hx - 1, hy, L.petal.hi) px(hx + 1, hy, L.petal.shade) px(hx, hy - 1, L.petal.hi)
      if big then px(hx, hy + 1, L.petal.shade) end
    end
  end
  local function shell(x, y, big)
    if big then -- a ribbed cockle
      hline(x - 1, x + 1, y - 2, L.awnB.hi) hline(x - 2, x + 2, y - 1, L.awnB.base) hline(x - 2, x + 2, y, L.awnB.shade)
      px(x - 1, y - 1, L.petal.hi) px(x + 1, y - 1, L.awnB.shade) px(x, y, L.awnB.deep)
    else px(x, y, L.awnB.hi) px(x + 1, y, L.awnB.shade) end
  end
  local function pebbles(x, y, n, seed)
    for k = 1, n or 3 do
      local px_, py_ = x + floor((hash(k, 1, seed or 5) - .5) * 6), y + floor((hash(k, 2, seed or 5) - .5) * 3)
      local r = hash(k, 3, seed or 5) < .7 and L.shingle or L.stone
      px(px_, py_, r.base) px(px_ + 1, py_, r.shade) px(px_, py_ - 1, r.hi) px(px_ + 1, py_ + 1, r.deep)
    end
  end
  -- a stick of driftwood from (x0,y0) to (x1,y1): bleached grey, lit top, dark underside, a knot
  local function driftwood(x0, y0, x1, y1, w)
    local m = line({ { x0, y0 }, { x1, y1 } }, w or 2)
    rimOf(m, L.timber)
    part(m, L.timber, { nopop = true })
    m:each(function(x, y) if not m:has(x, y - 1) then px(x, y, L.timber.hi) end end)
    px(floor((x0 + x1) / 2), floor((y0 + y1) / 2), L.timber.deep)
    return m
  end
  -- a heap of wrack / kelp: olive-brown ribbons with bladder dots
  local function wrack(x, y, w, seed)
    w = w or 6
    for k = 0, w do
      local yy = y + floor(sin(k * .5 + (seed or 0)) * .8 + .5)
      px(x + k, yy, k % 3 == 0 and L.kelp.hi or L.kelp.base) px(x + k, yy + 1, L.kelp.deep)
      if hash(k, 1, seed or 3) < .3 then px(x + k, yy - 1, L.kelp.shade) end
    end
  end
  -- crusty lichen (orange-yellow and grey-green) over a mask, thicker on upper faces
  local function lichen(m, k, seed)
    m:each(function(x, y)
      local top = not m:has(x, y - 1)
      local v = hash(x // 2, y // 2, seed or 86)
      if v < (top and k * 1.6 or k) then
        local w = hash(x, y, (seed or 86) + 1)
        px(x, y, w < .2 and L.lichen.base or (w < .5 and L.lichen.shade or (w < .8 and L.moss.base or L.moss.shade)))
      end
    end)
  end
  -- barnacles: pale rings with a dark pip, thick at the bottom of a mask (the tide line)
  local function barnacles(m, k, seed, yFrom)
    m:each(function(x, y)
      if y >= (yFrom or -999) and hash(x, y, seed or 87) < (k or .2) then
        px(x, y, L.awnB.shade) if hash(x, y, (seed or 87) + 1) < .4 then px(x, y, L.awnB.hi) end
      end
    end)
  end
  -- a cork float
  local function cork(x, y)
    hline(x - 1, x + 1, y - 1, L.cork.hi) hline(x - 1, x + 1, y, L.cork.base) px(x + 1, y, L.cork.shade) hline(x - 1, x + 1, y + 1, L.cork.deep)
  end
  -- a fishing boat, bow to the right (lean = -1 mirrors). o.sail ramp (default tan-red lug), o.hull ramp
  -- (default tarred), o.band ramp (a painted gunwale strip), o.far = tiny hazed version. Returns the mask.
  local function boat(x, yb, len, o)
    o = o or {}
    local s = o.flip and -1 or 1
    local sail, hull, band = o.sail or L.roof2, o.hull or L.tar, o.band or L.wall2
    if o.far then
      local hh = math.max(1, len // 6)
      local m = HP.mask()
      for k = 0, hh do hline(x - len // 2 + k, x + len // 2 - k + s, yb - hh + k, k == 0 and band.base or hull.shade) end
      local mx = x - s
      local sm = poly{ { mx, yb - hh - len + 1 }, { mx + floor(len * .45) * s, yb - hh - 1 }, { mx, yb - hh - 1 } }
      fill(sm, sail.base) sm:each(function(xx, yy) if (xx - mx) * s > len * .25 then px(xx, yy, sail.shade) end end)
      px(x, yb + 1, L.foam)
      return sm
    end
    local h = math.max(3, len // 5)
    local x0, x1 = x - len // 2, x + len // 2
    local hullM = poly{ { s > 0 and x0 or x1, yb - h }, { s > 0 and x1 + 2 or x0 - 2, yb - h - 2 }, { s > 0 and x1 - 3 or x0 + 3, yb }, { s > 0 and x0 + 3 or x1 - 3, yb } }
    local mx = x - floor(len * .1) * s
    local top = yb - h - floor(len * .95)
    local mast = rect(mx, top, mx, yb - h)
    local sl = poly{ { mx - 2 * s, top + 2 }, { mx + floor(len * .42) * s, top + 5 }, { mx + floor(len * .38) * s, yb - h - 2 }, { mx - floor(len * .18) * s, yb - h - 2 } }
    local mz = poly{ { (s > 0 and x0 or x1) + 3 * s, yb - h - floor(len * .45) }, { (s > 0 and x0 or x1) + 3 * s, yb - h - 2 }, { (s > 0 and x0 or x1) - 4 * s, yb - h - 2 } }
    local m = union(hullM, mast, sl, mz)
    rimOf(m, L.tar)
    part(hullM, hull, { nopop = true })
    hullM:each(function(xx, yy) if yy <= yb - h + 1 then px(xx, yy, band.base) end if yy == yb - h then px(xx, yy, band.hi) end end)
    part(mast, L.timber, { nopop = true, noshade = true })
    part(sl, sail) part(mz, sail, { nopop = true })
    sl:each(function(xx, yy) if (yy - top) % 5 == 0 then px(xx, yy, sail.shade) end end) -- reef bands
    return m
  end
  -- a gull in flight (size 1..3), or o = "big" sprite with a beak; wings flap when (x+y) odd
  local function gull(x, y, size)
    size = size or 2
    local g, w, k = L.gull.shade, L.gull.hi, L.gull.edge
    if size <= 1 then px(x - 1, y - 1, g) px(x + 1, y - 1, g) px(x, y, w)
    elseif size == 2 then
      px(x - 3, y - 2, k) px(x + 3, y - 2, k) hline(x - 2, x - 1, y - 1, g) hline(x + 1, x + 2, y - 1, g) px(x, y, w) px(x - 1, y, L.gull.base)
    else
      px(x - 4, y - 2, k) px(x + 4, y - 2, k) hline(x - 3, x - 2, y - 1, g) hline(x + 2, x + 3, y - 1, g)
      hline(x - 1, x + 1, y, w) px(x - 2, y, L.gull.base) px(x + 2, y, L.gull.base) px(x, y + 1, w) px(x + 1, y + 1, L.gold.base) px(x - 1, y + 1, L.gull.shade)
    end
  end
  -- a fishing net hanging in a swag from (x0,y0) to (x1,y0), sagging `sag` px; diamond mesh, a cork-floated foot rope
  local function netSwag(x0, x1, y0, sag, o)
    o = o or {}
    local col, col2 = o.col or L.tar.base, o.col2 or L.tar.shade
    local function yb(x) local t = (x - x0) / math.max(1, x1 - x0) return floor(y0 + sag * 4 * t * (1 - t) + .5) end
    local m = HP.mask()
    for x = x0, x1 do
      local b = yb(x)
      for y = y0, b do
        if (x + y) % 4 == 0 or (x - y) % 4 == 0 then m:set(x, y) px(x, y, ((x - x0) / (x1 - x0) > .5 or y > b - 2) and col2 or col) end
      end
      px(x, b, L.cork.deep) px(x, b + 1, L.tar.edge)
    end
    for x = x0 + 4, x1 - 3, o.floatStep or 7 do cork(x, yb(x) + 1) end
    return m
  end
  -- a domed withy lobster pot (creel): tarred hoops over a plank base, net in between, a rope tail
  local function lobsterPot(x, yb, w)
    w = w or 8
    local dome = c:ellipse(x, yb - 2, w, w):clip(rect(x - w, yb - w - 2, x + w, yb - 2))
    local base = rect(x - w, yb - 1, x + w, yb)
    local m = union(dome, base)
    rimOf(m, L.soil)
    -- wicker: woven diagonals in willow brown, lit upper left, darker lower right
    dome:each(function(xx, yy)
      local lt = (xx - x) / w + (yy - (yb - 2)) / w * .2
      local h = lt < -.3 and L.cork.hi or (lt < .35 and L.cork.base or L.cork.shade)
      if (xx + yy) % 3 == 0 then h = (lt < .35) and L.cork.shade or L.cork.deep end
      px(xx, yy, h)
    end)
    -- the withy hoops (dark bows) and the entrance eye on top
    for k = -w + 3, w - 3, 4 do dome:each(function(xx, yy) if xx == x + k then px(xx, yy, L.soil.shade) end end) end
    local eye = c:ellipse(x, yb - w + 1, math.max(1, w // 3), 1) fill(eye, L.soil.deep) hline(x - w // 3, x + w // 3, yb - w, L.cork.hi)
    part(base, L.timber, { nopop = true, noshade = true }) hline(x - w, x + w, yb, L.timber.deep)
    return m
  end
  -- red pantiles over a roof mask: S-profile tiles in columns 5 px wide (lit roll, shaded trough), course lines
  -- every 5 px, a few weathered tiles. Call after F.building{..., roof = L.roof2, shingle = true} on its roofM.
  local function pantile(m, r, y0, seed)
    m:each(function(x, y)
      local k, row = x % 5, (y - (y0 or 0)) % 5
      local h = (k == 0) and r.hi or ((k >= 3) and r.shade or r.base)
      if row == 4 then h = r.deep elseif row == 0 and k <= 1 then h = r.hi end
      if hash(x // 5, (y - (y0 or 0)) // 5, seed or 89) < .08 and row < 4 then h = (k >= 3) and r.deep or r.shade end
      px(x, y, h)
    end)
  end

  ---------------------------------------------------------------- BACKGROUND (coast: breezy blue sky, cumulus, sea with whitecaps, chalk headlands, beach, dunes)
  local SEA_Y = o.seaY or 92 -- the sea horizon: sky above, sea below
  local SHORE_Y = HZ - 7     -- where the surf runs up the beach
  for y = 0, SEA_Y - 1 do
    local f = y / SEA_Y * 5
    local b = floor(f)
    for x = 0, W - 1 do
      local i = b + 1
      if f - b > .72 and (x + y) % 2 == 0 and i < 5 then i = i + 1 end
      px(x, y, L.sky[i])
    end
  end
  -- a bright sun with a soft halo, upper left (the light source of every scene)
  local sunX, sunY = o.sunX or 92, o.sunY or 52
  if not o.noSun then
    fill(c:ellipse(sunX, sunY, 17, 16), "#b8d8ea") fill(c:ellipse(sunX, sunY, 12, 12), "#d4e8ec")
    fill(c:ellipse(sunX, sunY, 8, 8), "#f6f0d2") fill(c:ellipse(sunX, sunY, 6, 6), "#fbf6e2")
    px(sunX - 3, sunY - 3, "#fdfaee") px(sunX - 2, sunY - 4, "#fdfaee")
  end
  -- cumulus: heaped puffs with flat bottoms, each puff lit from the upper left, grey-blue undersides
  local function cumulus(x, y, w, seed)
    local nb = 3 + w // 14
    local blobs = {}
    for i = 1, nb do
      local t = (i - .5) / nb
      local r = w * (.16 + .16 * sin(t * math.pi) + .06 * hash(i, seed, 1))
      blobs[i] = { x + w * (.08 + .84 * t) + (hash(i, seed, 2) - .5) * 4, y - r * (.55 + .5 * sin(t * math.pi)), r }
    end
    local m = HP.mask()
    for _, b in ipairs(blobs) do m:add(c:ellipse(floor(b[1]), floor(b[2]), floor(b[3]), floor(b[3] * .85))) end
    m:add(c:rrect(x - 2, y - 4, x + w + 2, y, 2))
    m:clip(rect(0, 0, W - 1, y))
    m:each(function(xx, yy)
      local best, bi = 1e9, 1
      for i, b in ipairs(blobs) do local d = ((xx - b[1]) ^ 2 + ((yy - b[2]) / .85) ^ 2) / (b[3] * b[3]) if d < best then best, bi = d, i end end
      local b = blobs[bi]
      local nx, ny = (xx - b[1]) / b[3], (yy - b[2]) / b[3]
      local lit = -(nx * .55 + ny * .85) + (hash(xx // 2, yy // 2, seed) - .5) * .25 - (yy - (y - 3)) * .0
      local h
      if yy >= y - 1 then h = L.cloud.under
      elseif lit > .2 then h = L.cloud.top elseif lit > -.35 then h = L.cloud.mid elseif lit > -.75 then h = L.cloud.shade else h = L.cloud.under end
      if yy >= y - 3 and h == L.cloud.top then h = L.cloud.mid end
      px(xx, yy, h)
    end)
    -- a few torn wisps trailing downwind
    for k = 1, 3 do
      local wy = y - 2 - k * 3
      if m:has(x + w - 2, wy) or k == 1 then hline(x + w + 1, x + w + 4 + floor(hash(k, seed, 5) * 6), wy, L.cloud.mid) end
    end
    return m
  end
  for i, cl in ipairs(o.clouds or { { 112, 50, 46 }, { 292, 38, 60 }, { 396, 72, 38 }, { 26, 86, 30 }, { 196, 80, 22 } }) do cumulus(cl[1], cl[2], cl[3], 40 + i) end
  -- long thin streaks low over the sea
  for i = 1, 9 do
    local yy = SEA_Y - 3 - floor(hash(i, 1, 44) * 10)
    local xx = floor(hash(i, 2, 44) * W)
    hline(xx, xx + 10 + floor(hash(i, 3, 44) * 24), yy, L.mist)
  end

  -- headland profiles (fFar = top of the far land, SEA_Y where there is open sea)
  local function topL(x) return 60 + x * .15 + 3 * sin(x / 17) + 2 * sin(x / 7 + 1) end -- left headland, cliff end at x 136..150
  local function topR(x) return 70 + (W - x) * .08 + 2 * sin(x / 13) + 1.5 * sin(x / 6) end -- right headland, cliff end at x 368..380
  local function topD(x) return SEA_Y - 7 + 2 * sin(x / 19) - math.min(1, (x - 290) / 30) * 3 + math.max(0, 306 - x) * .45 end -- distant headland
  local L_END, R_END = o.leftHeadEnd or 150, o.rightHeadStart or 368
  local function fFar(x)
    if x < L_END then return math.max(topL(x), topL(x) + (x - (L_END - 14)) * 2.6 * (x > L_END - 14 and 1 or 0)) end
    if x > R_END then return math.max(topR(x), topR(x) + ((R_END + 12) - x) * 2.4 * (x < R_END + 12 and 1 or 0)) end
    if x > 290 then return topD(x) end
    return SEA_Y
  end
  local function fMid(x) return HZ - 4 + 4 * sin(x / 29 + 2) + 3 * sin(x / 11) end

  -- the sea: dark horizon line, deeper blue far, teal shallows near; whitecaps more and longer nearer; glitter
  local seaFar, seaShallow = L.sea.shade, "#86c0c8"
  for y = SEA_Y, SHORE_Y do
    local t = (y - SEA_Y) / (SHORE_Y - SEA_Y)
    for x = 0, W - 1 do
      local v = hash(x // 3, y, 51)
      local h
      if y == SEA_Y then h = L.sea.deep
      elseif t + (v - .5) * .18 < .32 then h = seaFar
      elseif t + (v - .5) * .18 < .78 then h = L.sea.base
      else h = seaShallow end
      px(x, y, h)
    end
    -- swell lines (lit crest above, shade trough below), whitecaps
    if y > SEA_Y + 1 then
      for x = 0, W - 1 do
        local seg = (x + y * 13) // (4 + floor(t * 6))
        local v = hash(seg, y, 52)
        if v < .16 + t * .1 then px(x, y, t < .5 and L.sea.base or L.sea.hi) end
        if hash(seg, y, 53) < .045 + t * .07 then
          px(x, y, L.foam) if hash(x, y, 54) < .5 and y < SHORE_Y - 1 then px(x, y + 1, L.sea.shade) end
        end
      end
    end
  end
  -- sun glitter: scattered sparkles across the left-centre sea
  for i = 1, 70 do
    local gx = 110 + floor(hash(i, 1, 55) * 150)
    local gy = SEA_Y + 1 + floor(hash(i, 2, 55) * (SHORE_Y - SEA_Y - 2))
    px(gx, gy, hash(i, 3, 55) < .5 and "#fbf6e2" or L.sea.hi) if hash(i, 4, 55) < .5 then px(gx + 1, gy, L.sea.hi) end
  end
  -- surf: a ragged foam line, wet sand, then dry sand to the horizon line
  for x = 0, W - 1 do
    local sy = SHORE_Y + floor(sin(x / 9) * 1 + hash(x // 4, 1, 56) * 1.6)
    px(x, sy - 1, hash(x, 2, 56) < .7 and L.foam or L.sea.hi) px(x, sy, L.foam)
    for y = sy + 1, HZ do
      local h
      if y <= sy + 2 then h = hash(x, y, 57) < .12 and L.sea.hi or L.wetSand.hi
      elseif hash(x, y, 58) < .05 then h = L.sand.shade else h = (y == sy + 3) and L.wetSand.hi or L.sand.base end
      px(x, y, h)
    end
  end
  -- default boats on the sea (o.boats = { {x, y, len}, ... }; {} for none)
  for _, b in ipairs(o.boats or { { 176, 96, 7 }, { 318, 95, 6 }, { 340, 100, 9 } }) do boat(b[1], b[2], b[3], { far = true }) end

  -- far headland (hazed): a low chalk line on the horizon right
  local function cliffFace(x, top, bot, r, grass, seed, endFace)
    for y = floor(top), bot do
      local h
      local d = y - floor(top)
      local cap = 2 + floor(hash(x // 3, 1, seed) * 2.5)
      if d < cap then h = d == 0 and grass[1] or grass[2]
      else
        local g = vnoise(x / 3.2, y / 14, seed) + (hash(x, y, seed + 3) - .5) * .12 -- vertical gullies and buttresses
        h = endFace or r.base
        if g < .3 then h = r.shade elseif g > .74 then h = r.hi end
        if g < .17 and d > cap + 2 then h = r.deep end
        if (y - floor(top)) % 6 == 4 and hash(x // 2, y, seed + 1) < .45 then h = (h == r.hi) and r.base or r.shade end -- flint bands
        if d == cap then h = r.hi end
        if y >= bot - 1 then h = hash(x, y, seed + 2) < .5 and r.deep or r.shade end -- talus at the foot
      end
      px(x, y, h)
    end
  end
  local cfar = { hi = mix(L.chalk.hi, HAZE, .45), base = mix(L.chalk.base, HAZE, .5), shade = mix(L.chalk.shade, HAZE, .5), deep = mix(L.chalk.deep, HAZE, .5) }
  for x = 290, W - 1 do cliffFace(x, topD(x), SEA_Y + 1, cfar, { mix(L.ridgeMid, HAZE, .45), mix(L.ridgeMid, HAZE, .55) }, 61) end
  -- the two near headlands: grassy caps, chalk faces with gullies and flint bands, a lit (right) / shaded (left) cliff end
  local cn = { hi = mix(L.chalk.hi, HAZE, .15), base = mix(L.chalk.base, HAZE, .2), shade = mix(L.chalk.shade, HAZE, .2), deep = mix(L.chalk.deep, HAZE, .2) }
  local gr = { mix(L.leaf.hi, HAZE, .25), mix(L.leaf.base, HAZE, .3) }
  local LB, RB = 101, 100
  for x = 0, L_END do
    local tp = fFar(x)
    cliffFace(x, tp, LB, cn, gr, 62, x > L_END - 14 and tp > topL(x) + 1 and cn.shade or nil)
  end
  for x = R_END, W - 1 do
    local tp = fFar(x)
    cliffFace(x, tp, RB, cn, gr, 63, x < R_END + 12 and tp > topR(x) + 1 and cn.hi or nil)
  end
  -- foam at the cliff feet and a few sea stacks
  for x = 0, L_END + 2 do if hash(x, 1, 64) < .7 then px(x, LB + 1, L.foam) end end
  for x = R_END - 2, W - 1 do if hash(x, 1, 65) < .7 then px(x, RB + 1, L.foam) end end
  for _, st in ipairs(o.stacks or { { 160, 101, 3, 9 }, { 356, 100, 2, 6 } }) do
    local m = poly{ { st[1] - st[3], st[2] }, { st[1] - st[3] + 1, st[2] - st[4] }, { st[1] + st[3] - 1, st[2] - st[4] + 1 }, { st[1] + st[3], st[2] } }
    fill(m, cn.base) m:each(function(xx, yy) if xx > st[1] then px(xx, yy, cn.shade) end if yy == st[2] - st[4] then px(xx, yy, gr[2]) end end)
    hline(st[1] - st[3] - 1, st[1] + st[3] + 1, st[2] + 1, L.foam)
  end
  -- coastal ridge (kept from the forest frame for scripts that call F.ridge)
  local function ridge(f, col, colLit, seed, hmin, hmax)
    local x = -4
    while x < W + 4 do
      local hh = hmin + floor(hash(x, 1, seed) * (hmax - hmin))
      local yb = floor(f(x)) + 2
      local w = math.max(2, floor(hh * .3))
      for yy = yb - hh, yb do
        local half = floor((yy - (yb - hh)) / hh * w + .5)
        for xx = x - half, x + half do px(xx, yy, (colLit and xx < x and yy < yb - 1) and colLit or col) end
      end
      x = x + 3 + floor(hash(x, 2, seed) * 5)
    end
  end
  if o.beforeMid then o.beforeMid() end
  setDepth(1)
  for i, tx in ipairs(o.farTrees or { 24, 52, 196, 290, 318, 352, 440 }) do tree(tx, floor(fMid(tx)) + 2, 16, i, true) end
  setDepth(0)
  -- the dunes behind the beach: golden marram crests, lit windward (left) slopes, sand blowouts, blade ticks
  local midM = HP.mask()
  for x = 0, W - 1 do
    local top = floor(fMid(x) + .5)
    local sl = fMid(x + 2) - fMid(x - 2)
    for y = top, HZ do
      if y < HZ then
        midM:set(x, y)
        local d = y - top
        local h = L.hillMid
        if sl > .6 then h = L.hillMidShade elseif sl < -.6 and d < 3 then h = L.marram.hi end
        local nv = vnoise(x / 9, y / 3, 33)
        if nv < .3 then h = sl > .6 and L.sand.shade or L.sand.hi end
        if hash(x, y, 34) < .1 then h = L.marram.shade end
        px(x, y, h)
      end
    end
    if top < HZ - 1 and hash(x, 3, 35) < .55 then
      local bh = 1 + floor(hash(x, 4, 35) * 3)
      vline(x, top - bh, top - 1, sl > .6 and L.marram.shade or L.marram.base)
    end
  end

  local groundCol = {}
  local function groundAt(x, y)
    local d = y - HZ + 2
    local base
    local f = (y - HZ - 1) / (H - 1 - HZ)
    if f < 1 / 13 then base = L.groundFar elseif f < 3 / 13 then base = L.ground.hi else base = L.ground.base end
    -- coast: low-frequency patches of pale sand (blowouts) and green dune turf, flattened by perspective
    local sy = 2 + d * .1
    local nv = vnoise(x / (sy * 5), y / sy, 5) + (hash(x, y, 6) - .5) * .08
    local sandy = false
    if nv < .34 then base = f < 3 / 13 and L.sand.hi or L.sand.base sandy = true
    elseif nv > .74 and f >= 1 / 13 then base = f < 3 / 13 and L.mossGround.hi or L.mossGround.base end
    local u = (x - VX) / d * 7
    if not sandy and y < 168 and abs(u - floor(u + .5)) < .06 + 1.2 / d and hash(x // 3, y // 2, 7) < .45 then return L.ground.shade end
    if hash(x, y, 1) < .02 + y / 9000 then return sandy and L.sand.shade or L.ground.shade end
    if hash(x, y + 1, 1) < .02 + (y + 1) / 9000 then return sandy and L.sand.hi or L.ground.hi end
    return base
  end
  -- coast: the ground is painted per pixel by groundAt (so eraseGround matches it exactly, patches included)
  for y = HZ + 1, H - 1 do for x = 0, W - 1 do px(x, y, groundAt(x, y)) end end
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
  -- coast ground detail: marram tufts (taller nearer), shingle, shells, sea thrift, driftwood sticks, wrack,
  -- turf with sea campion, wind ripples in the sand; far ground faint.
  local function groundDetail(x0, x1, y0, y1, seed)
    for i = 1, 700 do
      local x = x0 + floor(hash(i, 1, seed) * (x1 - x0))
      local y = y0 + floor(hash(i, 2, seed) ^ .7 * (y1 - y0))
      local near = (y - HZ) / (H - HZ)
      local kind = hash(i, 3, seed)
      if hash(i, 4, seed) < near * 1.2 then
        if kind < .30 then
          local th = 2 + floor(near * 6 * hash(i, 5, seed))
          if near > .3 then marram(x, y, th + 1) else vline(x, y - th, y, L.marram.shade) px(x, y - th, L.marram.hi) end
        elseif kind < .46 then pebbles(x, y, near > .5 and 3 or 1, i)
        elseif kind < .56 then shell(x, y, near > .45)
        elseif kind < .64 then if near > .3 then thrift(x, y, near > .6) else px(x, y, L.petal.base) end
        elseif kind < .71 then
          if near > .35 then local l = 3 + floor(near * 6) local dir = hash(i, 8, seed) < .5 and 1 or -1
            line({ { x, y }, { x + l * dir, y - 1 } }):each(function(xx, yy) px(xx, yy, L.timber.hi) end)
            line({ { x, y + 1 }, { x + l * dir, y } }):each(function(xx, yy) px(xx, yy, L.timber.deep) end)
          end
        elseif kind < .78 then if near > .3 then wrack(x, y, 3 + floor(near * 5), i) end
        elseif kind < .88 then
          px(x, y, L.leaf.base) px(x + 1, y, L.leaf.shade) px(x - 1, y, L.leaf.hi)
          if near > .5 then px(x, y - 1, L.awnB.hi) px(x + 2, y - 1, L.awnB.base) px(x + 1, y + 1, L.leaf.deep) end
        else
          local l = 2 + floor(near * 5)
          hline(x, x + l, y, L.sand.hi) hline(x + 1, x + l + 1, y + 1, L.sand.shade)
        end
      end
    end
  end
  groundDetail(0, W - 1, HZ + 8, H - 1, 401)
  -- coast: a dune line along the horizon (plane 1, hazed): low hummocks with marram, thrift and sand-fence stubs.
  -- Skips the road end; o.noDuneLine (or o.noTreeLine) turns it off, o.duneLineGap (or o.treeLineGap) = { x0, x1 }.
  if not (o.noDuneLine or o.noTreeLine) then
    local gp = o.duneLineGap or o.treeLineGap or { 220, 260 }
    setDepth(1)
    local x, i = 2, 0
    while x < W - 2 do
      i = i + 1
      local w = 6 + floor(hash(x, 3, 31) * 10)
      if x + w < gp[1] or x - w > gp[2] then
        local hh = 3 + floor(hash(x, 4, 31) * 5)
        local yb = HZ + 3 + floor(hash(x, 5, 31) * 2)
        local m = c:ellipse(x, yb, w, hh):clip(rect(x - w, yb - hh, x + w, yb))
        m:each(function(xx, yy)
          local lt = (xx - x) / w + (yy - yb) / hh * .6
          local h = lt < -.35 and L.marram.hi or (lt < .35 and L.marram.base or L.marram.shade)
          if vnoise(xx / 5, yy / 2, 36 + i) < .3 then h = lt < 0 and L.sand.hi or L.sand.base end
          px(xx, yy, h)
        end)
        for k = 1, w do
          local bx = x - w + floor(hash(k, i, 37) * 2 * w)
          for yy = yb - hh - 2, yb do if m:has(bx, yy) then vline(bx, yy - 1 - floor(hash(k, i, 38) * 3), yy, bx < x and L.marram.base or L.marram.deep) break end end
        end
        if hash(x, 6, 31) < .3 then px(x + 2, yb - hh, L.petal.base) end
        if hash(x, 7, 31) < .3 then vline(x + w - 2, yb - hh - 2, yb - hh + 2, L.timber.base) end
      end
      x = x + w + 3 + floor(hash(x, 6, 31) * 8)
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
      -- coast: blown sand drifted into the slab seams, crusts of orange lichen on some slabs
      if h == L.road.deep and hash(x, y, 24) < .3 then h = hash(x, y, 25) < .5 and L.sand.shade or L.sand.base
      elseif h ~= L.road.deep and hash(r1, u1, 26) < .22 and hash(x // 2, y, 27) < .14 then h = hash(x, y, 28) < .6 and L.lichen.shade or L.lichen.base end
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
    -- coast: fishing nets hung in swags under the beam (diamond mesh, cork-floated foot rope), a glass float in a
    -- rope cage and a hank of drying kelp at each side (replaces the forest pine boughs)
    netSwag(17, 98, 12, 16, { floatStep = 8 })
    netSwag(70, 128, 12, 8, { col = L.cork.shade, col2 = L.cork.deep, floatStep = 9 })
    netSwag(W - 99, W - 18, 12, 16, { floatStep = 8 })
    netSwag(W - 129, W - 71, 12, 8, { col = L.cork.shade, col2 = L.cork.deep, floatStep = 9 })
    for _, gfx in ipairs({ { 60, 34 }, { W - 61, 34 } }) do
      local gx, gy = gfx[1], gfx[2]
      vline(gx, 13, gy - 5, L.cork.deep)
      local gm = c:ellipse(gx, gy, 4, 4)
      c:rim(gm, L.glass.edge) part(gm, L.glass, { nopop = true })
      px(gx - 2, gy - 2, L.glass.hi) px(gx - 1, gy - 2, "#eefaf4") px(gx - 2, gy - 1, L.glass.hi)
      vline(gx, gy - 4, gy + 4, L.cork.deep) hline(gx - 4, gx + 4, gy, L.cork.deep) -- rope cage
    end
    for _, kx in ipairs({ 104, W - 105 }) do
      for k = 0, 4 do
        local len = 8 + floor(hash(k, kx, 90) * 9)
        for yy = 13, 13 + len do
          local xx = kx + k * 2 - 4 + floor(sin(yy * .5 + k) * 1.2)
          px(xx, yy, yy == 13 + len and L.kelp.deep or (k < 2 and L.kelp.hi or L.kelp.base))
          if k >= 2 then px(xx + 1, yy, L.kelp.shade) end
        end
      end
      hline(kx - 6, kx + 6, 13, L.cork.deep)
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
    -- coast: crusty orange and grey-green lichen on the stone courses (thicker high up, in the salt spray),
    -- a pale salt bloom along the mortar lines low down
    union(postL, postR):each(function(x, y)
      local ry = y % 9
      local dry = 1 - y / 222
      local v = hash(x // 2, (y + 1) // 3, 97)
      if ry ~= 0 and v < .025 + dry * .05 then local w = hash(x, y, 98) px(x, y, w < .3 and L.lichen.shade or (w < .5 and L.lichen.base or (w < .8 and L.moss.base or G.shade)))
      elseif ry == 1 and y > 150 and hash(x, y, 99) < .35 then px(x, y, L.chalk.base) end
    end)
    part(plL, G, { sep = true }) part(plR, G, { sep = true }) hline(0, 18, 218, G.hi) hline(W - 19, W - 1, 218, G.hi)
    for x = 0, W - 1 do if (x < 19 or x > W - 20) and hash(x, 219, 96) < .4 then px(x, 219, hash(x, 1, 96) < .5 and L.lichen.shade or L.sand.shade) end end
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
    -- forest additions (kept)
    conifer = conifer, pine = pine, birch = birch, fern = fern, mushroom = mushroom, logs = F_logs, logEnd = logEnd, moss = moss,
    ridge = ridge,
    -- coast additions
    windTree = windTree, marram = marram, thrift = thrift, shell = shell, pebbles = pebbles, driftwood = driftwood,
    wrack = wrack, lichen = lichen, barnacles = barnacles, cork = cork, boat = boat, gull = gull, netSwag = netSwag,
    lobsterPot = lobsterPot, pantile = pantile, cumulus = cumulus, cliffFace = cliffFace, SEA_Y = SEA_Y, SHORE_Y = SHORE_Y,
    seaWater = function(m, oo) F_water(m, L.sea, oo) m:each(function(x, y) if hash(x // 3, y, 88) < .05 and m:has(x, y - 2) then px(x, y, L.foam) end end) return m end,
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
      local col = b[4] or "#5e6670"
      px(x, y, col)
      for k = 1, w do px(x - k, y - (k == w and 1 or 0) - (k > 1 and 1 or 0) + (k == 1 and 0 or 0), col) px(x + k, y - (k > 1 and 1 or 0), col) end
    end
  end
  -- smoke column: puffs rising and drifting, lighter and smaller as they rise
  function F.smoke(x, y, n, drift, big)
    drift = drift or 1
    local cols = { "#98a4ac", "#b0bac2", "#c6ced4", "#dce2e6" } -- coast: pale blue-grey smoke, blown out to sea
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
    m:each(function(x, y) if not m:has(x - 1, y) or not m:has(x, y - 1) then local v = c:get(x, y) if v then rawput(c, x, y, mix(v, "#f8f2dc", k or .4)) end end end)
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
      if v then local _, _, l = toHsl(v) if l < .86 then rawput(c, x, y, mix(v, "#f8f2dc", .32)) end end
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
