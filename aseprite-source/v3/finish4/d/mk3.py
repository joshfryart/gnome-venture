src=open('/home/user/gnome-venture/aseprite-source/v3/finish2/wonder1/batch.lua').read()
i=src.index('---------------------------------------------------------------- pictures')
head=src[:i]
head=head.replace('local HP = dofile(d .. "/../../lib/hp.lua")','local HP = dofile(d .. "/../../lib/hp.lua")\nlocal GX = dofile(d .. "/../../gather/gx.lua")\nlocal vn = GX.vn',1)
new=r'''---------------------------------------------------------------- pictures
local pics = {}
local function M() return HP.mask() end
local function Dm(m, cx, cy, rx, ry) return GX.disc(m, floor(cx), floor(cy), max(1, floor(rx + .5)), max(1, floor((ry or rx) + .5))) end
local function lit(m, Rr, o) o = o or {}; o.R = o.R or 8; o.sc = o.sc or 3; return GX.lit(c, m, GX.ramp6(Rr), o) end

-- polyline sweep: tapered limb
local function limb(pts, r0, r1, X, Y, S)
  local m = M(); local n = #pts - 1
  for i = 1, n do for k = 0, 14 do
    local t = k / 14; local u = ((i - 1) + t) / n
    Dm(m, X(pts[i][1] + (pts[i + 1][1] - pts[i][1]) * t), Y(pts[i][2] + (pts[i + 1][2] - pts[i][2]) * t), (r0 + (r1 - r0) * u) * S, (r0 + (r1 - r0) * u) * S)
  end end
  return m
end

-- goat with real anatomy: barrel body, deep chest, jointed legs with hocks, wedge head, swept horns, beard
local function goat2(x, y, s, d, chew)
  local function X(v) return x + d * floor(v * s) end
  local function Y(v) return y + floor(v * s) end
  local COAT = { hi = "#fff6e0", base = "#eddcc0", shade = "#c4a88c", deep = "#84685c" }
  local LEGC = { hi = "#c8ac8c", base = "#9c7c60", shade = "#6e5646", deep = "#443438" }
  local FAR = { hi = "#c4a888", base = "#a08468", shade = "#725a4c", deep = "#483c3c" }
  local HORN = { hi = "#f4e0a8", base = "#c8a060", shade = "#8a6444", deep = "#4a3434" }
  local function L(pts, a, b) return limb(pts, a, b, X, Y, s) end
  local fr = { { { 9, -32 }, { 11, -20 }, { 10, -10 }, { 10, -1 } }, { { -13, -34 }, { -9, -22 }, { -17, -12 }, { -15, -1 } } }
  for _, p in ipairs(fr) do local m = L(p, 5, 2.2); lit(m, FAR, { R = 3, rimlight = false }) end
  local nr = { { { 17, -32 }, { 18, -20 }, { 17, -10 }, { 17, -1 } }, { { -21, -36 }, { -14, -22 }, { -24, -12 }, { -22, -1 } } }
  -- tail
  lit(L({ { -26, -44 }, { -30, -53 } }, 3.2, 1.6), COAT, { R = 3 })
  -- body
  local body = M(); Dm(body, X(-2), Y(-37), 27 * s, 14.5 * s); Dm(body, X(14), Y(-37), 14 * s, 16 * s); Dm(body, X(-18), Y(-38), 11 * s, 13 * s)
  body:add(L({ { 18, -44 }, { 26, -54 }, { 32, -62 } }, 8.5, 5.5))
  local head = M(); Dm(head, X(37), Y(-63), 6.5 * s, 5.8 * s); Dm(head, X(45), Y(-60), 6 * s, 4.4 * s); Dm(head, X(43), Y(-57), 5 * s, 3 * s)
  body:add(head)
  lit(body, COAT, { R = floor(15 * s), tex = .25, amb = .3 })
  -- patches
  local P1 = { hi = "#c89870", base = "#a8785a", shade = "#7a5448", deep = "#52383c" }
  for _, pa in ipairs{ { -10, -40, 9, 6 }, { 6, -28, 7, 5 }, { -22, -33, 6, 6 }, { 24, -52, 4, 4 } } do
    local pm = M(); Dm(pm, X(pa[1]), Y(pa[2]), pa[3] * s, pa[4] * s)
    pm:each(function(xx, yy) if body:has(xx, yy) and body:has(xx + 1, yy) and body:has(xx, yy + 1) and body:has(xx - 1, yy) and body:has(xx, yy - 1) then
      local l = -(((xx - X(pa[1])) / (pa[3] * s)) * .6 + ((yy - Y(pa[2])) / (pa[4] * s)) * .8)
      c:px(xx, yy, l > .4 and P1.hi or (l > -.3 and P1.base or P1.shade)) end end)
  end
  -- belly shade line + fur ticks
  body:each(function(xx, yy) if vn(xx, yy, 3, 8) > .8 and body:has(xx, yy + 1) and body:has(xx + d, yy) and yy > Y(-36) then c:px(xx, yy, COAT.shade) end end)
  -- near legs
  for _, p in ipairs(nr) do local m = L(p, p[1][1] > 0 and 5.2 or 6.5, 2.2); lit(m, LEGC, { R = 3 }) end
  for _, p in ipairs(nr) do local hx, hy = X(p[4][1]), Y(-1); c:rim(Dm(M(), hx, hy, 2.4 * s, 1.6 * s), INK); c:fillMask(Dm(M(), hx, hy, 2.4 * s, 1.6 * s), "#3a2830") end
  for _, p in ipairs(fr) do local hx, hy = X(p[4][1]), Y(-1); c:fillMask(Dm(M(), hx, hy, 2.4 * s, 1.5 * s), "#3a2830") end
  -- ear, horn, beard
  local ear = L({ { 31, -64 }, { 25, -62 }, { 20, -60 } }, 3.4, 1.4); lit(ear, COAT, { R = 3 }); c:px(X(27), Y(-62), "#e8a0a0")
  local horn = L({ { 34, -68 }, { 32, -80 }, { 24, -88 }, { 17, -87 } }, 2.8, 1); lit(horn, HORN, { R = 3 })
  for k = 1, 3 do local hxx, hyy = X(33 - k * 1.2), Y(-71 - k * 3.4); c:px(hxx, hyy, HORN.deep); c:px(hxx + d, hyy, HORN.deep) end
  lit(L({ { 43, -56 }, { 44, -49 } }, 2.4, 1), COAT, { R = 2, rimlight = false })
  -- face
  local ex, ey = X(40), Y(-65)
  c:fillMask(c:rect(min(ex, ex + d), ey, max(ex, ex + d), ey + 1), INK); c:px(ex, ey, "#ffe8a0")
  c:px(X(51), Y(-61), INK); c:px(X(51), Y(-60), INK)
  for k = 0, 4 do c:px(X(44 + k), Y(-57) + (k > 2 and 1 or 0), "#8c6a5c") end
  c:px(X(47), Y(-62), "#c89c8c")
  if chew then
    for _, g in ipairs{ { 52, -56 }, { 54, -53 }, { 50, -54 } } do local gm = Dm(M(), X(g[1]), Y(g[2]), 3 * s, 3 * s); c:rim(gm, INK); lit(gm, { hi = "#c090d8", base = "#7a4a9a", shade = "#58307a", deep = "#341c54" }, { R = 3, ink = false }) end
    c:fillMask(c:rect(X(52), Y(-60), X(52), Y(-57)), "#5aa04a")
  end
end

pics["wonder-goat-path-vineyards"] = function()
  c:stripes(0, 120, { "#8ec8e8", "#a8d8ee", "#c4e6f0", "#e0f0e8", "#f8f0d0" }, { 3, 3, 3, 3, 3 })
  cloudpuff(60, 44, 70, P.cream, "#c8e0f0"); cloudpuff(330, 36, 80, P.cream, "#c8e0f0"); cloudpuff(210, 66, 40, P.cream, "#d0e4f0")
  hills(110, 8, 45, "#a8b8a0", 2, 160)
  hills(124, 10, 52, "#8aa878", 0, 200)
  -- the terraced hill: each band's contour curves; vine rows follow that curve
  local bands = { { 140, 7, 70, 0, "#b8a45c", "#8a7844" }, { 168, 8, 58, 1.6, "#a8944f", "#7c6a3c" }, { 198, 9, 64, 3.1, "#98804a", "#6e5c36" }, { 232, 10, 72, 4.4, "#88703e", "#5e4e30" }, { 270, 10, 60, 5.7, "#7a6438", "#54452c" } }
  local function edge(i, x) local b = bands[i]; return b[1] + b[2] * sin(x / b[3] + b[4]) + b[2] * .35 * sin(x / (b[3] * .41) + b[4] * 2) end
  -- path (S-curve in perspective), used to keep vines off it
  local PB = { { 244, 138 }, { 296, 190 }, { 176, 214 }, { 214, 272 } }
  local function bz(t) local u = 1 - t; return u*u*u*PB[1][1] + 3*u*u*t*PB[2][1] + 3*u*t*t*PB[3][1] + t*t*t*PB[4][1], u*u*u*PB[1][2] + 3*u*u*t*PB[2][2] + 3*u*t*t*PB[3][2] + t*t*t*PB[4][2] end
  local pathm = M()
  for k = 0, 260 do local t = k / 260; local x, y = bz(t); Dm(pathm, x, y, 4 + 50 * t ^ 1.3, 2 + 14 * t ^ 1.3) end
  for i, b in ipairs(bands) do
    c:terrain(function(x) return edge(i, x) end, b[5], 269, 0, 479)
  end
  for i, b in ipairs(bands) do
    for x = 0, 479 do
      local y0 = floor(edge(i, x) + .5)
      if not pathm:has(x, y0 + 1) then
        px(x, y0, "#e8d68c"); px(x, y0 + 1, (x % 5 < 2) and "#c8b478" or "#9c8858"); px(x, y0 + 2, b[6])
        if (x // 3) % 4 ~= 0 then px(x, y0 + 3, "#7a6240") end
      end
    end
  end
  -- vine rows along the curves
  local function vinerow(i, off, seed)
    for x = 2, 477, 5 do
      local y = floor(edge(i, x) + off + sin(x * .3) * .5)
      if not pathm:has(x, y) and not pathm:has(x + 3, y) and not pathm:has(x - 3, y) then
        local lm = M(); Dm(lm, x, y, 4, 2.6); Dm(lm, x + 2, y - 1, 3, 2)
        lit(lm, { hi = "#9cd068", base = "#58a048", shade = "#3a7a40", deep = "#265a38" }, { R = 3, ink = false, rimlight = false, tex = .3, seed = seed + x })
        px(x - 1, y - 2, "#c8ec88")
        if (x // 5 + seed) % 3 == 0 then px(x, y + 3, "#7a4a9a"); px(x + 1, y + 4, "#9a60b4"); px(x - 1, y + 4, "#5a2a7a") end
      end
    end
    for x = 0, 479 do local y = floor(edge(i, x) + off + 3 + sin(x * .3) * .5); if not pathm:has(x, y) and x % 2 == 0 then px(x, y, "#6a5436") end end
  end
  for i = 1, 4 do local h = edge(i + 1, 240) - edge(i, 240); vinerow(i, 11, i * 11); if h > 26 then vinerow(i, 22, i * 13) end end
  vinerow(5, 11, 61)
  -- the S-curve path itself
  pathm:each(function(x, y) local n = vn(x, y, 3, 5); px(x, y, n > .8 and "#c8a870" or (n < .16 and "#f8ecc0" or "#ecd8a0")) end)
  c:rim(pathm, "#8a6a40")
  -- farmhouse + cypress on the ridge
  local hs = R(60, 112, 98, 134); rim(hs, INK); flat(hs, RP("#f4e4c4", { shade = "#d0b890" }))
  local rf = poly{ { 54, 114 }, { 79, 94 }, { 104, 114 } }; rim(rf, INK); flat(rf, RP("#d0503c", { hi = "#f08a60" }))
  fm(R(74, 120, 82, 134), "#6a3c2c"); fm(R(64, 118, 69, 124), "#8ab8d8"); fm(R(90, 118, 94, 124), "#8ab8d8")
  for _, x in ipairs{ 110, 118, 392, 402 } do local cy = poly{ { x - 5, 134 }, { x, 92 }, { x + 5, 134 } }; rim(cy, INK); fm(cy, "#2c6a48"); cy:each(function(xx, yy) if xx < x - 1 and hash(xx, yy) > 500 then px(xx, yy, "#4a9a5c") end end) end
  -- hero goat chewing a grape cluster, on the path
  fm(E(236, 252, 54, 5), "#b89c68")
  goat2(222, 252, 1.55, 1, true)
  -- small goats on terraces
  goat2(120, edge(2, 120) + 22, .52, 1); goat2(392, edge(3, 392) + 20, .6, -1); goat2(70, edge(4, 70) + 24, .7, 1)
  for _, b in ipairs{ { 60, 256 }, { 94, 262 }, { 420, 258 } } do
    local m = poly{ { b[1] - 18, b[2] - 12 }, { b[1] + 18, b[2] - 12 }, { b[1] + 14, b[2] + 8 }, { b[1] - 14, b[2] + 8 } }; rim(m, INK); flat(m, RP("#b88a50", { hi = "#e0b878" }))
    for y = b[2] - 8, b[2] + 6, 4 do for x = b[1] - 14, b[1] + 14 do if m:has(x, y) then px(x, y, "#7a5a34") end end end
    for k = 0, 8 do local gx, gy = b[1] - 14 + k * 3.5 + (k % 2), b[2] - 15 - (k % 3); local g = E(rd(gx), rd(gy), 4, 4); rim(g, INK); ball(g, RP("#7a4a9a", { hi = "#c090d8" }), rd(gx), rd(gy), 4, 4) end end
  for _, t in ipairs{ { 20, 262 }, { 450, 266 }, { 300, 262 } } do tuft(t[1], t[2], "#9acc68", "#5a9a44") end
end

pics["wonder-lantern-festival-river"] = function()
  c:stripes(0, 150, { "#161640", "#1e1c52", "#2a2262", "#3a2a72", "#52347c", "#7a4684" }, { 3, 3, 3, 3, 3, 3 })
  stars(60, 0, 80, 12, "#fff0d0")
  local mn = E(100, 44, 16, 16); fm(mn, "#fff0c0"); ball(mn, RP("#fff0c0", { hi = "#fffbe8", shade = "#e8d8a8", deep = "#d0c090" }), 100, 44, 16, 16)
  hills(120, 10, 60, "#3a2c66", 1, 170); hills(138, 8, 45, "#2c2458", 3, 200)
  local function tier(cx, y, w, col) local m = poly{ { cx - w - 6, y }, { cx - w, y - 6 }, { cx + w, y - 6 }, { cx + w + 6, y } }; rim(m, INK); flat(m, RP(col, { hi = mix(col, "#fff0c8", .4) })); end
  for i = 0, 3 do local y = 132 - i * 16; local w = 16 - i * 3
    local b = R(240 - w + 2, y - 12, 240 + w - 2, y - 5); rim(b, INK); flat(b, RP("#c8584a", { hi = "#f08a6a" })); fm(R(237, y - 11, 243, y - 6), "#ffd070")
    tier(240, y - 12, w, "#7a3a5a") end
  fm(R(239, 56, 241, 62), INK); px(240, 54, "#ffd070")
  -- river in true perspective: half-width grows from the horizon, gentle bend
  local function cxr(y) return 240 + 16 * sin((y - 148) * .028) end
  local function hw(y) return 12 + ((y - 148) ^ 1.1) * 1.5 end
  local riv = M()
  for y = 149, 269 do local w = hw(y); for x = floor(cxr(y) - w), floor(cxr(y) + w) do if x >= 0 and x <= 479 then riv:set(x, y) end end end
  for y = 149, 269 do
    local t = (y - 148) / 121; local row = log and 0 or 0
    local rr = math.log(1 + (y - 148) * .4) * 8; local fr = rr - floor(rr)
    local w = hw(y)
    for x = 0, 479 do
      if riv:has(x, y) then
        local col = t < .2 and "#2c3a7c" or (t < .5 and "#2a4a8a" or (t < .8 and "#2a5a98" or "#2c68a0"))
        local ripple = fr < .14 and ((floor(x / (3 + t * 9)) + floor(rr)) % 3 ~= 0)
        if ripple then col = t < .5 and "#3e5ea8" or "#4a74b8" end
        local mx = 100 + (cxr(y) - 240) * .2
        if abs(x - mx) < 3 + t * 22 and ripple then col = (floor(rr) % 2 == 0) and "#fff0c0" or "#e8d090" end
        local edge = min(x - (cxr(y) - w), (cxr(y) + w) - x)
        if edge < 2 then col = "#5a7ab0" end
        c:px(x, y, col)
      else
        -- banks: dark land with lit rim and grass texture
        local lx = (x - cxr(y)); local e = abs(lx) - w
        local col = "#1c3a4c"
        if e < 4 then col = "#3a6a60" elseif e < 10 then col = "#2a5058" end
        if hash(x, y) > 930 and e > 6 then col = "#2c6a58" end
        c:px(x, y, col)
      end
    end
  end
  fm(R(0, 148, 479, 150), "#2c2458")
  local function tree(x, y, s) fm(R(x - 1, y - rd(20 * s), x + 1, y), "#2a1c30"); obj(x, y - rd(28 * s), rd(14 * s), rd(12 * s), RP("#2c6a58", { hi = "#4a9a78" })); fm(E(x + 2, y + 1, rd(10 * s), 2), "#142c3c") end
  tree(40, 196, 1.4); tree(110, 190, 1); tree(430, 196, 1.5); tree(372, 180, .9); tree(190, 170, .5); tree(296, 168, .5); tree(18, 236, 1.7); tree(462, 238, 1.8)
  -- richer stone bridge: three arches, parapet with lamp posts, reflection
  local by, bx0, bx1 = 168, 116, 364
  local deck = R(bx0, by - 10, bx1, by + 14); rim(deck, INK)
  local BR = RP("#8a7aa8", { hi = "#c0b0d8", shade = "#5c4e80", deep = "#3a3060" })
  fm(deck, BR.base)
  deck:each(function(x, y)
    local row = floor((y - (by - 10)) / 4); local off = (row % 2) * 4; local col = (x - bx0 + off) % 9
    local h = hash(floor((x - bx0 + off) / 9), row)
    px(x, y, (y - (by - 10)) % 4 == 3 and BR.shade or (col == 0 and BR.shade or (h > 800 and BR.hi or (h < 200 and BR.shade or BR.base)))) end)
  fm(R(bx0, by - 10, bx1, by - 9), BR.hi)
  for k = 0, 2 do
    local acx = 178 + k * 62 - (k == 2 and 0 or 0); local aw = k == 1 and 24 or 20
    local m = E(acx, by + 14, aw, 14):clip(R(acx - aw, by - 2, acx + aw, by + 14)); rim(m, INK)
    m:each(function(x, y) local t = (y - (by - 2)) / 16; c:px(x, y, t < .3 and "#161840" or (t < .7 and "#242c68" or "#2c3a7c")) end)
    for x = acx - aw, acx + aw do px(x, by - 2 - floor(sqrt(max(0, 1 - ((x - acx) / aw) ^ 2)) * 0), BR.hi) end
  end
  for x = bx0, bx1, 12 do fm(R(x, by - 18, x + 2, by - 10), BR.base); px(x, by - 18, BR.hi); px(x + 2, by - 17, BR.shade) end
  fm(R(bx0, by - 15, bx1, by - 14), BR.hi); fm(R(bx0, by - 14, bx1, by - 13), BR.shade)
  for _, lx in ipairs{ bx0 + 2, 240, bx1 - 2 } do
    fm(R(lx - 1, by - 28, lx + 1, by - 18), INK); lantern(lx, by - 32, 5, 6, "#f2a83c")
    for k = 0, 5 do px(lx, by + 18 + k * 3, mix("#f2b83c", "#2a4a8a", .35 + k * .08)); if k % 2 == 0 then px(lx + 1, by + 19 + k * 3, mix("#f2b83c", "#2a4a8a", .5)) end end
  end
  for x = bx0, bx1, 3 do px(x, by + 17 + (x % 2), "#161840") end
  local function stringl(x0, y0, x1, y1, n)
    for k = 0, 40 do local t = k / 40; px(rd(x0 + (x1 - x0) * t), rd(y0 + (y1 - y0) * t + 18 * sin(t * pi)), INK) end
    for i = 1, n - 1 do local t = i / n; local x, y = rd(x0 + (x1 - x0) * t), rd(y0 + (y1 - y0) * t + 18 * sin(t * pi))
      lantern(x, y + 8, 4, 5, (i % 3 == 0) and "#f2603c" or ((i % 3 == 1) and "#f2b83c" or "#e0508a")) end
  end
  stringl(0, 40, 200, 70, 6); stringl(479, 40, 280, 70, 6)
  -- floating lanterns with reflections, scale with depth, kept inside the river
  local cols = { "#f2603c", "#f2b83c", "#e0508a", "#ffd070", "#f28a3c" }
  local list = {}
  for i = 0, 28 do
    local y = 184 + (hash(i, 5) % 70); local w = hw(y)
    list[#list + 1] = { y = y, x = rd(cxr(y) + ((hash(i, 7) % 200) / 100 - 1) * w * .75), col = cols[1 + i % 5], t = (y - 148) / 121 }
  end
  table.sort(list, function(a, b) return a.y < b.y end)
  for _, l in ipairs(list) do
    local s = 3 + rd(l.t * 6); local x, y, col = l.x, l.y, l.col
    fm(E(x, y + s + 2, s + 4, 2), mix(col, "#1c2a5c", .65))
    for k = 1, 5 do local cc = mix(col, "#2a4a8a", .45 + k * .08); for xx = x - rd(s * .5), x + rd(s * .5) do if (xx + k) % 2 == 0 then px(xx, y + s + 3 + k * 2, cc) end end end
    lantern(x, y, s, s - 1, col)
  end
  -- hero raft
  fm(E(240, 246, 60, 9), "#173060")
  local raft = poly{ { 190, 244 }, { 290, 244 }, { 282, 256 }, { 198, 256 } }; rim(raft, INK); flat(raft, RP("#a8704c", { hi = "#d8a070" }))
  for x = 198, 282, 10 do for y = 245, 255 do px(x, y, "#6a4a38") end end
  for k = 0, 6 do fm(R(222 + (k % 2) * 4, 258 + k * 2, 258 - (k % 2) * 4, 258 + k * 2), mix("#f2603c", "#173060", .4 + k * .07)) end
  lantern(240, 218, 18, 20, "#f2603c")
  fm(R(231, 216, 249, 218), "#ffd070"); fm(R(237, 208, 243, 226), "#fff0b0")
  lantern(206, 232, 9, 10, "#f2b83c"); lantern(274, 232, 9, 10, "#e0508a")
  sparkle(240, 190); sparkle(180, 210); sparkle(300, 204)
  fm(E(398, 252, 14, 3), "#2e8a50"); rim(E(398, 252, 14, 3), INK); fm(E(398, 252, 13, 2), "#48b060")
  obj(398, 246, 6, 5, RP("#6cc060")); px(395, 243, P.cream); px(401, 243, P.cream); px(395, 243, INK); px(401, 243, INK)
  fm(R(403, 238, 403, 246), INK); lantern(406, 238, 3, 4, "#ffd070")
  for _, f in ipairs{ { 20, 262 }, { 450, 266 } } do tuft(f[1], f[2], "#3c8a68", "#2a6a50") end
end

---------------------------------------------------------------- run
local only = app.params.name
local order = { "wonder-goat-path-vineyards", "wonder-lantern-festival-river" }
for _, n in ipairs(order) do
  if not only or only == "all" or only == n then
    c = HP.canvas{ w = 480, h = 270, scale = 1, name = n }
    local ok, e = xpcall(pics[n], debug.traceback); if not ok then print(e) end
    c:hem(2); c:hem(267)
    c:save{ aseprite = d .. "/out/" .. n .. ".aseprite", png = d .. "/out/" .. n .. ".png", scale = 1 }
  end
end
'''
open('batch3.lua','w').write(head+new)
