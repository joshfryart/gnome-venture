-- ico-puzzle (Opus single pass). One chunky jigsaw EDGE piece (flat bottom): knobs top and right, a socket left.
-- Seen from slightly above, so the 3 px cardboard thickness shows on the lower-right edges and inside the socket.
-- Material: glossy printed face with a bevelled, pillow-lit rim (6-tone per print colour), a coating sheen
-- streak; cardboard core in a 6-tone tan with fibre flecks and a pale cut edge; AO under the knob necks.
-- The print shows a fragment of the puzzle's picture (sky, sun, rolling hill).
-- quirk: a tiny red gnome hat pokes up over the hill on the print.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA8_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, sin = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin
local c = A.new("ico-puzzle")
local SKY   = { "#2a3e78", "#33599e", "#3f7cc4", "#5aa2e0", "#8cc8f2", "#c6e8fb" }
local GRASS = { "#1a4a3a", "#256a42", "#348a46", "#52ab4e", "#84ca5e", "#bfe484" }
local SUN   = { "#8f4a1f", "#d0801e", "#f0a828", "#fbc83c", "#ffe27a", "#fff3b8" }
local CARD  = { "#4a2c2a", "#6e4434", "#93633f", "#b5844e", "#d2a76a", "#ecca92" }
local HAT   = { "#5a1830", "#a82a3a", "#e0443c", "#ff7a58" }

-- face mask
local face = c:rrect(15, 18, 43, 46, 2)
face:add(c:ellipse(29, 12.5, 5, 5)):add(c:rect(27, 15, 31, 19))         -- top knob + neck
face:add(c:ellipse(48.5, 31.5, 5, 5)):add(c:rect(42, 29, 45, 34))       -- right knob + neck
face:cut(c:ellipse(19, 31.5, 4.5, 4.5)):cut(c:rect(15, 29, 16, 34))     -- left socket
-- cardboard side: extrusion toward lower-right
local side = HP.mask()
for _, d in ipairs{ { 1, 1 }, { 1, 2 }, { 2, 2 }, { 2, 3 } } do side:add(face:shift(d[1], d[2])) end
side:cut(face)
local ctok = { r = { name = "card" } }
side:each(function(x, y)
  -- depth into the side: 1 = just under the face (pale cut edge), 3 = bottom
  local dep = 3
  if face:has(x - 1, y - 1) or face:has(x, y - 1) or face:has(x - 1, y) then dep = 1
  elseif face:has(x - 1, y - 2) or face:has(x - 2, y - 2) or face:has(x, y - 2) then dep = 2 end
  local i = ({ 5, 3, 2 })[dep]
  if not face:has(x, y - 1) and not face:has(x, y - 2) and not face:has(x, y - 3) then i = i + 1 end  -- right-facing walls catch more light
  if X.hash(x, y, 5) < 0.18 then i = i - 1 end                                                   -- fibre flecks
  c:put(x, y, CARD[max(1, min(6, i))], ctok)
end)

-- print regions
local function hill(x) return 33 + 3.2 * sin((x - 14) * 0.17) end
local n = X.pillow(face, 3.2)
local v = X.light(n, { amb = 0.1, wrap = 0.3 })
local bias = {}
-- AO in the knob necks
face:each(function(x, y)
  if (y >= 15 and y <= 18 and x >= 27 and x <= 31) or (x >= 42 and x <= 44 and y >= 29 and y <= 34) then
    bias[K(x, y)] = -1 end end)
local sky, grass, sun = HP.mask(), HP.mask(), HP.mask()
local sunM = c:ellipse(23, 23, 3.5, 3.5)
face:each(function(x, y)
  if sunM:has(x, y) then sun:set(x, y) elseif y < hill(x) then sky:set(x, y) else grass:set(x, y) end end)
local ptok = { r = { name = "print" } }
local cuts = { 0.22, 0.38, 0.54, 0.7, 0.86 }
-- print colours sit in the middle of each ramp; the bevel walks them up/down
local function base(m, R, lift)
  local vv = {}
  for k, val in pairs(v) do vv[k] = max(0, min(1, val + (lift or 0))) end
  return X.tone(c, m, vv, R, { cuts = cuts, bias = bias, tok = ptok })
end
local si = base(sky, SKY, -0.19)
local gi = base(grass, GRASS, -0.02)
base(sun, SUN, 0.2)
-- hill rim: a lit lip along the horizon
grass:each(function(x, y) if sky:has(x, y - 1) or sun:has(x, y - 1) then c:put(x, y, GRASS[6], ptok) end end)
-- a far darker hill line + grass tufts on the print
for x = 17, 41, 6 do local y = floor(hill(x) + 5) if grass:has(x, y) and grass:has(x + 1, y - 1) then
  c:put(x, y, GRASS[3], ptok) c:put(x + 1, y - 1, GRASS[3], ptok) c:put(x + 2, y, GRASS[3], ptok) end end
-- sun rays (short, 1 px) on the sky
for _, p in ipairs{ { 23, 18 }, { 18, 23 }, { 27, 19 }, { 19, 19 }, { 28, 23 } } do
  if sky:has(p[1], p[2]) then c:put(p[1], p[2], SUN[5], ptok) end end
-- quirk: gnome hat peeking over the hill (right half)
local hx = 36
local hy = floor(hill(hx))
A.paintMap(c, { "..h..", "..H..", ".hHd.", ".HHd.", "hHHdd" }, hx - 2, hy - 4, { h = HAT[4], H = HAT[3], d = HAT[2] }, ptok)
-- glossy coating sheen: a diagonal streak upper-left of the face + one glint
for _, p in ipairs{ { 17, 21 }, { 18, 20 }, { 19, 20 }, { 17, 22 } } do
  if face:has(p[1], p[2]) then c:put(p[1], p[2], SKY[6], ptok) end end
c:put(26, 9, A.SPEC, ptok) c:put(27, 9, A.SPEC, ptok)
-- face/side seam: deep line where the face meets its own cardboard edge on the far right/bottom rim
face:each(function(x, y)
  if side:has(x + 1, y + 1) and side:has(x, y + 1) and not face:has(x, y + 1) then
    local col = grass:has(x, y) and GRASS[2] or SKY[2]
    c:put(x, y, col, ptok) end end)
A.save(c)
