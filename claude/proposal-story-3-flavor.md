# PROPOSAL: Story pass 3, flavor text

Status: PROPOSAL ONLY (2026-11-27). No code. Pass 3 of the story: player-facing text drafts.
Superseded in part by `PROPOSAL-HOLLOW-MASTER.md`: section 12, rulings 5 (off-road villages have tiers 0-2) and 15 (Sunsprinkle to Greatcanopy and Rainroot to Thornacre roads are added).
Builds on: `claude/proposal-story-1-base.md` (the Round, cast, stops, signature crops), `claude/proposal-story-2-quests.md` (chapters, errands, file formats).
Voice matched to: `includes/journey.php` (Wren's letters), `data/stops.txt` (ambience), `data/stop_threads.txt`, `stop_chat.txt`, `stop_happenings.txt`, `stop_tier_themes.txt`, `road_lines.txt`, `village_blurbs.txt`, `creatures.txt`.

Conventions in this file:
- Letters use the BBCode and `\n` of `journey.php`. Tokens: `{hearth}` (your Hearth stop's name), `{plaque}` (its plaque line), `{friend}` (a townsfolk friend in the area), `{first}` (the first stop you ever lit), `{name}`, `{place}`, `{folk}` as in `stop_chat.txt`.
- Rows are pipe rows with no pipe inside a field, in the formats of pass 2 section 5.2.
- **Next stops (pass 4, checked against `ROAD_PAIRS` in `roads.php`)**: Olivewhistle to Dunewhisper, Birchbramble to Spicepeak; Dunewhisper to the Greatcanopy and Spicepeak; the Greatcanopy to Thornacre; Thornacre to Spicepeak; Spicepeak to Blossomreach and the Monsoon Tangle. Sunsprinkle and Rainroot have no road to tier 4 (only CB-SA, and SA-OC, a tier 5 door). The pass 3 guesses (Sunsprinkle to Greatcanopy, Rainroot to Thornacre, Dunewhisper to Blossomreach, Greatcanopy to the Monsoon Tangle, Thornacre to the Coralscatter) named roads that do not exist and are corrected in 2.2.
- Two readings I had to pick: section 3 gives 6 ambience lines per band (3 unlit, 3 lit, covering all four times of day between them) and 3 plaque lines per band, each tagged with the tier it suits.

## 1. Voice sheet

**Wren** (letters only, never speech)
1. Opens "Dear friend," (later Field Hand, Pathfinder, Companion, Keeper), signs "Wren". Short paragraphs, one small real thing per paragraph: a jar, a chair, a slow walk over a bridge.
2. Reports, never orders. "The old book said X. I have crossed it out and written Y." She hopes, doubts, notices. She says "I think" and means it.
3. Dry, fond, a little behind you on the road. Names people. One joke per letter at most, and it is usually about someone's dignity (often her own handcart).

**The Stranger**
1. Seven words or fewer, and never a name, a place of origin or a reason.
2. Speaks only about what is in front of them: the tea, the bench, the lamp, the weather on the wick.
3. Thanks are left behind, not said: a button, a trimmed wick, a note under a bench. Never cryptic on purpose. Simply out of practice.

**Pell Quickthistle** (post-gnome)
1. Reads every address aloud, in full, before saying anything else. Never opens, never guesses at, a letter.
2. Measures everything in sack weight and boot leather. Cheerful about being late by a lifetime.
3. Ends with the next address, not a goodbye.

**Warden Hobb Stiles**
1. Counts first, greets second. Everything is a number and then a percentage, to no decimal places.
2. "Not yet, and here is why." He always says exactly what is missing and never sounds cross about it.
3. Feeling shows only as arithmetic going wrong: he rounds up when pleased.

**Ottilie Kettlewick** (cook)
1. Counts chairs, then people, then sighs at the difference. Sets a place for whoever is missing.
2. Talks in pots, ladles and seconds. Praise is a second helping, criticism is "it wants salt".
3. Never says she is lonely. Says the table is "a bit long today".

**Fusby Crumb** (clerk)
1. Speaks in forms: "Form 1: lamp, lit." Stamps things mid-sentence. Objects, then helps.
2. Finds the rule, finds nobody to file it with, files it anyway.
3. Comes round every time, and blames the paperwork for it.

(Spare, one line each. Bodkin and Thrum: two measurements, never the same, both stated as fact. Fenna: every boat has a name and she will tell you it. Morelby: speaks to the ground first, wrong with great confidence. Sorrel: "I am not lost. The map is early." Linnet: answers questions with the next four notes.)

**Banned words and tics**
- Words: destiny, chosen, prophecy, ancient evil, darkness (as a force), curse, doom, hero, saviour, realm, legend(ary), epic, quest (in the text: say errand, job, favour), magic(al) for the Waythread (it is a fungus), awaken, shadow, whisper of, heart of, tapestry, journey as a metaphor, "little did they know", "for the first time in a hundred years" (say "in Hobb's lifetime", "since before the bench").
- Never: exclamation marks in a row, ALL CAPS, questions to the player ("Will you help?"), threats, timers ("hurry", "before it is too late"), anyone thanking you for "saving" anything. Lamps are lit, roofs are mended, beds are planted. Nothing is saved.
- Never: em dashes, semicolons in speech, adverbs doing a verb's job ("said sadly"), three adjectives in a row, a simile where the plain thing will do.
- Creatures are neighbours with bad manners, not monsters. The Long Quiet is nobody's fault and nobody says whose.
- The Waythread glows, hums and wakes. It does not speak, choose, want or call.
- Size check: everything is gnome-sized. A puddle is a pond. A goat is weather.

## 2. Wren's letters

### 2.1 Prologue (replaces `JOURNEY_PROLOGUE`, 120 words)

```
Under every road in the Hollow runs the Waythread, one old fungus that glows where a lamp is lit and boots go by. Once a year the Roundwalkers walked the whole ring of roads. They lit the lamps, mended the benches, carried post and seed, and wrote it down in the Almanac.\n\nThen each walker thought somebody else had the next stretch. Nobody ended the Round. It only became nobody's job. Folk call the years since the Long Quiet.\n\nWren is a bookbinder with a handcart of pages. She wants an Almanac that is true today. Light a stop, plant its bed, come back often, and she will follow one area behind you, on the lit road, with a letter.
```

### 2.2 The 14 Seal letters (`data/journey_letters.txt`, kind `seal`)

Each has the four fixed parts: thanks, correction, Roll piece, doors and next stops. The signature crop is in bold here only for checking; drop the `[b]` if unwanted.

```
L|NA|seal|maplewold-the-lighting|[i]Dear friend,[/i]\n\nI walked in by your road and ate at {hearth}, under the plaque: "{plaque}". The [b]wild rice[/b] was on the table, so the Fens paddy is a paddy again.\n\nThe old book said the Maplewold's lamps "are lit each dusk". Crossed out. I have written: lit, by a friend, who came back.\n\nOne odd thing. The old book's last page has been cut out. I had never noticed.\n\nThe Cairnback Climb and the Northern Rim Pass are open. Cornrow Flats wants a granary, Hedgerow Downs a bridge.\n\n[i]Wren[/i]
L|CA|seal|maizehollow-the-beacon|[i]Dear Field Hand,[/i]\n\n{friend} sold me [b]amaranth[/b] cakes from a stall at {hearth} and would not take a Petal.\n\nThe old book said Maizehollow "wants for nothing". I have written what it wanted, and that it has it.\n\nPell showed me letters marked "The Walker, wherever met". Nobody has collected one in his lifetime.\n\nHobb's brazier is built and nothing answers it yet. If Mistmoor is still in fog, start at Hedgerow Downs. After that, the Ferry Landing on the Tide Track.\n\n[i]Wren[/i]
L|NWE|seal|mistmoor-lamps-in-the-fog|[i]Dear Field Hand,[/i]\n\nI crossed the moor lamp to lamp and counted. At {hearth} there was [b]barley[/b] bread and Bracken's goats asleep under the bench.\n\nThe old book said the moor "cannot be crossed in fog". I have written: it can, and here is where the lamps are.\n\nSomebody has left one lamp lit on the Fells for years. Nobody here will own to it.\n\nThe twin beacon stands. If Maizehollow's is still dark, begin at Cornrow Flats. Then the Fell Pass and the Smugglers' Tide will open together.\n\n[i]Wren[/i]
L|CB|seal|sunsprinkle-the-lighthouse|[i]Dear Pathfinder,[/i]\n\nThe first lit boat went out from {hearth} and every jetty lit behind it. Nettle cried and blamed the spray. Supper was [b]breadfruit[/b], roasted, with nothing on it. It wanted nothing.\n\nThe old book said the Isles "lie beyond the road". Crossed out. The road is wet here, that is all.\n\nA lamp was already burning on the far cay. Nobody keeps that cay.\n\nNo boat goes further from the Isles. The far ring starts on the Mistmoor side, at Olivewhistle and Birchbramble. Rainroot's Canoe Jetty first, if you have not been.\n\n[i]Wren[/i]
L|SA|seal|rainroot-the-canoe-jetty|[i]Dear Pathfinder,[/i]\n\nRowan poured me [b]yerba mate[/b] on the new jetty and we watched your lamps come on down the river, one bend at a time. {friend} sends a wave.\n\nThe old book said the river "cannot be kept". I have written: it is kept at every jetty where someone pours mate.\n\nThe well at {hearth} hums the same four notes as the one at home. Linnet has stopped being surprised.\n\nThe boats south to the Coralscatter wait for a Seal from the far ring. Hobb has the number. Until then, the far ring starts on the Mistmoor side.\n\n[i]Wren[/i]
L|SE|seal|olivewhistle-the-hill-windmill|[i]Dear Pathfinder,[/i]\n\nBread at {hearth}, dipped in the first pressing. Dew says the [b]olive[/b] trees were sulking and you talked them round. I have written "pruned".\n\nThe old book said the mill light "guides the boats". It was a lantern someone left in the loft. Now it is a mill, with a light, on purpose.\n\nWho left the lantern? It had fresh oil in it. Nobody on the Shore buys that kind.\n\nBoats now cross to the Dunewhisper. Start at the oasis and its waterwheel. Take a hat.\n\n[i]Wren[/i]
L|EE|seal|birchbramble-the-drying-barn|[i]Dear Pathfinder,[/i]\n\nThe Drying Barn smells of plums and warm [b]buckwheat[/b], and Ginger has hung your name on a rack. I sat at {hearth} until the storks came in.\n\nThe old book said the steppe "has one road". It has one road and a great many people who now use it.\n\nMorelby says the Waythread does cross water. It is simply deep. He says he always said so.\n\nThe east road climbs to Spicepeak from here. The Tea Terraces first. They will feed you at the top.\n\n[i]Wren[/i]
L|MENA|seal|dunewhisper-the-oasis-waterwheel|[i]Dear Companion,[/i]\n\nI came in at dusk and there was a lamp, then a table, then [b]dates[/b]. Holly kept {hearth} open for me.\n\nThe old book said "no one stops in the Dunes". Everyone stops. There is a table. I sat at it.\n\nA Grey Cloak left a button by my cup and was gone before I looked up.\n\nThe caravan road forks. West to the Greatcanopy (ask for the Storyteller's Platform), east to Spicepeak (the Tea Terraces).\n\n[i]Wren[/i]
L|CSA|seal|spicepeak-the-tea-terraces|[i]Dear Companion,[/i]\n\nSage walked me up the terraces and fed me at each. The hall at {hearth} is yellow to the elbows with [b]turmeric[/b], and so am I.\n\nThe old book said the pass "is for pilgrims". I have written: and for whoever is hungry at the top of it.\n\nThere were flags at the shrine for every lit stop, and one more. Nobody would say whose.\n\nThe high road east is open to Blossomreach. Begin at the Red Bridge. The low road goes to the Monsoon Tangle.\n\n[i]Wren[/i]
L|WCA|seal|greatcanopy-the-storytellers-platform|[i]Dear Companion,[/i]\n\nThey told a new story on the Platform last night. It was about you, and it was mostly true. Afterwards, [b]fonio[/b] from one big pot at {hearth}.\n\nThe old book said the stories "are told nightly". They had stopped. I have written the night they started.\n\nThe Grey Cloaks were here. They are households, friend, not ghosts. They keep the shrines out of habit.\n\nThe river road runs on to Thornacre. Ask for the Waterhole Pump. Bring water.\n\n[i]Wren[/i]
L|ESA|seal|thornacre-the-waterhole-pump|[i]Dear Companion,[/i]\n\nThe pump works. Poppy made me try it. Supper at {hearth} was [b]teff[/b] flatbread, and every seat taken but one. Ottilie set it anyway.\n\nThe old book said the plain "belongs to the herds". It does. The bench under the baobab belongs to everyone else.\n\nA stranger sat with us and left before pudding. There is a page sewn into that coat. I saw the corner.\n\nThe road north-east climbs to Spicepeak, and from its top the high road and the low road go to the far edge. Mind the ostrich.\n\n[i]Wren[/i]
L|EA|seal|blossomreach-the-red-bridge|[i]Dear Keeper,[/i]\n\nThe oldest lamp in Blossomreach lit for you. Fennick says it has refused four mayors. We ate dried [b]persimmon[/b] on the Red Bridge and I got petals in the glue.\n\nThe old book said the Clovercove road "is the short way home". It is closed. I have written closed, in pencil.\n\nThe Stranger was at {hearth} this morning and did not leave. That is new.\n\nTwo stretches remain: the Stilt Boathouse in the Monsoon Tangle and the Reef Garden in the Coralscatter. Then the Gatehouse, I think.\n\n[i]Wren[/i]
L|SEA|seal|monsoon-tangle-the-stilt-boathouse|[i]Dear Keeper,[/i]\n\nIt rained on every page and I did not mind. Moss rowed me under the Boathouse to the paddies. The [b]rice[/b] at {hearth} came in bowls the size of my hat.\n\nThe old book said the paddies "feed the Tangle". They feed three areas. I counted the canoes.\n\nPell's sack is nearly flat. One letter is left and he will not read me the address.\n\nIf the Reef Garden in the Coralscatter or the Red Bridge in Blossomreach is still dark, go there. Otherwise, the Clovercove Gatehouse.\n\n[i]Wren[/i]
L|OC|seal|coralscatter-the-reef-garden|[i]Dear Keeper,[/i]\n\nI stood in the shallows at {hearth} with my boots off and my notebook on my head. The [b]taro[/b] beds run straight into the sea, and nobody can say where garden stops and reef starts.\n\nThe old book said "the reef sings". It hums. Four notes. You know them.\n\nThe Stranger has stopped leaving, Keeper. They are waiting at a gate.\n\nWhen all fourteen sections are bound, the Clovercove road opens from the Blossomreach side. It comes out at the Gatehouse, a short walk from {first}.\n\n[i]Wren[/i]
```

### 2.3 Final-page letter (kind `joint`, chapter `the-last-page`)

```
L|-|joint|the-last-page|[i]Dear Keeper,[/i]\n\nThe old Roll is bound in. I used the good thread. Facing it is a fresh leaf, and it is the one page of this book I did not write. Your line is under the Stranger's. I checked the spelling twice.\n\nOttilie counted the chairs and then counted again, and then sat down, which I have never seen her do. Hobb gave no percentage. Fusby filed the form. The Stranger had two cups of tea and stayed for pudding.\n\nThe old book said the Round "is walked each year". I have not crossed that out. I am going to go and see if it is true.\n\nI have oiled the handcart. I will write from every stop, and I will start with {first}, because you did.\n\nKeep the lamp trimmed. Leave room at the bottom of the page.\n\n[i]Wren[/i]
```

## 3. Band flavor

Ambience rows follow `road_lines.txt` (`cond|...|text`) with one proposed condition, `lit=0` / `lit=1` (stop below tier 1 / tier 1 or better). Chat rows follow `stop_chat.txt` with a proposed condition `gl=` (share of the area's road stops that are lit: `dark` none, `first` at least one, `half` 50%, `seal` Seal held) and are shown to Regulars and up. Plaque rows are alternates for the plaque column of `stop_tier_themes.txt`.

### Band 1, the Maplewold: "The first lamp"

```
dp=dawn/lit=0|band1|The lantern post is cold and has a bird's nest on it. The bird looks settled.
dp=dusk/lit=0|band1|Nobody lights anything. Folk go in early and call it habit.
dp=night/lit=0|band1|Dark to the hedge and dark beyond it. Somebody walks into the post and apologises to it.
dp=day/lit=1|band1|The new bench is taken already. Its owner says he is only testing it.
dp=dusk/lit=1|band1|The lamp is lit at dusk and three doors open to look. Nobody admits to looking.
dp=night/lit=1|band1|One lamp, one bench, moths. Under the road the moss glows faintly, the colour of weak tea.
```
```
gl=dark|any|“We go to bed when the light goes, {name}. Saves candles. Saves conversation.”
gl=first|any|“I could see your lamp from my step last night. First time I’ve looked that way in years.”
gl=half|Grumpy|“Hmph. Lamps every which way. A gnome can’t trip over anything in peace.”
gl=seal|any|“Lit all the way to the Ridge, {name}. My sister walked over. Walked! She’s still here, mind.”
```
```
1|A lamp, lit on purpose.
1|A bench somebody mended and then sat on, to be sure.
4|The first long table in the Maplewold. Three chairs short, and counting.
```

### Band 2, Maizehollow and Mistmoor: "Open the stalls"

```
dp=dawn/lit=0|band2|The stall frames stand empty. A hen has taken the best pitch and pays no rent.
dp=day/lit=0|band2|One cistern, one cup, one queue. The well rope is knotted in four places.
dp=night/lit=0|band2|No lamp to steer by. The fog has the road to itself and seems to like it.
dp=day/lit=1|band2|Awnings up, scales out. Somebody is arguing about the price of beans, happily.
dp=dusk/lit=1|band2|The dusk lantern walk goes by, six lamps and a dog. The dog carries nothing and leads.
dp=night/lit=1|band2|From the step you can see the next lamp, and from there, they say, the next.
```
```
gl=dark|any|“Nothing comes up the road, {name}. Nothing goes down it. We’re very rested.”
gl=first|Chatty|“A pedlar came through. From the next stop! He had news. It was old news, but I hadn’t heard it.”
gl=half|any|“The post came, {name}. Twice. I’ve had to find where I put the letterbox.”
gl=seal|Proud|“Both beacons lit. Hobb says his was answered. He’s told everyone. He’s told me four times.”
```
```
2|A stall with something on it.
2|A scale that weighs fair, and a clerk who checked. Twice.
3|A well that is full, and a cup that is not on a chain.
```

### Band 3, Sunsprinkle, Rainroot, Olivewhistle, Birchbramble: "Across the water"

```
dp=dawn/lit=0|band3|The far shore is a grey line. Nobody on this side has asked what it is called lately.
dp=dusk/lit=0|band3|The ferry bell has a wasp nest in it. The ferry has a tree in it.
dp=night/lit=0|band3|Black water, no lamp. You can hear the other bank, but only its frogs.
dp=dawn/lit=1|band3|The first boat goes out with a lamp on its bow. Someone on the far jetty waves a tea towel.
dp=day/lit=1|band3|Crates going over, crates coming back. The porter says they are the same crates and he is tired.
dp=night/lit=1|band3|A lamp here, a lamp over there, and one long wobbling stripe of light on the water between.
```
```
gl=dark|any|“There’s folk across the water, {name}. I assume. There were when I was small.”
gl=first|Curious|“Somebody lit a lamp over there. I lit ours back. Now neither of us can go to bed.”
gl=half|any|“My cousin came over on the ferry, {name}. I didn’t know I had a cousin. He’s eaten all the plums.”
gl=seal|Cheerful|“The well hums the same tune as theirs! We tried it. We shouted across. They shouted ‘what?’”
```
```
1|A lamp you can see from the other side.
3|A pool that hums four notes. The same four as over there.
3|A well with a boat hook beside it, for hats.
```

### Band 4, Dunewhisper, Spicepeak, Greatcanopy, Thornacre: "The long table"

```
dp=dawn/lit=0|band4|A cold hearth and one cup, upside down on a shelf. The dust on it has dust on it.
dp=day/lit=0|band4|The road runs on to the edge of the sky with nobody on it. The keeper sweeps anyway.
dp=night/lit=0|band4|More stars than anyone needs and not one lamp. A long way off, something small coughs.
dp=day/lit=1|band4|A pot on, a door open. The keeper is counting cups and has found a second one.
dp=dusk/lit=1|band4|Dust on the horizon. The whole stop comes out to watch a stranger arrive for an hour.
dp=night/lit=1|band4|One window lit in all that dark, and inside it a table, and at the table, room.
```
```
gl=dark|any|“You’re the first this season, {name}. You may also be the last. Sit anywhere.”
gl=first|Generous|“I’ve put the big pot on. I know there’s one of you. It’s the principle.”
gl=half|Sleepy|“Mm? Three travellers last night, {name}. All talking. I’d forgotten how loud a table gets.”
gl=seal|any|“Every seat but one, {name}. Ottilie laid it anyway. Somebody left a button on the plate.”
```
```
4|A table at the end of a long walk.
4|A hall where the pot is on whether or not you are coming.
1|A lamp you can see from a day away. We measured.
```

### Band 5, Blossomreach, Monsoon Tangle, Coralscatter: "The far end is the near end"

```
dp=dawn/lit=0|band5|The old lamp stands in blossom to its knees. It has been asked nicely. It is thinking.
dp=day/lit=0|band5|A bright stretch, a dark stretch, a bright stretch. The road here is lit like a badly darned sock.
dp=dusk/lit=0|band5|Rain on a lamp that will not light. The keeper trims the wick all the same and says goodnight to it.
dp=dawn/lit=1|band5|The oldest lamp burns a little green. Nobody knows why. Nobody is going to touch it to find out.
dp=dusk/lit=1|band5|Paper lanterns go down the river past the stop, one for each lit lamp. Children keep count aloud.
dp=night/lit=1|band5|The road glows under the water as well as beside it. The whole shallows hum, four notes, slowly.
```
```
gl=dark|any|“That lamp only likes certain hands, {name}. Not mine. Not my mother’s. We’ve stopped taking it personally.”
gl=first|Curious|“It lit for you? Just like that? I’d like it noted that I loosened it.”
gl=half|any|“They say the road goes all the way round, {name}. I always thought that was something you tell children.”
gl=seal|Cheerful|“A gnome walked in from the west yesterday and out to the east today. Said she was ‘just going round’.”
```
```
1|A lamp that only likes certain hands. Yours, it turns out.
3|A pool where you can hear the road, if you stop talking.
4|A hall at the far end, which is also the near end. Come in either door.
```

## 4. Stop-state text

One line per stop type on arrival. Dark = tier 0 (unadopted or unlit). Pass 4: off-road villages have no tiers (only road villages can be adopted), so for them read `lit` as "the road stop their path leaves from is tier 1+". Relit = shown from tier 1 up, and once in full the first time you arrive after it is lit. Proposed file `data/stop_state.txt`: `type|state (dark/lit)|text`.

```
market|dark|Bare stall frames and a leaning notice board. One woman sells eggs off a windowsill and calls it the market.
market|lit|The lamp is lit over the best bench, and two stalls have turned up to see what the fuss is.
mill|dark|The wheel is green and still. The miller grinds by hand and says the exercise is good for him. It is not.
mill|lit|A lamp over the sack door. The wheel turns, complaining, and the pond has an opinion again.
inn|dark|The sign has lost its paint and the door sticks. There are beds, the innkeeper says, if you do not mind the hens.
inn|lit|Lamp in the porch, fire in the grate. The hens have been moved, under protest.
shrine|dark|Moss to the ankles and no lantern lit. Somebody has left one clean button on the step all the same.
shrine|lit|One stone lantern burns at the foot of the path. The moss around it has started, very faintly, to glow.
jetty|dark|Three planks missing and a bucket with no bottom. An angler sits at the end anyway, out of habit.
jetty|lit|A lamp on the end post. The fish come to look at it, and the anglers have noticed.
herb|dark|The beds have gone to nettles, with one stubborn row of thyme. The herbalist says she is letting it rest.
herb|lit|A lamp at the gate and the first bed dug over. The bees are back and behaving as if they never left.
workshop|dark|The forge is cold and there is a wren in the bellows. The tinker mends kettles on the doorstep, in daylight only.
workshop|lit|The lamp is lit and so is the forge. Somebody is hammering something that did not need it.
orchard|dark|Unpicked trees and wasps in the long grass. The press has a tarpaulin on it and the tarpaulin has a hole.
orchard|lit|A lamp hangs from the first tree. There are ladders out, and an argument about whose ladders.
ferry|dark|The boat is pulled up on the bank with grass growing in it. The ferryman will row you over if you help bail.
ferry|lit|A lamp on the landing and the bell scraped clean. The ferry is in the water and nearly on time.
tower|dark|The beacon basket is empty and there is a jackdaw in it. From the top you can see three dark roads.
tower|lit|The lamp at the foot of the stair is lit. From the top, one road now has a faint line on it, like a snail's.
spring|dark|Warm water, green edges, no lantern. The bath-keeper counts towels and gets to two.
spring|lit|A lamp in the steam, with a halo round it. Somebody has boiled an egg to mark the day.
camp|dark|A ring of logs round a cold black patch. One tent, one kettle, and a wanderer who says it is cosier small.
camp|lit|A lamp on a pole and a fire under it. The ring of logs has more bottoms on it than logs.
```

## 5. Gardening flavor

Proposed columns added to `data/seed_beds.txt`: `bed text (tier 0, shown until the first hand-in)|toast (shown at the first hand-in)`. Two short sentences, then the toast.

```
NA|wild-rice|The paddy is a pond now, and the beavers are polite about it. One clump of rice stands in the corner with its feet wet, waiting.|“To the rice, and to the beavers, who are having some.”
CA|amaranth|A dusty bed behind the mill, mostly thistle. One red amaranth plume leans on the wall like a gnome waiting for a cart.|“To the red stuff. May the mice never learn to climb.”
NWE|barley|Fog sits in the bed like soup in a bowl. There are four barley stalks in it, and the miller knows each by name.|“To four stalks, and all their grandchildren.”
CB|breadfruit|One old tree and a ring of sand where the others stood. It drops a single fruit a year, always on someone.|“To the tree. Mind your heads.”
SA|yerba-mate|A shady croft by the jetty, all vine and no path. The last mate bush is in there somewhere, being modest.|“To the first gourd. Pass it left, and do not say thank you until you are done.”
SE|olive|The terrace wall has slumped and the trees have gone grey and wild. One still fruits, out of spite.|“To the first pressing. It is green and it bites. Good.”
EE|buckwheat|A square of black earth under the barn eaves, gone to dock. One sprig of buckwheat flowers by the door, and the bees queue for it.|“To buckwheat, plain as a boot and twice as useful.”
MENA|date|Three palm stumps and a seedling in a cracked pot, kept alive with the washing-up water. The keeper apologises to it daily.|“To shade in thirty years, and dates rather sooner.”
CSA|turmeric|A plot below the terraces, stony and steep. Somewhere under it one knob of turmeric is keeping its colour to itself.|“To yellow fingers. You will have them all week.”
WCA|fonio|A patch by the hall, fine red dust and a few grass-thin stalks. The grains are so small the cook counts them with her eyes shut.|“To the smallest grain, and to the biggest pot we could find.”
ESA|teff|The bed under the baobab is bare but for one tuft the goats missed. The goats know. They are watching it.|“To teff, and to the fence. Mostly to the fence.”
EA|persimmon|A bare old orchard by the bridge, grey bark and long grass. One tree holds a single orange fruit, like a lamp it forgot to put out.|“To the persimmon. Wait until it is soft. Longer than that.”
SEA|rice|The paddies under the boathouse are all water and no green. One terrace still stands in rows, planted by somebody who did not leave a name.|“To the rows, and to whoever kept them straight.”
OC|taro|The beds run down into the shallows and the walls have let the sea in. A few big leaves still stand in the wet, holding rain like cups.|“To the taro, with its feet in the sea and its head in the weather.”
```

## 6. Three sample side quests (templates)

### 6.1 Lost folk: `na-s01` Within Sight of the Road (`data/journey_errands.txt`)

```
Q|na-s01|NA|1|lost|sorrel-inkpot|tier>=1@zone:1|once|2|c=60,xp=40|page=sorrel-map-na,mark=1|Within Sight of the Road|A satchel hangs on the lantern post, with a note pinned to it: "Gone to map the prairie. Back by tea. S. Inkpot." The stallholder says that was Tuesday. She does not say which Tuesday.|Sorrel unrolls her sheet on the new bench and inks in the lamp, the bench and, after some thought, herself. There is one blank bit left on the prairie. She draws a small question mark in it and hands the page to you. "I was not lost," she says. "The map was early."
S|na-s01|find|sorrel-inkpot|1|-|Find Sorrel Inkpot. She is in the long grass, forty steps from the road, holding her map up to the wrong hill.
S|na-s01|escort|who:sorrel-inkpot,to:stop|1|-|Walk Sorrel to the lit stop. She will stop twice to measure things. Let her.
S|na-s01|visit|segment:lit|1|-|Walk one glowing stretch of road with her. "It goes that way," she says, surprised. "It has gone that way all along."
```

Spare lines for the escort (shown while she is with you, one at random):
```
“Is that north? It feels like north.”
“I had the road a moment ago. I put it down somewhere.”
“Do not tell Wren about the hill.”
```

### 6.2 Creature trouble: `se-s02` Pelicans in Session (`data/journey_errands.txt`)

The outro field holds three endings, `;;` apart, in the order fight, charm, peaceful alt.

```
Q|se-s02|SE|0|creature|ferry|tier>=1@type:ferry|once|28|c=350,xp=600|title=Speaker to Pelicans|Pelicans in Session|The ferry cannot land. Nine pelicans are standing on the landing in a row, facing the same way, and a tenth is addressing them. The toll-keeper says they have been in session since Thursday and have not yet reached a vote.|The Parliament rises in a great flap, with remarks. They sit again on the harbour wall, which they say was the better chamber all along.;;You are heard out in full. The ruling: the landing is yours from dawn to dusk, theirs by night, and the Speaker keeps the left-hand post. It is entered in the minutes, which is a fish.;;Five sardines are moved, seconded and carried to the end of the breakwater. The whole house follows them. The ferry lands, to mild applause from one porter.
S|se-s02|defeat|creature:pelican-parliament|1|deliver:item:sardine:5,to:breakwater|Clear the landing: fight the Pelican Parliament, charm it (ask for a ruling), or carry 5 Sardine to the breakwater.
S|se-s02|visit|stop|1|-|Tell the toll-keeper. He will want it in writing. The pelicans did.
```

### 6.3 Multi-day stop thread: `heron`, The Heron Who Kept the Toll (`data/stop_threads.txt`)

Exact existing format, plus the two optional end fields from pass 2 (trigger, extra). Band 1 thread pay.

```
heron|🪶|The heron who kept the toll|ferry,jetty,herb,camp|NA|c=45:8,xp=16:3,item=rope:2|A grey post ~ There is a heron on the causeway, on one leg, exactly in the middle. Folk have been going round through the reeds and coming home wet.;;What it wants ~ An old stilt-villager says the toll here was always a fish. Nobody has paid it since the toll-keeper left. The heron stayed on.;;A fish a day ~ You lay a small fish on the planks. The heron looks at it, then at you, then eats it and steps one pace to the left. One pace.;;Paid in full ~ It steps aside for good and takes the old toll-post as its seat. From now on it nods folk through, and looks hard at anyone carrying a basket.|found=heron-stilt-village,regular@zone:4|unlock=pal:mw-toll-heron
```

## 7. Where this text lands

| Text | File | New / changed | Notes |
|---|---|---|---|
| Prologue (2.1) | `game/includes/journey.php`, const `JOURNEY_PROLOGUE` | changed | shown by `game/includes/journey_view.php` ("The story so far"); no change needed there |
| 14 Seal letters, final-page letter (2.2, 2.3) | `game/includes/data/journey_letters.txt` | NEW (pass 2) | kind `seal` and `joint`. Until that file exists they replace the outro strings in `journey_seed()` / `journey_seed2()` in `journey.php` |
| Old Tansy / Hollowheart letter text | `game/includes/journey.php` | removed | every outro that mentions Tansy, her notebook or the Hollowheart |
| Band ambience, unlit and lit (3) | `game/includes/data/stops.txt` (ambience column) or a new `data/stop_ambience_band.txt` | changed or NEW | needs the `lit=` condition; `stops.php` picks the line |
| Regular chat lines (3) | `game/includes/data/stop_chat.txt` | changed | needs the `gl=` condition and a Regular check in the chat picker (`stop_folk.php`) |
| Band plaque lines (3) | `game/includes/data/stop_tier_themes.txt` (plaque column), fallback `stop_tiers.txt` | changed | as alternates per band, or as the 12 variant rows of pass 2 |
| Dark and relit arrival text (4) | `game/includes/data/stop_state.txt` | NEW | or two extra columns on `data/stops.txt` |
| Seed-bed descriptions and toasts (5) | `game/includes/data/seed_beds.txt` | NEW (pass 2), two columns added | toast is also usable as the "Restored by" caption on the crop's Almanac page |
| Sample errands (6.1, 6.2) | `game/includes/data/journey_errands.txt` | NEW (pass 2) | 6.2 assumes the outro field can hold three endings |
| Sorrel's escort lines (6.1) | `game/includes/data/journey_errands.txt` or `data/road_meet.txt` | NEW rows | optional |
| Sample thread (6.3) | `game/includes/data/stop_threads.txt` | changed | uses the two optional end fields |
| Voice sheet (1) | this file only | - | reference for later writing passes, not shipped |
