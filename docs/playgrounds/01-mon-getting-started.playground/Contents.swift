import BusinessMath
import Foundation

// Present value: What's $110,000 in 1 year worth today at 10% rate?
let pv = presentValue(
	futureValue: 110_000,
	rate: 0.10,
	periods: 1
)
print("Present value: \(pv.currency())")
// Output: Present value: $100,000.00

// Future value: What will $100K grow to in 5 years at 8%?
let fv = futureValue(
	presentValue: 100_000,
	rate: 0.08,
	periods: 5
)
print("Future value: \(fv.currency())")
// Output: Future value: $146,932.81

	// Create periods at different granularities
	let jan2025 = Period.month(year: 2025, month: 1)
	let q1_2025 = Period.quarter(year: 2025, quarter: 1)
	let fy2025 = Period.year(2025)

	// Period arithmetic
	let feb2025 = jan2025 + 1  // Next month
	let yearRange = jan2025...jan2025 + 11  // Full year

	// Subdivision
	let quarters = fy2025.quarters()  // [Q1, Q2, Q3, Q4]
	let months = q1_2025.months()     // [Jan, Feb, Mar]

let periods = [
	Period.month(year: 2025, month: 1),
	Period.month(year: 2025, month: 2),
	Period.month(year: 2025, month: 3)
]
let revenue: [Double] = [100_000, 120_000, 115_000]

let ts = TimeSeries(periods: periods, values: revenue)

// Access values by period
if let janRevenue = ts[periods[0]] {
	print("January: \(janRevenue.currency())")
}

for (period, value) in zip(periods, ts) {
	print("\(period.label): \(ts[period]!.currency())")
}
	// Cash flows: initial investment, then returns over 5 years
	let cashFlows = [-250_000.0, 100_000, 150_000, 200_000, 250_000, 300_000]

	// Net Present Value at 10% discount rate
	let npvValue = npv(discountRate: 0.10, cashFlows: cashFlows)
print("NPV: \(npvValue.currency())")
	// Output: NPV: $472,168.75 (positive NPV → good investment!)

	// Internal Rate of Return
	let irrValue = try irr(cashFlows: cashFlows)
	print("IRR: \(irrValue.percent())")
	// Output: IRR: 56.72% (impressive return!)

	// Works with Double
	let pvDouble = presentValue(futureValue: 1000.0, rate: 0.05, periods: 10)

	// Works with Float
	let pvFloat: Float = presentValue(futureValue: 1000.0, rate: 0.05, periods: 10)
