-- passion-fruit-curd (final, Opus single pass aC32_1). A slim glass jar of golden passion-fruit curd flecked with black
-- seeds (curd lit as a cylinder seen through the glass: pale glass rim, cool side walls, bright vertical spec streak,
-- empty headspace above the curd line), a cream paper label with a tiny purple passion fruit, and a violet gingham
-- cloth cap (woven checks, pinked hem) tied with twisted twine and a little bow. Two-tone ground shadow.
-- quirk: one fat drip of curd has escaped under the cloth and runs down the outside of the glass.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "passion-fruit-curd"
local c = A.new(NAME)
local CURD = { "#9a5a12", "#c87e14", "#e8a21c", "#f8c63a", "#ffe07a", "#fff0b0" }
local GLASS = { "#3a6a8a", "#5f9ab4", "#9ccfd8", "#d6f2ee" }
local CLOTH = { "#35295f", "#4f3c8e", "#6c55b4", "#8a6fd0", "#ab94e4", "#cdbdf4" }
local TW = { "#6a4a2a", "#a87a48", "#d8b47c", "#f2dcaa" }
local PAPER = { "#c9b48c", "#ead8b0", "#fbf0d4" }
local SEEDC = "#2b1c26"

c:groundShadow(32, 56, 15, 2)
local cx = 32
-- jar silhouette: body with rounded shoulders, a short neck
local body = c:rrect(21, 27, 43, 55, 5)
local neck = c:rect(24, 22, 40, 27)
local jar = body:copy():add(neck)
-- cloth cap: domed top over the neck + skirt with pinked hem
local cap = HP.mask()
for y = 12, 27 do for x = 17, 47 do
  local dx = (x - cx) / 13.5
  local top = 19 - 6.0 * sqrt(max(0, 1 - dx * dx))          -- dome
  local hem = 24 + (abs(dx) * 3.0) + (((x % 3) == 0) and 1 or 0) -- skirt flares a bit, pinked edge
  if abs(dx) <= 1 and y >= top and y <= hem then cap:set(x, y) end
end end
jar:cut(cap)

-- glass jar: cylinder normal from x
local jn = {}
jar:each(function(x, y)
  local dx = (x - cx) / 11.8
  local yy = 0
  if y > 51 then yy = (y - 51) / 5 end
  jn[K(x, y)] = { A.norm(dx, yy, sqrt(max(0.05, 1 - dx * dx - yy * yy))) }
end)
local CL = 31  -- curd line
local inner = jar:copy():shrink(1)
local curd = inner:copy() curd:each(function(x, y) if y < CL then curd.s[K(x, y)] = nil end end)
local jtok = { r = { name = "glass" } }
local ctok = { r = { name = "curd" } }
-- headspace glass (empty, cool pale)
local v = X.light(jn, { amb = 0.2, wrap = 0.3 })
jar:each(function(x, y) local k = K(x, y)
  if not curd:has(x, y) then
    local i = 1 + floor(v[k] * 3.99)
    if inner:has(x, y) then i = min(4, i + 1) end
    c:put(x, y, GLASS[max(1, min(4, i))], jtok)
  end
end)
-- curd through glass
local cb = {}
curd:each(function(x, y) if y == CL then cb[K(x, y)] = 1 end if y == CL + 1 then cb[K(x, y)] = -1 end end)
A.tone(c, curd, jn, CURD, { tok = ctok, bias = cb, amb = 0.12, wrap = 0.3 })
-- curd line meniscus + seed flecks
curd:each(function(x, y)
  if y > CL + 1 and X.hash(x, y, 13) > 0.94 then c:put(x, y, SEEDC, ctok) end
end)
-- glass walls: cool side columns, darker bottom
jar:edge():each(function(x, y) if x > cx + 6 then c:put(x, y, GLASS[1], jtok) elseif x < cx - 6 then c:put(x, y, GLASS[3], jtok) end end)
for x = 24, 40 do if jar:has(x, 54) then c:put(x, 54, (x < 30) and GLASS[2] or GLASS[1], jtok) end end
-- vertical spec streak (broken) + small one right
for y = 30, 46 do if y ~= 37 and y ~= 38 then c:put(24, y, GLASS[4], jtok) end end
for y = 30, 34 do c:put(25, y, GLASS[4], jtok) end
for y = 41, 44 do c:put(40, y, GLASS[3], jtok) end

