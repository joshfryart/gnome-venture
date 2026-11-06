-- blackcurrant-jam (aR20_4, Opus single pass). Wide-mouthed glass jar of near-black violet jam with whole berries
-- pressed against the glass, curved cream label with a printed currant sprig and a deckled edge, glass streak and
-- cool rim. The lid is a violet gingham cloth (lit per pixel, fold lines on the skirt, pinked zigzag hem) gathered by
-- twisted twine with a bow; cloth casts a dark row onto the glass. 2-tone ground shadow.
-- quirk: one fresh blackcurrant sits on top of the cloth.
local NAME = "blackcurrant-jam"
local R = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_4.lua")
local HP, X, K = R.HP, R.X, R.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local c = R.new2(NAME)
local JAM = { "#16081a", "#26102c", "#3a1742", "#52215a", "#703274", "#9a5296" }
local GLS = { "#3f5677", "#5d7896", "#86a6bc", "#b0cdd6", "#d6ecec", "#f2fbf6" }
local GD = { "#25173c", "#352356", "#46306e", "#5a4288", "#735aa4" }
local GM = { "#5e5080", "#7e6ea0", "#9e8ebe", "#bcb0d8", "#d8d0ec" }
local GC = { "#9e9098", "#c8bcb4", "#e6dac8", "#f6ecd8", "#fff4d6" }
local TWINE = { "#6e4a30", "#a8824e", "#dcc08a" }
local PAPER = { "#a8906e", "#d6c29c", "#efe2c4", "#fbf1d8" }
local BC = { "#120c1e", "#1c1430", "#2a1e44", "#3c2c5a", "#5a4680", "#8f7db4" }

c:groundShadow(31.5, 55, 15, 1.5)

-- jar body
local jar = c:rrect(19, 27, 44, 54, 3)
local jn = R.vn(jar, 19, 44)
local jtok = { r = { name = "jar" } }
local jv = X.light(jn, { amb = 0.08, wrap = 0.3 })
local jidx = X.tone(c, jar, jv, JAM, { cuts = { 0.24, 0.42, 0.58, 0.74, 0.9 }, tok = jtok })
-- whole berries against the glass
for _, b in ipairs{ { 23, 33 }, { 30, 31 }, { 38, 33 }, { 34, 49 }, { 26, 50 }, { 41, 48 }, { 21, 45 } } do
  local m = c:ellipse(b[1], b[2], 1.5, 1.5)
  m:each(function(x, y) if jar:has(x, y) then
    local d = (x - b[1]) + (y - b[2])
    c:put(x, y, d < -0.5 and JAM[5] or (d > 0.5 and JAM[2] or JAM[4]), jtok) end end)
  c:put(b[1] - 1, b[2] - 1, JAM[6], jtok)
end
-- glass: base, rims, streak
for x = 22, 41 do c:put(x, 54, (x < 30) and GLS[3] or GLS[2], jtok) end
for x = 21, 42 do c:put(x, 53, JAM[1], jtok) end
for y = 29, 52 do c:put(19, y, JAM[4], jtok) c:put(44, y, "#33295a", jtok) end
for y = 31, 51 do if y < 36 or y > 47 then c:put(21, y, y < 40 and "#f0dcf0" or "#c8a6d0", jtok) end end
for y = 31, 34 do c:put(22, y, "#c8a6d0", jtok) end
for y = 49, 51 do c:put(42, y, JAM[5], jtok) end

