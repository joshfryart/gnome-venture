-- papaya (final, aC31_5, Opus single pass; replaces the Sonnet draft). A slim pear-shaped papaya halved lengthwise,
-- lying on the diagonal (stem upper-right, blossom end lower-left), cut face up. Material: the rind wall shows as a
-- lit band along the lower-right (cylinder light, green blushing to yellow-orange, faint ribs, waxy bloom specks, cool
-- reflected light); the cut face has a pale skin line, a golden inner rind ring and juicy 6-tone coral flesh that
-- deepens toward the long seed cavity; the cavity is sunk (AO on the upper-left wall, lit lower-right lip) and packed
-- with glossy black seeds, each in a pale jelly sac with a glint. Stem stub with a dark scar.
-- quirk: one seed has escaped the cavity and sits alone on the flesh near the rim.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local norm = G.norm
local c = G.new2("papaya")

local SKIN  = { "#26402c", "#3c6234", "#5e8a3a", "#93ac40", "#cfc24a", "#f2df7a" }
local BLUSH = { "#6a2a24", "#a2442a", "#d0682e", "#ec9036", "#f8b850", "#ffdc86" }
local FLESH = { "#7a2430", "#ae3a36", "#d65a3c", "#ee7a46", "#f99a5a", "#ffc184" }
local RIND  = "#f6d27a"
local SEED  = { "#1e1424", "#2e2034", "#46344a", "#6a5670", "#c9bfd6" }
local JELLY = "#f6c8a0"
local BOUNCE = "#9c7aa8"

-- outline of the half: tube along a gentle curve, narrow at the stem, wide and round at the blossom end
local P = { { 46, 13 }, { 41, 22 }, { 32, 36 }, { 21, 48 } }
local function hw(t) return 3.4 + 7.0 * sin(min(1, t * 1.25) * pi / 2) ^ 1.6 end
local F, Fn, FT, FS, samp = G.tubeR(P, hw)
-- rind wall: visible below/right of the cut face
local wall = F:shift(1, 2):add(F:shift(0, 1)):add(F:shift(1, 1)):cut(F)
local wn = {}
wall:each(function(x, y)
  local best, bs = 1e9
  for _, s in ipairs(samp) do local q = (x - s.x) ^ 2 + (y - s.y) ^ 2 if q < best then best, bs = q, s end end
  local d = (x - bs.x) * bs.px + (y - bs.y) * bs.py
  wn[K(x, y)] = { norm(bs.px * 0.9, bs.py * 0.9 + 0.2, 0.35) }
  wn[K(x, y)].t = bs.t
end)
local wtok = { r = { name = "rind" } }
local wv = X.light(wn, { amb = 0.18, wrap = 0.5 })
wall:each(function(x, y) local k = K(x, y)
  local t = wn[k].t
  local R = t < 0.42 and SKIN or BLUSH                -- green at the stem, ripe blush toward the blossom end
  local i = 2 for j, cut in ipairs({ 0.2, 0.32, 0.44, 0.56 }) do if wv[k] >= cut then i = j + 2 end end
  if (t > 0.38 and t < 0.46) and X.hash(x, y, 2) > 0.5 then R = SKIN end   -- mottled transition
  if floor(t * 14) % 3 == 0 then i = i - 1 end          -- faint ribs
  if X.hash(x, y, 9) > 0.9 then i = i + 1 end           -- waxy bloom specks
  c:put(x, y, R[max(1, min(6, i))], wtok)
end)
-- cool reflected light on the very bottom edge of the wall
wall:each(function(x, y) if not wall:has(x, y + 1) and not F:has(x, y + 1) and wn[K(x, y)].t > 0.55 and X.hash(x, y, 4) > 0.4 then c:put(x, y, BOUNCE, wtok) end end)

-- cut face: skin line, rind ring, flesh
local ftok = { r = { name = "face" } }
local cav = HP.mask()
F:each(function(x, y) local k = K(x, y) local t, s = FT[k], FS[k]
  if t > 0.26 and t < 0.86 then
    local cw = 0.42 * sin((t - 0.26) / 0.6 * pi) ^ 0.7
    if abs(s + 0.02) < cw then cav:set(x, y) end
  end
end)
local inner = F:shrink(2)
local fb = {}
X.ao(fb, F, cav, 2, -1)
local fnorm = X.pillow(F, 2.5, 0.8)
local fv = X.light(fnorm, { amb = 0.3, wrap = 0.4 })
F:each(function(x, y) local k = K(x, y)
  if cav:has(x, y) then return end
  if not F:shrink(1):has(x, y) then
    c:put(x, y, FT[k] < 0.4 and SKIN[5] or BLUSH[5], ftok)    -- skin line
  elseif not inner:has(x, y) then
    c:put(x, y, RIND, ftok)                                  -- pale golden inner rind
  else
    local i = 5 - (fv[k] < 0.62 and 1 or 0) + (fb[k] or 0)
    if fv[k] > 0.8 and FS[k] < -0.5 then i = 6 end
    if X.hash(x, y, 5) > 0.92 then i = i + 1 end           -- juicy sheen flecks
    c:put(x, y, FLESH[max(1, min(6, i))], ftok)
  end
end)
-- the cavity: sunken, shaded upper-left wall, lit lower-right lip
local ctok = { r = { name = "cavity" } }
cav:each(function(x, y) local k = K(x, y)
  local s = FS[k]
  local i = 2
  if not cav:has(x - 1, y) or not cav:has(x, y - 1) then i = 1 end
  if not cav:has(x + 1, y) or not cav:has(x, y + 1) then i = 3 end
  c:put(x, y, FLESH[i], ctok)
end)
-- seeds packed in the cavity: 2x2 glossy ovals in jelly sacs
local stok = { r = { name = "seeds" } }
local function seed(x, y, sac)
  if sac then c:put(x - 1, y, JELLY, stok) c:put(x, y - 1, JELLY, stok) end
  c:put(x, y, SEED[3], stok) c:put(x + 1, y, SEED[2], stok) c:put(x, y + 1, SEED[2], stok) c:put(x + 1, y + 1, SEED[1], stok)
  c:put(x, y, SEED[5], stok)
end
local placed = {}
for i = 0, 60 do
  local t = 0.3 + i * 0.0095
  local s0 = samp[floor(t * 160) + 1]
  for _, off in ipairs{ -0.2, 0.05, 0.22 } do
    local w = s0.w * off
    local x, y = floor(s0.x + s0.px * w + .5), floor(s0.y + s0.py * w + .5)
    if cav:has(x, y) and cav:has(x + 1, y + 1) then
      local ok = true
      for _, q in ipairs(placed) do if (q[1] - x)^2 + (q[2] - y)^2 < 7.5 then ok = false break end end
      if ok then placed[#placed + 1] = { x, y } end
    end
  end
end
for j, q in ipairs(placed) do seed(q[1], q[2], j % 2 == 0) end

-- stem stub at the narrow end, with dark scar
local tok2 = { r = { name = "stem" } }
G.map(c, {
  ".abb",
  "abcc",
  "dbb.",
}, 46, 9, { a = "#a2b46a", b = "#6e8a44", c = "#3e5a32", d = "#2c3a2a" }, tok2)
c:put(46, 13, SKIN[1], ftok)

-- quirk: one escaped seed on the flesh near the lower-left rim
seed(18, 44, true)

G.save2(c, "papaya")
