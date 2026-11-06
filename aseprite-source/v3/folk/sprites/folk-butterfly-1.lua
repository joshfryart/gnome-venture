-- folk-butterfly-1 sprite (folk F2_12) variant: 1
local V = 1
local NAME = "folk-butterfly-1"
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "/home/user/gnome-venture/aseprite-source/v3/folk/sprites/"
-- one design per variant: 1 gardener (sunny yellow rounded wings, green dungarees, straw hat, trowel)
-- 2 traveller (morpho-blue pointed wings, brown coat, rust scarf, olive cap, pack, lantern)
-- 3 cook (coral scalloped tailed wings with eyespots, mint smock, cream apron, mustard kerchief, copper ladle)
local PAL = {
  [1] = { W = { hi = "#fff09a", base = "#f7c843", shade = "#d98e3e", deep = "#8a4e5e" }, DK = "#4a3352", SP = "#fbe9c0", AC = "#ec7a3e",
    FUZ = { hi = "#c49a74", base = "#94684f", shade = "#664654", deep = "#432f45" },
    CL = { hi = "#b4dc72", base = "#72b24e", shade = "#43805a", deep = "#2f5250" },
    HAT = { hi = "#fcebb0", base = "#e9c274", shade = "#bb8a5c", deep = "#7c5856" },
    BOOT = { hi = "#a07a62", base = "#6e4e4c", shade = "#4c3446", deep = "#35253a" },
    PROP = { hi = "#e6eef0", base = "#a8b8c8", shade = "#6e7898", deep = "#4a4a6e" },
    WOOD = { hi = "#d9a066", base = "#a8703f", shade = "#764c44", deep = "#4e3240" },
    BG = { base = "#dbe596", shade = "#b9c676", deep = "#8e9c5a" } },
  [2] = { W = { hi = "#a8ecf4", base = "#55b6e4", shade = "#3b74bc", deep = "#353f80" }, DK = "#2f2a58", SP = "#e8f4f0", AC = "#f0b860",
    FUZ = { hi = "#a69cbc", base = "#766c92", shade = "#524970", deep = "#382f4e" },
    CL = { hi = "#d4a678", base = "#a2704c", shade = "#734c48", deep = "#4c3240" },
    SC = { hi = "#f6a26e", base = "#dc6442", shade = "#a83e42", deep = "#6e2a3e" },
    HAT = { hi = "#8fa58a", base = "#62786a", shade = "#465460", deep = "#32384a" },
    PACK = { hi = "#ead2a0", base = "#c8a470", shade = "#977660", deep = "#64504e" },
    BOOT = { hi = "#8e7a9e", base = "#5e4e70", shade = "#41365a", deep = "#2f2742" },
    PROP = { hi = "#ffe08a", base = "#d8a845", shade = "#a06c3e", deep = "#674248" },
    GLOW = { hi = "#fff6c8", base = "#ffd870", shade = "#f0a848", deep = "#c06a40" },
    BG = { base = "#b4c0ec", shade = "#8e9ad0", deep = "#6672a6" } },
  [3] = { W = { hi = "#ffd8b8", base = "#f6a07e", shade = "#d46c7c", deep = "#8c4668" }, DK = "#4e2c4c", SP = "#fff0d8", AC = "#e2703e",
    FUZ = { hi = "#f4e2cc", base = "#d8bcb2", shade = "#a68a9c", deep = "#6e5872" },
    CL = { hi = "#a8ead2", base = "#5cc2aa", shade = "#3a8a8e", deep = "#2e5a66" },
    APR = { hi = "#fff4dc", base = "#f2e2c0", shade = "#c8b4a8", deep = "#8e7c8a" },
    HAT = { hi = "#ffe08a", base = "#f0b840", shade = "#c07c40", deep = "#7e4a44" },
    BOOT = { hi = "#c49aa8", base = "#8e6a80", shade = "#634a64", deep = "#45344a" },
    PROP = { hi = "#ffc89a", base = "#e0884e", shade = "#a85440", deep = "#6c3640" },
    BG = { base = "#f6cabc", shade = "#dca2a4", deep = "#b07a8c" } },
}
local C = PAL[V]
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  local R = math.max(rx, ry)
  for y = math.floor(cy - R - 1), math.ceil(cy + R + 1) do for x = math.floor(cx - R - 1), math.ceil(cx + R + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local function part(c, m, R, band, pop)
  c:part(m, R, { band = band or 2, nopop = true })
  if pop then for _, q in ipairs(pop) do if m:has(q[1], q[2]) then c:put(q[1], q[2], R.hi, R) end end end
  return m
end
local function fill(c, m, hex) local l = {} m:each(function(x, y) l[#l + 1] = { x, y } end) for _, q in ipairs(l) do c:put(q[1], q[2], hex) end end
local function under(c, m, hex) local l = {} m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end) for _, q in ipairs(l) do c:put(q[1], q[2], hex) end end
local function rows(c, x0, y0, rs, map) for j, r in ipairs(rs) do for i = 1, #r do local h = map[r:sub(i, i)] if h then c:put(x0 + i - 1, y0 + j - 1, h) end end end end
local function outerOf(m, ax, sg, d) local r = HP.mask() m:each(function(x, y) if (x + .5 - ax) * sg > d then r:set(x, y) end end) return r end
-- four real butterfly wings: fore + hind per side, veins from the thorax, dark outer border with pale dots
local function wings(c, ax, ay, s, fl)
  local bw = (s > 1.2) and 3 or 2
  for _, sg in ipairs{ -1, 1 } do
    local fore, hind, tx, ty, hc
    if V == 1 then
      fore = oval(ax + sg * 13 * s, ay - 11 * s + fl, 11 * s, 9 * s, sg * -25)
      hind = oval(ax + sg * 11 * s, ay + 8 * s, 8 * s, 7 * s, sg * 25)
      tx, ty = ax + sg * 21 * s, ay - 17 * s + fl
      hc = { ax + sg * 13 * s, ay + 10 * s }
    elseif V == 2 then
      fore = c:poly{ { ax + sg * 2 * s, ay + 2 * s }, { ax + sg * 25 * s, ay - 30 * s + fl }, { ax + sg * 22 * s, ay - 4 * s + fl } }
      fore:add(oval(ax + sg * 15 * s, ay - 9 * s + fl, 7 * s, 6 * s, 0))
      hind = oval(ax + sg * 11 * s, ay + 8 * s, 7 * s, 6 * s, sg * 20)
      tx, ty = ax + sg * 24 * s, ay - 28 * s + fl
      hc = { ax + sg * 12 * s, ay + 9 * s }
    else
      fore = oval(ax + sg * 14 * s, ay - 9 * s + fl, 10 * s, 8 * s, sg * -35)
      hind = oval(ax + sg * 12 * s, ay + 8 * s, 9 * s, 7 * s, sg * 30)
      hind:add(c:line({ { ax + sg * 15 * s, ay + 13 * s }, { ax + sg * 19 * s, ay + 21 * s } }, (s > 1.2) and 3 or 2))
      for _, a in ipairs{ 20, 50, 110 } do
        local r = math.rad(a)
        hind:cut(HP.ellipse(ax + sg * 12 * s + sg * math.cos(r) * 9.6 * s, ay + 8 * s + math.sin(r) * 7.4 * s, 1.2 * s, 1.2 * s))
      end
      tx, ty = ax + sg * 22 * s, ay - 15 * s + fl
      hc = { ax + sg * 12 * s, ay + 8 * s }
    end
    part(c, hind, C.W, 2)
    part(c, fore, C.W, 2)
    local inF, inH = fore:copy():shrink(1), hind:copy():shrink(1)
    for _, t in ipairs{ { tx, ty }, { tx + sg * 4 * s, ty + 9 * s }, { tx - sg * 7 * s, ty - 1 * s } } do
      fill(c, c:line({ { ax, ay }, t }, 1):clip(inF), C.W.shade)
    end
    fill(c, c:line({ { ax, ay }, { hc[1] + sg * 4 * s, hc[2] + 4 * s } }, 1):clip(inH), C.W.shade)
    if V == 1 then
      fill(c, c:line({ { ax + sg * 9 * s, ay - 21 * s + fl }, { ax + sg * 17 * s, ay - 5 * s + fl } }, bw):clip(inF), C.DK)
      fill(c, HP.ellipse(hc[1], hc[2], 1.8 * s, 1.8 * s):clip(inH), C.AC)
    elseif V == 2 then
      fill(c, c:line({ { ax + sg * 5 * s, ay - 3 * s }, { tx - sg * 4 * s, ty + 7 * s } }, bw - 1):clip(fore:copy():shrink(2)), C.W.hi)
    else
      fill(c, oval(tx, ty, 5 * s, 4 * s, 0):clip(fore), C.DK)
    end
    local bF = outerOf(fore:copy():cut(fore:copy():shrink(bw)), ax, sg, 7 * s)
    local bH = outerOf(hind:copy():cut(hind:copy():shrink(bw)), ax, sg, 7 * s)
    fill(c, bF, C.DK) fill(c, bH, C.DK)
    local spots = {}
    for _, pr in ipairs{ { bF, inF }, { bH, inH } } do
      pr[1]:each(function(x, y) if pr[2]:has(x, y) and (x * 7 + y * 3) % 5 == 0 then spots[#spots + 1] = { x, y } end end)
    end
    for _, q in ipairs(spots) do c:put(q[1], q[2], C.SP) end
    if V == 3 then -- hindwing eyespot
      fill(c, HP.ellipse(hc[1], hc[2], 3 * s, 3 * s):clip(inH), C.HAT.base)
      fill(c, HP.ellipse(hc[1], hc[2], 1.8 * s, 1.8 * s):clip(inH), C.DK)
      c:put(math.floor(hc[1] - .6 * s), math.floor(hc[2] - .6 * s), C.SP)
    end
  end
end
local function eye(c, x, y)
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs({ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } }) do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.b
  c:groundShadow(32, 89.5, 12, 2.5)
  wings(c, 32, 61 + b, 1, p.fl or 0)
  if V == 2 then -- travel pack + bedroll peeking behind the right shoulder
    part(c, c:rrect(37, 57 + b, 50, 75 + b, 3), C.PACK, 2, { { 39, 58 + b }, { 40, 58 + b } })
    fill(c, c:rect(44, 64 + b, 50, 64 + b), C.PACK.deep)
    part(c, c:rrect(37, 53 + b, 51, 57 + b, 2), C.HAT, 1, { { 39, 54 + b } })
  end
  local body = c:ellipse(32, 76 + b, 10, 10.5)
  if V == 1 then
    part(c, body, C.FUZ, 2)
    local pants = body:copy():clip(c:rect(0, 77 + b, 63, 95))
    pants:add(c:rect(27, 69 + b, 37, 78 + b))
    part(c, pants, C.CL, 2, { { 28, 70 + b }, { 28, 71 + b } })
    part(c, c:line({ { 27, 70 + b }, { 25, 63 + b } }, 2), C.CL, 1)
    part(c, c:line({ { 37, 70 + b }, { 39, 63 + b } }, 2), C.CL, 1)
    c:put(27, 70 + b, C.HAT.hi) c:put(37, 70 + b, C.HAT.hi)
    for x = 29, 35, 2 do c:put(x, 74 + b, C.CL.shade) end
  elseif V == 2 then
    part(c, body, C.CL, 2, { { 25, 70 + b }, { 26, 69 + b } })
    fill(c, c:rect(32, 68 + b, 32, 86 + b):clip(body), C.CL.deep)
    c:put(34, 72 + b, C.PACK.hi) c:put(34, 77 + b, C.PACK.hi)
    part(c, c:line({ { 24, 65 + b }, { 41, 83 + b } }, 2):clip(body), C.PACK, 1)
  else
    part(c, body, C.CL, 2, { { 25, 70 + b } })
    part(c, c:rrect(25, 67 + b, 39, 86 + b, 3):clip(body), C.APR, 2, { { 27, 68 + b } })
    local pk = c:rect(29, 76 + b, 35, 80 + b)
    pk:cut(c:rect(30, 76 + b, 34, 79 + b))
    fill(c, pk, C.APR.shade)
    c:put(31, 74 + b, C.HAT.base) c:put(33, 74 + b, C.HAT.base)
  end
  if V == 2 then -- knitted scarf with a tail on the left
    part(c, c:rrect(22, 59 + b, 42, 63 + b, 2), C.SC, 1, { { 24, 60 + b } })
    for x = 25, 40, 3 do c:put(x, 62 + b, C.SC.shade) end
    local tl = (p.tail or 0)
    part(c, c:line({ { 24, 62 + b }, { 22, 70 + b + tl } }, 3), C.SC, 1)
    c:put(21, 72 + b + tl, C.SC.shade) c:put(23, 72 + b + tl, C.SC.shade)
  else
    local ruff = c:ellipse(32, 62 + b, 9, 2.5)
    for _, q in ipairs{ { 24, 63 }, { 28, 64 }, { 32, 64.5 }, { 36, 64 }, { 40, 63 } } do ruff:add(HP.ellipse(q[1], q[2] + b, 1.5, 1.5)) end
    part(c, ruff, C.FUZ, 1, { { 25, 61 + b }, { 26, 61 + b } })
  end
  local AR = (V == 1) and C.FUZ or C.CL
  part(c, c:ellipse(21.5, 69 + b, 2.5, 4), AR, 1, { { 20, 67 + b } })
  part(c, c:ellipse(42.5, 69 + b, 2.5, 4), AR, 1)
  -- prop in the right hand
  if V == 1 then
    part(c, c:poly{ { 39.5, 76 + b }, { 46.5, 76 + b }, { 43, 85 + b } }, C.PROP, 1, { { 41, 77 + b }, { 42, 77 + b } })
    for y = 78, 82 do c:put(43, y + b, C.PROP.shade) end
    part(c, c:rect(42, 72 + b, 44, 75 + b), C.PROP, 1)
    part(c, c:rrect(42, 63 + b, 44, 71 + b, 1), C.WOOD, 1, { { 42, 64 + b } })
  elseif V == 2 then
    fill(c, c:rect(43, 75 + b, 43, 76 + b), C.PROP.deep)
    part(c, c:rect(40, 77 + b, 46, 78 + b), C.PROP, 1, { { 41, 77 + b } })
    local G = p.flick and { hi = C.GLOW.base, base = C.GLOW.hi, shade = C.GLOW.base, deep = C.GLOW.shade } or C.GLOW
    part(c, c:rect(41, 79 + b, 45, 84 + b), G, 1, { { 42, 80 + b } })
    for y = 79, 84 do c:put(43, y + b, C.PROP.shade) end
    part(c, c:rect(40, 85 + b, 46, 86 + b), C.PROP, 1)
  else
    part(c, c:line({ { 44, 73 + b }, { 47, 61 + b } }, 2), C.PROP, 1)
    part(c, c:ellipse(47.5, 58.5 + b, 3.5, 2.5), C.PROP, 1, { { 45, 58 + b } })
    fill(c, c:rect(46, 57 + b, 49, 57 + b), C.AC)
  end
  part(c, c:ellipse(21.5, 73.5 + b, 2, 1.6), C.BOOT, 1)
  part(c, c:ellipse(43, 73.5 + b, 2, 1.6), C.BOOT, 1)
  -- feet (never move)
  part(c, c:ellipse(28, 88, 3, 1.6), C.BOOT, 1, { { 26, 87 } })
  part(c, c:ellipse(36, 88, 3, 1.6), C.BOOT, 1, { { 34, 87 } })
  -- fuzzy round head
  local head = c:ellipse(32, 46 + b, 13, 11.5)
  for _, q in ipairs{ { 19.5, 48 }, { 20.5, 52 }, { 44.5, 48 }, { 43.5, 52 }, { 24, 55.5 }, { 40, 55.5 }, { 28, 57 }, { 36, 57 } } do head:add(HP.ellipse(q[1], q[2] + b, 1.5, 1.5)) end
  part(c, head, C.FUZ, 3, { { 23, 41 + b }, { 24, 40 + b }, { 23, 42 + b } })
  for _, q in ipairs{ { 22, 51 }, { 26, 54 }, { 31, 56 }, { 38, 55 }, { 42, 51 } } do
    if c:get(q[1], q[2] + b) == C.FUZ.base then c:put(q[1], q[2] + b, C.FUZ.shade) end
  end
  local ey = 43 + b
  if p.blink then for _, x in ipairs{ 25, 35 } do for i = 0, 3 do c:put(x + i, ey + 2, P.ink) end end
  else eye(c, 25, ey) eye(c, 35, ey) end
  c:cheek(23, 48 + b) c:cheek(40, 48 + b)
  rows(c, 30, 49 + b, { ".pp.", "p..p", "p.p.", ".p.." }, { p = C.DK }) -- coiled proboscis
  -- headwear
  if V == 1 then
    local brim = c:ellipse(32, 36 + b, 17, 3.5)
    part(c, brim, C.HAT, 2, { { 18, 35 + b }, { 19, 35 + b } })
    under(c, brim, C.HAT.deep)
    for x = 16, 48, 3 do if brim:has(x, 37 + b) then c:put(x, 37 + b, C.HAT.shade) end end
    local crown = c:rrect(24, 27 + b, 40, 36 + b, 4)
    part(c, crown, C.HAT, 2, { { 26, 29 + b }, { 27, 29 + b }, { 26, 30 + b } })
    fill(c, c:rect(24, 33 + b, 40, 33 + b):clip(crown), C.CL.hi)
    fill(c, c:rect(24, 34 + b, 40, 35 + b):clip(crown), C.CL.base)
    fill(c, c:line({ { 38, 33 + b }, { 42, 25 + b } }, 1), C.CL.deep)
    part(c, oval(41, 27 + b, 2.6, 1.2, -45), C.CL, 1)
    part(c, oval(44, 25 + b, 2.6, 1.2, 25), C.CL, 1)
    part(c, oval(42, 22 + b, 1.2, 2.4, 10), C.CL, 1)
  elseif V == 2 then
    local cap = c:ellipse(32, 36 + b, 12.5, 5.5)
    cap:add(c:ellipse(32, 33 + b, 10, 4))
    part(c, cap, C.HAT, 2, { { 25, 33 + b }, { 26, 32 + b } })
    for _, q in ipairs{ { 28, 33 }, { 27, 36 }, { 36, 33 }, { 37, 36 } } do c:put(q[1], q[2] + b, C.HAT.shade) end
    c:put(32, 29 + b, C.HAT.hi)
    part(c, c:ellipse(27, 41.5 + b, 7, 1.8), { hi = C.HAT.base, base = C.HAT.shade, shade = C.HAT.deep, deep = C.HAT.deep }, 1)
  else
    local ker = head:copy():clip(c:rect(0, 0, 63, 39 + b))
    ker:add(oval(45.5, 39 + b, 2, 1.6, 0))
    ker:add(c:poly{ { 45, 38 + b }, { 50, 35 + b }, { 49, 40 + b } })
    ker:add(c:poly{ { 45, 40 + b }, { 49, 44 + b + (p.tail or 0) }, { 46, 44 + b + (p.tail or 0) } })
    part(c, ker, C.HAT, 2, { { 24, 37 + b }, { 25, 36 + b } })
    under(c, ker:copy():clip(c:rect(0, 0, 44, 63)), C.HAT.deep)
    for _, q in ipairs{ { 26, 38 }, { 30, 36 }, { 34, 38 }, { 38, 36 }, { 29, 39 }, { 37, 39 } } do
      if ker:has(q[1], q[2] + b) then c:put(q[1], q[2] + b, C.SP) end
    end
  end
  c:finish{ outline = true }
  -- clubbed antennae (butterfly, not moth)
  local A
  if V == 1 then A = { { { 28, 28 }, { 26, 22 }, { 23, 16 } }, { { 36, 28 }, { 38, 22 }, { 41, 16 } } }
  elseif V == 2 then A = { { { 28, 31 }, { 25, 24 }, { 21, 18 } }, { { 36, 31 }, { 39, 24 }, { 43, 18 } } }
  else A = { { { 27, 35 }, { 24, 28 }, { 20, 21 } }, { { 37, 35 }, { 40, 28 }, { 44, 21 } } } end
  for i, a in ipairs(A) do
    local dx = (i == 2) and (p.tw or 0) or 0
    local tx, ty = a[3][1] + dx, a[3][2] + b + (p.cd or 0)
    c:fillMask(c:line({ { a[1][1], a[1][2] + b }, { a[2][1], a[2][2] + b }, { tx, ty } }, 1), P.ink)
    fill(c, c:ellipse(tx + .5, ty - .5, 1.5, 2), C.DK)
    c:put(tx, ty - 1, C.W.base)
  end
  HP.assertClean(c)
  return c
end
local FR = { { b = 0 }, { b = 1, cd = 1, tail = 1 }, { b = 0 }, { b = 0, blink = true, tw = 1, fl = -1, flick = true } }
local frames = {}
for i, p in ipairs(FR) do frames[i] = frame(p) end
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local spr = Sprite(64, 96, ColorMode.RGB)
for _ = 2, 4 do spr:newEmptyFrame() end
local strip = Image(256, 96, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
for f, c in ipairs(frames) do
  local im = Image(64, 96, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do im:putPixel(i % 64, i // 64, rgba(hex)) strip:putPixel((f - 1) * 64 + i % 64, i // 64, rgba(hex)) end
  spr:newCel(spr.layers[1], spr.frames[f], im, Point(0, 0))
end
spr.layers[1].name = NAME
local tg = spr:newTag(1, 4) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
local s2 = Sprite(256, 96, ColorMode.RGB) s2.cels[1].image = strip
s2:saveCopyAs(out .. NAME .. ".png") s2:close()
print(NAME .. " sprite ok")
