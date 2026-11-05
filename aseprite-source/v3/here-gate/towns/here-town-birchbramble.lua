-- Hearth Pop v3: "Birchbramble Steppe" town gate view (480x270 native)
local OUT = (app and app.params and app.params.out) or "/home/user/gnome-venture/aseprite-source/v3/here-gate/towns/"
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local NAME = "here-town-birchbramble"
local W, H = 480, 270
local VPX, VPY = 240, 112
local floor, abs, sin, cos, sqrt = math.floor, math.abs, math.sin, math.cos, math.sqrt

---------------------------------------------------------------- colour
local buf = {}
local function cl(v) v = floor(v + 0.5) if v < 0 then v = 0 elseif v > 255 then v = 255 end return v end
local function parse(c) return tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16), tonumber(c:sub(6, 7), 16) end
local function mk(r, g, b)
  r, g, b = cl(r), cl(g), cl(b)
  if r + g + b == 0 then r = 2 end
  if r == 255 and g == 255 and b == 255 then b = 248 end
  return string.format("#%02x%02x%02x", r, g, b)
end
local function mix(a, b, t)
  local r1, g1, b1 = parse(a) local r2, g2, b2 = parse(b)
  return mk(r1 + (r2 - r1) * t, g1 + (g2 - g1) * t, b1 + (b2 - b1) * t)
end
local function RP(base, o)
  o = o or {}
  return { d = mix(base, "#2b1c3a", o.d or .55), s = mix(base, "#463e7c", o.s or .33), b = base,
           h = mix(base, "#fff0c0", o.h or .3), t = mix(base, "#fff8e0", o.t or .58) }
end
local function hash(x, y, s)
  local n = sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453
  return n - floor(n)
end
local function set(x, y, c)
  x, y = floor(x), floor(y)
  if c and x >= 0 and x < W and y >= 0 and y < H then buf[y * W + x] = c end
end
local function get(x, y)
  x, y = floor(x), floor(y)
  if x < 0 then x = 0 elseif x >= W then x = W - 1 end
  if y < 0 then y = 0 elseif y >= H then y = H - 1 end
  return buf[y * W + x] or "#808080"
end

---------------------------------------------------------------- masks
local function newm() return { s = {} } end
local function madd(m, x, y)
  x, y = floor(x), floor(y)
  if x >= 0 and x < W and y >= 0 and y < H then m.s[y * W + x] = true end
end
local function mhas(m, x, y)
  return x >= 0 and x < W and y >= 0 and y < H and m.s[y * W + x] == true
