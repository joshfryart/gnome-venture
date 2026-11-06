-- morel-risotto (pass B, final). Shallow slate-blue glazed bowl, glaze thinning pale over the lip, bare clay foot ring,
-- AO under the rim, specular + cool bounce. Creamy risotto mound (grains, parsley, parmesan curl) with contact shadows.
-- Morels: pointed conical caps with staggered elongated pits between continuous vertical ribs, knobbly silhouette,
-- pale stems; one halved to show the hollow. Slim wooden spoon with grain planted at the right.
-- History: morel-risotto.pA (pass A).
-- quirk: a single steam curl rising off the risotto.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local HP, X, c, P = H.new("morel-risotto")
local K, floor, max, min, sqrt = H.K, math.floor, math.max, math.min, math.sqrt
local function put(x, y, h) c:put(x, y, h) end
local function idx(v, n) return max(1, min(n or 6, floor(v * 5.99) + 1)) end

local GLAZE = { "#1d3150", "#294a6e", "#386890", "#4c88aa", "#6eaac0", "#a9d6dc" }
local CLAY  = { "#5a3628", "#7e4e36", "#a26a48", "#c48c62" }
local RICE  = { "#93703e", "#b89052", "#d5b06c", "#e9ca8a", "#f6e2ae", "#fff4d6" }
local MOR   = { "#3a2116", "#593420", "#7c4d2a", "#a06a38", "#c48d4c", "#e3b671" }
local FLESH = { "#b89a6e", "#d8c098", "#efdcb8", "#fbf0d6" }
local WOOD  = { "#51302b", "#74452e", "#9a6438", "#bd844a", "#dba566", "#f0c78c" }
local STEAM = { "#cfc8e0", "#ece8f6" }

c:groundShadow(32, 54, 13, 2)
-- foot ring (bare clay)
local foot = c:rrect(25, 47, 39, 52, 1)
foot:each(function(x, y) local i = x < 28 and 4 or x < 34 and 3 or x < 37 and 2 or 1 if y == 52 then i = max(1, i - 1) end put(x, y, CLAY[i]) end)
-- bowl body
local body = c:ellipse(32, 36, 21, 13):clip(c:rect(0, 36, 63, 63))
local outer = c:ellipse(32, 36, 21, 6)
body:add(outer)
local bn = X.sphere(30, 28, 24, body)
local bv = X.light(bn, { amb = 0.1, wrap = 0.35 })
body:each(function(x, y) put(x, y, GLAZE[idx(bv[K(x, y)])]) end)
for x = 12, 52 do for y = 37, 44 do if body:has(x, y) and not outer:has(x, y) and outer:has(x, y - 1) then put(x, y, GLAZE[1]) end end end
-- glaze specular streak + cool bounce on the lower right
for _, p in ipairs{ {16,40},{17,41},{17,42},{18,43},{19,44} } do put(p[1], p[2], GLAZE[6]) end put(17, 40, "#f2fff9")
for _, p in ipairs{ {46,45},{47,44},{48,43},{49,42} } do put(p[1], p[2], "#5f8fb8") end
-- rim lip: glaze thins to pale over the edge
local inner = c:ellipse(32, 36, 19, 4.5)
local lip = outer:copy():cut(inner)
lip:each(function(x, y) put(x, y, (y < 36) and (x < 32 and "#d6ecea" or "#a9d6dc") or (x < 22 and "#a9d6dc" or "#6eaac0")) end)
-- interior (far wall) dark
inner:each(function(x, y) put(x, y, GLAZE[y < 34 and 2 or 3]) end)
-- risotto mound
local ris = c:ellipse(32, 35.5, 18, 4.5):add(c:ellipse(32, 35, 15, 6):clip(c:rect(0, 0, 63, 36))):clip(c:ellipse(32, 36, 19, 7))
local rn = X.pillow(ris, 3)
local rv = X.light(rn, { amb = 0.15, wrap = 0.3 })
ris:each(function(x, y) put(x, y, RICE[idx(rv[K(x, y)])]) end)
for _, g in ipairs{ {18,35},{22,32},{26,34},{30,31},{35,33},{39,31},{44,34},{20,38},{28,38},{36,38},{42,37},{47,36},{33,36} } do
  local x, y = g[1], g[2]
  if ris:has(x, y) and ris:has(x + 1, y) then put(x, y, RICE[6]) put(x + 1, y, RICE[5]) if ris:has(x, y + 1) then put(x, y + 1, RICE[2]) end end
