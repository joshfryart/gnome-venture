-- _aD13_1: private helper for rooibos-seed + root_cellar-1/2/3 (Opus-style single pass, artist D13_1).
-- Wraps batch2/_bbg.lua (read-only). Everything shared by the cellar tiers lives here: dome mound, soil lip,
-- plank door, stone arch frame, flag, barrel, steps, grass flecks.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local A = { G = G, HP = HP, X = X, K = K }
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan

-- ramps dark -> light (6 tones)
A.GRASS = { "#1b4540", "#2a6845", "#43944e", "#68b956", "#94d166", "#c6e984" }
A.SOIL  = { "#33202a", "#4d2d2d", "#6b4033", "#8c5a3c", "#b07a4a", "#d29c64" }
A.STONE = { "#30324c", "#484a68", "#6a6b88", "#8d8da6", "#b3b2c4", "#dcdae6" }
A.WOOD  = { "#3b2229", "#5a342f", "#7b4b37", "#a06841", "#c48b58", "#e7b87e" }
A.IRON  = { "#262a3e", "#3a3e58", "#565a76", "#7a7f9c", "#a6abc2", "#dde0ec" }
A.EMBER = { "#46172e", "#7a2a46", "#b2323f", "#e8493b", "#ff7b52", "#ffb27c" }
A.CARROT = { "#7a2a24", "#b0471f", "#d9662a", "#f08a2a", "#ffae45", "#ffd678" }

function A.new(name)
  A.name = name
  local c = HP.canvas{ w = 64, h = 64, scale = 1, name = name }
  return c
end
function A.save(c) G.save(c, A.name) end

function A.hash(x, y, s) return X.hash(x, y, s) end

-- light a mask with a pillow normal field into a 6-tone ramp; returns idx map, normals
function A.pill(c, m, ramp, R, o)
  o = o or {}
  local n = X.pillow(m, R or 2.5, o.hs)
  local idx = G.toneN(c, m, n, ramp, { bias = o.bias, tok = o.tok or { r = { name = tostring(m) } }, cuts = o.cuts, amb = o.amb, wrap = o.wrap })
  return idx, n
end

-- superellipse dome (flat base at yb). skew shifts the crown sideways
function A.dome(cx, yb, rx, ry, e, skew)
  local m = HP.mask()
  for y = yb - ry, yb do
    local u = (yb - y) / ry
    local hw = rx * (1 - u ^ e) ^ (1 / e)
    local off = (skew or 0) * u ^ 1.5
    for x = floor(cx + off - hw + .5), floor(cx + off + hw - .5) do m:set(x, y) end
  end
  return m
end

-- arch mask: bottom yb, half width w, total height h, centre cx (cells cx-w .. cx+w-1)
function A.arch(cx, yb, w, h)
  local m = HP.mask()
  local ay = yb - h + w
  for y = yb - h, yb do
    local hw
    if y >= ay then hw = w else
      local dy = (ay - y) / (w + .2)
      hw = w * sqrt(max(0, 1 - dy * dy))
    end
    for x = floor(cx - hw + .5), floor(cx + hw - .5) do m:set(x, y) end
  end
  return m
end

-- fleck texture on a lit mask: short hi / shade strokes
function A.flecks(c, m, idx, ramp, seed, dens, tok)
  m:each(function(x, y)
    local k = K(x, y)
    local i = idx[k]
    if not i then return end
    local h = X.hash(x, y, seed)
    if h > 1 - dens and i >= 3 and i <= 5 and m:has(x + 1, y - 1) then
      c:put(x, y, ramp[i + 1], tok) c:put(x + 1, y - 1, ramp[i + 1], tok)
    elseif h < dens * .8 and i >= 3 and m:has(x - 1, y - 1) then
      c:put(x, y, ramp[i - 1], tok)
      if X.hash(x, y, seed + 9) > .5 then c:put(x - 1, y, ramp[i - 1], tok) end
    end
  end)
end

-- a grass blade sticking up from (x,y) (bottom) with a lean; tones lit/dark
function A.blade(c, x, y, len, lean, hi, lo)
  for i = 0, len - 1 do
    local xx = x + floor(lean * i / max(1, len - 1) + .5)
    c:put(xx, y - i, i >= len - 1 and hi or lo, { r = { name = "blade" } })
    if i >= 1 and i < len - 1 then end
  end
  c:put(x + floor(lean + .5), y - len + 1, hi, { r = { name = "blade" } })
end

-- soil lip: a strip of earth under a mound base. returns mask
function A.soil(c, cx, yb, rx, seed, ramp)
  local m = HP.mask()
  for x = cx - rx - 1, cx + rx + 1 do
    local top = yb - 2 + (X.hash(x, 0, seed or 3) > .55 and 1 or 0)
    for y = top, yb + 1 do m:set(x, y) end
  end
  m:cut(c:rect(cx - rx - 1, yb + 1, cx - rx - 1, yb + 1)):cut(c:rect(cx + rx + 1, yb + 1, cx + rx + 1, yb + 1))
  return m
