-- desert-rose-stone (final, Opus single pass). A gypsum desert rose: thin lens-shaped crystal blades in a rosette,
-- three seen nearly face-on (growth rings, lit rim, sand-crusted face) and five knife-thin blades seen edge-on (one
-- bright crest line each), sandy 6-tone ramp, sand-grain speckle, AO + contact shadow where blades tuck behind each
-- other, 2-tone ground shadow. Air between the outer blade tips keeps the rosette slim.
-- quirk: one small front blade has worn clear: a little selenite window, pale ice-blue among the sand.
local NAME = "desert-rose-stone"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, cos, sin = math.floor, math.abs, math.max, math.min, math.sqrt, math.cos, math.sin
local c = A.new(NAME)
local SAND = { "#4a2e2a", "#7a4f3a", "#a8774f", "#cfa06c", "#e9c891", "#fbe8bf" }
local SEL = { "#3d5272", "#5f84a8", "#8fb6cf", "#bfdbe6", "#e6f4f4", "#fbfdf6" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

c:groundShadow(32, 52, 16, 2)
-- back to front: {cx, cy, rx, ry, ang, kind}
local P = {
  { 32, 18, 10, 2.2, 1.40, "edge" },
  { 20, 23, 10, 2.0, -0.70, "edge" },
  { 44, 23, 10, 2.0, 0.70, "edge" },
  { 21, 34, 9, 5.2, -0.42, "face" },
  { 43, 34, 9, 5.2, 0.42, "face" },
  { 32, 38, 10, 6.4, 0.0, "face" },
  { 20, 46, 8, 1.8, 0.28, "edge" },
  { 44, 46, 7, 1.8, -0.30, "edge", true },
}
for _, p in ipairs(P) do p.m, p.n = A.oval(p[1], p[2], p[3], p[4], p[5], 1.0) end
for i, p in ipairs(P) do
  local vis, bias = p.m:copy(), {}
  for j = i + 1, #P do
    vis:cut(P[j].m)
    X.ao(bias, p.m, P[j].m, 1, -1)
    A.cast(bias, p.m, P[j].m, 1, 2, -1)
  end
  local ramp = p[7] and SEL or SAND
  local tok = { r = { name = "blade" .. i } }
  local ca, sa = cos(p[5]), sin(p[5])
  -- face plates lean back toward the light; edge blades are lit along their crest
  local v = X.light(p.n, { amb = 0.15, wrap = 0.3 })
  local idx = {}
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - p[1], y - p[2]
    local u = (dx * ca + dy * sa) / (p[3] + .45)
    local w = (-dx * sa + dy * ca) / (p[4] + .45)
    if ca * 1 + sa * 1 < 0 then w = -w end
    local val = v[k] or 0.5
    if p[6] == "face" then
      local q = u * u + w * w
      val = val + 0.12 - 0.08 * w
      local i = 1 for jj, t in ipairs(CUTS) do if val >= t then i = jj + 1 end end
      -- growth rings
      if abs(q - 0.32) < 0.07 or abs(q - 0.66) < 0.07 then i = i - 1 end
      -- lit upper rim, crusty lower rim
      if q > 0.8 and w < -0.2 then i = i + 1 end
      if q > 0.78 and w > 0.35 then i = i - 1 end
      idx[k] = i
    else
      local i
      if w < -0.35 then i = 5 elseif w < 0.2 then i = 4 elseif w < 0.6 then i = 3 else i = 2 end
      if abs(u) > 0.8 then i = i - 1 end
      if w < -0.35 and u < 0.1 and u > -0.6 then i = 6 end
      idx[k] = i
    end
    -- sand grain speckle
    local h = X.hash(x, y, i)
    if not p[7] then if h > 0.88 then idx[k] = idx[k] - 1 elseif h < 0.06 then idx[k] = idx[k] + 1 end end
    idx[k] = max(1, min(6, idx[k] + (bias[k] or 0)))
    c:put(x, y, ramp[idx[k]], tok)
  end)
  p.idx = idx
end
-- selenite window: pale core streak + glint
c:put(42, 46, SEL[6], { r = { name = "blade8" } }) c:put(43, 46, SEL[6], { r = { name = "blade8" } })
-- pop on the front face plate, sparkle on the top blade
c:put(27, 34, SAND[6]) c:put(28, 34, SAND[6])
c:sparkle(30, 12)
-- a few loose grains on the ground shadow at the foot
for _, g in ipairs{ {27, 52, 4}, {37, 53, 3}, {33, 53, 5} } do c:put(g[1], g[2], SAND[g[3]]) end
A.save(c, A.here(), NAME)
