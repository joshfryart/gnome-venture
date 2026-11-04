-- salak (final, artist D14_0). Snake fruit: a slim, tilted teardrop that tapers to a dried-calyx stalk at the top,
-- armoured in rhombic scales (lit upper-left lip, dark grout, lower-right shadow lip, paler tan scales near the tip).
-- A long wedge of skin has been peeled away from the right side: it shows one cream garlic-clove lobe with a seam
-- and a polished brown seed in its lower end, the cut skin edge has thickness, and cool bounce lights the shade rim.
-- quirk: the peeled strip is still hanging off the fruit as a loose scaly ribbon curl, cream on the inside.
local NAME = "salak"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD14_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local SK   = { "#22101c", "#40202a", "#642f2c", "#8a4631", "#b06838", "#dc9648" }
local CR   = { "#8c7660", "#c1a986", "#e3cfa4", "#f4e6bf", "#fff4d2", "#fffbe8" }
local SEED = { "#2a1614", "#4a2a1e", "#6a3e26", "#8a5a34", "#b07a46", "#e0b074" }
local STUB = { "#3a2220", "#5e3a2c", "#8a5c3a", "#b88450" }

-- body --------------------------------------------------------------------------------------
local TX, TY, L = 43, 10, 45
local DX, DY = -0.34, 0.94
local PX, PY = 0.94, 0.34
local body = HP.mask()
for y = 4, 60 do for x = 4, 60 do
  local dx, dy = x - TX, y - TY
  local a = dx * DX + dy * DY
  local s = dx * PX + dy * PY
  local t = a / L
  if t >= 0 and t <= 1 then
    local w
    if t < 0.5 then w = 0.6 + 11.4 * (t / 0.5) ^ 1.0 else w = 12 * sqrt(max(0, 1 - ((t - 0.5) / 0.5) ^ 2)) end
    if abs(s) <= w then body:set(x, y) end
  end
end end

-- peel window: one lobed wedge on the right flank
local win = G.rell(33.6, 35, DX, DY, 8.6, 3.9):clip(body)
local skin = body:copy():cut(win)

-- scale lattice bias
local bias = {}
body:each(function(x, y) local k = K(x, y)
  local lu, lv = (x + y) % 5, (x - y) % 5
  local b = 0
  if lu == 0 or lv == 0 then b = -2
  elseif lu == 1 then b = 1
  elseif lu == 4 then b = -1
  elseif lv == 1 then b = -1 end
  local a = (x - TX) * DX + (y - TY) * DY
  if a < 10 then b = b + 1 end
  bias[k] = b
end)
-- shadow of the cut skin edge is handled on the flesh; AO where the ribbon will join
local n = X.pillow(body, 9, 1)
local btok = { r = { name = "body" } }
local idx = X.tone(c, body, X.light(n, { amb = 0.1, wrap = 0.3 }), SK, { cuts = { 0.3, 0.46, 0.62, 0.78, 0.92 }, bias = bias, tok = btok })
-- scale centre glints (one small lit dot per scale on the lit half)
body:each(function(x, y) local lu, lv = (x + y) % 5, (x - y) % 5
  if lu == 2 and lv == 3 and (idx[K(x, y)] or 0) >= 4 then c:put(x, y, SK[6], btok) end end)
-- cool violet bounce on the lower-right rim
local rim = X.rim(n)
body:edge():each(function(x, y) if (rim[K(x, y)] or 0) > 0.8 and not win:has(x, y) then c:put(x, y, "#7a5a78", btok) end end)

-- flesh ---------------------------------------------------------------------------------------
local fb = {}
G.cast(fb, win, skin, 1, 1, -2) G.cast(fb, win, skin, 2, 2, -1)
local fn = X.pillow(win, 3.2, 1)
local ftok = { r = { name = "flesh" } }
X.tone(c, win, X.light(fn, { amb = 0.2, wrap = 0.4 }), CR, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = fb, tok = ftok })
-- seam groove between the two cloves along the window axis
win:each(function(x, y)
  local s = ((x - 33.6) * PX + (y - 35) * PY)
  local a = ((x - 33.6) * DX + (y - 35) * DY)
  if abs(s - 0.4) < 0.55 and abs(a) < 7.5 then c:put(x, y, CR[2], ftok) end
  if abs(s - 1.4) < 0.5 and abs(a) < 6.5 then c:put(x, y, CR[5], ftok) end
end)
-- seed in the lower end of the lobe
local sm, sn = G.oval(30.6, 40.4, 2.5, 3.3, 0.36, 0.9)
sm:clip(win)
G.toneN(c, sm, sn, SEED, { tok = { r = { name = "seed" } }, cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 }, amb = 0.1, wrap = 0.25 })
sm:edge():each(function(x, y) if x + y > 70 then c:put(x, y, SEED[1]) end end)
c:put(29, 38, "#fff1d6") c:put(30, 38, "#e8c698")
-- skin edge thickness: dark rind line, pale pith line below it
win:grow(1):cut(win):each(function(x, y) if skin:has(x, y) then
  local out = (x - 33.6) * PX + (y - 35) * PY > 0
  c:put(x, y, out and SK[2] or SK[1]) end end)
win:grow(2):cut(win:grow(1)):each(function(x, y) if skin:has(x, y) and x + y < 72 and (x + y) % 2 == 0 then c:put(x, y, SK[3]) end end)

-- stalk with dried calyx scales ------------------------------------------------------------------
local pm, pn = G.tube({ { 43, 11 }, { 44, 8.5 }, { 45, 7 }, { 46.5, 6 } }, function(t) return 1.3 - 0.45 * t end)
G.toneN(c, pm, pn, STUB, { tok = { r = { name = "stub" } }, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
c:put(47, 5, STUB[4]) c:put(48, 5, STUB[3])
for _, q in ipairs{ {42,13,2},{41,14,1},{44,13,3},{45,14,2} } do c:put(q[1], q[2], SK[q[3] + 1]) end

-- quirk: loose peeled ribbon ---------------------------------------------------------------------
local rp = { { 37.4, 29 }, { 44, 23.5 }, { 52, 28 }, { 49.5, 37 } }
local rm, rn, RT, RS = G.tube(rp, function(t) return 2.2 - 0.8 * t end)
local rtok = { r = { name = "ribbon" } }
local rb = {}
rm:each(function(x, y) local k = K(x, y)
  local lu, lv = (x + y) % 5, (x - y) % 5
  local b = 0
  if lu == 0 or lv == 0 then b = -2 elseif lu == 1 then b = 1 elseif lu == 4 then b = -1 end
  rb[k] = b
end)
X.tone(c, rm, X.light(rn, { amb = 0.1, wrap = 0.3 }), SK, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 }, bias = rb, tok = rtok })
-- inner (cream) face on the curled-over end
rm:each(function(x, y) local k = K(x, y)
  if RT[k] > 0.5 then
    local s = RS[k]
    c:put(x, y, s < -0.1 and CR[4] or (s < 0.5 and CR[3] or CR[2]), rtok)
  end end)
-- shadow of the ribbon where it lies over the fruit
rm:shift(1, 1):each(function(x, y) if skin:has(x, y) and not rm:has(x, y) then c:put(x, y, SK[1]) end end)
rm:shift(1, 1):each(function(x, y) if win:has(x, y) and not rm:has(x, y) then c:put(x, y, CR[1]) end end)

-- one waxy glint on the lit shoulder
c:put(25, 29, SK[6]) c:put(26, 29, "#fff0c2") c:put(25, 30, SK[6])
G.save2(c, NAME)
