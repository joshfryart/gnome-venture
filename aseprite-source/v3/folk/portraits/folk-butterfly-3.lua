-- folk-butterfly-3 portrait (folk F2_12) variant: 3
local V = 3
local NAME = "folk-butterfly-3"
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "/home/user/gnome-venture/aseprite-source/v3/folk/portraits/"
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
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
wings(c, 39.5, 72, 1.45, 0)
if V == 2 then
  part(c, c:rrect(52, 64, 70, 92, 3), C.PACK, 2, { { 54, 65 }, { 55, 65 } })
  fill(c, c:rect(58, 75, 70, 75), C.PACK.deep)
  part(c, c:rrect(50, 57, 72, 64, 3), C.HAT, 2, { { 52, 58 }, { 53, 58 } })
  for x = 55, 70, 5 do fill(c, c:rect(x, 58, x, 63), C.HAT.shade) end
end
local body = c:ellipse(39.5, 101, 27, 29):clip(c:rect(0, 0, 79, 99))
if V == 1 then
  part(c, body, C.FUZ, 3, { { 20, 80 } })
  for y = 76, 98, 3 do for x = 14 + (y % 2) * 2, 66, 5 do if c:get(x, y) == C.FUZ.base then c:put(x, y, C.FUZ.shade) end end end
  part(c, c:rrect(28, 82, 51, 99, 3), C.CL, 2, { { 30, 83 }, { 31, 83 } })
  part(c, c:line({ { 31, 83 }, { 28, 73 } }, 3), C.CL, 1)
  part(c, c:line({ { 48, 83 }, { 51, 73 } }, 3), C.CL, 1)
  part(c, c:rect(29, 82, 30, 83), C.HAT, 1) part(c, c:rect(49, 82, 50, 83), C.HAT, 1)
  for x = 34, 45, 2 do c:put(x, 88, C.CL.shade) end
  part(c, c:rrect(34, 89, 45, 95, 1), C.CL, 1)
elseif V == 2 then
  part(c, body, C.CL, 3, { { 20, 80 } })
  fill(c, c:line({ { 38, 73 }, { 33, 88 } }, 2):clip(body), C.CL.deep)
  fill(c, c:line({ { 41, 73 }, { 46, 88 } }, 2):clip(body), C.CL.deep)
  part(c, c:rect(39, 88, 40, 89), C.PACK, 1) part(c, c:rect(39, 94, 40, 95), C.PACK, 1)
  part(c, c:line({ { 25, 75 }, { 54, 99 } }, 4):clip(body), C.PACK, 1)
else
  part(c, body, C.CL, 3, { { 20, 80 } })
  part(c, c:rrect(28, 79, 51, 99, 4), C.APR, 2, { { 30, 80 }, { 31, 80 } })
  part(c, c:line({ { 31, 80 }, { 30, 72 } }, 3), C.APR, 1)
  part(c, c:line({ { 48, 80 }, { 49, 72 } }, 3), C.APR, 1)
  local pk = c:rrect(33, 88, 46, 96, 2) pk:cut(c:rrect(34, 89, 45, 95, 1)) pk:cut(c:rect(34, 88, 45, 88))
  fill(c, pk, C.APR.shade)
  for x = 35, 44, 3 do c:put(x, 90, C.HAT.base) end
end
if V == 2 then
  part(c, c:rrect(21, 65, 58, 74, 4), C.SC, 2, { { 23, 66 }, { 24, 66 } })
  for x = 25, 55, 4 do fill(c, c:rect(x, 67, x, 72), C.SC.shade) end
  part(c, c:line({ { 29, 72 }, { 26, 92 } }, 6), C.SC, 2)
  for x = 23, 29, 2 do c:put(x, 95, C.SC.shade) end
else
  local ruff = c:ellipse(39.5, 70, 15, 4)
  for _, q in ipairs{ { 26, 72 }, { 31, 73 }, { 37, 73.5 }, { 42, 73.5 }, { 48, 73 }, { 53, 72 } } do ruff:add(HP.ellipse(q[1], q[2], 2, 2)) end
  part(c, ruff, C.FUZ, 1, { { 28, 68 }, { 29, 68 } })
