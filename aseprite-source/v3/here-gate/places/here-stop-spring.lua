-- here-stop-spring.lua : Gate-view "Spring" rest stop (Hearth Pop v3, hero scale, 480x270 native).
-- Dawn spring stop: stone-ringed steaming pool + carved fountain, bathhouse, huts, notice/stamp post,
-- fire+bench gathering, rock-arch wild trail. Quirks: towel on fountain, teapot warming on a pool rock,
-- egg basket dipped on a stick, slippers at bathhouse door, boot planter by hut door.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local LIB = DIR .. "/../../lib/"
local HP = dofile(LIB .. "hp.lua")
local OUT = app.params.out or (DIR .. "/")
local NAME = "here-stop-spring"
local floor, sin, cos, max, min, abs, sqrt = math.floor, math.sin, math.cos, math.max, math.min, math.abs, math.sqrt
local W, H = 480, 270
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }

local function rgb(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
local function mix(a, b, t)
  local r1,g1,b1 = rgb(a) local r2,g2,b2 = rgb(b)
  return string.format("#%02x%02x%02x", floor(r1+(r2-r1)*t+.5), floor(g1+(g2-g1)*t+.5), floor(b1+(b2-b1)*t+.5))
end
local function hsh(x, y, s)
  local n = (x * 374761393 + y * 668265263 + (s or 0) * 2246822519) & 0xffffffff
  n = ((n ~ (n >> 13)) * 1274126177) & 0xffffffff
  n = n ~ (n >> 16)
  return (n & 0xffff) / 65535
end
local DEEPV, VIO, WARM = "#2a1f3a", "#3b2f5e", "#fff2c8"
local function ramp(b) return { mix(b, DEEPV, .55), mix(b, VIO, .3), b, mix(b, WARM, .28), mix(b, WARM, .55) } end
local R = function(...) return c:rect(...) end
local Pm = function(p) return c:poly(p) end
local function fill(m, col) c:fillMask(m, col) end
local function tint(m, col, amt)
  m:each(function(x, y) local g = c:get(x, y) if g then c:put(x, y, mix(g, col, amt)) end end)
end
-- shaded solid: tones from ramp, texture delta, top-left lit edge, lower-right shade side, deep 1px edge
local function solid(m, T, tex, o)
  o = o or {}
  local x0, y0, x1, y1 = m:bbox()
  if not x0 then return end
  local wdt, hgt = max(1, x1 - x0), max(1, y1 - y0)
  local sf = o.side or .72
  m:each(function(x, y)
    local i = 3
    if tex then i = i + (tex(x, y) or 0) end
    if not m:has(x - 1, y) or not m:has(x, y - 1) then i = i + 1 end
    if (x - x0) / wdt > sf then i = i - 1 end
    if (y - y0) / hgt > (o.bot or .88) then i = i - 1 end
    c:put(x, y, T[max(1, min(5, i))])
  end)
  if o.edge ~= false then c:edgeIn(m, T[1]) end
end
-- textures
local function planksV(w) return function(x, y)
  if x % w == 0 then return -1 end
  if x % w == 1 then return 1 end
  local h = hsh(floor(x / w), floor(y / 7), 3)
  if hsh(x, y, 9) > .93 then return -1 end
  return h > .75 and 1 or 0 end end
local function planksH(h) return function(x, y)
  if y % h == 0 then return -1 end
  if hsh(x, y, 4) > .92 then return -1 end
  return hsh(floor(x / 9), floor(y / h), 5) > .7 and 1 or 0 end end
local function bricks(bw, bh) return function(x, y)
  local row = floor(y / bh)
  local off = (row % 2) * floor(bw / 2)
  local xx = x + off
  if y % bh == 0 or xx % bw == 0 then return -1 end
  if y % bh == 1 or xx % bw == 1 then return 1 end
  local v = hsh(floor(xx / bw), row, 7)
  return v > .72 and 1 or (v < .2 and -1 or 0) end end
local function shingles(sw, sh) return function(x, y)
  local row = floor(y / sh)
  local xx = x + (row % 2) * floor(sw / 2)
  if y % sh == sh - 1 then return -1 end
  if xx % sw == 0 then return -1 end
  if y % sh == 0 then return 1 end
  return hsh(floor(xx / sw), row, 11) > .7 and 1 or 0 end end
local function thatch(x, y)
  local v = hsh(x, floor(y / 3), 13)
  if v < .25 then return -1 elseif v > .82 then return 1 end return 0 end
local function speck(x, y)
  local v = hsh(x, y, 21)
  if v < .1 then return -1 elseif v > .9 then return 1 end return 0 end
local function window(x0, y0, x1, y1, frameHex)
  fill(R(x0 - 1, y0 - 1, x1 + 1, y1 + 1), frameHex)
  local mx = floor((x0 + x1) / 2)
  for y = y0, y1 do for x = x0, x1 do
    local t = (y - y0) / max(1, y1 - y0)
    local col = t < .3 and "#fff0b0" or (t < .75 and "#ffd06e" or "#f0a04e")
    c:put(x, y, col)
  end end
  for y = y0, y1 do c:put(mx, y, frameHex) end
  for x = x0, x1 do c:put(x, floor((y0 + y1) / 2), frameHex) end
end
local function gshadow(cx, cy, rx, ry, amt) tint(c:ellipse(cx, cy, rx, ry), VIO, amt or .32) end
local function glow(cx, cy, r, amt)
  local m = HP.mask()
  for y = cy - r, cy + r do for x = cx - 2 * r, cx + 2 * r do
    local d = abs(x - cx) / 2 + abs(y - cy)
    if d <= r and x >= 0 and y >= 0 and x < W and y < H then m:set(x, y) end
  end end
  m:each(function(x, y)
    local d = (abs(x - cx) / 2 + abs(y - cy)) / r
    local a = d < .5 and amt or amt * .5
    local g = c:get(x, y) if g then c:put(x, y, mix(g, "#ffd890", a)) end
  end)
end
local function fern(x0, y0, ang, len, droop, dark, lite, scale)
  scale = scale or .3
  local px, py
  for i = 0, len do
    local t = i / len
    local x = x0 + cos(ang) * i
    local y = y0 + sin(ang) * i + droop * t * t * len
    local nx, ny = -sin(ang), cos(ang)
    if i % 2 == 0 and i > 1 then
      local L = floor((1 - t) * len * scale + 1.5)
      for s = -1, 1, 2 do
        for k = 1, L do
          local lx = floor(x + nx * k * s + cos(ang) * k * .5 + .5)
          local ly = floor(y + ny * k * s + sin(ang) * k * .5 + droop * .2 * k + .5)
          c:put(lx, ly, s < 0 and lite or dark)
        end
      end
    end
    c:put(floor(x + .5), floor(y + .5), dark)
    px, py = x, y
  end
end

---------------------------------------------------------------- sky (dawn)
c:stripes(0, 111, { "#6a74b0", "#7f84bc", "#988fc4", "#b598c4", "#d4a4bc", "#eab8b4", "#f6cfb0", "#f9e0bc" },
  { 3, 3, 3, 3, 3, 3, 2, 2 })
c:cloud(48, 46, 50, "#fbe6dc", "#d8b0c4")
c:cloud(286, 34, 40, "#fbe6dc", "#d8b0c4")
c:cloud(380, 58, 34, "#fbe6dc", "#d8b0c4")
c:cloud(150, 30, 26, "#f8dcd8", "#c8a4c4")
-- far mountains
local f1 = function(x) return 74 + 9 * sin(x / 37) + 6 * sin(x / 13 + 1) + 4 * sin(x / 7.3) end
c:terrain(f1, "#a198c6", 111)
for x = 0, W - 1 do
  local y = floor(f1(x) + .5)
  if f1(x - 1) > f1(x) then c:put(x, y, "#c6bcdc") c:put(x, y + 1, "#b8aed6") end
end
local f2 = function(x) return 90 + 7 * sin(x / 23 + 2) + 3 * sin(x / 9) end
c:terrain(f2, "#8692ba", 111)
for x = 0, W - 1 do if f2(x - 1) > f2(x) then c:put(x, floor(f2(x) + .5), "#a2acd0") end end
-- forest hills: conifer saw-tooth
local f3 = function(x) return 101 + 4 * sin(x / 31) - abs(((x % 9) - 4.5)) * -1 - 5 end
f3 = function(x) local k = x % 9 return 98 + 3 * sin(x / 31) + abs(k - 4) * 1.6 - 3 end
local hm = c:terrain(f3, "#5f8a7e", 111)
hm:each(function(x, y) if hsh(x, y, 31) > .9 then c:put(x, y, "#557e74") end end)
for x = 0, W - 1 do local y = floor(f3(x) + .5) if x % 9 < 4 then c:put(x, y, "#78a492") end end
-- mist
for i = 0, 9 do c:cloud(i * 52 - 10, 112, 40 + (i % 3) * 8, "#e0d6e6", "#d0c6dc") end

---------------------------------------------------------------- ground
local G0, G1 = "#a2bc7e", "#6c9848"
for y = 112, H - 1 do
  local t = (y - 112) / (H - 113)
  local base = mix(G0, G1, t ^ .8)
  local dk, lt = mix(base, VIO, .25), mix(base, WARM, .25)
  for x = 0, W - 1 do
    local v = hsh(x, y, 41)
    local col = base
    if v < .05 + t * .05 then col = dk elseif v > .96 then col = lt end
    c:put(x, y, col)
  end
end
-- grass tufts near
for i = 0, 140 do
  local x, y = floor(hsh(i, 1, 51) * W), 150 + floor(hsh(i, 2, 51) * 118)
  local base = c:get(x, y)
  if base then
    local dk = mix(base, VIO, .35)
    c:put(x, y, dk) c:put(x - 1, y, dk) c:put(x + 1, y, dk) c:put(x - 1, y - 1, dk) c:put(x + 1, y - 2, dk) c:put(x, y - 2, mix(base, WARM, .3))
  end
end

---------------------------------------------------------------- dirt track to the wild arch
local track = Pm{ {250,150},{300,153},{350,153},{398,149},{446,146},{446,157},{398,159},{350,163},{300,163},{250,159} }
solid(track, ramp("#bc9c72"), function(x, y) local v = hsh(x, y, 61) return v < .1 and -1 or (v > .93 and 1 or 0) end, { edge = false, side = 2, bot = 2 })
c:rim(track, mix("#6c9848", VIO, .3))

---------------------------------------------------------------- duckboard path
local function hw(y) return 4 + 81 * (y - 112) / 157 end
local pathM = HP.mask()
for y = 112, H - 1 do local h = hw(y) for x = floor(240 - h + .5), floor(240 + h + .5) do pathM:set(x, y) end end
local WOOD = ramp("#b08a62")
gshadow(240, 268, 92, 6, .25)
for y = 112, H - 1 do
  local d = y - 104
  local idx, idx2 = floor(3400 / d), floor(3400 / (d + 1))
  local spacing = d * d / 3400
  local h = hw(y)
  local xl, xr = floor(240 - h + .5), floor(240 + h + .5)
  local seam = spacing >= 2 and idx ~= idx2
  local top = spacing >= 2 and floor(3400 / (d - 1)) ~= idx
  local pv = hsh(idx, 0, 71)
  for x = xl, xr do
    local i = 3 + (pv > .65 and 1 or (pv < .3 and -1 or 0))
    if seam then i = 1 elseif top then i = i + 1 end
    local v = hsh(x, y, 73)
    if not seam and v > .95 then i = i - 1 end
    -- grain streaks
    if not seam and spacing >= 3 and hsh(floor(x / 6), idx, 75) > .8 and y % 2 == 0 then i = i - 1 end
    if x - xl < 2 or xr - x < 2 then i = 1 end
    -- nails
    if spacing >= 5 and not seam and floor(3400 / (d + 2)) ~= idx and (abs(x - floor(240 - h * .8)) <= 0 or abs(x - floor(240 + h * .8)) <= 0) then i = 1 end
    c:put(x, y, WOOD[max(1, min(5, i))])
  end
  -- moss on rails
  if hsh(y, 1, 77) > .7 then c:put(xl + 1, y, "#7aa04e") end
  if hsh(y, 2, 77) > .75 then c:put(xr - 1, y, "#6a9244") end
end

---------------------------------------------------------------- far tier: bathhouse (decor, behind left of path)
gshadow(192, 114, 36, 4)
local BH = ramp("#8a5a44")
local bw = R(164, 88, 220, 113)
solid(bw, BH, planksV(5))
local bdoor = R(184, 94, 200, 113)
fill(bdoor, "#3a2a3c")
-- noren curtain (indigo cloth, three flaps)
for k = 0, 2 do
  local nm = R(184 + k * 6, 94, 188 + k * 6, 103)
  solid(nm, ramp("#4f5fa8"), function(x, y) return (y % 3 == 0) and 1 or 0 end, { side = .6 })
end
window(168, 93, 178, 101, BH[1])
window(206, 93, 216, 101, BH[1])
local broof = Pm{ {154,90},{164,82},{192,62},{220,82},{230,90},{224,90},{220,88},{164,88},{160,90} }
solid(broof, ramp("#b0524a"), shingles(6, 4), { side = .55 })
-- cupola + steam
local cup = R(186, 54, 198, 63)
solid(cup, ramp("#8a5a44"), planksV(4))
fill(Pm{ {183,55},{192,48},{201,55} }, "#7e3c38") c:edgeIn(Pm{ {183,55},{192,48},{201,55} }, "#4e2430")
c:cloud(176, 46, 22, "#f6eef4", "#d6c6dc")
c:cloud(190, 34, 18, "#f6eef4", "#d6c6dc")
c:cloud(182, 22, 14, "#f6eef4", "#d6c6dc")
-- step + slippers (quirk)
fill(R(180, 113, 204, 115), "#8c8a9a") c:edgeIn(R(180, 113, 204, 115), "#5c5a70")
for _, sx in ipairs({ 185, 193 }) do
  local s = R(sx, 116, sx + 5, 118)
  fill(s, "#e87a8c") c:put(sx, 116, "#f8b0bc") c:put(sx + 5, 118, "#a04a60")
  c:rim(s, "#7a3448")
end

---------------------------------------------------------------- homes: two huts (box 18,64,152,142)
gshadow(52, 139, 34, 4) gshadow(122, 137, 32, 4)
-- hut A: timber walls + mossy thatch
local aw = R(26, 104, 80, 138)
solid(aw, ramp("#c08c5a"), planksH(5))
window(31, 112, 41, 122, "#5e3a2a")
fill(R(29, 111, 30, 123), "#3f7a5a") fill(R(42, 111, 43, 123), "#3f7a5a")
local ad = R(50, 116, 62, 138)
solid(ad, ramp("#4f8a5c"), planksV(4))
c:put(59, 127, "#f0c860") c:put(59, 128, "#a07a30")
local ar = Pm{ {16,108},{52,68},{88,108},{84,110},{20,110} }
solid(ar, ramp("#8ea04e"), thatch, { side = .6 })
for x = 20, 84, 3 do local L = 2 + floor(hsh(x, 3, 81) * 4) for y = 110, 110 + L do c:put(x, y, "#6a7a38") end end
local ach = R(66, 74, 74, 90)
solid(ach, ramp("#9a8c90"), bricks(5, 3))
-- boot planter (quirk)
local boot = Pm{ {66,128},{72,128},{72,136},{77,136},{77,139},{66,139} }
solid(boot, ramp("#d0c040"), nil)
for _, p in ipairs({ {67,124},{70,122},{72,125} }) do fill(R(p[1], p[2], p[1] + 2, p[2] + 2), "#f06a8a") c:put(p[1] + 1, p[2] + 1, "#ffd0a0") end
fill(R(68, 126, 71, 127), "#4e8a3a")
-- hut B: cream plaster + teal shingles
local bwm = R(98, 100, 148, 136)
solid(bwm, ramp("#eadcc0"), function(x, y) return hsh(x, y, 91) > .9 and -1 or 0 end)
for _, x in ipairs({ 98, 112, 134, 148 }) do fill(R(x, 100, x + 1, 136), "#7a4e36") end
fill(R(98, 117, 148, 118), "#7a4e36")
window(102, 104, 109, 113, "#5a3a2c") window(138, 104, 145, 113, "#5a3a2c")
local bdm = R(117, 118, 129, 136)
solid(bdm, ramp("#4a6ab0"), planksV(4))
c:put(126, 127, "#f0c860")
fill(R(101, 122, 110, 125), "#8a5a3a") for x = 102, 109, 2 do c:put(x, 121, "#f0b040") c:put(x + 1, 120, "#e85a6a") end
local brf = Pm{ {90,102},{100,78},{146,78},{156,102},{152,104},{94,104} }
solid(brf, ramp("#3e9a96"), shingles(7, 4), { side = .62 })
-- homes sign: post + house plaque
fill(R(88, 114, 90, 140), "#5e3a2a")
local hs = R(81, 106, 97, 118)
solid(hs, ramp("#a8744a"), nil)
local hicon = Pm{ {84,112},{89,108},{94,112},{93,112},{93,116},{85,116},{85,112} }
fill(hicon, "#f6e8c8") fill(R(88, 113, 90, 116), "#c0603a")

---------------------------------------------------------------- stop: notice board + stamp post (box 266,80,336,150)
gshadow(303, 149, 34, 4)
local SP = ramp("#7a5038")
local p1, p2 = R(280, 96, 284, 148), R(322, 96, 326, 148)
solid(p1, SP, planksV(9)) solid(p2, SP, planksV(9))
for _, x in ipairs({ 278, 320 }) do local b = R(x, 144, x + 8, 149) solid(b, ramp("#9a96a6"), bricks(4, 3)) end
local bfr = R(275, 98, 331, 129)
solid(bfr, ramp("#9a6a44"), nil)
local cork = R(278, 101, 328, 126)
solid(cork, ramp("#d2a46c"), speck, { edge = false })
c:rim(cork, "#5a3826")
local papers = { {282,104,295,117,"#f6ecd2"}, {299,103,310,113,"#bcd8f0"}, {313,105,325,119,"#f4c0cc"}, {298,116,310,124,"#f2e08a"} }
for _, p in ipairs(papers) do
  local m = R(p[1], p[2], p[3], p[4])
  solid(m, ramp(p[5]), nil, { side = .8 })
  for y = p[2] + 3, p[4] - 2, 2 do for x = p[1] + 2, p[3] - 2 - (y % 3) do c:put(x, y, mix(p[5], VIO, .35)) end end
  c:put(floor((p[1] + p[3]) / 2), p[2] + 1, "#d83a3a")
end
local srf = Pm{ {270,100},{303,81},{336,100},{332,102},{274,102} }
solid(srf, ramp("#c05a42"), shingles(6, 3), { side = .55 })
-- stamp emblem in gable (brass plaque with stamp icon)
local pl = R(297, 88, 309, 98)
solid(pl, ramp("#e0b04a"), nil)
fill(R(301, 89, 305, 91), "#5a3a1e") fill(R(302, 92, 304, 94), "#5a3a1e") fill(R(299, 95, 307, 97), "#5a3a1e")
-- stamp box
local sbx = R(289, 131, 317, 144)
solid(sbx, ramp("#d0503e"), planksH(4))
fill(R(296, 134, 310, 135), "#4a1e24")
local stk = R(300, 124, 306, 130) solid(stk, ramp("#e0b04a"), nil)
fill(R(301, 128, 305, 130), "#7a4e20")
fill(R(285, 132, 288, 133), "#5a3826") fill(R(318, 132, 321, 133), "#5a3826")

---------------------------------------------------------------- wild trail: rock arch + signpost (box 352,76,464,158)
-- forest beyond the gap
local gap = R(396, 92, 450, 157)
for y = 92, 157 do for x = 396, 450 do
  local col = (y < 112) and "#9cc080" or "#3e6a58"
  if y >= 112 and y < 126 and hsh(x, 0, 101) > .5 then col = "#4e7a62" end
  c:put(x, y, col)
end end
for i = 0, 4 do
  local tx = 398 + i * 11
  local tm = Pm{ {tx - 6, 130}, {tx, 100 + (i % 2) * 6}, {tx + 6, 130} }
  solid(tm, ramp(i % 2 == 0 and "#3e7462" or "#4c8468"), function(x, y) return (y % 4 == 0) and -1 or 0 end, { side = .6 })
end
fill(R(396, 130, 450, 157), "#46765a")
local tr2 = Pm{ {404,157},{420,146},{440,140},{451,139},{451,146},{438,148},{424,154},{418,157} }
solid(tr2, ramp("#c8a878"), nil, { edge = false })
-- arch rock
local ROCK = ramp("#9a92a4")
local rockTex = function(x, y) local v = hsh(floor(x / 5), floor(y / 4), 111) if hsh(x, y, 113) > .92 then return -1 end return v > .7 and 1 or (v < .2 and -1 or 0) end
gshadow(388, 157, 16, 3) gshadow(458, 157, 12, 3)
local lc = Pm{ {377,157},{375,124},{379,100},{392,94},{400,102},{398,157} }
local rc = Pm{ {449,157},{447,112},{452,98},{465,98},{465,157} }
local at = Pm{ {374,106},{382,86},{402,77},{430,76},{452,80},{465,88},{465,104},{450,100},{432,93},{408,95},{398,104} }
solid(lc, ROCK, rockTex, { side = .7 }) solid(rc, ROCK, rockTex, { side = .7 }) solid(at, ROCK, rockTex, { side = .8, bot = .8 })
-- moss on top + ivy
for x = 378, 464 do
  local top
  for y = 74, 100 do if at:has(x, y) then top = y break end end
  if top then
    local L = 2 + floor(hsh(x, 5, 117) * 3)
    for y = top, top + L do c:put(x, y, y == top and "#9cc060" or "#6e9a44") end
  end
end
for _, x in ipairs({ 404, 418, 433, 444 }) do
  local L = 8 + floor(hsh(x, 6, 119) * 10)
  for y = 96, 96 + L do c:put(x + floor(sin(y / 3) + .5), y, "#5a8a3c") if y % 3 == 0 then c:put(x + 1, y, "#8ab858") end end
end
-- signpost with arrow (leaf icon)
gshadow(364, 157, 9, 2)
local sp = R(361, 114, 365, 157)
solid(sp, ramp("#7a5038"), planksV(9))
local arrow = Pm{ {352,112},{380,112},{390,119},{380,126},{352,126} }
solid(arrow, ramp("#4e9a5a"), nil, { side = .8 })
local leaf = Pm{ {359,119},{366,114},{375,115},{370,122},{361,122} }
fill(leaf, "#f2e8c8")
for x = 361, 372 do c:put(x, 119 + floor((372 - x) / 6), "#4e9a5a") end

---------------------------------------------------------------- do: steaming pool + carved fountain (box 20,144,160,220)
local poolO = Pm{ {28,178},{44,164},{80,160},{124,162},{152,174},{157,196},{140,214},{96,219},{48,216},{26,202} }
gshadow(92, 214, 66, 6, .28)
local poolI = poolO:shrink(6)
local ring = poolO:copy():cut(poolI)
local ST = ramp("#a8a2b0")
local function stoneId(x, y) local a = math.atan(y - 190, x - 92) return floor((a + 3.1416) / 0.26) end
ring:each(function(x, y)
  local id = stoneId(x, y)
  local i = 3 + (hsh(id, 0, 121) > .6 and 1 or (hsh(id, 1, 121) < .3 and -1 or 0))
  if stoneId(x - 1, y) ~= id or stoneId(x, y - 1) ~= id then i = 1
  elseif stoneId(x + 1, y) ~= id or stoneId(x, y + 1) ~= id then i = max(2, i - 1)
  elseif not ring:has(x - 1, y) or not ring:has(x, y - 1) then i = i + 1 end
  if y > 200 then i = i - 1 end
  c:put(x, y, ST[max(1, min(5, i))])
end)
c:edgeIn(poolO, ST[1]) c:edgeIn(poolI, ST[1])
for x = 30, 152 do for y = 158, 170 do if ring:has(x, y) and not ring:has(x, y - 1) and hsh(x, 7, 123) > .45 then c:put(x, y, "#86ac54") c:put(x, y + 1, "#6e9444") end end end
local WT = ramp("#4fb4bc")
poolI:each(function(x, y)
  local i = 3
  if y < 178 then i = 2 end
  if (y + floor(x / 9)) % 6 == 0 and hsh(floor(x / 5), y, 125) > .45 then i = 5
  elseif (y + floor(x / 9)) % 6 == 1 and hsh(floor(x / 5), y, 125) > .55 then i = 4 end
  if not poolI:has(x, y - 1) then i = 1 end
  c:put(x, y, WT[i])
end)
-- rock + teapot (quirk)
local rk = Pm{ {100,198},{104,190},{116,188},{122,194},{120,202},{104,203} }
solid(rk, ramp("#8c9488"), rockTex, { side = .65 })
fill(R(104, 188, 116, 190), "#7aa04e")
local tp = Pm{ {105,180},{107,176},{115,176},{117,180},{116,187},{106,187} }
solid(tp, ramp("#3e7ac0"), nil, { side = .7 })
fill(R(110, 174, 112, 175), "#2a4e88") fill(R(117, 180, 121, 181), "#3e7ac0") c:put(121, 179, "#3e7ac0")
fill(R(102, 179, 104, 184), "#2a4e88") c:put(108, 178, "#cfe6ff")
-- fountain pillar (carved, with leaf spout) + towel quirk
gshadow(44, 182, 14, 3)
local pil = R(34, 152, 54, 182)
solid(pil, ramp("#b0aabb"), bricks(7, 5), { side = .7 })
local cap = R(31, 146, 57, 152)
solid(cap, ramp("#c4bece"), nil)
fill(R(33, 144, 55, 145), "#86ac54")
local carve = Pm{ {40,160},{44,155},{48,160},{44,168} }
fill(carve, "#7a748a") c:put(43, 158, "#d8d2e0")
local spout = Pm{ {54,158},{66,155},{68,158},{56,163} }
solid(spout, ramp("#5aa070"), nil)
for t = 0, 18 do local x = 67 + floor(t * .35) local y = 159 + t c:put(x, y, "#d4f2f4") c:put(x + 1, y, "#8ed8e0") end
for _, d in ipairs({ {66,178},{72,177},{69,175},{75,179} }) do c:put(d[1], d[2], "#eaffff") end
local tw = Pm{ {33,162},{40,162},{40,176},{36,178},{33,176} }
solid(tw, ramp("#e86a60"), function(x, y) return (y % 4 < 2) and 1 or 0 end, { side = .8 })
-- steam wisps
for k = 0, 4 do
  local bx = 64 + k * 17
  for t = 0, 14 do
    local x = bx + floor(sin(t / 3 + k) * 3 + .5)
    local y = 172 - t
    local col = t < 8 and "#f4eef6" or "#e2d8ea"
    c:put(x, y, col) c:put(x + 1, y, col)
  end
end
-- cup post with drop plaque + hanging cups ; egg basket stick (quirk)
gshadow(144, 177, 8, 2)
local cpost = R(142, 150, 145, 177)
solid(cpost, ramp("#7a5038"), nil)
local dpl = R(134, 144, 153, 155)
solid(dpl, ramp("#3e86c0"), nil)
local drop = Pm{ {143,145},{147,150},{147,153},{140,153},{140,150} }
fill(drop, "#f2f6ff") c:put(141, 150, "#ffffff" == "" and "" or "#cfe6ff")
fill(R(146, 158, 158, 159), "#5e3a2a")
for k, col in ipairs({ "#e0b04a", "#c8c4d4", "#e87a6a" }) do
  local x = 146 + k * 3
  c:put(x, 160, "#5e3a2a")
  local m = R(x - 1, 161, x + 1, 165) solid(m, ramp(col), nil, { edge = false }) c:put(x + 2, 162, mix(col, VIO, .4))
end
c:put(156, 160, "#5e3a2a")
for t = 0, 28 do c:put(150 - floor(t * .9), 206 - t, "#a07a40") c:put(150 - floor(t * .9) + 1, 206 - t, "#c8a060") end
for y = 179, 188 do c:put(124, y, "#e8e0c8") end
local bk = Pm{ {118,188},{130,188},{128,195},{120,195} }
solid(bk, ramp("#c89a50"), function(x, y) return ((x + y) % 2 == 0) and -1 or 0 end)
fill(R(120, 186, 122, 187), "#fff6e0") fill(R(125, 186, 127, 187), "#fff6e0")

---------------------------------------------------------------- people: fire, log bench, table (box 328,160,462,220)
glow(395, 202, 26, .3)
gshadow(353, 210, 22, 3) gshadow(438, 198, 24, 3)
-- table + mugs + loaf
local TB = ramp("#a86a40")
for _, x in ipairs({ 421, 454 }) do solid(R(x, 182, x + 3, 198), TB, nil) end
local tt = R(416, 176, 461, 182)
solid(tt, TB, planksH(3))
for k, col in ipairs({ "#e86a60", "#3e9a96", "#e0b04a" }) do
  local x = 420 + (k - 1) * 8
  local m = R(x, 169, x + 4, 175) solid(m, ramp(col), nil) c:put(x + 5, 171, mix(col, VIO, .4)) c:put(x + 5, 172, mix(col, VIO, .4))
end
local loaf = Pm{ {445,175},{447,169},{456,168},{459,175} }
solid(loaf, ramp("#d89a4a"), nil, { side = .7 }) c:put(449, 171, "#f6d08a") c:put(453, 170, "#f6d08a")
-- log bench + end face
local lg = R(334, 199, 372, 209)
solid(lg, ramp("#7a5434"), function(x, y) return (y % 3 == 0) and -1 or (hsh(x, y, 131) > .9 and 1 or 0) end)
local le = R(332, 199, 338, 209)
fill(le, "#d8b07a") c:edgeIn(le, "#7a5434") fill(R(334, 202, 336, 206), "#c09060") c:put(335, 204, "#8a6040")
-- stump seat
local sm = R(420, 202, 432, 214)
solid(sm, ramp("#7a5434"), planksV(3))
fill(R(421, 202, 431, 204), "#d8b07a") c:edgeIn(R(420, 202, 432, 204), "#7a5434")
-- tripod + kettle
c:fillMask(c:line({ {381,207},{395,164} }, 2), "#4e3428")
c:fillMask(c:line({ {409,207},{395,164} }, 2), "#5e4030")
fill(c:line({ {395,165},{395,170} }, 1), "#3a3040")
local kt = Pm{ {389,173},{391,170},{399,170},{401,173},{401,181},{389,181} }
solid(kt, ramp("#5a5868"), nil, { side = .7 })
fill(R(402, 173, 405, 174), "#5a5868") c:put(405, 172, "#5a5868")
c:put(391, 172, "#b8b6c8")
-- fire ring + flames
local fr = Pm{ {380,196},{388,191},{402,191},{410,196},{412,201},{409,207},{402,210},{388,210},{381,207},{378,201} }
local frI = fr:shrink(3)
local FS = ramp("#9a96a6")
fr:copy():cut(frI):each(function(x, y)
  local id = floor(x / 5) + floor(y / 4) * 7
  local i = 3 + (hsh(id, 2, 133) > .6 and 1 or 0)
  if x % 5 == 0 or y > 207 then i = 2 end
  c:put(x, y, FS[i])
end)
c:edgeIn(fr, FS[1])
fill(frI, "#4a3236")
local fl1 = Pm{ {385,202},{388,190},{391,195},{394,183},{397,192},{400,186},{403,195},{406,202} }
fill(fl1, "#e8602e") c:edgeIn(fl1, "#a83a2a")
local fl2 = Pm{ {389,202},{392,194},{395,188},{398,195},{401,202} }
fill(fl2, "#ffb840")
fill(Pm{ {393,202},{395,196},{398,202} }, "#fff0a0")
-- gathering flag (mug icon)
gshadow(340, 199, 5, 2)
local pole = R(338, 161, 340, 199)
solid(pole, ramp("#7a5038"), nil)
local flag = Pm{ {341,162},{362,162},{357,169},{362,176},{341,176} }
solid(flag, ramp("#d8784a"), nil, { side = .8 })
fill(R(345, 165, 351, 172), "#f6ecd2") fill(R(352, 166, 353, 170), "#f6ecd2") c:put(352, 167, "#d8784a") c:put(352, 168, "#d8784a")

---------------------------------------------------------------- near-left: mossy rocks + ferns, and a small rock by the path
local function mrock(pts)
  local m = Pm(pts)
  local x0, y0, x1, y1 = m:bbox()
  gshadow(floor((x0 + x1) / 2), y1, floor((x1 - x0) / 2) + 2, 3)
  solid(m, ramp("#8c8a9c"), rockTex, { side = .65 })
  for x = x0, x1 do for y = y0, y0 + 6 do if m:has(x, y) and not m:has(x, y - 1) then
    for k = 0, 1 + floor(hsh(x, 9, 141) * 2) do if m:has(x, y + k) then c:put(x, y + k, k == 0 and "#9cc060" or "#6e9a44") end end
  end end end
end
mrock{ {18,262},{22,244},{36,238},{52,244},{56,262} }
mrock{ {56,266},{60,254},{70,251},{78,258},{76,266} }
mrock{ {208,134},{211,128},{220,127},{224,133},{220,137},{210,137} }
fern(26, 236, -1.9, 22, 0.25, "#3e7a3a", "#7ab456", .35)
fern(30, 238, -1.2, 26, 0.3, "#3e7a3a", "#7ab456", .35)
fern(46, 240, -0.7, 22, 0.35, "#3e7a3a", "#7ab456", .35)
fern(66, 252, -1.3, 18, 0.3, "#3e7a3a", "#88c060", .35)
fern(162, 120, -2.3, 12, 0.2, "#4e8a44", "#86b860", .35)

---------------------------------------------------------------- gate frame: log beam, stone posts, hanging ferns, lanterns, charm
local PST = ramp("#8e8aa0")
local lp = R(0, 12, 15, 269)
solid(lp, PST, bricks(8, 6), { side = .75, bot = 2 })
local rp = R(464, 12, 479, 226)
solid(rp, PST, bricks(8, 6), { side = .75, bot = 2 })
local plinth = R(460, 224, 479, 231)
solid(plinth, ramp("#a29eb2"), nil)
gshadow(470, 232, 12, 2)
for _, pm in ipairs({ lp, rp }) do
  pm:each(function(x, y) if hsh(floor(x / 3), floor(y / 3), 151) > .86 then c:put(x, y, (y % 2 == 0) and "#7aa04e" or "#5e8a40") end end)
end
local beam = R(0, 0, 479, 13)
solid(beam, ramp("#8a5e3c"), function(x, y)
  if y % 4 == 1 and hsh(floor(x / 11), y, 153) > .3 then return -1 end
  if hsh(x, y, 155) > .94 then return 1 end return 0 end, { side = 2, bot = .82 })
for x = 0, W - 1 do
  if hsh(floor(x / 4), 0, 157) > .45 then
    local L = 1 + floor(hsh(x, 1, 157) * 3)
    for y = 13, 13 + L do c:put(x, y, y == 13 and "#86ac54" or "#5e8a40") end
  end
end
fern(60, 13, 1.75, 22, -0.1, "#3e7a3a", "#7ab456", .3)
fern(132, 13, 1.35, 18, -0.1, "#3e7a3a", "#7ab456", .3)
fern(352, 13, 1.75, 20, -0.1, "#3e7a3a", "#7ab456", .3)
fern(414, 13, 1.45, 16, -0.1, "#3e7a3a", "#7ab456", .3)
local function lantern(x, y0, chain)
  for y = y0, y0 + chain do c:put(x, y, (y % 2 == 0) and "#3a3040" or "#5a5068") end
  local ly = y0 + chain
  glow(x, ly + 10, 16, .22)
  local capm = Pm{ {x - 7, ly + 4}, {x, ly}, {x + 7, ly + 4} }
  fill(capm, "#4e3a40") c:edgeIn(capm, "#2e2030")
  local body = R(x - 5, ly + 4, x + 5, ly + 17)
  fill(body, "#3e3040")
  for y = ly + 6, ly + 15 do for xx = x - 3, x + 3 do
    c:put(xx, y, (y < ly + 9) and "#fff0b0" or (y < ly + 13 and "#ffd06e" or "#f0a04e"))
  end end
  for y = ly + 6, ly + 15 do c:put(x, y, "#3e3040") end
  fill(R(x - 6, ly + 17, x + 6, ly + 18), "#4e3a40")
  c:put(x, ly + 19, "#4e3a40") c:put(x, ly + 20, "#e0b04a")
end
lantern(34, 14, 8)
lantern(446, 14, 8)
-- charm: wooden plaque with a spring drop
for y = 14, 19 do c:put(240, y, "#5a4038") end
local ch = Pm{ {232,20},{248,20},{248,30},{240,34},{232,30} }
solid(ch, ramp("#b0804e"), nil)
fill(Pm{ {240,22},{244,27},{243,30},{237,30},{236,27} }, "#4fb4bc")
c:put(238, 27, "#d4f2f4")

c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

local f = io.open(OUT .. NAME .. ".layout.json", "w")
f:write([[{"w":480,"h":270,"horizon":112,"view":"gate","spots":[
{"k":"do","name":"Steaming Spring Pool","x":90,"y":182,"box":[20,144,160,220]},
{"k":"people","name":"Fireside Gathering","x":395,"y":190,"box":[328,160,462,220]},
{"k":"stop","name":"Stamp Post","x":301,"y":115,"box":[266,80,336,150]},
{"k":"homes","name":"Spring Huts","x":85,"y":103,"box":[18,64,152,142]},
{"k":"wild","name":"Wild Trail","x":408,"y":117,"box":[352,76,464,158]}],
"stand":[{"x":240,"y":166},{"x":190,"y":196},{"x":296,"y":198},{"x":222,"y":244},{"x":110,"y":250},{"x":340,"y":250}],
"compass_clear":[380,230,480,270]}
]])
f:close()
