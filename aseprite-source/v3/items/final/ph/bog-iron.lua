-- bog-iron (Opus single pass, aR21_2). A knobbly nodule of bog ore: rust-orange limonite crust, lumpy knobs,
-- porous pits, ochre speckle; the right end is broken off to show a dark violet-grey iron face with a bright
-- bevelled edge, a specular streak and a vug hole. AO crack where crust meets the fracture.
-- quirk: a tiny tuft of sphagnum moss still clings to the top knob.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR21_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min = math.floor, math.max, math.min
local c = A.new2("bog-iron")
local RUST  = { "#4a1f24", "#7a2f24", "#a8471f", "#cf6b28", "#ec9442", "#ffc77a" }
local STEEL = { "#231d30", "#383149", "#514b68", "#716e8c", "#9c9bb6", "#dcdcec" }
local OCHRE, PIT = "#f0c25a", "#33171d"

local m = HP.mask()
for _, e in ipairs{ {31, 35, 15, 9.5, 0.2}, {20, 37, 8, 7, -0.3}, {41, 31, 9, 7.5, 0.4}, {29, 27, 7, 5.5, 0},
                    {38, 41, 8, 5, 0}, {17, 32, 5, 4, 0}, {48, 36, 6.5, 7.5, 0} } do
  local ca, sa = math.cos(e[5]), math.sin(e[5])
  m:add(A.rell(e[1], e[2], ca, sa, e[3], e[4]))
end
-- fracture face: right end broken flat
local face = HP.poly({ {45, 24}, {56, 31}, {55, 43}, {47, 46}, {42, 37} }):clip(m)
local crust = m:copy():cut(face)
local knobs = {}
for i = 1, 26 do
  local x, y = 12 + floor(X.hash(i, 3) * 40), 22 + floor(X.hash(i, 7) * 26)
  if crust:has(x, y) then knobs[#knobs + 1] = { x, y, 2.2 + X.hash(i, 9) * 1.6, 1.3 } end
end
local pits = { {24, 33}, {33, 30}, {19, 40}, {30, 40}, {38, 36}, {26, 44}, {36, 26}, {14, 35} }
for _, p in ipairs(pits) do knobs[#knobs + 1] = { p[1], p[2], 1.8, -1.8 } end
local n = A.hnorm(crust, 4, A.bumps(knobs))
local v = X.light(n, { amb = 0.07, wrap = 0.22 })
local bias = {}
A.ring(face):each(function(x, y) if crust:has(x, y) then bias[K(x, y)] = -1 end end)
crust:each(function(x, y) local k = K(x, y)
  if y > 43 then bias[k] = (bias[k] or 0) - 1 end end)
local tok = { r = { name = "rust" } }
local idx = X.tone(c, crust, v, RUST, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = bias, tok = tok })
-- crust speckle: ochre limonite in the light, dark specks in the shade
crust:each(function(x, y) local k = K(x, y) local h = X.hash(x, y, 5)
  if h > 0.9 and idx[k] >= 4 and idx[k] <= 5 then c:put(x, y, OCHRE, tok)
  elseif h < 0.07 and idx[k] >= 3 then c:put(x, y, RUST[idx[k] - 2], tok) end end)
-- pit eyes
for _, p in ipairs(pits) do c:put(p[1], p[2], PIT, tok) c:put(p[1] + 1, p[2] + 1, RUST[min(6, (idx[K(p[1] + 1, p[2] + 1)] or 3) + 1)], tok) end
-- matte glint on the highest knob
local gx, gy = A.specAt(crust, n, 30) c:put(gx, gy, RUST[6], tok) c:put(gx + 1, gy, RUST[6], tok)

-- iron face: near-flat plane tilted up-left a bit, noise + a diagonal specular streak
local ftok = { r = { name = "iron" } }
local fv = {}
face:each(function(x, y) local k = K(x, y)
  local val = 0.5 + (X.hash(x, y, 11) - 0.5) * 0.16 - (x - 44) * 0.012 - (y - 30) * 0.008
  local d = (x + y) - 78
  if d >= 0 and d <= 1 then val = val + 0.3 elseif d == 2 then val = val + 0.12 end
  fv[k] = val end)
local fidx = X.tone(c, face, fv, STEEL, { cuts = { 0.15, 0.3, 0.45, 0.62, 0.8 }, tok = ftok })
-- bevel: bright edge where the face meets crust on its upper-left, dark lip on its lower side
face:each(function(x, y)
  if crust:has(x - 1, y) or crust:has(x, y - 1) then c:put(x, y, STEEL[6], ftok)
  elseif crust:has(x, y + 1) or crust:has(x + 1, y) then c:put(x, y, STEEL[2], ftok) end end)
-- vug hole
for _, q in ipairs{ {50, 39}, {51, 39}, {50, 40} } do c:put(q[1], q[2], STEEL[1], ftok) end
c:put(51, 40, STEEL[3], ftok)
c:put(49, 33, "#f4f2ff", ftok)

-- quirk: sphagnum tuft on the top knob
local MOSS = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local tuft = {
  ".a.c..",
  "cbaba.",
  "bbabb.",
  ".dbbd.",
}
local MC = { a = MOSS[4], b = MOSS[2], c = MOSS[3], d = MOSS[1] }
for yy, row in ipairs(tuft) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if MC[ch] then c:put(26 + xx, 18 + yy, MC[ch], { r = { name = "moss" } }) end end end
A.save2(c, "bog-iron")
