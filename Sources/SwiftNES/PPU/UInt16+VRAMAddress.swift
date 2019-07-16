/// Extensions for VRAM address
extension UInt16 {

    var nameTableIdx: UInt16 {
        return self & 0b111111111111
    }

    var coarseX: UInt16 {
        return self & 0b11111
    }

    var coarseXScroll: UInt16 {
        return self & 0b11111
    }

    /// Translate index of attribute table from name table
    var attrX: UInt16 {
        return coarseX / 4
    }

    var coarseY: UInt16 {
        return self & 0b1111100000
    }

    var coarseYScroll: UInt16 {
        return coarseY >> 5
    }

    /// Translate index of attribute table from name table
    var attrY: UInt16 {
        return coarseYScroll / 4
    }

    var nameTableSelect: UInt16 {
        return self & 0b110000000000
    }

    var nameTableNo: UInt16 {
        return nameTableSelect >> 10
    }

    var fineY: UInt16 {
        return self & 0b111000000000000
    }

    var fineYScroll: UInt8 {
        return UInt8((self & 0b111000000000000) >> 12)
    }
}
