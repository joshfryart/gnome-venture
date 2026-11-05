-- finish2/lair1: six LAIR pictures (480x270), param name=toad|owl|lizard|wyrm|spider|wolf|all. (condor is copied from p7.)
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d .. "/../../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.pi
local H = X.hash
local INK = GX.INK
local NAME = app.params.name or "all"
local mk = function() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, floor(cx), floor(cy), rx, ry or rx) end
local function R6(t) return GX.ramp6(t) end

local c
local function lit(m, R, seed, o)
  o = o or {}
  o.R = o.R or 8; o.tex = o.tex or .4; o.sc = o.sc or 4; o.seed = seed; if o.rimlight == nil then o.rimlight = true end; o.amb = o.amb or .25
  return GX.lit(c, m, type(R) == "function" and R or R6(R), o)
end
local function rough(m, s) return GX.rough(m, s, 1) end
local function line(x0, y0, x1, y1, col, w)
  local n = max(abs(x1 - x0), abs(y1 - y0), 1)
  for i = 0, n do
    local x, y = floor(x0 + (x1 - x0) * i / n + .5), floor(y0 + (y1 - y0) * i / n + .5)
    c:px(x, y, col); if w and w > 1 then c:px(x, y + 1, col) end
  end
end
local function stars(y1, seed, n, col)
  for i = 1, n do
    local x, y = floor(H(i, seed, 1) * 479), floor(H(i, seed, 2) * y1)
    local o = c:get(x, y)
    c:px(x, y, col or "#fff0c8")
    if i % 7 == 0 then c:px(x - 1, y, col or "#fff0c8"); c:px(x + 1, y, col or "#fff0c8"); c:px(x, y - 1, col or "#fff0c8"); c:px(x, y + 1, col or "#fff0c8") end
  end
end
local function snowfall(seed, n, col)
  for i = 1, n do
    local x, y = floor(H(i, seed, 3) * 479), floor(H(i, seed, 4) * 262)
    c:px(x, y, col or "#f4f4ee"); if i % 3 == 0 then c:px(x + 1, y, col or "#f4f4ee") end
  end
end
local function halo(cx, cy, r, ry, t, seed, col)
  local m = mk(); E(m, cx, cy, r, ry); m = rough(m, seed)
  m:each(function(x, y) local o = c:get(x, y); if o then c:px(x, y, GX.mix(o, col, t)) end end)
end
local function disc(cx, cy, r, R, seed)
  local m = mk(); E(m, cx, cy, r, r); m = rough(m, seed)
  lit(m, R, seed, { R = r, tex = .2, ink = false, rimlight = false, amb = .5 })
end
local function pine(x, by, h, R, SN, seed)
  local tr = mk(); for y = by - 8, by do for xx = x - 2, x + 2 do tr:set(xx, y) end end
  lit(tr, { hi = "#a8704a", base = "#6e4a48", shade = "#4a3040", deep = "#2e2034" }, seed, { R = 3 })
  for i = 4, 1, -1 do
    local yt = by - h + (i - 1) * floor(h / 5)
    local th, w = floor(h / 3.3), 5 + i * floor(h / 11)
    local yb = yt + th
    local m = c:poly{ { x, yt }, { x + w, yb }, { x + floor(w * .5), yb - 3 }, { x, yb }, { x - floor(w * .5), yb - 3 }, { x - w, yb } }
    m = rough(m, seed + i)
    lit(m, R, seed + i, { R = 6, tex = .5, sc = 3 })
    m:each(function(xx, yy) if not m:has(xx, yy - 2) and not m:has(xx - 1, yy - 1) or (not m:has(xx, yy - 1) and (xx + yy) % 2 == 0 and xx < x + w * .4) then c:px(xx, yy, SN[6]) elseif not m:has(xx, yy - 3) then c:px(xx, yy, SN[5]) end end)
  end
end
local function cavefill(m, y0, y1)
  m:each(function(x, y) local t = (y - y0) / max(1, y1 - y0); c:px(x, y, t > .6 and "#241830" or "#1b1223") end)
end
-- glowing eye: round or slit pupil
local function eye(x, y, rx, ry, col, slit)
  local m = mk(); E(m, x, y, rx, ry)
  local R = R6(col)
  m:each(function(xx, yy) local t = ((xx - x) / rx) ^ 2 + ((yy - y) / ry) ^ 2; c:px(xx, yy, t < .25 and R[6] or (t < .6 and R[5] or R[4])) end)
  if slit then for yy = y - ry + 1, y + ry - 1 do c:px(x, yy, "#1a1020"); if rx > 3 then c:px(x + 1, yy, "#1a1020") end end
  else c:px(x, y, "#1a1020"); c:px(x, y + 1, "#1a1020") end
  c:px(x - floor(rx / 2), y - floor(ry / 2), "#fffbe0")
end
local function clawmarks(x, y, n, len, col, dx)
  for i = 0, n - 1 do
    local sx, sy = x + i * 5, y + i * (dx or 1)
    for k = 0, len do c:px(sx + floor(k * .35), sy + k, col); if k % 4 ~= 3 then c:px(sx + 1 + floor(k * .35), sy + k, GX.mix(col, "#ffffff", .25)) end end
  end
end
local function pawprint(x, y, col, sc)
  sc = sc or 1
  c:fillMask(c:ellipse(x, y, 2 * sc, 2 * sc), col)
  for _, p in ipairs{ { -3, -3 }, { -1, -4 }, { 1, -4 }, { 3, -3 } } do c:px(x + p[1] * sc, y + p[2] * sc, col) ; if sc > 1 then c:px(x + p[1] * sc, y + p[2] * sc - 1, col) end end
end
local function finish(name)
  c:hem(2); c:hem(267)
  c:save{ aseprite = d .. "/out/" .. name .. ".aseprite", png = d .. "/out/" .. name .. ".png", scale = 1 }
end
local function layer(peaks, cap, R, seed, haze, ybot, hz)
  local R6s = R6(R)
  local function ridge(x)
    local best = cap
    for _, p in ipairs(peaks) do best = min(best, p[2] + abs(x - p[1]) * p[3]) end
    return floor(best + (GX.vn(x, 0, 5, seed) - .5) * 6)
  end
  for x = 0, 479 do
    local top = ridge(x); local sl = ridge(x + 3) - ridge(x - 3)
    for y = top, ybot do
      local v = .5 - sl * .04 + (GX.vn(x, y, 6, seed + 1) - .5) * .5
      if y - top < 2 and sl < 0 then v = .9 end
      local t = min(1, (y - top) / max(1, ybot - top)) * haze
      c:px(x, y, GX.mix(R6s[GX.idx(v)], hz, t))
    end
  end
