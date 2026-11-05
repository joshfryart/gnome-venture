-- Gnome Venture "Hearth Pop" v3: hidden Village, gate view at dawn. 480x270 native.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local out = (app and app.params and app.params["out"]) or "/home/user/gnome-venture/aseprite-source/v3/here-gate/places/"
local W, H, HZ = 480, 270, 112
local c = HP.canvas{ w = W, h = H, scale = 1, name = "here-village" }
local floor, sin, abs = math.floor, math.sin, math.abs

local function hash(x, y, s) local n = sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453 return n - floor(n) end
local function P(x, y, h) if x >= 0 and x < W and y >= 0 and y < H then c:put(x, y, h) end end
local function hl(x0, x1, y, h) for x = x0, x1 do P(x, y, h) end end
local function vl(x, y0, y1, h) for y = y0, y1 do P(x, y, h) end end
local function rectf(x0, y0, x1, y1, h) for y = y0, y1 do hl(x0, x1, y, h) end end

-- ramps {d,s,b,h}
local R = {
  thatch = { d="#6b4228", s="#a8703a", b="#d49a4a", h="#f0c46a" },
  turf   = { d="#2f4a2a", s="#4f7a3a", b="#6f9e48", h="#a6c862" },
  plaster= { d="#6e5a6a", s="#c4aab0", b="#efdcc0", h="#fff0d0" },
  plaster2={ d="#6a4e5a", s="#c8968e", b="#eebfa0", h="#ffdcbc" },
  stone  = { d="#4b4a63", s="#7d7c98", b="#a7a6ba", h="#cfcbd6" },
  wood   = { d="#4a2c26", s="#7a4a32", b="#a46a42", h="#cf9560" },
  dwood  = { d="#3a2224", s="#5e3a2e", b="#82533a", h="#a8774e" },
  red    = { d="#5a1e26", s="#8e2f30", b="#c0483a", h="#e57a5a" },
  green  = { d="#1e4436", s="#2f6a50", b="#3f8f68", h="#6fbf88" },
  tile   = { d="#5a2430", s="#94393a", b="#c45a42", h="#e8865a" },
  teal   = { d="#1f4a52", s="#2f6f78", b="#3f9aa0", h="#7fd0c8" },
  brass  = { d="#6a4420", s="#a87430", b="#d9a440", h="#ffd870" },
  cork   = { d="#6a3e22", s="#a86434", b="#c9884a", h="#e8b06a" },
  leaf   = { d="#1f3a2e", s="#2e5a3a", b="#3f7a44", h="#6aa356" },
  leafB  = { d="#24382e", s="#35573c", b="#4a7548", h="#79a058" },
  bark   = { d="#3a2626", s="#5a3a30", b="#7a523c", h="#9c704e" },
  soil   = { d="#3e2622", s="#5e3a2c", b="#7a4e36", h="#9a6a48" },
  pump   = { d="#7a3220", s="#c0602a", b="#e88a36", h="#ffb860" },
  canvas = { d="#7a6a6a", s="#c8b8a8", b="#f0e4cc", h="#fff4d6" },
  violet = { d="#3a3058", s="#5a4e86", b="#7a6eaa", h="#a89ad0" },
}
local INK = "#2b1c26"
local GLOW = { "#ffe9a0", "#ffcf5a", "#f29a3a" }

-- generic lit solid: rim, base, upper-left light, lower-right shade
local function solid(m, r, o)
  o = o or {}
  if not o.norim then c:rim(m, o.rim or r.d) end
  local sd, sdy = o.sd or 3, o.sdy or 2
  m:each(function(x, y)
    local col = r.b
    if not m:has(x + sd, y) or not m:has(x, y + sdy) then col = r.s end
    if not m:has(x - 1, y) or not m:has(x, y - 1) then col = r.h end
    if o.tex then col = o.tex(x, y, col) or col end
    P(x, y, col)
  end)
end

local function blobShade(blobs, r, seed, rimc)
  local all = HP.mask()
  local ms = {}
  for i, b in ipairs(blobs) do ms[i] = c:ellipse(b[1], b[2], b[3], b[4]) all:add(ms[i]) end
  c:rim(all, rimc or r.d)
  for i, e in ipairs(ms) do
    local k = math.max(2, floor(math.min(blobs[i][3], blobs[i][4]) * 0.45))
    c:fillMask(e, r.s)
    local lit = e:copy():clip(e:shift(-k, -k))
    c:fillMask(lit, r.b)
    local hot = e:copy():clip(e:shift(-2 * k, -2 * k))
    c:fillMask(hot, r.h)
    -- crevice under each blob over earlier ones
    e:edge():each(function(x, y) if y > blobs[i][2] + blobs[i][4] * 0.3 then P(x, y, r.d) end end)
  end
  -- leaf texture
  all:each(function(x, y)
    local v = hash(floor(x / 2), floor(y / 2), seed)
    if (x + y) % 2 == 0 then
      if v < 0.05 then P(x, y, r.d) elseif v < 0.08 then P(x, y, r.h) end
    end
  end)
  return all
end

-------------------------------------------------------------------- SKY (dawn)
c:stripes(0, HZ, { "#4b4a8a", "#5e5698", "#7a62a2", "#9a6ea8", "#c27ca6", "#e494a0", "#f6b090", "#ffcf98", "#ffe2a8" },
  { 3, 3, 3, 3, 3, 3, 3, 3, 2 })
-- stepped dawn glow above the vanishing point (no circle: stacked bars)
for i = 0, 7 do
  local y = HZ - 2 - i * 3
  local half = 86 - i * 10
  for yy = y - 2, y do hl(240 - half, 240 + half, yy, i < 3 and "#fff0b8" or (i < 6 and "#ffe0a0" or "#ffd09a")) end
