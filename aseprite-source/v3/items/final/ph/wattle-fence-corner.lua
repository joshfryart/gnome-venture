-- wattle-fence-corner (lean W2_37)
-- Two woven hazel panels meeting at a lashed corner post: the left panel faces us, the right panel recedes (skewed, darker).
-- Withy rods weave over/under upright stakes. quirk: a withy has sprouted a tiny green shoot.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wattle-fence-corner" }
local floor, abs = math.floor, math.abs
local ROD  = { "#5c3818", "#85541f", "#b07a2c", "#d4a145", "#ecc874", "#fbe6a8" }
local ROD2 = { "#3d2616", "#5e3a1c", "#835428", "#a67435", "#c79a54", "#e2c07e" }
local STK  = { "#3a2414", "#573418", "#7a4c22", "#9a6830" }
local WOOD = { "#35201a", "#57331f", "#7d4d2b", "#a56d3c", "#c8914f", "#e6b878" }
local tok = { r = { name = "p" } }
c:groundShadow(34, 54, 24, 3)
local function panel(x0, x1, ytop, ybot, ramp, stk, skew, dir)
  for x = x0, x1 do
    local off = floor((dir > 0 and (x - x0) or (x1 - x)) * skew + 0.5)
    local s = floor((x - x0) / 5)
    local sx = (x - x0) % 5
    for y = ytop, ybot do
      local ly = y - ytop
      local r = floor(ly / 4)
      local ry = ly % 4
      local over = (r + s) % 2 == 0
      local col
      if ly > ybot - ytop - 1 then col = nil end
      if over then col = ry == 0 and ramp[5] or ry == 1 and ramp[4] or ry == 2 and ramp[3] or ramp[1]
      else
        if sx <= 2 then col = (sx == 0) and stk[4] or stk[3] ; if ry == 3 then col = stk[1] end
        else col = ramp[1] end
        if sx == 3 and not over then col = stk[2] end
      end
      -- rod end shading at stake edges
      if over and sx == 4 then col = ramp[2] end
      c:put(x, y - off, col, tok)
    end
  end
end
panel(7, 28, 22, 50, ROD, STK, 0, 1)
panel(37, 57, 22, 50, ROD2, { "#2a1810", "#3d2616", "#583820", "#73492a" }, 0.3, -1)
-- panel top stake tips rounded
for x = 7, 28 do if ((x - 7) % 5) <= 2 and floor((x - 7) / 5) % 2 == 1 then c:put(x, 21, STK[4], tok) end end
-- corner post
local post = c:rect(29, 13, 35, 54)
local n = X.pillow(post, 3.6)
local v = X.light(n, { amb = 0.1, wrap = 0.25 })
G.tone(c, post, v, WOOD, nil, nil, tok)
for _, y in ipairs{ 20, 27, 34, 41, 47 } do
  for x = 30, 34 do if X.hash(x, y, 3) > 0.35 then c:px(x, y, WOOD[2]) end end
end
for y = 16, 52 do if X.hash(31, y, 9) > 0.8 then c:px(31, y, WOOD[5]) end end
-- cap: chamfered top
c:px(29, 13, WOOD[1]) c:px(35, 13, WOOD[1]) c:px(30, 13, WOOD[5]) c:px(31, 13, WOOD[6]) c:px(32, 13, WOOD[5])
-- twine lashings (diagonal wraps)
local TW = { "#6b5a2a", "#a8923f", "#d8c070", "#f0e2a0" }
for _, y0 in ipairs{ 25, 38 } do
  for i = 0, 6 do c:px(29 + i, y0 + (i % 3) - 0, i % 2 == 0 and TW[3] or TW[2]) c:px(29 + i, y0 + 1 + (i % 3), TW[1]) end
  c:px(34, y0 + 3, TW[4])
end
-- quirk: green shoot on the left panel
c:px(12, 20, "#4b9a50") c:px(12, 19, "#4b9a50") c:px(11, 18, "#76b66c") c:px(13, 18, "#76b66c") c:px(10, 17, "#9ccd6c") c:px(14, 17, "#2f7a45")
G.fin(c, "wattle-fence-corner")
