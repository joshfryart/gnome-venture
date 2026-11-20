-- shared kit (globals) for tool_shed + compost_bin state sprites. Needs global c (current canvas).
HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
P = HP.P
floor = math.floor
function newc(w, h, name) c = HP.canvas{ w = w, h = h, scale = 1, name = name } return c end
function px(x, y, hex) c:px(x, y, hex) end
function E(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
function R(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
local function hexrgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
function lerp(a, b, t)
  local r1, g1, b1 = hexrgb(a); local r2, g2, b2 = hexrgb(b)
  return string.format("#%02x%02x%02x", floor(r1 + (r2 - r1) * t + .5), floor(g1 + (g2 - g1) * t + .5), floor(b1 + (b2 - b1) * t + .5))
end
function hsh(x, y)
  local h = (x * 374761393 + y * 668265263) & 0xffffffff
  h = ((h ~ (h >> 13)) * 1274126177) & 0xffffffff
  return (h ~ (h >> 16)) % 100
end
DUSKSH = "#5a4660"
SHD_A, SHD_B = "#7d6a84", "#55445f"
INTERIOR = "#3b2c48"
SHEDR = { hi = P.sea.base, base = P.sea.shade, shade = P.sea.deep, deep = "#22305a" }
HEAP = { hi = P.wood.base, base = P.wood.shade, shade = P.wood.deep, deep = "#3a2430" }
LEAFD = { hi = P.moss.base, base = P.moss.shade, shade = P.moss.deep, deep = "#1f3f3a" }
WIN = { hi = P.sky.hi, base = P.sea.hi, shade = P.sea.base, deep = P.sea.shade }
function rampOf(r) if type(r) == "string" then return P[r] end return r end
function step(x, y, r, dir)
  r = rampOf(r)
  local v = c:get(x, y); if not v then return end
  local T = { r.hi, r.base, r.shade, r.deep }
  for i = 1, 4 do
    if v == T[i] then
      local n
      if dir > 0 then n = (i == 3) and lerp(r.shade, r.deep, .45) or (i == 4) and nil or T[i + 1]
      else n = (i == 1) and lerp(r.hi, P.cream, .5) or (i == 4) and r.shade or T[i - 1] end
      if n then px(x, y, n) end
      return
    end
  end
end
function dk(x, y, r) step(x, y, r, 1) end
function lt(x, y, r) step(x, y, r, -1) end
function courses(m, r, x0, x1, y0, y1, h, w, opt)
  opt = opt or {}
  for y = y0, y1 do
    local row = (y - y0) % h
    local course = (y - y0) // h
    for x = x0, x1 do
      if m:has(x, y) and m:has(x, y - 1) and m:has(x - 1, y) and m:has(x + 1, y) then
        local tx = (x - x0 + (course % 2) * (w // 2))
        if row == h - 1 then dk(x, y, r)
        elseif tx % w == 0 then if not opt.nojoint then dk(x, y, r) end
        else
          local t = hsh(tx // w + 3, course + (opt.seed or 0))
          if t < (opt.light or 12) then lt(x, y, r) elseif t > 100 - (opt.dark or 8) then dk(x, y, r) end
        end
      end
    end
  end
end
function rise(i) return (i + 1) // 2 end
function sideWall(x1, yt, yb, d, extra)
  local m = HP.mask()
  for i = 1, d do local s = rise(i); for yy = yt - s - (extra or 0), yb - s do m:set(x1 + i, yy) end end
  return m
end
function topPlane(x0, x1, yt, d)
  local m = HP.mask()
  for j = 1, rise(d) do for xx = x0 + 2 * j - 1, x1 + math.min(d, 2 * j) do m:set(xx, yt - j) end end
  return m
end
function hipRoof(x0, x1, ye, yr, ov, a, d, ah)
  local rr, hd = rise(d), d // 2
  local EL, ER, BR = { x0 - ov, ye + 1 }, { x1 + ov + 1, ye + 1 }, { x1 + ov + d + 1, ye + 1 - rr }
  local RL, RR = { x0 - ov + a + hd, yr }, { x1 + ov + 1 - (ah or a + 3) + hd, yr }
  local F = c:poly{ EL, RL, RR, ER }
  local S = c:poly{ ER, RR, BR }:cut(F)
  return F, S
end
function wallTones(base, lit)
  return { base = base, lite = lerp(base, lit or P.cream, .4), dark = lerp(base, DUSKSH, .12),
    eave = lerp(base, DUSKSH, .3), sbase = lerp(base, DUSKSH, .36), slite = lerp(base, DUSKSH, .27), sdark = lerp(base, DUSKSH, .47) }
end
function mottle(m, base, lite, dark, seed, dens)
  m:each(function(x, y)
    if c:get(x, y) == base then
      local h = hsh(x * 3 + seed, y * 5 + seed)
      if h < dens then px(x, y, lite) if c:get(x + 1, y) == base and h < dens // 2 then px(x + 1, y, lite) end
      elseif h > 99 - dens then px(x, y, dark) end
    end
  end)
end
function paintWalls(front, side, W, seed)
  c:fillMask(front, W.base) c:fillMask(side, W.sbase)
  mottle(front, W.base, W.lite, W.dark, seed or 1, 7)
  mottle(side, W.sbase, W.slite, W.sdark, (seed or 1) + 9, 9)
end
function eaveShadow(x0, x1, yt, d, W, rows)
  for r = 0, (rows or 1) - 1 do R(x0, yt + r, x1, yt + r, W.eave) end
  for i = 1, d do local s = rise(i); for r = 0, (rows or 1) do px(x1 + i, yt - s + r, W.sdark) end end
end
function paintRoof(F, S, Rr, o)
  o = o or {}
  c:fillMask(F, Rr.base) c:fillMask(S, Rr.shade)
  local x0, y0, x1, y1 = F:bbox()
  if o.tex ~= false then courses(F, Rr, x0, x1, y0 + 1, y1 - 1, o.h or 3, o.w or 5, { light = o.light or 12, dark = o.dark or 6, seed = o.seed or 1 }) end
  local sx0, sy0, sx1, sy1 = S:bbox()
  if sx0 then for yy = sy0, sy1 do if (yy - y0) % (o.h or 3) == (o.h or 3) - 1 then for xx = sx0, sx1 do if S:has(xx, yy) and S:has(xx - 1, yy) then px(xx, yy, lerp(Rr.shade, Rr.deep, .45)) end end end end end
  F:each(function(x, y)
    if not F:has(x, y - 1) and not S:has(x, y - 1) then px(x, y, Rr.hi)
    elseif not F:has(x - 1, y) then px(x, y, lerp(Rr.hi, Rr.base, .35)) end
  end)
  for xx = x0, x1 do if F:has(xx, y1) then px(xx, y1, lerp(Rr.shade, Rr.deep, .35)) end end
  if sx0 then S:each(function(x, y) if not S:has(x, y + 1) and not F:has(x, y + 1) then px(x, y, Rr.deep) end end) end
end
function window(wx, wy, w, h, o)
  o = o or {}
  local fr = o.frame or P.wood.base
  R(wx - 1, wy - 1, wx + w, wy + h, fr)
  local glass = o.glow and P.gold.hi or (o.glass or WIN.shade)
  R(wx, wy, wx + w - 1, wy + h - 1, glass)
  local rec = o.glow and P.gold.base or (o.rec or INTERIOR)
  R(wx, wy, wx + w - 1, wy, rec) R(wx, wy, wx, wy + h - 1, rec)
  if not o.nobar then
    local mx, my = wx + w // 2, wy + h // 2
    if w >= 5 then R(mx, wy, mx, wy + h - 1, fr) end
    if h >= 5 then R(wx, my, wx + w - 1, my, fr) end
  end
  if o.glow then px(wx + 1, wy + 1, P.cream) else px(wx + 1, wy + 1, o.glint or WIN.hi) end
  px(wx - 1, wy - 1, o.frameHi or lerp(fr, P.cream, .35))
  if not o.nosill then
    R(wx - 2, wy + h, wx + w + 1, wy + h, o.sill or P.stone.hi)
    R(wx - 1, wy + h + 1, wx + w + 1, wy + h + 1, o.sillsh)
  end
end
function door(dx0, dx1, dy0, yb, o)
  o = o or {}
  local Rw = o.ramp or P.wood
  local fr = o.frame or Rw.deep
  local f = c:rrect(dx0 - 1, dy0 - 1, dx1 + 1, yb, o.arch or 2)
  c:fillMask(f, fr)
  local leaf = c:rrect(dx0, dy0, dx1, yb, math.max((o.arch or 2) - 1, 0))
  c:fillMask(leaf, o.open and INTERIOR or Rw.base)
  if not o.open then
    for xx = dx0 + 2, dx1 - 1, 2 do leaf:each(function(x, y) if x == xx then px(x, y, Rw.shade) end end) end
    leaf:each(function(x, y) if not leaf:has(x, y - 1) or x == dx0 then px(x, y, lerp(Rw.shade, Rw.deep, .5)) end end)
    px(dx1 - 1, dy0 + (yb - dy0) // 2 + 1, P.gold.hi)
  end
  if o.lintel then R(dx0 - 2, dy0 - 2, dx1 + 2, dy0 - 2, o.lintel) end
  if not o.nostep then R(dx0 - 2, yb, dx1 + 2, yb, P.stone.base) R(dx0 - 2, yb, dx1 + 1, yb, P.stone.hi) end
end
function plinth(x0, x1, yb, d, rows)
  rows = rows or 2
  R(x0, yb - rows + 1, x1, yb, P.stone.base)
  R(x0, yb - rows + 1, x1, yb - rows + 1, P.stone.hi)
  R(x0, yb, x1, yb, P.stone.shade)
  for xx = x0 + 2, x1, 5 do px(xx, yb - rows + 2 > yb and yb or yb - rows + 2, P.stone.shade) end
  for i = 1, d do local s = rise(i); for r = 0, rows - 1 do px(x1 + i, yb - s - r, (r == rows - 1) and P.stone.shade or P.stone.deep) end end
end
-- solid cool cast shadow (no ground to tint), lower right
function castShadow(x0, x1, yb, d, hw, L)
  L = (L or 4) + 3
  local m = HP.mask()
  for j = 1, 3 do for xx = x0 + j, x1 + d + j + 1 do m:set(xx, yb + j) end end
  local rr = rise(d)
  for yy = yb - rr - hw, yb do
    local t = (yy - (yb - rr - hw)) / (hw + rr)
    for xx = x1 + d + 1, x1 + d + 1 + floor(t * L + .5) do m:set(xx, yy) end
  end
  local k = HP.mask() for xx = x0 + 1, x1 + d do k:set(xx, yb + 2) end
  c:fillMask(m, SHD_A) c:fillMask(k, SHD_B)
end
function shadowEllipse(cx, cy, rx, ry) c:fillMask(E(cx, cy, rx, ry), SHD_A) end
local LX, LY, LZ = -0.55, -0.62, 0.56
function ball(m, cx, cy, rx, ry, T, o)
  o = o or {}
  local t1, t2, t3 = o.t1 or .62, o.t2 or .2, o.t3 or -.18
  m:each(function(x, y)
    local u, v = (x + .5 - cx - .5) / (rx + .5), (y + .5 - cy - .5) / (ry + .5)
    local q = 1 - u * u - v * v; if q < 0 then q = 0 end
    local l = LX * u + LY * v + LZ * math.sqrt(q)
    px(x, y, (l > t1 and T.hi) or (l > t2 and T.base) or (l > t3 and T.shade) or T.deep)
  end)
  if not o.norefl then
    m:each(function(x, y) if (not m:has(x + 1, y) or not m:has(x, y + 1)) and c:get(x, y) == T.deep and (x - cx) + (y - cy) * (rx / math.max(ry, 1)) > rx * .5 then px(x, y, T.shade) end end)
  end
  if not o.nospec then local sx, sy = floor(cx - rx * .42 + .5), floor(cy - ry * .5 + .5); if m:has(sx, sy) then px(sx, sy, o.spec or P.cream) end end
end
function ink(...) local u = HP.mask() for _, m in ipairs{ ... } do u:add(m) end c:rim(u, P.ink) return u end
function inkPart(m, ramp, o) ink(m) c:part(m, ramp, o or { band = 1, nopop = true }) end

-- small props -------------------------------------------------
function flower(x, y, col)
  local head = HP.mask():set(x, y - 1):set(x - 1, y):set(x, y):set(x + 1, y):set(x, y + 1)
  local stem = c:rect(x, y + 2, x, y + 3)
  c:rim(HP.mask():add(head):add(stem), P.ink)
  c:fillMask(stem, P.moss.base); c:fillMask(head, col or P.petal.base); px(x, y, P.gold.hi)
end
function pebble(x, y, w)
  w = w or 3
  local m = c:rect(x, y, x + w - 1, y + 1)
  ink(m); c:part(m, "stone", { band = 1, nopop = true }); px(x, y, P.stone.hi)
end
function stake(x, y0, y1)
  local m = c:rect(x, y0, x, y1 + 0); ink(m); c:part(m, "wood", { band = 1, nopop = true }); px(x, y0, P.wood.hi)
end
function stringLine(pts)   -- cream string, 1 px
  for i = 1, #pts - 1 do c:fillMask(c:line({ pts[i], pts[i + 1] }, 1), P.cream) end
end
-- 3x5 font -------------------------------------------------
GLYPH = {
  B = { "XX.", "X.X", "XX.", "X.X", "XX." },
  U = { "X.X", "X.X", "X.X", "X.X", "XXX" },
  I = { "XXX", ".X.", ".X.", ".X.", "XXX" },
  L = { "X..", "X..", "X..", "X..", "XXX" },
  D = { "XX.", "X.X", "X.X", "X.X", "XX." },
}
function buildText(x, y, hex)   -- (x,y) top-left, 19 wide, 5 tall
  local cx = x
  for ch in ("BUILD"):gmatch(".") do
    local g = GLYPH[ch]
    for r = 1, 5 do for q = 1, 3 do if g[r]:sub(q, q) == "X" then px(cx + q - 1, y + r - 1, hex or P.ink) end end end
    cx = cx + 4
  end
end
function badge(cx, cy)   -- 9 px gold disc, ink outline, cream "!" with a tiny ink drop
  local disc = E(cx, cy, 4, 4)
  ink(disc)
  c:part(disc, "gold", { band = 2, pop = { x = cx - 3, y = cy - 3, horizontal = true } })
  R(cx + 1, cy - 3, cx + 1, cy + 1, P.gold.deep); R(cx + 1, cy + 3, cx + 1, cy + 3, P.gold.deep)
  R(cx, cy - 3, cx, cy + 1, P.cream); R(cx, cy + 3, cx, cy + 3, P.cream)
  R(cx - 1, cy - 3, cx - 1, cy + 1, P.cream); R(cx - 1, cy + 3, cx - 1, cy + 3, P.cream)
  R(cx - 1, cy - 4, cx, cy - 4, P.cream)
  R(cx - 1, cy - 4, cx, cy - 4, P.gold.hi)
end