end
for i = 0, 3 do hl(240 - 60 + i * 12, 240 + 60 - i * 12, HZ - 26 - i * 2, "#fff4d6") end
-- dawn clouds, lit from the low sun
local clouds = { { 64, 50, 44 }, { 150, 36, 30 }, { 286, 30, 40 }, { 372, 52, 34 }, { 196, 62, 22 } }
for _, cl in ipairs(clouds) do c:cloud(cl[1], cl[2], cl[3], "#ffd4b4", "#c88aa8") end
-- a few morning stars still up high
for _, s in ipairs({ { 120, 18 }, { 330, 12 }, { 410, 22 }, { 220, 8 }, { 90, 28 } }) do P(s[1], s[2], "#fff4d6") P(s[1]+1, s[2], "#c8b8e8") end

-------------------------------------------------------------------- FAR HILLS
c:terrain(function(x) return floor(88 + 6 * sin(x / 37) + 4 * sin(x / 13 + 1)) end, "#8a82b4", HZ)
c:terrain(function(x) return floor(97 + 5 * sin(x / 23 + 2) + 2 * sin(x / 7)) end, "#7e94a0", HZ)
-- hill top light rims
for x = 0, W - 1 do
  local y1 = floor(88 + 6 * sin(x / 37) + 4 * sin(x / 13 + 1)); P(x, y1, "#b0a4d0")
  local y2 = floor(97 + 5 * sin(x / 23 + 2) + 2 * sin(x / 7)); P(x, y2, "#a8b8a8")
end

-------------------------------------------------------------------- WINDMILL (far right)
do
  local cx, base, top = 326, 117, 66
  local tower = c:poly{ { cx - 15, base }, { cx - 10, top }, { cx + 10, top }, { cx + 15, base } }
  solid(tower, R.plaster2, { tex = function(x, y, col)
    if (y % 6 == 0) and hash(x, y, 3) < 0.5 then return R.plaster2.s end
  end })
  -- door + window glow
  local dm = c:rrect(cx - 4, base - 12, cx + 4, base, 3); solid(dm, R.dwood)
  rectf(cx - 2, top + 14, cx + 2, top + 19, GLOW[2]); hl(cx - 2, cx + 2, top + 17, GLOW[3]); c:rim(c:rect(cx-2, top+14, cx+2, top+19), R.plaster2.d)
  -- cap
  local cap = c:poly{ { cx - 13, top + 1 }, { cx - 7, top - 10 }, { cx + 7, top - 10 }, { cx + 13, top + 1 } }
  solid(cap, R.violet)
  -- sails (an X), lattice canvas
  local hx, hy = cx, top - 3
  local dirs = { { -1, -1 }, { 1, -1 }, { 1, 1 }, { -1, 1 } }
  for i, d in ipairs(dirs) do
    local L = 32
    local ex, ey = hx + d[1] * L * 0.86, hy + d[2] * L * 0.62
    local sail = c:line({ { hx + d[1] * 6, hy + d[2] * 4 }, { ex, ey } }, 7)
    c:rim(sail, R.canvas.d)
    sail:each(function(x, y)
      local col = ((x + y) % 4 == 0 or (x - y) % 4 == 0) and R.canvas.s or R.canvas.b
      if i == 1 and hash(x, y, 9) < 0.3 then col = R.canvas.h end
      P(x, y, col)
    end)
    local spar = c:line({ { hx, hy }, { ex, ey } }, 1); c:fillMask(spar, R.wood.d)
  end
  -- quirk: one sail has a patched square of red cloth
  rectf(hx + 14, hy + 8, hx + 18, hy + 11, R.red.b); hl(hx + 14, hx + 18, hy + 11, R.red.d)
  rectf(hx - 2, hy - 2, hx + 2, hy + 2, R.brass.b); P(hx - 1, hy - 1, R.brass.h); c:rim(c:rect(hx-2,hy-2,hx+2,hy+2), R.brass.d)
end

-------------------------------------------------------------------- HORIZON TREE LINE
blobShade({ {172,104,14,9},{190,100,12,11},{206,104,12,8},{160,108,10,6},{220,108,9,5} }, { d="#2e3c4e", s="#3e5260", b="#4f6a6a", h="#7a9480" }, 11)
blobShade({ {262,106,10,6},{276,101,13,10},{294,104,12,8},{308,108,9,5} }, { d="#2e3c4e", s="#3e5260", b="#4f6a6a", h="#7a9480" }, 12)

-------------------------------------------------------------------- GROUND
for y = HZ, H - 1 do
  local t = (y - HZ) / (H - HZ)
  for x = 0, W - 1 do
    local base = t < 0.12 and "#94b46e" or (t < 0.35 and "#86ad60" or "#7aa656")
    local v = hash(x, y, 1)
    local col = base
    if v < 0.07 then col = "#5f8c48" elseif v < 0.11 then col = "#a8c872"
    elseif v > 0.995 then col = (x % 2 == 0) and "#f6e08a" or "#f0b4c8" end
    -- grass tuft strokes near the viewer
    if t > 0.3 and hash(floor(x / 3), floor(y / 4), 2) < 0.12 and (x % 3 == 1) and (y % 4 < 2) then col = "#55803e" end
    P(x, y, col)
  end
end
-- dawn warm wash across the far meadow
for y = HZ, HZ + 8 do for x = 140, 340 do if hash(x, y, 5) < 0.35 then P(x, y, "#c2c27a") end end end

local function pxl(y) return 231 - 83 * (y - HZ) / (H - 1 - HZ) end
local function pxr(y) return 249 + 83 * (y - HZ) / (H - 1 - HZ) end

-- village green (lighter clover lawn) around the well
local green = c:poly{ { 120, 196 }, { 140, 186 }, { 210, 186 }, { 226, 198 }, { 214, 212 }, { 128, 212 } }
green:each(function(x, y) local v = hash(x, y, 21)
  P(x, y, v < 0.08 and "#7aa656" or (v < 0.13 and "#c8e090" or (v > 0.985 and "#fff4d6" or "#9cc46a"))) end)

