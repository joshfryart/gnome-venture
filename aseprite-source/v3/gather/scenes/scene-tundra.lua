-- scene-tundra: snowfield under a low pink-gold sun (day palette)
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H, INK = X.hash, GX.INK
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "tundra" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end

local SNOW = { hi = "#ffffff", base = "#f2ecf8", shade = "#c4c4ee", deep = "#9494d0" }
local SN6 = GX.ramp6(SNOW)
local SPR = { hi = "#5a9a88", base = "#2e6e6c", shade = "#1f4a58", deep = "#162c40" }
local FAR = { hi = "#eee6f8", base = "#cdc4ea", shade = "#a49ed4", deep = "#8284bc" }
local STO = { hi = "#c8c4e0", base = "#9a98c4", shade = "#6c6a9c", deep = "#464470" }
local ICE = { hi = "#f4fcff", base = "#bfe4f6", shade = "#8cb8e4", deep = "#6a90cc" }
local GRS = { hi = "#f0d890", base = "#b88e4e", shade = "#7e5c3c", deep = "#4e3a30" }
local RED = { hi = "#ff8a6c", base = "#e0403c", shade = "#aa2a42", deep = "#681e3c" }

---------------------------------------------------------------- sky, sun, ridge
GX.bands(c, 0, 140, { "#9eb2e6", "#bab8ec", "#dcbfe6", "#f6c8d0", "#fdd4b4", "#ffe4b0" }, 3, .2)
local sg = mk(); E(sg, 215, 118, 46, 30); sg = GX.rough(sg, 4, 1); c:fillMask(sg, "#ffe0c0")
local sg2 = mk(); E(sg2, 215, 118, 30, 20); sg2 = GX.rough(sg2, 5, 1); c:fillMask(sg2, "#ffeab8")
local sun = mk(); E(sun, 215, 118, 14, 13); c:fillMask(sun, "#fff8dc")
for i = 0, 26 do   -- wispy cloud streaks
  local y = 20 + floor(H(i, 3, 1) * 80); local x = floor(H(i, 5, 1) * 460); local w = 14 + floor(H(i, 7, 1) * 30)
  c:fillMask(c:rect(x, y, x + w, y), GX.mix("#f6c8d0", "#ffffff", .5))
end
GX.ground(c, function(x) return 122 + floor(5 * sin(x / 37) + 3 * sin(x / 13 + 1)) end, FAR, 5, { top = .7, fall = .3, tex = .3 })
local function distspruce(cx, base, h)
  for y = base - h, base do
    local hw = floor((y - (base - h)) / h * h * .22) + 1
    if (y % 4) ~= 0 then hw = hw - 1 end
    for x = cx - hw, cx + hw do c:px(x, y, x < cx and "#5c6aa4" or "#44508a") end
  end
end
for _, t in ipairs{ { 150, 130, 20 }, { 164, 128, 14 }, { 246, 129, 18 }, { 268, 127, 12 }, { 448, 129, 20 }, { 470, 128, 15 }, { 12, 130, 15 }, { 120, 129, 12 } } do distspruce(t[1], t[2], t[3]) end

---------------------------------------------------------------- snowfield
GX.ground(c, function(x) return 140 + floor(3 * sin(x / 29 + 1) + 2 * sin(x / 11)) end, SNOW, 7, { top = .9, fall = .55, tex = .34, sc = 9 })
for i = 0, 30 do   -- soft blue drifts
  local x, y = floor(H(i, 11, 1) * 480), 150 + floor(H(i, 13, 1) * 115)
  local m = mk(); E(m, x, y, 16 + i % 5 * 5, 2 + i % 2); m = GX.rough(m, i, 1); c:fillMask(m, GX.mix(SNOW.shade, SNOW.base, .45))
