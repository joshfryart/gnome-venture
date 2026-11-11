-- Hovel floor layers 480x50 (slot 0,220): planks, flagstones, moss. Opaque; each fully replaces the room's neutral boards.
-- Row 0 is the back edge against the wainscot (ink line, then a contact shade).
local SRC = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(SRC .. "/v3/lib/hp.lua")
local OUT = app.params.out or (SRC .. "/v3/hovel/")
local W, H = 480, 50
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local INK = "#2b1c26"
local function new(name)
  local c = HP.canvas{ w = W, h = H, scale = 1, name = name }
  return c, dofile(SRC .. "/v3/tree-yard/common.lua").setup(c)
end
local function backEdge(c, col) for x = 0, W - 1 do c:put(x, 0, INK); c:put(x, 1, col) end end

-- planks: honey boards, rows get taller toward the viewer; quirk: one knot hole has popped and shows a dark hollow with a lost button in it
do
  local c, S = new("hovel-floor-plank")
  local HON = {"#4a2a26", "#6e3e2c", "#94603a", "#b48048", "#d0a060", "#e6c080"}
  local rows = {2, 8, 15, 23, 32, 42, 50}
  for r = 1, #rows - 1 do
    local y0, y1 = rows[r], rows[r + 1] - 1
    local len, off = 70 + r * 6, (r * 37) % 60
    for y = y0, y1 do for x = 0, W - 1 do
      local k = floor((x + off) / len); local p = (x + off) % len
      local tone = (S.hash(k, r, 3) > .55) and 4 or ((S.hash(k, r, 4) > .5) and 3 or 4)
      if y == y0 then tone = 2 elseif y == y0 + 1 then tone = tone + 1 end
      if y == y1 and y1 - y0 > 5 then tone = tone - 1 end
      -- wavy grain lines
      local g = (y - y0) * 7 + floor(3 * math.sin((x + k * 13) / 9))
      if y > y0 + 1 and y < y1 and g % 11 == 0 then tone = tone - 1 end
      if p == 0 then tone = 1 elseif p == 1 then tone = 5 end
      if y > y0 + 1 and (p == 3 or p == len - 3) and (y - y0) % 4 == 2 then tone = 1 end    -- nail heads
      c:put(x, y, HON[max(1, min(6, tone))])
    end end
  end
  -- warm window light falls in a stepped patch on the left
  S.glow(80, 20, 70, "#fff0c0", .22)
  backEdge(c, HON[1])
  -- quirk: a knot hole with a little blue button lost inside
  for _, p in ipairs{{301, 27}, {302, 27}, {303, 27}, {300, 28}, {301, 28}, {302, 28}, {303, 28}, {304, 28}, {301, 29}, {302, 29}, {303, 29}} do c:put(p[1], p[2], HON[1]) end
  c:put(302, 28, "#46598a"); c:put(303, 28, "#6076a4"); c:put(301, 26, HON[2]); c:put(304, 27, HON[2]); c:put(305, 28, HON[5]); c:put(302, 30, HON[5])
  c:save{ aseprite = OUT .. "hovel-floor-plank.aseprite", png = OUT .. "hovel-floor-plank.png" }
end

-- flagstones: irregular cool-warm slabs in mortar; quirk: one tiny sprout pushing out of a crack
do
  local c, S = new("hovel-floor-stone")
  local ST = {"#3c3040", "#5e5260", "#7e7278", "#a09290", "#bcaea4", "#d6c8b8"}
  local MOR = "#5a4c50"
  -- jittered grid of stones, row height grows toward the front
  local rows = {2, 11, 22, 35, 50}
  for r = 1, #rows - 1 do
    local y0, y1 = rows[r], rows[r + 1] - 1
    local sw = 26 + r * 8
    local off = floor(S.hash(r, 0, 9) * sw)
    for y = y0, y1 do for x = 0, W - 1 do
      local k = floor((x + off) / sw); local p = (x + off) % sw
      local j = floor(S.hash(k, r, 2) * 5) - 2                     -- per-stone jag of the right joint
      local jx = p - (sw - 1) + ((y - y0 < (y1 - y0) / 2) and 0 or j)
      local col
      if y == y0 or p == 0 or jx >= 0 then col = MOR
      else
        local base = (S.hash(k, r, 7) > .66) and 5 or ((S.hash(k, r, 8) > .4) and 4 or 3)
        local tone = base
        if y == y0 + 1 or p == 1 then tone = base + 1 end           -- lit top/left lip
        if y == y1 or jx == -1 then tone = base - 1 end             -- shaded bottom/right lip
        if tone == base and S.hash(x, y, 31) > .93 then tone = base - 1 end
        if tone == base and S.hash(x, y, 33) < .03 then tone = base + 1 end
        col = ST[max(1, min(6, tone))]
        -- faint warm/cool tint per stone
        if S.hash(k, r, 12) > .7 and tone == base then col = ({"", "", "#86746e", "#a89488", "#c4b0a0"})[base] or col end
      end
      c:put(x, y, col)
    end end
  end
  S.glow(80, 20, 70, "#fff0c0", .2)
  backEdge(c, ST[1])
  -- a hairline crack across one stone, and the sprout out of it
  local cx, cy = 248, 30
  for i = 0, 7 do c:put(cx + i, cy + floor(i / 3), MOR) end
  c:put(cx + 3, cy, "#3a5222"); c:put(cx + 3, cy - 1, "#557228"); c:put(cx + 2, cy - 2, "#7a922e"); c:put(cx + 1, cy - 3, "#a4b444")
  c:put(cx + 4, cy - 2, "#557228"); c:put(cx + 5, cy - 3, "#7a922e"); c:put(cx + 4, cy - 3, INK); c:put(cx + 1, cy - 4, INK); c:put(cx + 2, cy - 3, INK); c:put(cx + 6, cy - 3, INK); c:put(cx + 5, cy - 4, INK); c:put(cx + 0, cy - 3, INK)
  c:save{ aseprite = OUT .. "hovel-floor-stone.aseprite", png = OUT .. "hovel-floor-stone.png" }