-- wild trail (dirt ribbon leaving to the right edge)
local trail = c:poly{ { 290, 194 }, { 340, 186 }, { 392, 182 }, { 470, 178 }, { 470, 194 }, { 392, 200 }, { 342, 206 }, { 296, 212 } }
c:rim(trail, "#8a6a4a")
trail:each(function(x, y) local v = hash(x, y, 31)
  P(x, y, v < 0.08 and "#9a7452" or (v < 0.14 and "#e2c08e" or "#c49a6c")) end)

-- main footpath
local path = c:poly{ { 231, HZ }, { 249, HZ }, { 332, H - 1 }, { 148, H - 1 } }
c:rim(path, "#8a6a4a")
path:each(function(x, y)
  local v = hash(x, y, 4)
  local col = "#c9a072"
  if v < 0.07 then col = "#a9805a" elseif v < 0.12 then col = "#e2c08e" end
  if x < pxl(y) + 3 or x > pxr(y) - 3 then col = "#b08860" end
  P(x, y, col)
end)
-- stepping stones in perspective
local sy = HZ + 6
local k = 0
while sy < H - 4 do
  local t = (sy - HZ) / (H - HZ)
  local sw, sh = floor(6 + 26 * t), floor(2 + 9 * t)
  local cxs = 240 + ((k % 2 == 0) and -1 or 1) * floor(4 + 18 * t)
  local st = c:rrect(cxs - floor(sw / 2), sy, cxs + floor(sw / 2), sy + sh, math.min(3, floor(sh / 2)))
  st:shift(1, 2):each(function(x, y) if path:has(x, y) and not st:has(x, y) then P(x, y, "#8a6a5a") end end)
  solid(st, R.stone, { sd = 2, sdy = 1, tex = function(x, y, col) if hash(x, y, 8) < 0.06 then return R.stone.s end end })
  sy = sy + sh + floor(3 + 8 * t)
  k = k + 1
end

-------------------------------------------------------------------- BIG BACK TREES
-- left big tree behind the cottages
do
  local tr = c:poly{ { 174, 120 }, { 180, 60 }, { 188, 60 }, { 194, 120 } }
  solid(tr, R.bark, { tex = function(x, y, col) if x % 4 == 0 and hash(x, y, 2) < 0.6 then return R.bark.s end end })
  blobShade({ {40,58,40,30},{96,42,42,30},{150,40,40,28},{190,58,30,26},{70,84,36,18},{130,74,40,20},{20,80,24,22} }, R.leafB, 41)
  -- right big tree behind the wild arch
  local tr2 = c:poly{ { 402, 120 }, { 408, 70 }, { 418, 70 }, { 424, 120 } }
  solid(tr2, R.bark)
  blobShade({ {398,62,34,26},{446,48,40,30},{420,86,36,18},{372,80,22,16},{470,82,22,22} }, R.leafB, 42)
end

-------------------------------------------------------------------- HOMES (cottage cluster)
local function cottage(x0, x1, yb, wh, rh, wall, roof, door, o)
  o = o or {}
  local yt = yb - wh
  local cx = floor((x0 + x1) / 2)
  -- side wall toward the vanishing point
  local sw = o.side or 6
  local side = c:poly{ { x1 + 1, yt + 2 }, { x1 + sw, yt + 5 }, { x1 + sw, yb - 2 }, { x1 + 1, yb } }
  c:groundShadow(cx + 4, yb + 1, floor((x1 - x0) / 2) + 6, 3)
  c:fillMask(side, wall.s); c:rim(side, wall.d)
  side:each(function(x, y) if hash(x, y, 6) < 0.08 then P(x, y, wall.d) end end)
  -- front wall, textured plaster with exposed stones
  local fw = c:rect(x0, yt, x1, yb)
  solid(fw, wall, { sd = 2, tex = function(x, y, col)
    local v = hash(floor(x / 4), floor(y / 3), 7)
    if col == wall.b and v < 0.12 and (x % 4 ~= 0) and (y % 3 ~= 0) then return R.stone.b end
    if col == wall.b and hash(x, y, 77) < 0.05 then return wall.s end
    if y > yb - 3 then return wall.s end
  end })
  -- round door (arched)
  local dw, dh = o.dw or 16, o.dh or 22
  local door_m = c:rect(cx - floor(dw / 2), yb - dh + floor(dw / 2), cx + floor(dw / 2), yb)
  door_m:add(c:ellipse(cx, yb - dh + floor(dw / 2), floor(dw / 2), floor(dw / 2)))
  c:rim(door_m, INK)
  door_m:each(function(x, y)
    local col = door.b
    if (x - cx + 64) % 4 == 0 then col = door.s end
    if not door_m:has(x - 1, y) or not door_m:has(x, y - 1) then col = door.h end
    if not door_m:has(x + 2, y) then col = door.s end
    P(x, y, col)
  end)
  rectf(cx + floor(dw / 2) - 4, yb - floor(dh / 2), cx + floor(dw / 2) - 3, yb - floor(dh / 2) + 1, R.brass.h)
  hl(cx - floor(dw / 2) - 3, cx + floor(dw / 2) + 3, yb + 1, R.stone.b)
  -- windows with warm glow + flower box
  for _, wx in ipairs(o.wins or {}) do
    local wy = yb - dh + 2
    local ww, whh = o.ww or 10, o.wwh or 9
    local wm = c:rect(wx, wy, wx + ww - 1, wy + whh - 1)
    c:rim(wm, wall.d)
    wm:each(function(x, y) P(x, y, (y < wy + 3) and GLOW[1] or (y < wy + 6 and GLOW[2] or GLOW[3])) end)
    vl(wx + floor(ww / 2), wy, wy + whh - 1, R.wood.d); hl(wx, wx + ww - 1, wy + floor(whh / 2), R.wood.d)
    local fb = c:rect(wx - 1, wy + whh + 1, wx + ww, wy + whh + 3); solid(fb, R.wood, { sd = 1, sdy = 1 })
    for i = 0, ww do if i % 2 == 0 then P(wx - 1 + i, wy + whh, (i % 4 == 0) and "#f07aa0" or "#ffd860") end end
  end
  -- roof: thick thatch with rounded overhang
  local ov = o.ov or 6
  local rf = c:poly{ { x0 - ov, yt + 3 }, { cx - 6, yt - rh }, { cx + 6, yt - rh }, { x1 + ov, yt + 3 } }
  rf:add(c:rrect(x0 - ov, yt - 3, x1 + ov, yt + 5, 4))
  if o.turf then
    solid(rf, R.turf, { sd = 4, sdy = 3, tex = function(x, y, col)
      if hash(x, y, 13) < 0.08 then return R.turf.d end
      if hash(x, y, 14) < 0.03 then return "#f6e08a" end end })
  else
    solid(rf, roof, { sd = 4, sdy = 3, tex = function(x, y, col)
      if col ~= roof.h and (x % 3 == 0) and hash(x, floor(y / 4), 13) < 0.7 then return roof.s end
      if (y - yt) % 7 == 0 and col == roof.b then return roof.s end
    end })
  end
  -- eave shadow on wall
  hl(x0, x1, yt + 6, wall.d); hl(x0, x1, yt + 7, wall.s)
  return cx, yt
