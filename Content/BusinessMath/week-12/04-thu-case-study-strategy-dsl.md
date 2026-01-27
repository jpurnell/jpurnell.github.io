---
title: Case Study: Investment Strategy DSL with Result Builders
date: 2026-03-27 13:00
series: BusinessMath Quarterly Series
week: 12
post: 4
playground: CaseStudies/InvestmentStrategyDSL.playground
tags: businessmath, swift, case-study, result-builders, dsl, investment-strategy, type-safety, declarative
layout: BlogPostLayout
published: false
---

# Case Study: Investment Strategy DSL with Result Builders

**Case Study #6 of 6 • Capstone for Result Builders + Complete Library**

---

## The Business Challenge

**Company**: Quantitative hedge fund with 15 investment strategies
**Portfolio**: $2B across multiple asset classes
**Challenge**: Encode investment strategies in code that portfolio managers can read, validate, and modify

**Current State (Python/Excel)**:
```python
# Strategy: Growth + Value + Momentum
positions = []
for stock in universe:
    score = 0
    # Growth scoring
    if stock.revenue_growth > 0.15:
        score += 2
    elif stock.revenue_growth > 0.10:
        score += 1

    # Value scoring
    if stock.pe_ratio < sector_median_pe * 0.8:
        score += 2
    elif stock.pe_ratio < sector_median_pe:
        score += 1

    # Momentum scoring
    if stock.returns_6mo > 0.20:
        score += 2
    elif stock.returns_6mo > 0.10:
        score += 1

    if score >= 4:  # Buy threshold
        weight = score / total_score
        positions.append((stock, weight))
```

**Problems**:
1. **Not type-safe**: Typos (`pe_ratio` vs. `p_e_ratio`) fail at runtime
2. **Hard to validate**: Portfolio managers can't easily verify logic
3. **Testing burden**: Each strategy needs 50+ test cases
4. **Duplication**: Same scoring patterns repeated across 15 strategies
5. **No reusability**: Can't compose strategies from building blocks

**The Ask**: "Can we write strategies that read like English but execute like code?"

---

## The Solution: Investment Strategy DSL

Using Swift result builders, we create a domain-specific language where strategies are declarative, type-safe, and composable.

### Part 1: Strategy DSL with Result Builders

```swift
import BusinessMath

// Define a strategy using result builder syntax
@InvestmentStrategyBuilder
var growthValueMomentum: InvestmentStrategy {
    // Strategy metadata
    Name("Growth + Value + Momentum")
    Description("Combines three quantitative factors with equal weighting")
    RebalanceFrequency(.monthly)

    // Universe selection
    Universe {
        Market(.us)
        MinMarketCap(5_000_000_000)  // $5B minimum
        ExcludeSectors([.financials, .utilities])  // Regulated sectors
    }

    // Scoring factors
    ScoringModel {
        // Growth factor
        Factor("Revenue Growth") {
            Metric(\.revenueGrowth)
            Threshold(strong: 0.15, moderate: 0.10)
            Weight(0.33)
        }

        // Value factor
        Factor("Valuation") {
            Metric(\.peRatio)
            Comparison(.lessThan)
            Benchmark(.sectorMedian)
            Threshold(strong: 0.80, moderate: 1.00)
            Weight(0.33)
        }

        // Momentum factor
        Factor("Price Momentum") {
            Metric(\.returns6Month)
            Threshold(strong: 0.20, moderate: 0.10)
            Weight(0.34)
        }
    }

    // Selection and weighting
    Selection {
        ScoreThreshold(4.0)  // Minimum composite score
        MaxPositions(50)
        PositionWeighting(.equalWeight)  // Equal-weight top 50
    }

    // Risk controls
    RiskLimits {
        MaxPositionSize(0.05)  // 5% max per position
        MaxSectorExposure(0.30)  // 30% max per sector
        TargetVolatility(0.15)  // 15% annual volatility
        MaxDrawdown(0.20)  // 20% max drawdown before defensive
    }
}

// The DSL compiles to an executable strategy
let holdings = growthValueMomentum.execute(universe: stockUniverse)

print("Strategy: \(growthValueMomentum.name)")
print("Selected \(holdings.count) positions:")
for holding in holdings.prefix(10) {
    print("  \(holding.ticker): \((holding.weight * 100).number())% (score: \(holding.score.number()))")
}
```

### Part 2: Result Builder Implementation

The magic happens in the `@InvestmentStrategyBuilder`:

