-- glyphs48.lua : every symbol of the v48 kit, as shapes in design units (box W x 17, light from the upper left).
--   mine   (cream, the type's colour as an inlay):   hurt sword, guard shield, heal cross, charm heart, soothe leaf, trick sparkle, item flask
--   creature (bone and the type's colour, other SHAPES so the owner is read without colour):
--            hurt claw marks, guard spiked shell, heal drop, charm paw print, soothe moon, trick bolt, item bone
--   environment (the thing itself, in its own colours): sun, bramble, rain, wind, mud, thornburst
local D = debug.getinfo(1, "S").source:match("@(.*/)")
local L = dofile(D .. "lib48.lua")
local S = L.S
local CREAM, CREAMSH, CREAMHI, INK, GOLD, GOLDSH, BONE, BONESH = L.CREAM, L.CREAMSH, L.CREAMHI, L.INK, L.GOLD, L.GOLDSH, L.BONE, L.BONESH
local G = { me = {}, foe = {}, env = {} }

function G.me.hurt(P)
  return { W = 18,
    { S.line(1.9, 15.2, 4.9, 12.2, 2.4), L.WOODSH },                       -- grip
    { S.line(5.4, 11.7, 14.4, 2.7, 4.2), CREAM },                           -- blade
    { S.poly({ { 12.6, 1.6 }, { 17.6, 0 }, { 15.9, 4.9 } }), CREAM },       -- point
    { S.line(7.2, 10.2, 13.6, 3.8, .9), CREAMSH },                          -- fuller
    { S.line(2.9, 8.7, 8.4, 14.2, 2.6), GOLD },                             -- cross-guard
    { S.disc(1.6, 15.5, 1.7), GOLD },                                       -- pommel
  }
end
function G.me.guard(P)
  return { W = 14,
    { S.poly({ { 0, 0 }, { 14, 0 }, { 14, 8 }, { 11.9, 12.8 }, { 7, 17 }, { 2.1, 12.8 }, { 0, 8 } }), CREAM },
    { S.poly({ { 2.2, 2.3 }, { 11.8, 2.3 }, { 11.8, 7.6 }, { 10.2, 11.4 }, { 7, 14.3 }, { 3.8, 11.4 }, { 2.2, 7.6 } }), P.base },
    { S.poly({ { 2.2, 2.3 }, { 7, 2.3 }, { 7, 14.3 }, { 3.8, 11.4 }, { 2.2, 7.6 } }), P.light },
    { S.rect(6.4, 4.2, 7.6, 11.6), CREAM }, { S.rect(4.0, 6.2, 10.0, 7.4), CREAM },   -- the boss cross
  }
end
function G.me.heal(P)
  return { W = 16,
    { S.rrect(4.8, 0, 11.2, 17, 1.6), CREAM }, { S.rrect(0, 5.3, 16, 11.7, 1.6), CREAM },
    { S.rect(6.9, 2.1, 9.1, 14.9), P.base }, { S.rect(2.1, 7.4, 13.9, 9.6), P.base },
    { S.rect(6.9, 2.1, 7.9, 7.4), P.light }, { S.rect(2.1, 7.4, 7.9, 8.4), P.light },
  }
end
function G.me.charm(P)
  return { W = 16,
    { S.disc(4.3, 4.6, 4.3), CREAM }, { S.disc(11.7, 4.6, 4.3), CREAM }, { S.poly({ { 0.5, 7 }, { 15.5, 7 }, { 8, 16.9 } }), CREAM }, { S.rect(4, 4, 12, 8), CREAM },
    { S.disc(4.9, 5.2, 2.3), P.base }, { S.disc(11.1, 5.2, 2.3), P.base }, { S.poly({ { 2.9, 6.6 }, { 13.1, 6.6 }, { 8, 13.6 } }), P.base }, { S.rect(5, 5, 11, 7.5), P.base },
    { S.disc(4.4, 4.6, 1.0), CREAMHI },
  }
end
function G.me.soothe(P)
  return { W = 18,
    { S.line(0.9, 16.1, 4.2, 12.8, 1.9), CREAM },                           -- stem
    { S.lens(2.4, 14.6, 17.4, 0.4, 5.0), CREAM },
    { S.line(4.6, 12.4, 13.6, 4.2, 1.1), P.shade },                         -- midrib
    { S.line(7.6, 9.6, 7.4, 6.2, .9), P.shade }, { S.line(10.4, 7.0, 13.8, 7.2, .9), P.shade },
    { S.line(7.6, 9.6, 11.0, 10.0, .9), P.shade }, { S.line(10.4, 7.0, 10.2, 3.8, .9), P.shade },
  }
end
function G.me.trick(P)
  return { W = 16,
    { S.star(8, 8.5, 4, 10.2, 3.1, -90), CREAM },                           -- the tips run past the box and are cut blunt
    { S.star(8, 8.5, 4, 4.4, 1.9, -90), GOLD },
    { S.disc(8, 8.5, 1.0), 0xffe58a },
  }
end
function G.me.item(P)
  return { W = 14,
    { S.rect(4.6, 2, 9.4, 7), CREAM },                                      -- neck
    { S.disc(7, 10.8, 6.2), CREAM },                                        -- flask
    { S.disc(7, 10.8, 4.1), P.base }, { S.rect(1, 4, 13, 9.4), CREAM },     -- the brew fills the lower part
    { S.rect(3.0, 9.4, 11, 10.3), P.light },                                -- its surface
    { S.rrect(3.6, 0, 10.4, 2.9, .8), L.WOOD },                             -- cork
    { S.disc(4.6, 12.6, .8), CREAMHI },
  }
end

-- the creature's ------------------------------------------------------------------------------
function G.foe.hurt(P)
  local t = { W = 18 }
  for k = 0, 2 do
    local ox = 5.5 * k
    t[#t + 1] = { S.line(6.6 + ox, 0.4, 3.9 + ox, 8.5, .7, 3.7), BONE }
    t[#t + 1] = { S.line(3.9 + ox, 8.5, 0.9 + ox, 16.6, 3.7, .7), BONE }
  end
  return t
end
function G.foe.guard(P)
  return { W = 18,
    { S.poly({ { 7.1, 5.4 }, { 9, 0 }, { 10.9, 5.4 } }), BONE },                                             -- spikes
    { S.poly({ { 2.2, 9.6 }, { 0.6, 4.2 }, { 5.6, 6.6 } }), BONE }, { S.poly({ { 15.8, 9.6 }, { 17.4, 4.2 }, { 12.4, 6.6 } }), BONE },
    { S.dome(9, 14.6, 8.6, 10.2), P.light },                                                                 -- shell
    { S.rrect(0, 13.4, 18, 17, 1.4), BONE },                                                                 -- its lip
    { S.line(9, 5.6, 9, 12.8, 1.0), P.shade }, { S.line(4.6, 8.4, 3.6, 12.8, 1.0), P.shade }, { S.line(13.4, 8.4, 14.4, 12.8, 1.0), P.shade },
  }
end
function G.foe.heal(P)
  return { W = 12,
    { S.disc(6, 11, 5.9), P.light }, { S.poly({ { 1.0, 8.4 }, { 6, 0 }, { 11.0, 8.4 } }), P.light },
    { S.arc(6, 11, 3.5, 100, 190, 1.3), BONE },                                                               -- the shine
    { S.disc(4.9, 5.6, .8), BONE },
  }
end
function G.foe.charm(P)
  return { W = 18,
    { S.ell(9, 12.3, 5.6, 4.6), BONE },
    { S.ell(2.6, 8.2, 2.3, 2.7), BONE }, { S.ell(6.6, 3.6, 2.4, 3.0), BONE }, { S.ell(11.4, 3.6, 2.4, 3.0), BONE }, { S.ell(15.4, 8.2, 2.3, 2.7), BONE },
    { S.ell(9, 12.6, 3.3, 2.5), P.base },
    { S.ell(6.7, 3.9, 1.0, 1.5), P.base }, { S.ell(11.3, 3.9, 1.0, 1.5), P.base },
  }
end
function G.foe.soothe(P)
  return { W = 14,
    { S.disc(7.6, 8.5, 8.2), P.light }, { S.disc(11.6, 6.3, 6.9), "cut" },
    { S.star(11.2, 6.0, 4, 3.0, 1.0), BONE },
  }
end
function G.foe.trick(P)
  return { W = 12,
    { S.poly({ { 6.6, 0 }, { 0.6, 9.6 }, { 5.2, 9.6 }, { 3.2, 17 }, { 11.4, 6.4 }, { 6.8, 6.4 }, { 9.8, 0 } }), P.light },
  }
end
function G.foe.item(P)   -- a bone: what a creature carries
  return { W = 18,
    { S.line(4.6, 12.4, 13.4, 4.6, 3.2), BONE },
    { S.disc(2.6, 11.6, 2.3), BONE }, { S.disc(5.2, 14.6, 2.3), BONE }, { S.disc(12.8, 2.4, 2.3), BONE }, { S.disc(15.4, 5.4, 2.3), BONE },
    { S.line(6.4, 10.4, 11.2, 6.2, .9), P.light },
  }
end

-- the environment's ---------------------------------------------------------------------------
function G.env.sun(K)
  local t = { W = 18 }
  for i = 0, 7 do
    local a = math.rad(i * 45)
    t[#t + 1] = { S.line(9 + 6.3 * math.cos(a), 8.5 + 6.3 * math.sin(a), 9 + 8.9 * math.cos(a), 8.5 + 8.9 * math.sin(a), 2.4, 1.0), K.shade }
  end
  t[#t + 1] = { S.disc(9, 8.5, 4.9), K.base }
  t[#t + 1] = { S.disc(7.5, 7.0, 1.7), K.hi }
  return t
end
function G.env.bramble(K)
  return { W = 20,
    { S.poly({ { 3.4, 12.6 }, { 0.6, 6.6 }, { 6.8, 10.4 } }), K.deep }, { S.poly({ { 8.4, 10.4 }, { 12.8, 15.4 }, { 11.8, 8.6 } }), K.deep },   -- thorns
    { S.poly({ { 12.2, 7.6 }, { 9.8, 1.4 }, { 15.2, 5.0 } }), K.deep }, { S.poly({ { 15.4, 5.4 }, { 20, 8.8 }, { 17.8, 3.0 } }), K.deep },
    { S.line(1.4, 15.4, 5, 11.4, 3.0), K.shade }, { S.line(5, 11.4, 9.6, 9.8, 3.0), K.shade }, { S.line(9.6, 9.8, 13.6, 6.2, 3.0), K.shade }, { S.line(13.6, 6.2, 18.6, 1.6, 3.0, 2.0), K.shade },
    { S.line(2.4, 14.0, 5.2, 10.8, 1.0), K.base }, { S.line(5.2, 10.8, 9.4, 9.2, 1.0), K.base }, { S.line(9.4, 9.2, 13.2, 5.8, 1.0), K.base },   -- the lit side of the stem
    { S.lens(5.2, 13.0, 9.6, 16.8, 2.1), K.base },
  }
end
function G.env.rain(K)
  local C, CS = 0xf4f2f6, 0xaaa9b8
  return { W = 18,
    { S.disc(4.8, 6.4, 3.8), C }, { S.disc(9.6, 4.8, 4.8), C }, { S.disc(13.8, 6.6, 3.4), C }, { S.rrect(1.2, 6, 17, 10.2, 1.8), C },
    { S.rect(3.4, 9.2, 15, 10.2), CS },
    { S.line(4.6, 12.2, 3.6, 15.8, 1.3, 2.4), K.shade }, { S.line(9.6, 13.0, 8.6, 16.6, 1.3, 2.4), K.shade }, { S.line(14.4, 12.2, 13.4, 15.8, 1.3, 2.4), K.shade },
  }
end
function G.env.wind(K)
  return { W = 20,
    { S.line(1, 5.8, 11.5, 5.8, 1.8), K.shade }, { S.arc(11.5, 3.0, 2.8, -180, 90, 1.8), K.shade },
    { S.line(1, 9.6, 15.5, 9.6, 1.8), K.shade }, { S.arc(15.5, 12.4, 2.8, -90, 180, 1.8), K.shade },
    { S.line(2.5, 13.6, 9.5, 13.6, 1.8), K.shade },
  }
end
function G.env.mud(K)
  return { W = 20, H = 15,
    { S.ell(10, 10.6, 10, 4.4), K.base },                                                                    -- the puddle
    { S.ell(10, 10.0, 7.4, 2.5), K.shade },                                                                  -- its wet middle
    { S.ell(6.6, 9.4, 2.6, .8), K.hi },
    { S.disc(13.4, 4.2, 2.6), K.base }, { S.disc(12.6, 3.4, .9), K.hi },                                     -- bubbles
    { S.disc(7.6, 3.0, 1.7), K.base }, { S.disc(7.2, 2.6, .5), K.hi },
    { S.disc(17.2, 6.8, 1.1), K.base },
  }
end
function G.env.thorn(K)
  return { W = 18,
    { S.star(9, 8.5, 8, 9.2, 4.3, -90), K.base },
    { S.star(9, 8.5, 8, 5.0, 2.6, -90), K.hi },
    { S.disc(9, 8.5, 1.7), 0xffe38a },
  }
end

-- shade partners: a colour on the lower-right edge of the art goes one step darker
function G.shades(P)
  local t = { [CREAM] = CREAMSH, [BONE] = BONESH, [GOLD] = GOLDSH, [L.WOOD] = L.WOODSH, [0xf4f2f6] = 0xaaa9b8 }
  if P.light then t[P.light] = P.base end
  if P.base and P.shade then t[P.base] = P.shade end
  if P.hi and P.base and not P.light then t[P.hi] = P.base end
  return t
end
function G.make(c, set, name, P)
  local scale = (c.name == "hand") and 30 / 17 or 1
  local art = L.glyph(G[set][name](P), scale, c.name == "hand" and 30 or 17, G.shades(P), c.name == "hand" and 2 or 1)
  return L.centre(c, art)
end
return G
