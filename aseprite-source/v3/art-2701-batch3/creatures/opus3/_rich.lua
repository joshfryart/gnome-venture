-- _rich.lua: shared helpers for the opus3 richness pass (needs v3/lib/hp.lua and hpx.lua).
--   local Q = dofile(DIR .. "/_rich.lua").init(HP)
--   Q.ramp("#6a55b4")            -> 6 hue-shifted tones, dark to light {deep, shade, dim, base, lit, hi}
--   Q.body(c, mask, ramp6, o)    -> per-pixel light (upper-left), quantised to the ramp; o.tex(x,y) adds tone steps;
--                                   o.bounce = hex paints the bounce line on the lower edge; returns idx map, normals
--   Q.side(mask, dx, dy)         -> pixels of mask whose (x+dx, y+dy) neighbour is outside it
--   Q.hash(x, y, seed)           -> 0..1 deterministic noise
-- Hard pixels only. Colours never reach pure black or white.
local Q = {}
local HP, X
local floor, max, min, abs = math.floor, math.max, math.min, math.abs

function Q.init(hp)
  HP = hp
  X = dofile(HP.dir .. "/hpx.lua").init(HP)
  Q.X = X
  return Q
end

local function rgb(h) return tonumber(h:sub(2, 3), 16) / 255, tonumber(h:sub(4, 5), 16) / 255, tonumber(h:sub(6, 7), 16) / 255 end
local function hsl(h)
  local r, g, b = rgb(h)
  local mx, mn = max(r, g, b), min(r, g, b)
  local l = (mx + mn) / 2
  if mx == mn then return 0, 0, l end
  local d = mx - mn
  local s = l > 0.5 and d / (2 - mx - mn) or d / (mx + mn)
  local hh
  if mx == r then hh = (g - b) / d + (g < b and 6 or 0) elseif mx == g then hh = (b - r) / d + 2 else hh = (r - g) / d + 4 end
  return hh * 60, s, l
end
local function hue2(p, q, t)
  if t < 0 then t = t + 1 end
  if t > 1 then t = t - 1 end
  if t < 1 / 6 then return p + (q - p) * 6 * t end
  if t < 1 / 2 then return q end
  if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
  return p
end
function Q.fromHsl(h, s, l)
  h = (h % 360) / 360
  s, l = max(0, min(1, s)), max(0.04, min(0.95, l))
  local r, g, b
  if s == 0 then r, g, b = l, l, l else
    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    r, g, b = hue2(p, q, h + 1 / 3), hue2(p, q, h), hue2(p, q, h - 1 / 3)
  end
  local function c8(v) return max(4, min(250, floor(v * 255 + 0.5))) end
  return string.format("#%02x%02x%02x", c8(r), c8(g), c8(b))
end
Q.hsl = hsl
-- move hue h toward target by at most deg along the short arc
local function toward(h, target, deg)
  local d = ((target - h + 540) % 360) - 180
  if abs(d) <= deg then return target end
  return h + (d > 0 and deg or -deg)
end
Q.toward = toward

-- 6 tones dark -> light. Darks drift toward violet (cool), lights toward warm yellow.
function Q.ramp(base, o)
  o = o or {}
  local h, s, l = hsl(base)
  local cool, warm = o.cool or 270, o.warm or 50
  local hd, hl = o.hd or 9, o.hl or 8
  local t = {}
  t[1] = Q.fromHsl(toward(h, cool, hd * 2.6), s * 0.72, l * 0.42)
  t[2] = Q.fromHsl(toward(h, cool, hd * 1.7), s * 0.80, l * 0.60)
  t[3] = Q.fromHsl(toward(h, cool, hd * 0.8), s * 0.90, l * 0.80)
  t[4] = base
  t[5] = Q.fromHsl(toward(h, warm, hl), min(1, s * 1.02), l + (1 - l) * 0.26)
  t[6] = Q.fromHsl(toward(h, warm, hl * 2.2), s * 0.95, l + (1 - l) * 0.55)
  return t
end
-- a cool bounce tone from the ramp's dim tone (reflected sky/ground light on the underside)
function Q.bounceOf(r, hue)
  local h, s, l = hsl(r[3])
  return Q.fromHsl(toward(h, hue or 195, 30), s * 0.85, l * 1.08)
end

-- expand a 4-tone {hi, base, shade, deep} ramp to 6 tones (dark -> light) keeping its colours;
-- the in-between tones lean cool on the dark side and warm on the light side
local function mix(a, b, t)
  local r1, g1, b1 = rgb(a) local r2, g2, b2 = rgb(b)
  local function c8(v) return max(4, min(250, floor(v * 255 + 0.5))) end
  return string.format("#%02x%02x%02x", c8(r1 + (r2 - r1) * t), c8(g1 + (g2 - g1) * t), c8(b1 + (b2 - b1) * t))
end
Q.mix = mix
function Q.six(r)
  return { r.deep, r.shade, mix(r.shade, r.base, 0.5), r.base, mix(r.base, r.hi, 0.5), r.hi }
end

Q.hash = function(x, y, s) return X.hash(x, y, s) end

function Q.side(m, dx, dy)
  local e = HP.mask()
  m:each(function(x, y) if not m:has(x + dx, y + dy) then e:set(x, y) end end)
  return e
end

-- per-pixel light. o.R bevel radius, o.sphere={cx,cy,r}, o.normals, o.amb, o.wrap, o.cuts, o.bias (table),
-- o.tex(x,y,k)->int tone steps, o.ao={{mask,r,amt},..}, o.bounce=hex, o.bounceMinX
function Q.body(c, m, ramp, o)
  o = o or {}
  local n = o.normals or (o.sphere and X.sphere(o.sphere[1], o.sphere[2], o.sphere[3], m)) or X.pillow(m, o.R or 4, o.hs)
  local v = X.light(n, { amb = o.amb or 0.15, wrap = o.wrap or 0.3 })
  local bias = o.bias or {}
  if o.ao then for _, a in ipairs(o.ao) do X.ao(bias, m, a[1], a[2] or 1, a[3] or -1) end end
  if o.tex then m:each(function(x, y)
    local k = X.K(x, y)
    local b = o.tex(x, y, k, v[k] or 0)
    if b and b ~= 0 then bias[k] = (bias[k] or 0) + b end
  end) end
  local tok = o.tok or { r = { name = tostring(ramp) } }
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or { .2, .36, .52, .7, .86 }, bias = bias, tok = tok })
  if o.bounce then
    local minx = o.bounceMinX or -999
    Q.side(m, 0, 1):each(function(x, y)
      if x >= minx and m:has(x, y - 1) and (idx[X.K(x, y)] or 9) <= 3 then c:put(x, y, o.bounce, tok) end
    end)
  end
  return idx, n, tok
end

-- recolour pixels of mask m that currently hold one of the listed colours
function Q.swap(c, m, map)
  m:each(function(x, y) local h = c:get(x, y) if h and map[h] then c.pix[y * c.w + x] = map[h] end end)
end

return Q
