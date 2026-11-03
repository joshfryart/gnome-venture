-- ico-fog (final pass, Opus). Three slim drifting fog ribbons stacked with air between them, the top one
-- curling up on the right, the middle one starting from a spiral on the left, the bottom one curling down.
-- Material: tube normals per ribbon (soft roll, 6-tone cool violet-grey), wispy lit streaks running along
-- the drift, frayed gaps on the edges, ambient/contact shade where the ribbons cross.
-- quirk: a little lit lantern is lost in the fog, its warm glow tinting the wisps around it.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.pi
local c = A.new("ico-fog")
local FOG  = { "#46466c", "#666890", "#8c8fb0", "#b0b4cf", "#d2d6e6", "#eef0f7" }
local WARM = { "#6a4a64", "#946676", "#c08c82", "#e0b490", "#f4d6a8", "#fff0cc" }
local MIX  = { "#584870", "#7e6a8a", "#a6909e", "#cab4b8", "#e4d4cc", "#f6eee6" }
local LX, LY = 38, 38   -- lantern glass centre

local function taper(t, wmax, e0, e1)
  local a = min(1, t / e0) local b = min(1, (1 - t) / e1)
  return 1.3 + (wmax - 1.3) * sqrt(min(a, b))
end
local ribbons = {
  { pts = { { 14, 19 }, { 22, 16 }, { 32, 18 }, { 40, 15 }, { 45, 12 }, { 46, 8 }, { 43, 7 }, { 41, 9 } },
    w = function(t) return taper(t, 3.6, 0.18, 0.42) end, seed = 1 },
  { pts = { { 15, 25 }, { 12, 23 }, { 8, 25 }, { 8, 29 }, { 13, 31 }, { 24, 30 }, { 35, 32 }, { 45, 30 }, { 54, 31 } },
    w = function(t) return taper(t, 3.7, 0.4, 0.16) end, seed = 2 },
  { pts = { { 11, 48 }, { 20, 46 }, { 30, 48 }, { 39, 46 }, { 46, 47 }, { 49, 50 }, { 47, 53 }, { 44, 52 } },
    w = function(t) return taper(t, 3.6, 0.16, 0.42) end, seed = 3 },
}

-- lantern first (behind the bottom ribbon, in front of the middle one): drawn after middle, before bottom
local function lantern()
  local tk = A.tok("lantern")
  A.map(c, {
    "..mmm..",
    "..m.m..",
    ".DMMMd.",
    "DMMMMMd",
    ".gGFGg.",
    ".gFCFg.",
    ".gGFGg.",
    ".gggGg.",
    "DMMMMMd",
    ".dMMd..",
  }, LX - 3, LY - 5, { m = "#5c5e78", M = "#8486a0", D = "#3a3c55", d = "#444663",
    g = "#d98322", G = "#f5b82e", F = "#ffe38a", C = "#fff4d6" }, tk)
  c:put(LX - 3, LY - 2, "#aaaabd", tk)
end

local masks, idxs = {}, {}
for i, r in ipairs(ribbons) do
  local m, n, T, S = A.ptube(r.pts, r.w, 10)
  -- frayed edges: knock out a few edge pixels so the wisps look torn by the wind
  m:edge():each(function(x, y) if X.hash(x, y, r.seed) > 0.86 and T[K(x, y)] > 0.25 and T[K(x, y)] < 0.8 then m.s[K(x, y)] = nil end end)
  local tok = A.tok("fog" .. i)
  local bias = {}
  for j = 1, i - 1 do X.ao(bias, masks[j], m, 1, -1) end
  local v = A.val(n, { amb = 0.12, wrap = 0.35, tilt = { 32, 32, 26, 0.12 } })
  local cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }
  local idx = {}
  m:each(function(x, y)
    local k = K(x, y)
    local ii = 1 for j, t in ipairs(cuts) do if v[k] >= t then ii = j + 1 end end
    ii = max(1, min(6, ii + (bias[k] or 0)))
    idx[k] = ii
    local d = sqrt((x - LX) ^ 2 + (y - LY) ^ 2)
    c:put(x, y, (d < 6.5 and WARM or (d < 9.5 and MIX or FOG))[ii], tok)
  end)
  -- wispy lit streaks along the drift on the lit half
  m:each(function(x, y)
    local k = K(x, y)
    local s = S[k]
    if s > -0.62 and s < -0.18 and idx[k] >= 3 and sin(T[k] * 38 + r.seed * 2) > 0.35 then
      local d = sqrt((x - LX) ^ 2 + (y - LY) ^ 2)
      c:put(x, y, (d < 6.5 and WARM or (d < 9.5 and MIX or FOG))[min(6, idx[k] + 1)], tok)
    end
  end)
  -- dark drift line along the shade half
  m:each(function(x, y)
    local k = K(x, y)
    if S[k] > 0.4 and S[k] < 0.62 and sin(T[k] * 23 + r.seed) > 0.5 and idx[k] >= 2 then
      c:put(x, y, FOG[max(1, idx[k] - 1)], tok)
    end
  end)
  -- contact shade on earlier ribbons just under this one
  for j = 1, i - 1 do
    m:shift(1, 1):each(function(x, y) if masks[j]:has(x, y) and not m:has(x, y) then
      local kk = K(x, y) if idxs[j][kk] then c:put(x, y, FOG[max(1, idxs[j][kk] - 2)], A.tok("fog" .. j)) end end end)
  end
  masks[i], idxs[i] = m, idx
  if i == 2 then lantern() end
end
-- one cream glint on the top ribbon's lit crest
c:put(22, 16, A.CREAM) c:put(23, 16, "#eef0f7")
for k, _ in pairs(c.pix) do if c.own[k] == true then c.own[k] = A.tok("misc") end end
A.save(c, "ico-fog")
