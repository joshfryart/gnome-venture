-- here-town-dunewhisper.lua : "The Dunewhisper" gate view (Hearth Pop v3, hero scale, 480x270)
-- Desert bazaar town at golden dusk: sandstone/mudbrick fronts, domes, arches, striped awnings,
-- an oasis with palms and a deep stone well, dunes beyond. No people, no animals, no text.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = (app.params and app.params.out) or "/home/user/gnome-venture/aseprite-source/v3/here-gate/towns/"
if OUT:sub(-1) ~= "/" then OUT = OUT .. "/" end
local NAME = "here-town-dunewhisper"
local W, H, HZ, VX = 480, 270, 112, 240
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local floor, abs, min, max, sin, cos, sqrt, pi = math.floor, math.abs, math.min, math.max, math.sin, math.cos, math.sqrt, math.pi
local atan = math.atan

---------------------------------------------------------------- helpers
local function hash(x, y, s) local v = sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453 return v - floor(v) end
local function rgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
local function cl(v) return max(10, min(248, floor(v + .5))) end
local function hx(r, g, b) return string.format("#%02x%02x%02x", cl(r), cl(g), cl(b)) end
local function mix(a, b, t) local r1, g1, b1 = rgb(a) local r2, g2, b2 = rgb(b) return hx(r1 + (r2 - r1) * t, g1 + (g2 - g1) * t, b1 + (b2 - b1) * t) end
local function px(x, y, col) c:put(floor(x), floor(y), col) end
local function get(x, y) return c:get(floor(x), floor(y)) end
local SHADE_TO, GLOW_TO = "#4a3470", "#ffd47a"
local function tint(x, y, to, t) local g = get(x, y) if g then px(x, y, mix(g, to, t)) end end
local function M(fn, x0, y0, x1, y1)
  local m = HP.mask()
  for y = max(0, floor(y0)), min(H - 1, floor(y1)) do for x = max(0, floor(x0)), min(W - 1, floor(x1)) do
    if fn(x, y) then m:set(x, y) end end end
  return m
