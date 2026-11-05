
---------------------------------------------------------------- 3 cenote
local function stalac(x, y0, w, len, seed, far, CX)
  local Rm = far and RR("#506070", "#3a4858", "#2a3444", "#1c2430") or RR("#6e7888", "#46526a", "#303a50", "#1c2234")
  local m = mk()
  for yy = 0, len do
    local t = yy / len
    local hw = (w * (1 - t) ^ .75 + .6) * (1 + (GX.vn(yy, seed, 7, seed + 2) - .5) * .55)
    local cx = x + (CX - x) * .1 * t + (GX.vn(yy, seed, 5, seed) - .5) * 3
    for xx = floor(cx - hw), floor(cx + hw) do m:set(xx, y0 + yy) end
    if yy % 9 == 5 and yy > 8 then m:set(floor(cx - hw) - 1, y0 + yy); m:set(floor(cx + hw) + 1, y0 + yy) end
  end
  litL(m, Rm, seed, { R = max(3, floor(w * .8)), tex = .5, sc = 3 })
  -- dark ring bands and drip tip
  m:each(function(xx, yy) if (yy - y0) % 9 == 6 and (xx + yy) % 2 == 0 then P(xx, yy, Rm.deep) end end)
  m:each(function(xx, yy) if not m:has(xx, yy + 1) and m:has(xx, yy - 1) then P(xx, yy, far and "#5a7080" or "#7a9aaa") end end)
  return m
