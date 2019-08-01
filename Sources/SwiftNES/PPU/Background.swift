let nameTableFirstAddr: UInt16 = 0x2000
let attrTableFirstAddr: UInt16 = 0x23C0

let tileHeight: UInt16 = 8

struct Background {
    /// value of name table
    var nameTableEntry: UInt8 = 0x00
    /// value of attribute table
    var attrTableEntry: UInt8 = 0x00

    /// 2 planes of 1 tile pattern
    var tempTileFirst: UInt8 = 0x00
    var tempTileSecond: UInt8 = 0x00

    /// general temporary address
    var tempTableAddr: UInt16 = 0x00

    /// 2 planes of 1 tile pattern
    var tilePatternFirst: UInt16 = 0x00
    var tilePatternSecond: UInt16 = 0x00

    var tileAttrLow: UInt8 = 0x00
    var tileAttrHigh: UInt8 = 0x00

    /// 1 quadrant of attrTableEntry
    var tileAttrLowLatch: Bool = false
    var tileAttrHighLatch: Bool = false

    /// Returns pallete index for fine X
    func getPaletteIndex(fineX: UInt8) -> Int {
        // http://wiki.nesdev.com/w/index.php/PPU_palettes#Memory_Map
        let pixelIdx = 15 &- fineX
        let pixel = (tilePatternSecond[pixelIdx] &<< 1) | tilePatternFirst[pixelIdx]

        ppuBackgroundLogger.trace("BG: \(tilePatternFirst.radix2)")

        guard pixel != 0 else {
            return Int(pixel)
        }

        let palleteIdx = 7 &- fineX
        let pallete = (tileAttrHigh[palleteIdx] &<< 1) | tileAttrLow[palleteIdx]
        return Int(pixel | (pallete &<< 2).u16)
    }

    /// Fetch nametable byte : step 1
    mutating func addressNameTableEntry(using v: UInt16) {
        tempTableAddr = nameTableFirstAddr | v.nameTableAddressIndex
    }

    /// Fetch nametable byte : step 2
    mutating func fetchNameTableEntry(from memory: Memory) {
        nameTableEntry = memory.read(at: tempTableAddr)
    }

    /// Fetch attribute table byte : step 1
    mutating func addressAttrTableEntry(using v: UInt16) {
        tempTableAddr = attrTableFirstAddr | v.attributeAddressIndex
    }

    /// Fetch attribute table byte : step 2
    mutating func fetchAttrTableEntry(from memory: Memory, v: UInt16) {
        attrTableEntry = memory.read(at: tempTableAddr)

        // select area
        if v.coarseXScroll[1] == 1 { attrTableEntry &>>= 2 }
        if v.coarseYScroll[1] == 1 { attrTableEntry &>>= 4 }
    }

    /// Fetch tile bitmap low byte : step 1
    mutating func addressTileBitmapLow(using v: UInt16, controller: PPUController) {
        tempTableAddr = controller.bgPatternTableAddrBase &+ (nameTableEntry.u16 &* tileHeight &* 2) &+ v.fineYScroll.u16
    }

    /// Fetch tile bitmap low byte : step 2
    mutating func fetchTileBitmapLow(from memory: Memory) {
        tempTileFirst = memory.read(at: tempTableAddr)
        if 0 < tempTileFirst {
            ppuBackgroundLogger.trace("fetchTileBitmapLow \(tempTileFirst.radix2) \(tempTableAddr.radix16) \(nameTableEntry.radix16)")
        }
    }

    /// Fetch tile bitmap high byte : step 1
    mutating func addressTileBitmapHigh() {
        tempTableAddr &+= tileHeight
    }

    /// Fetch tile bitmap high byte : step 2
    mutating func fetchTileBitmapHigh(from memory: Memory) {
        tempTileSecond = memory.read(at: tempTableAddr)
    }

    mutating func shift() {
        tilePatternFirst &<<= 1
        tilePatternSecond &<<= 1
        tileAttrLow = (tileAttrLow &<< 1) | unsafeBitCast(tileAttrLowLatch, to: UInt8.self)
        tileAttrHigh = (tileAttrHigh &<< 1) | unsafeBitCast(tileAttrHighLatch, to: UInt8.self)
    }

    mutating func reloadShift() {
        tilePatternFirst = (tilePatternFirst & 0xFF00) | tempTileFirst.u16
        tilePatternSecond = (tilePatternSecond & 0xFF00) | tempTileSecond.u16

        tileAttrLowLatch = attrTableEntry[0] == 1
        tileAttrHighLatch = attrTableEntry[1] == 1
    }
}
