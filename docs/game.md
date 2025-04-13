# 📱 **Build Failed Successfully**

> A solo deckbuilder where you're a lone mobile developer juggling features, bugs, marketing, and coffee-fueled chaos. Build your app, survive the sprints, and impress management before they pivot to crypto.

---

## 🌟 Objective
Grow your user base from 0 to 1 billion by shipping clever, combo-filled releases every 10 turns. Management expects you to hit specific user milestones to keep your job.

---

## 🕹️ Core Gameplay Loop
Each turn, you:
1. Draw cards until your hand has 5 total (do not discard non-bug cards at end of turn).
2. Gain 3 Energy (called "Hours").
3. Play as many cards as you want (within your Hours limit).
4. Press the **Release** button to ship the build and trigger all **OnResolve** effects.
5. Unplayed bugs trigger their negative effects.
6. Unfixed bugs remain in hand; all other cards are discarded during play, not turn-end.

---

## 🧩 Card Effects: OnPlay vs OnResolve

Every card has one or both of these effects:

### 🔹 OnPlay
- These effects trigger **immediately** when a card is played.
- Examples:
  - Draw a card
  - Gain 2 Hours
  - Discard a random card
  - Remove a bug

### 🔸 OnResolve
- These effects trigger when the player **presses Release**.
- This is the core of your turn: turning Features into Users.
- Most **Marketing** cards use Resolve effects.
- Examples:
  - "For every Feature to the left, gain 2,000 users."
  - "Double the effect of the card to your right."
  - "Trigger all OnResolve effects twice."

> **Note:** Feature cards do **not** have Resolve effects. They serve as building blocks for your Release, which Marketing cards convert into user gain.

---

## 📆 Management Goals
You must meet the following user milestones or get fired:

| Turn | Required Users      |
|------|---------------------|
| 10   | 10,000 users         |
| 20   | 100,000 users        |
| 30   | 500,000 users        |
| 40   | 1,000,000 users      |
| 50+  | Scaling continues... |

Failing to hit a milestone **ends the run**. No second chances.

---

## 🐞 Bug Behavior
Bug cards enter your hand like any other, but must be handled carefully:

- **If played (fixed):** Spend Hours to fix it; no negative effect.
- **If unplayed (ignored):** Bug triggers its effect when you release.
- **After turn ends:** Unfixed bugs remain in hand and continue to clog space.

Bug management is key to maintaining momentum and deck quality.

---

## 🃏 Example Starter Deck: "Version 0.1"

| Card Name         | Type      | Cost (Hours) | OnPlay Effect                | OnResolve Effect                                       | Flavor Text                                | Illustration                        |
|------------------|-----------|---------------|------------------------------|--------------------------------------------------------|--------------------------------------------|-------------------------------------|
| Add a Button      | Feature   | 1             | —                            | —                                                      | "It doesn't do much, but it *does* glow." | A button so shiny, it blinds the bugs.  |
| Pull to Refresh   | Feature   | 1             | —                            | —                                                      | "Because scrolling down is for peasants." | A hand pulling down a refresh icon, with a crown. |
| Dark Mode         | Feature   | 2             | —                            | —                                                      | "Now your app is 38% more modern."        | A vampire enjoying the dark screen.     |
| Tweetstorm        | Marketing | 2             | —                            | Gain 2,000 users for each Feature to the left          | "Just 14 tweets deep and you're trending."| A phone caught in a tornado of tweets.      |
| Push Notification | Marketing | 2             | Draw 1 card                  | +10% bonus user gain                                    | "Ping! You again."                         | A phone with a notification pop-up saying "Guess who?" |
| Product Hunt Post | Marketing | 3             | —                            | +50% user gain for every Feature in your build         | "Launched at midnight. Voted by mom."     | A laptop with a Product Hunt page, and a cat voting.  |
| Crash on Launch   | Bug       | 1             | —                            | −2,500 users                                            | "At least the splash screen looked nice." | A phone with a crash error screen, and a sad face.  |
| Buggy Commit      | Bug       | 1             | —                            | −10% total user gain                                    | "Works on my machine."                    | A developer shrugging at a computer, with a "Not my problem" sign.|
| Code Cleanup      | Utility   | 2             | Remove 1 Bug from your hand, draw 1 card  | —                                                      | "Finally deleted that one TODO from 2022."| A broom sweeping code snippets, with a "Mission Accomplished" banner.     |
| Coffee Refactor   | Utility   | 2             | Draw 2, discard 1            | —                                                      | "Clean code? No, *caffeinated* code."     | A steaming coffee cup on a desk, with a "Java" label.    |
| Microtransaction  | Utility   | 1             | Gain +2 Hours                | —                                                      | "Only costs your soul. And $0.99."        | A coin dropping into a phone slot, with a "Cha-ching!" sound.  |

---

## 🎨 Themes and Archetypes



