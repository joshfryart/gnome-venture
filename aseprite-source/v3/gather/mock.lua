-- gather scene-forest MOCKUPS (v3, GX engine). --script-param mock=A|B|C   A = dusk gate, B = golden-hour glade, C = moonlit hollow
-- Writes out/mock<A>-scene.png (480x270) and out/mock<A>-front.png (satchel front overlay).
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d .. "/gx.lua")
local SAT = dofile(d .. "/satchel3.lua")
local HP, X = GX.HP, GX.X
local MK = app.params.mock or "A"
local floor, max, min, abs, sin, cos = math.floor, math.max, math.min, math.abs, math.sin, math.cos
local H = X.hash
local INK = GX.INK
local REDL = { hi = "#ff8a5c", base = "#e8493b", shade = "#b52e3f", deep = "#6e2038" }
local ORGL = { hi = "#ffb85c", base = "#f0882e", shade = "#c95a26", deep = "#7a3423" }
local GOLDL = { hi = "#ffe38a", base = "#f0b43a", shade = "#d0802a", deep = "#8f4a1f" }
local GRN1 = { hi = "#c8f070", base = "#6cc050", shade = "#3a9048", deep = "#1f5a44" }
local GRN2 = { hi = "#a0dc60", base = "#48a050", shade = "#2e7648", deep = "#1c4a40" }
local BLU = { hi = "#6a9ae0", base = "#3a64b8", shade = "#2a4590", deep = "#1c2a62" }
local VIO = { hi = "#a890e8", base = "#7058c0", shade = "#4c3e98", deep = "#2c2468" }
local TEAL = { hi = "#6ad8c8", base = "#2e9aa0", shade = "#237080", deep = "#183e58" }
local PAL = {
  A = { bg = { "#ffd8a8", "#ffc090", "#f0a89a", "#d896a8", "#b88ab8", "#9a80b0" }, lift = "#fff0c0", far = "#9a7aa8",
        hill = { hi = "#c8c070", base = "#a8a860", shade = "#8a8a64", deep = "#6a6a68" },
        grass = { hi = "#d4dc70", base = "#9ac45a", shade = "#5a9a48", deep = "#2f6a46" },
        can = { REDL, ORGL, GOLDL, ORGL, REDL, GOLDL, ORGL, REDL, GOLDL, GRN2, GOLDL, GRN1 },
        bark = { hi = "#c0825a", base = "#8a5238", shade = "#6a3a38", deep = "#40242c" }, shadow = "#2f6a46",
        leaves = { "#f5b82e", "#e8883a", "#d98322", "#c94f3a" }, flowers = { "#ff9fc0", "#fff4d6", "#ffe38a", "#c9b2f0" } },
  B = { bg = { "#c8ecf8", "#d4f0e8", "#e4f6c8", "#d8f0a8", "#c0e498", "#a8d888" }, lift = "#ffffd0", far = "#8cc0a0",
        hill = { hi = "#c0e888", base = "#9cd070", shade = "#78b060", deep = "#5a9060" },
        grass = { hi = "#d8f880", base = "#9ce048", shade = "#58b040", deep = "#2a7a44" },
        can = { GRN1, GRN2, GOLDL, GRN1, GRN2, ORGL, GRN1, GRN2, GOLDL, GRN1, GRN2, GOLDL },
        bark = { hi = "#c89060", base = "#94603c", shade = "#6e4234", deep = "#442a2c" }, shadow = "#2a7a44",
        leaves = { "#f5d84a", "#f0a830", "#ffe38a", "#c4e07a" }, flowers = { "#ff9fc0", "#fff4d6", "#ffd470", "#c9b2f0", "#ff8a5c" } },
  C = { bg = { "#262c6c", "#2e3680", "#384294", "#444ea0", "#505aa8", "#5c64b0" }, lift = "#a8b8ff", far = "#4a54a0",
        hill = { hi = "#4a5aa8", base = "#3e4c98", shade = "#34428a", deep = "#2a3478" },
        grass = { hi = "#6cd0a0", base = "#38988a", shade = "#26707a", deep = "#183e58" },
        can = { BLU, VIO, TEAL, BLU, VIO, TEAL, BLU, VIO, TEAL, VIO, BLU, TEAL },
        bark = { hi = "#8a6a98", base = "#5e4878", shade = "#463a64", deep = "#2a2248" }, shadow = "#183e58",
        leaves = { "#6ad8c8", "#a890e8", "#ffe38a", "#8ab0f0" }, flowers = { "#ffe38a", "#c9b2f0", "#8ab0f0", "#fff4d6" } },
}
local P = PAL[MK]
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "mock" .. MK }
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end
local function mk() return HP.mask() end

