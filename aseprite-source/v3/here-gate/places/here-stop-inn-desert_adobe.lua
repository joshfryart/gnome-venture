-- here-stop-inn-desert_adobe.lua : Gnome Venture "Hearth Pop" v3 gate-view place, roadside Inn rest stop, DESERT ADOBE look, golden hour.
-- Same geometry / spots / stand / compass corner as here-stop-inn.lua; only colours, flora, sky, hills, roof/wall style and quirks differ.
-- 480x270 native, one-point perspective to (240,112). Run with --script-param out=<dir>/
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = (app.params and app.params.out) or "/home/user/gnome-venture/aseprite-source/v3/here-gate/places/"
local NAME = "here-stop-inn-desert_adobe"
local W, Hh, HOR, VPX = 480, 270, 112, 240
local c = HP.canvas{ w = W, h = Hh, scale = 1, name = NAME }
local floor, sin, abs, max, min = math.floor, math.sin, math.abs, math.max, math.min

local function hash(x, y, s)
  local n = (x * 374761393 + y * 668265263 + (s or 0) * 1442695041) & 0x7fffffff
  n = ((n ~ (n >> 13)) * 1274126177) & 0x7fffffff
  n = n ~ (n >> 16)
  return (n % 10007) / 10007
end
local POL = false -- true while a polish block paints: nothing may change the stand-point / compass zones
local ZST = { {240,250},{198,210},{282,208},{240,162},{100,256},{345,254} }
local function inZone(x, y)
  if x >= 378 and y >= 228 then return true end
  for _, s in ipairs(ZST) do local dx, dy = x - s[1], y - s[2] if dx >= -16 and dx <= 16 and dy >= -16 and dy <= 16 then return true end end
  return false
end
local function px(x, y, col) if POL and inZone(x, y) then return end c:put(x, y, col) end
local function R(d, s, b, h) return { d = d, s = s, b = b, h = h } end
local rect, poly = function(...) return c:rect(...) end, function(t) return c:poly(t) end

-- paint a mask: base, lit upper-left band, shade lower-right band, texture, own dark edge
local function paint(m, Rm, tex, o)
  o = o or {}
  local sh, lt = o.sh or 3, o.lt or 2
  m:each(function(x, y)
    local col = Rm.b
    if not o.noshade and (not m:has(x + sh, y) or not m:has(x, y + sh)) then col = Rm.s end
    if not o.nohi and (not m:has(x - lt, y) or not m:has(x, y - lt)) then col = Rm.h end
    if tex then local t = tex(x, y) if t then col = Rm[t] or t end end
    px(x, y, col)
  end)
  if not o.noedge then m:edge():each(function(x, y) px(x, y, Rm.d) end) end
  return m