```swift
@resultBuilder
struct InvestmentStrategyBuilder {
    // Build strategy from components
    static func buildBlock(_ components: StrategyComponent...) -> InvestmentStrategy {
        InvestmentStrategy(components: components)
    }

    // Support if/else conditionals
    static func buildEither(first component: StrategyComponent) -> StrategyComponent {
        component
    }

    static func buildEither(second component: StrategyComponent) -> StrategyComponent {
        component
    }

    // Support optional components
    static func buildOptional(_ component: StrategyComponent?) -> StrategyComponent {
        component ?? EmptyComponent()
    }

    // Support for loops
    static func buildArray(_ components: [StrategyComponent]) -> StrategyComponent {
        CompositeComponent(components)
    }
}

// Base protocol for all strategy components
protocol StrategyComponent {
    func apply(to strategy: inout InvestmentStrategy)
}

// Example component: Factor definition
struct Factor: StrategyComponent {
    let name: String
    let metric: KeyPath<Stock, Double>
    let threshold: (strong: Double, moderate: Double)
    let weight: Double
    let comparison: ComparisonType

    init(
        _ name: String,
        @FactorBuilder builder: () -> FactorConfiguration
    ) {
        self.name = name
        let config = builder()
        self.metric = config.metric
        self.threshold = config.threshold
        self.weight = config.weight
        self.comparison = config.comparison
    }

    func apply(to strategy: inout InvestmentStrategy) {
        strategy.scoringFactors.append(
            ScoringFactor(
                name: name,
                metric: metric,
                threshold: threshold,
                weight: weight,
                comparison: comparison
            )
        )
    }
}

// Nested result builder for factor configuration
@resultBuilder
struct FactorBuilder {
    static func buildBlock(_ components: FactorConfigComponent...) -> FactorConfiguration {
        var config = FactorConfiguration()
        for component in components {
            component.apply(to: &config)
        }
        return config
    }
}

// Factor configuration components
struct Metric<T>: FactorConfigComponent {
    let keyPath: KeyPath<Stock, T>

    init(_ keyPath: KeyPath<Stock, T>) {
        self.keyPath = keyPath
    }

    func apply(to config: inout FactorConfiguration) {
        config.metric = keyPath as! KeyPath<Stock, Double>
    }
}

struct Threshold: FactorConfigComponent {
    let strong: Double
    let moderate: Double

    func apply(to config: inout FactorConfiguration) {
        config.threshold = (strong, moderate)
    }
}

struct Weight: FactorConfigComponent {
    let value: Double

    init(_ value: Double) {
        self.value = value
    }

    func apply(to config: inout FactorConfiguration) {
        config.weight = value
    }
}
```

### Part 3: Type-Safe Stock Data

The DSL uses Swift key paths for type-safe metric access:

```swift
struct Stock {
    // Company identifiers
    let ticker: String
    let name: String
    let sector: Sector

    // Fundamentals
    let marketCap: Double
    let revenueGrowth: Double
    let earningsGrowth: Double
    let peRatio: Double
    let pbRatio: Double
    let debtToEquity: Double

    // Price data
    let price: Double
    let returns1Month: Double
    let returns6Month: Double
    let returns12Month: Double
    let volatility: Double

    // Valuation
    var relativeValuation: Double {
        // Compare to sector median
        peRatio / sector.medianPE
    }
}

// Key paths provide type safety
let revenueGrowthMetric: KeyPath<Stock, Double> = \.revenueGrowth
let peRatioMetric: KeyPath<Stock, Double> = \.peRatio

// Compiler prevents typos
// let badMetric: KeyPath<Stock, Double> = \.reveueGrowth  // ✗ Compile error!
```

### Part 4: Strategy Execution Engine

The DSL compiles to executable code:

