local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.pi
local H = X.hash
local INK = GX.INK
local NAME = app.params.name or "all"
local c
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end
local function R6(R) return GX.ramp6(R) end
local function RP(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local function lit(m, R, o) o = o or {}; o.rimlight = o.rimlight ~= false; return GX.lit(c, m, R6(R), o) end
local function blob(cx, cy, rx, ry, R, seed, o) local m = mk(); E(m, cx, cy, rx, ry); m = GX.rough(m, seed, 1); o = o or {}; o.seed = seed; lit(m, R, o); return m end
local function box(x0, y0, x1, y1, R, o) local m = c:rect(x0, y0, x1, y1); o = o or {}; o.R = o.R or 8; lit(m, R, o); return m end
local function ink(x0, y0, x1, y1, col) c:fillMask(c:rect(x0, y0, x1, y1), col or INK) end
local function poly(pts, R, o) local m = c:poly(pts); o = o or {}; o.R = o.R or 8; lit(m, R, o); return m end

local WOOD = RP("#e8a868", "#b86e44", "#82444a", "#4a2840")
local DWOOD = RP("#c88858", "#8a5238", "#5a3040", "#34202e")
local CREAM = RP("#fffae8", "#ffe8c0", "#e0b0a0", "#a07088")
local THATCH = RP("#ffd878", "#e0a050", "#a8684a", "#603a48")
local RED = RP("#ff9a88", "#e8485c", "#a02c5c", "#601c50")
local GRN = RP("#a8d860", "#48a048", "#2a6a48", "#183a40")
local GRN2 = RP("#88c458", "#2e8444", "#1c5440", "#122e3a")
local PINK = RP("#ffd8e4", "#f4a0bc", "#b8608c", "#6a3468")
local STONE = RP("#d8d4e8", "#a8a4c4", "#7a74a0", "#4a4470")
local SNOW = RP("#ffffff", "#e8f0fc", "#a8b8e0", "#6070a8")
local WARM = "#ffd878"

local function glowAt(x, y, r, col, a)
  for yy = y - r, y + r do for xx = x - r, x + r do
    local dd = sqrt((xx - x) ^ 2 + (yy - y) ^ 2); local cur = c:get(xx, yy)
    if cur and dd <= r and xx >= 0 and xx < 480 and yy >= 0 and yy < 270 then c:px(xx, yy, GX.mix(cur, col, dd < r * .55 and a or a * .5)) end
  end end
end
local function lantern(x, y, r)
  glowAt(x, y, r * 3, "#ffa040", .3)
  local m = mk(); E(m, x, y, r, r + 1); c:rim(m, INK)
  m:each(function(xx, yy) local dd = sqrt((xx - x) ^ 2 + ((yy - y) * r / (r + 1)) ^ 2); c:px(xx, yy, dd < r * .35 and "#fffbe0" or dd < r * .6 and "#ffe890" or dd < r * .85 and "#ffb848" or "#e87a38") end)
end
local function window(x0, y0, x1, y1, col)
  ink(x0 - 1, y0 - 1, x1 + 1, y1 + 1)
  for y = y0, y1 do for x = x0, x1 do local t = (y - y0) / max(1, y1 - y0); c:px(x, y, t < .3 and "#fff4c0" or t < .7 and (col or "#ffd060") or "#f0a040") end end
  c:fillMask(c:rect((x0 + x1) // 2, y0, (x0 + x1) // 2, y1), "#b86e44")
  c:fillMask(c:rect(x0, (y0 + y1) // 2, x1, (y0 + y1) // 2), "#b86e44")
end
local function fire(x, y, s)
  glowAt(x, y - 4 * s, 16 * s, "#ff9030", .3)
  for i = 0, 3 do blob(x - 7 * s + i * 5 * s, y + 1, 4 * s, 2 * s, DWOOD, 50 + i, { R = 3, tex = .2 }) end
  local m = mk(); for yy = 0, 15 * s do local w = floor((1 - yy / (15 * s)) * 6 * s * (.6 + .4 * sin(yy / 2))); for xx = -w, w do m:set(x + xx, y - yy) end end
  m = GX.rough(m, 3, 1); c:rim(m, "#8a2a38")
  m:each(function(xx, yy) local t = (y - yy) / (15 * s); local dx = abs(xx - x) / (6 * s); c:px(xx, yy, (t < .35 and dx < .35) and "#fff4b0" or t < .55 and "#ffc848" or t < .8 and "#ff8a30" or "#e8483c") end)
end
local function stars(n, ymax, seed)
  for i = 0, n do local x, y = floor(H(i, 1, seed) * 478), floor(H(i, 2, seed) * ymax); c:px(x, y, "#fff0d0"); if i % 6 == 0 then c:px(x + 1, y, "#d8c0e8"); c:px(x, y + 1, "#d8c0e8"); c:px(x - 1, y, "#d8c0e8"); c:px(x, y - 1, "#d8c0e8") end end
end
local function moon(x, y, r)
  glowAt(x, y, r * 2, "#fff0c0", .2)
  local m = mk(); E(m, x, y, r); local cut = mk(); E(cut, x + floor(r * .5), y - floor(r * .3), r); m:cut(cut); c:rim(m, INK)
  m:each(function(xx, yy) c:px(xx, yy, xx < x - r * .4 and "#fffbe0" or "#ffe890") end)
end
local function ground(y0, R, seed, o)
  local function yfn(x) return y0 + floor(2 * sin(x / 41 + seed) + 1.5 * sin(x / 13)) end
  GX.ground(c, yfn, R, seed, o or { top = .86, fall = .55, tex = .3, sc = 8 })
  for x = 0, 479 do local y = yfn(x); c:px(x, y - 1, R.hi); c:px(x, y, R.hi) end
end
local function shadow(cx, cy, rx, ry, col) local m = mk(); E(m, cx, cy, rx, ry); m = GX.rough(m, cx, 1); c:fillMask(m, col) end
local function pine(x, y, h, R)
  local w = floor(h * .3)
  c:fillMask(c:rect(x - 2, y - 10, x + 2, y), INK); c:fillMask(c:rect(x - 1, y - 10, x + 1, y), "#7a4a3a")
  for i = 0, 3 do
    local ty = y - 8 - i * floor(h / 4.6); local ww = w - i * floor(w / 4.5)
    local m = c:poly{ { x, ty - floor(h / 3.2) }, { x + ww, ty }, { x - ww, ty } }
    lit(m, R, { R = 8, tex = .3, seed = i + x })
    for k = -ww + 3, ww - 3, 4 do c:px(x + k, ty - 1 - abs(k) // 2, SNOW.hi) end
  end
end
local function palm(x0, y0, x1, y1, seed, fl)
  local m = mk(); for i = 0, 60 do local t = i / 60; local x = x0 + (x1 - x0) * t + 8 * sin(t * pi) * (fl or 1); local y = y0 + (y1 - y0) * t; E(m, floor(x), floor(y), 4 - floor(t * 2)) end
  lit(GX.rough(m, seed, 1), RP("#d89868", "#a0603c", "#6e3c44", "#40243a"), { R = 4, tex = .35, sc = 2, seed = seed, fn = function(x, y) return (floor(y / 3) % 2) * .14 - .07 end })
  local cx, cy = x1, y1
  for i, a in ipairs{ 170, 140, 105, 70, 35, 5, 200 } do
    local mm, L = mk(), 34 - (i % 2) * 5; local ca, sa = cos(a / 57.3), -sin(a / 57.3)
    for k = 0, L do local t = k / L; local x, y = floor(cx + ca * L * t), floor(cy + sa * L * t + 16 * t * t); local w = floor(5 * sin(pi * min(1, t * 1.15)) ^ .75 + .5); for j = -w, w do mm:set(x, y + j) end end
    lit(mm, i % 2 == 0 and GRN or GRN2, { R = 3, tex = .35, sc = 2, seed = seed + i, amb = .3 })
  end
  blob(cx - 3, cy + 5, 3, 3, DWOOD, seed, { R = 3 }); blob(cx + 3, cy + 5, 3, 3, DWOOD, seed + 1, { R = 3 })
end
local function tuftsAt(list, R) for _, p in ipairs(list) do GX.tuft(c, p[1], p[2], R) end end
local function swirl(x, y) c:px(x, y, "#fff0c0") end
local function note(x, y)
  c:fillMask(c:rect(x, y + 6, x + 3, y + 8), INK); c:fillMask(c:rect(x + 1, y + 6, x + 2, y + 7), "#fff0c0")
  c:fillMask(c:rect(x + 3, y, x + 3, y + 6), INK); c:fillMask(c:rect(x + 3, y, x + 6, y + 1), INK); c:px(x + 4, y + 1, "#fff0c0")
end
-- thatched / tiled gable roof, eaves overhang
local function roof(x0, x1, ytop, yb, R, seed, hem)
  local m = mk(); local mid = (x0 + x1) / 2
  for y = ytop, yb do local t = (y - ytop) / (yb - ytop); local hw = floor((mid - x0) * (.15 + .85 * t)); for x = floor(mid - hw), floor(mid + hw) do m:set(x, y) end end
  if hem then for x = x0, x1 do for k = 0, 2 do if H(x // 3, k, seed) < .5 then m:set(x, yb + k) end end end end
  m = GX.rough(m, seed, 1)
  lit(m, R, { R = 22, tex = .5, sc = 3, seed = seed, wrap = .4, fn = function(x, y) return (H(x // 2, y // 4, seed) - .5) * .2 - ((y - ytop) % 5 == 0 and .12 or 0) end })
  return m
end
local function sleeper(x, y, R, col)   -- sleepy fox / cat curled
  local m = blob(x, y, 15, 8, R, x, { R = 8, tex = .3 })
  blob(x + 12, y - 2, 6, 5, R, x + 1, { R = 5 })
  poly({ { x + 8, y - 5 }, { x + 10, y - 12 }, { x + 13, y - 6 } }, R, { R = 3 }); poly({ { x + 13, y - 6 }, { x + 17, y - 11 }, { x + 18, y - 3 } }, R, { R = 3 })
  c:px(x + 14, y - 2, INK); c:px(x + 15, y - 2, INK); c:px(x + 18, y, INK)
  blob(x - 15, y + 1, 7, 4, RP("#fff4e0", "#ffe0b8", "#d8a888", "#8a5a60"), x + 2, { R = 4 })
  ink(x + 2, y - 8, x + 6, y - 7, "#58c8d8"); ink(x + 4, y - 7, x + 5, y - 3, "#58c8d8")
end

local P = {}
---------------------------------------------------------------- aurora camp
P["haven-aurora-camp"] = function()
  GX.bands(c, 0, 168, { "#120c30", "#1a1448", "#241c5c", "#2c2a6c", "#34407c", "#40548c", "#5870a0" }, 5, .12)
  stars(90, 100, 3)
  for b = 0, 2 do
    local CC = { { "#58e8a8", "#3cc890", "#28a07c" }, { "#a8f0a0", "#58e8a8", "#38b890" }, { "#e890d8", "#b870d0", "#8858b8" } }; local cols = CC[b + 1]
    for x = 0, 479 do
      local y0 = 18 + b * 14 + floor(16 * sin(x / 52 + b * 1.7) + 7 * sin(x / 19 + b)); local len = 34 + floor(14 * sin(x / 33 + b))
      for k = 0, len do local col = k < 3 and cols[1] or k < len * .5 and cols[2] or cols[3]; if k > len * .7 and (x + k) % 2 == 1 then break end c:px(x, y0 + k, col) end
    end
  end
  -- far mountains
  local mm = mk(); for x = 0, 479 do local y = 150 - floor(26 * (sin(x / 61) * .5 + .5) ^ 1.3 + 8 * sin(x / 17)); for yy = y, 170 do mm:set(x, yy) end end
  lit(mm, RP("#c8d4f4", "#7c8cc8", "#4c58a0", "#2c3070"), { R = 30, tex = .4, sc = 4, seed = 2, rimlight = false, ink = false })
  ground(172, SNOW, 4, { top = .9, fall = .5, tex = .25, sc = 8 })
  for i = 0, 50 do c:px(floor(H(i, 8, 2) * 480), 180 + floor(H(i, 9, 2) * 88), i % 2 == 0 and "#a8b8e0" or "#ffffff") end
  local PN, PN2 = RP("#5ac0a0", "#2e8870", "#1e5860", "#143040"), RP("#4aa88c", "#26786a", "#1a4858", "#102a38")
  pine(44, 196, 64, PN); pine(86, 188, 46, PN2); pine(420, 192, 58, PN); pine(456, 200, 74, PN2); pine(380, 186, 38, PN2)
  -- tent
  shadow(250, 232, 90, 8, "#7080b8")
  local T = RP("#ffc060", "#f07a30", "#b84a38", "#702840")
  local tm = c:poly{ { 250, 108 }, { 332, 230 }, { 168, 230 } }
  lit(tm, T, { R = 30, tex = .25, sc = 4, seed = 2 })
  local door = c:poly{ { 250, 150 }, { 280, 230 }, { 220, 230 } }
  c:rim(door, INK); door:each(function(x, y) local t = (y - 150) / 80; c:px(x, y, t < .3 and "#fff4c0" or t < .65 and "#ffd060" or "#f0a040") end)
  glowAt(250, 220, 40, "#ffb050", .25)
  ink(249, 94, 250, 112); poly({ { 251, 94 }, { 262, 98 }, { 251, 102 } }, RED, { R = 3 })
  fire(150, 238, 1); fire(360, 240, 1)
  -- log seats
  box(92, 236, 118, 246, DWOOD, { R = 6 }); box(384, 238, 412, 248, DWOOD, { R = 6 })
  sleeper(330, 248, RP("#ffb060", "#e87838", "#b04a40", "#642a44"))
  -- kettle on fire (quirk: tiny teapot steaming)
  blob(176, 240, 7, 6, RP("#c8c4e0", "#8884b0", "#5c5890", "#383468"), 7, { R = 5 }); ink(171, 226, 181, 226, INK)
  for k = 0, 3 do swirl(176 + (k % 2) * 2, 224 - k * 3) end
  tuftsAt({ { 30, 244 }, { 210, 262 }, { 300, 262 }, { 470, 250 } }, RP("#ffffff", "#d8e4f8", "#8898c8", "#5060a0"))
end

---------------------------------------------------------------- baobab inn
P["haven-baobab-inn"] = function()
  GX.bands(c, 0, 200, { "#7a4a9c", "#a85a9a", "#d8707c", "#f49a6a", "#ffc070", "#ffe090", "#fff0b0" }, 4, .15)
  glowAt(380, 150, 60, "#fff4c0", .3); blob(380, 150, 24, 24, RP("#fffbe0", "#ffe890", "#ffc468", "#f09858"), 9, { R = 14, tex = .1, ink = false, rimlight = false })
  for i = 0, 3 do local x = 40 + i * 120; local y = 150 - (i % 2) * 6; ink(x, y, x, y + 14, "#4a2840"); blob(x, y - 2, 18, 4, RP("#78a848", "#4a8448", "#2e5848", "#1c3640"), i + 4, { R = 4, tex = .2 }) end
  ground(190, RP("#fff0c0", "#f2c890", "#c8946c", "#8a5a60"), 5)
  -- trunk
  local tr = mk(); for y = 36, 232 do local t = (y - 36) / 196; local hw = floor(46 + 22 * t ^ 2.2 + 8 * sin(y / 17)); for x = 240 - hw, 240 + hw do tr:set(x, y) end end
  lit(GX.rough(tr, 4, 1), RP("#f0b080", "#c07a58", "#8a4a52", "#52284a"), { R = 40, tex = .5, sc = 3, seed = 4, fn = function(x, y) return ((x + floor(y / 9)) % 11 == 0) and -.14 or 0 end })
  -- crown
  for i, p in ipairs{ { 150, 52, 38, 16 }, { 205, 30, 40, 16 }, { 270, 28, 42, 16 }, { 330, 50, 38, 16 }, { 240, 50, 30, 12 } } do blob(p[1], p[2], p[3], p[4], i % 2 == 0 and GRN or GRN2, i * 3, { R = 10, tex = .4 }) end
  -- door and windows in the trunk
  local dm = c:rect(222, 160, 258, 232); local dr = mk(); E(dr, 240, 172, 18, 14); dr:each(function(x, y) dm:set(x, y) end)
  c:rim(dm, INK); dm:each(function(x, y) local t = (y - 150) / 82; c:px(x, y, t < .25 and "#fff4c0" or t < .6 and "#ffd060" or "#f0a040") end)
  for x = 224, 256, 8 do ink(x, 166, x, 232, "#8a4a4a") end
  box(214, 228, 266, 234, WOOD, { R = 4 })
  window(178, 130, 194, 150); window(286, 130, 302, 150); window(206, 92, 222, 110); window(258, 92, 274, 110)
  glowAt(240, 190, 50, "#ffb050", .2)
  for i, x in ipairs{ 170, 310, 112, 368 } do ink(x, 120 + (i > 2 and 40 or 0), x, 150 + (i > 2 and 40 or 0)); lantern(x, 154 + (i > 2 and 40 or 0), 5) end
  -- sign + meerkat
  ink(120, 190, 120, 240); box(100, 176, 140, 196, WOOD, { R = 6 }); ink(108, 184, 132, 185, "#4a2840"); ink(108, 189, 126, 190, "#4a2840")
  local mk2 = RP("#f0c890", "#c89060", "#8a5a54", "#4a3040")
  blob(374, 236, 8, 12, mk2, 2, { R = 6 }); blob(374, 214, 6, 6, mk2, 3, { R = 4 }); ink(371, 212, 372, 213); ink(376, 212, 377, 213); c:px(374, 216, INK)
  ink(370, 207, 372, 209, "#52284a"); ink(377, 207, 379, 209, "#52284a")
  for _, x in ipairs{ 80, 420 } do ink(x, 238, x + 2, 252, "#4a2840"); blob(x, 250, 8, 5, RP("#ffe090", "#f0a848", "#b86a4c", "#6a3a48"), x, { R = 4 }) end
  tuftsAt({ { 60, 230 }, { 190, 250 }, { 300, 256 }, { 450, 232 } }, RP("#e8d870", "#a8a048", "#6e7448", "#44503c"))
end

---------------------------------------------------------------- cherry blossom teahouse
P["haven-cherry-blossom-teahouse"] = function()
  GX.bands(c, 0, 180, { "#8a9ce0", "#a8b4ec", "#c8c8f0", "#f0c8e0", "#ffd8d8", "#ffe8d0" }, 6, .1)
  local mt = mk(); for x = 0, 479 do local y = 140 - floor(70 * max(0, 1 - abs(x - 360) / 150) ^ 1.1) + floor(4 * sin(x / 9)); for yy = y, 150 do mt:set(x, yy) end end
  lit(mt, RP("#e8e8fc", "#8c94cc", "#5c64a8", "#383c7c"), { R = 40, tex = .3, sc = 4, seed = 3, rimlight = false, ink = false })
  for x = 300, 420 do local y = 140 - floor(70 * max(0, 1 - abs(x - 360) / 150) ^ 1.1); if y < 100 then for yy = y, y + 8 - abs(x - 360) // 8 do c:px(x, yy, "#ffffff") end end end
  ground(172, RP("#b8e088", "#78b860", "#3e8a58", "#24543e"), 3)
  -- teahouse
  shadow(300, 214, 130, 6, "#2e6a50")
  local base = box(190, 186, 410, 212, STONE, { R = 14, tex = .4 })
  local wall = box(204, 130, 396, 190, CREAM, { R = 40, tex = .2, rimlight = false })
  for x = 204, 396, 24 do ink(x, 130, x + 1, 190, "#8a4a4a") end
  for i = 0, 3 do local x0 = 214 + i * 46; window(x0, 144, x0 + 34, 184, "#ffe090"); for k = 0, 5 do ink(x0 + k * 7, 144, x0 + k * 7, 184, "#b86e44") end end
  -- curved double roof
  local function croof(x0, x1, y0, y1, sc)
    local m = mk(); for y = y0, y1 do local t = (y - y0) / (y1 - y0); local ext = floor((x1 - x0) / 2 * (.7 + .3 * t) + 12 * t ^ 3); local cx = (x0 + x1) // 2; for x = cx - ext, cx + ext do m:set(x, y) end end
    for x = x0 - 14, x1 + 14 do local lift = floor(((abs(x - (x0 + x1) / 2) / ((x1 - x0) / 2 + 14)) ^ 3) * 8); for y = y1 - lift + 1, y1 + 1 do m:set(x, y) end end
    lit(GX.rough(m, sc, 1), RP("#6a78b8", "#3e4a8a", "#2a3068", "#181c44"), { R = 28, tex = .3, sc = 3, seed = sc, fn = function(x, y) return (x % 5 == 0) and -.1 or 0 end })
  end
  croof(184, 416, 106, 134, 3); croof(230, 372, 78, 104, 4)
  ink(300, 62, 300, 80); poly({ { 300, 64 }, { 312, 70 }, { 300, 74 } }, RED, { R = 3 })
  window(262, 86, 338, 98, "#ffe090")
  lantern(206, 194, 6); lantern(396, 194, 6); lantern(300, 128, 5)
  -- steps + noren curtain
  box(274, 200, 328, 212, STONE, { R = 4 })
  -- cherry tree left
  local tk = mk(); for y = 60, 220 do local hw = floor(8 + (y - 60) / 20); for x = 90 - hw + floor(6 * sin(y / 30)), 90 + hw + floor(6 * sin(y / 30)) do tk:set(x, y) end end
  lit(GX.rough(tk, 7, 1), DWOOD, { R = 8, tex = .5, sc = 3, seed = 7 })
  local PBL = RP("#ffe4ee", "#f8a8c4", "#c8689a", "#7a3a78")
  for i, p in ipairs{ { 40, 66, 44, 26 }, { 100, 40, 50, 28 }, { 150, 74, 36, 20 }, { 74, 96, 40, 22 }, { 124, 100, 30, 16 } } do blob(p[1], p[2], p[3], p[4], PBL, i * 5, { R = 14, tex = .5, sc = 3 }) end
  for i = 0, 40 do local x, y = floor(H(i, 5, 5) * 480), 130 + floor(H(i, 6, 5) * 130); c:px(x, y, "#ffc8d8"); c:px(x + 1, y, "#f8a8c4") end
  -- koi pond
  local pm = mk(); E(pm, 120, 246, 56, 11); c:rim(pm, INK); pm:each(function(x, y) c:px(x, y, (x + y) % 9 == 0 and "#8ad8e8" or ((y - 236) < 4 and "#3e8ab0" or "#58b4d0")) end)
  blob(104, 246, 8, 4, RP("#ffc080", "#f07838", "#b84a38", "#702840"), 2, { R = 4 }); blob(140, 250, 7, 3, RP("#fffae8", "#ffe0c0", "#d8a090", "#8a5a60"), 3, { R = 3 }); ink(111, 245, 111, 245)
  blob(120, 242, 6, 3, GRN, 4, { R = 3 }); c:px(120, 240, "#ffc8d8")
  -- stone lantern quirk
  box(340, 224, 352, 232, STONE, { R = 4 }); box(342, 232, 350, 246, STONE, { R = 4 }); poly({ { 346, 214 }, { 358, 224 }, { 334, 224 } }, STONE, { R = 5 }); ink(343, 226, 349, 230, WARM)
  tuftsAt({ { 20, 240 }, { 230, 260 }, { 420, 244 }, { 460, 256 } }, RP("#c8f090", "#78b860", "#3e8a58", "#24543e"))
end

---------------------------------------------------------------- drum circle market
P["haven-drum-circle-market"] = function()
  GX.bands(c, 0, 185, { "#140c30", "#201448", "#301e5c", "#46286c", "#6a3a7c", "#964c80" }, 5, .12)
  stars(80, 100, 6); moon(80, 50, 16)
  ground(176, RP("#c88858", "#8a5238", "#5a3040", "#34202e"), 6, { top = .8, fall = .55, tex = .3, sc = 8 })
  shadow(260, 238, 190, 12, "#3c2232")
  -- huts
  local function hut(x, y, w, h)
    box(x - w + 6, y, x + w - 6, y + h, DWOOD, { R = 10, tex = .5 }); window(x - 6, y + 8, x + 6, y + h - 6)
    roof(x - w, x + w, y - 36, y + 2, THATCH, x, true); glowAt(x, y + 12, 28, "#ffa040", .2)
  end
  hut(70, 130, 44, 44); hut(400, 130, 44, 44)
  -- string lights
  for i = 0, 40 do local t = i / 40; local x = floor(30 + 420 * t); local y = 96 + floor(34 * 4 * t * (1 - t)) - floor(10 * sin(t * pi * 2)); c:px(x, y, INK); if i % 3 == 0 then lantern(x, y + 4, 2) end end
  -- bonfire centre
  fire(240, 220, 2)
  -- drums in a ring
  local function drum(x, y, w, h, R, skin)
    shadow(x, y + h, w + 4, 4, "#3c2232")
    local b = mk(); for yy = 0, h do local hw = floor(w - 3 * sin(yy / h * pi) * -1 - 2 + 2 * (yy / h)); for xx = -hw, hw do b:set(x + xx, y + yy) end end
    lit(GX.rough(b, x, 1), R, { R = 10, tex = .45, sc = 2, seed = x, fn = function(xx, yy) return ((xx - x) // 5 % 2) * .08 - .04 end })
    for k = 0, 2 do ink(x - w + 2, y + 4 + k * floor(h / 3), x + w - 2, y + 4 + k * floor(h / 3), R.deep) end
    blob(x, y, w, 5, skin, x + 1, { R = 4, tex = .2 })
    for k = -w + 3, w - 3, 5 do c:px(x + k, y - 3, R.deep) end
  end
  local SK = RP("#fff0d0", "#f0d0a0", "#c89c78", "#8a5a60")
  drum(130, 214, 20, 28, RP("#ff9a70", "#d84a4a", "#983a58", "#582444"), SK); drum(350, 214, 20, 28, RP("#78d8c0", "#38a898", "#2a6a78", "#1c3c58"), SK)
  drum(176, 244, 16, 20, RP("#ffd878", "#e8a040", "#a8684a", "#603a48"), SK); drum(304, 244, 16, 20, RP("#e8a0f0", "#b870d0", "#7a48a0", "#442c70"), SK)
  -- creature drummers: frogs
  local FR = RP("#c8f080", "#68c050", "#3a8a54", "#1e4c48")
  for _, x in ipairs{ 100, 380 } do
    blob(x, 240, 12, 10, FR, x, { R = 8 }); blob(x - 5, 228, 5, 5, CREAM, x + 1, { R = 3 }); blob(x + 5, 228, 5, 5, CREAM, x + 2, { R = 3 }); ink(x - 5, 228, x - 5, 229); ink(x + 5, 228, x + 5, 229); ink(x - 5, 244, x + 5, 244)
    ink(x - 14, 232, x - 10, 236, FR.base); ink(x + 10, 232, x + 14, 236, FR.base)
  end
  note(180, 160); note(300, 150); note(110, 190); note(370, 180)
  -- baobab-ish silhouette tree behind
  ink(240, 150, 240, 172, "#34202e")
end

---------------------------------------------------------------- floating flower market
local function water(y0, cols)
  GX.bands(c, y0, 269, cols, 5, .16)
  for i = 0, 90 do local x, y = floor(H(i, 7, 1) * 470), y0 + 4 + floor(H(i, 8, 1) * (269 - y0)); c:fillMask(c:rect(x, y, x + 3 + i % 5, y), i % 3 == 0 and "#c8f0f0" or cols[2]) end
end
local function boat(cx, cy, w, R, seed)
  local m = mk(); for x = cx - w, cx + w do local u = (x - cx) / w; for y = cy - floor(2 * u * u * 4), cy + 9 - floor(3 * u * u) do m:set(x, y) end end
  lit(GX.rough(m, seed, 1), R, { R = 8, tex = .4, sc = 2, seed = seed, fn = function(x, y) return ((y - cy) // 4 % 2) * .08 end })
  ink(cx - w + 4, cy + 6, cx + w - 4, cy + 6, R.deep)
end
P["haven-floating-flower-market"] = function()
  GX.bands(c, 0, 120, { "#8ac8f0", "#a8d8f4", "#c8e4f4", "#f0e8e0", "#ffe8c8" }, 3, .1)
  local mt = mk(); for x = 0, 479 do local y = 100 - floor(46 * (sin(x / 70 + 1) * .5 + .5) ^ 1.4) + floor(3 * sin(x / 8)); for yy = y, 122 do mt:set(x, yy) end end
  lit(mt, RP("#d0e0f8", "#7ca0d0", "#4c70a8", "#2c4078"), { R = 30, tex = .3, sc = 4, seed = 5, rimlight = false, ink = false })
  local hl = mk(); for x = 0, 479 do for y = 118 + floor(3 * sin(x / 20)), 130 do hl:set(x, y) end end
  lit(hl, GRN, { R = 6, tex = .4, rimlight = false, ink = false })
  water(128, { "#58c8d8", "#48b4cc", "#3aa0c0", "#3088b0", "#2a74a0", "#246090" })
  -- stilt houses on shore
  for i, x in ipairs{ 90, 240, 390 } do
    ink(x - 28, 150, x - 26, 166); ink(x + 26, 150, x + 28, 166)
    box(x - 32, 120, x + 32, 156, i == 2 and RP("#ffe0a8", "#e8a868", "#a8684c", "#6a3a48") or WOOD, { R = 16, tex = .4 })
    window(x - 20, 130, x - 8, 146); window(x + 8, 130, x + 20, 146)
    local rf = roof(x - 42, x + 42, 92, 124, RP("#ff9a88", "#d8485c", "#982c5c", "#581c50"), x, false)
    lantern(x, 160, 4)
  end
  -- flower boats
  local FC = { "#ff7a98", "#ffd060", "#f0a0f0", "#ff9a50", "#fff0c0" }
  local function fboat(cx, cy, w, R, seed)
    boat(cx, cy, w, R, seed)
    for k = 0, floor(w / 5) do local fx = cx - w + 6 + k * 10; blob(fx, cy - 8 - (k % 2) * 3, 7, 6, GRN2, seed + k, { R = 4 }); for j = 0, 3 do local px, py = fx - 4 + j * 3, cy - 12 - (k % 2) * 3 + (j % 2) * 3; blob(px, py, 3, 3, RP("#ffffff", FC[(k + j) % 5 + 1], "#b8608c", "#6a3468"), seed + j * 7 + k, { R = 2, tex = 0 }) end end
  end
  fboat(110, 200, 64, RP("#78d8c0", "#38a898", "#2a6a78", "#1c3c58"), 3)
  fboat(350, 214, 70, WOOD, 4)
  fboat(236, 176, 40, RP("#ffd878", "#e8a040", "#a8684a", "#603a48"), 5)
  -- gondola/pole creature: duck family
  local DK = RP("#fffbe0", "#ffe890", "#e0a860", "#9a6a50")
  for i = 0, 3 do local x, y = 190 + i * 14, 246 + (i % 2) * 3; blob(x, y, i == 0 and 9 or 6, i == 0 and 7 or 5, DK, i, { R = 5 }); if i == 0 then blob(x + 6, y - 7, 5, 5, DK, 9, { R = 3 }); ink(x + 10, y - 7, x + 13, y - 6, "#f08a38"); c:px(x + 7, y - 8, INK) end end
  lantern(430, 170, 4); ink(430, 150, 430, 166)
  note(300, 150)
  for i = 0, 14 do local x, y = floor(H(i, 3, 8) * 470), 130 + floor(H(i, 4, 8) * 130); c:px(x, y, FC[i % 5 + 1]) end
end

---------------------------------------------------------------- floating market (thai style)
P["haven-floating-market"] = function()
  GX.bands(c, 0, 110, { "#78c0e8", "#98d4f0", "#b8e4f4", "#e8f4e8", "#fff0c8" }, 2, .1)
  for i, x in ipairs{ 40, 380 } do blob(x, 100, 70, 10, GRN2, i, { R = 6, tex = .4, rimlight = false }) end
  water(112, { "#ffe090", "#a8d8b8", "#58b8c0", "#3a9cb4", "#2e84a4", "#246c92" })
  palm(30, 148, 54, 60, 3, 1); palm(450, 152, 420, 52, 6, -1)
  -- house on stilts
  for x = 130, 330, 24 do ink(x, 130, x + 2, 168) end
  box(120, 90, 340, 134, RP("#c8946c", "#8a5a48", "#5a3a44", "#34223c"), { R = 30, tex = .5 })
  for i = 0, 3 do window(140 + i * 46, 100, 166 + i * 46, 124); end
  roof(100, 360, 56, 92, RP("#ffa070", "#d85c48", "#983a50", "#582444"), 4, false)
  box(110, 134, 350, 142, WOOD, { R = 4 })
  lantern(230, 100, 4)
  -- big striped awning vendor boat
  boat(250, 226, 104, RP("#ffd878", "#e8a040", "#a8684a", "#603a48"), 3)
  for i = 0, 8 do local x0 = 170 + i * 18; poly({ { x0, 156 }, { x0 + 18, 156 }, { x0 + 19, 178 }, { x0 - 1, 178 } }, i % 2 == 0 and RED or CREAM, { R = 5, tex = .1 }) end
  ink(168, 176, 168, 220); ink(332, 176, 332, 220)
  local FR = { "#ff9a50", "#f0586c", "#a0e060", "#ffd060" }
  for k = 0, 8 do blob(190 + k * 15, 212 - (k % 2) * 4, 8, 7, RP("#ffffff", FR[k % 4 + 1], "#b8504c", "#6a2c48"), k, { R = 4, tex = .1 }) end
  blob(250, 196, 14, 12, RP("#ffe0a8", "#f0a040", "#b86a40", "#6a3a40"), 2, { R = 8 })
  -- small boats
  boat(70, 232, 50, RP("#78d8c0", "#38a898", "#2a6a78", "#1c3c58"), 5); for k = 0, 3 do blob(46 + k * 12, 222, 6, 5, RP("#ffffff", FR[k + 1], "#b8504c", "#6a2c48"), k + 9, { R = 3 }) end
  boat(420, 238, 52, WOOD, 7); for k = 0, 3 do blob(396 + k * 14, 228, 6, 6, RP("#ffffff", FR[(k + 2) % 4 + 1], "#b8504c", "#6a2c48"), k + 4, { R = 3 }) end
  -- cat/otter creature on a roof (quirk): cat with hat
  local CT = RP("#ffd0a0", "#e89060", "#a85a50", "#5a3040")
  blob(70, 220, 12, 8, CT, 2, { R = 6 }); blob(82, 213, 6, 5, CT, 3, { R = 3 }); c:px(84, 212, INK); poly({ { 79, 209 }, { 81, 203 }, { 84, 208 } }, CT, { R = 3 })
  note(300, 130)
end

---------------------------------------------------------------- gaucho gnome ranch
P["haven-gaucho-gnome-ranch"] = function()
  GX.bands(c, 0, 170, { "#6ab4ec", "#88c8f0", "#a8d8f4", "#d0e8f0", "#f8f0d8", "#ffe8b8" }, 3, .1)
  for i, p in ipairs{ { 90, 40 }, { 300, 28 }, { 410, 60 } } do blob(p[1], p[2], 30, 6, CREAM, i, { R = 4, tex = .3, ink = false, rimlight = false }) end
  local hl = mk(); for x = 0, 479 do for y = 140 + floor(4 * sin(x / 40)), 160 do hl:set(x, y) end end
  lit(hl, RP("#c8e090", "#90b860", "#5a8a54", "#34543e"), { R = 6, tex = .3, rimlight = false, ink = false })
  ground(160, RP("#e8e078", "#b8b850", "#7a8a48", "#4a5a3c"), 7, { top = .8, fall = .5, tex = .35, sc = 9 })
  -- ranch house
  shadow(130, 206, 100, 6, "#6a7040")
  box(50, 128, 210, 200, CREAM, { R = 40, tex = .2, rimlight = false })
  for x = 50, 210, 8 do c:px(x, 199, "#e0b0a0") end
  window(66, 144, 92, 172); window(168, 144, 194, 172); ink(65, 172, 93, 176, "#b86e44"); ink(167, 172, 195, 176, "#b86e44")
  local dm = c:rect(110, 150, 150, 200); c:rim(dm, INK); box(110, 150, 150, 200, RP("#e8a060", "#b8643c", "#7a3c44", "#46243a"), { R = 20, tex = .4 }); window(118, 158, 142, 176)
  local tile = RP("#ffa878", "#e0603c", "#a03c48", "#5e2040")
  local rf = mk(); for y = 96, 132 do local t = (y - 96) / 36; local hw = floor(70 + 24 * t); for x = 130 - hw, 130 + hw do rf:set(x, y) end end
  lit(rf, tile, { R = 20, tex = .3, sc = 3, seed = 4, fn = function(x, y) return ((x + (y // 5) * 3) % 6 == 0) and -.12 or ((y - 96) % 5 == 0 and -.1 or 0) end })
  box(176, 82, 188, 110, STONE, { R = 4 }); for k = 0, 2 do swirl(182 + k, 76 - k * 5) end
  lantern(100, 138, 4); lantern(160, 138, 4)
  -- windmill
  local wm = c:poly{ { 396, 100 }, { 420, 100 }, { 428, 196 }, { 388, 196 } }; lit(wm, RP("#e8ecf8", "#a8b0d0", "#6c78a0", "#3c4470"), { R = 20, tex = .3, sc = 4, seed = 5 })
  poly({ { 400, 80 }, { 416, 80 }, { 420, 100 }, { 396, 100 } }, RP("#a8b0d0", "#6c78a0", "#4a5488", "#2a3060"), { R = 4 })
  for k = 0, 3 do local a = k * pi / 2 + .5; local ex, ey = 408 + floor(cos(a) * 38), 88 + floor(sin(a) * 38); for t = 0, 38 do local x, y = 408 + floor(cos(a) * t), 88 + floor(sin(a) * t); c:fillMask(c:rect(x, y, x + 1, y + 1), t > 12 and "#ffe090" or INK) end end
  blob(408, 88, 4, 4, DWOOD, 3, { R = 3 }); window(402, 140, 414, 160)
  -- fence
  
  for x = 20, 470, 30 do box(x, 188, x + 4, 224, DWOOD, { R = 4, tex = .3 }) end
  box(16, 198, 476, 202, WOOD, { R = 3 }); box(16, 212, 476, 216, WOOD, { R = 3 })
  -- horse and cow
  local HC = RP("#d89060", "#a85c3c", "#743a40", "#42223a")
  blob(300, 214, 24, 12, HC, 3, { R = 10 }); for _, lx in ipairs{ 282, 290, 310, 318 } do box(lx, 220, lx + 4, 246, HC, { R = 3 }) end
  blob(326, 192, 8, 12, HC, 4, { R = 6 }); blob(332, 184, 10, 6, HC, 5, { R = 4 }); poly({ { 324, 176 }, { 326, 168 }, { 330, 176 } }, HC, { R = 3 }); c:px(334, 182, INK)
  for k = 0, 8 do c:px(278 - k // 2, 204 + k, "#2c1c2c"); c:px(277 - k // 2, 204 + k, "#42223a") end
  poly({ { 320, 176 }, { 328, 174 }, { 322, 202 }, { 316, 202 } }, RP("#5a3040", "#34202e", "#241a28", "#180f1c"), { R = 3 })
  local CW = RP("#ffffff", "#f0ecf0", "#b8a8c0", "#706088")
  blob(410, 238, 22, 10, CW, 8, { R = 8 }); blob(434, 232, 8, 7, CW, 9, { R = 4 }); blob(404, 236, 8, 5, RP("#8a6a68", "#5a4048", "#3a2838", "#221a2a"), 2, { R = 3 }); c:px(437, 230, INK)
  for _, lx in ipairs{ 394, 402, 418, 426 } do box(lx, 244, lx + 3, 258, CW, { R = 3 }) end
  -- asado fire (quirk)
  fire(250, 262, 1); ink(236, 244, 236, 262); ink(264, 244, 264, 262); ink(236, 248, 264, 248, "#8a5a60")
  for k = 0, 3 do blob(242 + k * 7, 245, 3, 2, RP("#ff9a70", "#d84a4a", "#983a58", "#582444"), k, { R = 2, tex = 0 }) end
  tuftsAt({ { 30, 250 }, { 100, 262 }, { 180, 252 }, { 460, 260 } }, RP("#d8f088", "#88b858", "#4e8a50", "#2e5a40"))
end

---------------------------------------------------------------- kava circle
P["haven-kava-circle"] = function()
  GX.bands(c, 0, 180, { "#1a1048", "#281a5c", "#3c2a70", "#5a3a80", "#8a4e88", "#c06888", "#e88a78" }, 4, .12)
  stars(60, 90, 9); moon(400, 50, 14)
  local sea = mk(); for x = 0, 479 do for y = 140, 170 do sea:set(x, y) end end
  GX.bands(c, 140, 180, { "#e88a78", "#a85a88", "#6a4a90", "#3c3a80", "#2c3a78" }, 5, .2)
  for i = 0, 40 do c:fillMask(c:rect(floor(H(i, 1, 4) * 470), 142 + floor(H(i, 2, 4) * 26), floor(H(i, 1, 4) * 470) + 4, 142 + floor(H(i, 2, 4) * 26)), i % 3 == 0 and "#ffd8a0" or "#5a5aa0") end
  ground(172, RP("#f2c890", "#c8946c", "#8a5a60", "#4a3048"), 5)
  -- open fale hut
  shadow(240, 214, 160, 6, "#6a4458")
  for _, x in ipairs{ 130, 190, 290, 350 } do box(x - 4, 128, x + 4, 206, WOOD, { R = 6, tex = .4 }) end
  box(130, 168, 350, 206, RP("#3c2238", "#4a2840", "#341c34", "#241428"), { R = 30, tex = .2, rimlight = false })
  glowAt(240, 190, 80, "#ffa040", .25)
  for k = 0, 8 do ink(130 + k * 26, 176, 130 + k * 26 + 12, 176, "#f0a040") end
  local rf = mk(); for y = 84, 136 do local t = (y - 84) / 52; local hw = floor(60 + 80 * t ^ .8); for x = 240 - hw, 240 + hw do rf:set(x, y) end end
  for x = 80, 400 do for k = 0, 3 do if H(x // 3, k, 8) < .55 then rf:set(x, 136 + k) end end end
  lit(GX.rough(rf, 9, 1), THATCH, { R = 30, tex = .55, sc = 3, seed = 21, wrap = .4, fn = function(x, y) return (H(x // 2, y // 5, 3) - .5) * .22 - ((y - 84) % 6 == 0 and .12 or 0) end })
  lantern(200, 146, 4); lantern(280, 146, 4)
  -- kava bowl in the middle (quirk) and circle mats
  local function bowl(x, y) local m = mk(); E(m, x, y, 30, 9); lit(GX.rough(m, 3, 1), DWOOD, { R = 9, tex = .4 }); local i = mk(); E(i, x, y - 1, 24, 6); lit(i, RP("#d8c090", "#a8905c", "#6e5a48", "#3c3040"), { R = 5, tex = .3, ink = false, rimlight = false }) end
  local mt = mk(); E(mt, 240, 236, 150, 22); lit(GX.rough(mt, 4, 1), RP("#ffe090", "#e0a058", "#a8684c", "#603a48"), { R = 14, tex = .5, sc = 2, seed = 3, fn = function(x, y) return ((x // 6 + y // 6) % 2) * .1 - .05 end })
  bowl(240, 232); for k = 0, 2 do swirl(236 + k * 4, 226 - k) end
  local COCO = RP("#d8985c", "#8a5438", "#5e3638", "#38222e")
  for _, p in ipairs{ { 150, 234 }, { 330, 234 }, { 190, 250 }, { 290, 250 } } do local m = mk(); E(m, p[1], p[2], 8, 6); m:cut(c:rect(p[1] - 10, p[2] - 8, p[1] + 10, p[2] - 3)); lit(GX.rough(m, p[1], 1), COCO, { R = 5 }); ink(p[1] - 6, p[2] - 4, p[1] + 6, p[2] - 3); ink(p[1] - 5, p[2] - 4, p[1] + 5, p[2] - 4, "#d8c090") end
  -- creature guests: turtles
  local TU = RP("#c8e478", "#6cb850", "#3a8050", "#1e4a48")
  for _, x in ipairs{ 100, 380 } do
    blob(x, 240, 18, 12, GRN2, x, { R = 10, tex = .3 }); blob(x + 18, 236, 8, 7, TU, x, { R = 5 }); c:px(x + 21, 234, INK); ink(x - 6, 232, x + 6, 232, "#e8c878")
    for k = 0, 2 do swirl(x - 6 + k * 6, 236) end
  end
  -- palms + tiki torches
  palm(36, 250, 54, 70, 3, 1); palm(450, 250, 426, 66, 6, -1)
  for _, x in ipairs{ 70, 420 } do ink(x, 200, x + 1, 250, "#4a2840"); fire(x, 200, 1) end
  note(220, 110); note(262, 100)
  tuftsAt({ { 110, 262 }, { 250, 264 }, { 400, 262 } }, RP("#c4d868", "#78a848", "#3e784a", "#245040"))
end

---------------------------------------------------------------- driver
local names = {}
for k in pairs(P) do names[#names + 1] = k end; table.sort(names)
for _, n in ipairs(names) do
  if NAME == "all" or NAME == n then
    c = HP.canvas{ w = 480, h = 270, scale = 1, name = n }
    P[n]()
    c:hem(2); c:hem(267)
    c:save{ aseprite = d .. "/out/" .. n .. ".aseprite", png = d .. "/out/" .. n .. ".png", scale = 1 }
  end
end
