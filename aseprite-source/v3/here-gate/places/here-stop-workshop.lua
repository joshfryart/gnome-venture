-- Gnome Venture "Hearth Pop" v3: HERE gate view, Workshop rest stop (480x270 native)
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = (app and app.params and app.params.out) or "/home/user/gnome-venture/aseprite-source/v3/here-gate/places/"
local NAME = "here-stop-workshop"
local W, H, HZ, VX, VY = 480, 270, 112, 240, 112
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }

local floor, sin, cos, abs = math.floor, math.sin, math.cos, math.abs
local function R(v) return floor(v + 0.5) end
local function hash(x, y, s) local n = sin(x * 127.1 + y * 311.7 + (s or 0) * 74.7) * 43758.5453 return n - floor(n) end
local function P(x, y, col) if x >= 0 and y >= 0 and x < W and y < H then c:put(x, y, col) end end
local function poly(pts) local q = {} for i, p in ipairs(pts) do q[i] = { R(p[1]), R(p[2]) } end return c:poly(q) end
local function rect(x0, y0, x1, y1) return c:rect(R(x0), R(y0), R(x1), R(y1)) end
local function rec(p, k) return { p[1] + (VX - p[1]) * k, p[2] + (VY - p[2]) * k } end

-- generic lit fill: top/left hi, lower-right shade band, optional texture, deep rim
local function fill(m, r, o)
  o = o or {}
  local band = o.band or 2
  m:each(function(x, y)
    local col = r[3]
    if not m:has(x + band, y) or not m:has(x, y + band) then col = r[2] end
    if not m:has(x - 1, y) or not m:has(x, y - 1) then col = r[4] end
    if o.tex then col = o.tex(x, y, col) or col end
    c:put(x, y, col)
  end)
  if o.rim ~= false then c:rim(m, o.rim or r[1]) end
  return m
end

-- ramps {deep, shade, base, hi}
local INK = "#2b1c26"
local WOOD = { "#4a2a20", "#7a4630", "#a0643c", "#c58552" }
local WOODS = { "#3c2230", "#5e3a3e", "#7c4c40", "#94604a" }   -- side wall (cool shade)
local SLATE = { "#2f3550", "#475473", "#5f6f8f", "#8597b6" }
local BRASS = { "#6a4a1c", "#a07428", "#d1a040", "#f0cc6a" }
local IRON = { "#2c2f3d", "#464b62", "#646a85", "#9aa2bd" }
local STONE = { "#4f4552", "#776a74", "#9a8c8e", "#c2b4ac" }
local CRATE = { "#5a3a22", "#8a6034", "#b98a4e", "#dcb170" }
local PLAST = { "#7a6450", "#c2a678", "#e8d4a6", "#f6e8c4" }
local TEAL = { "#2e4a48", "#3f6e62", "#5f9a7a", "#8cc29a" }
local TERRA = { "#5a2a22", "#8e4430", "#c0623e", "#e48a5a" }
local HSTONE = { "#4e4656", "#7a7080", "#a99a8c", "#cbbcaa" }
local ROCK = { "#4a4458", "#6f6880", "#948a9a", "#bdb2b8" }
local CORK = { "#6a4428", "#9a6a40", "#c4945e", "#deb47c" }
local RED = { "#5e1e2a", "#9a2e36", "#c8443e", "#ee7a5a" }
local LOG = { "#4a2c22", "#6e4630", "#946040", "#b88258" }
local GLOW, GLOWH, GLOWD = "#ffd36e", "#ffeaa6", "#e89a3e"

------------------------------------------------------------------ SKY (golden late afternoon)
c:stripes(0, HZ - 1, { "#6a77b0", "#8484b8", "#a58cb6", "#c99ab0", "#e8ad9e", "#f4c48e", "#f8d89a" }, { 3, 3, 3, 3, 3, 2, 2 })
c:cloud(60, 40, 46, "#fbe2c0", "#e2a6a8")
c:cloud(150, 30, 34, "#f8d4bc", "#d79aa6")
c:cloud(300, 46, 52, "#fbe2c0", "#e2a6a8")
c:cloud(392, 34, 30, "#f8d4bc", "#d79aa6")
c:cloud(214, 62, 24, "#fbe6c4", "#e7b2a8")

------------------------------------------------------------------ FAR SCENERY
c:terrain(function(x) return R(86 + 7 * sin(x / 41) + 4 * sin(x / 13 + 1)) end, "#9a8cba", HZ - 1)
c:terrain(function(x) return R(94 + 5 * sin(x / 29 + 2) + 3 * sin(x / 9)) end, "#8a8fae", HZ - 1)
local hill = c:terrain(function(x) return R(101 + 4 * sin(x / 23 + 0.5) + 2 * sin(x / 7)) end, "#7f9e72", HZ - 1)
hill:each(function(x, y) if y == R(101 + 4 * sin(x / 23 + 0.5) + 2 * sin(x / 7)) then c:put(x, y, "#9cb882") end end)
-- distant tree clumps (lollipop-free: stacked bumps)
for _, t in ipairs{ { 168, 100 }, { 180, 98 }, { 300, 99 }, { 312, 101 }, { 262, 103 }, { 196, 103 } } do
  local x, y = t[1], t[2]
  c:fillMask(poly{ { x - 6, y + 4 }, { x - 5, y - 4 }, { x - 2, y - 8 }, { x + 2, y - 8 }, { x + 5, y - 4 }, { x + 6, y + 4 } }, "#5f7e62")
  c:fillMask(poly{ { x - 4, y - 3 }, { x - 2, y - 7 }, { x + 1, y - 7 }, { x, y - 3 } }, "#78966e")
  c:put(x, y + 5, "#4e5e50") c:put(x, y + 6, "#4e5e50")
