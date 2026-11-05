-- batch.lua: 28 banner header strips (480x120) from one table of looks. Param: name=<banner name without "banner-"> or all
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local V3 = d .. "/../.."
local GX = dofile(V3 .. "/gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.pi
local H, INK = X.hash, GX.INK
local NAME = app.params.name or "all"

local function rp(a, b, c, e) return { hi = a, base = b, shade = c, deep = e } end
local C = {
  GREEN = rp("#cdf07a", "#6cc05a", "#3a8a52", "#1e5a48"), DKGRN = rp("#7cc060", "#3a8a4c", "#25603f", "#143c36"),
  PINE = rp("#6ab860", "#2f8050", "#1f5a45", "#123a3a"), BARK = rp("#d4985c", "#9c6438", "#6e4230", "#452a2c"),
  BIRCH = rp("#fff4e0", "#e6dcc8", "#b0a49c", "#78687a"), YEL = rp("#ffe870", "#f0b840", "#c07a34", "#8a4a30"),
  PINK = rp("#ffd2e0", "#f49ac0", "#d0648e", "#8e3e68"), SNOW = rp("#f6fbff", "#d4e8f6", "#a4bede", "#7088b4"),
  ROCK = rp("#d8d8e0", "#a8a8bc", "#76789a", "#4c4a6e"), RED = rp("#ff9a8a", "#e0504a", "#a8324a", "#6c2240"),
  REDROCK = rp("#f09a60", "#c85c3c", "#8e3e3e", "#5a2a3a"), SANDST = rp("#fff0b8", "#f2c070", "#d08e52", "#9c5e3e"),
  CREAM = rp("#fff8e4", "#f6e4c0", "#d8b894", "#a08078"), TERRA = rp("#f4a070", "#d06a44", "#a04a44", "#6c3042"),
  BLUE = rp("#8cc8f0", "#4c90d0", "#3462a8", "#243c78"), THATCH = rp("#f0d078", "#cc9c48", "#98683a", "#64402e"),
  WOOD = rp("#e0a468", "#b0743e", "#80502f", "#54323a"), STONE = rp("#e4dccc", "#b8aca4", "#867c88", "#58505e"),
  GOLD = rp("#fff2a0", "#f5cf6a", "#d09a40", "#946030"), TEAL = rp("#9ae8d8", "#3cb8b0", "#27808e", "#1a4c66"),
  VIOLET = rp("#d8b8f0", "#9c78cc", "#6a4ea0", "#3e2e6e"), WHITE = rp("#fffaf0", "#f0eadc", "#c8c0cc", "#8c82a0"),
  DARK = rp("#9c8cb0", "#6e6088", "#4a3e66", "#2c2444"), ORANGE = rp("#ffd080", "#f0983c", "#c06238", "#7c3a38"),
  GREY = rp("#e8e4e0", "#b8b4bc", "#868498", "#585470"), BROWN = rp("#c89c78", "#946c52", "#684a44", "#3e2c34"),
  CLOUD = rp("#fff4d0", "#ffe6b4", "#f4b898", "#d68a78"), COOL = rp("#ffffff", "#e8f0f8", "#b8c8e0", "#8aa0c4"),
  CRYST = rp("#e8fcff", "#7ae0e8", "#3c9cc8", "#2a5a96"), MAG = rp("#ffe0f4", "#e88cd8", "#a85aac", "#683a80"),
  WATER = rp("#bff0f0", "#5ac8d4", "#2c92b8", "#1c5c90"),
}
local HEM, GOLDC = "#3d2a1c", "#f5cf6a"

local c, G, GCOL
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, floor(cx), floor(cy), rx, ry or rx) end
local function R(m, x0, y0, x1, y1) for y = floor(y0), floor(y1) do for x = floor(x0), floor(x1) do m:set(x, y) end end return m end
local function L(m, Rm, seed, o)
  o = o or {}
  o.seed = o.seed or seed; o.R = o.R or 6
  if not o.nr then m = GX.rough(m, seed, 1) end
  local r6 = type(Rm) == "function" and Rm or GX.ramp6(Rm)
  GX.lit(c, m, r6, o)
  return m
end
local function SH(x, by, rx)
  if not GCOL then return end
  local s = mk(); E(s, x, by, rx, 2); c:fillMask(GX.rough(s, floor(x), 1), GCOL)
end
local function LN(pts, w) return c:line(pts, w) end

--------------------------------------------------------------------------- props
local P = {}
function P.pine(x, by, o)
  local h, n = o.h or 50, o.n or 4
  local m = mk()
  local tierH = h * .5
  local step = (h - 6 - tierH) / (n - 1)
  R(m, x - 2, by - 9, x + 2, by)
  for i = 0, n - 1 do
    local ay = by - h + i * step
    local hw = (h * .27) * (.5 + .5 * (i + 1) / n)
    m:add(c:poly{ { x, ay }, { x + hw, ay + tierH }, { x - hw, ay + tierH } })
  end
  SH(x + 6, by, h * .22)
  L(m, o.R or C.PINE, x, { R = 9, tex = .4, sc = 3, rimlight = true, fn = function(xx, yy) return ((yy + 99) % 5 == 0 and -.12 or 0) end })
  if o.snow then
    m:each(function(xx, yy) if yy < by - 8 and not m:has(xx, yy - 2) or (not m:has(xx - 1, yy - 1) and not m:has(xx, yy - 1) and yy < by - 8) then c:px(xx, yy, C.SNOW.hi); if m:has(xx, yy + 1) then c:px(xx, yy + 1, C.SNOW.base) end end end)
  end
