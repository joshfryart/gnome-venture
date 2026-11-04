-- log-pile (final, Opus single pass aC21_1). Six split-length logs stacked 3-2-1, seen in 3/4: sawn end faces in front,
-- bark barrels running back to the upper-right.
-- Material: end grain with off-centre pith, growth rings, a radial drying check, a dark bark rim; bark barrels with
-- per-pixel cylinder light and fissure lines along the grain; AO where logs press together, ground shadow.
-- quirk: a little snail is gliding along the top log.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("log-pile")
local BARK = { "#2e1b20", "#45282a", "#5f3a31", "#7c4f3b", "#9a6a4b", "#b98a62" }
local END  = { "#8f5a36", "#b07a48", "#cb985c", "#e0b678", "#f0cf96", "#fbe6b8" }
local RING = "#a46a3e"
local R, DX, DY = 6.5, 6, -5
c:groundShadow(34, 53, 24, 2)
local logs = {
  { 18, 46, 0.8, -0.6 }, { 31, 46, -0.5, 0.4 }, { 44, 46, 0.3, 0.9 },
  { 24.5, 34.5, -0.7, -0.2 }, { 37.5, 34.5, 0.6, 0.3 },
  { 31, 23, 0.0, -0.8 },
}
-- 1) bark barrels, back to front (top row first)
local faces = HP.mask()
for _, L in ipairs(logs) do faces:add(c:ellipse(L[1], L[2], R, R)) end
local order = { 6, 4, 5, 1, 2, 3 }
local bodies = {}
for _, i in ipairs(order) do
  local L = logs[i]
  local m, n, T, S = X.cyl(L[1], L[2], L[1] + DX, L[2] + DY, function() return R end)
  m:add(c:ellipse(L[1] + DX, L[2] + DY, R, R))       -- far end cap of the barrel
  local bm = m:copy():cut(faces)
  for k, _ in pairs(bm.s) do if not n[k] then n[k] = { 0.4, -0.3, 0.86 } S[k] = 0.4 end end
  local bias = {}
  -- AO: barrels darken where they tuck behind the end faces in front
  X.ao(bias, bm, faces, 1, -1)
  local idx = A.shade(c, bm, n, BARK, { bias = bias })
  -- fissures along the grain
  bm:each(function(x, y) local k = K(x, y)
    local s = S[k] or 0
    if abs((s * 3.2 + 10) % 1 - 0.5) < 0.12 and X.hash(x, y, i) > 0.25 then A.step(c, idx, BARK, x, y, -1) end
  end)
  bodies[i] = bm
end
-- 2) sawn end faces
for i, L in ipairs(logs) do
  local cx, cy = L[1], L[2]
  local m = c:ellipse(cx, cy, R, R)
  local n = X.pillow(m, 1.5)
  local bias = {}
  -- contact AO where neighbouring faces press
  for j, M in ipairs(logs) do if j ~= i then
    local d = sqrt((M[1] - cx) ^ 2 + (M[2] - cy) ^ 2)
    if d < 2 * R + 1.5 then
      m:each(function(x, y) if sqrt((x - M[1]) ^ 2 + (y - M[2]) ^ 2) < R + 1.6 then local k = K(x, y) bias[k] = (bias[k] or 0) - 1 end end)
    end
  end end
  local idx = A.shade(c, m, n, END, { bias = bias, amb = 0.2, wrap = 0.5 })
  -- growth rings around an off-centre pith
  local px, py = cx + L[3] * 1.2, cy + L[4] * 1.2
  m:each(function(x, y)
    local d = sqrt((x - px) ^ 2 + (y - py) ^ 2)
    if d > 1.2 and abs(d % 2.3 - 1.15) < 0.38 then A.step(c, idx, END, x, y, -1) end
  end)
  c:put(floor(px + .5), floor(py + .5), RING)
  -- bark rim: outer ring of the face in bark tones, lit upper-left
  m:edge():each(function(x, y)
    local lit = (x - cx) + (y - cy) < -2
    c:put(x, y, lit and BARK[4] or BARK[2])
  end)
  -- sapwood band just inside the bark (paler)
  m:shrink(1):edge():each(function(x, y) if (x - cx) + (y - cy) < 0 and idx[K(x, y)] < 6 then c:put(x, y, END[6]) end end)
  -- radial drying check on some logs
  if i == 2 or i == 5 then
    local ang = (i == 2) and 0.7 or 2.4
    for t = 1, 5 do
      local x, y = floor(px + math.cos(ang) * t + .5), floor(py + math.sin(ang) * t + .5)
      if m:has(x, y) then c:put(x, y, END[1]) end
    end
  end
end
-- one bright glint on the top face (fresh-cut)
c:put(28, 20, "#fff4d6")

-- quirk: snail on the top log's barrel
local SN = { a = "#c4e07a", b = "#7cc35a", d = "#3f9150", s = "#f5809f", t = "#c94f84", u = "#7d2c5e", h = "#ffc4d8", e = "#2b1c26" }
A.map(c, {
  "e.e.....",
  ".a..hst.",
  ".ab.sutt",
  ".abbtttu",
  "..bbddd.",
}, 34, 9, SN)
A.save(c, "log-pile")
