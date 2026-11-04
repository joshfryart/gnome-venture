-- dD11 helper (Sonnet first draft chunk: quince..raspberry). Thin layer over batch2/_b2.lua (shared files untouched).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local floor, max, min, abs, sin, cos, sqrt, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.pi
local D = { B = B, H = H, HP = HP, X = X, K = B.K, INK = "#2b1c26", CREAM = "#fff4d6" }
D.new, D.ell, D.ln, D.polyline, D.fin = B.new, B.ell, B.ln, B.polyline, B.fin
D.hash = X.hash

-- hex -> 6 tone ramp by the guide recipe
local function rgb2hsl(r, g, b)
  r, g, b = r / 255, g / 255, b / 255
  local mx, mn = max(r, g, b), min(r, g, b)
  local l, h, s = (mx + mn) / 2, 0, 0
  if mx ~= mn then
    local d = mx - mn
    s = l > .5 and d / (2 - mx - mn) or d / (mx + mn)
    if mx == r then h = (g - b) / d + (g < b and 6 or 0) elseif mx == g then h = (b - r) / d + 2 else h = (r - g) / d + 4 end
    h = h * 60
  end
  return h, s, l
end
local function hsl2hex(h, s, l)
  h = (h % 360) / 360
  local function f(p, q, t) if t < 0 then t = t + 1 end if t > 1 then t = t - 1 end
    if t < 1/6 then return p + (q - p) * 6 * t end if t < .5 then return q end
    if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end return p end
  local r, g, b
  if s == 0 then r, g, b = l, l, l else
    local q = l < .5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    r, g, b = f(p, q, h + 1/3), f(p, q, h), f(p, q, h - 1/3) end
  return string.format("#%02x%02x%02x", floor(r * 255 + .5), floor(g * 255 + .5), floor(b * 255 + .5))
end
local function toward(h, target, amt)
  local d = ((target - h + 540) % 360) - 180
  if abs(d) <= amt then return target end
  return h + (d > 0 and amt or -amt)
end
function D.ramp(hex)
  local h, s, l = rgb2hsl(tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16))
  local hi = hsl2hex(toward(h, 45, 10), s, l + (1 - l) * .3)
  local top = hsl2hex(toward(h, 45, 14), s, l + (1 - l) * .6)
  local sh = hsl2hex(toward(h, 270, 8), s * .8, l * .8)
  local dp = hsl2hex(toward(h, 270, 20), s * .6, l * .55)
  return { dp, sh, H.mix(sh, hex, .5), hex, hi, top }
end
local function R(r) if type(r) == "table" and #r == 6 then return r end if type(r) == "string" and r:sub(1, 1) == "#" then return D.ramp(r) end return H.ramp(r) end
D.R = R
function D.lit(c, m, ramp, Rr, o) return B.lit(c, m, R(ramp), Rr, o) end

-- lit sphere with a spec pixel
function D.sph(c, cx, cy, r, ramp, o)
  o = o or {}
  local m = o.m or c:ellipse(cx, cy, r, r)
  local n = X.sphere(cx - .4, cy - .4, r, m)
  local rp = R(ramp)
  local idx = X.tone(c, m, X.light(n, { amb = .06, wrap = .2 }), rp, { cuts = o.cuts or { .22, .4, .56, .72, .88 }, bias = o.bias })
  if not o.nospec then c:px(floor(cx - r * .42), floor(cy - r * .48), o.spec or rp[6]) end
  return m, n, idx
end
-- rod / cylinder with lighting
function D.rod(c, ax, ay, bx, by, w, ramp, o)
  local wf = type(w) == "function" and w or function() return w end
  return H.cyl(c, ax, ay, bx, by, wf, R(ramp), o)
end
-- leaf blade with veins (batch2 blade)
function D.blade(c, ax, ay, bx, by, w, ramp, o) return B.blade(c, ax, ay, bx, by, w, R(ramp), o) end
-- leaf scrap used for seed items
function D.scrap(c, ax, ay, bx, by, w, ramp, veins, o)
  o = o or {}
  o.veins = veins or { 5, 9, 13, 17, 21, 25 } o.slant = o.slant or 2.2
  return B.blade(c, ax, ay, bx, by, w, R(ramp), o)
end
-- stem + list of leaves {ax,ay,bx,by,w,ramp,veins,opts}
function D.sprout(c, pts, stemRamp, leaves)
  local rp = R(stemRamp)
  for i = 1, #pts - 1 do
    D.rod(c, pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2], 1.1, rp, { amb = .15, wrap = .3 })
  end
  for _, L in ipairs(leaves) do
    D.blade(c, L[1], L[2], L[3], L[4], L[5], L[6], L[8] or { veins = L[7] or { 3, 6 }, slant = 2 })
  end
end
-- flat seed with contact shadow, glint
function D.seed(c, cx, cy, rx, ry, ang, ramp, shadow, glint) return B.seed(c, cx, cy, rx, ry, ang, R(ramp), shadow or "#1f553f", glint) end
-- pixel strings: rows of chars with a map
function D.stamp(c, x, y, rows, map) c:paint(rows, x, y, map) end

