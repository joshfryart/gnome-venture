-- batch.lua: eight WONDER pictures, 480x270. Param: name=<picture> or all
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local V3 = d .. "/../.."
local HP = dofile(V3 .. "/lib/hp.lua")
local GX = dofile(V3 .. "/gather/gx.lua")
local floor, max, min, sin, cos, sqrt, abs, atan = math.floor, math.max, math.min, math.sin, math.cos, math.sqrt, math.abs, math.atan
local INK = "#2b1c26"
local NAME = app.params.name or "all"

local function build(name)
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = name }
local S = dofile(V3 .. "/tree-yard/common.lua").setup(c)
local TIMB, OAK, CREAM, GREEN, LEAF, SBLUE, BARN, GOLD, STONE, TEAL, VIOLET, PINK, DIRT, IRON =
  S.TIMB, S.OAK, S.CREAM, S.GREEN, S.LEAF, S.SBLUE, S.BARN, S.GOLD, S.STONE, S.TEAL, S.VIOLET, S.PINK, S.DIRT, S.IRON
local hash = S.hash
local function P(x, y, col) c:put(floor(x), floor(y), col) end
local function R4(r) return { hi = r[6], base = r[4], shade = r[3], deep = r[2] } end
local mixc, vn = GX.mix, GX.vn
local function rect(x0, y0, x1, y1) return c:rect(floor(x0), floor(y0), floor(x1), floor(y1)) end
local function ell(cx, cy, rx, ry) return c:ellipse(floor(cx), floor(cy), rx, ry) end
local function poly(t) return S.poly(t) end
local function solid(m, R, o) o = o or {}; o.R = o.R or 6; return GX.lit(c, m, R, o) end
local function inkfill(m, col) c:rim(m, INK); c:fillMask(m, col) end
local function clampi(v, a, b) return max(a, min(b, v)) end
local function sky(cols, seed, y1) GX.bands(c, 0, y1 or 269, cols, seed, .12) end
local function hills(f, ramp, ybot, seed)
  local m = c:terrain(f, nil, ybot)
  m:each(function(x, y)
    local t = (y - f(x)) / 30
    local v = .78 - t * .35 + (vn(x, y, 9, seed) - .5) * .3
    P(x, y, ramp[GX.idx(v)])
  end)
  for x = 0, 479 do P(x, floor(f(x) + .5), ramp[6]) end
end
local function ground(yfn, ramp, seed, o) GX.ground(c, yfn, R4(ramp), seed, o) end
local function brick(m, R, rh, bw, seed, lf)
  local x0, y0 = m:bbox()
  m:each(function(x, y)
    local row = floor((y - y0) / rh)
    local off = (row % 2) * floor(bw / 2)
    local col = floor((x - x0 + off) / bw)
    local hv = hash(col, row, seed)
    local t = 4 + (hv > .72 and 1 or (hv < .22 and -1 or 0))
    local px, py = (x - x0 + off) % bw, (y - y0) % rh
    if py == rh - 1 or px == 0 then t = 2 elseif py == 0 then t = t + 1 end
    if lf then t = t + lf(x, y) end
    P(x, y, R[clampi(t, 1, 6)])
  end)
