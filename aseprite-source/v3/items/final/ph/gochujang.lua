-- gochujang (final, Opus aB35 single pass). A slim onggi crock: surface-of-revolution lighting on a dark glossy
-- brown glaze (vertical specular streak, throwing grooves with lit lips, a pale finger-swiped orchid stroke), a
-- shallow lid knocked askew so a wedge of glossy red chili paste shows in the mouth, AO under the lid and the rope.
-- Straw geumjul rope with twist round the neck. Ground shadow.
-- quirk: two dried red chillies are tucked into the straw rope, the way crocks are hung for luck.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB35_0.lua")
local HP, X, K, norm = A.HP, A.X, A.K, A.norm
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local c = A.new("gochujang")
local POT   = { "#24121a", "#3e1e20", "#5e3024", "#83462c", "#a8663a", "#d6965a" }
local LID   = { "#2a141c", "#462422", "#683828", "#8c5232", "#b27442", "#dca868" }
local PASTE = { "#5e1024", "#94182a", "#c4262e", "#e84a3a", "#ff7a5a", "#ffb89a" }
local STRAW = { "#6a4a1f", "#a8782e", "#d9a84a", "#f5d27a" }
local CHILI = { "#5e1024", "#a81c2c", "#e03a32", "#ff7a5a" }
local CX, TOP, BOT = 32, 18, 53

local function R(y) -- body radius profile
  if y < 21 then return 7.5 end
  local t = (y - 21) / (BOT - 21)
  if t < 0.45 then return 7.5 + 6 * sin(t / 0.45 * pi / 2) end
  return 13.5 - 4 * ((t - 0.45) / 0.55) ^ 2
end
c:groundShadow(CX, BOT + 1, 12, 2)
local body = HP.mask()
for y = TOP, BOT do local r = R(y) for x = floor(CX - r - 1), floor(CX + r + 1) do
  if abs(x + 0.5 - (CX + 0.5)) <= r + 0.3 then body:set(x, y) end end end
local bn, bias = {}, {}
body:each(function(x, y)
  local r = R(y)
  local sx = max(-0.97, min(0.97, (x - CX) / (r + 0.5)))
  local dr = (R(y + 1) - R(y - 1)) / 2
  bn[K(x, y)] = { norm(sx, -dr * 0.6, sqrt(1 - sx * sx)) }
  if y <= TOP + 3 then bias[K(x, y)] = -1 end   -- under the lid / rope
  if y >= BOT - 1 then bias[K(x, y)] = -1 end
end)
local ptok = { r = { name = "pot" } }
local idx = A.shade(c, body, bn, POT, { tok = ptok, bias = bias, amb = 0.05, wrap = 0.15, cuts = { 0.3, 0.5, 0.66, 0.82, 0.94 } })
-- throwing grooves with a lit lip above
for _, gy in ipairs{ 38, 45 } do
  body:each(function(x, y) if y == gy and (x + gy) % 4 ~= 0 then A.step(c, idx, POT, x, y, -1, ptok) elseif y == gy - 1 then A.step(c, idx, POT, x, y, 1, ptok) end end)
end
-- finger-swiped orchid: two pale curved strokes on the belly
for _, p in ipairs{ { 30, 34 }, { 31, 33 }, { 32, 33 }, { 33, 32 }, { 34, 32 }, { 31, 35 }, { 32, 36 }, { 33, 36 }, { 34, 37 }, { 36, 31 } } do
  A.step(c, idx, POT, p[1], p[2], 1, ptok) end
-- glaze specular streak on the lit shoulder
for y = 27, 35 do local x = floor(CX - R(y) * 0.55 + 0.5) c:put(x, y, y >= 29 and y <= 32 and "#fff4d6" or POT[6], ptok) end
c:put(CX - 6, 44, POT[6], ptok) c:put(CX - 6, 45, POT[6], ptok)
-- mouth: neck rim + red paste
local mouth = HP.ellipse(CX, TOP, 7.5, 2.5)
local mtok = { r = { name = "paste" } }
local mn = X.pillow(mouth, 2)
for k, n in pairs(mn) do mn[k] = { norm(n[1], n[2] - 0.6, n[3]) } end
A.shade(c, mouth, mn, PASTE, { tok = mtok, amb = 0.2 })
mouth:edge():each(function(x, y) if y > TOP then c:put(x, y, POT[4], ptok) end end)
-- lid knocked askew (up-left, tilted), covering the left part of the mouth
local lid, ln = A.oval(CX - 6, TOP - 3, 7.5, 3, -0.3, 0.8)
local knob, kn = A.oval(CX - 7, TOP - 6, 2.5, 1.6, -0.3)
local ltok = { r = { name = "lid" } }
-- contact shadow from the lid onto the paste
lid:shift(2, 2):each(function(x, y) if mouth:has(x, y) and not lid:has(x, y) then c:put(x, y, PASTE[2], mtok) end end)
local lidx = A.shade(c, lid, ln, LID, { tok = ltok, amb = 0.1 })
lid:each(function(x, y) if not lid:has(x, y + 1) or not lid:has(x + 1, y + 1) then A.step(c, lidx, LID, x, y, -1, ltok) end end)
A.shade(c, knob, kn, LID, { tok = { r = { name = "knob" } }, amb = 0.15 })
c:put(CX - 8, TOP - 7, LID[6])
-- paste glint + a dab on the mouth lip
c:put(CX + 2, TOP - 1, "#fff4d6") c:put(CX + 3, TOP - 1, PASTE[6])
-- straw rope round the neck (2 px twisted)
local rope = HP.mask()
for x = CX - 8, CX + 8 do local dx = (x - CX) / 8.5 local yy = TOP + 4 + floor(1.6 * sqrt(max(0, 1 - dx * dx)) + 0.5)
  rope:set(x, yy) rope:set(x, yy + 1) end
local rtok = { r = { name = "rope" } }
rope:each(function(x, y) local tw = (x + y) % 3
  c:put(x, y, tw == 0 and STRAW[1] or (tw == 1 and STRAW[3] or STRAW[2]), rtok)
  if x < CX - 3 and tw == 1 then c:put(x, y, STRAW[4], rtok) end end)
body:each(function(x, y) if not rope:has(x, y) and rope:has(x, y - 1) then A.step(c, idx, POT, x, y, -1, ptok) end end)
-- quirk: two dried chillies tucked in the rope, hanging down the shoulder
local function chili(x0, y0, x1, y1, bend)
  local m, n, T, S = A.tube({ { x0, y0 }, { x0 + bend, y0 + 3 }, { x1 + bend, y1 - 2 }, { x1, y1 } }, function(t) return 1.3 * (1 - t) ^ 0.6 + 0.3 end)
  local tok = { r = { name = "chili" } }
  local i = A.shade(c, m, n, CHILI, { tok = tok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.1 })
  m:each(function(x, y) local k = K(x, y) if T[k] > 0.2 and T[k] < 0.7 and S[k] < -0.3 and (x + y) % 3 == 0 then c:put(x, y, CHILI[4], tok) end end)
  c:put(x0, y0 - 1, "#3f6a36", tok) c:put(x0 + 1, y0 - 1, "#6a9a42", tok) c:put(x0, y0 - 2, "#3f6a36", tok)
  return m
end
chili(CX + 3, TOP + 7, CX + 6, TOP + 15, 1.5)
chili(CX + 7, TOP + 6, CX + 11, TOP + 13, 1)
A.save(c, "gochujang")