```swift
struct InvestmentStrategy {
    var name: String = ""
    var description: String = ""
    var rebalanceFrequency: RebalanceFrequency = .monthly

    var universeFilters: [UniverseFilter] = []
    var scoringFactors: [ScoringFactor] = []
    var selectionRules: SelectionRules = SelectionRules()
    var riskLimits: RiskLimits = RiskLimits()

    // Execute strategy on stock universe
    func execute(universe: [Stock]) -> [Holding] {
        // 1. Apply universe filters
        let filteredUniverse = universe.filter { stock in
            universeFilters.allSatisfy { $0.passes(stock) }
        }

        // 2. Score each stock
        let scoredStocks = filteredUniverse.map { stock in
            (stock: stock, score: calculateScore(for: stock))
        }

        // 3. Select top stocks
        let selectedStocks = scoredStocks
            .filter { $0.score >= selectionRules.scoreThreshold }
            .sorted { $0.score > $1.score }
            .prefix(selectionRules.maxPositions)

        // 4. Calculate weights
        let holdings = calculateWeights(
            selectedStocks: Array(selectedStocks),
            method: selectionRules.weightingMethod
        )

        // 5. Apply risk limits
        let constrainedHoldings = applyRiskLimits(holdings)

        return constrainedHoldings
    }

    private func calculateScore(for stock: Stock) -> Double {
        var totalScore = 0.0

        for factor in scoringFactors {
            let value = stock[keyPath: factor.metric]
            let benchmark = factor.benchmark?.value(for: stock) ?? 0.0

            let comparison = factor.comparison == .greaterThan ?
                value > benchmark : value < benchmark

            if comparison {
                if factor.threshold.strong > 0 && value >= factor.threshold.strong {
                    totalScore += 2.0 * factor.weight
                } else if factor.threshold.moderate > 0 && value >= factor.threshold.moderate {
                    totalScore += 1.0 * factor.weight
                }
            }
        }

        return totalScore
    }

    private func calculateWeights(
        selectedStocks: [(stock: Stock, score: Double)],
        method: WeightingMethod
    ) -> [Holding] {
        switch method {
        case .equalWeight:
            let weight = 1.0 / Double(selectedStocks.count)
            return selectedStocks.map { Holding(stock: $0.stock, weight: weight, score: $0.score) }

        case .scoreWeighted:
            let totalScore = selectedStocks.map(\.score).reduce(0, +)
            return selectedStocks.map {
                Holding(stock: $0.stock, weight: $0.score / totalScore, score: $0.score)
            }

        case .marketCapWeighted:
            let totalMarketCap = selectedStocks.map { $0.stock.marketCap }.reduce(0, +)
            return selectedStocks.map {
                Holding(stock: $0.stock, weight: $0.stock.marketCap / totalMarketCap, score: $0.score)
            }
        }
    }

    private func applyRiskLimits(_ holdings: [Holding]) -> [Holding] {
        var adjusted = holdings

        // Cap individual positions
        adjusted = adjusted.map { holding in
            var h = holding
            h.weight = min(h.weight, riskLimits.maxPositionSize)
            return h
        }

        // Renormalize to 100%
        let totalWeight = adjusted.map(\.weight).reduce(0, +)
        adjusted = adjusted.map { holding in
            var h = holding
            h.weight = h.weight / totalWeight
            return h
        }

        return adjusted
    }
}

struct Holding {
    let stock: Stock
    var weight: Double
    let score: Double

    var ticker: String { stock.ticker }
}
```

### Part 5: Strategy Composition

Compose complex strategies from building blocks:

```swift
// Reusable factor definitions
let growthFactor = Factor("Revenue Growth") {
    Metric(\.revenueGrowth)
    Threshold(strong: 0.15, moderate: 0.10)
    Weight(0.50)
}

let valueFactor = Factor("Valuation") {
    Metric(\.peRatio)
    Comparison(.lessThan)
    Benchmark(.sectorMedian)
    Threshold(strong: 0.80, moderate: 1.00)
    Weight(0.50)
}

// Compose strategies
@InvestmentStrategyBuilder
var pureGrowth: InvestmentStrategy {
    Name("Pure Growth")
    ScoringModel {
        growthFactor
        // Single factor strategy
    }
}

@InvestmentStrategyBuilder
var growthAtReasonablePrice: InvestmentStrategy {
    Name("Growth at Reasonable Price (GARP)")
    ScoringModel {
        growthFactor
        valueFactor
        // Combines two factors
    }
}

// Conditional strategies
@InvestmentStrategyBuilder
var adaptiveStrategy: InvestmentStrategy {
    Name("Adaptive Multi-Factor")

    ScoringModel {
        if marketCondition == .bull {
            growthFactor  // Growth in bull markets
        } else {
            valueFactor   // Value in bear markets
        }
    }
}
```

---

## The Results

### Code Comparison

**Before (Python)**:
```python
# 150 lines of procedural code
# Repeated logic across 15 strategies
# Runtime errors common
# Hard for PMs to validate
```

**After (Swift DSL)**:
```swift
// 30 lines of declarative code
// Reusable components
// Compile-time type safety
// PMs can read and modify
```

**Code Reduction**: 80% fewer lines per strategy

### Validation and Testing

