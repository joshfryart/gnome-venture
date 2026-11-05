-- finish5 maps-b: second RICHNESS pass on 7 region maps (480x270). Param: name=<MENA|WCA|ESA|CSA|EA|SEA|OC|all>, out=<dir>/
-- Base = the live PNG before this pass (copied to base/). Composition, paths, water, cave edge and the market village
-- are kept; landmarks and biome texture are added only on plain floor/rock away from every layout marker
-- (tools/map_layout.lua: clear circles + road and trail lines). Hard pixels, ink rim on landmarks, lit upper-left.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local LAY = dofile(d .. "/../../../../tools/map_layout.lua").regions
local OUT = app.params.out or (d .. "/out/")
local NAME = app.params.name or "all"
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local W, H = 480, 270
local INK = "#2b1c26"

local function hash(x, y, s)
  local n = (x * 374761393 + y * 668265263 + (s or 0) * 2147483647) % 4294967296
  n = ((n ~ (n >> 13)) * 1274126177) % 4294967296
  return ((n ~ (n >> 16)) % 65536) / 65536
end
local function vn(x, y, sc, s)
  local gx, gy = x / sc, y / sc
  local x0, y0 = floor(gx), floor(gy)
  local fx, fy = gx - x0, gy - y0
  fx = fx * fx * (3 - 2 * fx); fy = fy * fy * (3 - 2 * fy)
  local a, b = hash(x0, y0, s), hash(x0 + 1, y0, s)
  local c, e = hash(x0, y0 + 1, s), hash(x0 + 1, y0 + 1, s)
  return (a + (b - a) * fx) * (1 - fy) + (c + (e - c) * fx) * fy
end
local function rgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
local function hex(r, g, b) return string.format("#%02x%02x%02x", r, g, b) end
local function mix(a, b, t)
  local r1, g1, b1 = rgb(a); local r2, g2, b2 = rgb(b)
  return hex(floor(r1 + (r2 - r1) * t + .5), floor(g1 + (g2 - g1) * t + .5), floor(b1 + (b2 - b1) * t + .5))
end
local function set(t) local s = {} for _, k in ipairs(t) do s[k] = true end return s end

-- ramps {hi, base, shade, deep}
local RP = {
  adobe = { "#f6dcaa", "#dcae74", "#ac7a4c", "#744c34" },
  sand  = { "#fae6b0", "#e8c47a", "#c49450", "#8a6236" },
  palm  = { "#b8e070", "#6cb04a", "#3a8044", "#22503c" },
  trunk = { "#d8a070", "#a8703f", "#764a30", "#4a2e28" },
  water = { "#b6f0e0", "#5fc4c8", "#3a86b0", "#2a4a7a" },
  jungle= { "#9ad870", "#4aa04c", "#2a7044", "#174434" },
  kapok = { "#c4e47e", "#78b850", "#468a46", "#24563c" },
  thatch= { "#f4d27a", "#d4a046", "#a07030", "#664424" },
  mud   = { "#e0a678", "#b87850", "#8a5038", "#5a3028" },
  olive = { "#d4d878", "#9aa848", "#667a34", "#3c4a2a" },
  baob  = { "#d6bca8", "#a88c7a", "#7a6058", "#4c3a40" },
  termit= { "#eca878", "#c46e42", "#904a32", "#5c2c28" },
  stone = { "#e8e4ea", "#b0aec0", "#787a92", "#484a68" },
  wstone= { "#ead6c0", "#bca08c", "#8a6e64", "#56404a" },
  snow  = { "#f8f4ea", "#d8e2ee", "#a8b8d0", "#7a88a8" },
  stupa = { "#faf2de", "#e2d6bc", "#b4a48a", "#7a6a5c" },
  gold  = { "#ffe38a", "#f5b82e", "#d98322", "#8f4a1f" },
  terr  = { "#c8e88a", "#88c45a", "#4e9248", "#2e5e3e" },
  paddy = { "#d0f4dc", "#8cd4c0", "#58a8a8", "#2e6e78" },
  bamboo= { "#c8e488", "#80bc50", "#4c8a40", "#2c5a36" },
  cherry= { "#ffd8e6", "#f5a0bc", "#d06890", "#8a3a64" },
  roofEA= { "#7ec0d0", "#3a8aa8", "#2a5a80", "#1e3a5a" },
  roofR = { "#ff9a6a", "#e0583a", "#b03a36", "#6e2034" },
  plaster={ "#fff0d8", "#f0d0a8", "#c89a78", "#8a6050" },
  mang  = { "#8ec46a", "#4e8e4a", "#2e6a42", "#1c4436" },
  ochre = { "#f4a878", "#d4643c", "#a6402e", "#6a2a2a" },
  slate = { "#a8b8d8", "#6e80a8", "#4a5880", "#2e3858" },
  yak   = { "#8a6a5a", "#5e463e", "#3e2e30", "#2e2028" },
  buff  = { "#9a9aa8", "#6e6e82", "#4c4c62", "#34344a" },
  camel = { "#f0c88a", "#d09c5c", "#a07040", "#6a4830" },
  giraffe={ "#ffe08a", "#eab450", "#c08030", "#7a4c26" },
  crane = { "#fbf4e6", "#e6dccc", "#b8acb0", "#7a7088" },
  parrot= { "#ff8a5c", "#e8493b", "#b52e3f", "#6e2038" },
}

-------------------------------------------------------------- per-map state
local pix, cls, hard, soft, inkNear, occ
local function I(x, y) return y * W + x end
local function inb(x, y) return x >= 0 and y >= 0 and x < W and y < H end
local function get(x, y) if inb(x, y) then return pix[I(x, y)] end end
local function put(x, y, c) if inb(x, y) and c then pix[I(x, y)] = c end end

-- masks: tables keyed by index
local function M() return {} end
local function mset(m, x, y) if inb(x, y) then m[I(x, y)] = true end end
local function ell(m, cx, cy, rx, ry)
  for y = floor(cy - ry - 1), floor(cy + ry + 1) do for x = floor(cx - rx - 1), floor(cx + rx + 1) do
    local a, b = (x - cx) / (rx + .35), (y - cy) / (ry + .35)
    if a * a + b * b <= 1 then mset(m, x, y) end
  end end
  return m
end
local function rect(m, x0, y0, x1, y1) for y = y0, y1 do for x = x0, x1 do mset(m, x, y) end end return m end
local function poly(m, pts)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for _, p in ipairs(pts) do x0 = min(x0, p[1]); y0 = min(y0, p[2]); x1 = max(x1, p[1]); y1 = max(y1, p[2]) end
  for y = floor(y0), floor(y1) do for x = floor(x0), floor(x1) do
    local px, py, inside = x + .5, y + .5, false
    local j = #pts
    for i = 1, #pts do
      local a, b = pts[i], pts[j]
      if ((a[2] > py) ~= (b[2] > py)) and (px < (b[1] - a[1]) * (py - a[2]) / (b[2] - a[2]) + a[1]) then inside = not inside end
      j = i
    end
    if inside then mset(m, x, y) end
  end end
  return m
end
local function line(m, x0, y0, x1, y1, th)
  x0, y0, x1, y1 = floor(x0 + .5), floor(y0 + .5), floor(x1 + .5), floor(y1 + .5)
  local dx, dy = abs(x1 - x0), -abs(y1 - y0)
  local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
  local err = dx + dy
  while true do
    mset(m, x0, y0); if th then mset(m, x0 + 1, y0) end
    if x0 == x1 and y0 == y1 then break end
    local e2 = 2 * err
    if e2 >= dy then err = err + dy; x0 = x0 + sx end
    if e2 <= dx then err = err + dx; y0 = y0 + sy end
  end
  return m