end
local function each(m, fn) for k in pairs(m.s) do fn(k % W, k // W) end end
local function rect(x0, y0, x1, y1)
  local m = newm()
  for y = floor(y0), floor(y1) do for x = floor(x0), floor(x1) do madd(m, x, y) end end
  return m
end
local function poly(p)
  local m = newm()
  local minx, maxx, miny, maxy = 1e9, -1e9, 1e9, -1e9
  for _, q in ipairs(p) do
    minx = math.min(minx, q[1]) maxx = math.max(maxx, q[1])
    miny = math.min(miny, q[2]) maxy = math.max(maxy, q[2])
  end
  for y = floor(miny), floor(maxy) do
    for x = floor(minx), floor(maxx) do
      local px, py, inside = x + .5, y + .5, false
      local j = #p
      for i = 1, #p do
        local xi, yi, xj, yj = p[i][1], p[i][2], p[j][1], p[j][2]
        if ((yi > py) ~= (yj > py)) and (px < (xj - xi) * (py - yi) / (yj - yi) + xi) then inside = not inside end
        j = i
      end
      if inside then madd(m, x, y) end
    end
  end
  return m
end
local function ell(cx, cy, rx, ry, jag, seed)
  local m = newm()
  for y = floor(cy - ry - 1), floor(cy + ry + 1) do
    for x = floor(cx - rx - 1), floor(cx + rx + 1) do
      local d = ((x + .5 - cx) / rx) ^ 2 + ((y + .5 - cy) / ry) ^ 2
      local lim = 1
      if jag then lim = 1 - jag * hash(x // 2, y // 2, seed or 1) end
      if d <= lim then madd(m, x, y) end
    end
  end
  return m
end
local function union(...)
  local m = newm()
  for _, a in ipairs({ ... }) do for k in pairs(a.s) do m.s[k] = true end end
  return m
end
local function cut(m, b) for k in pairs(b.s) do m.s[k] = nil end return m end
local function lineM(pts, w)
  local m = newm()
  local h0 = floor((w - 1) / 2)
  for i = 1, #pts - 1 do
    local ax, ay, bx, by = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    local n = math.max(1, floor(math.max(abs(bx - ax), abs(by - ay)) * 2))
    for s = 0, n do
      local x, y = ax + (bx - ax) * s / n, ay + (by - ay) * s / n
      for dy = 0, w - 1 do for dx = 0, w - 1 do madd(m, floor(x) - h0 + dx, floor(y) - h0 + dy) end end
    end
  end
  return m
end
local function fill(m, f)
  each(m, function(x, y)
    local c = (type(f) == "string") and f or f(x, y)
    if c then set(x, y, c) end
  end)
end
local function edge(m, c)
  each(m, function(x, y)
    if not (mhas(m, x - 1, y) and mhas(m, x + 1, y) and mhas(m, x, y - 1) and mhas(m, x, y + 1)) then set(x, y, c) end
  end)
end
local function darken(m, col, t) each(m, function(x, y) set(x, y, mix(get(x, y), col, t)) end) end
-- generic lit part: upper-left light, lower-right cool shade, own dark edge
local function lit(m, rp, o)
  o = o or {}
  local sb = o.band or 2
  each(m, function(x, y)
    local c = rp.b
    local shade = false
    for i = 1, sb + 1 do
      if not mhas(m, x + i, y) or not mhas(m, x, y + i) then shade = true end
    end
    if shade then c = rp.s
    elseif not mhas(m, x - 2, y) or not mhas(m, x, y - 2) then c = rp.h end
    if o.tex and c == rp.b and hash(x, y, o.tex) < .12 then c = rp.h end
    if o.tex and c == rp.b and hash(x, y, o.tex + 3) < .1 then c = rp.s end
    set(x, y, c)
  end)
  if not o.noedge then edge(m, rp.d) end
end
local function glow(cx, cy, rx, ry, col)
  for y = floor(cy - ry), floor(cy + ry) do
    for x = floor(cx - rx), floor(cx + rx) do
      local d = ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2
      if d <= .3 then set(x, y, mix(get(x, y), col, .38))
      elseif d <= .62 then set(x, y, mix(get(x, y), col, .25))
      elseif d <= 1 then set(x, y, mix(get(x, y), col, .13)) end
    end
  end
end
local function mv(x, y, t) return x + (VPX - x) * t, y + (VPY - y) * t end

---------------------------------------------------------------- palette
local INK = "#2b1c26"
local SHADOWC = "#3f3466"
local WARM = "#ffd06a"
local GLASS = { a = "#ffe7a2", b = "#ffcf6e", c = "#f0a55a", d = "#8a4b3a" }
local CREAM = RP("#efe2c4")
local WOOD = RP("#a8774d")
local BIRCH = { d = "#4a3a46", s = "#bdb3c4", b = "#e6e0d6", h = "#f6f0e4", t = "#fbf6ec", mark = "#3b2f3a" }
local LEAF = { d = "#3d573a", s = "#5d7f46", b = "#8eae4a", h = "#c4cf5e", t = "#e9d977" }
local STEAM = { d = "#a99fbd", s = "#d3cbd9", b = "#efe8e2", h = "#faf5ee" }

---------------------------------------------------------------- 1 sky
local skyc = { { 0, "#5c70b4" }, { 14, "#6a7fbf" }, { 28, "#8190c8" }, { 42, "#9d9fcf" }, { 56, "#bba9cc" },
  { 68, "#d6b3c0" }, { 80, "#ebc1a2" }, { 92, "#f4cf92" }, { 102, "#f8dd9a" } }
for y = 0, 120 do
  local c = skyc[1][2]
  for _, b in ipairs(skyc) do if y >= b[1] then c = b[2] end end
  for x = 0, W - 1 do
    local cc = c
    -- low golden sun rays from the upper left
    local a = math.atan(y + 60, x + 80)
    if floor(a * 34) % 3 == 0 and y > 8 then cc = mix(cc, "#fff2c6", .12) end
    set(x, y, cc)
  end
end
-- clouds
local function cloud(x, y, w, seed)
  local m = union(ell(x + w * .3, y - w * .16, w * .26, w * .2, .12, seed),
    ell(x + w * .55, y - w * .26, w * .27, w * .27, .12, seed + 1),
    ell(x + w * .8, y - w * .12, w * .2, w * .16, .12, seed + 2),
    ell(x + w * .12, y - w * .07, w * .14, w * .1, .1, seed + 3), rect(x + w * .08, y - w * .1, x + w * .94, y))
  cut(m, rect(x - 20, y + 1, x + w + 20, y + 40))
  local cr = { d = "#c58f9e", s = "#dfa9ab", b = "#f3d3bd", h = "#fde9d2" }
  each(m, function(px, py)
    local c = cr.b
    if py >= y - 2 then c = cr.s
    elseif not mhas(m, px + 2, py) or not mhas(m, px + 1, py + 1) then c = cr.s
    elseif not mhas(m, px - 2, py) or not mhas(m, px, py - 2) then c = cr.h end
    if py == y then c = "#e8b07e" end
    set(px, py, c)
  end)
  edge(m, cr.d)
  each(m, function(px, py) if py == y and get(px, py) == cr.d then set(px, py, "#d99a78") end end)
end
cloud(24, 46, 74, 1)
cloud(112, 30, 50, 4)
cloud(300, 28, 84, 7)
cloud(392, 54, 58, 10)
cloud(166, 66, 36, 13)
cloud(250, 84, 40, 16)

---------------------------------------------------------------- 2 far scenery
local f1 = function(x) return floor(97 + 5 * sin(x / 41) + 3 * sin(x / 17 + 1)) end
for x = 0, W - 1 do
  local top = f1(x)
  for y = top, 120 do set(x, y, (y == top) and "#b9aacd" or ((y - top) % 7 == 3 and "#998cba" or "#a395c2")) end
end
local f2 = function(x) return floor(105 + 3 * sin(x / 29 + 2) + 2 * sin(x / 9)) end
for x = 0, W - 1 do
  local top = f2(x)
  for y = top, 120 do set(x, y, (y == top) and "#93a27a" or "#7d8f76") end
end
-- distant birch groves (tiny crowns + white trunks)
local i = 0
for gx = 4, 472, 7 do
  i = i + 1
  if not (gx > 196 and gx < 286) and hash(gx, 3, 2) < .8 then
    local base = f2(gx) + 1
    local hh = 6 + floor(hash(gx, 1, 3) * 7)
    local m = ell(gx + .5, base - hh / 2 - 2, 3.2, hh / 2 + .5, .15, gx)
    each(m, function(x, y)
      local c = "#8a9d6a"
      if not mhas(m, x - 1, y - 1) then c = "#b3b778" elseif not mhas(m, x + 1, y + 1) then c = "#6d8460" end
      set(x, y, c)
    end)
    set(gx, base, "#e2dccc") set(gx, base - 1, "#e2dccc") set(gx, base - 2, "#d0c8c0")
  end
end
-- far haystacks on the steppe (low domes, flat-sided)
local function rick(cx, by, w)
  local m = poly { { cx - w, by }, { cx - w + 2, by - w + 1 }, { cx, by - w - 2 }, { cx + w - 2, by - w + 1 }, { cx + w, by } }
  lit(m, RP("#d6a95a"), { band = 1 })
end
rick(186, 114, 4) rick(176, 116, 3) rick(300, 115, 4) rick(312, 117, 3)

---------------------------------------------------------------- 3 steppe ground
for y = 108, H - 1 do
  for x = 0, W - 1 do
    if y >= 112 or y > f2(x) + 4 then
      local t = (y - 112) / 158
      local base = mix("#dcc27b", "#b9944f", t)
      local sc = 1 + floor((y - 108) / 26)
      local h = hash(x, floor(y / sc), 9)
      local c = base
      if h < .16 then c = mix(base, "#6f5c38", .3)
      elseif h < .24 then c = mix(base, "#fff0b0", .3)
      elseif h < .3 then c = mix(base, "#8a9a50", .3) end
      set(x, y, c)
    end
  end
end
-- scattered steppe flowers, foreground only (keep stand areas calm-ish)
for n = 1, 260 do
  local x, y = floor(hash(n, 1, 21) * 470) + 5, floor(hash(n, 2, 21) * 140) + 125
  if not (x > 376 and y > 226) then
    local c = ({ "#f3ead6", "#7a8fd8", "#e9c94a", "#d77b8a" })[1 + n % 4]
    set(x, y, c)
    if y > 200 then set(x + 1, y, c) set(x, y + 1, "#6f7f40") end
  end
end

---------------------------------------------------------------- 4 plank road + plaza
local function L(y) return 140 + 94 * (270 - y) / 158 end
local function Rr(y) return 340 - 94 * (270 - y) / 158 end
local ROAD = RP("#b58d60")
for y = 113, H - 1 do
  local k = floor(900 / (y - 106))
  local kp = floor(900 / (y - 107))
  local lx, rx = L(y), Rr(y)
  for x = floor(lx), floor(rx) do
    local c = (k % 2 == 0) and ROAD.b or mix(ROAD.b, ROAD.h, .4)
    local gs = 2 + floor((y - 112) / 14)
    local hh = hash(floor(x / gs), k, 31)
    if hh < .22 then c = ROAD.s elseif hh > .9 then c = ROAD.h end
    if k ~= kp then c = ROAD.d end
    if y > 160 and hash(floor(x / gs), k, 33) < .015 then c = ROAD.d end
    -- plank end joints
    local seg = floor((x - lx + (k % 3) * 37) / (40 + (y - 112) * .4))
    local seg2 = floor((x - 1 - lx + (k % 3) * 37) / (40 + (y - 112) * .4))
    if seg ~= seg2 and y > 125 then c = ROAD.d end
    if x <= lx + 1 + (y - 112) / 50 or x >= rx - 1 - (y - 112) / 50 then c = WOOD.d end
    set(x, y, c)
  end
end

---------------------------------------------------------------- building kit
local function logC(rp, yy, x, seed, dark)
  local r = floor(yy) % 5
  local c
  if r == 0 then c = rp.d elseif r == 1 then c = rp.h elseif r == 4 then c = rp.s else c = rp.b end
  if (r == 2 or r == 3) and hash(x // 3, floor(yy) // 5, seed) < .2 then c = rp.s end
  if r == 2 and hash(x, floor(yy) // 5, seed + 1) < .035 then c = rp.d end
  if dark then
    if c == rp.h then c = rp.b elseif c == rp.b then c = rp.s elseif c == rp.s then c = mix(rp.s, rp.d, .5) end
  end
  return c
end
local function shingleC(rp, x, y, seed, moss)
  local row = y // 4 local r = y % 4 local off = (row % 2) * 3
  local c
  if r == 3 then c = rp.d elseif (x + off) % 6 == 0 then c = rp.s elseif r == 0 then c = rp.h else c = rp.b end
  if c ~= rp.d and hash((x + off) // 6, row, seed) < .18 then c = rp.s end
  if moss and c ~= rp.d and hash(x // 3, y // 3, seed + 5) < .14 then c = (r == 0) and "#a4b85e" or "#7a9a4e" end
  return c
end

local function window(x, y, w, h, shut, tr)
  tr = tr or CREAM
  local sw = floor(w / 2) + 1
  -- shutters
  local sl, sr = rect(x - 3 - sw, y - 1, x - 3, y + h), rect(x + w + 2, y - 1, x + w + 2 + sw, y + h)
  for _, m in ipairs({ sl, sr }) do
    fill(m, function(px, py) return (px % 3 == 0) and shut.s or shut.b end)
    edge(m, shut.d)
  end
  -- painted diamonds
  for _, ox in ipairs({ x - 3 - sw + sw / 2, x + w + 2 + sw / 2 }) do
    local cy = y + h / 2
    set(ox, cy - 1, shut.t) set(ox - 1, cy, shut.t) set(ox + 1, cy, shut.t) set(ox, cy + 1, shut.t) set(ox, cy, CREAM.b)
  end
  -- frame
  local fr = rect(x - 2, y - 2, x + w + 1, y + h + 1)
  lit(fr, tr, { band = 0 })
  -- carved pediment
  local pd = poly { { x - 4, y - 1 }, { x + w + 4, y - 1 }, { x + w / 2, y - 8 } }
  lit(pd, tr, { band = 0 })
  set(x + w / 2, y - 4, shut.b) set(x + w / 2 - 1, y - 3, shut.b) set(x + w / 2 + 1, y - 3, shut.b)
  -- sill + drops
  local sil = rect(x - 4, y + h + 2, x + w + 3, y + h + 3)
  lit(sil, tr, { band = 0 })
  for px = x - 2, x + w + 1, 3 do set(px, y + h + 4, tr.s) end
  -- glass
  local gm = rect(x, y, x + w - 1, y + h - 1)
  each(gm, function(px, py)
    local c = GLASS.b
    if px - x + py - y < 3 then c = GLASS.a elseif (x + w - 1 - px) + (y + h - 1 - py) < 3 then c = GLASS.c end
    set(px, py, c)
  end)
  local mx, my = x + floor(w / 2), y + floor(h / 2)
  for py = y, y + h - 1 do set(mx, py, tr.d) end
  for px = x, x + w - 1 do set(px, my, tr.d) end
  set(x + 1, y + 1, "#fff6d6")
end
local function door(x, y, w, h, rp)
  local m = rect(x, y, x + w - 1, y + h - 1)
  fill(m, function(px, py) return ((px - x) % 4 == 3) and rp.s or (((px - x) % 4 == 0) and rp.h or rp.b) end)
  for px = x, x + w - 1 do set(px, y + 4, rp.d) set(px, y + h - 6, rp.d) end
  edge(m, rp.d)
  set(x + w - 3, y + floor(h / 2), "#e8b84a") set(x + w - 3, y + floor(h / 2) + 1, "#9a6a2a")
  local st = rect(x - 2, y + h, x + w + 1, y + h + 1)
  lit(st, RP("#9f9087"), { band = 0 })
end
-- izba: gable front, side receding toward the VP
local function izba(o)
  local x0, x1, yb = o.x0, o.x1, o.yb
  local wt = yb - o.wh
  local ya = wt - o.rh
  local cx = (x0 + x1) / 2
  local ov = o.ov or 4
  local t = o.t
  local wr, rr, tr = o.wall, o.roof, o.trim
  local seed = o.seed or 1
  -- ground shadow (light upper-left -> lower-right)
  if o.side == "L" then
    local bx, by = mv(x1, yb, t)
    darken(poly { { x0 + 2, yb - 2 }, { bx + 2, by - 2 }, { bx + 12, by + 5 }, { x0 + 10, yb + 6 } }, SHADOWC, .36)
  else
    local bx, by = mv(x0, yb, t)
    darken(poly { { bx, by - 2 }, { x1, yb - 2 }, { x1 + 12, yb + 6 }, { bx + 8, by + 5 } }, SHADOWC, .36)
  end
  -- side wall
  local sx = (o.side == "L") and x1 or x0
  local ax, ay = mv(sx, wt, t)
  local bx, by = mv(sx, yb, t)
  local side = poly { { sx, wt }, { sx, yb + 1 }, { bx, by + 1 }, { ax, ay } }
  each(side, function(x, y)
    local s = (x - sx) / (VPX - sx)
    local yf = (y - s * VPY) / (1 - s)
    set(x, y, logC(wr, yf - wt, x, seed, o.side == "L"))
  end)
  edge(side, wr.d)
  -- roof plane receding
  local ex = (o.side == "L") and (x1 + ov) or (x0 - ov)
  local p1x, p1y = mv(cx, ya, t)
  local p2x, p2y = mv(ex, wt + 3, t)
  local rp = poly { { cx, ya }, { ex, wt + 3 }, { p2x, p2y }, { p1x, p1y } }
  each(rp, function(x, y)
    local c = shingleC(rr, x, y, seed, o.moss)
    if o.side == "L" and c == rr.h then c = rr.b end
    set(x, y, c)
  end)
  edge(rp, rr.d)
  -- ridge cap line
  local rc = lineM({ { cx, ya }, { p1x, p1y } }, 2)
  fill(rc, rr.d)
  -- front wall logs
  local fw = rect(x0, wt, x1, yb)
  each(fw, function(x, y)
    local c = logC(wr, y - wt, x, seed)
    if x >= x1 - 2 and c ~= wr.d then c = (c == wr.h) and wr.b or wr.s end
    if x <= x0 + 1 and c == wr.b then c = wr.h end
    set(x, y, c)
  end)
  edge(fw, wr.d)
  -- log ends at the corners
  for yy = wt + 1, yb - 3, 5 do
    for _, ex2 in ipairs({ x0 - 3, x1 + 1 }) do
      local m = rect(ex2, yy, ex2 + 2, yy + 3)
      fill(m, wr.h) edge(m, wr.d) set(ex2 + 1, yy + 1, mix(wr.h, "#fff4cc", .4))
    end
  end
  -- gable boards
  local gb = poly { { cx, ya + 2 }, { x1 + 1, wt + 1 }, { x0 - 1, wt + 1 } }
  each(gb, function(x, y)
    local g = o.gable or wr
    local c = ((x - x0) % 4 == 0) and g.s or g.b
    if x > cx + 3 then c = ((x - x0) % 4 == 0) and g.d or g.s end
    set(x, y, c)
  end)
  for x = x0 - 1, x1 + 1 do set(x, wt + 1, wr.d) set(x, wt + 2, wr.s) end
  -- barge boards (carved) + towel pendant
  local bl = lineM({ { cx, ya }, { x0 - ov, wt + 4 } }, 3)
  local br = lineM({ { cx, ya }, { x1 + ov, wt + 4 } }, 3)
  lit(bl, tr, { band = 0 }) lit(br, tr, { band = 1 })
  -- drip teeth under the barge boards
  for s = 0, 1, 0.08 do
    local px, py = cx + (x0 - ov - cx) * s, ya + (wt + 4 - ya) * s
    set(px, py + 2, tr.s)
    local qx = cx + (x1 + ov - cx) * s
    set(qx, py + 2, tr.d)
  end
  local pend = poly { { cx - 2, ya + 1 }, { cx + 2, ya + 1 }, { cx + 2, ya + 9 }, { cx, ya + 12 }, { cx - 2, ya + 9 } }
  lit(pend, tr, { band = 0 })
  set(cx, ya + 5, o.shut and o.shut.b or tr.d)
  return { wt = wt, ya = ya, cx = cx }
end

local function puff(x, y, r, seed)
  local m = union(ell(x, y, r, r * .8, .1, seed), ell(x + r * .7, y - r * .4, r * .7, r * .6, .1, seed + 1),
    ell(x - r * .6, y + r * .1, r * .6, r * .5, .1, seed + 2))
  each(m, function(px, py)
    local c = STEAM.b
    if not mhas(m, px + 2, py) or not mhas(m, px, py + 2) then c = STEAM.s
    elseif not mhas(m, px - 2, py) or not mhas(m, px, py - 2) then c = STEAM.h end
    set(px, py, c)
  end)
  edge(m, STEAM.d)
end

---------------------------------------------------------------- 5 LIBRARY (far left)
do
  local wall, roof, trim, shut = RP("#6f88bf"), RP("#3f8379"), CREAM, RP("#e0a83e")
  local g = izba { x0 = 18, x1 = 76, yb = 134, wh = 34, rh = 30, t = .14, side = "L", wall = wall, roof = roof,
    trim = trim, shut = shut, seed = 11, gable = RP("#8aa0cc") }
  window(24, 109, 8, 10, shut)
  window(60, 109, 8, 10, shut)
  door(42, 116, 10, 18, RP("#7b4a3a"))
  -- BIG open book sign on the gable
  local cx = 47
  local covers = poly { { cx - 17, 84 }, { cx - 1, 88 }, { cx + 1, 88 }, { cx + 17, 84 }, { cx + 17, 101 }, { cx + 1, 104 }, { cx - 1, 104 }, { cx - 17, 101 } }
  lit(covers, RP("#c0463c"), { band = 1 })
  local pl = poly { { cx - 15, 83 }, { cx - 1, 87 }, { cx - 1, 101 }, { cx - 15, 99 } }
  local pr = poly { { cx + 1, 87 }, { cx + 15, 83 }, { cx + 15, 99 }, { cx + 1, 101 } }
  fill(pl, "#f7ecd2") fill(pr, "#e6d8bc") edge(pl, "#9a8270") edge(pr, "#8a7262")
  for ly = 89, 97, 3 do
    for lx = cx - 12, cx - 4 do if hash(lx, ly, 3) < .8 then set(lx, ly - floor((cx - lx) / 6), "#8c7d93") end end
    for lx = cx + 4, cx + 12 do if hash(lx, ly, 4) < .8 then set(lx, ly - floor((lx - cx) / 6), "#8c7d93") end end
  end
  for y = 87, 103 do set(cx, y, "#6e2f34") end
  -- ribbon bookmark hanging out of the book
  for y = 101, 108 do set(cx + 4, y, "#e0a83e") end set(cx + 3, 108, "#e0a83e") set(cx + 5, 108, "#e0a83e")
  -- QUIRK: book stack by the door with a birch-bark bookmark
  local cols = { "#c25a4a", "#4f7db0", "#e0b048", "#6a9a58", "#8c5aa0" }
  for k = 0, 4 do
    local bx0 = 55 + (k % 2) - 1
    local m = rect(bx0, 131 - k * 3, bx0 + 8 - (k % 3), 133 - k * 3)
    lit(m, RP(cols[k + 1]), { band = 0 })
  end
  for y = 112, 117 do set(62, y, BIRCH.b) end set(62, 114, BIRCH.mark)
end

---------------------------------------------------------------- 6 TEAHOUSE "The Samovar" (far left-mid)
do
  local wall, roof, trim, shut = RP("#d39a55"), RP("#b04a3c"), CREAM, RP("#c43c3c")
  izba { x0 = 112, x1 = 160, yb = 140, wh = 30, rh = 38, t = .18, side = "L", wall = wall, roof = roof,
    trim = trim, shut = shut, seed = 21, gable = RP("#e4b36a") }
  window(118, 118, 7, 9, RP("#3f8a6a"))
  door(132, 122, 9, 18, RP("#7d3a32"))
  -- hanging teacup sign on bracket
  for x = 136, 150 do set(x, 101, WOOD.d) end
  set(146, 102, INK) set(146, 103, INK)
  local cup = poly { { 141, 104 }, { 151, 104 }, { 150, 110 }, { 142, 110 } }
  lit(cup, RP("#f2ead8"), { band = 1 })
  local hdl = lineM({ { 151, 105 }, { 153, 106 }, { 152, 108 }, { 150, 108 } }, 1)
  fill(hdl, "#8a7c80")
  for x = 142, 150 do set(x, 106, "#c43c3c") end
  local sau = rect(139, 111, 153, 111) fill(sau, "#cfc2b4")
  set(144, 102, "#efe8e2") set(147, 100, "#efe8e2")

  -- table with lace cloth
  local tcx, ttop = 172, 136
  for _, lx in ipairs({ tcx - 14, tcx + 13 }) do
    local lg = rect(lx, ttop + 3, lx + 1, ttop + 10) fill(lg, WOOD.s) edge(lg, WOOD.d)
  end
  darken(poly { { tcx - 16, 145 }, { tcx + 18, 145 }, { tcx + 22, 149 }, { tcx - 10, 149 } }, SHADOWC, .35)
  local cloth = rect(tcx - 17, ttop, tcx + 17, ttop + 4)
  lit(cloth, CREAM, { band = 0 })
  for x = tcx - 17, tcx + 17 do if (x % 3) ~= 0 then set(x, ttop + 5, CREAM.h) end if x % 3 == 1 then set(x, ttop + 6, CREAM.s) end end
  -- big brass samovar (named: ribbon + tag)
  local BR = RP("#d9a43e", { s = .38 })
  local sc = tcx
  local prof = {}
  local yb0 = ttop - 1
  -- rows from bottom upward: {row offset, half width}
  local function hwAt(r) -- r = 0 at bottom
    if r <= 2 then return 9 end
    if r <= 5 then return 6 end
    if r <= 22 then return floor(10 + 2 * sin(math.pi * (r - 6) / 16)) end
    if r <= 24 then return 7 end
    if r <= 27 then return 5 + (r - 25) end
    return nil
  end
  local sm = newm()
  for r = 0, 27 do
    local hw = hwAt(r)
    for x = sc - hw, sc + hw do madd(sm, x, yb0 - r) end
  end
  each(sm, function(x, y)
    local r = yb0 - y
    local hw = hwAt(r)
    local u = (x - sc) / hw
    local c = BR.b
    if u < -.8 then c = BR.b elseif u < -.45 then c = BR.t elseif u < .25 then c = BR.h elseif u < .65 then c = BR.b else c = BR.s end
    if r == 6 or r == 22 or r == 13 then c = BR.d end
    if r == 14 and u < 0 then c = BR.t end
    set(x, y, c)
  end)
  edge(sm, BR.d)
  -- handles
  for _, d in ipairs({ -1, 1 }) do
    local hm = lineM({ { sc + d * 11, yb0 - 18 }, { sc + d * 15, yb0 - 17 }, { sc + d * 15, yb0 - 12 }, { sc + d * 12, yb0 - 11 } }, 2)
    fill(hm, "#5a3326")
    set(sc + d * 15, yb0 - 17, "#8a5a40")
  end
  -- tap
  local tp = rect(sc - 1, yb0 - 9, sc + 1, yb0 - 4) lit(tp, BR, { band = 0 })
  set(sc - 2, yb0 - 9, BR.d) set(sc + 2, yb0 - 9, BR.d) set(sc, yb0 - 10, "#5a3326")
  set(sc - 1, yb0 - 3, BR.d) set(sc + 1, yb0 - 3, BR.d)
  -- feet
  for _, fx in ipairs({ sc - 8, sc + 7 }) do local fm = rect(fx, yb0 + 1, fx + 1, yb0 + 1) fill(fm, BR.d) end
  -- teapot on the crown (painted porcelain)
  local tpm = union(ell(sc + .5, yb0 - 32, 6, 4.5), rect(sc - 2, yb0 - 38, sc + 2, yb0 - 36))
  lit(tpm, RP("#e9e1ee"), { band = 1 })
  set(sc - 2, yb0 - 32, "#c43c3c") set(sc + 2, yb0 - 31, "#3f6fb0") set(sc - 1, yb0 - 31, "#5a9a50")
  set(sc, yb0 - 39, "#c43c3c")
  local sp = lineM({ { sc + 6, yb0 - 31 }, { sc + 9, yb0 - 34 } }, 1) fill(sp, "#9e95a8")
  puff(sc + 12, yb0 - 40, 3, 5)
  puff(sc + 16, yb0 - 46, 2.5, 7)
  -- QUIRK: named samovar -> red ribbon bow + little name tag
  for x = sc - 7, sc + 7 do set(x, yb0 - 23, "#d23a3a") end
  local bow = union(poly { { sc - 9, yb0 - 26 }, { sc - 5, yb0 - 23 }, { sc - 9, yb0 - 20 } }, poly { { sc - 1, yb0 - 26 }, { sc - 5, yb0 - 23 }, { sc - 1, yb0 - 20 } })
  lit(bow, RP("#d23a3a"), { band = 0 })
  local tag = rect(sc - 9, yb0 - 18, sc - 4, yb0 - 14) lit(tag, CREAM, { band = 0 })
  set(sc - 7, yb0 - 16, "#8c5aa0") set(sc - 6, yb0 - 16, "#8c5aa0")
  set(sc - 5, yb0 - 19, "#d23a3a") set(sc - 6, yb0 - 20, "#d23a3a")
  -- cups and jam on the cloth
  for _, cxp in ipairs({ tcx - 14, tcx + 11 }) do
    local cm = rect(cxp, ttop - 3, cxp + 3, ttop - 1) lit(cm, RP("#f2ead8"), { band = 0 })
    set(cxp + 1, ttop - 3, "#a0482e") set(cxp + 2, ttop - 3, "#a0482e")
  end
  local jam = rect(tcx + 15, ttop - 5, tcx + 18, ttop - 1) lit(jam, RP("#c2303e"), { band = 0 })
  set(tcx + 15, ttop - 6, "#f2ead8") set(tcx + 16, ttop - 6, "#f2ead8") set(tcx + 17, ttop - 6, "#f2ead8") set(tcx + 18, ttop - 6, "#f2ead8")
  set(tcx + 16, ttop - 4, "#f07a8a")
end

---------------------------------------------------------------- 7 MUSHROOM WOOD (far right)
local function birchTrunk(x, w, ytop, ybot, seed)
  local m = newm()
  for y = ytop, ybot do
    local ww = w - floor((ybot - y) / 60)
    if ww < 2 then ww = 2 end
    for xx = x, x + ww - 1 do madd(m, xx, y) end
  end
  each(m, function(px, py)
    local c = BIRCH.b
    if not mhas(m, px - 1, py) then c = BIRCH.h end
    if not mhas(m, px + 1, py) or not mhas(m, px + 2, py) then c = BIRCH.s end
    -- black birch dashes
    local row = py // 3
    if hash(row, x, seed) < .32 and hash(px, row, seed) < .65 and py % 3 ~= 2 then c = BIRCH.mark end
    if py > ybot - 5 and hash(px, py, seed) < .5 then c = "#5a4a50" end
    set(px, py, c)
  end)
  edge(m, BIRCH.d)
  return m
end
local function foliage(clumps, seed, bias)
  local m = newm()
  local cl2 = {}
  for i2, c in ipairs(clumps) do
    local e = ell(c[1], c[2], c[3], c[4], .28, seed + i2)
    for k in pairs(e.s) do m.s[k] = true end
  end
  -- weeping strands
  for x = 0, W - 1 do
    local lowest = nil
    for _, c in ipairs(clumps) do
      if abs(x - c[1]) < c[3] * .85 then
        local by = c[2] + c[4] * sqrt(1 - ((x - c[1]) / c[3]) ^ 2) * .9
        if not lowest or by > lowest then lowest = by end
      end
    end
    if lowest and hash(x, 7, seed) < .45 then
      local len = 3 + floor(hash(x, 9, seed) * (bias or 10))
      for y = floor(lowest), floor(lowest) + len do madd(m, x, y) end
    end
  end
  each(m, function(x, y)
    local c = LEAF.b
    local lt = 0
    for _, cc in ipairs(clumps) do
      local d = ((x - cc[1]) / cc[3]) ^ 2 + ((y - cc[2]) / cc[4]) ^ 2
      if d < 1.2 then
        local v = -((x - cc[1]) / cc[3] + (y - cc[2]) / cc[4])
        if v > lt then lt = v end
      end
    end
    local h = hash(x // 2, y // 2, seed + 40)
    if lt > .9 then c = LEAF.t elseif lt > .45 then c = LEAF.h elseif lt > -.1 then c = LEAF.b else c = LEAF.s end
    if h < .15 then c = (c == LEAF.t) and LEAF.h or ((c == LEAF.h) and LEAF.b or LEAF.s) end
    if h > .9 and c ~= LEAF.t then c = LEAF.h end
    if not mhas(m, x + 1, y) or not mhas(m, x, y + 1) then c = LEAF.s end
    if not mhas(m, x, y + 1) and not mhas(m, x, y - 1) then c = LEAF.b end
    set(x, y, c)
  end)
  edge(m, LEAF.d)
  return m
end
local function mushroom(cx, by, w, cap)
  local stem = rect(cx - floor(w / 4), by - floor(w * .6), cx + floor(w / 4), by)
  lit(stem, RP("#efe0c0"), { band = 0 })
  local cm = poly { { cx - w / 2 - 1, by - w * .55 }, { cx - w / 3, by - w * .95 }, { cx + w / 3, by - w * .95 }, { cx + w / 2 + 1, by - w * .55 } }
  lit(cm, RP(cap), { band = 1 })
  set(cx - w / 4, by - w * .85, mix(cap, "#fff4d0", .6))
end
local function basket(x0, y0, w, h, covered, seed)
  local body = poly { { x0, y0 }, { x0 + w, y0 }, { x0 + w - 2, y0 + h }, { x0 + 2, y0 + h } }
  local WK = RP("#c08a48")
  each(body, function(x, y)
    local c = ((x + (y // 2) % 2) % 2 == 0) and WK.b or WK.h
    if (y - y0) % 3 == 2 then c = WK.s end
    if x > x0 + w - 4 then c = (c == WK.h) and WK.b or WK.s end
    set(x, y, c)
  end)
  edge(body, WK.d)
  local hd = lineM({ { x0 + 2, y0 }, { x0 + 3, y0 - 6 }, { x0 + w / 2, y0 - 8 }, { x0 + w - 3, y0 - 6 }, { x0 + w - 2, y0 } }, 1)
  fill(hd, WK.d)
  if covered then
    local cl3 = poly { { x0 - 1, y0 + 1 }, { x0 + 2, y0 - 4 }, { x0 + w - 2, y0 - 4 }, { x0 + w + 1, y0 + 1 } }
    fill(cl3, function(x, y) return (((x // 2) + (y // 2)) % 2 == 0) and "#d8424a" or "#f2e6d4" end)
    edge(cl3, "#7a2a36")
  else
    for k = 0, 3 do
      local mx = x0 + 3 + k * floor((w - 6) / 3)
      local cm = rect(mx - 2, y0 - 3 - (k % 2), mx + 2, y0 - 1)
      lit(cm, RP((k % 2 == 0) and "#8a4f2a" or "#c06a2e"), { band = 0 })
    end
  end
  darken(rect(x0 + 3, y0 + h + 1, x0 + w + 3, y0 + h + 2), SHADOWC, .3)
end
do
  -- ground shadow strip for the wood
  darken(poly { { 296, 134 }, { 380, 134 }, { 388, 143 }, { 304, 143 } }, SHADOWC, .25)
  foliage({ { 306, 50, 15, 13 }, { 330, 38, 18, 14 }, { 354, 50, 17, 13 }, { 372, 62, 10, 12 }, { 318, 66, 12, 10 }, { 344, 70, 13, 10 }, { 300, 74, 9, 9 } }, 50, 14)
  birchTrunk(302, 5, 58, 138, 1)
  birchTrunk(317, 4, 72, 136, 2)
  birchTrunk(332, 6, 46, 140, 3)
  birchTrunk(350, 4, 62, 135, 4)
  birchTrunk(366, 5, 56, 139, 5)
  -- drying string of mushrooms
  local function sy(x) return 98 + floor(5 * (1 - ((x - 335) / 17) ^ 2)) end
  for x = 320, 349 do set(x, sy(x), "#6a4a3a") end
  for x = 322, 347, 4 do
    local y = sy(x) + 1
    set(x, y, "#e8d6b0") set(x - 1, y + 1, "#8a5a32") set(x, y + 1, "#a86e3a") set(x + 1, y + 1, "#8a5a32") set(x, y + 2, "#d8c4a0")
  end
  -- QUIRK: grandmother's secret birch, tied with a red ribbon
  for x = 332, 337 do set(x, 112, "#d23a3a") set(x, 113, "#a82a36") end
  set(338, 114, "#d23a3a") set(339, 116, "#d23a3a") set(338, 115, "#a82a36")
  -- undergrowth / ferns
  local ug = newm()
  for x = 294, 380 do
    local top = 124 + floor(4 * sin(x / 5) + 3 * hash(x, 1, 60))
    for y = top, 141 do if y > 128 or hash(x, y, 61) < .7 then madd(ug, x, y) end end
  end
  each(ug, function(x, y)
    local c = (hash(x // 2, y, 62) < .4) and "#5f8a44" or "#79a24c"
    if (x + y) % 5 == 0 then c = "#a4be5a" end
    if y > 137 then c = "#4e7440" end
    set(x, y, c)
  end)
  edge(ug, "#38563a")
  -- mushrooms in the grass
  mushroom(298, 140, 7, "#9a5a2c")
  mushroom(311, 141, 9, "#8a4a26")
  mushroom(344, 140, 7, "#d0682e")
  mushroom(375, 141, 8, "#9a5a2c")
  basket(318, 130, 16, 10, false, 1)
  basket(354, 131, 14, 9, true, 2)
end

---------------------------------------------------------------- 8 WILD TRAIL (right edge)
do
  -- path leaving the picture
  local path = poly { { 262, 151 }, { 300, 146 }, { 400, 141 }, { 470, 136 }, { 470, 148 }, { 400, 153 }, { 300, 157 }, { 268, 159 } }
  each(path, function(x, y)
    local c = (hash(x // 2, y, 70) < .2) and "#a98458" or "#c7a06a"
    if hash(x, y, 71) < .06 then c = "#e0c08a" end
    set(x, y, c)
  end)
  edge(path, "#8f6e4a")
  -- tall grass tufts along the path
  for x = 300, 460, 9 do
    local y = 141 - floor((x - 300) / 32)
    for k = 0, 3 do set(x + k, y - k % 2 - 1, "#8a9a50") set(x + k, y - 2 - (k % 3), "#a8b060") end
  end
  -- the arch: two birch-log posts, carved crossbeam, little shingle roof
  darken(poly { { 412, 150 }, { 456, 148 }, { 462, 152 }, { 418, 154 } }, SHADOWC, .3)
  birchTrunk(410, 6, 86, 151, 8)
  birchTrunk(446, 6, 86, 149, 9)
  local beam = rect(402, 84, 460, 90)
  each(beam, function(x, y) set(x, y, logC(RP("#a8774d"), y - 84, x, 3)) end)
  lit(beam, RP("#a8774d"), { band = 1, noedge = false, tex = 4 })
  for x = 404, 458, 6 do set(x, 87, "#3f6fb0") set(x + 1, 86, "#3f6fb0") set(x + 1, 88, "#3f6fb0") set(x + 2, 87, "#3f6fb0") end
  local rf = poly { { 398, 84 }, { 431, 70 }, { 464, 84 } }
  each(rf, function(x, y) set(x, y, shingleC(RP("#4f8f6a"), x, y, 9, true)) end)
  edge(rf, "#2f5446")
  local pend = poly { { 429, 71 }, { 433, 71 }, { 433, 78 }, { 431, 81 }, { 429, 78 } }
  lit(pend, CREAM, { band = 0 })
  -- carved valance drops under the beam
  for x = 404, 458, 5 do set(x, 91, "#7a4e30") set(x + 1, 91, "#7a4e30") set(x + 1, 92, "#7a4e30") end
  -- woven garland hanging in the arch
  for x = 416, 446 do
    local y = 92 + floor(6 * (1 - ((x - 431) / 15) ^ 2))
    set(x, y, "#6a8a3a")
    if x % 3 == 0 then set(x, y + 1, "#e9c94a") set(x - 1, y + 1, "#8eae4a") end
    if x % 5 == 0 then set(x, y - 1, "#c43c3c") end
  end
  -- signpost with arrow boards (painted icons, no text)
  darken(rect(392, 151, 400, 153), SHADOWC, .3)
  local post = rect(392, 100, 395, 152) lit(post, WOOD, { band = 1 })
  local a1 = poly { { 381, 104 }, { 403, 104 }, { 408, 108 }, { 403, 112 }, { 381, 112 } }
  lit(a1, RP("#4f7db0"), { band = 1 })
  local mt = poly { { 386, 110 }, { 390, 105 }, { 394, 110 } } fill(mt, "#efe8e2") set(390, 106, "#c4cad8")
  local a2 = poly { { 384, 117 }, { 404, 117 }, { 409, 121 }, { 404, 125 }, { 384, 125 } }
  lit(a2, RP("#6a9a58"), { band = 1 })
  local mu = poly { { 389, 120 }, { 391, 118 }, { 395, 118 }, { 397, 120 } } fill(mu, "#c4482e")
  set(392, 121, "#efe0c0") set(393, 121, "#efe0c0") set(392, 122, "#efe0c0") set(393, 122, "#efe0c0")
  local cap = poly { { 390, 100 }, { 394, 96 }, { 397, 100 } } lit(cap, RP("#c43c3c"), { band = 0 })
  -- QUIRK: one more mushroom, very large, guarding the trail
  mushroom(458, 146, 10, "#c4682e")
end

---------------------------------------------------------------- 9 THE BIRCH GREEN (centre, biggest)
do
  local LAWN = RP("#7fae54")
  darken(poly { { 220, 150 }, { 266, 150 }, { 296, 206 }, { 194, 206 } }, SHADOWC, .3)
  local lawn = poly { { 216, 148 }, { 264, 148 }, { 290, 202 }, { 190, 202 } }
  each(lawn, function(x, y)
    local sc = 1 + floor((y - 148) / 18)
    local h = hash(x, floor(y / sc), 80)
    local c = LAWN.b
    if h < .2 then c = LAWN.s elseif h < .32 then c = LAWN.h elseif h > .97 then c = "#f3ead6" elseif h > .955 then c = "#7a8fd8" end
    set(x, y, c)
  end)
  edge(lawn, LAWN.d)
  -- tree shadow on the lawn (to the lower right)
  darken(poly { { 238, 170 }, { 262, 168 }, { 282, 178 }, { 252, 182 } }, SHADOWC, .3)
  -- log bench
  local bs = rect(203, 168, 223, 171) lit(bs, RP("#b98552"), { band = 1 })
  for _, lx in ipairs({ 205, 220 }) do local lg = rect(lx, 172, lx + 1, 176) fill(lg, WOOD.s) edge(lg, WOOD.d) end
  darken(rect(206, 177, 226, 178), SHADOWC, .3)
  -- trunk + branches
  local br = union(lineM({ { 240, 128 }, { 224, 108 }, { 212, 92 } }, 3), lineM({ { 241, 112 }, { 256, 96 }, { 268, 82 } }, 3),
    lineM({ { 240, 96 }, { 230, 80 }, { 222, 66 } }, 2), lineM({ { 242, 132 }, { 258, 124 }, { 270, 120 } }, 3),
    lineM({ { 241, 84 }, { 248, 66 }, { 252, 50 } }, 2))
  fill(br, function(x, y) return (hash(x // 2, y // 3, 81) < .3) and BIRCH.mark or BIRCH.s end)
  edge(br, BIRCH.d)
  -- canopy
  foliage({ { 214, 86, 19, 15 }, { 240, 60, 24, 17 }, { 266, 76, 21, 15 }, { 225, 108, 15, 10 }, { 262, 102, 16, 11 },
    { 240, 86, 16, 12 }, { 208, 62, 12, 10 }, { 274, 52, 12, 9 }, { 246, 42, 14, 9 } }, 90, 14)
  birchTrunk(236, 10, 62, 180, 12)
  -- QUIRK: birdhouse shaped like a tiny izba on the trunk
  local bh = rect(235, 99, 245, 109) lit(bh, RP("#d39a55"), { band = 1 })
  local bhr = poly { { 232, 100 }, { 240, 92 }, { 248, 100 } } lit(bhr, RP("#b04a3c"), { band = 1 })
  local hole = rect(239, 102, 241, 105) fill(hole, "#3a2830")
  set(240, 107, WOOD.d) set(241, 107, WOOD.d)
  -- QUIRK: rope swing from the low branch
  for y = 121, 160 do set(260, y, "#e0c890") set(268, y + (y > 150 and 0 or 0), "#d0b47a") end
  local seat = rect(257, 160, 271, 162) lit(seat, RP("#c04a3c"), { band = 0 })
  -- woven wattle fence along the front of the green
  for x = 190, 290 do
    for y = 199, 203 do
      local c = (((x // 4) + (y > 201 and 1 or 0)) % 2 == 0) and "#b0884e" or "#8a6438"
      if y == 199 then c = "#d0a866" end
      if y == 203 then c = "#5a3e2a" end
      set(x, y, c)
    end
  end
  for x = 190, 290, 10 do
    local p = rect(x, 195, x + 1, 205) fill(p, "#7a5232") edge(p, "#4a3024") set(x, 195, "#c49a5a")
  end
  -- chamomile clumps at the lawn corners
  for _, p in ipairs({ { 196, 196 }, { 284, 196 }, { 222, 192 }, { 262, 194 } }) do
    for k = 0, 4 do
      local fx, fy = p[1] + k * 2 - 4, p[2] - (k % 2) * 2
      set(fx, fy, "#f6efe0") set(fx, fy + 1, "#e9c94a") set(fx, fy + 2, "#5d7f46")
    end
  end
end

---------------------------------------------------------------- 10 BANYA (near left)
do
  local wall, roof, trim = RP("#8a5236"), RP("#8c8070"), RP("#d8c29a")
  -- chimney first-half (behind roof plane? chimney sits on right slope: draw after)
  izba { x0 = 14, x1 = 92, yb = 238, wh = 42, rh = 34, t = .1, side = "L", wall = wall, roof = roof, trim = trim,
    seed = 31, moss = true, gable = RP("#9a6a48") }
  -- chimney on the right slope
  local ch = rect(72, 156, 80, 182)
  each(ch, function(x, y)
    local c = (((y // 3) + ((x // 4) % 2)) % 2 == 0) and "#9c8f9a" or "#b2a6ae"
    if (y % 3 == 0) then c = "#6f6478" end
    if x >= 79 then c = "#6f6478" end
    set(x, y, c)
  end)
  edge(ch, "#4a3f52")
  local cc = rect(70, 154, 82, 156) lit(cc, RP("#8a7f8e"), { band = 0 })
  -- big steam puffs drifting up-right
  puff(80, 148, 6, 1)
  puff(92, 142, 7, 4)
  puff(106, 140, 5, 7)
  -- small steamy window
  window(24, 207, 7, 6, RP("#4f7aa0"), trim)
  puff(34, 202, 3, 9)
  -- low door
  door(44, 212, 12, 26, RP("#6a3a28"))
  -- SIGN: big leafy birch broom (venik) on a peg
  local hdl = rect(70, 202, 72, 210) fill(hdl, "#c08a48") edge(hdl, "#6a4a2a")
  for x = 69, 73 do set(x, 211, "#c43c3c") end
  local vm = poly { { 68, 212 }, { 74, 212 }, { 80, 228 }, { 71, 232 }, { 62, 228 } }
  each(vm, function(x, y)
    local h = hash(x // 2, y // 2, 33)
    local c = LEAF.b
    if h < .3 then c = LEAF.s elseif h > .75 then c = LEAF.h end
    if x - 71 > (y - 212) * .4 then c = (c == LEAF.h) and LEAF.b or LEAF.s end
    set(x, y, c)
  end)
  edge(vm, LEAF.d)
  for y = 214, 228, 4 do set(71, y, "#6a4a2a") set(70, y + 1, "#6a4a2a") end
  -- QUIRK: pointy felt banya hat on a peg
  set(36, 213, "#5a3a2a") set(37, 213, "#5a3a2a")
  local hat = poly { { 31, 224 }, { 36, 213 }, { 42, 224 } }
  lit(hat, RP("#e8dcc2"), { band = 1 })
  for x = 30, 43 do set(x, 224, "#c8b48e") set(x, 225, "#8a7458") end
  -- wooden tub with hoops + ladle
  darken(poly { { 76, 238 }, { 104, 238 }, { 108, 242 }, { 80, 242 } }, SHADOWC, .3)
  local tub = poly { { 78, 226 }, { 100, 226 }, { 98, 240 }, { 80, 240 } }
  each(tub, function(x, y)
    local c = ((x % 4) == 0) and "#8a5a32" or "#b07a44"
    if x > 94 then c = "#8a5a32" end
    if y == 229 or y == 236 then c = "#5d6a80" end
    set(x, y, c)
  end)
  edge(tub, "#4a2e22")
  for x = 80, 98 do set(x, 226, "#6a8ac0") end
  local lad = lineM({ { 92, 227 }, { 104, 214 } }, 1) fill(lad, "#7a4e30")
  local lb = rect(90, 225, 94, 227) fill(lb, "#a86e3a") edge(lb, "#5a3a2a")
  -- firewood stack (log ends)
  local fwm = rect(16, 228, 40, 238)
  darken(rect(18, 238, 44, 241), SHADOWC, .3)
  for yy = 228, 236, 4 do
    for xx = 16 + ((yy // 4) % 2) * 2, 36, 5 do
      local lg = rect(xx, yy, xx + 4, yy + 3)
      fill(lg, "#d8b07a") edge(lg, "#7a4e30") set(xx + 2, yy + 1, "#b58050") set(xx + 1, yy + 1, "#e8c890")
    end
  end
  -- steam curling from the door crack
  puff(60, 210, 2.5, 12)
end

---------------------------------------------------------------- 11 NOTICE BOARD (near left-centre)
do
  local BW = RP("#8e7a62")
  darken(poly { { 122, 238 }, { 162, 238 }, { 170, 243 }, { 128, 243 } }, SHADOWC, .35)
  for _, px in ipairs({ 124, 155 }) do
    local p = rect(px, 158, px + 3, 238)
    each(p, function(x, y) set(x, y, (x == px) and BW.h or ((x == px + 3) and BW.s or BW.b)) end)
    edge(p, BW.d)
  end
  local panel = rect(120, 166, 162, 216)
  lit(panel, BW, { band = 1 })
  local inner = rect(123, 169, 159, 213)
  fill(inner, function(x, y) return (hash(x // 3, y // 2, 40) < .3) and "#d0b088" or "#c4a47c" end)
  edge(inner, "#7a5e44")
  local papers = {
    { 125, 171, 136, 183, "#f4ecd8", "#d23a3a" }, { 139, 170, 151, 179, "#f2c6c8", "#3f6fb0" },
    { 153, 172, 158, 187, "#c8d8f0", "#e0a83e" }, { 126, 187, 135, 197, "#cfe8c8", "#3f6fb0" },
    { 138, 182, 150, 196, "#f6e6b0", "#d23a3a" }, { 140, 199, 157, 211, "#ddd0ee", "#6a9a58" },
    { 125, 200, 136, 211, "#f4ecd8", "#e0a83e" } }
  for n, p in ipairs(papers) do
    local m = rect(p[1], p[2], p[3], p[4])
    local rp = RP(p[5], { d = .45 })
    lit(m, rp, { band = 0 })
    for y = p[2] + 3, p[4] - 2, 2 do
      for x = p[1] + 2, p[3] - 2 do if hash(x // 2, y, n) < .7 then set(x, y, rp.s) end end
    end
    set(p[3], p[4], rp.t) set(p[3] - 1, p[4], rp.t) set(p[3], p[4] - 1, rp.t) -- curled corner
    local pcx = floor((p[1] + p[3]) / 2)
    set(pcx, p[2], p[6]) set(pcx + 1, p[2], p[6]) set(pcx, p[2] + 1, mix(p[6], INK, .4)) set(pcx + 1, p[2] + 1, p[6])
  end
  -- little drawing on one note: a sprout
  set(130, 194, "#5d7f46") set(130, 193, "#5d7f46") set(129, 192, "#8eae4a") set(131, 192, "#8eae4a")
  -- roof
  local rf = poly { { 114, 167 }, { 141, 150 }, { 168, 167 } }
  each(rf, function(x, y) set(x, y, shingleC(RP("#3f8f8a"), x, y, 41)) end)
  edge(rf, "#24504e")
  for x = 114, 168 do if x % 4 ~= 0 then set(x, 168, "#c8b48e") end end
  -- QUIRK: a tiny named samovar on the roof ridge (with its own ribbon)
  local ms = union(rect(138, 143, 144, 149), rect(139, 141, 143, 142), rect(137, 150, 145, 150))
  lit(ms, RP("#d9a43e"), { band = 1 })
  set(140, 145, "#fff0c0") set(144, 146, "#d23a3a") set(145, 147, "#d23a3a") set(146, 148, "#f4ecd8")
  set(141, 140, "#8a7f8e")
  -- shelf with a jar of pins
  local sh = rect(120, 218, 162, 220) lit(sh, BW, { band = 0 })
  local jar = rect(150, 212, 155, 217) lit(jar, RP("#b8d8d8"), { band = 0 })
  set(151, 213, "#d23a3a") set(153, 214, "#3f6fb0") set(152, 215, "#e0a83e")
end

---------------------------------------------------------------- 12 SHOPS (near right): seed shop + honey/veg stall
local function stall(x0, x1, ytop, ybot, aw1, aw2, seed)
  darken(poly { { x0 + 2, ybot - 1 }, { x1 + 2, ybot - 1 }, { x1 + 10, ybot + 4 }, { x0 + 8, ybot + 4 } }, SHADOWC, .35)
  for _, px in ipairs({ x0 + 2, x1 - 4 }) do
    local p = rect(px, ytop + 8, px + 2, ybot)
    each(p, function(x, y) set(x, y, (x == px) and WOOD.h or WOOD.b) end)
    edge(p, WOOD.d)
  end
  -- back shelf
  local shelf = rect(x0 + 5, ytop + 30, x1 - 7, ytop + 33) lit(shelf, WOOD, { band = 0 })
  -- awning
  local aw = poly { { x0 + 4, ytop }, { x1 - 4, ytop }, { x1 + 3, ytop + 14 }, { x0 - 3, ytop + 14 } }
  each(aw, function(x, y)
    local c = ((x - x0 + 60) // 6 % 2 == 0) and aw1.b or aw2.b
    if y <= ytop + 2 then c = ((x - x0 + 60) // 6 % 2 == 0) and aw1.h or aw2.h end
    if y >= ytop + 12 then c = ((x - x0 + 60) // 6 % 2 == 0) and aw1.s or aw2.s end
    set(x, y, c)
  end)
  edge(aw, aw1.d)
  for x = x0 - 3, x1 + 3 do
    local k = (x - x0 + 60) // 6
    local d = 3 - abs(((x - x0 + 60) % 6) - 2.5)
    for y = ytop + 15, ytop + 15 + floor(d) do set(x, y, (k % 2 == 0) and aw1.b or aw2.b) end
    set(x, ytop + 16 + floor(d), aw1.d)
  end
  -- counter
  local ct = rect(x0, ybot - 26, x1, ybot)
  each(ct, function(x, y)
    local c = ((y - (ybot - 26)) % 5 == 0) and WOOD.d or (((y - (ybot - 26)) % 5 == 1) and WOOD.h or WOOD.b)
    if x > x1 - 3 then c = WOOD.s end
    if hash(x // 4, y // 5, seed) < .15 and c == WOOD.b then c = WOOD.s end
    set(x, y, c)
  end)
  edge(ct, WOOD.d)
  local top = rect(x0 - 2, ybot - 28, x1 + 2, ybot - 26) lit(top, RP("#c79a64"), { band = 0 })
end
do
  -- QUIRK: the over-tall sunflower (short hot summers, everything races up)
  local stem = lineM({ { 390, 226 }, { 391, 190 }, { 389, 168 } }, 2) fill(stem, "#5d7f46") edge(stem, "#3d573a")
  local lf = poly { { 391, 196 }, { 400, 190 }, { 396, 198 } } lit(lf, RP("#7fae54"), { band = 0 })
  local lf2 = poly { { 390, 184 }, { 381, 179 }, { 385, 187 } } lit(lf2, RP("#7fae54"), { band = 0 })
  stall(324, 384, 160, 226, RP("#5f9a4a"), RP("#efe2c4"), 1)
  stall(398, 454, 164, 226, RP("#c4483c"), RP("#efe2c4"), 2)
  -- sunflower head on top (petal ring, chunky)
  local sfp = poly { { 380, 164 }, { 384, 158 }, { 389, 155 }, { 394, 156 }, { 398, 160 }, { 400, 165 }, { 397, 171 }, { 391, 174 }, { 385, 173 }, { 381, 169 } }
  lit(sfp, RP("#f2c23a"), { band = 1 })
  for _, p in ipairs({ { 378, 166 }, { 389, 153 }, { 401, 163 }, { 392, 176 }, { 382, 158 }, { 398, 172 } }) do set(p[1], p[2], "#f2c23a") set(p[1] + 1, p[2], "#d8a02a") end
  local ctr = poly { { 385, 162 }, { 389, 159 }, { 394, 160 }, { 395, 166 }, { 391, 169 }, { 386, 167 } }
  fill(ctr, function(x, y) return ((x + y) % 2 == 0) and "#6a3e22" or "#8a5a2e" end) edge(ctr, "#4a2a1a")

  -- seed shop goods: shelf of seed packets
  local pk = { "#e0a83e", "#c4483c", "#7a8fd8", "#6a9a58", "#d77b8a", "#e9c94a", "#8c5aa0" }
  for k = 0, 6 do
    local px = 330 + k * 7
    local m = rect(px, 182, px + 5, 189) lit(m, RP(pk[k + 1]), { band = 0 })
    set(px + 2, 186, "#f4ecd8") set(px + 3, 185, "#5d7f46") set(px + 2, 184, "#5d7f46")
  end
  -- seedling pots on shelf
  for _, px in ipairs({ 380 - 3 }) do
    local pot = rect(px - 2, 185, px + 2, 189) lit(pot, RP("#c86a3e"), { band = 0 })
    set(px, 184, "#5d7f46") set(px - 1, 182, "#8eae4a") set(px + 1, 182, "#8eae4a") set(px, 183, "#5d7f46")
  end
  -- SIGN: hanging board with a sprouting seed
  for y = 176, 180 do set(348, y, "#6a4a3a") set(360, y, "#6a4a3a") end
  local sb = rect(344, 180, 364, 195) lit(sb, RP("#f0dcae"), { band = 1 })
  local seedm = poly { { 350, 192 }, { 354, 186 }, { 358, 192 }, { 354, 194 } } lit(seedm, RP("#a86e3a"), { band = 0 })
  set(354, 185, "#5d7f46") set(354, 184, "#5d7f46") set(354, 183, "#5d7f46")
  local l1 = poly { { 354, 184 }, { 348, 181 }, { 351, 185 } } fill(l1, "#7fae54")
  local l2 = poly { { 354, 184 }, { 360, 181 }, { 357, 185 } } fill(l2, "#5d9a44")
  -- seed sacks in front of the counter
  local sacks = { { 328, "#5a4038", "stripe" }, { 345, "#a8483a", "bean" }, { 362, "#e0b048", "grain" } }
  for _, s in ipairs(sacks) do
    local x0 = s[1]
    local sk = poly { { x0, 210 }, { x0 + 14, 210 }, { x0 + 15, 226 }, { x0 - 1, 226 } }
    lit(sk, RP("#cdb48a"), { band = 2, tex = 7 })
    local fold = rect(x0 - 1, 208, x0 + 15, 211) lit(fold, RP("#dcc49a"), { band = 0 })
    local heap = poly { { x0 + 1, 208 }, { x0 + 4, 203 }, { x0 + 10, 202 }, { x0 + 14, 208 } }
    fill(heap, function(x, y)
      if s[3] == "stripe" then return ((x + y) % 3 == 0) and "#efe2c4" or s[2] end
      if s[3] == "bean" then return (hash(x, y, 5) < .3) and "#f0c0a0" or s[2] end
      return (hash(x, y, 6) < .3) and "#f4d880" or s[2]
    end)
    edge(heap, mix(s[2], INK, .4))
    local scoop = rect(x0 + 9, 203, x0 + 12, 205) fill(scoop, "#b9bdc8") edge(scoop, "#6a6a7a")
  end
  -- honey / jam / cabbage stall goods
  local hj = { "#e0a030", "#c2303e", "#e0a030", "#8c2a4a", "#e0a030" }
  for k = 0, 4 do
    local px = 403 + k * 9
    local m = rect(px, 189, px + 5, 195) lit(m, RP(hj[k + 1]), { band = 0 })
    for x = px, px + 5 do set(x, 188, "#f2e6d4") end
    set(px + 1, 190, "#fff0c0")
  end
  for k = 0, 2 do
    local cx = 409 + k * 15
    local cab = poly { { cx - 6, 208 }, { cx - 4, 203 }, { cx, 201 }, { cx + 4, 203 }, { cx + 6, 208 }, { cx, 210 } }
    lit(cab, RP("#8ec06a"), { band = 1 })
    set(cx, 203, "#c4e08a") set(cx - 2, 205, "#5d7f46") set(cx + 2, 205, "#5d7f46")
  end
  -- stall B sign: hanging board with a honey jar icon
  for y = 180, 183 do set(420, y, "#6a4a3a") set(432, y, "#6a4a3a") end
  local sb2 = rect(417, 183, 435, 196) lit(sb2, RP("#f0dcae"), { band = 1 })
  local jj = rect(423, 187, 429, 194) lit(jj, RP("#e0a030"), { band = 0 })
  for x = 422, 430 do set(x, 186, "#c4483c") end
end

---------------------------------------------------------------- 13 GATE FRAME (carved timber, folk paint)
do
  local GT = RP("#9a6a44")
  local blue, red, ochre = "#3f62a8", "#c43c3c", "#e0a83e"
  local function timberV(x0, x1)
    local m = rect(x0, 0, x1, H - 1)
    each(m, function(x, y)
      local c = GT.b
      if x == x0 then c = GT.h elseif x >= x1 - 1 then c = GT.s end
      if c == GT.b and hash(x, y // 6, 91) < .25 then c = GT.s end
      if c == GT.b and hash(x, y // 9, 92) < .12 then c = GT.h end
      set(x, y, c)
    end)
    edge(m, GT.d)
    for by = 52, 240, 60 do
      for y = by, by + 9 do for x = x0 + 1, x1 - 1 do set(x, y, (y == by or y == by + 9) and GT.d or blue) end end
      local mx = floor((x0 + x1) / 2)
      for d = 0, 3 do
        set(mx - d, by + 1 + d, red) set(mx + d, by + 1 + d, red) set(mx - d, by + 8 - d, red) set(mx + d, by + 8 - d, red)
      end
      set(mx, by + 4, ochre) set(mx, by + 5, ochre)
    end
    -- stone plinth
    local pl = rect(x0 - 1, 252, x1 + 1, H - 1)
    fill(pl, function(x, y) return ((y - 252) % 6 == 0 or (x + ((y - 252) // 6) * 4) % 9 == 0) and "#6f6478" or "#9c8f9a" end)
    edge(pl, "#4a3f52")
  end
  timberV(0, 13)
  timberV(466, 479)
  -- top beam
  local bm = rect(0, 0, W - 1, 11)
  each(bm, function(x, y)
    local c = GT.b
    if y <= 1 then c = GT.h elseif y >= 9 then c = GT.s end
    if c == GT.b and hash(x // 7, y, 93) < .2 then c = GT.s end
    set(x, y, c)
  end)
  edge(bm, GT.d)
  for x = 20, 460, 12 do
    set(x, 5, red) set(x + 1, 4, red) set(x + 1, 6, red) set(x + 2, 5, red) set(x + 1, 5, ochre)
    set(x + 6, 5, blue) set(x + 7, 5, blue)
  end
  -- central carved rhombus emblem
  local em = poly { { 240, 1 }, { 252, 8 }, { 240, 15 }, { 228, 8 } } lit(em, RP("#3f62a8"), { band = 1 })
  local em2 = poly { { 240, 4 }, { 246, 8 }, { 240, 12 }, { 234, 8 } } lit(em2, RP("#e0a83e"), { band = 0 })
  -- lace valance under the beam
  for x = 14, 465, 8 do
    if x < 226 or x > 254 then
      local dm = poly { { x, 11 }, { x + 8, 11 }, { x + 4, 18 } }
      lit(dm, GT, { band = 0 })
      set(x + 4, 13, "#f2c46a")
    end
  end
  -- corner braces with fretwork
  for _, side in ipairs({ 1, -1 }) do
    local bx = (side == 1) and 13 or 466
    local br = poly { { bx, 11 }, { bx + side * 30, 11 }, { bx, 41 } }
    local hole = poly { { bx + side * 4, 15 }, { bx + side * 18, 15 }, { bx + side * 4, 29 } }
    cut(br, hole)
    lit(br, GT, { band = 1 })
    set(bx + side * 6, 17, red) set(bx + side * 7, 17, red)
  end
end

---------------------------------------------------------------- 14 BUNTING + LANTERNS
do
  local fc = { "#d23a3a", "#f2e6d4", "#3f6fb0", "#e9c94a", "#5f9a4a" }
  local function by(x) return 22 + floor(18 * (1 - ((x - 240) / 226) ^ 2)) end
  for x = 14, 466 do set(x, by(x), "#5a3a2a") end
  local k = 0
  for x = 18, 456, 13 do
    k = k + 1
    local y0 = by(x + 4)
    local f = poly { { x, by(x) + 1 }, { x + 9, by(x + 9) + 1 }, { x + 4.5, y0 + 10 } }
    local rp = RP(fc[(k % #fc) + 1])
    lit(f, rp, { band = 1 })
  end
  for _, lx in ipairs({ 52, 428 }) do
    glow(lx, 34, 22, 20, WARM)
    for y = 12, 21 do set(lx, y, (y % 2 == 0) and "#4a3a46" or "#6f6478") end
    local capm = poly { { lx - 6, 26 }, { lx - 2, 22 }, { lx + 2, 22 }, { lx + 6, 26 } } lit(capm, RP("#5a6a5a"), { band = 0 })
    local body = rect(lx - 5, 27, lx + 5, 39)
    fill(body, "#ffd35c") edge(body, "#3f3a3a")
    for y = 28, 38 do set(lx - 2, y, "#6a5a4a") set(lx + 2, y, "#6a5a4a") end
    set(lx, 31, "#fff4c0") set(lx, 32, "#fff4c0") set(lx, 33, "#ffb040") set(lx - 1, 33, "#ffe080") set(lx + 1, 33, "#ffe080")
    set(lx - 4, 28, "#fff4c0")
    local bot = poly { { lx - 6, 40 }, { lx + 6, 40 }, { lx + 2, 43 }, { lx - 2, 43 } } lit(bot, RP("#5a6a5a"), { band = 0 })
    set(lx, 44, "#3f3a3a") set(lx, 45, "#e9c94a")
  end
end

---------------------------------------------------------------- output
local c = HP.canvas { w = W, h = H, scale = 1, name = NAME }
for y = 0, H - 1 do for x = 0, W - 1 do c:px(x, y, buf[y * W + x] or "#808080") end end
c:finish { outline = false }
HP.assertClean(c)
c:save { aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }
print("saved " .. OUT .. NAME)