```swift
// Strategies are testable!
func testGrowthValueMomentumStrategy() {
    let strategy = growthValueMomentum

    // Test universe filtering
    XCTAssertEqual(strategy.universeFilters.count, 3)

    // Test scoring factors
    XCTAssertEqual(strategy.scoringFactors.count, 3)
    XCTAssertEqual(strategy.scoringFactors[0].name, "Revenue Growth")

    // Test with mock data
    let mockUniverse = createMockStocks()
    let holdings = strategy.execute(universe: mockUniverse)

    // Verify risk limits applied
    XCTAssertTrue(holdings.allSatisfy { $0.weight <= 0.05 })
}

// Property-based testing
func testStrategyInvariants() {
    for _ in 0..<100 {
        let randomUniverse = generateRandomStocks(count: 500)
        let holdings = growthValueMomentum.execute(universe: randomUniverse)

        // Invariants that MUST hold
        let totalWeight = holdings.map(\.weight).reduce(0, +)
        XCTAssertEqual(totalWeight, 1.0, accuracy: 1e-6, "Weights must sum to 100%")
        XCTAssertLessOrEqual(holdings.count, 50, "Max 50 positions")
        XCTAssertTrue(holdings.allSatisfy { $0.weight <= 0.05 }, "No position > 5%")
    }
}
```

**Test Coverage**: 15 strategies × 20 tests each = 300 automated tests

---

## Business Value

**Before DSL**:
- Time to code new strategy: 3-5 days (developer-led)
- Strategy validation: 2 days (manual review)
- Bugs per strategy: 8-12 (runtime errors, logic bugs)
- PM involvement: Minimal (couldn't read code)

**After DSL**:
- Time to code new strategy: 2-4 hours (PM can draft, developer refines)
- Strategy validation: 30 minutes (DSL is self-documenting)
- Bugs per strategy: 0-2 (type system catches most errors)
- PM involvement: High (can read, modify, propose strategies)

**Annual Impact**:
- Strategy development speed: 6× faster
- Bugs in production: 85% reduction
- PM productivity: Can now propose 10 strategies/year vs. 2/year
- **Estimated value: $4.2M/year** (faster strategy deployment, fewer errors, more strategies tested)

**Technology ROI**:
- Development time: 6 engineer-weeks (~$45K)
- Payback period: 12 days
- 5-year NPV: $18.4M

---

## What Worked

1. **Domain Expert Empowerment**: Portfolio managers can now write strategies (with light developer support)
2. **Type Safety**: Compiler catches errors that were runtime failures in Python
3. **Composability**: Reusable factor definitions across all 15 strategies
4. **Testability**: Every strategy has 20+ automated tests
5. **Documentation**: Strategies are self-documenting ("reads like English")

---

## What Didn't Work

1. **Initial Learning Curve**: PMs needed 2-day training on Swift basics
2. **Complex Nesting**: Deeply nested result builders got confusing (limited to 2 levels)
3. **Error Messages**: Result builder compile errors can be cryptic (improved with better type annotations)

---

## The Insight

**The best DSL doesn't feel like code—it feels like structured English.**

When a portfolio manager looks at this:
```swift
Factor("Revenue Growth") {
    Metric(\.revenueGrowth)
    Threshold(strong: 0.15, moderate: 0.10)
    Weight(0.50)
}
```

They see: "Revenue growth factor, strong threshold 15%, moderate 10%, weight 50%."

**Not**: "Function call with closure parameter accepting lambda with key path and tuple."

That's the magic of result builders: Hide the machinery, expose the meaning.

And when they try to write:
```swift
Metric(\.reveueGrowth)  // Typo
```

The compiler says: **"No such property 'reveueGrowth' on Stock"**

**That's the magic of type safety: Catch errors at compile time, not in production.**

Combine these two—readable DSL + type safety—and you get something remarkable: **Domain experts writing production code that actually works.**

---

## Try It Yourself

Download the complete case study playground:

```
→ Download: CaseStudies/InvestmentStrategyDSL.playground
→ Includes: Full DSL implementation, 15 strategy examples, test suite
→ Extensions: Add machine learning factors, real-time data feeds
```

---

## Series Conclusion

This is the final post in the 12-week BusinessMath blog series. We've covered:

**Weeks 1-2**: Foundation (getting started, time series, TVM, ratios)
**Weeks 3-5**: Financial Modeling (growth, forecasting, statements, loans, bonds)
**Week 6**: Simulation (Monte Carlo, scenarios)
**Weeks 7-11**: Optimization (gradient descent → BFGS → genetic → PSO → annealing)
**Week 12**: Reflections and this final case study

**6 Case Studies**:
1. Retirement Planning (Week 1)
2. Capital Equipment (Week 3)
3. Option Pricing (Week 6)
4. Portfolio Optimization (Week 8)
5. Real-Time Rebalancing (Week 11)
6. **Investment Strategy DSL (Week 12)** ← You are here

Thank you for following along on this journey. From NPV calculations to GPU-accelerated optimization to type-safe investment strategies—we've built something powerful.

**Now go build something remarkable.**

---

**Series**: [Week 12 of 12] **COMPLETE** | **Case Study [6/6]** **COMPLETE** | **Topics Combined**: Result Builders + Type Safety + Full Library

**The End** 🎉