end
-- textures
local function planksH(h, seed, y0)
  return function(x, y)
    if (y - (y0 or 0)) % h == 0 then return "s" end
    local r = hash(x // 9, y // h, seed)
    if hash(x, y, seed) < 0.05 then return "s" end
    if (x + floor(r * 20)) % 23 == 0 then return "d" end
  end
end
local function planksV(w, seed, x0)
  return function(x, y)
    if (x - (x0 or 0)) % w == 0 then return "s" end
    if hash(x, y // 3, seed) < 0.06 then return "s" end
    if hash(x // w, y, seed + 1) < 0.012 then return "d" end
  end
end
local function bricks(bw, bh, seed, x0, y0)
  return function(x, y)
    local row = (y - y0) // bh
    local off = (row % 2) * (bw // 2)
    if (y - y0) % bh == 0 then return "s" end
    if (x - x0 + off) % bw == 0 then return "s" end
    local r = hash((x - x0 + off) // bw, row, seed)
    if r < 0.18 and (y - y0) % bh == 1 then return "h" end
    if r > 0.85 and hash(x, y, seed) < 0.3 then return "s" end
  end
end
local function shingles(rh, sw, seed, y0)
  return function(x, y)
    local row = (y - y0) // rh
    local off = (row % 2) * (sw // 2)
    if (y - y0) % rh == rh - 1 then return "d" end
    if (x + off) % sw == 0 and (y - y0) % rh >= rh - 3 then return "s" end
    if hash((x + off) // sw, row, seed) < 0.15 and (y - y0) % rh == 0 then return "h" end
  end
end
local function speck(seed, a, b)
  return function(x, y)
    local r = hash(x, y, seed)
    if r < (a or 0.05) then return "s" elseif r > 1 - (b or 0.03) then return "h" end
  end
end
local function thatch(seed)
  return function(x, y)
    local r = hash(x, y // 4, seed)
    if (y % 6 == 5) then return "s" end
    if r < 0.2 then return "s" elseif r > 0.88 then return "h" end
  end
end
local function leafy(seed)
  return function(x, y)
    local r = hash(x // 3, y // 2, seed)
    local q = hash(x, y, seed + 9)
    if r < 0.18 then return "s" end
    if r > 0.86 and q < 0.6 then return "h" end
    if q < 0.03 then return "d" end
  end
end

---------------------------------------------------------------- palette
local INK2 = "#2b1c26"
local GLOW = { "#fff0b0", "#ffd66e", "#f7a845", "#d9783a" }
local SKY = { "#a8c4cc", "#bccdc6", "#cfd4bc", "#e0d6ae", "#ead2a0", "#f2cc92", "#f6d09a", "#f8d8a6", "#fae0b4" }
local Rframe = R("#7e5040", "#c48862", "#e4ae80", "#f8d6ac")
local Rtimber = R("#3e2418", "#64402a", "#845a3a", "#a47650")
local Rplaster = R("#7e5040", "#d09a70", "#e8b688", "#f8d6ac")
local Rplasd = R("#6a4038", "#a06a52", "#b87c5e", "#cc9070")
local Rstone = R("#6e4c44", "#aa8060", "#d0a47a", "#eec69a")
local Rroof = R("#5a2a24", "#8e4228", "#c06a3e", "#e0905a")
local Rbrick = R("#6a3a2e", "#9a5a40", "#b8724e", "#d08c62")
local Rdoor = R("#2e1810", "#5a3018", "#7c4422", "#9c5e30")
local Rhoney = R("#4a2a14", "#8a5a2a", "#b07a3e", "#d39a56")
local Rstable = R("#7a4a3a", "#b0785a", "#cc906a", "#e4aa80")
local Rthatch = R("#6a4a28", "#a8844a", "#cca660", "#e6c47c")
local Rhut1 = R("#7a4a44", "#c0806a", "#dc9a7e", "#f0b896")
local Rmoss = R("#30442e", "#4e6a3c", "#6e8a4a", "#94a860")
local Rhut2 = R("#7e5a40", "#c49a6c", "#dcb486", "#f0cea0")
local Rplum = R("#6a3a2e", "#a86a4a", "#c8865e", "#e2a678")
local Rteal = R("#1e5a62", "#2e8a88", "#4cbcb0", "#86dcd0")
local Rwellst = R("#6e4c44", "#aa8060", "#cc9e78", "#e8c094")
local Rpine = R("#34523a", "#5e8a44", "#8aae52", "#c4d27a")
local Rbush = R("#30442e", "#4e6a3c", "#6e8a4a", "#94a860")
local Rbark = R("#4a3830", "#74583f", "#9a7a58", "#c8a47a")
local Riron = R("#1e1a24", "#36303e", "#4e4658", "#6e6676")
local Rbrass = R("#5a3a12", "#9a6a1e", "#cc962e", "#f0c650")
local Rred = R("#4a1418", "#8a2a2a", "#b83c34", "#de6448")
local Rcream = R("#8c7458", "#d8c49c", "#efe0bc", "#fbf0d4")
local Rcopper = R("#4a2416", "#8a4a26", "#b86a32", "#e0904a")
local Rbarrel = R("#3a2010", "#6a3c1c", "#8c5428", "#ac6e38")

local Rturq = R("#1e5a62", "#2e8a88", "#4cbcb0", "#a8ece0")
local Ragave = R("#36585a", "#5e8a82", "#8ab8a4", "#c4e0c8")
local Rcact = R("#30503a", "#527e44", "#7ca852", "#b8d27a")
local Rfrond = R("#36583a", "#628e46", "#94b85a", "#d4e08a")
local Rdate = R("#5a2a24", "#8e4228", "#c86a30", "#f0a050")
local Rpalm = R("#4a3830", "#74583f", "#9a7a58", "#c8a47a")

---------------------------------------------------------------- sky (golden-hour haze, banded + dithered)
c:stripes(0, HOR - 1, SKY, { 3, 3, 3, 2, 2, 2, 2, 2, 2 })
do
  local prev = c:get(0, 0)
  for y = 1, HOR - 1 do
    local cur = c:get(0, y)
    if cur ~= prev then
      for x = 0, W - 1 do if (x + y) % 2 == 0 then px(x, y, prev) end end
      for x = 0, W - 1 do if (x + y) % 4 == 1 then px(x, y - 1, cur) end end
    end
    prev = cur
  end
end
-- low sun between the inn and the huts, banded halo
for _, rr in ipairs({ { 20, "#fae8bc" }, { 15, "#fcefc8" }, { 10, "#fff2c8" }, { 7, "#fff8de" } }) do
  c:fillMask(c:ellipse(214, 62, rr[1], rr[1]), rr[2])
end
-- dust haze streaks, lit top, shaded under
for _, s in ipairs({ { 20, 30, 110 }, { 250, 24, 150 }, { 120, 48, 70 }, { 330, 40, 120 }, { 170, 78, 60 }, { 300, 60, 90 } }) do
  local x0, y0, len = s[1], s[2], s[3]
  for x = x0, x0 + len do
    local t = (x - x0) / len
    local th = (t > 0.15 and t < 0.85) and 2 or 1
    if not (th == 1 and x % 2 == 0) then
      px(x, y0, "#fbf0d6")
      if th == 2 then px(x, y0 + 1, "#f2dcb4"); if x % 3 ~= 0 then px(x, y0 + 2, "#e6cca4") end end
    end
  end
end

---------------------------------------------------------------- far scenery: mesas, a far adobe, dunes, hazy palms
local MESAS = { { 150, 196, 82 }, { 330, 390, 78 }, { 420, 466, 86 }, { -10, 30, 84 } }
local function mesaY(x)
  local y = floor(98 + 3 * sin(x / 23) + 2 * sin(x / 7 + 1))
  for _, m in ipairs(MESAS) do
    local a, b, top = m[1], m[2], m[3]
    local d = (x < a) and (a - x) or ((x > b) and (x - b) or 0)
    local my = top + floor(d * 1.3 + (d > 0 and (d * d) * 0.05 or 0))
    if x >= a and x <= b and (x * 7) % 11 == 0 then my = my - 1 end
    if my < y then y = my end
  end
  return y
end
c:terrain(mesaY, "#e2b8a0", HOR)
for x = 0, W - 1 do
  local y1 = mesaY(x)
  px(x, y1, "#f4d4b8")
  for y = y1 + 1, HOR - 1 do
    if (y - y1) % 5 == 3 and hash(x // 4, y, 5) > 0.3 then px(x, y, "#d0a492") end
    if mesaY(x + 1) < y1 and y < y1 + 12 and (x + y) % 2 == 0 then px(x, y, "#c89c94") end
  end
end
-- far adobe cube on the mesa foot with one lit window (quirk: someone's still up)
paint(rect(150, 92, 162, 100), R("#b48a7c", "#c89c8a", "#d4aa94", "#e2bca2"), nil, { nohi = true, noshade = true })
paint(rect(149, 90, 163, 92), R("#a87e72", "#bc9282", "#c89c8a", "#d4aa94"), nil, { nohi = true, noshade = true })
px(153, 95, GLOW[2]) px(154, 95, GLOW[2]) px(153, 96, GLOW[3]) px(154, 96, GLOW[3])
local function duneY(x) return floor(102 + 4 * sin(x / 33 + 2) + 3 * sin(x / 13)) end
c:terrain(duneY, "#ecc690", HOR)
for x = 0, W - 1 do
  local y1 = duneY(x)
  px(x, y1, "#f8e0b0")
  if duneY(x + 1) < y1 then for k = 1, 3 do if (x + k) % 2 == 0 then px(x, y1 + k, "#dcac7c") end end end
end
c:terrain(function(x) return 108 + 2 * sin(x / 19 + 3) end, "#e4b884", HOR)
-- distant hazy palms and scrub bumps
local function farpalm(x, by, h)
  for y = by - h, by do px(x + ((by - y) * (x % 3 - 1)) // 12, y, "#8e806c") end
  local tx, ty = x + (h * (x % 3 - 1)) // 12, by - h
  for _, d in ipairs({ { -5, 2 }, { -4, -1 }, { -2, -3 }, { 2, -3 }, { 4, -1 }, { 5, 2 }, { 0, -3 } }) do
    local n = max(abs(d[1]), abs(d[2]))
    for k = 0, n do px(tx + floor(d[1] * k / n + .5), ty + floor(d[2] * k / n + .5) + ((k > n - 2 and abs(d[1]) > 3) and 1 or 0), "#9a9c74") end
  end
  px(tx, ty, "#7e8264")
end
for i = 0, 40 do
  local x = 8 + i * 12 + floor(hash(i, 1, 3) * 6)
  if abs(x - VPX) > 18 then
    if hash(i, 4, 3) > 0.5 then farpalm(x, 111, 8 + floor(hash(i, 2, 3) * 8))
    else paint(c:rrect(x - 5, 107, x + 5, 111, 2), R("#7e8264", "#9a9c74", "#a8a87e", "#b4b48a"), nil, { noedge = true, nohi = true }) end
  end
end

POL = false
---------------------------------------------------------------- ground
local function pathL(y) return 232 - 72 * (y - HOR) / 157 end
local function pathR(y) return 248 + 72 * (y - HOR) / 157 end
local pathM = HP.mask()
for y = HOR, Hh - 1 do
  local gcol = (y < 126) and "#e8c28e" or ((y < 152) and "#ecc894" or "#efcc98")
  for x = 0, W - 1 do px(x, y, gcol) end
  for x = floor(pathL(y) + .5), floor(pathR(y) + .5) do pathM:set(x, y) end
end
-- grass tufts
for y = HOR + 2, Hh - 1 do for x = 0, W - 1 do
  local d = (y - HOR) / 158
  if hash(x, y, 77) < 0.005 + 0.006 * d then
    local hgt = 1 + floor(d * 3)
    for k = 0, hgt do px(x, y - k, "#b0905a") end
    px(x, y - hgt - 1, "#d8c07a")
    if d > 0.4 then px(x + 1, y - 1, "#b0905a") px(x + 1, y - 2, "#d8c07a") end
  end
end end
-- path dirt
pathM:each(function(x, y)
  local d = (y - HOR) / 158
  local col = (d < 0.2) and "#d09670" or "#d4986a"
  local r = hash(x, y, 31)
  if r < 0.06 then col = "#b67c56" elseif r > 0.97 then col = "#e8b080" end
  px(x, y, col)
end)
-- wheel ruts converge to the vanishing point
for y = HOR + 4, Hh - 1 do
  local d = (y - HOR) / 157
  for _, bx in ipairs({ 196, 284 }) do
    local x = floor(VPX + (bx - VPX) * d + .5)
    local w = max(1, floor(d * 4))
    for k = 0, w - 1 do px(x + k, y, "#a8704e") end
    px(x - 1, y, "#e4aa7c")
  end
end
-- flat pebbles on the path
for y = HOR + 8, Hh - 3, 1 do for x = 150, 330 do
  if pathM:has(x, y) and pathM:has(x + 5, y) and hash(x, y, 5) < 0.0035 * (1 + (y - HOR) / 60) then
    local w = 2 + floor((y - HOR) / 40)
    for k = 0, w do px(x + k, y, "#f0cca0") end
    for k = 0, w do px(x + k, y + 1, "#9a6450") end
  end
end end
-- path verge line
for y = HOR, Hh - 1 do px(floor(pathL(y) + .5) - 1, y, "#c08a60") px(floor(pathR(y) + .5) + 1, y, "#c08a60") end

-- warm light pools (flat, wide)
local function pool(cx, cy, rx, ry)
  local m = c:ellipse(cx, cy, rx, ry)
  m:each(function(x, y)
    if y > HOR then
      if pathM:has(x, y) then px(x, y, "#e8b084") else
        local cur = c:get(x, y)
        px(x, y, (cur == "#b0905a") and "#c8a466" or "#f6d8a6")
      end
    end
  end)
end
pool(116, 176, 48, 7)
pool(36, 224, 30, 8)
pool(358, 228, 28, 5)

-- cool-violet ground shadow helper
local function shadow(m)
  m:each(function(x, y) if y > HOR then px(x, y, pathM:has(x, y) and "#a86e66" or "#c49c8c") end end)
end

POL = true
-- v2.5.40 polish pass 1: ground variety (grass bands, worn dirt, flowers, leaves, pebbles)
local STANDS = { {240,250},{198,210},{282,208},{240,162},{100,256},{345,254} }
local function free(x, y, r)
  for _, s in ipairs(STANDS) do
    local dx, dy = x - s[1], y - s[2]
    if dx * dx + dy * dy < r * r then return false end
  end
  return true
end
local GRASS = { ["#e8c28e"]=true, ["#ecc894"]=true, ["#efcc98"]=true }
for y = HOR + 2, Hh - 1 do for x = 0, W - 1 do
  if not pathM:has(x, y) and GRASS[c:get(x, y)] then
    local n = sin(x / 17 + y / 9) + sin(x / 7 - y / 11) + sin((x + y) / 23)
    local d = (y - HOR) / 158
    local p = sin(y * (0.55 + (1 - d) * 0.4) + sin(x / 23) * 2.4 + sin(x / 61) * 1.5)
    local sg = hash((x + y * 3) // 11, y // 3, 2) > 0.4
    if n > 1.5 then px(x, y, d < 0.15 and "#f2d2a0" or "#f6d8a8")
    elseif n < -1.6 then px(x, y, "#dcb282")
    elseif p > 0.93 and sg then px(x, y, "#f8e0b2")
    elseif p < -0.95 and sg and x % 3 ~= 0 then px(x, y, "#d8ae80")
    elseif n < -1.1 and hash(x, y, 8) < 0.4 then px(x, y, "#dcb282") end
  end
end end
-- worn dirt patches where feet go (door, table, board, well, trail)
local function wear(cx, cy, rx, ry, seed)
  c:ellipse(cx, cy, rx, ry):each(function(x, y)
    if y > HOR and not pathM:has(x, y) and free(x, y, 16) then
      local e = ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2
      if e < 0.55 or hash(x, y, seed) < (1 - e) * 1.6 then
        px(x, y, hash(x, y, seed + 1) < 0.2 and "#c48a60" or "#d49c6c")
      end
    end
  end)
end
wear(116, 178, 26, 4, 140) wear(88, 238, 36, 5, 141) wear(358, 226, 22, 4, 142)
wear(300, 182, 14, 3, 143) wear(404, 222, 18, 3, 144)
-- footpaths from the road to the door, the table, the board and the trail
local function foot(pts, seed)
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local n = max(abs(b[1] - a[1]), abs(b[2] - a[2]))
    for k = 0, n do
      local x = floor(a[1] + (b[1] - a[1]) * k / n + .5)
      local y = floor(a[2] + (b[2] - a[2]) * k / n + .5)
      for dx = -1, 1 do if hash(x + dx, y, seed) < 0.75 and free(x + dx, y, 16) and not pathM:has(x + dx, y) then px(x + dx, y, "#d49c6c") end end
    end
  end
end
foot({{176,178},{150,176},{128,178}}, 150) foot({{190,224},{150,230},{120,238}}, 151)
foot({{300,200},{332,214},{352,224}}, 152) foot({{322,164},{300,176}}, 153) foot({{340,190},{380,200},{412,210}}, 154)
-- flowers, leaves, pebbles in the grass (never near stand points)
local FL = { "#e8607a", "#f4c040", "#c86ac8", "#f08a50", "#f6e0b0" }
for y = HOR + 10, Hh - 2 do for x = 18, W - 20 do
  if not pathM:has(x, y) and GRASS[c:get(x, y)] and free(x, y, 20) then
    local r = hash(x, y, 160)
    if r < 0.0042 then
      local col = FL[1 + floor(hash(x, y, 161) * #FL)]
      px(x, y, col) px(x, y + 1, "#8a8a50")
      if hash(x, y, 162) < 0.5 then px(x + 1, y, col) end
    elseif r > 0.9975 then
      px(x, y, "#9a7a4a") px(x + 1, y, "#b8985a")
    elseif r > 0.9955 then
      px(x, y, "#e2c09a") px(x + 1, y, "#c49a74") px(x, y + 1, "#8a5e4a") px(x + 1, y + 1, "#8a5e4a")
    end
  end
end end
-- fallen leaves and grit along the road edge
for y = HOR + 6, Hh - 2 do for x = 100, 400 do
  if pathM:has(x, y) and free(x, y, 18) and hash(x, y, 170) > 0.9972 then
    px(x, y, "#b06a3a") px(x + 1, y, "#c88a4a")
  end
end end

POL = false
---------------------------------------------------------------- date palms behind the homes and the ramada
local function palm(cx, base, h, lean, scale, clipY)
  scale = scale or 1
  local tx, top = cx + lean, base - h
  local tm = c:line({ { cx, base }, { cx + floor(lean * 0.4), base - floor(h * 0.5) }, { tx, top } }, scale > 0.8 and 3 or 2)
  if clipY then tm:clip(rect(0, 0, W - 1, clipY)) end
  paint(tm, Rpalm, function(x, y) if y % 3 == 0 then return "s" end end, { sh = 1, lt = 1 })
  local L = floor(16 * scale)
  local m = HP.mask()
  for _, f in ipairs({ { -1, -0.35 }, { -0.85, 0.25 }, { -0.45, 0.62 }, { 1, -0.3 }, { 0.85, 0.3 }, { 0.45, 0.66 }, { -0.25, -0.8 }, { 0.3, -0.78 } }) do
    local ex, ey = tx + floor(f[1] * L), top + floor(f[2] * L)
    local mx, my = tx + floor(f[1] * L * 0.55), top + floor(f[2] * L * 0.55) - floor(3 * scale)
    m:add(c:line({ { tx, top }, { mx, my }, { ex, ey } }, scale > 0.8 and 3 or 2))
  end
  paint(m, Rfrond, function(x, y) if (x + y) % 3 == 0 then return "s" end if hash(x, y, 8) > 0.9 then return "h" end end, { sh = 1, lt = 1 })
  if scale > 0.8 then paint(c:rrect(tx - 3, top + 2, tx + 1, top + 7, 1), Rdate, function(x, y) if (x + y) % 2 == 0 then return "s" end end, { sh = 1, lt = 1 }) end
end
for _, t in ipairs({ {270,118,52,-4}, {300,118,64,3}, {338,118,56,-2}, {372,118,68,5}, {404,118,50,-3} }) do palm(t[1], t[2], t[3], t[4], 1, 118) end
for _, t in ipairs({ {200,116,46,-3}, {228,116,38,4} }) do palm(t[1], t[2], t[3], t[4], 0.85, 116) end

---------------------------------------------------------------- ramada stable (far left, beside the inn): adobe walls, flat palm-thatch roof
shadow(poly{{176,126},{228,126},{236,131},{182,131}})
local stW = paint(rect(178, 100, 224, 126), Rstable, speck(11, 0.05, 0.03))
-- flat roof: viga row, palm-mat slab, fringe
paint(rect(172, 92, 230, 99), Rthatch, thatch(12), { sh = 2 })
for x = 174, 228 do if x % 3 ~= 0 then px(x, 100, Rthatch.s) end if x % 4 == 1 then px(x, 101, Rthatch.d) end end
for vx = 176, 226, 8 do paint(rect(vx, 99, vx + 2, 101), Rtimber, nil, { noshade = true }) end
-- open doorway with hay
paint(rect(190, 108, 210, 126), R("#4a2a24", "#5e3a30", "#6a4436", "#76503e"), nil, { nohi = true })
paint(poly{{192,126},{196,116},{204,114},{209,126}}, Rthatch, thatch(13), { sh = 2 })
-- turquoise swing doors leaned open
paint(rect(180, 108, 189, 126), Rturq, function(x, y) if (x - 180) == (y - 108) // 2 then return "d" end end)
paint(rect(211, 108, 220, 126), Rturq, function(x, y) if (220 - x) == (y - 108) // 2 then return "d" end end)
-- saddle with a striped blanket draped over a mesquite rail
paint(rect(166, 118, 176, 120), Rtimber, nil, { noshade = true })
paint(rect(166, 116, 168, 126), Rtimber) paint(rect(174, 116, 176, 126), Rtimber)
paint(poly{{168,114},{173,114},{174,121},{167,121}}, Rred, function(x, y) if y == 117 then return Rturq.h end end)

---------------------------------------------------------------- INN (k=do): two-storey adobe with a rooftop room, flat roofs, vigas
shadow(poly{{20,166},{166,160},{176,170},{30,172}})
-- side face receding toward the path
paint(poly{{150,64},{166,76},{166,158},{150,166}}, Rplasd, speck(21, 0.06, 0.02), { nohi = true })
paint(poly{{150,126},{166,124},{166,127},{150,129}}, Rtimber, nil, { noshade = true })
paint(poly{{156,98},{162,101},{162,112},{156,110}}, R("#8a4a1e", "#d9783a", "#f7a845", "#ffd66e"), nil, { noshade = true })
-- upper storey adobe plaster (soft corners: mud-plaster)
paint(rect(22, 84, 150, 128), Rplaster, speck(22, 0.05, 0.03))
-- storey ledge: a viga band with beam ends poking out
paint(rect(22, 124, 150, 128), Rtimber, planksV(40, 23), { sh = 1 })
for vx = 26, 146, 12 do paint(rect(vx, 125, vx + 3, 129), Rtimber, nil, { noshade = true }) px(vx + 1, 126, Rtimber.h) end
-- ground storey: sandstone-footed mud brick
paint(rect(22, 129, 150, 166), Rstone, bricks(12, 6, 24, 22, 129))
-- flat roof parapet of the upper storey (stepped, rounded corners)
local roof = c:rrect(14, 64, 160, 88, 3):add(c:rrect(14, 58, 40, 66, 2)):add(c:rrect(132, 58, 160, 66, 2))
paint(roof, Rplaster, function(x, y) if hash(x, y, 25) < 0.04 then return "s" end if y == 86 and x % 9 < 4 then return "s" end end, { sh = 3 })
-- viga ends under the parapet
for vx = 20, 154, 10 do paint(rect(vx, 86, vx + 3, 90), Rtimber, nil, { noshade = true }) px(vx + 1, 87, Rtimber.h) end
-- canales (rain spouts) in terracotta
paint(rect(10, 74, 18, 77), Rroof, nil, { noshade = true }) paint(rect(156, 74, 166, 77), Rroof, nil, { noshade = true })
-- kiva chimney: rounded adobe stack with puffs
paint(c:rrect(44, 30, 58, 64, 4), Rplaster, speck(26, 0.06, 0.03))
paint(rect(46, 30, 56, 33), Rbrick, nil, { noshade = true })
for i, p in ipairs({ {60,12,6,4}, {70,8,8,5}, {84,6,6,4} }) do
  local m = c:rrect(p[1], 24 - i * 3, p[1] + p[3] * 2, 24 - i * 3 + p[4], 2)
  m:clip(rect(0, 14, W - 1, 28))
  paint(m, R("#c8b6a4", "#dccab4", "#ecdcc4", "#f6ead4"), nil, { noedge = true, noshade = true })
end
-- rooftop room (the old gable dormer spot) with a stepped parapet
paint(rect(70, 40, 108, 86), Rplaster, speck(27))
paint(c:rrect(66, 34, 112, 44, 2):add(c:rrect(80, 28, 98, 36, 2)), Rplaster, function(x, y) if hash(x, y, 28) < 0.05 then return "s" end end, { sh = 2 })
for vx = 72, 106, 8 do paint(rect(vx, 44, vx + 2, 47), Rtimber, nil, { noshade = true }) end
-- turquoise band around the rooftop room
for x = 70, 108 do px(x, 52, Rturq.b) px(x, 53, Rturq.s) end
-- teapot weathervane on a pole from the roof (quirk)
paint(rect(124, 24, 125, 58), Riron, nil, { noshade = true, nohi = true })
paint(c:rrect(118, 16, 130, 24, 2), Rcopper)
paint(rect(122, 14, 126, 16), Rcopper, nil, { noshade = true })
paint(c:line({{130,20},{135,16}}, 2), Rcopper, nil, { noshade = true, nohi = true })
paint(rect(115, 18, 117, 22), Rcopper, nil, { noshade = true, nohi = true })

-- deep-set window helper: turquoise frame, warm lamplit glass, terracotta pot sill
local function window(x0, y0, x1, y1, cross, box)
  paint(rect(x0 - 2, y0 - 2, x1 + 2, y1 + 2), Rturq, nil, { sh = 1 })
  local g = rect(x0, y0, x1, y1)
  g:each(function(x, y)
    local col = GLOW[2]
    if x - x0 < 3 and y - y0 < 3 then col = GLOW[1] end
    if x1 - x < 3 or y1 - y < 2 then col = GLOW[3] end
    px(x, y, col)
  end)
  local mx, my = (x0 + x1) // 2, (y0 + y1) // 2
  for x = x0, x1 do px(x, my, Rturq.s) end
  if cross then for y = y0, y1 do px(mx, y, Rturq.s) end end
  paint(rect(x0 - 3, y1 + 3, x1 + 3, y1 + 4), Rtimber, nil, { noshade = true })
  if box then -- terracotta pot box with red geraniums
    paint(rect(x0 - 2, y1 + 5, x1 + 2, y1 + 9), Rroof, function(x, y) if y == y1 + 7 and x % 4 == 0 then return "s" end end)
    for k = x0, x1, 4 do px(k, y1 + 4, "#e05a4a") px(k + 1, y1 + 3, "#f08a60") px(k + 2, y1 + 4, "#6a8a4a") end
  end
end
window(30, 94, 48, 116, true)
window(118, 94, 136, 116, true, true)
window(80, 64, 98, 78, true)
window(30, 136, 54, 154, true)
window(64, 136, 88, 154, true)
-- hanging sign (tankard icon) from a beam
paint(rect(58, 88, 104, 90), Riron, nil, { noshade = true })
paint(rect(64, 90, 65, 96), Riron, nil, { noshade = true, nohi = true })
paint(rect(96, 90, 97, 96), Riron, nil, { noshade = true, nohi = true })
-- sign shadow on wall
rect(64, 99, 102, 121):each(function(x, y) px(x, y, Rplaster.s) end)
paint(c:rrect(60, 96, 100, 118, 2), Rhoney, planksH(5, 42, 96))
paint(rect(72, 101, 84, 114), Rbrass)
paint(rect(85, 104, 89, 111):cut(rect(85, 106, 87, 109)), Rbrass, nil, { noshade = true })
paint(rect(71, 99, 85, 102), Rcream, nil, { noshade = true })
-- door, half open with warm light
paint(rect(100, 130, 130, 166), Rtimber, nil, { sh = 1 })
local dIn = c:rrect(103, 133, 127, 166, 5)
dIn:each(function(x, y) px(x, y, (x > 122 or y > 162) and GLOW[3] or GLOW[2]) end)
paint(c:rrect(103, 133, 113, 166, 4):cut(rect(112, 133, 113, 140)), Rdoor, planksV(4, 43, 103))
px(110, 150, Rbrass.h) px(110, 151, Rbrass.b)
paint(rect(98, 164, 132, 168), Rstone, nil, { noshade = true })
-- porch lantern
paint(rect(136, 132, 137, 136), Riron, nil, { noshade = true, nohi = true })
paint(rect(133, 137, 141, 148), Riron, function(x, y) if x > 134 and x < 140 and y > 138 and y < 147 then return GLOW[2] end end, { noshade = true })
-- barrels and crate by the door
local function barrel(x0, y0, x1, y1)
  shadow(rect(x0 + 2, y1 - 1, x1 + 4, y1 + 2))
  local m = c:rrect(x0, y0, x1, y1, 3)
  paint(m, Rbarrel, planksV(3, x0, x0))
  for _, hy in ipairs({ y0 + 3, y1 - 3 }) do for x = x0, x1 do if m:has(x, hy) then px(x, hy, Riron.b) end end end
  for x = x0 + 1, x1 - 1 do px(x, y0, Rbarrel.h) end
end
barrel(136, 151, 150, 168)
barrel(152, 154, 164, 169)
-- giant ladle stuck in the barrel (quirk)
paint(c:line({{144,150},{150,136}}, 2), Rcopper, nil, { noshade = true, nohi = true })
paint(c:rrect(148, 130, 154, 136, 2), Rcopper, nil, { noshade = true })
-- crate
shadow(rect(6, 160, 22, 170))
paint(rect(4, 152, 20, 168), Rhoney, function(x, y) if x == 4 + (y - 152) or x == 20 - (y - 152) then return "s" end end)

---------------------------------------------------------------- homes (k=homes), far right tier
-- hut 1: rosy adobe with a mud-plaster dome
shadow(poly{{262,132},{324,132},{332,137},{268,137}})
paint(rect(264, 100, 322, 132), Rhut1, speck(51, 0.05, 0.03))
paint(c:ellipse(293, 102, 31, 30):clip(rect(0, 0, W - 1, 102)), Rhut1, function(x, y)
  if (y - 72) % 7 == 0 and hash(x // 6, y, 52) > 0.35 then return "s" end
  if hash(x, y, 53) < 0.03 then return "h" end
end, { sh = 3 })
paint(c:rrect(289, 68, 297, 74, 2), Rhut1, nil, { sh = 1 })
paint(rect(256, 100, 330, 103), Rtimber, nil, { noshade = true })
for vx = 260, 326, 9 do px(vx, 101, Rtimber.h) end
window(270, 108, 282, 120, true)
paint(c:rrect(296, 110, 310, 132, 4), Rteal, planksV(4, 53, 296))
paint(rect(294, 108, 312, 110), Rtimber, nil, { noshade = true })
px(306, 121, Rbrass.h)
-- mushroom-red door step stone
paint(rect(294, 131, 312, 134), Rstone, nil, { noshade = true })
-- hut 2: sand adobe, flat roof with a stepped parapet, kiva chimney, vigas
shadow(poly{{336,132},{400,132},{406,137},{342,137}})
paint(rect(338, 98, 398, 132), Rhut2, bricks(10, 5, 54, 338, 98))
paint(c:rrect(380, 66, 390, 84, 3), Rhut2, speck(55))
paint(c:rrect(334, 80, 402, 98, 2):add(c:rrect(352, 74, 384, 82, 2)), Rplum, function(x, y) if hash(x, y, 56) < 0.05 then return "s" end end, { sh = 2 })
paint(rect(330, 98, 406, 101), Rtimber, nil, { noshade = true })
for vx = 336, 400, 9 do paint(rect(vx, 96, vx + 2, 99), Rtimber, nil, { noshade = true }) end
for i, p in ipairs({ {382,62,6,3}, {388,55,8,4}, {398,49,6,3} }) do
  paint(c:rrect(p[1], p[2], p[1] + p[3], p[2] + p[4], 1), R("#c8b6a4", "#dccab4", "#ecdcc4", "#f6ead4"), nil, { noedge = true, noshade = true })
end
paint(rect(344, 108, 360, 132), Rteal, planksV(4, 57, 344))
paint(rect(342, 106, 362, 108), Rtimber, nil, { noshade = true })
window(372, 108, 390, 120, true, true)
-- clothesline with one odd sock (quirk)
for x = 323, 337 do px(x, 104 + ((x - 323) * (337 - x)) // 30, "#d8c8a8") end
paint(poly{{327,106},{331,106},{331,112},{334,113},{334,115},{327,115}}, Rred, function(x, y) if y == 108 then return "h" end end, { noshade = true })

---------------------------------------------------------------- well (decor, right mid)
shadow(poly{{280,172},{318,172},{324,177},{286,177}})
paint(rect(284, 156, 316, 174), Rwellst, bricks(8, 5, 61, 284, 156))
paint(rect(282, 154, 318, 157), Rwellst, nil, { noshade = true })
paint(rect(286, 138, 289, 154), Rbark) paint(rect(311, 138, 314, 154), Rbark)
paint(poly{{280,141},{300,128},{320,141}}, Rroof, shingles(4, 6, 62, 128), { sh = 2 })
paint(rect(288, 143, 312, 144), Rbark, nil, { noshade = true, nohi = true })
px(299, 145, "#d8c8a8") px(299, 146, "#d8c8a8") px(299, 147, "#d8c8a8")
-- bucket with a sprout growing in it (quirk)
paint(poly{{294,148},{304,148},{303,154},{295,154}}, Rcopper, nil, { noshade = true })
paint(c:rrect(297, 141, 301, 148, 1), Rcact, function(x, y) if x == 299 then return "s" end end, { sh = 1, lt = 1 })
px(295, 145, Rcact.b) px(296, 144, Rcact.h) px(299, 140, "#f08aa0") px(300, 140, "#e8607a")

---------------------------------------------------------------- people area (k=people): long table, benches, fire
-- string lights on poles
paint(rect(58, 174, 61, 214), Rbark) paint(rect(156, 174, 159, 214), Rbark)
for x = 61, 156 do
  local t = (x - 61) / 95
  local y = 176 + floor(10 * 4 * t * (1 - t))
  px(x, y, "#3a2a30")
  if (x - 66) % 22 == 0 and x > 62 and x < 154 then
    paint(rect(x - 2, y + 1, x + 2, y + 6), R("#a8541e", "#f0a040", "#ffd66e", "#fff0b0"), nil, { noshade = true })
  end
end
-- back bench
paint(rect(66, 188, 150, 191), Rhoney, nil, { noshade = true })
-- table
shadow(poly{{66,214},{156,214},{164,220},{72,220}})
paint(rect(72, 202, 76, 216), Rtimber) paint(rect(142, 202, 146, 216), Rtimber)
paint(poly{{62,194},{152,194},{158,204},{66,204}}, Rhoney, planksH(3, 71, 194), { sh = 2 })
-- things on the table: mugs, a pie, candle, boot flowerpot (quirk)
for _, mx in ipairs({ 74, 120, 134 }) do
  paint(rect(mx, 189, mx + 4, 195), Rbrass) px(mx + 1, 189, Rcream.h) px(mx + 2, 189, Rcream.h)
end
paint(poly{{86,195},{90,190},{102,190},{106,195}}, Rcopper, function(x, y) if y == 191 and x % 3 == 0 then return "s" end end)
paint(rect(112, 186, 114, 195), Rcream) px(113, 184, GLOW[1]) px(113, 185, GLOW[2])
paint(poly{{140,183},{145,183},{145,191},{151,191},{151,196},{140,196}}, R("#2c1810", "#4e2e1c", "#6a4026", "#88563a"))
paint(c:rrect(141, 176, 144, 183, 1), Rcact, function(x, y) if x == 142 then return "s" end end, { sh = 1, lt = 1 }) px(142, 175, "#f4c040") px(143, 175, "#e8607a")
-- front bench
shadow(rect(66, 222, 154, 225))
paint(rect(64, 214, 152, 218), Rhoney, planksH(2, 72, 214))
paint(rect(70, 218, 73, 224), Rtimber) paint(rect(142, 218, 145, 224), Rtimber)
-- square stone fire pit with flames
shadow(rect(20, 222, 54, 228))
paint(rect(22, 210, 52, 226), Rstone, bricks(8, 4, 73, 22, 210))
paint(rect(26, 210, 48, 213), R("#24141a", "#2e1a1e", "#3a2224", "#442a2a"), nil, { nohi = true, noshade = true })
paint(poly{{28,211},{31,196},{34,204},{37,188},{41,203},{44,197},{47,211}}, R("#a8341e", "#e0602a", "#f7a845", "#ffe08a"),
  function(x, y) if abs(x - 37) < 3 and y > 200 then return "#fff0b0" end end, { sh = 2 })
for _, sp in ipairs({ {32,184}, {42,180}, {38,176} }) do px(sp[1], sp[2], GLOW[2]) end
-- log seat beside the fire
shadow(rect(14, 232, 34, 234))
paint(c:rrect(8, 226, 32, 232, 2), Rbark, planksH(3, 74, 226))

---------------------------------------------------------------- stop (k=stop): notice board + stamp post
shadow(poly{{332,222},{388,222},{394,227},{338,227}})
paint(rect(338, 196, 341, 224), Rbark) paint(rect(376, 196, 379, 224), Rbark)
paint(poly{{328,180},{358,166},{388,180}}, Rteal, shingles(4, 6, 81, 166), { sh = 2 })
paint(rect(332, 180, 384, 208), Rteal, nil, { sh = 2 })
paint(rect(336, 183, 380, 205), R("#5a3a22", "#8a5e36", "#a87444", "#c08a52"), speck(82, 0.06, 0.02), { nohi = true })
paint(rect(339, 185, 351, 199), Rcream, function(x, y) if (y - 186) % 3 == 0 and x > 340 and x < 350 then return "s" end end)
paint(rect(354, 187, 364, 201), R("#8a5a6a", "#d49aa8", "#f0c0c8", "#fadce0"), function(x, y) if (y - 189) % 3 == 0 and x > 355 and x < 363 then return "s" end end)
paint(rect(367, 184, 377, 194), R("#8a7430", "#d8c060", "#f0dc80", "#faecb0"), nil)
for _, p in ipairs({ {345,185}, {359,187}, {372,184} }) do px(p[1], p[2], Rred.b) end
-- stamp seal icon: red diamond on the board's peak
paint(poly{{358,168},{365,175},{358,182},{351,175}}, Rred)
px(358, 175, Rred.h) px(357, 174, Rred.h)
-- hanging stamp on a cord
for y = 209, 213 do px(384, y, "#d8c8a8") end
paint(rect(381, 214, 387, 216), Rdoor, nil, { noshade = true })
paint(rect(379, 217, 389, 221), Rred)
-- lantern on the post
paint(rect(342, 188, 342, 190), Riron)

---------------------------------------------------------------- wild trail (k=wild), arch of trees on the right edge
-- trail leaving right
local trail = poly{{414,214},{462,196},{462,206},{428,218}}
trail:each(function(x, y) px(x, y, hash(x, y, 91) < 0.08 and "#866448" or "#9a7656") end)
-- ringed palm trunks
shadow(rect(412, 212, 430, 216))
local ring = function(x, y) if y % 3 == 0 then return "s" end if y % 3 == 1 and hash(x, y, 92) > 0.7 then return "h" end end
paint(poly{{416,214},{424,214},{426,140},{420,128},{414,130},{420,142}}, Rpalm, ring, { sh = 2 })
paint(poly{{448,206},{456,206},{458,124},{452,128}}, Rpalm, ring, { sh = 2 })
-- frond fans arching over the trail (gap below)
local function fan(fx, fy, len, dirs)
  local m = HP.mask()
  for _, d in ipairs(dirs) do
    local ex, ey = fx + floor(d[1] * len), fy + floor(d[2] * len)
    local mx, my = fx + floor(d[1] * len * 0.55), fy + floor(d[2] * len * 0.55) - 3
    m:add(c:line({ { fx, fy }, { mx, my }, { ex, ey } }, 3))
  end
  m:clip(rect(0, 0, 463, Hh - 1))
  paint(m, Rfrond, function(x, y) if (x + y) % 3 == 0 then return "s" end if hash(x, y, 41) > 0.9 then return "h" end end, { sh = 1, lt = 1 })
end
fan(419, 128, 20, { { -1, 0.5 }, { -0.8, -0.4 }, { -0.2, -0.9 }, { 0.5, -0.7 }, { 1, 0.1 }, { 0.3, 0.8 }, { -0.4, 0.9 } })
fan(455, 124, 20, { { -1, 0.2 }, { -0.6, -0.7 }, { 0.1, -0.9 }, { 0.6, -0.6 }, { 1, 0.4 }, { -0.5, 0.8 }, { 0.2, 0.9 } })
fan(437, 112, 16, { { -1, 0.3 }, { -0.5, -0.8 }, { 0.5, -0.8 }, { 1, 0.3 } })
for _, p in ipairs({ {416,132},{452,128} }) do paint(c:rrect(p[1], p[2], p[1] + 4, p[2] + 6, 1), Rdate, function(x, y) if (x + y) % 2 == 0 then return "s" end end, { sh = 1, lt = 1 }) end
-- agave clump at the feet
local function agave(fx, fy, sc)
  local m = HP.mask()
  for _, d in ipairs({ { -5, -2 }, { -3, -6 }, { 0, -8 }, { 3, -6 }, { 5, -2 }, { -2, -4 }, { 2, -4 } }) do
    m:add(c:line({ { fx, fy }, { fx + floor(d[1] * sc), fy + floor(d[2] * sc) } }, 2))
  end
  paint(m, Ragave, nil, { sh = 1, lt = 1 })
  px(fx, fy - floor(8 * sc), Ragave.h)
end
agave(411, 212, 1.3)
-- signpost with leaf arrow
shadow(rect(436, 206, 448, 209))
paint(rect(438, 166, 441, 208), Rbark)
paint(poly{{426,164},{450,164},{457,170},{450,176},{426,176}}, Rhoney, planksH(4, 96, 164))
paint(poly{{426,164},{450,164},{457,170},{450,176},{426,176}}, Rturq, function(x, y) if y == 170 and x > 428 and x < 450 then return "h" end end)
paint(c:rrect(437, 166, 441, 175, 1), Rcact, nil, { noshade = true }) px(435, 168, Rcact.b) px(436, 169, Rcact.b) px(443, 167, Rcact.b) px(442, 168, Rcact.b)
-- a small lantern hung from the branch
for y = 146, 150 do px(424, y, "#3a2a30") end
paint(rect(421, 151, 427, 159), Riron, function(x, y) if x > 421 and x < 427 and y > 152 and y < 158 then return GLOW[2] end end, { noshade = true })

POL = true
-- v2.5.40 polish pass 2: material cues (cracks, chips, moss, grain, rust, rope, cloth folds)
local function dots(col, t) for _, p in ipairs(t) do px(p[1], p[2], col) end end
local function seg(col, pts) for i = 1, #pts - 1 do
  local a, b = pts[i], pts[i + 1]
  local n = max(abs(b[1] - a[1]), abs(b[2] - a[2]))
  for k = 0, n do px(floor(a[1] + (b[1] - a[1]) * k / n + .5), floor(a[2] + (b[2] - a[2]) * k / n + .5), col) end
end end
local MOSS, MOSSL, MOSSD = "#e6be8a", "#f4d4a0", "#d0a274" -- wind-blown sand drifts instead of moss
-- inn plaster: hairline cracks, damp stains below sills, eave shadow
seg("#9a7a66", {{110,92},{112,96},{111,100},{114,104},{113,108}})
seg("#9a7a66", {{140,100},{142,104},{141,108}})
seg("#9a7a66", {{52,118},{54,121},{53,124}})
for _, wx in ipairs({ 30, 38, 46, 120, 130 }) do seg("#b8967c", {{wx, 119},{wx, 123}}) end
for x = 24, 148 do if hash(x, 5, 200) < 0.7 then px(x, 88, Rplaster.s) end end
-- stone courses: chips, cracks, mossy foot on the shady left, mortar glints
for _, p in ipairs({ {28,131},{70,133},{94,150},{146,142},{93,134},{58,158},{26,148},{144,156},{92,162} }) do
  px(p[1], p[2], Rstone.h) px(p[1] + 1, p[2], Rstone.h) px(p[1], p[2] + 1, Rstone.d) px(p[1] + 1, p[2] + 1, Rstone.d)
end
seg(Rstone.d, {{58,141},{60,144},{59,147}}) seg(Rstone.d, {{92,152},{94,155},{93,158}})
for x = 22, 76 do for y = 158, 166 do
  if hash(x, y, 201) < (0.55 - (x - 22) / 110) * (y - 157) / 9 then px(x, y, hash(x, y, 202) < 0.3 and MOSSL or (hash(x, y, 203) < 0.5 and MOSS or MOSSD)) end
end end
for x = 134, 150 do for y = 160, 166 do if hash(x, y, 204) < 0.22 then px(x, y, MOSS) end end end
-- roof: moss on the shady lower-left, a few newer shingles, ridge cap, soot on the chimney
for x = 14, 74 do for y = 60, 86 do
  if roof:has(x, y) and hash(x, y, 205) < 0.28 * (y - 58) / 28 * (1 - (x - 14) / 80) then px(x, y, hash(x, y, 206) < 0.3 and MOSSL or MOSS) end
end end
-- parapet: rain streaks under the canales, a few bare mud bricks where plaster fell, chimney soot
for _, sx in ipairs({ 14, 160 }) do for y = 78, 120 do if hash(sx, y, 207) < 0.6 then px(sx + (sx < 100 and 10 or -8), y, Rplaster.s) end end end
for _, r in ipairs({ {104,100,114,108},{56,140,62,148},{130,70,142,76},{24,70,34,76} }) do
  for y = r[2], r[4] do for x = r[1], r[3] do
    if ((y - r[2]) % 3 == 0) or ((x + ((y - r[2]) // 3) * 3) % 6 == 0) then px(x, y, Rbrick.s) else px(x, y, Rbrick.b) end
  end end
end
for x = 46, 56 do if hash(x, 3, 207) < 0.6 then px(x, 34, "#6a4038") end end
-- barrels: rust bloom on hoops, stave glints, drips
for _, b in ipairs({ {136,151,150,168},{152,154,164,169} }) do
  for _, hy in ipairs({ b[2] + 3, b[4] - 3 }) do
    for x = b[1] + 1, b[3] - 1 do if hash(x, hy, 208) < 0.4 then px(x, hy, "#a8542a") end end
  end
  px(b[1] + 2, b[2] + 6, Rbarrel.h) px(b[1] + 2, b[2] + 7, Rbarrel.h) px(b[3] - 3, b[4] - 1, Rbarrel.d)
end
-- crate: nail heads and split
dots(Riron.h, {{6,154},{18,154},{6,166},{18,166}}) seg(Rhoney.s, {{9,158},{11,162}})
-- table: knots, mug rings, plank seams
dots("#6e432c", {{82,198},{104,200},{132,197}}) dots("#4a2a14", {{83,198},{105,200},{133,197}})
for x = 90, 98 do px(x, 199, "#8a5a2a") end
seg("#8a5a2a", {{110,201},{116,201}})
-- stable: loose straw at the eave, hay wisps, door grain
for x = 176, 226, 3 do px(x, 102, Rthatch.h) px(x + 1, 103, Rthatch.b) px(x, 104, Rthatch.s) end
dots(Rthatch.h, {{196,124},{198,125},{203,124},{206,125}})
seg("#6e3028", {{186,112},{186,120}}) seg("#6e3028", {{214,112},{214,122}})
-- saddle: cloth folds and a stitched edge
seg(Rred.d, {{169,115},{171,119}}) seg(Rred.h, {{172,115},{173,118}})
dots("#e8c890", {{168,121},{170,121},{172,121}})
-- huts: nail rows, moss on the blue hut wall foot, shingle glints, step chips
for y = 104, 128, 6 do px(266, y, Rhut1.d) px(320, y, Rhut1.d) end
for x = 264, 292 do for y = 126, 132 do if hash(x, y, 209) < 0.26 * (y - 125) / 7 then px(x, y, MOSS) end end end
for x = 340, 392, 2 do px(x, 124, Rhut2.d) end
seg(Rhut2.d, {{353,116},{355,120},{354,124}}) dots(Rhut2.h, {{372,126},{385,128},{346,100}})
for x = 332, 360 do for y = 80, 98 do if hash(x, y, 210) < 0.1 and abs(y - (68 + (x < 368 and (x - 332) * 0.9 or 0))) > 0 then if c:get(x, y) == Rplum.b then px(x, y, Rplum.h) end end end end
dots(Rstone.h, {{296,132},{305,133},{310,132}})
-- well: wet moss at the foot, cracked stones, rust and verdigris on the bucket, rope coil
for x = 284, 316 do for y = 166, 174 do if hash(x, y, 211) < 0.3 * (y - 165) / 9 then px(x, y, MOSS) end end end
seg(Rwellst.d, {{292,160},{294,163},{293,166}}) seg(Rwellst.d, {{306,158},{307,162}})
dots("#a8542a", {{296,150},{302,152},{303,150}}) dots("#5eaaa2", {{297,148},{301,148}})
for y = 143, 147 do px(300, y, "#a89878") end dots("#a89878", {{297,147},{298,148},{297,149}})
-- board: nail heads, curled paper corners, pinned twine
dots(Riron.h, {{337,184},{379,184},{337,204},{379,204},{340,186},{352,186},{355,188},{365,188}})
dots(Rcream.d, {{350,198},{349,199}}) dots("#f0c0c8", {{364,200},{363,201}})
seg("#d8c8a8", {{353,186},{358,184},{366,186}})
for x = 334, 382 do if hash(x, 3, 212) < 0.2 then px(x, 192, Rteal.s) end end
-- fire pit: soot streaks, chipped stones; log seat bark ridges
for x = 24, 50, 2 do px(x, 214, "#24141a") px(x, 215, "#3a2224") end
dots(Rstone.h, {{26,220},{40,222},{48,216}}) seg(Rstone.d, {{34,218},{35,222}})
for x = 10, 30, 3 do px(x, 228, Rbark.h) px(x + 1, 230, Rbark.d) end
dots("#d8c8a8", {{8,229},{8,230},{9,229}})
-- trail trees: bark ridges, moss on the north (left) trunk face, branch stubs
seg(Rbark.h, {{418,136},{419,160},{420,190}}) seg(Rbark.d, {{423,150},{423,180},{424,205}})
for y = 150, 208 do if hash(417, y, 213) < 0.35 then px(417 + floor((y - 150) / 25), y, MOSS) end end
seg(Rbark.h, {{451,140},{452,170},{452,200}}) seg(Rbark.d, {{455,136},{456,176},{456,200}})
dots(MOSSL, {{451,160},{451,166},{452,188},{450,176}})
-- signpost: grain and nail, pole cracks
dots(Riron.h, {{430,168},{430,172}}) seg(Rbark.d, {{440,180},{440,200}}) seg(Rbark.h, {{439,178},{439,196}})
-- stamp post hanger rope twist
for y = 209, 213 do if y % 2 == 0 then px(384, y, "#a89878") end end
-- porch lantern rust and glass sheen
dots("#a8542a", {{134,138},{140,147},{138,137}}) px(135, 140, GLOW[1])

-- v2.5.40 polish pass 3: lived-in story props (what happens at this stop)
local Rlog = R("#3c2618", "#8a5a2a", "#c89a5a", "#e0b878")
-- 1. firewood stack against the inn foot (left), logs end-on, with a split log on top
shadow(rect(22, 168, 50, 171))
paint(rect(22, 158, 48, 168), Rbark, nil, { noshade = true, nohi = true })
for row = 0, 2 do for i = 0, 4 do
  local cx, cy = 25 + i * 5 + (row % 2) * 2, 160 + row * 3 + (row == 0 and 0 or 1)
  if cx < 47 then
    paint(c:ellipse(cx, cy + 1, 2, 2), Rlog, nil, { noshade = true, nohi = true })
    px(cx, cy + 1, "#a87a3e") px(cx - 1, cy, Rlog.h)
  end
end end
paint(rect(24, 155, 44, 157), Rbark, planksH(2, 220, 155), { noshade = true })
-- 2. broom leaning by the door, bristles at the foot
paint(rect(94, 142, 95, 164), Rhoney, nil, { noshade = true, nohi = true })
paint(poly{{92,162},{97,162},{98,168},{91,168}}, Rthatch, thatch(221), { noshade = true })
px(93, 164, Rthatch.d) px(96, 166, Rthatch.d)
-- 3. green travelling cloak on a peg on the inn side wall (story: guests stay the night)
paint(rect(156, 124, 162, 125), Riron, nil, { noshade = true, nohi = true })
paint(poly{{155,126},{163,126},{164,142},{160,145},{157,142},{154,143}}, R("#16301e", "#2a5a3a", "#3f7a4a", "#5a9a5a"), function(x, y)
  if x == 159 and y > 128 then return "s" end
  if y == 141 and x % 2 == 0 then return "d" end
end, { sh = 2 })
-- 4. mounting block beside the stable door
shadow(poly{{212,138},{228,138},{232,141},{216,141}})
paint(rect(218, 130, 230, 138), Rstone, bricks(6, 4, 222, 218, 130), { sh = 2 })
paint(rect(214, 134, 222, 138), Rstone, nil, { sh = 2 })
px(224, 131, Rstone.h) px(225, 131, Rstone.h)
-- 5. wheelbarrow of hay in front of the stable
shadow(poly{{178,134},{196,134},{200,137},{182,137}})
paint(poly{{178,126},{194,126},{191,133},{181,133}}, Rhoney, planksH(3, 223, 126), { sh = 2 })
for x = 180, 192, 2 do px(x, 124 + (x % 4) // 2, Rthatch.h) px(x + 1, 125, Rthatch.b) end
paint(c:ellipse(185, 134, 2, 2), Riron, nil, { noshade = true })
paint(rect(194, 127, 199, 128), Rhoney, nil, { noshade = true, nohi = true })
-- 6. herb bundles hung to dry under the eave
seg("#d8c8a8", {{141,90},{141,92}}) seg("#d8c8a8", {{145,90},{145,92}})
paint(poly{{139,93},{143,93},{142,99},{140,99}}, R("#2a4a22", "#3f6a34", "#6a9a48", "#8ab85a"), nil, { noshade = true })
paint(poly{{143,93},{147,93},{146,98},{144,98}}, R("#6a2a2a", "#a84a3a", "#d8683a", "#f09a4a"), nil, { noshade = true })
-- 7. pewter mugs on the front bench and a mug left on the log seat
for _, mx in ipairs({ 96, 130 }) do
  paint(rect(mx, 209, mx + 3, 214), Rbrass, nil, { noshade = true }) px(mx, 209, Rcream.h) px(mx + 4, 210, Rbrass.d) px(mx + 4, 212, Rbrass.d)
end
paint(rect(22, 221, 25, 226), Rbrass, nil, { noshade = true }) px(22, 221, Rcream.h)
-- 8. water barrel beside the blue hut, lid ajar, rope and a ladle
shadow(rect(326, 131, 336, 134))
paint(c:rrect(324, 119, 334, 133, 3), Rbarrel, planksV(3, 224, 324))
for _, hy in ipairs({ 122, 130 }) do for x = 324, 334 do px(x, hy, Riron.b) end end
px(324, 119, Rbarrel.h)
for x = 325, 333 do px(x, 120, Rbarrel.d) end for x = 326, 332 do px(x, 121, "#5a7aa0") end
-- 9. stacked sacks of grain by the huts' foot (right of hut 2 door)
shadow(rect(396, 131, 406, 134))
paint(c:ellipse(400, 128, 5, 4), R("#6a5a3a", "#b8a478", "#d8c496", "#efe0b8"), function(x, y) if y == 125 then return "d" end end, { sh = 2 })
paint(c:ellipse(398, 122, 4, 3), R("#6a5a3a", "#b8a478", "#d8c496", "#efe0b8"), nil, { sh = 2 })
px(400, 125, "#a88e66") px(399, 119, "#a88e66")
-- 10. a bootscraper and doormat before the inn door
paint(rect(104, 168, 126, 169), R("#5a3a22", "#a87444", "#c08a52", "#d8a468"), function(x, y) if x % 3 == 0 then return "s" end end, { noshade = true })
paint(rect(92, 168, 98, 170), Riron, nil, { noshade = true })

-- v2.5.40 polish pass 4b: key light top-left, warm glows, rim light, flora variety, foreground flora
local sqrt = math.sqrt
for y = 88, 118 do for x = 190, 410 do
  local cur = c:get(x, y)
  if (cur == Rpine.b or cur == Rpine.s or cur == Rpine.h) and hash(x, y, 301) < (y - 88) / 45 then px(x, y, (cur == Rpine.h) and "#4a6a6e" or "#3a5a62") end
end end
local GC = { ["#e8c28e"]=true, ["#ecc894"]=true, ["#efcc98"]=true, ["#f2d2a0"]=true, ["#f6d8a8"]=true, ["#dcb282"]=true, ["#f8e0b2"]=true,
             ["#d8ae80"]=true, ["#d49c6c"]=true, ["#c48a60"]=true, ["#f6d8a6"]=true, ["#e8b084"]=true }
local function glow(m, cA, cB, solid)
  m:each(function(x, y)
    if y > HOR and GC[c:get(x, y)] and free(x, y, 16) then
      if (x + y) % 2 == 0 then px(x, y, cA) elseif solid then px(x, y, cB) end
    end
  end)
end
-- window and door light spilling onto the ground in front of the inn
glow(poly{{30,169},{56,169},{66,177},{36,177}}, "#f8dca4", "#f2d09a")
glow(poly{{64,169},{90,169},{100,178},{70,178}}, "#f8dca4", "#f2d09a")
glow(poly{{104,171},{128,171},{146,187},{96,187}}, "#fae2ac", "#f6d6a0", true)
-- fire glow on grass
glow(c:ellipse(37, 219, 26, 10), "#f8c88a", "#f4d49c", true)
-- warm rim light on the fire-facing edges of the pit and log seat
for x = 22, 30 do px(x, 210, "#e8a060") end for y = 211, 224 do px(22, y, "#c8804e") end
for x = 8, 18 do px(x, 226, "#d8904e") end
-- string lights warm the table top beneath them
for x = 64, 150, 3 do px(x, 195, "#e8b868") end
-- lantern halos in the evening sky (ring dither)
local function halo(cx, cy, r)
  for y = cy - r, cy + r do for x = cx - r, cx + r do
    local d = sqrt((x - cx) ^ 2 + (y - cy) ^ 2)
    local cur = c:get(x, y)
    if d < r and d > 7 and y > 13 and x > 15 and x < W - 16 and (cur == SKY[1] or cur == SKY[2] or cur == SKY[3] or cur == SKY[4]) then
      if d < r - 5 then px(x, y, "#5a4a7e") elseif (x + y) % 2 == 0 then px(x, y, "#4a4078") end
    end
  end end
end
-- (no sky halos by day)
-- rim light along the lit upper-left roof edge, and warm rim on the inn's door-side edges
for x = 16, 38 do px(x, 58, "#fff0d0") end for x = 68, 110 do px(x, 34, "#fff0d0") end for y = 60, 86 do px(14, y, "#fbe4c0") end
for y = 134, 164 do px(133, y, "#f0b060") end
for y = 134, 150 do px(104, y, "#f0b060") end
-- berry bush between the inn and the stable
shadow(poly{{172,162},{192,162},{196,166},{176,166}})
for _, pd in ipairs({ {176,152,183,163}, {182,146,189,157}, {170,147,176,156}, {184,155,191,163} }) do
  paint(c:ellipse((pd[1] + pd[3]) // 2, (pd[2] + pd[4]) // 2, (pd[3] - pd[1]) // 2, (pd[4] - pd[2]) // 2), Rcact,
    function(x, y) if hash(x, y, 311) < 0.06 then return "#f6e8b8" end end, { sh = 2, lt = 1 })
end
for _, b in ipairs({ {184,145},{187,145},{171,146},{189,154} }) do px(b[1], b[2], "#d8384a") px(b[1], b[2] - 1, "#f08090") end
-- hollyhock stalks beside the well (tall spires, new plant kind)
for _, hx in ipairs({ 272, 276, 279 }) do
  local top = 150 + (hx % 5) * 3
  for y = top, 172 do px(hx, y, "#5e7a40") end
  for k = 0, 3 do
    local by = top + k * 5
    local col = ({ "#e05a8a", "#f4d0b0", "#b84a8a", "#f08aa0" })[1 + (hx + k) % 4]
    px(hx - 1, by, col) px(hx + 1, by, col) px(hx, by - 1, col) px(hx, by, "#f0d060")
  end
  px(hx - 2, 170, "#6e8a4a") px(hx + 2, 169, "#6e8a4a") px(hx - 1, 171, "#94a860") px(hx + 1, 171, "#94a860")
end
-- foreground frame flora: dark ferns and foxglove at the lower edges (kept off every stand point)
local function fern(bx, by, n, len, seed)
  for i = 1, n do
    local a = -3.14159 * (0.12 + 0.76 * (i - 1) / (n - 1))
    local L = len * (0.7 + 0.3 * hash(i, seed, 320))
    for t = 0, L do
      local x = floor(bx + math.cos(a) * t + .5)
      local y = floor(by + math.sin(a) * t * 0.95 + .5)
      px(x, y, (t % 5 == 0) and "#8ab8a4" or "#5e8a82") px(x, y + 1, "#36585a")
      if t > 3 and t % 4 == 0 then px(x, y - 1, "#c4e0c8") end
    end
  end
end
fern(26, 269, 7, 20, 1) fern(52, 269, 5, 14, 2) fern(310, 269, 6, 16, 3) fern(21, 140, 0, 0, 4)
for _, fx in ipairs({ 40, 46, 316 }) do
  for y = 248 + (fx % 7), 268 do px(fx, y, "#9a7a58") px(fx + 1, y, "#74583f") end
  for k = 0, 4 do
    local y = 250 + (fx % 7) + k * 3
    px(fx - 1, y, "#f6e8c4") px(fx + 2, y + 1, "#ecdcb0") px(fx - 2, y + 1, "#d8c49a")
  end
end

POL = false
---------------------------------------------------------------- the gate frame (inn timber + lanterns)
local adobeTex = function(x, y)
  local bare = hash(x // 7, y // 18, 71) > 0.55
  if bare and y % 6 == 0 then return "s" end
  if bare and y % 6 ~= 0 and (x + ((y // 6) % 2) * 4) % 8 == 0 then return "s" end
  if hash(x, y, 72) > 0.97 then return "h" end
end
paint(rect(0, 0, 15, Hh - 1), Rframe, adobeTex, { sh = 3 })
paint(rect(W - 16, 0, W - 1, Hh - 1), Rframe, adobeTex, { sh = 3 })
for _, x0 in ipairs({ 1, W - 15 }) do for x = x0, x0 + 13 do px(x, 150, Rturq.h) px(x, 151, Rturq.b) px(x, 152, Rturq.s) end end
paint(rect(0, 0, W - 1, 13), Rtimber, function(x, y) if (y == 4 or y == 8) and hash(x // 5, y, 73) > 0.3 then return "s" end end, { sh = 3 })
-- viga ends poking through under the lintel
for _, vx in ipairs({ 20, 60, 100, 140, 180, 290, 330, 370, 410, 450 }) do paint(rect(vx, 13, vx + 5, 17), Rtimber, nil, { noshade = true }) px(vx + 2, 15, Rtimber.d) end
-- palm fronds drooping from the lintel
local function bough(bx, by, len, dir)
  local m = poly{ { bx, by }, { bx + dir * len, by + floor(len * 0.55) }, { bx + dir * floor(len * 0.6), by + floor(len * 0.75) }, { bx - dir * 3, by + floor(len * 0.35) } }
  paint(m, Rfrond, function(x, y) if (x * dir + y) % 3 == 0 then return "s" end if (x * dir - y) % 7 == 0 then return "h" end end, { sh = 2 })
end
for _, b in ipairs({ { 14, 11, 30, 1 }, { 6, 18, 22, 1 }, { 465, 11, 30, -1 }, { 473, 18, 22, -1 }, { 186, 11, 9, 1 }, { 290, 11, 9, -1 } }) do bough(b[1], b[2], b[3], b[4]) end
-- hanging lanterns
local function lantern(cx, top, len)
  for y = 14, top - 1 do px(cx, y, (y % 2 == 0) and Riron.b or Riron.h) end
  paint(rect(cx - 6, top, cx + 6, top + 3), Riron, nil, { noshade = true })
  paint(rect(cx - 5, top + 4, cx + 5, top + len), Riron, function(x, y)
    if x > cx - 4 and x < cx + 4 and y > top + 4 and y < top + len - 1 then
      return (x < cx and y < top + 8) and GLOW[1] or ((x > cx + 1 or y > top + len - 3) and GLOW[3] or GLOW[2])
    end
  end, { noshade = true })
  for x = cx - 4, cx + 4 do if x ~= cx - 4 and x ~= cx + 4 then end end
  for y = top + 5, top + len - 2 do px(cx, y, Riron.s) end
  paint(rect(cx - 3, top + len + 1, cx + 3, top + len + 2), Riron, nil, { noshade = true })
end
lantern(34, 26, 16)
lantern(446, 26, 16)
-- charm: a short chili ristra on a turquoise tie, little brass bell at the tip
for y = 14, 18 do px(240, y, "#d8c8a8") end
paint(rect(237, 18, 243, 20), Rturq, nil, { noshade = true })
for i = 0, 4 do
  local cy = 21 + i * 4
  paint(c:rrect(235, cy, 239, cy + 4, 1), Rred, nil, { sh = 1, lt = 1 })
  paint(c:rrect(241, cy + 2, 245, cy + 6, 1), Rred, nil, { sh = 1, lt = 1 })
end
paint(poly{{237,42},{243,42},{245,47},{235,47}}, Rbrass)
px(240, 48, Rbrass.d)

---------------------------------------------------------------- save
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

local layout = [[{"w":480,"h":270,"horizon":112,"view":"gate","spots":[]] ..
  [[{"k":"do","name":"Lantern Inn","x":91,"y":95,"box":[10,14,172,176]},]] ..
  [[{"k":"people","name":"Long Table","x":84,"y":205,"box":[4,180,164,234]},]] ..
  [[{"k":"stop","name":"Stamp Board","x":358,"y":195,"box":[326,164,392,227]},]] ..
  [[{"k":"homes","name":"Roadside Huts","x":331,"y":101,"box":[254,46,406,138]},]] ..
  [[{"k":"wild","name":"Wild Trail","x":435,"y":156,"box":[408,94,463,218]}],]] ..
  [["stand":[{"x":240,"y":250},{"x":198,"y":210},{"x":282,"y":208},{"x":240,"y":162},{"x":100,"y":256},{"x":345,"y":254}],]] ..
  [["compass_clear":[380,230,480,270]}]]
local f = io.open(OUT .. NAME .. ".layout.json", "w") f:write(layout .. "\n") f:close()
print("ok " .. NAME)
