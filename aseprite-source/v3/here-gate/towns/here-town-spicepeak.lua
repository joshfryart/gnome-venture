-- here-town-spicepeak.lua : Gnome Venture "Hearth Pop" v3 town gate view, Spicepeak (Himalayan foothills hill-terrace town).
-- 480x270 native, opaque scene, one-point perspective VP (240,112). Morning light from upper left.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = (app.params and app.params.out) or "/home/user/gnome-venture/aseprite-source/v3/here-gate/towns/"
local NAME = "here-town-spicepeak"
local W, H = 480, 270
local VX, VY = 240, 112
local HOR = 116
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local floor, abs, min, max = math.floor, math.abs, math.min, math.max

---------------------------------------------------------------- helpers
local function hsh(x, y, s)
  local n = (floor(x) * 374761393 + floor(y) * 668265263 + (s or 0) * 1442695041) % 4294967296
  n = ((n ~ (n >> 13)) * 1274126177) % 4294967296
  n = n ~ (n >> 16)
  return (n % 10007) / 10007
end
local function put(x, y, h) if x >= 0 and y >= 0 and x < W and y < H then c:put(x, y, h) end end
local function F(m, h) c:fillMask(m, h) return m end
local function R(x0, y0, x1, y1) return c:rect(floor(x0), floor(y0), floor(x1), floor(y1)) end
local function P(t) return c:poly(t) end
local function L(t, w) return c:line(t, w or 1) end
local function hx(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
local function mix(a, b, t)
  local r1, g1, b1 = hx(a) local r2, g2, b2 = hx(b)
  return string.format("#%02x%02x%02x", floor(r1 + (r2 - r1) * t + .5), floor(g1 + (g2 - g1) * t + .5), floor(b1 + (b2 - b1) * t + .5))
end
local VIO, WARM = "#4a3a6e", "#ffe9b8"
local function tint(m, to, t) m:each(function(x, y) local h = c:get(x, y) if h then put(x, y, mix(h, to, t)) end end) return m end
local function shadow(m, t) return tint(m, VIO, t or .32) end
local function toward(x, y, t) return x + (VX - x) * t, y + (VY - y) * t end
-- light top-left rim, violet lower-right band, own dark edge
local function form(m, deep, o)
  o = o or {}
  local band, lit = o.band or 2, o.lit or .22
  local sh, li = HP.mask(), HP.mask()
  m:each(function(x, y)
    if not m:has(x + band, y) or not m:has(x, y + band) then sh:set(x, y) end
    if not m:has(x - 1, y) or not m:has(x, y - 1) then li:set(x, y) end
  end)
  if not o.noshade then tint(sh, VIO, o.shade or .22) end
  if not o.nolight then tint(li, WARM, lit) end
  if deep then c:edgeIn(m, deep) end
  return m
end
-- textures. ramp = {deep, shade, base, light, alt}
local function stone(m, r, ch, bw, seed)
  ch, bw, seed = ch or 5, bw or 10, seed or 1
  local x0, y0 = m:bbox()
  m:each(function(x, y)
    local row, ry = (y - y0) // ch, (y - y0) % ch
    local xx = x + (row % 2) * (bw // 2) + floor(hsh(row, 0, seed) * 3)
    local bid, bx = xx // bw, xx % bw
    local hv = hsh(bid, row, seed)
    local col
    if ry == ch - 1 or bx == bw - 1 then col = r[2]
    else
      col = (hv < .28) and r[4] or ((hv > .74) and r[5] or r[3])
      if ry == 0 and bx < bw - 2 and hv < .6 then col = r[4] end
      if ry == ch - 2 and bx > bw - 4 then col = mix(col, VIO, .12) end
    end
    put(x, y, col)
  end)
  return m
end
local function planks(m, r, pw, seed, horiz)
  pw = pw or 4
  m:each(function(x, y)
    local a, b = horiz and y or x, horiz and x or y
    local k = a % pw
    local col = r[3]
    if k == pw - 1 then col = r[2] elseif k == 0 then col = r[4] end
    local g = hsh(a // pw, b // 4, seed or 3)
    if k > 0 and k < pw - 1 and g > .82 then col = r[5] end
    if k > 0 and k < pw - 1 and hsh(a, b, (seed or 3) + 9) > .985 then col = r[1] end -- knot
    put(x, y, col)
  end)
  return m
end
local function plaster(m, r, seed)
  m:each(function(x, y)
    local v = hsh(x, y, seed or 5)
    local col = r[3]
    if v > .93 then col = r[5] elseif v < .05 then col = r[4] end
    put(x, y, col)
  end)
  return m
end
local function tiles(m, r, rh, tw, seed) -- roof tiles: rows with scallop shade
  rh, tw = rh or 4, tw or 5
  local x0, y0 = m:bbox()
  m:each(function(x, y)
    local row, ry = (y - y0) // rh, (y - y0) % rh
    local xx = (x + (row % 2) * (tw // 2)) % tw
    local col = r[3]
    if ry == rh - 1 then col = r[1] elseif ry == rh - 2 and (xx == tw - 1 or xx == 0) then col = r[2]
    elseif xx == tw - 1 then col = r[2] elseif ry == 0 and xx < 2 then col = r[4] end
    if col == r[3] and hsh(x // tw, row, seed or 7) > .78 then col = r[5] end
    put(x, y, col)
  end)
  return m
end
local GLOW = { "#ffdc8e", "#f8bf62", "#e3914a", "#7a3f2a" }
local function window(x0, y0, x1, y1, frame, o)
  o = o or {}
  F(R(x0 - 1, y0 - 1, x1 + 1, y1 + 1), frame)
  local inn = R(x0, y0, x1, y1)
  inn:each(function(x, y)
    local t = (y - y0) / max(1, y1 - y0)
    put(x, y, t < .3 and GLOW[1] or (t < .75 and GLOW[2] or GLOW[3]))
  end)
  if o.shelves then -- book spines
    local cols = { "#b8443a", "#3f6fb0", "#4f9a5a", "#e2b33c", "#8a4f9a", "#d77a3a" }
    for y = y0 + 3, y1, 5 do
      F(R(x0, y, x1, y), "#6e432c")
      for x = x0, x1 do
        if hsh(x, y, 4) > .25 then
          local col = cols[floor(hsh(x, y, 2) * #cols) + 1]
          local hgt = 2 + floor(hsh(x, y, 8) * 2)
          for yy = y - hgt, y - 1 do if yy >= y0 then put(x, yy, col) end end
        end
      end
    end
  end
  if not o.nomull then
    local mx = (x0 + x1) // 2
    F(R(mx, y0, mx, y1), frame)
    if y1 - y0 > 8 then F(R(x0, (y0 + y1) // 2, x1, (y0 + y1) // 2), frame) end
  end
  F(R(x0 - 2, y1 + 2, x1 + 2, y1 + 2), o.sill or mix(frame, WARM, .3))
  F(R(x0 - 2, y1 + 3, x1 + 2, y1 + 3), mix(frame, VIO, .4))
end
local FLAGC = { "#3f6fc4", "#f1ece4", "#d4423a", "#3f9a5a", "#f0c53a" }
local function flags(x0, y0, x1, y1, sag, step, fw, fh, off)
  local function at(t) return x0 + (x1 - x0) * t, y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) end
  local pts = {}
  for i = 0, 60 do local x, y = at(i / 60) pts[#pts + 1] = { x, y } end
  F(L(pts, 1), "#5b4448")
  local len = math.sqrt((x1 - x0) ^ 2 + (y1 - y0) ^ 2)
  local n = floor(len / step)
  for i = 1, n - 1 do
    local x, y = at(i / n)
    x, y = floor(x), floor(y)
    local col = FLAGC[(i + (off or 0)) % 5 + 1]
    local fl = (i % 2 == 0) and 1 or 0
    local m = P{ { x - fw // 2, y + 1 }, { x + fw - fw // 2, y + 1 }, { x + fw - fw // 2 + fl, y + fh + 1 }, { x - fw // 2 + fl, y + fh + 1 } }
    F(m, col)
    form(m, mix(col, VIO, .45), { band = 1, lit = .15, shade = .25 })
  end
end
local function heap(cx, by, w, h, base, seed)
  local m = P{ { cx - w / 2, by + 1 }, { cx - w * .38, by - h * .45 }, { cx - w * .2, by - h * .85 }, { cx - w * .05, by - h },
    { cx + w * .1, by - h }, { cx + w * .26, by - h * .78 }, { cx + w * .42, by - h * .38 }, { cx + w / 2 + 1, by + 1 } }
  m:each(function(x, y)
    local col = base
    local v = hsh(x, y, seed or 11)
    if x > cx + w * .08 + (y - (by - h)) * .15 then col = mix(base, VIO, .25) end
    if x < cx - w * .15 and y < by - h * .35 then col = mix(base, WARM, .25) end
    if v > .88 then col = mix(col, VIO, .2) elseif v < .08 then col = mix(col, WARM, .35) end
    put(x, y, col)
  end)
  c:edgeIn(m, mix(base, VIO, .55))
  put(floor(cx - w * .12), floor(by - h * .82), mix(base, WARM, .6))
  return m
end
local function sack(x0, y0, w, h, cloth, spice, seed)
  local m = c:rrect(x0, y0 + 3, x0 + w - 1, y0 + h - 1, 3)
  m:add(P{ { x0 + 1, y0 + 4 }, { x0 + 2, y0 }, { x0 + w - 3, y0 }, { x0 + w - 2, y0 + 4 } })
  plaster(m, { 0, 0, cloth, mix(cloth, WARM, .3), mix(cloth, VIO, .2) }, seed)
  -- weave
  m:each(function(x, y) if (x + y) % 4 == 0 and hsh(x, y, 2) > .5 then put(x, y, mix(cloth, VIO, .15)) end end)
  form(m, mix(cloth, VIO, .55), { band = 2 })
  F(R(x0 + 1, y0 + 3, x0 + w - 2, y0 + 4), mix(cloth, WARM, .35)) -- rolled rim
  heap(x0 + w / 2 - .5, y0 + 2, w - 4, 5, spice, seed)
  shadow(P{ { x0 + 2, y0 + h }, { x0 + w + 3, y0 + h }, { x0 + w + 5, y0 + h + 2 }, { x0 + 4, y0 + h + 2 } }, .3)
end
local function steam(x, y0, y1, seed, col)
  for y = y1, y0, -1 do
    local t = (y1 - y) / max(1, y1 - y0)
    local dx = floor(math.sin((y + seed) * .35) * (1 + t * 3) + .5)
    local wdt = 1 + floor(t * 2.5)
    if hsh(seed, y // 5, 3) > .15 then
      for k = 0, wdt - 1 do put(x + dx + k, y, (k == 0) and (col or "#f6f1ea") or "#ddd6e6") end
    end
  end
end
local function lantern(x, ytop, ylen, teapot)
  F(R(x, ytop, x, ytop + ylen), "#4a3438")
  local y = ytop + ylen
  -- glow halo (diamond, banded)
  local halo = P{ { x, y - 8 }, { x + 13, y + 6 }, { x, y + 20 }, { x - 13, y + 6 } }
  tint(halo, "#ffd27a", .22)
  local halo2 = P{ { x, y - 3 }, { x + 8, y + 6 }, { x, y + 15 }, { x - 8, y + 6 } }
  tint(halo2, "#ffd27a", .2)
  if teapot then -- quirk: a teapot-shaped lantern
    local body = c:rrect(x - 6, y + 2, x + 6, y + 12, 3)
    F(body, "#ffcf72")
    F(R(x - 4, y + 9, x + 4, y + 12), "#f2a54e")
    F(R(x - 5, y + 2, x + 5, y + 3), "#b8662e")
    form(body, "#7a3a20", { band = 1 })
    F(R(x - 2, y, x + 2, y + 1), "#b8662e") put(x, y - 1, "#7a3a20")
    F(L({ { x + 7, y + 6 }, { x + 9, y + 4 }, { x + 11, y + 1 } }, 2), "#b8662e") -- spout
    F(L({ { x - 7, y + 4 }, { x - 9, y + 6 }, { x - 7, y + 10 } }, 1), "#7a3a20") -- handle
    steam(x + 11, y - 9, y - 1, 7)
    put(x - 3, y + 4, "#fff4d0")
  else
    F(P{ { x - 4, y }, { x + 4, y }, { x + 6, y + 3 }, { x - 6, y + 3 } }, "#8a3a2a")
    local body = R(x - 4, y + 4, x + 4, y + 13)
    F(body, "#ffd27a")
    F(R(x - 4, y + 10, x + 4, y + 13), "#f3a94e")
    F(R(x - 5, y + 4, x - 5, y + 13), "#8a3a2a") F(R(x + 5, y + 4, x + 5, y + 13), "#8a3a2a")
    F(R(x, y + 4, x, y + 13), "#c25a34")
    F(R(x - 5, y + 14, x + 5, y + 15), "#8a3a2a")
    F(R(x - 1, y + 16, x + 1, y + 18), "#d4423a") -- tassel
    put(x - 3, y + 5, "#fff4d0")
  end
end

---------------------------------------------------------------- sky (warm morning)
c:stripes(0, HOR, { "#7fb6e3", "#93c3e6", "#a9cfe5", "#c3dae0", "#dde0d2", "#f0dcb4", "#f8d29a" }, { 3, 3, 3, 3, 2, 2, 2 })
-- soft sun rays from the upper left
for i = 0, 3 do
  local x0 = 30 + i * 46
  tint(P{ { x0, 14 }, { x0 + 12, 14 }, { x0 + 84, 116 }, { x0 + 66, 116 } }, "#fff0c4", .1)
end
c:cloud(40, 44, 46, "#fbf3e6", "#e2d6e6")
c:cloud(118, 30, 34, "#fbf3e6", "#e2d6e6")
c:cloud(312, 38, 52, "#fbf3e6", "#e2d6e6")
c:cloud(404, 26, 30, "#fbf3e6", "#e2d6e6")

---------------------------------------------------------------- far snowy peaks
local PEAKS = { { 34, 50, 1.0 }, { 118, 34, 1.15 }, { 176, 60, 1.1 }, { 318, 40, 1.05 }, { 398, 30, 1.1 }, { 466, 54, 1.0 } }
for x = 0, W - 1 do
  local best, bk = 1e9, 1
  for k, p in ipairs(PEAKS) do
    local f = p[2] + abs(x - p[1]) * p[3] + hsh(x // 3, k, 21) * 2.5
    if f < best then best, bk = f, k end
  end
  local p = PEAKS[bk]
  local right = x > p[1]
  local snowy = p[2] + 14 + floor(hsh(x // 2, bk, 5) * 6)
  for y = floor(best), HOR do
    local col
    if y < snowy then col = right and "#c9cbe8" or "#fbf2e6"
    else
      col = right and "#8689bf" or "#a3a7d6"
      if (y + x // 2) % 9 == 0 and hsh(x, y, 3) > .4 then col = right and "#7b7db5" or "#9599cc" end -- rock striations
    end
    if y == floor(best) then col = right and "#b7b9de" or "#fff6ea" end
    put(x, y, col)
  end
end
-- second, nearer blue-green range
c:terrain(function(x) return 82 + math.sin(x * .03) * 6 + math.sin(x * .011 + 1) * 8 end, "#7f9cc0", HOR)
for x = 0, W - 1 do
  local t = floor(82 + math.sin(x * .03) * 6 + math.sin(x * .011 + 1) * 8 + .5)
  put(x, t, "#9bb6d2")
  for y = t + 1, HOR do if hsh(x, y, 31) > .9 then put(x, y, "#6f8cb4") end end
end

---------------------------------------------------------------- monastery crag + clouds
local crag = P{ { 196, 118 }, { 204, 100 }, { 210, 84 }, { 220, 74 }, { 262, 74 }, { 270, 86 }, { 278, 100 }, { 286, 118 } }
crag:each(function(x, y)
  local col = "#9c8a8e"
  if x > 248 + (y - 74) * .35 then col = "#7d6c7c" elseif x < 222 then col = "#b4a3a0" end
  if (y * 3 + x) % 11 == 0 and hsh(x, y, 9) > .3 then col = mix(col, VIO, .25) end
  put(x, y, col)
end)
c:edgeIn(crag, "#5f4f62")
-- crag pines
for _, p in ipairs({ { 206, 104 }, { 212, 96 }, { 274, 100 }, { 268, 92 }, { 280, 108 } }) do
  F(P{ { p[1], p[2] - 9 }, { p[1] + 4, p[2] }, { p[1] - 4, p[2] } }, "#3f6a52")
  F(P{ { p[1] + 1, p[2] - 7 }, { p[1] + 4, p[2] }, { p[1] + 1, p[2] } }, "#2f5244")
end

-- the Cloud Monastery
local mon = P{ { 212, 76 }, { 268, 76 }, { 264, 44 }, { 216, 44 } }
plaster(mon, { 0, 0, "#f1e6d4", "#fbf3e4", "#ddcfbd" }, 41)
-- stone base course
stone(R(210, 70, 270, 77), { "#5a4a50", "#8c7a74", "#b5a291", "#d2c2ae", "#a8927f" }, 4, 8, 2)
form(mon:add(R(210, 70, 270, 77)), "#7a6a6e", { band = 3 })
F(R(216, 44, 264, 49), "#8e2f3a") -- maroon parapet band
F(R(216, 49, 264, 49), "#5e1f2a")
for x = 218, 262, 4 do put(x, 46, "#d9a23a") put(x + 1, 46, "#d9a23a") end -- gilded dots row
-- upper hall
local up = R(226, 30, 254, 43)
plaster(up, { 0, 0, "#efe2cf", "#fbf3e4", "#d9cab8" }, 42)
form(up, "#7a6a6e")
F(R(226, 30, 254, 33), "#8e2f3a")
-- roofs (teal tile, upturned eaves)
local roof1 = P{ { 204, 44 }, { 276, 44 }, { 270, 39 }, { 262, 37 }, { 218, 37 }, { 210, 39 } }
tiles(roof1, { "#1f4a4a", "#2a6262", "#33807a", "#56a89a", "#2e7470" }, 3, 5, 3)
F(R(203, 44, 277, 44), "#d9a23a") put(203, 43, "#d9a23a") put(277, 43, "#d9a23a")
local roof2 = P{ { 220, 30 }, { 260, 30 }, { 254, 25 }, { 226, 25 } }
tiles(roof2, { "#1f4a4a", "#2a6262", "#33807a", "#56a89a", "#2e7470" }, 3, 5, 4)
F(R(219, 30, 261, 30), "#d9a23a")
-- quirk: tea bushes growing on the monastery roof
for i, x in ipairs({ 229, 236, 243, 250 }) do
  local b = c:rrect(x - 3, 20, x + 3, 25, 2)
  F(b, "#4f8a4a") F(R(x - 2, 21, x, 22), "#7ab65e") F(R(x + 1, 24, x + 3, 25), "#3a6a3e")
  c:edgeIn(b, "#2f5a36")
  put(x - 1, 20, "#a8d97c")
end
F(R(237, 12, 239, 19), "#d9a23a") -- gilded finial (diamond top)
F(P{ { 238, 6 }, { 241, 10 }, { 238, 14 }, { 235, 10 } }, "#f0c54a")
put(237, 9, "#fff0b0") F(R(239, 12, 239, 19), "#b07a22")
-- windows and door
for _, x in ipairs({ 220, 252 }) do
  window(x, 54, x + 7, 64, "#3f6fb0", { sill = "#d4423a" })
  F(R(x - 2, 52, x + 9, 52), "#d4423a") -- painted lintel
end
window(234, 34, 237, 40, "#d4423a", { nomull = true }) window(243, 34, 246, 40, "#d4423a", { nomull = true })
local door = c:rrect(233, 58, 247, 76, 3)
F(R(231, 55, 249, 57), "#f0c53a")
F(door, "#a8302e") F(R(240, 59, 240, 76), "#6a1e22") F(R(234, 59, 239, 60), "#c84a3a")
put(238, 68, "#f0c53a") put(242, 68, "#f0c53a")
c:edgeIn(door, "#5e1a20")
-- stairs down the crag
local stairs = P{ { 232, 78 }, { 248, 78 }, { 258, 117 }, { 222, 117 } }
stairs:each(function(x, y)
  local col = ((y - 78) % 3 == 2) and "#9c8a84" or "#e2d4c2"
  if ((y - 78) % 3 == 0) then col = "#f2e8d8" end
  put(x, y, col)
end)
tint(P{ { 246, 78 }, { 248, 78 }, { 258, 117 }, { 251, 117 } }, VIO, .25)
c:edgeIn(stairs, "#7a6a6e")
-- prayer flags from the finial
flags(238, 16, 198, 72, 6, 7, 4, 5, 0)
flags(238, 16, 282, 72, 6, 7, 4, 5, 2)
-- clouds around the crag foot (cloud monastery)
c:cloud(180, 104, 34, "#fbf3e6", "#ddd2e6")
c:cloud(262, 106, 36, "#fbf3e6", "#ddd2e6")
c:cloud(200, 112, 22, "#f6ece0", "#ddd2e6")

---------------------------------------------------------------- terraced hills (spice and tea terraces)
local function hillY(x)
  if x < 196 then return 112 - 40 * ((196 - x) / 196) ^ .8 + math.sin(x * .07) * 2
  elseif x > 284 then return 112 - 34 * ((x - 284) / 196) ^ .8 + math.sin(x * .06) * 2
  end
  return 113
end
local CROPS = { "#c9442f", "#e4b331", "#4f8a4a", "#d9622b", "#6fa24e" }
for x = 0, W - 1 do
  if x < 198 or x > 282 then
    local top = floor(hillY(x) + .5)
    for y = top, HOR + 2 do
      local d = y - top
      local band = (y + floor(x * ((x < 240) and .08 or -.08))) // 6
      local k = (y + floor(x * ((x < 240) and .08 or -.08))) % 6
      local col = "#86b46c"
      if k == 5 then col = "#5b7d4a" elseif k == 4 then col = "#6f9a58" elseif k == 0 then col = "#a9cf86" end
      local crop = CROPS[floor(hsh(band, x // 34, 13) * #CROPS) + 1]
      if (k == 2 or k == 3) and x % 3 == 0 and hsh(band, x // 34, 17) > .35 then col = crop end
      if d == 0 then col = "#b7d98e" end
      put(x, y, col)
    end
  end
end
-- tiny far terrace houses (scenery, left hill)
local function hut(x, y, w, wall, roofc)
  local m = R(x, y, x + w, y + 7)
  plaster(m, { 0, 0, wall, mix(wall, WARM, .3), mix(wall, VIO, .15) }, x)
  form(m, mix(wall, VIO, .5), { band = 1 })
  F(P{ { x - 2, y }, { x + w // 2, y - 5 }, { x + w + 2, y } }, roofc)
  F(R(x - 2, y, x + w + 2, y), mix(roofc, VIO, .4))
  put(x + 2, y + 3, "#ffd27a") put(x + 3, y + 3, "#ffd27a") put(x + w - 3, y + 3, "#ffd27a")
end
hut(124, 94, 12, "#e08a7a", "#5d5f7a") hut(150, 102, 10, "#7fb0d8", "#8e2f3a") hut(170, 94, 11, "#f0c53a", "#5d5f7a")
hut(110, 106, 9, "#f1e6d4", "#2a6262")
-- quirk: a terrace growing so fast you can hear it (big sprout + sound arcs)
do
  local sx, sy = 150, 92
  F(R(sx, sy - 10, sx + 1, sy), "#3f7a3a")
  local l1 = P{ { sx, sy - 9 }, { sx - 8, sy - 14 }, { sx - 4, sy - 7 } } F(l1, "#7ab65e") c:edgeIn(l1, "#3f7a3a")
  local l2 = P{ { sx + 1, sy - 9 }, { sx + 9, sy - 15 }, { sx + 5, sy - 6 } } F(l2, "#8cc66a") c:edgeIn(l2, "#3f7a3a")
  F(P{ { sx - 3, sy }, { sx + 4, sy }, { sx + 2, sy - 2 }, { sx - 1, sy - 2 } }, "#8a6a4a")
  for i = 0, 2 do -- sound arcs
    local r = 4 + i * 3
    F(L({ { sx + 6 + r, sy - 16 - r }, { sx + 8 + r, sy - 12 - r // 2 }, { sx + 6 + r, sy - 8 } }, 1), "#fbf3e6")
    F(L({ { sx - 6 - r, sy - 16 - r }, { sx - 8 - r, sy - 12 - r // 2 }, { sx - 6 - r, sy - 8 } }, 1), "#fbf3e6")
  end
end

---------------------------------------------------------------- ground (meadow) and paved square
local ground = R(0, HOR, W - 1, H - 1)
ground:each(function(x, y)
  local col = "#9cbc6c"
  local v = hsh(x, y, 51)
  if v > .9 then col = "#86a85c" elseif v < .07 then col = "#b4d07e" end
  if (x + y * 3) % 13 == 0 and hsh(x // 2, y, 7) > .5 then col = "#7f9e56" end -- blades
  put(x, y, col)
end)
-- perspective paving
local plaza = P{ { 132, 270 }, { 374, 270 }, { 338, 210 }, { 322, 140 }, { 264, HOR }, { 216, HOR }, { 158, 140 }, { 146, 210 } }
do
  local rows, y, rh = {}, HOR, 2
  while y < H do rows[#rows + 1] = y; y = y + floor(2 + (y - VY) / 20) end
  local function rowOf(yy) local r = 1 for i, v in ipairs(rows) do if v <= yy then r = i end end return r end
  local SET = { "#cdbba6", "#c2ae98", "#d6c6b2", "#bba892", "#d9c3a2", "#c9b0a6" }
  plaza:each(function(x, y)
    local r = rowOf(y)
    local ry = y - rows[r]
    local rhh = (rows[r + 1] or H) - rows[r]
    local u = (x - VX) / (y - VY + 6) * 9 + (r % 2) * .5
    local bid = floor(u)
    local fr = u - bid
    local col = SET[floor(hsh(bid, r, 61) * #SET) + 1]
    if ry == rhh - 1 or fr < 1 / max(1, (y - VY) / 6) * .9 then col = "#8f7f7a"
    elseif ry == 0 then col = mix(col, WARM, .3) end
    put(x, y, col)
  end)
  c:edgeIn(plaza, "#8a7a6a")
end
-- grass-to-plaza dirt fringe
tint(c:rim(plaza, "#b49a72"):add(plaza:grow(2):cut(plaza)), "#b49a72", .4)

---------------------------------------------------------------- 6) back-left far: LIBRARY (stone + timber, blue painted, big book sign)
local STONE = { "#5a4a50", "#8c7a74", "#b5a291", "#d2c2ae", "#a8927f" }
local WOOD = { "#3e261c", "#6e432c", "#8d5a38", "#b07a4c", "#7c4c30" }
local SLATE = { "#2e2a44", "#4a4664", "#625f80", "#8a87a8", "#57547a" }
do
  shadow(P{ { 26, 140 }, { 112, 138 }, { 124, 146 }, { 34, 147 } }, .3)
  -- side wall receding to VP
  local s = P{ { 94, 70 }, { 108, 74 }, { 108, 137 }, { 94, 140 } }
  stone(s, STONE, 5, 9, 6) tint(s, VIO, .3) c:edgeIn(s, "#4a3a46")
  local sroof = P{ { 60, 44 }, { 77, 49 }, { 113, 75 }, { 100, 72 } }
  tiles(sroof, SLATE, 3, 5, 6) tint(sroof, VIO, .2) c:edgeIn(sroof, "#241f36")
  -- ground floor stone
  local gf = R(26, 104, 94, 140)
  stone(gf, STONE, 5, 10, 7) form(gf, "#4a3a46")
  -- upper timber + blue painted panels
  local uf = R(26, 72, 94, 103)
  F(uf, "#3f6fb0")
  plaster(uf, { 0, 0, "#3f6fb0", "#5f8ccc", "#3a64a3" }, 8)
  for _, x in ipairs({ 26, 48, 70, 92 }) do planks(R(x, 72, x + 2, 103), WOOD, 3, 2) end
  planks(R(26, 72, 94, 74), WOOD, 3, 2, true)
  -- carved painted diamonds on panels
  for _, x in ipairs({ 37, 59, 81 }) do F(P{ { x, 76 }, { x + 3, 79 }, { x, 82 }, { x - 3, 79 } }, "#f0c53a") put(x, 79, "#d4423a") end
  form(uf, "#24386a", { band = 2 })
  -- gable roof
  local roof = P{ { 20, 73 }, { 100, 73 }, { 60, 42 } }
  tiles(roof, SLATE, 3, 5, 9)
  form(roof, "#241f36", { band = 2 })
  F(L({ { 20, 73 }, { 60, 42 } }, 2), "#b07a4c") F(L({ { 60, 42 }, { 100, 73 } }, 2), "#8d5a38") -- carved bargeboards
  for x = 22, 98, 4 do put(x, 74, "#6e432c") put(x + 1, 75, "#6e432c") end
  -- BIG BOOK SIGN in the gable
  local cover = P{ { 45, 56 }, { 60, 60 }, { 75, 56 }, { 75, 69 }, { 60, 72 }, { 45, 69 } }
  F(cover, "#b8443a") c:edgeIn(cover, "#6a1e22")
  local lp = P{ { 47, 56 }, { 59, 59 }, { 59, 69 }, { 47, 66 } }
  local rp = P{ { 61, 59 }, { 73, 56 }, { 73, 66 }, { 61, 69 } }
  F(lp, "#fbf1dc") F(rp, "#efe0c4")
  for i = 0, 3 do
    F(L({ { 49, 59 + i * 2 }, { 57, 61 + i * 2 } }), "#9c8a84")
    F(L({ { 63, 61 + i * 2 }, { 71, 59 + i * 2 } }), "#9c8a84")
  end
  F(R(60, 59, 60, 71), "#6a1e22")
  F(R(57, 70, 58, 74), "#d4423a") -- ribbon bookmark
  -- windows with shelves, balcony door
  window(31, 110, 44, 126, "#24386a", { shelves = true, nomull = true })
  window(76, 110, 89, 126, "#24386a", { shelves = true, nomull = true })
  window(32, 79, 42, 90, "#7a3a20") window(77, 79, 87, 90, "#7a3a20")
  local d = c:rrect(52, 114, 67, 140, 5)
  F(d, "#2f5590") planks(d, { "#1c2c5a", "#24386a", "#2f5590", "#4a74b0", "#2a4c86" }, 4, 3)
  c:edgeIn(d, "#162048") put(64, 128, "#f0c53a")
  F(R(50, 112, 69, 113), "#d2c2ae")
  -- carved wooden balcony
  local bal = R(28, 92, 92, 103)
  F(R(28, 92, 92, 93), "#b07a4c") F(R(28, 101, 92, 103), "#8d5a38")
  for x = 30, 90, 3 do F(R(x, 94, x + 1, 100), "#8d5a38") put(x, 94, "#b07a4c") put(x + 1, 100, "#5a3424") end
  for x = 28, 92, 4 do put(x + 1, 104, "#6e432c") put(x + 2, 105, "#6e432c") end
  c:edgeIn(bal, "#3e261c")
  -- flower box on balcony
  for x = 34, 86, 6 do put(x, 91, "#d4423a") put(x + 2, 91, "#f0c53a") put(x + 1, 90, "#4f8a4a") end
end

---------------------------------------------------------------- 5) back-right mid: SHOPS (seed shop)
do
  shadow(P{ { 310, 134 }, { 362, 134 }, { 370, 140 }, { 316, 140 } }, .3)
  local s = P{ { 302, 98 }, { 310, 96 }, { 310, 134 }, { 302, 132 } }
  stone(s, STONE, 4, 8, 12) tint(s, VIO, .32) c:edgeIn(s, "#4a3a46")
  local f = R(310, 96, 360, 134)
  plaster(f, { 0, 0, "#d9708a", "#ec98aa", "#c8607c" }, 13)
  -- stone plinth
  stone(R(310, 127, 360, 134), STONE, 4, 7, 14)
  form(f, "#7a2a44")
  local roof = P{ { 304, 97 }, { 366, 97 }, { 335, 78 } }
  tiles(roof, { "#5e1f22", "#8e3a2e", "#b8523a", "#dc7a52", "#a8483a" }, 3, 5, 15)
  form(roof, "#4a1418")
  local rs = P{ { 304, 97 }, { 335, 78 }, { 328, 82 }, { 300, 99 } }
  tiles(rs, { "#5e1f22", "#8e3a2e", "#b8523a", "#dc7a52", "#a8483a" }, 3, 5, 16) tint(rs, VIO, .3)
  -- sprout sign in gable
  local sg = R(328, 85, 342, 95)
  planks(sg, WOOD, 3, 4, true) c:edgeIn(sg, "#3e261c")
  F(R(335, 89, 335, 94), "#3f7a3a")
  F(P{ { 335, 90 }, { 330, 86 }, { 333, 91 } }, "#7ab65e") F(P{ { 335, 89 }, { 340, 86 }, { 337, 91 } }, "#8cc66a")
  -- awning (green/cream stripes, scalloped)
  local aw = P{ { 308, 104 }, { 362, 104 }, { 365, 111 }, { 305, 111 } }
  aw:each(function(x, y) put(x, y, ((x // 4) % 2 == 0) and "#3f9a5a" or "#f1e6cf") end)
  for x = 305, 365 do if (x // 4) % 2 == 0 then put(x, 112, "#2f7a46") else put(x, 112, "#d8c8a8") end end
  form(aw, "#245a36", { band = 1 })
  -- display window with seed packets
  window(314, 115, 336, 125, "#7a2a44", { nomull = true })
  local pk = { "#d4423a", "#f0c53a", "#3f6fc4", "#3f9a5a", "#e08a2c", "#8a4f9a" }
  for i = 0, 5 do local x = 315 + i * 4 F(R(x, 119, x + 2, 124), pk[i + 1]) put(x + 1, 120, "#fbf1dc") end
  local d = R(342, 113, 354, 134)
  planks(d, WOOD, 3, 5) c:edgeIn(d, "#3e261c") put(344, 124, "#f0c53a")
end

---------------------------------------------------------------- 2) back-right: CHAI STALL / teahouse
do
  shadow(P{ { 378, 136 }, { 458, 136 }, { 462, 144 }, { 386, 144 } }, .3)
  local s = P{ { 366, 74 }, { 380, 70 }, { 380, 136 }, { 366, 133 } }
  planks(s, WOOD, 4, 21) tint(s, VIO, .3) c:edgeIn(s, "#2e1c16")
  local SAF = { "#7a3a18", "#b8621f", "#e08a2c", "#f2ad55", "#d27b25" }
  local f = R(380, 70, 456, 136)
  planks(f, SAF, 5, 22)
  form(f, "#6a2e12", { band = 2 })
  -- hipped roof (green tin with ribs)
  local roof = P{ { 372, 72 }, { 462, 72 }, { 448, 54 }, { 388, 54 } }
  roof:each(function(x, y)
    local col = (x % 5 == 0) and "#2a6a5e" or "#3a8a78"
    if y < 58 then col = mix(col, WARM, .2) end
    put(x, y, col)
  end)
  form(roof, "#1c4a40", { band = 2 })
  local rside = P{ { 372, 72 }, { 388, 54 }, { 382, 58 }, { 364, 75 } }
  F(rside, "#2a6a5e") tint(rside, VIO, .3)
  for x = 372, 462, 3 do put(x, 73, "#e08a2c") put(x + 1, 74, "#b8621f") end -- carved eave fringe
  -- cup sign on roof
  local sg = R(406, 40, 430, 54)
  planks(sg, WOOD, 3, 23, true) c:edgeIn(sg, "#2e1c16")
  local cup = P{ { 411, 45 }, { 423, 45 }, { 421, 52 }, { 413, 52 } }
  F(cup, "#c8603a") F(R(412, 45, 422, 46), "#7a3a20") c:edgeIn(cup, "#7a2a18")
  F(L({ { 424, 47 }, { 426, 48 }, { 424, 50 } }), "#c8603a")
  steam(414, 34, 43, 3) steam(419, 33, 43, 9)
  -- open counter
  local hole = R(388, 88, 448, 112)
  F(hole, "#5a3426")
  for y = 92, 104, 6 do F(R(390, y, 446, y), "#8d5a38") end
  for i = 0, 8 do local x = 392 + i * 6 F(R(x, 98, x + 3, 103), ({ "#e4b331", "#c9442f", "#4f8a4a", "#d9622b" })[i % 4 + 1]) put(x, 98, "#fbf1dc") end
  for i = 0, 6 do local x = 394 + i * 7 F(R(x, 88 + 2, x + 2, 91), "#c8603a") end
  -- awning (saffron/cream, scalloped)
  local aw = P{ { 384, 80 }, { 452, 80 }, { 456, 88 }, { 380, 88 } }
  aw:each(function(x, y) put(x, y, ((x // 5) % 2 == 0) and "#d4423a" or "#f6e6c4") end)
  for x = 380, 456 do if x % 5 ~= 4 then put(x, 89, ((x // 5) % 2 == 0) and "#a8302e" or "#dcc8a2") end end
  form(aw, "#7a1e1e", { band = 1 })
  -- counter
  local ct = R(384, 112, 452, 115) planks(ct, WOOD, 4, 24, true) c:edgeIn(ct, "#2e1c16")
  local cf = R(386, 116, 450, 136)
  F(cf, "#3f9a5a")
  for x = 388, 446, 10 do
    local pnl = R(x, 119, x + 7, 133) F(pnl, "#2f7a46") c:edgeIn(pnl, "#245a36")
    F(P{ { x + 3, 122 }, { x + 6, 126 }, { x + 3, 130 }, { x, 126 } }, "#f0c53a") put(x + 3, 126, "#d4423a")
  end
  form(cf, "#1f5a36")
  -- big copper kettle with steam
  local k = c:rrect(398, 98, 416, 111, 4)
  F(k, "#c8703a")
  F(R(400, 100, 403, 102), "#f2b070") F(R(410, 106, 415, 110), "#8a4224")
  c:edgeIn(k, "#5e2a16")
  F(R(404, 95, 410, 97), "#8a4224") F(R(406, 93, 408, 94), "#f0c53a")
  F(L({ { 417, 104 }, { 420, 101 }, { 422, 97 } }, 2), "#c8703a")
  F(L({ { 397, 101 }, { 394, 104 }, { 397, 108 } }, 1), "#5e2a16")
  steam(422, 44, 95, 1) steam(426, 52, 93, 5)
  -- clay cups row
  for i = 0, 4 do
    local x = 426 + i * 5
    local cu = P{ { x, 106 }, { x + 4, 106 }, { x + 3, 111 }, { x + 1, 111 } }
    F(cu, "#c8603a") put(x + 1, 106, "#e8d0b0") put(x + 2, 106, "#b8762e") c:edgeIn(cu, "#7a2a18")
  end
  -- quirk: a cardamom pod cheering the pot
  local pod = P{ { 405, 86 }, { 408, 82 }, { 411, 86 }, { 408, 91 } }
  F(pod, "#8bb04a") F(R(408, 83, 408, 90), "#6a8a36") put(406, 85, "#c4dc84") c:edgeIn(pod, "#4a6a26")
  F(L({ { 405, 85 }, { 402, 82 } }), "#4a6a26") F(L({ { 411, 85 }, { 414, 82 } }), "#4a6a26")
  c:sparkle(400, 80) c:sparkle(417, 79)
end

---------------------------------------------------------------- 3) mid-left: NOTICE BOARD
do
  shadow(P{ { 132, 205 }, { 160, 205 }, { 170, 210 }, { 140, 210 } }, .35)
  for _, x in ipairs({ 134, 154 }) do local p = R(x, 160, x + 3, 206) planks(p, WOOD, 4, x) form(p, "#2e1c16", { band = 1 }) end
  local roof = P{ { 127, 128 }, { 165, 128 }, { 156, 118 }, { 136, 118 } }
  tiles(roof, SLATE, 3, 4, 31) form(roof, "#241f36")
  local fr = R(130, 129, 162, 170)
  planks(fr, WOOD, 3, 32, true)
  local cork = R(133, 132, 159, 167)
  cork:each(function(x, y) local v = hsh(x, y, 33) put(x, y, v > .85 and "#b0844e" or (v < .1 and "#ddb57a" or "#c99c62")) end)
  form(fr, "#2e1c16")
  local papers = { { 135, 134, 145, 146, "#fbf1dc" }, { 148, 133, 157, 141, "#bcd8ee" }, { 148, 144, 157, 156, "#f4c8c8" },
    { 135, 149, 144, 158, "#f6e08a" }, { 136, 160, 147, 165, "#c4e4c0" }, { 150, 159, 157, 165, "#fbf1dc" } }
  for i, p in ipairs(papers) do
    local m = R(p[1], p[2], p[3], p[4])
    F(m, p[5]) form(m, mix(p[5], VIO, .4), { band = 1, nolight = true })
    for y = p[2] + 3, p[4] - 2, 2 do F(R(p[1] + 2, y, p[3] - 2 - (y % 3), y), mix(p[5], VIO, .35)) end
    put((p[1] + p[3]) // 2, p[2] + 1, "#d4423a")
  end
  -- little mountain doodle on a paper
  F(L({ { 136, 145 }, { 139, 140 }, { 141, 143 }, { 143, 139 }, { 145, 145 } }), "#3f6fc4")
  -- prayer flag pennant atop
  F(R(146, 108, 146, 118), "#5b4448")
  F(P{ { 147, 108 }, { 154, 110 }, { 147, 113 } }, "#f0c53a")
end

---------------------------------------------------------------- 1) THE TERRACE GREEN (two-tier lawn, biggest object)
do
  shadow(P{ { 166, 212 }, { 316, 212 }, { 326, 218 }, { 172, 218 } }, .3)
  local GR = { "#7fb35e", "#8cc06a" }
  local function lawn(m, seed)
    m:each(function(x, y)
      local u = (x - VX) / (y - VY + 4) * 6
      local col = GR[(floor(u) % 2) + 1]
      if hsh(x, y, seed) > .92 then col = "#a6d27c" end
      put(x, y, col)
    end)
  end
  local low = P{ { 178, 170 }, { 302, 170 }, { 314, 199 }, { 166, 199 } }
  lawn(low, 71)
  form(low, "#4f7a3a", { band = 1 })
  local lw = R(166, 199, 314, 212)
  stone(lw, { "#5a4a50", "#8c7a74", "#c2ac94", "#dccab2", "#b09a84" }, 4, 9, 72) form(lw, "#4a3a46")
  local upt = P{ { 202, 141 }, { 278, 141 }, { 290, 160 }, { 190, 160 } }
  lawn(upt, 73)
  form(upt, "#4f7a3a", { band = 1 })
  local uw = R(190, 160, 290, 170)
  stone(uw, { "#5a4a50", "#8c7a74", "#c2ac94", "#dccab2", "#b09a84" }, 4, 9, 74) form(uw, "#4a3a46")
  -- central steps
  for _, st in ipairs({ { 226, 254, 199, 212 }, { 230, 250, 160, 170 } }) do
    local m = R(st[1], st[3], st[2], st[4])
    m:each(function(x, y) put(x, y, ((y - st[3]) % 3 == 2) and "#8c7a74" or (((y - st[3]) % 3 == 0) and "#f2e8d8" or "#d6c8b4")) end)
    tint(R(st[2] - 2, st[3], st[2], st[4]), VIO, .25)
    c:edgeIn(m, "#4a3a46")
  end
  -- marigold borders along front edges of each tier
  for x = 168, 312, 2 do
    if x < 224 or x > 256 then put(x, 197, (x % 4 == 0) and "#f08a24" or "#f0c53a") put(x + 1, 196, "#3f7a3a") end
  end
  for x = 192, 288, 2 do
    if x < 228 or x > 252 then put(x, 158, (x % 4 == 0) and "#f08a24" or "#f0c53a") put(x + 1, 157, "#3f7a3a") end
  end
  -- tea bushes on the lower tier
  for _, b in ipairs({ { 186, 182 }, { 204, 186 }, { 276, 186 }, { 294, 182 } }) do
    local m = c:rrect(b[1] - 6, b[2] - 5, b[1] + 6, b[2] + 4, 3)
    m:each(function(x, y) local v = hsh(x, y, 75) put(x, y, v > .7 and "#3f7a3a" or (v < .2 and "#7ab65e" or "#4f8a4a")) end)
    form(m, "#2f5a36", { band = 2 })
    put(b[1] - 3, b[2] - 4, "#a8d97c")
    shadow(R(b[1] - 4, b[2] + 5, b[1] + 8, b[2] + 6), .25)
  end
  -- green's icon: a flowering rhododendron tree on the upper tier
  shadow(P{ { 232, 156 }, { 256, 156 }, { 262, 159 }, { 236, 159 } }, .3)
  F(R(239, 146, 242, 156), "#6e432c") F(R(241, 146, 242, 156), "#4a2e22")
  local can = P{ { 226, 146 }, { 222, 140 }, { 226, 134 }, { 234, 130 }, { 246, 129 }, { 255, 133 }, { 259, 139 }, { 255, 146 }, { 244, 148 } }
  can:each(function(x, y)
    local v = hsh(x, y, 76)
    local col = (x > 246 and y > 138) and "#3f7a3a" or "#4f8a4a"
    if v > .78 then col = "#d4423a" elseif v > .7 then col = "#f0889a" end
    if x < 236 and y < 137 and v < .3 then col = "#7ab65e" end
    put(x, y, col)
  end)
  c:edgeIn(can, "#2f5a36")
  -- little prayer flags across the green
  flags(192, 162, 226, 152, 4, 6, 3, 4, 1)
  flags(254, 152, 288, 162, 4, 6, 3, 4, 3)
end

---------------------------------------------------------------- 4) near-left: SPICE GRINDERS shed
do
  shadow(P{ { 20, 242 }, { 118, 242 }, { 126, 258 }, { 26, 258 } }, .2)
  -- back wall
  local bw = R(22, 186, 114, 236)
  planks(bw, { "#2e1c16", "#4a2e22", "#5e3a28", "#7a4c34", "#553424" }, 5, 41)
  tint(R(22, 186, 114, 196), VIO, .3)
  c:edgeIn(bw, "#2a1a14")
  -- lean-to roof (wood shingles)
  local roof = P{ { 18, 170 }, { 116, 168 }, { 124, 190 }, { 14, 190 } }
  tiles(roof, { "#4a2418", "#7a3a24", "#a8583a", "#cc7a50", "#94482e" }, 4, 6, 42)
  form(roof, "#3a1810", { band = 2 })
  F(R(14, 190, 124, 191), "#6e432c")
  for x = 15, 123, 4 do put(x, 192, "#6e432c") put(x + 1, 193, "#4a2e22") end
  -- roof sign: mortar & pestle icon
  local sg = R(56, 154, 82, 169)
  planks(sg, WOOD, 3, 43, true) c:edgeIn(sg, "#2e1c16")
  F(R(60, 167, 61, 170), "#3e261c") F(R(77, 167, 78, 170), "#3e261c")
  local mort = P{ { 61, 160 }, { 77, 160 }, { 74, 166 }, { 64, 166 } }
  F(mort, "#b5a291") F(R(62, 160, 76, 161), "#e4b331") c:edgeIn(mort, "#5a4a50")
  F(L({ { 70, 161 }, { 76, 155 } }, 2), "#d2c2ae")
  -- posts
  for _, x in ipairs({ 22, 66, 112 }) do local p = R(x, 191, x + 3, 244) planks(p, WOOD, 4, x) form(p, "#2e1c16", { band = 1 }) end
  -- grinder 1: big stone mortar with a log pestle (turmeric)
  local m1 = P{ { 30, 214 }, { 60, 214 }, { 56, 238 }, { 34, 238 } }
  stone(m1, STONE, 5, 8, 44) form(m1, "#4a3a46", { band = 3 })
  F(R(31, 214, 59, 216), "#e4b331") F(R(32, 214, 44, 214), "#f6d26a")
  local pes = L({ { 46, 214 }, { 52, 202 }, { 56, 194 } }, 4)
  F(pes, "#8d5a38") F(L({ { 45, 213 }, { 50, 203 }, { 54, 195 } }, 1), "#b07a4c") c:edgeIn(pes, "#3e261c")
  -- grinder 2: stacked stone quern with peg (chilli)
  local q1 = c:rrect(72, 226, 108, 238, 3)
  stone(q1, STONE, 4, 9, 45) form(q1, "#4a3a46", { band = 2 })
  local q2 = c:rrect(76, 216, 104, 225, 3)
  stone(q2, { "#5a4a50", "#8c7a74", "#c2ac94", "#dccab2", "#b09a84" }, 4, 7, 46) form(q2, "#4a3a46", { band = 2 })
  local peg = R(97, 204, 100, 216) planks(peg, WOOD, 4, 47) c:edgeIn(peg, "#3e261c")
  F(R(73, 238, 107, 239), "#c9442f") heap(110, 239, 10, 5, "#c9442f", 48)
  F(R(80, 220, 100, 220), "#c9442f")
  -- shed floor
  F(R(22, 239, 114, 242), "#8a6a4a") F(R(22, 239, 114, 239), "#6e5240")
  -- spice heaps on woven mats out front
  local spices = { { 34, "#e4b331" }, { 56, "#c9442f" }, { 78, "#a9743a" }, { 100, "#7fa04a" } }
  for i, s in ipairs(spices) do
    local mat = P{ { s[1] - 11, 248 }, { s[1] + 11, 248 }, { s[1] + 13, 255 }, { s[1] - 9, 255 } }
    mat:each(function(x, y) put(x, y, ((x + y) % 3 == 0) and "#b8925a" or "#d6b27a") end)
    c:edgeIn(mat, "#8a6a3e")
    heap(s[1], 251, 18, 11, s[2], 50 + i)
  end
  sack(116, 238, 10, 13, "#d8c49a", "#d9622b", 55)
end

---------------------------------------------------------------- 8) near-right: WILD TRAIL arch
do
  -- path winding off to the right edge
  local path = P{ { 396, 226 }, { 444, 226 }, { 440, 196 }, { 452, 176 }, { 464, 168 }, { 464, 162 }, { 444, 170 }, { 428, 192 }, { 402, 210 } }
  path:each(function(x, y) local v = hsh(x, y, 81) put(x, y, v > .85 and "#b8906a" or (v < .1 and "#e6c69a" or "#d4b088")) end)
  c:edgeIn(path, "#a07c5a")
  -- deodar pines beyond
  for _, t in ipairs({ { 412, 196, 10 }, { 432, 176, 9 }, { 452, 160, 8 }, { 404, 178, 7 } }) do
    local x, y, s = t[1], t[2], t[3]
    for k = 0, 2 do
      local m = P{ { x, y - s * 2 + k * s // 2 - s }, { x + s - k, y - s + k * s // 1.5 - s // 2 }, { x - s + k, y - s + k * s // 1.5 - s // 2 } }
      F(m, k == 0 and "#3f6a52" or "#4f7a5e")
      tint(P{ { x, y - s * 3 }, { x + s, y }, { x, y } }, VIO, .2)
    end
    F(R(x - 1, y - s // 2, x, y), "#5a3424")
  end
  -- arch shadow
  shadow(P{ { 394, 224 }, { 450, 224 }, { 458, 229 }, { 400, 229 } }, .3)
  -- carved posts
  for _, x in ipairs({ 392, 440 }) do
    local p = R(x, 160, x + 6, 225) planks(p, WOOD, 3, x) form(p, "#2e1c16", { band = 2 })
    for y = 166, 220, 8 do F(P{ { x + 3, y }, { x + 5, y + 3 }, { x + 3, y + 6 }, { x + 1, y + 3 } }, "#d4423a") end
    F(R(x - 2, 222, x + 8, 225), "#8c7a74")
  end
  local lin = R(386, 154, 452, 161)
  planks(lin, WOOD, 3, 83, true)
  for x = 389, 449, 6 do put(x, 157, "#f0c53a") put(x + 1, 157, "#3f9a5a") end
  form(lin, "#2e1c16")
  local rf = P{ { 382, 154 }, { 456, 154 }, { 448, 146 }, { 390, 146 } }
  tiles(rf, { "#1f4a4a", "#2a6262", "#33807a", "#56a89a", "#2e7470" }, 3, 5, 84) form(rf, "#163a3a")
  F(P{ { 419, 140 }, { 422, 146 }, { 416, 146 } }, "#d9a23a")
  flags(398, 163, 440, 163, 6, 6, 4, 5, 4)
  -- signpost with an arrow pointing out into the wild
  local sp = R(451, 182, 453, 226) planks(sp, WOOD, 3, 85) c:edgeIn(sp, "#2e1c16")
  local ar = P{ { 444, 186 }, { 456, 186 }, { 461, 190 }, { 456, 194 }, { 444, 194 } }
  planks(ar, { "#7a5a2a", "#a8823e", "#d0a85a", "#e8c880", "#c09a4e" }, 3, 86, true) c:edgeIn(ar, "#5a3e1c")
  F(P{ { 447, 192 }, { 450, 188 }, { 453, 192 } }, "#3f6a52") -- little mountain-pine icon
  -- rhododendron bushes beside the arch
  for _, b in ipairs({ { 384, 218 }, { 456, 212 } }) do
    local m = c:rrect(b[1] - 6, b[2] - 6, b[1] + 6, b[2] + 6, 3)
    m:each(function(x, y) local v = hsh(x, y, 87) put(x, y, v > .75 and "#d4423a" or (v > .6 and "#f0889a" or "#4f8a4a")) end)
    form(m, "#2f5a36", { band = 2 })
  end
end

---------------------------------------------------------------- foreground prop near the plaza edge (non-clickable)
sack(340, 240, 11, 14, "#cbb48a", "#e4b331", 91)
sack(353, 244, 11, 12, "#bfa47a", "#c9442f", 92)

---------------------------------------------------------------- 0) GATE FRAME (stone pillars, carved painted timber beam)
do
  local GS = { "#4a3a40", "#7c6a64", "#b39c86", "#d2bea4", "#a48e7a" }
  for _, x0 in ipairs({ 0, 462 }) do
    local p = R(x0, 14, x0 + 17, H - 1)
    stone(p, GS, 6, 9, 90 + x0)
    form(p, "#3a2a30", { band = 3 })
    -- painted timber capital
    local cap = R(x0, 14, x0 + 17, 24)
    planks(cap, WOOD, 3, 93 + x0, true)
    for y = 16, 22, 3 do put(x0 + 4, y, "#f0c53a") put(x0 + 12, y, "#d4423a") end
    c:edgeIn(cap, "#2e1c16")
    -- inner side shadow
    tint(R(x0 == 0 and 18 or 456, 24, x0 == 0 and 21 or 461, H - 1), VIO, .25)
  end
  local beam = R(0, 0, W - 1, 13)
  planks(beam, WOOD, 3, 95, true)
  -- painted motif band
  for x = 0, W - 1 do
    local k = x % 12
    local col = ({ "#d4423a", "#3f6fc4", "#3f9a5a", "#f0c53a" })[(x // 12) % 4 + 1]
    if abs(k - 6) + abs(0) <= 5 then
      for y = 5, 9 do if abs(k - 6) + abs(y - 7) <= 3 then put(x, y, col) end end
    end
    if k == 0 then for y = 5, 9 do put(x, y, "#f0c53a") end end
  end
  F(R(0, 4, W - 1, 4), "#f0c53a") F(R(0, 10, W - 1, 10), "#f0c53a")
  -- slate cap
  tiles(R(0, 0, W - 1, 3), SLATE, 4, 5, 96)
  -- carved dentils under the beam
  for x = 0, W - 1, 4 do F(R(x, 14, x + 1, 15), "#6e432c") put(x, 16, "#4a2e22") end
  form(beam, "#2e1c16", { band = 2 })
  tint(R(18, 14, 461, 17), VIO, .15)
  -- prayer-flag bunting under the beam
  flags(20, 18, 460, 18, 14, 9, 5, 7, 0)
  -- hanging lanterns (right one is a teapot: quirk)
  lantern(34, 16, 8, false)
  lantern(444, 16, 6, true)
end

---------------------------------------------------------------- save
c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

local spots = {
  { "green", "The Terrace Green", { 164, 138, 316, 214 } },
  { "tea", "The Chai Stall", { 368, 32, 462, 142 } },
  { "board", "Notice Board", { 126, 106, 161, 210 } },
  { "library", "Library", { 20, 42, 114, 146 } },
  { "s1", "Spice Grinders", { 14, 152, 124, 258 } },
  { "s2", "Cloud Monastery", { 196, 4, 284, 118 } },
  { "shops", "Seed Shop", { 300, 76, 364, 136 } },
  { "wild", "Wild Trail", { 378, 146, 462, 228 } },
}
local js = { '{"w":480,"h":270,"horizon":' .. HOR .. ',"view":"gate","spots":[' }
for i, s in ipairs(spots) do
  local b = s[3]
  js[#js + 1] = string.format('%s{"k":"%s","name":"%s","x":%d,"y":%d,"box":[%d,%d,%d,%d]}', i > 1 and "," or "", s[1], s[2],
    (b[1] + b[3]) // 2, (b[2] + b[4]) // 2, b[1], b[2], b[3], b[4])
end
js[#js + 1] = '],"stand":[{"x":150,"y":240},{"x":200,"y":242},{"x":252,"y":236},{"x":304,"y":248},{"x":346,"y":174},{"x":350,"y":214}],"compass_clear":[380,230,480,270]}'
local fh = io.open(OUT .. NAME .. ".layout.json", "w") fh:write(table.concat(js)) fh:close()
print("ok " .. NAME)
