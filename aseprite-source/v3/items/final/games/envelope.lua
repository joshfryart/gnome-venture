-- envelope (final, Opus single pass). The back of a sealed letter: four folded paper flaps (left, right, bottom,
-- pointed top flap) meeting under a red wax seal; a perforated stamp stuck on the top-right corner, struck by a
-- wavy postmark.
-- Material: per-pixel pillow light on each flap with its own tilt (6-tone paper), contact shadow where a flap
-- overlaps the one below + lit lip on the upper flap, paper fibre specks, bevelled edges. Wax: blobby disc with
-- poured lumps, embossed acorn inside a pressed ring, cream specular. Stamp: perforated edge, inked
-- picture, postmark lines that carry on over the paper.
-- quirk: the bottom-left corner is dog-eared, folded up to show the paler inside of the paper.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA0_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, pi, max, min, sqrt, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.abs
local c = A.new("envelope")
local PAP  = { "#8e6a4a", "#b98e64", "#d6b07e", "#e9cc98", "#f6e0b0", "#fff0cc" }
local INS  = { "#9a8a86", "#c0aea0", "#dccab4", "#ecdcc4", "#f8ecd6", "#fff6e4" }
local WAX  = { "#4e1430", "#7c1c38", "#ae2838", "#d63a36", "#f0603e", "#ff9a6a" }
local SEA  = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }
local INKP = "#5a4a78"
local tokP, tokW, tokS = { r = { name = "paper" } }, { r = { name = "wax" } }, { r = { name = "stamp" } }

local X0, Y0, X1, Y1 = 9, 16, 54, 46
local CXc = (X0 + X1) / 2
local body = c:rrect(X0, Y0, X1, Y1, 2)
-- quirk: dog-ear, bottom-left corner folded up
local DE = 8
local ear = c:poly{ {X0 - 1, Y1 - DE}, {X0 - 1, Y1 + 1}, {X0 + DE + 1, Y1 + 1} }
local earZone = HP.mask()
body:each(function(x, y) if (x - X0) + (Y1 - y) < DE then earZone:set(x, y) end end)
body:cut(earZone)
-- flap zones
local topF = c:poly{ {X0, Y0}, {X1, Y0}, {CXc, 36} }:clip(body)
local botF = c:poly{ {X0, Y1}, {27, 33}, {36, 33}, {X1, Y1} }:clip(body):cut(topF)
local leftF = HP.mask() local rightF = HP.mask()
body:each(function(x, y) if not topF:has(x, y) and not botF:has(x, y) then if x < CXc then leftF:set(x, y) else rightF:set(x, y) end end end)
local zones = { { leftF, { -0.35, 0.05 } }, { rightF, { 0.4, 0.05 } }, { botF, { 0.0, 0.28 } }, { topF, { -0.1, -0.3 } } }
local nP = X.pillow(body, 2.2)
local n, bias = {}, {}
for _, z in ipairs(zones) do z[1]:each(function(x, y) local k = K(x, y) local a = nP[k]
  n[k] = { A.norm(a[1] + z[2][1], a[2] + z[2][2], a[3]) } end) end
-- contact shadow: lower flap pixels just below/right of an upper flap
local function shadowUnder(upper, lowerList, d)
  for _, lo in ipairs(lowerList) do lo:each(function(x, y)
    for i = 1, d do if upper:has(x - i, y - i) or upper:has(x, y - i) then local k = K(x, y) bias[k] = min(bias[k] or 0, i == 1 and -2 or -1) break end end
  end) end
end
shadowUnder(topF, { leftF, rightF, botF }, 2)
shadowUnder(botF, { leftF, rightF }, 1)
-- fibre specks
body:each(function(x, y) local h = A.hash(x, y, 11) local k = K(x, y)
  if h < 0.045 then bias[k] = (bias[k] or 0) - 1 elseif h > 0.965 then bias[k] = (bias[k] or 0) + 1 end end)
local idx = A.shade(c, body, n, PAP, { amb = 0.1, wrap = 0.3, bias = bias, tok = tokP, cuts = { 0.2, 0.34, 0.48, 0.62, 0.78 } })
-- lit lip along the top flap's lower edges
topF:edge():each(function(x, y) if (y > Y0 + 1) and body:has(x, y + 1) and not topF:has(x, y + 1) then
  c:put(x, y, PAP[min(6, (idx[K(x, y)] or 4) + 1)], tokP) end end)

-- crease lines: dark fold under the top flap edge, lighter creases of the bottom flap
A.ln(c, X0 + 1, Y0 + 1, CXc - 0.5, 36, PAP[2], body, tokP) A.ln(c, X1 - 1, Y0 + 1, CXc + 0.5, 36, PAP[2], body, tokP)
topF:edge():each(function(x, y) if body:has(x, y + 1) and not topF:has(x, y + 1) and y > Y0 + 1 then c:put(x, y + 1, PAP[2], tokP) end end)
A.ln(c, X0 + DE - 1, Y1 - 1, 27, 33, PAP[3], body, tokP) A.ln(c, X1 - 1, Y1 - 1, 36, 33, PAP[3], body, tokP)
-- dog-ear: folded triangle (inside of the paper) + its contact shadow on the envelope
local fold = HP.mask()
-- reflect earZone across the crease line x - X0 + Y1 - y = DE
earZone:each(function(x, y) local u, v = x - X0, Y1 - y   -- u+v < DE
  local s = DE - (u + v)                                     -- distance to crease along (1,1)
  fold:set(x + s, y - s) end)
