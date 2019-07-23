extension PPU {

    func incrCoarseX() {
        guard renderingEnabled else { return }

        if registers.v.coarseXScroll == 31 {
            registers.v &= ~0b11111 // coarse X = 0
            registers.v ^= 0x0400  // switch horizontal nametable
        } else {
            registers.v += 1
        }
    }

    func incrY() {
        guard renderingEnabled else { return }

        if registers.v.fineYScroll < 7 {
            registers.v += 0x1000
        } else {
            registers.v &= ~0x7000 // fine Y = 0

            var y = registers.v.coarseYScroll
            if y == 29 {
                y = 0
                registers.v ^= 0x0800  // switch vertical nametable
            } else if y == 31 {
                y = 0
            } else {
                y += 1
            }

            registers.v = (registers.v & ~0x03E0) | (y << 5)
        }
    }

    func updateHorizontalPosition() {
        guard renderingEnabled else { return }

        registers.v = (registers.v & ~0b010000011111) | (registers.t & 0b010000011111)
    }

    func updateVerticalPosition() {
        guard renderingEnabled else { return }

        registers.v = (registers.v & ~0b101111100000) | (registers.t & 0b101111100000)
    }
}