-- ======================================================================= barrel
-- o: cx, yt (rim centre y), yb, wt, wb, bulge, ry (rim ellipse ry), wood ramp, hoops {y..}, hoop ramp, nst, water (ramp), lv (water drop)
function D.barrel(c, o)
  local cx, yt, yb = o.cx, o.yt, o.yb
  local wood = R(o.wood or "wood")
  local hoopR = R(o.hoop or "stone")
  local nst = o.nst or 7
  local function hw(y) local t = max(0, min(1, (y - yt) / (yb - yt)))
    return o.wt + (o.wb - o.wt) * t + o.bulge * sin(pi * t) end
  local body = HP.mask()
  for y = yt, yb do local w = hw(y)
    for x = floor(cx - w + .5), floor(cx + w - .5) do body:set(x, y) end end
  body:add(c:ellipse(cx - .5, yb, o.wb - .5, 3))
  local rim = c:ellipse(cx - .5, yt, o.wt + .5, o.ry)
  -- body paint
  local info = {}
  body:each(function(x, y)
    local w = hw(min(y, yb)) + .5
    local u = max(-.97, min(.97, (x + .5 - cx) / w))
    local nz = sqrt(1 - u * u)
    local v = max(0, min(1, .1 + .9 * max(0, (-.6 * u + .45 * nz + .3) / 1.0)))
    local i = 1
    for j, t in ipairs({ .26, .44, .6, .75, .88 }) do if v >= t then i = j + 1 end end
    local th = math.asin(u)
    local sf = (th + pi / 2) / (pi / nst)
    local k = floor(sf)
    local xb = abs((x + .5 - cx) - (sin(-pi / 2 + k * pi / nst) * w)) < .55 or abs((x + .5 - cx) - (sin(-pi / 2 + (k + 1) * pi / nst) * w)) < .55
    local sb = (o.stave and o.stave(k)) or ((X.hash(k, 3, 9) > .6) and 1 or (X.hash(k, 5, 4) < .25 and -1 or 0))
    i = max(1, min(6, i + sb))
    if xb then i = max(1, i - 2) end
    local wd = wood
    if o.staveRamp then o._rc = o._rc or {} local rr = o.staveRamp(k) if rr then o._rc[rr] = o._rc[rr] or R(rr) wd = o._rc[rr] end end
    -- grain: a few dark flecks
    if not xb and X.hash(x, floor(y / 3), 21) > .93 then i = max(1, i - 1) end
    c:put(x, y, wd[i], { r = { name = "wood" } })
    info[B.K(x, y)] = { u = u, v = v }
  end)
  -- hoops
  for _, hy in ipairs(o.hoops or {}) do
    for y = hy, hy + 1 do
      local w = hw(y) + .5
      for x = floor(cx - w - 1), floor(cx + w) do
        local u = max(-.97, min(.97, (x + .5 - cx) / (w + .6)))
        local nz = sqrt(1 - u * u)
        local v = max(0, min(1, .1 + .9 * max(0, (-.6 * u + .45 * nz + .3))))
        local i = 1
        for j, t in ipairs({ .26, .44, .6, .75, .88 }) do if v >= t then i = j + 1 end end
        if y == hy + 1 then i = max(1, i - 1) else i = min(6, i + 1) end
        c:put(x, y, hoopR[i], { r = { name = "hoop" } })
      end
    end
  end
  -- top rim (wood) + interior
  local rimTok = { r = { name = "rim" } }
  local ri = X.tone(c, rim, (function() local v = {} rim:each(function(x, y) v[B.K(x, y)] = (y < yt and .8 or .6) - ((x - cx) / 40) end) return v end)(), wood, { cuts = { .3, .45, .6, .72, .85 }, tok = rimTok })
  local inner = c:ellipse(cx - .5, yt, o.wt - 1.5, o.ry - 1.8)
  local water = inner:shift(0, o.lv or 2):clip(inner)
  local wall = inner:copy():cut(water)
  wall:each(function(x, y) c:put(x, y, (y < yt - 1) and wood[1] or wood[2], rimTok) end)
  local wr = R(o.water or "sea")
  water:each(function(x, y)
    local t = (y - (yt + (o.lv or 2) - (o.ry - 1.8))) / max(1, 2 * (o.ry - 1.8))
    c:put(x, y, wr[(x - cx) < -(o.wt - 4) / 2 and 4 or 3], { r = { name = "water" } })
  end)
  -- water shine + dark meniscus line against the wall
  water:edge():each(function(x, y) if y <= yt + (o.lv or 2) then c:put(x, y, wr[2], { r = { name = "water" } }) end end)
  c:px(floor(cx - 3), yt + (o.lv or 2), wr[6]) c:px(floor(cx - 2), yt + (o.lv or 2), wr[6]) c:px(floor(cx - 4), yt + (o.lv or 2) + 1, wr[5])
  return { body = body, rim = rim, inner = inner, water = water, hw = hw, wood = wood, hoopR = hoopR, wr = wr, cx = cx, yt = yt, yb = yb, o = o }
end
-- gutter pipe: vertical from (px, py0) to (px, ey), across to (ex, ey), short spout down to (ex, ey+sd)
function D.pipe(c, px, py0, ey, ex, sd, ramp)
  local rp = R(ramp or "stone")
  D.rod(c, px, py0, px, ey, 2, rp, { amb = .1 })
  D.rod(c, px, ey, ex, ey, 2, rp, { amb = .1 })
  D.rod(c, ex, ey, ex, ey + sd, 1.5, rp, { amb = .1 })
  D.sph(c, px, ey, 2.3, rp, { nospec = true })
  -- bracket
  c:fillMask(c:rect(px - 3, py0 + 2, px + 3, py0 + 2), rp[2])
end
function D.drop(c, x, y, ramp)
  local rp = R(ramp or "sea")
  c:px(x, y, rp[5]) c:px(x, y + 1, rp[4]) c:px(x - 1, y + 1, rp[4]) c:px(x + 1, y + 1, rp[3]) c:px(x, y + 2, rp[3])
end
return D