end
pic("wonder-cenote-of-echoes", function()
  sky({ "#182226", "#202c32", "#283840", "#223038" }, 0, 270, 3)
  for y = 0, 269 do for x = 0, 479 do
    local h = H(x // 3, y // 2, 5)
    if (y + floor(GX.vn(x, y, 22, 7) * 8)) % 11 == 0 and h > .4 then P(x, y, "#34464e") elseif h > .93 then P(x, y, "#34484e") elseif h < .06 then P(x, y, "#121a20") end
  end end
  local CX, CY = 240, 56
  local hole = rough(E(CX, CY, 112, 34), 71)
  local outer = rough(E(CX, CY, 140, 52), 72)
  local ring = outer:copy():cut(hole)
  local skyc = { "#8cd0e8", "#a8dcec", "#c8ecee", "#e8f6e8" }
  hole:each(function(x, y) P(x, y, skyc[max(1, min(4, 1 + floor((y - 22) / 14)))]) end)
  cloudp(210, 50, 44, "#fffdf0", "#cfe6e8"); cloudp(300, 40, 30, "#fffdf0", "#cfe6e8")
  c:rim(hole, INK)
  local RK = RR("#b4b8b4", "#868c90", "#586070", "#38404e")
  lit(ring, RK, 73, { R = 20, tex = .7, sc = 3 })
  ring:each(function(x, y) if hole:has(x, y + 1) or hole:has(x - 1, y + 1) then P(x, y, RK.hi) end end)
  for i = 0, 14 do local a = pi + (i + .5) / 15 * pi; local x, y = CX + 138 * cos(a), CY + 50 * sin(a)
    if i % 2 == 0 then GX.foliage(c, floor(x), floor(y) + 2, 12 + (i % 3) * 3, 6, RR("#8cd05a", "#4a9a48", "#2e6e44", "#1e4a38"), 80 + i) end end
  for i = 0, 6 do local x = 120 + i * 40 + floor(H(i, 2, 2) * 16); local len = 20 + floor(H(i, 4, 4) * 44); for y = 76, 76 + len do P(x + floor(sin(y / 7 + i)), y, y % 6 == 5 and "#9ad45a" or "#4a8a48") end end
  local function ringBot(x) local u = (x - CX) / 140; if abs(u) >= .98 then return 0 end return floor(CY + 52 * sqrt(1 - u * u)) - 5 end
  -- far small stalactites along the lip, converging toward the centre
  for i, x in ipairs{ 130, 152, 176, 204, 276, 304, 328, 350 } do
    local y0 = ringBot(x); if y0 > 0 then stalac(x, y0, 4 + (i % 3), 14 + (i * 7) % 14, 40 + i, true, CX) end
  end
  for i, x in ipairs{ 110, 164, 192, 288, 318, 364 } do
    local y0 = ringBot(x); if y0 > 0 then stalac(x, y0, 7, 30 + (i * 11) % 18, 60 + i, false, CX) end
  end
  -- light shaft: slim rays fanning out, not a solid wedge
  for k = 0, 9 do
    local tx = 150 + k * 21 + floor(H(k, 3, 3) * 6)
    local bx = 70 + k * 38 + floor(H(k, 4, 3) * 12)
    local w0, w1 = 3 + floor(H(k, 5, 3) * 5), 9 + floor(H(k, 6, 3) * 14)
    local ray = PL({ { tx - w0, 84 }, { tx + w0, 84 }, { bx + w1, 230 }, { bx - w1, 230 } })
    ray:each(function(x, y) local o = c:get(x, y); if o then
      local tt = (y - 84) / 146
      if (x + y) % 2 == 0 then P(x, y, mix(o, "#fff4b8", .42 - tt * .1)) elseif (x // 2 + y) % 3 == 0 then P(x, y, mix(o, "#fff4b8", .16)) end end end)
  end
  local fan = PL({ { 140, 84 }, { 340, 84 }, { 400, 228 }, { 80, 228 } })
  fan:each(function(x, y) if (x % 3 == 0 and y % 3 == 0) then shadeTo(x, y, "#fff4b8", .3) end end)
  -- pool basin
  local ledge = E(240, 232, 214, 44); lit(ledge, RK, 5, { R = 18, tex = .6 })
  local pool = E(240, 232, 190, 34)
  c:rim(pool, INK)
  pool:each(function(x, y) local dy = (y - 198) / 68; P(x, y, dy < .2 and "#1a5e78" or (dy < .45 and "#1f7a94" or (dy < .75 and "#28a0aa" or "#44c8c0"))) end)
  for k = 1, 5 do local rx, ry = 20 + k * 24, 4 + k * 5
    E(240, 226, rx, ry):copy():cut(E(240, 226, rx - 2, ry - 1)):clip(pool):each(function(x, y) if (x + k) % 3 ~= 0 then P(x, y, (k % 2 == 1) and "#d8fff0" or "#8ee8dc") end end) end
  fill(E(240, 226, 62, 12), "#e8fff0"); fill(E(240, 226, 36, 7), CREAM)
  for i = 0, 40 do local x, y = 70 + floor(H(i, 41, 1) * 340), 204 + floor(H(i, 43, 1) * 56); if pool:has(x, y) then P(x, y, "#9aeee0"); P(x + 1, y, "#9aeee0") end end
  -- stalagmite reflections of the big drips: dark streaks in the water
  for _, sx in ipairs{ 90, 380 } do for y = 214, 246 do if pool:has(sx, y) and y % 2 == 0 then P(sx + floor(sin(y / 3)), y, "#16485c") end end end
  for _, s in ipairs{ { 156, 242, 16, 6 }, { 200, 236, 12, 5 }, { 290, 238, 12, 5 }, { 334, 244, 16, 6 } } do lit(E(s[1], s[2], s[3], s[4]), RK, s[1], { R = 5, tex = .5 }) end
  lit(E(240, 222, 12, 8), RK, 7, { R = 6, tex = .4 }); fill(R(239, 214, 241, 220), "#ffe38a"); c:sparkle(240, 208)
  for _, f in ipairs{ { 20, 256, 60, 26 }, { 460, 258, 64, 26 } } do lit(rough(E(f[1], f[2], f[3], f[4]), f[1]), RK, f[1], { R = 12, tex = .6 }) end
  -- near giant dark stalactites with perspective (large, hanging from the ceiling at the frame edges)
  stalac(26, -2, 24, 118, 11, false, CX); stalac(70, -2, 13, 70, 12, false, CX); stalac(104, -2, 8, 40, 13, false, CX)
  stalac(456, -2, 26, 126, 14, false, CX); stalac(410, -2, 14, 76, 15, false, CX); stalac(376, -2, 8, 42, 16, false, CX)
  -- quirk: sleeping bat on a stalactite
  local bat = E(70, 82, 4, 5); lit(bat, RR("#8a7a90", "#5e5068", "#443a52", "#2e2640"), 9, { R = 3, tex = 0 })
  P(68, 84, "#ffd0d8"); P(72, 84, "#ffd0d8")
  for i = 1, 30 do local x, y = 150 + floor(H(i, 8, 8) * 180), 100 + floor(H(i, 9, 8) * 110); c:px(x, y, "#fffbe0") end
  c:sparkle(210, 150); c:sparkle(280, 120)
end)

---------------------------------------------------------------- 4 flamingo shallows
local function flamingo(x, y, s, d, pose)
  local PK = RR("#ffc8d2", "#f08aa4", "#c8587c", "#8a3a62")
  local LEG = RR("#f4a0b0", "#d86a88", "#a8466a", "#7a3058")
  local bx, by = x, y - 36 * s
  local function ptr(a, b) return { bx + d * a * s, by + b * s } end
  -- legs
  local function leg(hx, hy, kx, ky, fx, fy) local m = spline({ { hx, hy }, { kx, ky }, { fx, fy } }, max(.7, 1.1 * s), max(.6, .8 * s), nil, 8); c:rim(m, INK); fill(m, LEG.base); return m end
  if pose == "one" or pose == "preen" then
    leg(x - d * 2 * s, by + 8 * s, x - d * 3 * s, y - 16 * s, x - d * 2 * s, y)
    local m = spline({ ptr(2, 8), ptr(10, 18), ptr(3, 19) }, max(.7, 1.1 * s), max(.6, .8 * s), nil, 8); c:rim(m, INK); fill(m, LEG.base)
  else
    leg(x - d * 4 * s, by + 8 * s, x - d * 6 * s, y - 15 * s, x - d * 5 * s, y)
    leg(x + d * 3 * s, by + 8 * s, x + d * 5 * s, y - 15 * s, x + d * 4 * s, y)
    for _, fx in ipairs({ x - d * 5 * s, x + d * 4 * s }) do fill(PL({ { fx, y }, { fx + d * 7 * s, y + 1 }, { fx - d * 2 * s, y + 1 } }), LEG.shade) end
  end
  -- wing for flap pose (behind body)
  if pose == "flap" then
    local wg = PL({ ptr(-2, -6), ptr(-14, -34), ptr(-2, -50), ptr(16, -42), ptr(24, -22), ptr(14, -6) })
    c:rim(wg, INK); lit(wg, PK, 9, { R = 10, tex = .2, ink = false })
    fill(PL({ ptr(24, -22), ptr(14, -6), ptr(-2, -6), ptr(8, -16) }), "#3a2840")
  end
  -- body + tail
  local body = E(bx, by, 15 * s, 10 * s)
  body:add(PL({ ptr(-10, -6), ptr(-27, 4), ptr(-12, 9) }))
  lit(body, PK, 3 + floor(x), { R = floor(10 * s), tex = .3 })
  local wing = E(bx - d * 2 * s, by - 1 * s, 10 * s, 5 * s); fill(wing, PK.hi)
  wing:each(function(xx, yy) if not wing:has(xx, yy + 1) then P(xx, yy, PK.base) end end)
  fill(PL({ ptr(-12, 1), ptr(-26, 3), ptr(-14, 7) }), "#3a2840")
  -- neck + head
  local N = {
    stand = { { 0, 0 }, { 5, -14 }, { -1, -28 }, { 5, -42 }, { 10, -50 } },
    high = { { 0, 0 }, { 2, -18 }, { -3, -34 }, { 2, -52 }, { 6, -62 } },
    feed = { { 0, 0 }, { 10, -4 }, { 19, 8 }, { 22, 24 }, { 19, 36 } },
    preen = { { 0, 0 }, { 8, -14 }, { 0, -28 }, { -12, -24 }, { -18, -12 } },
    one = { { 0, 0 }, { 8, -10 }, { 2, -22 }, { 9, -34 }, { 14, -38 } },
    flap = { { 0, 0 }, { 6, -14 }, { 0, -30 }, { 6, -44 }, { 10, -52 } },
  }
  local npts = {}
  for i, p in ipairs(N[pose]) do npts[i] = { bx + d * (11 + p[1]) * s, by - 5 * s + p[2] * s } end
  local neck = spline(npts, 0, 0, function(t) return (2.8 - t * .9) * s end, 14)
  lit(neck, PK, 20 + floor(x), { R = 4, tex = .2 })
  local h = npts[#npts]
  local hdm = E(h[1], h[2], 3.6 * s, 3 * s); lit(hdm, PK, 21, { R = 3, tex = 0 })
  local bd = ({ stand = { d, .4 }, high = { d, .4 }, feed = { .2 * d, 1 }, preen = { -d, .6 }, one = { d, .4 }, flap = { d, .4 } })[pose]
  local bl = sqrt(bd[1] ^ 2 + bd[2] ^ 2)
  local b1 = { h[1] + bd[1] / bl * 5 * s, h[2] + bd[2] / bl * 5 * s }
  local b2 = { h[1] + bd[1] / bl * 9 * s, h[2] + bd[2] / bl * 9 * s + 3 * s }
  local bk = spline({ h, b1, b2 }, 2.6 * s, 1 * s, nil, 8); c:rim(bk, INK); fill(bk, "#f6d8c8")
  fill(spline({ b1, b2 }, 1.6 * s, 1 * s, nil, 6), "#2b1c26")
  P(h[1] + d * 1.5 * s, h[2] - 1 * s, INK); P(h[1] + d * 1.5 * s - 1, h[2] - 1 * s - 1, CREAM)
  -- ripples at feet
  c:rim(E(x, y + 1, 14 * s, 3 * s), "#ffe6e0")
end
local WSNAP = {}
local function snap() for y = 130, 269 do WSNAP[y] = {} for x = 0, 479 do WSNAP[y][x] = c:get(x, y) end end end
local function reflect(x, y, s)
  local h = floor(62 * s)
  for dy = 1, h do
    local ry = y + dy + 1
    if ry > 268 then break end
    for xx = floor(x - 30 * s), floor(x + 30 * s) do
      if xx >= 0 and xx < 480 then
        local o = c:get(xx, y + 1 - dy)
        local w = WSNAP[y + 1 - dy] and WSNAP[y + 1 - dy][xx]
        local bg = WSNAP[ry] and WSNAP[ry][xx]
        if o and w and o ~= w and bg and (xx + dy) % 2 == 0 then P(xx, ry, mix(bg, o, .55)) end
      end
    end
  end
end
pic("wonder-flamingo-shallows", function()
  sky({ "#f2a0a8", "#f6b4ae", "#f8c8b4", "#fbdcbc", "#fdecc8", "#fff4d8" }, 0, 128, 3)
  cloudp(60, 44, 70, "#ffe0d0", "#f2a8b0"); cloudp(350, 30, 90, "#ffe0d0", "#f2a8b0"); cloudp(210, 64, 50, "#fff0dc", "#f6b8b4")
  fill(E(240, 126, 38, 38):clip(R(0, 0, 479, 126)), "#fff0b8"); fill(E(240, 126, 34, 34):clip(R(0, 0, 479, 126)), "#ffe8a0"); fill(E(240, 126, 24, 24):clip(R(0, 0, 479, 126)), "#fff6c8")
  ridge(function(x) return 114 + floor(4 * sin(x / 50 + 1)) end, "#c8a0b8", 134)
  ridge(function(x) return 121 + floor(3 * sin(x / 30 + 4)) end, "#b08aa8", 134)
  for _, a in ipairs({ { 70, 128, 1.2 }, { 410, 128, 1 }, { 150, 128, .7 }, { 330, 128, .8 } }) do
    local x, y, s = a[1], a[2], a[3]
    fill(R(x - 1, y - 10 * s, x, y), "#6a4a68"); fill(E(x, y - 12 * s, 18 * s, 3 * s), "#6a4a68"); fill(E(x - 5 * s, y - 15 * s, 9 * s, 2 * s), "#6a4a68")
  end
  local wc = { "#e8a0b8", "#e496b6", "#d88ab4", "#c880b0", "#b878b0", "#a070a8" }
  for y = 130, 269 do local i = min(6, 1 + floor((y - 130) / 24)); for x = 0, 479 do P(x, y, wc[i]) end end
  for i = 0, 140 do local y = 132 + (i * 53) % 136; local x = floor(H(i, 71, 1) * 480); local l = 4 + floor(H(i, 73, 1) * 12)
    for k = 0, l do P(x + k, y, (y < 190) and "#ffd0d0" or "#d8a8d0") end end
  for y = 132, 200, 3 do local w = 4 + (y - 130) // 4; for k = -w, w do if floor(H(k, y, 3) * 3) == 0 then P(240 + k, y, "#fff0b8") end end end
  snap()
  local far = { { 40, 150, .26, 1, "stand" }, { 82, 156, .3, -1, "feed" }, { 130, 148, .24, 1, "one" }, { 190, 158, .3, 1, "stand" }, { 296, 152, .26, -1, "preen" }, { 356, 160, .3, -1, "stand" }, { 410, 150, .24, 1, "feed" }, { 452, 158, .28, -1, "one" } }
  for _, f in ipairs(far) do flamingo(f[1], f[2], f[3], f[4], f[5]); reflect(f[1], f[2], f[3]) end
  local hero = { { 66, 214, .85, 1, "preen" }, { 436, 220, .9, -1, "feed" }, { 330, 206, 1.0, -1, "flap" }, { 120, 250, 1.4, 1, "feed" }, { 380, 252, 1.4, -1, "one" }, { 250, 255, 1.7, 1, "stand" } }
  for _, f in ipairs(hero) do flamingo(f[1], f[2], f[3], f[4], f[5]); reflect(f[1], f[2], f[3]) end
  fill(E(190, 236, 12, 3), "#4cb064"); c:rim(E(190, 236, 12, 3), INK)
  lit(E(190, 232, 5, 4), RR("#d8f070", "#8ccc48", "#4e9a44", "#2e6a3c"), 7, { R = 3, tex = 0 }); P(188, 230, INK); P(192, 230, INK)
  for i = 1, 20 do c:sparkle(floor(H(i, 5, 5) * 470) + 4, 140 + floor(H(i, 6, 5) * 120)) end
end)
