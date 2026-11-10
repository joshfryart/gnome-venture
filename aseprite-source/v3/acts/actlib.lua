-- actlib.lua: shared helpers for the v3 (Hearth Pop 2.5D) act popover scenes, 144x108 with the old wooden frame.
-- Run a scene: /tmp/aseq/squashfs-root/AppRun -b --script aseprite-source/v3/acts/<slug>/<slug>.lua
-- Each scene defines draw(f) for f = 0..5 (f = 0 is the static picture) and calls A.run(slug, draw).
-- Picture area (inside the frame): x 10..133, y 10..97. The 10 px frame ring is copied from the old static
-- (old-act-<slug>.png next to the scene) so the game's frame convention is unchanged.
-- The figures are the game's own 2.5D gnome rig (game/assets/img/gnome25, 10 layers, palette-mapped colours).
local A = {}
local floor, max, min, abs, sin, cos, rad = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.rad
local DIR = (debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")) or "."
A.dir = DIR
A.root = DIR .. "/../../.."
local HP = dofile(DIR .. "/../lib/hp.lua")
A.HP, A.P = HP, HP.P
local P = HP.P
A.X0, A.Y0, A.X1, A.Y1 = 10, 10, 137, 99   -- painted picture (frame: 10 px left/top, 6 px right, 8 px bottom)
A.AX1, A.AY1 = 133, 97   -- animated pixels stay inside the 10 px ring bulk_verify.py checks
A.N = 6

---------------------------------------------------------------- colour
local function hexrgb(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
local function rgbhex(r, g, b) return string.format("#%02x%02x%02x", r, g, b) end
A.hexrgb, A.rgbhex = hexrgb, rgbhex
local function hsl(r, g, b)
  r, g, b = r / 255, g / 255, b / 255
  local mx, mn = max(r, g, b), min(r, g, b)
  local l = (mx + mn) / 2
  if mx == mn then return 0, 0, l end
  local d = mx - mn
  local s = l > .5 and d / (2 - mx - mn) or d / (mx + mn)
  local h
  if mx == r then h = (g - b) / d + (g < b and 6 or 0) elseif mx == g then h = (b - r) / d + 2 else h = (r - g) / d + 4 end
  return h * 60, s, l
end
local function h2c(p, q, t)
  if t < 0 then t = t + 1 end if t > 1 then t = t - 1 end
  if t < 1/6 then return p + (q - p) * 6 * t end
  if t < 1/2 then return q end
  if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
  return p
end
local function fromhsl(h, s, l)
  local r, g, b
  if s == 0 then r, g, b = l, l, l else
    local q = l < .5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    r, g, b = h2c(p, q, h / 360 + 1/3), h2c(p, q, h / 360), h2c(p, q, h / 360 - 1/3)
  end
  return rgbhex(floor(r * 255 + .5), floor(g * 255 + .5), floor(b * 255 + .5))
end
local function toward(h, t, amt)
  local d = ((t - h + 540) % 360) - 180
  local st = min(abs(d), amt) * (d >= 0 and 1 or -1)
  return (h + st + 360) % 360
end
-- the art guide's ramp recipe (same as includes/gnome25.php): {hi, base, shade, deep}
function A.ramp(base)
  local h, s, l = hsl(hexrgb(base))
  local cl = function(x) return min(.97, max(.03, x)) end
  return { hi = fromhsl(toward(h, 45, 10), s, cl(l + (1 - l) * .3)), base = base:lower(),
           shade = fromhsl(toward(h, 270, 8), s * .8, cl(l * .8)), deep = fromhsl(toward(h, 270, 20), s * .6, cl(l * .55)) }
end

---------------------------------------------------------------- png in / sprites
-- sprite = { p = {[key]=hex}, bbox } ; key = (y+512)*2048 + (x+512)
local function K(x, y) return (y + 512) * 2048 + (x + 512) end
local function XY(k) return k % 2048 - 512, k // 2048 - 512 end
A.K, A.XY = K, XY
function A.loadPNG(path, x0, y0, w, h)
  local img = Image{ fromFile = path }
  if not img then error("actlib: cannot load " .. path) end
  local pc = app.pixelColor
  local s = { p = {} }
  x0, y0 = x0 or 0, y0 or 0
  w, h = w or img.width, h or img.height
  for y = 0, h - 1 do for x = 0, w - 1 do
    local v = img:getPixel(x0 + x, y0 + y)
    if pc.rgbaA(v) > 0 then s.p[K(x, y)] = rgbhex(pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v)) end
  end end
  return s
end

local MARK = { ["#f0f0f0"] = "hi", ["#b4b4b4"] = "base", ["#787878"] = "shade", ["#3c3c3c"] = "deep" }
local ORDER = { {"shadow"}, {"outline"}, {"boots","boots"}, {"tunic","tunic"}, {"scarf","scarf"}, {"skin","skin"},
  {"beard","beard"}, {"face"}, {"hat","hat"}, {"trim","trim"} }
local DEF = {
  hat = { hi="#ff8a5c", base="#e8493b", shade="#b52e3f", deep="#6e2038" }, tunic = { hi="#b6f0e0", base="#5fc4c8", shade="#3a86b0", deep="#2a4a7a" },
  scarf = { hi="#ffe38a", base="#f5b82e", shade="#d98322", deep="#51302b" }, beard = { hi="#fff4d6", base="#e2e0e6", shade="#aaa9b8", deep="#74758c" },
  boots = { hi="#e8b982", base="#b97a4a", shade="#864c33", deep="#51302b" }, skin = { hi="#ffe0bd", base="#f0b98d", shade="#c98462", deep="#51302b" },
  trim = { hi="#ffe38a", base="#f5b82e", shade="#d98322", deep="#51302b" },
}
local LAYERS = {}
-- A.gnome{view="front"|"side"|"back", frame=0, hat="#hex", tunic=, scarf=, beard=, skip={shadow=true}} -> sprite (64x80 cell coords)
function A.gnome(o)
  o = o or {}
  local view, fr = o.view or "front", o.frame or 0
  local s = { p = {} }
  for _, L in ipairs(ORDER) do
    local name, role = L[1], L[2]
    if not (o.skip and o.skip[name]) then
      local key = view .. "-" .. name .. "-" .. fr
      local lay = LAYERS[key]
      if not lay then
        lay = A.loadPNG(A.root .. "/game/assets/img/gnome25/" .. view .. "-" .. name .. ".png", fr * 64, 0, 64, 80)
        LAYERS[key] = lay
      end
      local rp = role and ((o[role] and A.ramp(o[role])) or DEF[role])
      for k, hex in pairs(lay.p) do
        local t = rp and MARK[hex]
        s.p[k] = t and rp[t] or hex
      end
    end
  end
  return s
end
-- after skipping the hat layer, drop the outline pixels that only outlined the hat (rows <= ymax)
function A.dropOrphanInk(s, ymax)
  local ink = P.ink
  local del = {}
  for k, v in pairs(s.p) do
    local x, y = XY(k)
    if v == ink and y <= ymax then
      local keep = false
      for _, d in ipairs({ {1,0}, {-1,0}, {0,1}, {0,-1} }) do
        local q = s.p[K(x + d[1], y + d[2])]
        if q and q ~= ink then keep = true end
      end
      if not keep then del[#del + 1] = k end
    end
  end
  for _, k in ipairs(del) do s.p[k] = nil end
  return s
end
function A.copy(s) local n = { p = {} } for k, v in pairs(s.p) do n.p[k] = v end return n end
-- keep only rows y0..y1 of a sprite
function A.rows(s, y0, y1) local n = { p = {} } for k, v in pairs(s.p) do local _, y = XY(k) if y >= y0 and y <= y1 then n.p[k] = v end end return n end
-- paint extra pixels into a sprite (cell coords): rows of chars, map char -> hex
function A.spaint(s, rows, x0, y0, map)
  for j, row in ipairs(rows) do for i = 1, #row do
    local ch = row:sub(i, i)
    if ch ~= "." and ch ~= " " then s.p[K(x0 + i - 1, y0 + j - 1)] = map[ch] or error("spaint: " .. ch) end
  end end
  return s
end
function A.sput(s, x, y, hex) s.p[K(x, y)] = hex return s end
function A.sdel(s, x, y) s.p[K(x, y)] = nil return s end

-- EPX / scale2x of a sprite (returns a sprite in 2x coords)
local function epx(s)
  local n = { p = {} }
  for k, P0 in pairs(s.p) do
    local x, y = XY(k)
    local A_, B, C, D = s.p[K(x, y - 1)], s.p[K(x + 1, y)], s.p[K(x - 1, y)], s.p[K(x, y + 1)]
    local e0, e1, e2, e3 = P0, P0, P0, P0
    if C == A_ and C ~= D and A_ ~= B and A_ then e0 = A_ end
    if A_ == B and A_ ~= C and B ~= D and B then e1 = B end
    if D == C and D ~= B and C ~= A_ and C then e2 = C end
    if B == D and B ~= A_ and D ~= C and D then e3 = D end
    n.p[K(2 * x, 2 * y)], n.p[K(2 * x + 1, 2 * y)], n.p[K(2 * x, 2 * y + 1)], n.p[K(2 * x + 1, 2 * y + 1)] = e0, e1, e2, e3
  end
  return n
end
-- rotate the part of a sprite ABOVE row py (y < py) by ang degrees (positive = clockwise on screen) about (px, py).
-- RotSprite-lite: 8x EPX upscale, nearest sample, so the pixel art keeps clean edges. Rows >= py stay. A band of
-- `fill` rows above the pivot is kept unrotated underneath, so the bent back has no gap.
function A.bend(s, px, py, ang, fill)
  if ang == 0 then return A.copy(s) end
  local up = { p = {} }
  for k, v in pairs(s.p) do local _, y = XY(k) if y < py then up.p[k] = v end end
  local big = epx(epx(epx(up)))
  local out = { p = {} }
  for k, v in pairs(s.p) do local _, y = XY(k) if y >= py - (fill or 0) then out.p[k] = v end end
  local c, sn = cos(rad(ang)), sin(rad(ang))
  for ty = py - 70, py + 40 do for tx = px - 70, px + 70 do
    local dx, dy = tx + .5 - px, ty + .5 - py
    -- inverse rotation
    local sx, sy = dx * c + dy * sn + px, -dx * sn + dy * c + py
    if sy < py then
      local v = big.p[K(floor(sx * 8), floor(sy * 8))]
      if v then out.p[K(tx, ty)] = v end
    end
  end end
  return out
end
function A.bbox(s)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for k in pairs(s.p) do local x, y = XY(k) x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  return x0, y0, x1, y1
end
-- stamp a sprite onto the canvas; cell (0,0) lands on (ox,oy). o.flip mirrors in the 64-wide cell; o.clip(x,y)->bool keeps
function A.stamp(c, s, ox, oy, o)
  o = o or {}
  for k, v in pairs(s.p) do
    local x, y = XY(k)
    if o.flip then x = 63 - x end
    local X, Y = ox + x, oy + y
    if not o.clip or o.clip(X, Y) then c:put(X, Y, v, o.owner) end
  end
end

---------------------------------------------------------------- canvas + output
function A.canvas(name) return HP.canvas{ w = 144, h = 108, name = name } end
function A.inside(x, y) return x >= A.X0 and x <= A.X1 and y >= A.Y0 and y <= A.Y1 end
function A.ainside(x, y) return x >= A.X0 and x <= A.AX1 and y >= A.Y0 and y <= A.AY1 end
-- deterministic hash noise 0..1
function A.hash(x, y, seed)
  local n = (floor(x) * 374761393 + floor(y) * 668265263 + floor(seed or 0) * 2246822519) % 4294967296
  n = ((n ~ (n >> 13)) * 1274126177) % 4294967296
  return (n % 100000) / 100000
end

local FRAMES = {}
local function frameRing(c, slug)
  local key = slug
  local ring = FRAMES[key]
  if not ring then
    ring = A.loadPNG(DIR .. "/" .. slug .. "/old-act-" .. slug .. ".png")
    FRAMES[key] = ring
  end
  for y = 0, 107 do for x = 0, 143 do
    if not A.inside(x, y) then
      local v = ring.p[K(x, y)]
      local i = y * 144 + x
      if v then c.pix[i] = v; c.own[i] = true else c.pix[i] = nil; c.own[i] = nil end
    end
  end end
end

function A.run(slug, draw)
  local out = DIR .. "/" .. slug .. "/"
  local frames = {}
  for f = 0, A.N - 1 do
    local c = draw(f)
    frameRing(c, slug)
    HP.assertClean(c)
    frames[#frames + 1] = c
  end
  frames[1]:save{ aseprite = out .. "act-" .. slug .. ".aseprite", png = out .. "act-" .. slug .. ".png", scale = 1 }
  HP.sheet{ cellw = 144, cellh = 108, frames = frames, tags = { { name = "loop", from = 1, to = A.N } } }
    :save{ aseprite = out .. "act-" .. slug .. "-anim.aseprite", png = out .. "act-" .. slug .. "-anim.png", scale = 1 }
  print("actlib: wrote " .. slug)
end

---------------------------------------------------------------- scene painters
-- flat fill of the picture area in one colour
function A.fill(c, hex) for y = A.Y0, A.Y1 do for x = A.X0, A.X1 do c:put(x, y, hex) end end end
function A.mfill(c, m, hex) m:each(function(x, y) c:put(x, y, hex) end) end

-- looping particle lanes: every lane holds identical particles D = N*s apart, wrapped over L (multiple of D),
-- so after N frames the pattern is back where it started. pts per lane: y = ytop + ((ph + k*D + f*s) % L)
-- o = {lanes={{x=,ph=}}, ytop=, L=, s=, D=, f=, put=function(x,y,lane,k) end, sway=function(y,lane)->dx, dx=0 (drift per step)}
function A.lanes(o)
  for li, ln in ipairs(o.lanes) do
    local k = 0
    while k * o.D < o.L do
      local d = (ln.ph + k * o.D + o.f * o.s) % o.L
      local y = o.ytop + d
      local x = ln.x + floor((o.dx or 0) * d + .5) + (o.sway and o.sway(y, li) or 0)
      o.put(x, y, li, k)
      k = k + 1
    end
  end
end

-- snow flakes falling, loop in N frames. density = lanes; big = share of 2x2 flakes
function A.snow(c, f, o)
  o = o or {}
  local lanes = {}
  local n = o.n or 12
  for i = 1, n do lanes[i] = { x = A.X0 + 2 + floor(A.hash(i, 7, o.seed or 1) * (A.AX1 - A.X0 - 4)), ph = floor(A.hash(i, 3, o.seed or 1) * 18) } end
  local col = o.col or "#f4fbff"
  local col2 = o.col2 or P.sky.hi
  A.lanes{ lanes = lanes, ytop = A.Y0 - 18, L = 126, s = o.s or 3, D = (o.s or 3) * A.N, f = f, dx = o.dx,
    sway = function(y, li) return floor(sin(y / 9 + li) * 1.4 + .5) end,
    put = function(x, y, li, k)
      if o.skip and o.skip(x, y) then return end
      local big = A.hash(li, k, 11) < (o.big or .3)
      local function pp(px, py, hx) if A.ainside(px, py) then c:put(px, py, hx) end end
      if big then pp(x, y, col) pp(x + 1, y, col) pp(x, y + 1, col) pp(x + 1, y + 1, col2)
      else pp(x, y, col) end
    end }
end

-- conifer with tiers; (x,yb) = trunk base centre, h = height. snow=true adds caps. Returns mask
function A.pine(c, x, yb, h, o)
  o = o or {}
  local g = o.ramp or { hi = "#7cc35a", base = "#3f9150", shade = "#2f7048", deep = "#24544a" }
  local tiers = o.tiers or 3
  local m = HP.mask()
  local top = yb - h
  c:fillMask(c:rect(x - 1, yb - 4, x + 1, yb), P.wood.shade)
  c:put(x - 1, yb - 4, P.wood.deep)
  local tmasks = {}
  for t = 0, tiers - 1 do
    local ty0 = top + floor(t * h * .26)
    local ty1 = top + floor((t + 1) * h * .3) + floor(h * .12)
    if ty1 > yb - 4 then ty1 = yb - 4 end
    local hw = floor((h * .2) + t * h * .09)
    local tm = c:poly{ { x + .5, ty0 }, { x + hw + 1.5, ty1 + 1 }, { x - hw - .5, ty1 + 1 } }
    tmasks[#tmasks + 1] = { tm, ty0, ty1, hw }
    m:add(tm)
  end
  c:rim(m, o.rimc or g.deep)
  for i, T in ipairs(tmasks) do
    local tm, ty0, ty1, hw = T[1], T[2], T[3], T[4]
    tm:each(function(px, py)
      local col = g.base
      if px > x + (py - ty0) * .25 then col = g.shade end
      if py >= ty1 then col = g.deep end
      if px < x - (py - ty0) * .3 and py < ty1 - 1 and (px + py) % 3 == 0 then col = g.hi end
      c:put(px, py, col)
    end)
    if o.snow then
      for py = ty0, ty1 do for px = x - hw - 1, x + hw + 1 do
        if tm:has(px, py) and not tm:has(px, py - 1) then
          c:put(px, py, o.snowc or "#f4fbff")
          if (px + i) % 3 ~= 0 and tm:has(px, py + 1) then c:put(px, py + 1, o.snow2 or P.sky.base) end
        end
      end end
      -- a snow ledge along each tier's lower-left edge
      for px = x - hw, x - 1 do if tm:has(px, ty1) and (px % 4 ~= 0) then c:put(px, ty1 - 1, o.snowc or "#f4fbff") end end
    end
  end
  return m
end

-- steam wisp lanes rising from (x, ybot) up h px (loops). col tones list (bottom..top)
function A.steam(c, f, x, ybot, h, seed, cols)
  cols = cols or { "#f4fbff", P.sky.hi }
  local L = 24
  A.lanes{ lanes = { { x = x, ph = floor(A.hash(seed, 1, 5) * 6) } }, ytop = ybot - L, L = L, s = 1, D = 6, f = f,
    sway = function(y) return floor(sin((y + seed * 5) / 4) * 1.5 + .5) end,
    put = function(px, py)
      local t = (ybot - py) / L
      local col = t < .5 and cols[1] or cols[2]
      local function pp(x, y) if A.ainside(x, y) then c:put(x, y, col) end end
      if t < .92 then
        pp(px, py)
        if t < .7 then pp(px + 1, py) pp(px, py - 1) end
        if t < .4 then pp(px + 1, py - 1) pp(px - 1, py) pp(px + 2, py - 1) end
      end
    end }
end

return A