end
function A.soilPaint(c, m, seed, ramp)
  ramp = ramp or A.SOIL
  local tok = { r = { name = "soil" } }
  local idx = A.pill(c, m, ramp, 2.2, { tok = tok, amb = .14 })
  m:each(function(x, y)
    local h = X.hash(x, y, seed or 5)
    if h > .92 then c:put(x, y, A.STONE[3], tok) c:put(x + 1, y, A.STONE[4], tok)
    elseif h < .06 then c:put(x, y, ramp[1], tok) end
  end)
  return idx
end

-- plank door (arched top). o.cx, o.yb, o.w, o.h; returns mask
function A.door(c, cx, yb, w, h, o)
  o = o or {}
  local m = A.arch(cx, yb, w, h)
  local W = A.WOOD
  local x0 = cx - w
  local pw = o.pw or 4
  local tok = { r = { name = "door" .. cx } }
  local top = yb - h
  m:each(function(x, y)
    local lx = (x - x0) % pw
    local p = floor((x - x0) / pw)
    local base = (p % 2 == 0) and 4 or 3
    local i
    if lx == 0 then i = 1
    elseif lx == 1 then i = base + 1
    elseif lx == pw - 1 then i = base - 1
    else i = base end
    -- grain: dark streaks, deterministic
    local g = X.hash(x, floor(y / 3), 11 + p)
    if lx > 0 and g > .86 then i = i - 1 end
    -- shadow from the frame above / left (door is recessed)
    local depth = y - top
    if depth < 2 then i = i - 2 elseif depth < 4 then i = i - 1 end
    if x - x0 < 1 then i = i - 1 end
    -- plank end butt lines
    if (y + p * 5) % 9 == 0 and lx > 0 and lx < pw - 1 then i = i - 1 end
    -- light falling on the lower right of the recess floor
    i = max(1, min(6, i))
    c:put(x, y, W[i], tok)
  end)
  return m, tok
end

-- iron straps + ring handle for a door
function A.ironwork(c, cx, yb, w, h, o)
  o = o or {}
  local I = A.IRON
  local x0 = cx - w
  local tok = { r = { name = "iron" .. cx } }
  for _, f in ipairs{ .28, .66 } do
    local y = yb - floor(h * f)
    local len = floor(w * 1.4)
    for x = x0, x0 + len do
      c:put(x, y, I[4], tok) c:put(x, y + 1, I[2], tok)
    end
    c:put(x0, y - 1, I[3], tok) c:put(x0, y + 2, I[2], tok)             -- hinge eye
    c:put(x0 + 1, y, I[6], tok)                                         -- rivet glint
    c:put(x0 + len - 1, y, I[6], tok)
  end
  -- ring handle on the right
  local hx, hy = cx + w - 4, yb - floor(h * .46)
  c:put(hx, hy - 1, I[5], tok) c:put(hx + 1, hy - 1, I[3], tok)
  c:put(hx - 1, hy, I[4], tok) c:put(hx + 2, hy, I[2], tok)
  c:put(hx - 1, hy + 1, I[3], tok) c:put(hx + 2, hy + 1, I[1], tok)
  c:put(hx, hy + 2, I[2], tok) c:put(hx + 1, hy + 2, I[1], tok)
  c:put(hx, hy, A.WOOD[1], tok) c:put(hx + 1, hy, A.WOOD[1], tok)
  c:put(hx, hy + 1, A.WOOD[2], tok) c:put(hx + 1, hy + 1, A.WOOD[1], tok)
  c:put(hx - 1, hy - 1, I[6], tok)
end

-- stone arch frame ring around a door. returns frame mask
function A.stoneFrame(c, cx, yb, w, h, th, seed)
  local outer = A.arch(cx, yb, w + th, h + th)
  local inner = A.arch(cx, yb, w, h)
  local fm = outer:copy():cut(inner)
  local S = A.STONE
  local ay = yb - h + w
  local acx = cx - .5
  local NB = 9
  local function block(x, y)
    if y <= ay then
      local a = atan(y - ay, x - acx)               -- -pi .. 0 across the crown
      local f = (a + pi) / pi
      return "a" .. floor(f * NB)
    end
    local course = floor((yb - y) / 4)
    local side = x < cx and 0 or 1
    local jx = ((course + side) % 2 == 0) and 1 or 0
    local inEdge = (x < cx) and (x >= cx - w - th + 0) and (x - (cx - w - th) >= th - 1 - jx and 1 or 0) or ((x - (cx + w - 1)) <= 1 + jx and 1 or 0)
    return "c" .. course .. "_" .. side .. "_" .. inEdge
  end
  local tok = { r = { name = "stoneframe" } }
  local bias = {}
  fm:each(function(x, y)
    local b = block(x, y)
    local bid = 0 for i = 1, #b do bid = bid + b:byte(i) * i end
    local hv = X.hash(bid, 1, seed or 2)
    bias[K(x, y)] = hv > .78 and 1 or (hv < .25 and -1 or 0)
  end)
  local idx, n = A.pill(c, fm, S, 2.2, { bias = bias, tok = tok, amb = .12 })
  -- mortar: first pixel of each new block (left/up) is a dark joint
  fm:each(function(x, y)
    local b = block(x, y)
    local l, u = fm:has(x - 1, y) and block(x - 1, y), fm:has(x, y - 1) and block(x, y - 1)
    if (l and l ~= b) or (u and u ~= b) then c:put(x, y, S[2], tok) end
  end)
  -- chips and a lit top edge
  fm:each(function(x, y)
    if X.hash(x, y, 77) > .965 then c:put(x, y, S[6], tok) end
  end)
  return fm, outer, inner
