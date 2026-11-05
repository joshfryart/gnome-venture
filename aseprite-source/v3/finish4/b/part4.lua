
---------------------------------------------------------------- 9 dragonlizard den
local function scales(m, cw, ch, seed, tintcol, strength)
  vor(m, cw, ch, seed, function(x, y, qx, qy, id, d1, gap)
    local o = c:get(x, y); if not o then return end
    if gap < 1.1 then P(x, y, mix(o, "#1a1220", .55))
    elseif x < qx - cw * .15 and y < qy - ch * .15 and gap < 3 then P(x, y, mix(o, "#ffffd0", .28))
    else P(x, y, mix(o, tintcol, (id - .5) * (strength or .3) + .05)) end
  end)
end
pic("lair-dragonlizard-den", function()
  -- cave interior
  GX.bands(c, 0, 270, { "#2a1a38", "#34223e", "#3e2a44", "#46304a" }, 3, .2)
  for y = 0, 269 do for x = 0, 479 do if H(x // 3, y // 3, 4) > .92 then P(x, y, "#563c58") elseif H(x // 2, y // 2, 5) < .07 then P(x, y, "#20142c") end end end
  -- opening to dusk valley on the left
  local op = rough(E(86, 130, 82, 112):clip(R(0, 0, 200, 262)), 8)
  GX.bands(c, 0, 270, { "#6a4a8c", "#c8688c", "#ff8a6c", "#ffc068", "#ffe090" }, 9, .1)
  local OP = mk(); op:each(function(x, y) end)
  -- re-darken everything outside the opening
  local keep = {}
  op:each(function(x, y) keep[x * 1000 + y] = c:get(x, y) end)
  GX.bands(c, 0, 270, { "#2a1a38", "#34223e", "#3e2a44", "#46304a" }, 3, .2)
  for y = 0, 269 do for x = 0, 479 do if H(x // 3, y // 3, 4) > .92 then P(x, y, "#563c58") elseif H(x // 2, y // 2, 5) < .07 then P(x, y, "#20142c") end end end
  op:each(function(x, y) P(x, y, keep[x * 1000 + y]) end)
  op:each(function(x, y) if y > 150 then local t = (y - 150) / 112; P(x, y, t < .3 and "#e8a068" or (t < .6 and "#b06a5a" or "#6a3a4c")) end end)
  fill(E(70, 150, 22, 22):clip(op), "#fff0b8"); fill(E(70, 150, 18, 18):clip(op), "#fff8d0")
  c:rim(op, INK)
  layerClip = nil
  for k = 0, 3 do ln(30 + k * 40, 168 + (k % 2) * 8, 54 + k * 40, 160 + (k % 2) * 8, "#b06a5a", 2) end
  -- light shaft from opening across the floor
  PL({ { 20, 160 }, { 150, 120 }, { 330, 270 }, { 100, 270 } }):each(function(x, y) if (x + y) % 3 == 0 then shadeTo(x, y, "#ffd890", .18) end end)
  -- stalagmite columns / ceiling teeth
  for _, s in ipairs{ { 200, 0, 14, 60 }, { 240, 0, 9, 36 }, { 290, 0, 12, 50 }, { 340, 0, 10, 30 } } do
    local m = mk(); for yy = 0, s[4] do local hw = s[3] * (1 - yy / s[4]) ^ .8 + .5; for xx = floor(s[1] - hw), floor(s[1] + hw) do m:set(xx, yy) end end
    litL(m, RR("#8a6a88", "#5a4268", "#3a2a50", "#22183a"), s[1], { R = 6, tex = .5 })
  end
  -- the dragonlizard: head in profile facing the light
  local function Wp(pts) local t = {} for i, p in ipairs(pts) do t[i] = { p[1], p[2] } end return PL(t) end
  local upper = Wp({ { 172, 150 }, { 176, 138 }, { 190, 126 }, { 214, 116 }, { 240, 104 }, { 262, 90 }, { 290, 82 }, { 330, 80 }, { 370, 92 }, { 406, 118 }, { 430, 160 }, { 436, 196 }, { 392, 196 }, { 340, 188 }, { 290, 176 }, { 240, 168 }, { 200, 160 } })
  local lower = Wp({ { 178, 172 }, { 200, 170 }, { 240, 180 }, { 296, 192 }, { 350, 202 }, { 440, 214 }, { 470, 270 }, { 330, 270 }, { 296, 238 }, { 240, 214 }, { 200, 196 }, { 180, 184 } })
  local neck = Wp({ { 392, 150 }, { 440, 176 }, { 470, 214 }, { 479, 270 }, { 420, 270 }, { 410, 220 }, { 380, 190 } })
  local ridgeS = {}
  local whole = upper:copy():add(lower):add(neck)
  -- frill spikes and horns (behind)
  local horns = limb({ { 300, 84 }, { 310, 58 }, { 336, 40 }, { 352, 38 } }, 6, 1.5, 10):add(limb({ { 350, 90 }, { 366, 66 }, { 392, 54 }, { 408, 56 } }, 7, 1.5, 10)):add(limb({ { 252, 96 }, { 252, 78 }, { 262, 64 } }, 4, 1.2, 8))
  for k = 0, 4 do horns:add(PL({ { 388 + k * 12, 118 + k * 18 }, { 388 + k * 12 + 18, 100 + k * 18 }, { 400 + k * 12, 132 + k * 18 } })) end
  c:rim(horns, INK)
  litL(horns, RR("#fff0c8", "#e8a860", "#b06a44", "#6a3a40"), 9, { R = 4, tex = .3, ink = false })
  c:rim(whole, INK)
  local SK = RR("#d8f080", "#6aa848", "#3e7a48", "#1e4a3c")
  litL(neck, SK, 21, { R = 30, tex = .4, ink = false, amb = .1 })
  litL(upper, SK, 22, { R = 22, tex = .35, ink = false, amb = .2 })
  litL(lower, RR("#fff0b0", "#c8c868", "#6a9a58", "#2e5a44"), 23, { R = 22, tex = .35, ink = false, amb = .15 })
  scales(whole, 7, 6, 31, "#243a48", .5)
  -- belly plates on throat
  for k = 0, 12 do local yy = 200 + k * 5; ln(250 + k * 14, yy + 6 + k * 3, 290 + k * 14, yy + 10 + k * 3, "#8a9a50", 1) end
  -- mouth interior and teeth along the gap
  local mouth = Wp({ { 178, 158 }, { 240, 170 }, { 296, 182 }, { 350, 194 }, { 340, 200 }, { 296, 190 }, { 240, 178 }, { 200, 170 } })
  fill(mouth, "#3a1424"); fill(Wp({ { 236, 174 }, { 296, 186 }, { 280, 190 }, { 240, 182 } }), "#c8586a")
  for k = 0, 9 do local tx = 190 + k * 15; local ty = 158 + floor(k * 3.7); fill(PL({ { tx, ty }, { tx + 6, ty + 2 }, { tx + 3, ty + 9 } }), "#fff1cf"); P(tx + 3, ty + 8, "#c8b498") end
  for k = 0, 8 do local tx = 196 + k * 15; local ty = 172 + floor(k * 3.4); fill(PL({ { tx, ty }, { tx + 5, ty - 1 }, { tx + 3, ty - 8 } }), "#fff1cf") end
  -- brow ridge, eye, nostril
  local brow = limb({ { 232, 112 }, { 256, 106 }, { 282, 100 } }, 5, 3, 8); litL(brow, SK, 24, { R = 3, tex = .3, ink = false }); c:rim(brow, INK)
  local eye = E(262, 120, 11, 9); c:rim(eye, INK)
  eye:each(function(x, y) local t = ((x - 262) / 11) ^ 2 + ((y - 120) / 9) ^ 2; P(x, y, t < .5 and "#ffe04a" or (t < .8 and "#f09a30" or "#c8602c")) end)
  fill(R(261, 111, 263, 129):clip(eye), INK); P(258, 114, "#fffbe0"); P(259, 114, "#fffbe0")
  glow(262, 120, 28, "#ffc040", .22)
  fill(E(198, 138, 3, 2), "#241a30"); P(197, 137, "#6a4a5a")
  for k, q in ipairs{ { 196, 128, 4 }, { 188, 116, 5 }, { 176, 102, 6 }, { 160, 90, 5 } } do fill(E(q[1], q[2], q[3], q[3]), "#8a7a8c"); P(q[1] - 1, q[2] - 1, "#d8c8d0") end
  -- hoard
  local hm = mk(); for x = 0, 479 do local top = 238 + floor(6 * sin(x / 40) + 4 * sin(x / 13 + 2)) - floor(14 * max(0, 1 - abs(x - 120) / 110)); for y = top, 269 do hm:set(x, y) end end
  litL(hm, RR("#fff0a0", "#f2b84a", "#c0742c", "#6a3a38"), 3, { R = 14, tex = .6, sc = 2, ink = false })
  for i = 0, 90 do local x, y = floor(H(i, 1, 6) * 470) + 4, 240 + floor(H(i, 2, 6) * 28)
    if hm:has(x, y) then fill(E(x, y, 4, 2), "#f2b84a"); c:rim(E(x, y, 4, 2), "#7a4a30"); P(x - 2, y - 1, "#fff0b8") end end
  litL(E(60, 244, 8, 6), RR("#ffd0e0", "#e8487a", "#a02a62", "#5a1a48"), 4, { R = 4, tex = 0 })
  litL(E(420, 246, 9, 7), RR("#d8ffff", "#48c8e0", "#2a8ac0", "#1a4a90"), 5, { R = 4, tex = 0 })
  -- bones and a crooked sword as small props
  ln(300, 252, 330, 262, "#f0e0c8", 2); fill(E(298, 251, 3, 3), "#f0e0c8"); fill(E(332, 263, 3, 3), "#f0e0c8")
  -- smoke from nostril
  for i, q in ipairs{ { 190, 124, 4 }, { 182, 112, 5 }, { 174, 98, 6 } } do end
  for i = 1, 40 do local x, y = floor(H(i, 8, 8) * 470), floor(H(i, 9, 8) * 250); if H(i, 2, 2) > .5 then P(x, y, "#ffe49a") end end
  c:sparkle(90, 230); c:sparkle(380, 240)
end)

---------------------------------------------------------------- 10 oasis that moves
local function palm(x, y, h, lean, seed)
  local tr = limb({ { x, y }, { x + lean * .4, y - h * .5 }, { x + lean, y - h } }, 3, 1.8, 10)
  c:rim(tr, INK); lit(tr, RR("#d8a874", "#946648", "#5e3e3c", "#3a2634"), seed, { R = 3, tex = .5, ink = false })
  for k = 0, 8 do local yy = y - 4 - k * (h / 10); if k % 1 == 0 then local xx = x + lean * ((y - yy) / h) * (1 - 0 ) ; ln(xx - 2, yy, xx + 2, yy, "#5e3e3c", 1) end end
  local tx, ty = x + lean, y - h
  for k = 0, 7 do
    local a = -pi + k * pi / 7 + (k % 2) * .12
    local len = h * .62
    local fr = limb({ { tx, ty }, { tx + cos(a) * len * .5, ty + sin(a) * len * .5 - 8 }, { tx + cos(a) * len, ty + sin(a) * len * .7 + 7 } }, 2.4, .8, 10)
    c:rim(fr, INK); lit(fr, RR("#c8f070", "#58b048", "#2e7a44", "#1e4a38"), seed + k, { R = 2, tex = .3, ink = false })
  end
  fill(E(tx - 2, ty + 3, 3, 3), "#a86a3c"); fill(E(tx + 3, ty + 4, 3, 3), "#a86a3c")
end
pic("wonder-the-oasis-that-moves", function()
  GX.bands(c, 0, 170, { "#6a8ce0", "#8ca8e8", "#e8b0b0", "#ffc890", "#ffdc9c", "#fff0b8" }, 6, .12)
  cloudp(80, 40, 60, "#fff0e0", "#f0b8b0"); cloudp(400, 56, 70, "#fff0e0", "#f0b8b0"); cloudp(250, 24, 40, "#fff0e0", "#f0b8b0")
  fill(E(70, 150, 30, 30):clip(R(0, 0, 479, 156)), "#fff6c8")
  layer({ { 100, 140, .5 }, { 350, 144, .4 } }, 160, { hi = "#f8d8b8", base = "#e0a890", shade = "#b87c80", deep = "#8a5870" }, 7, .4, 200, "#f0c8a8")
  local DN = RR("#ffe4a8", "#f0b878", "#c07a58", "#744050")
  GX.ground(c, function(x) return 174 + floor(8 * sin(x / 52) + 3 * sin(x / 17)) end, DN, 5, { top = .9, fall = .6, tex = .3 })
  for i = 0, 90 do local x, y = floor(H(i, 1, 2) * 480), 180 + floor(H(i, 2, 2) * 90); for k = 0, 4 do P(x + k, y - floor(k / 3), "#ffe4b0") end end
  local gy = 238
  -- far legs
  local SKN = RR("#d8c890", "#a8946a", "#6e5a58", "#44343c")
  local function leg(x0, w, far)
    local m = PL({ { x0, 190 }, { x0 + w, 190 }, { x0 + w + 4, gy - 4 }, { x0 + w + 8, gy + 8 }, { x0 - 8, gy + 8 }, { x0 - 4, gy - 4 } })
    litL(m, far and RR(SKN.shade, SKN.shade, SKN.deep, SKN.deep) or SKN, x0, { R = 8, tex = .5, sc = 3 })
    vor(m, 5, 4, 77 + x0, function(x, y, qx, qy, id, d1, gap) if gap < 1 then shadeTo(x, y, "#2e2030", .5) end end)
    for k = 0, 2 do fill(R(x0 - 6 + k * 6, gy + 5, x0 - 3 + k * 6, gy + 8), "#e8d8b0") end
  end
  leg(168, 38, true); leg(318, 40, true)
  -- tail and head
  local tail = limb({ { 380, 200 }, { 404, 206 }, { 420, 218 } }, 6, 2, 8); c:rim(tail, INK); lit(tail, SKN, 9, { R = 3, tex = .4, ink = false })
  local neck = limb({ { 130, 196 }, { 104, 186 }, { 78, 190 } }, 14, 11, 10)
  local head = E(62, 192, 20, 15):add(PL({ { 70, 186 }, { 44, 196 }, { 46, 208 }, { 70, 206 } }))
  local hh = neck:copy():add(head)
  litL(hh, SKN, 11, { R = 10, tex = .5, sc = 3 })
  vor(hh, 5, 4, 12, function(x, y, qx, qy, id, d1, gap) if gap < 1 then shadeTo(x, y, "#2e2030", .45) end end)
  fill(PL({ { 44, 198 }, { 62, 202 }, { 62, 204 }, { 44, 204 } }), "#6e5a58")
  P(46, 198, INK); fill(E(60, 184, 5, 4), "#ffe49a"); fill(E(60, 184, 2, 3), INK); P(58, 183, "#fffbe0")
  ln(48, 180, 70, 178, "#6e5a58", 2)
  -- the shell: big patterned dome
  local shell = rough(E(250, 192, 150, 100):clip(R(90, 72, 410, 212)), 21)
  local SHELLR = RR("#f6c880", "#c8884a", "#8a5048", "#4a2c40")
  litL(shell, SHELLR, 22, { R = 56, tex = .2, sc = 5 })
  local pal = { "#d8603a", "#2aa09a", "#f2b84a", "#8a4a8c", "#e8884a" }
  vor(shell, 36, 28, 41, function(x, y, qx, qy, id, d1, gap)
    local o = c:get(x, y); if not o then return end
    local col = pal[1 + floor(id * 5) % 5]
    local ring = floor(d1 / 4) % 3
    if gap < 1.5 then P(x, y, mix(o, "#2e1c26", .72))
    elseif x < qx and y < qy and gap < 3 then P(x, y, mix(o, "#fff1cf", .4))
    elseif ring == 0 then P(x, y, mix(o, col, .62))
    elseif ring == 1 then P(x, y, mix(o, "#fff1cf", .22))
    else P(x, y, mix(o, col, .3)) end
  end)
  -- marginal scutes along the shell hem
  for k = 0, 19 do local xx = 112 + k * 14; local m = R(xx, 200, xx + 12, 212); m:clip(shell); c:rim(m, INK); fill(m, k % 2 == 0 and "#c8884a" or "#a8663e"); fill(R(xx, 200, xx + 12, 201), "#f6c880"); fill(R(xx, 210, xx + 12, 212), "#6a3a44") end
  c:rim(shell, INK)
  -- oasis on the shell crown
  local pond = rough(E(250, 78, 44, 6), 44); c:rim(pond, INK)
  pond:each(function(x, y) P(x, y, y < 78 and "#48b8d8" or "#2a8ac0"); if (x * 3 + y) % 7 == 0 then P(x, y, "#a8ecff") end end)
  for k = 0, 11 do local gx = 204 + k * 8; GX.tuft(c, gx, 82, RR("#bef08a", "#58b860", "#2e8450", "#1a5a40")) end
  palm(226, 80, 56, -12, 31); palm(276, 78, 70, 10, 32); palm(250, 74, 36, 3, 33)
  fill(R(244, 86, 256, 92), "#e8b078"); c:rim(R(244, 86, 256, 92), INK) -- tiny tent
  fill(PL({ { 242, 86 }, { 250, 76 }, { 258, 86 } }), "#e0443a"); c:rim(PL({ { 242, 86 }, { 250, 76 }, { 258, 86 } }), INK)
  -- near legs
  leg(130, 42, false); leg(284, 44, false)
  -- footprints and dust trail behind
  for i = 0, 8 do fill(E(430 + i * 5 - 20, 252 + (i % 2) * 6, 5, 2), "#a8663e"); dust(420 + i * 7, 246, 10, 3, "#f0c890", i) end
  for i = 0, 6 do fill(E(30 + i * 14, 256 + (i % 2) * 5, 5, 2), "#a8663e") end
  -- quirk: meerkat on the shell with a tiny water jug
  local mx, my = 150, 134
  litL(E(mx, my + 8, 4, 7), RR("#f8dcb0", "#d8a870", "#946048", "#5e3a3c"), 5, { R = 3, tex = 0 }); litL(E(mx, my, 3, 3), RR("#f8dcb0", "#d8a870", "#946048", "#5e3a3c"), 6, { R = 2, tex = 0 }); P(mx - 1, my, INK); P(mx + 1, my, INK)
  c:sparkle(300, 60); c:sparkle(120, 90)
end)

---------------------------------------------------------------- 11 labyrinth isle
local seedv = 12345
local function rnd() seedv = (seedv * 1103515245 + 12345) % 2147483648; return seedv / 2147483648 end
pic("wonder-the-labyrinth-isle", function()
  GX.bands(c, 0, 66, { "#7cb0e8", "#a0c8ee", "#c8e0f0", "#f4eed0" }, 4, .1)
  cloudp(90, 24, 60, "#fffaf0", "#cfe0ec"); cloudp(380, 34, 80, "#fffaf0", "#cfe0ec")
  -- sea
  for y = 62, 269 do for x = 0, 479 do local t = (y - 62) / 208; local n = GX.vn(x, y * 2, 12, 5); local cols = { "#6ad0d8", "#48b8d0", "#38a0c8", "#2a88b8", "#2070a8" }; P(x, y, cols[max(1, min(5, 1 + floor((t * .8 + (n - .5) * .3) * 5)))]) end end
  for i = 0, 150 do local x, y = floor(H(i, 1, 4) * 470), 66 + floor(H(i, 2, 4) * 200); for k = 0, 4 + floor(H(i, 3, 4) * 6) do P(x + k, y, "#c8f4f0") end end
  -- far sail and sea stack
  fill(PL({ { 390, 62 }, { 390, 50 }, { 402, 62 } }), "#fff1cf"); fill(R(388, 62, 404, 63), "#6a4a48")
  -- island: beach ring + grass
  local iso = rough(E(240, 168, 232, 104), 9)
  lit(iso, RR("#fff0c0", "#f0d090", "#c89a6a", "#8a6a58"), 2, { R = 30, tex = .3 })
  local grass = rough(E(240, 166, 216, 94), 10)
  c:rim(grass, "#c89a6a")
  grass:each(function(x, y) local n = GX.vn(x, y, 6, 3); P(x, y, n > .6 and "#7cc858" or (n < .3 and "#4e9c48" or "#62b050")) end)
  for i = 0, 40 do local x = floor(H(i, 3, 3) * 470); local y = 130 + floor(H(i, 4, 3) * 130); if grass:has(x, y) then GX.flower(c, x, y, ({ "#ff8aa8", "#ffe07a", "#fff1cf" })[1 + i % 3]) end end
  -- maze
  local cols, rows, px, py, wx, wy, hh = 22, 12, 18, 13, 4, 3, 5
  local x0, y0 = 40, 92
  local inside = {}
  for j = 0, rows - 1 do inside[j] = {} for i = 0, cols - 1 do
    local u, v = (i + .5 - cols / 2) / (cols / 2), (j + .5 - rows / 2) / (rows / 2)
    inside[j][i] = (u * u + v * v) <= 1.02
  end end
  local vis, passV, passH = {}, {}, {}  -- passV[j][i]: opening between (i-1,j) and (i,j); passH[j][i]: between (i,j-1),(i,j)
  for j = 0, rows do vis[j] = {} passV[j] = {} passH[j] = {} end
  local function ins(i, j) return i >= 0 and j >= 0 and i < cols and j < rows and inside[j][i] end
  seedv = 777
  local sx_, sy_ = 11, 6
  local stack = { { sx_, sy_ } }; vis[sy_][sx_] = true
  while #stack > 0 do
    local cur = stack[#stack]; local i, j = cur[1], cur[2]
    local opts = {}
    for _, dd in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do local ni, nj = i + dd[1], j + dd[2]; if ins(ni, nj) and not vis[nj][ni] then opts[#opts + 1] = { ni, nj, dd } end end
    if #opts == 0 then stack[#stack] = nil else
      local o = opts[1 + floor(rnd() * #opts)]
      if o[3][1] == 1 then passV[j][i + 1] = true elseif o[3][1] == -1 then passV[j][i] = true elseif o[3][2] == 1 then passH[j + 1][i] = true else passH[j][i] = true end
      vis[o[2]][o[1]] = true; stack[#stack + 1] = { o[1], o[2] }
    end
  end
  -- extra openings for loops and an open plaza in the centre
  for k = 1, 22 do local i, j = 1 + floor(rnd() * (cols - 2)), 1 + floor(rnd() * (rows - 2)); if ins(i, j) and ins(i - 1, j) then passV[j][i] = true end end
  for j = 5, 6 do for i = 9, 12 do passV[j][i] = true end end
  for i = 9, 12 do passH[6][i] = true end
  -- entrance at the bottom
  local ei = 11; while not ins(ei, rows - 1) do ei = ei + 1 end
  passH[rows][ei] = true
  -- floor paths (sand) with speckle
  for j = 0, rows - 1 do for i = 0, cols - 1 do if inside[j][i] then
    local rx0, ry0 = x0 + i * px + wx, y0 + j * py + wy
    local rx1, ry1 = x0 + (i + 1) * px - 1, y0 + (j + 1) * py - 1
    for yy = ry0, ry1 do for xx = rx0, rx1 do P(xx, yy, (H(xx, yy, 5) > .86) and "#d8b078" or "#f4dc9c") end end
    if passV[j][i] then for yy = ry0, ry1 do for xx = rx0 - wx, rx0 - 1 do P(xx, yy, "#f4dc9c") end end end
    if passH[j][i] then for yy = ry0 - wy, ry0 - 1 do for xx = rx0, rx1 do P(xx, yy, "#f4dc9c") end end end
  end end end
  -- hedge walls, drawn back to front
  local walls = {}
  for j = 0, rows do for i = 0, cols do
    -- horizontal wall above row j at column i
    local a, b = ins(i, j - 1), ins(i, j)
    if (a or b) and not passH[j][i] then walls[#walls + 1] = { x0 + i * px, y0 + j * py, x0 + (i + 1) * px + wx - 1, y0 + j * py + wy - 1, 1 } end
    local l, r = ins(i - 1, j), ins(i, j)
    if (l or r) and not passV[j][i] and j < rows then walls[#walls + 1] = { x0 + i * px, y0 + j * py, x0 + i * px + wx - 1, y0 + (j + 1) * py + wy - 1, 0 } end
  end end
  table.sort(walls, function(a, b) if a[4] ~= b[4] then return a[4] < b[4] end return a[5] < b[5] end)
  local HG = RR("#bef06a", "#58b048", "#2e7a44", "#1a4a38")
  for _, w in ipairs(walls) do
    local X0, Y0, X1, Y1 = w[1], w[2], w[3], w[4]
    -- front (south) face
    for yy = Y1 - hh + 1, Y1 do for xx = X0, X1 do local n = H(xx, yy, 8); P(xx, yy, n > .75 and HG.base or (yy == Y1 and HG.deep or HG.shade)) end end
    -- top face lifted by hh
    for yy = Y0 - hh, Y1 - hh do for xx = X0, X1 do
      local n = GX.vn(xx, yy, 2.5, 6); local col = n > .62 and HG.hi or (n < .3 and HG.base or "#78c858")
      if yy == Y0 - hh then col = HG.hi end
      P(xx, yy, col)
    end end
    P(X0, Y0 - hh, HG.deep); P(X1, Y0 - hh, HG.base)
  end
  -- centre: fountain plaza with gold gnome statue (non-player)
  local cx, cy = x0 + 11 * px + wx, y0 + 6 * py + 4
  litL(E(cx, cy + 6, 22, 8), RR("#e8e8e0", "#a8a8b8", "#686880", "#444458"), 3, { R = 6, tex = .3 })
  fill(E(cx, cy + 5, 18, 5), "#48b8d8"); fill(E(cx, cy + 4, 12, 3), "#a8ecff")
  litL(R(cx - 4, cy - 14, cx + 4, cy + 4), RR("#e8e8e0", "#a8a8b8", "#686880", "#444458"), 4, { R = 3, tex = 0 })
  litL(E(cx, cy - 22, 5, 7), RR("#fff0a0", "#f2b84a", "#c0742c", "#7a4030"), 5, { R = 4, tex = 0 })
  local hat = PL({ { cx - 5, cy - 26 }, { cx, cy - 40 }, { cx + 5, cy - 26 } }); c:rim(hat, INK); fill(hat, "#f2b84a"); P(cx - 1, cy - 34, "#fff0b8")
  c:sparkle(cx, cy - 46)
  -- entrance dock and little boat
  fill(R(ei * px + x0 + wx - 4, y0 + rows * py + 2, ei * px + x0 + wx + 14, 268), "#9a6a48")
  for k = 0, 8 do ln(ei * px + x0 + wx - 4, 250 + k * 2, ei * px + x0 + wx + 14, 250 + k * 2, "#6a4a3c", 1) end
  -- quirk: lost goat wandering a path
  local gx_, gy_ = x0 + 5 * px + 8, y0 + 8 * py + 8
  litL(E(gx_, gy_ + 1, 5, 3), RR("#fff6e8", "#e0d4c8", "#a89aa4", "#6a5a6e"), 3, { R = 3, tex = 0 }); fill(E(gx_ + 5, gy_ - 2, 2, 2), "#e0d4c8"); P(gx_ + 6, gy_ - 5, INK); P(gx_ + 4, gy_ - 5, INK); fill(R(gx_ - 3, gy_ + 3, gx_ - 3, gy_ + 5), INK); fill(R(gx_ + 3, gy_ + 3, gx_ + 3, gy_ + 5), INK)
  for i = 1, 20 do c:sparkle(floor(H(i, 5, 5) * 470) + 4, 72 + floor(H(i, 6, 5) * 190)) end
end)

---------------------------------------------------------------- 12 tea garden slopes
pic("wonder-tea-garden-slopes", function()
  GX.bands(c, 0, 150, { "#8ed0d8", "#b8e4d0", "#e8f0c0", "#fff0b8", "#ffe0a0" }, 3, .12)
  cloudp(80, 28, 70, "#fffaf0", "#d8ecdc"); cloudp(250, 18, 56, "#fffaf0", "#d8ecdc"); cloudp(430, 40, 60, "#fffaf0", "#d8ecdc")
  fill(E(110, 112, 22, 22), "#fff6c8")
  layer({ { 40, 90, .7 }, { 200, 100, .6 }, { 420, 86, .8 } }, 140, { hi = "#c8ecd0", base = "#98d0b0", shade = "#70b49c", deep = "#4a9488" }, 5, .5, 200, "#e8f4d0")
  layer({ { 120, 110, .5 }, { 360, 112, .4 }, { 470, 100, .6 } }, 140, { hi = "#a8dc98", base = "#6cb878", shade = "#4a9a6c", deep = "#307a60" }, 8, .3, 200, "#d8ecb8")
  local function hillTop(x) return 112 + floor(34 * ((x - 330) / 330) ^ 2 + 4 * sin(x / 30)) end
  -- hilltop grass
  for x = 0, 479 do for y = hillTop(x) - 4, 270 do local n = GX.vn(x, y, 6, 4); P(x, y, n > .6 and "#9ad45a" or (n < .3 and "#5fae48" or "#78c452")) end end
  local spacing = { 26, 34, 24, 38, 30, 42, 50 }
  local TYPES = {
    { RR("#9ad45a", "#4aa048", "#2e7a44", "#1e5438"), "#4aa048" },
    { RR("#d8f080", "#8ccc48", "#5a9a44", "#3a6a3c"), "#8ccc48" },
    { RR("#a8dc68", "#4e9a48", "#2e6e44", "#1e4a38"), "#ff9ab8" },
    { RR("#e8b078", "#b87a4e", "#7a4a40", "#4a2c3c"), "#8ccc48" },
    { RR("#88c8a0", "#3e8a68", "#2a6458", "#1a4448"), "#c8f0e8" },
    { RR("#b8e070", "#62a848", "#3a7a44", "#244e38"), "#ffe07a" },
    { RR("#9ad45a", "#4aa048", "#2e7a44", "#1e5438"), "#4aa048" },
  }
  local base = hillTop(0)
  local edges = {}
  local acc = {}
  for k = 1, 7 do edges[k] = {} end
  for x = 0, 479 do
    local y = hillTop(x) + 12
    for k = 1, 7 do
      local sp = spacing[k] + floor(5 * sin(x / (24 + k * 7) + k * 1.7))
      edges[k][x] = y; y = y + sp
    end
  end
  local WALL = RR("#e8d4a8", "#b49a7a", "#7c6a6a", "#4a3c4c")
  for k = 1, 7 do
    local T = TYPES[k]; local R6t = GX.ramp6(T[1])
    for x = 0, 479 do
      local yt = edges[k][x]; local yn = (k < 7) and edges[k + 1][x] or 270
      local surf = floor((yn - yt) * .62)
      for y = yt, min(269, yn - 1) do
        if y - yt < surf then
          local v = .55 + (GX.vn(x, y, 4, k) - .5) * .5 - (y - yt) / max(1, surf) * .15
          if y == yt then v = .95 end
          P(x, y, R6t[GX.idx(v)])
        else
          local bw = (floor((y - yt) / 4) % 2 == 0) and 0 or 5
          local brick = ((x + bw) % 10 == 0) or ((y - yt) % 4 == 3)
          local col = brick and WALL.shade or WALL.base
          if y - yt == surf then col = WALL.hi end
          if y == yn - 1 then col = WALL.deep end
          if GX.vn(x, y, 3, k + 9) > .75 and not brick then col = WALL.hi end
          P(x, y, col)
        end
      end
    end
    -- bush rows
    local rowsN = (k == 4) and 0 or 2
    for r = 1, rowsN do
      for xx = (r % 2) * 5, 479, 10 do
        local yt = edges[k][min(479, xx)]; local yn = (k < 7) and edges[k + 1][min(479, xx)] or 270
        local surf = floor((yn - yt) * .62)
        local by = yt + floor(surf * r / (rowsN + .6)) + 2
        if by < yt + surf - 1 and by < 266 then
          local m = E(xx, by, 6, 3 + (k > 4 and 1 or 0))
          lit(m, T[1], xx + k, { R = 3, tex = .4, ink = false, sc = 2 })
          m:each(function(x, y) if not m:has(x, y + 1) then P(x, y, T[1].deep) end end)
          if H(xx, k, r) > .45 then P(xx - 2, by - 2, T[2]); P(xx + 1, by - 1, T[2]) end
        end
      end
    end
    if k == 4 then for xx = 3, 479, 6 do local yt = edges[k][xx]; local yn = edges[k + 1][xx]; for y = yt + 2, yt + floor((yn - yt) * .62) - 2, 5 do P(xx, y, "#8ccc48"); P(xx + 1, y - 1, "#8ccc48") end end end
    -- mist between tiers
    if k == 2 or k == 5 then
      for x = 0, 479 do for y = edges[k][x] - 6, edges[k][x] + 4 do if (x + y) % 2 == 0 and GX.vn(x, y, 12, 3 + k) > .5 then shadeTo(x, y, "#fffaf0", .5) end end end
    end
  end
  -- switchback stone path to the teapot
  local path = limb({ { 110, 270 }, { 150, 236 }, { 96, 206 }, { 170, 176 }, { 120, 156 }, { 220, 140 }, { 290, 130 } }, 5, 3, 14)
  c:rim(path, "#7c6a6a"); path:each(function(x, y) P(x, y, ((x // 3 + y // 2) % 2 == 0) and "#f4e4b8" or "#d8c498") end)
  -- giant teapot house
  local tx, ty = 346, 96
  local TP = RR("#ffb09a", "#e0584a", "#a83a48", "#6a2440")
  fill(E(tx, ty + 34, 62, 6), "#3e6a3c")
  local spout = limb({ { tx - 40, ty + 14 }, { tx - 64, ty + 4 }, { tx - 74, ty - 22 }, { tx - 86, ty - 34 } }, 11, 5, 14)
  local handle = E(tx + 56, ty + 8, 22, 26):cut(E(tx + 56, ty + 8, 13, 18)):cut(R(tx - 10, ty - 40, tx + 36, ty + 50))
  local body = E(tx, ty + 6, 56, 38)
  local lid = E(tx, ty - 28, 26, 8)
  local dome = E(tx, ty - 34, 18, 12):clip(R(tx - 30, ty - 50, tx + 30, ty - 30))
  local all = spout:copy():add(handle):add(body):add(lid):add(dome)
  c:rim(all, INK)
  lit(handle, TP, 3, { R = 5, tex = .2, ink = false }); lit(spout, TP, 4, { R = 6, tex = .2, ink = false })
  lit(body, TP, 5, { R = 34, tex = .2, ink = false })
  lit(dome, RR("#fff1cf", "#f0d090", "#c09068", "#7a5058"), 6, { R = 8, tex = .2, ink = false })
  lit(lid, TP, 7, { R = 5, tex = .2, ink = false })
  lit(E(tx, ty - 47, 5, 5), RR("#fff0a0", "#f2b84a", "#c0742c", "#7a4030"), 8, { R = 3, tex = 0 })
  -- cream pattern band with gold blossoms
  body:each(function(x, y) local yy = y - (ty - 6); if yy >= 0 and yy <= 9 then local o = c:get(x, y); P(x, y, (yy == 0 or yy == 9) and "#f2b84a" or mix(o, "#fff1cf", .78)) end end)
  for k = -5, 5 do local bx = tx + k * 10 - (k % 2) * 0; local o = body:has(bx, ty - 1); if o then fill(E(bx, ty - 1, 2, 2), "#e0584a"); P(bx, ty - 1, "#f2b84a"); P(bx - 2, ty - 1, "#6aa848"); P(bx + 2, ty - 1, "#6aa848") end end
  -- door, windows, spout opening
  local door = E(tx, ty + 24, 9, 10):add(R(tx - 9, ty + 24, tx + 9, ty + 34)); c:rim(door, INK); fill(door, "#3a1c30"); fill(E(tx, ty + 28, 5, 6), "#ffcf6a")
  for _, wx_ in ipairs{ -32, 32 } do local w = E(tx + wx_, ty + 14, 5, 5); c:rim(w, INK); fill(w, "#ffe49a"); P(tx + wx_ - 2, ty + 12, "#fff6d8"); ln(tx + wx_ - 5, ty + 14, tx + wx_ + 5, ty + 14, "#a83a48", 1) end
  fill(E(tx - 86, ty - 35, 5, 2), "#3a1c30")
  -- steam
  for i, q in ipairs{ { -88, -46, 6 }, { -80, -62, 8 }, { -92, -80, 9 }, { -82, -98, 10 } } do
    local m = rough(E(tx + q[1], ty + q[2], q[3], q[3] - 1), 60 + i); fill(m, "#fff6e4"); fill(m:copy():shift(1, 2):cut(m), "#e8d8cc")
    m:each(function(x, y) if not m:has(x - 1, y - 1) then P(x, y, "#ffffee") end end)
  end
  for i, q in ipairs{ { 4, -62, 5 }, { -2, -76, 7 }, { 6, -92, 7 } } do fill(rough(E(tx + q[1], ty + q[2], q[3], q[3] - 1), 70 + i), "#fff6e4") end
  -- tiny pickers (non-player gnomes) with baskets
  for _, g in ipairs{ { 60, 210 }, { 220, 182 }, { 400, 232 }, { 300, 196 } } do
    local gx_, gy_ = g[1], g[2]
    fill(R(gx_ - 2, gy_ - 6, gx_ + 2, gy_), "#e8884a"); fill(R(gx_ - 1, gy_ - 9, gx_ + 1, gy_ - 7), "#f8d0a8")
    fill(PL({ { gx_ - 3, gy_ - 8 }, { gx_, gy_ - 15 }, { gx_ + 3, gy_ - 8 } }), "#d8483a"); fill(R(gx_ + 3, gy_ - 4, gx_ + 6, gy_ - 1), "#c8884a")
  end
  -- quirk: cat napping on the wall
  local cx_, cy_ = 150, 238
  litL(E(cx_, cy_, 7, 4), RR("#ffd8a0", "#e89a4a", "#a8603c", "#5e3a3c"), 3, { R = 3, tex = 0 }); litL(E(cx_ - 6, cy_ - 1, 3, 3), RR("#ffd8a0", "#e89a4a", "#a8603c", "#5e3a3c"), 4, { R = 2, tex = 0 })
  P(cx_ - 7, cy_ - 4, "#e89a4a"); P(cx_ - 5, cy_ - 4, "#e89a4a"); ln(cx_ + 7, cy_, cx_ + 12, cy_ - 2, "#e89a4a", 1)
  for i = 1, 14 do c:sparkle(floor(H(i, 5, 5) * 470) + 4, floor(H(i, 6, 5) * 120) + 10) end
end)
