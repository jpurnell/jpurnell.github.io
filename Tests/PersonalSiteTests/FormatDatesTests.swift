import Testing
@testable import PersonalSiteLib

@Suite("Format Dates")
struct FormatDatesTests {

    // MARK: - getYear

    @Test("getYear returns year from valid date string")
    func getYearValid() {
        #expect(getYear("2024-06-15") == "2024")
    }

    @Test("getYear returns empty string for invalid input")
    func getYearInvalid() {
        #expect(getYear("not-a-date") == "")
    }

    @Test("getYear returns empty string for empty input")
    func getYearEmpty() {
        #expect(getYear("") == "")
    }

    // MARK: - getMonth

    @Test("getMonth returns month from valid date string")
    func getMonthValid() {
        #expect(getMonth("2024-06-15") == "6")
    }

    @Test("getMonth returns empty string for invalid input")
    func getMonthInvalid() {
        #expect(getMonth("garbage") == "")
    }

    @Test("getMonth handles January correctly")
    func getMonthJanuary() {
        #expect(getMonth("2024-01-01") == "1")
    }

    @Test("getMonth handles December correctly")
    func getMonthDecember() {
        #expect(getMonth("2024-12-31") == "12")
    }

    // MARK: - getDay

    @Test("getDay returns day from valid date string")
    func getDayValid() {
        #expect(getDay("2024-06-15") == "15")
    }

    @Test("getDay returns empty string for invalid input")
    func getDayInvalid() {
        #expect(getDay("xyz") == "")
    }

    // MARK: - formatDates

    @Test("formatDates returns range with both dates")
    func formatDatesRange() {
        let result = formatDates("2020-01-01", end: "2024-12-31")
        #expect(result == "2020 - 2024")
    }

    @Test("formatDates returns open-ended range with nil end date")
    func formatDatesOpenEnded() {
        let result = formatDates("2020-01-01", end: nil)
        #expect(result == "2020 - ")
    }

    // MARK: - getDate

    @Test("getDate parses valid date string")
    func getDateValid() {
        let date = getDate("2024-06-15")
        #expect(date != .distantPast)
    }

    @Test("getDate returns distantPast for invalid input")
    func getDateInvalid() {
        let date = getDate("invalid")
        #expect(date == .distantPast)
    }

    // MARK: - formatDate

    @Test("formatDate returns non-empty string for valid input")
    func formatDateValid() {
        let result = formatDate("2024-06-15")
        #expect(!result.isEmpty)
        #expect(result.contains("2024"))
    }
}
