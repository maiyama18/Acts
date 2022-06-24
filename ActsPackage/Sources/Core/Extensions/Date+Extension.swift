import Foundation

let yearMonthDateTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY/MM/dd HH:mm"
    return formatter
}()

let monthDateTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd HH:mm"
    return formatter
}()

let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter
}()

let calendar = Calendar(identifier: .gregorian)

public extension Date {
    func dateTimeFormatted() -> String {
        if calendar.isDate(self, equalTo: Date(), toGranularity: .year) {
            return calendar.isDateInToday(self)
                ? timeFormatter.string(from: self)
                : monthDateTimeFormatter.string(from: self)
        } else {
            return yearMonthDateTimeFormatter.string(from: self)
        }
    }
}
