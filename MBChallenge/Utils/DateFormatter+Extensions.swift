//
//  DateFormatter+Extensions.swift
//  MBChallenge
//
//  Created by Diego Iturrizaga on 18/07/25.
//

import Foundation

extension DateFormatter {
    
    static func formatGuardianDate(_ dateString: String) -> String {
        // Try multiple date formats that The Guardian API might use
        let dateFormats = [
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd HH:mm:ss Z"
        ]
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        for format in dateFormats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return formatDateForDisplay(date)
            }
        }
        
        // If parsing fails, return the original string
        return dateString
    }
    
    private static func formatDateForDisplay(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date, to: now)
        
        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale.current
        
        // If the article is from today, show time
        if let days = components.day, days == 0 {
            displayFormatter.dateStyle = .none
            displayFormatter.timeStyle = .short
            return "Today at \(displayFormatter.string(from: date))"
        }
        // If the article is from yesterday, show "Yesterday"
        else if let days = components.day, days == 1 {
            displayFormatter.dateStyle = .none
            displayFormatter.timeStyle = .short
            return "Yesterday at \(displayFormatter.string(from: date))"
        }
        // If the article is from this year, show date and time
        else if calendar.component(.year, from: date) == calendar.component(.year, from: now) {
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        // If the article is from a different year, show full date
        else {
            displayFormatter.dateStyle = .long
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
    }
} 