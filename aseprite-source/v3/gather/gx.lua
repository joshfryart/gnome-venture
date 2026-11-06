-- gx.lua: organic pixel engine for gather scenes (v3). No smooth ovals: noisy silhouettes, per-pixel light (hpx pillow), 6-tone ramps,
-- value-noise texture, selective ink. Usage: local GX = dofile(dir.."/gx.lua")
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local X = dofile(d .. "/../lib/hpx.lua").init(HP)
local GX = { HP = HP, X = X, INK = "#2b1c26" }
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H = X.hash

local function hx(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
function GX.mix(a, b, t)
  local r1, g1, b1 = hx(a); local r2, g2, b2 = hx(b)
  return string.format("#%02x%02x%02x", floor(r1 + (r2 - r1) * t + .5), floor(g1 + (g2 - g1) * t + .5), floor(b1 + (b2 - b1) * t + .5))
end
function GX.ramp6(R) return { R.deep, GX.mix(R.deep, R.shade, .5), R.shade, R.base, GX.mix(R.base, R.hi, .5), R.hi } end
function GX.idx(v, cuts)
  cuts = cuts or { .17, .34, .5, .67, .84 }
  local i = 1
  for j, t in ipairs(cuts) do if v >= t then i = j + 1 end end
  return i
end
function GX.vn(x, y, sc, s)
  local gx, gy = x / sc, y / sc
  local x0, y0 = floor(gx), floor(gy)
  local fx, fy = gx - x0, gy - y0
  fx = fx * fx * (3 - 2 * fx); fy = fy * fy * (3 - 2 * fy)
  local a, b, c, e = H(x0, y0, s), H(x0 + 1, y0, s), H(x0, y0 + 1, s), H(x0 + 1, y0 + 1, s)
  return a + (b - a) * fx + (c - a) * fy + (a - b - c + e) * fx * fy
end
function GX.disc(m, cx, cy, r, ry)
  ry = ry or r
  for y = cy - ry, cy + ry do for x = cx - r, cx + r do
    if ((x - cx) / r) ^ 2 + ((y - cy) / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
function GX.rough(m, seed, amt)
  for pass = 1, amt or 1 do
    local g = m:grow(1)
    local n = HP.mask()
    g:each(function(x, y)
      local nz = GX.vn(x, y, 3, seed + pass)
      if m:has(x, y) then
        if not (m:has(x - 1, y) and m:has(x + 1, y) and m:has(x, y - 1) and m:has(x, y + 1)) and nz < .28 then else n:set(x, y) end
      elseif nz > .6 then n:set(x, y) end
    end)
    m = n
  end
  return m
end

-- lit: ink rim, pillow light, noise texture, 6-tone ramp. returns value map
function GX.lit(c, m, R6, o)
  o = o or {}
  if o.ink ~= false then c:rim(m, o.ink or GX.INK) end
  local n = X.pillow(m, o.R or 6, o.h or 1)
  local v = X.light(n, { amb = o.amb or .2, wrap = o.wrap or .3 })
  local sc, seed = o.sc or 5, o.seed or 1
  m:each(function(x, y)
    local k = X.K(x, y)
    local val = v[k] or .5
    local nn = GX.vn(x, y, sc, seed) * .6 + GX.vn(x, y, sc * 2.3, seed + 7) * .4
    val = val + (nn - .5) * (o.tex or .3)
    if o.fn then val = val + o.fn(x, y) end
    v[k] = max(0, min(1, val))
    local rp = type(R6) == "function" and R6(x, y) or R6
    c:px(x, y, rp[GX.idx(v[k], o.cuts)])
  end)
  if o.rimlight and type(R6) == "table" then
    m:each(function(x, y) if (not m:has(x - 1, y) or not m:has(x, y - 1)) and v[X.K(x, y)] > .45 then c:px(x, y, R6[6]) end end)
  end
  return v
end

-- banded background with wobbling boundaries; shaft(x,y)->true lifts the colour
function GX.bands(c, y0, y1, cols, seed, tex, shaft, lift)
  local cache = {}
  for y = y0, y1 do for x = 0, 479 do
    local t = (y - y0) / (y1 - y0) + (GX.vn(x, y, 20, seed) - .5) * tex
    local i = max(1, min(#cols, floor(t * #cols) + 1))
    local col = cols[i]
    if shaft and shaft(x, y) then cache[col] = cache[col] or GX.mix(col, lift or "#ffffff", .32); col = cache[col] end
    c:px(x, y, col)
  end end
end

function GX.ground(c, yfn, R, seed, o)
  o = o or {}
  local R6 = GX.ramp6(R)
  for x = 0, 479 do
    local y0 = yfn(x)
    for y = y0, 269 do
      local t = (y - y0) / max(1, 270 - y0)
      local v = (o.top or .82) - (o.fall or .5) * t + (GX.vn(x, y, o.sc or 7, seed) - .5) * (o.tex or .42) + (GX.vn(x, y, 2.2, seed + 3) - .5) * .05
      c:px(x, y, R6[GX.idx(v)])
    end
  end
end

function GX.foliage(c, cx, cy, rw, rh, R, seed, o)
  o = o or {}
  local m = HP.mask()
  local n = floor(rw * rh / 48) + 5
  for i = 1, n do
    local a = H(i, seed, 1) * 6.283
    local rr = sqrt(H(i, seed, 2))
    GX.disc(m, floor(cx + cos(a) * rw * rr * .92), floor(cy + sin(a) * rh * rr * .92), 5 + floor(H(i, seed, 3) * 7))
  end
  for i = 1, 5 do   -- hanging scallops under the belly
    local sx = cx - rw * .8 + H(i, seed, 8) * rw * 1.6
    GX.disc(m, floor(sx), floor(cy + rh * .8 + H(i, seed, 9) * 5), 4 + floor(H(i, seed, 4) * 3), 4)
  end
  m = GX.rough(m, seed, 1)
  for i = 1, 3 do   -- sky holes
    local hole = HP.mask()
    GX.disc(hole, floor(cx + (H(i, seed, 5) - .5) * rw * 1.2), floor(cy + H(i, seed, 6) * rh * .5), 1 + i % 2, 1)
    m:cut(hole)
  end
  GX.lit(c, m, GX.ramp6(R), { R = 9, tex = .7, sc = 3.2, seed = seed, amb = .28, rimlight = true,
    fn = function(x, y) return (H(x // 3, y // 2, seed) - .5) * .28 end })
  m:each(function(x, y)   -- little leaf marks: lit leaf + dark notch
    if H(x, y, seed + 3) < .022 and m:has(x + 2, y + 1) and m:has(x, y + 2) then
      c:px(x, y, R.hi); c:px(x + 1, y, R.hi); c:px(x + 1, y + 1, R.base); c:px(x + 2, y + 1, R.shade); c:px(x, y + 2, R.deep)
    end
  end)
  return m
end

function GX.trunk(c, x0, x1, y0, y1, R, seed, o)
  o = o or {}
  local m, rows = HP.mask(), {}
  for y = y0, y1 do
    local wob = floor((GX.vn(0, y, 16, seed) - .5) * 5)
    local fl = floor(max(0, y - (y1 - 26)) * .55)
    rows[y] = { x0 - fl + wob, x1 + fl + wob }
    for x = rows[y][1], rows[y][2] do m:set(x, y) end
  end
  m = GX.rough(m, seed, 1)
  if not o.noink then c:rim(m, GX.INK); c:rim(m:copy():grow(1), GX.mix(GX.INK, R.deep, .5)) end
  local R6 = GX.ramp6(R)
  m:each(function(x, y)
    local r = rows[y] or rows[max(y0, min(y1, y))]
    local mid, hw = (r[1] + r[2]) / 2, max(2, (r[2] - r[1]) / 2)
    local s = max(-1, min(1, (x - mid) / hw))
    local nz = sqrt(max(0, 1 - s * s))
    local v = .12 + .88 * max(0, -.66 * s + .62 * nz)
    local st = GX.vn(x * 1.0, y * .11, 1.5, seed)
    v = v + (st - .5) * .6
    if st < .16 then v = v - .22 end
    if H(x // 2, y // 5, seed) < .06 then v = v - .18 end   -- bark plates
    c:px(x, y, R6[GX.idx(max(0, min(1, v)))])
  end)
  if o.moss then   -- moss on the shaded base
    local MR = GX.ramp6(o.moss)
    for y = y1 - 46, y1 - 2 do for x = x0 - 8, x1 + 8 do
      if m:has(x, y) and GX.vn(x, y, 5, seed + 5) > .56 + (y1 - y) / 140 then
        c:px(x, y, MR[2 + floor(H(x, y, seed) * 3)])
      end
    end end
  end
  return m
end

-- hand-placed decor helpers
function GX.tuft(c, x, y, R)
  local dk, md, lt = R.shade, R.base, R.hi
  for _, p in ipairs{ { -3, 0 }, { -1, -1 }, { 1, 0 }, { 3, -1 } } do
    c:px(x + p[1], y + p[2], dk); c:px(x + p[1], y + p[2] - 1, md); c:px(x + p[1], y + p[2] - 2, lt)
  end
  c:px(x, y - 3, lt); c:px(x - 1, y - 4, lt)
end
function GX.flower(c, x, y, col, ctr)
  c:px(x, y - 1, col); c:px(x - 1, y, col); c:px(x + 1, y, col); c:px(x, y + 1, col); c:px(x, y, ctr or "#ffe38a")
  c:px(x, y + 2, "#3f9150"); c:px(x, y + 3, "#3f9150")
end

return GX
