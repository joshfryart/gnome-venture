-- morel-risotto pass A. Shallow slate-blue glazed bowl with a bare clay foot ring, creamy risotto mound,
-- two whole honeycomb morels + one halved (hollow cream inside), slim wooden spoon planted at the right.
-- quirk: a single steam curl rising off the risotto.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local HP, X, c, P = H.new("morel-risotto.pA")
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
-- glaze specular streak + cool bounce on the lower right
for _, p in ipairs{ {16,40},{17,41},{17,42},{18,43} } do put(p[1], p[2], GLAZE[6]) end
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

-- morels: honeycomb cone caps on pale stems
local function morel(cx, by, w, h, half)
  local cap = HP.mask()
  for r = 0, h - 1 do
    local f = (r + 1) / h
    local hw = (w / 2) * min(1, (f / 0.6)) ^ 0.55
    for x = floor(cx - hw + 0.5), floor(cx + hw - 0.01 + 0.5) do cap:set(x, by - h + r) end
  end
  local stem = c:rect(floor(cx) - 1, by, floor(cx) + 1, by + 2)
  stem:each(function(x, y) put(x, y, (x == floor(cx) - 1) and FLESH[4] or (x == floor(cx) + 1) and FLESH[1] or FLESH[3]) end)
  local n = X.sphere(cx - 1, by - h * 0.55, max(w / 2, h / 2), cap)
  local v = X.light(n, { amb = 0.15, wrap = 0.3 })
  cap:each(function(x, y)
    local i = idx(v[K(x, y)])
    if half then
      local e = not cap:has(x - 1, y) or not cap:has(x + 1, y) or not cap:has(x, y - 1)
      if e then put(x, y, MOR[max(2, i - 1)])
      else
        local hollow = math.abs(x - cx) < w * 0.22 and y > by - h * 0.75 and y < by - 1
        put(x, y, hollow and FLESH[1] or FLESH[(x < cx) and 4 or 3])
      end
    else
      local r = y - (by - h)
      local ridgeV = ((x + floor(r / 3)) % 3 == 0)
      local ridgeH = (r % 3 == 0)
      if ridgeV or ridgeH then put(x, y, MOR[min(6, i + 1)]) else put(x, y, MOR[max(1, i - 2)]) end
    end
  end)
  return cap
end

-- wooden spoon (behind front morel, planted in the risotto right)
local sm, sT, sS = H.cyl(c, 42, 34, 54, 11, function(t) return 1.1 + (t > 0.75 and 0.5 or 0) end, WOOD)
sm:each(function(x, y) local s, t = sS[K(x, y)], sT[K(x, y)] if math.abs(s + 0.1) < 0.2 and (floor(t * 30) % 4) ~= 0 then put(x, y, WOOD[3]) end end)
put(42, 35, RICE[2]) put(43, 35, RICE[5]) put(41, 34, RICE[5])
morel(24, 34, 7, 11)
morel(35, 33, 8, 13, true)
morel(29, 37, 6, 8)
-- quirk: steam curl
for _, p in ipairs{ {19,22,2},{18,21,2},{17,20,1},{17,19,1},{18,18,2},{19,17,2},{20,16,1},{20,15,1},{19,14,2},{18,13,2},{17,12,1},{17,11,1},{18,10,2} } do
  put(p[1], p[2], STEAM[p[3]])
end
H.fin(c)