end

do
  -- cottage A (bigger, nearer): thatch, red door, chimney = stacked flowerpots (quirk)
  local cx, yt = cottage(42, 104, 140, 38, 26, R.plaster, R.thatch, R.red, { wins = { 46, 86 }, side = 7 })
  -- flowerpot chimney
  local p1 = c:poly{ { 52, yt - 18 }, { 64, yt - 18 }, { 62, yt - 6 }, { 54, yt - 6 } }
  solid(p1, R.pump, { sd = 2 })
  local p2 = c:poly{ { 53, yt - 28 }, { 63, yt - 28 }, { 61, yt - 19 }, { 55, yt - 19 } }
  solid(p2, R.pump, { sd = 2 }); hl(51, 65, yt - 18, R.pump.d); hl(52, 64, yt - 28, R.pump.h)
  c:cloud(46, yt - 32, 14, "#e8e0ea", "#b8a8c8"); c:cloud(36, yt - 42, 12, "#e8e0ea", "#b8a8c8")
  -- a boot used as a flower pot by the door (quirk)
  local boot = c:poly{ { 30, 140 }, { 30, 128 }, { 36, 128 }, { 36, 135 }, { 42, 136 }, { 42, 140 } }
  -- (boot sits left of the cottage on the lawn)
  solid(boot, R.dwood, { sd = 2 })
  for _, f in ipairs({ { 31, 125 }, { 34, 123 }, { 33, 126 } }) do P(f[1], f[2], "#f07aa0") P(f[1], f[2] + 1, "#3f7a44") P(f[1], f[2] + 2, "#3f7a44") end

  -- cottage B (further, smaller): turf roof, green door
  local cx2, yt2 = cottage(126, 164, 126, 28, 18, R.plaster2, R.thatch, R.green, { wins = { 129 }, ww = 8, wwh = 7, dw = 12, dh = 17, side = 5, turf = true, ov = 5 })
  -- little turf-roof flower tufts
  for _, f in ipairs({ { 130, yt2 - 2 }, { 150, yt2 - 10 }, { 160, yt2 - 1 } }) do P(f[1], f[2], "#f6e08a") P(f[1] + 1, f[2], "#f07aa0") end
  -- stone chimney on B
  local ch = c:rect(154, yt2 - 18, 160, yt2 - 6); solid(ch, R.stone, { sd = 2 })
  c:cloud(150, yt2 - 22, 12, "#e8e0ea", "#b8a8c8")
end