end

local B = {}

---------------------------------------------------------------- 1. frost toad barrow
function B.toad()
  c = HP.canvas{ w = 480, h = 270, scale = 1, name = "lair-barrow-of-the-frost-toad" }
  GX.bands(c, 0, 170, { "#2c4478", "#3a5a8e", "#5078a4", "#74a0b8", "#a0c6c8", "#cfe2d4", "#f0ecd4" }, 3, .2)
  stars(60, 9, 40, "#e8f4ff")
  halo(390, 66, 52, 46, .15, 3, "#f4fff0"); halo(390, 66, 34, 30, .22, 4, "#f4fff0")
  disc(390, 66, 20, { hi = "#ffffff", base = "#e4f4e8", shade = "#a8cccc", deep = "#7aa0b8" }, 5)
  layer({ { 30, 140, .6 }, { 150, 128, .7 }, { 330, 136, .6 }, { 460, 126, .7 } }, 160, { hi = "#f0f8f4", base = "#c0dcd8", shade = "#8cb4c4", deep = "#6890b0" }, 11, .35, 200, "#dfeee8")
  GX.ground(c, function(x) return 196 + floor((GX.vn(x, 0, 30, 4) - .5) * 8) end, { hi = "#ffffff", base = "#d8ecf0", shade = "#a4c4da", deep = "#7c9cc4" }, 12, { top = .85, fall = .5, tex = .3 })
  -- the barrow mound
  local mound = mk()
  for y = 100, 216 do for x = 40, 440 do
    local t = ((x - 240) / 200) ^ 2 + ((y - 214) / 114) ^ 2
    if t <= 1 then mound:set(x, y) end
  end end
  mound = rough(mound, 14)
  local GREEN = R6({ hi = "#b4e090", base = "#5fa860", shade = "#397a62", deep = "#235060" })
  local FROST = R6({ hi = "#ffffff", base = "#e0f2f4", shade = "#a8cce0", deep = "#7a9ec8" })
  local v = lit(mound, function(x, y) return (GX.vn(x, y, 14, 15) + (130 - y) * .004 > .6 or y < 118 + GX.vn(x, 0, 9, 16) * 14) and FROST or GREEN end, 14, { R = 22, tex = .5, sc = 4 })
  -- turf tufts and frost sparkles on the slope
  for i = 1, 26 do
    local x, y = 60 + floor(H(i, 20, 1) * 360), 150 + floor(H(i, 20, 2) * 60)
    if mound:has(x, y) and mound:has(x + 4, y) and (x < 175 or x > 305 or y < 160) then GX.tuft(c, x, y, { hi = "#d8f0b0", base = "#5fa860", shade = "#2e6a5c" }) end
  end
  -- doorway: two standing stones + lintel, dark hole between
  local hole = c:poly{ { 212, 214 }, { 212, 176 }, { 220, 162 }, { 260, 162 }, { 268, 176 }, { 268, 214 } }
  cavefill(hole, 162, 214)
  -- silhouette of a huge toad hunched in the dark
  local body = mk(); E(body, 240, 202, 26, 17); E(body, 240, 190, 20, 12)
  body:each(function(x, y) if hole:has(x, y) then c:px(x, y, ((y < 184 or x < 224) and "#2e4a5e" or "#244050")) end end)
  for _, p in ipairs{ { 232, 196 }, { 246, 200 }, { 240, 190 }, { 252, 194 }, { 228, 204 } } do c:px(p[1], p[2], "#3e6478"); c:px(p[1] + 1, p[2], "#3e6478") end
  eye(228, 183, 5, 5, { hi = "#f8ffb0", base = "#c8e858", shade = "#7cb050", deep = "#3c7048" }, true)
  eye(252, 183, 5, 5, { hi = "#f8ffb0", base = "#c8e858", shade = "#7cb050", deep = "#3c7048" }, true)
  for x = 222, 258 do c:px(x, 182 - ((x - 240) ^ 2 > 250 and 0 or 1) - 3, "#1b1223") end   -- heavy brow
  local STONE = { hi = "#e8f0f4", base = "#a4b4cc", shade = "#6c7ca0", deep = "#46507c" }
  local function slab(x0, y0, x1, y1, seed)
    local m = mk(); for y = y0, y1 do for x = x0, x1 do m:set(x, y) end end
    m = rough(m, seed)
    lit(m, STONE, seed, { R = 8, tex = .5, sc = 3 })
    m:each(function(x, y) if y < y0 + 3 and H(x // 3, 0, seed) < .8 then c:px(x, y, "#ffffff") end end)
    return m
  end
  slab(205, 168, 214, 216, 21); slab(266, 168, 275, 216, 22); slab(198, 154, 282, 166, 23)
  for _, x in ipairs{ 216, 236, 258 } do c:px(x, 160, STONE.deep); c:px(x + 1, 160, STONE.deep) end
  -- runes on the lintel
  for i = 0, 4 do local x = 214 + i * 12; c:px(x, 158, "#7cd8e8"); c:px(x, 159, "#7cd8e8"); c:px(x + 1, 160, "#7cd8e8"); c:px(x - 1, 157, "#7cd8e8") end
  -- quirk: a red scarf tied round the left stone
  for x = 204, 215 do c:px(x, 186, "#d84a48"); c:px(x, 187, "#a8323f"); c:px(x, 185, INK) end
  for y = 188, 197 do c:px(212, y, "#d84a48"); c:px(213, y, "#a8323f") end
  c:px(212, 198, "#e86858")
  -- frozen pond in front with a frozen fly
  local pond = mk(); E(pond, 120, 244, 74, 16); E(pond, 380, 248, 60, 13); pond = rough(pond, 31)
  lit(pond, { hi = "#f4ffff", base = "#a8dcec", shade = "#68a8d0", deep = "#4478b0" }, 31, { R = 14, tex = .3, sc = 6 })
  for _, l in ipairs{ { 70, 240, 100, 236 }, { 110, 250, 150, 247 }, { 350, 248, 390, 252 }, { 400, 242, 420, 240 } } do line(l[1], l[2], l[3], l[4], "#e8fcff") end
  c:px(130, 243, INK); c:px(131, 243, INK); c:px(130, 242, "#7cd8e8"); c:px(132, 242, "#e8fcff")
  -- toad prints in the snow leading to the door
  for i, p in ipairs{ { 226, 224 }, { 252, 230 }, { 232, 238 }, { 256, 218 } } do pawprint(p[1], p[2], "#8cacd0", 1) end
  -- ice crystals either side of the door
  local function crystal(x, y, h, w)
    local m = c:poly{ { x - w, y }, { x - floor(w / 3), y - h }, { x + floor(w / 2), y - floor(h * .7) }, { x + w, y } }
    lit(m, { hi = "#ffffff", base = "#a8e4f4", shade = "#5ab0e0", deep = "#3a78c0" }, x, { R = 5, tex = .2 })
  end
  crystal(180, 218, 22, 6); crystal(190, 220, 14, 5); crystal(300, 220, 24, 7); crystal(312, 222, 14, 5); crystal(60, 240, 14, 5)
  snowfall(7, 60)
end

---------------------------------------------------------------- 3. great white owl den
function B.owl()
  c = HP.canvas{ w = 480, h = 270, scale = 1, name = "lair-den-of-the-great-white-owl" }
  GX.bands(c, 0, 200, { "#1a1a44", "#26285a", "#343a74", "#4a4e8a", "#6c68a0", "#9a88b4" }, 5, .2)
  stars(120, 3, 90)
  halo(76, 64, 44, 40, .14, 3, "#f8f0d0"); halo(76, 64, 30, 27, .22, 4, "#f8f0d0")
  do local m = mk(); E(m, 76, 64, 17, 17); local cut = mk(); E(cut, 84, 60, 15, 15); m:cut(cut); m = rough(m, 5)
    lit(m, { hi = "#fffce8", base = "#f8ecc0", shade = "#e0c890", deep = "#b49a88" }, 5, { R = 5, tex = .1, ink = false, rimlight = false }) end
  layer({ { 60, 150, .7 }, { 200, 136, .6 }, { 400, 144, .7 }, { 480, 150, .6 } }, 170, { hi = "#a8a4cc", base = "#7c78b0", shade = "#5a5c98", deep = "#444880" }, 21, .3, 220, "#9a88b4")
  for _, p in ipairs{ { 40, 200, 70 }, { 76, 204, 54 }, { 430, 200, 72 }, { 462, 206, 52 }, { 395, 208, 44 } } do pine(p[1], p[2], p[3], { hi = "#5c8c8c", base = "#366870", shade = "#264a5e", deep = "#1c3248" }, R6({ hi = "#ffffff", base = "#e4e8f4", shade = "#b0b8d8", deep = "#7c88b8" }), p[1]) end
  GX.ground(c, function(x) return 204 + floor((GX.vn(x, 0, 30, 4) - .5) * 8) end, { hi = "#f8f4fc", base = "#d4d0ec", shade = "#9c9cd0", deep = "#6c70b0" }, 12, { top = .85, fall = .5, tex = .3 })
  -- the great pale oak
  local BARK = { hi = "#f4ecf4", base = "#c8bcd8", shade = "#8c84b0", deep = "#5a5688" }
  GX.trunk(c, 190, 280, 30, 232, BARK, 31, { noink = false })
  -- branches (lit masks)
  local function branch(pts, w, seed)
    local m = c:line(pts, w); m = rough(m, seed); lit(m, BARK, seed, { R = 4, tex = .4 }); return m
  end
  branch({ { 196, 80 }, { 160, 62 }, { 120, 56 }, { 92, 44 } }, 6, 32)
  branch({ { 280, 70 }, { 316, 52 }, { 360, 50 }, { 392, 36 } }, 6, 33)
  branch({ { 150, 61 }, { 138, 38 } }, 3, 34); branch({ { 340, 51 }, { 352, 30 } }, 3, 35)
  -- hollow with a golden glow
  local hole = mk(); E(hole, 236, 118, 25, 33); E(hole, 236, 96, 19, 18); hole = rough(hole, 36)
  c:rim(hole, INK)
  hole:each(function(x, y) local t = ((x - 236) / 26) ^ 2 + ((y - 120) / 36) ^ 2; c:px(x, y, t > .75 and "#6a3a40" or (t > .45 and "#3e2634" or "#241828")) end)
  local sil = mk(); E(sil, 236, 140, 17, 20); E(sil, 236, 118, 15, 15)
  sil:each(function(x, y) if hole:has(x, y) then c:px(x, y, (y < 112) and "#d8cce0" or "#b8aed0") end end)   -- white feathered owl body in the dark
  sil:each(function(x, y) if hole:has(x, y) and (x // 2 + y // 3) % 3 == 0 and y > 124 then c:px(x, y, "#9a90bc") end end)
  -- ear tufts & brow
  for _, s in ipairs{ -1, 1 } do for i = 0, 6 do c:px(236 + s * (8 + i), 104 - i, "#f4ecf4"); c:px(236 + s * (8 + i), 105 - i, "#c8bcd8") end end
  eye(224, 116, 7, 7, { hi = "#fffbd8", base = "#ffc83c", shade = "#e08a2c", deep = "#a05028" }, false)
  eye(248, 116, 7, 7, { hi = "#fffbd8", base = "#ffc83c", shade = "#e08a2c", deep = "#a05028" }, false)
  for _, ex in ipairs{ 224, 248 } do for x = ex - 7, ex + 7 do c:px(x, 108 + floor(abs(x - ex) * .25), "#7a6a96") end end
  for x = 233, 239 do c:px(x, 122, "#f4a850") end; for x = 234, 238 do c:px(x, 123, "#c8783c"); c:px(x, 124, "#e89040") end
  -- claw marks on the bark
  clawmarks(206, 166, 4, 16, BARK.deep); clawmarks(256, 176, 3, 14, BARK.deep)
  -- ledge/perch lip under the hollow
  local lip = c:poly{ { 208, 152 }, { 264, 152 }, { 272, 160 }, { 200, 160 } }; lip = rough(lip, 37); lit(lip, BARK, 37, { R = 4 })
  -- pellet pile + feathers + prints in the snow
  for _, p in ipairs{ { 214, 228 }, { 224, 230 }, { 220, 226 }, { 232, 229 } } do
    local m = mk(); E(m, p[1], p[2], 4, 3); lit(m, { hi = "#c8b4a0", base = "#8a7468", shade = "#5e4a52", deep = "#3e3040" }, p[1], { R = 3, tex = .5 })
    c:px(p[1] - 1, p[2] - 1, "#e0d4c0")
  end
  local function feather(x, y, dir)
    for i = 0, 9 do local px, py = x + i * dir, y - floor(sin(i / 9 * 2.3) * 3); c:px(px, py, "#fffcf4"); c:px(px, py + 1, "#c8c0e0"); if i > 2 and i % 3 == 0 then c:px(px, py - 1, "#e8e4f4") end end
    c:px(x + 9 * dir, y - 2, "#8c84b0")
  end
  feather(160, 238, 1); feather(320, 232, -1); feather(284, 214, 1)
  for i = 0, 5 do pawprint(300 + i * 12, 224 + (i % 2) * 5, "#9a9cd0", 1) end
  -- quirk: a little lantern hung on the left branch
  line(104, 50, 104, 58, "#4a3040")
  do local m = mk(); for y = 58, 68 do for x = 100, 108 do m:set(x, y) end end
    lit(m, { hi = "#fffbd0", base = "#ffc84a", shade = "#e0902c", deep = "#9a5a30" }, 8, { R = 4, tex = .15 })
    for x = 99, 109 do c:px(x, 57, INK) end c:px(104, 62, "#fffff0"); c:px(104, 63, "#fffff0")
    halo(104, 63, 16, 14, .18, 9, "#ffd890") end
  snowfall(7, 70, "#f4f0fc")
end

---------------------------------------------------------------- 4. dragonlizard den
function B.lizard()
  c = HP.canvas{ w = 480, h = 270, scale = 1, name = "lair-dragonlizard-den" }
  GX.bands(c, 0, 170, { "#3a8ab8", "#5aa8c8", "#8cc8d0", "#c4dcc0", "#f8dca0", "#ffc27c", "#ff9c6c" }, 4, .22)
  halo(380, 90, 60, 52, .15, 3, "#fff0b0"); halo(380, 90, 40, 35, .2, 4, "#fff0b0")
  disc(380, 90, 22, { hi = "#ffffe0", base = "#ffe888", shade = "#ffbc58", deep = "#f08a54" }, 5)
  layer({ { 30, 130, 1.4 }, { 120, 110, 1.3 }, { 330, 120, 1.2 }, { 450, 106, 1.3 } }, 170, { hi = "#f4b88c", base = "#d8866c", shade = "#b0607c", deep = "#8a4a84" }, 11, .4, 200, "#ffd0a0")
  GX.ground(c, function(x) return 196 + floor((GX.vn(x, 0, 30, 4) - .5) * 8) end, { hi = "#ffe8a8", base = "#f0b870", shade = "#c88458", deep = "#9a5a54" }, 12, { top = .85, fall = .55, tex = .3 })
  -- the red-rock butte with the den mouth
  local butte = mk()
  for y = 40, 222 do
    local l = 70 + (y - 40) * .1 + (GX.vn(0, y, 10, 71) - .5) * 14
    local r = 340 - (y - 40) * .15 - (y < 70 and (70 - y) * 1.4 or 0) + (GX.vn(0, y, 10, 72) - .5) * 14
    if y < 70 then l = l + (70 - y) * 1.2 end
    for x = floor(l), floor(r) do butte:set(x, y) end
  end
  butte = rough(butte, 73)
  local RK = { hi = "#ffb890", base = "#d8704c", shade = "#a04450", deep = "#6a2c4c" }
  local cave = c:poly{ { 128, 226 }, { 126, 180 }, { 140, 150 }, { 176, 138 }, { 212, 152 }, { 226, 184 }, { 224, 226 } }
  local mc = cave:copy()
  lit(butte, function(x, y) return R6(RK) end, 73, { R = 20, tex = .55, sc = 5, fn = function(x, y) return (GX.vn(x * .4, y, 12, 74) > .6 and -.16 or 0) end })
  -- strata
  butte:each(function(x, y) if y % 17 == 0 and H(x // 5, y, 75) < .85 and not cave:has(x, y) then c:px(x, y, RK.shade) elseif y % 17 == 1 and H(x // 5, y, 75) < .6 and not cave:has(x, y) then c:px(x, y, RK.hi) end end)
  c:rim(cave, INK); cavefill(cave, 138, 226)
  eye(158, 176, 6, 5, { hi = "#ffffb8", base = "#ffd030", shade = "#e8882c", deep = "#a04a30" }, true)
  eye(192, 178, 6, 5, { hi = "#ffffb8", base = "#ffd030", shade = "#e8882c", deep = "#a04a30" }, true)
  for _, ex in ipairs{ 158, 192 } do for x = ex - 7, ex + 7 do c:px(x, 169 + floor(abs(x - ex) * .2) - (ex < 175 and 0 or 0), "#1b1223") end end
  for _, p in ipairs{ { 166, 192 }, { 172, 192 }, { 178, 192 }, { 184, 192 } } do c:px(p[1], p[2], "#f4ecd0"); c:px(p[1], p[2] + 1, "#f4ecd0") end   -- nostril/teeth glints hint
  c:px(168, 190, "#4a2c3c"); c:px(176, 190, "#4a2c3c")
  clawmarks(240, 120, 4, 22, RK.deep, 1); clawmarks(96, 130, 3, 18, RK.deep, 1)
  -- the scaly tail winding out of the den across the sand
  local path = {}
  for i = 0, 100 do
    local t = i / 100
    local x = 200 + t * 220 + sin(t * 6.2) * 20 * (1 - t * .4)
    local y = 214 + sin(t * 5.2 + .4) * 14 + t * 14 - (t > .8 and (t - .8) ^ 2 * 400 or 0)
    path[#path + 1] = { x, y, 17 * (1 - t) + 2.5 }
  end
  local tail = mk()
  for _, p in ipairs(path) do E(tail, p[1], p[2], max(2, floor(p[3])), max(2, floor(p[3] * .85))) end
  tail = rough(tail, 81)
  local OL = R6({ hi = "#e0ec80", base = "#8cb84c", shade = "#4e8450", deep = "#2e5a50" })
  local BEL = R6({ hi = "#fff0b0", base = "#f0cc78", shade = "#c8985c", deep = "#8a6458" })
  lit(tail, function(x, y) return BEL end, 82, { R = 10, tex = .3 })
  tail:each(function(x, y)   -- olive back with diamond pattern, cream underside
    local near = 1e9; local w = 1
    for i = 1, #path, 3 do local p = path[i]; local dd = (x - p[1]) ^ 2 + (y - p[2]) ^ 2; if dd < near then near = dd; w = i end end
    local p = path[w]; local rel = (y - p[2]) / max(2, p[3])
    local v = .55 - rel * .35 + (GX.vn(x, y, 3, 83) - .5) * .25 - ((x * .5 + y) % 6 < 1 and .15 or 0)
    if rel < .45 then
      local dx = floor(x / 5 + y / 5); local dy = floor(x / 5 - y / 5)
      if (dx + dy) % 3 == 0 and (floor(x) + floor(y)) % 5 < 2 then v = v - .22 end
      c:px(x, y, OL[GX.idx(max(0, min(1, v)))])
    end
  end)
  -- dorsal spines
  for i = 4, #path - 6, 7 do
    local p = path[i]; local h = max(3, floor(p[3] * .5))
    for k = 1, h do c:px(floor(p[1]) - floor(k / 3), floor(p[2] - p[3] * .85 - k), k > h - 2 and "#ffe8a0" or "#c8683c"); c:px(floor(p[1]) + 1 - floor(k / 3), floor(p[2] - p[3] * .85 - k), "#a04450") end
  end
  -- palms and a cactus
  local function palm(x, by, h, lean)
    local pts = {}
    for i = 0, h do pts[#pts + 1] = { x + sin(i / h * 1.2) * lean, by - i } end
    local tr = c:line(pts, 4); tr = rough(tr, x); lit(tr, { hi = "#d8a86c", base = "#a8704c", shade = "#704a4c", deep = "#3e2c40" }, x, { R = 3, tex = .5 })
    local tx, ty = x + sin(1.2) * lean, by - h
    for a = 0, 6 do
      local ang = a / 7 * pi * 1.3 + pi * .85
      local m = mk(); for k = 0, 22 do E(m, tx + cos(ang) * k * .95, ty + sin(ang) * k * .5 + (k * k) * .018, max(1, 3 - floor(k / 8)), 1) end
      lit(m, { hi = "#c8f080", base = "#58b058", shade = "#2e7a58", deep = "#1e4a50" }, x + a, { R = 3, tex = .3 })
    end
  end
  palm(60, 222, 60, 8); palm(436, 218, 56, -8)
  do local m = mk(); for y = 206, 238 do for x = 400, 408 do m:set(x, y) end end; for y = 216, 224 do for x = 388, 399 do m:set(x, y) end end; for y = 210, 218 do for x = 409, 418 do m:set(x, y) end end
    for y = 208, 216 do for x = 388, 392 do m:set(x, y) end end; for y = 200, 210 do for x = 414, 418 do m:set(x, y) end end
    lit(m, { hi = "#c8f080", base = "#58b058", shade = "#2e7a58", deep = "#1e4a50" }, 91, { R = 4, tex = .3 }); c:px(404, 205, "#ff7a8a"); c:px(403, 205, "#ff7a8a") end
  -- bones and a scattered pile of eggshell
  for i = 0, 6 do line(250 + i * 2, 246, 262 + i * 2, 248, "#f4ecd0") end
  for _, p in ipairs{ { 100, 244 }, { 112, 248 }, { 90, 250 } } do local m = mk(); E(m, p[1], p[2], 4, 3); lit(m, { hi = "#fffce8", base = "#f4e8c8", shade = "#c8a8a0", deep = "#8a6c84" }, p[1], { R = 3, tex = .1 }) end
  -- quirk: a tiny gnome hat (non-player red cap) hanging on a cactus spike
  for _, p in ipairs{ { 411, 203, "#e8493b" }, { 412, 203, "#e8493b" }, { 411, 202, "#ff8a70" }, { 413, 204, "#b52e3f" }, { 410, 204, "#b52e3f" } } do c:px(p[1], p[2], p[3]) end
end

---------------------------------------------------------------- 5. forge of the cinder wyrm
function B.wyrm()
  c = HP.canvas{ w = 480, h = 270, scale = 1, name = "lair-forge-of-the-cinder-wyrm" }
  GX.ground(c, function(x) return 0 end, { hi = "#9a5a58", base = "#5e3448", shade = "#3c2240", deep = "#261630" }, 5, { top = .62, fall = .3, tex = .8, sc = 9 })
  local furn = c:poly{ { 168, 218 }, { 168, 100 }, { 180, 68 }, { 240, 50 }, { 300, 68 }, { 312, 100 }, { 312, 218 } }
  -- heat glow on the walls
  for r, t in ipairs{ .1, .15, .2 } do local m = mk(); E(m, 240, 150, 190 - r * 40, 120 - r * 20); m = rough(m, 6 + r)
    m:each(function(x, y) local o = c:get(x, y); if o and not furn:has(x, y) then c:px(x, y, GX.mix(o, "#ff9a4a", t)) end end) end
  -- furnace arch
  local FR = { hi = "#c89090", base = "#8a5a6e", shade = "#5c3a58", deep = "#3a2646" }
  local frame = furn:copy():grow(7); lit(frame, FR, 11, { R = 12, tex = .5, sc = 4 })
  furn:each(function(x, y) local t = (y - 50) / 168; local v = t + (GX.vn(x, y, 6, 12) - .5) * .5
    c:px(x, y, v > .62 and "#ffe66a" or (v > .42 and "#ffb43c" or (v > .22 and "#f26a2c" or "#c8402c"))) end)
  -- flame tongues
  for i = 0, 8 do local x = 176 + i * 16; for k = 0, 22 + floor(H(i, 13, 1) * 26) do c:px(x + floor(sin(k / 5 + i) * 2), 217 - k, k > 16 and "#ffe66a" or "#ffd048") ; c:px(x + 1 + floor(sin(k / 5 + i) * 2), 217 - k, "#ffb43c") end end
  -- brick lines on frame
  frame:each(function(x, y) if not furn:has(x, y) and (y % 10 == 0 or (x + (y // 10) * 7) % 16 == 0) and H(x, y, 14) < .8 then c:px(x, y, FR.deep) end end)
  -- WYRM: a huge slit eye glowing in the dark crevice above, pair of nostril embers
  local cre = c:poly{ { 340, 20 }, { 440, 14 }, { 462, 110 }, { 424, 160 }, { 372, 150 }, { 346, 90 } }
  cre = rough(cre, 15); c:rim(cre, INK); cavefill(cre, 14, 160)
  eye(386, 70, 9, 8, { hi = "#fffbb0", base = "#ff9a2c", shade = "#e04a2c", deep = "#8a2c3c" }, true)
  eye(420, 74, 7, 6, { hi = "#fffbb0", base = "#ff9a2c", shade = "#e04a2c", deep = "#8a2c3c" }, true)
  for x = 374, 396 do c:px(x, 61 + floor(abs(x - 385) * .3), "#4a2438") end
  for x = 411, 430 do c:px(x, 67 + floor(abs(x - 420) * .3), "#4a2438") end
  for _, p in ipairs{ { 398, 98 }, { 408, 100 } } do c:px(p[1], p[2], "#e04a2c"); c:px(p[1] + 1, p[2], "#ff9a2c") end
  for k = 0, 16 do c:px(392 + k, 118 + floor(sin(k) * 1.2), (k % 3 == 0) and "#f4ecd0" or "#bca0a0"); if k % 3 == 0 then c:px(392 + k, 120, "#f4ecd0") end end   -- teeth hint
  -- stalactites
  for _, s in ipairs{ { 30, 30 }, { 90, 46 }, { 140, 26 }, { 330, 38 }, { 20, 80 }, { 470, 30 } } do
    local m = c:poly{ { s[1] - 12, 0 }, { s[1] + 12, 0 }, { s[1] + 2, s[2] + 20 }, { s[1] - 1, s[2] + 34 }, { s[1] - 3, s[2] + 16 } }
    m = rough(m, s[1]); lit(m, { hi = "#c08c8c", base = "#7a4c64", shade = "#503050", deep = "#321c3c" }, s[1], { R = 6, tex = .5 })
  end
  -- lava river in front
  GX.ground(c, function(x) return 222 + floor((GX.vn(x, 0, 25, 4) - .5) * 8) end, { hi = "#ffe66a", base = "#ff9a2c", shade = "#e04a2c", deep = "#9a2c3c" }, 17, { top = .9, fall = .6, tex = .55, sc = 6 })
  for i = 1, 18 do local x, y = floor(H(i, 18, 1) * 470), 232 + floor(H(i, 18, 2) * 32); line(x, y, x + 10, y + (i % 3) - 1, "#fff0a0") end
  -- obsidian platform with anvil
  local plat = mk(); for y = 196, 236 do for x = 40, 144 do if y >= 196 + floor((x - 40) * .0) then plat:set(x, y) end end end
  plat = rough(plat, 19); lit(plat, { hi = "#a08ca8", base = "#5a4a6e", shade = "#3a2e54", deep = "#261c3c" }, 19, { R = 10, tex = .5 })
  local an = c:poly{ { 52, 184 }, { 112, 184 }, { 118, 190 }, { 100, 194 }, { 96, 210 }, { 112, 214 }, { 112, 218 }, { 58, 218 }, { 58, 214 }, { 76, 210 }, { 72, 194 }, { 60, 192 } }
  lit(an, { hi = "#c0c4e0", base = "#7a80a0", shade = "#4c5278", deep = "#2e3258" }, 20, { R = 8, tex = .3 })
  for x = 54, 110 do c:px(x, 185, "#e8ecff") end
  for x = 70, 100 do c:px(x, 186, "#ff9a4a") end; c:px(86, 182, "#ffe66a"); c:px(84, 181, "#ffb43c"); c:px(90, 180, "#ffe66a")
  -- hammer leaning on the platform
  line(128, 218, 118, 188, "#6e4a48", 2); local hm = c:poly{ { 110, 182 }, { 126, 182 }, { 126, 192 }, { 110, 192 } }; lit(hm, { hi = "#c0c4e0", base = "#7a80a0", shade = "#4c5278", deep = "#2e3258" }, 21, { R = 4 })
  -- chains hanging from the top
  for _, x in ipairs{ 150, 330 } do for y = 0, 56, 4 do c:px(x, y, "#8a80a0"); c:px(x + 1, y, "#8a80a0"); c:px(x, y + 1, "#4a4068"); c:px(x - 1 + (y // 4 % 2) * 3, y + 2, "#6a6088") end end
  -- ember dots and smoke puffs (hard pixels)
  for i = 1, 55 do local x, y = floor(H(i, 22, 1) * 470), floor(H(i, 22, 2) * 220); c:px(x, y, i % 3 == 0 and "#ffe66a" or "#ff8a3a") end
  for i, p in ipairs{ { 236, 36, 7 }, { 248, 22, 6 }, { 230, 10, 5 } } do local m = mk(); E(m, p[1], p[2], p[3], p[3] - 1); lit(m, { hi = "#a08ca8", base = "#6e5a78", shade = "#4a3c62", deep = "#2e2448" }, i, { R = 5, tex = .3, ink = false }) end
  -- quirk: a tiny mug of cooling tea on the platform
  do local m = mk(); for y = 208, 217 do for x = 130, 138 do m:set(x, y) end end
    lit(m, { hi = "#f4ecd0", base = "#e8b878", shade = "#b87c64", deep = "#7a4c5c" }, 23, { R = 3, tex = .1 }); c:px(139, 211, INK); c:px(140, 212, INK); c:px(139, 213, INK); c:px(133, 207, "#c8c0d8"); c:px(135, 205, "#c8c0d8") end
end

---------------------------------------------------------------- 6. hollow of the silverback spider
function B.spider()
  c = HP.canvas{ w = 480, h = 270, scale = 1, name = "lair-hollow-of-the-silverback-spider" }
  GX.bands(c, 0, 270, { "#1c3a3c", "#234a42", "#2c5a48", "#366a4c", "#487a50" }, 5, .3)
  -- background trunks
  for i, x in ipairs{ 20, 70, 410, 450, 150, 330 } do
    local m = mk(); for y = 0, 230 do for xx = x - 12, x + 12 do m:set(xx, y) end end
    lit(m, { hi = "#4e8660", base = "#2e5e4c", shade = "#214438", deep = "#173026" }, i, { R = 10, tex = .5, ink = false, rimlight = false, fn = function() return -.12 end })
  end
  -- ground
  GX.ground(c, function(x) return 214 + floor((GX.vn(x, 0, 30, 4) - .5) * 8) end, { hi = "#b8784c", base = "#7a4a44", shade = "#4e3040", deep = "#34243a" }, 12, { top = .7, fall = .5, tex = .5 })
  -- the great hollow trunk
  local BARK = { hi = "#a88a7c", base = "#6e5660", shade = "#483c4e", deep = "#2e2a3c" }
  local tr = mk()
  for y = 20, 226 do local fl = max(0, y - 190) * .8; for x = floor(150 - fl), floor(330 + fl) do tr:set(x, y) end end
  tr = rough(tr, 31)
  local hole = c:poly{ { 186, 226 }, { 182, 150 }, { 196, 108 }, { 240, 86 }, { 284, 108 }, { 298, 150 }, { 294, 226 } }
  hole = rough(hole, 32)
  lit(tr, BARK, 33, { R = 24, tex = .6, sc = 3, fn = function(x, y) return (GX.vn(x * .25, y, 10, 34) < .3) and -.2 or 0 end })
  c:rim(hole, INK); cavefill(hole, 86, 226)
  -- eight eyes of the silverback
  local EC = { hi = "#ffffff", base = "#d8b8ff", shade = "#9a6adc", deep = "#5c3a98" }
  eye(222, 148, 7, 7, EC, false); eye(258, 148, 7, 7, EC, false)
  for _, p in ipairs{ { 210, 134, 3 }, { 270, 134, 3 }, { 234, 132, 3 }, { 246, 132, 3 }, { 200, 150, 2 }, { 280, 150, 2 } } do eye(p[1], p[2], p[3], p[3], EC, false) end
  -- silvery bristles: curved lines along the top of the dark shape
  for i = 0, 17 do local x = 214 + i * 3.2; local base = 172 + abs(i - 8.5) * 1.2
    for k = 0, 7 do c:px(floor(x - (i - 8.5) * k * .15), floor(base + k * .6), k < 4 and "#d8d8ec" or "#8c8cb0") end end
  -- fangs
  for _, s in ipairs{ -1, 1 } do for k = 0, 9 do c:px(240 + s * (7 - floor(k * .2)), 172 + k, "#f4ecd0"); c:px(240 + s * (8 - floor(k * .2)), 172 + k, "#a89cb8") end end
  -- legs reaching round the edges of the hollow (dark with silver rim) hint
  for _, s in ipairs{ -1, 1 } do
    local pts = { { 240 + s * 44, 170 }, { 240 + s * 56, 128 }, { 240 + s * 52, 102 } }
    local lg = c:line(pts, 4); lg = rough(lg, 40 + s)
    lg:each(function(x, y) if hole:has(x, y) then c:px(x, y, (x * s < 240 * s + 50) and "#3c3450" or "#2e2840"); if not lg:has(x - s, y) then c:px(x, y, "#b8b4d8") end end end)
  end
  -- web over the mouth: radial + rings
  local function web(cx, cy, R, col, col2, rr)
    for a = 0, 15 do local ang = a / 16 * 2 * pi; line(cx, cy, cx + cos(ang) * R, cy + sin(ang) * R * .9, col) end
    for r = 12, R, 12 do for a = 0, 63 do local ang = a / 64 * 2 * pi; local sag = sin(ang * 8) * 1.5
      c:px(floor(cx + cos(ang) * (r + sag)), floor(cy + sin(ang) * (r + sag) * .9), (a % 5 == 0) and col2 or col) end end
  end
  local hx = hole
  -- clip web to hollow mouth only
  local snapshot = {}
  web(240, 160, 60, "#c8c8e0", "#ffffff")
  -- fix: restore ink outside hollow rim? (web bleeds slightly onto trunk, acceptable as silk strands)
  -- corner webs on the trunk
  line(150, 30, 190, 60, "#d8d8ec"); line(190, 60, 160, 90, "#b8b8d4"); line(150, 30, 160, 90, "#b8b8d4"); line(170, 45, 175, 75, "#f0f0fa")
  line(330, 30, 296, 62, "#d8d8ec"); line(296, 62, 322, 96, "#b8b8d4"); line(330, 30, 322, 96, "#b8b8d4")
  -- dew drops on web
  for _, p in ipairs{ { 220, 120 }, { 262, 118 }, { 240, 100 }, { 204, 165 }, { 278, 170 } } do c:px(p[1], p[2], "#ffffff"); c:px(p[1], p[2] + 1, "#7ad8e8") end
  -- hanging silk cocoons
  for _, p in ipairs{ { 120, 120, 11 }, { 366, 130, 10 }, { 100, 70, 7 } } do
    line(p[1], 0, p[1], p[2] - p[3], "#c8c8e0")
    local m = mk(); E(m, p[1], p[2], p[3] - 3, p[3] + 3)
    lit(m, { hi = "#ffffff", base = "#dcd8ee", shade = "#a8a4cc", deep = "#6c6a9c" }, p[1], { R = 6, tex = .3 })
    m:each(function(x, y) if (y + x // 3) % 4 == 0 then c:px(x, y, "#8c88b8") end end)
  end
  -- quirk: a glowing firefly stuck in the left cocoon
  c:px(120, 118, "#ffe66a"); c:px(121, 118, "#ffe66a"); c:px(119, 118, "#fff8b0"); c:px(120, 117, "#fff8b0")
  halo(120, 118, 10, 10, .18, 7, "#ffe66a")
  -- mushrooms and leaf litter
  local function shroom(x, y, s, cap)
    for yy = y - 5 * s, y do for xx = x - s, x + s do c:px(xx, yy, "#f4ecd0") end end
    local m = mk(); E(m, x, y - 5 * s, 4 * s, 3 * s); m:each(function(xx, yy) if yy > y - 5 * s + 1 then m.s[X.K(xx, yy)] = nil end end)
    lit(m, cap, x, { R = 4, tex = .2 }); c:px(x - s, y - 6 * s, "#ffffff"); c:px(x + s + 1, y - 6 * s - 1, "#ffffff")
  end
  local cap = { hi = "#ffb0a0", base = "#e8493b", shade = "#a8323f", deep = "#6a2438" }
  shroom(100, 246, 2, cap); shroom(126, 250, 1, cap); shroom(380, 244, 2, { hi = "#f0d8ff", base = "#b890e0", shade = "#7a5ab0", deep = "#4a3a80" }); shroom(404, 252, 1, cap)
  for i = 1, 40 do local x, y = floor(H(i, 41, 1) * 470), 236 + floor(H(i, 41, 2) * 28); c:px(x, y, i % 2 == 0 and "#d88a48" or "#a8603c"); c:px(x + 1, y, "#d88a48") end
  -- silver paw-claw drag marks on the dirt
  clawmarks(200, 232, 4, 9, "#d8d8ec", 0)
  for i = 1, 24 do c:px(floor(H(i, 42, 1) * 470), floor(H(i, 42, 2) * 230), "#d8c8ff") end   -- drifting spores
end

---------------------------------------------------------------- 7. grey wolf king
function B.wolf()
  c = HP.canvas{ w = 480, h = 270, scale = 1, name = "lair-of-the-grey-wolf-king" }
  GX.bands(c, 0, 190, { "#202450", "#2c3466", "#3a4880", "#50629a", "#7284ae", "#9aa4c0" }, 6, .2)
  stars(110, 4, 80, "#f0f0ff")
  halo(250, 84, 110, 100, .1, 3, "#f4f4ff"); halo(250, 84, 84, 76, .14, 4, "#f4f4ff"); halo(250, 84, 64, 58, .2, 5, "#f4f4ff")
  disc(250, 84, 48, { hi = "#ffffff", base = "#f0f0f8", shade = "#c4c8e0", deep = "#9ca4cc" }, 6)
  for _, p in ipairs{ { 232, 70, 6 }, { 264, 98, 8 }, { 254, 66, 4 }, { 238, 100, 5 } } do local m = mk(); E(m, p[1], p[2], p[3], p[3]); m:each(function(x, y) c:px(x, y, "#c4c8e0") end) end
  layer({ { 60, 150, .6 }, { 190, 138, .8 }, { 330, 134, .7 }, { 450, 140, .7 } }, 170, { hi = "#b0b8d4", base = "#8490b8", shade = "#6874a4", deep = "#505c90" }, 11, .3, 220, "#a0a8c8")
  for _, p in ipairs{ { 20, 210, 60 }, { 52, 214, 46 }, { 100, 208, 56 }, { 380, 210, 52 }, { 420, 214, 64 }, { 460, 212, 48 }, { 340, 214, 36 }, { 140, 216, 34 } } do
    pine(p[1], p[2], p[3], { hi = "#5a8a8a", base = "#356a6c", shade = "#264a5c", deep = "#1c3246" }, R6({ hi = "#ffffff", base = "#e4e8f4", shade = "#b0b8d8", deep = "#7c88b8" }), p[1])
  end
  GX.ground(c, function(x) return 222 + floor((GX.vn(x, 0, 30, 4) - .5) * 8) end, { hi = "#f8f8ff", base = "#d4d8f0", shade = "#9ca4d4", deep = "#6c78b4" }, 12, { top = .85, fall = .5, tex = .3 })
  -- the rock spire with the den
  local sp = c:poly{ { 140, 232 }, { 156, 190 }, { 170, 160 }, { 186, 122 }, { 214, 108 }, { 248, 112 }, { 266, 136 }, { 290, 172 }, { 312, 200 }, { 330, 232 } }
  sp = rough(sp, 51)
  local RK = { hi = "#e4e8f4", base = "#9ca4bc", shade = "#646c8c", deep = "#3e4468" }
  lit(sp, RK, 52, { R = 22, tex = .6, sc = 4, fn = function(x, y) return (GX.vn(x * .3, y, 9, 53) < .25 and -.15 or 0) end })
  sp:each(function(x, y) if y < 116 + (x - 186) * .0 and not sp:has(x, y - 2) then c:px(x, y, "#ffffff") end end)
  local den = c:poly{ { 196, 232 }, { 196, 206 }, { 208, 186 }, { 240, 180 }, { 262, 192 }, { 270, 232 } }
  den = rough(den, 54); c:rim(den, INK); cavefill(den, 180, 232)
  eye(222, 204, 5, 4, { hi = "#fffbb0", base = "#ffd23c", shade = "#e0902c", deep = "#9a5a30" }, false)
  eye(244, 204, 5, 4, { hi = "#fffbb0", base = "#ffd23c", shade = "#e0902c", deep = "#9a5a30" }, false)
  for x = 216, 250 do c:px(x, 199 + floor(abs(x - 233) * .1), "#1b1223") end
  for x = 224, 242 do c:px(x, 214, "#d8dcec") end
  for k = 0, 4 do c:px(225 + k * 4, 215, "#f4f4ff"); c:px(225 + k * 4, 216, "#f4f4ff") end   -- fangs glint
  clawmarks(284, 190, 3, 20, RK.deep, 2)
  -- the wolf king on the summit: grey profile howling at the moon
  local o = { 226, 112 }
  local function P(x, y) return { o[1] + x, o[2] + y } end
  local wolf = c:poly{ P(-18, 0), P(-20, -12), P(-16, -28), P(-8, -42), P(-2, -52), P(0, -62), P(4, -68), P(2, -76), P(6, -73), P(10, -78), P(14, -72), P(24, -84), P(28, -82), P(24, -72), P(14, -66), P(8, -56), P(10, -44), P(14, -28), P(14, -10), P(16, 0) }
  wolf = rough(wolf, 61)
  lit(wolf, { hi = "#d8dcec", base = "#8a90ac", shade = "#585e80", deep = "#383e60" }, 62, { R = 12, tex = .5, sc = 3 })
  -- tail curling behind
  local tl = c:line({ P(-18, -6), P(-32, -12), P(-38, -26), P(-34, -40) }, 6); tl = rough(tl, 63)
  lit(tl, { hi = "#d8dcec", base = "#8a90ac", shade = "#585e80", deep = "#383e60" }, 64, { R = 4, tex = .5 })
  eye(o[1] + 8, o[2] - 62, 1, 1, { hi = "#fffbb0", base = "#ffd23c", shade = "#e0902c", deep = "#9a5a30" }, false)
  -- tiny crown
  for x = -2, 10 do c:px(o[1] + x, o[2] - 74, "#f5cf6a"); c:px(o[1] + x, o[2] - 73, "#d89a3a") end
  for _, x in ipairs{ -2, 3, 8, 10 } do c:px(o[1] + x, o[2] - 75, "#ffe38a"); c:px(o[1] + x, o[2] - 76, "#f5cf6a") end
  c:px(o[1] + 4, o[2] - 74, "#e8493b")
  -- howl puffs of breath
  for i, p in ipairs{ { 262, 28, 2 }, { 270, 22, 3 }, { 280, 14, 4 } } do local m = mk(); E(m, o[1] + p[1] - 220 + 0, o[2] - 90 + (p[2] - 28), p[3], p[3]); lit(m, { hi = "#ffffff", base = "#e8ecf8", shade = "#b8c0dc", deep = "#8c98c0" }, i, { R = 3, ink = false, rimlight = false, tex = .1 }) end
  -- banner pole: torn grey flag (quirk) and paw prints in the snow
  line(78, 224, 78, 168, "#6e4a48", 2); line(79, 224, 79, 168, "#8a6450")
  local fl = c:poly{ { 80, 170 }, { 110, 174 }, { 104, 182 }, { 110, 192 }, { 80, 190 } }; lit(fl, { hi = "#c8ccdc", base = "#888ea8", shade = "#5a6084", deep = "#3a4068" }, 65, { R = 5, tex = .3 })
  for x = 84, 100 do c:px(x, 180, "#f5cf6a") end
  for i = 0, 7 do pawprint(330 + i * 16, 246 + (i % 2) * 6 - floor(i * .5), "#8c98c8", 1) end
  snowfall(7, 60, "#f4f4ff")
end

local order = { toad = "lair-barrow-of-the-frost-toad", owl = "lair-den-of-the-great-white-owl", lizard = "lair-dragonlizard-den", wyrm = "lair-forge-of-the-cinder-wyrm", spider = "lair-hollow-of-the-silverback-spider", wolf = "lair-of-the-grey-wolf-king" }
local list = NAME == "all" and { "toad", "owl", "lizard", "wyrm", "spider", "wolf" } or { NAME }
for _, k in ipairs(list) do B[k](); finish(order[k]) end
