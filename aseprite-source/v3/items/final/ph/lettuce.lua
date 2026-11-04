-- lettuce (final, Opus single pass). A slim upright cos/romaine head: five long leaves fanning from a pale cut stem,
-- dark outer leaves behind, crisp lime inner heart leaves in front. Each leaf has a scalloped, ruffled margin,
-- a fat pale midrib that widens to white at the base, swept veins and a V-fold light; dark AO rows where leaves
-- overlap. Pale cut-stem disc with a ring, small 2-tone ground shadow. quirk: one round dewdrop on the front-right leaf.
local NAME = "lettuce"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)
local DARK = { "#143a2c", "#1f5434", "#2e7038", "#45903e", "#69ae4a", "#9acb62" }
local MID  = { "#1d4a2c", "#2c6a30", "#47913a", "#6db444", "#9bd25a", "#cdec84" }
local HEART = { "#2a5a2c", "#3f7d32", "#62a23c", "#8cc64a", "#b9e06a", "#e6f6a8" }
local RIB = { "#a9c886", "#cfe4a6", "#eef7cf" }
local CRM = { "#8a7a5c", "#c8bc94", "#e8e0bc", "#fbf6dc" }
local DEW = { "#3a86b0", "#8fd4e0", "#d8f6f4" }

c:groundShadow(32, 57, 13, 2)

-- leaf spec: base, ctrl, tip, max half-width, ramp
local leaves = {
  { { 30, 55 }, { 21, 38 }, { 16, 13 }, 6.6, DARK, 0.2 },
  { { 34, 55 }, { 43, 38 }, { 48, 14 }, 6.6, DARK, 1.3 },
  { { 32, 55 }, { 31, 32 }, { 33, 7 }, 7.4, MID, 2.1 },
  { { 31, 56 }, { 25, 42 }, { 25, 21 }, 5.8, HEART, 3.4 },
  { { 33, 56 }, { 40, 42 }, { 40, 22 }, 5.8, HEART, 4.6 },
}
local PER = 3.6
local built = {}
for i, L in ipairs(leaves) do
  local m, n, T, S, len = A.blade(L[1][1], L[1][2], L[2][1], L[2][2], L[3][1], L[3][2], function(t)
    if t > 0.985 then return -1 end
    local w = L[4] * sin(pi * min(1, t * 0.62 + 0.3)) ^ 0.55 * (0.45 + 0.55 * min(1, t * 2.2))
    return max(0.6, w)
  end, { fold = 0.45 })
  -- ruffle: scallops on the upper margin, deeper toward the tip
  local cut = {}
  m:each(function(x, y) local k = K(x, y)
    local t, s = T[k], S[k]
    local ph = t * len / PER + (s > 0 and 0.5 or 0) + L[6]
    local f = abs((ph - floor(ph)) - 0.5) * 2
    if t > 0.35 and abs(s) > 0.98 - (1 - f) ^ 2 * (0.2 + 0.25 * t) then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  built[i] = { m = m, n = n, T = T, S = S, len = len, r = L[5] }
end
-- paint back to front, with AO from every later (front) leaf
for i, b in ipairs(built) do
  local bias = {}
  for j = i + 1, #built do
    X.ao(bias, b.m, built[j].m, 1, -1)
    A.cast(bias, b.m, built[j].m, 1, 1, -1)
  end
  local vis = b.m:copy()
  for j = i + 1, #built do vis:cut(built[j].m) end
  -- leaf ruffle light: small bumps near the margin
  local n2 = {}
  for k, v in pairs(b.n) do
    local t = b.T[k]
    local wob = (abs(b.S[k]) > 0.55 and t > 0.3) and 0.35 * sin(t * b.len * 1.6) or 0
    n2[k] = { A.norm(v[1] + wob, v[2] - wob * 0.5, v[3]) }
  end
  A.toneN(c, vis, n2, b.r, { bias = bias, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.15, wrap = 0.3 })
  -- midrib: wide and pale at the base, tapering
  vis:each(function(x, y) local k = K(x, y)
    if bias[k] then return end
    local t, s = b.T[k], b.S[k]
    local rw = 0.12 + 0.3 * (1 - t) ^ 2
    if abs(s) < rw and t < 0.9 then
      local tone = t < 0.25 and (s < 0 and 3 or 2) or (s < 0 and 2 or 1)
      c:put(x, y, RIB[tone])
    else
      local ph = (t * b.len - abs(s) * 5) / 5.5 + (s > 0 and 0.5 or 0)
      local f = abs((ph - floor(ph)) - 0.5) * 2
      if f > 0.88 and abs(s) > rw + 0.08 and abs(s) < 0.8 and t > 0.12 and t < 0.85 then
        c:put(x, y, s < 0 and b.r[6] or b.r[3]) end
    end
    -- pale blanched base
    if t < 0.12 and abs(s) >= rw then c:put(x, y, s < 0 and RIB[2] or RIB[1]) end
  end)
end
-- cut stem: pale disc under the leaf bases, with a ring and AO row above
local st = c:ellipse(32, 57, 4, 1)
c:fillMask(st, CRM[3])
for _, p in ipairs{ { 29, 57 }, { 30, 57 }, { 31, 56 } } do c:put(p[1], p[2], CRM[4]) end
for _, p in ipairs{ { 35, 57 }, { 36, 57 }, { 34, 58 }, { 33, 58 } } do c:put(p[1], p[2], CRM[2]) end
c:put(32, 57, CRM[2])
for x = 29, 35 do if c:get(x, 55) then c:put(x, 55, RIB[1]) end end

-- quirk: dewdrop on the front-right leaf
local DX, DY = 38, 34
for _, p in ipairs{ { 0, 0, 2 }, { 1, 0, 2 }, { 0, 1, 2 }, { 1, 1, 1 }, { -1, 0, 1 }, { 0, -1, 1 }, { 2, 1, 1 }, { 1, 2, 1 }, { 1, -1, 1 }, { -1, 1, 2 }, { 0, 2, 1 } } do
  c:put(DX + p[1], DY + p[2], DEW[p[3]])
end
c:put(DX, DY, DEW[3]) c:put(DX + 2, DY + 2, HEART[1])

A.save(c, NAME)