end
-- far road climbing the hill
for y = 100, HZ - 1 do local hw = (y - 100) * 0.4 + 1 for x = R(VX - hw), R(VX + hw) do if y >= 104 then c:put(x, y, "#d8bc8e") end end end

------------------------------------------------------------------ GROUND
local function pathL(y) return (VX - 8) - (y - HZ) / (H - HZ) * 82 end
local function pathR(y) return (VX + 8) + (y - HZ) / (H - HZ) * 82 end
local function sideTop(x) return 150 - (x - 262) * (12 / 204) end
local function sideBot(x) return 161 - (x - 262) * (9 / 204) end
local function glowF(x, y) return ((x - 62) / 44) ^ 2 + ((y - 238) / 13) ^ 2 < 1 end
local function glowP(x, y) return ((x - 336) / 48) ^ 2 + ((y - 206) / 18) ^ 2 < 1 end
for y = HZ, H - 1 do
  local t = (y - HZ) / (H - HZ)
  local xl, xr = pathL(y), pathR(y)
  for x = 0, W - 1 do
    local col
    local main = x >= xl and x <= xr
    local side = (x > xr - 4) and x >= 262 and y >= sideTop(x) and y <= sideBot(x)
    local glow = glowF(x, y) or glowP(x, y)
    if main or side then
      col = t < 0.3 and "#d8b27a" or (t < 0.65 and "#cfa56c" or "#c79b62")
      if glow then col = "#e8bc78" end
      if main then
        local u = (x - xl) / (xr - xl)
        if abs(u - 0.3) < 0.035 or abs(u - 0.7) < 0.035 then col = "#b38655" end
        if x - xl < 1.2 or xr - x < 1.2 then col = "#8e9c4e" end
      end
      local h = hash(x, y, 3)
      if t > 0.15 and h < 0.02 then col = "#e8c890"
      elseif t > 0.15 and hash(x - 1, y - 1, 3) < 0.02 then col = "#9c7550" end
    else
      col = t < 0.25 and "#a7b56c" or (t < 0.6 and "#97ac5d" or "#88a253")
      if glow then col = "#b9b462" end
      local h = hash(x, y, 7)
      local th = 0.025 + t * 0.03
      if h < th then col = "#6f8c48"
      elseif hash(x, y + 1, 7) < th then col = "#b8c87a" end
      if t > 0.5 and hash(x, y, 9) < 0.006 then col = "#e6b34a" end -- tiny buttercups
    end
    c:put(x, y, col)
  end
end
-- shadows: darken whatever ground is under the mask (cool violet)
local SH = {}
local function shadowCol(col)
  if not col then return "#6c7058" end
  local r, g, b = tonumber(col:sub(2, 3), 16), tonumber(col:sub(4, 5), 16), tonumber(col:sub(6, 7), 16)
  local function cl(v) return math.max(16, math.min(235, floor(v))) end
  return string.format("#%02x%02x%02x", cl(r * 0.68 + 10), cl(g * 0.64 + 6), cl(b * 0.7 + 30))
