-- bird-of-paradise-seed: round black-brown seeds each crowned with a bright orange fibre tuft, on a big paddle-leaf scrap; the sprout is one broad paddle leaf on a thick stalk. quirk: one seed's orange tuft is combed into a tiny crest.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("bird-of-paradise-seed")
local SD = { "#120c10", "#241a1c", "#3a2a28", "#5a4238", "#80624c", "#b0886a" }
local OR = { "#8f3a1f", "#c25a24", "#e8782e", "#ff9a3c", "#ffbc5c", "#ffe08a" }
D.scrap(4, 56, 58, 50, 8, D.GRN, { norib = false })
-- paddle leaf sprout
D.ln(40, 46, 40, 28, "#6a9a50") D.ln(41, 46, 41, 28, "#4a7a40")
local pad = D.ell(41, 17, 8, 11, .12)
D.lit(pad, D.LEAF2, 4, { wrap = .3 })
D.ln(40, 28, 42, 8, "#c8e898")
for i = 0, 5 do D.ln(41, 27 - i * 3, 41 + 6, 24 - i * 3, "#86c868", pad) D.ln(41, 27 - i * 3, 41 - 6, 24 - i * 3, "#2c7440", pad) end
local function seed(cx, cy, k)
  local m = D.ell(cx, cy, 4.6, 4.2, 0)
  c:fillMask(D.ell(cx + 1, cy + 1.2, 4.8, 4.4, 0), "#1f4a3a")
  D.lit(m, SD, 4)
  c:px(cx - 2, cy - 2, "#fff4d6") c:px(cx - 1, cy - 2, SD[6])
  -- tuft
  for i = -2, 2 do
    local len = 3 - abs(i) * (k == 2 and 0 or 1)
    for j = 1, len + 1 do c:px(cx + i + 3, cy - 2 - j + floor(abs(i) / 2) * (k == 2 and 0 or 1), j > 2 and OR[5] or (i < 0 and OR[4] or OR[3])) end
  end
  c:px(cx + 3, cy - 2, OR[1])
end
seed(14, 51, 1) seed(27, 53, 2) seed(41, 49, 3)
D.fin()