end
local shd = mk(); GX.disc(shd, 357, 213, 74, 5); c:fillMask(shd, SNOW.deep)   -- satchel contact shadow
local function blocked(x, y)
  return (x > 280 and x < 438 and y > 60 and y < 220) or (x < 160 and y > 150 and y < 210) or (x > 185 and x < 245 and y > 160 and y < 202) or (x > 380 and y > 236)
end

---------------------------------------------------------------- spruce
local function spruce(cx, base, h, hw, seed)
  local tr = c:rect(cx - 2, base - 12, cx + 2, base)
  GX.lit(c, tr, GX.ramp6({ hi = "#a07858", base = "#6c4a3c", shade = "#4a3238", deep = "#2e2030" }), { R = 2, tex = .3, seed = seed })
  local n = 6
  for i = n, 1, -1 do
    local ytop = base - h + floor((i - 1) * h * .8 / n)
    local ybot = min(base - 8, ytop + floor(h / n * 1.8))
    local bw = hw * (.38 + .62 * i / n)
    local m = mk()
    for x = cx - floor(bw) - 1, cx + floor(bw) + 1 do
      local lim = ybot - floor(abs(sin((x - cx) * .55 + seed + i)) * 3)
      for y = ytop, lim do
        local t = (y - ytop) / max(1, ybot - ytop)
        if abs(x - cx) <= bw * t ^ .85 + 1 then m:set(x, y) end
      end
    end
    m = GX.rough(m, seed + i, 1)
    GX.lit(c, m, GX.ramp6(SPR), { R = 6, tex = .55, sc = 3, seed = seed + i, amb = .25 })
    m:each(function(x, y)
      local t = (y - ytop) / max(1, ybot - ytop)
      if t < .5 + (GX.vn(x, y, 4, seed) - .5) * .7 then
        local s = (x - cx) / max(1, bw)
        local k = s < -.25 and 6 or (s < .35 and 5 or 4)
        if GX.vn(x, y, 2, seed + 9) < .15 then k = k - 1 end
        c:px(x, y, SN6[k])
      end
    end)
    for x = cx - floor(bw), cx + floor(bw) do   -- icicle-ish snow clumps hanging
      if H(x, i, seed) < .08 then c:px(x, ybot + 1, SN6[4]) end
    end
  end
  c:px(cx, base - h - 1, SN6[6]); c:px(cx, base - h, SN6[6])
