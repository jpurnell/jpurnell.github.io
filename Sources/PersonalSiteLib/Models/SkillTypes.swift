import Foundation

/// Professional skill categories used in the CV.
///
/// Each case maps to a human-readable raw value for display and JSON encoding.
public enum SkillType: String, Codable, CaseIterable {
    case agile = "Agile Methodologies" // LIVE: decoded from cv.json
    case analytics = "Analytics" // LIVE: decoded from cv.json
    case businessAnalysis = "Business Analysis" // LIVE: decoded from cv.json
    case operations = "Company Operations" // LIVE: decoded from cv.json
    case strategyContent = "Content Strategy" // LIVE: decoded from cv.json
    case financeCorporate = "Corporate Finance" // LIVE: decoded from cv.json
    case strategyCorporate = "Corporate Strategy" // LIVE: decoded from cv.json
    case strategyFormulation = "Corporate Strategy Formulation" // LIVE: decoded from cv.json
    case leadershipCrossFunctionalTeam = "Cross-functional Team Leadership" // LIVE: decoded from cv.json
    case dataAnalytics = "Data Analysis" // LIVE: decoded from cv.json
    case dataScience = "Data Science" // LIVE: decoded from cv.json
    case digitalMedia = "Digital Media" // LIVE: decoded from cv.json
    case strategyDigital = "Digital Strategy" // LIVE: decoded from cv.json
    case dueDiligence = "Due Diligence" // LIVE: decoded from cv.json
    case entrepreneurship = "Entrepreneurship" // LIVE: decoded from cv.json
    case execVisibility = "Executive Visibility" // LIVE: decoded from cv.json
    case finance = "Finance" // LIVE: decoded from cv.json
    case financialAnalysis = "Financial Analysis" // LIVE: decoded from cv.json
    case financialModeling = "Financial Modeling" // LIVE: decoded from cv.json
    case leadership = "Leadership" // LIVE: decoded from cv.json
    case management = "Management" // LIVE: decoded from cv.json
    case consultingManagement = "Management Consulting" // LIVE: decoded from cv.json
    case marketPlanning = "Market Planning" // LIVE: decoded from cv.json
    case marketResearch = "Market Research" // LIVE: decoded from cv.json
    case strategyMarketing = "Marketing Strategy" // LIVE: decoded from cv.json
    case msftXLS = "Microsoft Excel" // LIVE: decoded from cv.json
    case msftPPT = "Microsoft PowerPoint" // LIVE: decoded from cv.json
    case msftDOC = "Microsoft Word" // LIVE: decoded from cv.json
    case newMedia = "New Media" // LIVE: decoded from cv.json
    case newVentureDevelopment = "New Venture Development" // LIVE: decoded from cv.json
    case personalization = "Personalization" // LIVE: decoded from cv.json
    case presentations = "Presentations" // LIVE: decoded from cv.json
    case problemSolving = "Problem Solving" // LIVE: decoded from cv.json
    case processImprovement = "Process Improvement" // LIVE: decoded from cv.json
    case productDevelopment = "Product Development" // LIVE: decoded from cv.json
    case productLeadership = "Product Leadership" // LIVE: decoded from cv.json
    case productManagement = "Product Management" // LIVE: decoded from cv.json
    case projectManagement = "Project Management" // LIVE: decoded from cv.json
    case publicSpeaking = "Public Speaking" // LIVE: decoded from cv.json
    case ratioAnalysis = "Ratio Analysis" // LIVE: decoded from cv.json
    case research = "Research" // LIVE: decoded from cv.json
    case socialInfluence = "Social Influence" // LIVE: decoded from cv.json
    case socialMedia = "Social Media" // LIVE: decoded from cv.json
    case stakeholderManagement = "Stakeholder Management" // LIVE: decoded from cv.json
    case strategicPlanning = "Strategic Planning" // LIVE: decoded from cv.json
    case strategicVision = "Strategic Vision" // LIVE: decoded from cv.json
    case strategy = "Strategy" // LIVE: decoded from cv.json
    case swift = "Swift" // LIVE: decoded from cv.json
    case technicalProductManagement = "Technical Product Management" // LIVE: decoded from cv.json
    case ventureCapital = "Venture Capital" // LIVE: decoded from cv.json
    case spanish = "Spanish" // LIVE: decoded from cv.json
    case swiftui = "SwiftUI" // LIVE: decoded from cv.json
    case xcode = "Xcode" // LIVE: decoded from cv.json
    case macos = "macOS" // LIVE: decoded from cv.json
    case windows = "Windows" // LIVE: decoded from cv.json
    case unix = "Unix/Linux" // LIVE: decoded from cv.json
    case keynote = "Keynote" // LIVE: decoded from cv.json
    case bloomberg = "Bloomberg Terminal" // LIVE: decoded from cv.json
    case spss = "SPSS" // LIVE: decoded from cv.json
    case photoshop = "Photoshop" // LIVE: decoded from cv.json
    case finalCut = "Final Cut" // LIVE: decoded from cv.json
    case html = "HTML" // LIVE: decoded from cv.json
    case css = "CSS" // LIVE: decoded from cv.json
}