end
local function R(x0, y0, x1, y1) return M(function() return true end, x0, y0, x1, y1) end
local function PG(pts) return c:poly(pts):clip(R(0, 0, W - 1, H - 1)) end
local function fill(m, col) c:fillMask(m, col) return m end
local function edge(m, col) c:edgeIn(m, col) return m end
local function rect(x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do px(x, y, col) end end end
local function hline(x0, x1, y, col) for x = x0, x1 do px(x, y, col) end end
local function vline(x, y0, y1, col) for y = y0, y1 do px(x, y, col) end end
local function shadow(pts, amt) local m = PG(pts) m:each(function(x, y) tint(x, y, SHADE_TO, amt or .3) end) return m end
local function glow(cx, cy, r, amt, to)
  for y = floor(cy - r), floor(cy + r) do for x = floor(cx - r * 1.3), floor(cx + r * 1.3) do
    local dx, dy = abs(x - cx) / 1.3, abs(y - cy)
    local d = (max(dx, dy) * .55 + (dx + dy) * .45) / r
    if d < 1 then tint(x, y, to or GLOW_TO, d < .5 and amt or amt * .5) end
  end end
end
-- volume shading for small solid parts: base, lit top-left inner row, shaded bottom-right, own deep edge
local function solid(m, Rm)
  m:each(function(x, y) px(x, y, Rm.b) end)
  m:each(function(x, y) if not m:has(x + 2, y) or not m:has(x, y + 2) then px(x, y, Rm.s) end end)
  m:each(function(x, y) if (not m:has(x - 2, y) or not m:has(x, y - 2)) and m:has(x + 2, y) and m:has(x, y + 2) then px(x, y, Rm.h) end end)
  edge(m, Rm.d) return m
end
-- wall textures: "brick" (mudbrick courses), "stone" (sandstone blocks), "plaster" (speckled render + bare patches)
local function wall(m, Rm, kind, seed)
  local x0, y0 = m:bbox()
  m:each(function(x, y)
    local col, n = Rm.b, hash(x, y, seed)
    if kind == "brick" or kind == "stone" then
      local bh, bw = (kind == "brick") and 4 or 6, (kind == "brick") and 8 or 11
      local row = floor((y - y0) / bh)
      local off = (row % 2) * floor(bw / 2)
      if (y - y0) % bh == bh - 1 then col = Rm.s
      elseif (x - x0 + off) % bw == 0 then col = Rm.s
      elseif (y - y0) % bh == 0 then col = mix(Rm.b, Rm.h, .5)
      else
        local v = hash(floor((x - x0 + off) / bw), row, seed)
        if v < .3 then col = mix(Rm.b, Rm.s, .3) elseif v > .82 then col = mix(Rm.b, Rm.h, .35) end
        if n < .05 then col = Rm.s end
      end
    else
      if n < .05 then col = mix(Rm.b, Rm.s, .6) elseif n > .965 then col = Rm.h end
      local p = hash(floor(x / 11), floor(y / 8), seed + 3)
      if p > .86 then
        if (y % 4 == 3) or ((x + (floor(y / 4) % 2) * 3) % 6 == 0) then col = Rm.s else col = mix(Rm.b, Rm.s, .35) end
      end
      if hash(floor(x / 3), floor(y / 2), seed + 9) > .93 then col = mix(Rm.b, Rm.h, .5) end
    end
    px(x, y, col)
  end)
end
local function sidePts(xf, ytop, ybase, w)
  local dir = (VX > xf) and 1 or -1
  local t = w / abs(VX - xf)
  local xe = floor(xf + dir * w + .5)
  return { { xf, ytop }, { xe, floor(ytop + t * (HZ - ytop) + .5) }, { xe, floor(ybase + t * (HZ - ybase) + .5) }, { xf, ybase } }
end
-- pointed (ogee-free, two-centred look) arch mask
local function archM(x0, y0, x1, y1, ph)
  local cx, hw = (x0 + x1) / 2, (x1 - x0) / 2 + .5
  return M(function(x, y)
    if y >= y0 + ph then return true end
    local d = abs(x - cx) / hw
    if d >= 1 then return false end
    return y >= y0 + ph * (1 - sqrt(1 - d))
  end, x0, y0, x1, y1)
end
local function dome(cx, yb, rx, ry, Rm, tip)
  tip = tip or .25
  local m = M(function(x, y)
    local d = abs(x - cx) / rx
    if d > 1 then return false end
    local top = yb - ry * sqrt(1 - d * d) - ry * tip * max(0, 1 - d / .35) ^ 2
    return y >= top
  end, cx - rx, yb - ry * (1 + tip) - 1, cx + rx, yb)
  m:each(function(x, y)
    local rel, col = (x - cx) / rx, Rm.b
    local row = floor((yb - y) / 4)
    if (yb - y) % 4 == 3 and ((x + row * 2) % 4) < 2 then col = Rm.s end
    if rel > .42 then col = (col == Rm.s) and Rm.d or Rm.s end
    if rel < -.2 and rel > -.55 and y < yb - ry * .35 then col = Rm.h end
    px(x, y, col)
  end)
  edge(m, Rm.d)
  local ty = floor(yb - ry * (1 + tip))
  vline(floor(cx), ty - 5, ty, "#a86a20") px(floor(cx), ty - 6, "#f6d46a")
  px(floor(cx) - 1, ty - 3, "#e0a838") px(floor(cx) + 1, ty - 3, "#8a5420") px(floor(cx), ty - 3, "#f6d46a")
  return m
end
local function mosaic(x0, y0, x1, y1, c1, c2, c3)
  c1, c2, c3 = c1 or "#2e5aa0", c2 or "#e8b84a", c3 or "#3aa6a0"
  local ym = (y0 + y1) / 2
  for y = y0, y1 do for x = x0, x1 do
    local col = c1
    if y == y0 or y == y1 then col = "#1e3456"
    else
      local d = abs(((x - x0) % 6) - 3) + abs(y - ym)
      if d <= 1 then col = c2 elseif d <= 2 then col = c3 end
    end
    px(x, y, col)
  end end
end
local function window(x0, y0, x1, y1, ph, frame, lattice)
  glow((x0 + x1) / 2, (y0 + y1) / 2 + 2, (x1 - x0) * 1.1, .14)
  fill(archM(x0 - 1, y0 - 1, x1 + 1, y1 + 1, ph + 1), frame)
  archM(x0, y0, x1, y1, ph):each(function(x, y)
    local col = (y > (y0 + y1) / 2 + 2) and "#e8923e" or "#f6c45a"
    if y < y0 + ph + 3 and hash(x, y, 5) > .6 then col = "#fbe08a" end
    if lattice and ((x + y) % 3 == 0 or (x - y) % 3 == 0) then col = "#7a3e2e" end
    px(x, y, col)
  end)
  if not lattice then vline(floor((x0 + x1) / 2), y0 + ph - 2, y1, frame) hline(x0, x1, floor((y0 + ph + y1) / 2), frame) end
  hline(x0 - 2, x1 + 2, y1 + 2, frame) hline(x0 - 2, x1 + 2, y1 + 3, mix(frame, "#2a1828", .4))
end
local function carpet(x0, y0, x1, y1, b, a, bd)
  hline(x0 - 1, x1 + 1, y0 - 1, "#7a4a1e")
  for y = y0, y1 do for x = x0, x1 do
    local col = b
    if x == x0 or x == x1 or y == y0 or y == y1 then col = bd
    elseif x == x0 + 1 or x == x1 - 1 or y == y0 + 1 or y == y1 - 1 then col = a
    else
      local d = abs(x - (x0 + x1) / 2) + abs(((y - y0) % 10) - 5)
      if d <= 1.5 then col = a elseif d <= 2.5 then col = bd end
    end
    px(x, y, col)
  end end
  for x = x0 + 1, x1 - 1, 2 do px(x, y1 + 1, a) px(x, y1 + 2, mix(a, bd, .4)) end
  for y = y0 + 1, y1 + 1 do tint(x1 + 1, y, SHADE_TO, .3) end
end
local function urn(x, yb, Rm)
  local rows = { 2, 2, 4, 6, 8, 8, 8, 7, 6, 4 }
  local m = HP.mask()
  for i, w in ipairs(rows) do local y = yb - #rows + i for k = 0, w - 1 do m:set(x - floor(w / 2) + k, y) end end
  solid(m, Rm) px(x - 2, yb - 5, "#fbe08a")
end
-- palms
local PALM = { d = "#21482c", s = "#346f3a", b = "#4c9a42", h = "#86c45a" }
local TR = { d = "#4a2c22", s = "#7a4a30", b = "#9a6440", h = "#c08a5a" }
local function frond(tx, ty, angd, L, droop)
  local a = math.rad(angd)
  local pts, n = {}, floor(L * 1.2)
  for i = 0, n do local t = i / n pts[#pts + 1] = { tx + cos(a) * L * t, ty + sin(a) * L * t + droop * L * t * t, t } end
  local dirx = cos(a) >= 0 and 1 or -1
  for pass = 1, 2 do
    for _, p in ipairs(pts) do
      local x, y, t = p[1], p[2], p[3]
      local ll = floor(1.5 + 4 * sin(pi * min(1, t * 1.15)))
      if t > .08 then
        for k = 1, ll do
          local lx, ly = floor(x + dirx * k * .45 + .5), floor(y + k + .5)
          if pass == 1 then px(lx + 1, ly + 1, PALM.d) else px(lx, ly, (k >= ll - 1) and PALM.s or ((k == 1 and dirx < 0) and PALM.h or PALM.b)) end
        end
      end
    end
  end
  for _, p in ipairs(pts) do px(floor(p[1] + .5), floor(p[2] + .5) - 1, PALM.d) end
  for _, p in ipairs(pts) do px(floor(p[1] + .5), floor(p[2] + .5), dirx < 0 and PALM.h or "#6aae4a") end
end
local function palm(bx, by, tx, ty, bend, L)
  shadow({ { bx - 3, by }, { bx + 4, by }, { bx + 16, by + 5 }, { bx + 7, by + 6 } }, .32)
  local n = floor(by - ty)
  for i = 0, n do
    local t = i / n
    local y = by - i
    local x = bx + (tx - bx) * t + bend * sin(pi * t)
    local w = floor(6 - 2.5 * t + .5)
    local x0 = floor(x - w / 2 + .5)
    for k = 0, w - 1 do
      local col
      if k == 0 or k == w - 1 then col = TR.d elseif k == 1 then col = TR.h else col = TR.b end
      if i % 4 == 0 and k > 0 and k < w - 1 then col = TR.s end
      if i % 4 == 1 and k == w - 2 then col = TR.s end
      px(x0 + k, y, col)
    end
  end
  local fr = { { -165, 1, .55 }, { -140, .95, .35 }, { -112, .5, .25 }, { -68, .5, .25 }, { -40, .95, .35 }, { -15, 1, .55 },
               { 160, .75, .9 }, { 20, .75, .9 }, { 125, .5, 1.3 }, { 55, .5, 1.3 } }
  for _, f in ipairs(fr) do frond(tx, ty, f[1], L * f[2], f[3]) end
  for _, d in ipairs({ { -4, 2 }, { 2, 3 }, { -1, 4 }, { 3, 1 } }) do rect(tx + d[1], ty + d[2], tx + d[1] + 1, ty + d[2] + 1, "#b8602a") px(tx + d[1], ty + d[2], "#ec9a3e") end
  rect(tx - 2, ty - 1, tx + 2, ty, "#5a3a26")
end
local function lantern(lx, ytop, ychain, big)
  glow(lx, ytop + 9, big and 26 or 16, .3)
  for y = ychain, ytop - 1 do px(lx, y, (y % 2 == 0) and "#4a2e22" or "#9a7040") end
  local rows = { { 1, "cap" }, { 3, "cap" }, { 5, "cap" }, { 7, "rim" }, { 7, "b" }, { 9, "b" }, { 9, "b" }, { 9, "b" }, { 9, "b" },
                 { 9, "b" }, { 9, "b" }, { 7, "b" }, { 7, "rim" }, { 5, "cap" }, { 3, "cap" }, { 1, "cap" } }
  if not big then rows = { { 1, "cap" }, { 3, "cap" }, { 5, "rim" }, { 5, "b" }, { 5, "b" }, { 5, "b" }, { 5, "rim" }, { 3, "cap" } } end
  for i, r in ipairs(rows) do
    local y, hw = ytop + i - 1, floor(r[1] / 2)
    for x = lx - hw, lx + hw do
      local col
      if r[2] == "cap" then col = (x < lx) and "#e0a840" or ((x == lx) and "#c88a2e" or "#a86a22")
      elseif r[2] == "rim" then col = "#7a4a1e"
      elseif x == lx - hw or x == lx + hw then col = "#7a4a1e"
      elseif (x - lx) % 2 == 0 and i % 2 == 0 then col = "#ffeaa0"
      else col = (x > lx + 1) and "#e89a34" or "#f6c24a" end
      px(x, y, col)
    end
  end
end
local function teapot(cx, cy, s, Rm)
  local body = c:rrect(cx - 4 * s, cy - 3 * s, cx + 4 * s, cy + 3 * s, 2 * s)
  body:add(PG { { cx - 2 * s, cy - 3 * s }, { cx + 2 * s, cy - 3 * s }, { cx, cy - 6 * s } })
  body:add(c:line({ { cx + 4 * s, cy + s }, { cx + 7 * s, cy - 2 * s }, { cx + 8 * s, cy - 2 * s } }, s + 1))
  body:add(c:line({ { cx - 4 * s, cy - 2 * s }, { cx - 7 * s, cy - s }, { cx - 7 * s, cy + s }, { cx - 4 * s, cy + 2 * s } }, s))
  solid(body, Rm)
  px(cx - 2 * s, cy - s, "#fbe08a")
  return body
end

---------------------------------------------------------------- palettes
local SST = { d = "#6a4630", s = "#ae7c4c", b = "#d6a868", h = "#eec88c" }   -- frame sandstone
local GOLD = { d = "#6e4018", s = "#b07024", b = "#dca038", h = "#f6d46a" }
local BRASS = { d = "#6a4018", s = "#a86a22", b = "#d8a040", h = "#f4d070" }
local WOOD = { d = "#4a2c1e", s = "#7a4a2a", b = "#a06a3a", h = "#c88e52" }
local STN = { d = "#4e3a50", s = "#7e6a7e", b = "#a8949e", h = "#ccb8b8" }

---------------------------------------------------------------- sky
c:stripes(0, HZ, { "#4c3870", "#634280", "#7e4c88", "#a05a86", "#c26c7c", "#dc8270", "#ec9c68", "#f4b46e", "#f8c87c", "#fad692" },
  { 3, 3, 3, 3, 3, 3, 3, 2, 2, 2 })
glow(318, 104, 70, .28, "#ffe2a0")
local function cloud(x, y, w)
  local m = c:rrect(x + floor(w * .2), y - 10, x + floor(w * .6), y - 3, 3)
  m:add(c:rrect(x + floor(w * .45), y - 7, x + floor(w * .85), y - 2, 2))
  m:add(c:rrect(x, y - 4, x + w, y, 2))
  m:each(function(a, b)
    local col = "#eeb08c"
    if not m:has(a, b - 1) then col = "#fbe2b4" elseif not m:has(a, b - 2) then col = "#f6cc9c"
    elseif not m:has(a, b + 1) then col = "#c47a8a" elseif a > x + w * .7 and not m:has(a, b + 2) then col = "#d8928a" end
    px(a, b, col)
  end)
end
for _, cd in ipairs({ { 30, 46, 60 }, { 112, 30, 46 }, { 286, 26, 74 }, { 386, 58, 54 }, { 162, 66, 40 }, { 326, 80, 36 }, { 420, 32, 40 }, { 210, 20, 34 } }) do cloud(cd[1], cd[2], cd[3]) end

---------------------------------------------------------------- far scenery
local function dunes(f, lit, sh, crest, ybot, x0, x1)
  for x = x0 or 0, x1 or W - 1 do
    local y0 = floor(f(x) + .5)
    local rising = f(x + 1) < f(x) + .05
    for y = y0, ybot do px(x, y, (y == y0 and rising) and crest or (rising and lit or sh)) end
  end
end
dunes(function(x) return 95 - 7 * sin(x / 47 + .5) - 3 * sin(x / 17) end, "#c27a8a", "#a0607e", "#daa0a0", HZ)
-- distant town silhouettes (pale violet), domes and towers on the horizon
local FAR = "#b46e8c"
for _, b in ipairs({ { 120, 10, 9 }, { 132, 8, 13 }, { 142, 12, 8 }, { 172, 9, 11 }, { 184, 6, 18 }, { 288, 8, 10 }, { 360, 12, 9 }, { 300, 9, 7 } }) do
  rect(b[1], 106 - b[3], b[1] + b[2], 106, FAR)
  if b[2] >= 9 then fill(M(function(x, y) local d = abs(x - (b[1] + b[2] / 2)) / (b[2] / 2 - 1) return d <= 1 and y >= 106 - b[3] - 4 * sqrt(max(0, 1 - d * d)) end, b[1], 106 - b[3] - 5, b[1] + b[2], 106 - b[3]), FAR) end
end
dunes(function(x) return 104 - 4 * sin(x / 29 + 2) - 2 * sin(x / 9 + 1) end, "#e09a6a", "#c07868", "#f0b47e", HZ)

---------------------------------------------------------------- ground + street
for y = HZ, H - 1 do for x = 0, W - 1 do
  local col = y < 136 and "#e2b07e" or (y < 180 and "#e6ba84" or "#e9c28c")
  local r = sin(x * .11 + y * .9 + 2.5 * sin(x * .027 + y * .05))
  if r > .94 then col = "#d3a272" elseif r > .86 and r < .9 then col = "#f0d09a" end
  local n = hash(x, y, 7)
  if n < .03 then col = "#d6a676" elseif n > .985 then col = "#f4dcaa" end
  px(x, y, col)
end end
local function xL(y) return VX - (y - HZ) * .85 end
local function xR(y) return VX + (y - HZ) * .85 end
local TILE = { "#dcb383", "#d2a676", "#e2c090", "#d8ad7e" }
local function tileAt(x, y) local d = y - 104 local wz = 2400 / d local j = floor(wz) return floor((x - VX) * 8 / d + (j % 2) * .5), j, wz end
for y = HZ + 4, H - 1 do
  local a, b = floor(xL(y) + .5), floor(xR(y) + .5)
  for x = a, b do
    local i, j, wz = tileAt(x, y)
    local i2 = tileAt(x - 1, y)
    local _, j2, wz2 = tileAt(x, y - 1)
    local d = y - 104
    local col = TILE[1 + floor(hash(i, j, 3) * 4)]
    if j2 ~= j and (wz2 - wz) < .6 then col = "#a87c5a"
    elseif i2 ~= i and d > 14 then col = "#b08460"
    else
      local _, j3, wz3 = tileAt(x, y - 2)
      if j3 ~= j and (wz3 - wz) < .6 and d > 40 then col = "#ecd2a2" end
      if hash(x, y, 11) < .04 then col = "#c89a6c" end
    end
    if x <= a + 1 or x >= b - 1 then col = (x == a or x == b) and "#8a6248" or "#c49a6c" end
    px(x, y, col)
  end
end

---------------------------------------------------------------- LIBRARY (back left)  box [22,34,118,132]
local LIB = { d = "#5e2e2c", s = "#8e4a3a", b = "#bc6a48", h = "#da9064" }
shadow({ { 30, 129 }, { 116, 127 }, { 128, 134 }, { 40, 136 } }, .3)
dome(62, 54, 22, 15, { d = "#1c3e5e", s = "#2c6290", b = "#4a8ac0", h = "#8cc0e4" }, .3)
local libSide = PG(sidePts(101, 52, 128, 14))
wall(libSide, { d = "#4a2428", s = "#6a3632", b = "#8a4838", h = "#a05a44" }, "brick", 21) edge(libSide, "#4a2428")
window(105, 72, 110, 90, 4, "#4a2428", true)
local fac = R(24, 54, 100, 128)
wall(fac, LIB, "plaster", 3)
for y = 54, 128 do tint(99, y, SHADE_TO, .2) tint(100, y, SHADE_TO, .25) end
edge(fac, LIB.d)
for x = 24, 96, 9 do local m = R(x, 48, x + 5, 54) wall(m, LIB, "plaster", x) edge(m, LIB.d) end
hline(25, 99, 55, LIB.h)
mosaic(26, 59, 98, 63)
local plin = R(24, 120, 100, 128) wall(plin, STN, "stone", 9) edge(plin, STN.d)
-- arched door with stone surround
local dOut = archM(46, 84, 78, 128, 14)
dOut:each(function(x, y) px(x, y, hash(x, y, 4) < .1 and "#c8a476" or "#e6c896") end) edge(dOut, "#7a5a40")
local dIn = archM(50, 88, 74, 128, 12)
dIn:each(function(x, y) local col = "#2e5a7a" if (x - 50) % 4 == 0 then col = "#1e3e5a" elseif x < 56 then col = "#3e74a0" end px(x, y, col) end)
edge(dIn, "#16304a") vline(62, 98, 127, "#16304a")
for y = 102, 124, 6 do px(56, y, "#e0b04a") px(68, y, "#e0b04a") end
px(60, 112, "#f6d46a") px(64, 112, "#f6d46a")
rect(44, 129, 80, 131, "#cbb8a8") hline(44, 80, 131, "#8a7480") hline(44, 80, 129, "#e2d2c2")
-- windows (one mashrabiya lattice, one mullioned)
window(30, 72, 42, 96, 7, "#6e3a2a", true)
window(84, 72, 95, 96, 7, "#6e3a2a", false)
-- BIG BOOK sign over the door
local cover = PG { { 44, 68 }, { 62, 72 }, { 80, 68 }, { 80, 80 }, { 62, 85 }, { 44, 80 } }
fill(cover, "#a83a3a") edge(cover, "#5e1e24")
local lp = PG { { 46, 67 }, { 61, 70 }, { 61, 81 }, { 46, 78 } } fill(lp, "#f4e6c6") edge(lp, "#b49a78")
local rp = PG { { 63, 70 }, { 78, 67 }, { 78, 78 }, { 63, 81 } } fill(rp, "#e2cca4") edge(rp, "#a08460")
for k = 0, 3 do
  c:line({ { 48, 71 + k * 2 }, { 59, 73 + k * 2 } }, 1):each(function(x, y) px(x, y, "#a89080") end)
  c:line({ { 65, 73 + k * 2 }, { 76, 71 + k * 2 } }, 1):each(function(x, y) px(x, y, "#9a8070") end)
end
vline(62, 70, 84, "#7a2a2a") vline(72, 79, 86, "#e8b040") px(72, 87, "#b07a24")
px(47, 68, "#fbeed0") px(48, 68, "#fbeed0")
-- quirk: a tower of books on the parapet with a palm seedling growing out of it
for i, bk in ipairs({ { 86, 46, 99, "#3a62a8" }, { 87, 43, 97, "#c8484a" }, { 85, 40, 96, "#e8b040" }, { 88, 37, 98, "#4c9a42" } }) do
  local m = R(bk[1], bk[2], bk[3], bk[2] + 2) fill(m, bk[4]) hline(bk[1], bk[3], bk[2] + 2, mix(bk[4], "#2a1828", .45))
  vline(bk[3], bk[2], bk[2] + 2, mix(bk[4], "#2a1828", .45)) hline(bk[1] + 1, bk[3] - 2, bk[2] + 1, "#f2e6c8")
end
vline(92, 31, 36, TR.b) frond(92, 31, -150, 8, .4) frond(92, 31, -30, 8, .4) frond(92, 31, -95, 5, .2)

---------------------------------------------------------------- BAZAAR (back centre)  box [196,34,284,128]
local BAZ = { d = "#7a5638", s = "#c09a6a", b = "#e2c48e", h = "#f4dcaa" }
shadow({ { 204, 127 }, { 282, 126 }, { 294, 132 }, { 214, 134 } }, .3)
dome(240, 56, 24, 16, GOLD, .35)
local drum = R(218, 52, 262, 58) wall(drum, BAZ, "stone", 5) edge(drum, BAZ.d)
for x = 221, 259, 6 do vline(x, 54, 56, "#5a3a44") end
local bfac = R(200, 60, 280, 126) wall(bfac, BAZ, "stone", 31) edge(bfac, BAZ.d)
for x = 200, 274, 8 do local m = PG { { x, 61 }, { x, 57 }, { x + 1, 57 }, { x + 1, 55 }, { x + 5, 55 }, { x + 5, 57 }, { x + 6, 57 }, { x + 6, 61 } } fill(m, BAZ.b) edge(m, BAZ.d) end
mosaic(201, 63, 279, 67)
-- voussoir arch (red / cream) and the dim interior
local fr = archM(212, 70, 268, 126, 24)
fr:each(function(x, y) local k = floor((atan(y - 104, x - 240) + pi) * 10 / pi) px(x, y, k % 2 == 0 and "#b8524a" or "#f0dcb0") end)
edge(fr, BAZ.d)
local op = archM(218, 76, 262, 126, 20)
op:each(function(x, y) local col = y < 92 and "#3a2440" or "#4a3050" if y > 118 then col = "#6a4a50" end px(x, y, col) end)
carpet(222, 94, 230, 116, "#9a3c4c", "#e8b84a", "#5a1e2c")
carpet(250, 94, 258, 116, "#2e5a8a", "#f0dcb0", "#1a2e50")
glow(240, 104, 18, .2)
for _, xx in ipairs({ 234, 240, 246 }) do urn(xx, 118, BRASS) end
edge(op, "#2a1a30")
-- icon: brass balance scale (haggling) hanging in the arch
vline(240, 78, 85, "#8a5a22")
hline(228, 252, 86, BRASS.b) hline(228, 252, 87, BRASS.s) px(240, 85, BRASS.h)
for _, sx in ipairs({ 230, 250 }) do
  c:line({ { sx, 88 }, { sx - 3, 92 } }, 1):each(function(x, y) px(x, y, "#c8a070") end)
  c:line({ { sx, 88 }, { sx + 3, 92 } }, 1):each(function(x, y) px(x, y, "#c8a070") end)
  local pan = PG { { sx - 5, 92 }, { sx + 6, 92 }, { sx + 4, 95 }, { sx - 3, 95 } } solid(pan, BRASS)
end
-- carpets on the facade
carpet(203, 76, 212, 116, "#b8404a", "#f0c860", "#5a1e2c")
carpet(268, 76, 277, 116, "#3a5aa0", "#f0dcb0", "#1a2e50")
-- quirk: first price is a joke (big X tag), second a story (spiral tag)
local t1 = R(269, 86, 276, 93) fill(t1, "#f4e6c6") edge(t1, "#8a6a4a")
c:line({ { 271, 88 }, { 274, 91 } }, 1):each(function(x, y) px(x, y, "#c8484a") end)
c:line({ { 274, 88 }, { 271, 91 } }, 1):each(function(x, y) px(x, y, "#c8484a") end)
local t2 = R(270, 98, 276, 104) fill(t2, "#f4e6c6") edge(t2, "#8a6a4a")
for _, p in ipairs({ { 272, 100 }, { 273, 100 }, { 274, 101 }, { 273, 102 }, { 272, 102 }, { 272, 101 } }) do px(p[1], p[2], "#3a62a8") end
vline(272, 81, 85, "#7a5a40") vline(273, 94, 97, "#7a5a40")
urn(206, 126, BRASS) urn(216, 126, { d = "#5a2a1a", s = "#9a4a2a", b = "#c0663a", h = "#e08a54" })
urn(266, 126, { d = "#1e3e5a", s = "#2c6290", b = "#4a8ac0", h = "#8cc0e4" }) urn(276, 126, BRASS)

---------------------------------------------------------------- MINT TENT teahouse (back right)  box [372,40,458,128]
local MINT = { d = "#1e5a48", s = "#3a8a6a", b = "#5ab48a", h = "#8ad6aa" }
local CRM = { d = "#8a7a5a", s = "#d0bc90", b = "#f0e2bc", h = "#f8eed4" }
shadow({ { 378, 128 }, { 456, 128 }, { 468, 134 }, { 388, 135 } }, .3)
local ins = R(380, 80, 452, 127)
ins:each(function(x, y) local col = "#2a4e44" if (x - 380) % 12 < 6 and y < 112 then col = "#24443c" end if y >= 118 then col = "#6a3e3a" end px(x, y, col) end)
carpet(384, 90, 394, 112, "#b8404a", "#f0c860", "#5a1e2c")
carpet(438, 90, 448, 112, "#8a4aa0", "#f0dcb0", "#3a1e50")
glow(414, 108, 22, .22)
local tbl = R(400, 114, 430, 118) solid(tbl, WOOD) rect(403, 119, 405, 124, WOOD.s) rect(425, 119, 427, 124, WOOD.s)
teapot(412, 110, 1, BRASS)
for _, gx in ipairs({ 420, 424 }) do rect(gx, 110, gx + 1, 113, "#5ab48a") px(gx, 110, "#c8f0d0") end
local cu1 = c:rrect(384, 116, 398, 123, 2) solid(cu1, { d = "#5a1e2c", s = "#8a2e3a", b = "#c84850", h = "#ec7a70" })
local cu2 = c:rrect(434, 116, 448, 123, 2) solid(cu2, GOLD)
local rug = PG { { 384, 124 }, { 448, 124 }, { 456, 130 }, { 376, 130 } }
rug:each(function(x, y) local col = "#a83a44" if y == 124 or y == 130 then col = "#5a1e2c" elseif (x + y) % 6 == 0 then col = "#e8b84a" end px(x, y, col) end)
local p1 = R(377, 78, 380, 128) solid(p1, WOOD) local p2 = R(452, 78, 455, 128) solid(p2, WOOD)
local can = PG { { 414, 48 }, { 370, 80 }, { 460, 80 } }
can:each(function(x, y)
  local k = floor((atan(y - 46, x - 414) / pi) * 16)
  local col = (k % 2 == 0) and MINT.b or CRM.b
  if x > 414 + (y - 48) * .35 then col = (col == MINT.b) and MINT.s or CRM.s end
  if y < 60 and x < 414 and x > 414 - (y - 48) * 1.0 then col = (col == MINT.b) and MINT.h or CRM.h end
  px(x, y, col)
end)
edge(can, MINT.d)
for x = 370, 460 do
  local k, dd = floor((x - 370) / 8), 4 - abs(((x - 370) % 8) - 4)
  for y = 80, 80 + dd do px(x, y, (k % 2 == 0) and MINT.s or CRM.s) end
  px(x, 81 + dd, MINT.d)
end
-- icon: big brass teapot sign with a mint sprig, hanging from the valance
vline(406, 85, 89, "#7a4a1e") vline(422, 85, 89, "#7a4a1e")
glow(414, 98, 14, .15)
teapot(414, 98, 2, BRASS)
local leaf = PG { { 412, 84 }, { 418, 81 }, { 422, 83 }, { 416, 87 } } solid(leaf, PALM)
-- quirk: a teapot weathervane on the tent peak, puffing a little steam curl
vline(414, 41, 48, "#7a4a1e")
teapot(414, 38, 1, BRASS)
for _, p in ipairs({ { 423, 33 }, { 424, 32 }, { 424, 31 }, { 423, 30 }, { 424, 29 }, { 425, 28 } }) do px(p[1], p[2], "#f8eed4") end

---------------------------------------------------------------- NOTICE BOARD (mid left)  box [126,90,172,143]
shadow({ { 132, 142 }, { 168, 142 }, { 182, 147 }, { 142, 148 } }, .3)
solid(R(132, 100, 135, 142), WOOD) solid(R(163, 100, 166, 142), WOOD)
solid(R(129, 104, 169, 134), WOOD)
R(132, 107, 166, 131):each(function(x, y) local n = hash(x, y, 17) px(x, y, n < .12 and "#b07a48" or (n > .9 and "#dca870" or "#c89058")) end)
for _, pp in ipairs({ { 134, 109, 9, 11, "#f2e6c8", "#c8484a" }, { 146, 108, 9, 8, "#d8e8f4", "#3a62a8" }, { 158, 110, 7, 12, "#f4e0b0", "#4c9a42" },
                      { 134, 122, 11, 7, "#d8ecd8", "#e8b040" }, { 148, 119, 7, 10, "#f6d0c0", "#3a62a8" }, { 158, 124, 7, 6, "#f2e6c8", "#c8484a" } }) do
  local m = R(pp[1], pp[2], pp[1] + pp[3] - 1, pp[2] + pp[4] - 1) fill(m, pp[5]) edge(m, mix(pp[5], "#4a3040", .45))
  for y = pp[2] + 3, pp[2] + pp[4] - 3, 2 do hline(pp[1] + 2, pp[1] + pp[3] - 3 - (y % 3), y, mix(pp[5], "#4a3040", .3)) end
  for x = pp[1] + 1, pp[1] + pp[3] do tint(x, pp[2] + pp[4], SHADE_TO, .3) end
  px(pp[1] + floor(pp[3] / 2), pp[2] + 1, pp[6]) px(pp[1] + floor(pp[3] / 2), pp[2] + 2, mix(pp[6], "#2a1828", .4))
end
-- curling corner of a sketch map flapping in the dune wind
local curl = PG { { 160, 116 }, { 165, 116 }, { 165, 121 } } fill(curl, "#c8b48a") edge(curl, "#8a6a4a")
local roof = PG { { 125, 105 }, { 149, 91 }, { 173, 105 } }
roof:each(function(x, y) local col = "#3a62a8" if (y - 91) % 3 == 2 then col = "#2a4a88" elseif x < 149 and (y - 91) % 3 == 0 then col = "#5a86c8" end px(x, y, col) end)
edge(roof, "#1e3460") vline(149, 87, 91, "#c88a2e") px(149, 86, "#f6d46a")
hline(126, 172, 105, "#1e3460")

---------------------------------------------------------------- SHOPS: seed shop (mid right)  box [294,78,360,142]
local LAV = { d = "#3e3060", s = "#6e5c96", b = "#9a86c4", h = "#bcaee2" }
shadow({ { 306, 139 }, { 358, 139 }, { 370, 145 }, { 314, 146 } }, .3)
local sside = PG(sidePts(306, 92, 138, 10))
wall(sside, { d = "#2e2448", s = "#4e406e", b = "#6e5c96", h = "#8270aa" }, "plaster", 12) edge(sside, "#2e2448")
dome(331, 92, 13, 9, { d = "#1e5a5a", s = "#2e8a84", b = "#46b0a6", h = "#8ad8c8" }, .3)
local sfac = R(306, 92, 357, 138) wall(sfac, LAV, "plaster", 44) edge(sfac, LAV.d)
mosaic(307, 94, 356, 98, "#c8484a", "#e8b84a", "#f0dcb0")
-- icon sign: sprouting seed on a cream board
local sb = R(320, 100, 342, 110) solid(sb, CRM)
vline(331, 103, 108, "#3a7a34")
local l1 = PG { { 331, 105 }, { 325, 101 }, { 324, 103 }, { 329, 106 } } fill(l1, "#5aae48")
local l2 = PG { { 332, 104 }, { 338, 100 }, { 339, 102 }, { 333, 106 } } fill(l2, "#4c9a42")
rect(330, 108, 332, 109, "#8a5a2a")
-- striped awning
local aw = PG { { 304, 111 }, { 359, 111 }, { 362, 119 }, { 301, 119 } }
aw:each(function(x, y) local col = (floor((x - 300) / 4) % 2 == 0) and "#e07a3a" or "#f2dcb0" if y >= 117 then col = mix(col, SHADE_TO, .2) end px(x, y, col) end)
edge(aw, "#7a3a1e")
for x = 301, 362 do local dd = 2 - abs(((x - 301) % 4) - 2) for y = 120, 120 + dd do px(x, y, (floor((x - 301) / 4) % 2 == 0) and "#c8602a" or "#d8c49a") end end
local sop = R(310, 122, 353, 130)
sop:each(function(x, y) px(x, y, y < 125 and "#2e2440" or "#3a2e4e") end)
for i = 0, 9 do local jx = 312 + i * 4 local jc = ({ "#c8484a", "#e8b040", "#5aae48", "#8a5a2a", "#e07a3a" })[i % 5 + 1] rect(jx, 126, jx + 2, 129, jc) px(jx, 126, "#f4e6c6") end
for x = 310, 353 do tint(x, 122, SHADE_TO, .35) end
local cnt = R(308, 131, 355, 138) wall(cnt, WOOD, "brick", 7) edge(cnt, WOOD.d)
for i, sc in ipairs({ { 312, "#c8484a" }, { 324, "#e8b040" }, { 336, "#5aae48" }, { 348, "#8a5a2a" } }) do
  local sk = PG { { sc[1] - 4, 133 }, { sc[1] + 5, 133 }, { sc[1] + 6, 141 }, { sc[1] - 5, 141 } }
  solid(sk, { d = "#6a4a2a", s = "#a07a4a", b = "#c8a070", h = "#e2c290" })
  rect(sc[1] - 3, 132, sc[1] + 4, 134, sc[2]) px(sc[1] - 2, 132, mix(sc[2], "#fbeed0", .5))
end
for _, pt in ipairs({ { 310, 88 }, { 352, 88 } }) do
  local pot = PG { { pt[1] - 3, pt[2] }, { pt[1] + 3, pt[2] }, { pt[1] + 2, pt[2] + 4 }, { pt[1] - 2, pt[2] + 4 } } solid(pot, { d = "#5a2a1a", s = "#9a4a2a", b = "#c0663a", h = "#e08a54" })
  frond(pt[1], pt[2] - 1, -140, 6, .5) frond(pt[1], pt[2] - 1, -40, 6, .5)
end

---------------------------------------------------------------- WILD TRAIL (right)  box [380,140,462,222]
local path = PG { { 352, 236 }, { 382, 216 }, { 404, 212 }, { 446, 212 }, { 446, 219 }, { 404, 221 }, { 384, 229 }, { 362, 240 } }
path:each(function(x, y) local n = hash(x, y, 31) px(x, y, n < .08 and "#b88a62" or (n > .93 and "#e8c896" or "#d09c6c")) end)
local ARC = { d = "#6e3e26", s = "#b06a3e", b = "#d4925a", h = "#ecb87c" }
shadow({ { 446, 220 }, { 461, 220 }, { 472, 227 }, { 452, 227 } }, .3)
local outer = archM(388, 142, 460, 220, 26)
local opn = archM(402, 156, 446, 220, 20)
opn:each(function(x, y) px(x, y, y < 172 and "#f4b46e" or (y < 184 and "#f8c87c" or "#fad692")) end)
local function vd(f, lit, sh, crest) for x = 402, 446 do local y0 = floor(f(x) + .5) local rs = f(x + 1) < f(x) + .05
  for y = y0, 220 do if opn:has(x, y) then px(x, y, (y == y0 and rs) and crest or (rs and lit or sh)) end end end end
vd(function(x) return 190 - 6 * sin((x - 402) / 7) end, "#e6a868", "#c48462", "#f6c890")
vd(function(x) return 203 - 4 * sin((x - 402) / 5 + 1) end, "#eebc80", "#d09a6c", "#f8d8a0")
local vp = PG { { 420, 220 }, { 434, 220 }, { 428, 204 }, { 425, 204 } } vp:clip(opn) fill(vp, "#d09c6c")
-- quirk: the dunes whisper (wind curls lifting off a crest)
for _, w in ipairs({ { 404, 186, 1 }, { 412, 182, 1 }, { 426, 196, 0 } }) do
  local x0, y0 = w[1], w[2]
  for k = 0, 14 do
    local x = x0 + k
    local y = y0 + floor(1.5 * sin(k / 2.2))
    if k > 10 then local a = (k - 10) * 1.2 x = x0 + 10 + floor(2 * sin(a)) y = y0 - floor(2 - 2 * cos(a)) end
    if opn:has(x, y) then px(x, y, "#fbe6b8") end
  end
end
local mas = outer:copy():cut(opn)
wall(mas, ARC, "stone", 61) edge(mas, ARC.d)
mas:each(function(x, y) if not mas:has(x - 1, y) and x > 420 then px(x, y, ARC.h) end end)
local ks = PG { { 424, 144 }, { 428, 148 }, { 424, 153 }, { 420, 148 } } fill(ks, "#3aa6a0") edge(ks, "#1e5a64") px(424, 148, "#e8b84a")
-- crumbled top notches
for _, nt in ipairs({ { 398, 152 }, { 452, 158 }, { 404, 147 } }) do rect(nt[1], nt[2], nt[1] + 2, nt[2] + 1, mix("#f4b46e", "#f8c87c", .3)) end
-- signpost with arrow boards (leaf icon = the wild, drop icon = water)
solid(R(410, 178, 413, 220), WOOD)
local ab = PG { { 403, 181 }, { 427, 181 }, { 433, 186 }, { 427, 191 }, { 403, 191 } } solid(ab, WOOD)
local lf = PG { { 413, 186 }, { 418, 183 }, { 422, 185 }, { 417, 188 } } fill(lf, "#4c9a42") edge(lf, "#21482c")
local ab2 = PG { { 405, 195 }, { 423, 195 }, { 428, 199 }, { 423, 203 }, { 405, 203 } } solid(ab2, { d = "#1e5a64", s = "#2e8a8a", b = "#3aa6a0", h = "#7ad0c4" })
local dr = PG { { 416, 196 }, { 418, 199 }, { 416, 201 }, { 414, 199 } } fill(dr, "#e8f0f4")
-- agave tuft at the pillar foot
for _, a in ipairs({ { -8, -10 }, { -4, -14 }, { 0, -16 }, { 4, -13 }, { 8, -9 }, { -6, -6 }, { 6, -6 } }) do
  c:line({ { 392, 220 }, { 392 + a[1], 220 + a[2] } }, 2):each(function(x, y) px(x, y, a[1] < 0 and "#7aae8a" or "#4e8a6a") end)
end

---------------------------------------------------------------- THE PALM COURT (centre, hero)  box [168,148,312,224]
shadow({ { 172, 222 }, { 308, 222 }, { 314, 226 }, { 178, 226 } }, .35)
local top = PG { { 196, 184 }, { 284, 184 }, { 308, 212 }, { 172, 212 } }
top:each(function(x, y)
  local d = y - 100
  local wx, wz = (x - VX) * 9 / d, 1400 / d
  local fx, fz = wx - floor(wx), wz - floor(wz)
  local dd = abs(fx - .5) + abs(fz - .5)
  local col = "#ecd6a8"
  if dd < .42 then col = ((floor(wx) + floor(wz)) % 2 == 0) and "#3a9aa0" or "#3a62a8" end
  if dd < .18 then col = "#e8b84a" end
  if fx < .07 or fz < .09 then col = "#c8a878" end
  px(x, y, col)
end)
edge(top, "#b07a3a") edge(top:shrink(1), "#e8b84a")
local front = R(172, 213, 308, 221) wall(front, { d = "#6a4630", s = "#b08a62", b = "#d8b88a", h = "#ecd2a2" }, "stone", 51)
mosaic(173, 215, 307, 219, "#3a62a8", "#e8b84a", "#3aa6a0") edge(front, "#6a4630")
-- side planters + palms
for _, sp in ipairs({ { 196, 186, 166, -6 }, { 284, 294, 166, 6 } }) do
  local pl = R(sp[1] - 7, 194, sp[1] + 7, 206)
  wall(pl, { d = "#1e3456", s = "#2a4a88", b = "#3a62a8", h = "#5a86c8" }, "brick", sp[1])
  hline(sp[1] - 7, sp[1] + 7, 199, "#e8b84a") edge(pl, "#1e3456")
  rect(sp[1] - 7, 192, sp[1] + 7, 194, "#e6d0a8") hline(sp[1] - 7, sp[1] + 7, 194, "#a08a70")
  palm(sp[1], 193, sp[2], sp[3], sp[4], 22)
end
-- central octagonal planter-fountain with the great palm
local pfront = PG { { 222, 188 }, { 258, 188 }, { 258, 200 }, { 253, 205 }, { 227, 205 }, { 222, 200 } }
wall(pfront, { d = "#1e3456", s = "#2a4a88", b = "#3a62a8", h = "#5a86c8" }, "brick", 77)
for x = 224, 256, 4 do px(x, 196, "#e8b84a") px(x + 1, 196, "#f6d46a") end
edge(pfront, "#1e3456")
local prim = PG { { 225, 183 }, { 255, 183 }, { 260, 188 }, { 220, 188 } } fill(prim, "#e6d0a8") edge(prim, "#8a7460")
hline(224, 256, 185, "#2f8aa4") hline(226, 254, 186, "#62c4d0")
for _, sx in ipairs({ 228, 252 }) do vline(sx, 178, 184, "#62c4d0") px(sx, 177, "#c8f0f0") px(sx - 1, 179, "#2f8aa4") px(sx + 1, 179, "#2f8aa4") end
palm(240, 186, 238, 158, 3, 30)
-- lantern posts at the court's front corners
for _, lx in ipairs({ 176, 304 }) do solid(R(lx - 1, 196, lx + 1, 212), WOOD) lantern(lx, 188, 188, false) end
for _, fl in ipairs({ { 206, 208 }, { 274, 208 } }) do
  local pot = PG { { fl[1] - 4, fl[2] - 4 }, { fl[1] + 4, fl[2] - 4 }, { fl[1] + 3, fl[2] + 2 }, { fl[1] - 3, fl[2] + 2 } }
  solid(pot, { d = "#5a2a1a", s = "#9a4a2a", b = "#c0663a", h = "#e08a54" })
  for k = -3, 3, 2 do px(fl[1] + k, fl[2] - 5, "#c8484a") px(fl[1] + k + 1, fl[2] - 6, "#4c9a42") end
end

---------------------------------------------------------------- OASIS: pool + bottomless well (front left)  box [16,150,120,258]
local pool = PG { { 24, 222 }, { 42, 215 }, { 70, 213 }, { 88, 218 }, { 96, 230 }, { 90, 244 }, { 70, 251 }, { 42, 250 }, { 26, 243 }, { 20, 232 } }
local rim = pool:grow(3)
rim:shift(3, 2):each(function(x, y) if not rim:has(x, y) then tint(x, y, SHADE_TO, .3) end end)
for i = 0, 40 do local gx, gy = 18 + floor(hash(i, 1, 5) * 90), 208 + floor(hash(i, 2, 5) * 48)
  if not rim:has(gx, gy) and rim:grow(4):has(gx, gy) then px(gx, gy, "#7aae4a") px(gx, gy - 1, "#5a9a3e") px(gx + 1, gy - 2, "#86c45a") end end
local rimR = rim:copy():cut(pool)
rimR:each(function(x, y) local k = floor((atan(y - 232, x - 58) + pi) * 9 / pi) px(x, y, (k % 2 == 0) and STN.b or STN.h) if hash(x, y, 2) < .1 then px(x, y, STN.s) end end)
edge(rim, STN.d)
pool:each(function(x, y)
  local col = "#2f8aa4"
  if not pool:has(x, y - 3) then col = "#1e5a74" end
  if y % 5 == 0 and hash(floor(x / 6), y, 2) > .5 then col = "#e8a070" end
  if y % 4 == 2 and hash(floor(x / 4), y, 4) > .75 then col = "#62c4d0" end
  px(x, y, col)
end)
for _, lp2 in ipairs({ { 40, 236 }, { 62, 244 }, { 76, 232 } }) do
  local m = PG { { lp2[1] - 4, lp2[2] }, { lp2[1], lp2[2] - 2 }, { lp2[1] + 4, lp2[2] }, { lp2[1], lp2[2] + 2 } } fill(m, "#4c9a42") edge(m, "#21482c")
  px(lp2[1], lp2[2] - 1, "#f08aa0") px(lp2[1] + 1, lp2[2] - 1, "#f8b8c4")
end
for _, rd in ipairs({ { 22, 226 }, { 25, 224 }, { 92, 236 }, { 94, 240 }, { 88, 246 } }) do
  vline(rd[1], rd[2] - 10, rd[2], "#4c9a42") vline(rd[1] + 1, rd[2] - 7, rd[2], "#346f3a") rect(rd[1], rd[2] - 13, rd[1] + 1, rd[2] - 10, "#8a5a2a")
end
palm(58, 213, 66, 172, -3, 24)
palm(28, 240, 34, 166, -8, 28)
-- the deep stone well
shadow({ { 96, 228 }, { 120, 228 }, { 128, 234 }, { 104, 234 } }, .32)
local wb = R(94, 204, 118, 228) wall(wb, STN, "stone", 71)
for y = 204, 228 do tint(116, y, SHADE_TO, .25) tint(117, y, SHADE_TO, .3) end
edge(wb, STN.d)
local wt = PG { { 93, 200 }, { 98, 196 }, { 114, 196 }, { 119, 200 }, { 119, 204 }, { 114, 208 }, { 98, 208 }, { 93, 204 } } fill(wt, STN.h) edge(wt, STN.d)
local mouth = PG { { 98, 200 }, { 101, 198 }, { 111, 198 }, { 114, 200 }, { 114, 203 }, { 111, 205 }, { 101, 205 }, { 98, 203 } } fill(mouth, "#20163a")
hline(101, 111, 199, "#3a2a5a")
-- quirk: a bottomless well -- a tiny star twinkles far down inside
px(106, 202, "#fbe9a0") px(105, 202, "#a888e0") px(107, 202, "#a888e0") px(106, 201, "#a888e0") px(106, 203, "#a888e0")
solid(R(95, 170, 97, 199), WOOD) solid(R(115, 170, 117, 199), WOOD)
solid(R(91, 168, 121, 171), WOOD)
local wr = PG { { 87, 169 }, { 106, 156 }, { 125, 169 } }
wr:each(function(x, y) local col = "#c0603e" if (y - 156) % 3 == 2 then col = "#8a3e2a" elseif x < 106 and (y - 156) % 3 == 0 then col = "#e0845a" end px(x, y, col) end)
edge(wr, "#5a2a1e")
vline(106, 172, 186, "#c8a070")
local bucket = PG { { 102, 186 }, { 111, 186 }, { 110, 194 }, { 103, 194 } } solid(bucket, WOOD) hline(103, 110, 189, BRASS.b)
-- a coin mid-toss, glinting
rect(110, 178, 111, 179, GOLD.b) px(110, 178, GOLD.h) px(111, 179, GOLD.s) px(113, 176, "#fbe9a0") px(113, 175, "#f6d46a") px(114, 176, "#f6d46a")

---------------------------------------------------------------- gate frame (desert arch) + bunting + lanterns
local function bunting(x0, x1, ya, sag)
  local cols = { "#c8484a", "#3aa0a0", "#e8b040", "#3a62b0", "#f0dcb0", "#8a4aa0" }
  local function sy(x) local t = (x - (x0 + x1) / 2) / ((x1 - x0) / 2) return ya + sag * (1 - t * t) end
  for x = x0, x1 do px(x, floor(sy(x)), "#5a3a30") end
  local k = 0
  for x = x0 + 6, x1 - 6, 13 do
    k = k + 1
    local y, col = floor(sy(x)) + 1, cols[(k - 1) % #cols + 1]
    local m = PG { { x - 4, y }, { x + 5, y }, { x + .5, y + 8 } }
    fill(m, col)
    m:each(function(a, b) if a > x then px(a, b, mix(col, SHADE_TO, .22)) end end)
    edge(m, mix(col, "#2a1828", .5))
  end
end
bunting(20, 460, 21, 9)
local spand = M(function(x, y)
  local d = abs(x - 239.5) / 222
  if d >= 1 then return true end
  return y < 14 + 34 * (1 - sqrt(1 - d))
end, 0, 0, W - 1, 60)
wall(spand, SST, "stone", 41)
spand:each(function(x, y) if not spand:has(x, y + 3) then px(x, y, (floor(x / 7) % 2 == 0) and "#b8524a" or "#f0dcb0") end end)
spand:each(function(x, y) if not spand:has(x, y + 1) then px(x, y, "#5a2a2a") end end)
-- lintel: sandstone course, mosaic band, carved beam
rect(0, 0, W - 1, 4, SST.b) for x = 0, W - 1, 10 do vline(x, 0, 4, SST.s) end hline(0, W - 1, 4, SST.s) hline(0, W - 1, 0, SST.h)
mosaic(0, 5, W - 1, 9)
for x = 0, W - 1 do for y = 10, 13 do px(x, y, (y == 10) and WOOD.h or ((y == 13) and WOOD.d or ((x % 16 == 0) and WOOD.s or WOOD.b))) end end
for x = 8, W - 1, 32 do px(x, 11, BRASS.h) px(x, 12, BRASS.s) end
local function pillar(x0, x1, inner)
  local m = R(x0, 0, x1, H - 1) wall(m, SST, "stone", x0 + 3)
  for y = 56, 238 do for x = x0 + 3, x1 - 3 do
    local col
    if x == x0 + 3 or x == x1 - 3 or y == 56 or y == 238 then col = "#e8b84a"
    elseif x == x0 + 4 or x == x1 - 4 then col = "#1e3a6a"
    else local v = (y + floor(abs(x - (x0 + x1) / 2))) % 8 col = v < 2 and "#2e5aa0" or (v < 3 and "#f0dcb0" or (v < 5 and "#3aa6a0" or "#f0dcb0")) end
    px(x, y, col)
  end end
  local cx0, cx1 = (inner > x0) and x0 or x0 - 4, (inner > x0) and x1 + 4 or x1
  local cap = R(cx0, 46, cx1, 53) solid(cap, SST) hline(cx0 + 1, cx1 - 1, 49, "#b8524a")
  local base = R(cx0, 244, cx1, H - 1) solid(base, SST)
  if inner > x0 then for y = 0, H - 1 do tint(x1 - 1, y, SHADE_TO, .25) tint(x1 - 2, y, SHADE_TO, .15) end
  else for y = 54, 243 do px(x0 + 1, y, SST.h) end end
  vline(inner, 0, H - 1, SST.d)
end
pillar(0, 17, 17)
pillar(462, 479, 462)
lantern(46, 44, 36, true)
lantern(434, 44, 36, true)

c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

---------------------------------------------------------------- layout
local spots = {
  { "green", "The Palm Court", { 168, 148, 312, 224 } },
  { "tea", "The Mint Tent", { 372, 40, 458, 128 } },
  { "board", "Notice Board", { 126, 90, 172, 143 } },
  { "library", "Library", { 22, 34, 118, 132 } },
  { "s1", "Oasis", { 16, 150, 120, 258 } },
  { "s2", "Bazaar", { 196, 34, 284, 128 } },
  { "shops", "Shops", { 294, 78, 360, 142 } },
  { "wild", "Wild Trail", { 380, 140, 462, 222 } },
}
local stand = { { 158, 246 }, { 240, 248 }, { 322, 246 }, { 348, 164 }, { 352, 200 }, { 240, 137 } }
local parts = {}
for _, s in ipairs(spots) do
  local b = s[3]
  parts[#parts + 1] = string.format('{"k":"%s","name":"%s","x":%d,"y":%d,"box":[%d,%d,%d,%d]}', s[1], s[2], floor((b[1] + b[3]) / 2), floor((b[2] + b[4]) / 2), b[1], b[2], b[3], b[4])
end
local st = {}
for _, p in ipairs(stand) do st[#st + 1] = string.format('{"x":%d,"y":%d}', p[1], p[2]) end
local f = io.open(OUT .. NAME .. ".layout.json", "w")
f:write(string.format('{"w":480,"h":270,"horizon":%d,"view":"gate","spots":[%s],"stand":[%s],"compass_clear":[380,230,480,270]}\n', HZ, table.concat(parts, ","), table.concat(st, ",")))
f:close()
print("ok " .. NAME)
