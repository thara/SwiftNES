/// Extensions for VRAM address
///
/// https://wiki.nesdev.com/w/index.php/PPU_scrolling#PPU_internal_registers
///
/// yyy NN YYYYY XXXXX
/// ||| || ||||| +++++-- coarse X scroll
/// ||| || +++++-------- coarse Y scroll
/// ||| ++-------------- nametable select
/// +++----------------- fine Y scroll
extension UInt16 {

    var coarseX: UInt16 {
        return self & 0b11111
    }

    var coarseXScroll: UInt16 {
        return self & 0b11111
    }

    var coarseY: UInt16 {
        return self & 0b11_11100000
    }

    var coarseYScroll: UInt16 {
        return coarseY >> 5
    }

    var fineY: UInt16 {
        return self & 0b1110000_00000000
    }

    var fineYScroll: UInt8 {
        return UInt8((self & 0b1110000_00000000) >> 12)
    }

    var nameTableAddressIndex: UInt16 {
        return self & 0b1111_11111111
    }

    var nameTableSelect: UInt16 {
        return self & 0b1100_00000000
    }

    var nameTableNo: UInt16 {
        return nameTableSelect >> 10
    }

    var descriptionAsVRAMAddress: String {
        return "fY=\(fineYScroll.radix16) NT=\(nameTableNo) cY=\(coarseYScroll) cX=\(coarseXScroll)"
    }
}

/// Tile and attribute fetching
/// https://wiki.nesdev.com/w/index.php/PPU_scrolling#Tile_and_attribute_fetching
///
/// NN 1111 YYY XXX
/// || |||| ||| +++-- high 3 bits of coarse X (x/4)
/// || |||| +++------ high 3 bits of coarse Y (y/4)
/// || ++++---------- attribute offset (960 bytes)
/// ++--------------- nametable select
extension UInt16 {

    var coarseXHigh: UInt16 {
        return (self &>> 2) & 0b000111
    }

    var coarseYHigh: UInt16 {
        return (self &>> 4) & 0b111000
    }

    var attributeAddressIndex: UInt16 {
        return nameTableSelect | coarseYHigh | coarseXHigh
    }

    var descriptionAsVRAMTile: String {
        return "NT=\(nameTableNo) cY=\(coarseYHigh >> 3) cX=\(coarseXHigh)"
    }
}
