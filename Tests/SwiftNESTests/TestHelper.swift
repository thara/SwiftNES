func vramAddress(fineYScroll: UInt16 = 0, nameTableNo: UInt16, coarseYScroll: UInt16, coarseXScroll: UInt16) -> UInt16 {
    return (fineYScroll << 12) | (nameTableNo << 10) | (coarseYScroll << 5) | coarseXScroll
}