### 🚀 Feature Spam
Play as many Features as possible. Pair with scaling Marketing cards that reward quantity.
- Works well with: *Tweetstorm*, *Product Hunt Post*
- Weakness: no utility = bug buildup

**Key Cards:**

| Card Name              | Type      | Cost (Hours) | OnPlay Effect | OnResolve Effect                          | Flavor Text                                | Illustration                        |
|------------------------|-----------|---------------|---------------|-------------------------------------------|--------------------------------------------|-------------------------------------|
| Feature Dump           | Feature   | 1             | —             | —                                         | "Just ship everything. It'll be fine."     | A conveyor belt of features, with a "Ship it!" sign.        |
| Form Field Bonanza     | Feature   | 2             | —             | —                                         | "Now with 18 required fields!"             | A form with endless fields, and a user drowning in them.         |
| Tech Demo              | Marketing | 3             | —             | Gain 1,000 users per Feature in play      | "Looks impressive if you squint."          | A flashy tech presentation, with an audience squinting.         |
| Checklist Complete     | Marketing | 2             | —             | For every 2 Features, gain +50% bonus     | "Everything's done. Ship it!"              | A completed checklist on a clipboard, with a "Victory!" stamp.|
| Build in Public        | Marketing | 2             | Gain 500 users per Feature played this turn              | - | "Transparency? Or just free debugging?" | A developer live-streaming their coding session.             |
- **Feature Dump** (Feature, 1h): OnPlay: — | Flavor: "Just ship everything. It'll be fine."
- **Form Field Bonanza** (Feature, 2h): OnPlay: — | Flavor: "Now with 18 required fields!"
- **Tech Demo** (Marketing, 3h): OnResolve: Gain 1,000 users per Feature in play
- **Checklist Complete** (Marketing, 2h): OnResolve: For every 2 Features, gain +50% user bonus
- **Build in Public** (Marketing, 2h): OnResolve: Gain 500 users for each Feature card played this turn | Flavor: "Transparency? Or just free debugging?"

### �� Marketing Machine
Focus on sequencing and positioning to maximize OnResolve chains.
- Cards like: *Echo Chamber* (repeat right card), *Influencer Collab* (triple gain)
- Weakness: needs setup and exact timing

**Key Cards:**

| Card Name           | Type      | Cost (Hours) | OnPlay Effect | OnResolve Effect                                             | Flavor Text                      | Illustration                        |
|---------------------|-----------|---------------|---------------|----------------------------------------------------------------|----------------------------------|-------------------------------------|
| Echo Chamber        | Marketing | 2             | —             | Trigger the OnResolve effect of the card to the right         | "You're totally right. Again."   | A room echoing with voices, all agreeing.         |
| Influencer Collab   | Marketing | 3             | —             | Triple the OnResolve effect of the card to the left           | "We made a TikTok together!"     | Two influencers filming together, with a "#Viral" tag.  |
| Algorithm Surge     | Marketing | 2             | Draw 1        | Gain 500 users per Marketing card played this turn            | "The algo blessed us today."     | A graph surging upwards, with a "Praise the Algo" banner.           |
| Trend Jacker        | Marketing | 1             | —             | Copy the left-most Marketing effect                           | "Ride that trend wave!"          | A surfer riding a digital wave, with a "Cowabunga!" shout.    |
- **Echo Chamber** (Marketing, 2h): OnResolve: Trigger the OnResolve effect of the card to the right
- **Influencer Collab** (Marketing, 3h): OnResolve: Triple the OnResolve effect of the card to the left
- **Algorithm Surge** (Marketing, 2h): OnPlay: Draw 1 | OnResolve: Gain 500 users per Marketing card played this turn
- **Trend Jacker** (Marketing, 1h): OnResolve: Copy the left-most Marketing effect

### 🐛 Bug Farming
Exploit bugs as fuel for energy or combos.
- Example: *Known Issue* (gain 1 Hour per bug), *Crash Monetizer* (+1 card per bug triggered)
- Weakness: volatile if you don't stabilize later

**Key Cards:**

| Card Name           | Type     | Cost (Hours) | OnPlay Effect | OnResolve Effect                                             | Flavor Text                             | Illustration                        |
|---------------------|----------|---------------|---------------|----------------------------------------------------------------|------------------------------------------|-------------------------------------|
| Known Issue         | Utility  | 1             | Gain +1 Hour per Bug in hand             | - | "It's a feature, not a bug."            | A bug with a clock, wearing a "Feature" badge.                 |
| Crash Monetizer     | Utility  | 2             | —             | Draw 1 card per Bug that triggers this turn                   | "Bugs = content."                        | A cash register with bugs, and a "Ka-ching!" sound.          |
| Legacy Codebase     | Bug      | 0             | —             | Shuffle 2 Bugs into your deck                                 | "Nobody knows what this does."          | A dusty old computer, with a "Do Not Touch" sign.               |
| Error Farming       | Utility  | 3             | —             | For every Bug played this turn, gain +1 draw next turn        | "We're pivoting to glitch-based growth."| A farm with error signs, and a farmer shrugging.            |
- **Known Issue** (Utility, 1h): OnResolve: Gain +1 Hour per Bug in hand
- **Crash Monetizer** (Utility, 2h): OnResolve: Draw 1 card per Bug that triggers this turn
- **Legacy Codebase** (Bug, 0h): OnResolve: Shuffle 2 Bugs into your deck | Flavor: "Nobody knows what this does."
- **Error Farming** (Utility, 3h): OnResolve: For every Bug played this turn, gain +1 draw next turn

