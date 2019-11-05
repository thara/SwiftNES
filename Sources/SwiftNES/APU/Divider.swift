// http://wiki.nesdev.com/w/index.php/APU#Glossary
struct Divider {

    var P: UInt = 0
    var counter: UInt = 0

    var nextClock: () -> ()

    var zero: Bool {
        return counter == 0
    }

    mutating func reload() {
        counter = P
    }

    mutating func clock() {
        if counter == 0 {
            reload()
            nextClock()
        } else {
            counter &-= 1
        }
    }
}