end
local AR = (V == 1) and C.FUZ or C.CL
part(c, c:ellipse(V == 2 and 19 or 18, V == 2 and 86 or 88, 4.5, 6), AR, 1, { { 16, 84 } })
part(c, c:ellipse(61, 88, 4.5, 6), AR, 1)
if V == 1 then
  part(c, c:poly{ { 55.5, 77 }, { 67.5, 77 }, { 61.5, 62 } }, C.PROP, 1, { { 58, 75 }, { 59, 73 }, { 60, 71 } })
  for y = 66, 75 do c:put(61, y, C.PROP.shade) end
  part(c, c:rect(59, 78, 64, 80), C.PROP, 1)
  part(c, c:rrect(59, 81, 64, 93, 1), C.WOOD, 1, { { 60, 82 }, { 60, 83 } })
  part(c, c:ellipse(61.5, 87, 3.5, 2.5), C.BOOT, 1)
  part(c, c:ellipse(18, 92, 3, 2.5), C.BOOT, 1)
elseif V == 2 then
  part(c, c:ellipse(13.5, 79, 3, 2.5), C.BOOT, 1)
  fill(c, c:rect(13, 81, 13, 82), C.PROP.deep)
  part(c, c:poly{ { 6, 86 }, { 20, 86 }, { 17, 83 }, { 9, 83 } }, C.PROP, 1, { { 9, 84 } })
  part(c, c:rect(7, 87, 19, 95), C.GLOW, 2, { { 9, 88 }, { 9, 89 } })
  for y = 87, 95 do c:put(13, y, C.PROP.shade) end
  part(c, c:rect(6, 96, 20, 98), C.PROP, 1)
  part(c, c:ellipse(61, 93, 3, 2.5), C.BOOT, 1)
else
  part(c, c:line({ { 62, 87 }, { 66, 67 } }, 3), C.PROP, 1)
  part(c, c:ellipse(67, 63, 6, 4), C.PROP, 2, { { 63, 62 }, { 64, 61 } })
  fill(c, c:ellipse(67, 61.5, 4.5, 1.2), C.AC)
  part(c, c:ellipse(62, 87, 3.5, 2.5), C.BOOT, 1)
  part(c, c:ellipse(18, 92, 3, 2.5), C.BOOT, 1)
end
-- head
local head = c:ellipse(39.5, 48, 20, 17)
for _, a in ipairs{ 150, 165, 180, 195, 0, 15, 30, -15, 60, 75, 90, 105, 120 } do
  local r = math.rad(a)
  head:add(HP.ellipse(39.5 + math.cos(r) * 19.5, 48 + math.sin(r) * 16.5, 2, 2))
end
part(c, head, C.FUZ, 3, { { 27, 37 }, { 28, 36 }, { 26, 38 }, { 29, 36 } })
for _, s in ipairs{ { 23, 56, 24, 54 }, { 28, 60, 29, 58 }, { 50, 60, 51, 58 }, { 55, 56, 56, 54 }, { 34, 62, 35, 60 }, { 44, 62, 45, 60 } } do
  c:line({ { s[1], s[2] }, { s[3], s[4] } }, 1):clip(head):each(function(x, y) if c:get(x, y) == C.FUZ.base then c:put(x, y, C.FUZ.shade) end end)
