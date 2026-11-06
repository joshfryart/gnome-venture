-- ico-wolf (final pass, Opus single pass). Bold icon: a grey wolf's head, front view. Tall slim pointed ears,
-- a dark saddle mask from the crown down to the eyes with pale brow spots, a jagged cheek ruff flaring at the sides,
-- a pale muzzle and chin, ink nose with a cream glint, 2x3 pill eyes with an amber rim.
-- Material: per-pixel round-head light (6-tone cool grey fur, violet shade), fur tufts (jagged ruff spikes with
-- darker strand ticks), AO in the ear roots and under the muzzle where it meets the ruff, dark inner ears.
-- quirk: a daisy is tucked behind the left ear.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/../_helpers/_aR1_1.lua")
local HP, X, K = T.HP, T.X, T.K
local floor, max, min, sqrt, abs, sin, cos, pi = math.floor, math.max, math.min, math.sqrt, math.abs, math.sin, math.cos, math.pi
local c = T.new("ico-wolf")
local FUR  = { "#28283f", "#3e405f", "#5c6084", "#868aa8", "#b0b3c8", "#d8d9e6" }
local MASK = { "#222136", "#33334f", "#4a4b6c", "#6a6c8e", "#8e90ac" }
local MUZ  = { "#6a5e70", "#9a90a0", "#c8c0c4", "#e8e2de", "#fbf4ea" }
local EAR  = { "#4a2a44", "#7d3c5e", "#b06080" }
local AMBER = "#f5b82e"

local CX = 32
-- ears (behind head)
local etok = { r = { name = "ears" } }
local earL = HP.poly{ { 17, 29 }, { 18.5, 7 }, { 30, 22 } }
local earR = HP.poly{ { 47, 29 }, { 45.5, 7 }, { 34, 22 } }
local ears = earL:copy():add(earR)
local eidx = T.pil(c, ears, FUR, 2.2, { amb = 0.08, wrap = 0.22, tok = etok })
-- inner ear: dark cup with a pink lit edge
local inL = HP.poly{ { 20, 25 }, { 19.6, 12 }, { 27, 22 } }
local inR = HP.poly{ { 44, 25 }, { 44.4, 12 }, { 37, 22 } }
inL:add(inR):each(function(x, y) c:put(x, y, EAR[1], etok) end)
inL:each(function(x, y) if not inL:has(x - 1, y) then c:put(x, y, EAR[3], etok) end end)
inR:each(function(x, y) if not inR:has(x + 1, y) and inL:has(x, y) == false and x > 32 then c:put(x, y, EAR[2], etok) end end)

-- head + cheek ruff (one mask), muzzle painted on top
local htok = { r = { name = "head" } }
local head = HP.ellipse(CX, 32, 13.5, 11)
local ruff = HP.poly{ { 19, 28 }, { 14, 37 }, { 18, 37 }, { 15, 43 }, { 20, 42 }, { 19, 47 }, { 25, 45 }, { 28, 50 },
  { 36, 50 }, { 39, 45 }, { 45, 47 }, { 44, 42 }, { 49, 43 }, { 46, 37 }, { 50, 37 }, { 45, 28 } }
head:add(ruff)
local hn = T.blend(X.pillow(head, 4), X.sphere(CX, 34, 15, head), 0.55)
local hbias = {}
-- AO at the ear roots
X.ao(hbias, head, ears:copy():cut(head), 1, -1)
local hidx = T.shade(c, head, hn, FUR, { amb = 0.08, wrap = 0.25, bias = hbias, tok = htok })
-- ruff strand ticks: short darker strokes following the spikes outward
local ticks = { { 18, 38, -1, 1 }, { 19, 43, -1, 1 }, { 23, 45, -1, 1 }, { 46, 38, 1, 1 }, { 45, 43, 1, 1 }, { 41, 45, 1, 1 },
  { 21, 34, -1, 1 }, { 43, 34, 1, 1 } }
for _, t in ipairs(ticks) do
  T.step(c, hidx, FUR, t[1], t[2], -1, htok) T.step(c, hidx, FUR, t[1] + t[3], t[2] - 1, -1, htok)
  T.step(c, hidx, FUR, t[1] - t[3], t[2] + 1, 1, htok)
end

-- dark saddle mask: crown to eyes, a V pointing down the nose bridge
local mtok = { r = { name = "mask" } }
local sad = HP.poly{ { 20, 25 }, { 24, 22 }, { 32, 21 }, { 40, 22 }, { 44, 25 }, { 42, 31 }, { 36, 31 }, { 32, 36 }, { 28, 31 }, { 22, 31 } }
sad:clip(head)
local sn = T.blend(X.pillow(sad, 3), X.sphere(CX, 32, 14, sad), 0.6)
local sidx = T.shade(c, sad, sn, MASK, { amb = 0.1, wrap = 0.3, tok = mtok })
-- fur parting on the crown
c:put(31, 23, MASK[2], mtok) c:put(32, 24, MASK[2], mtok) c:put(33, 23, MASK[2], mtok)

-- muzzle + chin (pale), with soft shade bottom-right
local ztok = { r = { name = "muzzle" } }
local muz = HP.ellipse(CX, 41, 6.2, 5.2):add(HP.poly{ { 29, 33 }, { 35, 33 }, { 37, 38 }, { 27, 38 } })
local zn = T.blend(X.pillow(muz, 2.5), X.sphere(CX, 40, 7, muz), 0.6)
local zbias = {}
muz:each(function(x, y) if y >= 46 then zbias[K(x, y)] = -1 end end) -- AO under the jaw where the ruff meets it
local zidx = T.shade(c, muz, zn, MUZ, { amb = 0.12, wrap = 0.3, bias = zbias, tok = ztok })
-- cheek pads (pale) either side of the muzzle
for _, p in ipairs{ { 24, 35 }, { 25, 36 }, { 24, 36 }, { 40, 35 }, { 39, 36 }, { 40, 36 } } do c:put(p[1], p[2], MUZ[3], ztok) end

-- nose: rounded ink with a cream glint, dark philtrum, mouth
local ntok = { r = { name = "nose" } }
T.map(c, {
  ".kkkkk.",
  "kckkkkk",
  "kkkkkkk",
  ".kkdkk.",
  "...d...",
  ".dd.dd.",
}, 29, 37, { k = T.INK, c = T.CREAM, d = "#4a3a4a" }, ntok)
c:put(31, 37, "#5a4a5a", ntok) -- lit top of nose leather
-- pink tongue tip peeking
c:put(32, 43, "#f5809f", ntok) c:put(32, 44, "#c94f84", ntok)

-- eyes: 2x3 pills with amber inner rim, pale brow spots above
c:eyeSmall(26, 29) c:eyeSmall(36, 29)
c:put(28, 30, AMBER) c:put(28, 31, "#d98322") c:put(35, 30, AMBER) c:put(35, 31, "#d98322")
c:put(25, 27, MUZ[4], mtok) c:put(26, 27, MUZ[5], mtok) c:put(37, 27, MUZ[5], mtok) c:put(38, 27, MUZ[4], mtok)

-- quirk: a daisy tucked behind the left ear
local dtok = { r = { name = "daisy" } }
T.map(c, {
  ".pp.",
  "pPgp",
  "pggP",
  ".pp.",
}, 13, 23, { p = "#f2eadc", P = T.CREAM, g = "#f5b82e" }, dtok)
c:put(15, 25, "#d98322", dtok)
c:put(13, 27, "#7cc35a", dtok) c:put(12, 28, "#3f9150", dtok)

c:sparkle(10, 14)
T.save(c, "ico-wolf")
