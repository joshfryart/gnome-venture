-- _frame.lua : TUNDRA gate-view frame for the stop-type looks, palette "tundra_frost".
-- A copy of art-forest-stops/_frame.lua (itself a copy of the Maplewold art-2701-batch3/stops/opus3/_frame.lua)
-- with the same API and composition compass (horizon y=112, slab road, gate, bunting, lanterns, compass corner,
-- depth planes, rim light), re-skinned for an arctic tundra: pale aurora-tinted sky with a LOW sun upper left,
-- snowy fells, wind-sculpted snow ground with exposed lichen / moss / willow scrub, frosted slabs, snowy spruce
-- boughs and icicles on the gate, long lilac shadows, warm windows. F.tree draws stunted snowy spruces and bare
-- dwarf birch; building() roofs default to SOD with a snow cap (thatch / shingle still available).
-- New helpers: F.snowCap, F.icicles, F.drift, F.rubble, F.sod, F.willow, F.steam, F.tracks, F.cairn, F.fells
-- (plus the forest ones: F.conifer, F.pine, F.birch, F.fern, F.mushroom, F.logs, F.logEnd, F.moss, F.ridge).
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
  -- tundra_frost: same keys as Maplewold / forest so type scripts keep working; the MEANING of some keys shifts:
  -- ground = SNOW (cool white, lilac / blue shadows), roof = sod (straw-olive turf, wears a snow cap),
  -- roof2 = blue-grey slate, timber = silver driftwood, board = pale planks, plaster = lime render,
  -- wall2 = falu-red paint, leaf = rusty willow scrub, needle = rust lichen / bearberry, fern = dry sedge straw,
  -- moss = grey-green tundra moss, foliage = dark stunted spruce, foliage2 = frosted blue spruce, water = ice blue.
  local L = {
    sky = { "#a9b6d4", "#bcc6de", "#cfd4e4", "#e2dfe4", "#f0e2d4" },
    cloud = { top = "#f2eef0", under = "#c8c6dc" },
    hillFar = "#c6cade", hillMid = "#dee2ee", hillMidShade = "#bcc2da",
    ridgeFar = "#9ea6c4", ridgeMid = "#6c7a92", mist = "#e6e8f0", mist2 = "#d6dae8",
    peak = rp("#eceef4 #d2d6e6 #aab0cc #8890b2 #646c8e"), rock = rp("#a4a2b4 #82809a #64627e #4a4862 #302e44"),
    aurora = { "#c2e0d4", "#cecae6", "#b6d6d0", "#d6cee8" },
    farTree = rp("#b4c2cc #8ea0b2 #72869c #5a6c84 #44546c"),
    ground = rp("#eef0f6 #dce2ee #bcc4dc #98a0c2 #6e7698"), groundFar = "#e2e4ee",
    road = rp("#d6d8e2 #b2b6c8 #9094aa #6e7088 #4a4c64"), slabRatio = 1.06, slabK = 15,
    stone = rp("#d2d2dc #aaaabc #88889e #66667e #42425a"),
    plaster = rp("#f0eae2 #dad2c8 #b8b0aa #8c8490 #5a5464"),
    wall2 = rp("#dc8a70 #b45a48 #8a3e3a #622a30 #3e1a24"),
    timber = rp("#c8beb2 #a0968c #7a706c #565052 #322c38"),
    roof = rp("#d0c48c #a89a64 #7e744c #5a523c #36302a"),
    roof2 = rp("#acb4c6 #868ea4 #666c86 #4a4e66 #2e3046"),
    awnA = rp("#f08a78 #d6524a #aa3a3e #7a2a38 #4a1a28"),
    awnB = rp("#f4f0e2 #e2dccc #c2bcae #98948e #5e5a5e"),
    accent = rp("#8cbade #5a8cc4 #426ca4 #30507c #1e3254"),
    foliage = rp("#8eae98 #5e8272 #42625a #2e4648 #1c2e36"),
    foliage2 = rp("#a8c4c8 #76989e #557482 #3c5466 #263848"),
    leaf = rp("#e2b07a #c4844e #9a5e3c #6c4030 #442622"),
    water = rp("#e6f2f8 #b2d6e6 #80aed0 #5884ac #36567c"),
    glow = rp("#fff2c0 #ffd46e #f6a640 #d27630 #8a4626"),
    soil = rp("#a8887a #806458 #5e4842 #42302e #281c20"),
    board = rp("#eadcc0 #ccb898 #a69276 #7c6a5c #4e4042"),
    produce = rp("#ffb04a #f07c22 #c85a1e #943e1c #5e2618"),
    lav = rp("#d6ccf0 #ac98dc #8270ba #5c4c8c #3a2e5e"),
    iron = rp("#b4b8c0 #82889a #5e6476 #424858 #282c3c"),
    skin = rp("#ffe0bd #f0b98d #c98462 #7a4036 #4a2620"),
    apple = rp("#ff8a6c #e23c3a #b02436 #741c30 #4a1222"),
    petal = rp("#f8c4cc #ec8c9c #c86478 #94485e #5e2c40"),
    gold = rp("#f6e08a #e2be52 #b8923a #86662c #563f22"),
    -- tundra ramps (forest keys kept so forest scripts still run)
    snow = rp("#f4f6fa #e0e6f2 #c4cce2 #a0a8c8 #727a9c"),
    ice = rp("#eef6fa #cce2ee #a2c4dc #7898bc #4c6a90"),
    lichen = rp("#eadc9e #ccb66a #a68c4c #7a683c #4c4228"),
    rust = rp("#e8a274 #c87048 #9c4e38 #6e362e #44221e"),
    greyMoss = rp("#c8d0b0 #a2ae8e #7e8c70 #5c6a56 #3c4840"),
    moss = rp("#c8d0b0 #a2ae8e #7e8c70 #5c6a56 #3c4840"),
    birch = rp("#f0ece4 #d8d2cc #aea6a4 #7e7880 #4c4852"),
    birchLeaf = rp("#eac080 #cc9654 #a4703e #765034 #4a3228"),
    redbark = rp("#d8946e #b06648 #864a3c #5e3230 #3a1e22"),
    needle = rp("#e8a274 #c87048 #9c4e38 #6e362e #44221e"),
    fern = rp("#e6d8a4 #c8b47c #a08c5c #766644 #4a4232"),
    mossGround = rp("#c2c4a4 #a4a888 #84886c #626852 #42483c"), duff = "#9a8a7a",
    -- muted bare-ground tones for the wind-bared tundra patches (far .. near)
    tLichen = { "#dcd6c0", "#d2c69c", "#bcae84", "#a89a78" },
    tMoss = { "#ccd0c2", "#b8bea6", "#a2aa90", "#8c9680" },
    tRust = { "#dcc8c0", "#cca896", "#b48c7a", "#9c7466" },
    fur = rp("#f4f2ee #dcd8d4 #b8b2b4 #8c8692 #5a5464"),
    deer = rp("#c8b49c #a08670 #7a6252 #56443e #34282a"),
    shadow = "#b0b4d4", shadowRoad = "#8e92b0",
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
  local HAZE = "#dcdeec" -- tundra: cool lilac-blue frost haze

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

  -- tundra: the sun is low, so cast shadows are LONG (dx x2, dy x1.3) and soft: a core tone and a paler fringe tone
  local SHF, SHFR = "#c8cce2", "#a2a6c0"
  local function shadow(x0, x1, yb, dx, dy)
    local LX, LY = floor(dx * 2 + .5), floor(dy * 1.3 + .5)
    local m = poly{ { x0, yb - 2 }, { x1, yb - 2 }, { x1 + LX, yb + LY }, { x0 + LX, yb + LY } }
    local core = poly{ { x0, yb - 2 }, { x1, yb - 2 }, { x1 + dx, yb + dy }, { x0 + dx, yb + dy } }
    m:each(function(x, y)
      local inC = core:has(x, y)
      px(x, y, roadM:has(x, y) and (inC and L.shadowRoad or SHFR) or (inC and L.shadow or SHF))
    end)
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
    local maxW = o.w or math.max(3, floor(h * (o.slim and .2 or .27))) -- tundra: stunted, narrow spruces
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
    -- tundra: snow loading. Sky-exposed tier tops carry a 1-2 px snow crust (lit left, lilac right) with lumps;
    -- far trees get a single frosted pixel row. o.snow = false turns it off.
    if o.snow ~= false then
      local S = L.snow
      m:each(function(xx, yy)
        if not m:has(xx, yy - 1) then
          local lft = xx <= x
          if far then if hash(xx, yy, seed + 3) < .35 then px(xx, yy, lft and S.shade or r.hi) end
          else
            px(xx, yy, lft and S.hi or S.base)
            if m:has(xx, yy + 1) and hash(xx // 2, yy, seed + 4) < .55 then px(xx, yy + 1, lft and S.base or S.shade) end
            if m:has(xx, yy + 2) and hash(xx, yy, seed + 5) < .18 then px(xx, yy + 2, S.shade) end
          end
        end
      end)
    end
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
  -- tundra: a bare (dwarf) birch. White trunk with dark lenticel dashes, forked limbs, a fine fan of rust-brown
  -- twigs, a few last dry leaves, snow lying along the upper side of the limbs. Returns the twig-crown mask.
  local function birch(x, yb, h, seed)
    local top = yb - h
    local trunk = poly{ { x - 1, yb }, { x + 2, yb }, { x + 1, top + h * .35 }, { x, top + h * .35 } }
    local limbs, twigs = HP.mask(), HP.mask()
    local function branch(x0, y0, ang, len, depth)
      local x1, y1 = x0 + cos(ang) * len, y0 - sin(ang) * len
      local l = line({ { floor(x0 + .5), floor(y0 + .5) }, { floor(x1 + .5), floor(y1 + .5) } }, 1)
      if depth <= 1 then limbs:add(l) else twigs:add(l) end
      if depth < 4 and len > 2 then
        local k = 2 + (hash(depth, floor(x1), seed) < .5 and 1 or 0)
        for j = 1, k do
          local da = (j - (k + 1) / 2) * (.55 + .2 * hash(j, depth, seed)) + (hash(j, floor(y1), seed) - .5) * .3
          branch(x1, y1, ang + da, len * (.58 + .12 * hash(j, depth + 9, seed)), depth + 1)
        end
      end
    end
    local by = top + h * .38
    branch(x + .5, by, math.pi / 2 + .45, h * .3, 1)
    branch(x + .5, by, math.pi / 2 - .4, h * .32, 1)
    branch(x + .5, by + h * .12, math.pi / 2 - 1.0, h * .2, 2)
    branch(x + .5, by + h * .08, math.pi / 2 + 1.05, h * .18, 2)
    twigs:cut(limbs):cut(trunk)
    rimOf(union(trunk, limbs), L.birch)
    part(trunk, L.birch, { nopop = true, noshade = true })
    trunk:each(function(xx, yy)
      if xx > x then px(xx, yy, L.birch.shade) end
      if hash(yy // 2, 0, seed) < .28 and hash(xx, yy, seed) < .7 then px(xx, yy, L.birch.edge) end
    end)
    limbs:each(function(xx, yy) px(xx, yy, hash(xx, yy, seed + 1) < .3 and L.birch.edge or L.birch.shade) end)
    twigs:each(function(xx, yy) px(xx, yy, hash(xx, yy, seed + 2) < .5 and L.redbark.shade or L.redbark.deep) end)
    -- tips of the finest twigs: a purple-brown haze pixel, a few dry leaves
    twigs:each(function(xx, yy)
      if not twigs:has(xx, yy - 1) and hash(xx, yy, seed + 3) < .25 then px(xx, yy - 1, L.redbark.base) end
      if hash(xx, yy, seed + 6) < .05 then px(xx, yy, L.birchLeaf.base) end
    end)
    -- snow along the upper side of trunk fork and limbs
    union(limbs, trunk):each(function(xx, yy)
      if yy < by + 4 and not limbs:has(xx, yy - 1) and not trunk:has(xx, yy - 1) and hash(xx, yy, seed + 4) < .5 then px(xx, yy - 1, L.snow.hi) end
    end)
    return union(limbs, twigs)
  end
  -- tundra: dwarf willow / birch scrub. A low clump of rust-red stems fanning up from the snow, finer twig tips,
  -- snow caught in the crotches and banked at the foot. w = half width, h = height. Returns the clump mask.
  local function willow(x, yb, w, h, seed, r)
    r = r or L.leaf
    seed = seed or 5
    local m = HP.mask()
    local n = math.max(4, floor(w * 1.2))
    for i = 1, n do
      local t = (i - .5) / n * 2 - 1
      local x1 = x + t * w + (hash(i, 1, seed) - .5) * 3
      local y1 = yb - h * (1 - t * t * .45) * (.7 + .3 * hash(i, 2, seed))
      local l = line({ { x + floor(t * 2), yb }, { floor(x1), floor(y1) } }, 1)
      m:add(l)
      if h > 6 then
        local mx, my = floor(x + (x1 - x) * .6), floor(yb + (y1 - yb) * .6)
        m:add(line({ { mx, my }, { mx + (t < 0 and -2 or 2), my - 3 } }, 1))
      end
    end
    m:each(function(xx, yy)
      local v = hash(xx, yy, seed)
      local lit = xx < x
      px(xx, yy, v < .25 and (lit and r.hi or r.base) or (v < .7 and r.base or (lit and r.shade or r.deep)))
    end)
    m:each(function(xx, yy) if not m:has(xx, yy - 1) and hash(xx, yy, seed + 1) < .35 then px(xx, yy - 1, r.shade) end end)
    -- snow lumps in the crotches and a little drift at the foot
    for k = 1, floor(w / 2) + 1 do
      local sx = x + floor((hash(k, 3, seed) - .5) * w * 1.4)
      local sy = yb - floor(hash(k, 4, seed) * h * .6)
      if m:has(sx, sy) then px(sx, sy - 1, L.snow.hi) px(sx + 1, sy - 1, L.snow.base) end
    end
    local d = c:ellipse(x + 1, yb, w + 1, 2):clip(rect(x - w - 2, yb - 2, x + w + 3, yb))
    fill(d, L.snow.base) hline(x - w + 1, x + 1, yb - 2, L.snow.hi)
    d:each(function(xx, yy) if xx > x + w // 2 and yy == yb then px(xx, yy, L.snow.shade) end end)
    return m
  end
  -- F.tree: tundra default. seed%4: 0,2 = frosted blue spruce (foliage2), 1 = dark spruce (foliage),
  -- 3 = bare dwarf birch. far = hazed little snowy spruce.
  local function tree(x, yb, h, seed, far)
    if far then return conifer(x, yb, h, L.farTree, seed, { far = true, slim = true }) end
    local k = seed % 4
    if k == 3 then return birch(x, yb, h, seed) end
    return conifer(x, yb, h, k == 1 and L.foliage or L.foliage2, seed, { slim = h > 40 })
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

  -- ======== tundra helpers ========
  -- snow cap: the top d px of every column of mask m (lumpy: +-1 px by column groups), lit side snow.hi, the far
  -- side snow.base, a lilac underside line. o.cx = x where the lit side ends (default bbox centre), o.lip = an
  -- overhang of 1 px past the sides at the very top. Returns the snow mask.
  local function snowCap(m, d, seed, o)
    o = o or {}
    seed = seed or 51
    local b = { m:bbox() }
    local cx = o.cx or (((b[1] or 0) + (b[3] or 0)) / 2)
    local S = HP.mask()
    m:each(function(x, y)
      local dd = d + (hash(x // 3, 0, seed) < .35 and 1 or 0) - (hash(x // 4, 1, seed) < .2 and 1 or 0)
      local k = 0
      while k < dd and m:has(x, y - k - 1) do k = k + 1 end
      if k < dd then S:set(x, y) end
    end)
    newObj()
    S:each(function(x, y)
      local top = not S:has(x, y - 1)
      local bot = not S:has(x, y + 1)
      local lit = x < cx
      local h
      if top then h = lit and L.snow.hi or L.snow.base
      elseif bot then h = lit and L.snow.shade or L.snow.deep
      else h = lit and (hash(x, y, seed) < .2 and L.snow.hi or L.snow.base) or (hash(x, y, seed) < .3 and L.snow.base or L.snow.shade) end
      px(x, y, h)
    end)
    if o.lip then
      S:each(function(x, y)
        if not S:has(x, y - 1) and not m:has(x - 1, y) then px(x - 1, y, L.snow.hi) px(x - 1, y + 1, L.snow.shade) end
        if not S:has(x, y - 1) and not m:has(x + 1, y) then px(x + 1, y, L.snow.base) px(x + 1, y + 1, L.snow.deep) end
      end)
    end
    return S
  end
  -- icicles hanging from y along x0..x1: random lengths up to maxLen, lit stem, darker tip, every few px
  local function icicles(x0, x1, y, maxLen, seed, dens)
    seed = seed or 52
    newObj()
    for x = x0, x1 do
      if hash(x, y, seed) < (dens or .45) then
        local len = 1 + floor(hash(x, 2, seed) ^ 1.6 * maxLen)
        for k = 0, len - 1 do
          px(x, y + k, k == len - 1 and L.ice.deep or (k == 0 and L.ice.hi or (k % 3 == 1 and L.ice.base or L.ice.shade)))
        end
        if len > 3 and hash(x, 3, seed) < .5 then px(x + 1, y, L.ice.base) px(x + 1, y + 1, L.ice.shade) end
      end
    end
  end
  -- a wind-sculpted snowdrift on the ground: gentle windward slope on the left, steep leeward right side with a
  -- cornice lip, ripples, lilac lee shadow. (x = crest x, yb = foot line, w = half width, h = height)
  local function drift(x, yb, w, h, seed)
    seed = seed or 53
    local m = poly{ { x - w, yb }, { x - w * .55, yb - h * .55 }, { x - w * .1, yb - h }, { x + w * .25, yb - h - 1 },
      { x + w * .32, yb - h + 1 }, { x + w * .45, yb - h * .45 }, { x + w, yb } }
    newObj()
    m:each(function(xx, yy)
      local u = (xx - x) / w
      local h0
      if u < .28 then
        local f = (yb - yy) / math.max(1, h)
        h0 = (f > .55 and hash(xx, yy, seed) < .7) and L.snow.hi or L.snow.base
        if (yy + floor(xx * .35)) % 4 == 0 and hash(xx // 3, yy, seed) < .55 then h0 = L.snow.shade end -- wind ripples
      else
        h0 = u < .5 and L.snow.shade or (hash(xx, yy, seed) < .25 and L.snow.shade or L.snow.deep)
      end
      px(xx, yy, h0)
    end)
    -- cornice lip highlight + its undercut shadow
    for xx = floor(x - w * .1), floor(x + w * .3) do
      local top
      for yy = yb - h - 2, yb do if m:has(xx, yy) then top = yy break end end
      if top then px(xx, top, L.snow.hi) end
    end
    for xx = floor(x + w * .26), floor(x + w * .5) do if m:has(xx, yb - floor(h * .6)) then px(xx, yb - floor(h * .6), L.snow.edge) end end
    hline(floor(x + w * .2), floor(x + w), yb, L.snow.deep)
    return m
  end
  -- rubble stone wall texture: irregular rows (rowH px), stones of varying length, mortar lines, each stone
  -- lit top-left, some stones tinted (rust lichen, grey-green moss), a frost line on the top of each row.
  local function rubble(m, r, y0, rowH, seed)
    r = r or L.stone
    rowH = rowH or 5
    seed = seed or 54
    local tint = { L.lichen, L.greyMoss }
    m:each(function(x, y)
      local row = (y - y0) // rowH
      local ry = (y - y0) % rowH
      local off = floor(hash(row, 1, seed) * 9)
      local sw = 6 + floor(hash(row, 2, seed) * 4)
      local s = (x + off) // sw
      local sx = (x + off) % sw
      local h
      if ry == rowH - 1 or (sx == 0 and hash(s, row, seed) < .8) then h = r.deep
      else
        local v = hash(s, row, seed + 1)
        h = v < .3 and r.hi or (v > .78 and r.shade or r.base)
        if ry == 0 and sx > 0 then h = r.hi end
        if (sx == sw - 1 or ry == rowH - 2) and v < .6 then h = r.shade end
        local tv = hash(s, row, seed + 2)
        if tv < .14 and hash(x, y, seed) < .6 then h = tint[1 + floor(tv * 14) % 2].base end
      end
      if ry == 0 and hash(x // 2, row, seed + 3) < .35 then h = L.snow.base end -- frost on the course tops
      px(x, y, h)
    end)
  end
  -- sod roof texture: straw-olive turf strands, darker matted rows, tufts curling over the eave (r = L.roof)
  local function sod(m, r, y0, cx)
    r = r or L.roof
    m:each(function(x, y)
      local row = (y - y0) // 5
      local ry = (y - y0) % 5
      local h
      if ry == 4 and hash(x, row, 55) < .55 then h = r.deep
      elseif (x * 2 + y + row) % 5 == 0 and hash(x, y, 56) < .6 then h = r.shade
      elseif ry == 0 and hash(x, y, 57) < .35 then h = (x < (cx or 9999)) and r.hi or r.base
      elseif hash(x, y, 58) < .05 then h = L.greyMoss.base end
      if x > (cx or 9999) + 2 and ry == 2 and hash(x, y, 59) < .4 then h = r.deep end
      if h then px(x, y, h) end
    end)
  end
  -- steam rising off warm water / a vent: soft pale wisps, drifting right, thinning as they rise (no smoke tint)
  local function steam(x, y, n, drift, seed)
    drift = drift or .6
    seed = seed or 60
    local cols = { "#e4e8f2", "#eceef6", "#f2f2f8" }
    newObj()
    for i = 0, n - 1 do
      local cx = x + floor(drift * i * 1.4 + 2 * sin(i * 1.1 + seed))
      local cy = y - i * 3
      local w = 2 + (i % 3) + floor(i / 3)
      for xx = cx - w, cx + w do
        if hash(xx, cy, seed) < .78 - i * .04 then px(xx, cy, cols[1 + (i // 3) % 3]) end
        if hash(xx, cy - 1, seed) < .45 - i * .04 and abs(xx - cx) < w - 1 then px(xx, cy - 1, cols[1 + ((i // 3) + 1) % 3]) end
      end
    end
  end
  -- tracks pressed into snow along a polyline: kind "hare" (Y-shaped hop groups), "deer" (paired slots),
  -- "bird" (little arrows), "boot" (gnome boot prints). step = px between prints.
  local function tracks(pts, kind, step)
    step = step or 6
    newObj()
    local acc = 0
    for i = 1, #pts - 1 do
      local a, b = pts[i], pts[i + 1]
      local len = math.sqrt((b[1] - a[1]) ^ 2 + (b[2] - a[2]) ^ 2)
      local d = acc
      while d < len do
        local t = d / len
        local x, y = floor(a[1] + (b[1] - a[1]) * t + .5), floor(a[2] + (b[2] - a[2]) * t + .5)
        local sh, hi = L.snow.shade, L.snow.hi
        if kind == "hare" then px(x, y, sh) px(x + 2, y, sh) px(x + 1, y + 2, sh) px(x + 1, y + 3, sh) px(x, y + 1, hi)
        elseif kind == "deer" then px(x, y, sh) px(x + 1, y, L.snow.deep) px(x + 3, y + 1, sh) px(x + 4, y + 1, L.snow.deep)
        elseif kind == "bird" then px(x, y, sh) px(x - 1, y + 1, sh) px(x + 1, y + 1, sh) px(x, y + 1, sh)
        else px(x, y, sh) px(x + 1, y, sh) px(x, y + 1, L.snow.deep) px(x + 1, y - 1, hi) end
        d = d + step
      end
      acc = d - len
    end
  end
  -- a stone cairn: stacked flat stones, each lit top-left, snow on every top, lichen spots. Returns its mask.
  local function cairn(x, yb, h, seed)
    seed = seed or 61
    local m, rows, y = HP.mask(), {}, yb
    local n = math.max(3, floor(h / 4))
    for i = 1, n do
      local w = floor((n - i + 2) * 1.6 + hash(i, 1, seed) * 2)
      local sh = 3 + (hash(i, 2, seed) < .4 and 1 or 0)
      local ox = floor((hash(i, 3, seed) - .5) * 2)
      local r = c:rrect(x - w + ox, y - sh, x + w + ox, y, 1)
      rows[i] = r m:add(r)
      y = y - sh + 1
    end
    c:rim(m, L.stone.edge)
    for i, r in ipairs(rows) do part(r, L.stone, { nopop = true, sep = true }) end
    for _, r in ipairs(rows) do
      r:each(function(xx, yy)
        if not m:has(xx, yy - 1) then px(xx, yy, xx < x + 2 and L.snow.hi or L.snow.base) end
        if hash(xx, yy, seed) < .08 then px(xx, yy, L.lichen.base) end
      end)
    end
    return m
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
    elseif b.thatch then F_thatch(roofM, rr, top - rh, cx)
    else sod(roofM, rr, top - rh, cx) end -- tundra default: sod roof
    -- plaster wall texture: lime wash patches, a lath crack, damp darker base
    wallM:each(function(x, y)
      local v = hash(x, y, 41)
      if y <= top + 3 then return end
      if y >= yb - 3 and hash(x // 2, y, 42) < .4 then px(x, y, wr.shade)
      elseif hash(x // 4, y, 41) < .03 then px(x, y, wr.hi) end
    end)
    line({ { x0 - 2, top + 2 }, { cx, top - rh + 1 } }):each(function(x, y) if roofM:has(x, y) then px(x, y, rr.hi) end end)
    hline(x0 - 3, x1 + 3, top + 3, rr.deep)
    -- tundra: snow cap on the roof (b.noSnow to skip; b.snow = depth, default 3) and icicles along the eave
    if not b.noSnow then
      snowCap(roofM, b.snow or 3, x0 + x1, { cx = cx + 1 })
      icicles(x0 - 2, x1 + 2, top + 4, b.icicles or 4, x0 + 7)
      if chim then snowCap(chim, 2, x1, { cx = x1 - 9 }) end
    end
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

  ---------------------------------------------------------------- BACKGROUND (tundra: pale aurora-tinted sky, low sun, snowy fells)
  c:stripes(0, HZ, L.sky, { 3, 3, 3, 2, 2 })
  -- faint daylight aurora: two hanging curtains in the upper sky, green at the top fading to lilac (o.noAurora)
  if not o.noAurora then
    for k, au in ipairs({ { 16, 60, 1.3, 0 }, { 30, 44, 2.1, 210 } }) do
      for x = 0, W - 1 do
        local yc = floor(au[1] + 7 * sin((x + au[4]) / au[2]) + 3 * sin(x / 17 + au[3]))
        local len = 6 + floor(vnoise(x / 11, k, 41) * 14)
        local on = vnoise(x / 9, k * 3, 42)
        if on > .44 then
          for y = yc, yc + len do
            local t = (y - yc) / len
            local col = t < .5 and L.aurora[k == 1 and 1 or 3] or L.aurora[k == 1 and 2 or 4]
            if hash(x // 2, k, 45) < .3 then col = t < .5 and L.aurora[k == 1 and 3 or 1] or L.aurora[k == 1 and 4 or 2] end -- rays
            if on < .5 and t > .5 then col = nil end -- thin at the curtain's ends
            if col then px(x, y, col) end
          end
        end
      end
    end
  end
  -- the LOW sun, upper left, sitting just above the fells: halo rings, a sun pillar, two faint sun dogs
  if not o.noSun then
    local sx, sy = o.sunX or 72, o.sunY or 80
    for y = sy - 28, sy - 8 do
      local w = (y > sy - 16) and 2 or 1
      for x = sx - w, sx + w do if hash(x, y, 44) < .9 - (sy - y) * .02 then px(x, y, abs(x - sx) < 2 and "#f2e2dc" or "#e8dee2") end end
    end
    fill(c:ellipse(sx, sy, 15, 13), "#eedcd4") fill(c:ellipse(sx, sy, 11, 10), "#f2e2d6") fill(c:ellipse(sx, sy, 7, 7), "#f6e8da")
    fill(c:ellipse(sx, sy, 4, 4), "#fcf2e2")
    for _, dx in ipairs({ -27, 27 }) do
      vline(sx + dx, sy - 4, sy + 3, "#f2dcd2") vline(sx + dx + 1, sy - 3, sy + 2, "#e2dcee") px(sx + dx, sy - 1, "#f8e8dc")
    end
  end
  -- long thin stratus streaks, their undersides catching the low sun on the left
  for _, cl in ipairs(o.clouds or { { 130, 40, 60 }, { 300, 24, 70 }, { 400, 58, 36 }, { 20, 58, 40 } }) do
    local x, y, w = cl[1], cl[2], cl[3]
    local m = c:rrect(x - w // 4, y - 3, x + w + w // 4, y, 1):add(c:rrect(x + w // 6, y - 6, x + w * 3 // 4, y - 2, 2))
    fill(m, L.cloud.top)
    hline(x - w // 4 + 2, x + w + w // 4 - 2, y, L.cloud.under)
    for xx = x - w // 4 + 2, x + w // 3 do if hash(xx, y, 46) < .6 then px(xx, y, "#f0d8cc") end end
    m:each(function(xx, yy) if hash(xx // 3, yy, 9) < .1 and yy < y - 1 then px(xx, yy, L.sky[4]) end end)
    hline(x + w + w // 4, x + w + w // 4 + w // 3, y - 1, L.cloud.under)
  end
  local function fFar(x) return HZ - 16 + 6 * sin(x / 37) + 4 * sin(x / 13 + 1) end
  local function fMid(x) return HZ - 6 + 4 * sin(x / 29 + 2) + 3 * sin(x / 11) end
  -- conifer silhouette ridge (kept from forest; tundra uses it sparsely). keep(x) -> false skips a spire.
  local function ridge(f, col, colLit, seed, hmin, hmax, keep, gapMin)
    local x = -4
    while x < W + 4 do
      local hh = hmin + floor(hash(x, 1, seed) * (hmax - hmin))
      local yb = floor(f(x)) + 2
      local w = math.max(2, floor(hh * .3))
      if not keep or keep(x) then
        for yy = yb - hh, yb do
          local half = floor((yy - (yb - hh)) / hh * w + .5)
          if (yy - (yb - hh)) % 3 == 2 then half = half + 1 end -- tier tips
          for xx = x - half, x + half do px(xx, yy, (colLit and xx < x and yy < yb - 1) and colLit or col) end
        end
      end
      x = x + (gapMin or 3) + floor(hash(x, 2, seed) * 5)
    end
  end
  -- snowy fells behind the far hills: jagged peaks, lit snow faces to the upper left, lilac shadow faces,
  -- rock gullies and ribs. o.peaks = { {cx, height, halfWidth}, ... }, o.noPeaks.
  local function fells(list)
    local function peakAt(x)
      local best, bi = HZ - 12, nil
      for i, p in ipairs(list) do
        local t = 1 - abs(x - p[1]) / p[3]
        if t > 0 then
          local y = HZ - 14 - p[2] * t ^ 1.15 + (vnoise(x / 3, i, 47) - .5) * 3 * t
          if y < best then best, bi = y, i end
        end
      end
      return best, bi
    end
    for x = 0, W - 1 do
      local yt, i = peakAt(x)
      if i then
        local p = list[i]
        local yt0 = floor(yt + .5)
        local lit = x < p[1] + (vnoise(x / 4, 2, 48) - .5) * 4
        for y = yt0, HZ - 8 do
          local f = (y - yt0) / math.max(1, HZ - 8 - yt0)
          local h = lit and L.peak.base or L.peak.shade
          if lit and y - yt0 < 2 then h = L.peak.hi end
          local fall = (y - yt0) * (lit and .7 or -.7) -- gullies run down the fall line of each face
          local g = vnoise((x + fall) / 2.6, y / 11, 49 + i) + (hash(x, y, 50) - .5) * .06
          if g > .74 - f * .12 then h = lit and L.rock.hi or L.rock.base
          elseif g > .68 - f * .1 then h = lit and L.peak.shade or L.peak.deep end
          if not lit and y - yt0 < 1 then h = L.peak.base end
          px(x, y, h)
        end
      end
    end
  end
  if not o.noPeaks then fells(o.peaks or { { 150, 40, 46 }, { 196, 26, 30 }, { 290, 46, 54 }, { 352, 30, 34 }, { 432, 50, 52 }, { 14, 20, 26 } }) end
  local farM = c:terrain(fFar, L.hillFar, HZ)
  farM:each(function(x, y) if y <= floor(fFar(x) + .5) then px(x, y, L.mist) elseif (x * 2 + y * 5) % 31 == 0 then px(x, y, L.ridgeFar) end end)
  ridge(fFar, L.ridgeFar, nil, 21, 4, 9, function(x) return vnoise(x / 26, 1, 22) > .62 end)
  for y = HZ - 15, HZ - 10 do for x = 0, W - 1 do if hash(x // 9, y, 23) < .3 then px(x, y, L.mist) end end end
  if o.beforeMid then o.beforeMid() end
  setDepth(1)
  ridge(function(x) return fMid(x) + 1 end, L.ridgeMid, L.hillMidShade, 27, 4, 10, function(x) return vnoise(x / 22, 2, 28) > .58 end, 4)
  for i, tx in ipairs(o.farTrees or { 24, 52, 196, 290, 318, 352, 440 }) do tree(tx, floor(fMid(tx)) + 2, 22, i, true) end
  setDepth(0)
  local midM = c:terrain(fMid, L.hillMid, HZ)
  -- wind-carved snow on the mid rises: a lit crest line, lilac lee hollows
  midM:each(function(x, y)
    local top = floor(fMid(x) + .5)
    if y == top then px(x, y, L.snow.hi)
    elseif fMid(x + 1) > fMid(x) and y < top + 3 then px(x, y, L.hillMidShade)
    elseif (x + y * 3) % 23 == 0 then px(x, y, L.hillMidShade) end
  end)
  -- spindrift lying in the back rows: long low streaks at the foot of the mid rises
  for y = HZ - 6, HZ - 1 do
    for x = 0, W - 1 do
      local v = hash(x // 14, y, 25)
      if v < .4 - (HZ - y) * .05 then px(x, y, (y % 2 == 0) and L.mist or L.mist2) end
    end
  end

  local groundCol = {}
  local function groundAt(x, y)
    local d = y - HZ + 2
    local base
    local f = (y - HZ - 1) / (H - 1 - HZ)
    local near = f >= 3 / 13
    if f < 1 / 13 then base = L.groundFar elseif not near then base = L.ground.hi else base = L.ground.base end
    -- tundra: low-frequency patches where the wind has bared the ground (lichen ochre, grey-green moss, rusty
    -- bearberry), thin snow at their edges, bright wind-packed crests; flattened by perspective
    local sy = 2 + d * .1
    local nv = vnoise(x / (sy * 5), y / sy, 5) + (hash(x, y, 6) - .5) * .08
    if f >= 1 / 13 then
      if nv < .25 then
        local n2 = vnoise(x / (sy * 3), y / sy, 9)
        local r = n2 < .42 and L.tLichen or (n2 < .74 and L.tMoss or L.tRust)
        local v = hash(x, y, 7)
        base = near and (v < .55 and r[2] or (v < .85 and r[3] or r[4])) or (v < .6 and r[1] or r[2])
        if nv > .22 and hash(x, y, 8) < .55 then base = L.ground.shade end
        return base
      elseif nv < .29 then
        if hash(x, y, 8) < .3 then return L.ground.shade end
      elseif nv > .74 then base = near and L.ground.hi or L.snow.hi end
      -- sastrugi: wind ripples, spacing grows toward the viewer
      local per = 3 + floor(d / 18)
      if (y + floor(vnoise(x / 26, y / 5, 11) * 5)) % per == 0 and hash(x // 5, y, 12) < .42 then return near and L.ground.shade or L.ground.base end
    end
    if hash(x, y, 1) < .005 + y / 24000 then return L.ground.shade end
    if hash(x, y + 1, 1) < .005 + (y + 1) / 24000 then return L.snow.hi end
    return base
  end
  -- tundra: the ground is painted per pixel by groundAt (so eraseGround matches it exactly, patches included)
  for y = HZ + 1, H - 1 do for x = 0, W - 1 do px(x, y, groundAt(x, y)) end end
  -- fern() is kept from forest (now draws a dry sedge / grass clump in straw tones); mushroom() is kept for API
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
  -- tundra ground detail: sedge tufts poking through the snow, lichen clumps, dwarf willow sprigs, snow-capped
  -- stones, red crowberries, little frozen pools, wind-packed snow lips, cotton grass. Far ground faint.
  local function groundDetail(x0, x1, y0, y1, seed)
    for i = 1, 700 do
      local x = x0 + floor(hash(i, 1, seed) * (x1 - x0))
      local y = y0 + floor(hash(i, 2, seed) ^ .7 * (y1 - y0))
      local near = (y - HZ) / (H - HZ)
      local kind = hash(i, 3, seed)
      if hash(i, 4, seed) < near * 1.2 then
        if kind < .26 then
          local th = 2 + floor(near * 4 * hash(i, 5, seed))
          local r = L.fern
          vline(x, y - th, y, r.shade) px(x, y - th, r.hi)
          if near > .4 then vline(x - 1, y - th + 2, y, r.base) px(x + 1, y - th + 1, r.deep) vline(x + 1, y - th + 2, y, r.shade) end
          px(x - 1, y + 1, L.snow.hi) px(x, y + 1, L.snow.base) px(x + 1, y + 1, L.snow.shade)
        elseif kind < .42 then
          local r = ({ L.lichen, L.greyMoss, L.rust })[1 + floor(hash(i, 6, seed) * 3)]
          px(x, y, r.base) px(x + 1, y, r.shade) px(x - 1, y, r.hi) px(x, y - 1, r.hi)
          if near > .5 then px(x + 2, y, r.shade) px(x - 2, y + 1, r.base) px(x + 1, y + 1, r.deep) px(x - 1, y + 1, r.base) end
        elseif kind < .54 then
          if near > .3 then
            local r = L.leaf
            local th = 2 + floor(near * 5)
            local dir = hash(i, 8, seed) < .5 and 1 or -1
            for k = 0, th do px(x + (k // 2) * dir, y - k, k == th and r.hi or r.shade) end
            px(x + dir * (th // 2) - dir, y - th + 1, r.base) px(x - dir, y - th // 2, r.deep)
            px(x - 1, y + 1, L.snow.hi) px(x + 1, y + 1, L.snow.shade)
          end
        elseif kind < .64 then
          px(x, y, L.stone.base) px(x + 1, y, L.stone.shade) px(x, y - 1, L.snow.hi)
          if near > .5 then px(x + 2, y, L.stone.deep) px(x + 1, y - 1, L.snow.base) px(x - 1, y, L.stone.hi) px(x + 3, y, L.snow.shade) end
        elseif kind < .70 then
          if near > .35 then px(x, y, L.greyMoss.base) px(x + 1, y, L.greyMoss.shade) px(x, y - 1, L.apple.base) px(x + 2, y - 1, L.apple.shade) px(x - 1, y, L.lav.shade) end
        elseif kind < .75 then
          if near > .4 then
            local w = 2 + floor(near * 5 * hash(i, 9, seed))
            local m = c:ellipse(x, y, w, math.max(1, w // 3))
            fill(m, L.ice.base)
            m:each(function(xx, yy) if not m:has(xx, yy - 1) then px(xx, yy, L.ice.shade) elseif not m:has(xx, yy + 1) then px(xx, yy, L.ice.hi) end end)
            px(x - w // 2, y, L.ice.hi) hline(x - w + 1, x + w - 1, y + math.max(1, w // 3) + 1, L.snow.hi)
          end
        elseif kind < .88 then
          local w = 1 + floor(near * 4)
          hline(x - w, x + w, y, L.snow.hi) hline(x - w + 1, x + w + 1, y + 1, L.ground.shade)
        else
          if near > .3 then local th = 3 + floor(near * 4)
            vline(x, y - th, y, L.fern.shade) px(x, y - th - 1, L.awnB.hi) px(x + 1, y - th - 1, L.awnB.base) px(x, y - th - 2, L.awnB.hi)
          end
        end
      end
    end
  end
  groundDetail(0, W - 1, HZ + 8, H - 1, 401)
  -- tundra: a sparse horizon line of stunted spruce clumps, willow scrub and low drifts (plane 1, hazed).
  -- Skips the road end; o.noTreeLine turns it off, o.treeLineGap = { x0, x1 } changes the gap (default 220..260).
  if not o.noTreeLine then
    local g0, g1 = (o.treeLineGap or { 220, 260 })[1], (o.treeLineGap or { 220, 260 })[2]
    setDepth(1)
    local x, i = 2, 0
    while x < W - 2 do
      i = i + 1
      if x < g0 or x > g1 then
        local yb = HZ + 3 + floor(hash(x, 4, 31) * 3)
        if vnoise(x / 34, 3, 32) > .5 then
          local hh = 10 + floor(hash(x, 3, 31) * 14)
          conifer(x, yb, hh, hash(x, 5, 31) < .5 and L.foliage2 or L.farTree, 300 + i, { slim = true })
        else
          willow(x, yb, 3 + floor(hash(x, 7, 31) * 4), 3 + floor(hash(x, 8, 31) * 3), 300 + i)
        end
      end
      x = x + 6 + floor(hash(x, 6, 31) * 10)
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
      -- tundra: snow packed into the slab seams, rime frost on some faces, a few slabs glazed with ice
      if h == L.road.deep and hash(x, y, 24) < .3 then h = L.snow.shade
      elseif h ~= L.road.deep then
        local g = hash(r1, u1, 28)
        if g < .12 then h = (h == L.road.hi) and L.ice.hi or (hash(x, y, 29) < .2 and L.ice.hi or L.ice.base)
        elseif hash(r1, u1, 26) < .3 and hash(x, y, 27) < .14 then h = L.snow.base end
      end
      px(x, y, h)
    end)
    for y = yTop, math.min(H - 1, yBot) do
      px(floor(xl(y)), y, L.road.edge) px(floor(xl(y)) - 1, y, L.ground.deep)
      px(floor(xr(y) + .99), y, L.road.edge) px(floor(xr(y) + .99) + 1, y, L.ground.deep)
      -- ploughed snow banked along both verges (lit on the left verge, lilac on the right)
      local bw = 1 + floor((y - yTop) / 40)
      for k = 1, bw do
        if hash(y // 3, k, 34) < .8 then px(floor(xl(y)) - 1 - k, y, k == bw and L.snow.base or L.snow.hi) end
        if hash(y // 3, k, 35) < .8 then px(floor(xr(y) + .99) + 1 + k, y, k == 1 and L.snow.shade or L.snow.base) end
      end
    end
    return m
  end
  if not o.noRoad then drawRoad(ROAD_TOP, H - 1) end

  ---------------------------------------------------------------- gate frame (drawn in finish)
  local function gate()
    local G = L.stone
    -- tundra: snow-laden spruce boughs over the beam corners, needle fringes, a heavy snow cap on each
    local boughs = { { 56, 18, 34, 12, L.foliage, 91 }, { 110, 14, 22, 8, L.foliage2, 92 }, { 428, 18, 34, 12, L.foliage2, 93 }, { 378, 14, 20, 8, L.foliage, 94 } }
    for _, b in ipairs(boughs) do
      local m = crown(b[1], b[2], b[3], b[4], b[5], b[6])
      local r = b[5]
      m:each(function(x, y)
        if not m:has(x, y + 1) and y > 12 and hash(x, y, b[6]) < .55 then
          local len = 1 + floor(hash(x, 1, b[6]) * 3)
          for k = 1, len do px(x, y + k, k == len and r.edge or r.deep) end
        elseif (x + y * 2) % 5 == 0 and hash(x, y, b[6] + 1) < .5 then px(x, y, (x - b[1]) < 0 and r.hi or r.shade) end
      end)
      snowCap(m:copy():clip(rect(0, 13, W - 1, H - 1)), 3, b[6], { cx = b[1] + 2 })
      -- snow clumps resting on the lower boughs
      for k = 1, 4 do
        local sx = b[1] + floor((hash(k, 5, b[6]) - .5) * b[3] * 1.4)
        local sy = b[2] + floor(hash(k, 6, b[6]) * b[4] * .8)
        if m:has(sx, sy) and m:has(sx + 2, sy) then hline(sx, sx + 2, sy, L.snow.hi) hline(sx, sx + 2, sy + 1, L.snow.shade) end
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
    -- tundra: snow lodged on the stone course ledges (more higher up, where the wind drops it), rime frost
    -- speckle on the windward (outer) faces, a few rust lichen spots low down
    union(postL, postR):each(function(x, y)
      local ry = y % 9
      local cold = 1 - y / 222
      if ry == 1 and hash(x // 2, y // 9, 97) < .3 + cold * .35 then px(x, y, hash(x, y, 98) < .5 and L.snow.hi or L.snow.base)
      elseif ry == 2 and hash(x // 2, y // 9, 97) < .12 + cold * .2 then px(x, y, L.snow.shade)
      elseif ry > 2 and hash(x, y, 99) < .04 then px(x, y, L.snow.base)
      elseif ry > 3 and y > 150 and hash(x // 3, y // 4, 95) < .06 then px(x, y, L.lichen.base) end
    end)
    part(plL, G, { sep = true }) part(plR, G, { sep = true }) hline(0, 18, 218, G.hi) hline(W - 19, W - 1, 218, G.hi)
    -- snow heaped on the plinths and drifted against their feet
    for _, pl in ipairs({ { 0, 18 }, { W - 19, W - 1 } }) do
      for x = pl[1], pl[2] do
        local hh = 1 + floor(hash(x // 3, 1, 96) * 2)
        for k = 0, hh do px(x, 217 - k, k == hh and L.snow.hi or L.snow.base) end
        px(x, 218, L.snow.shade)
      end
    end
    part(brL, L.timber, { nopop = true }) part(brR, L.timber, { nopop = true })
    hline(17, 31, 13, L.snow.base) hline(W - 32, W - 18, 13, L.snow.base)
    part(beam, L.timber, { band = 2 })
    flatCrown = false
    beam:each(function(x, y) if y > 1 and y < 11 and hash(x // 7, y, 95) < .12 then px(x, y, L.timber.shade) end end)
    hline(0, W - 1, 1, L.timber.hi)
    for x = 30, W - 30, 60 do fill(rect(x, 4, x + 2, 6), L.timber.deep) px(x, 4, L.timber.hi) end
    -- tundra: icicles along the underside of the beam (shorter near the posts, none over the boughs' fringes)
    icicles(16, W - 17, 13, 5, 90, .38)
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
    -- forest additions (kept)
    conifer = conifer, pine = pine, birch = birch, fern = fern, mushroom = mushroom, logs = F_logs, logEnd = logEnd, moss = moss,
    ridge = ridge,
    -- tundra additions
    snowCap = snowCap, icicles = icicles, drift = drift, rubble = rubble, sod = sod, willow = willow, steam = steam,
    tracks = tracks, cairn = cairn, fells = fells, vnoise = vnoise,
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
      local col = b[4] or "#4a4656" -- tundra: ravens
      px(x, y, col)
      for k = 1, w do px(x - k, y - (k == w and 1 or 0) - (k > 1 and 1 or 0) + (k == 1 and 0 or 0), col) px(x + k, y - (k > 1 and 1 or 0), col) end
    end
  end
  -- smoke column: puffs rising and drifting, lighter and smaller as they rise
  function F.smoke(x, y, n, drift, big)
    drift = drift or 1
    local cols = { "#a8a6b8", "#bebccc", "#d2d0de", "#e2e0ea" } -- tundra: cool lilac-grey peat smoke
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
    m:each(function(x, y) if not m:has(x - 1, y) or not m:has(x, y - 1) then local v = c:get(x, y) if v then rawput(c, x, y, mix(v, "#f8e4c6", k or .4)) end end end)
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
      if v then local _, _, l = toHsl(v) if l < .86 then rawput(c, x, y, mix(v, "#f8e2c2", .32)) end end -- tundra: warm low-sun rim
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
