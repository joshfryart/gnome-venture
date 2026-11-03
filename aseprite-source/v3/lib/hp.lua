-- hp.lua : Hearth Pop v3 pixel library for Aseprite 1.3.x CLI. See README.md.
local HP = {}
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local DIR = (debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")) or "."
local P = dofile(DIR .. "/palette.lua")
HP.P, HP.dir = P, DIR

local PALSET = {}
local function lc(h) return h:lower() end
PALSET[P.ink], PALSET[P.cream] = true, true
for _, r in pairs(P) do if type(r) == "table" then for _, h in pairs(r) do PALSET[lc(h)] = true end end end
local TONES = { "hi", "base", "shade", "deep" }

local function ramp(r)
  if type(r) == "string" then return P[r] and type(P[r]) == "table" and P[r] or error("HP: unknown ramp " .. r, 3) end
  return r
end
local function hexrgb(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end

---------------------------------------------------------------- masks
local Mask = {}; Mask.__index = Mask
local function K(x, y) return (y + 256) * 1024 + (x + 256) end
local function XY(k) return k % 1024 - 256, k // 1024 - 256 end
function HP.mask() return setmetatable({ s = {} }, Mask) end
function Mask:set(x, y) self.s[K(x, y)] = true return self end
function Mask:has(x, y) return self.s[K(x, y)] == true end
function Mask:add(m) for k in pairs(m.s) do self.s[k] = true end return self end
function Mask:cut(m) for k in pairs(m.s) do self.s[k] = nil end return self end
function Mask:clip(m) for k in pairs(self.s) do if not m.s[k] then self.s[k] = nil end end return self end
function Mask:copy() local n = HP.mask() for k in pairs(self.s) do n.s[k] = true end return n end
function Mask:count() local n = 0 for _ in pairs(self.s) do n = n + 1 end return n end
function Mask:each(f) for k in pairs(self.s) do local x, y = XY(k) f(x, y) end end
function Mask:bbox()
  local x0, y0, x1, y1
  self:each(function(x, y) x0 = x0 and min(x0, x) or x; x1 = x1 and max(x1, x) or x; y0 = y0 and min(y0, y) or y; y1 = y1 and max(y1, y) or y end)
  return x0, y0, x1, y1
end
function Mask:shift(dx, dy) local n = HP.mask() self:each(function(x, y) n:set(x+dx, y+dy) end) return n end
function Mask:grow(r) -- 4-neighbour dilation, new mask
  local cur = self:copy()
  for _ = 1, r or 1 do
    local nx = cur:copy()
    cur:each(function(x, y) nx:set(x+1,y) nx:set(x-1,y) nx:set(x,y+1) nx:set(x,y-1) end)
    cur = nx
  end
  return cur
end
function Mask:edge() -- inner 1px border (pixels with a 4-neighbour outside)
  local n = HP.mask()
  self:each(function(x, y) if not (self:has(x+1,y) and self:has(x-1,y) and self:has(x,y+1) and self:has(x,y-1)) then n:set(x, y) end end)
  return n
end
function Mask:shrink(r) local cur = self:copy() for _ = 1, r or 1 do cur:cut(cur:edge()) end return cur end

local function mRect(x0, y0, x1, y1) local m = HP.mask() for y = y0, y1 do for x = x0, x1 do m:set(x, y) end end return m end
local function mRRect(x0, y0, x1, y1, r)
  local m = HP.mask()
  for y = y0, y1 do for x = x0, x1 do
    local ok, cx, cy = true
    if x < x0 + r then cx = x0 + r elseif x > x1 - r then cx = x1 + 1 - r end
    if y < y0 + r then cy = y0 + r elseif y > y1 - r then cy = y1 + 1 - r end
    if cx and cy then ok = (x + .5 - cx)^2 + (y + .5 - cy)^2 <= r * r end
    if ok then m:set(x, y) end
  end end
  return m
end
local function mEllipse(cx, cy, rx, ry)
  local m = HP.mask()
  for y = floor(cy - ry - 1), math.ceil(cy + ry + 1) do for x = floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    if ((x - cx) / (rx + .5))^2 + ((y - cy) / (ry + .5))^2 <= 1 then m:set(x, y) end
  end end
  return m
end
local function mPoly(pts)
  local m = HP.mask()
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for _, p in ipairs(pts) do x0, y0, x1, y1 = min(x0, p[1]), min(y0, p[2]), max(x1, p[1]), max(y1, p[2]) end
  for y = floor(y0), math.ceil(y1) do for x = floor(x0), math.ceil(x1) do
    local px, py, inside, n = x + .5, y + .5, false, #pts
    local j = n
    for i = 1, n do
      local a, b = pts[i], pts[j]
      if (a[2] > py) ~= (b[2] > py) and px < (b[1] - a[1]) * (py - a[2]) / (b[2] - a[2]) + a[1] then inside = not inside end
      j = i
    end
    if inside then m:set(x, y) end
  end end
  return m
end
local function mLine(pts, w)
  w = w or 1
  local m, lo = HP.mask(), floor((w - 1) / 2)
  local function stamp(x, y)
    for dy = 0, w - 1 do for dx = 0, w - 1 do
      if not (w >= 4 and (dx == 0 or dx == w - 1) and (dy == 0 or dy == w - 1)) then m:set(x - lo + dx, y - lo + dy) end
    end end
  end
  if #pts == 1 then stamp(floor(pts[1][1] + .5), floor(pts[1][2] + .5)) end
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i+1]
    local n = max(abs(b[1]-a[1]), abs(b[2]-a[2]), 1)
    for s = 0, n do stamp(floor(a[1] + (b[1]-a[1]) * s / n + .5), floor(a[2] + (b[2]-a[2]) * s / n + .5)) end
  end
  return m
end
HP.rect, HP.rrect, HP.ellipse, HP.poly, HP.line = mRect, mRRect, mEllipse, mPoly, mLine

---------------------------------------------------------------- canvas
local Canvas = {}; Canvas.__index = Canvas
local SHADOW = {} -- owner sentinel for ground shadow / non-solid pixels
function HP.canvas(o)
  local c = setmetatable({ w = o.w, h = o.h, W = o.w, H = o.h, scale = o.scale or 1, name = o.name or "canvas", pix = {}, own = {} }, Canvas)
  return c
end
local function inb(c, x, y) return x >= 0 and y >= 0 and x < c.w and y < c.h end
function Canvas:rect(...) return mRect(...) end
function Canvas:rrect(...) return mRRect(...) end
function Canvas:ellipse(...) return mEllipse(...) end
function Canvas:poly(...) return mPoly(...) end
function Canvas:line(...) return mLine(...) end
function Canvas:get(x, y) return inb(self, x, y) and self.pix[y * self.w + x] or nil end
function Canvas:put(x, y, hex, owner)
  if inb(self, x, y) then self.pix[y * self.w + x] = lc(hex); self.own[y * self.w + x] = owner or true end
end
function Canvas:px(x, y, hex) self:put(x, y, hex) return self end
function Canvas:fillMask(m, hex) m:each(function(x, y) self:put(x, y, hex) end) return self end

local function shadeSet(m, list, band)
  local sh = {}
  for _, p in ipairs(list) do if not m:has(p[1] + band, p[2] + band) then sh[K(p[1], p[2])] = true end end
  return sh
end

-- c:part(mask, ramp, {band=2|3, noshade, pop={x,y,horizontal}, nopop, inner=true, sep=false})
function Canvas:part(m, rampOrName, o)
  o = o or {}
  local r = ramp(rampOrName)
  local list = {}
  m:each(function(x, y) if inb(self, x, y) then list[#list+1] = { x, y } end end)
  if #list == 0 then return m end
  local col = {}
  local tok = { r = r } -- owner token: one per part (ramp in .r)
  for _, p in ipairs(list) do col[K(p[1], p[2])] = r.base end
  -- inner line where touching a different earlier solid part
  local inner = {}
  if o.inner ~= false then
    for _, p in ipairs(list) do
      for _, d in ipairs({ {1,0}, {-1,0}, {0,1}, {0,-1} }) do
        local nx, ny = p[1] + d[1], p[2] + d[2]
        if not m:has(nx, ny) and inb(self, nx, ny) then
          local ow = self.own[ny * self.w + nx]
          -- fix: ground shadow is not a part (was giving a doubled deep+ink line on the underside);
          -- o.sep: also separate from earlier parts of the SAME ramp (rule 2: line where similar colours touch)
          if type(ow) == "table" and ow ~= SHADOW and (ow.r ~= r or (o.sep and ow ~= tok)) then inner[K(p[1], p[2])] = true break end
        end
      end
    end
  end
  if not o.noshade then
    local band = o.band or (#list < 600 and 2 or 3)
    local sh = shadeSet(m, list, band)
    if not o.band then
      while band > 1 do
        local n = 0 for _ in pairs(sh) do n = n + 1 end
        if n / #list <= 0.45 then break end
        band = band - 1; sh = shadeSet(m, list, band)
      end
    end
    for k in pairs(sh) do col[k] = r.shade end
  end
  for k in pairs(inner) do col[k] = r.deep end
  if not o.nopop then
    local pop
    if o.pop then
      local h = o.pop.horizontal ~= false
      pop = { o.pop.x or o.pop[1], o.pop.y or o.pop[2], h }
    else
      local best
      for pass = 1, 2 do
        for _, p in ipairs(list) do
          local x, y = p[1], p[2]
          local k1, k2 = K(x, y), K(x + 1, y)
          if col[k1] == r.base and col[k2] == r.base and (pass == 2 or (m:has(x-1,y) and m:has(x,y-1) and m:has(x,y+1) and m:has(x+2,y) and not inner[k1] and not inner[k2])) then
            local sc = (x + y) * 1000 + y
            if not best or sc < best[3] then best = { x, y, sc } end
          end
        end
        if best then break end
      end
      if best then pop = { best[1], best[2], true } end
    end
    if pop then
      col[K(pop[1], pop[2])] = r.hi
      if pop[3] then col[K(pop[1] + 1, pop[2])] = r.hi else col[K(pop[1], pop[2] + 1)] = r.hi end
    end
  end
  for k, hex in pairs(col) do local x, y = XY(k) if m:has(x, y) then self:put(x, y, hex, tok) end end
  return m
end

function Canvas:paint(rows, x0, y0, map)
  for j, row in ipairs(rows) do
    for i = 1, #row do
      local ch, v = row:sub(i, i), nil
      if ch ~= "." and ch ~= " " then
        v = map[ch]
        if v == nil then error("HP.paint: no mapping for '" .. ch .. "'") end
        if v:sub(1, 1) ~= "#" then
          local rn, t = v:match("^(%w+)%.(%w+)$")
          v = rn == nil and P[v] or P[rn][t]
        end
        self:put(x0 + i - 1, y0 + j - 1, v)
      end
    end
  end
  return self
end
function Canvas:sparkle(x, y)
  for _, d in ipairs({ {0,0}, {1,0}, {-1,0}, {0,1}, {0,-1} }) do self:put(x + d[1], y + d[2], P.cream) end
  return self
end
function Canvas:eyeSmall(x, y) -- (x,y) = top-left of 2x3 pill
  self:fillMask(mRect(x, y, x + 1, y + 2), P.ink)
  self:put(x, y, P.cream) return self
end
function Canvas:eyeLocked(x, y) -- (x,y) = top-left of 5x5 disc
  for j = 0, 4 do for i = 0, 4 do
    if not ((i == 0 or i == 4) and (j == 0 or j == 4)) then self:put(x + i, y + j, P.cream) end
  end end
  self:fillMask(mRect(x + 1, y + 1, x + 3, y + 3), P.ink)
  self:put(x + 1, y + 1, P.cream) return self
end
function Canvas:cheek(x, y) self:put(x, y, P.petal.base) self:put(x + 1, y, P.petal.base) return self end -- top-left of 2x1
function Canvas:stitch(points) -- polyline; gold dashes 2 on 1 off
  local i = 0
  for s = 1, #points - 1 do
    local a, b = points[s], points[s+1]
    local n = max(abs(b[1]-a[1]), abs(b[2]-a[2]), 1)
    for t = (s == 1 and 0 or 1), n do
      if i % 3 < 2 then self:put(floor(a[1] + (b[1]-a[1]) * t / n + .5), floor(a[2] + (b[2]-a[2]) * t / n + .5), P.gold.base) end
      i = i + 1
    end
  end
  return self
end
function Canvas:button(x, y) self:fillMask(mRect(x - 1, y - 1, x + 1, y + 1), P.gold.base) return self end -- centred
function Canvas:groundShadow(cx, cy, rx, ry)
  local m = mEllipse(cx, cy, rx, ry)
  local list = {}
  m:each(function(x, y) list[#list+1] = { x, y } end)
  local sh = shadeSet(m, list, 1)
  for _, p in ipairs(list) do self:put(p[1], p[2], sh[K(p[1], p[2])] and P.stone.shade or P.stone.base, SHADOW) end
  return self
end
function Canvas:bands(y0, y1, rampName, n) -- n (1-4) flat bands, darkest on top
  local r = ramp(rampName)
  local seq = { "deep", "shade", "base", "hi" }
  local first = 5 - n
  local h = y1 - y0 + 1
  for y = y0, y1 do
    local bi = min(n, floor((y - y0) * n / h) + 1)
    for x = 0, self.w - 1 do self:put(x, y, r[seq[first + bi - 1]]) end
  end
  return self
end
function Canvas:hem(y, x0, x1) -- gold dashes 2 on 1 off
  for x = x0 or 0, x1 or self.w - 1 do if (x - (x0 or 0)) % 3 < 2 then self:put(x, y, P.gold.base) end end
  return self
end
function Canvas:finish(o)
  o = o or {}
  if o.outline == false then return self end
  local add = {}
  for y = 0, self.h - 1 do for x = 0, self.w - 1 do
    local ow = self.own[y * self.w + x]
    if ow == nil or ow == SHADOW then
      for _, d in ipairs({ {1,0}, {-1,0}, {0,1}, {0,-1} }) do
        local q = inb(self, x + d[1], y + d[2]) and self.own[(y + d[2]) * self.w + x + d[1]]
        if q and q ~= SHADOW then add[#add+1] = { x, y } break end
      end
    end
  end end
  for _, p in ipairs(add) do self:put(p[1], p[2], P.ink) end
  return self
end

---------------------------------------------------------------- output
local function toImage(c, scale)
  scale = scale or 1
  if scale ~= floor(scale) then -- fractional nearest-neighbour (e.g. 1.5 for region thumbs)
    local W, H = floor(c.w * scale + .5), floor(c.h * scale + .5)
    local img = Image(W, H, ColorMode.RGB)
    img:clear(app.pixelColor.rgba(0, 0, 0, 0))
    local cache = {}
    for ty = 0, H - 1 do for tx = 0, W - 1 do
      local h = c.pix[min(c.h - 1, floor(ty / scale)) * c.w + min(c.w - 1, floor(tx / scale))]
      if h then
        local v = cache[h]
        if not v then local r, g, b = hexrgb(h) v = app.pixelColor.rgba(r, g, b, 255) cache[h] = v end
        img:putPixel(tx, ty, v)
      end
    end end
    return img
  end
  local img = Image(c.w * scale, c.h * scale, ColorMode.RGB)
  img:clear(app.pixelColor.rgba(0, 0, 0, 0))
  local cache = {}
  for y = 0, c.h - 1 do for x = 0, c.w - 1 do
    local h = c.pix[y * c.w + x]
    if h then
      local v = cache[h]
      if not v then local r, g, b = hexrgb(h) v = app.pixelColor.rgba(r, g, b, 255) cache[h] = v end
      for dy = 0, scale - 1 do for dx = 0, scale - 1 do img:putPixel(x * scale + dx, y * scale + dy, v) end end
    end
  end end
  return img
end
Canvas.toImage = toImage
local function mkdirs(p) if p then pcall(function() app.fs.makeAllDirectories(app.fs.filePath(p)) end) end end

function Canvas:save(o)
  o = o or {}
  local scale = o.scale or self.scale or 1
  mkdirs(o.aseprite) mkdirs(o.png)
  if o.aseprite then
    local spr = Sprite(self.w, self.h, ColorMode.RGB)
    spr.cels[1].image = toImage(self, 1)
    spr:saveAs(o.aseprite) spr:close()
  end
  if o.png then
    local img = toImage(self, scale)
    local spr = Sprite(img.width, img.height, ColorMode.RGB)
    spr.cels[1].image = img
    spr:saveCopyAs(o.png) spr:close()
  end
  return self
end

-- HP.sheet{cellw,cellh,frames={c1,..},tags={{name=,from=,to=},..}}
local Sheet = {}; Sheet.__index = Sheet
function HP.sheet(o)
  for i, f in ipairs(o.frames) do
    if f.w > o.cellw or f.h > o.cellh then error("HP.sheet: frame " .. i .. " larger than cell") end
  end
  return setmetatable({ cellw = o.cellw, cellh = o.cellh, frames = o.frames, tags = o.tags or {} }, Sheet)
end
function Sheet:save(o)
  o = o or {}
  local scale, n = o.scale or 1, #self.frames
  mkdirs(o.aseprite) mkdirs(o.png)
  local function frameImg(f, s)
    local img = Image(self.cellw * s, self.cellh * s, ColorMode.RGB)
    img:clear(app.pixelColor.rgba(0, 0, 0, 0))
    img:drawImage(toImage(f, s), Point(0, 0))
    return img
  end
  if o.aseprite then
    local spr = Sprite(self.cellw, self.cellh, ColorMode.RGB)
    spr.cels[1].image = frameImg(self.frames[1], 1)
    for i = 2, n do
      local fr = spr:newEmptyFrame()
      spr:newCel(spr.layers[1], fr, frameImg(self.frames[i], 1), Point(0, 0))
    end
    for _, t in ipairs(self.tags) do local tg = spr:newTag(t.from, t.to) tg.name = t.name end
    spr:saveAs(o.aseprite) spr:close()
  end
  if o.png then
    local spr = Sprite(self.cellw * n * scale, self.cellh * scale, ColorMode.RGB)
    local strip = Image(self.cellw * n * scale, self.cellh * scale, ColorMode.RGB)
    strip:clear(app.pixelColor.rgba(0, 0, 0, 0))
    for i, f in ipairs(self.frames) do strip:drawImage(frameImg(f, scale), Point((i - 1) * self.cellw * scale, 0)) end
    spr.cels[1].image = strip
    spr:saveCopyAs(o.png) spr:close()
  end
  return self
end

---------------------------------------------------------------- checks
function HP.report(c, quiet)
  local img = (type(c) == "userdata") and c or toImage(c, 1)
  local pc, w, h = app.pixelColor, img.width, img.height
  local cols, off, semi, bw, solid = {}, 0, 0, 0, {}
  local x0, y0, x1, y1 = w, h, -1, -1
  for y = 0, h - 1 do for x = 0, w - 1 do
    local v = img:getPixel(x, y)
    local a = pc.rgbaA(v)
    if a > 0 then
      if a < 255 then semi = semi + 1 end
      local hex = string.format("#%02x%02x%02x", pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v))
      if not cols[hex] then cols[hex] = 0 end
      cols[hex] = cols[hex] + 1
      if hex == "#000000" or hex == "#ffffff" then bw = bw + 1 end
      solid[y * w + x] = true
      x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y)
    end
  end end
  local nd = 0
  for hex, n in pairs(cols) do nd = nd + 1 if not PALSET[hex] then off = off + n end end
  local iso = 0
  for k in pairs(solid) do
    local x, y, lone = k % w, k // w, true
    for dy = -1, 1 do for dx = -1, 1 do
      if (dx ~= 0 or dy ~= 0) and solid[(y + dy) * w + x + dx] and x + dx >= 0 and x + dx < w then lone = false end
    end end
    if lone then iso = iso + 1 end
  end
  local r = { w = w, h = h, bbox = x1 >= 0 and { x0, y0, x1, y1 } or nil, distinct = nd, offPalette = off, semi = semi, blackWhite = bw, isolated = iso }
  if x1 >= 0 then r.margin = { l = x0, t = y0, r = w - 1 - x1, b = h - 1 - y1 } end
  if not quiet then
    print(string.format("HP.report %s: size %dx%d bbox %s margin %s", type(c) == "table" and c.name or "image", w, h,
      r.bbox and table.concat(r.bbox, ",") or "empty",
      r.margin and string.format("l%d t%d r%d b%d", r.margin.l, r.margin.t, r.margin.r, r.margin.b) or "-"))
    print(string.format("  distinct colours %d | off-palette px %d | semi-transparent %d | pure black/white %d | isolated px %d",
      nd, off, semi, bw, iso))
  end
  return r
end
function HP.assertClean(c)
  local r = HP.report(c, true)
  if r.offPalette > 0 or r.semi > 0 or r.blackWhite > 0 then
    error(string.format("HP.assertClean: offPalette=%d semi=%d blackWhite=%d", r.offPalette, r.semi, r.blackWhite), 2)
  end
  return r
end

---------------------------------------------------------------- scene helpers (opaque canvases)
-- c:rim(mask, hex[, clipMask]) 1px ring just outside mask (4-neighbour). Ink edge / deep-tone edge
-- for objects in opaque scenes, where finish{outline} has no transparent pixels to work on.
function Canvas:rim(m, hex, clip)
  local r = m:grow(1):cut(m)
  if clip then r:clip(clip) end
  self:fillMask(r, hex) return r
end
-- c:edgeIn(mask, hex) 1px line on the mask's own inner border (keeps the silhouette size).
function Canvas:edgeIn(m, hex) local e = m:edge() self:fillMask(e, hex) return e end
-- c:stripes(y0, y1, {hex,..}[, {weight,..}]) flat full-width bands, top to bottom, any ramps.
function Canvas:stripes(y0, y1, cols, wts)
  local tot, acc, h = 0, 0, y1 - y0 + 1
  for i = 1, #cols do tot = tot + (wts and wts[i] or 1) end
  local y = y0
  for i, hex in ipairs(cols) do
    acc = acc + (wts and wts[i] or 1)
    local ye = (i == #cols) and y1 or (y0 + floor(h * acc / tot + .5) - 1)
    for yy = y, ye do for x = 0, self.w - 1 do self:put(x, yy, hex) end end
    y = ye + 1
  end
  return self
end
-- c:terrain(f, hex[, ybot, x0, x1]) fill each column x from f(x) down to ybot (default bottom). Returns mask.
function Canvas:terrain(f, hex, ybot, x0, x1)
  local m = HP.mask()
  for x = x0 or 0, x1 or self.w - 1 do
    for y = max(0, floor(f(x) + .5)), ybot or self.h - 1 do m:set(x, y) end
  end
  if hex then self:fillMask(m, hex) end
  return m
end
-- c:cloud(x, y, w[, top, under]) puff cloud: 3 bumps, flat bottom, (x,y) = bottom-left, w >= 12.
-- top = body colour (cream), under = 1 row flat underside tone (sky.hi / petal.hi). Returns mask.
function Canvas:cloud(x, y, w, top, under)
  local a = floor(w * .22 + .5)
  local m = mEllipse(x + a, y - a + 1, a, a)
    :add(mEllipse(x + floor(w * .48), y - floor(w * .3), floor(w * .27), floor(w * .3)))
    :add(mEllipse(x + w - a - 1, y - a + 2, a, a - 1))
    :clip(mRect(x, y - w, x + w - 1, y))
  m:add(mRect(x + 1, y - 1, x + w - 2, y))
  self:fillMask(m, top or P.cream)
  if under then for xx = x, x + w - 1 do if m:has(xx, y) then self:put(xx, y, under) end end end
  return m
end
-- HP.cells(c, cols, rows[, quiet]) distinct colours per grid cell (jigsaw check). Returns {min=,grid={{..}}}.
function HP.cells(c, cols, rows, quiet)
  local cw, ch, res, mn = c.w // cols, c.h // rows, {}, 1e9
  for r = 0, rows - 1 do
    res[r + 1] = {}
    for q = 0, cols - 1 do
      local set, n = {}, 0
      for y = r * ch, (r + 1) * ch - 1 do for x = q * cw, (q + 1) * cw - 1 do
        local h = c.pix[y * c.w + x] if h and not set[h] then set[h] = true n = n + 1 end
      end end
      res[r + 1][q + 1] = n mn = min(mn, n)
    end
    if not quiet then print(string.format("  cells row %d: %s", r, table.concat(res[r + 1], " "))) end
  end
  if not quiet then print("  cells min distinct: " .. mn) end
  return { min = mn, grid = res }
end

return HP