---------------------------------------------------------------- backdrop
local function shaft(x, y)
  for i = 0, 6 do
    local x0 = 30 + i * 66
    local t = y / 150
    if x >= x0 + t * 40 and x <= x0 + 24 + t * 50 then return true end
  end
  return false
end
GX.bands(c, 0, 150, P.bg, 3, .22, shaft, P.lift)
for _, t in ipairs{ { 28, 22 }, { 150, 16 }, { 250, 20 }, { 340, 14 }, { 420, 18 } } do
  local far = { hi = GX.mix(P.far, P.lift, .25), base = P.far, shade = GX.mix(P.far, "#000000", .12), deep = GX.mix(P.far, "#000000", .25) }
  GX.trunk(c, t[1], t[1] + t[2] - 1, 28, 152, far, t[1], { noink = true })
end
GX.ground(c, function(x) return 126 + floor(5 * sin(x / 31)) end, P.hill, 5, { top = .75, fall = .3, tex = .3 })
GX.ground(c, function(x) return 140 + floor(4 * sin(x / 23 + 2)) end, P.grass, 7, { top = .86, fall = .62, tex = .3, sc = 8 })

---------------------------------------------------------------- canopy (top row first, hanging row last)
local CL = { { 40, 14, 52, 24 }, { 110, 6, 46, 20 }, { 170, 18, 46, 22 }, { 236, 6, 48, 22 }, { 300, 18, 50, 24 }, { 362, 6, 46, 20 }, { 424, 16, 50, 24 }, { 474, 6, 34, 20 },
  { 14, 40, 32, 14 }, { 250, 42, 34, 12 }, { 372, 44, 34, 12 }, { 70, 44, 26, 10 } }
for pass = 1, 2 do
  for i, g in ipairs(CL) do
    if (pass == 1) == (g[2] < 30) then GX.foliage(c, g[1], g[2], g[3], g[4], P.can[i], 100 + i * 17) end
  end
end

---------------------------------------------------------------- big trunks
GX.trunk(c, 76, 112, 14, 140, P.bark, 11, { moss = GRN2 })
GX.trunk(c, 166, 178, 26, 124, P.bark, 12)
GX.trunk(c, 440, 479, 0, 166, P.bark, 13, { moss = GRN2 })

