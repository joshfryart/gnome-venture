-- nav-feedback (final pass, Opus aC2r1_1). A glossy enamel speech bubble (rounded slab, curved tail lower-left)
-- holding three raised cream pearl dots. Material: pillow-lit 6-tone blue with a bright top bevel, a window
-- reflection streak along the top, cool violet reflected light on the lower-right rim; pearls are sphere-lit with
-- a specular each and a contact shadow on the enamel.
-- quirk: the middle dot is hopping mid-"typing", its shadow left behind on the bubble.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r1_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("nav-feedback")
local BLUE  = { "#1e2a5a", "#2b4888", "#3b6ab6", "#5490d6", "#86bcee", "#c4e4ff" }
local PEARL = { "#6c5a7a", "#9a86a0", "#c8b8c0", "#e8dccc", "#fbf0d8", "#fffaee" }
local BOUNCE = "#5a5cb8"

local body = c:rrect(9, 12, 54, 41, 10)
local tail = c:poly{ { 15, 36 }, { 27, 38 }, { 21, 45 }, { 12, 52 }, { 15, 45 } }
local m = body:copy():add(tail)
local n, d = X.pillow(m, 5)

-- dots
local dots = { { 21, 27 }, { 32, 23 }, { 43, 27 } }
local dm = {}
local bias = A.bias()
for i, p in ipairs(dots) do
  local dmask, dn = A.oval(p[1], p[2], 2.6, 2.6, 0)
  dm[i] = { m = dmask, n = dn }
  if i == 2 then
    -- shadow left behind where the dot was sitting (flattened, offset)
    local sh = A.oval(32.5, 28.4, 2.6, 1.3, 0)
    sh:each(function(x, y) local k = K(x, y) bias[k] = (bias[k] or 0) - 2 end)
  else
    A.cast(bias, m, dmask, 1, 1, -2)
    A.ao(bias, m, dmask, 1, -1)
  end
end
local idx = A.shade(c, m, n, BLUE, { bias = bias })

-- window reflection along the top inside edge + a short tick after a gap
m:each(function(x, y) local k = K(x, y)
  local dd = d[k]
  if dd and dd > 1.2 and dd < 2.3 and y <= 15 and x >= 17 and x <= 33 then c:put(x, y, BLUE[6]) end
  if dd and dd > 1.2 and dd < 2.3 and y <= 15 and x >= 36 and x <= 38 then c:put(x, y, BLUE[6]) end
  if dd and dd > 1.2 and dd < 2.3 and x <= 13 and y >= 20 and y <= 26 then c:put(x, y, BLUE[5]) end
end)
-- cool reflected light on the lower-right rim
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.62 and x > 30 and y > 30 then c:put(x, y, BOUNCE) end end)

-- pearls
for i, p in ipairs(dots) do
  local pi = A.shade(c, dm[i].m, dm[i].n, PEARL, { amb = 0.1, wrap = 0.3 })
  c:put(p[1] - 1, p[2] - 1, A.CREAM)
end
c:sparkle(52, 9)
A.save(c, "nav-feedback")
