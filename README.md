# 📱 Build Failed Successfully

[![Build Failed Successfully Cover](docs/cover.png)](https://www.youtube.com/watch?v=S01tPLxQiU4)

> A solo deckbuilder where you're a lone mobile developer juggling features, bugs, marketing, and coffee-fueled chaos. Build your app, survive the sprints, and impress management before they pivot to crypto.

This project was entirely Vibe Coded using AI assistance during a live stream!
**This project is currently under active development.**

**Watch the Stream:** [Vibe Coding an Online Card Game with Flutter with Norbert and Simon](https://www.youtube.com/watch?v=S01tPLxQiU4)
**Join us live every Sunday at GMT+2!**

---

## 🌟 Game Concept

You are a lone mobile developer trying to build the next big app. Your goal is to grow your user base from 0 to 1 billion by shipping clever, combo-filled releases. However, you must meet specific user milestones set by management every 10 turns (sprints) to keep your job!

## 🕹️ Gameplay Loop

Each turn (sprint), you:
1. Draw cards until your hand has 5 total.
2. Gain 3 Energy (called "Hours").
3. Play cards (Features, Marketing, Utilities) by spending Hours.
4. Press the **Release** button to ship the build and trigger **OnResolve** effects (mostly from Marketing cards converting Features into Users).
5. Unplayed **Bug** cards trigger their negative effects.
6. Unfixed bugs remain in hand; other played cards go to the discard pile.

Manage your hand, your Hours, and the ever-present Bugs to build powerful release combos and hit those crucial user milestones!

*(For more detailed rules, see `docs/game.md`)*

---

## 🚀 Getting Started (Standard Flutter)

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## ✨ Development Process

This game was developed using an AI pair programmer during a live stream. The goal was to create a functional game with minimal direct coding, relying on AI to generate the Flutter code based on prompts and design documents (`docs/*.md`). Every commit triggered a CI/CD release, allowing viewers to test the game live.

---

## 💡 Got Card Ideas?

We love community contributions! If you have an idea for a new Feature, Marketing card, Bug, or Utility card, please share it with us!

Use the [Card Idea issue template](.github/ISSUE_TEMPLATE/card_idea.md) to submit your suggestion.