---------------------------------------------------------------- mood props (per mockup)
if MK == "A" then   -- bunting and lanterns
  local FLAG = { "#e8493b", "#f5b82e", "#5fc4c8", "#f5809f", "#7cc35a" }
  local function bunt(x0, y0, x1, y1, sag)
    local pts, n = {}, x1 - x0
    for i = 0, n do local t = i / n; local y = floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t)); pts[#pts + 1] = { x0 + i, y }; c:px(x0 + i, y, INK); c:px(x0 + i, y + 1, "#6a4a38") end
    for i = 8, n - 6, 13 do
      local x, y = pts[i][1], pts[i][2] + 2; local col = FLAG[1 + (i // 13) % 5]
      local fl = c:poly{ { x - 4, y }, { x + 4, y }, { x, y + 10 } }
      GX.lit(c, fl, GX.ramp6({ hi = GX.mix(col, "#ffffff", .45), base = col, shade = GX.mix(col, "#000000", .25), deep = GX.mix(col, "#000000", .5) }), { R = 3, tex = 0, rimlight = false })
    end
    return pts
  end
  local function lantern(x, y)
    local halo = mk(); E(halo, x, y + 4, 11); c:fillMask(halo, "#ffe9b8"); local h2 = mk(); E(h2, x, y + 4, 8); c:fillMask(h2, "#ffd890")
    local l = mk(); E(l, x, y + 4, 4, 5); GX.lit(c, l, GX.ramp6({ hi = "#fff4d6", base = "#f5b82e", shade = "#d98322", deep = "#8f4a1f" }), { R = 4, tex = 0, rimlight = true })
    c:px(x, y - 2, INK); c:px(x, y - 1, INK)
  end
  local p1 = bunt(112, 54, 166, 50, 8)
  local p2 = bunt(178, 50, 440, 48, 26)
  for _, i in ipairs{ 36, 110, 180, 236 } do lantern(p2[i][1], p2[i][2] + 1) end
  lantern(p1[28][1], p1[28][2] + 1)
elseif MK == "C" then   -- moon in a gap, lantern post
  local mo = mk(); E(mo, 300, 56, 12); local mg = mk(); E(mg, 300, 56, 18); c:fillMask(mg, "#6a78c8"); local mg2 = mk(); E(mg2, 300, 56, 15); c:fillMask(mg2, "#8a98e0")
  GX.lit(c, mo, GX.ramp6({ hi = "#ffffff", base = "#f4eed0", shade = "#d0c8a8", deep = "#a8a088" }), { R = 12, tex = .25, sc = 3, seed = 3, ink = false })
  for _, p in ipairs{ { -4, -3 }, { 3, 2 }, { -2, 5 } } do c:fillMask(c:rect(300 + p[1], 56 + p[2], 301 + p[1], 56 + p[2]), "#c8c0a0") end
  for _, g in ipairs{ { 300, 56 } } do end
else   -- B: warm sun glare behind the canopy
  local sun = mk(); E(sun, 232, 8, 22, 14); c:fillMask(sun, "#fffbd8"); local s2 = mk(); E(s2, 232, 8, 14, 9); c:fillMask(s2, "#ffffff")
end

---------------------------------------------------------------- ground details
local function blocked(x, y) return (x < 156 and y > 120 and y < 200) or (x > 280 and x < 432 and y > 60 and y < 218) or (abs(x - 240) < 60 and abs(y - 214) < 20) end
for _, t in ipairs{ { 94, 172, 38, 5 }, { 172, 152, 14, 3 }, { 458, 176, 22, 5 } } do   -- trunk shadows
  local m = mk(); E(m, t[1], t[2], t[3], t[4]); m = GX.rough(m, t[1], 1); c:fillMask(m, GX.mix(P.grass.shade, P.grass.base, .35))
end
for i = 0, 10 do   -- dapples
  local x, y = 30 + floor(H(i, 51, 1) * 420), 150 + floor(H(i, 53, 1) * 100)
  if not blocked(x, y) then local m = mk(); E(m, x, y, 12 + i % 4 * 3, 4); m = GX.rough(m, i, 1); c:fillMask(m, GX.mix(P.grass.hi, P.lift, .3)) end
end
local STO = { hi = "#e8e4ee", base = "#b4b0c4", shade = "#7e7a98", deep = "#4a4868" }
if MK == "C" then STO = { hi = "#aab4e0", base = "#7a86b8", shade = "#56628e", deep = "#363e66" } end
for si, s2 in ipairs{ { 232, 268, 20, 6 }, { 262, 254, 16, 5 }, { 214, 246, 13, 4 }, { 246, 238, 11, 4 }, { 224, 232, 9, 3 } } do
  local m = mk(); E(m, s2[1], s2[2], s2[3], s2[4])
  GX.lit(c, m, GX.ramp6(STO), { R = 4, tex = .3, sc = 3, seed = si, rimlight = true })
  for k = 0, 5 do c:px(s2[1] - s2[3] + 3 + k * 2, s2[2] - s2[4] + 1, GRN1.base) end
end
for i = 0, 44 do
  local x, y = 10 + floor(H(i, 61, 1) * 460), 160 + floor(H(i, 63, 1) * 108)
  if not blocked(x, y) then GX.tuft(c, x, y, y > 214 and { hi = P.grass.base, base = P.grass.shade, shade = P.grass.deep } or P.grass) end
end
for i = 0, 28 do
  local x, y = 20 + floor(H(i, 41, 1) * 440), 152 + floor(H(i, 43, 1) * 112)
  if not blocked(x, y) then GX.flower(c, x, y, P.flowers[1 + i % #P.flowers]) end
end

---------------------------------------------------------------- hollow log with moss, mushrooms, squirrel
local LOGR = { hi = P.bark.hi, base = GX.mix(P.bark.base, P.bark.hi, .2), shade = P.bark.shade, deep = P.bark.deep }
local lg = mk()
for x = 10, 140 do local top = 138 + floor((GX.vn(x, 0, 12, 4) - .5) * 4); for y = top, 190 - floor((GX.vn(x, 9, 10, 5)) * 3) do lg:set(x, y) end end
E(lg, 12, 164, 5, 26)
GX.lit(c, lg, GX.ramp6(LOGR), { R = 24, tex = .3, sc = 2.2, seed = 9, rimlight = true, fn = function(x, y) return (GX.vn(x * .22, y, 2, 6) - .5) * .5 end })
local ms = mk()
for x = 12, 140 do local top = 131 + floor(GX.vn(x, 3, 7, 8) * 4); local bot = 141 + floor(GX.vn(x, 7, 6, 2) * 8); for y = top, bot do ms:set(x, y) end end
GX.lit(c, ms, GX.ramp6(GRN2), { R = 5, tex = .6, sc = 3, seed = 4, rimlight = true })
local face = mk(); E(face, 142, 164, 14, 28)
GX.lit(c, face, GX.ramp6({ hi = "#f0c898", base = "#d19a62", shade = "#a8704a", deep = "#7a4a34" }), { R = 12, tex = .15, seed = 2, rimlight = true,
  fn = function(x, y) local dd = math.sqrt(((x - 143) / 14) ^ 2 + ((y - 165) / 28) ^ 2); return (math.floor(dd * 5) % 2) * .16 - .08 end })
local hl = mk(); E(hl, 144, 167, 7, 14)
GX.lit(c, hl, GX.ramp6({ hi = "#4a3040", base = "#2c1a26", shade = "#1c1018", deep = "#100a0e" }), { R = 4, tex = .1, seed = 3, ink = "#1c1018" })
c:fillMask(c:rect(140, 163, 141, 164), "#ffe38a"); c:fillMask(c:rect(147, 163, 148, 164), "#ffe38a")
local CAPC = (MK == "C") and TEAL or { hi = "#ff8a5c", base = "#e8493b", shade = "#b52e3f", deep = "#6e2038" }
local function shroom(x, y, s, glow)
  local st = c:rect(x - 1, y - 7 * s, x + 1, y); GX.lit(c, st, GX.ramp6({ hi = "#ffffff", base = "#fff4d6", shade = "#d8c8a8", deep = "#a8987e" }), { R = 2, tex = 0, ink = INK })
  local cap = mk(); E(cap, x, y - 8 * s, 4 * s + 2, 3 * s + 1); cap:cut(c:rect(x - 20, y - 8 * s + 1 + 2 * s, x + 20, y + 20))
  if glow then local gl = mk(); E(gl, x, y - 7 * s, 4 * s + 5, 3 * s + 4); c:fillMask(gl, GX.mix(P.grass.base, "#8ff0f0", .3)); local g2 = mk(); E(g2, x, y - 7 * s, 4 * s + 3, 3 * s + 2); c:fillMask(g2, GX.mix(P.grass.hi, "#c8fff8", .5)) end
  GX.lit(c, cap, GX.ramp6(CAPC), { R = 4, tex = .1, seed = x, rimlight = true })
  c:px(x - 2, y - 9 * s, "#fff4d6"); c:px(x + 2, y - 8 * s, "#fff4d6"); c:px(x, y - 10 * s, "#fff4d6"); c:px(x + 1, y - 9 * s + 1, "#fff4d6")
end
shroom(40, 134, 2, MK == "C"); shroom(64, 134, 1, MK == "C"); shroom(112, 132, 1, MK == "C")
local ORG = ORGL
local function squirrel(x, y)
  local tl = c:poly{ { x - 6, y }, { x - 12, y - 8 }, { x - 11, y - 18 }, { x - 5, y - 20 }, { x - 3, y - 12 }, { x - 3, y - 2 } }
  GX.lit(c, tl, GX.ramp6(ORG), { R = 4, tex = .3, sc = 2, seed = 5, rimlight = true })
  local b = mk(); E(b, x + 2, y - 4, 6, 8); GX.lit(c, b, GX.ramp6(ORG), { R = 6, tex = .15, seed = 6, rimlight = true })
  local bl = mk(); E(bl, x + 4, y - 3, 3, 5); c:fillMask(bl, "#fff4d6")
  local hd = mk(); E(hd, x + 5, y - 14, 5, 4); GX.lit(c, hd, GX.ramp6(ORG), { R = 4, tex = .1, seed = 7, rimlight = true })
  c:px(x + 4, y - 18, ORG.deep); c:px(x + 8, y - 18, ORG.deep); c:px(x + 3, y - 14, INK); c:px(x + 8, y - 13, INK)
end
squirrel(100, 136)

---------------------------------------------------------------- fairy ring, acorns, ferns, berry bush
local fr = mk(); E(fr, 240, 214, 52, 14); fr = GX.rough(fr, 21, 1)
GX.lit(c, fr, GX.ramp6({ hi = GX.mix(P.grass.hi, "#fff4d6", .5), base = GX.mix(P.grass.hi, "#fff4d6", .2), shade = P.grass.base, deep = P.grass.shade }), { R = 6, tex = .2, sc = 4, seed = 22, ink = false })
for a = 0, 17 do
  local t = a / 18 * 6.2832; local x, y = 240 + floor(52 * cos(t)), 214 + floor(14 * sin(t))
  local st = c:rect(x, y - 4, x, y); c:fillMask(st, "#e8dcc0")
  local cp = mk(); E(cp, x, y - 5, 3, 2); GX.lit(c, cp, GX.ramp6({ hi = "#ffffff", base = "#fff4d6", shade = "#d8c8a8", deep = "#a8987e" }), { R = 2, tex = 0, seed = a })
end
local NUT = { hi = "#d19a62", base = "#b97a4a", shade = "#864c33", deep = "#51302b" }
local CPR = { hi = "#a8704a", base = "#7a4a34", shade = "#5a3430", deep = "#3a2229" }
for _, a in ipairs{ { 172, 196 }, { 184, 206 }, { 62, 222 }, { 130, 244 }, { 250, 252 }, { 440, 224 }, { 326, 240 } } do
  local n = mk(); E(n, a[1], a[2] + 3, 4, 5); GX.lit(c, n, GX.ramp6(NUT), { R = 4, tex = .1, seed = a[1], rimlight = true })
  local cp = mk(); E(cp, a[1], a[2] - 1, 5, 3); GX.lit(c, cp, GX.ramp6(CPR), { R = 3, tex = .25, sc = 2, seed = a[2], rimlight = true }); c:px(a[1], a[2] - 5, INK)
end
local function fern(x, y, dir)
  for i = 0, 6 do
    local ang = (-80 + i * 24) * dir
    local len = 30 - abs(i - 3) * 3
    local ex, ey = x + floor(len * sin(ang / 57.3)), y - floor(len * cos(ang / 57.3))
    local mx, my = (x + ex) // 2 - dir * 3, (y + ey) // 2 - 4
    local fr2 = c:poly{ { x, y }, { mx - 3, my }, { ex, ey }, { mx + 3, my + 4 } }
    GX.lit(c, fr2, GX.ramp6(i % 2 == 0 and GRN1 or GRN2), { R = 3, tex = .25, sc = 2, seed = i, rimlight = true })
  end
end
fern(20, 264, 1); fern(444, 218, -1); fern(300, 266, -1)
for _, p in ipairs{ { -14, 0, 14, 9 }, { 8, -2, 16, 10 }, { -2, -10, 14, 10 } } do
  local m = mk(); E(m, 396 + p[1], 232 + p[2], p[3], p[4]); m = GX.rough(m, p[3], 1); GX.lit(c, m, GX.ramp6(GRN2), { R = 7, tex = .5, sc = 3, seed = p[3], rimlight = true })
end
for i = 0, 11 do local bx, by = 376 + floor(H(i, 5, 1) * 40), 218 + floor(H(i, 9, 1) * 20); local bm = mk(); E(bm, bx, by, 2); GX.lit(c, bm, GX.ramp6(REDL), { R = 2, tex = 0, ink = INK }) end
for i = 0, 150 do   -- fallen leaves, lit with two tones
  local x, y = floor(H(i, 31, 1) * 480), 150 + floor(H(i, 37, 1) * 120)
  local col = P.leaves[1 + i % #P.leaves]
  c:px(x, y, col); c:px(x + 1, y, col); c:px(x + 1, y + 1, GX.mix(col, "#000000", .3)); c:px(x, y + 1, GX.mix(col, "#ffffff", .2))
end
if MK == "C" then   -- fireflies + lantern on a stake + glow mushrooms on the ground
  for i = 0, 40 do
    local x, y = 20 + floor(H(i, 71, 1) * 440), 70 + floor(H(i, 73, 1) * 150)
    c:px(x - 1, y, "#4a6ad0"); c:px(x + 1, y, "#4a6ad0"); c:px(x, y - 1, "#4a6ad0"); c:px(x, y + 1, "#4a6ad0"); c:px(x, y, "#fff4a0")
  end
  local post = c:rect(190, 170, 192, 214); GX.lit(c, post, GX.ramp6(WOOD or P.bark), { R = 2, tex = .2, seed = 3 })
  local hl2 = mk(); E(hl2, 191, 168, 14); c:fillMask(hl2, "#4a5aa8"); local hl3 = mk(); E(hl3, 191, 168, 10); c:fillMask(hl3, "#8a98d8")
  local lt = mk(); E(lt, 191, 168, 5, 7); GX.lit(c, lt, GX.ramp6({ hi = "#fff4d6", base = "#ffd470", shade = "#e8a030", deep = "#8f4a1f" }), { R = 5, tex = 0, rimlight = true })
  shroom(210, 246, 1, true); shroom(300, 252, 2, true)
elseif MK == "B" then   -- butterflies
  for _, b in ipairs{ { 190, 150, "#ff9fc0" }, { 260, 134, "#ffd470" }, { 410, 120, "#a0c8ff" } } do
    local x, y, col = b[1], b[2], b[3]
    c:fillMask(c:rect(x - 3, y - 2, x - 1, y), col); c:fillMask(c:rect(x + 1, y - 2, x + 3, y), col); c:fillMask(c:rect(x - 2, y + 1, x - 1, y + 2), GX.mix(col, "#000000", .2)); c:fillMask(c:rect(x + 1, y + 1, x + 2, y + 2), GX.mix(col, "#000000", .2)); c:px(x, y - 1, INK); c:px(x, y, INK)
  end
end

---------------------------------------------------------------- satchel back
SAT.back(c, GX, MK, P.shadow)
c:save{ aseprite = d .. "/out/mock" .. MK .. "-scene.aseprite", png = d .. "/out/mock" .. MK .. "-scene.png", scale = 1 }

local f = HP.canvas{ w = 480, h = 270, scale = 1, name = "mock" .. MK .. "front" }
SAT.front(f, GX, MK)
f:save{ aseprite = d .. "/out/mock" .. MK .. "-front.aseprite", png = d .. "/out/mock" .. MK .. "-front.png", scale = 1 }
