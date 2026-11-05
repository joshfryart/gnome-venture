-- wonder-glowworm-grotto, Hearth Pop v3 PILOT (P7). 480x270 native. Single pass.
-- Gold stitch hem on top and bottom like the live art. Quirk: one glowworm thread ends in a tiny hanging lantern-fruit.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local NAME = app.params.name or "wonder-glowworm-grotto"
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = NAME }
local INK = P.ink
local floor, sin, cos, abs, min, max = math.floor, math.sin, math.cos, math.abs, math.min, math.max
local function E(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry or rx) end
local function R(x0, y0, x1, y1) return c:rect(x0, y0, x1, y1) end
local function fm(m, h) c:fillMask(m, h) return m end
local function px(x, y, h) c:px(x, y, h) end
local function hash(a, b) return ((a * 73856093) ~ (b * 19349663) ~ (a * b * 83492791)) % 1000 end
local function rim(m, h) return c:rim(m, h or INK) end
local ROCK = { hi = "#8a7fc0", base = "#5e5499", shade = "#403a78", deep = "#2a2552" }
local STONE = { hi = "#b4b8d0", base = "#8088a8", shade = "#575f86", deep = "#363c5e" }
local GLOW = "#7ff0e8"; local GLOW2 = "#c6fff4"

local function form(m, Rm, o)
  o = o or {}
  fm(m, Rm.base)
  local lt, sh, dp = {}, {}, {}
  m:each(function(x, y)
    if not m:has(x - 2, y - 2) then lt[#lt + 1] = { x, y } end
    if not m:has(x + 2, y + 2) then sh[#sh + 1] = { x, y } end
    if o.deep and not m:has(x, y + 1) then dp[#dp + 1] = { x, y } end
  end)
  for _, p in ipairs(lt) do px(p[1], p[2], Rm.hi) end
  for _, p in ipairs(sh) do px(p[1], p[2], Rm.shade) end
  for _, p in ipairs(dp) do px(p[1], p[2], Rm.deep) end
  return m
end

---------------------------------------------------------------- far cavern: layered dark bands, hazy depth
c:stripes(0, 269, { "#171a3a", "#1e2250", "#262c64", "#2c3470", "#243468", "#1c2c5c" }, { 3, 3, 3, 3, 3, 2 })
for i = 0, 3 do   -- distant rock ridges (lighter = further)
  local base = 120 + i * 14
  c:terrain(function(x) return base + floor(10 * sin(x / (28 + i * 9) + i * 2.1)) end, ({ "#2e3a78", "#283270", "#222a62", "#1c2354" })[i + 1], 200, 0, 479)
end
fm(R(0, 150, 479, 200), "#1c2c5c")

---------------------------------------------------------------- cave walls (ink rim, near plane)
local lw = c:poly{ { 0, 0 }, { 44, 0 }, { 30, 60 }, { 52, 110 }, { 36, 170 }, { 48, 270 }, { 0, 270 } }
rim(lw, INK); form(lw, ROCK, { deep = true })
local rw = c:poly{ { 479, 0 }, { 440, 0 }, { 452, 70 }, { 430, 130 }, { 446, 190 }, { 432, 270 }, { 479, 270 } }
rim(rw, INK); form(rw, ROCK, { deep = true })
for i = 0, 40 do local x, y = hash(i, 3) % 40, hash(i, 5) % 260; px(x, y, ROCK.hi) end   -- rock speckle
for i = 0, 40 do local x, y = 440 + hash(i, 7) % 38, hash(i, 9) % 260; px(x, y, ROCK.shade) end

---------------------------------------------------------------- ceiling with stalactites
local ceil = c:poly{ { 0, 0 }, { 479, 0 }, { 479, 26 }, { 440, 34 }, { 400, 24 }, { 360, 40 }, { 300, 30 }, { 250, 44 }, { 200, 30 }, { 150, 42 }, { 100, 28 }, { 50, 38 }, { 0, 26 } }
rim(ceil, INK); form(ceil, ROCK, { deep = true })
local function stal(x, y, w, h)
  local m = c:poly{ { x - w, y }, { x + w, y }, { x + 1, y + h }, { x, y + h + 2 }, { x - 1, y + h } }
  rim(m, INK); form(m, ROCK)
  px(x - w + 2, y + 2, ROCK.hi); px(x - w + 3, y + 3, ROCK.hi)
end
for _, s in ipairs{ { 62, 34, 9, 34 }, { 128, 38, 8, 28 }, { 196, 34, 11, 40 }, { 262, 42, 9, 30 }, { 334, 36, 10, 36 }, { 396, 28, 8, 26 }, { 164, 40, 5, 18 }, { 300, 32, 6, 20 } } do stal(s[1], s[2], s[3], s[4]) end

---------------------------------------------------------------- glowworm threads (the wonder)
local function thread(x, len, sway)
  for t = 0, len, 2 do   -- silk
    local y = 34 + t
    px(x + floor(sway * sin(t / 11)), y, "#7f8fd0")
  end
  local n = floor(len / 8)
  for i = 1, n do
    local y = 34 + i * 8
    local gx = x + floor(sway * sin((i * 8) / 11))
    local a = hash(x, i)
    px(gx, y, GLOW); px(gx + 1, y, GLOW); px(gx, y + 1, GLOW); px(gx + 1, y + 1, GLOW2)
    if a % 3 == 0 then px(gx - 2, y, "#3fb8c8"); px(gx + 3, y + 1, "#3fb8c8") end
  end
end
for _, t in ipairs{ { 70, 70, 3 }, { 86, 100, 4 }, { 140, 62, 3 }, { 170, 110, 5 }, { 214, 88, 4 }, { 232, 118, 3 }, { 272, 70, 4 }, { 346, 96, 5 }, { 366, 66, 3 }, { 410, 84, 4 } } do thread(t[1], t[2], t[3]) end
-- quirk: a lantern-fruit on the longest thread
fm(E(234, 163, 4, 5), "#ffe38a"); rim(E(234, 163, 4, 5), INK); fm(E(234, 163, 3, 4), "#ffe38a"); px(233, 161, P.cream); fm(R(233, 157, 234, 158), "#7f8fd0")
-- drifting motes
for i = 0, 36 do local x, y = 60 + hash(i, 13) % 380, 60 + hash(i, 17) % 130; px(x, y, GLOW); if i % 4 == 0 then px(x + 1, y, GLOW2) end end

---------------------------------------------------------------- pool with glow reflections
local pool = E(240, 214, 190, 40)
rim(pool, INK)
fm(pool, "#1f5a86")
fm(E(240, 218, 176, 32), "#2a7ea4"); fm(E(240, 220, 150, 24), "#3aa0b8"); fm(E(240, 222, 100, 14), "#52c4c8")
for i = 0, 70 do   -- ripples and glints
  local x, y = 70 + hash(i, 21) % 340, 190 + hash(i, 23) % 50
  if pool:has(x, y) then px(x, y, GLOW2); px(x + 1, y, GLOW) end
end
for _, x in ipairs{ 90, 170, 220, 290, 340 } do for y = 194, 206, 2 do px(x + floor(2 * sin(y)), y, "#8fe8f0") end end   -- glow column reflections

---------------------------------------------------------------- stepping stones
local function stone(cx, cy, rx, ry)
  local m = E(cx, cy, rx, ry); rim(m, INK); form(m, STONE, { deep = true })
  px(cx - rx + 4, cy - 2, "#dfe2f0"); px(cx - rx + 5, cy - 2, "#dfe2f0")
  fm(E(cx + 3, cy + ry + 2, rx - 4, 2), "#163a5c")
end
for _, s in ipairs{ { 150, 220, 14, 7 }, { 196, 208, 12, 6 }, { 244, 222, 14, 7 }, { 290, 208, 12, 6 }, { 336, 220, 13, 7 } } do stone(s[1], s[2], s[3], s[4]) end

---------------------------------------------------------------- foreground rocks and glow mushrooms
local function fore(cx, cy, rx, ry)
  local m = E(cx, cy, rx, ry); rim(m, INK); form(m, ROCK, { deep = true })
end
fore(30, 248, 34, 18); fore(110, 262, 40, 12); fore(380, 262, 44, 12); fore(444, 246, 32, 20)
local function shroom(x, y, s)
  fm(R(x - 1, y - 6 * s, x + 1, y), "#cfe8f8"); px(x + 1, y - 3 * s, "#98b8d8")
  local cap = E(x, y - 7 * s, 4 * s + 1, 3 * s); rim(cap, INK); fm(cap, "#3fa8d8"); fm(E(x - 1, y - 7 * s - 1, 2 * s, s + 1), "#8fe0f8")
  px(x - 2, y - 7 * s, GLOW2); px(x + 2, y - 7 * s + 1, "#2878b0")
  fm(E(x, y - 7 * s, 6 * s + 2, 4 * s + 1):copy():cut(E(x, y - 7 * s, 4 * s + 1, 3 * s)):clip(R(x - 12 * s, y - 14 * s, x + 12 * s, y)):copy(), "#1f5a86")   -- soft ring
end
shroom(60, 236, 2); shroom(78, 242, 1); shroom(398, 246, 2); shroom(414, 252, 1)

---------------------------------------------------------------- right alcove with a chest
local al = c:poly{ { 408, 150 }, { 420, 130 }, { 440, 130 }, { 452, 150 }, { 452, 188 }, { 408, 188 } }
rim(al, INK); fm(al, "#2a2552"); fm(c:poly{ { 412, 150 }, { 422, 134 }, { 438, 134 }, { 448, 150 }, { 448, 186 }, { 412, 186 } }, "#3a2a50")
local ch = R(418, 160, 442, 184); rim(ch, INK); form(ch, { hi = "#d19a62", base = "#a8704a", shade = "#7a4a34", deep = "#51302b" }, { deep = true })
fm(R(418, 160, 442, 168), "#c08550"); fm(R(429, 168, 431, 173), "#ffe38a"); c:sparkle(430, 154)
fm(R(406, 188, 454, 192), STONE.base); rim(R(406, 188, 454, 192), INK); fm(R(406, 188, 454, 188), STONE.hi)

c:hem(2); c:hem(267)
c:save{ aseprite = d .. "/out/" .. NAME .. ".aseprite", png = d .. "/out/" .. NAME .. ".png", scale = 1 }
