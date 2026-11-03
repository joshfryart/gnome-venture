-- celery (v3 first draft, dB15). quirk: a ladybird rests on the middle stalk
local DIR = debug.getinfo(1,"S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR.."/../_helpers/_dB15.lua")
local H, HP, X, B = D.H, D.HP, D.X, D
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local c = D.new("celery")
local ST = { "#3f7a3c", "#6aa84a", "#92c867", "#b4de86", "#d2eea4", "#eaf8c8" }
local LF = { "#1f5a3a", "#2f7a46", "#47a052", "#68bc5c", "#90d672", "#bcee94" }
local stalks = {
  { {26, 54}, {22, 40}, {19, 28}, {15, 17}, 3.6 },
  { {38, 54}, {41, 40}, {44, 28}, {49, 17}, 3.6 },
  { {32, 54}, {32, 40}, {31, 28}, {31, 13}, 4.0 },
}
for i, s in ipairs(stalks) do
  local m = H.sweep(s, function(t) return s[5] - 1.2 * t end)
  H.lit(c, m, ST, { R = 1.8 })
  D.bline(c, s, ST[2], m, 1, 0)
  D.bline(c, s, ST[2], m, -1, 0)
  local x, y = D.bez(s, 1)
  for _, L in ipairs{ {-5, -3, 3.4, 2.6, -0.3}, {5, -4, 3.4, 2.6, 0.4}, {0, -7, 3.2, 3.2, 0} } do
    H.lit(c, B.ell(x + L[1], y + L[2], L[3], L[4], L[5]), LF, { R = 1.6 })
  end
end
-- cut base
H.lit(c, B.ell(32, 54, 8, 2, 0), { "#8aa860", "#b4cc84", "#d4e4a4", "#e8f2bc", "#f4f8d4", "#fcfce8" }, { R = 1 })
-- ladybird
local lm = B.ell(32, 33, 2.6, 2.2, 0)
H.lit(c, lm, "ember", { R = 1.5 })
c:px(32, 32, "#2b1c26") c:px(32, 34, "#2b1c26") c:px(31, 31, "#ff8a5c") c:px(30, 33, "#2b1c26")
c:px(32, 30, "#2b1c26") c:px(33, 30, "#2b1c26")
D.fin()
