-- rat-pelt (final D12_0, Sonnet high). A flat stretched rat hide seen from above: pointed snout and two ear flaps on the
-- left, four splayed legs with tiny claws, a short saddle of darker fur along the spine, hair strokes that flow head to
-- rump, the curled-under hide edge showing pink flesh on the lower-right, empty eye holes. Thin scaly pink tail.
-- quirk: the tail ends in a little curled hook.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("rat-pelt")
local FUR = { "#34262c", "#56424a", "#7a6264", "#9c837a", "#bea28e", "#dfc8aa" }
local SK = { "#6e2a3e", "#a04a5a", "#c8707a", "#e49a98", "#f6c0ae", "#ffdcc8" }
local INK = "#2b1c26"

-- ---------------------------------------------------------------- tail (behind the hide)
local pt = { { 40, 33 }, { 46, 29 }, { 49, 39 }, { 54, 35 } }
local tm, tn, TT, TS = A.tube(pt, function(t) return 1.7 - 0.7 * t end)
local pc = { { 54, 35 }, { 56.5, 33.5 }, { 56, 29.5 }, { 52.5, 31 } }
local cm, cn, CT, CS = A.tube(pc, function(t) return 1.0 - 0.35 * t end)
local tail = tm:copy():add(cm)
local tlen = 24
local tidx = {}
local tv = X.light(tn, { amb = 0.1, wrap = 0.3 })
local cv = X.light(cn, { amb = 0.1, wrap = 0.3 })
tm:each(function(x, y) local k = K(x, y)
  local i = 1 for j, th in ipairs{ 0.24, 0.42, 0.6, 0.76, 0.9 } do if tv[k] >= th then i = j + 1 end end
  local ring = floor(TT[k] * tlen / 1.8) % 2 == 0
  if ring and TS[k] > -0.2 then i = i - 1 end
  c:px(x, y, SK[A.clamp(i, 1, 6)])
end)
cm:each(function(x, y) local k = K(x, y)
  if tm:has(x, y) then return end
  local i = 1 for j, th in ipairs{ 0.24, 0.42, 0.6, 0.76, 0.9 } do if cv[k] >= th then i = j + 1 end end
  if floor(CT[k] * 5 / 1.4) % 2 == 0 and CS[k] > -0.2 then i = i - 1 end
  c:px(x, y, SK[A.clamp(i, 1, 6)])
end)
c:px(52, 31, SK[6])  -- bright hooked tip

-- ---------------------------------------------------------------- hide silhouette
local body = c:ellipse(29, 32, 12, 10.5)
local hm = A.tube({ { 9, 32 }, { 12, 32 }, { 16, 32 }, { 22, 32 } }, function(t) return 1.3 + 4.1 * t ^ 0.9 end)
body:add(hm)
local ears = {}
for _, e in ipairs{ { 21, 25, 2.9, 3.3 }, { 21, 39, 2.9, 3.3 } } do
  local em = c:ellipse(e[1], e[2], e[3], e[4]) ears[#ears + 1] = em body:add(em)
end
local legs = {
  { { { 23, 25 }, { 21, 21 }, { 19, 18 }, { 16, 15 } }, 2.5, 1.7, { 15, 14 } },
  { { { 23, 39 }, { 21, 43 }, { 19, 46 }, { 16, 49 } }, 2.5, 1.7, { 15, 50 } },
  { { { 36, 24 }, { 38, 20 }, { 41, 17 }, { 44, 15 } }, 2.7, 1.8, { 45, 14 } },
  { { { 36, 40 }, { 38, 44 }, { 41, 47 }, { 44, 49 } }, 2.7, 1.8, { 45, 50 } },
}
for _, L in ipairs(legs) do
  local lm = A.tube(L[1], function(t) return L[2] + (L[3] - L[2]) * t end)
  body:add(lm)
  body:add(c:ellipse(L[4][1], L[4][2], 2.7, 2.1))
end
-- eye holes and nose are cut/painted later; pillow-lit hide
local n, d = X.pillow(body, 3.6)
local v = X.light(n, { amb = 0.12, wrap = 0.3 })
local idx = X.tone(c, body, v, FUR, { cuts = { 0.3, 0.5, 0.66, 0.8, 0.92 } })

-- dark saddle along the spine (wavy edges), paler underfur toward the edge
body:each(function(x, y) local k = K(x, y)
  local sad = 2.4 + 1.2 * sin(x * 0.55) + (x > 20 and x < 41 and 0.8 or -1.4)
  if x >= 19 and x <= 42 and abs(y - 32) <= sad then idx[k] = idx[k] - 1 end
  if d[k] < 1.2 and (n[k][1] + n[k][2]) < 0.25 then idx[k] = idx[k] + 1 end
end)
-- hair strokes: short dark / light runs flowing head -> rump, splaying outward from the spine
local base = {}
for k, i in pairs(idx) do base[k] = i end
local function stroke(x, y, len, delta)
  local slope = (y - 32) * 0.045
  for i = 0, len - 1 do
    local px, py = x + i, y + floor(i * slope + 0.5)
    if body:has(px, py) and d[K(px, py)] > 0.6 then idx[K(px, py)] = base[K(px, py)] + delta end
  end
end
body:each(function(x, y)
  local h = X.hash(x, y, 31)
  if h < 0.12 then stroke(x, y, 3, -1) elseif h < 0.2 then stroke(x, y, 2, 1) end
end)
-- shade the legs where they leave the body (ambient) and the ear bases
local bias = {}
for _, em in ipairs(ears) do A.touch(em, hm):each(function(x, y) idx[K(x, y)] = max(1, (idx[K(x, y)] or 3) - 1) end) end
A.paintIdx(c, idx, FUR, body)

-- curled-under hide edge: flesh-pink rim on the lower-right boundary
body:each(function(x, y) local k = K(x, y)
  if d[k] < 0.9 and (n[k][1] + n[k][2]) > 0.55 then c:px(x, y, SK[3]) end
  if d[k] < 0.9 and (n[k][1] + n[k][2]) > 1.05 then c:px(x, y, SK[2]) end
end)
-- ears: inner pink flap with a darker rim
for _, e in ipairs{ { 21, 25 }, { 21, 39 } } do
  local inner = c:ellipse(e[1] - 0.2, e[2], 1.5, 1.9)
  A.shade(c, inner, X.pillow(inner, 1.4), SK, { amb = 0.15, wrap = 0.3 })
  c:px(e[1] - 1, e[2] - 1, SK[6])
end
-- eye holes (empty sockets, ink with a pink lid) and snout
for _, y in ipairs{ 29, 35 } do
  c:px(16, y, SK[3]) c:px(17, y, INK) c:px(18, y, INK) c:px(17, y + (y < 32 and 1 or -1) * 0, INK)
  c:px(16, y + 1, INK)
end
c:px(10, 31, SK[4]) c:px(10, 32, INK) c:px(10, 33, SK[2]) c:px(9, 32, SK[3]) c:px(9, 31, SK[5])
c:px(11, 32, FUR[2]) c:px(12, 32, FUR[2])  -- mouth line
-- claws: tiny cream hooks on each paw
for _, q in ipairs{ { 13, 13 }, { 12, 14 }, { 13, 51 }, { 12, 50 }, { 47, 12 }, { 47, 13 }, { 47, 51 }, { 47, 50 } } do
  if not body:has(q[1], q[2]) then c:px(q[1], q[2], FUR[6]) end
end
-- one bright catch-light on the shoulder fur
c:px(25, 26, FUR[6]) c:px(26, 26, FUR[6])
A.save(c, "rat-pelt")