end
local function fronds(tx, ty, angs, len, droop, w, Rm, seed)
  local m = mk()
  for _, a in ipairs(angs) do
    local pts = {}
    for k = 0, 6 do
      local t = k / 6
      pts[#pts + 1] = { tx + cos(a * pi / 180) * len * t, ty + sin(a * pi / 180) * len * t + droop * t * t }
    end
    m:add(LN(pts, w))
  end
  return m
end
function P.palm(x, by, o)
  local h, lean = o.h or 60, o.lean or 10
  local pts = {}
  for k = 0, 8 do local t = k / 8; pts[#pts + 1] = { x + lean * t * t, by - h * t } end
  SH(x + 6, by, 12)
  local tr = LN(pts, 4)
  L(tr, o.TR or C.BARK, x, { R = 3, nr = true, tex = .25, fn = function(xx, yy) return (yy % 4 == 0) and -.2 or 0 end })
  local tx, ty = x + lean, by - h
  local fm = fronds(tx, ty, { -165, -135, -105, -75, -45, -15 }, o.len or 30, 16, 3, nil, 1)
  L(fm, o.R or C.GREEN, x + 3, { R = 3, nr = true, tex = .3, rimlight = true })
  local cm = mk(); E(cm, tx - 2, ty + 3, 2); E(cm, tx + 2, ty + 4, 2)
  L(cm, C.BARK, x + 4, { R = 2, nr = true })
end
function P.mount(x, by, o)
  local w, h, sn = o.w or 120, o.h or 60, o.sn or 0
  local pk = o.pk or .45
  local pts = { { x - w / 2, by + 3 } }
  local N = 16
  for i = 0, N do
    local t = i / N
    local hp = (t < pk) and (t / pk) or ((1 - t) / (1 - pk))
    local ny = (GX.vn(i * 9, 0, 3, x) - .5) * h * .12 * min(1, hp * 3)
    pts[#pts + 1] = { x - w / 2 + w * t, by - h * hp ^ .92 + ny }
  end
  pts[#pts + 1] = { x + w / 2, by + 3 }
  local m = c:poly(pts)
  local px = x - w / 2 + w * pk
  local snowline = by - h + h * sn
  if not o.noshadow then SH(x + 10, by, w * .3) end
  L(m, o.R or C.ROCK, x, { R = 16, tex = .35, sc = 4, amb = .28, nr = true,
    fn = function(xx, yy) return -(xx - px) / w * .9 - (o.bands and ((yy // 5) % 2 - .5) * .14 or 0) end })
  if sn > 0 then
    m:each(function(xx, yy)
      local sl = snowline + (GX.vn(xx, 0, 5, x + 3) - .5) * 9 + abs(xx - px) * .25
      if yy < sl then
        local col = (xx < px - 1 + (GX.vn(xx, yy, 4, 2) - .5) * 6) and C.SNOW.hi or C.SNOW.base
        if yy >= sl - 2 then col = C.SNOW.shade end
        c:px(xx, yy, col)
      end
    end)
  end
end
function P.house(x, by, o)
  local w, h = o.w or 40, o.h or 28
  local st = o.stilt or 0
  local yb = by - st
  local W, Rf = o.wall or C.CREAM, o.roof or C.TERRA
  SH(x + w / 2 + 4, by, w * .6)
  if st > 0 then
    for _, lx in ipairs{ x - w / 2 + 2, x - 1, x + w / 2 - 4 } do
      local lm = R(mk(), lx, yb, lx + 2, by)
      L(lm, C.WOOD, lx, { R = 2, nr = true })
    end
    L(R(mk(), x - w / 2 + 2, by - st // 2, x + w / 2 - 2, by - st // 2 + 1), C.WOOD, 5, { R = 2, nr = true })
  end
  local wm = o.round and c:rrect(x - w // 2, yb - h, x + w // 2, yb, 5) or R(mk(), x - w // 2, yb - h, x + w // 2, yb)
  L(wm, W, x, { R = 9, tex = o.tex or .4, sc = 4, rimlight = true, fn = function(xx, yy) return (o.beam and ((xx - x) % 12 == 0 or yy == yb - h + 8) and -.25 or 0) end })
  local rh = o.rh or 18
  local rm = mk()
  if o.roofstyle == "flat" then
    R(rm, x - w // 2 - 2, yb - h - 3, x + w // 2 + 2, yb - h + 1)
  else
    rm:add(c:poly{ { x - w // 2 - 4, yb - h + 2 }, { x, yb - h - rh }, { x + w // 2 + 4, yb - h + 2 } })
  end
  L(rm, Rf, x + 1, { R = 8, tex = .4, sc = 3, rimlight = true, nr = true, fn = function(xx, yy) return ((yy % 4 == 0) and not o.thatch) and -.14 or (o.thatch and (H(xx // 2, yy, 3) - .5) * .3 or 0) end })
  -- door + windows
  local dx = x - (o.doorx or 0)
  local dm = R(mk(), dx - 3, yb - 12, dx + 3, yb); dm:cut(R(mk(), dx - 3, yb - 12, dx - 3, yb - 12)); dm:cut(R(mk(), dx + 3, yb - 12, dx + 3, yb - 12))
  L(dm, C.WOOD, x + 5, { R = 3, nr = true })
  c:px(dx + 2, yb - 6, C.GOLD.base)
  for _, wx in ipairs(o.win or {}) do
    local wm2 = R(mk(), x + wx - 2, yb - h + 8, x + wx + 2, yb - h + 13)
    L(wm2, rp("#fff6b8", "#ffd25a", "#f09a40", "#c0642c"), wx, { R = 3, nr = true, amb = .6, wrap = .6 })
    c:px(x + wx, yb - h + 8, INK); c:px(x + wx, yb - h + 13, INK)
  end
  if o.chim then
    local cm = R(mk(), x + w // 4, yb - h - rh + 2, x + w // 4 + 5, yb - h - rh // 2)
    L(cm, C.STONE, x + 8, { R = 3, nr = true })
    for k = 1, 3 do local m2 = E(mk(), x + w // 4 + 2 + k * 2, yb - h - rh - k * 5, 2 + k // 2, 2 + k // 2); L(m2, C.COOL, 70 + k, { R = 3, nr = true, amb = .5 }) end
  end
  if o.sign then
    local sm = R(mk(), x + w // 2 + 6, yb - h + 8, x + w // 2 + 13, yb - h + 15)
    L(sm, C.WOOD, 8, { R = 3, nr = true }); c:px(x + w // 2 + 9, yb - h + 11, C.GOLD.hi)
  end
end
function P.dome(x, by, o)
  local r, bh = o.r or 20, o.bh or 16
  local Wl, Dm = o.wall or C.CREAM, o.dom or C.BLUE
  SH(x + r * .5, by, r * 1.1)
  local drum = R(mk(), x - floor(r * .85), by - bh, x + floor(r * .85), by)
  L(drum, Wl, x, { R = 9, rimlight = true })
  local m = mk()
  E(m, x, by - bh, r, o.fl and floor(r * o.fl) or r)
  m:clip(R(mk(), x - r - 2, by - bh - 3 * r, x + r + 2, by - bh + 1))
  if o.onion then m:add(c:poly{ { x - floor(r * .55), by - bh - floor(r * .9) }, { x, by - bh - floor(r * 2.1) }, { x + floor(r * .55), by - bh - floor(r * .9) } }) end
  L(m, Dm, x + 1, { R = r, tex = .3, sc = 3, rimlight = true, nr = true })
  local top = by - bh - (o.onion and floor(r * 2.1) or floor(r * (o.fl or 1)))
  LN({ { x, top }, { x, top - 7 } }, 1):each(function(xx, yy) c:px(xx, yy, INK) end)
  c:px(x, top - 8, C.GOLD.hi); c:px(x + 1, top - 7, C.GOLD.base); c:px(x - 1, top - 7, C.GOLD.base)
  if o.door then L(R(mk(), x - 4, by - 11, x + 4, by), C.BLUE.deep and rp("#7a5a52", "#5a3e46", "#3e2a38", "#2a1c2c") or C.WOOD, 3, { R = 3, nr = true }) end
  if o.windows then for k = -1, 1, 2 do c:px(x + k * 6, by - bh + 5, C.GOLD.base); c:px(x + k * 6, by - bh + 6, C.GOLD.base) end end
end
function P.minaret(x, by, o)
  local h, w = o.h or 60, o.w or 8
  SH(x + 4, by, 8)
  local m = c:poly{ { x - w, by }, { x - w + 2, by - h }, { x + w - 2, by - h }, { x + w, by } }
  L(m, o.wall or C.CREAM, x, { R = 6, nr = true, rimlight = true })
  L(R(mk(), x - w, by - h * .62, x + w, by - h * .62 + 3), C.GOLD, x, { R = 2, nr = true })
  L(c:poly{ { x - w + 1, by - h }, { x, by - h - 18 }, { x + w - 1, by - h } }, o.cap or C.TEAL, x + 2, { R = 6, nr = true, rimlight = true })
  c:px(x, by - h - 19, C.GOLD.hi); c:px(x, by - h - 20, C.GOLD.base)
  c:px(x, by - h + 8, C.DARK.deep); c:px(x, by - h + 9, C.DARK.deep)
end
function P.pagoda(x, by, o)
  local n, w = o.n or 3, o.w or 44
  SH(x + 8, by, w * .6)
  local y = by
  for i = 0, n - 1 do
    local bw = floor(w * (1 - i * .2))
    local body = R(mk(), x - bw // 2 + 3, y - 10, x + bw // 2 - 3, y)
    L(body, o.wall or C.CREAM, x + i, { R = 5, rimlight = true, nr = true })
    for k = -1, 1 do c:px(x + k * 6, y - 6, C.RED.base); c:px(x + k * 6, y - 5, C.RED.base) end
    local rm = c:poly{ { x - bw // 2 - 6, y - 7 }, { x - bw // 2 + 3, y - 14 }, { x + bw // 2 - 3, y - 14 }, { x + bw // 2 + 6, y - 7 }, { x + bw // 2 + 1, y - 9 }, { x - bw // 2 - 1, y - 9 } }
    L(rm, o.roof or C.TEAL, x + i * 3, { R = 6, nr = true, rimlight = true })
    y = y - 14
  end
  LN({ { x, y }, { x, y - 14 } }, 1):each(function(xx, yy) c:px(xx, yy, INK) end)
  for k = 0, 2 do c:px(x - 1, y - 4 - k * 3, C.GOLD.base); c:px(x + 1, y - 4 - k * 3, C.GOLD.base) end
  c:px(x, y - 15, C.GOLD.hi)
end
function P.windmill(x, by, o)
  local h = o.h or 56
  SH(x + 14, by, 22)
  local tw = c:poly{ { x - 15, by }, { x - 9, by - h }, { x + 9, by - h }, { x + 15, by } }
  L(tw, o.wall or C.CREAM, x, { R = 10, nr = true, rimlight = true, fn = function(xx, yy) return ((yy // 6) % 2 == 0) and .06 or 0 end })
  L(c:poly{ { x - 11, by - h + 1 }, { x, by - h - 12 }, { x + 11, by - h + 1 } }, o.roof or C.TERRA, x, { R = 8, nr = true, rimlight = true })
  L(R(mk(), x - 3, by - 11, x + 3, by), C.WOOD, 3, { R = 3, nr = true })
  local hx, hy = x, by - h + 1
  for k = 0, 3 do
    local a = (o.rot or 20 + k * 90) * pi / 180
    if o.rot then a = (o.rot + k * 90) * pi / 180 end
    local dx, dy = cos(a), sin(a)
    local px_, py_ = -dy, dx
    local q = c:poly{ { hx + dx * 8 + px_ * 1, hy + dy * 8 + py_ * 1 }, { hx + dx * 32 + px_ * 1, hy + dy * 32 + py_ * 1 }, { hx + dx * 32 + px_ * 9, hy + dy * 32 + py_ * 9 }, { hx + dx * 8 + px_ * 9, hy + dy * 8 + py_ * 9 } }
    L(q, C.WHITE, k, { R = 4, nr = true, amb = .4 })
    LN({ { hx, hy }, { hx + dx * 34, hy + dy * 34 } }, 2):each(function(xx, yy) c:px(xx, yy, C.WOOD.shade) end)
  end
  L(E(mk(), hx, hy, 3), C.WOOD, 4, { R = 3, nr = true })
end
function P.lighthouse(x, by, o)
  local h = o.h or 62
  local tw = c:poly{ { x - 10, by }, { x - 6, by - h }, { x + 6, by - h }, { x + 10, by } }
  local WH, RD = GX.ramp6(C.WHITE), GX.ramp6(C.RED)
  L(tw, function(xx, yy) return (((by - yy) // 10) % 2 == 0) and WH or RD end, x, { R = 8, nr = true, rimlight = true })
  L(R(mk(), x - 9, by - h - 3, x + 9, by - h), C.WOOD, x, { R = 2, nr = true })
  L(R(mk(), x - 5, by - h - 13, x + 5, by - h - 3), rp("#fffbc8", "#ffe070", "#f0b040", "#c07830"), x, { R = 4, nr = true, amb = .6, wrap = .6 })
  L(c:poly{ { x - 8, by - h - 12 }, { x, by - h - 22 }, { x + 8, by - h - 12 } }, C.RED, x + 1, { R = 6, nr = true })
  c:px(x, by - h - 23, C.GOLD.hi)
  L(R(mk(), x - 3, by - 10, x + 3, by), C.WOOD, 2, { R = 3, nr = true })
end
function P.boat(x, y, o)
  local s = o.s or 1
  local mast = R(mk(), x, y - floor(30 * s), x + 1, y)
  L(mast, C.WOOD, x, { R = 2, nr = true })
  L(c:poly{ { x + 3, y - 2 }, { x + 3, y - floor(28 * s) }, { x + floor(18 * s), y - 4 } }, o.sail or C.WHITE, x, { R = 8, nr = true, amb = .4 })
  L(c:poly{ { x - 1, y - 2 }, { x - 1, y - floor(20 * s) }, { x - floor(12 * s), y - 4 } }, o.jib or C.CLOUD, x + 1, { R = 6, nr = true, amb = .4 })
  L(c:poly{ { x - floor(16 * s), y }, { x + floor(18 * s), y }, { x + floor(12 * s), y + 6 }, { x - floor(11 * s), y + 6 } }, o.hull or C.RED, x + 2, { R = 5, nr = true, rimlight = true })
  for k = -floor(15 * s), floor(15 * s), 5 do c:px(x + k, y + 9, C.WATER.hi); c:px(x + k + 1, y + 9, C.WATER.hi) end
end
function P.cactus(x, by, o)
  local yt, w = by - (o.h or 56), o.w or 6
  local m = mk()
  R(m, x - w, yt + w, x + w, by); E(m, x, yt + w, w)
  for _, a in ipairs(o.arms or { { 28, 1, 13, 18 }, { 18, -1, 12, 12 } }) do
    local ay, side, reach, rise = by - a[1], a[2], a[3], a[4]
    local aw = max(2, w - 2); local ex = x + side * reach
    R(m, min(x, ex), ay - aw, max(x, ex), ay + aw); R(m, ex - aw, ay - rise, ex + aw, ay + aw); E(m, ex, ay - rise, aw)
  end
  SH(x + w + 5, by, w * 3)
  L(m, o.R or C.GREEN, x, { R = w + 2, tex = .35, sc = 3, rimlight = true, fn = function(xx, yy) return (((xx + 1000) // 3) % 2 - .5) * .16 end })
  c:px(x, yt - 1, C.PINK.base); c:px(x - 1, yt - 1, C.PINK.base); c:px(x + 1, yt - 1, C.PINK.base); c:px(x, yt - 2, C.GOLD.hi)
end
function P.baobab(x, by, o)
  local h, bw = o.h or 56, o.bw or 14
  local m = mk()
  for y = by - h, by do
    local t = (by - y) / h
    local half = bw * (1.0 - .45 * t) + 2.5 * sin(t * 5) + (t < .12 and (1 - t / .12) * 4 or 0)
    for xx = floor(x - half), floor(x + half) do m:set(xx, y) end
  end
  SH(x + 12, by, bw * 1.4)
  L(m, o.TR or rp("#d8b090", "#a8806c", "#78565a", "#4a3444"), x, { R = bw, tex = .5, sc = 3, rimlight = true, fn = function(xx, yy) return ((xx // 3) % 3 == 0) and -.1 or 0 end })
  for k, a in ipairs{ -50, -20, 20, 50 } do
    local pts = { { x, by - h + 4 }, { x + a * .45, by - h - 8 }, { x + a, by - h - 14 } }
    L(LN(pts, 3), o.TR or rp("#d8b090", "#a8806c", "#78565a", "#4a3444"), k, { R = 2, nr = true })
  end
  GX.foliage(c, x, by - h - 14, 32, 8, o.R or C.GREEN, x + 5)
end
function P.acacia(x, by, o)
  local h, rw = o.h or 50, o.rw or 28
  local lean = o.lean or 4
  SH(x + 8, by, 10)
  L(LN({ { x, by }, { x + lean, by - h * .5 }, { x + lean, by - h + 4 } }, 4), o.TR or C.BARK, x, { R = 3, nr = true })
  L(LN({ { x + lean, by - h * .6 }, { x + lean - rw * .5, by - h + 6 } }, 2), o.TR or C.BARK, x + 1, { R = 2, nr = true })
  L(LN({ { x + lean, by - h * .6 }, { x + lean + rw * .5, by - h + 6 } }, 2), o.TR or C.BARK, x + 2, { R = 2, nr = true })
  GX.foliage(c, x + lean, by - h, rw, 6, o.R or C.DKGRN, x + 9)
end
function P.cypress(x, by, o)
  local h, w = o.h or 60, o.w or 7
  SH(x + 5, by, 9)
  local m = E(mk(), x, by - h / 2, w, floor(h / 2)); R(m, x - 1, by - 6, x + 1, by)
  L(m, o.R or rp("#4a9a58", "#2a7248", "#1c5440", "#103830"), x, { R = w + 1, tex = .5, sc = 3, rimlight = true })
end
function P.mushroom(x, by, o)
  local r = o.r or 14
  SH(x + 6, by, r)
  L(R(mk(), x - 4, by - r, x + 4, by), C.CREAM, x, { R = 4, nr = true })
  local cap = E(mk(), x, by - r, r, floor(r * .7)); cap:clip(R(mk(), x - r - 1, by - r * 2, x + r + 1, by - r + 2))
  L(cap, o.R or C.RED, x + 1, { R = r, rimlight = true, nr = true })
  for k, p in ipairs{ { -5, -4 }, { 3, -7 }, { 7, -2 }, { -1, -1 } } do
    c:px(x + p[1], by - r + p[2], C.WHITE.hi); c:px(x + p[1] + 1, by - r + p[2], C.WHITE.hi); c:px(x + p[1], by - r + p[2] + 1, C.WHITE.base)
  end
end
function P.columns(x, by, o)
  local n, sp, h = o.n or 4, o.sp or 16, o.h or 40
  local x0 = x - (n - 1) * sp // 2
  SH(x + 10, by, n * sp * .5)
  L(R(mk(), x0 - 12, by - 3, x0 + (n - 1) * sp + 12, by), C.STONE, x, { R = 2, nr = true })
  for i = 0, n - 1 do
    local cx = x0 + i * sp
    L(R(mk(), cx - 4, by - h, cx + 3, by - 3), o.R or C.WHITE, i, { R = 5, nr = true, rimlight = true, fn = function(xx, yy) return ((xx - cx) % 3 == 0) and -.1 or 0 end })
    L(R(mk(), cx - 6, by - h - 3, cx + 5, by - h), o.R or C.WHITE, i + 4, { R = 2, nr = true })
  end
  L(R(mk(), x0 - 10, by - h - 8, x0 + (n - 1) * sp + 10, by - h - 3), o.R or C.WHITE, 3, { R = 3, nr = true, rimlight = true })
  L(c:poly{ { x0 - 12, by - h - 8 }, { x, by - h - 22 }, { x0 + (n - 1) * sp + 12, by - h - 8 } }, o.R or C.WHITE, 5, { R = 8, nr = true, rimlight = true })
  E(mk(), x, by - h - 13, 2); c:fillMask(E(mk(), x, by - h - 13, 2), C.TEAL.base)
end
function P.rock(x, by, o)
  local rx, ry = o.rx or 20, o.ry or 12
  local m = E(mk(), x, by - ry + 2, rx, ry)
  m:clip(R(mk(), x - rx - 2, by - ry * 2 - 2, x + rx + 2, by + 1))
  SH(x + 5, by, rx)
  L(m, o.R or C.ROCK, x, { R = max(rx, 6), tex = .45, sc = 3, rimlight = true, nr = o.nr,
    fn = function(xx, yy) return o.streak and (((xx // 3) % 3 == 0) and -.1 or 0) or 0 end })
end
function P.mesa(x, by, o)
  local w, h = o.w or 70, o.h or 40
  local m = c:poly{ { x - w / 2, by }, { x - w / 2 + 6, by - h }, { x + w / 2 - 6, by - h }, { x + w / 2, by } }
  SH(x + 10, by, w * .5)
  L(m, o.R or C.REDROCK, x, { R = 14, nr = true, tex = .3, rimlight = true,
    fn = function(xx, yy) return (((yy // 5) % 2) - .5) * .14 - (xx - x) / w * .4 end })
end
function P.arch(x, by, o)
  local w, h = o.w or 90, o.h or 56
  local m = c:poly{ { x - w / 2, by }, { x - w / 2 + 8, by - h }, { x + w / 2 - 8, by - h }, { x + w / 2, by } }
  local hole = E(mk(), x, by - 6, floor(w * .24), floor(h * .5)); hole:clip(R(mk(), x - w, by - h, x + w, by - 8 + 6))
  R(hole, x - floor(w * .24), by - 6, x + floor(w * .24), by)
  m:cut(hole)
  SH(x + 10, by, w * .55)
  L(m, o.R or C.REDROCK, x, { R = 12, nr = true, rimlight = true, tex = .3, fn = function(xx, yy) return (((yy // 5) % 2) - .5) * .14 - (xx - x) / w * .5 end })
  hole:each(function(xx, yy) if yy < by and not hole:has(xx, yy - 1) then end end)
end
function P.steps(x, by, o)
  local n, w, th = o.n or 4, o.w or 64, o.th or 11
  SH(x + 10, by, w * .5)
  for i = 0, n - 1 do
    local bw = floor(w * (1 - i / (n + .5)))
    local yb = by - i * th
    L(R(mk(), x - bw // 2, yb - th, x + bw // 2, yb), o.R or C.STONE, i, { R = 6, nr = true, rimlight = true, fn = function(xx, yy) return ((xx + yy // th) % 9 == 0) and -.12 or 0 end })
    if o.grass then L(R(mk(), x - bw // 2, yb - th, x + bw // 2, yb - th + 2), C.GREEN, i + 3, { R = 2, nr = true, ink = false }) end
  end
  if o.spire then
    local yt = by - n * th
    L(c:poly{ { x - 5, yt }, { x - 3, yt - o.spire * .6 }, { x, yt - o.spire }, { x + 3, yt - o.spire * .6 }, { x + 5, yt } }, o.R or C.STONE, 4, { R = 6, nr = true, rimlight = true })
    c:px(x, yt - o.spire - 1, C.GOLD.hi)
  end
  if o.door then L(R(mk(), x - 4, by - 12, x + 4, by), rp("#6a4a52", "#4a3240", "#322230", "#221826"), 3, { R = 3, nr = true }) end
end
function P.tower(x, by, o)
  local w, h = o.w or 30, o.h or 60
  SH(x + 10, by, w)
  local m = R(mk(), x - w // 2, by - h, x + w // 2, by)
  L(m, o.wall or C.STONE, x, { R = 10, nr = true, rimlight = true, tex = .5, fn = function(xx, yy) return ((yy // 5 + (xx // 6) * ((yy // 5) % 2)) % 4 == 0 and (yy % 5 == 0)) and -.15 or 0 end })
  for k = 0, 3 do L(R(mk(), x - w // 2 - 1 + k * floor(w / 3.2), by - h - 5, x - w // 2 + 2 + k * floor(w / 3.2), by - h), o.wall or C.STONE, k, { R = 2, nr = true }) end
  L(c:poly{ { x - w // 2 - 2, by - h - 5 }, { x, by - h - 28 }, { x + w // 2 + 2, by - h - 5 } }, o.roof or C.BLUE, x + 1, { R = 8, nr = true, rimlight = true })
  c:px(x, by - h - 29, C.RED.base); c:px(x + 1, by - h - 29, C.RED.base); c:px(x + 1, by - h - 28, C.RED.base)
  L(R(mk(), x - 2, by - h + 10, x + 1, by - h + 16), rp("#fff6b8", "#ffd25a", "#f09a40", "#c0642c"), 5, { R = 2, nr = true, amb = .6 })
  L(R(mk(), x - 3, by - 11, x + 3, by), C.WOOD, 3, { R = 3, nr = true })
end
function P.torii(x, by, o)
  local w, h = o.w or 44, o.h or 44
  SH(x + 6, by, w * .5)
  for _, px_ in ipairs{ x - w // 2 + 4, x + w // 2 - 4 } do L(R(mk(), px_ - 2, by - h, px_ + 2, by), C.RED, px_, { R = 3, nr = true, rimlight = true }) end
  L(c:poly{ { x - w // 2 - 6, by - h - 6 }, { x - w // 2 + 2, by - h - 1 }, { x + w // 2 - 2, by - h - 1 }, { x + w // 2 + 6, by - h - 6 }, { x + w // 2 + 4, by - h + 2 }, { x - w // 2 - 4, by - h + 2 } }, C.RED, 5, { R = 4, nr = true, rimlight = true })
  L(R(mk(), x - w // 2 + 2, by - h + 8, x + w // 2 - 2, by - h + 11), C.RED, 7, { R = 3, nr = true })
end
function P.totem(x, by, o)
  local cols = { C.RED, C.TEAL, C.GOLD, C.VIOLET, C.ORANGE }
  SH(x + 8, by, 14)
  local n = o.n or 5
  for i = 0, n - 1 do
    local y1 = by - i * 14
    L(R(mk(), x - 6, y1 - 14, x + 6, y1), cols[i % #cols + 1], i + x, { R = 6, nr = true, rimlight = true })
    c:fillMask(R(mk(), x - 4, y1 - 10, x - 2, y1 - 8), INK); c:fillMask(R(mk(), x + 2, y1 - 10, x + 4, y1 - 8), INK)
    c:fillMask(R(mk(), x - 3, y1 - 4, x + 3, y1 - 3), INK)
    c:px(x - 3, y1 - 9, C.WHITE.hi); c:px(x + 3, y1 - 9, C.WHITE.hi)
    if i == 2 then
      L(c:poly{ { x - 6, y1 - 12 }, { x - 20, y1 - 6 }, { x - 6, y1 - 3 } }, C.TEAL, 4, { R = 4, nr = true, rimlight = true })
      L(c:poly{ { x + 6, y1 - 12 }, { x + 20, y1 - 6 }, { x + 6, y1 - 3 } }, C.TEAL, 6, { R = 4, nr = true, rimlight = true })
    end
  end
  L(c:poly{ { x - 6, by - n * 14 }, { x, by - n * 14 - 8 }, { x + 6, by - n * 14 } }, C.GOLD, 7, { R = 4, nr = true })
end
function P.igloo(x, by, o)
  local r = o.r or 30
  SH(x + 8, by, r)
  local m = E(mk(), x, by, r, floor(r * .75)); m:clip(R(mk(), x - r - 2, by - r, x + r + 2, by))
  L(m, C.SNOW, x, { R = r, tex = .15, rimlight = true, nr = true, fn = function(xx, yy) return ((yy // 6 + xx // 8 * ((yy // 6) % 2)) % 3 == 0 and (yy % 6 == 0)) and -.2 or 0 end })
  local tun = R(mk(), x - r - 6, by - 14, x - r + 14, by); tun:clip(E(mk(), x - r + 4, by - 6, 14, 12))
  L(tun, C.SNOW, x + 1, { R = 6, nr = true, rimlight = true })
  L(E(mk(), x - r + 4, by - 4, 6, 8):clip(R(mk(), x - r - 4, by - 14, x - r + 14, by)), rp("#4a4a6c", "#34345a", "#242446", "#181832"), 2, { R = 3, nr = true, ink = false })
end
function P.reeds(x, by, o)
  local n = o.n or 5
  for i = 0, n - 1 do
    local sx = x + (i - n // 2) * 4 + floor((H(i, x, 1) - .5) * 3)
    local hh = (o.h or 30) + floor(H(i, x, 2) * 14)
    local lean = floor((H(i, x, 3) - .5) * 6)
    for k = 0, hh do
      local px_ = sx + floor(lean * (k / hh) ^ 2)
      c:px(px_, by - k, (k > hh * .7) and C.GREEN.base or C.DKGRN.base); c:px(px_ + 1, by - k, C.DKGRN.shade)
    end
    if i % 2 == 0 then
      local tx = sx + lean
      c:fillMask(R(mk(), tx - 2, by - hh - 6, tx + 2, by - hh + 1), INK)
      c:fillMask(R(mk(), tx - 1, by - hh - 5, tx + 1, by - hh), C.BROWN.base); c:px(tx - 1, by - hh - 5, C.BROWN.hi); c:px(tx + 1, by - hh, C.BROWN.deep)
      c:px(tx, by - hh - 8, C.BROWN.shade); c:px(tx, by - hh - 7, C.BROWN.shade)
    end
  end
end
function P.lily(x, y, o)
  local m = E(mk(), x, y, 8, 3); m:cut(R(mk(), x, y - 1, x + 8, y))
  L(m, C.GREEN, x, { R = 4, nr = true, rimlight = true })
  if o.flower then c:px(x - 3, y - 2, C.PINK.base); c:px(x - 2, y - 3, C.PINK.hi); c:px(x - 4, y - 3, C.PINK.hi); c:px(x - 3, y - 3, C.GOLD.base); c:px(x - 2, y - 2, C.PINK.base) end
end
function P.heron(x, by, o)
  local body = o.body or rp("#e8ecf4", "#b8c4d8", "#8494b4", "#566488")
  local bm = mk()
  E(bm, x, by - 22, 7, 4)
  bm:add(LN({ { x - 6, by - 22 }, { x - 12, by - 20 } }, 3))
  bm:add(LN({ { x + 4, by - 24 }, { x + 8, by - 30 }, { x + 4, by - 36 }, { x + 8, by - 42 } }, 2))
  E(bm, x + 9, by - 43, 3, 2)
  L(bm, body, x, { R = 4, nr = true, rimlight = true })
  LN({ { x + 11, by - 43 }, { x + 18, by - 41 } }, 1):each(function(xx, yy) c:px(xx, yy, o.beak or C.GOLD.base) end)
  c:px(x + 9, by - 44, INK)
  for _, lx in ipairs{ x - 1, x + 2 } do for yy = by - 18, by do c:px(lx, yy, o.leg or C.GOLD.shade) end c:px(lx + 1, by, o.leg or C.GOLD.shade) end
end
function P.parrot(x, y, o)
  local body = o.body or C.RED
  local bm = mk(); E(bm, x, y, 4, 7); E(bm, x + 1, y - 9, 3, 3)
  bm:add(R(mk(), x - 2, y + 5, x, y + 18))
  L(bm, body, x, { R = 4, nr = true, rimlight = true })
  L(E(mk(), x - 1, y + 1, 3, 5), o.wing or C.BLUE, x + 3, { R = 3, nr = true })
  L(c:poly{ { x + 3, y - 10 }, { x + 8, y - 8 }, { x + 4, y - 6 } }, C.GOLD, x + 1, { R = 2, nr = true })
  c:px(x + 2, y - 10, INK); c:px(x + 1, y - 10, C.WHITE.hi)
  if o.branch then L(R(mk(), x - 10, y + 7, x + 10, y + 9), C.BARK, x, { R = 2, nr = true }) end
end
function P.animal(x, by, o)
  local dir = o.dir or 1
  local ll, lw = o.leg or 12, o.lw or 3
  local rx, ry = o.rx or 8, o.ry or 5
  local bcy = by - ll - ry + 2
  local m = mk()
  E(m, x, bcy, rx, ry)
  for _, lo in ipairs{ -rx + 2, -rx + 5, rx - 6, rx - 3 } do R(m, x + lo, bcy, x + lo + lw - 1, by) end
  local nx, ny = o.nx or 4, o.ny or 18
  local sx, sy = x + dir * (rx - 3), bcy - ry + 2
  local hx, hy = sx + dir * nx, sy - ny
  if ny ~= 0 or nx ~= 0 then m:add(LN({ { sx, sy }, { hx, hy } }, o.nw or 3)) end
  E(m, hx + dir * 2, hy, o.hrx or 3, o.hry or 2)
  if o.snout then R(m, min(hx + dir * 2, hx + dir * (2 + o.snout)), hy, max(hx + dir * 2, hx + dir * (2 + o.snout)), hy + 2) end
  if o.trunk then m:add(LN({ { hx + dir * 4, hy + 1 }, { hx + dir * 8, hy + 8 }, { hx + dir * 9, hy + 14 } }, 3)) end
  for _, hmp in ipairs(o.humps or {}) do E(m, x + hmp, bcy - ry, 4, 4) end
  m:add(LN({ { x - dir * rx, bcy - 1 }, { x - dir * (rx + (o.tail or 4)), bcy + 4 } }, 2))
  if o.ear then m:add(R(mk(), hx - 1, hy - 4, hx, hy - 3)); m:add(R(mk(), hx + 2, hy - 4, hx + 3, hy - 3)) end
  if o.horns then m:add(LN({ { hx, hy - 2 }, { hx + dir * 2, hy - 7 }, { hx + dir * 5, hy - 8 } }, 1)) end
  SH(x + 5, by, rx + 4)
  L(m, o.R or C.ORANGE, x, { R = 5, nr = true, rimlight = true, tex = .35,
    fn = function(xx, yy) return (o.spots and H(xx // 3, yy // 3, x) < .24 and yy < by - 3) and -.4 or 0 end })
  c:px(hx + dir * 3, hy - 1, INK)
  if o.tusk then c:px(hx + dir * 5, hy + 5, C.WHITE.hi); c:px(hx + dir * 6, hy + 6, C.WHITE.hi) end
end
function P.hay(x, by, o)
  local r = o.r or 11
  SH(x + 5, by, r + 2)
  L(E(mk(), x, by - r + 2, r, r - 1), C.YEL, x, { R = r, rimlight = true, nr = true, fn = function(xx, yy) return (((xx + yy) // 3) % 2 - .5) * .22 end })
  L(R(mk(), x - r, by - r - 1, x + r, by - r + 1), C.THATCH, x + 2, { R = 2, nr = true, ink = false })
end
function P.fence(x, by, o)
  local n = o.n or 6
  for i = 0, n - 1 do
    local px_ = x + i * 14
    L(R(mk(), px_, by - 14, px_ + 3, by), C.WOOD, i, { R = 2, nr = true, rimlight = true })
  end
  for _, ry_ in ipairs{ by - 11, by - 5 } do L(R(mk(), x - 2, ry_, x + (n - 1) * 14 + 5, ry_ + 2), C.WOOD, ry_, { R = 2, nr = true }) end
end
function P.crystals(x, by, o)
  local Rm = o.R or C.CRYST
  SH(x + 4, by, 14)
  for i, p in ipairs(o.list or { { -8, 22, 5 }, { 0, 34, 6 }, { 8, 18, 5 } }) do
    local cx, hh, hw = x + p[1], p[2], p[3]
    L(c:poly{ { cx - hw, by }, { cx - hw + 1, by - hh + 8 }, { cx, by - hh }, { cx + hw - 1, by - hh + 8 }, { cx + hw, by } }, Rm, i + x, { R = hw, nr = true, rimlight = true, amb = .45, wrap = .5 })
  end
  c:px(x + 1, by - (o.list and 28 or 30), Rm.hi); c:sparkle(x - 12, by - 26)
end
function P.cave(x, by, o)
  local rx, ry = o.rx or 60, o.ry or 40
  local m = E(mk(), x, by, rx, ry); m:clip(R(mk(), x - rx - 2, by - ry - 2, x + rx + 2, by + 1))
  SH(x + 10, by, rx)
  L(m, o.R or C.DARK, x, { R = ry, tex = .5, sc = 4, rimlight = true, fn = function(xx, yy) return o.grass and (H(xx // 2, yy, 2) - .5) * .25 or 0 end })
  local mw, mh = o.mw or 16, o.mh or 22
  local mouth = R(mk(), x - mw, by - mh, x + mw, by); mouth:clip(E(mk(), x, by - mh + mw, mw, mw):add(R(mk(), x - mw, by - mh + mw, x + mw, by)))
  c:rim(mouth, INK)
  L(mouth, rp("#4a3a5a", "#2c2038", "#1e1428", "#120c1c"), 3, { R = 4, nr = true, ink = false, tex = .15 })
  if o.timber then
    L(R(mk(), x - mw - 3, by - mh + 2, x - mw, by), C.WOOD, 1, { R = 2, nr = true }); L(R(mk(), x + mw, by - mh + 2, x + mw + 3, by), C.WOOD, 2, { R = 2, nr = true })
    L(R(mk(), x - mw - 4, by - mh - 2, x + mw + 4, by - mh + 2), C.WOOD, 3, { R = 2, nr = true, rimlight = true })
  end
  if o.eyes then
    for _, ex in ipairs{ x - 7, x + 5 } do
      c:fillMask(R(mk(), ex, by - 14, ex + 3, by - 11), "#ff9a30"); c:fillMask(R(mk(), ex + 1, by - 13, ex + 2, by - 12), "#fff0a0"); c:px(ex, by - 14, "#ffd060")
    end
  end
end
function P.stall(x, by, o)
  local w = o.w or 56
  SH(x + 8, by, w * .6)
  L(R(mk(), x - w // 2, by - 14, x + w // 2, by), C.WOOD, x, { R = 6, nr = true, rimlight = true, fn = function(xx, yy) return ((xx - x) % 7 == 0) and -.15 or 0 end })
  for _, px_ in ipairs{ x - w // 2 - 1, x + w // 2 - 1 } do L(R(mk(), px_, by - 46, px_ + 2, by - 14), C.WOOD, px_, { R = 2, nr = true }) end
  local a1, a2 = GX.ramp6(o.a1 or C.RED), GX.ramp6(o.a2 or C.WHITE)
  local aw = R(mk(), x - w // 2 - 4, by - 48, x + w // 2 + 4, by - 36)
  for xx = x - w // 2 - 4, x + w // 2 + 4 do
    if ((xx - x) // 7) % 2 == 0 then end
    local sc = ((xx - x + 1000) // 7) % 2 == 0
    if sc then aw:set(xx, by - 35); aw:set(xx, by - 34) end
  end
  L(aw, function(xx, yy) return (((xx - x + 1000) // 7) % 2 == 0) and a1 or a2 end, x, { R = 8, nr = true, rimlight = true })
  for k, col in ipairs(o.goods or {}) do
    local gx = x - w // 2 + 8 + (k - 1) * floor((w - 16) / max(1, #o.goods - 1))
    L(E(mk(), gx, by - 18, 5, 4), col, k + x, { R = 4, nr = true, rimlight = true })
  end
end
function P.barrel(x, by, o)
  SH(x + 4, by, 9)
  L(E(mk(), x, by - 8, 7, 8):clip(R(mk(), x - 8, by - 17, x + 8, by)), C.WOOD, x, { R = 7, nr = true, rimlight = true })
  for _, yy in ipairs{ by - 12, by - 4 } do for xx = x - 6, x + 6 do c:px(xx, yy, C.STONE.shade) end end
end
function P.lantern(x, by, o)
  L(R(mk(), x, by - 30, x + 1, by), C.DARK, x, { R = 2, nr = true })
  L(R(mk(), x - 3, by - 38, x + 4, by - 30), rp("#fff6b8", "#ffd25a", "#f09a40", "#c0642c"), x, { R = 4, nr = true, amb = .7, wrap = .6 })
  L(c:poly{ { x - 4, by - 38 }, { x, by - 43 }, { x + 5, by - 38 } }, C.DARK, x, { R = 3, nr = true })
end
function P.well(x, by, o)
  SH(x + 6, by, 14)
  L(R(mk(), x - 12, by - 12, x + 12, by), C.STONE, x, { R = 6, nr = true, rimlight = true, fn = function(xx, yy) return (((xx // 5) + (yy // 4)) % 3 == 0) and -.14 or 0 end })
  L(R(mk(), x - 10, by - 26, x - 8, by - 12), C.WOOD, 1, { R = 2, nr = true }); L(R(mk(), x + 8, by - 26, x + 10, by - 12), C.WOOD, 2, { R = 2, nr = true })
  L(c:poly{ { x - 14, by - 25 }, { x, by - 35 }, { x + 14, by - 25 } }, C.TERRA, 3, { R = 6, nr = true, rimlight = true })
end
function P.cart(x, by, o)
  SH(x + 6, by, 18)
  L(c:poly{ { x - 14, by - 18 }, { x + 14, by - 18 }, { x + 10, by - 5 }, { x - 10, by - 5 } }, C.BROWN, x, { R = 5, nr = true, rimlight = true })
  for k, p in ipairs{ { -8, -22 }, { 0, -25 }, { 7, -22 } } do L(E(mk(), x + p[1], by + p[2] + 2, 4, 3), C.CRYST, k, { R = 3, nr = true, amb = .5 }) end
  for _, wx in ipairs{ x - 8, x + 8 } do L(E(mk(), wx, by - 3, 4, 4), C.GREY, wx, { R = 3, nr = true, rimlight = true }); c:px(wx, by - 3, INK) end
end
function P.egg(x, by, o)
  local r = o.r or 9
  SH(x + 4, by, r)
  L(E(mk(), x, by - r - 2, r - 2, r), o.R or C.CREAM, x, { R = r, nr = true, rimlight = true, fn = function(xx, yy) return (H(xx // 3, yy // 3, 4) < .15) and -.3 or 0 end })
end
function P.deadtree(x, by, o)
  local h = o.h or 56
  SH(x + 5, by, 10)
  local m = LN({ { x, by }, { x - 2, by - h * .5 }, { x + 2, by - h } }, 4)
  m:add(LN({ { x - 1, by - h * .45 }, { x - 14, by - h * .75 }, { x - 18, by - h * .72 } }, 2)); m:add(LN({ { x, by - h * .6 }, { x + 14, by - h * .85 }, { x + 18, by - h * .95 } }, 2))
  m:add(LN({ { x + 1, by - h * .8 }, { x - 8, by - h - 2 } }, 2))
  L(m, o.R or C.BROWN, x, { R = 3, nr = true, rimlight = true })
end
function P.bones(x, by, o)
  SH(x + 5, by, 20)
  local m = mk()
  for k = 0, 3 do m:add(LN({ { x - 12 + k * 7, by }, { x - 10 + k * 7, by - 14 }, { x - 4 + k * 7, by - 20 } }, 2)) end
  m:add(R(mk(), x - 14, by - 2, x + 18, by))
  L(m, C.WHITE, x, { R = 3, nr = true, rimlight = true })
end
function P.sparklefield(x, by, o) for k = 1, o.n or 6 do c:sparkle(x + floor((H(k, x, 1) - .5) * (o.w or 80)), by - floor(H(k, x, 2) * (o.h or 30))) end end
function P.stones(x, by, o)
  local list = o.list or { { -52, 36, 9 }, { -30, 46, 10 }, { 0, 52, 11 }, { 30, 46, 10 }, { 52, 36, 9 } }
  SH(x + 10, by, 66)
  for i, s in ipairs(list) do
    local sx = x + s[1]
    L(c:poly{ { sx - s[3], by }, { sx - s[3] + 1, by - s[2] + 4 }, { sx - 2, by - s[2] }, { sx + s[3] - 2, by - s[2] + 3 }, { sx + s[3], by } }, o.R or C.ROCK, i + x, { R = 7, nr = true, rimlight = true, tex = .5 })
    for k = 0, 2 do c:px(sx - 1, by - s[2] + 12 + k * 5, o.rune or C.GOLD.hi); c:px(sx, by - s[2] + 13 + k * 5, o.rune or C.GOLD.base) end
  end
  if o.lintel then
    L(R(mk(), x - 20, by - 62, x + 20, by - 53), o.R or C.ROCK, 9, { R = 5, nr = true, rimlight = true })
  end
end
function P.leafplant(x, by, o)
  SH(x + 4, by, 14)
  local fm = fronds(x, by - 4, { -170, -140, -110, -70, -40, -10 }, o.len or 24, 6, 5, nil, 1)
  L(fm, o.R or C.GREEN, x, { R = 4, nr = true, rimlight = true })
end
function P.bird(x, y, o) -- tiny gull V
  for k = 0, 4 do c:px(x - k, y + (k // 2) * -1 + 1, INK); c:px(x + k, y + (k // 2) * -1 + 1, INK) end
end
function P.vines(x, y0, o) -- hanging vine strands from a canopy
  for k = 0, (o.n or 4) - 1 do
    local vx = x + k * 5
    local len = (o.len or 30) + floor(H(k, x, 5) * 12)
    for yy = 0, len do c:px(vx + floor(sin(yy / 6 + k) * 1.2), y0 + yy, (yy % 5 == 0) and C.GREEN.hi or C.DKGRN.base) end
  end
end

--------------------------------------------------------------------------- finish4 props
-- tall trunk + layered canopy of separately lit clumps (back clumps darker, lit clumps in front/upper-left)
function P.tree(x, by, o)
  local h = o.h or 60
  local rw = o.rw or floor(h * .42)
  local rh = o.rh or floor(h * .3)
  local TR, RR = o.TR or C.BARK, o.R or C.GREEN
  local seed = o.seed or x
  local cy = by - h + rh
  SH(x + rw * .4, by, max(9, floor(rw * .6)))
  local tw = o.tw or 2
  local top = cy + floor(rh * .1)
  local tm = mk()
  for y = top, by do
    local t = (y - top) / max(1, by - top)
    local half = tw + .5 + t * 1.4 + ((y > by - 5) and (y - (by - 5)) * 1.0 or 0)
    local wob = floor((GX.vn(0, y, 11, seed) - .5) * 3)
    for xx = floor(x - half + wob), floor(x + half + wob) do tm:set(xx, y) end
  end
  tm:add(LN({ { x, cy + rh * .6 }, { x - rw * .5, cy - rh * .1 } }, 2))
  tm:add(LN({ { x, cy + rh * .5 }, { x + rw * .55, cy - rh * .05 } }, 2))
  L(tm, TR, seed, { R = 4, nr = true, tex = .35, sc = 3, rimlight = true,
    fn = function(xx, yy) return (((xx - x) % 3 == 0) and -.14 or 0) + ((H(xx, yy // 3, seed) < .08) and -.2 or 0) end })
  if o.marks then for yy = top + 8, by - 3, 5 do for k = 0, 1 do c:px(x - 1 + k * 2 + (yy % 3), yy, C.BIRCH.deep) end end end
  -- clumps
  local cl = {}
  local N = max(7, floor(rw / 3.6))
  for i = 1, N do
    local a = H(i, seed, 1) * 6.283
    local rr = sqrt(H(i, seed, 2)) * .8
    cl[#cl + 1] = { x = x + cos(a) * rw * rr * .9, y = cy + sin(a) * rh * rr * .85 + rh * .08, r = floor(rh * .52 + H(i, seed, 3) * rh * .3) }
  end
  cl[#cl + 1] = { x = x - rw * .55, y = cy + rh * .15, r = floor(rh * .6) }
  cl[#cl + 1] = { x = x + rw * .55, y = cy + rh * .2, r = floor(rh * .55) }
  cl[#cl + 1] = { x = x - rw * .15, y = cy - rh * .35, r = floor(rh * .75) }
  table.sort(cl, function(a, b) return a.y < b.y end)
  for i, k in ipairs(cl) do
    local f = (i - 1) / max(1, #cl - 1)         -- 0 back .. 1 front
    local m = mk(); E(m, floor(k.x), floor(k.y), k.r + 1, k.r)
    m = GX.rough(m, seed + i, 1)
    local dim = .45 * (1 - f)
    local Rd = { hi = GX.mix(RR.hi, RR.shade, dim * .5), base = GX.mix(RR.base, RR.shade, dim), shade = GX.mix(RR.shade, RR.deep, dim), deep = RR.deep }
    GX.lit(c, m, GX.ramp6(Rd), { R = k.r + 2, tex = .55, sc = 3, seed = seed + i, amb = .2 + .1 * f, rimlight = true,
      fn = function(xx, yy) return (H(xx // 2, yy // 2, seed + i) - .5) * .25 end })
    -- lit leaf dabs on the upper-left
    for j = 1, 3 do
      local lx = floor(k.x - k.r * .5 + H(j, i, seed) * k.r * .6)
      local ly = floor(k.y - k.r * .55 + H(j, i, seed + 4) * k.r * .5)
      if m:has(lx, ly) and m:has(lx + 3, ly + 1) then
        c:px(lx, ly, RR.hi); c:px(lx + 1, ly, RR.hi); c:px(lx + 2, ly, RR.hi); c:px(lx + 1, ly + 1, RR.base); c:px(lx - 1, ly + 1, RR.base)
      end
    end
    if o.fruit and i % 3 == 0 then c:px(floor(k.x) + 2, floor(k.y) + 2, C.RED.base); c:px(floor(k.x) + 3, floor(k.y) + 2, C.RED.hi) end
  end
end

local function onion(cx, by, Rr, hgt, Rm, seed, o)
  o = o or {}
  local m = mk()
  for y = by - hgt, by do
    local t = (by - y) / hgt
    local w
    if t < .28 then w = Rr * (.8 + .2 * sin(t / .28 * pi / 2))
    else local u = (t - .28) / .72; w = Rr * (1 - u ^ 1.6) ^ .72 end
    if t > .86 then w = w * (1 - ((t - .86) / .14) ^ 1.2 * .3) end
    for xx = floor(cx - w), floor(cx + w) do m:set(xx, y) end
  end
  L(m, Rm, seed, { R = Rr, nr = true, tex = .2, rimlight = true, amb = .22,
    fn = function(xx, yy) return (((xx - cx + 200) % 7 == 0) and -.1 or 0) + (o.fn and o.fn(xx, yy) or 0) end })
  return by - hgt
end
function P.palace(x, by, o)
  local WHT = rp("#fffaf0", "#f4eadc", "#b8a6cc", "#6e5a92")
  local SAND = rp("#fff0d0", "#e8cc9c", "#b8946c", "#7a5a56")
  local DOOR = rp("#6e5a82", "#4a3a64", "#2e2448", "#1c1630")
  SH(x + 30, by, 100)
  -- plinth
  L(R(mk(), x - 82, by - 8, x + 82, by), SAND, x, { R = 5, nr = true, rimlight = true, fn = function(xx, yy) return ((xx // 6) % 2 == 0 and yy == by - 4) and -.12 or 0 end })
  L(R(mk(), x - 56, by - 11, x + 56, by - 8), SAND, x + 1, { R = 2, nr = true, rimlight = true })
  -- hall
  local hy = by - 11
  L(R(mk(), x - 48, hy - 28, x + 48, hy), WHT, x, { R = 12, nr = true, rimlight = true, tex = .2 })
  for k = -2, 2 do
    local ax, w, hh = x + k * 18, (k == 0) and 9 or 6, (k == 0) and 24 or 16
    if k == 0 then ax = x end
    local m = c:poly{ { ax - w, hy }, { ax - w, hy - hh * .6 }, { ax, hy - hh }, { ax + w, hy - hh * .6 }, { ax + w, hy } }
    c:rim(m, INK); L(m, DOOR, ax, { R = 4, nr = true, ink = false, tex = .1, amb = .1 })
    c:fillMask(c:poly{ { ax - w - 1, hy - hh * .6 }, { ax, hy - hh - 2 }, { ax - 1, hy - hh - 1 } }, WHT.shade)
  end
  L(R(mk(), x - 50, hy - 31, x + 50, hy - 28), C.GOLD, x, { R = 2, nr = true, rimlight = true })
  -- wing chhatris
  for _, s in ipairs{ -1, 1 } do
    local cx = x + s * 38
    L(R(mk(), cx - 4, hy - 38, cx - 3, hy - 31), WHT, cx, { R = 1, nr = true }); L(R(mk(), cx + 3, hy - 38, cx + 4, hy - 31), WHT, cx + 1, { R = 1, nr = true })
    local t = onion(cx, hy - 37, 7, 13, WHT, cx)
    c:px(cx, t - 1, C.GOLD.hi); c:px(cx, t - 2, C.GOLD.base)
  end
  -- drum + big dome
  local dy = hy - 31
  L(R(mk(), x - 22, dy - 14, x + 22, dy), WHT, x, { R = 10, nr = true, rimlight = true })
  for k = -2, 2 do c:fillMask(R(mk(), x + k * 8 - 1, dy - 10, x + k * 8 + 1, dy - 4), DOOR.base); c:px(x + k * 8 - 1, dy - 10, DOOR.hi) end
  L(R(mk(), x - 24, dy - 17, x + 24, dy - 14), C.GOLD, x, { R = 2, nr = true, rimlight = true })
  local top = onion(x, dy - 17, 26, 42, WHT, x + 3)
  -- gold finial: stacked balls, spike, crescent
  for k = 0, 11 do c:px(x, top - k, INK); c:px(x + 1, top - k, INK) end
  for k = 1, 10 do c:px(x, top - k, C.GOLD.base) end
  for _, yy in ipairs{ top - 3, top - 7 } do L(E(mk(), x, yy, 2, 2), C.GOLD, x, { R = 2, nr = true }) end
  c:px(x - 2, top - 11, C.GOLD.hi); c:px(x + 2, top - 11, C.GOLD.base); c:px(x - 2, top - 12, C.GOLD.base); c:px(x + 2, top - 12, C.GOLD.shade); c:px(x, top - 13, C.GOLD.hi); c:px(x, top - 12, C.GOLD.hi)
  -- minarets
  for _, s in ipairs{ -1, 1 } do
    local mx = x + s * 84
    local mh = 80
    L(R(mk(), mx - 8, by - 11, mx + 8, by - 8), SAND, mx, { R = 2, nr = true, rimlight = true })
    local body = c:poly{ { mx - 6, by - 10 }, { mx - 4, by - 10 - mh }, { mx + 4, by - 10 - mh }, { mx + 6, by - 10 } }
    L(body, WHT, mx, { R = 6, nr = true, rimlight = true, fn = function(xx, yy) return (((by - yy) // 8) % 2 == 0) and 0 or -.12 end })
    for _, gy in ipairs{ 28, 54, mh } do
      local yy = by - 10 - gy
      L(R(mk(), mx - 8, yy, mx + 8, yy + 3), C.GOLD, mx + gy, { R = 2, nr = true, rimlight = true })
      c:px(mx - 8, yy + 4, INK); c:px(mx + 8, yy + 4, INK)
    end
    for _, gy in ipairs{ 12, 40, 66 } do c:fillMask(R(mk(), mx - 1, by - 10 - gy - 6, mx, by - 10 - gy), DOOR.base) end
    local ty = by - 10 - mh - 1
    for _, px_ in ipairs{ mx - 5, mx + 4 } do L(R(mk(), px_, ty - 8, px_ + 1, ty), WHT, px_, { R = 1, nr = true }) end
    local t = onion(mx, ty - 8, 6, 13, WHT, mx + 5)
    c:px(mx, t - 1, INK); c:px(mx, t - 2, C.GOLD.hi); c:px(mx, t - 3, C.GOLD.base); c:px(mx - 1, t - 3, C.GOLD.base); c:px(mx + 1, t - 3, C.GOLD.shade)
  end
end

function P.monolith(x, by, o)
  local base = { { -102, 3 }, { -99, -9 }, { -94, -22 }, { -84, -36 }, { -68, -47 }, { -44, -54 }, { -16, -58 }, { 12, -59 }, { 40, -56 }, { 66, -48 }, { 84, -37 }, { 94, -24 }, { 99, -10 }, { 103, 3 } }
  local pts = {}
  for i, p in ipairs(base) do pts[#pts + 1] = { x + p[1] + floor((GX.vn(i * 7, 0, 2, 5) - .5) * 3), by + p[2] + floor((GX.vn(i * 3, 9, 2, 6) - .5) * 4) } end
  local m = c:poly(pts)
  local U = o.R or rp("#ffa468", "#e0603a", "#a63a40", "#5c2846")
  SH(x + 20, by + 1, 110)
  L(m, U, 17, { R = 30, tex = .22, sc = 4, amb = .3, nr = true, rimlight = true,
    fn = function(xx, yy)
      local v = -(xx - x + 14) / 200 * 1.0
      local sb = (by - yy + floor(3 * sin(xx / 21) + 2 * sin(xx / 7))) // 6
      local line = ((by - yy + floor(3 * sin(xx / 21) + 2 * sin(xx / 7))) % 6 == 0) and -.2 or 0
      v = v + line + ((sb % 3 == 0) and .08 or ((sb % 3 == 1) and -.05 or 0))
      local fl = GX.vn(xx, yy * .16, 3.2, 8)
      if fl < .3 and yy > by - 46 then v = v - .22 end
      return v
    end })
  -- cave overhangs + water stains
  for _, p in ipairs{ { -64, -10, 9, 4 }, { -22, -5, 6, 3 }, { 46, -9, 8, 4 } } do
    local cm = E(mk(), x + p[1], by + p[2], p[3], p[4]); cm:clip(m)
    c:rim(cm, INK); c:fillMask(cm, U.deep)
  end
  for k = 1, 7 do
    local sx = x - 80 + k * 22 + floor((H(k, 3, 3) - .5) * 8)
    local len = 14 + floor(H(k, 5, 3) * 16)
    local topy = by - 54 + floor(abs(sx - x + 10) * .22)
    for yy = topy + 3, topy + len do if m:has(sx, yy) then c:px(sx, yy, U.deep) end end
  end
  -- lit upper-left ridge + glints
  for xx = x - 70, x - 14 do local yy = by - 55 + floor((x - 14 - xx) * .16) - floor(abs(xx - x + 40) * .02); if m:has(xx, yy + 1) and H(xx, 1, 2) > .25 then c:px(xx, yy + 1, U.hi) end end
  -- scree + scrub at the foot
  for k = 0, 30 do
    local sx = x - 100 + floor(H(k, 2, 9) * 205)
    local sy = by + floor(H(k, 3, 9) * 3)
    c:fillMask(E(mk(), sx, sy, 3 + k % 3, 2), GX.mix("#e6a070", U.shade, .35)); c:px(sx - 1, sy - 1, U.hi)
  end
  for _, sx in ipairs{ x - 88, x - 40, x + 6, x + 60, x + 96 } do
    L(E(mk(), sx, by + 1, 5, 3), rp("#d0d88c", "#8ca860", "#5c8450", "#3c5c46"), sx, { R = 4, nr = true, rimlight = true })
    c:px(sx - 1, by - 3, "#d0d88c"); c:px(sx + 2, by - 2, "#d0d88c")
  end
end

function P.mesa2(x, by, o)
  local w, h = o.w or 100, o.h or 64
  local tiers = o.tiers or {
    { .96, .27, rp("#d89070", "#b05a44", "#7c3a42", "#4e2a3c") },
    { .76, .25, rp("#ffc48a", "#e88a4c", "#b45a44", "#783c48") },
    { .62, .22, rp("#fff0b0", "#f0c070", "#c88a50", "#8c5a48") },
    { .70, .26, rp("#e89a72", "#c25a40", "#8a3a40", "#52283a") } }
  -- talus slopes
  local SD = rp("#fff0b8", "#f2c070", "#d08e52", "#9c5e3e")
  L(c:poly{ { x - w * .72, by + 2 }, { x - w * .42, by - h * .24 }, { x + w * .42, by - h * .24 }, { x + w * .72, by + 2 } }, SD, x, { R = 20, tex = .35, sc = 3, rimlight = true, fn = function(xx, yy) return -(xx - x) / w * .5 end })
  SH(x + 14, by, w * .6)
  local y = by - 2
  for i, t in ipairs(tiers) do
    local hw, th = w * t[1] / 2, h * t[2]
    local last = (i == #tiers)
    local lean = (i == #tiers) and 3 or 1
    local m = c:poly{ { x - hw, y }, { x - hw + lean + (last and 0 or 1), y - th }, { x + hw - lean - (last and 0 or 1), y - th }, { x + hw, y } }
    if last then m:add(R(mk(), x - hw - 3, y - th, x + hw + 3, y - th + 3)) end
    local yb, y0 = y, y - th
    L(m, t[3], 40 + i, { R = 14, tex = .3, sc = 3, nr = true, rimlight = true,
      fn = function(xx, yy)
        local fl = GX.vn(xx, yy * .2, 3, i + 3)
        return -(xx - x) / w * .55 + ((fl < .3) and -.2 or 0) + ((((yb - yy) % 5) == 0 and H(xx // 4, yy, i) > .5) and -.14 or 0) end })
    for xx = x - hw, x + hw do if m:has(xx, y0) then c:px(xx, y0, t[3].hi) end end
    c:fillMask(R(mk(), x - hw + 1, yb - 1, x + hw - 1, yb - 1):clip(m), t[3].deep)
    y = y - th
  end
  c:px(x - 20, y - 4, C.SANDST.hi)
end

--------------------------------------------------------------------------- looks
local function sky6(a, b, c2, d2, e, f) return { a, b, c2, d2, e, f } end
local LOOK = {}
local function look(n, t) LOOK[n] = t end
local TP = { hi = "#fff0a0", base = "#dcbc58", shade = "#a88040", deep = "#76502e" }
local function GR(a, b, c2, d2) return rp(a, b, c2, d2) end
local GRASS = GR("#c8ec7a", "#7ac45c", "#4a9452", "#2a6048")
local FLW = { "#ff7aa8", "#ffe38a", "#fff4d0", "#ff9a5a" }

look("CB", { sky = sky6("#28b0d8", "#48c4e0", "#72d6e6", "#a0e6dc", "#cff2cc", "#fcf4bc"), sun = { 380, 30, 11, "#fff2a8", "#fffad0" },
  water = { 62, 88, { "#2aa8c8", "#3cbdd0", "#58d0d4", "#8ae2d6" } }, far = { { rp("#6ec8a0", "#58b090", "#3c9484", "#2c7078"), 62, 5, 1 } },
  g = GR("#fff0d8", "#f8d8b0", "#e0aa8c", "#b27870"), gy = 88, rip = true, flw = { "#ff7aa8", "#ffe38a" },
  props = { { "palm", 50, 104, { h = 62, lean = 14 } }, { "boat", 170, 80, {} }, { "house", 280, 104, { w = 40, h = 26, wall = C.PINK, roof = C.TEAL, win = { -12, 12 }, rh = 14, doorx = 0 } },
    { "heron", 360, 104, { body = rp("#ffd0dc", "#fa8ca8", "#d85888", "#98386a"), beak = C.ORANGE.shade, leg = "#d85888" } }, { "palm", 430, 104, { h = 52, lean = -12 } } } })
look("CSA", { sky = sky6("#4f9ad8", "#6eb4e6", "#92cdf0", "#b8e2f0", "#d8eed8", "#f0f4cc"), sun = { 60, 30, 9, "#fff2a8", "#fffad0" },
  g = GR("#d8e88a", "#9cc860", "#68a050", "#3e7048"), gy = 82,
  mounts = {}, props = { { "mount", 120, 92, { w = 150, h = 72, sn = .3, R = rp("#c0b4d0", "#8c86ac", "#625e88", "#3e3a62"), noshadow = true } }, { "mount", 340, 92, { w = 180, h = 62, sn = .26, pk = .6, R = rp("#bcc4a8", "#86a088", "#5c7c70", "#3a5656"), noshadow = true } },
    { "steps", 250, 105, { n = 4, w = 70, th = 10, grass = true, R = C.STONE } }, { "animal", 100, 104, { R = rp("#fff0dc", "#e8d0b0", "#bc9c84", "#806a68"), rx = 9, ry = 5, leg = 12, nx = 3, ny = 14, nw = 3, hrx = 3, hry = 2, snout = 2, ear = true, tail = 3 } },
    { "animal", 150, 106, { R = rp("#d8c0a0", "#b49474", "#846c58", "#584640"), rx = 8, ry = 5, leg = 11, nx = 3, ny = 13, dir = -1, nw = 3, ear = true, snout = 2 } },
    { "house", 410, 104, { w = 32, h = 22, wall = C.STONE, roof = C.THATCH, thatch = true, rh = 16, win = { 9 }, doorx = 4 } } } })
look("EA", { sky = sky6("#f08aa8", "#f4a0b4", "#f8b8bc", "#fccac4", "#ffdccc", "#ffeed4"), sun = { 300, 40, 12, "#ffe0b0", "#fff0cc" },
  g = GR("#e8f4a8", "#a8d878", "#6cb060", "#3e8050"), gy = 84, flw = { "#ffd2e0", "#ffe38a" },
  props = { { "mount", 330, 92, { w = 200, h = 66, sn = .34, pk = .5, R = rp("#c8c0e0", "#9c94c4", "#726aa0", "#4c4478"), noshadow = true } },
    { "tree", 40, 104, { h = 64, R = C.PINK, TR = C.BARK, seed = 5 } }, { "pagoda", 140, 104, { n = 4, w = 46 } }, { "torii", 232, 104, { w = 46, h = 46 } },
    { "tree", 420, 104, { h = 52, R = C.PINK, seed = 9 } }, { "tree", 462, 106, { h = 34, rw = 14, rh = 10, R = C.PINK, seed = 11, tw = 1 } } } })
look("EE", { sky = sky6("#8e8cb8", "#a09cc4", "#b8b0cc", "#ccc0cc", "#e0d0c8", "#f0e0cc"), cl = C.COOL, sun = nil,
  g = GR("#e4ecc0", "#b8d094", "#88a874", "#587a62"), gy = 84, far = { { rp("#9c98bc", "#8a86ac", "#746e98", "#5a5680"), 74, 5, 3 } },
  props = { { "tree", 40, 104, { h = 66, R = C.YEL, TR = C.BIRCH, marks = true, seed = 21 } }, { "tree", 80, 106, { h = 54, R = C.YEL, TR = C.BIRCH, marks = true, seed = 22 } },
    { "dome", 195, 106, { r = 12, bh = 18, onion = true, wall = C.WHITE, dom = C.TEAL } }, { "dome", 238, 106, { r = 20, bh = 28, onion = true, wall = C.WHITE, dom = C.BLUE, windows = true, door = true } }, { "dome", 285, 106, { r = 12, bh = 18, onion = true, wall = C.WHITE, dom = C.RED } },
    { "tree", 370, 104, { h = 64, R = C.YEL, TR = C.BIRCH, marks = true, seed = 23 } }, { "tree", 430, 106, { h = 52, R = C.GREEN, TR = C.BIRCH, marks = true, seed = 24 } } } })
look("ESA", { sky = sky6("#f2754e", "#f58c52", "#f8a65a", "#fabf66", "#fcd878", "#fde8a0"), sun = { 330, 62, 22, "#fff0b4", "#fff8d4" },
  g = GR("#f6dc84", "#d8aa58", "#a8783e", "#704a38"), gy = 80, far = { { rp("#e8985c", "#d27e58", "#b06050", "#884450"), 70, 4, 6 } },
  props = { { "mount", 120, 88, { w = 120, h = 40, sn = .3, pk = .5, R = rp("#e6a47a", "#c8805e", "#a0604c", "#744048"), noshadow = true } },
    { "acacia", 56, 104, { h = 56, rw = 30, R = rp("#a8c85c", "#6c9c48", "#4a7442", "#2e4c38") } }, { "animal", 170, 106, { R = C.ORANGE, rx = 8, ry = 4, leg = 16, lw = 2, nx = 6, ny = 28, nw = 3, hrx = 3, hry = 2, snout = 2, spots = true, ear = true, tail = 5 } },
    { "baobab", 262, 104, { h = 62, bw = 14, R = rp("#a8c85c", "#6c9c48", "#4a7442", "#2e4c38") } }, { "acacia", 372, 106, { h = 46, rw = 26, lean = -4, R = rp("#a8c85c", "#6c9c48", "#4a7442", "#2e4c38") } },
    { "animal", 440, 106, { R = C.ORANGE, rx = 7, ry = 4, leg = 13, lw = 2, nx = -5, ny = 24, nw = 3, dir = -1, hrx = 3, hry = 2, snout = 2, spots = true, ear = true, tail = 4 } } } })
look("MENA", { sky = sky6("#4a3a7a", "#6a4a90", "#9a5a9c", "#cc6e9c", "#f0889c", "#fcb08c"), stars = true, cl = rp("#ffd0d0", "#f0a0b8", "#c07098", "#8c5088"), ncl = 2,
  moon = { 400, 28, 9 }, g = GR("#f8d8b0", "#dca884", "#a87470", "#704c68"), gy = 84, far = { { rp("#9a6a9c", "#84588c", "#6a4a7c", "#52386a"), 74, 6, 8 } },
  props = { { "palm", 50, 104, { h = 56, lean = 8, R = C.DKGRN } }, { "minaret", 170, 106, { h = 66, wall = C.CREAM, cap = C.TEAL } }, { "dome", 235, 106, { r = 28, bh = 20, wall = C.CREAM, dom = C.TEAL, door = true, windows = true } },
    { "minaret", 300, 106, { h = 54, wall = C.CREAM, cap = C.TEAL } }, { "palm", 380, 106, { h = 62, lean = -10, R = C.DKGRN } }, { "house", 440, 106, { w = 32, h = 22, wall = C.CREAM, roofstyle = "flat", roof = C.CREAM, win = { 8 } } } } })
look("NA", { sky = sky6("#3a8ee0", "#58a6e8", "#7cbcf0", "#a2d2f4", "#c4e4f4", "#e4f2e8"), sun = nil,
  g = GR("#d4f090", "#8cc860", "#58a050", "#34704a"), gy = 82, far = { { rp("#6aa078", "#4c8868", "#3a6c5c", "#2c4c4c"), 70, 6, 2 } },
  props = { { "mount", 150, 90, { w = 150, h = 74, sn = .38, pk = .45, R = C.ROCK, noshadow = true } }, { "mount", 380, 90, { w = 120, h = 56, sn = .3, pk = .55, R = rp("#bfc4d0", "#9498b4", "#6c7098", "#484a72"), noshadow = true } },
    { "pine", 30, 106, { h = 62, n = 4 } }, { "pine", 78, 106, { h = 48, n = 3 } }, { "totem", 230, 106, { n = 5 } },
    { "animal", 310, 106, { R = rp("#c89c78", "#946c52", "#684a44", "#3e2c34"), rx = 12, ry = 7, leg = 8, lw = 3, nx = 7, ny = -2, nw = 5, hrx = 5, hry = 4, humps = { 6 }, horns = true, tail = 3 } },
    { "pine", 410, 106, { h = 66, n = 4 } }, { "pine", 452, 106, { h = 50, n = 3 } } } })
look("NWE", { sky = sky6("#7c98b4", "#92aac4", "#a8bcd0", "#bccddc", "#d0dce4", "#e4eae8"), cl = C.COOL,
  g = GR("#c8ec86", "#80c45e", "#4c9852", "#2c6648"), gy = 82, far = { { rp("#8aa8b4", "#7898a8", "#607e94", "#486480"), 72, 4, 5 } },
  props = { { "windmill", 80, 104, { h = 58, wall = C.CREAM, roof = C.TERRA, rot = 25 } }, { "tower", 200, 106, { w = 32, h = 54, wall = C.STONE, roof = C.BLUE } }, { "tree", 270, 106, { h = 54, seed = 31 } },
    { "house", 350, 106, { w = 50, h = 28, wall = rp("#f6e8d0", "#e0c8a8", "#b89888", "#806870"), roof = rp("#e8a090", "#c06a58", "#904650", "#5c2c44"), beam = true, win = { -14, 14 }, chim = true, rh = 20, doorx = 0 } },
    { "tree", 430, 106, { h = 44, seed = 32 } }, { "tree", 466, 106, { h = 30, rw = 12, rh = 9, seed = 33, tw = 1 } } } })
look("OC", { sky = sky6("#28b0e0", "#48c4e4", "#74d6e6", "#a2e4de", "#d4f0c8", "#fcf4b0"), sun = { 70, 30, 12, "#fff2a8", "#fffad0" },
  g = GR("#ffd8a0", "#f0a468", "#c8744c", "#8c4a44"), gy = 84, far = { { rp("#e89c7c", "#d0846c", "#b0685c", "#884a50"), 74, 3, 7 } },
  props = { { "monolith", 232, 104, {} }, { "tree", 52, 104, { h = 70, R = rp("#bcd89c", "#88b080", "#608868", "#3e6050"), TR = C.BIRCH, seed = 41, marks = true } },
    { "tree", 430, 106, { h = 58, R = rp("#bcd89c", "#88b080", "#608868", "#3e6050"), TR = C.BIRCH, seed = 42, marks = true } },
    { "animal", 360, 106, { R = rp("#e8b080", "#c88458", "#9c5c48", "#6c3c40"), rx = 6, ry = 7, leg = 6, lw = 3, nx = 3, ny = 10, nw = 4, hrx = 3, hry = 2, snout = 3, ear = true, tail = 9 } },
    { "rock", 470, 108, { rx = 10, ry = 5, R = C.REDROCK } } } })
look("SA", { sky = sky6("#f0a040", "#f4b44c", "#f8c85a", "#fada74", "#fce896", "#fef4b8"), sun = { 400, 44, 14, "#fff4b0", "#fffad0" },
  g = GR("#e8e48a", "#b8c460", "#7c9c4c", "#4c6c44"), gy = 84, far = { { rp("#e8b46c", "#d89c64", "#b87c58", "#905c4c"), 74, 4, 2 } },
  props = { { "animal", 44, 106, { R = rp("#c8c0cc", "#a09cb4", "#7a7898", "#545070"), rx = 14, ry = 9, leg = 12, lw = 4, nx = 10, ny = -2, nw = 7, hrx = 7, hry = 6, trunk = true, tusk = true, ear = true, tail = 3 } },
    { "palace", 236, 106, {} }, { "tree", 436, 106, { h = 64, rw = 36, rh = 17, R = C.DKGRN, tw = 3, seed = 51 } },
    { "lily", 470, 109, { flower = true } } } })
look("SE", { sky = sky6("#2e8fe0", "#4ea6e8", "#74bcee", "#9ed0f0", "#c6e2f0", "#eaf0e4"), sun = { 420, 30, 11, "#fff2a8", "#fffad0" },
  g = GR("#f4dca0", "#dcb070", "#ac8052", "#745440"), gy = 84, far = { { rp("#9cb8a8", "#80a094", "#688880", "#4e6870"), 74, 5, 4 } },
  props = { { "cypress", 40, 106, { h = 62 } }, { "columns", 130, 106, { n = 4, sp = 16, h = 38 } }, { "cypress", 214, 106, { h = 52 } },
    { "dome", 300, 106, { r = 18, bh = 24, wall = C.WHITE, dom = C.BLUE, door = true, windows = true } }, { "house", 372, 106, { w = 30, h = 24, wall = C.WHITE, roof = C.TERRA, rh = 12, win = { 8 } } },
    { "tree", 430, 106, { h = 40, rw = 22, rh = 13, R = rp("#bcd09c", "#88a878", "#668060", "#445c4c"), tw = 3, seed = 61 } }, { "cypress", 466, 106, { h = 48 } } } })
look("SEA", { sky = sky6("#3ab8a0", "#58c8a4", "#84d8a4", "#b0e4a0", "#d8eca0", "#f8f0a0"), sun = { 90, 38, 10, "#fff2a8", "#fffad0" },
  g = GR("#c8f088", "#7cc860", "#48a050", "#2a6a48"), gy = 84, far = { { rp("#4ca878", "#3c9070", "#2c7468", "#245456"), 70, 7, 9 } },
  props = { { "palm", 30, 106, { h = 60, lean = 10 } }, { "house", 100, 104, { w = 34, h = 20, stilt = 12, wall = C.WOOD, roof = C.THATCH, thatch = true, rh = 18, win = { 8 }, doorx = -4 } },
    { "steps", 240, 106, { n = 4, w = 70, th = 11, spire = 34, R = rp("#e8d8b0", "#c4b088", "#948868", "#645c52"), door = true } }, { "house", 370, 104, { w = 34, h = 20, stilt = 12, wall = C.WOOD, roof = C.THATCH, thatch = true, rh = 18, win = { -8 } } },
    { "palm", 440, 106, { h = 54, lean = -12 } } } })
look("WCA", { sky = sky6("#58a8d8", "#78bce0", "#9ed0dc", "#c4e0c8", "#e4ecb0", "#f8f0a0"), sun = { 400, 34, 10, "#fff2a8", "#fffad0" },
  g = GR("#f0b080", "#d08058", "#a45c48", "#6c3c40"), gy = 84, far = { { rp("#5ca868", "#4a9060", "#3a7458", "#2c5450"), 72, 6, 11 } },
  props = { { "tree", 50, 106, { h = 76, rw = 40, rh = 22, R = C.DKGRN, tw = 5, seed = 71 } }, { "house", 150, 106, { w = 34, h = 22, round = true, wall = rp("#e8a878", "#c07850", "#904c46", "#5e3040"), roof = C.THATCH, thatch = true, rh = 20, win = {}, doorx = 0 } },
    { "palm", 230, 106, { h = 66, lean = -8, len = 28 } }, { "parrot", 232, 36, { body = C.GREY, wing = C.GREY, branch = false } }, { "house", 320, 106, { w = 36, h = 24, round = true, wall = rp("#e8a878", "#c07850", "#904c46", "#5e3040"), roof = C.THATCH, thatch = true, rh = 22, win = {}, doorx = 0 } },
    { "palm", 410, 106, { h = 50, lean = 12 } }, { "leafplant", 455, 106, { len = 22 } } } })

-- landscapes
look("coast", { sky = sky6("#4aa0e0", "#66b4e8", "#88c8ee", "#aedcf0", "#d2ecf0", "#f4f4dc"), sun = { 70, 30, 10, "#fff2a8", "#fffad0" },
  water = { 62, 90, { "#2a90c0", "#3aa8cc", "#52bcd4", "#7cd4dc" } }, g = GR("#fff0c0", "#f4d48c", "#d0a468", "#946c52"), gy = 90, rip = true,
  props = { { "boat", 120, 80, {} }, { "rock", 330, 91, { rx = 52, ry = 22, R = C.ROCK, streak = true } }, { "lighthouse", 330, 74, { h = 54 } }, { "boat", 230, 76, { s = .6, sail = C.CLOUD, hull = C.BLUE } },
    { "bird", 190, 30, {} }, { "bird", 210, 38, {} }, { "rock", 60, 106, { rx = 14, ry = 8, R = C.ROCK } }, { "rock", 430, 106, { rx = 18, ry = 9, R = C.ROCK } } } })
look("desert", { sky = sky6("#58b4e0", "#80c8e4", "#a8dcdc", "#cce8c4", "#f4eab0", "#fdd890"), sun = { 400, 32, 14, "#fff8c0", "#fffbe0" },
  g = GR("#fff0b8", "#f4cc72", "#d49a54", "#9c6244"), gy = 80, rip = true, far = { { rp("#f0c47c", "#dca46c", "#bc8060", "#8c5c54"), 70, 6, 12 } },
  props = { { "arch", 92, 100, { w = 92, h = 60 } }, { "cactus", 190, 104, { h = 60, w = 6 } }, { "mesa2", 308, 98, { w = 108, h = 72 } }, { "animal", 410, 106, { R = rp("#f4d4a0", "#d8a870", "#a87c54", "#70503e"), rx = 11, ry = 6, leg = 14, lw = 3, nx = 7, ny = 14, nw = 3, hrx = 3, hry = 2, snout = 2, humps = { -4, 4 }, tail = 4 } },
    { "mesa2", 454, 100, { w = 44, h = 38, tiers = { { .9, .34, rp("#d89070", "#b05a44", "#7c3a42", "#4e2a3c") }, { .64, .34, rp("#ffc48a", "#e88a4c", "#b45a44", "#783c48") }, { .74, .32, rp("#e89a72", "#c25a40", "#8a3a40", "#52283a") } } } },
    { "rock", 30, 107, { rx = 12, ry = 6, R = C.SANDST } } } })
look("forest", { sky = sky6("#7cc8a0", "#98d4a0", "#b4e0a0", "#d0ecA0", "#e4f2b0", "#f4f6c0"), sun = nil, g = GR("#a8d870", "#68a850", "#3e7c48", "#24503e"), gy = 84, far = { { rp("#4c9c64", "#3c845c", "#2c6a50", "#224c44"), 68, 8, 14 } }, flw = { "#ff7aa8", "#ffe38a", "#fff4d0" },
  props = { { "tree", 56, 106, { h = 76, R = C.GREEN, seed = 81, tw = 3 } }, { "pine", 150, 106, { h = 80, n = 4 } }, { "mushroom", 200, 106, { r = 12 } }, { "pine", 250, 106, { h = 70, n = 4 } },
    { "tree", 330, 106, { h = 70, R = C.YEL, seed = 82, tw = 3 } }, { "mushroom", 395, 107, { r = 9, R = C.ORANGE } }, { "pine", 430, 106, { h = 84, n = 4 } } } })
look("grassland", { sky = sky6("#4aa8e8", "#6cbcec", "#92d0f0", "#b8e2f0", "#d8f0e0", "#f2f6cc"), sun = { 380, 30, 11, "#fff4a8", "#fffad0" }, g = GR("#d8f090", "#98d062", "#62a850", "#3c7448"), gy = 82, far = { { rp("#a0d880", "#88c474", "#6aa868", "#4a8460"), 70, 6, 15 } }, flw = FLW, manyflw = true,
  props = { { "tree", 110, 104, { h = 52, seed = 91 } }, { "hay", 190, 106, { r = 11 } }, { "hay", 216, 108, { r = 9 } }, { "tree", 300, 106, { h = 78, rw = 38, rh = 24, tw = 4, seed = 92 } }, { "fence", 360, 106, { n = 6 } },
    { "hay", 60, 106, { r = 10 } }, { "bird", 250, 34, {} }, { "bird", 270, 40, {} } } })
look("island", { sky = sky6("#34b4dc", "#58c8e4", "#80dae4", "#aeeadc", "#d6f4cc", "#fcf6bc"), sun = { 90, 30, 12, "#fff2a8", "#fffad0" },
  water = { 60, 111, { "#2aa8c8", "#3cbdd0", "#58d0d4", "#8ae2d6" } }, islandm = { 240, 92, 120, 16 },
  props = { { "palm", 205, 90, { h = 64, lean = -12 } }, { "palm", 270, 90, { h = 54, lean = 14 } }, { "house", 238, 90, { w = 24, h = 16, wall = C.WOOD, roof = C.THATCH, thatch = true, rh = 14, win = { 5 } } },
    { "boat", 400, 78, { s = .8 } }, { "boat", 70, 100, { s = .7, hull = C.BLUE, sail = C.CLOUD } }, { "bird", 330, 34, {} } } })
look("mountain", { sky = sky6("#5a78c8", "#7a90d4", "#9ea8dc", "#c2bee0", "#e4d0dc", "#f8e2d0"), sun = { 400, 34, 10, "#fff2d0", "#fffae8" },
  g = GR("#c8e49c", "#8cc068", "#5c9454", "#386448"), gy = 88, far = { { rp("#8c88b8", "#7a76a8", "#625e90", "#484474"), 68, 6, 16 } },
  props = { { "mount", 110, 94, { w = 190, h = 82, sn = .42, pk = .45, R = C.ROCK, noshadow = true } }, { "mount", 300, 94, { w = 200, h = 70, sn = .4, pk = .6, R = rp("#c8c0d8", "#9c98bc", "#706c98", "#4a4676"), noshadow = true } },
    { "mount", 450, 96, { w = 120, h = 48, sn = .3, pk = .4, R = C.ROCK, noshadow = true } }, { "pine", 40, 106, { h = 54, n = 3 } }, { "pine", 84, 106, { h = 40, n = 3 } }, { "pine", 390, 106, { h = 50, n = 3 } },
    { "animal", 250, 106, { R = C.WHITE, rx = 6, ry = 4, leg = 7, lw = 2, nx = 3, ny = 6, nw = 3, hrx = 3, hry = 2, horns = true, tail = 2 } }, { "rock", 330, 107, { rx = 14, ry = 7, R = C.ROCK } } } })
look("rainforest", { sky = sky6("#2e8a58", "#3c9c5c", "#52b064", "#74c470", "#a0d884", "#c8e898"), sun = nil, g = GR("#a8d870", "#58a850", "#38784a", "#1e4a3e"), gy = 90, far = { { rp("#2a7a52", "#206a4c", "#185a46", "#124036"), 66, 10, 17 } }, flw = { "#ff7aa8", "#ff9a5a" },
  props = { { "tree", 90, 106, { h = 96, rw = 44, rh = 26, R = rp("#a0e070", "#4ca850", "#2c7c4c", "#16503e"), tw = 5, seed = 101 } }, { "parrot", 112, 62, { branch = true } },
    { "tree", 390, 106, { h = 92, rw = 48, rh = 26, R = rp("#a0e070", "#4ca850", "#2c7c4c", "#16503e"), tw = 5, seed = 102 } }, { "leafplant", 230, 106, { len = 28 } }, { "leafplant", 300, 108, { len = 22 } }, { "mushroom", 170, 108, { r = 8, R = C.ORANGE } },
    { "leafplant", 460, 108, { len = 24 } } } })
look("tundra", { sky = sky6("#5a88c8", "#78a0d4", "#9cb8dc", "#c0d0e4", "#dce4ec", "#f0f2f2"), aurora = { "#7af0b8", "#4ccaa0", "#a88cf0" }, stars = true, g = GR("#fafcff", "#dceaf6", "#b0c8e4", "#7c98c0"), gy = 84, far = { { rp("#b4c4e0", "#a0b0d4", "#8898c4", "#6c7cae"), 72, 5, 18 } },
  props = { { "pine", 60, 106, { h = 62, n = 4, snow = true } }, { "pine", 112, 106, { h = 46, n = 3, snow = true } }, { "igloo", 250, 106, { r = 32 } }, { "animal", 340, 106, { R = C.SNOW, rx = 13, ry = 7, leg = 6, lw = 4, nx = 8, ny = 0, nw = 6, hrx = 5, hry = 4, snout = 3, ear = true, tail = 2 } },
    { "pine", 420, 106, { h = 66, n = 4, snow = true } }, { "rock", 470, 108, { rx = 12, ry = 6, R = C.SNOW } } } })
look("wetland", { sky = sky6("#9cc8c0", "#b4d8b8", "#cce4b0", "#e0eca8", "#f2f0b0", "#fcf4c0"), sun = { 70, 38, 12, "#fff6b8", "#fffbd8" }, water = { 84, 111, { "#4aa8a0", "#58b8a8", "#74ccb0", "#9ce0bc" } },
  g = GR("#c8e480", "#88c060", "#5a9450", "#386448"), gy = 76, bank = 84, far = { { rp("#7cb090", "#6a9c84", "#547e76", "#3e6068"), 70, 5, 19 } },
  props = { { "tree", 70, 94, { h = 68, rw = 34, rh = 22, R = C.DKGRN, tw = 3, seed = 111 } }, { "reeds", 140, 104, { n = 5 } }, { "heron", 215, 104, {} }, { "lily", 270, 106, { flower = true } }, { "lily", 300, 109, {} },
    { "reeds", 350, 104, { n = 6, h = 34 } }, { "tree", 430, 94, { h = 56, rw = 28, rh = 18, R = C.DKGRN, tw = 3, seed = 112 } }, { "lily", 170, 109, {} } } })

-- places
look("delve", { sky = sky6("#241c34", "#2c2240", "#362a4c", "#443458", "#563e66", "#6a4a72"), cave = true, g = GR("#9c8cb0", "#6e6088", "#4a3e66", "#2c2444"), gy = 86, flw = {},
  props = { { "crystals", 70, 106, {} }, { "cave", 230, 106, { rx = 64, ry = 56, mw = 18, mh = 26, timber = true, R = C.DARK } }, { "lantern", 288, 106, {} }, { "cart", 345, 106, {} },
    { "crystals", 430, 106, { R = C.MAG, list = { { -8, 18, 4 }, { 0, 30, 5 }, { 8, 22, 4 } } } }, { "rock", 130, 108, { rx = 12, ry = 6, R = C.DARK } } } })
look("haven", { sky = sky6("#f08a68", "#f4a070", "#f8b87c", "#fad08a", "#fce0a0", "#fef0c0"), sun = { 380, 60, 18, "#fff0b0", "#fff8d4" }, g = GR("#e0d4a8", "#bca880", "#8c7860", "#5c4c4c"), gy = 86, rip = false, flw = {},
  props = { { "tree", 50, 106, { h = 56, seed = 121 } }, { "lantern", 138, 106, {} }, { "house", 230, 106, { w = 78, h = 40, wall = rp("#f6e8d0", "#e0c8a8", "#b89888", "#806870"), roof = C.TERRA, rh = 26, win = { -22, 22 }, chim = true, sign = true, beam = true, doorx = 0 } },
    { "lantern", 324, 106, {} }, { "barrel", 360, 106, {} }, { "barrel", 376, 108, {} }, { "tree", 440, 106, { h = 62, seed = 122 } } } })
look("lair", { sky = sky6("#3a2048", "#5a2a58", "#8a3a62", "#b84e6a", "#e0705a", "#f09a58"), sun = { 90, 62, 16, "#ffc070", "#ffe0a0" }, g = GR("#a8847c", "#7e6064", "#5a4452", "#38283c"), gy = 86, far = { { rp("#6a3a5c", "#583050", "#442644", "#301c36"), 72, 8, 21 } }, flw = {},
  props = { { "deadtree", 50, 106, { h = 60 } }, { "egg", 130, 106, { r = 9 } }, { "egg", 152, 108, { r = 7, R = C.ORANGE } }, { "cave", 250, 106, { rx = 80, ry = 54, mw = 24, mh = 30, R = rp("#a08c88", "#76646c", "#544654", "#382a3e"), eyes = true } },
    { "bones", 370, 106, {} }, { "deadtree", 430, 106, { h = 50 } }, { "rock", 465, 108, { rx = 12, ry = 6, R = C.DARK } } } })
look("market", { sky = sky6("#7cc8e8", "#94d4ea", "#acdee8", "#c8ecE4", "#e0f4dc", "#f6f8d4"), sun = nil, bunting = true, g = GR("#f8e0a4", "#e0bc7c", "#b08c5c", "#74543e"), gy = 86, flw = {}, cobble = true,
  props = { { "stall", 100, 106, { w = 62, a1 = C.RED, a2 = C.WHITE, goods = { C.RED, C.GOLD, C.GREEN } } }, { "stall", 240, 106, { w = 62, a1 = C.GOLD, a2 = C.BLUE, goods = { C.ORANGE, C.GOLD, C.PINK } } },
    { "stall", 380, 106, { w = 62, a1 = C.GREEN, a2 = C.WHITE, goods = { C.TEAL, C.VIOLET, C.RED } } }, { "barrel", 450, 108, {} }, { "barrel", 30, 108, {} } } })
look("village", { sky = sky6("#58a8e4", "#78bcea", "#9cd0ee", "#bce0f0", "#d8f0e4", "#f2f6cc"), sun = { 410, 30, 11, "#fff4a8", "#fffad0" }, g = GR("#d4ee90", "#94cc64", "#60a050", "#3c7048"), gy = 84, far = { { rp("#9cc89c", "#88b490", "#6c9884", "#507868"), 74, 4, 23 } }, flw = FLW,
  props = { { "tree", 36, 106, { h = 50, seed = 131 } }, { "house", 100, 106, { w = 40, h = 26, wall = C.CREAM, roof = C.TERRA, rh = 18, win = { -10, 10 }, chim = true, doorx = 0 } }, { "well", 170, 106, {} },
    { "house", 240, 106, { w = 46, h = 30, wall = rp("#f6e8d0", "#e0c8a8", "#b89888", "#806870"), roof = C.BLUE, rh = 20, win = { -14, 14 }, doorx = 0 } }, { "house", 340, 106, { w = 36, h = 24, wall = C.CREAM, roof = C.THATCH, thatch = true, rh = 18, win = { 9 }, doorx = 3 } },
    { "fence", 395, 108, { n = 4 } }, { "tree", 458, 106, { h = 58, seed = 132 } } } })
look("wonder", { sky = sky6("#2a2860", "#3a3478", "#524088", "#7a4e98", "#a860a4", "#d888a8"), stars = true, aurora = { "#7af0d0", "#58c8e8", "#e8a0f0" }, g = GR("#7cc0a8", "#4c9890", "#34707c", "#224c60"), gy = 86, flw = { "#e8fcff", "#f4b0f0" },
  props = { { "crystals", 66, 106, {} }, { "stones", 240, 106, { lintel = true, rune = nil } }, { "crystals", 410, 106, { R = C.MAG, list = { { -8, 20, 4 }, { 0, 34, 6 }, { 8, 16, 4 } } } }, { "sparklefield", 240, 90, { n = 10, w = 200, h = 50 } } } })

--------------------------------------------------------------------------- builder
local function build(name)
  local t = LOOK[name]
  c = HP.canvas{ w = 480, h = 120, scale = 1, name = "banner-" .. name }
  local sd = 0; for i = 1, #name do sd = sd + name:byte(i) * i end
  -- sky
  for y = 0, 90 do for x = 0, 479 do
    local tt = y / 90 + (GX.vn(x, y, 14, 4 + sd) - .5) * .22
    c:px(x, y, t.sky[max(1, min(6, floor(tt * 6) + 1))])
  end end
  if t.aurora then
    for x = 0, 479 do
      local yc = 34 + 10 * sin(x / 52 + sd) + 5 * sin(x / 17)
      local th = 6 + 4 * sin(x / 23 + 1)
      for y = floor(yc - th), floor(yc + th) do
        local k = (y - (yc - th)) / (2 * th)
        c:px(x, y, k < .45 and t.aurora[1] or (k < .8 and t.aurora[2] or t.aurora[3]))
      end
    end
  end
  if t.stars then
    for i = 1, 40 do
      local x, y = floor(H(i, sd, 1) * 478) + 1, floor(H(i, sd, 2) * 54) + 8
      c:px(x, y, "#fff4c8"); if i % 6 == 0 then c:px(x - 1, y, "#fff4c8"); c:px(x + 1, y, "#fff4c8"); c:px(x, y - 1, "#fff4c8"); c:px(x, y + 1, "#fff4c8") end
    end
  end
  if t.sun then
    local s = mk(); E(s, t.sun[1], t.sun[2], t.sun[3] + 8, floor(t.sun[3] * .7) + 4); c:fillMask(GX.rough(s, 3, 1), GX.mix(t.sky[3], t.sun[4], .5))
    local s1 = mk(); E(s1, t.sun[1], t.sun[2], t.sun[3]); c:fillMask(GX.rough(s1, 3, 1), t.sun[4])
    local s2 = mk(); E(s2, t.sun[1], t.sun[2], floor(t.sun[3] * .6)); c:fillMask(GX.rough(s2, 4, 1), t.sun[5])
  end
  if t.moon then
    local m = mk(); E(m, t.moon[1], t.moon[2], t.moon[3]); m:cut(E(mk(), t.moon[1] + 4, t.moon[2] - 2, t.moon[3] - 1))
    GX.lit(c, m, GX.ramp6(C.GOLD), { ink = false, R = 4, amb = .5 })
  end
  if not t.cave then
    local clr = t.cl or C.CLOUD
    for i = 1, t.ncl or 4 do
      local cx, cy = floor(30 + H(i, sd, 7) * 420), 18 + floor(H(i, sd, 8) * 26)
      local rx, ry = 20 + floor(H(i, sd, 9) * 14), 4 + floor(H(i, sd, 10) * 3)
      local m = mk(); E(m, cx, cy, rx, ry); E(m, cx - rx // 2, cy - 3, rx // 2, ry); E(m, cx + rx // 3, cy - 4, rx // 2, ry - 1)
      GX.lit(c, GX.rough(m, 10 + i, 2), GX.ramp6(clr), { ink = false, R = 5, tex = .35, sc = 3, seed = 10 + i, amb = .35 })
    end
  else
    -- cave ceiling stalactites
    for x = 0, 479 do
      local hgt = 8 + floor(GX.vn(x, 0, 9, 5) * 22) * ((x % 17 < 6) and 1 or 0) + floor(GX.vn(x, 0, 4, 6) * 6)
      for y = 5, hgt do c:px(x, y, (y > hgt - 2) and "#463a5a" or "#32284a") end
    end
  end
  -- far layers
  for fi, f in ipairs(t.far or {}) do
    local m = mk()
    for x = 0, 479 do
      local top = f[2] + floor(f[3] * sin(x / 31 + f[4]) + f[3] * .5 * sin(x / 11 + f[4] * 2) + (GX.vn(x, 0, 7, f[4]) - .5) * f[3])
      for y = top, 90 do m:set(x, y) end
    end
    GX.lit(c, m, GX.ramp6(f[1]), { ink = false, R = 14, tex = .3, sc = 6, seed = f[4], amb = .5 })
  end
  -- water
  if t.water then
    local w = t.water
    for y = w[1], w[2] do
      local k = (y - w[1]) / max(1, w[2] - w[1])
      for x = 0, 479 do
        local col = w[3][max(1, min(4, floor(k * 4 + (GX.vn(x, y, 12, 3) - .5) * .7) + 1))]
        c:px(x, y, col)
      end
    end
    for i = 1, 60 do
      local x, y = floor(H(i, sd, 21) * 470), w[1] + 3 + floor(H(i, sd, 22) * (w[2] - w[1] - 4))
      if not (t.islandm and false) then for k = 0, 4 + i % 4 do c:px(x + k, y, "#d8f8f4") end end
    end
  end
  -- ground
  if t.g then
    local g6 = GX.ramp6(t.g)
    GCOL = GX.mix(t.g.shade, t.g.deep, .45)
    local function gyf(x) return t.gy + floor(2 * sin(x / 40 + 2) + sin(x / 13)) end
    local gtop, ymax = t.bank or t.gy, 111
    for x = 0, 479 do
      local y0 = gyf(x)
      local ye = t.bank and (t.water[1] + 2) or 111
      if t.water and not t.bank then ye = 111 end
      for y = y0, 111 do
        local tt = (y - y0) / 34
        local v = .86 - .3 * tt + (GX.vn(x, y, 7, 5 + sd) - .5) * .4 + (GX.vn(x, y, 2.2, 8) - .5) * .06
        if t.rip then
          local wv = y + floor(GX.vn(x, y, 12, 9) * 5) + floor(3 * sin(x / 19))
          if wv % 6 == 0 and GX.vn(x, y, 6, 12) > .45 then v = v - .2 elseif wv % 6 == 1 and GX.vn(x, y, 6, 13) > .55 then v = v + .15 end
        end
        if t.cobble and ((x + (y // 5 % 2) * 4) % 9 == 0 or y % 5 == 0) and y > y0 + 2 then v = v - .18 end
        c:px(x, y, g6[GX.idx(v)])
      end
    end
    if t.bank then -- wetland: water below the bank (redraw over ground)
      local w = t.water
      for y = w[1], w[2] do
        local k = (y - w[1]) / max(1, w[2] - w[1])
        for x = 0, 479 do
          local ey = gyf(x) + 8
          if y > ey or y > w[1] + 3 then c:px(x, y, w[3][max(1, min(4, floor(k * 4 + (GX.vn(x, y, 12, 3) - .5) * .7) + 1))]) end
        end
      end
      for i = 1, 50 do local x, y = floor(H(i, sd, 21) * 470), w[1] + 5 + floor(H(i, sd, 22) * (w[2] - w[1] - 6)); for k = 0, 4 do c:px(x + k, y, "#d8f8f4") end end
      GCOL = nil
    end
  end
  if t.islandm then
    local im = t.islandm
    local m = mk()
    for x = im[1] - im[3] // 2, im[1] + im[3] // 2 do
      local tt = (x - im[1]) / (im[3] / 2)
      local top = floor(im[2] - im[4] * sqrt(max(0, 1 - tt * tt)))
      for y = top, im[2] + 4 do m:set(x, y) end
    end
    m = GX.rough(m, 5, 1)
    GX.lit(c, m, GX.ramp6(rp("#fff0c0", "#f4d48c", "#d0a468", "#946c52")), { R = 14, tex = .4, sc = 4, seed = 3, rimlight = true })
    GCOL = "#c89868"
  end
  -- bunting (market)
  if t.bunting then
    local cols = { "#e0504a", "#f5cf6a", "#3cb8b0", "#f49ac0", "#6cc05a", "#4c90d0" }
    for x = 4, 476, 11 do
      local y = 16 + floor(5 * sin(x / 40)) + floor(abs(((x - 4) % 88) - 44) / -8) + 5
      local col = cols[((x - 4) // 11) % #cols + 1]
      c:fillMask(c:poly{ { x, y }, { x + 8, y }, { x + 4, y + 8 } }, col); c:px(x + 4, y + 8, INK)
      for k = 0, 8 do c:px(x + k, y - 1, INK) end
    end
  end
  -- props
  for _, p in ipairs(t.props) do
    local f = P[p[1]]
    if p[1] == "mount" then
      -- far mounts are drawn without a ground shadow
    end
    f(p[2], p[3], p[4] or {})
  end
  -- scatter tufts / flowers
  if t.g and not t.cave then
    local tf = t.tuf or TP
    for i = 0, 26 do
      local x, y = 4 + floor(H(i, sd, 31) * 470), 96 + floor(H(i, sd, 32) * 14)
      if not (t.water and not t.bank and not t.islandm) then
        local tfr = (t.g.hi == "#fff0d8" or t.g.hi == "#fff0c0" or t.g.hi == "#fff0b8" or t.g.hi == "#fafcff") and { hi = t.g.hi, base = t.g.base, shade = t.g.shade, deep = t.g.deep } or { hi = t.g.hi, base = GX.mix(t.g.base, t.g.hi, .2), shade = t.g.shade, deep = t.g.deep }
        if not t.islandm and not t.bank then GX.tuft(c, x, y, tfr) end
      end
    end
    if t.flw then for i = 0, (t.manyflw and 40 or 14) do
      local x, y = 4 + floor(H(i, sd, 41) * 470), 94 + floor(H(i, sd, 42) * 14)
      if #t.flw > 0 and not t.islandm and not t.bank then GX.flower(c, x, y, t.flw[i % #t.flw + 1]) end
    end end
  end
  -- hems (stitched, as the pilot)
  for y = 0, 5 do for x = 0, 479 do c:px(x, y, HEM) end end
  for x = 0, 479 do if x % 6 < 4 then for y = 2, 3 do c:px(x, y, GOLDC) end end end
  for x = 0, 479 do
    local f = 6 + floor(GX.vn(x, 0, 5, 77) * 3)
    for y = 6, f + (x % 8 < 3 and 2 or 0) do c:px(x, y, "#4a2c1a") end
  end
  for y = 112, 119 do for x = 0, 479 do c:px(x, y, "#c9a96e") end end
  for x = 0, 479 do c:px(x, 111, "#74462a"); if x % 6 < 4 then for y = 116, 117 do c:px(x, y, GOLDC) end end end
  c:save{ aseprite = d .. "/out/banner-" .. name .. ".aseprite", png = d .. "/out/banner-" .. name .. ".png", scale = 1 }
end

if NAME == "all" then
  for _, n in ipairs{ "OC", "SA", "desert", "forest", "grassland", "wetland", "village" } do build(n) end
else
  build(NAME)
end
