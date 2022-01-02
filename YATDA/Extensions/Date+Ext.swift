//
//  Date+Ext.swift
//  YATDA
//
//  Created by Scott Bolin on 20-Dec-21.
//

import Foundation

extension Date {
    func formattedRelativeToday() -> String {
        if Calendar.autoupdatingCurrent.isDateInToday(self)
            || Calendar.autoupdatingCurrent.isDateInYesterday(self)
            || Calendar.autoupdatingCurrent.isDateInTomorrow(self) {

            let formatStyle = Date.RelativeFormatStyle(
                presentation: .named,
                unitsStyle: .wide,
                capitalizationContext: .beginningOfSentence)

            return self.formatted(formatStyle)
        }
        else {
            return self.formatted(date: .complete, time: .omitted)
        }
    }

    func nearestHour() -> Date? {
        var components = NSCalendar.current.dateComponents([.minute], from: self)
        let minute = components.minute ?? 0
        components.minute = minute >= 30 ? 60 - minute : -minute
        return Calendar.current.date(byAdding: components, to: self)
    }

    func nextHour(basedOn date: Date? = nil) -> Date? {
        let other = date ?? self

        var timeComponents = Calendar.current.dateComponents([.hour, .minute], from: other)
        let minute = timeComponents.minute ?? 0
        timeComponents.minute = minute >= 0 ? 60 : 0

        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: self)

        let newDateComponents = DateComponents(calendar: Calendar.current,
                                               year: dateComponents.year,
                                               month: dateComponents.month,
                                               day: dateComponents.day,
                                               hour: timeComponents.hour,
                                               minute: timeComponents.minute)

        return Calendar.current.date(from: newDateComponents)
    }

    func startOfDay() -> String {
        let date = Calendar.current.startOfDay(for: self)
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}
