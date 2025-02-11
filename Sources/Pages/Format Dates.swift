//
//  File.swift
//  IgniteStarter
//
//  Created by Justin Purnell on 10/2/24.
//

import Foundation
import Ignite

// Shared DateFormatter instance to avoid repeated initialization
private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd"
    return df
}()

/// Extracts the year from a date string in "yyyy-MM-dd" format
/// - Parameter start: Date string in "yyyy-MM-dd" format
/// - Returns: The year as a string, or empty string if invalid
func getYear(_ start: String) -> String {
    guard let date = dateFormatter.date(from: start) else { return "" }
    let year = Calendar.current.component(.year, from: date)
    return year > 0 ? year.description : ""
}

/// Extracts the month from a date string in "yyyy-MM-dd" format
/// - Parameter dateString: Date string in "yyyy-MM-dd" format
/// - Returns: The month as a string (1-12), or empty string if invalid
func getMonth(_ dateString: String) -> String {
    guard let date = dateFormatter.date(from: dateString) else { return "" }
    let month = Calendar.current.component(.month, from: date)
    return (1...12).contains(month) ? month.description : ""
}

/// Extracts the day from a date string in "yyyy-MM-dd" format
/// - Parameter dateString: Date string in "yyyy-MM-dd" format
/// - Returns: The day of month as a string (1-31), or empty string if invalid
func getDay(_ dateString: String) -> String {
    guard let date = dateFormatter.date(from: dateString) else { return "" }
    let day = Calendar.current.component(.day, from: date)
    return (1...31).contains(day) ? day.description : ""
}

/// Formats a date range as "YYYY - YYYY" or "YYYY - " if no end date
/// - Parameters:
///   - start: Start date string in "yyyy-MM-dd" format
///   - end: Optional end date string in "yyyy-MM-dd" format
/// - Returns: Formatted date range string
func formatDates(_ start: String, end: String?) -> String {
    let startYear = getYear(start)
    guard let end = end else { return "\(startYear) - " }
    let endYear = getYear(end)
    return "\(startYear) - \(endYear)"
}

/// Converts a date string to a Date object
/// - Parameter dateString: Date string in "yyyy-MM-dd" format
/// - Returns: Parsed Date object or distant past if invalid
func getDate(_ dateString: String) -> Date {
    return dateFormatter.date(from: dateString) ?? .distantPast
}

/// Formats a date string into a medium style date string
/// - Parameter dateString: Date string in "yyyy-MM-dd" format
/// - Returns: Formatted date string in medium style
func formatDate(_ dateString: String) -> String {
    let df = DateFormatter()
    df.dateStyle = .medium
    return df.string(from: getDate(dateString))
}