-- contact shadow right/below of the fold
fold:each(function(x, y) for _, d in ipairs{ {1, 0}, {1, 1}, {0, 1} } do local xx, yy = x + d[1], y + d[2]
  if body:has(xx, yy) and not fold:has(xx, yy) then c:put(xx, yy, PAP[max(1, (idx[K(xx, yy)] or 4) - 2)], tokP) end end end)
local nF = {}
fold:each(function(x, y) nF[K(x, y)] = { A.norm(-0.25, -0.35, 1) } end)
local fi = X.tone(c, fold, X.light(nF, { amb = 0.1, wrap = 0.3 }), INS, { cuts = { 0.2, 0.34, 0.48, 0.62, 0.78 }, tok = tokP })
-- crease line (lit) and fold shading toward its tip
fold:each(function(x, y) local u, v = x - X0, Y1 - y
  if u + v == DE or u + v == DE + 1 then c:put(x, y, INS[6], tokP) end
  if u + v >= DE + 5 then c:put(x, y, INS[3], tokP) end end)

-- stamp (upper-right), perforated edge
local SX0, SY0, SX1, SY1 = 41, 18, 51, 29
local st = c:rect(SX0, SY0, SX1, SY1)
for x = SX0 + 1, SX1 - 1, 2 do st.s[K(x, SY0)] = nil st.s[K(x, SY1)] = nil end
for y = SY0 + 1, SY1 - 1, 2 do st.s[K(SX0, y)] = nil st.s[K(SX1, y)] = nil end
-- shadow of the stamp on the paper
st:each(function(x, y) if body:has(x + 1, y + 1) and not st:has(x + 1, y + 1) then c:put(x + 1, y + 1, PAP[max(1, (idx[K(x + 1, y + 1)] or 4) - 1)], tokP) end end)
st:each(function(x, y) c:put(x, y, (x >= SX1 - 1 or y >= SY1 - 1) and "#c4bcd6" or ((x == SX0 or y == SY0) and "#fbf6ff" or "#ebe6f4"), tokS) end)
local pic = c:rect(SX0 + 2, SY0 + 2, SX1 - 2, SY1 - 2)
pic:each(function(x, y) c:put(x, y, y < SY0 + 5 and SEA[3] or SEA[2], tokS) end)
c:put(SX0 + 7, SY0 + 3, SEA[4], tokS)
-- tiny red gnome hat on the stamp picture
A.map(c, { "...h...", "..hR...", "..RRr..", ".RRRr..", ".RRRrr.", "bbbbbbb", "ggGgggg", "gGgggGg" }, SX0 + 2, SY0 + 2,
  { h = "#ff8a5c", R = "#e8493b", r = "#b52e3f", b = "#fff4d6", g = "#3f9150", G = "#7cc35a" }, tokS)
-- postmark: two wavy lines from the stamp leftwards over the paper
for i = 0, 1 do
  for x = 33, SX0 + 4 do
    local y = floor(SY0 + 3 + i * 3 + sin((x - 33) * 0.7) * 1.0 + .5)
    if x % 7 ~= 3 and (body:has(x, y) or st:has(x, y)) then c:put(x, y, INKP, tokS) end
  end
end

-- wax seal: blob + lumps + drip, embossed acorn in a pressed ring
local WX, WY = CXc, 36
local wm = c:ellipse(WX, WY, 6, 6):add(c:ellipse(WX - 5.2, WY + 2.4, 1.6, 1.5)):add(c:ellipse(WX + 4.8, WY - 3.4, 1.6, 1.5))
wm:add(c:ellipse(WX + 2.2, WY + 5.4, 2.2, 1.6))
-- contact shadow of the wax on the paper
wm:shift(1, 1):each(function(x, y) if body:has(x, y) and not wm:has(x, y) then c:put(x, y, PAP[max(1, (idx[K(x, y)] or 4) - 2)], tokP) end end)
local wn = A.body(wm, WX - 0.5, WY - 0.5, 7, 2.6, 0.45)
local wb = {}
local ring = HP.mask()
wm:each(function(x, y) local d = sqrt((x - WX)^2 + (y - WY)^2) if d >= 3.6 and d < 4.6 then ring:set(x, y) end end)
local widx = A.shade(c, wm, wn, WAX, { amb = 0.06, wrap = 0.2, tok = tokW })
-- pressed ring: groove (dark) on the upper-left inner side, lit lip lower-right (recessed)
ring:each(function(x, y) local k = K(x, y) local i = widx[k] or 3
  local up = (x - WX) + (y - WY) < 0
  c:put(x, y, up and WAX[1] or WAX[min(6, i + 2)], tokW) end)
-- embossed acorn (raised): lit upper-left, shade lower-right
A.map(c, {
  "..s..",
  ".hhd.",
  "hhhdd",
  "sssss",
  ".lms.",
  "..m..",
}, floor(WX) - 2, floor(WY) - 3, { h = WAX[6], d = WAX[2], l = WAX[6], m = WAX[4], s = WAX[1] }, tokW)
-- specular + glint on the wax
c:put(floor(WX) - 4, floor(WY) - 4, WAX[6], tokW) c:put(floor(WX) - 5, floor(WY) - 3, WAX[6], tokW)
c:put(floor(WX) - 4, floor(WY) - 5, A.CREAM, tokW) c:put(floor(WX) - 3, floor(WY) - 5, WAX[6], tokW)
A.save(c, "envelope")
