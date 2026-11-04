-- hawk-feather (dC11 first draft): long barred flight feather, russet with dark bars, pale cream shaft, notched tip.
-- quirk: a red thread with a single blue bead is tied round the quill.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC11.lua")
local c = D.new("hawk-feather")
local P = D.P
local X, K = D.X, D.K
local RUS = D.r4("#f2c288", "#b9743a", "#7e4a2f", "#432a28")
local len = math.sqrt(38 ^ 2 + 50 ^ 2)
local m, n, T, S = X.cyl(14, 58, 52, 7, function(t)
  if t > 0.985 then return -1 end
  if t < 0.2 then return 0.9 end
  return math.max(0.8, 7.2 * math.sin(math.pi * math.min(1, (t - 0.18) / 0.86)) ^ 0.7)
end)
X.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), RUS, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 } })
m:each(function(x, y)
  local k = K(x, y) local s, t = S[k], T[k]
  if t < 0.22 then c:px(x, y, s <= 0 and P.cream or "#d6b98a")
  elseif math.abs(s) < 0.1 then c:px(x, y, s <= 0 and P.cream or "#d6b98a")
  elseif (t * len) % 7 < 2.2 and math.abs(s) > 0.15 then c:px(x, y, RUS[1]) end
  -- barbs
  if t > 0.25 and math.abs(s) > 0.2 and ((t * len - math.abs(s) * 2.6) % 3 < 0.6) and not ((t * len) % 7 < 2.2) then c:px(x, y, s < 0 and RUS[5] or RUS[2]) end
end)
-- thread + bead
D.ln(c, 17, 52, 20, 49, P.ember.base) D.ln(c, 17, 51, 20, 48, P.ember.shade)
c:fillMask(D.ell(19, 52, 1.5, 1.5), P.sea.base) c:px(18, 51, P.cream)
D.fin()
