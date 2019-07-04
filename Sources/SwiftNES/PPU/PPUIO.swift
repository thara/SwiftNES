protocol PPUIORegister: class {
    func read(addr: UInt16) -> UInt8?
    func write(addr: UInt16, data: UInt8)
}

extension PPUEmulator: PPUIORegister {

    func read(addr: UInt16) -> UInt8? {
        switch addr {
        case 0x2002:
            return status.rawValue
        case 0x2004:
            return objectAttributeMemoryData
        case 0x2007:
            return data
        default:
            return nil
        }
    }

    func write(addr: UInt16, data: UInt8) {
        switch addr {
        case 0x2000:
            controller = data
        case 0x2001:
            mask = data
        case 0x2003:
            objectAttributeMemoryAddress = data
        case 0x2004:
            objectAttributeMemoryData = data
        case 0x2005:
            scroll = data
        case 0x2006:
            address = data
        case 0x2007:
            self.data = data
        case 0x4014:
            self.objectAttributeMemoryDMA = data
        default:
            break
            // NOP
        }
    }
}