end

-- moss: a deep springy carpet of tufts; quirk: one tiny pale mushroom with a cream cap among the tufts
do
  local c, S = new("hovel-floor-moss")
  local MO = {"#1c3434", "#2a5240", "#3a704a", "#529054", "#78b064", "#a8d080"}
  for y = 2, H - 1 do for x = 0, W - 1 do
    local s = 3 + floor((y - 2) / 12)                                -- tuft size grows to the front
    local tx, ty = floor(x / s), floor(y / s)
    local h = S.hash(tx, ty, 61)
    local lx, ly = x - tx * s, y - ty * s
    local tone = (h > .6) and 4 or 3
    if ly == 0 and lx < s - 1 then tone = tone + 1 end              -- lit top of each tuft
    if lx == 0 and ly > 0 then tone = tone - 1 end
    if ly == s - 1 then tone = tone - 1 end
    if S.hash(x, y, 63) > .965 then tone = 6 end                    -- bright moss tips
    if h < .08 then tone = 2 end                                    -- the odd hollow
    c:put(x, y, MO[max(1, min(6, tone))])
  end end
  -- a few starry moss flowers (cream with a gold eye), clustered
  for i = 0, 14 do
    local x, y = floor(S.hash(i, 1, 71) * 470) + 4, floor(S.hash(i, 2, 71) * 40) + 6
    if abs(x - 300) > 12 then
      c:put(x, y, "#f4e8c4"); c:put(x - 1, y, "#e8d6a8"); c:put(x + 1, y, "#e8d6a8"); c:put(x, y - 1, "#f8eacc"); c:put(x, y + 1, "#d4be8c"); c:put(x, y, "#e0aa2c")
    end
  end
  S.glow(80, 20, 70, "#f8f0b0", .2)
  backEdge(c, MO[1])
  -- quirk: tiny mushroom
  local mx, my = 300, 30
  for y = my, my + 3 do c:put(mx, y, "#eed9b8"); c:put(mx + 1, y, "#bca290") end
  for x = mx - 3, mx + 4 do c:put(x, my - 1, "#dcc4a6"); c:put(x, my - 2, (x < mx + 1) and "#f8eacc" or "#eed9b8") end
  for x = mx - 2, mx + 3 do c:put(x, my - 3, (x < mx) and "#f8eacc" or "#dcc4a6") end
  for x = mx - 4, mx + 5 do c:put(x, my, (x == mx or x == mx + 1) and c:get(x, my) or c:get(x, my)) end
  for x = mx - 3, mx + 4 do c:put(x, my - 4, INK) end; c:put(mx - 4, my - 2, INK); c:put(mx - 4, my - 1, INK); c:put(mx + 5, my - 2, INK); c:put(mx + 5, my - 1, INK)
  c:put(mx - 3, my - 3, INK); c:put(mx + 4, my - 3, INK)
  for x = mx - 3, mx + 4 do if x ~= mx and x ~= mx + 1 then c:put(x, my, INK) end end
  c:put(mx - 1, my + 1, INK); c:put(mx + 2, my + 1, INK); c:put(mx - 1, my + 2, INK); c:put(mx + 2, my + 2, INK); c:put(mx - 1, my + 3, INK); c:put(mx + 2, my + 3, INK)
  c:put(mx - 1, my - 2, "#fff4d6")
  c:save{ aseprite = OUT .. "hovel-floor-moss.aseprite", png = OUT .. "hovel-floor-moss.png" }
end
print("ok")