end
c:eyeLocked(30, 44) c:eyeLocked(45, 44)
rows(c, 37, 50, { ".ppp.", "p...p", "p.p.p", "p.pp.", ".p..." }, { p = C.DK }) -- coiled proboscis
rows(c, 35, 56, { "i.......i", ".iiiiiii." }, { i = P.ink })
rows(c, 24, 53, { "kkk", "kkk" }, { k = "#f2949e" }) rows(c, 53, 53, { "kkk", "kkk" }, { k = "#f2949e" })
c:put(24, 53, "#f8b8b0") c:put(53, 53, "#f8b8b0")
if V == 1 then
  local brim = c:ellipse(39.5, 33, 28, 5.5)
  part(c, brim, C.HAT, 2, { { 16, 31 }, { 17, 31 }, { 18, 30 } })
  under(c, brim, C.HAT.deep)
  for x = 13, 66, 3 do if brim:has(x, 35) then c:put(x, 35, C.HAT.shade) end end
  local crown = c:rrect(28, 16, 51, 33, 6)
  part(c, crown, C.HAT, 2, { { 31, 18 }, { 30, 19 }, { 30, 20 } })
  fill(c, c:rect(28, 27, 51, 27):clip(crown), C.CL.hi)
  fill(c, c:rect(28, 28, 51, 30):clip(crown), C.CL.base)
  fill(c, c:rect(28, 31, 51, 31):clip(crown), C.CL.shade)
  for y = 19, 25, 3 do for x = 30 + (y % 2), 49, 3 do if c:get(x, y) == C.HAT.base then c:put(x, y, C.HAT.shade) end end end
  fill(c, c:line({ { 48, 27 }, { 55, 13 } }, 1), C.CL.deep)
  part(c, oval(52, 19, 4, 1.7, -50), C.CL, 1, { { 50, 19 } })
  part(c, oval(56, 14, 4, 1.7, 30), C.CL, 1)
  part(c, oval(54, 9, 1.7, 3.6, 10), C.CL, 1)
elseif V == 2 then
  local cap = c:ellipse(39.5, 32, 19, 8)
  cap:add(c:ellipse(39.5, 28, 15, 6))
  part(c, cap, C.HAT, 2, { { 28, 26 }, { 29, 25 }, { 27, 27 } })
  fill(c, c:line({ { 39, 22 }, { 31, 37 } }, 1):clip(cap), C.HAT.shade)
  fill(c, c:line({ { 40, 22 }, { 49, 37 } }, 1):clip(cap), C.HAT.shade)
  part(c, c:ellipse(39.5, 22, 2, 1.5), C.HAT, 1, { { 39, 21 } })
  part(c, c:ellipse(32, 40, 13, 3), { hi = C.HAT.base, base = C.HAT.shade, shade = C.HAT.deep, deep = C.HAT.deep }, 1)
else
  local ker = head:copy():clip(c:rect(0, 0, 79, 38))
  ker:add(oval(59.5, 37, 3, 2.5, 0))
  ker:add(c:poly{ { 59, 36 }, { 68, 31 }, { 67, 39 } })
  ker:add(c:poly{ { 59, 38 }, { 67, 45 }, { 62, 46 } })
  part(c, ker, C.HAT, 2, { { 26, 33 }, { 27, 32 }, { 28, 31 } })
  under(c, ker:copy():clip(c:rect(0, 0, 57, 99)), C.HAT.deep)
  for _, q in ipairs{ { 27, 36 }, { 32, 33 }, { 38, 35 }, { 44, 32 }, { 50, 35 }, { 35, 37 }, { 47, 37 }, { 41, 31 }, { 63, 36 } } do
    if ker:has(q[1], q[2]) then c:put(q[1], q[2], C.SP) c:put(q[1] + 1, q[2], C.SP) end
  end
end
c:finish{ outline = true }
local A
if V == 1 then A = { { { 33, 16 }, { 30, 10 }, { 26, 5 } }, { { 46, 16 }, { 49, 10 }, { 53, 5 } } }
elseif V == 2 then A = { { { 34, 23 }, { 30, 15 }, { 25, 8 } }, { { 45, 23 }, { 49, 15 }, { 54, 8 } } }
else A = { { { 33, 32 }, { 29, 21 }, { 24, 11 } }, { { 46, 32 }, { 50, 21 }, { 55, 11 } } } end
for _, a in ipairs(A) do
  c:fillMask(c:line(a, 1), P.ink)
  local tx, ty = a[3][1], a[3][2]
  fill(c, c:ellipse(tx + .5, ty - .5, 2, 2.5), C.DK)
  c:put(tx - 1, ty - 2, C.W.base) c:put(tx, ty - 2, C.W.base)
end
if V == 3 then for _, q in ipairs{ { 65, 57 }, { 66, 56 }, { 66, 55 }, { 69, 56 }, { 70, 55 }, { 69, 54 } } do c:put(q[1], q[2], C.SP) end end
backdrop(C.BG)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " portrait ok")
