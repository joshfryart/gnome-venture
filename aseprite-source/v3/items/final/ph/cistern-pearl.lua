-- cistern-pearl (Opus single pass). A lustrous pearl sitting in the shallow water of a small round stone cistern.
-- Cistern: cut-stone wall in two courses of curved blocks (mortar joints bend with the drum, per-block tone shift,
-- chisel pits, pale bevel on each block top), a capstone ring seen from above, the back inner wall in shade and a
-- clear water disc with a ripple ring and a pearl reflection. Pearl: sphere normals, lavender-cream 6-tone ramp,
-- warm pink orient band at the terminator, cool teal bounce, window specular + one sparkle. Ground shadow.
-- quirk: a moss tuft with a curled fern fiddlehead grows out of a mortar joint.
local NAME = "cistern-pearl"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sin, cos, abs, sqrt, asin = math.floor, math.max, math.min, math.sin, math.cos, math.abs, math.sqrt, math.asin
local c = A.new2(NAME)
local ST = { "#34334d", "#4f5068", "#717289", "#9493a8", "#b8b7c8", "#dcdbe5" }
local SEA = { "#1f3c66", "#2a5a8a", "#3a86b0", "#5fbcc4", "#9ee6dc", "#d6fbf0" }
local PE = { "#6a5a88", "#9384b0", "#bcb0d4", "#ded2e6", "#f6ecee", "#fffaf0" }
local CX, RX = 32, 20
local TOP, BOT = 37, 51

c:groundShadow(CX, 55, 21, 1)
-- wall: drum front between rim ellipse (y=TOP) and bottom ellipse (y=BOT), both bulging down by 5*sqrt(1-u^2)
local wall, wn, WU, WY = HP.mask(), {}, {}, {}
for x = CX - RX, CX + RX - 1 do
  local u = (x + 0.5 - CX) / RX
  local bulge = 5 * sqrt(max(0, 1 - u * u))
  for y = floor(TOP + bulge * 0.2), floor(BOT + bulge * 0.8) do
    wall:set(x, y)
    local nz = sqrt(max(0.03, 1 - u * u))
    wn[K(x, y)] = { u, 0.12, nz }
    WU[K(x, y)], WY[K(x, y)] = u, y - bulge * 0.8   -- WY: height in "unrolled" wall coordinates
  end
end
for k, v in pairs(wn) do local l = sqrt(v[1]^2 + v[2]^2 + v[3]^2) wn[k] = { v[1]/l, v[2]/l, v[3]/l } end
-- blocks: course split, joints by angle
local wbias, joint, bevel = {}, {}, {}
wall:each(function(x, y) local k = K(x, y)
  local u, h = WU[k], WY[k]
  local ang = asin(max(-1, min(1, u)))
  local course = (h < 44) and 0 or 1
  local off = course == 0 and 0 or 0.28
  local seg = (ang + 1.6 + off) / 0.56
  local f = seg - floor(seg)
  local yy = floor(h + 0.5)
  if yy == 44 or (f < 0.5 / (0.56 * RX * cos(ang) + 0.01) * 1.6 and abs(u) < 0.93) then joint[k] = true
  elseif yy == 45 or yy == TOP + 1 then bevel[k] = true end
  if floor(seg) % 3 == 1 then wbias[k] = 1 elseif floor(seg) % 3 == 2 and course == 1 then wbias[k] = -1 end
end)
local wtok = { r = { name = "wall" } }
local widx = A.shade(c, wall, wn, ST, { bias = wbias, tok = wtok, rim = "#5c6a8a", rimT = 0.62, cuts = { 0.14, 0.32, 0.5, 0.68, 0.86 } })
wall:each(function(x, y) local k = K(x, y)
  local i = widx[k] or 3
  if joint[k] then c:put(x, y, ST[max(1, i - 2)], wtok)
  elseif bevel[k] and WU[k] < 0.5 then c:put(x, y, ST[min(6, i + 1)], wtok)
  elseif X.hash(x, y, 7) > 0.93 then c:put(x, y, ST[max(1, i - 1)], wtok) end   -- chisel pits
end)
-- foot: darker AO row at the very bottom
for x = CX - RX, CX + RX do for y = BOT, BOT + 6 do if wall:has(x, y) and not wall:has(x, y + 1) then c:put(x, y, ST[1], wtok) end end end

-- capstone ring (top face), inner back wall, water
local function inE(x, y, cy, rx, ry) local dx, dy = (x + 0.5 - CX) / rx, (y + 0.5 - cy) / ry return dx*dx + dy*dy <= 1 end
local cap, inner, water = HP.mask(), HP.mask(), HP.mask()
for y = 26, 46 do for x = CX - RX - 1, CX + RX do
  if inE(x, y, 37, RX + 0.4, 6.2) then cap:set(x, y) end
  if inE(x, y, 36.6, RX - 3.6, 4.2) then inner:set(x, y) end
  if inE(x, y, 37.8, RX - 4.2, 3.2) then water:set(x, y) end