end
local function sprshadow(cx, base, len)
  local m = mk(); E(m, cx + len // 2, base - 1, len, 3); m = GX.rough(m, cx, 1); c:fillMask(m, GX.mix(SNOW.shade, SNOW.base, .3))
end
sprshadow(30, 152, 60); sprshadow(150, 148, 30); sprshadow(466, 172, 6)

---------------------------------------------------------------- frozen pond (hero, left)
local pm = mk(); E(pm, 80, 182, 66, 19); pm = GX.rough(pm, 31, 2)
local bank = pm:copy():grow(3); bank = GX.rough(bank, 33, 1)
c:fillMask(bank, GX.mix(SNOW.shade, SNOW.base, .5))
local bank2 = pm:copy():grow(2); c:fillMask(bank2, "#f8f2fa")
local IC6 = GX.ramp6(ICE)
GX.lit(c, pm, IC6, { R = 12, tex = .35, sc = 4, seed = 8, amb = .35, wrap = .5,
  fn = function(x, y) return (GX.vn(x * .3, y, 5, 14) - .5) * .25 end })
local cr = { }
local function crack(x, y, ang, len, depth)
  for s = 1, len do
    ang = ang + (H(x, y, 5) - .5) * .9
    x = x + cos(ang) * 1.3; y = y + sin(ang) * .7
    local px, py = floor(x), floor(y)
    if not pm:has(px, py) or not pm:has(px, py - 1) then return end
    c:px(px, py, ICE.deep); c:px(px - 1, py - 1, ICE.hi)
    if s % 9 == 0 and depth < 2 then crack(x, y, ang + (H(px, py, 6) > .5 and 1.1 or -1.1), 12 + floor(H(px, py, 7) * 14), depth + 1) end
  end
end
crack(70, 180, .2, 40, 0); crack(70, 180, 3.3, 34, 0); crack(100, 174, 1.0, 22, 1); crack(48, 188, -.5, 24, 1); crack(95, 190, 2.4, 18, 1)
for _, g in ipairs{ { 104, 176, 8 }, { 112, 182, 5 }, { 96, 188, 6 }, { 118, 187, 4 } } do   -- sun streak on the ice
  c:fillMask(c:rect(g[1], g[2], g[1] + g[3], g[2]), "#fff0d0")
end
for i = 0, 14 do   -- trapped bubbles
  local x, y = 24 + floor(H(i, 21, 1) * 112), 170 + floor(H(i, 23, 1) * 24)
  if pm:has(x, y) and pm:has(x + 2, y) then c:px(x, y, ICE.hi); c:px(x + 1, y, ICE.hi); c:px(x + 1, y + 1, ICE.shade) end
end
local function gtuft(x, y) GX.tuft(c, x, y, GRS) end
for _, p in ipairs{ { 18, 188 }, { 24, 196 }, { 144, 184 }, { 140, 193 }, { 60, 166 }, { 112, 165 }, { 36, 200 } } do gtuft(p[1], p[2]) end

---------------------------------------------------------------- boulders
local function boulder(cx, cy, rx, ry, seed)
  local sh = mk(); E(sh, cx + 5, cy + ry - 1, rx + 4, 3); c:fillMask(sh, GX.mix(SNOW.shade, SNOW.base, .2))
  local m = mk(); E(m, cx, cy, rx, ry); m = GX.rough(m, seed, 2)
  GX.lit(c, m, GX.ramp6(STO), { R = max(rx, ry) * .8, tex = .5, sc = 3, seed = seed, rimlight = true })
  m:each(function(x, y)
    local t = (y - (cy - ry)) / (ry * 2)
    local nz = GX.vn(x, y, 3, seed + 4)
    if t < .38 + (nz - .5) * .5 and x < cx + rx * .5 then c:px(x, y, SN6[(x < cx and 6 or 5)])
    elseif t < .55 and nz > .66 then c:px(x, y, ICE.base) end
    if H(x, y, seed) < .02 and t > .3 then c:px(x, y, "#e8a830") end   -- lichen
    if t > .35 and H(x // 2, y // 2, seed + 2) < .05 then c:px(x, y, "#b8c898") end
  end)
  for i = 0, 3 do c:px(cx - rx + 3 + i * 3, cy - ry + 4 + (i % 2), "#ffffff") end
end
boulder(176, 160, 15, 9, 41); boulder(36, 242, 26, 14, 43); boulder(262, 238, 12, 7, 45); boulder(118, 246, 9, 5, 47)

---------------------------------------------------------------- ground details
local function berries(x, y)
  c:px(x - 3, y, "#4a6a40"); c:px(x - 2, y - 1, "#6a8a50"); c:px(x + 3, y, "#4a6a40")
  for _, p in ipairs{ { 0, 0 }, { 2, 1 }, { -2, 1 }, { 1, -2 } } do
    c:px(x + p[1], y + p[2], RED.base); c:px(x + p[1] + 1, y + p[2], RED.shade); c:px(x + p[1], y + p[2] + 1, RED.deep); c:px(x + p[1], y + p[2] - 1, RED.hi)
  end
end
for i = 0, 40 do
  local x, y = 8 + floor(H(i, 61, 1) * 460), 154 + floor(H(i, 63, 1) * 112)
  if not blocked(x, y) then
    local k = i % 4
    if k < 2 then gtuft(x, y)
    elseif k == 2 then   -- lichen patch
      local m = mk(); E(m, x, y, 3, 1); m = GX.rough(m, i, 1); c:fillMask(m, i % 2 == 0 and "#d8a43a" or "#a8bc88")
      c:px(x, y, "#f0d070")
    else berries(x, y) end
  end
end
for _, p in ipairs{ { 150, 218 }, { 230, 228 }, { 292, 232 }, { 54, 220 }, { 178, 250 }, { 330, 250 }, { 14, 214 } } do berries(p[1], p[2]) end
for _, p in ipairs{ { 100, 232 }, { 204, 218 }, { 300, 246 }, { 74, 256 }, { 240, 258 } } do gtuft(p[1], p[2]) end
for i = 0, 70 do   -- little bluish tracks / ice crumbs
  local x, y = floor(H(i, 71, 1) * 480), 156 + floor(H(i, 73, 1) * 110)
  if not blocked(x, y) then c:px(x, y, SNOW.shade); c:px(x + 1, y + 1, SNOW.shade) end
end
for i = 0, 8 do   -- fox footprints leading to the fox
  local x, y = 250 - i * 6, 205 - (i % 2) * 2 + i // 2
  c:px(x, y, SNOW.deep); c:px(x + 1, y, SNOW.deep); c:px(x, y - 1, SNOW.shade)
end

---------------------------------------------------------------- arctic fox with a berry (quirk)
local function fpart(m, seed, R) GX.lit(c, m, GX.ramp6(R), { R = 5, tex = .25, sc = 2.5, seed = seed, rimlight = true }) end
local FOX = { hi = "#ffffff", base = "#f0eaf6", shade = "#c0bce8", deep = "#8c88c4" }
local tail = mk(); E(tail, 207, 193, 9, 4); tail = GX.rough(tail, 51, 1); fpart(tail, 51, FOX)
local body = mk(); E(body, 214, 188, 8, 10); body = GX.rough(body, 52, 1); fpart(body, 52, FOX)
local e1 = c:poly{ { 211, 174 }, { 212, 165 }, { 216, 173 } }; fpart(e1, 53, FOX)
local e2 = c:poly{ { 218, 173 }, { 222, 165 }, { 224, 174 } }; fpart(e2, 54, FOX)
local head = mk(); E(head, 218, 177, 7, 5); head = GX.rough(head, 55, 1); fpart(head, 55, FOX)
local snout = c:poly{ { 223, 176 }, { 228, 179 }, { 223, 181 } }; fpart(snout, 56, FOX)
c:px(212, 165, INK); c:px(222, 165, INK); c:px(228, 179, INK); c:px(221, 175, INK); c:px(222, 175, INK)
c:px(226, 181, RED.base); c:px(227, 181, RED.base); c:px(226, 182, RED.shade); c:px(227, 182, RED.deep); c:px(226, 180, RED.hi)
for _, x in ipairs{ 211, 215, 219 } do c:px(x, 198, INK); c:px(x + 1, 198, INK) end
local ft = c:rect(210, 195, 219, 197); fpart(ft, 57, FOX)

---------------------------------------------------------------- framing spruces (last, in front)
spruce(30, 154, 124, 40, 61)
spruce(150, 150, 70, 24, 63)
spruce(466, 176, 160, 32, 67)
spruce(436, 138, 46, 14, 69)
-- foreground low shrub twigs bottom-left
for i = 0, 5 do local x = 6 + i * 4; for y = 262, 269 - (i % 2) do c:px(x, y, GRS.shade) end; c:px(x, 262, GRS.hi) end

---------------------------------------------------------------- sparkles
for i = 0, 60 do
  local x, y = 6 + floor(H(i, 81, 1) * 468), 142 + floor(H(i, 83, 1) * 124)
  if not (x > 286 and x < 436 and y > 60 and y < 218) then
    c:px(x, y, "#ffffff")
    if i % 3 == 0 then c:px(x - 1, y, "#fff4d8"); c:px(x + 1, y, "#fff4d8"); c:px(x, y - 1, "#fff4d8"); c:px(x, y + 1, "#fff4d8") end
  end
end

c:save{ aseprite = d.."/../out/scene-tundra.aseprite", png = d.."/../out/scene-tundra.png", scale = 1 }
