-- batch.lua: seven LAIR pictures (480x270). Param name=crab|dragonfly|jelly|caldera|peak|moth|scarab|all
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d .. "/../../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H = X.hash
local INK, GOLD = GX.INK, "#f5cf6a"
local NAME = app.params.name or "all"

local function build(name, fn)
  local c = HP.canvas{ w = 480, h = 270, scale = 1, name = name }
  local function mk() return HP.mask() end
  local function E(m, cx, cy, rx, ry) return GX.disc(m, floor(cx), floor(cy), rx, ry or rx) end
  local function pal(hi, base, shade, deep) return GX.ramp6{ hi = hi, base = base, shade = shade, deep = deep } end
  local function lit(m, R6, seed, o)
    o = o or {}
    m = GX.rough(m, seed, 1)
    local oo = { R = 8, tex = .4, sc = 4, seed = seed, amb = .25, rimlight = true }
    for k, v in pairs(o) do oo[k] = v end
    GX.lit(c, m, R6, oo)
    return m
  end
  local function blob(cx, cy, rx, ry, R6, seed, o) local m = mk(); E(m, cx, cy, rx, ry); return lit(m, R6, seed, o or { R = min(rx, ry) }) end
  local function line(x0, y0, x1, y1, col, th)
    local n = max(abs(x1 - x0), abs(y1 - y0), 1)
    for i = 0, n do
      local x, y = floor(x0 + (x1 - x0) * i / n + .5), floor(y0 + (y1 - y0) * i / n + .5)
      for t = 0, (th or 1) - 1 do c:px(x, y + t, col) end
    end
  end
  local function limb(pts, r0, r1, R6, seed, o)   -- thick tapered polyline mask
    local m = mk()
    for s = 1, #pts - 1 do
      local a, b = pts[s], pts[s + 1]
      local n = max(abs(b[1] - a[1]), abs(b[2] - a[2]), 1)
      for i = 0, n do
        local t = ((s - 1) + i / n) / (#pts - 1)
        local r = r0 + (r1 - r0) * t
        E(m, a[1] + (b[1] - a[1]) * i / n, a[2] + (b[2] - a[2]) * i / n, max(1, floor(r + .5)))
      end
    end
    return lit(m, R6, seed, o or { R = max(2, r0 * .8), tex = .3 })
  end
  local function eye(x, y, r, look, R6)
    local e = mk(); E(e, x, y, r, r)
    GX.lit(c, e, R6 or pal("#ffffff", "#fff4d8", "#e8c890", "#a8805a"), { R = r, tex = 0, seed = 1 })
    local px = x + (look or 0)
    for yy = y - floor(r / 2), y + floor(r / 2) do for xx = px - floor(r / 3), px + floor(r / 3) do c:px(xx, yy, INK) end end
    c:px(px - floor(r / 3), y - floor(r / 2), "#ffffff")
  end
  local function stars(y0, y1, n, seed, col)
    for i = 1, n do local x, y = floor(H(i, seed, 1) * 480), y0 + floor(H(i, seed, 2) * (y1 - y0)); c:px(x, y, col or "#fff0c0"); if i % 5 == 0 then c:px(x - 1, y, col or "#fff0c0"); c:px(x + 1, y, col or "#fff0c0"); c:px(x, y - 1, col or "#fff0c0"); c:px(x, y + 1, col or "#fff0c0") end end
  end
  local function hem() c:hem(2, 0, 479); c:hem(267, 0, 479) end
  local function polyfill(pts, R6, seed, o) return lit(c:poly(pts), R6, seed, o) end
  local function tuftrow(y0, y1, x0, x1, n, seed, R)
    for i = 1, n do
      local x = x0 + floor(H(i, seed, 1) * (x1 - x0))
      for y = y0, y1 do local k = c:get(x, y); if k then end end
      GX.tuft(c, x, y0 + floor(H(i, seed, 2) * (y1 - y0)), R)
    end
  end

  fn{ c = c, mk = mk, E = E, pal = pal, lit = lit, blob = blob, line = line, limb = limb, eye = eye, stars = stars, poly = polyfill, tuft = tuftrow }
  hem()
  c:save{ aseprite = d .. "/out/" .. name .. ".aseprite", png = d .. "/out/" .. name .. ".png", scale = 1 }
end

local P = {}

---------------------------------------------------------------- hurricane crab
P.crab = { "lair-of-the-hurricane-crab", function(S)
  local c, mk, E, pal, lit, blob, line, limb, eye = S.c, S.mk, S.E, S.pal, S.lit, S.blob, S.line, S.limb, S.eye
  GX.bands(c, 0, 160, { "#272540", "#34315a", "#44406e", "#5a5684", "#7a7498", "#9a92aa" }, 3, .3)
  -- swirling storm clouds
  for i = 1, 14 do
    local cx, cy = 20 + i * 34 + floor(H(i, 1, 1) * 20), 22 + floor(sin(i * .9) * 14) + (i % 3) * 14
    blob(cx, cy, 30 + floor(H(i, 1, 2) * 16), 9 + floor(H(i, 1, 3) * 4), pal("#8a82aa", "#625c86", "#443e68", "#2c2848"), 10 + i, { R = 8, ink = false, tex = .5 })
  end
  GX.ground(c, function(x) return 158 + floor(sin(x / 22) * 2) end, { hi = "#5aa0b8", base = "#34708e", shade = "#235070", deep = "#17304e" }, 5, { top = .75, fall = .6, sc = 6 })
  for i = 1, 40 do local x, y = floor(H(i, 2, 1) * 460), 164 + floor(H(i, 2, 2) * 100); line(x, y, x + 8 + floor(H(i, 2, 3) * 8), y, "#8cc8d8", 1) end
  -- legs
  local SH = pal("#ff9a7a", "#d8402e", "#9c2a3c", "#5c1a34")
  for _, s in ipairs{ -1, 1 } do for k = 0, 3 do
    local bx = 240 + s * (50 + k * 14)
    limb({ { bx, 170 }, { bx + s * (28 + k * 4), 168 + k * 3 }, { bx + s * (36 + k * 6), 214 } }, 5, 3, SH, 20 + k + s * 7)
  end end
  -- shell dome
  local sh = mk(); E(sh, 240, 168, 104, 44); for y = 120, 135 do end
  lit(sh, SH, 31, { R = 38, tex = .45, sc = 5 })
  for i = 1, 24 do local x, y = 150 + floor(H(i, 3, 1) * 180), 140 + floor(H(i, 3, 2) * 40); if sh:has(x, y) then c:px(x, y, "#ffb08a"); c:px(x + 1, y, "#ffb08a"); c:px(x, y + 1, "#a02c3c") end end
  -- eyestalks
  for _, s in ipairs{ -1, 1 } do
    limb({ { 240 + s * 18, 132 }, { 240 + s * 22, 112 } }, 4, 4, pal("#ffa088", "#e04a36", "#a02c3c", "#5c1a34"), 40 + s, { R = 4 })
    eye(240 + s * 22, 106, 9, -s * 2)
    for xx = 240 + s * 22 - 9, 240 + s * 22 + 9 do c:px(xx, 99 + floor(abs(xx - 240 - s * 22) * .15 * s * -1 + 1), INK) end
  end
  -- claws
  for _, s in ipairs{ -1, 1 } do
    limb({ { 240 + s * 80, 150 }, { 240 + s * 110, 120 }, { 240 + s * 132, 90 } }, 9, 8, SH, 50 + s)
    local cl = mk(); E(cl, 240 + s * 138, 70, 22, 24); local cut = mk(); for y = 44, 62 do for x = 240 + s * 138 - 3, 240 + s * 138 + 3 do cut:set(x, y) end end; cl:cut(cut)
    lit(cl, SH, 60 + s, { R = 14 })
    c:px(240 + s * 138, 62, INK)
  end
  -- mouth smile
  for x = -10, 10 do c:px(240 + x, 166 + floor((x * x) / 40), INK) end
  -- tiny lighthouse + sprout on the shell (quirk)
  local lx = 286
  S.poly({ { lx - 5, 138 }, { lx + 5, 138 }, { lx + 3, 112 }, { lx - 3, 112 } }, pal("#ffffff", "#f4e6d0", "#c8a6a0", "#806080"), 70, { R = 5 })
  for y = 118, 130, 6 do for x = lx - 4, lx + 4 do c:px(x, y, "#e04a36") end end
  S.poly({ { lx - 4, 112 }, { lx + 4, 112 }, { lx, 105 } }, pal("#ff9a7a", "#d8402e", "#9c2a3c", "#5c1a34"), 71, { R = 3 })
  c:px(lx, 108, "#ffe27a"); c:px(lx - 1, 109, "#ffe27a"); c:px(lx + 1, 109, "#ffe27a")
  -- lightning
  for _, p in ipairs{ { 60, 4 }, { 420, 14 } } do
    local x, y = p[1], p[2]
    for i = 1, 9 do local nx, ny = x + (i % 2 == 0 and -6 or 6), y + 9; line(x, y, nx, ny, "#fff2a0", 2); x, y = nx, ny end
  end
  -- foreground waves cover the leg feet
  for x = 0, 479 do
    local y = 220 + floor(sin(x / 9) * 4) + floor(sin(x / 23) * 3)
    for yy = y, 269 do
      local t = (yy - y) / 50
      c:px(x, yy, yy - y < 2 and "#c8ecf0" or (t < .3 and "#4a98b0" or (t < .7 and "#2e708e" or "#1e4a6c")))
    end
    if (x + floor(H(x // 7, 4, 4) * 9)) % 24 < 3 then c:px(x, y - 1, "#e8fafa") end
  end
  for i = 1, 90 do local x, y = floor(H(i, 5, 1) * 480), floor(H(i, 5, 2) * 215); line(x, y, x - 3, y + 7, "#b4b0cc", 1) end
end }

---------------------------------------------------------------- jade dragonfly
P.dragonfly = { "lair-of-the-jade-dragon-fly", function(S)
  local c, mk, E, pal, lit, blob, line, limb, eye = S.c, S.mk, S.E, S.pal, S.lit, S.blob, S.line, S.limb, S.eye
  GX.bands(c, 0, 200, { "#bfe8c4", "#a8dcb8", "#8ecdb0", "#74bca8", "#5ea8a0", "#4a9298" }, 3, .25)
  -- mist ridges
  for i = 0, 1 do
    for x = 0, 479 do local y = 150 + i * 14 + floor(GX.vn(x, 0, 30, 5 + i) * 26); for yy = y, 200 do c:px(x, yy, i == 0 and "#6cb0a4" or "#52989a") end end
  end
  -- bamboo stalks
  local BAM = pal("#d8f0a0", "#8cc860", "#4e9250", "#2a5a46")
  for _, b in ipairs{ { 20, 7, 3 }, { 48, 6, 4 }, { 438, 8, 5 }, { 462, 6, 6 }, { 408, 5, 7 }, { 90, 5, 8 } } do
    local x, w = b[1], b[2]
    for y0 = -6, 200, 34 do
      local m = mk(); for y = y0, min(200, y0 + 31) do for xx = x - w // 2, x + w // 2 do m:set(xx, y) end end
      lit(m, BAM, b[3] * 10 + y0, { R = w, tex = .25 })
    end
    for y0 = 28, 200, 34 do for xx = x - w // 2 - 1, x + w // 2 + 1 do c:px(xx, y0, "#2a5a46") end end
    for k = 1, 3 do local ly = 20 + k * 50 + b[3] * 6; for i = 0, 8 do c:px(x + (b[1] < 240 and 1 or -1) * (w // 2 + i), ly + floor(i * .5), "#3a8a4a"); c:px(x + (b[1] < 240 and 1 or -1) * (w // 2 + i), ly + floor(i * .5) + 1, "#7cc060") end end
  end
  -- pond
  GX.ground(c, function(x) return 200 end, { hi = "#7cd0c0", base = "#3e9a9c", shade = "#2a6e82", deep = "#1c4666" }, 7, { top = .7, fall = .5, sc = 8 })
  for i = 1, 36 do local x, y = floor(H(i, 9, 1) * 460), 206 + floor(H(i, 9, 2) * 60); line(x, y, x + 7, y, "#a8e8d8", 1) end
  -- reeds in front
  for _, rx in ipairs{ 30, 60, 440, 455 } do for i = 0, 28 do c:px(rx + floor(sin(i / 9) * 2), 238 - i, i % 3 == 0 and "#9ad060" or "#3a8a4a"); c:px(rx + 1 + floor(sin(i / 9) * 2), 238 - i, "#2a5a46") end; blob(rx, 206, 2, 5, pal("#e0b070", "#a8703a", "#6e4a2a", "#3c2a2a"), rx, { R = 2 }) end
  -- lily pads
  for _, p in ipairs{ { 120, 232, 26 }, { 340, 240, 30 }, { 230, 252, 22 }, { 400, 220, 18 } } do
    local m = mk(); E(m, p[1], p[2], p[3], floor(p[3] * .32))
    lit(m, pal("#c8f088", "#68b858", "#3a8450", "#255a46"), p[1], { R = 5, tex = .3 })
  end
  blob(340, 235, 5, 4, pal("#ffd8e0", "#ff90b4", "#d05a8c", "#8a3a68"), 3, { R = 4 }); c:px(340, 234, "#ffe27a")
  blob(120, 228, 4, 3, pal("#fff4d8", "#ffc8d8", "#e080a8", "#8a3a68"), 4, { R = 3 }); c:px(120, 228, "#ffe27a")
  -- dragonfly: wings (four), body, head
  local WG = pal("#f4fff0", "#c4f0dc", "#86d0bc", "#4a9ca0")
  local function wing(x0, y0, x1, y1, mr, seed)
    local m = mk(); local n = max(abs(x1 - x0), abs(y1 - y0))
    for i = 0, n do local t = i / n; local r = 2 + floor(mr * sin(3.14 * min(1, t * 1.1)) ^ .7)
      E(m, x0 + (x1 - x0) * t, y0 + (y1 - y0) * t, r, r) end
    lit(m, WG, seed, { R = 9, tex = .25 })
    for i = 3, n - 3 do local t = i / n; local px, py = floor(x0 + (x1 - x0) * t), floor(y0 + (y1 - y0) * t)
      if m:has(px, py) then c:px(px, py, "#4a9ca0") end
      if i % 7 == 0 then for k = -5, 5 do if m:has(px + k, py + (k * (x1 - x0) // max(1, abs(y1 - y0)) // 3)) then c:px(px + k, py + floor(k * .4), "#86d0bc") end end end end
    return m
  end
  wing(246, 104, 186, 30, 12, 1); wing(262, 104, 318, 26, 12, 2)
  wing(246, 120, 180, 186, 11, 3); wing(262, 120, 322, 190, 11, 4)
  -- stigma
  
  -- body (head left, tail right)
  local JADE = pal("#b8f0a0", "#44b080", "#237a68", "#12485a")
  for i = 0, 9 do blob(250 + i * 17, 112 + floor(sin(i / 3) * 2), 10, 5 - floor(i / 6), i % 2 == 0 and JADE or pal("#e8f8b0", "#78c890", "#3a9a78", "#1c5a64"), 20 + i, { R = 5, tex = .2 }) end
  blob(210, 112, 30, 16, JADE, 31, { R = 14 })
  blob(256, 110, 24, 14, JADE, 32, { R = 12 })
  for k = 0, 2 do line(238 + k * 11, 104, 242 + k * 11, 118, "#e8d060", 1) end
  -- legs
  for k = 0, 2 do limb({ { 196 + k * 8, 122 }, { 188 + k * 8, 134 }, { 190 + k * 9, 144 } }, 1, 1, pal("#80c880", "#44b080", "#237a68", "#12485a"), 40 + k, { R = 1, tex = 0 }) end
  -- head with huge eyes
  blob(158, 108, 22, 20, JADE, 50, { R = 18 })
  for _, ey in ipairs{ 98, 118 } do
    local m = mk(); E(m, 154, ey - 4 + (ey > 100 and 8 or 0), 15, 13)
    local e = lit(m, pal("#ffe27a", "#e8a030", "#b0602c", "#5a2a3a"), 51 + ey, { R = 12, tex = .35 })
    E(mk(), 0, 0, 0)
    for _, p in ipairs{ { 150, 3 }, { 151, 3 } } do end
  end
  eye(160, 104, 5, -1); eye(160, 119, 5, -1)
  for x = 140, 172 do c:px(x, 112, INK) end   -- brow/mouth line hint
  for x = 143, 150 do c:px(x, 126, INK) end
  -- antennae
  line(142, 92, 136, 84, INK, 1); line(148, 90, 146, 80, INK, 1)
  -- quirk: tiny frog on a lily pad watching
  blob(290, 248, 6, 4, pal("#c8f088", "#68c050", "#3a8a48", "#255a46"), 60, { R = 4 })
  eye(287, 244, 2, 0); eye(293, 244, 2, 0)
end }

---------------------------------------------------------------- box jelly queen reef
P.jelly = { "lair-reef-of-the-box-jelly-queen", function(S)
  local c, mk, E, pal, lit, blob, line, limb, eye = S.c, S.mk, S.E, S.pal, S.lit, S.blob, S.line, S.limb, S.eye
  GX.bands(c, 0, 220, { "#5ad0d8", "#42b8cc", "#3a9cc0", "#3280b0", "#2a64a0", "#264c88", "#223870" }, 3, .22, function(x, y) return abs((x - 120) + y * .5) % 90 < 12 and y < 170 end, "#c8fff0")
  -- far reef silhouettes
  for _, p in ipairs{ { 40, 170, 30 }, { 120, 180, 22 }, { 360, 176, 34 }, { 450, 170, 28 } } do blob(p[1], p[2], p[3], 28, pal("#5a78c0", "#4a60aa", "#3c4c90", "#2c3470"), p[1], { R = 12, ink = false, rimlight = false }) end
  -- sand
  GX.ground(c, function(x) return 226 + floor(sin(x / 30) * 4) end, { hi = "#fff0b8", base = "#f0c88a", shade = "#c0907c", deep = "#7a5a70" }, 8, { top = .85, fall = .5, sc = 9 })
  for i = 1, 30 do local x, y = floor(H(i, 3, 1) * 470), 234 + floor(H(i, 3, 2) * 32); c:px(x, y, "#fff4c8"); c:px(x + 1, y, "#fff4c8") end
  -- coral
  local function branch(x, y, h, R6, seed)
    limb({ { x, y }, { x + floor((H(seed, 1, 1) - .5) * 12), y - h * .6 }, { x + floor((H(seed, 1, 2) - .5) * 30), y - h } }, 4, 2, R6, seed)
    limb({ { x, y - h * .4 }, { x + 16, y - h * .7 } }, 3, 2, R6, seed + 1)
    limb({ { x, y - h * .55 }, { x - 14, y - h * .85 } }, 3, 2, R6, seed + 2)
  end
  local ORG, PNK, PRP = pal("#ffe090", "#ffa040", "#d86a3c", "#8a3a50"), pal("#ffc8e0", "#ff7aa8", "#c84a80", "#7a2a60"), pal("#e0c0ff", "#a878e0", "#7448b0", "#44286e")
  for _, b in ipairs{ { 30, 240, 50, ORG }, { 62, 246, 36, PNK }, { 410, 240, 54, PRP }, { 448, 246, 40, PNK }, { 380, 250, 30, ORG } } do branch(b[1], b[2], b[3], b[4], b[1]) end
  blob(110, 252, 24, 12, PNK, 71, { R = 10 }); blob(350, 254, 22, 10, PRP, 72, { R = 9 })
  for i = 1, 9 do c:px(100 + i * 3, 246 + (i % 3), "#ffe0f0") end
  -- seaweed
  for _, sx in ipairs{ 90, 150, 330, 392 } do for i = 0, 40 do c:px(sx + floor(sin(i / 7 + sx) * 3), 240 - i, i % 4 == 0 and "#8ae070" or "#2e9a5a"); c:px(sx + 1 + floor(sin(i / 7 + sx) * 3), 240 - i, "#1c6a4a") end end
  -- the queen: cube bell
  local CUBE = pal("#f4ffff", "#bce8f8", "#7cb8e0", "#4a78b8")
  for i = 0, 7 do   -- tentacles first
    local x0 = 188 + i * 15
    local pts = {}
    for k = 0, 8 do pts[#pts + 1] = { x0 + floor(sin(k / 1.5 + i) * 4), 152 + k * 9 } end
    limb(pts, 2, 1, pal("#ffd0f0", "#ff8cc8", "#c850a0", "#782a6a"), 90 + i, { R = 1, tex = 0 })
  end
  local top = c:poly{ { 178, 56 }, { 218, 40 }, { 300, 40 }, { 300, 56 } }
  local side = c:poly{ { 300, 40 }, { 314, 54 }, { 314, 144 }, { 300, 156 } }
  local front = mk(); for y = 56, 156 do for x = 178, 300 do front:set(x, y) end end
  lit(front, CUBE, 80, { R = 30, tex = .3, sc = 6 })
  lit(top, pal("#ffffff", "#e0f8ff", "#a8d8f0", "#6ca0d0"), 81, { R = 8, tex = .2 })
  lit(side, pal("#d0f0ff", "#8cc0e8", "#5a88c8", "#3a58a0"), 82, { R = 6, tex = .2 })
  for y = 150, 156 do for x = 178, 300 do if (x // 6) % 2 == 0 then c:px(x, y, "#7cb8e0") end end end
  -- crown
  local cr = c:poly{ { 196, 42 }, { 196, 24 }, { 208, 34 }, { 222, 18 }, { 236, 32 }, { 250, 18 }, { 264, 34 }, { 278, 24 }, { 278, 42 } }
  lit(cr, pal("#fff4a0", "#f4c040", "#c8883a", "#7a4a3a"), 83, { R = 6, tex = .15 })
  for _, p in ipairs{ { 222, 18 }, { 250, 18 } } do c:px(p[1], p[2] - 2, "#ff7aa8"); c:px(p[1], p[2] - 1, "#ff7aa8") end
  c:px(236, 36, "#ff5a78"); c:px(237, 36, "#ff5a78")
  -- face
  eye(214, 100, 8, 0); eye(266, 100, 8, 0)
  for x = -9, 9 do c:px(240 + x, 118 + floor(x * x / 22), INK) end
  c:px(205, 112, "#ffa0b0"); c:px(206, 112, "#ffa0b0"); c:px(207, 112, "#ffa0b0"); c:px(274, 112, "#ffa0b0"); c:px(275, 112, "#ffa0b0"); c:px(273, 112, "#ffa0b0")
  -- bubbles
  for _, b in ipairs{ { 60, 80, 4 }, { 70, 120, 3 }, { 420, 70, 5 }, { 440, 140, 3 }, { 120, 40, 3 }, { 350, 100, 4 } } do
    local m = mk(); E(m, b[1], b[2], b[3], b[3]); local r = m:edge(); c:fillMask(r, "#e8ffff"); c:px(b[1] - 1, b[2] - 1, "#ffffff")
  end
  -- quirk: clam with a pearl
  blob(250, 252, 10, 6, pal("#ffd8d0", "#e89aa0", "#b06a8c", "#6a3a62"), 99, { R = 6 }); blob(250, 249, 3, 3, pal("#ffffff", "#fff4f8", "#e0c8e0", "#a888b8"), 98, { R = 3 })
end }

---------------------------------------------------------------- smokecap caldera
P.caldera = { "lair-smokecap-caldera", function(S)
  local c, mk, E, pal, lit, blob, line, limb, eye = S.c, S.mk, S.E, S.pal, S.lit, S.blob, S.line, S.limb, S.eye
  GX.bands(c, 0, 262, { "#4a3a6e", "#6e4a82", "#9a5a8c", "#c8708a", "#ec8c80", "#fcb078", "#ffd088" }, 3, .22)
  -- far hills
  for x = 0, 479 do local y = 170 + floor(GX.vn(x, 0, 40, 3) * 28); for yy = y, 220 do c:px(x, yy, yy - y < 2 and "#a8628a" or "#8a5088") end end
  -- caldera mountain
  local ROCK = pal("#c89a8a", "#8a6070", "#5e4260", "#3a2c46")
  local mtn = c:poly{ { -10, 262 }, { 60, 190 }, { 110, 156 }, { 150, 146 }, { 330, 146 }, { 370, 156 }, { 420, 190 }, { 490, 262 } }
  lit(mtn, ROCK, 5, { R = 40, tex = .5, sc = 6 })
  -- crater lava glow
  local cr = mk(); E(cr, 240, 148, 96, 14)
  lit(cr, pal("#fff0a0", "#ffb040", "#e8602c", "#a02c3c"), 6, { R = 10, tex = .4, sc = 4 })
  for _, p in ipairs{ { 130, 190, 150, 210, 140, 240 }, { 350, 188, 330, 214, 350, 244 }, { 240, 190, 232, 216, 246, 246 } } do line(p[1], p[2], p[3], p[4], "#ffb040", 1); line(p[3], p[4], p[5], p[6], "#e8602c", 1) end
  -- giant smokecap mushroom (the boss) growing from the crater
  local CAP = pal("#ffc8a0", "#c8584a", "#8a3a4e", "#4e2440")
  local stem = mk(); for y = 96, 156 do local w = 17 + floor((y - 96) * .12); for x = 240 - w, 240 + w do stem:set(x, y) end end
  lit(stem, pal("#fff4e0", "#f0d8c0", "#c0a0a0", "#7a6078"), 7, { R = 16, tex = .3 })
  local gill = mk(); E(gill, 240, 98, 74, 12); lit(gill, pal("#c89a8a", "#8a5a70", "#5a3a58", "#3a2644"), 8, { R = 8, tex = .3 })
  for x = 170, 310, 4 do line(x, 96, 240 + (x - 240) * .85, 106, "#3a2644", 1) end
  local cap = mk(); E(cap, 240, 72, 82, 38); cap:cut(c:rect(0, 92, 479, 130))
  lit(cap, CAP, 9, { R = 36, tex = .35, sc = 5 })
  for _, p in ipairs{ { 200, 54, 7 }, { 250, 44, 9 }, { 288, 62, 6 }, { 222, 76, 5 }, { 270, 82, 5 }, { 176, 78, 4 } } do blob(p[1], p[2], p[3], floor(p[3] * .75), pal("#ffffff", "#fff0d8", "#e8c4b0", "#a08090"), p[1], { R = 5, tex = .1 }) end
  -- eyes in the shadowed gills
  for _, s in ipairs{ -1, 1 } do local m = mk(); E(m, 240 + s * 16, 106, 5, 3); c:fillMask(m, "#ffd84a"); c:px(240 + s * 16, 106, INK); c:px(240 + s * 16, 107, INK) end
  -- smoke puffs rising
  for i = 0, 6 do blob(246 + floor(sin(i * .8) * 18) + i * 4, 30 - i * 5 + (i > 2 and 6 or 0), 11 - i, 8 - floor(i / 1.5), pal("#ece4f0", "#c8bcd4", "#8e84a8", "#5a5078"), 30 + i, { R = 6, tex = .4 }) end
  -- little spotted mushrooms on the slopes
  for _, p in ipairs{ { 60, 232 }, { 110, 248 }, { 380, 236 }, { 430, 250 }, { 170, 252 }, { 320, 255 } } do
    local x, y = p[1], p[2]
    local s = mk(); for yy = y - 10, y do for xx = x - 3, x + 3 do s:set(xx, yy) end end
    lit(s, pal("#fff4e0", "#f0d8c0", "#c0a0a0", "#7a6078"), x, { R = 3, tex = .2 })
    local cp = mk(); E(cp, x, y - 12, 10, 7); cp:cut(c:rect(0, y - 9, 479, 300))
    lit(cp, pal("#ffa078", "#d8503e", "#9a2c3c", "#5a1c34"), x + 1, { R = 7 })
    c:px(x - 4, y - 15, "#fff0d8"); c:px(x + 3, y - 14, "#fff0d8"); c:px(x, y - 17, "#fff0d8")
  end
  -- foreground rock, ferns
  GX.ground(c, function(x) return 258 + floor(sin(x / 20) * 3) end, { hi = "#c89a8a", base = "#8a6070", shade = "#5e4260", deep = "#3a2c46" }, 11, { top = .8, fall = .3 })
  for _, x in ipairs{ 14, 34, 454, 470 } do for i = 0, 22 do c:px(x + floor(i * (x < 240 and .6 or -.6)), 258 - i + floor(i * i / 30), "#3a8a4a"); c:px(x + floor(i * (x < 240 and .6 or -.6)), 259 - i + floor(i * i / 30), "#7cc060") end end
  -- embers
  for i = 1, 14 do c:px(floor(H(i, 8, 1) * 440) + 20, 90 + floor(H(i, 8, 2) * 120), i % 2 == 0 and "#ffd84a" or "#ff8a3c") end
end }

---------------------------------------------------------------- snowcrown peak
P.peak = { "lair-snowcrown-peak", function(S)
  local c, mk, E, pal, lit, blob, line, limb, eye = S.c, S.mk, S.E, S.pal, S.lit, S.blob, S.line, S.limb, S.eye
  GX.bands(c, 0, 220, { "#6a78c0", "#8a8cd0", "#a89ad8", "#c8a8d8", "#e8b8d0", "#fcd0c8", "#ffe4d0" }, 3, .22)
  S.stars(0, 60, 24, 7, "#ffffff")
  -- far range
  for x = 0, 479 do local y = 150 + floor(abs(sin(x / 38)) * -26) + floor(GX.vn(x, 0, 12, 4) * 8); for yy = y, 230 do c:px(x, yy, yy - y < 3 and "#f4e0f0" or "#9a8cc4") end end
  -- main peak
  local SNOW = pal("#ffffff", "#f0ecfa", "#bcb4de", "#7c74b4")
  local ROCK = pal("#a49ad0", "#6c62a4", "#48407e", "#2c2858")
  local pk = c:poly{ { 70, 262 }, { 150, 150 }, { 190, 100 }, { 214, 78 }, { 240, 60 }, { 266, 78 }, { 290, 100 }, { 330, 150 }, { 410, 262 } }
  lit(pk, ROCK, 3, { R = 60, tex = .5, sc = 5, fn = function(x, y) return (x < 240 and .1 or -.18) end })
  -- snowcap and spiky ice crown
  local cap = c:poly{ { 168, 120 }, { 190, 100 }, { 214, 82 }, { 240, 62 }, { 266, 82 }, { 290, 100 }, { 312, 120 }, { 300, 130 }, { 286, 122 }, { 270, 136 }, { 252, 124 }, { 238, 140 }, { 222, 124 }, { 206, 136 }, { 190, 122 }, { 178, 132 } }
  lit(cap, SNOW, 4, { R = 24, tex = .3, fn = function(x, y) return (x < 240 and .1 or -.12) end })
  for _, s in ipairs{ { 208, 0 }, { 224, 1 }, { 240, 2 }, { 256, 1 }, { 272, 0 } } do
    local x, h = s[1], 20 + s[2] * 6
    local sp = c:poly{ { x - 6, 74 + (s[2] == 2 and -14 or 0) + 8 }, { x, 66 - h * .5 + (s[2] == 2 and -14 or 0) }, { x + 6, 74 + (s[2] == 2 and -14 or 0) + 8 } }
    lit(sp, pal("#ffffff", "#d8f4ff", "#8cc8f0", "#4a84c0"), x, { R = 5, tex = .1 })
  end
  c:px(240, 36, "#fff4a0"); c:px(239, 37, "#fff4a0"); c:px(241, 37, "#fff4a0"); c:px(240, 38, "#fff4a0")
  -- the cave with eyes
  local cave = mk(); E(cave, 240, 188, 22, 18); cave:cut(c:rect(0, 200, 479, 300))
  lit(cave, pal("#483a68", "#2e2650", "#241c40", "#1a1430"), 9, { R = 4, tex = 0, rimlight = false })
  for _, s in ipairs{ -1, 1 } do local m = mk(); E(m, 240 + s * 9, 188, 4, 3); c:fillMask(m, "#ffd84a"); c:px(240 + s * 9, 188, INK); c:px(240 + s * 9, 189, INK) end
  for x = 231, 249 do c:px(x, 198, "#f0ecfa") end
  -- paw prints
  for i = 0, 5 do local x, y = 240 + (i % 2 == 0 and -8 or 8) + floor(i * 2), 206 + i * 8; c:px(x, y, "#9a90c8"); c:px(x + 1, y, "#9a90c8"); c:px(x, y + 2, "#9a90c8"); c:px(x + 1, y + 2, "#9a90c8"); c:px(x - 1, y + 1, "#9a90c8"); c:px(x + 2, y + 1, "#9a90c8") end
  -- snowy foreground
  GX.ground(c, function(x) return 236 + floor(sin(x / 28) * 4) end, { hi = "#ffffff", base = "#ece8fa", shade = "#b4acdc", deep = "#7c74b4" }, 12, { top = .9, fall = .5, sc = 10 })
  -- pines
  local PINE = pal("#6ac8a0", "#2e8a78", "#1e5a6a", "#143a50")
  for _, p in ipairs{ { 40, 250, 1.3 }, { 96, 244, 1 }, { 400, 248, 1.2 }, { 448, 252, 1.4 }, { 360, 240, .8 } } do
    local x, y, s = p[1], p[2], p[3]
    local tr = c:rect(x - 2, y - 10, x + 2, y); lit(tr, pal("#c08a60", "#8a5a46", "#5a3a3a", "#32222e"), x, { R = 2 })
    for k = 0, 3 do
      local w = floor((26 - k * 5) * s)
      local t = c:poly{ { x - w, y - 8 - k * floor(18 * s) }, { x + w, y - 8 - k * floor(18 * s) }, { x, y - 30 * s - k * floor(18 * s) } }
      lit(t, PINE, x + k, { R = 8, tex = .4 })
      for xx = x - w + 2, x + w - 2, 3 do c:px(xx, y - 8 - k * floor(18 * s) - 1, "#f4f0ff") end
    end
  end
  -- quirk: a snow-gnome snowman with a red cap
  blob(300, 250, 9, 8, SNOW, 41, { R = 8 }); blob(300, 238, 6, 6, SNOW, 42, { R = 6 })
  c:fillMask(c:poly{ { 295, 233 }, { 305, 233 }, { 300, 224 } }, "#e8493b"); c:px(298, 232, "#ff8a70"); c:px(300, 237, "#f08838"); c:px(301, 237, "#f08838"); c:px(298, 236, INK); c:px(302, 236, INK)
  for i = 1, 70 do c:px(floor(H(i, 6, 1) * 480), floor(H(i, 6, 2) * 250), "#ffffff") end
end }

---------------------------------------------------------------- tiger moth temple
P.moth = { "lair-temple-of-the-tiger-moth", function(S)
  local c, mk, E, pal, lit, blob, line, limb, eye = S.c, S.mk, S.E, S.pal, S.lit, S.blob, S.line, S.limb, S.eye
  GX.bands(c, 0, 262, { "#1c1c4a", "#262658", "#34346c", "#46467e", "#5e5a90", "#7a6ea0" }, 3, .2)
  S.stars(0, 140, 50, 3)
  -- moon
  blob(380, 52, 24, 24, pal("#ffffea", "#fff0b8", "#e8c890", "#b09090"), 5, { R = 22, ink = false, tex = .2 })
  for x = 0, 479 do local y = 190 + floor(GX.vn(x, 0, 36, 6) * 30); for yy = y, 230 do c:px(x, yy, "#2e2a5e") end end
  -- temple tiers
  local STONE = pal("#e0c8b8", "#a88c9c", "#725e80", "#463a62")
  local tiers = { { 90, 262, 156 }, { 112, 252, 140 }, { 134, 240, 124 }, { 150, 226, 108 } }
  local ty = 262
  for i, t in ipairs{ { 150, 330, 232 }, { 172, 308, 206 }, { 194, 286, 182 }, { 212, 268, 160 } } do
    local m = c:rect(t[1], t[3], t[2], i == 1 and 264 or t[3] + 26)
    lit(m, STONE, 30 + i, { R = 10, tex = .4, sc = 4 })
    for x = t[1] + 6, t[2] - 6, 14 do for y = t[3] + 7, t[3] + 14 do c:px(x, y, "#463a62"); c:px(x + 1, y, "#463a62") end end
    for x = t[1], t[2] do c:px(x, t[3] - 1, "#f0dcc8") end
  end
  -- stairs
  for k = 0, 5 do c:fillMask(c:rect(228 - k * 3 + 6, 264 - k * 0, 252 + k * 3 - 6, 264), k % 2 == 0 and "#c8a8a4" or "#a88c9c") end
  -- pagoda roof
  local ROOF = pal("#f08a6a", "#c0483e", "#88304a", "#4e2040")
  local roof = c:poly{ { 196, 160 }, { 220, 146 }, { 260, 146 }, { 284, 160 }, { 274, 166 }, { 206, 166 } }
  lit(roof, ROOF, 9, { R = 12 })
  for _, x in ipairs{ 196, 284 } do c:px(x - (x < 240 and 1 or -1), 158, "#f5cf6a") end
  -- doorway glow
  local dr = mk(); E(dr, 240, 214, 10, 14); dr:cut(c:rect(0, 224, 479, 300)); for y = 214, 224 do for x = 230, 250 do dr:set(x, y) end end
  lit(dr, pal("#fff0a0", "#ffc858", "#e88a40", "#a04a3c"), 11, { R = 8, tex = .2, rimlight = false })
  -- lanterns
  for _, p in ipairs{ { 168, 236 }, { 312, 236 }, { 184, 212 }, { 296, 212 } } do blob(p[1], p[2], 4, 5, pal("#fff4a0", "#ffc040", "#e88030", "#8a3a3a"), p[1], { R = 4 }); c:px(p[1], p[2] - 7, INK); c:px(p[1], p[2] - 6, INK) end
  -- the moth atop the roof
  local OR = pal("#ffd070", "#f0902c", "#c05a30", "#6a2c3c")
  local function wing(sgn, seed)
    local pts = {}
    local P1 = { { 6, -4 }, { 30, -46 }, { 72, -78 }, { 108, -66 }, { 112, -24 }, { 92, 4 }, { 56, 14 }, { 20, 8 } }
    for _, p in ipairs(P1) do pts[#pts + 1] = { 240 + sgn * p[1], 132 + p[2] } end
    local m = c:poly(pts)
    local lw = c:poly{ { 240 + sgn * 6, 140 }, { 240 + sgn * 60, 130 }, { 240 + sgn * 92, 150 }, { 240 + sgn * 70, 176 }, { 240 + sgn * 28, 160 } }
    lit(lw, OR, seed + 1, { R = 14, tex = .3 })
    lit(m, OR, seed, { R = 24, tex = .3, sc = 5 })
    for k = 1, 5 do   -- tiger stripes
      local sx = 240 + sgn * (18 + k * 16)
      for y = 132 - 62 + k * 4, 132 + 10 do if m:has(sx, y) and (y + k * 3) % 11 < 7 then c:px(sx, y, INK); c:px(sx + sgn, y, "#3a1c32") end end
    end
    local eyew = mk(); E(eyew, 240 + sgn * 88, 100, 9, 9); lit(eyew, pal("#fff8d0", "#ffe27a", "#e8a040", "#a04a3c"), seed + 3, { R = 7 }); c:px(240 + sgn * 88, 100, INK); c:px(240 + sgn * 88 + 1, 100, INK)
  end
  wing(-1, 20); wing(1, 40)
  blob(240, 130, 9, 22, pal("#fffae0", "#f0d8b0", "#c09c98", "#7a6078"), 50, { R = 8, tex = .6, sc = 2 })
  blob(240, 104, 8, 8, pal("#fffae0", "#f0d8b0", "#c09c98", "#7a6078"), 51, { R = 7 })
  eye(236, 103, 3, 0); eye(244, 103, 3, 0)
  for _, s in ipairs{ -1, 1 } do for i = 0, 18 do c:px(240 + s * (3 + i), 98 - floor(i * 1.2 - i * i / 28), INK); if i % 3 == 0 then c:px(240 + s * (3 + i), 98 - floor(i * 1.2 - i * i / 28) - 2, "#fff0c0") end end end
  -- prayer flags
  for i = 0, 22 do
    local x = 20 + i * 6; local y = 60 + floor(((i - 11) ^ 2) / 8) + 2 * 0
    c:px(x, y, INK)
  end
  for i = 0, 22 do local x = 20 + i * 6; local y = 60 + floor(((i - 11) ^ 2) / 8); local cols = { "#e8493b", "#4a8ad8", "#f5cf6a", "#5ab868", "#f4f0e0" }
    if i % 2 == 0 then c:fillMask(c:rect(x, y + 1, x + 3, y + 6), cols[(i // 2) % 5 + 1]) end end
  for y = 59, 80 do c:px(20, y, INK) end
  GX.ground(c, function(x) return 256 + floor(sin(x / 20) * 2) end, { hi = "#8a8cc0", base = "#5a5a96", shade = "#3c3c74", deep = "#26264e" }, 13, { top = .6, fall = .3 })
  -- quirk: a tiny incense pot with smoke curl
  blob(94, 252, 8, 6, pal("#f4c880", "#c88a4e", "#8a5a46", "#4a3040"), 60, { R = 6 })
  for i = 0, 14 do c:px(94 + floor(sin(i / 2.5) * 3), 244 - i, "#c8c4e0") end
end }

---------------------------------------------------------------- sand scarab tomb
P.scarab = { "lair-tomb-of-the-sand-scarab", function(S)
  local c, mk, E, pal, lit, blob, line, limb, eye = S.c, S.mk, S.E, S.pal, S.lit, S.blob, S.line, S.limb, S.eye
  GX.bands(c, 0, 262, { "#f8a878", "#fcb888", "#fdc894", "#fed8a0", "#ffe4b0", "#fff0c4" }, 3, .22)
  blob(380, 56, 26, 26, pal("#ffffea", "#fff4b0", "#ffd070", "#f0a060"), 4, { R = 24, ink = false, tex = .15 })
  -- far pyramid and dunes
  c:fillMask(c:poly{ { 60, 190 }, { 130, 120 }, { 200, 190 } }, "#d89478"); c:fillMask(c:poly{ { 130, 120 }, { 200, 190 }, { 150, 190 } }, "#b87470")
  for x = 0, 479 do local y = 186 + floor(GX.vn(x, 0, 50, 3) * 20); for yy = y, 230 do c:px(x, yy, yy - y < 2 and "#ffe0a8" or "#ecb078") end end
  -- tomb facade (right)
  local ST = pal("#f8d8a8", "#d0a07c", "#946a6c", "#5a4258")
  local fac = c:rect(290, 126, 450, 232); lit(fac, ST, 5, { R = 20, tex = .4, sc = 5 })
  lit(c:rect(280, 112, 460, 128), pal("#ffe8b8", "#e0b088", "#a07a72", "#624a5e"), 6, { R = 8 })
  for x = 284, 456, 6 do c:px(x, 118, "#946a6c"); c:px(x, 119, "#946a6c") end
  local door = mk(); for y = 160, 232 do for x = 340, 400 do door:set(x, y) end end; E(door, 370, 160, 30, 22)
  lit(door, pal("#4a3a68", "#2e2650", "#241c40", "#1a1430"), 7, { R = 4, tex = 0, rimlight = false })
  for _, s in ipairs{ -1, 1 } do local m = mk(); E(m, 370 + s * 10, 196, 5, 3); c:fillMask(m, "#7af0d8"); c:px(370 + s * 10, 196, INK); c:px(370 + s * 10, 197, INK) end
  for _, x in ipairs{ 306, 330, 410, 434 } do lit(c:rect(x - 5, 130, x + 5, 232), ST, x, { R = 5, tex = .3 }); for y = 150, 220, 10 do c:px(x - 3, y, "#5a4258"); c:px(x - 2, y, "#5a4258") end end
  -- winged sun glyph over door
  local gl = mk(); E(gl, 370, 138, 6, 6); lit(gl, pal("#fff4a0", "#f5cf6a", "#c8883a", "#7a4a3a"), 8, { R = 5 })
  line(352, 140, 364, 138, "#c8883a", 1); line(376, 138, 388, 140, "#c8883a", 1)
  -- foreground dune
  GX.ground(c, function(x) return 228 + floor(sin(x / 40 + 1) * 5) end, { hi = "#ffe8b0", base = "#f0c088", shade = "#c08a78", deep = "#7a5470" }, 9, { top = .88, fall = .55, sc = 9 })
  -- giant scarab (left)
  local SH = pal("#8af0e0", "#2aa8b0", "#1c6e94", "#143a6a")
  for _, s in ipairs{ 0, 1, 2 } do limb({ { 120 + s * 30, 214 }, { 108 + s * 30, 238 }, { 112 + s * 30, 252 } }, 4, 3, pal("#4a6ab0", "#34468a", "#242c64", "#181c44"), 20 + s) end
  local shell = mk(); E(shell, 150, 204, 66, 40); shell:cut(c:rect(0, 218, 479, 300))
  lit(shell, SH, 21, { R = 34, tex = .3, sc = 6 })
  line(150, 166, 150, 218, "#143a6a", 1); line(151, 166, 151, 218, "#f5cf6a", 1)
  for k = 1, 3 do for x = 100 + k * 0, 200 do end end
  for _, p in ipairs{ { 112, 190 }, { 188, 190 }, { 120, 206 }, { 180, 206 } } do c:px(p[1], p[2], "#f5cf6a"); c:px(p[1] + 1, p[2], "#f5cf6a") end
  blob(150, 168, 5, 4, pal("#fff4a0", "#f5cf6a", "#c8883a", "#7a4a3a"), 22, { R = 4 })
  -- head and horn toward the tomb
  local head = mk(); E(head, 228, 214, 24, 18); head:cut(c:rect(0, 230, 479, 300))
  lit(head, pal("#6ac0d8", "#2a7ca8", "#1c4a84", "#142a5a"), 23, { R = 16 })
  c:fillMask(c:poly{ { 240, 200 }, { 262, 190 }, { 252, 208 } }, "#143a6a"); lit(c:poly{ { 240, 204 }, { 266, 188 }, { 254, 210 } }, pal("#ffe8a0", "#e8b058", "#a8704a", "#5a3a3a"), 24, { R = 4 })
  eye(226, 208, 5, 3)
  -- golden sun ball it pushes (quirk)
  blob(300, 246, 12, 12, pal("#fff4a0", "#f5cf6a", "#d8903a", "#8a4a3a"), 25, { R = 10 })
  c:px(296, 242, "#ffffff"); c:px(297, 242, "#ffffff")
  -- small cacti
  for _, x in ipairs{ 20, 462 } do lit(c:rect(x - 3, 214, x + 3, 250), pal("#a8e08a", "#58a860", "#38785a", "#1e4a50"), x, { R = 3 }); lit(c:rect(x + 3, 224, x + 9, 228), pal("#a8e08a", "#58a860", "#38785a", "#1e4a50"), x + 1, { R = 2 }) end
end }

local order = { "crab", "dragonfly", "jelly", "caldera", "peak", "moth", "scarab" }
if NAME == "all" then for _, n in ipairs(order) do build(P[n][1], P[n][2]) end else build(P[NAME][1], P[NAME][2]) end
