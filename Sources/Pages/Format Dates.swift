//
//  File.swift
//  IgniteStarter
//
//  Created by Justin Purnell on 10/2/24.
//

import Foundation
import Ignite

func getYear(_ start: String) -> String {
	let df = DateFormatter()
	df.dateFormat = "yyyy-MM-dd"
	var startDate: Date { return df.date(from: start)! }
	var startComponents: DateComponents { return Calendar.current.dateComponents([.year, .month, .day, .weekday, .hour, .minute], from: startDate) }
	var date: String { return "\(startComponents.year!)" }
	return date
}

func formatDates(_ start: String, end: String?) -> String {
	let df = DateFormatter()
	df.dateFormat = "yyyy-MM-dd"
	var startDate: Date { return df.date(from: start)! }
	var startComponents: DateComponents { return Calendar.current.dateComponents([.year, .month, .day, .weekday, .hour, .minute], from: startDate) }
	var endDate: Date? { guard let endString = end else { return nil }; return df.date(from: endString) }
	var endComponents: DateComponents? { if let endDate { return Calendar.current.dateComponents([.year, .month, .day, .weekday, .hour, .minute, .timeZone], from: endDate) } else { return nil } }
	var dates: String { guard let endComps = endComponents else { return "\(startComponents.year!) - " }; return "\(startComponents.year!) - \(endComps.year!)"}
	return dates
}

func getDate(_ dateString: String) -> Date {
	let df = DateFormatter()
	df.dateFormat = "yyyy-MM-dd"
	return df.date(from: dateString)!
}

func formatDate(_ dateString: String) -> String {
	let df = DateFormatter()
	df.dateStyle = .medium
	return df.string(from: getDate(dateString))
}