### ⚙️ Utility Engine
Focus on card draw, hand manipulation, and energy generation.
- Includes: *Nightshift*, *Coffee Refactor*, *Stack Overflow*
- Weakness: indirect scoring, needs combo pieces

**Key Cards:**

| Card Name             | Type     | Cost (Hours) | OnPlay Effect                           | OnResolve Effect     | Flavor Text                            | Illustration                        |
|-----------------------|----------|---------------|-----------------------------------------|----------------------|----------------------------------------|-------------------------------------|
| Nightshift            | Utility  | 2             | Gain +3 Hours                           | —                    | "Sleep is for QA."                     | A moonlit office, with a "No Sleep" poster.                   |
| Stack Overflow        | Utility  | 2             | Draw 3, then discard 1                  | —                    | "Copy-paste with confidence."          | A stack of code snippets, with a "Ctrl+C, Ctrl+V" sign.           |
| Late Night Coding     | Utility  | 1             | Draw 1                                  | Gain +1 Hour         | "Midnight genius coding moment."       | A coder at a dimly lit desk, with a "Eureka!" lightbulb.        |
| Rubber Duck Debugger  | Utility  | 1             | Reveal top card of deck, you may draw  | —                    | "Tell it your problems. It understands."| A rubber duck on a keyboard, with a "Quack!" speech bubble.        |
- **Nightshift** (Utility, 2h): OnPlay: Gain +3 Hours | Flavor: "Sleep is for QA."
- **Stack Overflow** (Utility, 2h): OnPlay: Draw 3, then discard 1 | Flavor: "Copy-paste with confidence."
- **Late Night Coding** (Utility, 1h): OnPlay: Draw 1 | OnResolve: Gain +1 Hour
- **Rubber Duck Debugger** (Utility, 1h): OnPlay: Reveal top card of deck, you may draw it

### 🧪 Experimental Tech
Play cards that change the rules.
- Cards like: *Reverse QA* (bugs buff marketing), *Fail Fast* (release without ending turn)
- Great for risk-taking, unreliable but powerful

**Key Cards:**

| Card Name         | Type     | Cost (Hours) | OnPlay Effect                            | OnResolve Effect                                                | Flavor Text                          | Illustration                        |
|-------------------|----------|---------------|------------------------------------------|------------------------------------------------------------------|--------------------------------------|-------------------------------------|
| Reverse QA        | Utility  | 2             | —                                        | Each Bug gains +1,000 users instead of a penalty this turn       | "If it's broken, market it."        | A bug with a marketing badge, and a "Genius!" label.       |
| Fail Fast         | Utility  | 2             | —                                        | Release immediately without ending turn (once per game)         | "YOLO deploy mode: activated."      | A rocket launching prematurely, with a "Oops!" sign.     |
| Feature Flip      | Utility  | 1             | Swap positions of two cards in play     | —                                                               | "Front becomes back. Chaos ensues." | Two cards flipping positions, with a "Ta-da!" effect.       |
| Chaos Deploy      | Marketing| 3             | —                                        | Trigger all Marketing effects in random order                    | "Spin the wheel of virality."       | A spinning wheel with marketing icons, and a "Round and Round" tune. |
- **Reverse QA** (Utility, 2h): OnResolve: Each Bug card gains +1,000 user value instead of penalty this turn
- **Fail Fast** (Utility, 2h): OnResolve: Release immediately without ending turn (once per game)
- **Feature Flip** (Utility, 1h): OnPlay: Swap positions of two cards in play
- **Chaos Deploy** (Marketing, 3h): OnResolve: Trigger all Marketing effects in random order

---

## 🧠 Strategy Highlights
- Stack Features before Release to maximize Marketing effects.
- Weigh your Hours: will you have time left for Marketing?
- Time your Releases wisely to hit milestones.
- Bugs are slow-burning sabotage—clean them up or build around them.
- Gambling for high-risk cards like **Nightshift** (Gain 3 Hours) might save you late in the turn.

---

## ✨ Future Ideas (Optional Expansions)
- Multiple release types ("Soft Launch", "Patch Update")
- Relics that affect bug handling or feature scaling
- New characters/decks (e.g., "The Consultant", "The Open Source Maintainer")
- Ascension/difficulty levels for replayability

---

*Last updated: April 2025*