end
for _, g in ipairs{ {24,36},{38,35},{45,33},{31,39} } do put(g[1], g[2], "#5aa957") put(g[1] + 1, g[2], "#2f6e4f") end

-- parmesan curl + contact shadows under the morels
put(40, 37, "#fff4d6") put(41, 37, "#f6e2ae") put(42, 38, "#d5b06c")
for _, p in ipairs{ {21,35},{22,35},{23,35},{26,35},{27,36},{28,38},{31,38},{32,38},{33,35},{34,35},{37,35},{38,34} } do
  if ris:has(p[1], p[2]) then put(p[1], p[2], RICE[2]) end
end

-- morels: pointed cone caps, continuous vertical ribs, staggered elongated pits, knobbly edge
local function morel(cx, by, w, h, seed, half)
  local cap = HP.mask()
  for r = 0, h - 1 do
    local f = (r + 0.5) / h
    local hw = (w / 2) * min(1, f / 0.75) ^ 0.6
    if f > 0.9 then hw = hw - 0.4 end
    for x = floor(cx - hw + 0.5), floor(cx + hw + 0.49) do cap:set(x, by - h + r) end
  end
  local stem = c:rect(floor(cx) - 1, by, floor(cx) + 1, by + 2)
  stem:each(function(x, y) put(x, y, (x == floor(cx) - 1) and FLESH[4] or (x == floor(cx) + 1) and FLESH[2] or FLESH[3]) end)
  put(floor(cx) - 1, by, FLESH[2]) put(floor(cx), by, FLESH[1]) put(floor(cx) + 1, by, FLESH[1])   -- AO under the cap
  local n = X.sphere(cx - 0.8, by - h * 0.5, max(w / 2 + 0.5, h / 2), cap)
  local v = X.light(n, { amb = 0.12, wrap = 0.3 })
  local top = by - h
  local pits = {}
  cap:each(function(x, y)
    local col = floor(x - cx + 20)
    local r = y - top + ((floor(col / 2) % 2 == 0) and 0 or 2)            -- stagger the pits per rib column
    local rib = (col % 2 == 0)
    local cross = (r % 4 == 0)
    pits[K(x, y)] = not (rib or cross)
  end)
  -- knobbly silhouette: nibble some pit pixels on the edge
  local cut = HP.mask()
  cap:edge():each(function(x, y) if pits[K(x, y)] and X.hash(x, y, seed) > 0.7 and y > top + 1 then cut:set(x, y) end end)
  cap:cut(cut)
  cap:each(function(x, y)
    local i = max(1, min(6, floor(v[K(x, y)] * 5.99) + 1))
    if half then
      local e = not cap:has(x - 1, y) or not cap:has(x + 1, y) or not cap:has(x, y - 1)
      local hol = math.abs(x - cx) < 1.2 and y > top + 4 and y < by - 1
      if e then put(x, y, MOR[(i > 3) and 4 or 3])
      elseif hol then put(x, y, (x < cx) and FLESH[1] or MOR[3])        -- the hollow inside
      else put(x, y, FLESH[(x < cx - 1) and 4 or (x < cx + 2) and 3 or 2]) end
    else
      if pits[K(x, y)] then put(x, y, MOR[max(1, i - 3)]) else put(x, y, MOR[min(6, i + 1)]) end
    end
  end)
  if not half then put(floor(cx - w / 4), top + 3, MOR[6]) end
  return cap
end

-- wooden spoon planted at the right (round end, grain, a little rice clinging)
local sm, sT, sS = H.cyl(c, 42, 35, 53, 12, function(t) return 1.05 + (t > 0.82 and 0.55 or 0) end, WOOD)
sm:each(function(x, y) local s, t = sS[K(x, y)], sT[K(x, y)]
  if math.abs(s - 0.15) < 0.2 and (floor(t * 30) % 5) ~= 0 then put(x, y, WOOD[3]) end end)
put(53, 11, WOOD[6]) put(52, 12, WOOD[5])                              -- pale end grain
put(42, 35, RICE[1]) put(43, 35, RICE[1]) put(41, 34, RICE[5]) put(44, 35, RICE[6]) put(40, 35, RICE[6])
morel(22.5, 34, 9, 12, 3)
morel(35.5, 33, 9, 13, 5, true)
morel(29, 37, 8, 10, 9)
-- quirk: one soft steam curl (two-tone S, thinning as it rises)
local stm = H.sweep({ {18,24},{13,19},{22,15},{16,8} }, function(t) return 0.6 end, 90)
stm:each(function(x, y) put(x, y, (x < 17) and STEAM[2] or STEAM[1]) end)
H.fin(c)