-- label
local ltok = { r = { name = "label" } }
local lab = c:rect(26, 38, 38, 47)
lab:each(function(x, y)
  local i = 2
  if x >= 36 then i = 1 elseif x <= 27 then i = 3 end
  c:put(x, y, PAPER[i], ltok)
end)
for x = 26, 38 do c:put(x, 38, PAPER[1], ltok) c:put(x, 47, PAPER[1], ltok) end
-- tiny passion fruit on the label
for _, p in ipairs{ {31,41,"#7c3d84"},{32,41,"#7c3d84"},{30,42,"#7c3d84"},{31,42,"#9e58a0"},{32,42,"#7c3d84"},{33,42,"#5e2c6a"},
  {30,43,"#7c3d84"},{31,43,"#7c3d84"},{32,43,"#5e2c6a"},{33,43,"#5e2c6a"},{31,44,"#5e2c6a"},{32,44,"#41204f"},{33,40,"#46954b"},{34,40,"#68b452"} } do
  c:put(p[1], p[2], p[3], ltok) end

-- cloth cap: gingham checks with weave, lit as a dome
local captok = { r = { name = "cloth" } }
local cn = {}
cap:each(function(x, y)
  local dx = (x - cx) / 14
  local dy = (y - 18) / 9
  cn[K(x, y)] = { A.norm(dx, dy - 0.15, sqrt(max(0.08, 1 - dx * dx - dy * dy * 0.4))) }
end)
local cv = X.light(cn, { amb = 0.15, wrap = 0.3 })
cap:each(function(x, y) local k = K(x, y)
  local i = 2 + floor(cv[k] * 3.5)
  local gx, gy = floor((x - 1) / 3) % 2, floor((y) / 3) % 2
  if gx == 1 and gy == 1 then i = i + 2 elseif gx == 1 or gy == 1 then i = i + 1 end
  if (x + y) % 4 == 0 and i > 2 then i = i - 1 end     -- diagonal weave
  if y >= 24 then i = i - 1 end                          -- skirt is in shade under the twine
  c:put(x, y, CLOTH[max(1, min(6, i))], captok)
end)
-- twisted twine band at y 22-23 with a bow on the left
local ttok = { r = { name = "twine" } }
for x = 18, 46 do if cap:has(x, 22) then
  c:put(x, 22, TW[(x % 3 == 0) and 2 or ((x < cx) and 4 or 3)], ttok)
  c:put(x, 23, TW[(x % 3 == 1) and 1 or 2], ttok)
end end
for _, p in ipairs{ {21,20,3},{22,21,3},{20,21,2},{19,20,2},{18,20,3},{18,21,2},{19,22,1},
  {24,20,4},{25,21,3},{26,20,3},{26,21,2},{23,22,2},{21,24,2},{20,25,3},{20,26,2},{23,24,2},{23,25,3},{23,26,2} } do
  c:put(p[1], p[2], TW[p[3]], ttok) end
c:put(22, 22, TW[1], ttok)
c:put(26, 14, CLOTH[6], captok) c:put(27, 14, CLOTH[6], captok)   -- one cloth pop

-- quirk: curd drip from under the cloth hem down the glass
local dtok = { r = { name = "drip" } }
for _, p in ipairs{ {41,27,4},{41,28,4},{42,28,3},{41,29,5},{42,29,3},{41,30,4},{42,30,3},{41,31,4},{42,31,2},{41,32,3},{42,32,2},{41,33,2} } do
  c:put(p[1], p[2], CURD[p[3]], dtok) end
c:put(41, 30, CURD[6], dtok)
A.save(c, NAME)
