
---------------------------------------------------------------- 5 snowcrown peak
local ICE = RR("#e8fcff", "#8ad8f0", "#4aa0d0", "#2a6aa8")
local function crystal(x, y, w, h, lean, seed)
  local tx, ty = x + lean, y - h
  local whole = PL({ { x - w, y }, { x - w + 1, y - h * .72 }, { tx, ty }, { x + w - 1, y - h * .66 }, { x + w, y }, { x, y + 3 } })
  c:rim(whole, INK)
  local lf = PL({ { x - w, y }, { x - w + 1, y - h * .72 }, { tx, ty }, { x + lean * .5, y - h * .25 }, { x, y + 3 } })
  fill(whole, ICE.shade); fill(lf, ICE.base)
  local lh = PL({ { x - w + 1, y - 2 }, { x - w + 2, y - h * .66 }, { tx - 1, ty + 3 }, { x - w * .3, y - h * .5 } }); fill(lh, ICE.hi)
  ln(tx, ty, x + lean * .5, y - h * .25, "#f2fbff", 1)
  ln(x + lean * .5, y - h * .25, x, y + 2, ICE.deep, 1)
  P(tx, ty, "#fffbe8")
end
pic("lair-snowcrown-peak", function()
  GX.bands(c, 0, 200, { "#3a3a78", "#6a54a0", "#b068a0", "#f08a8c", "#ffb08a", "#ffd8a0" }, 5, .15)
  stars(0, 70, 36, 3, { "#fff1cf", "#ffd8e8" })
  halo(240, 80, 150, 90, .13, 3, "#ffe0b0"); halo(240, 80, 100, 60, .15, 4, "#ffe0b0")
  layer({ { 60, 130, .8 }, { 130, 120, 1.1 }, { 390, 118, 1.0 }, { 450, 136, .8 } }, 190, { hi = "#f2d8e8", base = "#b49cc8", shade = "#8474ac", deep = "#5c5090" }, 11, .4, 240, "#f0b8c0")
  local SN = RR("#fff1ee", "#d8dcf0", "#9a9cd0", "#5e58a4")
  local peak = rough(PL({ { 20, 246 }, { 70, 214 }, { 100, 196 }, { 120, 172 }, { 152, 160 }, { 170, 130 }, { 196, 118 }, { 210, 92 }, { 228, 76 }, { 240, 68 }, { 258, 78 }, { 270, 96 }, { 292, 108 }, { 306, 138 }, { 330, 150 }, { 352, 180 }, { 384, 196 }, { 410, 222 }, { 466, 246 } }), 31)
  litL(peak, SN, 32, { R = 40, tex = .5, sc = 4 })
  -- rock bands and couloirs, right face in shadow
  peak:each(function(x, y)
    local n = GX.vn(x, y * 1.7, 7, 33)
    if y > 110 and n > .66 then shadeTo(x, y, "#6a5a8a", .6) end
    local ridgeX = 238 + (y - 66) * .12
    if x > ridgeX then shadeTo(x, y, "#5a50a0", .5) end
    if x > ridgeX and (x + y) % 2 == 0 and n > .5 then shadeTo(x, y, "#3a3478", .35) end
  end)
  for k = 0, 90 do local y = 70 + k * 1.8; P(floor(238 + (y - 66) * .12), floor(y), "#ffe8e0") end
  -- crown of ice crystals
  for _, cr in ipairs{ { 214, 82, 7, 38, -4 }, { 266, 86, 6, 32, 5 }, { 226, 74, 8, 52, -2 }, { 254, 76, 8, 48, 3 }, { 240, 70, 9, 70, 0 } } do crystal(cr[1], cr[2], cr[3], cr[4], cr[5], 1) end
  glow(240, 20, 40, "#c8f4ff", .3)
  -- aurora-ish gold light shafts on the left face
  for k = 0, 5 do ln(176 + k * 6, 130 + k * 5, 150 + k * 6, 200 + k * 4, "#fff4d0", 1) end
  -- glacier tongue and lake
  GX.ground(c, function(x) return 226 + floor((GX.vn(x, 0, 24, 4) - .5) * 8) end, RR("#fff1ee", "#d8dcf0", "#a0a4d8", "#6a64b0"), 12, { top = .85, fall = .5, tex = .3 })
  for _, q in ipairs{ { 20, 224, 56 }, { 60, 228, 44 }, { 110, 222, 50 }, { 372, 224, 54 }, { 418, 228, 62 }, { 462, 224, 46 }, { 150, 230, 30 } } do
    pine(q[1], q[2], q[3], { hi = "#6a9a90", base = "#3a7270", shade = "#2a5266", deep = "#1e3850" }, GX.ramp6(SN), q[1])
  end
  local lake = rough(E(240, 256, 150, 16), 41); c:rim(lake, INK)
  lake:each(function(x, y) local t = (y - 240) / 32; P(x, y, t < .3 and "#8ad8f0" or (t < .6 and "#5ab8e0" or "#3a8cc8")) end)
  for k = 0, 40 do local x, y = 100 + floor(H(k, 3, 3) * 280), 244 + floor(H(k, 4, 3) * 24); if lake:has(x, y) then P(x, y, "#e8fcff"); P(x + 1, y, "#e8fcff") end end
  -- crown reflection shards
  for k = -3, 3 do local x = 240 + k * 7; for y = 244, 244 + 18 - abs(k) * 3 do if lake:has(x, y) and y % 2 == 0 then P(x, y, "#c8f0ff") end end end
  -- lair mouth with glowing eyes at the foot of the peak
  local cv = rough(PL({ { 214, 232 }, { 214, 218 }, { 224, 204 }, { 240, 198 }, { 256, 204 }, { 266, 218 }, { 266, 232 } }), 44); c:rim(cv, INK)
  cv:each(function(x, y) P(x, y, y > 222 and "#2a1c44" or "#1e1438") end)
  eyeL(230, 216, 3, 2, { hi = "#e8ffff", base = "#6ae0ff", shade = "#2a9ad0", deep = "#1a5a98" }); eyeL(250, 216, 3, 2, { hi = "#e8ffff", base = "#6ae0ff", shade = "#2a9ad0", deep = "#1a5a98" })
  for k = 0, 5 do local x = 217 + k * 9; for y = 199 + (k % 2) * 3, 206 + (k % 3) * 3 do if cv:has(x, y) or true then P(x, y, "#e8fcff") end end end
  -- quirk: snowman with a red gnome hat
  local sx, sy = 96, 250
  litL(E(sx, sy, 7, 6), SN, 3, { R = 4, tex = 0 }); litL(E(sx, sy - 10, 5, 5), SN, 4, { R = 3, tex = 0 })
  local hat = PL({ { sx - 4, sy - 13 }, { sx, sy - 24 }, { sx + 4, sy - 13 } }); c:rim(hat, INK); fill(hat, "#e0443a")
  P(sx - 1, sy - 11, INK); P(sx + 1, sy - 11, INK); P(sx + 2, sy - 10, "#f09030"); P(sx + 3, sy - 10, "#f09030")
  for i = 1, 70 do local x, y = floor(H(i, 9, 2) * 478), floor(H(i, 9, 3) * 260); P(x, y, "#fff1ee") end
end)

