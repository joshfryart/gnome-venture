-- chanterelle (v3 first draft, dB15). quirk: a baby chanterelle and moss tuft keep it company
local DIR = debug.getinfo(1,"S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR.."/../_helpers/_dB15.lua")
local H, HP, X, B = D.H, D.HP, D.X, D
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local c = D.new("chanterelle")
D.shadow(c, 32, 52, 22, 3)
local CAP = { "#7a3a1c", "#b8631f", "#e08a28", "#f5b82e", "#ffd868", "#fff0a8" }
local STM = { "#9a6a3a", "#c8924a", "#e8b866", "#f6d68a", "#fde8ae", "#fff4d0" }
local function chant(cx, top, w, h)
  local stem = c:poly{ { cx - w * .5, top + 3 }, { cx + w * .5, top + 3 }, { cx + w * .3, top + h }, { cx - w * .3, top + h } }
  H.vcyl(c, stem, STM, cx - w * .5, cx + w * .5)
  local cap = B.ell(cx, top, w * 1.4, w * .55, 0)
  H.lit(c, cap, CAP, { R = 3 })
  local dim = B.ell(cx, top - 1, w * .8, w * .22, 0)
  H.lit(c, dim, { "#6a2a14", "#9a4818", "#c06a20", "#d98a2a", "#eea838", "#ffd060" }, { R = 1 })
  for i = -3, 3 do  -- gill ridges running down the stem
    local x = floor(cx + i * w * .13 + .5)
    B.ln(c, x, floor(top + w * .5), floor(cx + i * w * .09 + .5), top + h - 2, STM[2], stem)
  end
  return cap
end
chant(30, 22, 12, 28)
chant(48, 38, 6, 13)
for _, p in ipairs{ {14, 48}, {17, 47}, {20, 49}, {16, 50}, {13, 50}, {19, 51}, {23, 50} } do c:px(p[1], p[2], (p[1] + p[2]) % 2 == 0 and "#3f9150" or "#7cc35a") end
c:px(15, 47, "#c4e07a")
D.fin()