end
local function each(m, f) for i in pairs(m) do f(i % W, i // W) end end
local function union(list) local u = {} for _, m in ipairs(list) do for i in pairs(m) do u[i] = true end end return u end
local function rim(u, col)
  local r = {}
  for i in pairs(u) do
    local x, y = i % W, i // W
    for _, o in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
      local xx, yy = x + o[1], y + o[2]
      if inb(xx, yy) and not u[I(xx, yy)] then r[I(xx, yy)] = true end
    end
  end
  for i in pairs(r) do pix[i] = col or INK end
end
-- lit fill: light from the upper left around (cx, cy)
local function fill(m, R, cx, cy, rx, ry, speck, sd)
  each(m, function(x, y)
    local l = -((x - cx) / max(1, rx) + (y - cy) / max(1, ry)) * .5
    local k = l > .32 and 1 or (l > -.12 and 2 or (l > -.52 and 3 or 4))
    if speck and hash(x, y, sd or 7) > 1 - speck then k = max(1, min(4, k + (hash(x, y, (sd or 7) + 1) > .5 and 1 or -1))) end
    put(x, y, R[k])
  end)
end
local function solid(m, c) each(m, function(x, y) put(x, y, c) end) end
-- draw parts with one ink rim round the union; parts = { {mask, fn} }
local function obj(parts, norim)
  local ms = {}
  for _, p in ipairs(parts) do ms[#ms + 1] = p[1] end
  local u = union(ms)
  if not norim then rim(u) end
  for _, p in ipairs(parts) do p[2](p[1]) end
  return u
end
local function smoke(x, y, s)
  local cs = { "#d6ccd0", "#b8aebc", "#9e94a8" }
  local dx = 0
  for k = 0, 2 do
    local yy = y - 1 - k * 3
    dx = dx + ((hash(k, s, 3) > .5) and 1 or 0)
    put(x + dx, yy, cs[k + 1]); put(x + dx + 1, yy, cs[k + 1]); put(x + dx, yy - 1, cs[k + 1])
    if k > 0 then put(x + dx + 1, yy - 1, cs[k + 1]) end
  end
end
local function shadowBlob(x, y, rx)   -- soft contact shadow on the floor (one darker tone, hard pixels)
  for xx = x - rx, x + rx do for yy = y, y + 1 do
    if inb(xx, yy) and cls[I(xx, yy)] == 1 and (yy == y or abs(xx - x) < rx - 1) then put(xx, yy, mix(get(xx, yy), "#3a2a50", .28)) end
  end end
end

-------------------------------------------------------------- landmarks
local L = {}
function L.palm(x, y, s, h)
  h = h or (9 + floor(hash(s, 1, 2) * 4))
  local lean = hash(s, 2, 2) > .5 and 1 or -1
  local tr = M()
  local tx, ty = x, y
  for i = 0, h do tx = x + floor(lean * (i * i) / (h * h) * 3 + .5); ty = y - i; mset(tr, tx, ty) end
  local fr = M()
  local fronds = { { -6, 2 }, { -5, -2 }, { -1, -4 }, { 4, -3 }, { 6, 2 } }
  for _, f in ipairs(fronds) do
    line(fr, tx, ty, tx + f[1], ty + f[2] - 1)
    mset(fr, tx + f[1], ty + f[2]); mset(fr, tx + f[1] + (f[1] > 0 and -1 or 1), ty + f[2])
    line(fr, tx + (f[1] > 0 and 1 or -1), ty, tx + f[1] - (f[1] > 0 and 1 or -1), ty + f[2])
  end
  shadowBlob(x + 1, y + 1, 3)
  obj({ { tr, function(m) each(m, function(px, py) put(px, py, (py % 2 == 0) and RP.trunk[2] or RP.trunk[3]) end) end },
        { fr, function(m) fill(m, RP.palm, tx - 1, ty - 1, 5, 3) end } })
  put(tx - 1, ty + 1, RP.trunk[4]); put(tx + 1, ty + 1, RP.trunk[3])
end
function L.oasis(x, y, s)
  local g = ell(M(), x, y - 2, 11, 4)
  local w = ell(M(), x, y - 2, 7, 2)
  obj({ { g, function(m) fill(m, RP.palm, x - 3, y - 4, 10, 4, .18, s) end } }, true)
  each(g, function(px, py) local o = g[I(px, py + 1)] and g[I(px, py - 1)] and g[I(px - 1, py)] and g[I(px + 1, py)]; if not o then put(px, py, RP.palm[4]) end end)
  obj({ { w, function(m) fill(m, RP.water, x - 2, y - 3, 7, 2) end } })
  put(x - 3, y - 3, RP.water[1]); put(x - 2, y - 3, RP.water[1]); put(x + 2, y - 2, RP.water[1])
  L.palm(x - 7, y - 3, s + 1, 11); L.palm(x + 6, y - 4, s + 2, 9); L.palm(x + 9, y, s + 3, 7)
end
function L.dune(x, y, s)
  local w, h = 12 + floor(hash(s, 3, 1) * 5), 6 + floor(hash(s, 4, 1) * 3)
  local m = poly(M(), { { x - w, y }, { x - w + 4, y - h + 2 }, { x - 1, y - h }, { x + 3, y - h + 1 }, { x + w, y } })
  local crest = function(px, py) return px - x < (y - py) * .9 - 2 end
  each(m, function(px, py)
    local c = crest(px, py) and RP.sand[1] or "#b88650"
    if (py + floor(px * .3)) % 3 == 0 and hash(px, py, s) > .3 then c = crest(px, py) and RP.sand[2] or "#946a40" end
    put(px, py, c)
  end)
  rim(m, "#7a5234")
  for xx = x - w + 2, x + w - 1 do if inb(xx, y + 1) and cls[I(xx, y + 1)] == 1 then put(xx, y + 1, mix(get(xx, y + 1), "#3a2a50", .3)) end end
end
function L.mudhouse(x, y, s, dome)
  local wall = rect(M(), x - 4, y - 6, x + 4, y)
  local roof = rect(M(), x - 5, y - 7, x + 5, y - 7)
  local parts = { { wall, function(m) fill(m, RP.adobe, x - 3, y - 5, 4, 3) end }, { roof, function(m) solid(m, RP.adobe[1]) end } }
  if dome then parts[#parts + 1] = { ell(M(), x - 1, y - 9, 3, 2.6), function(m) each(m, function(px, py) if py <= y - 8 then put(px, py, (px < x - 1) and "#f2e0c0" or "#c8a888") end end) end } end
  obj(parts)
  if dome then for xx = x - 4, x + 2 do if get(xx, y - 6) == INK then end end end
  put(x - 1, y - 2, RP.adobe[4]); put(x - 1, y - 1, RP.adobe[4]); put(x, y - 2, RP.adobe[4]); put(x, y - 1, RP.adobe[4])
  put(x + 2, y - 4, RP.adobe[4]); put(x + 3, y - 4, RP.adobe[4]); put(x - 3, y - 4, "#5a3a40")
end
function L.mudvillage(x, y, s)
  L.mudhouse(x - 7, y - 1, s, true); L.mudhouse(x + 6, y - 4, s + 1, false); L.mudhouse(x + 2, y + 3, s + 2, false)
  smoke(x + 9, y - 12, s)
end
function L.camel(x, y, s)
  local b = ell(M(), x, y - 4, 4, 2)
  ell(b, x - 1, y - 6, 1.5, 1.5)
  local legs = M(); for _, lx in ipairs({ x - 3, x - 1, x + 2, x + 3 }) do rect(legs, lx, y - 2, lx, y) end
  local neck = M(); line(neck, x + 4, y - 4, x + 6, y - 7); rect(neck, x + 6, y - 8, x + 7, y - 7)
  obj({ { legs, function(m) solid(m, RP.camel[3]) end }, { b, function(m) fill(m, RP.camel, x - 1, y - 5, 4, 2) end },
        { neck, function(m) fill(m, RP.camel, x + 5, y - 7, 2, 2) end } })
  put(x + 7, y - 8, INK)
end
function L.caravan(x, y, s) L.camel(x - 9, y, s); L.camel(x, y - 1, s + 1); L.camel(x + 9, y, s + 2) end
function L.fossil(x, y, s, R)   -- ribcage + skull in the rock (back plane, no ink)
  local c1, c2 = "#a08890", "#76606e"
  for k = 0, 4 do
    local xx = x - 4 + k * 2
    put(xx, y - 2, c1); put(xx, y - 1, c1); put(xx, y, c2); put(xx + 1, y + 1, c2)
  end
  for xx = x - 5, x + 5 do put(xx, y - 3, c1) end
  put(x + 6, y - 4, c1); put(x + 7, y - 4, c1); put(x + 7, y - 3, c2); put(x + 6, y - 3, c1); put(x + 8, y - 3, c1)
end
function L.amphora(x, y, s)
  local m = ell(M(), x, y - 3, 2, 3); rect(m, x, y - 7, x, y - 6); rect(m, x - 1, y - 8, x + 1, y - 8)
  obj({ { m, function(mm) fill(mm, RP.ochre, x - 1, y - 4, 2, 3) end } })
  put(x + 2, y - 2, "#3a2430")   -- crack
end
-- rainforest
function L.canopy(x, y, s, r, R)
  r = r or (5 + floor(hash(s, 5, 1) * 3)); R = R or RP.jungle
  local tr = rect(M(), x - 1, y - 4, x, y)
  local cr = ell(M(), x, y - r - 3, r, r - 1)
  ell(cr, x - r + 1, y - r, r - 2, r - 3); ell(cr, x + r - 1, y - r, r - 2, r - 3); ell(cr, x - 1, y - floor(r * 1.7) - 2, r - 2, r - 3)
  shadowBlob(x, y + 1, r - 1)
  obj({ { tr, function(m) fill(m, RP.trunk, x - 1, y - 3, 1, 2) end }, { cr, function(m) fill(m, R, x - 2, y - r - 4, r, r, .22, s) end } })
  return x, y - r * 2 - 3
end
function L.kapok(x, y, s)
  local tr = poly(M(), { { x - 4, y }, { x - 1, y - 4 }, { x - 1, y - 14 }, { x + 1, y - 14 }, { x + 1, y - 4 }, { x + 4, y } })
  local cr = ell(M(), x, y - 18, 12, 3); ell(cr, x - 6, y - 20, 5, 3); ell(cr, x + 5, y - 21, 6, 3); ell(cr, x, y - 22, 5, 2)
  shadowBlob(x, y + 1, 5)
  obj({ { tr, function(m) fill(m, RP.baob, x - 1, y - 8, 2, 6) end }, { cr, function(m) fill(m, RP.kapok, x - 3, y - 21, 10, 3, .25, s) end } })
  -- the quirk: a red parrot on the crown
  local px, py = x + 7, y - 24
  local p = rect(M(), px, py - 2, px + 1, py); mset(p, px + 2, py + 1)
  obj({ { p, function(m) fill(m, RP.parrot, px, py - 2, 1, 1) end } })
  put(px + 2, py + 1, "#3a86b0"); put(px - 1, py - 1, "#f5b82e")
end
function L.roundhut(x, y, s, R)
  local wall = rect(M(), x - 3, y - 3, x + 3, y)
  local roof = poly(M(), { { x - 5.5, y - 2.5 }, { x, y - 9 }, { x + 5.5, y - 2.5 } })
  obj({ { wall, function(m) fill(m, RP.mud, x - 2, y - 2, 3, 2) end },
        { roof, function(m) fill(m, R or RP.thatch, x - 2, y - 6, 4, 3); each(m, function(px, py) if (px + py) % 3 == 0 and hash(px, py, s) > .4 then put(px, py, (R or RP.thatch)[3]) end end) end } })
  put(x, y - 1, RP.mud[4]); put(x, y, RP.mud[4])
end
function L.hutvillage(x, y, s, R)
  L.roundhut(x - 6, y - 2, s, R); L.roundhut(x + 6, y - 3, s + 1, R); L.roundhut(x, y + 2, s + 2, R)
  smoke(x + 7, y - 13, s)
end
function L.stream(x, y, s)   -- a short winding stream with a plank bridge
  local wm = M()
  for xx = x - 18, x + 18 do
    local yy = y + floor(2.5 * sin((xx - x) * .22 + s) + .5)
    mset(wm, xx, yy); mset(wm, xx, yy + 1)
  end
  rim(wm, "#1e3a3a")
  each(wm, function(px, py) put(px, py, (hash(px, py, s) > .8) and RP.water[1] or ((wm[I(px, py - 1)]) and RP.water[3] or RP.water[2])) end)
  local bx = x + floor(hash(s, 9, 1) * 8) - 4
  local by = y + floor(2.5 * sin((bx - x) * .22 + s) + .5)
  local b = rect(M(), bx - 2, by - 2, bx + 2, by + 3)
  obj({ { b, function(m) each(m, function(px, py) put(px, py, (py % 2 == 0) and RP.trunk[2] or RP.trunk[1]) end) end } })
  put(bx - 3, by - 2, RP.trunk[4]); put(bx + 3, by - 2, RP.trunk[4]); put(bx - 3, by + 3, RP.trunk[4]); put(bx + 3, by + 3, RP.trunk[4])
end
function L.vine(x, y, s)   -- hangs down from (x, y) through rock
  local n = 6 + floor(hash(s, 1, 9) * 10)
  for k = 0, n do
    local xx = x + floor(sin(k * .6 + s) * 1.3 + .5)
    local yy = y + k
    if inb(xx, yy) and cls[I(xx, yy)] == 2 and not hard[I(xx, yy)] then
      put(xx, yy, (k % 3 == 0) and "#4a8a44" or "#2e6a3c")
      if k % 4 == 2 then put(xx + 1, yy, "#7cc35a") end
    end
  end
end
function L.fern(x, y, s)
  local m = M()
  for _, f in ipairs({ { -4, -3 }, { -2, -5 }, { 1, -6 }, { 3, -4 }, { 4, -1 } }) do line(m, x, y, x + f[1], y + f[2]) end
  obj({ { m, function(mm) each(mm, function(px, py) put(px, py, (px < x) and "#9ad870" or "#4aa04c") end) end } })
end
-- savanna
function L.acacia(x, y, s)
  local tr = M(); line(tr, x, y, x, y - 5); line(tr, x, y - 5, x - 3, y - 8); line(tr, x, y - 5, x + 3, y - 8); line(tr, x, y - 3, x + 2, y - 5)
  local cr = ell(M(), x, y - 9, 8, 1.6); ell(cr, x - 3, y - 10, 4, 1.4); ell(cr, x + 3, y - 10, 4, 1.4)
  shadowBlob(x + 2, y + 1, 6)
  obj({ { tr, function(m) solid(m, RP.trunk[3]) end }, { cr, function(m) fill(m, RP.olive, x - 3, y - 11, 7, 2, .2, s) end } })
end
function L.acaciasil(x, y, s)   -- far acacia silhouettes on the dark ground (back plane, no ink)
  local tr = M(); line(tr, x, y, x, y - 5); line(tr, x, y - 5, x - 3, y - 8); line(tr, x, y - 5, x + 3, y - 8)
  local cr = ell(M(), x, y - 9, 7 + floor(hash(s, 1, 1) * 3), 1.4); ell(cr, x - 3, y - 10, 3, 1.2); ell(cr, x + 3, y - 10, 3, 1.2)
  solid(tr, "#5a3034")
  each(cr, function(px, py) put(px, py, cr[I(px, py - 1)] and "#5e3236" or "#7a4a40") end)
  for xx = x - 5, x + 5 do if inb(xx, y + 1) and cls[I(xx, y + 1)] == 2 and hash(xx, y, s) > .4 then put(xx, y + 1, "#4e2a30") end end
end
function L.baobab(x, y, s)
  local tr = poly(M(), { { x - 4, y }, { x - 3, y - 9 }, { x + 3, y - 9 }, { x + 4, y } })
  local br = M(); line(br, x - 2, y - 9, x - 5, y - 12); line(br, x, y - 9, x, y - 13); line(br, x + 2, y - 9, x + 5, y - 12)
  local cr = M(); ell(cr, x - 5, y - 13, 2, 1); ell(cr, x, y - 14, 2, 1); ell(cr, x + 5, y - 13, 2, 1)
  shadowBlob(x + 1, y + 1, 5)
  obj({ { tr, function(m) fill(m, RP.baob, x - 2, y - 6, 3, 5) end }, { br, function(m) solid(m, RP.baob[3]) end }, { cr, function(m) fill(m, RP.olive, x - 1, y - 14, 5, 1) end } })
  put(x - 1, y - 5, RP.baob[4]); put(x + 1, y - 3, RP.baob[4])
end
function L.mound(x, y, s)
  local m = poly(M(), { { x - 3.5, y + .5 }, { x - 2, y - 6 }, { x - 1, y - 10 }, { x + 1, y - 9 }, { x + 2, y - 5 }, { x + 3.5, y + .5 } })
  ell(m, x + 3, y - 2, 1.5, 2)
  obj({ { m, function(mm) fill(mm, RP.termit, x - 1, y - 6, 2, 4) end } })
end
function L.giraffe(x, y, s)
  local b = ell(M(), x, y - 5, 3, 1.6)
  local legs = M(); for _, lx in ipairs({ x - 2, x - 1, x + 1, x + 2 }) do rect(legs, lx, y - 3, lx, y) end
  local neck = M(); line(neck, x + 2, y - 6, x + 4, y - 11, true); rect(neck, x + 4, y - 12, x + 6, y - 11)
  obj({ { legs, function(m) solid(m, RP.giraffe[3]) end }, { b, function(m) fill(m, RP.giraffe, x - 1, y - 6, 3, 1) end },
        { neck, function(m) fill(m, RP.giraffe, x + 3, y - 10, 2, 3) end } })
  put(x - 1, y - 5, RP.giraffe[4]); put(x + 1, y - 6, RP.giraffe[4]); put(x + 3, y - 8, RP.giraffe[4]); put(x + 4, y - 13, INK)
end
function L.rockart(x, y, s)   -- ochre animals painted on the cave rock (no ink: it's paint)
  local o, c = "#c8643a", "#e6c890"
  if hash(s, 1, 4) > .5 then   -- antelope
    for xx = x - 2, x + 2 do put(xx, y - 3, o) end
    put(x - 2, y - 2, o); put(x - 2, y - 1, o); put(x + 2, y - 2, o); put(x + 2, y - 1, o)
    put(x + 3, y - 4, o); put(x + 3, y - 5, o); put(x + 2, y - 6, c); put(x + 4, y - 6, c)
  else   -- giraffe
    for xx = x - 2, x + 1 do put(xx, y - 3, c) end
    put(x - 2, y - 2, c); put(x - 2, y - 1, c); put(x + 1, y - 2, c); put(x + 1, y - 1, c)
    put(x + 2, y - 4, c); put(x + 2, y - 5, c); put(x + 3, y - 6, c); put(x + 3, y - 7, c); put(x + 4, y - 7, c)
  end
  put(x + 6, y - 2, o); put(x + 7, y - 3, o); put(x + 6, y - 4, o)   -- a little sun spiral
end
-- mountains
function L.peak(x, y, s, w, h, R, snowR)
  w = w or (9 + floor(hash(s, 1, 5) * 5)); h = h or (12 + floor(hash(s, 2, 5) * 6))
  local off = floor(hash(s, 3, 5) * 3) - 1
  local m = poly(M(), { { x - w - .5, y + .5 }, { x - 3 + off, y - h + 4 }, { x + off, y - h }, { x + 3 + off, y - h + 5 }, { x + w + .5, y + .5 } })
  R = R or RP.wstone; snowR = snowR or RP.snow
  obj({ { m, function(mm) each(mm, function(px, py)
    local left = (px - x - off) < (y - py) * .08 - 1
    local snowline = y - h * .55 + floor(hash(px, 1, s) * 3)
    local col
    if py < snowline then col = left and snowR[1] or snowR[3]
    else col = left and R[2] or R[3]; if (px * 2 + py) % 7 == 0 then col = left and R[1] or R[4] end end
    put(px, py, col)
  end) end } })
end
function L.stupa(x, y, s)
  local base = rect(M(), x - 4, y - 2, x + 4, y)
  local dome = ell(M(), x, y - 4, 3.5, 2.6)
  local sp = rect(M(), x, y - 10, x, y - 7)
  obj({ { base, function(m) fill(m, RP.stupa, x - 3, y - 2, 4, 1) end }, { dome, function(m) fill(m, RP.stupa, x - 2, y - 6, 3, 3) end }, { sp, function(m) solid(m, RP.gold[2]) end } })
  put(x, y - 11, RP.gold[1]); put(x - 1, y - 5, "#3a86b0"); put(x + 1, y - 5, "#3a86b0")
end
function L.flags(x, y, s)   -- prayer flags between two posts
  local cs = { "#3a86b0", "#f4eee0", "#e8493b", "#4e9a4a", "#f5b82e" }
  for k = 0, 4 do put(x - 9, y - k, RP.trunk[3]); put(x + 9, y - 1 - k, RP.trunk[3]) end
  for xx = x - 8, x + 8 do
    local t = (xx - x) / 9
    local yy = y - 5 + floor(2.5 * (1 - t * t) + .5)
    put(xx, yy - 1, "#5a4a4a")
    if (xx - x) % 2 == 0 then put(xx, yy, cs[((xx - x) // 2) % 5 + 1]); put(xx, yy + 1, cs[((xx - x) // 2) % 5 + 1]) end
  end
end
function L.spicefield(x, y, s)
  local cols = { { "#e8493b", "#9a2a30" }, { "#f5b82e", "#b07a10" }, { "#7cc35a", "#3f9150" } }
  local m = poly(M(), { { x - 11, y }, { x - 8, y - 6 }, { x + 9, y - 6 }, { x + 11, y } })
  rim(m, "#6e3628")
  each(m, function(px, py)
    local row = (py - y + 6) // 2
    local c = cols[(row + s) % 3 + 1]
    put(px, py, ((px + row) % 2 == 0) and c[1] or c[2])
    if (py - y) % 2 == 0 then put(px, py, "#8a4a30") end
  end)
end
function L.flathouse(x, y, s)   -- whitewashed flat-roof house with a coloured door
  local wall = rect(M(), x - 3, y - 5, x + 3, y)
  local roof = rect(M(), x - 4, y - 6, x + 4, y - 6)
  obj({ { wall, function(m) fill(m, RP.plaster, x - 2, y - 4, 3, 3) end }, { roof, function(m) solid(m, RP.trunk[3]) end } })
  put(x, y - 1, "#3a86b0"); put(x, y - 2, "#3a86b0"); put(x - 2, y - 4, "#5a4050"); put(x + 2, y - 4, "#5a4050")
end
function L.flatvillage(x, y, s)
  L.flathouse(x - 5, y, s); L.flathouse(x + 4, y - 4, s + 1); L.flathouse(x + 5, y + 2, s + 2)
  smoke(x + 6, y - 11, s)
end
function L.yak(x, y, s)
  local b = ell(M(), x, y - 3, 4, 2.4)
  local legs = M(); for _, lx in ipairs({ x - 3, x - 1, x + 1, x + 3 }) do rect(legs, lx, y - 1, lx, y) end
  local hd = ell(M(), x + 4, y - 3, 1.6, 1.6)
  obj({ { legs, function(m) solid(m, RP.yak[4]) end }, { b, function(m) fill(m, RP.yak, x - 1, y - 4, 4, 2, .3, s) end }, { hd, function(m) solid(m, RP.yak[3]) end } })
  put(x + 4, y - 6, "#f4eee0"); put(x + 6, y - 5, "#f4eee0"); put(x + 5, y - 5, "#e2dad6")
end
-- east asia
function L.terraces(x, y, s, R, bank, rows, wet)
  rows = rows or 4
  local all = M()
  for r = 0, rows - 1 do
    local w = 11 - r * 2
    for dx = -w, w do
      local t = dx / w
      local yy = y - r * 3 + floor(t * t * 3 + .5)
      for k = 0, 2 do mset(all, x + dx + r, yy - k) end
    end
  end
  rim(all, bank)
  each(all, function(px, py)
    local up = all[I(px, py - 1)]
    local dn = all[I(px, py + 1)]
    local c = R[2]
    if not dn then c = bank elseif not up then c = wet and (((px + s) % 3 == 0) and "#d0f4ee" or "#8cd4c8") or R[1] elseif hash(px, py, s) > .8 then c = R[3] end
    put(px, py, c)
  end)
end
function L.bamboo(x, y, s)
  local m = M()
  local tops = {}
  for k = 0, 4 do
    local bx = x - 4 + k * 2
    local h = 9 + floor(hash(k, s, 3) * 6)
    rect(m, bx, y - h, bx, y)
    tops[#tops + 1] = { bx, y - h }
  end
  local lv = M()
  for _, t in ipairs(tops) do mset(lv, t[1] - 1, t[2] + 1); mset(lv, t[1] + 1, t[2] + 2); mset(lv, t[1] - 1, t[2] + 4) end
  obj({ { m, function(mm) each(mm, function(px, py) put(px, py, ((py - y) % 4 == 0) and RP.bamboo[4] or ((px - x) % 4 == 0 and RP.bamboo[1] or RP.bamboo[2])) end) end },
        { lv, function(mm) solid(mm, RP.bamboo[3]) end } }, false)
end
function L.cherry(x, y, s)
  local tr = M(); line(tr, x, y, x, y - 4); line(tr, x, y - 4, x - 2, y - 6); line(tr, x, y - 3, x + 2, y - 5)
  local cr = ell(M(), x, y - 8, 6, 3); ell(cr, x - 4, y - 7, 3, 2); ell(cr, x + 4, y - 7, 3, 2)
  shadowBlob(x + 1, y + 1, 4)
  obj({ { tr, function(m) solid(m, "#5a3a44") end }, { cr, function(m) fill(m, RP.cherry, x - 2, y - 10, 5, 3, .25, s) end } })
  for k = 1, 4 do local px, py = x - 6 + floor(hash(k, s, 1) * 13), y + 1 + floor(hash(k, s, 2) * 2); if inb(px, py) and cls[I(px, py)] == 1 then put(px, py, RP.cherry[1]) end end
end
function L.tilehouse(x, y, s, R)
  R = R or RP.roofEA
  local wall = rect(M(), x - 3, y - 4, x + 3, y)
  local roof = poly(M(), { { x - 6, y - 4 }, { x - 4, y - 8 }, { x + 4, y - 8 }, { x + 6, y - 4 } })
  mset(roof, x - 6, y - 5); mset(roof, x + 6, y - 5)
  obj({ { wall, function(m) fill(m, RP.plaster, x - 2, y - 3, 3, 2) end },
        { roof, function(m) fill(m, R, x - 3, y - 7, 5, 2); each(m, function(px, py) if px % 2 == 0 and py > y - 8 then put(px, py, R[3]) end end) end } })
  put(x, y - 1, "#b03a36"); put(x, y, "#b03a36"); put(x - 2, y - 2, "#5a4050"); put(x + 2, y - 2, "#5a4050")
end
function L.tilevillage(x, y, s, R)
  L.tilehouse(x - 6, y, s, R); L.tilehouse(x + 6, y - 3, s + 1, R)
  smoke(x + 9, y - 11, s)
end
function L.wall(x, y, s)   -- a stretch of great wall with two towers
  local m = M()
  local tw = {}
  for xx = x - 22, x + 22 do
    local yy = y + floor(2.5 * sin((xx - x) * .12 + s) + .5)
    rect(m, xx, yy - 3, xx, yy)
    if (xx % 2 == 0) then mset(m, xx, yy - 4) end
    if xx == x - 14 or xx == x + 12 then tw[#tw + 1] = { xx, yy } end
  end
  for _, t in ipairs(tw) do rect(m, t[1] - 2, t[2] - 7, t[1] + 2, t[2]); mset(m, t[1] - 2, t[2] - 8); mset(m, t[1], t[2] - 8); mset(m, t[1] + 2, t[2] - 8) end
  obj({ { m, function(mm) each(mm, function(px, py)
    local top = not mm[I(px, py - 1)]
    local c = top and RP.stone[1] or RP.stone[2]
    if not mm[I(px, py + 1)] then c = RP.stone[4] elseif (py + (px // 3)) % 2 == 0 and not top then c = RP.stone[3] end
    put(px, py, c)
  end) end } })
  for _, t in ipairs(tw) do put(t[1], t[2] - 4, INK); put(t[1], t[2] - 3, INK) end
end
function L.crane(x, y, s)
  local b = ell(M(), x, y - 4, 3, 1.6)
  local nk = M(); line(nk, x + 2, y - 5, x + 3, y - 9); mset(nk, x + 4, y - 9)
  local lg = M(); rect(lg, x - 1, y - 2, x - 1, y); rect(lg, x + 1, y - 2, x + 1, y)
  obj({ { lg, function(m) solid(m, "#5a4a5a") end }, { b, function(m) fill(m, RP.crane, x - 1, y - 5, 3, 1) end }, { nk, function(m) solid(m, RP.crane[2]) end } })
  put(x - 3, y - 4, INK); put(x - 2, y - 3, INK); put(x + 3, y - 10, "#e8493b"); put(x + 5, y - 9, "#d98322")
end
-- south-east asia
function L.stilthouse(x, y, s)
  local posts = M(); for _, px in ipairs({ x - 4, x - 1, x + 2, x + 4 }) do rect(posts, px, y - 3, px, y) end
  local wall = rect(M(), x - 4, y - 7, x + 4, y - 4)
  local roof = poly(M(), { { x - 7, y - 6.5 }, { x - 5, y - 9 }, { x, y - 13 }, { x + 5, y - 9 }, { x + 7, y - 6.5 } })
  obj({ { posts, function(m) solid(m, RP.trunk[3]) end }, { wall, function(m) fill(m, RP.trunk, x - 3, y - 6, 4, 2) end },
        { roof, function(m) fill(m, RP.thatch, x - 3, y - 10, 5, 3); each(m, function(px, py) if (px - py) % 3 == 0 then put(px, py, RP.thatch[3]) end end) end } })
  put(x - 1, y - 5, RP.trunk[4]); put(x + 2, y - 6, "#f5b82e")
  -- water under the house
  for xx = x - 6, x + 6 do if inb(xx, y + 1) and cls[I(xx, y + 1)] == 1 then put(xx, y + 1, (xx % 3 == 0) and RP.water[1] or RP.water[2]) end end
end
function L.stiltvillage(x, y, s)
  L.stilthouse(x - 7, y, s); L.stilthouse(x + 7, y - 2, s + 1)
  smoke(x + 9, y - 16, s)
end
function L.mangrove(x, y, s)
  local cr = ell(M(), x, y - 8, 6, 3); ell(cr, x - 3, y - 10, 3, 2); ell(cr, x + 3, y - 10, 3, 2)
  local rt = M()
  for _, k in ipairs({ -4, -2, 0, 2, 4 }) do line(rt, x, y - 5, x + k, y - 1); mset(rt, x + k, y) end
  for xx = x - 6, x + 6 do if inb(xx, y + 1) and cls[I(xx, y + 1)] == 1 then put(xx, y + 1, (xx % 2 == 0) and RP.water[2] or RP.water[3]) end end
  obj({ { rt, function(m) solid(m, RP.trunk[3]) end }, { cr, function(m) fill(m, RP.mang, x - 2, y - 10, 5, 3, .25, s) end } })
end
function L.temple(x, y, s)   -- three stepped corn-cob towers
  local m = M()
  rect(m, x - 9, y - 3, x + 9, y)
  for _, t in ipairs({ { x - 6, 9 }, { x, 14 }, { x + 6, 9 } }) do
    local tx, th = t[1], t[2]
    for k = 0, th do local hw = max(0, floor(2.6 - k / th * 2.6 + .5)); rect(m, tx - hw, y - 3 - k, tx + hw, y - 3 - k) end
  end
  obj({ { m, function(mm) each(mm, function(px, py)
    local c = RP.wstone[2]
    if not mm[I(px - 1, py)] then c = RP.wstone[1] elseif not mm[I(px + 1, py)] then c = RP.wstone[3] end
    if py % 3 == 0 then c = RP.wstone[3] end
    put(px, py, c)
  end) end } })
  put(x, y - 1, INK); put(x, y - 2, INK)
  put(x + 8, y - 4, "#7cc35a"); put(x + 9, y - 4, "#3f9150")   -- strangler fig sprout
end
function L.buffalo(x, y, s)
  local b = ell(M(), x, y - 3, 4, 2)
  local legs = M(); for _, lx in ipairs({ x - 3, x - 1, x + 1, x + 3 }) do rect(legs, lx, y - 1, lx, y) end
  local hd = ell(M(), x + 5, y - 3, 1.5, 1.5)
  local hn = M(); mset(hn, x + 4, y - 5); mset(hn, x + 3, y - 6); mset(hn, x + 6, y - 5); mset(hn, x + 7, y - 6)
  obj({ { legs, function(m) solid(m, RP.buff[4]) end }, { b, function(m) fill(m, RP.buff, x - 1, y - 4, 4, 2) end }, { hd, function(m) solid(m, RP.buff[3]) end }, { hn, function(m) solid(m, "#e6dccc") end } })
  -- the quirk: a small bird riding on its back
  put(x - 1, y - 6, "#f4eee0"); put(x, y - 6, "#e6dccc"); put(x + 1, y - 6, "#f5b82e")
end
-- oceania
function L.atoll(x, y, s, rx)
  rx = rx or (8 + floor(hash(s, 4, 3) * 5)); local ry = rx * .55
  for yy = floor(y - ry - 4), floor(y + ry + 4) do for xx = floor(x - rx - 4), floor(x + rx + 4) do
    if inb(xx, yy) and cls[I(xx, yy)] == 2 and not hard[I(xx, yy)] then
      local a, b = (xx - x) / rx, (yy - y) / ry
      local dd = sqrt(a * a + b * b) * rx
      local c
      if dd <= rx - 4.2 then c = (hash(xx, yy, s) > .85) and RP.water[1] or RP.water[2]
      elseif dd <= rx - 2.6 then c = ((xx - x) + (yy - y) < 0) and RP.sand[1] or RP.sand[2]
      elseif dd <= rx - 1.6 then c = ((xx - x) + (yy - y) < 0) and RP.sand[2] or RP.sand[3]
      elseif dd <= rx - .6 then c = RP.water[2]
      elseif dd <= rx + .6 then c = ((xx + yy) % 2 == 0) and "#d8f4ee" or "#9ad6d4"
      elseif dd <= rx + 2.6 then c = "#2e4a72"
      elseif dd <= rx + 4 and (xx + yy) % 2 == 0 then c = "#2a3a58" end
      if c then put(xx, yy, c) end
    end
  end end
  -- green islets on the ring + a palm
  local ix, iy = floor(x - rx * .55), floor(y - ry * .65)
  local g = ell(M(), ix, iy, 2.5, 1.2)
  obj({ { g, function(m) fill(m, RP.palm, ix - 1, iy - 1, 2, 1) end } }, true)
  L.palm(ix + 1, iy, s + 5, 6)
end
function L.reef(x, y, s)
  for yy = y - 4, y + 4 do for xx = x - 6, x + 6 do
    if inb(xx, yy) and cls[I(xx, yy)] == 2 and not hard[I(xx, yy)] then
      local a, b = (xx - x) / 6, (yy - y) / 4
      local dd = a * a + b * b
      if dd <= 1 then
        local c = (dd > .65) and "#2e4a72" or "#3a6a8a"
        if dd < .6 and hash(xx, yy, s) > .55 then c = ({ "#f5809f", "#ff8a5c", "#c9b2f0", "#f5b82e" })[1 + floor(hash(xx, yy, s + 1) * 4)] end
        if dd < .6 and hash(xx, yy, s + 3) > .92 then c = "#d8f4ee" end
        put(xx, yy, c)
      end
    end
  end end
end
function L.whale(x, y, s)   -- the quirk: a whale's tail lifting out of the deep
  for xx = x - 7, x + 7 do if inb(xx, y + 1) and cls[I(xx, y + 1)] == 2 then put(xx, y + 1, ((xx + s) % 2 == 0) and "#d8f4ee" or "#9ad6d4") end end
  local m = M(); rect(m, x, y - 4, x + 1, y)
  poly(m, { { x - 5, y - 8 }, { x - 1, y - 4 }, { x + 2, y - 4 }, { x + 6, y - 8 }, { x + 3, y - 6.5 }, { x + .5, y - 5 }, { x - 2, y - 6.5 } })
  obj({ { m, function(mm) fill(mm, RP.slate, x - 2, y - 6, 4, 2) end } })
  put(x - 6, y - 10, "#d8f4ee"); put(x + 7, y - 10, "#d8f4ee"); put(x - 4, y - 11, "#9ad6d4")
end
function L.uluru(x, y, s)
  local m = poly(M(), { { x - 12, y + .5 }, { x - 10, y - 5 }, { x - 6, y - 8 }, { x + 5, y - 8.5 }, { x + 9, y - 6 }, { x + 12, y + .5 } })
  shadowBlob(x + 2, y + 1, 11)
  obj({ { m, function(mm) fill(mm, RP.ochre, x - 4, y - 7, 9, 4); each(mm, function(px, py) if (px % 4 == 0) and py > y - 7 and hash(px, py, s) > .3 then put(px, py, RP.ochre[3]) end end) end } })
  put(x - 5, y - 7, RP.ochre[1]); put(x - 4, y - 7, RP.ochre[1])
end
function L.fale(x, y, s)
  local posts = M(); rect(posts, x - 4, y - 3, x - 4, y); rect(posts, x + 4, y - 3, x + 4, y); rect(posts, x, y - 3, x, y)
  local roof = ell(M(), x, y - 5, 6, 3)
  local cut = {}; for i in pairs(roof) do if i // W > y - 4 then cut[i] = true end end
  for i in pairs(cut) do roof[i] = nil end
  obj({ { posts, function(m) solid(m, RP.trunk[3]) end }, { roof, function(m) fill(m, RP.thatch, x - 2, y - 7, 5, 2); each(m, function(px, py) if (px + py) % 3 == 0 then put(px, py, RP.thatch[3]) end end) end } })
end
function L.falevillage(x, y, s) L.fale(x - 6, y, s); L.fale(x + 6, y - 2, s + 1); smoke(x + 8, y - 11, s) end

-------------------------------------------------------------- texture passes
local SH, LT = "#3a2a50", "#fff0c0"
local TEX = {}
TEX.MENA = function(x, y, c)   -- dune ripples
  local v = vn(x, y, 22, 5)
  if v < .38 then return end
  local p = y + 3 * sin(x * .08) + 2 * sin(x * .031 + 1.3) + 4 * vn(x, y, 40, 9)
  local f = p % 5
  if f < 1 then return mix(c, SH, .18) elseif f < 2 and hash(x, y, 3) > .35 then return mix(c, LT, .22) end
end
TEX.WCA = function(x, y, c)   -- leaf litter, fern sprigs
  local h = hash(x, y, 11)
  if vn(x, y, 14, 3) > .55 and h > .86 then return (hash(x, y, 12) > .5) and mix(c, "#c4e07a", .3) or mix(c, "#173a30", .35) end
end
TEX.ESA = function(x, y, c)   -- dry grass tufts
  if hash(x, y, 21) > .955 or hash(x, y + 1, 21) > .955 then return mix(c, "#ffe8a0", .3) end
  if hash(x, y - 1, 21) > .955 then return mix(c, SH, .2) end
end
TEX.CSA = function(x, y, c)   -- scree and contour steps
  local p = y + 6 * sin(x * .05 + y * .02) + 5 * vn(x, y, 30, 2)
  if vn(x, y, 26, 4) > .5 and p % 7 < 1 then return mix(c, SH, .2) end
  if hash(x, y, 31) > .975 then return mix(c, "#f0d8c0", .35) end
end
TEX.EA = function(x, y, c)   -- moss and stray blossom petals
  if hash(x, y, 41) > .994 then return RP.cherry[2] end
  if vn(x, y, 12, 6) > .6 and hash(x, y, 42) > .8 then return mix(c, "#e8dcff", .2) end
end
TEX.SEA = function(x, y, c)   -- flooded paddies catching the light
  local v = vn(x, y, 26, 7)
  if v < .5 then return end
  local p = y + 4 * sin(x * .06) + 3 * vn(x, y, 50, 1)
  local f = p % 4
  if f < 1 then return mix(c, "#2e5e3e", .3) elseif f < 2 and v > .58 then return mix(c, "#b6f0e0", .35) end
end
TEX.OC = function(x, y, c)
  if hash(x, y, 51) > .985 then return mix(c, "#f4dc9e", .45) end
end

local RTEX = {}
RTEX.MENA = function(x, y, c, R) local p = y + 4 * sin(x * .05) + 3 * vn(x, y, 30, 3); if vn(x, y, 24, 8) > .45 and p % 9 < 1 then return R[3] end end
RTEX.WCA = function(x, y, c, R) local p = x + 5 * sin(y * .12) + 4 * vn(x, y, 20, 3); if vn(x, y, 18, 8) > .5 and p % 12 < 1 then return "#3e3a26" end end
RTEX.ESA = function(x, y, c, R) local p = y + 5 * sin(x * .04) + 3 * vn(x, y, 30, 3); if vn(x, y, 24, 8) > .45 and p % 8 < 1 then return "#5e3434" end end
RTEX.EA = function(x, y, c, R) local p = x * .7 + y + 6 * sin(x * .05) + 5 * vn(x, y, 25, 3); if vn(x, y, 22, 8) > .7 and p % 14 < 1 then return "#3e6a6a" end end
RTEX.OC = function(x, y, c, R) local p = y + 3 * sin(x * .1 + y * .03) + 3 * vn(x, y, 30, 3); if vn(x, y, 20, 8) > .5 and p % 7 < 1 then return "#3a4a6c" end end

-------------------------------------------------------------- per-map programs
local ROCKS = {
  MENA = { "#34222d", "#402c38", "#5a4150" }, WCA = { "#232a28", "#2e3a34", "#445850" }, ESA = { "#3a1e26", "#4a2a30", "#68403e" },
  CSA = { "#3a1e26", "#4a2a30", "#68403e" }, EA = { "#2e2038", "#3a2a48", "#544066" }, SEA = { "#232a28", "#2e3a34", "#445850" },
  OC = { "#262c3c", "#303850", "#46506a" },
}
local PATHS = set{ "#d9a85c", "#ecc989", "#f6e3b4", "#f5c95a", "#a8743a", "#c9a96e", "#9a6b3f", "#74462a" }
local EXCL = set{ "#2b1c26", "#f08a24", "#fff3c8", "#3f8fb0", "#25637d", "#b07a10", "#8a4f2a", "#a8582f", "#e0501f", "#5e2f1e", "#c8ecdc",
  "#a9d6ea", "#f6b8cf", "#9a3a62", "#e87898", "#e46a9b", "#dd3a2a", "#c3b2ea", "#7a5cc0", "#c9c5bc", "#5b6470", "#b07a45", "#2f6a3a", "#c89a6c" }
local WATER = set{ "#3f8fb0", "#25637d", "#a9d6ea" }

local PROG = {}
-- each entry: { fn, count, zone (1 floor / 2 rock), halfwidth, top, bottom, [ymin, ymax] }
PROG.MENA = {
  { "oasis", 3, 1, 14, 18, 3 }, { "mudvillage", 3, 1, 13, 19, 5 }, { "caravan", 1, 1, 15, 10, 1 }, { "dune", 9, 1, 16, 9, 2 },
  { "palm", 10, 1, 7, 14, 2 }, { "fossil", 5, 2, 9, 5, 2 }, { "amphora", 4, 2, 3, 9, 1 },
}
PROG.WCA = {
  { "kapok", 1, 1, 13, 27, 2 }, { "hutvillage", 3, 1, 12, 16, 5 }, { "stream", 2, 1, 20, 5, 6 }, { "canopy", 22, 1, 9, 16, 2 },
  { "fern", 14, 1, 5, 7, 1 }, { "vine", 30, 2, 2, 1, 14, 0, 40 },
}
PROG.ESA = {
  { "peak", 1, 2, 16, 18, 1, nil, 230, { 15, 18 } }, { "hutvillage", 2, 1, 11, 15, 4 }, { "giraffe", 1, 1, 5, 14, 1 },
  { "baobab", 3, 1, 6, 14, 2 }, { "acacia", 12, 1, 7, 10, 1 }, { "acaciasil", 14, 2, 9, 11, 2 }, { "mound", 8, 1, 4, 10, 1 }, { "rockart", 10, 2, 8, 8, 1 },
}
PROG.CSA = {
  { "peak", 9, 1, 13, 18, 1 }, { "flatvillage", 3, 1, 10, 13, 3 }, { "spicefield", 5, 1, 12, 7, 1 }, { "stupa", 3, 1, 5, 12, 1 },
  { "flags", 3, 1, 10, 7, 1 }, { "yak", 1, 1, 6, 7, 1 },
}
PROG.EA = {
  { "wall", 2, 2, 23, 9, 3 }, { "tilevillage", 3, 1, 10, 12, 1 }, { "terraces", 5, 1, 12, 10, 2 }, { "cherry", 7, 1, 7, 11, 2 },
  { "bamboo", 7, 1, 5, 15, 1 }, { "crane", 1, 1, 4, 11, 1 },
}
PROG.SEA = {
  { "temple", 1, 1, 10, 18, 1 }, { "stiltvillage", 3, 1, 14, 17, 2 }, { "stream", 1, 1, 20, 5, 6 }, { "buffalo", 1, 1, 7, 7, 1 },
  { "terraces", 9, 1, 13, 10, 3 }, { "mangrove", 9, 1, 7, 12, 2 }, { "palm", 9, 1, 7, 14, 2 },
}
PROG.OC = {
  { "whale", 1, 2, 8, 12, 2 }, { "atoll", 5, 2, 15, 11, 11 }, { "reef", 10, 2, 7, 5, 5 }, { "uluru", 1, 1, 13, 10, 2 },
  { "falevillage", 3, 1, 11, 10, 1 }, { "palm", 10, 1, 7, 14, 2 }, { "fern", 6, 1, 5, 7, 1 },
}

local function build(name)
  local img = Image{ fromFile = d .. "/base/map-" .. name .. ".png" }
  local pc = app.pixelColor
  pix, cls, hard, soft, inkNear, occ = {}, {}, {}, {}, {}, {}
  local cnt = {}
  for y = 0, H - 1 do for x = 0, W - 1 do
    local v = img:getPixel(x, y)
    local k = hex(pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v))
    pix[I(x, y)] = k; cnt[k] = (cnt[k] or 0) + 1
  end end
  local rk = set(ROCKS[name])
  for i = 0, W * H - 1 do
    local k = pix[i]
    if rk[k] then cls[i] = 2 elseif PATHS[k] then cls[i] = 3 elseif EXCL[k] or cnt[k] < 150 then cls[i] = 4 else cls[i] = 1 end
  end
  -- protection
  local R = LAY[name]
  local function disc(cx, cy, r, t) for y = floor(cy - r), floor(cy + r) do for x = floor(cx - r), floor(cx + r) do
    if inb(x, y) and (x - cx) ^ 2 + (y - cy) ^ 2 <= r * r then t[I(x, y)] = true end end end end
  for _, c in ipairs(R.clear) do disc(c[1], c[2], c[3] + 1, hard) end
  local function seg(a, b, r)
    local x0, y0, x1, y1 = a[1], a[2], b[1], b[2]
    local dx, dy = x1 - x0, y1 - y0
    local L2 = max(1, dx * dx + dy * dy)
    for y = floor(min(y0, y1) - r), floor(max(y0, y1) + r) do for x = floor(min(x0, x1) - r), floor(max(x0, x1) + r) do
      if inb(x, y) then
        local t = max(0, min(1, ((x - x0) * dx + (y - y0) * dy) / L2))
        local ex, ey = x0 + t * dx - x, y0 + t * dy - y
        if ex * ex + ey * ey <= r * r then hard[I(x, y)] = true end
      end
    end end
  end
  for _, rd in ipairs(R.roads) do for i = 2, #rd.pts do seg(rd.pts[i - 1], rd.pts[i], 5) end end
  for _, tr in ipairs(R.trails) do seg(tr[1], tr[2], 4) end
  for y = 0, H - 1 do for x = 0, W - 1 do if x < 3 or y < 3 or x >= W - 3 or y >= H - 3 then hard[I(x, y)] = true end end end
  for y = 0, H - 1 do for x = 0, W - 1 do
    local c = cls[I(x, y)]
    if c == 3 or c == 4 then
      local isInk = pix[I(x, y)] == INK
      for dy = -1, 1 do for dx = -1, 1 do if inb(x + dx, y + dy) then
        if isInk then inkNear[I(x + dx, y + dy)] = true else soft[I(x + dx, y + dy)] = true end
      end end end
    end
  end end
  if app.params.debug then
    local dm = Image(W, H, ColorMode.RGB)
    for y = 0, H - 1 do for x = 0, W - 1 do
      local i = I(x, y)
      local r, g, b = 90, 90, 90
      if not hard[i] and not soft[i] then
        if cls[i] == 1 then if inkNear[i] then r, g, b = 40, 120, 40 else r, g, b = 80, 220, 80 end elseif cls[i] == 2 then r, g, b = 60, 80, 220 end
      elseif hard[i] then r, g, b = 160, 60, 60 end
      dm:drawPixel(x, y, app.pixelColor.rgba(r, g, b, 255))
    end end
    dm:saveAs(OUT .. "dbg-" .. name .. ".png")
  end
  -- 1) floor texture
  local tex = TEX[name]
  local new = {}
  for y = 0, H - 1 do for x = 0, W - 1 do
    local i = I(x, y)
    if cls[i] == 1 and not hard[i] and not soft[i] then new[i] = tex(x, y, pix[i]) end
  end end
  for i, c in pairs(new) do pix[i] = c end
  if RTEX[name] then
    new = {}
    for y = 0, H - 1 do for x = 0, W - 1 do
      local i = I(x, y)
      if cls[i] == 2 and not hard[i] and not soft[i] and not inkNear[i] then new[i] = RTEX[name](x, y, pix[i], ROCKS[name]) end
    end end
    for i, c in pairs(new) do pix[i] = c end
  end
  -- 2) OC coast: surf on the rock (sea) just outside the cave rim
  if name == "OC" then
    local nb = {}
    for y = 0, H - 1 do for x = 0, W - 1 do
      local i = I(x, y)
      if cls[i] == 2 and not hard[i] and not soft[i] then
        local dmin = 9
        for dy = -3, 3 do for dx = -3, 3 do if inb(x + dx, y + dy) and cls[I(x + dx, y + dy)] == 1 then dmin = min(dmin, max(abs(dx), abs(dy))) end end end
        if dmin == 2 then nb[i] = ((x + y) % 3 ~= 0 and hash(x, y, 61) > .25) and "#9ad6d4" or "#3a6a8a"
        elseif dmin == 3 then nb[i] = ((x + y) % 2 == 0) and "#2e4a72" or nil end
      end
    end end
    for i, c in pairs(nb) do pix[i] = c end
  end
  -- 3) bridges over existing narrow water outside the keep-clear zones
  local bridges = 0
  for t = 1, 4000 do
    if bridges >= 1 then break end
    local x, y = 5 + floor(hash(t, 3, 77) * (W - 10)), 5 + floor(hash(t, 4, 77) * (H - 10))
    if WATER[pix[I(x, y)]] and not hard[I(x, y)] then
      local run = 0
      for dx = -4, 4 do if WATER[pix[I(x + dx, y)]] then run = run + 1 end end
      local vert = WATER[pix[I(x, y - 2)]] and WATER[pix[I(x, y + 2)]]
      local okb = true
      for dx = -4, 4 do for dy = -2, 3 do local ii = I(x + dx, y + dy); if hard[ii] or cls[ii] == 3 then okb = false end end end
      if run <= 3 and vert and okb then
        local b = rect(M(), x - 3, y - 1, x + 3, y + 1)
        obj({ { b, function(m) each(m, function(px, py) put(px, py, (px % 2 == 0) and RP.trunk[1] or RP.trunk[2]) end) end } })
        put(x - 3, y - 2, RP.trunk[3]); put(x + 3, y - 2, RP.trunk[3])
        for dx = -2, 2 do put(x + dx, y - 1, ((dx + 2) % 2 == 0) and RP.roofR[2] or RP.trunk[1]) end
        bridges = bridges + 1
      end
    end
  end
  -- 4) landmarks
  local function boxOK(x0, y0, x1, y1, zone)
    for y = y0, y1 do for x = x0, x1 do
      if not inb(x, y) then return false end
      local i = I(x, y)
      if hard[i] or soft[i] or occ[i] or cls[i] ~= zone then return false end
      if zone == 1 and inkNear[i] then return false end
    end end
    return true
  end
  local rep = {}
  for pi, pr in ipairs(PROG[name]) do
    local kind, n, zone, w, top, bot, ylo, yhi, args = pr[1], pr[2], pr[3], pr[4], pr[5], pr[6], pr[7], pr[8], pr[9]
    local placed, t = 0, 0
    while placed < n and t < 9000 do
      t = t + 1
      local x = 4 + floor(hash(t, pi, #name * 31 + 7) * (W - 8))
      local y = 4 + floor(hash(t, pi, #name * 31 + 9) * (H - 8))
      if (not ylo or y >= ylo) and (not yhi or y <= yhi) then
        local ok
        if kind == "vine" then ok = boxOK(x - 1, y - 1, x + 1, y + 4, 2) and (y < 30)
        else ok = boxOK(x - w, y - top, x + w, y + bot, zone) end
        if ok then
          for yy = y - top - 2, y + bot + 2 do for xx = x - w - 2, x + w + 2 do if inb(xx, yy) then occ[I(xx, yy)] = true end end end
          placed = placed + 1
          local s = placed * 13 + pi * 7
          if kind == "peak" and args then L.peak(x, y, s, args[1], args[2])
          elseif kind == "terraces" then
            if name == "SEA" then L.terraces(x, y, s, { "#e4f8b0", "#a8dc6a", "#7ab850", "#3e7a44" }, "#2e6a3e", 4, true) else L.terraces(x, y, s, RP.terr, "#2e5e3e", 4) end
          elseif kind == "fossil" then L.fossil(x, y, s, { nil, nil, ROCKS[name][3], "#7a6070" })
          elseif kind == "tilevillage" then L.tilevillage(x, y, s, (placed == 2) and RP.roofR or RP.roofEA)
          elseif kind == "hutvillage" then L.hutvillage(x, y, s, (name == "WCA") and { "#c8d070", "#9aa040", "#6a7030", "#40482a" } or RP.thatch)
          elseif kind == "canopy" then L.canopy(x, y, s, nil, (placed % 3 == 0) and RP.kapok or RP.jungle)
          else L[kind](x, y, s) end
        end
      end
    end
    rep[#rep + 1] = kind .. " " .. placed .. "/" .. n
  end
  print(name .. ": bridges " .. bridges .. "; " .. table.concat(rep, ", "))
  -- write
  local out = Image(W, H, ColorMode.RGB)
  for y = 0, H - 1 do for x = 0, W - 1 do
    local r, g, b = rgb(pix[I(x, y)])
    out:drawPixel(x, y, pc.rgba(r, g, b, 255))
  end end
  out:saveAs(OUT .. "map-" .. name .. ".png")
end

local names = (NAME == "all") and { "MENA", "WCA", "ESA", "CSA", "EA", "SEA", "OC" } or { NAME }
for _, n in ipairs(names) do build(n) end