---------------------------------------------------------------- 6 temple of the tiger moth
local function mir(pts) local t = {} for i, p in ipairs(pts) do t[i] = { 480 - p[1], p[2] } end return t end
pic("lair-temple-of-the-tiger-moth", function()
  GX.bands(c, 0, 270, { "#0e2a3c", "#143a48", "#1a4a50", "#2a6058", "#3a7a58", "#5a9a58" }, 7, .15)
  halo(240, 60, 150, 100, .14, 3, "#ffe8b0")
  fill(E(240, 70, 46, 46), "#ffe8b0"); fill(E(240, 70, 42, 42), "#fff3cc")
  for i = 0, 10 do local x = i * 46 + 8; flat(R(x, 0, x + 6, 200), RR("#3a7a58", "#245a48", "#183e38", "#102a2a"), i, { sc = 2 }) end
  for y = 0, 200 do for x = 0, 479 do if ((x + y * .5) // 22) % 5 == 0 then shadeTo(x, y, "#ffe8a0", .1) end end end
  GX.ground(c, function(x) return 236 + floor(3 * sin(x / 22)) end, RR("#8ad060", "#4a9a48", "#2e6a40", "#1e4a38"), 4, { top = .8, fall = .5 })
  local ST = RR("#ecd8a8", "#b8a47a", "#7c7068", "#4a4458")
  local tiers = { { 60, 420, 214, 242 }, { 96, 384, 186, 214 }, { 132, 348, 160, 186 }, { 168, 312, 138, 160 } }
  for k, t in ipairs(tiers) do
    flat(R(t[1], t[3], t[2], t[4]), ST, k, { sc = 3 })
    fill(R(t[1], t[3], t[2], t[3] + 1), ST.hi)
    -- carved panels: squares with a spiral glyph and glowing slits
    for x = t[1] + 10, t[2] - 14, 22 do
      fill(R(x, t[3] + 6, x + 12, t[4] - 5), ST.shade); fill(R(x + 1, t[3] + 7, x + 11, t[4] - 6), ST.deep)
      ln(x + 3, t[3] + 9, x + 9, t[3] + 9, "#ffb84a", 1); ln(x + 9, t[3] + 9, x + 9, t[4] - 9, "#ffb84a", 1); ln(x + 3, t[3] + 12, x + 3, t[4] - 9, "#ffb84a", 1); ln(x + 3, t[4] - 9, x + 6, t[4] - 9, "#ffb84a", 1)
    end
  end
  for y = 138, 242, 4 do fill(R(226, y, 254, y), ST.hi); fill(R(226, y + 1, 254, y + 1), ST.shade) end
  fill(R(225, 138, 225, 242), INK); fill(R(255, 138, 255, 242), INK)
  -- shrine on top
  flat(R(212, 112, 268, 138), ST, 9, { sc = 3 })
  local roof = PL({ { 204, 112 }, { 276, 112 }, { 264, 100 }, { 216, 100 } }); flat(roof, RR("#9ed070", "#5aa050", "#3a7a48", "#245a3c"), 8)
  local door = E(240, 130, 8, 9):add(R(232, 130, 248, 138)):clip(R(232, 118, 248, 138)); c:rim(door, INK); fill(door, "#ffcf6a"); fill(E(240, 134, 4, 6):clip(door), "#fff0b8")
  -- torches
  for _, tx in ipairs{ 70, 410, 144, 336 } do
    local ty = tx < 100 or tx > 380 and 214 or 186
    if tx == 144 or tx == 336 then ty = 160 else ty = 214 end
    fill(R(tx, ty - 10, tx + 2, ty), "#5a3a40")
    fill(PL({ { tx - 3, ty - 10 }, { tx + 5, ty - 10 }, { tx + 1, ty - 24 } }), "#ff8a30"); fill(PL({ { tx - 1, ty - 10 }, { tx + 3, ty - 10 }, { tx + 1, ty - 18 } }), "#ffe07a")
    glow(tx + 1, ty - 14, 22, "#ffb860", .3)
  end
  -- the tiger moth: forewings dark brown with cream tiger bands, hindwings flame orange with black eye-spots
  local WB = RR("#7a4a38", "#4a2c28", "#2e1c24", "#1e1220")
  local function wing(pts, kind, seed, sx)
    local m = rough(PL(pts), seed); c:rim(m, INK)
    local bx, by = sx and 236 or 244, 104
    m:each(function(x, y)
      local dx, dy = (x - bx) * (sx and -1 or 1), y - by
      local dist = sqrt(dx * dx + dy * dy)
      local col
      if kind == "fore" then
        local band = (dx * .55 + dy * .85 + (GX.vn(x, y, 5, seed) - .5) * 7) / 9
        col = (floor(band) % 3 == 0) and "#fff1cf" or ((floor(band) % 3 == 1) and "#6a3e34" or "#4a2c28")
        if (floor(band) % 3 == 0) and dist < 24 then col = "#f6d49a" end
        if not m:has(x - 2, y - 1) or not m:has(x - 1, y - 2) then col = "#c89a78" end
      else
        local t = min(1, dist / 78)
        col = t < .3 and "#ffc060" or (t < .6 and "#ff8a30" or (t < .85 and "#e8502c" or "#c03030"))
        if not m:has(x - 2, y - 1) or not m:has(x - 1, y - 2) then col = "#ffd890" end
        if not m:has(x + 3, y + 2) then col = "#7a2a30" end
      end
      P(x, y, col)
    end)
    if kind == "hind" then
      for _, sp in ipairs(sx and mir{ { 292, 150 }, { 312, 136 }, { 330, 156 }, { 300, 164 } } or { { 292, 150 }, { 312, 136 }, { 330, 156 }, { 300, 164 } }) do
        fill(E(sp[1], sp[2], 6, 6):clip(m), INK); fill(E(sp[1], sp[2], 3, 3):clip(m), "#5ab0ff"); P(sp[1] - 1, sp[2] - 1, "#d8f4ff")
      end
    end
    -- veins
    local tipx = bx + (sx and -1 or 1) * 90
    for k = 0, 4 do ln(bx, by + k * 6, tipx, 40 + k * 28, kind == "fore" and "#2e1c24" or "#a83a2c", 1) end
    m:each(function(x, y) end)
    return m
  end
  local FW = { { 246, 104 }, { 270, 78 }, { 310, 48 }, { 352, 30 }, { 374, 40 }, { 380, 64 }, { 366, 92 }, { 334, 112 }, { 290, 122 }, { 258, 118 } }
  local HW = { { 246, 114 }, { 290, 116 }, { 336, 124 }, { 366, 144 }, { 360, 170 }, { 330, 182 }, { 296, 172 }, { 266, 150 } }
  wing(mir(HW), "hind", 21, true); wing(HW, "hind", 22, false)
  wing(mir(FW), "fore", 23, true); wing(FW, "fore", 24, false)
  -- fuzzy body
  local ab = limb({ { 240, 118 }, { 240, 132 }, { 240, 148 } }, 8, 5, 8)
  c:rim(ab, INK); lit(ab, RR("#ffe4b0", "#f0a860", "#b4683c", "#6a3a34"), 5, { R = 5, tex = .5, ink = false })
  for k = 0, 3 do local yy = 124 + k * 7; ln(233, yy, 247, yy, "#2e1c24", 1) end
  local th = E(240, 108, 11, 12); lit(th, RR("#fff1cf", "#f0b878", "#b4683c", "#6a3a34"), 6, { R = 7, tex = .6 })
  local hd = E(240, 90, 8, 7); lit(hd, RR("#ffe4b0", "#e8a060", "#a86040", "#6a3a34"), 7, { R = 4, tex = .4 })
  for _, sx in ipairs{ -1, 1 } do
    fill(E(240 + sx * 5, 89, 3, 3), INK); P(240 + sx * 5 - 1, 88, "#ffe8a0")
    local an = limb({ { 240 + sx * 3, 84 }, { 240 + sx * 10, 70 }, { 240 + sx * 18, 62 }, { 240 + sx * 24, 64 } }, 1, .6, 8); fill(an, "#2e1c24")
    for k = 0, 6 do P(240 + sx * (8 + k * 2.3), 74 - k * 1.3 + 5, "#2e1c24") end
  end
  -- mossy vines and foreground foliage
  for i = 1, 16 do local x = floor(H(i, 1, 3) * 470); local len = 14 + floor(H(i, 2, 3) * 40); for y = 0, len do P(x + floor(sin(y / 6 + i)), y, y % 7 == 6 and "#9ad45a" or "#3f8a48") end end
  GX.foliage(c, 40, 244, 90, 24, RR("#6cc058", "#368a48", "#245e3c", "#173e30"), 5); GX.foliage(c, 440, 250, 100, 22, RR("#6cc058", "#368a48", "#245e3c", "#173e30"), 6)
  for i = 1, 16 do tuft(floor(H(i, 6, 6) * 470) + 4, 250 + floor(H(i, 7, 6) * 16), GRASS) end
  -- quirk: tiny snail on the second step
  fill(E(214, 183, 4, 3), "#f0c070"); c:rim(E(214, 183, 4, 3), INK); fill(E(210, 185, 4, 1), "#d89a78"); P(207, 182, INK)
  for i = 1, 26 do local x, y = 40 + floor(H(i, 8, 8) * 400), 70 + floor(H(i, 9, 8) * 150); c:sparkle(x, y); P(x, y, "#ffe49a") end
end)

---------------------------------------------------------------- 7 tomb of the sand scarab
pic("lair-tomb-of-the-sand-scarab", function()
  GX.bands(c, 0, 170, { "#4a2e78", "#8a4a8c", "#d0688c", "#ff8a6c", "#ffb868", "#ffe090" }, 8, .12)
  halo(110, 150, 140, 70, .2, 3, "#ffe0a0")
  fill(E(110, 152, 40, 40), "#ffb868"); fill(E(110, 152, 36, 36), "#ffd88a"); fill(E(110, 152, 33, 33), "#fff0b8")
  stars(0, 70, 22, 5, { "#ffe8c8" })
  local DN = RR("#ffe0a0", "#e8a868", "#b0684c", "#6a3a48")
  ridge(function(x) return 150 + floor(10 * sin(x / 70) + 4 * sin(x / 23)) end, "#a8587a", 270)
  -- sandstone cliff and tomb facade
  local cliff = rough(PL({ { 170, 200 }, { 176, 118 }, { 200, 96 }, { 280, 92 }, { 330, 104 }, { 360, 130 }, { 380, 200 } }), 51)
  litL(cliff, RR("#f6c890", "#d49058", "#9a5a4a", "#5a3040"), 52, { R = 24, tex = .6, sc = 3 })
  cliff:each(function(x, y) if (y % 9 == 0) and H(x // 4, y, 53) > .3 then shadeTo(x, y, "#5a3040", .35) end end)
  local fac = R(204, 112, 332, 204); flat(fac, RR("#ffdca0", "#e0a468", "#a8685a", "#643848"), 55, { sc = 3 })
  fill(R(200, 108, 336, 114), "#fff0c0"); fill(R(200, 115, 336, 117), "#a8685a")
  for _, px_ in ipairs{ 214, 252, 292, 322 } do  -- lotus pillars
    local pm = R(px_, 118, px_ + 8, 204); litL(pm, RR("#ffe8b0", "#e8b078", "#a8685a", "#643848"), px_, { R = 4, tex = .3 })
    fill(R(px_ - 2, 118, px_ + 10, 122), "#a8685a"); fill(R(px_ - 2, 202, px_ + 10, 205), "#a8685a")
  end
  local door = R(262, 150, 284, 204); c:rim(door, INK); fill(door, "#1a1020"); fill(R(266, 190, 280, 204), "#ffcf6a"); fill(R(270, 196, 276, 204), "#fff0b8")
  for y = 150, 204 do if y % 3 == 0 then P(262, y, "#a8685a") end end
  -- golden scarab relief over the door
  fill(E(273, 134, 10, 7), "#f2b84a"); c:rim(E(273, 134, 10, 7), INK); ln(273, 127, 273, 141, "#9a5a30", 1)
  fill(E(273, 125, 4, 3), "#f2b84a"); ln(262, 134, 258, 138, "#f2b84a", 1); ln(284, 134, 288, 138, "#f2b84a", 1)
  P(270, 132, "#fff0b8"); P(269, 131, "#fff0b8")
  for k = 0, 8 do fill(R(210 + k * 14, 124, 214 + k * 14, 126), "#b0603c") end
  -- obelisks
  local function obelisk(x, by, w, h, seed)
    local m = PL({ { x - w, by }, { x - w + 2, by - h }, { x, by - h - 8 }, { x + w - 2, by - h }, { x + w, by } })
    litL(m, RR("#ffd8a0", "#d48e60", "#98605a", "#5a3448"), seed, { R = 6, tex = .3 })
    for k = 0, floor(h / 8) - 1 do fill(R(x - 2, by - 8 - k * 8, x + 1, by - 6 - k * 8), "#5a3448") end
  end
  obelisk(168, 226, 8, 70, 3); obelisk(356, 224, 8, 62, 4)
  GX.ground(c, function(x) return 220 + floor(6 * sin(x / 60) + 3 * sin(x / 14)) end, DN, 5, { top = .9, fall = .7, tex = .35 })
  for i = 0, 60 do local x, y = floor(H(i, 1, 2) * 480), 226 + floor(H(i, 2, 2) * 44); for k = 0, 5 do P(x + k, y - floor(k / 3), "#ffe0a0") end end
  -- the giant scarab pushing a golden sun-ball
  local bx, gy = 170, 258
  local function sp(...) local t = { ... } local q = {} for i = 1, #t, 2 do q[#q + 1] = { bx + t[i], gy + t[i + 1] } end return q end
  local LG = RR("#7a98a8", "#3a5a78", "#26385a", "#1a2440")
  local legs = limb(sp(-30, -18, -48, -10, -50, 0), 3, 1.6):add(limb(sp(-10, -12, -20, -4, -22, 0), 3, 1.6)):add(limb(sp(8, -12, 10, -4, 14, 0), 3, 1.6))
  legs:add(limb(sp(38, -16, 56, -28, 70, -30), 3, 2))
  local ballM = E(bx + 108, gy - 36, 34, 34)
  local ball = lit(ballM, RR("#fff0a0", "#f2b84a", "#c0742c", "#7a4030"), 9, { R = 30, tex = .25 })
  for k = 1, 3 do ln(bx + 80, gy - 52 + k * 14, bx + 138, gy - 52 + k * 14 - 6, "#c0742c", 1) end
  c:rim(legs, INK); fill(legs, LG.base)
  legs:each(function(x, y) if not legs:has(x, y - 1) then P(x, y, LG.hi) elseif not legs:has(x, y + 1) then P(x, y, LG.deep) end end)
  for k = 0, 2 do P(bx - 49 + k, gy - 6 - k * 2, "#cfd8e0") end
  local dome = E(bx, gy - 32, 44, 28):clip(R(bx - 60, gy - 70, bx + 60, gy - 14)):add(R(bx - 38, gy - 20, bx + 40, gy - 14))
  local SH = RR("#a8f4d8", "#2ea8b0", "#1a6a8c", "#102e5a")
  lit(dome, SH, 12, { R = 26, tex = .25 })
  dome:each(function(x, y) local r = ((x - bx) / 44) ^ 2 + ((y - gy + 32) / 28) ^ 2; if floor(r * 9) % 2 == 0 and r > .15 and (x + y) % 2 == 0 then shadeTo(x, y, "#102e5a", .45) end end)
  ln(bx - 40, gy - 24, bx + 36, gy - 54, "#102e5a", 1)
  dome:each(function(x, y) if H(x // 3, y // 3, 12) > .93 then P(x, y, "#ffe090") end end)
  local pron = E(bx + 36, gy - 26, 12, 14); lit(pron, RR("#c8fff0", "#38b4a8", "#1e7a90", "#123a68"), 13, { R = 6, tex = .3 })
  local hd = E(bx + 52, gy - 16, 9, 8); lit(hd, RR("#9ac8d8", "#386a88", "#26385a", "#1a2440"), 14, { R = 4, tex = .2 })
  fill(PL({ { bx + 58, gy - 22 }, { bx + 68, gy - 18 }, { bx + 60, gy - 14 } }), "#cfd8e0"); P(bx + 56, gy - 19, "#ffe090")
  fill(PL({ { bx + 58, gy - 12 }, { bx + 66, gy - 10 }, { bx + 58, gy - 9 } }), "#cfd8e0")
  for k = 0, 2 do fill(E(bx + 54 + k * 3, gy - 27 - k * 2, 2, 2), "#3a5a78") end
  -- near legs over the body, long hind leg with spurs
  local nl = limb(sp(-24, -20, -40, -8, -38, 0), 3, 1.6):add(limb(sp(-2, -14, -6, -5, -2, 0), 3, 1.6)):add(limb(sp(22, -14, 28, -5, 34, 0), 3, 1.6))
  c:rim(nl, INK); fill(nl, LG.base); nl:each(function(x, y) if not nl:has(x, y - 1) then P(x, y, LG.hi) end end)
  for k = 1, 8 do fill(E(bx - 70 + k * 5, gy + 1, 3, 1), "#c8885a") end
  -- drag trail and dust puffs
  for i = 0, 12 do dust(bx - 70 - i * 10, gy + 2, 10, 2, "#e8a868", i) end
  dust(bx + 76, gy + 1, 22, 3, "#e8a868", 5)
  -- quirk: lizard on the obelisk base
  fill(E(176, 224, 5, 2), "#6ac078"); c:rim(E(176, 224, 5, 2), INK); ln(181, 224, 186, 222, "#6ac078", 1); P(172, 223, INK)
  c:sparkle(110, 120); c:sparkle(380, 80)
end)

---------------------------------------------------------------- 8 jade dragonfly
local JD = RR("#d8ffd0", "#5ad8a0", "#2a9a84", "#14606c")
pic("lair-of-the-jade-dragon-fly", function()
  -- pond seen from above
  for y = 0, 269 do for x = 0, 479 do
    local n = GX.vn(x * .6, y, 14, 3) * .6 + GX.vn(x, y, 5, 5) * .4
    local cols = { "#0e5058", "#146a68", "#1c8478", "#2a9a84", "#46b494" }
    P(x, y, cols[max(1, min(5, 1 + floor((n + (y - 135) * .0006) * 5)))])
  end end
  for i = 0, 120 do local x, y = floor(H(i, 1, 9) * 470), floor(H(i, 2, 9) * 265); for k = 0, 3 + floor(H(i, 3, 9) * 6) do P(x + k, y, (i % 3 == 0) and "#8ae8c0" or "#0e4048") end end
  for _, q in ipairs{ { 90, 70, 36, 12 }, { 380, 190, 44, 16 } } do
    local rg = E(q[1], q[2], q[3], q[4]):copy():cut(E(q[1], q[2], q[3] - 2, q[4] - 1)); rg:each(function(x, y) if (x + y) % 2 == 0 then P(x, y, "#9ef0d0") end end)
  end
  -- lily pads with notch
  local PAD = RR("#bef08a", "#58b860", "#2e8450", "#1a5a40")
  local pads = { { 60, 200, 30 }, { 120, 238, 24 }, { 420, 58, 28 }, { 360, 28, 20 }, { 40, 40, 22 }, { 440, 140, 24 }, { 150, 150, 18 }, { 330, 236, 22 }, { 220, 40, 16 } }
  for i, pd in ipairs(pads) do
    local m = E(pd[1], pd[2], pd[3], floor(pd[3] * .75)):cut(PL({ { pd[1], pd[2] }, { pd[1] + pd[3] + 4, pd[2] - 3 }, { pd[1] + pd[3] + 4, pd[2] + 5 } }))
    lit(m, PAD, i, { R = 8, tex = .3 })
    for k = 0, 5 do local a = k * 1.05 + i; ln(pd[1], pd[2], pd[1] + cos(a) * pd[3] * .8, pd[2] + sin(a) * pd[3] * .6, PAD.shade, 1) end
  end
  -- pink lotus blooms
  local function lotus(x, y, r)
    local PT = RR("#fff1f0", "#ffa8c0", "#e0689a", "#9a3a78")
    for k = 0, 7 do local a = k * .785; local m = E(x + cos(a) * r * .55, y + sin(a) * r * .42, r * .5, r * .3); lit(m, PT, k + x, { R = 3, tex = 0 }) end
    for k = 0, 4 do local a = k * 1.26 + .4; lit(E(x + cos(a) * r * .28, y + sin(a) * r * .2, r * .34, r * .22), PT, k + y, { R = 3, tex = 0 }) end
    fill(E(x, y, r * .2, r * .15), "#ffd860"); P(x, y, "#fff0b8")
  end
  lotus(70, 120, 22); lotus(410, 100, 24); lotus(300, 250, 18); lotus(180, 36, 16)
  -- jade stepping stones
  for i, q in ipairs{ { 36, 120, 10 }, { 450, 220, 12 }, { 270, 20, 9 }, { 100, 260, 10 } } do lit(E(q[1], q[2], q[3], floor(q[3] * .7)), JD, i, { R = 5, tex = .3 }) end
  -- dragonfly geometry (top view): shadow first
  local function wingPts(fore)
    if fore then return { { 246, 118 }, { 290, 98 }, { 336, 82 }, { 376, 86 }, { 384, 98 }, { 360, 112 }, { 320, 124 }, { 270, 128 } } end
    return { { 246, 130 }, { 290, 132 }, { 336, 142 }, { 372, 158 }, { 372, 172 }, { 340, 172 }, { 300, 162 }, { 262, 146 } }
  end
  local ab = limb({ { 240, 138 }, { 240, 170 }, { 240, 206 }, { 240, 244 } }, 7, 2.2, 10)
  local th = E(240, 126, 13, 15); local hd = E(240, 102, 11, 9)
  local wm = mk()
  for _, f in ipairs{ true, false } do wm:add(PL(wingPts(f))); wm:add(PL(mir(wingPts(f)))) end
  local shadow = wm:copy():add(ab):add(th):add(hd):shift(16, 22)
  shadow:each(function(x, y) if (x + y) % 2 == 0 or GX.vn(x, y, 3, 4) > .5 then shadeTo(x, y, "#08303a", .6) end end)
  -- wings
  local function wingDraw(pts, seedv, left)
    local m = rough(PL(pts), seedv)
    c:rim(m, "#1a5a5c")
    m:each(function(x, y)
      local o = c:get(x, y)
      local dx = abs(x - 240)
      local base = mix(o, "#d8fff0", .55)
      if (x + y) % 2 == 0 then base = mix(o, "#e8fff4", .75) end
      P(x, y, base)
    end)
    -- longitudinal veins fanning out and cross veins
    for k = 0, 5 do
      local ty = pts[3][2] + (pts[5][2] - pts[3][2]) * k / 5
      ln(left and 480 - pts[1][1] or pts[1][1], pts[1][2], left and 480 - pts[4][1] or pts[4][1], ty + (k - 2) * 3, "#2a8a7c", 1)
    end
    for k = 0, 9 do local fx = 246 + 12 * k; local xx = left and 480 - fx or fx; for y = pts[3][2] - 6, pts[5][2] + 10 do if m:has(xx, y) and (y + k) % 4 < 2 then P(xx, y, "#2a8a7c") end end end
    local tipx = left and 480 - pts[5][1] + 8 or pts[5][1] - 8
    fill(R(tipx - 3, pts[4][2] + 2, tipx + 3, pts[4][2] + 5):clip(m), "#8a4a3c")
  end
  local fw, hw = wingPts(true), wingPts(false)
  wingDraw(mir(hw), 11, true); wingDraw(hw, 12, false); wingDraw(mir(fw), 13, true); wingDraw(fw, 14, false)
  -- body
  c:rim(ab, INK); lit(ab, JD, 3, { R = 5, tex = .25, ink = false })
  for k = 0, 10 do local yy = 148 + k * 9; local hw_ = max(1, floor(6.5 - k * .45)); fill(R(240 - hw_, yy, 240 + hw_, yy), "#f2b84a"); P(240 - hw_, yy, JD.deep); P(240 + hw_, yy, JD.deep) end
  ln(240, 140, 240, 242, JD.deep, 1)
  lit(th, JD, 4, { R = 7, tex = .25 })
  ln(232, 114, 236, 138, "#f2b84a", 1); ln(248, 114, 244, 138, "#f2b84a", 1); ln(240, 112, 240, 138, JD.deep, 1)
  lit(hd, RR("#c8ffe8", "#48c8a0", "#2a8a84", "#14505c"), 5, { R = 5, tex = .2 })
  local EY = RR("#d8ffff", "#38b8d8", "#1e70a8", "#12407c")
  for _, sx in ipairs{ -1, 1 } do
    local e = E(240 + sx * 7, 98, 7, 8); lit(e, EY, 7 + sx, { R = 5, tex = .2 })
    P(240 + sx * 7 - 2, 95, "#f2fbff"); P(240 + sx * 7 - 1, 95, "#f2fbff")
    for k = 0, 4 do P(240 + sx * (3 + k * 2), 100 + k % 2, EY.deep) end
  end
  fill(R(237, 106, 243, 107), "#f2b84a")
  -- tucked legs
  for _, sx in ipairs{ -1, 1 } do for k = 0, 2 do ln(240 + sx * 6, 120 + k * 5, 240 + sx * (14 + k * 2), 124 + k * 8, INK, 1) end end
  -- quirk: frog on a pad looking up
  local fx, fy = 150, 152
  lit(E(fx, fy, 7, 5), RR("#d8f070", "#8ccc48", "#4e9a44", "#2e6a3c"), 7, { R = 3, tex = 0 }); fill(E(fx - 4, fy - 4, 2, 2), "#ffe49a"); fill(E(fx + 4, fy - 4, 2, 2), "#ffe49a"); P(fx - 4, fy - 4, INK); P(fx + 4, fy - 4, INK)
  for i = 1, 24 do c:sparkle(floor(H(i, 5, 5) * 470) + 4, floor(H(i, 6, 5) * 250)) end
end)