end

-- slim flag pole + waving flag. px,py = pole foot; top y; returns pole mask
function A.flag(c, px, foot, top, o)
  o = o or {}
  local W = A.WOOD
  local tok = { r = { name = "pole" } }
  for y = top, foot do
    c:put(px, y, W[5], tok) c:put(px + 1, y, W[3], tok)
    if (y % 4) == 0 then c:put(px + 1, y, W[2], tok) end
  end
  c:put(px, top, W[6], tok) c:put(px + 1, top, W[5], tok)
  c:put(px, top - 1, W[5], tok)   -- rounded knob
  -- flag cloth
  local E = A.EMBER
  local fx0, fy0 = px + 2, top + 1
  local len, hgt = o.len or 12, o.hgt or 8
  local fm = HP.mask()
  for x = 0, len - 1 do
    local wave = floor(sin(x / (len - 1) * pi * 1.5 + .4) * 1.6 + .5)
    local hh = hgt - floor(x * (o.taper or .25))
    local notch = (x >= len - 3) and (x - (len - 4)) or 0     -- swallow tail
    for y = 0, hh - 1 do
      if not (notch > 0 and abs(y - hh / 2 + .5) < notch * .9) then fm:set(fx0 + x, fy0 + y + wave) end
    end
  end
  local n = {}
  fm:each(function(x, y)
    local ph = (x - fx0) / (len - 1) * pi * 1.5 + .4
    local nx = cos(ph) * .85
    n[K(x, y)] = { nx * -1, -.15, sqrt(max(.05, 1 - nx * nx)) }
  end)
  local tk = { r = { name = "flag" } }
  G.toneN(c, fm, n, E, { tok = tk, amb = .12, wrap = .3, cuts = { .2, .38, .54, .7, .86 } })
  fm:each(function(x, y)
    if X.hash(x, y, 4) > .93 then c:put(x, y, E[3], tk) end
  end)
  -- a sewn hem on the pole side
  for y = fy0, fy0 + hgt + 2 do if fm:has(fx0, y) then c:put(fx0, y, E[2], tk) end end
  return fm
end

-- barrel: hw half width at the belly, y0..y0+h, centre cx. hoops iron.
function A.barrel(c, cx, y0, h, hw, seed)
  local m = HP.mask()
  local W = A.WOOD
  for y = y0, y0 + h - 1 do
    local t = (y - y0) / (h - 1)
    local r = hw - .8 + 1.4 * sin(pi * t) ^ .8
    for x = floor(cx - r + .5), floor(cx + r - .5) do m:set(x, y) end
  end
  local n = {}
  m:each(function(x, y)
    local t = (y - y0) / (h - 1)
    local r = hw - .8 + 1.4 * sin(pi * t) ^ .8
    local s = max(-.95, min(.95, (x - (cx - .5)) / (r)))
    n[K(x, y)] = { s, 0, sqrt(1 - s * s) }
  end)
  local tok = { r = { name = "barrel" } }
  G.toneN(c, m, n, W, { tok = tok, amb = .1, wrap = .3 })
  -- stave seams
  m:each(function(x, y)
    if (x - (cx - hw)) % 3 == 0 and y > y0 + 1 and y < y0 + h - 1 then
      local s = floor((x - (cx - hw)) / 3)
      c:put(x, y, W[2], tok)
    end
  end)
  -- hoops
  local I = A.IRON
  for _, y in ipairs{ y0 + 2, y0 + h - 3 } do
    m:each(function(x, yy)
      if yy == y then c:put(x, yy, (x < cx) and I[5] or I[3], tok) end
      if yy == y + 1 then c:put(x, yy, I[2], tok) end
    end)
  end
  -- lid shine
  c:put(floor(cx - hw + 1), y0, W[6], tok) c:put(floor(cx - hw + 2), y0, W[6], tok)
  return m
end

return A
