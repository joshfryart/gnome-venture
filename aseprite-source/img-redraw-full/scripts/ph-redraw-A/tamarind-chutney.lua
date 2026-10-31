-- ph/tamarind-chutney, redraw A (2.2.1 leftovers, Opus medium): bigger terracotta matka, tilted saucer lid,
-- one thick dark drip, cream wave band.
local HERE = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local D = HERE .. "../../../"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N, V = "tamarind-chutney", "A"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local terra = GV.ramp("#cf6a38")
local paste = GV.ramp("#4a2216", { rim = "#6e3420", gloss = "#9a5a34", dot = "#c08050" })
local body = c:ellipse(32, 41, 18, 14):add(c:rect(24, 22, 40, 30))
local p = c:build{
  { "pot", body, terra, { gloss = { 19, 36 } } },
  { "rim", c:rrect(19, 17, 45, 23, 3), terra, { gloss = false, cres = 2 } },
}
-- paste showing under the lid and a thick drip down the front
c:fill(c:rect(22, 18, 42, 19), paste.base)
local drip = c:line({ {27, 19}, {27, 26}, {26, 31} }, 4):add(c:ellipse(26.5, 33, 2.5, 3))
c:part(drip, paste, { flat = true, contact = false, contour = "#2a1a10" })
c:px(26, 22, paste.gloss); c:px(26, 23, paste.gloss); c:px(25, 32, paste.dot)
-- cream wave band round the belly
for x = 17, 47 do
  local y = 44 + ((x % 6 < 3) and 0 or 1)
  local g = c:get(x, y)
  if p.pot.m:has(x, y) and g ~= terra.shade and g ~= terra.deep and g ~= terra.bounce then
    c:px(x, y, "#f6e3c0"); c:px(x, y + 1, "#f6e3c0")
  end
end
-- saucer lid, tilted up to the right, with a knob
local lid = c:poly({ {16, 15}, {44, 7}, {48, 9}, {48, 12}, {20, 20}, {16, 18} })
c:part(lid, terra, { gloss = false, cres = 2, deep = 1 })
c:part(c:rrect(30, 6, 35, 10, 1), terra, { flat = true })
c:ground(32, 57, 17, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph-redraw-" .. V .. "/") .. N .. ".aseprite", (P.out or D .. "img-redraw-full/redraw-2.2.1/" .. V .. "/") .. N .. ".png")
print(N, V, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