end
local function glow(cx, cy, r, col, a) S.glow(cx, cy, r, col, a) end
local function stars(n, seed, y1, cols)
  for i = 1, n do
    local x, y = floor(hash(i, 1, seed) * 478) + 1, floor(hash(i, 2, seed) * y1)
    local col = cols[i % #cols + 1]
    P(x, y, col)
    if i % 5 == 0 then P(x - 1, y, col); P(x + 1, y, col); P(x, y - 1, col); P(x, y + 1, col) end
  end
end
local function sun(cx, cy, r, R)
  local m = ell(cx, cy, r, r)
  for k = 3, 1, -1 do c:fillMask(ell(cx, cy, r + k * 7, r + k * 7), mixc(R[3], "#fce4a0", 1 - k * .22)) end
  solid(m, R, { R = r, tex = .1, ink = false })
end
local function palm(x, y, h, lean)
  local pts = {}
  for i = 0, 8 do pts[#pts + 1] = { x + lean * (i / 8) ^ 2, y - h * i / 8 } end
  local tm = c:line(pts, 4)
  c:rim(tm, INK)
  tm:each(function(px, py) P(px, py, ((py + px) % 5 == 0) and TIMB[3] or ((px < x + lean * ((y - py) / h) ^ 2 + 1) and TIMB[5] or TIMB[4])) end)
  local tx, ty = x + lean, y - h
  local fm = HP.mask()
  for k = 0, 8 do
    local a = -3.2 + k * .5
    local L = 38 + (k % 2) * 8
    local fp = {}
    for t = 0, 1, .07 do fp[#fp + 1] = { tx + cos(a) * L * t, ty + sin(a) * L * t * .55 + 26 * t * t } end
    fm:add(c:line(fp, 3))
  end
  c:rim(fm, INK)
  fm:each(function(px, py) P(px, py, (hash(px, py, 4) > .6 or py < ty - 6) and GREEN[5] or GREEN[4]); if hash(px, py, 8) > .9 then P(px, py, GREEN[3]) end end)
  c:fillMask(ell(tx, ty + 3, 3, 3), TIMB[3]); P(tx - 1, ty + 2, TIMB[5])
end
local function fox(x, y, s)   -- sitting fox, (x,y) = feet centre
  local ORG = { "#4a2418", "#7a3a20", "#b05a2a", "#d87a34", "#f0a458", "#f8cc88" }
  local tail = ell(x + 10 * s, y - 5 * s, 4 * s, 8 * s)
  solid(tail, ORG, { R = 5, tex = .1 })
  c:fillMask(ell(x + 11 * s, y - 11 * s, 2 * s, 2 * s), "#f8ecd0")
  local body = ell(x, y - 9 * s, 7 * s, 9 * s):add(ell(x, y - 21 * s, 6 * s, 5 * s))
  body:add(poly{ { x - 6 * s, y - 24 * s }, { x - 5 * s, y - 32 * s }, { x - 1 * s, y - 25 * s } }):add(poly{ { x + 6 * s, y - 24 * s }, { x + 5 * s, y - 32 * s }, { x + 1 * s, y - 25 * s } })
  solid(body, ORG, { R = 6, tex = .1 })
  c:fillMask(ell(x, y - 6 * s, 3 * s, 6 * s), "#f8ecd0")
  c:fillMask(poly{ { x - 5 * s, y - 20 * s }, { x + 5 * s, y - 20 * s }, { x, y - 15 * s } }, "#f8ecd0")
  P(x - 3 * s, y - 22 * s, INK); P(x + 3 * s, y - 22 * s, INK); P(x - 3 * s, y - 23 * s, INK); P(x + 3 * s, y - 23 * s, INK); P(x, y - 17 * s, INK)
  P(x - 5 * s, y - 29 * s, INK); P(x + 5 * s, y - 29 * s, INK)
end
local function bird(x, y, body, wing, beak)   -- little round bird facing right
  local m = ell(x, y, 6, 5)
  solid(m, body, { R = 5, tex = .08 })
  c:fillMask(ell(x - 2, y + 1, 3, 2), wing[3])
  local bk = poly{ { x + 5, y - 2 }, { x + 9, y }, { x + 5, y + 1 } }
  inkfill(bk, beak)
  P(x + 2, y - 2, "#fff6dc"); P(x + 3, y - 2, INK); P(x + 3, y - 3, "#fff6dc")
  for k = 0, 3 do P(x - 7 - k, y + 1 + k // 2, wing[2]) end
end
local function note(x, y, col)   -- eighth note
  local hm = ell(x, y, 3, 2)
  c:rim(hm, INK); c:fillMask(hm, col)
  for k = 1, 11 do P(x + 3, y - k, INK); P(x + 2, y - k, col) end
  for k = 0, 4 do P(x + 4 + k // 2, y - 11 + k, INK); P(x + 3 + k // 2, y - 11 + k, col) end
end
local function sparkles(list, col) for _, p in ipairs(list) do c:sparkle(p[1], p[2]) end end

local F = {}

---------------------------------------------------------------- 1. SILK ROAD CARAVANSERAI
F["wonder-the-silk-road-caravanserai"] = function()
  local SAND = { "#5a3a3a", "#8a5a48", "#b8805a", "#d8a674", "#ecc794", "#f8e2b4" }
  local CAML = { "#4a3020", "#6e4a2a", "#946a38", "#b88c48", "#d4aa5c", "#ecc878" }
  sky({ "#4a3a7a", "#8a4a8a", "#d46a7a", "#f09a6a", "#f8c880", "#fbe0a0" }, 3, 215)
  sun(96, 136, 22, { "#f0a040", "#f8c050", "#fce080", "#fff0b0", "#fff6cc", "#fffae0" })
  c:cloud(300, 70, 70, "#f4b8a0", "#d890a0"); c:cloud(380, 50, 44, "#f8d0b0", "#e0a4a8")
  hills(function(x) return 168 + 10 * sin(x / 60 + 1) end, { "#6a3a5a", "#7e4a62", "#965c6a", "#b07474", "#c88c80", "#e0a48e" }, 220, 3)
  hills(function(x) return 186 + 8 * sin(x / 45 + 3) + 3 * sin(x / 13) end, { "#8a4a48", "#a05e4e", "#bc7a5c", "#d49a6c", "#e8b882", "#f4d0a0" }, 225, 5)
  palm(44, 214, 66, -12); palm(436, 214, 74, 14)
  ground(function(x) return 212 + floor(sin(x / 40) * 2) end, { "#8a5a48", "#b8805a", "#d8a674", "#ecc794", "#f4d8a8", "#fce8c0" }, 9, { tex = .3, fall = .35 })
  -- wings and towers
  for _, w in ipairs{ { 56, 118 }, { 362, 424 } } do
    local m = rect(w[1], 154, w[2], 212)
    for x = w[1], w[2] - 6, 14 do m:add(rect(x, 147, x + 7, 154)) end
    c:rim(m, INK); brick(m, SAND, 6, 14, 4, function(x) return (x > 300) and -1 or 0 end)
    for x = w[1] + 14, w[2] - 12, 24 do
      local wm = rect(x, 172, x + 7, 188):add(ell(x + 3, 172, 4, 4))
      c:rim(wm, INK); c:fillMask(wm, "#3a2030"); for y = 182, 188 do for xx = x, x + 7 do P(xx, y, "#f0a050") end end
    end
  end
  for _, t in ipairs{ { 110, 150 }, { 330, 370 } } do
    local m = rect(t[1], 100, t[2], 212)
    c:rim(m, INK); brick(m, SAND, 6, 13, 7, function(x) return (x > 330) and -1 or ((x < 120) and 1 or 0) end)
    local dm = ell((t[1] + t[2]) / 2, 100, 20, 22):clip(rect(t[1] - 4, 70, t[2] + 4, 100))
    solid(dm, TEAL, { R = 14, tex = .1 })
    c:fillMask(rect((t[1] + t[2]) / 2 - 1, 52, (t[1] + t[2]) / 2, 74), INK); c:fillMask(ell((t[1] + t[2]) / 2, 54, 2, 2), GOLD[5])
    local wm = rect((t[1] + t[2]) / 2 - 3, 122, (t[1] + t[2]) / 2 + 3, 138):add(ell((t[1] + t[2]) / 2, 122, 4, 4))
    c:rim(wm, INK); c:fillMask(wm, "#3a2030"); for y = 132, 138 do for xx = (t[1] + t[2]) / 2 - 3, (t[1] + t[2]) / 2 + 3 do P(xx, y, "#f0a050") end end
    for x = t[1] - 2, t[2] + 2 do P(x, 100, TEAL[2]); P(x, 101, GOLD[4]) end
  end
  -- main facade
  local fm = rect(148, 120, 332, 212)
  for x = 148, 326, 14 do fm:add(rect(x, 113, x + 7, 120)) end
  c:rim(fm, INK); brick(fm, SAND, 7, 16, 11, function(x, y) return (x < 170) and 1 or ((x > 316) and -1 or 0) end)
  -- central dome on a drum
  local dr = rect(196, 96, 284, 120); c:rim(dr, INK); brick(dr, SAND, 6, 12, 2)
  for x = 196, 284 do P(x, 104, TEAL[4]); P(x, 105, TEAL[3]); if x % 6 < 3 then P(x, 106, GOLD[4]) end end
  local dome = ell(240, 96, 44, 40):clip(rect(190, 40, 290, 96))
  solid(dome, TEAL, { R = 22, tex = .12, rimlight = true })
  for a = -3, 3 do for y = 60, 95 do local x = 240 + a * 12 * (1 - (96 - y) / 120) ; if dome:has(floor(x), y) then P(x, y, TEAL[2]) end end end
  c:fillMask(rect(239, 30, 240, 56), INK); c:fillMask(ell(240, 40, 3, 3), GOLD[5]); P(239, 38, GOLD[6]); c:fillMask(rect(239, 24, 240, 32), GOLD[4])
  -- gate arch
  local ar = ell(240, 166, 23, 27):clip(rect(210, 130, 270, 166)):add(rect(217, 166, 263, 212))
  local fr = ell(240, 166, 31, 35):clip(rect(200, 126, 280, 166)):add(rect(209, 166, 271, 212))
  c:rim(fr, INK)
  fr:each(function(x, y) if not ar:has(x, y) then local k = floor(atan(y - 166, x - 240) * 6); P(x, y, ((k + (y // 4)) % 2 == 0) and TEAL[4] or ((x + y) % 4 == 0 and GOLD[5] or SBLUE[4])) end end)
  c:rim(ar, INK)
  ar:each(function(x, y)
    local t = (y - 140) / 72
    P(x, y, (t < .25) and "#4a2840" or ((t < .5) and "#8a4a58" or ((t < .75) and "#d88050" or "#f4b45c")))
    if hash(x, y, 3) > .94 then P(x, y, "#fce080") end
  end)
  for _, lx in ipairs{ 232, 248 } do for y = 165, 168 do P(lx, y, INK) end end   -- bunting between the towers
  for i = 0, 17 do
    local bx = 152 + i * 10
    local by = 128 + floor(8 * sin((i / 17) * 3.1416))
    local col = ({ "#e8493b", "#ffd24a", "#3a9ab0", "#f080a8", "#78b064" })[i % 5 + 1]
    P(bx, by, INK); P(bx + 1, by, INK); P(bx + 2, by, INK); P(bx + 3, by, INK)
    c:fillMask(poly{ { bx, by + 1 }, { bx + 5, by + 1 }, { bx + 2, by + 7 } }, col)
    c:rim(poly{ { bx, by + 1 }, { bx + 5, by + 1 }, { bx + 2, by + 7 } }, INK)
  end
  -- lanterns at the gate
  for _, lx in ipairs{ 208, 272 } do
    glow(lx, 150, 22, "#ffd070", .5)
    c:fillMask(rect(lx - 1, 138, lx, 144), INK)
    inkfill(rect(lx - 3, 145, lx + 2, 155), "#ffe08a"); c:fillMask(rect(lx - 1, 148, lx, 152), "#fff6cc")
  end
  -- steps
  for i = 0, 2 do local m = rect(206 - i * 4, 208 + i * 2, 274 + i * 4, 210 + i * 2); c:rim(m, INK); c:fillMask(m, SAND[5 - i % 2]); for x = 206 - i * 4, 274 + i * 4 do P(x, 210 + i * 2, SAND[2]) end end
  -- camel with a tiny red cap
  local cx, cy = 98, 238
  local body = ell(cx, cy, 24, 11):add(ell(cx - 8, cy - 14, 7, 8)):add(c:line({ { cx + 18, cy - 4 }, { cx + 30, cy - 22 }, { cx + 34, cy - 34 } }, 7)):add(ell(cx + 40, cy - 35, 8, 4))
  for _, lx in ipairs{ -17, -9, 11, 19 } do body:add(rect(cx + lx - 2, cy + 6, cx + lx + 2, cy + 22)) end
  body:add(c:line({ { cx - 24, cy - 2 }, { cx - 30, cy + 10 } }, 2))
  solid(body, CAML, { R = 8, tex = .2, seed = 4 })
  for _, lx in ipairs{ -17, -9, 11, 19 } do for y = cy + 20, cy + 22 do for x = cx + lx - 2, cx + lx + 2 do P(x, y, CAML[2]) end end end
  c:fillMask(rect(cx - 16, cy - 8, cx + 10, cy - 2), "#d04050"); for x = cx - 16, cx + 10 do P(x, cy - 2, "#8a2438"); if x % 4 == 0 then P(x, cy - 8, "#ffd24a") end end
  P(cx + 42, cy - 37, INK); P(cx + 46, cy - 34, INK); P(cx + 41, cy - 33, CAML[2])
  c:fillMask(poly{ { cx + 36, cy - 40 }, { cx + 43, cy - 40 }, { cx + 40, cy - 49 } }, "#e8493b"); c:rim(poly{ { cx + 36, cy - 40 }, { cx + 43, cy - 40 }, { cx + 40, cy - 49 } }, INK); P(cx + 40, cy - 50, "#ffd24a")
  -- sacks and crates, right
  for k, s in ipairs{ { 392, 250, 14, 11, "#c8a060" }, { 414, 252, 12, 9, "#d8b070" }, { 404, 240, 11, 9, "#b88c48" } } do
    solid(ell(s[1], s[2], s[3], s[4]), { "#4a3020", "#6e4a2a", "#946a38", s[5], mixc(s[5], "#ffffff", .2), mixc(s[5], "#ffffff", .4) }, { R = 6, tex = .15, seed = k })
    c:fillMask(rect(s[1] - 3, s[2] - s[4] - 1, s[1] + 3, s[2] - s[4]), "#8a5a3a")
  end
  inkfill(rect(356, 240, 378, 256), TIMB[4]); S.planks(rect(356, 240, 378, 256), TIMB, { w = 5 }); for x = 356, 378 do P(x, 240, TIMB[6]) end
  for i = 1, 40 do P(floor(hash(i, 1, 4) * 470) + 4, 218 + floor(hash(i, 2, 4) * 50), "#d8a674") end
  sparkles({ { 240, 76 }, { 120, 80 }, { 366, 96 } })
end

---------------------------------------------------------------- 2. SINGING WATERFALL
F["wonder-the-singing-waterfall"] = function()
  local BAS = { "#2a2438", "#3e3650", "#564c6a", "#726888", "#948aa8", "#b8aec8" }
  local WTR = { "#3a86b8", "#5aa8d0", "#8cc8e4", "#b8e0f0", "#e0f4f8", "#f8fcf4" }
  sky({ "#6ab8dc", "#88cce0", "#a8dce2", "#c8ecde", "#e8f6d8" }, 4, 200)
  for k, col in ipairs{ "#e8493b", "#f5a03c", "#ffe05a", "#78c864", "#4aa8e0", "#8a6ac8" } do   -- rainbow arcs
    local r = 150 - k * 5
    for a = 3.2, 6.2, .004 do P(240 + cos(a) * (r + 40), 214 + sin(a) * r, col); P(240 + cos(a) * (r + 40), 215 + sin(a) * r, col) end
  end
  c:cloud(40, 60, 54, "#f8f0e0", "#c8e6f0"); c:cloud(400, 40, 46, "#f8f0e0", "#c8e6f0")
  hills(function(x) return 130 + 14 * sin(x / 50) end, { "#2c5a58", "#3a7066", "#4c8a78", "#62a488", "#7cbc98", "#9cd0a8" }, 220, 3)
  ground(function(x) return 200 end, { "#1c3a2a", "#2a5a34", "#3a7a3e", "#5aa04a", "#7cc058", "#a8e07c" }, 3)
  -- cliff behind
  local cl = poly{ { 120, 215 }, { 138, 120 }, { 170, 64 }, { 240, 50 }, { 310, 64 }, { 342, 120 }, { 360, 215 } }
  cl = GX.rough(cl, 3, 2)
  solid(cl, BAS, { R = 18, tex = .6, sc = 6, seed = 5 })
  for i = 1, 70 do local x, y = 150 + floor(hash(i, 1, 6) * 180), 70 + floor(hash(i, 2, 6) * 120); if cl:has(x, y) then P(x, y, GREEN[3 + i % 2]); P(x + 1, y, GREEN[3]) end end
  -- organ-pipe basalt columns
  local tops = { 112, 98, 84, 96, 108, 100, 90, 104, 118 }
  for i, side in ipairs{ -1, -1, -1, -1, 1, 1, 1, 1 } do
    local k = (i - 1) % 4
    local x0 = (side < 0) and (146 + k * 17) or (270 + k * 17)
    local top = 84 + floor(abs(k - (side < 0 and 3 or 0)) * 10) + floor(hash(i, 1, 2) * 8)
    local m = rect(x0, top, x0 + 14, 196)
    solid(m, BAS, { R = 7, tex = .25, seed = i, rimlight = true })
    for y = top + 6, 196, 7 do for x = x0, x0 + 14 do P(x, y, BAS[2]) end end
    c:fillMask(ell(x0 + 7, top + 3, 4, 2), "#1c1830"); c:fillMask(ell(x0 + 7, top + 2, 3, 1), "#3a86b8")
  end
  -- waterfall
  local wm = rect(216, 56, 264, 192)
  wm:each(function(x, y)
    local st = vn(x * 1.0, y * .12, 1.7, 7) + (vn(x, y, 3, 2) - .5) * .3
    local v = .7 + (st - .5) * .9 - (y - 56) / 300
    if (x - 216) < 3 then v = v - .3 elseif x > 260 then v = v - .2 end
    P(x, y, WTR[GX.idx(v, { .22, .4, .56, .72, .86 })])
  end)
  c:rim(wm:copy():cut(rect(214, 188, 266, 200)), WTR[1])
  local lip = rect(212, 50, 268, 58); solid(lip, BAS, { R = 4, tex = .2, seed = 9 })
  -- pool
  local pool = ell(240, 214, 190, 42):clip(rect(0, 190, 479, 269))
  pool:each(function(x, y)
    local v = .75 - (y - 190) / 90 + (vn(x * .5, y * 2, 8, 3) - .5) * .3
    P(x, y, WTR[GX.idx(v, { .2, .36, .52, .68, .82 })])
  end)
  for i = 1, 70 do local x, y = 40 + floor(hash(i, 1, 5) * 400), 196 + floor(hash(i, 2, 5) * 66); if pool:has(x, y) and pool:has(x + 5, y) then for k = 0, 3 do P(x + k, y, WTR[5]) end; P(x + 1, y + 1, WTR[1]); P(x + 2, y + 1, WTR[1]) end end
  for k, e in ipairs{ { 240, 206, 54, 12 }, { 240, 206, 38, 8 } } do
    local r = ell(e[1], e[2], e[3], e[4]); local ed = r:edge(); ed:each(function(x, y) if (x + y) % 3 ~= 0 then P(x, y, "#f8fcf4") end end)
  end
  for i = 1, 26 do   -- mist at the foot
    local a = hash(i, 1, 9) * 6.28; local x, y = 240 + cos(a) * hash(i, 2, 9) * 44, 192 + sin(a) * hash(i, 2, 9) * 7
    c:fillMask(ell(x, y, 4 + i % 3, 3), "#f4f8f0"); P(x - 1, y - 1, "#fff");
  end
  -- stepping stones and lily pad with a singing frog
  for _, s in ipairs{ { 150, 236, 14 }, { 190, 250, 11 }, { 330, 244, 12 } } do solid(ell(s[1], s[2], s[3], 5), BAS, { R = 6, tex = .3, seed = s[1] }) end
  local lp = ell(370, 232, 22, 7); inkfill(lp, GREEN[4]); lp:each(function(x, y) if y < 231 then P(x, y, GREEN[5]) end end)
  c:fillMask(poly{ { 370, 232 }, { 392, 226 }, { 392, 232 } }, "#3a86b8")
  local fg = ell(366, 224, 8, 6):add(ell(361, 218, 3, 3)):add(ell(370, 218, 3, 3))
  solid(fg, { "#1c3a2a", "#2a5a34", "#3a7a3e", "#5aa04a", "#7cc058", "#a8e07c" }, { R = 5, tex = .1 })
  c:fillMask(ell(366, 227, 4, 2), "#f0e8b0"); P(361, 217, "#fff6dc"); P(370, 217, "#fff6dc"); P(361, 218, INK); P(370, 218, INK)
  for x = 362, 370 do P(x, 224, INK) end; P(363, 225, "#e8493b"); P(364, 225, "#e8493b"); P(365, 225, "#e8493b")
  note(384, 208, "#ffd24a"); note(398, 192, "#f080a8")
  -- floating notes around the fall
  for _, n in ipairs{ { 190, 150, "#ffd24a" }, { 160, 120, "#f080a8" }, { 292, 130, "#ffd24a" }, { 322, 100, "#78c864" }, { 264, 40, "#f080a8" }, { 210, 36, "#ffd24a" } } do note(n[1], n[2], n[3]) end
  -- ferns left and right
  for _, b in ipairs{ { 30, 200, 54, 30 }, { 110, 232, 46, 22 }, { 440, 204, 52, 30 }, { 420, 250, 56, 20 }, { 70, 252, 52, 18 } } do GX.foliage(c, b[1], b[2], b[3], b[4], R4((b[1] % 3 == 0) and LEAF or GREEN), b[1] + 3) end
  for i, p in ipairs{ { 20, 236 }, { 96, 244 }, { 430, 232 }, { 452, 250 }, { 140, 222 } } do GX.flower(c, p[1], p[2], ({ "#f080a8", "#ffd24a", "#fff2dc" })[i % 3 + 1]) end
  sparkles({ { 232, 170 }, { 252, 120 }, { 244, 80 } })
end

---------------------------------------------------------------- 3. SKY CITY RUINS
F["wonder-the-sky-city-ruins"] = function()
  local RK = { "#3a2438", "#5a3a48", "#7e5a5a", "#a07c70", "#c4a28a", "#e4c8aa" }
  local MARB = { "#5e4658", "#8e7476", "#bca290", "#dcc4a6", "#eed9b8", "#f8eacc" }
  sky({ "#5a4a8a", "#8a5a9a", "#c87aa0", "#f0a0a0", "#f8c8a0", "#fce4b4" }, 5, 269)
  stars(40, 3, 60, { "#fce4b4", "#f8c8d8" })
  for _, k in ipairs{ { 0, 262, 110 }, { 100, 270, 130 }, { 220, 268, 100 }, { 330, 266, 140 }, { 440, 264, 110 }, { 40, 246, 90 }, { 380, 244, 80 } } do c:cloud(k[1], k[2], k[3], "#fbd8c4", "#e8a8b0") end
  for _, k in ipairs{ { 30, 270, 90 }, { 150, 268, 120 }, { 290, 270, 110 }, { 400, 270, 90 } } do c:cloud(k[1], k[2], k[3], "#fff0dc", "#f8c8c0") end
  local function island(cx, yt, w, dp, seed, ruin)
    local m = HP.mask()
    for y = yt, yt + dp do
      local t = (y - yt) / dp
      local hw = w * (1 - t ^ .8) + 3
      for x = floor(cx - hw), floor(cx + hw) do m:set(x, y) end
    end
    m = GX.rough(m, seed, 2)
    solid(m, RK, { R = 12, tex = .6, sc = 5, seed = seed })
    local g = HP.mask()
    m:each(function(x, y) if y <= yt + 5 + floor((vn(x, 0, 6, seed) - .5) * 5) then g:set(x, y) end end)
    c:rim(g, INK); g:each(function(x, y) P(x, y, (y < yt + 2) and GREEN[6] or ((y < yt + 4) and GREEN[5] or GREEN[3])) end)
    for i = 1, floor(w / 8) do   -- hanging roots
      local x = cx - w * .8 + hash(i, 1, seed) * w * 1.6
      local ln = 8 + floor(hash(i, 2, seed) * 14)
      for k = 0, ln do if m:has(floor(x), yt + 5 + k - 2) or k > 3 then P(x, yt + dp * (1 - ((x - cx) / w) ^ 2) * .45 + k + 4, (k % 3 == 0) and GREEN[3] or "#6a4a38") end end
    end
    return m
  end
  island(70, 118, 38, 26, 2); island(420, 96, 34, 24, 4); island(400, 196, 30, 20, 6); island(58, 204, 28, 18, 8)
  for _, p in ipairs{ { 70, 118 }, { 420, 96 } } do   -- small ruined columns
    for k = -1, 1, 2 do local m = rect(p[1] + k * 14 - 3, p[2] - 18, p[1] + k * 14 + 3, p[2] - 1); solid(m, MARB, { R = 4, tex = .2 }) end
  end
  GX.foliage(c, 420, 80, 18, 12, R4(LEAF), 3)
  -- main island
  local mm = island(240, 168, 128, 70, 11)
  -- falling stream
  for y = 176, 232 do local x = 358 + floor(sin(y / 9) * 1.2); P(x, y, "#a8dce8"); P(x + 1, y, "#e0f4f8"); P(x - 1, y, "#6aa8c8") end
  for i = 0, 6 do P(354 + i * 2, 236 + i % 2, "#f8fcf4") end
  -- paving
  local pv = rect(130, 158, 350, 168); c:rim(pv, INK); brick(pv, MARB, 5, 14, 3)
  -- arch of the sky gate: two piers and a ring
  local ring = ell(240, 108, 42, 42):cut(ell(240, 108, 30, 30)):clip(rect(190, 60, 290, 108))
  ring:add(rect(198, 108, 210, 158)):add(rect(270, 108, 282, 158)):cut(rect(210, 100, 270, 158))
  c:rim(ring, INK); brick(ring, MARB, 7, 12, 6, function(x) return (x < 230) and 1 or ((x > 262) and -1 or 0) end)
  -- the sky gem in the gate
  glow(240, 120, 36, "#a8f0ff", .55)
  local gem = poly{ { 240, 98 }, { 254, 118 }, { 240, 146 }, { 226, 118 } }
  solid(gem, { "#1e5a8a", "#2e86b8", "#4aaed4", "#78d4ec", "#b0ecf8", "#f0fcff" }, { R = 12, tex = .1 })
  for y = 118, 119 do for x = 226, 254 do if gem:has(x, y) then P(x, y, "#2e86b8") end end end
  c:sparkle(236, 108); c:sparkle(248, 128); c:sparkle(240, 90); c:sparkle(212, 112); c:sparkle(270, 100)
  -- broken colonnade
  for i, cx in ipairs{ 150, 172, 308, 330 } do
    local h = 34 + (i % 2) * 14
    local m = rect(cx - 5, 158 - h, cx + 5, 158)
    m:cut(poly{ { cx - 6, 158 - h - 1 }, { cx + 6, 158 - h - 1 }, { cx + 6, 158 - h + 5 }, { cx + 1, 158 - h + 2 }, { cx - 3, 158 - h + 7 }, { cx - 6, 158 - h + 3 } })
    solid(m, MARB, { R = 6, tex = .2, seed = i })
    for y = 158 - h + 2, 156, 4 do for x = cx - 4, cx + 4, 2 do if m:has(x, y) and (x - cx) % 4 == 0 then P(x, y, MARB[2]) end end end
    c:fillMask(rect(cx - 7, 156, cx + 7, 158), MARB[3]); c:rim(rect(cx - 7, 156, cx + 7, 158), INK)
    for k = 1, 5 do P(cx - 4 + floor(hash(k, i, 3) * 9), 158 - h + 6 + floor(hash(k, i, 5) * h * .6), GREEN[3]) end
  end
  -- fallen blocks and moss
  for _, b in ipairs{ { 196, 154, 12 }, { 270, 156, 10 }, { 130, 156, 8 } } do local m = rect(b[1], b[2] - 6, b[1] + b[3], b[2] + 1); c:rim(m, INK); brick(m, MARB, 4, 8, 9); for x = b[1], b[1] + b[3] do P(x, b[2] - 6, GREEN[5]) end end
  -- quirk: a small blue bird on a broken column
  bird(308, 158 - 48 - 6, { "#1e3a6a", "#2e5a9a", "#3e7ac0", "#5a9ae0", "#88c0f0", "#c0e0fc" }, { "#1e3a6a", "#1e3a6a", "#2e5a9a" }, "#f5a03c")
  sparkles({ { 120, 70 }, { 360, 60 }, { 200, 30 }, { 300, 36 } })
end

---------------------------------------------------------------- 4. STANDING STONES
F["wonder-the-standing-stones"] = function()
  local ST = { "#1c1830", "#2e2a48", "#463e62", "#625a80", "#847ca0", "#aaa4c4" }
  sky({ "#120e2a", "#1e1844", "#2e2662", "#463a80", "#6a4a8e", "#8a5a98" }, 6, 182)
  stars(110, 4, 140, { "#f8f0d8", "#c8d4f8", "#f8d0e8" })
  local moon = ell(352, 56, 22, 22)
  for k = 3, 1, -1 do c:fillMask(ell(352, 56, 22 + k * 6, 22 + k * 6), mixc("#2e2662", "#f8f0d8", .08 * (4 - k))) end
  solid(moon, { "#a8a0b8", "#c4bcc8", "#dcd4cc", "#ece4d0", "#f6eed8", "#fff8e8" }, { R = 22, tex = .08, ink = false })
  for _, p in ipairs{ { 346, 50, 4 }, { 358, 64, 3 }, { 360, 46, 2 } } do c:fillMask(ell(p[1], p[2], p[3], p[3] - 1), "#d4ccc8") end
  hills(function(x) return 166 + 10 * sin(x / 70 + 2) + 4 * sin(x / 19) end, { "#1c1e46", "#26285a", "#323470", "#40448a", "#5058a0", "#6a6cb8" }, 200, 3)
  hills(function(x) return 178 + 8 * sin(x / 50) end, { "#1a2a44", "#223c58", "#2c4e68", "#3a6478", "#4c7c88", "#609498" }, 205, 7)
  ground(function(x) return 192 + floor(sin(x / 35) * 1.5) end, { "#142a30", "#1e3e3c", "#2a5648", "#3a7058", "#4e8a68", "#68a47c" }, 5, { tex = .4, fall = .3 })
  local function menhir(cx, by, w, h, seed, glow_runes)
    c:fillMask(ell(cx + w * .7, by, w * .9, 3), "#102420")
    local m = poly{ { cx - w / 2, by }, { cx - w / 2 + 1, by - h * .6 }, { cx - w / 2 + 3, by - h + 4 }, { cx + 1, by - h }, { cx + w / 2 - 2, by - h + 2 }, { cx + w / 2, by - h * .7 }, { cx + w / 2, by } }
    m = GX.rough(m, seed, 1)
    solid(m, ST, { R = max(4, floor(w / 2)), tex = .5, sc = 4, seed = seed, rimlight = true })
    m:each(function(x, y) if vn(x, y, 4, seed + 3) > .7 + (by - y) / h * .3 and y > by - h * .3 or (y < by - h + 8 and vn(x, y, 3, seed) > .66) then P(x, y, GREEN[2 + (x + y) % 3]) end end)
    if glow_runes then
      for k = 0, 2 do
        local rx, ry = cx - 3 + floor(hash(k, seed, 3) * 4), by - h * .75 + k * h * .18
        for j = 0, 5 do P(rx, ry + j, "#7af4e0") end
        P(rx + 1, ry + 1, "#7af4e0"); P(rx + 2, ry, "#7af4e0"); P(rx - 1, ry + 4, "#7af4e0"); P(rx - 2, ry + 3, "#7af4e0")
        P(rx - 1, ry + 2, "#3aa8b8"); P(rx + 1, ry + 5, "#3aa8b8")
      end
    end
    return m
  end
  local ring = {}
  for i = 0, 13 do
    local a = i / 14 * 6.2832
    local x, y = 240 + cos(a) * 200, 214 + sin(a) * 24
    if not (abs(x - 240) < 70 and y < 200) then ring[#ring + 1] = { x, y, 0 } end
  end
  table.sort(ring, function(a, b) return a[2] < b[2] end)
  for i, r in ipairs(ring) do
    local sc = .55 + (r[2] - 190) / 60
    if r[2] < 205 then menhir(r[1], r[2], 12 * sc + 6, 40 * sc + 14, i * 3, i % 3 == 0) end
  end
  -- grand trilithon
  glow(240, 150, 46, "#7af4e0", .5)
  c:fillMask(rect(222, 118, 258, 196), "#3a6a84")
  for y = 118, 196 do for x = 222, 258 do local v = (y - 118) / 78; P(x, y, (hash(x, y, 3) > .5 and v > .6) and "#a8f4e8" or ((v < .3) and "#2e5878" or ((v < .6) and "#4a8a9c" or "#78c8c0"))) end end
  for k = -4, 4 do local x = 240 + k * 5; for y = 130 + abs(k) * 6, 160 do if (y + k) % 3 == 0 then P(x, y, "#c8fcf0") end end end
  menhir(206, 198, 32, 96, 31, true); menhir(274, 198, 32, 96, 37, true)
  local lint = poly{ { 184, 108 }, { 190, 90 }, { 296, 88 }, { 298, 106 }, { 292, 112 }, { 188, 114 } }
  lint = GX.rough(lint, 5, 1)
  solid(lint, ST, { R = 10, tex = .5, sc = 4, seed = 8, rimlight = true })
  for k = 0, 2 do local rx = 218 + k * 22; for j = 0, 5 do P(rx, 96 + j, "#7af4e0") end; P(rx + 1, 97, "#7af4e0"); P(rx - 1, 100, "#7af4e0") end
  for i, r in ipairs(ring) do
    local sc = .55 + (r[2] - 190) / 60
    if r[2] >= 205 then menhir(r[1], r[2] + 8, 12 * sc + 6, 40 * sc + 14, i * 5, i % 2 == 0) end
  end
  -- ground mist
  for y = 196, 232 do for x = 0, 479 do if vn(x, y * 3, 14, 7) > .66 and (x + y) % 2 == 0 then P(x, y, "#5a7ea0") end end end
  for i = 1, 40 do local x, y = floor(hash(i, 1, 2) * 470) + 4, 200 + floor(hash(i, 2, 2) * 66); P(x, y, "#ffe88a"); P(x + 1, y, "#fff6cc"); if i % 3 == 0 then P(x, y - 1, "#ffe88a") end end
  for x = 170, 310, 3 do local y = 262 - floor(abs(x - 240) / 10); P(x, y, "#4a8a68") end
  -- quirk: a sleeping hedgehog wearing a tiny cap
  local hx, hy = 96, 254
  local hg = ell(hx, hy - 6, 13, 8):add(ell(hx + 12, hy - 3, 5, 4))
  solid(hg, { "#2a1a1a", "#4a2e28", "#6e4a38", "#8e6a48", "#b08c60", "#d4b080" }, { R = 8, tex = .6, sc = 2, seed = 3 })
  for i = 0, 14 do P(hx - 11 + i * 1.6, hy - 14 + abs(i - 7) // 2, INK) end
  c:fillMask(ell(hx + 14, hy - 2, 3, 2), "#f0d0a8"); P(hx + 16, hy - 3, INK); P(hx + 13, hy - 4, INK); P(hx + 14, hy - 4, INK)
  c:fillMask(poly{ { hx + 8, hy - 7 }, { hx + 14, hy - 7 }, { hx + 11, hy - 15 } }, "#e8493b"); P(hx + 11, hy - 16, "#ffd24a")
  P(hx + 18, hy - 10, "#f8f0d8"); P(hx + 20, hy - 13, "#f8f0d8"); P(hx + 22, hy - 17, "#f8f0d8")
  c:sparkle(240, 100)
end

---------------------------------------------------------------- 5. STEPPED SEED TEMPLE
F["wonder-the-stepped-seed-temple"] = function()
  local JADE = { "#1e3a34", "#2c5a4c", "#3a7a62", "#52a07c", "#7cc89c", "#b0e8c4" }
  local TST = { "#3a2c34", "#5e4a48", "#8a6c5a", "#b08c6c", "#d4ae88", "#f0d2aa" }
  sky({ "#58b0e0", "#7cc8e8", "#a4dcec", "#cceadc", "#f0f0c8" }, 7, 200)
  c:cloud(30, 64, 54, "#fff8e8", "#cfe8ee"); c:cloud(390, 90, 60, "#fff8e8", "#cfe8ee"); c:cloud(150, 40, 40, "#fff8e8", "#cfe8ee")
  hills(function(x) return 150 + 18 * sin(x / 55) end, { "#2c5a58", "#3a7066", "#4c8a78", "#62a488", "#7cbc98", "#9cd0a8" }, 215, 3)
  hills(function(x) return 176 + 10 * sin(x / 40 + 2) end, { "#2a5a34", "#38723c", "#4c8a46", "#64a454", "#82c068", "#a4d884" }, 220, 6)
  for _, b in ipairs{ { 40, 170, 50, 26 }, { 440, 176, 52, 28 }, { 110, 188, 40, 20 }, { 380, 190, 44, 20 } } do GX.foliage(c, b[1], b[2], b[3], b[4], R4(GREEN), b[1]) end
  ground(function(x) return 214 + floor(sin(x / 30) * 1.2) end, GREEN, 8)
  -- five tiers
  local base = 214
  for i = 0, 4 do
    local hw = 170 - i * 30
    local y1, y0 = base - i * 30, base - i * 30 - 28
    local m = rect(240 - hw, y0, 240 + hw, y1)
    c:rim(m, INK); brick(m, TST, 7, 15, i + 2, function(x, y) return (x < 240 - hw + 6) and 1 or ((x > 240 + hw - 8) and -1 or 0) end)
    for x = 240 - hw, 240 + hw do   -- jade fret band
      local py = y0 + 13
      P(x, py, JADE[4]); P(x, py + 1, JADE[3]); P(x, py - 1, JADE[5])
      if (x // 3) % 3 == 0 then P(x, py - 2, JADE[2]); P(x, py + 2, JADE[2]); P(x + 1, py - 2, GOLD[4]) end
    end
    local ter = rect(240 - hw - 4, y0 - 5, 240 + hw + 4, y0 - 1)   -- crop terrace on the ledge
    c:rim(ter, INK)
    ter:each(function(x, y) local t = (y == y0 - 5) and 5 or 3; if hash(x, y, 4) > .8 then t = 6 end; P(x, y, GREEN[t]) end)
    for x = 240 - hw, 240 + hw - 2, 6 do if abs(x - 240) > 20 then local col = ({ "#e8493b", "#ffd24a", "#f5a03c" })[(x // 6 + i) % 3 + 1]; P(x, y0 - 6, col); P(x + 1, y0 - 6, col); P(x, y0 - 7, GREEN[5]) end end
  end
  -- stair
  local st = poly{ { 222, 214 }, { 258, 214 }, { 252, 76 }, { 228, 76 } }
  c:rim(st, INK)
  st:each(function(x, y) local t = (y // 5 % 2 == 0) and 5 or 4; if y % 5 == 0 then t = 6 elseif y % 5 == 4 then t = 2 end; if x < 232 then t = min(6, t + 0) end; P(x, y, TST[t]) end)
  for y = 76, 214 do local hw = 12 + (y - 76) * .21; P(240 - hw, y, TST[2]); P(240 + hw, y, TST[2]) end
  -- shrine and the great seed
  local sh = rect(210, 56, 270, 76); c:rim(sh, INK); brick(sh, TST, 6, 12, 5)
  local dr = ell(240, 70, 8, 8):clip(rect(230, 62, 250, 76)):add(rect(232, 70, 248, 76)); c:rim(dr, INK); c:fillMask(dr, "#3a2030"); for y = 70, 76 do for x = 233, 247 do P(x, y, "#f0a050") end end
  local roof = rect(204, 50, 276, 56); c:rim(roof, INK); brick(roof, JADE, 6, 10, 3)
  glow(240, 30, 40, "#ffe08a", .6)
  for k = 0, 11 do local a = k / 12 * 6.2832; for r = 22, 30 do if (r + k) % 2 == 0 then P(240 + cos(a) * r, 30 + sin(a) * r, "#fff0a8") end end end
  local seed = poly{ { 240, 12 }, { 252, 28 }, { 253, 40 }, { 240, 50 }, { 227, 40 }, { 228, 28 } }
  solid(seed, GOLD, { R = 12, tex = .15, rimlight = true })
  for y = 20, 46 do P(240 + floor(sin(y / 6) * 1.2), y, GOLD[3]) end
  c:fillMask(poly{ { 240, 12 }, { 232, 4 }, { 224, 6 }, { 230, 12 } }, GREEN[4]); c:rim(poly{ { 240, 12 }, { 232, 4 }, { 224, 6 }, { 230, 12 } }, INK)
  c:fillMask(poly{ { 240, 12 }, { 248, 2 }, { 256, 4 }, { 250, 12 } }, GREEN[5]); c:rim(poly{ { 240, 12 }, { 248, 2 }, { 256, 4 }, { 250, 12 } }, INK)
  c:sparkle(236, 24); c:sparkle(262, 14); c:sparkle(218, 36)
  -- quirk: a macaw on the second tier
  bird(116, 140, { "#6a1220", "#a02030", "#d03a38", "#e8584a", "#f48070", "#ffa898" }, { "#2e5aa0", "#1e3a6a", "#3e7ac0" }, "#f8e8c8")
  c:fillMask(rect(104, 144, 108, 156), "#2e5aa0")
  -- front foliage and flowers
  for _, b in ipairs{ { 26, 236, 50, 24 }, { 452, 238, 50, 24 }, { 100, 258, 46, 16 }, { 380, 258, 46, 16 } } do GX.foliage(c, b[1], b[2], b[3], b[4], R4((b[1] % 2 == 0) and GREEN or LEAF), b[1] + 7) end
  for i = 1, 14 do GX.flower(c, 130 + floor(hash(i, 1, 3) * 220), 226 + floor(hash(i, 2, 3) * 30), ({ "#f080a8", "#ffd24a", "#e8493b", "#fff2dc" })[i % 4 + 1]) end
end

---------------------------------------------------------------- 6. THOUSAND GATES
F["wonder-the-thousand-gates"] = function()
  local RED = { "#3a0f18", "#6a1a20", "#98282a", "#c8422e", "#e8643a", "#f6906a" }
  local BLK = { "#14101a", "#241c2a", "#36283a", "#4a3a4a", "#5e4a58", "#74606c" }
  sky({ "#5a3a7a", "#a04a82", "#e0647a", "#f8946a", "#fcc47a", "#fce4a0" }, 3, 125)
  for k = 4, 1, -1 do c:fillMask(ell(240, 112, 40 + k * 14, 40 + k * 14):clip(rect(0, 0, 479, 118)), mixc("#f8946a", "#fce4a0", 1 - k * .2)) end
  solid(ell(240, 112, 38, 38):clip(rect(0, 0, 479, 118)), { "#f08838", "#f8a848", "#fcc868", "#ffe090", "#fff0b0", "#fffad0" }, { R = 38, tex = .05, ink = false })
  c:cloud(30, 70, 60, "#f8b8a0", "#d88098"); c:cloud(390, 56, 64, "#f8b8a0", "#d88098")
  hills(function(x) return 104 + 12 * sin(x / 50) + 4 * sin(x / 17) end, { "#5a2a62", "#6e3a70", "#864c7c", "#a0648a", "#bc7e98", "#d49aa4" }, 125, 3)
  ground(function(x) return 118 end, { "#3a5a3c", "#4c7448", "#64904e", "#82ac5c", "#a4c470", "#c8dc90" }, 6, { tex = .35, fall = .55 })
  local path = poly{ { 236, 118 }, { 244, 118 }, { 440, 270 }, { 40, 270 } }
  path:each(function(x, y)
    local v = .6 + (vn(x, y, 4, 3) - .5) * .35 - (y - 118) / 400
    P(x, y, STONE[GX.idx(v, { .22, .38, .5, .64, .8 }) + 0])
  end)
  for k = 0, 12 do local y = 118 + floor(152 * (k / 12) ^ 2.2); for x = 0, 479 do if path:has(x, y) then P(x, y, STONE[3]) end end end
  path:edge():each(function(x, y) P(x, y, STONE[2]) end)
  local function gate(cx, baseY, s)
    local hw, H = floor(62 * s), floor(170 * s)
    local top = baseY - H
    local pw = max(2, floor(11 * s))
    local rim = (s > .35) and INK or RED[1]
    local function part(m, R, o) o = o or {}; o.rim = rim; if s > .3 then S.obj(m, R, o) else c:rim(m, rim); c:fillMask(m, R[4]); end end
    part(rect(cx - hw, top + floor(12 * s), cx - hw + pw, baseY), RED, { base = 4, lit = 0, shade = 1 })
    part(rect(cx + hw - pw, top + floor(12 * s), cx + hw, baseY), RED, { base = 3, lit = 0, shade = 1 })
    part(rect(cx - hw - floor(5 * s), top + floor(40 * s), cx + hw + floor(5 * s), top + floor(40 * s) + max(2, floor(9 * s))), RED, { base = 4, lit = 1, shade = 1 })
    part(rect(cx - hw - floor(6 * s), top + floor(10 * s), cx + hw + floor(6 * s), top + floor(20 * s)), RED, { base = 5, lit = 1, shade = 2 })
    local kasa = poly{ { cx - hw - floor(18 * s), top - floor(6 * s) }, { cx + hw + floor(18 * s), top - floor(6 * s) }, { cx + hw + floor(12 * s), top + floor(8 * s) }, { cx - hw - floor(12 * s), top + floor(8 * s) } }
    part(kasa, BLK, { base = 3, lit = 1, shade = 2 })
    if s > .45 then
      for x = cx - hw - floor(12 * s), cx + hw + floor(12 * s), 7 do P(x, top + floor(2 * s), BLK[2]) end
      part(rect(cx - hw, baseY - floor(14 * s), cx - hw + pw, baseY), BLK, { base = 3 }); part(rect(cx + hw - pw, baseY - floor(14 * s), cx + hw, baseY), BLK, { base = 3 })
    end
  end
  for i = 24, 0, -1 do
    local s = .86 ^ i
    local baseY = 118 + floor(127 * s)
    if floor(170 * s) >= 7 then gate(240, baseY, s) end
  end
  -- cherry trees and lanterns
  for _, t in ipairs{ { 40, 170, 1.0 }, { 110, 150, .7 }, { 440, 176, 1.0 }, { 372, 150, .7 } } do
    local tm = rect(t[1] - 5 * t[3], 128 + (1 - t[3]) * 30, t[1] + 5 * t[3], 230)
    solid(tm, TIMB, { R = 4, tex = .3 })
    GX.foliage(c, t[1], floor(100 + (1 - t[3]) * 40), floor(60 * t[3]), floor(34 * t[3]), R4({ "#6a2a50", "#a8486c", "#d86a8c", "#ec90aa", "#f8b8c8", "#fcd8e0" }), floor(t[1]))
  end
  for _, x in ipairs{ 96, 384 } do
    solid(rect(x - 4, 214, x + 4, 244), STONE, { R = 4, tex = .2 }); solid(rect(x - 9, 204, x + 9, 213), STONE, { R = 4, tex = .2 })
    c:fillMask(rect(x - 3, 220, x + 3, 228), "#ffe08a"); glow(x, 224, 22, "#ffd070", .5); solid(rect(x - 11, 196, x + 11, 204), STONE, { R = 4 })
  end
  fox(120, 258, 1.2)
  for i = 1, 30 do
    local x, y = floor(hash(i, 1, 8) * 470) + 4, 226 + floor(hash(i, 2, 8) * 40)
    if not path:has(x, y) or y > 250 then P(x, y, "#f8b8c8"); P(x + 1, y, "#ec90aa") end
  end
  for i = 1, 8 do local x, y = 20 + floor(hash(i, 3, 8) * 440), 130 + floor(hash(i, 4, 8) * 80); P(x, y, "#f8d8e0"); P(x + 1, y + 1, "#ec90aa") end
  c:sparkle(240, 90)
end

---------------------------------------------------------------- 7. THOUSAND RINGS STUMP
F["wonder-thousand-rings-stump"] = function()
  sky({ "#1c3a34", "#24493c", "#2e5a44", "#3a704a", "#4c8a54", "#62a468" }, 5, 200)
  -- light shafts: lift
  GX.bands(c, 0, 200, { "#1c3a34", "#24493c", "#2e5a44", "#3a704a", "#4c8a54", "#62a468" }, 5, .1, function(x, y) return ((x + y * .55) % 96) < 26 end, "#fff4b0")
  for _, t in ipairs{ { 14, 34 }, { 90, 22 }, { 360, 26 }, { 430, 40 }, { 300, 16 } } do
    local m = rect(t[1], 0, t[1] + t[2], 200)
    solid(m, { "#10201e", "#1e3430", "#2e4a3e", "#46604a", "#608058", "#82a068" }, { R = 8, tex = .6, sc = 3, seed = t[1], amb = .3 })
    for y = 0, 200 do P(t[1] + floor(t[2] * .75), y, "#10201e") end
  end
  for _, b in ipairs{ { 60, 70, 70, 36 }, { 420, 60, 70, 36 }, { 240, 30, 120, 30 } } do GX.foliage(c, b[1], b[2], b[3], b[4], R4(GREEN), b[1] + 2) end
  ground(function(x) return 192 + floor(sin(x / 28) * 1.5) end, { "#142a24", "#1e3e30", "#2c5a3a", "#3e7644", "#58944e", "#7cb464" }, 4, { tex = .4 })
  -- stump body
  local top = ell(240, 138, 178, 60)
  local body = ell(240, 138, 178, 60):add(rect(62, 138, 418, 192)):add(ell(240, 192, 178, 52)):add(ell(240, 192, 178, 52))
  for i, rx in ipairs{ 70, 120, 360, 410 } do   -- roots
    local sgn = (rx < 240) and -1 or 1
    body:add(poly{ { rx - 14, 190 }, { rx + 14, 190 }, { rx + sgn * 34, 226 }, { rx + sgn * 20, 232 }, { rx - sgn * 4, 212 } })
  end
  body = GX.rough(body, 3, 1)
  c:rim(body, INK)
  body:each(function(x, y)
    local nx = (x - 240) / 178
    local ridge = sin(x * .62 + vn(x, y * .25, 14, 5) * 6 + vn(x, y, 40, 9) * 3)
    local v = .56 - nx * .3 + ridge * .17 + (vn(x * 1.0, y * .1, 1.8, 5) - .5) * .3 + (hash(x // 2, y // 6, 4) < .06 and -.2 or 0)
    if y > 200 then v = v - (y - 200) * .01 end
    local t = GX.idx(v, { .1, .3, .46, .64, .82 })
    if ridge < -.86 and y > 150 then t = 1 end
    if ridge > .9 and y > 150 and v > .45 then t = min(6, t + 1) end
    if y > 150 and hash(x // 5, y // 9, 11) < .05 and ridge < .2 then t = 1 end
    P(x, y, TIMB[t])
  end)
  for i = 1, 150 do local x, y = 70 + floor(hash(i, 1, 6) * 340), 150 + floor(hash(i, 2, 6) * 80); if body:has(x, y) and y > 170 and vn(x, y, 6, 3) > .5 then P(x, y, GREEN[2 + i % 3]) end end
  -- tiny door in the bark
  local dm = rect(300, 178, 312, 198):add(ell(306, 178, 6, 5)); c:rim(dm, INK); c:fillMask(dm, "#f0a050"); c:fillMask(rect(300, 190, 312, 198), "#ffd070"); glow(306, 190, 20, "#ffd070", .5)
  for y = 178, 198 do P(306, y, "#8a4a30") end; P(309, 190, INK); c:fillMask(rect(298, 198, 314, 200), OAK[3])
  -- the ring top
  local top = ell(240, 138, 170, 56)
  c:rim(top, INK)
  top:each(function(x, y)
    local nx, ny = (x - 240) / 170, (y - 138) / 56
    local dd = sqrt(nx * nx + ny * ny) + (vn(x, y, 20, 3) - .5) * .05
    local ringn = dd * 46 + (vn(x, y, 30, 8) - .5) * 1.6
    local fr = ringn - floor(ringn)
    local t = (fr < .3) and 3 or ((fr < .7) and 5 or 4)
    if fr < .12 then t = 2 end
    if floor(ringn) % 9 == 0 and fr < .7 then t = 2 end
    if dd > .93 then t = 3 end; if dd > .97 then t = 2 end
    if dd < .05 then t = 2 elseif dd < .1 then t = 3 end
    if ((x + y * .5) % 96) < 26 then t = min(6, t + 1) end
    P(x, y, OAK[t])
  end)
  -- quirk: ladybug walking round a ring, and a snail
  local lx, ly = 330, 120
  c:fillMask(ell(lx, ly, 3, 2), INK); c:fillMask(ell(lx, ly, 2, 1), "#e8493b"); P(lx, ly, INK); P(lx - 1, ly - 1, "#ff9a8a"); P(lx + 3, ly, INK)
  P(150, 130, "#8a5a38")
  local sm = ell(150, 132, 4, 3); c:rim(sm, INK); c:fillMask(sm, "#d4783c"); P(149, 131, "#f0a868"); c:fillMask(rect(145, 135, 154, 136), "#e8cfa4")
  -- mushrooms and ferns at the base
  for _, m in ipairs{ { 40, 222, 4, "#e8493b" }, { 52, 230, 3, "#f5809f" }, { 436, 226, 4, "#e8493b" }, { 448, 232, 3, "#ffd24a" } } do
    c:fillMask(rect(m[1], m[2] - 4, m[1] + 1, m[2]), "#f4e6c8")
    local cap = ell(m[1], m[2] - 6, m[3], 3); c:rim(cap, INK); c:fillMask(cap, m[4]); P(m[1] - 1, m[2] - 7, "#fff2dc"); P(m[1] + 2, m[2] - 6, "#fff2dc")
  end
  for _, b in ipairs{ { 90, 252, 50, 16 }, { 400, 254, 56, 16 }, { 250, 262, 70, 12 } } do GX.foliage(c, b[1], b[2], b[3], b[4], R4(LEAF), b[1]) end
  for i, p in ipairs{ { 20, 246 }, { 150, 250 }, { 330, 252 } } do GX.flower(c, p[1], p[2], ({ "#ffd24a", "#fff2dc", "#c8b8ec" })[i]) end
  for i = 1, 24 do local x, y = floor(hash(i, 1, 5) * 470) + 4, floor(hash(i, 2, 5) * 150) + 20; P(x, y, "#fff4b0") end
end

---------------------------------------------------------------- 8. VOLCANO SPICE GARDENS
F["wonder-volcano-spice-gardens"] = function()
  local VR = { "#2a1c28", "#46303a", "#6a4a4a", "#8e6858", "#b48c70", "#d8b496" }
  sky({ "#5a7ac0", "#7a9ad0", "#b0b4d8", "#e8b8c0", "#f8d4b0", "#fce8c0" }, 3, 170)
  c:cloud(30, 60, 60, "#fff4e0", "#d8c4d8"); c:cloud(400, 40, 52, "#fff4e0", "#d8c4d8")
  local WT = { "#1e4a6a", "#2a6a8a", "#3a86a4", "#52a0b8", "#78bccc", "#a8dce0" }
  for y = 160, 224 do for x = 0, 479 do local v = .75 - (y - 160) / 70 * .5 + (vn(x, y * 2.4, 10, 3) - .5) * .25; P(x, y, WT[GX.idx(v, { .2, .36, .5, .62, .8 })]) end end
  for i = 1, 40 do local x, y = floor(hash(i, 1, 5) * 470), 166 + floor(hash(i, 2, 5) * 50); if x < 80 or x > 400 then for k = 0, 3 do P(x + k, y, WT[6]) end end end
  -- the cone: tall, concave flanks
  local TOP = 50
  local hwf = function(y) return 16 + 204 * ((y - TOP) / (216 - TOP)) ^ 1.7 end
  local vm = HP.mask()
  for y = TOP, 216 do local hw = hwf(y); for x = floor(240 - hw), floor(240 + hw) do vm:set(x, y) end end
  vm = GX.rough(vm, 4, 1)
  solid(vm, VR, { R = 30, tex = .5, sc = 6, seed = 7, amb = .25, fn = function(x, y) return ((240 - x) / 250) * .28 + sin(x * .35 + (y * .05)) * .05 end })
  -- ridges down the flanks
  for k = -5, 5 do
    for y = TOP + 14, 214 do
      local hw = hwf(y); local x = floor(240 + k * hw / 5.6 + sin(y * .08 + k) * 3)
      if vm:has(x, y) and (y + k) % 4 < 3 then P(x, y, k < 0 and VR[5] or VR[2]) end
    end
  end
  -- curved terraces: each ring wraps the cone, front edge bows downward
  local crops = { { "#e8493b", "#ff9a8a" }, { "#a078d0", "#d8c0f4" }, { "#f0b020", "#ffe080" }, { "#4aa05a", "#9ce084" }, { "#f5803c", "#ffc080" } }
  local lv = { 110, 123, 136, 149, 162, 175, 188, 201 }
  local function arc(j, x) local y0 = lv[j]; local hw = hwf(y0) - 4; local dx = (x - 240) / hw; if abs(dx) >= 1 then return nil end; return y0 + hw * .17 * sqrt(1 - dx * dx) end
  for j = 1, #lv do
    local col = crops[j % #crops + 1]
    for x = 0, 479 do
      local ya = arc(j, x)
      if ya then
        ya = floor(ya)
        local yb = (j < #lv and arc(j + 1, x)) and floor(arc(j + 1, x)) or ya + 14
        for y = ya + 1, min(yb - 1, ya + 15) do
          if vm:has(x, y) then P(x, y, (y - ya) < 3 and "#8a5c3c" or (((x + y * 2) % 11 == 0) and "#5a3a2a" or ((x // 2 + j) % 7 == 0 and "#8a5c3c" or "#7a4e34"))) end
        end
        if vm:has(x, ya) then P(x, ya, STONE[5]) end
        if vm:has(x, ya - 1) then P(x, ya - 1, STONE[4]) end
        if vm:has(x, ya + 1) then P(x, ya + 1, STONE[2]) end
        if x % 6 == 0 and vm:has(x, ya + 1) then P(x, ya, STONE[3]) end
      end
    end
    for _, off in ipairs{ 6, 11 } do
      for x = floor(240 - hwf(lv[j])) + 6, floor(240 + hwf(lv[j])) - 6, 5 do
        local ya = arc(j, x)
        if ya and vm:has(x, floor(ya) + off) then
          local yy = floor(ya) + off + floor((x // 5 + off) % 2)
          c:fillMask(ell(x, yy, 3, 2), INK); c:fillMask(ell(x, yy, 2, 1), col[1]); P(x - 1, yy - 1, col[2])
        end
      end
    end
  end
  -- crater, lava streams and smoke
  c:fillMask(ell(240, TOP + 2, 22, 6), VR[2]); c:fillMask(ell(240, TOP + 1, 18, 4), "#f5803c"); c:fillMask(ell(240, TOP + 1, 11, 2), "#ffe05a")
  glow(240, TOP - 2, 52, "#ffa040", .5)
  local LAV = { { 232, 56, 10 }, { 262, 56, 8 }, { 250, 58, 9 } }
  local function stream(x0, y0, sway, w0, w1, y1, seed)
    local m = HP.mask()
    for y = y0, y1 do
      local t = (y - y0) / (y1 - y0)
      local x = x0 + sin(y * .09 + seed) * sway * (.4 + t) + (x0 - 240) * t * .9
      local w = floor(w0 + (w1 - w0) * t)
      for xx = floor(x - w), floor(x + w) do if vm:has(xx, y) then m:set(xx, y) end end
    end
    c:rim(m, "#5a1c20"); c:fillMask(m, "#e0502c")
    m:each(function(x, y) if m:has(x + 2, y) and m:has(x - 2, y) then P(x, y, "#f58a34") end if m:has(x + 4, y) and m:has(x - 4, y) and m:has(x, y - 2) and (x + y) % 3 ~= 0 then P(x, y, "#ffd45a") end end)
    for y = y0, y1, 9 do for xx = x0 - 30, x0 + 40 do end end
  end
  stream(236, TOP + 6, 5, 1, 5, 186, 0); stream(252, TOP + 8, 4, 1, 4, 160, 2.2); stream(228, TOP + 10, 6, 1, 3, 120, 4)
  for k, p in ipairs{ { 250, 36, 12 }, { 262, 22, 15 }, { 282, 10, 17 }, { 308, 4, 17 }, { 338, 2, 16 } } do
    local sm = ell(p[1], p[2], p[3], p[3] - 2); c:rim(sm, "#5a4a60"); c:fillMask(sm, mixc("#e8c8c0", "#6a5a78", k / 6)); P(p[1] - 3, p[2] - 3, "#f8e4dc"); P(p[1] - 4, p[2] - 2, "#f8e4dc")
  end
  for i = 1, 22 do local x, y = 240 + floor((hash(i, 1, 4) - .3) * 60), TOP - 4 - floor(hash(i, 2, 4) * 36); P(x, y, "#ffa040"); if i % 3 == 0 then P(x + 1, y, "#ffe05a") end end
  -- palms and foreground
  palm(34, 226, 60, -10); palm(452, 226, 66, 12)
  ground(function(x) return 216 + floor(sin(x / 35) * 1.5) end, { "#4a2a28", "#6a3a2e", "#8e5236", "#b06c40", "#cc8a52", "#e4a868" }, 5, { tex = .45, fall = .4 })
  for r = 0, 2 do   -- rows of chili in the foreground
    for x = 10 + r * 14, 470, 18 do
      local y = 236 + r * 14
      if abs(x - 240) > 70 or r == 2 then GX.foliage(c, x, y - 6, 8, 5, R4(GREEN), x + r); c:fillMask(rect(x - 2, y - 4, x - 1, y - 1), "#e8493b"); P(x + 2, y - 3, "#f5803c"); P(x + 2, y - 2, "#e8493b") end
    end
  end
  -- spice bowls: the offering at the centre front
  for k, b in ipairs{ { 190, 252, "#e8493b", "#ff9a8a" }, { 240, 256, "#f0b020", "#ffe080" }, { 290, 252, "#a078d0", "#d8c0f4" } } do
    local bowl = ell(b[1], b[2], 22, 9):clip(rect(b[1] - 24, b[2], b[1] + 24, b[2] + 12)):add(rect(b[1] - 22, b[2] - 2, b[1] + 22, b[2]))
    local mound = poly{ { b[1] - 18, b[2] - 1 }, { b[1] - 6, b[2] - 14 }, { b[1] + 6, b[2] - 14 }, { b[1] + 18, b[2] - 1 } }
    solid(mound, { mixc(b[3], "#000000", .5), mixc(b[3], "#000000", .3), mixc(b[3], "#000000", .15), b[3], b[4], mixc(b[4], "#ffffff", .5) }, { R = 6, tex = .5, sc = 2, seed = k })
    solid(bowl, TIMB, { R = 7, tex = .2 })
    for x = b[1] - 20, b[1] + 20, 5 do P(x, b[2] + 3, GOLD[5]) end
  end
  -- quirk: a little fire salamander on a rock
  solid(ell(404, 254, 16, 8), VR, { R = 8, tex = .5, seed = 3 })
  local sl = ell(404, 244, 7, 3):add(c:line({ { 410, 244 }, { 420, 240 }, { 428, 244 } }, 2)):add(ell(396, 242, 3, 3))
  c:rim(sl, INK); c:fillMask(sl, "#f5803c"); for x = 399, 421, 4 do P(x, 243, "#ffe05a"); P(x + 1, 244, INK) end
  P(395, 241, INK); P(394, 244, "#e8493b"); c:fillMask(rect(398, 246, 399, 249), "#f5803c"); c:fillMask(rect(410, 246, 411, 249), "#f5803c")
  c:sparkle(150, 100); c:sparkle(330, 120)
end

local ok, err = xpcall(F[name], debug.traceback); if not ok then print(err) end
c:hem(2); c:hem(267)
c:save{ aseprite = d .. "/out/" .. name .. ".aseprite", png = d .. "/out/" .. name .. ".png", scale = 1 }
end

local ALL = { "wonder-thousand-rings-stump", "wonder-volcano-spice-gardens" }
if NAME == "all" then for _, n in ipairs(ALL) do build(n) end else build(NAME) end