end end
water:clip(inner)
cap:cut(inner)
local ctok = { r = { name = "cap" } }
cap:each(function(x, y)
  local dx = (x + 0.5 - CX) / RX
  local back = y < 37
  local i = back and 5 or 4
  if dx < -0.55 then i = i + 1 elseif dx > 0.55 then i = i - 1 end
  if not back and y >= 41 then i = i - 1 end
  c:put(x, y, ST[max(2, min(6, i))], ctok)
end)
-- capstone joints (radial ticks) on the top face
for _, p in ipairs{ {16, 35}, {16, 36}, {24, 32}, {40, 32}, {48, 36}, {48, 37}, {22, 42}, {42, 42} } do c:put(p[1], p[2], ST[3], ctok) end
-- lit inner edge of the capstone (front lip) catches light
for x = CX - 14, CX + 6 do for y = 39, 44 do if cap:has(x, y) and inner:has(x, y - 1) then c:put(x, y, ST[6], ctok) end end end
local itok = { r = { name = "inner" } }
inner:each(function(x, y) c:put(x, y, (y < 35) and ST[1] or ST[2], itok) end)
local wtk = { r = { name = "water" } }
water:each(function(x, y)
  local dx, dy = (x + 0.5 - CX) / (RX - 4.2), (y + 0.5 - 37.8) / 3.2
  local i = 3
  if dy < -0.4 then i = 2 end
  if dx > 0.5 then i = i - 1 end
  if dx < -0.4 and dy > -0.2 then i = 4 end
  c:put(x, y, SEA[max(1, i)], wtk)
end)

-- pearl: sphere normals sitting in the water
local PC, PY, PR = CX + 1, 29, 8.6
local pm = HP.mask()
for y = 18, 40 do for x = 22, 44 do local dx, dy = x + 0.5 - PC, y + 0.5 - PY if dx*dx + dy*dy <= (PR + 0.3)^2 then pm:set(x, y) end end end
-- cut the bottom where it sinks into water
local sink = HP.mask() pm:each(function(x, y) if y >= 37 then sink:set(x, y) end end) pm:cut(sink)
local pn = X.sphere(PC - 0.5, PY - 0.5, PR, pm)
local ptok = { r = { name = "pearl" } }
local pv = X.light(pn, { amb = 0.12, wrap = 0.45 })
local pidx = X.tone(c, pm, pv, PE, { cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, tok = ptok })
local rr = X.rim(pn)
pm:each(function(x, y) local k = K(x, y) local i = pidx[k]
  if (i == 3 or i == 2) and pv[k] > 0.33 and pv[k] < 0.44 then c:put(x, y, "#e8b4c8", ptok) end   -- pink orient band
  if i <= 2 and rr[k] > 0.5 then c:put(x, y, "#8ccad6", ptok) end                                   -- teal bounce
end)
-- waterline AO row on the pearl
for x = 24, 42 do if pm:has(x, 36) then c:put(x, 36, (x < PC) and PE[3] or PE[2], ptok) end end
-- window specular (2x2 + sill) and sparkle
for _, p in ipairs{ {28, 24}, {29, 24}, {28, 25}, {29, 25} } do c:put(p[1], p[2], "#fffaf0", ptok) end
c:put(30, 23, PE[5], ptok) c:put(27, 26, PE[5], ptok) c:put(31, 26, "#fffaf0", ptok)
c:sparkle(41, 21)
-- ripple ring and reflection in the water
for x = 21, 45 do
  local dx = (x + 0.5 - PC) / 12.5
  if abs(dx) < 1 then local y = floor(37.6 + 2.2 * sqrt(1 - dx * dx) + 0.5)
    if water:has(x, y) and (x % 4 ~= 3) then c:put(x, y, (dx < 0.3) and SEA[6] or SEA[4], wtk) end end
end
for x = 27, 38 do if water:has(x, 37) and not pm:has(x, 37) then c:put(x, 37, (x < 32) and PE[4] or PE[3], wtk) end end
c:put(29, 38, PE[4], wtk) c:put(31, 38, PE[3], wtk)

-- quirk: moss tuft + fern fiddlehead out of the mortar joint on the right
local MO = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local mtok = { r = { name = "moss" } }
for _, p in ipairs{ {46, 44, 2}, {47, 44, 3}, {48, 44, 2}, {45, 45, 1}, {46, 45, 2}, {47, 45, 3}, {48, 45, 2}, {49, 45, 1}, {47, 43, 4} } do c:put(p[1], p[2], MO[p[3]], mtok) end
-- fiddlehead stalk + curl
for _, p in ipairs{ {48, 43, 2}, {49, 42, 3}, {50, 41, 3}, {51, 40, 3}, {52, 39, 4}, {53, 39, 3}, {54, 40, 2}, {54, 41, 2}, {53, 42, 2}, {52, 41, 3} } do c:put(p[1], p[2], MO[p[3]], mtok) end
c:put(50, 43, MO[2], mtok) c:put(51, 43, MO[3], mtok)

A.run(c, NAME)