-------------------------------------------------------------------- WASHING LINE (far, between cottage and path)
do
  local function post(x, y0, y1) local m = c:rect(x, y0, x + 1, y1); solid(m, R.wood, { sd = 1, sdy = 1 }) end
  c:groundShadow(194, 125, 20, 2)
  post(174, 98, 124); post(212, 100, 124)
  -- sagging line
  for x = 176, 211 do local t = (x - 176) / 35; local y = floor(99 + 6 * (1 - (2 * t - 1) ^ 2)); P(x, y, "#e6d8c0") end
  local function cloth(x0, x1, y0, y1, r) local m = c:rect(x0, y0, x1, y1); solid(m, r, { sd = 1, sdy = 1 }) end
  cloth(179, 184, 103, 110, R.teal)
  cloth(187, 193, 105, 113, R.canvas)
  -- giant striped sock (quirk)
  local sock = c:poly{ { 196, 104 }, { 202, 104 }, { 202, 116 }, { 206, 118 }, { 206, 121 }, { 196, 121 } }
  c:rim(sock, R.red.d)
  sock:each(function(x, y) P(x, y, ((y // 2) % 2 == 0) and R.red.b or "#f6e08a") end)
  for _, x in ipairs({ 181, 189, 198 }) do P(x, 102, R.wood.b) end
end

-------------------------------------------------------------------- PEOPLE: noticeboard + bench
do
  c:groundShadow(334, 190, 46, 4)
  -- noticeboard posts + little teal roof
  local p1 = c:rect(296, 140, 299, 190); solid(p1, R.wood, { sd = 1, sdy = 1 })
  local p2 = c:rect(331, 140, 334, 190); solid(p2, R.wood, { sd = 1, sdy = 1 })
  local roof = c:poly{ { 290, 142 }, { 304, 130 }, { 326, 130 }, { 340, 142 } }
  roof:add(c:rect(290, 140, 340, 144))
  solid(roof, R.teal, { sd = 3, tex = function(x, y, col) if (y - 130) % 4 == 3 and col == R.teal.b then return R.teal.s end end })
  local board = c:rect(300, 147, 330, 176)
  c:rim(board, R.cork.d)
  board:each(function(x, y) local v = hash(x, y, 51)
    P(x, y, v < 0.12 and R.cork.s or (v < 0.2 and R.cork.h or R.cork.b)) end)
  -- notes with picture icons (no text)
  local function note(x0, y0, x1, y1, col, pin)
    local m = c:rect(x0, y0, x1, y1); c:rim(m, "#8a7060"); c:fillMask(m, col)
    hl(x0, x1, y1, "#c8b8a0"); P(floor((x0 + x1) / 2), y0, pin); P(floor((x0 + x1) / 2), y0 + 1, pin)
  end
  note(303, 150, 313, 162, "#fff0d0", R.red.b)       -- leaf sketch
  for i = 0, 4 do P(305 + i, 160 - i, R.green.b) P(306 + i, 160 - i, R.green.h) end; P(305, 161, R.green.d)
  note(317, 149, 327, 159, "#f6e08a", R.teal.b)       -- cake icon
  rectf(319, 154, 325, 157, R.pump.b); hl(319, 325, 153, "#fff4d6"); P(322, 152, R.red.b); P(322, 151, GLOW[2])
  note(306, 165, 317, 174, "#d8ecf0", R.brass.b)      -- star/sparkle
  P(311, 167, R.brass.b); hl(309, 313, 169, R.brass.b); P(311, 168, R.brass.b); P(311, 170, R.brass.b); P(311, 171, R.brass.b); P(311, 169, R.brass.h)
  note(320, 163, 328, 173, "#f0c8d8", R.green.b)      -- heart-ish (two squares)
  rectf(322, 166, 323, 168, R.red.b); rectf(325, 166, 326, 168, R.red.b); rectf(323, 168, 325, 170, R.red.b); P(324, 171, R.red.b)
  -- bench (teal painted slats)
  local back = c:rect(344, 160, 378, 172)
  c:rim(back, R.teal.d)
  back:each(function(x, y) P(x, y, ((y - 160) % 4 == 3) and R.teal.d or ((y - 160) % 4 == 0 and R.teal.h or R.teal.b)) end)
  local seat = c:rect(342, 175, 380, 179); solid(seat, R.teal, { sd = 2, sdy = 1 })
  for _, lx in ipairs({ 345, 376 }) do local l = c:rect(lx, 172, lx + 2, 190); solid(l, R.dwood, { sd = 1, sdy = 1 }) end
  for _, lx in ipairs({ 345, 376 }) do local l = c:rect(lx, 180, lx + 2, 190); solid(l, R.dwood, { sd = 1, sdy = 1 }) end
  -- quirk: a forgotten teacup with steam on the bench
  local cup = c:rect(366, 169, 371, 174); solid(cup, R.canvas, { sd = 1, sdy = 1, rim = R.violet.d })
  P(372, 171, R.violet.d); P(373, 171, R.violet.d); P(373, 172, R.violet.d); P(372, 173, R.violet.d)
  hl(366, 371, 170, R.pump.b)
  P(368, 166, "#e8e0ea"); P(369, 165, "#e8e0ea"); P(368, 164, "#e8e0ea")
end

-------------------------------------------------------------------- DO: the well on the village green
do
  c:groundShadow(174, 205, 42, 5)
  -- stone barrel
  local body = c:rect(142, 176, 206, 202)
  c:rim(body, INK)
  body:each(function(x, y)
    local row = floor((y - 176) / 5)
    local off = (row % 2) * 6
    local col = R.stone.b
    if (y - 176) % 5 == 4 or (x - 142 + off) % 12 == 0 then col = R.stone.d
    elseif x > 199 then col = R.stone.s
    elseif x < 150 or (y - 176) % 5 == 0 then col = R.stone.h end
    if col == R.stone.b and hash(x, y, 61) < 0.08 then col = R.stone.s end
    if col == R.stone.b and hash(x, y, 62) < 0.03 then col = "#7aa656" end -- moss
    P(x, y, col)
  end)
  -- rim lip and dark opening (flattened)
  local lip = c:rect(138, 170, 210, 177); solid(lip, R.stone, { sd = 3, sdy = 2 })
  local hole = c:rect(146, 172, 202, 175); c:fillMask(hole, "#2e2a44"); hl(146, 202, 172, INK)
  for x = 150, 198, 9 do P(x, 174, "#5a6ab0") P(x + 1, 174, "#7a8ad0") end -- water glints
  -- posts
  for _, px in ipairs({ 146, 198 }) do local m = c:rect(px, 152, px + 4, 170); solid(m, R.wood, { sd = 2, sdy = 1, rim = INK }) end
  -- winch axle + rope + crank
  local ax = c:rect(150, 156, 197, 158); solid(ax, R.dwood, { sd = 1, sdy = 1, rim = INK })
  vl(174, 159, 171, "#e6d8c0"); vl(175, 159, 171, "#b8a888")
  local crank = c:rect(203, 156, 206, 158); solid(crank, R.dwood, { sd = 1, sdy = 1 }); vl(206, 157, 162, R.dwood.d)
  -- red tile roof
  local rf = c:poly{ { 132, 156 }, { 160, 140 }, { 188, 140 }, { 216, 156 } }
  rf:add(c:rect(132, 154, 216, 157))
  solid(rf, R.tile, { sd = 4, sdy = 2, rim = INK, tex = function(x, y, col)
    if (y - 140) % 4 == 3 and col ~= R.tile.h then return R.tile.s end
    if ((x + (floor((y - 140) / 4) % 2) * 3) % 6 == 0) and col == R.tile.b then return R.tile.s end
  end })
  -- tiny weather charm on ridge (bucket icon)
  vl(174, 134, 139, R.dwood.d); rectf(171, 130, 177, 134, R.brass.b); hl(171, 177, 130, R.brass.h)
  -- bucket on the lip with a sprout growing in it (quirk)
  local bk = c:poly{ { 186, 162 }, { 196, 162 }, { 195, 170 }, { 187, 170 } }
  solid(bk, R.wood, { sd = 2, sdy = 1, rim = INK }); hl(186, 196, 165, R.stone.s); hl(187, 195, 168, R.stone.s)
  vl(191, 156, 161, R.green.s); P(190, 156, R.green.h); P(189, 155, R.green.h); P(192, 157, R.green.h); P(193, 156, R.green.h)
  -- flowers on the green
  for _, f in ipairs({ { 132, 204 }, { 214, 200 }, { 138, 208 }, { 210, 208 }, { 124, 200 } }) do P(f[1], f[2], "#f6e08a") P(f[1] + 1, f[2], "#f07aa0") end
end

-------------------------------------------------------------------- WILD TRAIL: bramble arch on the right edge
do
  -- dark forest gap behind the arch
  local gap = c:poly{ { 404, 128 }, { 470, 120 }, { 470, 196 }, { 404, 200 } }
  gap:each(function(x, y) local t = (y - 120) / 80
    local col = t < 0.5 and "#2e4a46" or "#28403e"
    if hash(x, y, 71) < 0.08 then col = "#3a5a50" end
    P(x, y, col) end)
  -- trail continuing into the gap
  local tt = c:poly{ { 404, 182 }, { 470, 178 }, { 470, 194 }, { 404, 200 } }
  tt:each(function(x, y) P(x, y, hash(x, y, 72) < 0.15 and "#7a6a5a" or "#9a805e") end)
  -- glowing mushrooms in the gap (quirk)
  for _, m in ipairs({ { 448, 170 }, { 456, 174 }, { 436, 166 } }) do
    hl(m[1] - 2, m[1] + 2, m[2], "#7fd0c8"); hl(m[1] - 1, m[1] + 1, m[2] - 1, "#bff0e0"); vl(m[1], m[2] + 1, m[2] + 3, "#e6d8c0")
  end
  -- left gnarled trunk of the arch
  local tr = c:poly{ { 394, 204 }, { 398, 140 }, { 404, 118 }, { 412, 120 }, { 408, 140 }, { 408, 204 } }
  solid(tr, R.bark, { rim = INK, tex = function(x, y, col) if (x + floor(y / 5)) % 4 == 0 and col == R.bark.b then return R.bark.s end end })
  -- arching bramble canopy
  blobShade({ {404,112,18,14},{426,104,20,14},{450,108,22,16},{470,116,14,20},{398,132,10,12} }, R.leaf, 81, INK)
  -- berries on brambles
  for _, b in ipairs({ { 414, 110 }, { 432, 116 }, { 452, 100 }, { 400, 126 }, { 462, 122 } }) do
    P(b[1], b[2], "#c0485a") P(b[1] + 1, b[2], "#8e2f40") P(b[1], b[2] - 1, "#f07a8a")
  end
  -- wild signpost: arrow board pointing right with a leaf icon
  c:groundShadow(424, 205, 9, 2)
  local post = c:rect(422, 150, 426, 204); solid(post, R.dwood, { sd = 2, sdy = 1, rim = INK })
  local arrow = c:poly{ { 412, 152 }, { 446, 152 }, { 454, 158 }, { 446, 164 }, { 412, 164 } }
  solid(arrow, R.wood, { sd = 2, sdy = 2, rim = INK, tex = function(x, y, col) if (y - 152) % 4 == 0 and col == R.wood.b then return R.wood.s end end })
  -- leaf icon
  for i = 0, 6 do local w = (i < 3) and i or (6 - i); hl(426 + i * 2 - 0, 426 + i * 2 + 1, 158 - floor(w / 2), R.green.h); hl(426 + i * 2, 426 + i * 2 + 1, 158 + floor(w / 2), R.green.b) end
  hl(426, 438, 158, R.green.d)
end

-------------------------------------------------------------------- GARDEN: veg plot, scarecrow, picket fence + gate
do
  -- soil plot in perspective
  local plot = c:poly{ { 46, 192 }, { 116, 192 }, { 124, 246 }, { 36, 246 } }
  c:rim(plot, R.soil.d)
  plot:each(function(x, y)
    local col = ((y - 192) % 9 < 3) and R.soil.s or R.soil.b
    if hash(x, y, 91) < 0.06 then col = R.soil.h end
    P(x, y, col)
  end)
  -- scarecrow (rear right corner), flowerpot hat with a flower (quirk)
  local sx = 104
  local pole = c:rect(sx - 1, 186, sx + 1, 214); solid(pole, R.wood, { sd = 1, sdy = 1, rim = INK })
  local arms = c:rect(sx - 14, 194, sx + 14, 196); solid(arms, R.wood, { sd = 1, sdy = 1, rim = INK })
  local coat = c:poly{ { sx - 7, 193 }, { sx + 7, 193 }, { sx + 9, 208 }, { sx - 9, 208 } }
  solid(coat, R.teal, { sd = 2, rim = INK, tex = function(x, y, col) if y == 200 and col == R.teal.b then return R.teal.d end end })
  rectf(sx + 2, 202, sx + 5, 205, R.red.b) -- patch
  P(sx + 2, 202, R.red.h)
  for _, s in ipairs({ { sx - 16, 195 }, { sx + 15, 195 }, { sx - 8, 209 }, { sx + 8, 209 } }) do P(s[1], s[2], R.thatch.h) P(s[1], s[2] + 1, R.thatch.b) P(s[1] + 1, s[2] + 1, R.thatch.h) end
  local head = c:rrect(sx - 5, 182, sx + 5, 192, 3); solid(head, R.canvas, { sd = 2, rim = INK })
  P(sx - 2, 186, R.dwood.d); P(sx + 2, 186, R.dwood.d); hl(sx - 2, sx + 2, 189, R.cork.s) -- stitched face
  local hat = c:poly{ { sx - 6, 182 }, { sx + 6, 182 }, { sx + 4, 174 }, { sx - 4, 174 } }
  solid(hat, R.pump, { sd = 2, rim = INK }); hl(sx - 6, sx + 6, 181, R.pump.d); hl(sx - 5, sx + 5, 174, R.pump.h)
  vl(sx, 166, 173, R.green.s); P(sx - 1, 169, R.green.h); P(sx + 1, 170, R.green.h)
  rectf(sx - 1, 164, sx + 1, 166, "#f07aa0"); P(sx, 165, "#ffd860")
  -- veg rows: cabbages, carrots, pumpkins
  local function cabbage(x, y, s)
    local m = c:ellipse(x, y, s, s - 1)
    solid(m, R.green, { sd = 2, sdy = 2, tex = function(px, py, col) if (px - x) == 0 or py == y then return R.green.s end end })
  end
  for i = 0, 5 do cabbage(52 + i * 11, 202, 4) end
  for i = 0, 8 do local x = 48 + i * 8; local y = 216
    vl(x, y - 4, y, "#4f9a48"); P(x - 1, y - 4, "#7fc060"); P(x + 1, y - 5, "#7fc060"); hl(x - 1, x + 1, y + 1, R.pump.b) end
  for i = 0, 3 do
    local x, y = 52 + i * 19, 233
    local m = c:rrect(x - 6, y - 4, x + 6, y + 4, 3)
    solid(m, R.pump, { sd = 3, sdy = 2, rim = R.pump.d, tex = function(px, py, col) if (px - x) % 4 == 0 and col ~= R.pump.h then return R.pump.s end end })
    vl(x, y - 6, y - 5, R.green.s); P(x + 1, y - 6, R.green.h)
  end
  -- picket fence with a gate in the middle (gate has a sprout icon)
  local fenceY0, fenceY1 = 244, 262
  local rail1 = c:rect(32, 248, 128, 250); local rail2 = c:rect(32, 256, 128, 258)
  c:rim(rail1, INK); c:rim(rail2, INK); c:fillMask(rail1, "#d8c8a8"); c:fillMask(rail2, "#d8c8a8")
  hl(32, 128, 248, "#f0e4cc"); hl(32, 128, 256, "#f0e4cc")
  local function picket(x, col)
    local m = c:poly{ { x, fenceY0 + 2 }, { x + 2, fenceY0 }, { x + 4, fenceY0 + 2 }, { x + 4, fenceY1 }, { x, fenceY1 } }
    solid(m, { d = INK, s = "#c8b8a0", b = col or "#f0e4cc", h = "#fff4d6" }, { sd = 1, sdy = 1, rim = INK })
  end
  for x = 32, 64, 8 do picket(x) end
  for x = 98, 124, 8 do picket(x) end
  -- gate (green-painted, arched top)
  local gate = c:poly{ { 70, 246 }, { 80, 240 }, { 90, 246 }, { 90, 262 }, { 70, 262 } }
  c:rim(gate, INK)
  gate:each(function(x, y)
    local col = ((x - 70) % 4 == 0) and R.green.s or R.green.b
    if y == 250 or y == 258 then col = R.green.d end
    if (x - 70) == 1 then col = R.green.h end
    P(x, y, col)
  end)
  -- sprout icon on the gate
  vl(80, 251, 255, R.brass.h); P(79, 251, R.brass.h); P(78, 250, R.brass.h); P(81, 252, R.brass.h); P(82, 251, R.brass.h)
  P(88, 254, R.brass.b) -- latch
end

-------------------------------------------------------------------- STOP: village signpost with a lantern
do
  c:groundShadow(332, 247, 14, 3)
  local post = c:rect(328, 202, 333, 246); solid(post, R.dwood, { sd = 2, sdy = 1, rim = INK,
    tex = function(x, y, col) if y % 6 == 0 and col == R.dwood.b then return R.dwood.s end end })
  local arm = c:rect(318, 204, 352, 207); solid(arm, R.dwood, { sd = 1, sdy = 1, rim = INK })
  -- board with a little house-with-hearth icon
  local board = c:rect(312, 214, 330, 230); solid(board, R.brass, { sd = 2, sdy = 2, rim = INK })
  local roof = c:poly{ { 315, 222 }, { 321, 217 }, { 327, 222 } }; c:fillMask(roof, R.red.b)
  rectf(316, 222, 326, 227, R.plaster.b); rectf(320, 224, 322, 227, R.red.d); P(321, 225, GLOW[2])
  -- hanging lantern from the arm
  vl(347, 208, 212, INK)
  local lan = c:rect(343, 214, 351, 226); c:rim(lan, INK)
  lan:each(function(x, y)
    local col = GLOW[2]
    if x == 343 or x == 351 or y == 214 or y == 226 then col = R.brass.b end
    if y < 218 and x > 344 and x < 350 then col = GLOW[1] end
    if y > 222 and x > 344 and x < 350 then col = GLOW[3] end
    P(x, y, col)
  end)
  local cap = c:poly{ { 342, 214 }, { 347, 210 }, { 352, 214 } }; c:fillMask(cap, R.brass.d); P(346, 211, R.brass.h)
  -- warm glow pixels around the lantern on the grass
  for _, g in ipairs({ { 340, 230 }, { 354, 230 }, { 347, 232 }, { 338, 222 }, { 356, 220 } }) do P(g[1], g[2], "#e6d47a") end
end

-------------------------------------------------------------------- FRAME: tree trunk left, branch on top, vines right
do
  -- left trunk with roots and a round door in it (quirk)
  local tr = c:poly{ { 0, 0 }, { 22, 0 }, { 24, 200 }, { 30, 250 }, { 40, 269 }, { 0, 269 } }
  solid(tr, R.bark, { rim = INK, sd = 6, tex = function(x, y, col)
    if (x + floor(y / 9)) % 5 == 0 then return R.bark.d end
    if col == R.bark.b and hash(x, y, 101) < 0.05 then return R.bark.h end
  end })
  local door = c:rect(6, 226, 18, 248); door:add(c:ellipse(12, 226, 6, 6))
  c:rim(door, INK)
  door:each(function(x, y) P(x, y, ((x - 6) % 3 == 0) and R.brass.s or R.brass.b) end)
  P(16, 238, R.brass.h); P(16, 239, R.brass.d)
  rectf(10, 230, 14, 234, GLOW[2]); vl(12, 230, 234, R.dwood.d); hl(10, 14, 232, R.dwood.d)
  -- ivy on the trunk
  for i = 0, 14 do local x = 4 + floor(hash(i, 1, 5) * 16); local y = 30 + i * 13
    P(x, y, R.leaf.h); P(x + 1, y, R.leaf.b); P(x, y + 1, R.leaf.b); P(x + 1, y + 1, R.leaf.s) end
  -- top branch across the whole width
  local br = c:poly{ { 0, 0 }, { 479, 0 }, { 479, 9 }, { 300, 12 }, { 240, 10 }, { 140, 13 }, { 0, 14 } }
  solid(br, R.bark, { rim = INK, sd = 3, sdy = 3, tex = function(x, y, col) if (x + y * 7) % 11 == 0 then return R.bark.d end end })
  -- leafy clumps hanging from the branch
  blobShade({ {30,14,22,10},{90,12,16,7},{150,14,14,6},{214,12,12,5},{290,13,14,6},{352,12,16,7},{420,14,22,10},{468,18,16,14} }, R.leaf, 111, INK)
  -- right-hand hanging vine branch
  blobShade({ {470,40,12,16},{474,66,10,16},{466,88,8,10} }, R.leaf, 112, INK)
  -- hanging lantern (left)
  vl(52, 20, 28, INK); vl(53, 20, 28, R.brass.d)
  local lan = c:rect(46, 32, 58, 46); c:rim(lan, INK)
  lan:each(function(x, y)
    local col = GLOW[2]
    if x == 46 or x == 58 or y == 32 or y == 46 or x == 52 then col = R.brass.b end
    if y < 37 and x ~= 52 and x > 46 and x < 58 then col = GLOW[1] end
    if y > 41 and x ~= 52 and x > 46 and x < 58 then col = GLOW[3] end
    P(x, y, col)
  end)
  local lc = c:poly{ { 44, 32 }, { 52, 27 }, { 60, 32 } }; c:rim(lc, INK); c:fillMask(lc, R.brass.s); hl(48, 54, 29, R.brass.h)
  rectf(50, 47, 54, 48, R.brass.d)
  -- acorn charm (right) on twine
  vl(440, 22, 34, "#e6d8c0")
  local cupm = c:rrect(433, 34, 447, 40, 2); solid(cupm, R.dwood, { sd = 2, sdy = 1, rim = INK, tex = function(x, y, col) if (x + y) % 3 == 0 then return R.dwood.d end end })
  local nut = c:poly{ { 434, 41 }, { 446, 41 }, { 445, 48 }, { 440, 53 }, { 435, 48 } }
  solid(nut, R.brass, { sd = 2, sdy = 2, rim = INK })
  vl(440, 31, 33, R.dwood.d)
  -- little ribbon on charm
  P(437, 54, R.red.b); P(443, 54, R.red.b); P(438, 55, R.red.b); P(442, 55, R.red.b)
end

c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = out .. "here-village.aseprite", png = out .. "here-village.png", scale = 1 }

local spots = {
  { k = "do",     name = "Village Green & Well", box = { 130, 143, 218, 212 } },
  { k = "people", name = "Bench & Noticeboard",  box = { 288, 128, 382, 194 } },
  { k = "stop",   name = "Village Signpost",     box = { 310, 198, 358, 250 } },
  { k = "homes",  name = "Cottages",             box = { 26, 54, 174, 142 } },
  { k = "garden", name = "Your Garden",          box = { 28, 162, 126, 264 } },
  { k = "wild",   name = "Wild Trail",           box = { 390, 96, 470, 212 } },
}
local stand = { { 70, 152 }, { 246, 152 }, { 158, 228 }, { 262, 210 }, { 214, 252 }, { 280, 254 } }
local parts = {}
for _, s in ipairs(spots) do
  local b = s.box
  parts[#parts + 1] = string.format('{"k":"%s","name":"%s","x":%d,"y":%d,"box":[%d,%d,%d,%d]}',
    s.k, s.name, floor((b[1] + b[3]) / 2), floor((b[2] + b[4]) / 2), b[1], b[2], b[3], b[4])
end
local st = {}
for _, p in ipairs(stand) do st[#st + 1] = string.format('{"x":%d,"y":%d}', p[1], p[2]) end
local f = io.open(out .. "here-village.layout.json", "w")
f:write(string.format('{"w":480,"h":270,"horizon":%d,"view":"gate","spots":[%s],"stand":[%s],"compass_clear":[380,230,480,270]}\n',
  HZ, table.concat(parts, ","), table.concat(st, ",")))
f:close()
print("ok here-village")
