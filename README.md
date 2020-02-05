# SwiftNES

![CI Status for macOS on GitHub Action](https://github.com/thara/SwiftNES/workflows/Swift/badge.svg)
[![CI Status for Ubuntu on CircleCI](https://circleci.com/gh/thara/SwiftNES.svg?style=svg)](https://circleci.com/gh/thara/SwiftNES)

[WIP] Cross-platform NES Emulator written in Swift

## Requirements

- Swift 5.0.1 later
- SDL2
- GD Graphics Library
- libsoundio

## Roadmap

### CPU

- [x] Registers
- [x] Memory map
- [x] Addressing modes
- [x] Official operations
- [x] Unofficial operations
- [x] Interrupt handlers
- [x] Disassembler + nestest logging

### PPU

- [x] Registers
- [x] Memory map
- [x] Background rendering
  - [x] hardware accurate emulation
- [x] Sprite rendering
  - [ ] hardware accurate emulation
- [x] Sprite zero hit
- [x] DMA
- [x] Other flags
- SDL
  - [x] Rendering by line buffer

### APU

- [ ] Pulse wave channels
- [ ] Triangle wave channel
- [ ] Noise channel
- [ ] Sampling by DMC
- [ ] Frame Counter
- [ ] Mixer

### Controllers

- Standard Controller
  - [x] Keyboard
  - [ ] Joypad
  
### Cartridge, Mappers

- [x] Parse iNES file
- [x] Support mapper 0

### Tools

- [ ] Debugger


## Goals

Run and play games in cartridges I bought in childhood.

- [ ] [『スーパーマリオブラザーズ』(Super Mario Bros.) ](https://ja.wikipedia.org/wiki/スーパーマリオブラザーズ)
- [ ] [『スーパーマリオブラザーズ3』(SUPER MARIO BROS. 3)](https://ja.wikipedia.org/wiki/スーパーマリオブラザーズ3)
- [ ] [『4人打ち麻雀』(Four Player Strike Mahjong)](https://ja.wikipedia.org/wiki/ジャン狂)
- [ ] [『ゼルダの伝説』(The Legend of Zelda)](https://ja.wikipedia.org/wiki/ゼルダの伝説)
- [ ] [『戦場の狼』(Commando)](https://ja.wikipedia.org/wiki/戦場の狼)
- [ ] [『迷宮組曲 ミロンの大冒険』(Milon's Secret Castle)](https://ja.wikipedia.org/wiki/迷宮組曲_ミロンの大冒険)
- [ ] [『わんぱくダック夢冒険』(DuckTales)](https://en.wikipedia.org/wiki/DuckTales_(video_game))
- [ ] [『ドラえもん ギガゾンビの逆襲』(Doraemon: Giga Zombie no Gyakushū)](https://ja.wikipedia.org/wiki/ドラえもん_ギガゾンビの逆襲)
- [ ] [『ワリオの森』(Wario's Woods)](https://ja.wikipedia.org/wiki/ワリオの森)
- [ ] [『エグゼドエグゼス』(EXED EXES)](https://ja.wikipedia.org/wiki/エグゼドエグゼス)
- [ ] [『ワギャンランド3』(Wagan Land 3)](https://ja.wikipedia.org/wiki/ワギャンランド#ワギャンランド3)
- [ ] [『ヨッシーのクッキー』(Yoshi's Cookie)](https://ja.wikipedia.org/wiki/ヨッシーのクッキー)

- [ ] [『ぷよぷよ』（Puyo Puyo）](https://ja.wikipedia.org/wiki/ぷよぷよ)

## Author

[thara](https://thara.jp)