-- label: curved cream band, deckled lower edge, printed sprig
local lab = c:rect(20, 37, 43, 46)
for x = 20, 43 do if X.hash(x, 3, 6) > 0.6 then lab.s[K(x, 46)] = nil end end
local labn = R.vn(lab, 19, 44)
local latok = { r = { name = "label" } }
X.tone(c, lab, X.light(labn, { amb = 0.15, wrap = 0.35 }), PAPER, { cuts = { 0.3, 0.52, 0.76 }, tok = latok })
for x = 21, 42 do c:put(x, 38, (x % 3 == 2) and PAPER[1] or PAPER[2], latok) end
-- sprig: stalk, three berries, a leaf
for _, q in ipairs{ { 32, 40, "#4a8a4c" }, { 33, 40, "#6ab055" }, { 31, 41, "#3a6a40" }, { 30, 42, "#3a6a40" } } do c:put(q[1], q[2], q[3], latok) end
for _, b in ipairs{ { 28, 43 }, { 31, 44 }, { 34, 43 } } do
  c:put(b[1], b[2], BC[3], latok) c:put(b[1] + 1, b[2], BC[2], latok) c:put(b[1], b[2] + 1, BC[2], latok) c:put(b[1] + 1, b[2] + 1, BC[1], latok)
  c:put(b[1], b[2], BC[5], latok)
end
for _, q in ipairs{ { 32, 42 }, { 30, 43 } } do c:put(q[1], q[2], "#3a6a40", latok) end

-- cloth lid: dome + gathered neck + flared skirt with pinked hem
local cloth = HP.mask()
cloth:add(c:ellipse(31.5, 22, 12.5, 6)) cloth:cut(c:rect(0, 25, 63, 63))
for y = 23, 25 do for x = 20, 43 do cloth:set(x, y) end end
for x = 17, 46 do
  local bot = 30 - abs((x % 4) - 2)
  for y = 26, bot do
    local fl = (y - 25) * 0.75
    if x >= 20 - fl and x <= 43 + fl then cloth:set(x, y) end
  end
end
-- cast shadow of the cloth onto the jar
cloth:shift(1, 1):each(function(x, y) if jar:has(x, y) and not cloth:has(x, y) then c:put(x, y, JAM[1], jtok) end end)
local cn = X.pillow(cloth, 3)
local cv = X.light(cn, { amb = 0.12, wrap = 0.3 })
local cltok = { r = { name = "cloth" } }
local CUT = { 0.24, 0.42, 0.6, 0.78 }
cloth:each(function(x, y) local k = K(x, y)
  local i = 1 for j, t in ipairs(CUT) do if cv[k] >= t then i = j + 1 end end
  -- fold lines on the skirt, AO under the gather
  if y >= 26 and (x % 5 == 1) then i = i - 1 end
  if y == 26 then i = i - 1 end
  i = max(1, min(5, i))
  local a, b = (floor((x + 1) / 3) % 2 == 0), (floor(y / 3) % 2 == 0)
  local ramp = (a and b) and GD or ((a or b) and GM or GC)
  c:put(x, y, ramp[i], cltok)
end)

-- twine round the gather (twist) with a bow on the right
local ttok = { r = { name = "twine" } }
for x = 20, 43 do c:put(x, 24, (x % 2 == 0) and TWINE[3] or TWINE[2], ttok) c:put(x, 25, (x % 2 == 0) and TWINE[1] or TWINE[2], ttok) end
for _, q in ipairs{ { 44, 23, 2 }, { 45, 22, 3 }, { 46, 23, 2 }, { 45, 24, 1 }, { 44, 25, 2 }, { 45, 26, 2 }, { 46, 27, 3 }, { 46, 28, 2 }, { 44, 26, 1 }, { 44, 27, 2 }, { 43, 28, 2 } } do
  c:put(q[1], q[2], TWINE[q[3]], ttok) end

-- quirk: a fresh berry on the cloth, with its stalk and a contact shadow
local btok = { r = { name = "berry" } }
c:put(27, 16, GD[1], cltok) c:put(28, 16, GD[1], cltok) c:put(29, 16, GD[2], cltok)
R.berry(c, 27.5, 13, 2.6, BC, { tok = btok, rim = "#363c6a" })
c:put(29, 10, "#7f8c42", btok) c:put(30, 9, "#5a6530", btok)

R.save2(c, NAME)
