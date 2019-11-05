// http://wiki.nesdev.com/w/index.php/APU#Glossary
class Divider {

    var period: UInt = 0
    var counter: UInt = 0

    var nextClock: () -> ()

    init(nextClock: @escaping () -> ()) {
        self.nextClock = nextClock
    }

    var zero: Bool {
        return counter == 0
    }

    func reload() {
        counter = period
    }

    func clock() {
        if counter == 0 {
            reload()
            nextClock()
        } else {
            counter &-= 1
        }
    }
}
