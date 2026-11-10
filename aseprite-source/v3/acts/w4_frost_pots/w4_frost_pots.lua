-- act-w4_frost_pots (v3 Hearth Pop 2.5D): at a pink frosty dusk a gnome keeps smudge pots burning under two
-- blossom trees so the frost cannot nip the flowers.
-- Motion: the pot flames flicker, smoke curls up, a few petals and flakes drift down.
-- quirk: one pot is a dented kettle with its spout smoking.
local DIR = (debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")) or "."
local A = dofile(DIR .. "/../actlib.lua")
local P, HP = A.P, A.HP
local floor = math.floor

local G = A.gnome{ view = "front", hat = "#e8493b", tunic = "#3a86b0", scarf = "#f5b82e" }
local SN, SN2, SN3 = "#f6eef8", "#e4d8ee", "#c9b8dc"
local CAN = { hi = "#e2e8f6", base = "#a8b4d8", shade = "#7d86b8", deep = "#4e5288" }
local FLAME = {
  { "..o..", ".oyo.", "oyWyo", ".yWy." },
  { ".o...", ".oyo.", "oyWyo", ".yWy." },
  { "...o.", ".oyo.", "oyyWo", ".yWy." },
  { "..o..", "..yo.", ".oWyo", ".yWy." },
  { ".o...", ".oy..", "oyWyo", ".yWy." },
  { "...o.", "..oy.", "oyWyo", ".yWy." },
}
local FMAP = { o = "#e8493b", y = "#f5b82e", W = "#fff4d6" }

local function tree(c, cx, cy, r, tx)
  c:fillMask(HP.rect(tx - 2, cy + r - 4, tx + 2, 72), P.wood.shade)
  c:fillMask(HP.rect(tx - 2, cy + r - 4, tx - 1, 72), P.wood.base)
  c:fillMask(HP.rect(tx - 2, cy + r - 4, tx + 2, cy + r - 3), P.wood.deep)
  local m = HP.ellipse(cx, cy, r, r - 3):add(HP.ellipse(cx - r * .55, cy + 3, r * .55, r * .5)):add(HP.ellipse(cx + r * .55, cy + 2, r * .55, r * .5))
  c:rim(m, CAN.deep)
  m:each(function(x, y)
    local d = (x - cx) + (y - cy) * 1.2
    local col = d > 6 and CAN.shade or (d < -10 and CAN.hi or CAN.base)
    if A.hash(x, y, 77) < .08 and col ~= CAN.hi then col = CAN.shade end
    c:put(x, y, col)
  end)
  -- snow on the crown
  m:each(function(x, y) if not m:has(x, y - 1) or not m:has(x, y - 2) then c:put(x, y, SN) end end)
  -- blossoms
  math.randomseed(cx)
  for i = 1, 30 do
    local x = floor(cx - r + math.random() * 2 * r)
    local y = floor(cy - r + 4 + math.random() * (2 * r - 4))
    if m:has(x, y) and m:has(x + 1, y + 1) then
      c:put(x, y, "#ffc4d8") c:put(x + 1, y, "#f5809f") c:put(x, y + 1, "#f5809f") c:put(x + 1, y + 1, "#c94f84")
    end
  end
end

local function pot(c, x, yb, f, idx, kettle)
  local body = kettle and HP.ellipse(x, yb - 4, 6, 4) or HP.rrect(x - 5, yb - 8, x + 5, yb, 2)
  local rim = HP.rect(x - 6, yb - 9, x + 6, yb - 8)
  local legs = HP.rect(x - 5, yb + 1, x - 4, yb + 2):add(HP.rect(x + 4, yb + 1, x + 5, yb + 2))
  local all = body:copy():add(legs)
  if not kettle then all:add(rim) end
  if kettle then all:add(c:line({ { x + 6, yb - 5 }, { x + 10, yb - 9 } }, 2)) end
  c:rim(all, P.ink)
  all:each(function(px, py)
    local col = (px < x - 2) and "#74758c" or (px > x + 2 and "#35364e" or "#444663")
    if py == yb - 9 then col = "#aaa9b8" end
    c:put(px, py, col)
  end)
  if kettle then
    c:put(x - 3, yb - 6, "#aaa9b8") c:put(x - 2, yb - 7, "#aaa9b8")
    c:put(x + 1, yb - 5, "#35364e") c:put(x + 2, yb - 4, "#74758c")   -- the dent
    c:fillMask(HP.rect(x - 1, yb - 9, x + 1, yb - 8), "#35364e")
    A.steam(c, f, x + 10, yb - 10, 22, idx, { "#6e6496", "#887eae" })
    return
  end
  -- glow on the rim and flame
  for px = x - 3, x + 3 do c:put(px, yb - 9, "#d98322") end
  local fl = FLAME[((f + idx * 2) % 6) + 1]
  c:paint(fl, x - 2, yb - 13, FMAP)
  A.steam(c, f, x, yb - 14, 22, idx, { "#6e6496", "#887eae" })
end

return A.run("w4_frost_pots", function(f)
  local c = A.canvas("w4_frost_pots")
  c:stripes(10, 60, { "#7d72c0", "#9a84c8", "#b896cc", "#d4a8cc", "#ecbcc8" })
  c:put(30, 14, SN) c:put(70, 18, SN) c:put(122, 12, SN)
  c:terrain(function(x) return 50 + math.sin(x / 9) * 2 + math.sin(x / 4) end, "#9a8cc4", 62)
  for i, x in ipairs({ 18, 46, 66, 98, 128 }) do
    local m = HP.ellipse(x, 52, 6, 4) c:fillMask(m, "#8a7cbc") c:fillMask(HP.rect(x, 55, x, 60), "#7a6cac")
  end
  c:terrain(function(x) return 58 + math.sin((x + 5) / 13) * 1.5 end, "#a898cc", 62)
  for y = 60, 99 do for x = 10, 137 do c:put(x, y, y < 63 and SN2 or SN) end end
  for i = 1, 22 do
    local x, y = 12 + floor(A.hash(i, 1, 2) * 120), 64 + floor(A.hash(i, 2, 2) * 34)
    c:put(x, y, SN2) c:put(x + 1, y, SN2) c:put(x + 1, y + 1, SN3)
  end
  tree(c, 30, 34, 20, 30)
  tree(c, 114, 30, 21, 114)
  -- tree shadows on the snow
  c:fillMask(HP.ellipse(30, 73, 11, 2), SN3) c:fillMask(HP.ellipse(114, 73, 11, 2), SN3)
  c:fillMask(HP.rect(28, 54, 32, 72), P.wood.shade) c:fillMask(HP.rect(28, 54, 29, 72), P.wood.base)
  c:fillMask(HP.rect(112, 51, 116, 72), P.wood.shade) c:fillMask(HP.rect(112, 51, 113, 72), P.wood.base)
  -- back row of pots, then the gnome, then the front pots
  pot(c, 44, 78, f, 1)
  pot(c, 96, 78, f, 2, true)
  A.stamp(c, G, 37, 24)
  pot(c, 20, 94, f, 3)
  pot(c, 124, 94, f, 4)
  -- a few petals and flakes drift down (loop)
  A.lanes{ lanes = { { x = 24, ph = 0 }, { x = 52, ph = 30 }, { x = 88, ph = 12 }, { x = 118, ph = 44 }, { x = 70, ph = 60 } },
    ytop = 10, L = 72, s = 2, D = 12, f = f,
    sway = function(y, li) return floor(math.sin(y / 5 + li) * 2 + .5) end,
    put = function(x, y, li, k)
      if not A.ainside(x, y) then return end
      if (li + k) % 3 == 0 then c:put(x, y, "#f5809f") c:put(x + 1, y, "#ffc4d8") else c:put(x, y, SN) end
    end }
  return c
end)