end
local function shadow(m) local cols = {} m:each(function(x, y) cols[#cols + 1] = { x, y, shadowCol(c:get(x, y)) } end) for _, p in ipairs(cols) do c:put(p[1], p[2], p[3]) end end
local function shadowE(cx, cy, rx, ry) shadow(c:ellipse(cx, cy, rx, ry)) end
local function spark(x, y, big)
  P(x, y, "#fff0b8") P(x - 1, y, "#ffb050") P(x + 1, y, "#ffb050") P(x, y - 1, "#ffb050") P(x, y + 1, "#ffb050")
  if big then P(x - 2, y, "#f07a3a") P(x + 2, y, "#f07a3a") P(x, y - 2, "#f07a3a") P(x, y + 2, "#f07a3a") end
end
local function window(x0, y0, x1, y1, frame)
  local m = rect(x0, y0, x1, y1)
  c:rim(m, frame)
  m:each(function(x, y)
    local col = GLOW
    if x - x0 < 2 and y - y0 < 3 then col = GLOWH end
    if y1 - y < 2 then col = GLOWD end
    c:put(x, y, col)
  end)
  local mx, my = R((x0 + x1) / 2), R((y0 + y1) / 2)
  for y = y0, y1 do c:put(mx, y, frame) end
  for x = x0, x1 do c:put(x, my, frame) end
  local sill = rect(x0 - 2, y1 + 2, x1 + 2, y1 + 3) fill(sill, WOOD, { band = 1 })
end
local function gear(cx, cy, R1, R2, n, rot)
  local pts = {}
  for i = 0, n * 4 - 1 do
    local a = (i + 0.5) / (n * 4) * math.pi * 2 + (rot or 0)
    local rr = (i % 4 < 2) and R1 or R2
    pts[#pts + 1] = { cx + rr * cos(a), cy + rr * sin(a) }
  end
  return poly(pts)
end
local function planks(step, ramp, seed)
  return function(x, y, col)
    if x % step == 0 then return ramp[2] end
    if col == ramp[3] and hash(floor(x / step), y // 3, seed) < 0.18 and hash(x, y, seed) < 0.5 then return ramp[2] end
    if col == ramp[3] and hash(x, y, seed + 1) < 0.04 then return ramp[4] end
  end
end
local function shingles(ramp)
  return function(x, y, col)
    if y % 4 == 0 then return ramp[1] == col and col or ramp[2] end
    if (x + (floor(y / 4) % 2) * 4) % 8 == 0 then return ramp[2] end
    if y % 4 == 1 and col == ramp[3] then return ramp[4] end
  end
end
local function bricks(ramp, bw, bh)
  return function(x, y, col)
    if y % bh == 0 then return ramp[2] end
    if (x + (floor(y / bh) % 2) * floor(bw / 2)) % bw == 0 then return ramp[2] end
    if col == ramp[3] and hash(floor(x / bw), floor(y / bh), 5) < 0.25 then return ramp[4] end
  end
end

-- building with front gable + receding side face toward the vanishing point
local function building(o)
  local px = (o.x0 + o.x1) / 2
  local right = o.x1 < VX
  local sx = right and o.x1 or o.x0
  local ov = o.ov or 4
  local a, b = { sx, o.ye }, { sx, o.yb }
  local a2, b2 = rec(a, o.k), rec(b, o.k)
  local Pk = { px, o.yp }
  local E = { sx + (right and ov or -ov), o.ye + 3 }
  local P2, E2 = rec(Pk, o.k), rec(E, o.k)
  shadow(poly{ { o.x0 - 2, o.yb - 1 }, { o.x1 + 2, o.yb - 1 }, { right and b2[1] + 8 or o.x1 + 6, b2[2] + 2 }, { o.x1 + 8, o.yb + 6 }, { o.x0 + 6, o.yb + 6 } })
  local side = poly{ a, a2, b2, b }
  fill(side, o.sideRamp, { tex = o.sideTex, band = 1, rim = INK })
  local roof = poly{ Pk, P2, E2, E }
  fill(roof, o.roof, { tex = shingles(o.roof), rim = INK })
  local front = poly{ { o.x0, o.ye }, Pk, { o.x1, o.ye }, { o.x1, o.yb }, { o.x0, o.yb } }
  fill(front, o.wall, { tex = o.tex, band = 3, rim = INK })
  local trim = c:line({ { R(o.x0 - ov), R(o.ye + 3) }, { R(px), R(o.yp - 1) }, { R(o.x1 + ov), R(o.ye + 3) } }, 3)
  c:rim(trim, INK)
  trim:each(function(x, y) c:put(x, y, trim:has(x, y - 1) and o.roof[2] or o.roof[4]) end)
  return { front = front, side = side, px = px, a2 = a2, b2 = b2 }
end

------------------------------------------------------------------ HOMES (far left, k="homes")
-- hut 1: cream plaster + timber, teal roof
local h1 = building{ x0 = 24, x1 = 76, ye = 104, yp = 82, yb = 128, k = 0.12, wall = PLAST, sideRamp = { "#5a4a48", "#8a7468", "#a88e7c", "#c0a48a" },
  roof = TEAL, tex = function(x, y, col) if x == 24 + 2 or x == 74 or y == 116 then return "#7a5034" end if hash(x, y, 11) < 0.05 then return PLAST[2] end end }
window(32, 109, 42, 119, INK)
local d1 = rect(52, 112, 62, 128) fill(d1, TEAL, { tex = planks(3, TEAL, 2) }) P(60, 120, BRASS[4])
local fb = rect(31, 122, 43, 125) fill(fb, WOOD, { band = 1 })
for i = 0, 4 do P(32 + i * 2 + 1, 121, (i % 2 == 0) and "#e86a7a" or "#f2c04a") end
-- hut 2: stone, terracotta roof, tiny chimney
local ch2 = rect(126, 74, 133, 92) fill(ch2, HSTONE, { tex = bricks(HSTONE, 4, 3) })
local h2 = building{ x0 = 92, x1 = 148, ye = 102, yp = 80, yb = 128, k = 0.1, wall = HSTONE, sideRamp = { "#3e3848", "#5a5262", "#6e6474", "#827686" },
  roof = TERRA, tex = bricks(HSTONE, 7, 4) }
local d2 = poly{ { 101, 128 }, { 101, 114 }, { 103, 111 }, { 109, 111 }, { 111, 114 }, { 111, 128 } } fill(d2, RED, { tex = planks(3, RED, 4) }) P(108, 120, BRASS[4])
window(122, 108, 136, 118, INK)
c:cloud(122, 70, 14, "#e8dcd8", "#c8b4c0") c:cloud(130, 60, 12, "#f2e6e0", "#d4c0c8")
-- quirk: a bird-house shaped like a tiny cog on hut 1 gable
local cg = gear(50, 94, 5, 3, 6, 0.2) fill(cg, BRASS, { band = 1 }) P(50, 94, BRASS[1]) P(51, 94, BRASS[1])

------------------------------------------------------------------ STOP (signpost + notice board, k="stop")
shadowE(316, 147, 36, 4)
local p1 = rect(290, 104, 294, 146) fill(p1, WOOD, { tex = planks(9, WOOD, 3), band = 1 })
local p2 = rect(332, 104, 336, 146) fill(p2, WOOD, { tex = planks(9, WOOD, 3), band = 1 })
local cap = poly{ { 280, 104 }, { 288, 94 }, { 340, 94 }, { 348, 104 } } fill(cap, TERRA, { tex = shingles(TERRA) })
local brd = rect(284, 106, 342, 134) fill(brd, WOOD, { band = 2 })
local cork = rect(288, 109, 338, 131) fill(cork, CORK, { rim = false, tex = function(x, y, col) if hash(x, y, 21) < 0.12 then return CORK[2] end end })
-- pinned notes (icon doodles, no text)
local notes = { { 291, 111, 305, 125, "#f6e8c4", "#c8443e" }, { 308, 113, 320, 129, "#cfe2f0", "#3f6e9a" }, { 323, 110, 335, 121, "#f8cfd8", "#5f9a7a" }, { 324, 123, 335, 130, "#f6e8c4", "#d1a040" } }
for i, n in ipairs(notes) do
  local m = rect(n[1], n[2], n[3], n[4]) shadow(m:shift(1, 1)) fill(m, { "#7a6450", "#c8b8a0", n[5], n[5] }, { band = 1, rim = false })
  P(R((n[1] + n[3]) / 2), n[2] + 1, n[6]) P(R((n[1] + n[3]) / 2), n[2], RED[2])
end
-- note doodles: tiny map path, a sun-ish star, a wave, a bar
for i = 0, 8 do P(293 + i, 121 - floor(i / 2) % 3, "#9a2e36") end
for i = 0, 6 do P(310 + i, 120 + (i % 2), "#3f6e9a") P(310 + i, 124 + ((i + 1) % 2), "#3f6e9a") end
c:fillMask(poly{ { 329, 113 }, { 331, 116 }, { 329, 119 }, { 327, 116 } }, "#5f9a7a")
for x = 326, 333 do P(x, 126, "#a07428") end
-- stamp post with big stamp
local sp = rect(348, 118, 352, 146) fill(sp, IRON, { band = 1 })
local tray = rect(344, 114, 356, 118) fill(tray, BRASS, { band = 1 })
local sb = rect(345, 106, 355, 112) fill(sb, RED, { band = 1 })
local sh = poly{ { 348, 106 }, { 348, 100 }, { 346, 97 }, { 349, 95 }, { 352, 97 }, { 351, 100 }, { 351, 106 } } fill(sh, LOG, { band = 1 })
-- inked stamp print on a note (star mark)
P(300, 114, "#c8443e") P(299, 115, "#c8443e") P(301, 115, "#c8443e") P(300, 116, "#c8443e")

------------------------------------------------------------------ WILD TRAIL (right edge, k="wild")
-- glimpse through the arch: deep wood
local inside = poly{ { 428, 106 }, { 466, 104 }, { 466, 160 }, { 428, 160 } }
inside:each(function(x, y)
  local col = (y < 122) and "#4c6a58" or "#3f5e4a"
  if hash(floor(x / 5), floor(y / 6), 31) < 0.3 then col = "#5f8264" end
  if y >= sideTop(x) - 1 and y <= sideBot(x) then col = (y - sideTop(x) < 2) and "#b89a6c" or "#c8a676" end
  c:put(x, y, col)
end)
for _, tx in ipairs{ 434, 446, 458 } do for y = 112, 138 do P(tx, y, "#2e4438") P(tx + 1, y, "#36503f") end end
shadowE(440, 162, 34, 4)
local lp = poly{ { 410, 162 }, { 411, 120 }, { 415, 106 }, { 424, 98 }, { 432, 102 }, { 431, 130 }, { 433, 162 } }
fill(lp, ROCK, { band = 3, rim = INK, tex = function(x, y, col) if hash(floor(x / 6), floor(y / 5), 41) < 0.2 and col == ROCK[3] then return ROCK[2] end if (x + y) % 11 == 0 and col == ROCK[3] then return ROCK[2] end end })
local lint = poly{ { 418, 104 }, { 426, 92 }, { 446, 88 }, { 466, 88 }, { 466, 104 }, { 446, 103 }, { 432, 108 } }
fill(lint, ROCK, { band = 3, rim = INK, tex = function(x, y, col) if hash(floor(x / 7), floor(y / 4), 43) < 0.25 and col == ROCK[3] then return ROCK[2] end end })
-- moss and a hanging vine
for x = 420, 465 do local y = R(91 + (x < 446 and (446 - x) * 0.15 or 0)) if hash(x, 1, 44) < 0.7 then P(x, y - 1, "#7aa04e") P(x, y, "#5f8a40") end end
for y = 104, 128 do P(452 + R(sin(y / 3)), y, "#5f8a40") if y % 4 == 0 then P(453 + R(sin(y / 3)), y, "#9cc46a") end end
for y = 104, 120 do P(440 + R(sin(y / 2)), y, "#5f8a40") end
-- trail signpost with arrow board (points right, into the wild)
shadowE(406, 160, 8, 2)
local sp2 = rect(403, 118, 407, 160) fill(sp2, LOG, { band = 1 })
local arr = poly{ { 400, 120 }, { 422, 120 }, { 428, 125 }, { 422, 130 }, { 400, 130 } } fill(arr, { "#2e4a2a", "#4f7a3a", "#6fa04a", "#9cc46a" }, { band = 2 })
c:fillMask(poly{ { 405, 124 }, { 414, 124 }, { 414, 122 }, { 418, 125 }, { 414, 128 }, { 414, 126 }, { 405, 126 } }, "#f6e8c4")
local leaf = poly{ { 402, 134 }, { 408, 132 }, { 414, 135 }, { 408, 138 } } fill(leaf, { "#2e4a2a", "#4f7a3a", "#6fa04a", "#9cc46a" }, { band = 1 })

------------------------------------------------------------------ QUIRK: giant wrench as a fence post (between stop and wild)
shadowE(378, 150, 10, 3)
local wr = poly{ { 375, 150 }, { 375, 126 }, { 381, 126 }, { 381, 150 } }
local jaw = poly{ { 370, 126 }, { 370, 114 }, { 374, 114 }, { 374, 120 }, { 382, 120 }, { 382, 114 }, { 386, 114 }, { 386, 126 } }
jaw:add(wr) fill(jaw, IRON, { band = 2 })
for y = 130, 146, 4 do P(377, y, IRON[4]) P(378, y, IRON[4]) end
local rope = c:line({ { 386, 134 }, { 394, 137 }, { 402, 136 } }, 1) c:fillMask(rope, "#c4a070")
local rope2 = c:line({ { 352, 134 }, { 362, 138 }, { 374, 136 } }, 1) c:fillMask(rope2, "#c4a070")

------------------------------------------------------------------ PEOPLE (fire + log bench + table, k="people")
-- log bench behind the fire
shadowE(334, 188, 36, 4)
local lg = rect(302, 174, 362, 184) fill(lg, LOG, { band = 3, tex = function(x, y, col) if (y == 177 or y == 181) and hash(x // 4, y, 51) < 0.6 then return LOG[2] end end })
local lgEnd = poly{ { 362, 173 }, { 366, 175 }, { 367, 179 }, { 366, 183 }, { 362, 185 } } fill(lgEnd, { LOG[1], "#c49a6a", "#dcb47e", "#ecc894" }, { band = 1 })
P(364, 179, "#a87850") P(365, 178, "#a87850")
for _, lx in ipairs{ 308, 354 } do local l = rect(lx, 185, lx + 3, 191) fill(l, LOG, { band = 1 }) end
-- stone fire ring (separate stones) + flames
local ring = {}
for i = 0, 9 do
  local a = i / 10 * math.pi * 2
  ring[#ring + 1] = { R(334 + 19 * cos(a)), R(207 + 7 * sin(a)) }
end
table.sort(ring, function(p, q) return p[2] < q[2] end)
local back, front = {}, {}
for _, p in ipairs(ring) do if p[2] <= 207 then back[#back + 1] = p else front[#front + 1] = p end end
for _, p in ipairs(back) do local s = c:rrect(p[1] - 4, p[2] - 3, p[1] + 4, p[2] + 2, 1) fill(s, STONE, { band = 1 }) end
local coal = poly{ { 322, 208 }, { 328, 203 }, { 340, 203 }, { 346, 208 }, { 340, 212 }, { 328, 212 } } c:fillMask(coal, "#5e2a2a")
for x = 324, 344 do if hash(x, 1, 61) < 0.4 then P(x, 207, "#ff8a3a") end end
local fl = poly{ { 326, 208 }, { 324, 198 }, { 329, 192 }, { 330, 198 }, { 334, 184 }, { 337, 194 }, { 340, 190 }, { 343, 199 }, { 342, 208 } }
fill(fl, { "#b8401e", "#e8622e", "#ff9a40", "#ffd070" }, { band = 2, rim = "#b8401e" })
local fl2 = poly{ { 330, 207 }, { 331, 200 }, { 334, 194 }, { 337, 201 }, { 338, 207 } } c:fillMask(fl2, "#ffe08a")
for _, p in ipairs(front) do local s = c:rrect(p[1] - 4, p[2] - 3, p[1] + 4, p[2] + 2, 1) fill(s, STONE, { band = 1 }) end
spark(346, 180) spark(322, 184) spark(338, 172, true)
-- quirk: kettle with a wind-up key, on a tripod
local tp = c:line({ { 318, 214 }, { 334, 178 }, { 350, 214 } }, 1) c:fillMask(tp, IRON[1])
local kt = poly{ { 327, 188 }, { 329, 184 }, { 339, 184 }, { 341, 188 }, { 340, 194 }, { 328, 194 } } fill(kt, { "#2e4a48", "#3f6e62", "#5f9aa0", "#9cd0c8" }, { band = 1, rim = INK })
c:fillMask(c:line({ { 341, 187 }, { 345, 184 } }, 1), "#3f6e62")
for y = 179, 183 do P(334, y, IRON[1]) end
c:fillMask(rect(324, 189, 326, 190), BRASS[3]) P(323, 188, BRASS[3]) P(323, 191, BRASS[3])
-- table with mugs and a lantern
shadowE(386, 214, 22, 4)
for _, lx in ipairs{ 368, 400 } do local l = rect(lx, 196, lx + 3, 214) fill(l, WOOD, { band = 1 }) end
local tt = poly{ { 364, 190 }, { 404, 190 }, { 406, 196 }, { 362, 196 } } fill(tt, WOOD, { band = 1, tex = planks(8, WOOD, 6) })
local mug1 = rect(368, 183, 373, 189) fill(mug1, RED, { band = 1 }) P(374, 185, RED[1]) P(375, 186, RED[1]) P(374, 187, RED[1])
local mug2 = rect(381, 184, 386, 189) fill(mug2, TEAL, { band = 1 }) P(387, 186, TEAL[1])
local bread = poly{ { 390, 189 }, { 391, 185 }, { 395, 183 }, { 399, 185 }, { 400, 189 } } fill(bread, CRATE, { band = 1 }) P(393, 186, CRATE[2]) P(396, 185, CRATE[2])
local ln = rect(400, 178, 404, 188) fill(ln, BRASS, { band = 1 }) c:fillMask(rect(401, 181, 403, 186), GLOW) P(401, 181, GLOWH)
-- stumps
for _, s in ipairs{ { 300, 214 }, { 362, 220 } } do
  shadowE(s[1] + 7, s[2] + 10, 10, 2)
  local st = rect(s[1], s[2] + 2, s[1] + 14, s[2] + 10) fill(st, LOG, { band = 2 })
  local top = rect(s[1] + 1, s[2], s[1] + 13, s[2] + 2) fill(top, { LOG[1], "#c49a6a", "#dcb47e", "#ecc894" }, { band = 1 })
  P(s[1] + 7, s[2] + 1, "#a87850")
end

------------------------------------------------------------------ WORKSHOP (near left, k="do")
-- chimney (behind gable), kettle on top (quirk), sparks
local chm = rect(30, 140, 42, 170) fill(chm, STONE, { tex = bricks(STONE, 6, 4) })
local chc = rect(28, 136, 44, 140) fill(chc, STONE, { band = 1 })
local ket = poly{ { 31, 136 }, { 32, 130 }, { 35, 128 }, { 40, 128 }, { 43, 130 }, { 44, 136 } } fill(ket, BRASS, { band = 1 })
c:fillMask(c:line({ { 44, 132 }, { 48, 128 } }, 1), BRASS[2]) P(37, 127, BRASS[1]) P(38, 127, BRASS[1])
c:cloud(46, 124, 14, "#e8dcd8", "#c8b4c0") c:cloud(56, 114, 12, "#f2e6e0", "#d4c0c8")
spark(26, 126) spark(48, 138) spark(20, 116, true)
local ws = building{ x0 = 20, x1 = 104, ye = 176, yp = 146, yb = 226, k = 0.14, ov = 5, wall = WOOD, sideRamp = WOODS, roof = SLATE,
  tex = planks(6, WOOD, 1), sideTex = planks(5, WOODS, 8) }
-- beams
for x = 20, 104 do P(x, 186, WOOD[1]) P(x, 187, WOOD[2]) end
-- big gear on the gable
local gr = gear(62, 164, 12, 9, 10, 0) fill(gr, BRASS, { band = 2, rim = INK })
local hub = rect(59, 161, 65, 167) fill(hub, BRASS, { band = 1 }) c:fillMask(rect(61, 163, 63, 165), BRASS[1])
-- forge opening with glow
local door = poly{ { 40, 226 }, { 40, 198 }, { 44, 192 }, { 76, 192 }, { 80, 198 }, { 80, 226 } }
c:rim(door, WOOD[1])
door:each(function(x, y)
  local col = "#4a2a3a"
  if y > 206 then col = "#5e3040" end
  c:put(x, y, col)
end)
local hearth = rect(46, 208, 74, 226) fill(hearth, STONE, { tex = bricks(STONE, 6, 4) })
local coals = poly{ { 48, 208 }, { 52, 202 }, { 68, 202 }, { 72, 208 } } c:fillMask(coals, "#ff8a3a")
c:fillMask(poly{ { 52, 207 }, { 56, 203 }, { 64, 203 }, { 68, 207 } }, "#ffd070")
for x = 49, 71, 3 do P(x, 205 - (x % 2), "#fff0b8") end
local hood = poly{ { 50, 194 }, { 70, 194 }, { 66, 200 }, { 54, 200 } } fill(hood, IRON, { band = 1 })
c:fillMask(rect(41, 226, 79, 226), "#ffb050")
-- side window + front window (lit), pegboard of tools
window(86, 196, 98, 208, INK)
local wsw = poly{ { 108, 192 }, { 116, 190 }, { 116, 200 }, { 108, 203 } } c:rim(wsw, INK) c:fillMask(wsw, GLOWD) c:fillMask(poly{ { 109, 193 }, { 112, 192 }, { 112, 196 }, { 109, 197 } }, GLOW)
local peg = rect(24, 194, 36, 214) fill(peg, CORK, { band = 1 })
c:fillMask(rect(26, 197, 27, 205), IRON[3]) c:fillMask(rect(25, 196, 28, 197), IRON[2])           -- hammer
c:fillMask(rect(30, 197, 31, 207), WOOD[2]) c:fillMask(rect(29, 207, 32, 211), IRON[3])           -- chisel
c:fillMask(rect(33, 198, 34, 210), IRON[4]) P(32, 198, IRON[2]) P(35, 198, IRON[2])               -- spanner
-- anvil on a stump
shadowE(54, 252, 20, 4)
local stp = rect(46, 240, 62, 252) fill(stp, LOG, { band = 2 })
local anv = poly{ { 28, 232 }, { 40, 230 }, { 70, 230 }, { 72, 235 }, { 62, 237 }, { 60, 240 }, { 50, 240 }, { 48, 237 }, { 38, 236 } }
fill(anv, IRON, { band = 2, rim = INK })
P(52, 231, "#d4dcf0") P(53, 231, "#d4dcf0")
spark(36, 224) spark(76, 226, true) spark(66, 220)
-- workbench with tools (vise, saw, mallet)
shadowE(98, 252, 26, 4)
for _, lx in ipairs{ 78, 114 } do local l = rect(lx, 234, lx + 3, 252) fill(l, WOOD, { band = 1 }) end
local bt = poly{ { 74, 228 }, { 120, 228 }, { 122, 234 }, { 72, 234 } } fill(bt, CRATE, { band = 1, tex = planks(9, CRATE, 7) })
local shelf = rect(78, 244, 117, 246) fill(shelf, WOOD, { band = 1 })
local vise = poly{ { 78, 228 }, { 78, 220 }, { 86, 220 }, { 86, 228 } } fill(vise, IRON, { band = 1 }) c:fillMask(rect(76, 223, 88, 224), IRON[4])
local saw = poly{ { 92, 227 }, { 112, 222 }, { 112, 226 }, { 92, 228 } } fill(saw, { IRON[1], IRON[2], "#b8c0d6", "#dce2f0" }, { band = 1 })
c:fillMask(rect(112, 220, 116, 227), RED[3]) c:rim(rect(112, 220, 116, 227), INK)
local pot = rect(100, 238, 108, 243) fill(pot, TEAL, { band = 1 })                                 -- bucket of bolts
for x = 101, 107, 2 do P(x, 237, IRON[4]) end
-- crooked lean-to with crates (quirk: wind-up key in the top crate, boot planter)
shadowE(148, 228, 24, 4)
local post1 = poly{ { 128, 226 }, { 126, 190 }, { 129, 190 }, { 131, 226 } } fill(post1, LOG, { band = 1 })
local post2 = poly{ { 164, 226 }, { 166, 186 }, { 169, 186 }, { 167, 226 } } fill(post2, LOG, { band = 1 })
local cr1 = rect(132, 208, 150, 226) fill(cr1, CRATE, { tex = function(x, y, col) if (x - y) % 18 == 0 or y == 217 then return CRATE[2] end end })
local cr2 = rect(152, 212, 164, 226) fill(cr2, { "#3c3a2a", "#6a6a3a", "#909a4e", "#b8c070" }, { tex = function(x, y, col) if y == 219 then return "#6a6a3a" end end })
local cr3 = rect(136, 194, 150, 207) fill(cr3, CRATE, { tex = function(x, y, col) if (x + y) % 14 == 0 then return CRATE[2] end end })
local key = c:line({ { 143, 194 }, { 143, 188 } }, 1) c:fillMask(key, BRASS[1])
local kb1 = rect(138, 184, 142, 188) fill(kb1, BRASS, { band = 1 }) local kb2 = rect(144, 184, 148, 188) fill(kb2, BRASS, { band = 1 })
local cogL = gear(158, 205, 6, 4, 7, 0.3) fill(cogL, IRON, { band = 1 }) P(158, 205, IRON[1])
local lr = poly{ { 120, 192 }, { 170, 182 }, { 172, 187 }, { 122, 198 } } fill(lr, { "#3a3a4e", "#5a5e7a", "#7a82a0", "#a2aac4" }, { band = 2, tex = function(x, y, col) if x % 7 == 0 then return "#5a5e7a" end end })
local boot = poly{ { 152, 211 }, { 153, 204 }, { 157, 204 }, { 157, 208 }, { 162, 209 }, { 162, 211 } }
-- boot planter sits on crate cr2 lid
boot = boot:shift(0, 0) fill(boot, { "#3a2420", "#6a4030", "#8e5a3c", "#b07a52" }, { band = 1 })
P(154, 202, "#e86a7a") P(156, 201, "#f2c04a") P(155, 203, "#5f8a40") P(153, 203, "#5f8a40")

------------------------------------------------------------------ FRAME (timber gate: posts, beam, lantern, gear charm, tool bunting)
local function timber(m, horiz)
  fill(m, WOOD, { band = 3, rim = INK, tex = function(x, y, col)
    local g = horiz and y or x
    if col == WOOD[3] and (g % 5 == 0) and hash(horiz and x // 6 or y // 6, g, 71) < 0.6 then return WOOD[2] end
    if col == WOOD[3] and hash(x, y, 72) < 0.03 then return WOOD[4] end
  end })
end
-- tool bunting
local cord = {}
for x = 14, 466 do cord[#cord + 1] = { x, R(14 + 12 * math.sin((x - 14) / 452 * math.pi)) } end
for _, p in ipairs(cord) do P(p[1], p[2], "#5a3a2a") end
local tagCols = { BRASS, { "#5a2a1e", "#9a4a2a", "#c87040", "#eaa070" }, IRON }
local i = 0
for x = 30, 450, 20 do
  i = i + 1
  local y = R(14 + 12 * math.sin((x - 14) / 452 * math.pi)) + 1
  local rmp = tagCols[(i % 3) + 1]
  local m
  if i % 2 == 0 then m = gear(x, y + 5, 4, 3, 5, 0.1)
  else m = poly{ { x - 1, y }, { x + 1, y }, { x + 1, y + 6 }, { x + 3, y + 7 }, { x + 2, y + 10 }, { x, y + 8 }, { x - 2, y + 10 }, { x - 3, y + 7 }, { x - 1, y + 6 } } end
  fill(m, rmp, { band = 1, rim = INK })
end
local lpost = rect(0, 0, 12, 269) timber(lpost)
local rpost = rect(467, 0, 479, 269) timber(rpost)
local beam = rect(0, 0, 479, 11) timber(beam, true)
for _, b in ipairs{ { 13, 12, 13, 30, 31, 12 }, { 466, 12, 466, 30, 448, 12 } } do
  local m = poly{ { b[1], b[2] }, { b[3], b[4] }, { b[5], b[6] } } timber(m)
end
for _, rx in ipairs{ 6, 473 } do for y = 20, 260, 40 do local m = rect(rx - 3, y, rx + 3, y + 4) fill(m, IRON, { band = 1 }) P(rx, y + 2, IRON[4]) end end
for x = 20, 460, 40 do P(x, 5, IRON[4]) P(x + 1, 5, IRON[3]) P(x, 6, IRON[2]) end
-- hanging lantern (left)
for y = 12, 22 do P(52, y, IRON[1]) end
local lt = rect(46, 26, 58, 40) fill(lt, IRON, { band = 1 })
c:fillMask(rect(48, 28, 56, 38), GLOW) c:fillMask(rect(48, 28, 50, 31), GLOWH) c:fillMask(rect(48, 37, 56, 38), GLOWD)
for y = 28, 38 do P(52, y, IRON[2]) end
local ltop = poly{ { 44, 26 }, { 48, 22 }, { 56, 22 }, { 60, 26 } } fill(ltop, IRON, { band = 1 })
local lbot = rect(48, 41, 56, 42) fill(lbot, IRON, { band = 1 })
-- gear charm (right)
for y = 12, 26 do P(428, y, IRON[1]) end
local gc = gear(428, 36, 10, 7, 8, 0.15) fill(gc, BRASS, { band = 2, rim = INK })
c:fillMask(rect(426, 34, 430, 38), BRASS[1]) c:fillMask(rect(427, 35, 429, 37), "#8a6a9a")

------------------------------------------------------------------ FINISH + LAYOUT
c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

local spots = {
  { k = "do", name = "Tinker's Workshop", box = { 14, 132, 172, 256 } },
  { k = "homes", name = "Tinker Cottages", box = { 18, 70, 156, 130 } },
  { k = "stop", name = "Stamp Post", box = { 278, 90, 360, 150 } },
  { k = "people", name = "Fireside Table", box = { 294, 168, 408, 230 } },
  { k = "wild", name = "Wild Trail", box = { 398, 86, 466, 164 } },
}
local stand = { { 200, 250 }, { 282, 250 }, { 240, 214 }, { 210, 172 }, { 268, 176 }, { 240, 140 } }
local parts = {}
for _, s in ipairs(spots) do
  local b = s.box
  parts[#parts + 1] = string.format('{"k":"%s","name":"%s","x":%d,"y":%d,"box":[%d,%d,%d,%d]}', s.k, s.name, (b[1] + b[3]) // 2, (b[2] + b[4]) // 2, b[1], b[2], b[3], b[4])
end
local st = {}
for _, p in ipairs(stand) do st[#st + 1] = string.format('{"x":%d,"y":%d}', p[1], p[2]) end
local f = io.open(OUT .. NAME .. ".layout.json", "w")
f:write(string.format('{"w":480,"h":270,"horizon":%d,"view":"gate","spots":[%s],"stand":[%s],"compass_clear":[380,230,480,270]}\n', HZ, table.concat(parts, ","), table.concat(st, ",")))
f:close()
print("ok " .. NAME)
