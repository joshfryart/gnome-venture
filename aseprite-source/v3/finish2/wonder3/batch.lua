-- wonder3: nine WONDER pictures, one parameterised script. Hearth Pop v3. 480x270.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d .. "/../../gather/gx.lua")
local HP = GX.HP
local P = HP.P
local NAME = app.params.name
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = NAME }
local INK = GX.INK
local floor, sin, cos, abs, min, max, sqrt = math.floor, math.sin, math.cos, math.abs, math.min, math.max, math.sqrt
local mix = GX.mix
local function E(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry or rx) end
local function Rc(x0, y0, x1, y1) return c:rect(x0, y0, x1, y1) end
local function fm(m, h) c:fillMask(m, h) return m end
local function px(x, y, h) c:px(x, y, h) end
local function hash(a, b) return ((a * 73856093) ~ (b * 19349663) ~ (a * b * 83492791)) % 1000 end
local function rim(m, h) c:rim(m, h or INK) return m end
local function ramp(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local function lit(m, R, seed, o) o = o or {}; o.seed = seed; return GX.lit(c, m, GX.ramp6(R), o) end
local function blob(cx, cy, rx, ry, seed) return GX.rough(GX.disc(HP.mask(), cx, cy, rx, ry), seed or 3, 1) end
local function ln(x0, y0, x1, y1, col, th)
  th = th or 1
  local n = max(abs(x1 - x0), abs(y1 - y0), 1)
  for i = 0, n do
    local x, y = floor(x0 + (x1 - x0) * i / n + .5), floor(y0 + (y1 - y0) * i / n + .5)
    for a = 0, th - 1 do for b = 0, th - 1 do px(x + a, y + b, col) end end
  end
end
local function sun(cx, cy, r, c1, c2, c3)
  fm(E(cx, cy, r + 8), c3); fm(E(cx, cy, r + 3), c2); fm(E(cx, cy, r), c1)
end
local function cloud(cx, cy, w, col, shade)
  local m = HP.mask()
  GX.disc(m, cx, cy, w, floor(w / 4)); GX.disc(m, cx - floor(w / 2), cy + 1, floor(w / 2), floor(w / 5)); GX.disc(m, cx + floor(w / 3), cy - floor(w / 6), floor(w / 2.5), floor(w / 5))
  m = GX.rough(m, cx, 1); fm(m, col)
  m:each(function(x, y) if not m:has(x, y - 2) then px(x, y, mix(col, "#ffffff", .35)) elseif not m:has(x, y + 2) then px(x, y, shade) end end)
end
local function hills(f, col, hi)
  c:terrain(f, col, 269, 0, 479)
  if hi then for x = 0, 479 do px(x, f(x), hi) end end
end
local function sparkle(x, y) c:sparkle(x, y) end
local function bug(x, y, s) -- tiny quirk helper: pixel dot cluster
  px(x, y, INK); px(x + 1, y, INK)
end

---------------------------------------------------------------- 1 STORK CHIMNEY VILLAGE
local function stork(x, y, s, bundle)  -- (x,y)= feet
  local W, K, RD = "#f6ecdc", "#3a2c3e", "#e0443a"
  ln(x - s, y - 10 * s, x - s, y, RD, max(1, floor(s / 2))); ln(x + 2 * s, y - 10 * s, x + 2 * s, y, RD, max(1, floor(s / 2)))
  local body = E(x, y - 15 * s, 8 * s, 5 * s); rim(body); fm(body, W)
  fm(E(x - 2 * s, y - 14 * s, 5 * s, 3 * s), K); fm(E(x - 7 * s, y - 16 * s, 2 * s, 1 * s + 1), K)
  fm(E(x - 3 * s, y - 17 * s, 4 * s, 2 * s), mix(W, "#ffffff", .0))
  local nk = Rc(x + 5 * s, y - 29 * s, x + 7 * s, y - 16 * s); rim(nk); fm(nk, W)
  local hd = E(x + 7 * s, y - 29 * s, 3 * s, 3 * s); rim(hd); fm(hd, W)
  local bk = Rc(x + 9 * s, y - 29 * s, x + 20 * s, y - 28 * s + max(0, s - 2)); rim(bk); fm(bk, RD)
  px(x + 8 * s, y - 30 * s, INK); if s > 1 then px(x + 8 * s + 1, y - 30 * s, INK) end
  if bundle then
    local bx, by = x + 20 * s, y - 27 * s
    ln(bx, by, bx + 3, by + 6, "#b8863a", 1)
    local b = E(bx + 4, by + 12, 8, 7); rim(b); fm(b, "#f4e4c8"); fm(E(bx + 3, by + 10, 3, 2), "#fffaf0")
    for _, p in ipairs{ { 6, 8 }, { 10, 13 }, { 2, 14 }, { 7, 15 } } do px(bx + p[1], by + p[2], "#e0443a") end
    fm(Rc(bx + 2, by + 5, bx + 6, by + 6), "#e0443a")
  end
end
local function house(x, y, w, h, roof, wall, chim)
  local wm = Rc(x, y, x + w, y + h); lit(wm, wall, x, { tex = .15, amb = .4 })
  local rf = c:poly{ { x - 6, y + 2 }, { x + 10, y - 22 }, { x + w - 10, y - 22 }, { x + w + 6, y + 2 } }
  lit(rf, roof, x + 3, { tex = .2 })
  for ry = y - 18, y, 5 do for rx = x - 2, x + w, 8 do px(rx + (ry % 2) * 4, ry, roof.deep) end end
  if chim then local ch = Rc(chim - 5, y - 40, chim + 5, y - 14); lit(ch, ramp("#e8946a", "#c8603e", "#8a3a3a", "#5a2430"), x, { tex = .3 }); fm(Rc(chim - 6, y - 42, chim + 6, y - 39), "#6a4a52") end
  fm(Rc(x + 6, y + 8, x + 18, y + 20), "#ffd878"); rim(Rc(x + 6, y + 8, x + 18, y + 20)); fm(Rc(x + 11, y + 8, x + 12, y + 20), "#8a4a34")
  fm(Rc(x + w - 18, y + 14, x + w - 8, h + y), "#7a4a3a"); rim(Rc(x + w - 18, y + 14, x + w - 8, h + y))
end
local function stork_village()
  GX.bands(c, 0, 175, { "#5c4a9c", "#8a5ab0", "#c068a8", "#f07c94", "#ff9c80", "#ffc078", "#ffdc98" }, 4, .12)
  sun(100, 118, 18, "#fff0b8", "#ffd88c", "#ffb27a")
  for _, k in ipairs{ { 70, 50, 38 }, { 360, 40, 44 }, { 220, 88, 30 }, { 440, 100, 32 } } do cloud(k[1], k[2], k[3], "#ffb0b8", "#c8689c") end
  hills(function(x) return 150 + floor(14 * sin(x / 50)) end, "#8a68a8", "#a888c0")
  hills(function(x) return 168 + floor(9 * sin(x / 33 + 2)) end, "#6a5a98")
  GX.ground(c, function(x) return 196 + floor(3 * sin(x / 40)) end, ramp("#f4d8a0", "#d8a46c", "#a8704c", "#6a4040"), 8, { top = .75, fall = .4 })
  for i = 0, 90 do local x, y = hash(i, 1) % 480, 205 + hash(i, 2) % 60; fm(E(x, y, 4, 2), "#b88458"); px(x - 1, y - 1, "#f0cc90") end
  house(24, 160, 70, 40, ramp("#f08a6a", "#d0503e", "#903a44", "#5a2838"), ramp("#fff0d0", "#e8c898", "#b08a6a", "#6a5058"), 70)
  house(380, 160, 76, 40, ramp("#f08a6a", "#d0503e", "#903a44", "#5a2838"), ramp("#fff0d0", "#e8c898", "#b08a6a", "#6a5058"), 420)
  stork(70, 118, 1, false); stork(420, 118, 1, false)
  house(150, 150, 180, 70, ramp("#f89a74", "#d85a40", "#9a3c48", "#5a2838"), ramp("#fff4d6", "#f0d0a0", "#b8906c", "#6a5058"), nil)
  local ch = Rc(216, 88, 264, 134); lit(ch, ramp("#f0a070", "#cc603e", "#8a3a3c", "#5a2430"), 5, { tex = .35 })
  for y = 94, 132, 8 do for x = 218, 262, 12 do px(x + (y // 8 % 2) * 6, y, "#6a3040"); px(x + (y // 8 % 2) * 6 + 1, y, "#6a3040") end end
  fm(Rc(212, 84, 268, 90), "#6a4a52"); rim(Rc(212, 84, 268, 90), INK)
  local nest = blob(240, 80, 40, 10, 7); lit(nest, ramp("#e8c47c", "#b88a50", "#80583c", "#4e3234"), 9, { tex = .6, sc = 2 })
  for i = 0, 30 do local a = hash(i, 4) % 60; ln(206 + a, 74 + hash(i, 6) % 12, 214 + a, 76 + hash(i, 8) % 12, "#d8b070", 1) end
  stork(240, 76, 2, true)
  fm(Rc(238, 164, 246, 180), "#ffd878"); local win = Rc(190, 176, 214, 200); fm(win, "#ffd878"); rim(win); fm(Rc(201, 176, 202, 200), "#8a4a34"); fm(Rc(190, 187, 214, 188), "#8a4a34")
  local dr = c:poly{ { 252, 220 }, { 252, 190 }, { 262, 182 }, { 272, 190 }, { 272, 220 } }; fm(dr, "#7a4a3a"); rim(dr); px(268, 204, "#ffd878")
  for _, p in ipairs{ { 40, 232 }, { 130, 246 }, { 350, 240 }, { 440, 250 } } do GX.flower(c, p[1], p[2], ({ "#ff7a9a", "#ffe07a", "#fff0d0", "#ff9a5a" })[(p[1] // 10) % 4 + 1]) end
end

---------------------------------------------------------------- 2 SUNKEN GNOME GALLEON
local function fish(x, y, s, col, fl)
  local b = E(x, y, 6 * s, 3 * s); rim(b); fm(b, col); fm(c:poly{ { x + 5 * s, y }, { x + 9 * s, y - 3 * s }, { x + 9 * s, y + 3 * s } }, fl or col)
  px(x - 3 * s, y - 1, INK); px(x - 2 * s, y + s, mix(col, "#ffffff", .4))
end
local function galleon()
  GX.bands(c, 0, 269, { "#58d0d0", "#3fb8c8", "#2a98b8", "#2078a8", "#1c5c94", "#1a4478" }, 6, .1,
    function(x, y) return ((x - floor(y * .55)) // 22) % 4 == 0 and y < 200 end, "#d8fff0")
  GX.ground(c, function(x) return 212 + floor(6 * sin(x / 30)) end, ramp("#ffe8a8", "#e8c078", "#b08a5c", "#5a4a58"), 12, { top = .8, fall = .5 })
  for i = 0, 50 do local x = hash(i, 1) % 480; px(x, 214 + hash(i, 2) % 50, "#fff0c0") end
  -- ship, heeling over
  local hull = c:poly{ { 110, 168 }, { 330, 140 }, { 372, 150 }, { 350, 206 }, { 296, 240 }, { 190, 246 }, { 136, 226 }, { 118, 196 } }
  lit(hull, ramp("#c88858", "#8a5a3c", "#5a3a34", "#3a2430"), 3, { tex = .35, amb = .3 })
  for k = 0, 4 do ln(122 + k * 4, 176 + k * 14, 360 - k * 12, 150 + k * 16, "#3a2430", 1) end
  fm(c:poly{ { 110, 168 }, { 330, 140 }, { 334, 148 }, { 114, 178 } }, "#e8b060")
  for k = 0, 5 do local px0 = 150 + k * 32; local pm = E(px0, 192 + floor(k * -3) + 14, 8, 8); rim(pm, "#4a3020"); fm(pm, "#2a98b8"); fm(E(px0 - 2, 190 + 14 - 3 * k, 3, 3), "#8fe8f0"); fm(E(px0, 192 + 14 - 3 * k, 8, 8):copy():cut(E(px0, 192 + 14 - 3 * k, 6, 6)), "#ffd060") end
  ln(250, 168, 214, 40, "#5a3a34", 5); ln(251, 168, 215, 40, "#8a5a3c", 2)
  ln(214, 56, 140, 78, "#5a3a34", 3)
  local sail = c:poly{ { 216, 52 }, { 292, 62 }, { 286, 92 }, { 270, 104 }, { 258, 94 }, { 244, 112 }, { 232, 100 }, { 222, 120 }, { 242, 130 }, { 252, 124 }, { 236, 132 }, { 226, 130 } }
  lit(sail, ramp("#fff0d0", "#ecd0a0", "#b8946c", "#6a5058"), 2, { tex = .3 })
  for _, p in ipairs{ { 262, 76 }, { 248, 100 } } do fm(E(p[1], p[2], 3, 3), "#2a98b8") end
  fm(c:poly{ { 210, 38 }, { 236, 34 }, { 222, 46 } }, "#e0443a"); rim(c:poly{ { 210, 38 }, { 236, 34 }, { 222, 46 } })
  -- quirk: octopus in the gnome hat peeking from a porthole
  local oc = blob(300, 176, 11, 9, 4); lit(oc, ramp("#ff9aa8", "#e0647a", "#a04060", "#5a2848"), 7, { tex = .2 })
  fm(c:poly{ { 292, 172 }, { 300, 152 }, { 308, 172 } }, "#d83a3a"); rim(c:poly{ { 292, 172 }, { 300, 152 }, { 308, 172 } }); px(298, 160, "#ffe8a0")
  px(296, 178, INK); px(297, 178, INK); px(304, 178, INK); px(305, 178, INK)
  for k = 0, 3 do ln(292 + k * 6, 184, 288 + k * 8, 196 + k % 2 * 3, "#e0647a", 2) end
  -- fore: treasure
  local ch = Rc(380, 222, 424, 250); lit(ch, ramp("#d8a062", "#a8704a", "#7a4a34", "#4a2c2c"), 5, { tex = .3 })
  fm(Rc(380, 222, 424, 230), "#c08550"); fm(Rc(398, 228, 405, 238), "#ffe38a"); sparkle(402, 214)
  for i = 0, 14 do local x = 372 + hash(i, 3) % 20; fm(E(x, 250 + hash(i, 4) % 6, 3, 2), "#ffd060") end
  fish(60, 70, 2, "#ffb03a", "#ff8a2a"); fish(100, 110, 1, "#ffb03a", "#ff8a2a"); fish(400, 70, 2, "#ff6a8a", "#c8406a"); fish(430, 110, 1, "#ffb03a", "#ff8a2a")
  for i = 0, 22 do local x, y = 140 + hash(i, 5) % 220, 30 + hash(i, 6) % 140; E(x, y, 1 + i % 3, 1 + i % 3); c:rim(E(x, y, 1 + i % 3, 1 + i % 3), "#d8fff0") end
  for _, p in ipairs{ { 40, 240 }, { 450, 236 } } do for k = 0, 3 do ln(p[1] + k * 5, p[2], p[1] + k * 5 + (k - 2) * 2, p[2] - 24 - k % 2 * 10, ({ "#ff6a8a", "#ff9ac0" })[k % 2 + 1], 3) end end
  for _, p in ipairs{ { 80, 232 }, { 20, 224 }, { 170, 252 } } do ln(p[1], p[2], p[1] + 3, p[2] - 28, "#58d878", 2); ln(p[1] + 4, p[2], p[1], p[2] - 20, "#38a858", 2) end
end

---------------------------------------------------------------- 3 TEA GARDEN SLOPES
local function tea()
  GX.bands(c, 0, 150, { "#8ac0d8", "#a8d4e0", "#c8e4e0", "#e8f0d8", "#f8f0c8" }, 2, .1)
  sun(380, 50, 16, "#fffae0", "#fff0b0", "#f8e8a8")
  hills(function(x) return 90 + floor(30 * sin(x / 70 + 1)) end, "#8aa8c0", "#b0c8d8")
  hills(function(x) return 112 + floor(18 * sin(x / 50 + 3)) end, "#7aa098")
  cloud(120, 100, 70, "#f0f4ec", "#c0d4d4"); cloud(400, 112, 60, "#f0f4ec", "#c0d4d4")
  local prof = function(x) return 96 + floor(((x - 240) / 240) ^ 2 * 44 + 6 * sin(x / 22)) end
  local g = { { "#5ca848", "#3f8a44", "#306a3c", "#9ad468" }, { "#74c050", "#4a9a46", "#38783e", "#b4e078" } }
  for x = 0, 479 do
    local y0 = prof(x)
    for y = y0, 269 do
      local rel = y - y0
      local lv = floor(rel / 17); local t = rel % 17
      local gg = g[lv % 2 + 1]
      local cw = y0 + lv * 17
      if t < 2 then px(x, y, "#c8f080")
      elseif t >= 14 then px(x, y, t == 16 and "#5a3a34" or "#9a5e44")
      else
        local n = hash(x // 2 + lv * 5, y // 2)
        px(x, y, n < 200 and gg[4] or (n < 520 and gg[1] or (n < 800 and gg[2] or gg[3])))
        if (x + lv * 3) % 7 == 0 and t == 6 then px(x, y, "#2a6a38") end
      end
    end
  end
  for lv = 0, 5 do for i = 0, 8 do local x = 30 + hash(lv, i) % 420; local y = prof(x) + lv * 17 + 6; if y < 255 then px(x, y, "#ffe8f0"); px(x + 1, y, "#ffb8c8") end end end
  -- pavilion at the summit
  local base = prof(240) - 2
  local wall = Rc(218, base - 24, 262, base); lit(wall, ramp("#fff0d0", "#e8c898", "#b0906c", "#6a5058"), 2, { tex = .1, amb = .4 })
  local rf = c:poly{ { 208, base - 22 }, { 222, base - 44 }, { 258, base - 44 }, { 272, base - 22 } }; lit(rf, ramp("#b8785a", "#8a4a3c", "#5e3440", "#3a2430"), 3, {})
  fm(c:poly{ { 238, base - 44 }, { 240, base - 54 }, { 242, base - 44 } }, "#ffd060")
  fm(Rc(234, base - 14, 246, base), "#7a4a3a"); fm(Rc(224, base - 18, 230, base - 10), "#ffd878"); fm(Rc(250, base - 18, 256, base - 10), "#ffd878")
  -- foreground teapot + cup, quirk snail
  local pot = blob(120, 242, 26, 20, 3); lit(pot, ramp("#fff0e0", "#e8a8a0", "#b0687c", "#6a3a54"), 4, { tex = .15 })
  fm(Rc(106, 214, 134, 222), "#d0807e"); rim(Rc(106, 214, 134, 222)); fm(Rc(118, 208, 122, 214), "#ffd060")
  ln(146, 232, 160, 232, INK, 2); ln(160, 232, 158, 250, INK, 2); ln(146, 250, 158, 250, INK, 2); ln(148, 236, 156, 236, "#e8a8a0", 2)
  ln(96, 238, 84, 232, INK, 2); ln(84, 232, 88, 226, INK, 2)
  for k = 0, 2 do ln(114 + k * 5, 206 - k % 2 * 3, 112 + k * 6, 190 - k * 4, "#f8f8f0", 2) end
  local bk = blob(390, 250, 36, 14, 8); lit(bk, ramp("#e8c47c", "#b88a50", "#80583c", "#4e3234"), 3, { tex = .5, sc = 2 })
  for k = 0, 10 do ln(366 + k * 5, 240, 366 + k * 5, 252, "#80583c", 1) end
  for k = 0, 8 do GX.tuft(c, 372 + k * 6, 238 - k % 3, ramp("#c8f080", "#74c050", "#3f8a44", "#306a3c")) end
  local sn = E(300, 256, 6, 5); rim(sn); fm(sn, "#f0a050"); px(298, 254, "#ffd890"); fm(Rc(305, 258, 316, 260), "#d8c0a0"); rim(Rc(305, 258, 316, 260)); px(315, 254, INK)
end

---------------------------------------------------------------- 4 AMBER WOODS
local function amber()
  GX.bands(c, 0, 200, { "#7a4a3c", "#a8603a", "#d8843a", "#f4a43c", "#ffc860", "#ffe09a" }, 9, .12,
    function(x, y) return ((x + floor(y * .4)) // 26) % 5 == 0 end, "#fff0b0")
  for i = 0, 22 do local x = i * 22 + hash(i, 1) % 14; GX.trunk(c, x, x + 3, 40 + hash(i, 2) % 40, 190, ramp("#a8603a", "#7a4034", "#54303a", "#34202e"), i, { noink = true }) end
  GX.foliage(c, 80, 60, 130, 50, ramp("#ffd060", "#f09a2e", "#b8602a", "#6a3430"), 5)
  GX.foliage(c, 400, 50, 140, 50, ramp("#ffd060", "#f09a2e", "#b8602a", "#6a3430"), 6)
  GX.foliage(c, 240, 28, 120, 28, ramp("#ffe080", "#f8aa38", "#c06c2c", "#6a3430"), 7)
  GX.ground(c, function(x) return 196 + floor(4 * sin(x / 30)) end, ramp("#f8c060", "#d88a3a", "#9a5436", "#4e2e34"), 13, { top = .78, fall = .5 })
  for i = 0, 140 do local x, y = hash(i, 3) % 480, 198 + hash(i, 4) % 72; local m = E(x, y, 3, 1); fm(m, ({ "#ffc040", "#e8702a", "#b8402a", "#ffe08a" })[i % 4 + 1]) end
  GX.trunk(c, 6, 36, 20, 250, ramp("#b8683c", "#7a4034", "#54303a", "#34202e"), 31)
  GX.trunk(c, 446, 472, 10, 250, ramp("#b8683c", "#7a4034", "#54303a", "#34202e"), 32)
  -- amber boulder, the wonder
  local b = blob(240, 188, 86, 62, 11); local R = ramp("#fff0a0", "#f4a828", "#c06020", "#6a3030")
  lit(b, R, 12, { tex = .25, amb = .35, rimlight = true })
  fm(c:ellipse(240, 252, 90, 8), "#7a4034")
  b = blob(240, 188, 86, 62, 11); c:rim(b, INK)
  -- trapped bee and leaf
  fm(E(236, 190, 9, 6), "#4a2a30"); for k = 0, 2 do fm(Rc(230 + k * 5, 185, 231 + k * 5, 195), "#ffd060") end
  fm(E(232, 183, 6, 3), "#fff0c0"); fm(E(244, 183, 6, 3), "#fff0c0"); px(228, 190, "#4a2a30"); px(229, 190, "#4a2a30")
  ln(262, 218, 294, 196, "#7a4a2c", 1); fm(c:poly{ { 270, 210 }, { 292, 190 }, { 290, 208 } }, "#a8602a")
  for i = 0, 6 do px(190 + hash(i, 1) % 30, 150 + hash(i, 2) % 30, "#fff8d0") end
  sparkle(206, 150); sparkle(290, 160)
  -- fallen leaves & tiny mushrooms
  for _, p in ipairs{ { 100, 244 }, { 380, 248 }, { 130, 256 } } do local cap = E(p[1], p[2] - 6, 7, 5); rim(cap); fm(cap, "#e0443a"); px(p[1] - 3, p[2] - 8, "#fff0d0"); px(p[1] + 2, p[2] - 6, "#fff0d0"); fm(Rc(p[1] - 1, p[2] - 2, p[1] + 1, p[2]), "#f0e0c0") end
end

---------------------------------------------------------------- 5 GREAT MIGRATION
local function gnu(x, y, s, col, hi, dust)  -- (x,y) = feet line centre
  local bd = E(x, y - 8 * s, 10 * s, 5 * s)
  local hm = E(x + 6 * s, y - 12 * s, 5 * s, 4 * s)
  local hd = c:poly{ { x + 10 * s, y - 14 * s }, { x + 17 * s, y - 8 * s }, { x + 15 * s, y - 3 * s }, { x + 9 * s, y - 8 * s } }
  if s >= 3 then rim(bd); rim(hm); rim(hd) end
  ln(x - 6 * s, y - 5 * s, x - 7 * s - floor(sin(x) * s), y, col, max(1, s)); ln(x + 4 * s, y - 5 * s, x + 4 * s + floor(cos(x) * s), y, col, max(1, s))
  ln(x - 3 * s, y - 5 * s, x - 3 * s + 1, y, mix(col, "#000000", .15), max(1, s)); ln(x + 7 * s, y - 5 * s, x + 8 * s, y, mix(col, "#000000", .15), max(1, s))
  fm(bd, col); fm(hm, col); fm(hd, col)
  ln(x - 10 * s, y - 9 * s, x - 13 * s, y - 3 * s, col, 1)
  ln(x + 12 * s, y - 14 * s, x + 11 * s, y - 18 * s, hi, 1); ln(x + 15 * s, y - 12 * s, x + 17 * s, y - 16 * s, hi, 1)
  if s >= 3 then fm(E(x, y - 11 * s, 8 * s, 2 * s), hi); px(x + 14 * s, y - 8 * s, "#ffe8a0") end
end
local function migration()
  GX.bands(c, 0, 160, { "#c85a8c", "#e87a7c", "#ff9a6c", "#ffb868", "#ffd488", "#ffe8a8" }, 14, .1)
  for _, k in ipairs{ { 90, 40, 50 }, { 380, 34, 56 }, { 240, 78, 40 } } do cloud(k[1], k[2], k[3], "#ffb890", "#d86a7c") end
  sun(240, 138, 40, "#fff4c0", "#ffd890", "#ffb878")
  GX.ground(c, function(x) return 150 end, ramp("#f8d08a", "#d49a58", "#9a6a48", "#5a3a40"), 15, { top = .8, fall = .55, tex = .3 })
  hills(function(x) return 148 + floor(2 * sin(x / 20)) end, "#a8604a")
  for i = 0, 70 do px(hash(i, 1) % 480, 154 + hash(i, 2) % 110, "#ffe0a0") end
  -- acacia
  GX.trunk(c, 58, 64, 100, 150, ramp("#9a5a40", "#6a3a38", "#4a2a34", "#2a1c2a"), 41, { noink = true })
  GX.foliage(c, 62, 96, 56, 12, ramp("#a8c060", "#5a8a3c", "#3a603a", "#24402e"), 42)
  ln(430, 110, 430, 150, "#5a3a40", 3); fm(Rc(420, 106, 440, 110), "#5a3a40")
  local cols = { "#5a3a4a", "#4a3044", "#3a2a40" }
  for row = 0, 4 do
    local y = 158 + row * 17 + row * row * 1
    local s = 1 + floor(row * .5)
    local n = 22 - row * 3
    for i = 0, n do
      local x = (i * 480 / n + hash(i, row) % 20 - 4 + row * 17) % 500 - 10
      if abs(x - 240) > 10 or row < 3 then gnu(floor(x), y, s, cols[(row + i) % 3 + 1], "#c88a6a", false) end
    end
  end
  for i = 0, 40 do local x, y = hash(i, 5) % 480, 154 + hash(i, 6) % 30; fm(E(x, y, 5, 1), "#e8a070") end
  gnu(240, 262, 5, "#5a3a4a", "#d8a07a")
  -- quirk: little bird in a red gnome hat riding the big bull
  local br = E(236, 214, 5, 4); rim(br); fm(br, "#fff0d0"); fm(c:poly{ { 232, 211 }, { 237, 201 }, { 241, 211 } }, "#e0443a"); rim(c:poly{ { 232, 211 }, { 237, 201 }, { 241, 211 } }); px(238, 214, INK); px(241, 216, "#f0a030"); px(242, 216, "#f0a030")
  -- a coin of sun-gold at hoof
  fm(E(330, 262, 5, 4), "#ffd060"); rim(E(330, 262, 5, 4)); sparkle(330, 250)
end

---------------------------------------------------------------- 6 HANGING GARDEN RUINS
local function hanging()
  GX.bands(c, 0, 170, { "#6a8ad0", "#88a4d8", "#a8bce0", "#d0c8e8", "#f0d4d8", "#ffe4c8" }, 20, .1)
  sun(90, 60, 14, "#fffae8", "#fff0c8", "#ffe4c0")
  cloud(380, 50, 60, "#fff0e8", "#c8b4d0"); cloud(200, 30, 40, "#fff0e8", "#c8b4d0")
  hills(function(x) return 150 + floor(24 * sin(x / 60 + 1) * cos(x / 130)) end, "#a090c0", "#c0b0d8")
  hills(function(x) return 176 + floor(10 * sin(x / 40)) end, "#7a88b0")
  GX.ground(c, function(x) return 220 + floor(4 * sin(x / 25)) end, ramp("#d8e8a0", "#90bc64", "#5a8a50", "#2e5a44"), 22, { top = .8 })
  local ST = ramp("#f4e0b8", "#c8a888", "#8a7080", "#4e3a50")
  local tiers = { { 130, 350, 70 }, { 100, 380, 100 }, { 70, 410, 130 }, { 40, 440, 160 } }
  local ys = { 214, 184, 154, 124 }
  -- back to front: top first so lower tiers overlap
  for i = 4, 1, -1 do
    local t = tiers[i]; local x0, x1, y = 240 - (160 - (i - 1) * -1) , 0, 0
  end
  local W = { 200, 270, 340, 410 }  -- tier widths bottom to top reversed
  local info = { { 40, 440, 188, 222 }, { 80, 400, 150, 190 }, { 120, 360, 112, 152 }, { 160, 320, 76, 114 } }
  for i = 4, 1, -1 do
    local f = info[i]
    local m = Rc(f[1], f[3], f[2], f[4]); lit(m, ST, i * 5, { tex = .35, amb = .3 })
    for x = f[1] + 12, f[2] - 12, 30 do   -- arches
      local a = c:poly{ { x, f[4] }, { x, f[3] + 20 }, { x + 4, f[3] + 14 }, { x + 10, f[3] + 14 }, { x + 14, f[3] + 20 }, { x + 14, f[4] } }
      fm(a, "#4e3a50"); fm(Rc(x + 2, f[3] + 22, x + 12, f[4]), "#6a5a70")
    end
    for x = f[1], f[2] do   -- planted lip and hanging vines
      local top = Rc(x, f[3] - 5, x, f[3] + 1); fm(top, hash(x, i) < 300 and "#4aa850" or "#70c860")
      if hash(x, i * 3) < 130 then ln(x, f[3] + 2, x, f[3] + 8 + hash(x, i) % 26, hash(x, 2) < 500 and "#3a9a48" or "#5ac05a", 1) end
      if hash(x, i * 7) < 18 then px(x, f[3] + 6 + hash(x, 3) % 18, "#ff7a9a") end
    end
    for k = 0, 5 do GX.flower(c, f[1] + 16 + k * ((f[2] - f[1] - 30) // 5), f[3] - 4, ({ "#ff7a9a", "#ffe07a", "#fff0d0" })[k % 3 + 1]) end
  end
  -- waterfall
  fm(Rc(232, 76, 248, 222), "#5ab8e0"); for y = 76, 222, 3 do px(234 + (y * 7) % 12, y, "#e8fcff"); px(240 + (y * 5) % 6, y + 1, "#c8f0f8") end
  c:rim(Rc(232, 76, 248, 76), "#e8fcff")
  fm(E(240, 238, 60, 14), "#2a78b0"); rim(E(240, 238, 60, 14)); fm(E(240, 238, 56, 11), "#4ab0dc"); fm(E(240, 240, 40, 7), "#7ad8f0")
  for i = 0, 25 do px(190 + hash(i, 1) % 100, 232 + hash(i, 2) % 12, "#e8fcff") end
  -- crown trees & broken column
  GX.foliage(c, 180, 70, 36, 14, ramp("#7ad060", "#3f9a4a", "#2e7040", "#1e4a38"), 51)
  GX.foliage(c, 300, 70, 36, 14, ramp("#7ad060", "#3f9a4a", "#2e7040", "#1e4a38"), 52)
  local col = Rc(60, 150, 74, 188); lit(col, ST, 9, { tex = .2 }); fm(c:poly{ { 58, 150 }, { 62, 142 }, { 70, 148 }, { 76, 150 } }, "#c8a888"); rim(c:poly{ { 58, 150 }, { 62, 142 }, { 70, 148 }, { 76, 150 } })
  -- quirk: tiny gnome door with lantern
  local dr = c:poly{ { 412, 222 }, { 412, 208 }, { 418, 202 }, { 424, 208 }, { 424, 222 } }; fm(dr, "#a8603a"); rim(dr); px(421, 214, "#ffd060")
  fm(Rc(430, 206, 433, 212), "#ffe38a"); rim(Rc(430, 206, 433, 212)); ln(431, 200, 431, 205, INK, 1); sparkle(431, 196)
end

---------------------------------------------------------------- 7 LABYRINTH ISLE
local function labyrinth()
  GX.bands(c, 0, 90, { "#8ac0e8", "#b0d8f0", "#d8ecf4", "#f8f0e0" }, 30, .1)
  cloud(100, 36, 56, "#fff8f0", "#c0d8e8"); cloud(380, 28, 50, "#fff8f0", "#c0d8e8")
  GX.bands(c, 90, 269, { "#58c8d8", "#3fb0d0", "#2a94c4", "#2078b4", "#1c5ca0" }, 31, .12)
  for i = 0, 120 do local x, y = hash(i, 1) % 480, 94 + hash(i, 2) % 175; fm(Rc(x, y, x + 3, y), "#a8ecf0") end
  hills(function(x) return 90 + floor(5 * sin(x / 40)) end, "#90a8d0")
  -- island
  local isl = E(240, 178, 226, 78); rim(isl); fm(isl, "#d8b878"); fm(E(240, 176, 220, 74), "#f0d898")
  fm(E(240, 172, 212, 68), "#7ac060"); fm(E(240, 170, 206, 63), "#90d468")
  local rings = { { 190, 54, 0.9 }, { 154, 44, 2.0 }, { 118, 34, 3.3 }, { 84, 24, 4.4 } }
  for i, r in ipairs(rings) do
    local ring = E(240, 172, r[1], r[2]); ring:cut(E(240, 172, r[1] - 12, r[2] - 6))
    local gx = 240 + floor(cos(r[3]) * (r[1] - 6)); local gy = 172 + floor(sin(r[3]) * (r[2] - 3))
    ring:cut(E(gx, gy, 14, 14)); ring:cut(E(240 + floor(cos(r[3] + 3.1) * (r[1] - 6)), 172 + floor(sin(r[3] + 3.1) * (r[2] - 3)), 12, 12))
    local face = ring; local top = ring:shift(0, -8)
    rim(top, INK); fm(face, "#2e6a40"); fm(top, "#3f9a4a")
    face:each(function(x, y) if top:has(x, y) then px(x, y, "#3f9a4a") end end)
    top:each(function(x, y) if (hash(x // 2, y // 2) < 200) then px(x, y, "#68c458") elseif not top:has(x, y - 1) then px(x, y, "#9ae070") end end)
    face:each(function(x, y) if not top:has(x, y) and hash(x, y) < 250 then px(x, y, "#1e4a38") end end)
  end
  -- central tower
  fm(E(240, 170, 26, 10), "#e8d0a0")
  local tw = Rc(228, 88, 252, 168); lit(tw, ramp("#fff0d0", "#d8b890", "#9a7a84", "#5a4258"), 5, { tex = .25 })
  for y = 94, 164, 10 do fm(Rc(228, y, 252, y), "#8a6a78") end
  local rf = c:poly{ { 222, 92 }, { 240, 56 }, { 258, 92 } }; lit(rf, ramp("#f89a74", "#d85a40", "#9a3c48", "#5a2838"), 6, {})
  fm(Rc(238, 112, 242, 128), "#4e3a50"); px(240, 44, "#ffd060"); ln(240, 44, 240, 56, INK, 1); fm(c:poly{ { 241, 44 }, { 252, 48 }, { 241, 52 } }, "#e0443a")
  sparkle(266, 76)
  -- cypress sentries
  for _, p in ipairs{ { 52, 190 }, { 424, 192 }, { 98, 214 }, { 380, 216 } } do local m = c:poly{ { p[1] - 6, p[2] }, { p[1], p[2] - 34 }, { p[1] + 6, p[2] } }; lit(m, ramp("#6ac058", "#2e7a44", "#1e5a3c", "#143a30"), p[1], { tex = .5 }) end
  -- boat + quirk goat
  local hull = c:poly{ { 24, 244 }, { 84, 244 }, { 72, 258 }, { 36, 258 } }; lit(hull, ramp("#e8b070", "#c0704a", "#8a4a3c", "#4e2c34"), 8, {})
  ln(54, 244, 54, 214, INK, 2); fm(c:poly{ { 56, 216 }, { 78, 240 }, { 56, 240 } }, "#fff0d0"); rim(c:poly{ { 56, 216 }, { 78, 240 }, { 56, 240 } })
  local gt = E(338, 192, 6, 4); rim(gt); fm(gt, "#f0e4d0"); fm(Rc(342, 184, 345, 192), "#f0e4d0"); px(345, 186, INK); px(341, 182, "#c0a888"); px(343, 181, "#c0a888"); fm(Rc(333, 195, 334, 199), "#c0a888"); fm(Rc(340, 195, 341, 199), "#c0a888")
  for _, p in ipairs{ { 460, 120 }, { 20, 130 }, { 300, 62 } } do ln(p[1], p[2], p[1] + 3, p[2] - 3, INK, 1); ln(p[1] + 3, p[2] - 3, p[1] + 6, p[2], INK, 1) end
end

---------------------------------------------------------------- 8 MIRROR SALT FLAT
local function mirror()
  local HZ = 138
  GX.bands(c, 0, HZ, { "#5a4a9c", "#8a5aa8", "#c068a4", "#f27c94", "#ff9c80", "#ffc078", "#ffe4a8" }, 50, .08)
  sun(330, HZ - 20, 20, "#fff4c8", "#ffe098", "#ffc080")
  cloud(110, 40, 60, "#ffb0b8", "#b8609c"); cloud(400, 66, 46, "#ffc0b0", "#c86a9c"); cloud(220, 82, 36, "#ffb8a8", "#c86a9c")
  hills(function(x) return HZ - 24 + floor(26 * abs(sin(x / 70 + 0.5)) - 10 * cos(x / 23)) end, "#6a58a0", "#8878b8")
  fm(Rc(0, HZ - 2, 479, HZ), "#ffe8c0")
  -- salt crystal spire: the wonder
  local sp = c:poly{ { 214, HZ }, { 224, HZ - 40 }, { 232, HZ - 86 }, { 242, HZ - 112 }, { 252, HZ - 84 }, { 260, HZ - 46 }, { 272, HZ } }
  lit(sp, ramp("#ffffff", "#f4f0f8", "#b8b0d8", "#6a5a90"), 8, { tex = .2, amb = .3 })
  local sp2 = c:poly{ { 270, HZ }, { 276, HZ - 30 }, { 286, HZ - 60 }, { 294, HZ - 28 }, { 304, HZ } }; lit(sp2, ramp("#ffffff", "#f0e8f4", "#b8b0d8", "#6a5a90"), 9, {})
  local sp3 = c:poly{ { 190, HZ }, { 198, HZ - 34 }, { 208, HZ - 54 }, { 214, HZ - 20 }, { 220, HZ } }; lit(sp3, ramp("#ffffff", "#f0e8f4", "#b8b0d8", "#6a5a90"), 10, {})
  sparkle(242, HZ - 120); sparkle(286, HZ - 68)
  for i = 0, 5 do local x = 60 + i * 66 + hash(i, 1) % 20; ln(x, HZ - 1, x, HZ - 6, "#e0443a", 1); fm(E(x, HZ - 6, 2, 1), "#ff9ac0") end
  -- mirror the top half
  for y = HZ + 1, 269 do
    local sy = 2 * HZ - y + 1 + ((y // 3) % 2 == 0 and 0 or 0)
    for x = 0, 479 do
      local sx = x + ((y // 4) % 3 == 1 and 1 or 0)
      local h = c:get(sx % 480, sy)
      if sy >= 3 and h then
        local t = min(.5, .18 + (y - HZ) / 400)
        px(x, y, mix(h, "#c8b8e8", t))
        if (y % 6 == 0) and hash(x // 6, y) < 120 then px(x, y, mix(h, "#ffffff", .3)) end
      end
    end
  end
  for i = 0, 50 do local x, y = hash(i, 4) % 480, HZ + 8 + hash(i, 5) % 120; px(x, y, "#fff0e8"); px(x + 1, y, "#fff0e8") end
  sparkle(150, 214)  -- quirk: a star that is only in the reflection
  -- flamingos
  local function fl(x, y, s, flip)
    local PK, DP = "#ff8ab0", "#d8508a"
    ln(x, y - 22 * s, x, y, "#e87898", 2)
    local bd = E(x + 2 * s, y - 28 * s, 10 * s, 6 * s); rim(bd); fm(bd, PK); fm(E(x - 2 * s, y - 27 * s, 6 * s, 3 * s), DP); fm(E(x - 8 * s, y - 28 * s, 2 * s, 2 * s), "#3a2c3e")
    local nk = c:poly{ { x + 8 * s, y - 30 * s }, { x + 14 * s, y - 46 * s }, { x + 10 * s, y - 52 * s }, { x + 14 * s, y - 52 * s }, { x + 17 * s, y - 46 * s }, { x + 11 * s, y - 30 * s } }
    rim(nk); fm(nk, PK)
    fm(E(x + 17 * s, y - 52 * s, 4 * s - 1, 3 * s - 1), PK); rim(E(x + 17 * s, y - 52 * s, 4 * s - 1, 3 * s - 1)); fm(E(x + 17 * s, y - 52 * s, 4 * s - 1, 3 * s - 1), PK)
    fm(Rc(x + 20 * s, y - 52 * s, x + 23 * s, y - 51 * s + s - 1), "#3a2c3e"); px(x + 17 * s, y - 53 * s, INK)
  end
  fl(80, 252, 2, 0); fl(400, 262, 2, 0); fl(150, 262, 2, 0)
  for _, p in ipairs{ { 80, 254 }, { 400, 264 }, { 150, 264 } } do fm(E(p[1], p[2], 14, 2), "#c8e0f0"); fm(E(p[1], p[2], 8, 1), "#ffffff") end
end

---------------------------------------------------------------- 9 THE OASIS THAT MOVES
local function palm(x, y, h, lean, seed)
  local pts = {}
  for k = 0, h, 2 do local xx = x + floor(lean * (k / h) ^ 2); ln(xx, y - k, xx, y - k - 2, (k // 4 % 2 == 0) and "#a8703c" or "#80502c", 4); pts = { xx, y - k } end
  local tx, ty = pts[1] + 1, pts[2]
  for a = -3, 3 do
    local dx = a * 13
    local mx, my = tx + dx, ty - 8 + abs(a) * 6
    local ex, ey = tx + dx * 1.9, ty + 4 + abs(a) * 8
    ln(tx, ty, mx, my, "#2e7a44", 3); ln(mx, my, ex, ey, "#3f9a4a", 3)
    ln(tx, ty - 1, mx, my - 1, "#6ac058", 1); ln(mx, my - 1, ex, ey - 1, "#8ad468", 1)
  end
  fm(E(tx - 3, ty + 6, 3, 3), "#8a5a2c"); fm(E(tx + 4, ty + 6, 3, 3), "#8a5a2c"); fm(E(tx - 3, ty + 5, 2, 2), "#ffb03a"); fm(E(tx + 4, ty + 5, 2, 2), "#ffb03a")
end
local function oasis()
  GX.bands(c, 0, 170, { "#58a8e0", "#78c0e8", "#a0d4ec", "#c8e4e0", "#f4ecc8", "#ffe0a0" }, 60, .1)
  sun(400, 50, 18, "#fffae0", "#fff0b0", "#ffe8a8"); cloud(100, 44, 54, "#fff8f0", "#b8d8e8"); cloud(260, 24, 36, "#fff8f0", "#b8d8e8")
  hills(function(x) return 140 + floor(16 * sin(x / 70 + 2)) end, "#e8b078", "#f8d098")
  hills(function(x) return 168 + floor(12 * sin(x / 50 + 4)) end, "#d89860", "#f0c088")
  GX.ground(c, function(x) return 210 + floor(5 * sin(x / 36)) end, ramp("#f8d890", "#e0a860", "#b0784a", "#6a4840"), 61, { top = .8, fall = .5 })
  -- giant tortoise
  local legs = { { 150, 222 }, { 192, 232 }, { 300, 232 }, { 340, 222 } }
  for _, l in ipairs(legs) do local m = blob(l[1], l[2], 18, 18, l[1]); lit(m, ramp("#c8d09a", "#98a470", "#687a58", "#3a4a44"), l[1], { tex = .5 }) end
  local head = blob(80, 188, 28, 18, 5); lit(head, ramp("#d8dca8", "#a4b078", "#6a7e5c", "#3a4a44"), 6, { tex = .5 })
  fm(Rc(74, 182, 77, 185), "#fff0c0"); px(75, 183, INK); px(76, 183, INK); ln(60, 194, 70, 196, "#6a7e5c", 1)
  local tail = c:poly{ { 396, 196 }, { 428, 206 }, { 396, 212 } }; lit(tail, ramp("#c8d09a", "#98a470", "#687a58", "#3a4a44"), 4, {})
  local shell = blob(240, 168, 160, 66, 9)
  lit(shell, ramp("#f0d49a", "#c8905a", "#8a5a46", "#4a3038"), 10, { tex = .45, amb = .3, rimlight = true })
  for i = 0, 36 do local a = i / 36 * 6.28; local x = 240 + floor(cos(a) * 130); local y = 168 + floor(sin(a) * 48); if sin(a) < 0.2 then fm(E(x, y, 4, 3), "#e8b878"); px(x - 1, y - 1, "#fff0c0") end end
  for _, p in ipairs{ { 140, 188 }, { 240, 204 }, { 340, 188 }, { 190, 176 }, { 290, 176 } } do ln(p[1] - 14, p[2], p[1], p[2] - 8, "#8a5a46", 1); ln(p[1], p[2] - 8, p[1] + 14, p[2], "#8a5a46", 1) end
  -- the oasis on its back
  local top = blob(240, 124, 118, 24, 13); lit(top, ramp("#f8e8a8", "#e8c078", "#b08a56", "#6a4a40"), 14, { tex = .3 })
  local pool = E(240, 128, 84, 14); rim(pool); fm(pool, "#2a88b8"); fm(E(240, 129, 78, 11), "#48b4d8"); fm(E(240, 131, 56, 7), "#78d8ec")
  for i = 0, 20 do px(190 + hash(i, 1) % 100, 124 + hash(i, 2) % 12, "#d8fcff") end
  palm(170, 126, 64, -14, 1); palm(240, 118, 84, 6, 2); palm(310, 126, 58, 16, 3)
  for k = 0, 8 do GX.tuft(c, 150 + k * 22, 118 + (k % 3) * 2, ramp("#c8f080", "#6ac058", "#3f8a44", "#2e6a3c")) end
  -- tent
  local tn = c:poly{ { 344, 118 }, { 362, 92 }, { 380, 118 } }; lit(tn, ramp("#fff0d0", "#e8c898", "#b0906c", "#6a5058"), 5, {}); fm(c:poly{ { 358, 118 }, { 362, 104 }, { 366, 118 } }, "#4e3a50")
  fm(c:poly{ { 362, 92 }, { 372, 94 }, { 362, 98 } }, "#e0443a")
  -- footprints and dust
  for k = 0, 6 do fm(E(20 + k * 14, 252 + (k % 2) * 4, 5, 2), "#b0784a") end
  for _, p in ipairs{ { 430, 240 }, { 450, 248 }, { 410, 250 } } do fm(E(p[1], p[2], 12, 4), "#f0c888"); fm(E(p[1] - 3, p[2] - 2, 6, 2), "#f8d8a0") end
  -- quirk: fennec fox hitching a ride on the tail
  local fx = E(414, 192, 6, 5); rim(fx); fm(fx, "#f4b070"); fm(c:poly{ { 409, 188 }, { 407, 178 }, { 413, 186 } }, "#f4b070"); fm(c:poly{ { 418, 188 }, { 422, 178 }, { 421, 187 } }, "#f4b070"); px(412, 192, INK); px(416, 192, INK); px(414, 194, INK)
end

local scenes = {
  ["wonder-stork-chimney-village"] = stork_village, ["wonder-sunken-gnome-galleon"] = galleon,
  ["wonder-tea-garden-slopes"] = tea, ["wonder-the-amber-woods"] = amber,
  ["wonder-the-great-migration"] = migration, ["wonder-the-hanging-garden-ruins"] = hanging,
  ["wonder-the-labyrinth-isle"] = labyrinth, ["wonder-the-mirror-salt-flat"] = mirror,
  ["wonder-the-oasis-that-moves"] = oasis,
}
scenes[NAME]()
c:hem(2); c:hem(267)
c:save{ aseprite = d .. "/out/" .. NAME .. ".aseprite", png = d .. "/out/" .. NAME .. ".png", scale = 1 }
