import Foundation

/// The type of summary content used in the CV.
public enum SummaryType: String, Codable {
    /// Full curriculum vitae summary.
    case cv
    /// Abbreviated resume summary.
    case resume
    /// Website-specific summary.
    case website
}

/// The top-level curriculum vitae model decoded from `cv.json`.
public struct CurriculumVitae: Codable {
    /// Unique identifier for this CV instance.
    public let id: UUID
    /// Basic personal and contact information.
    public let basics: Basics
    /// Collection of summaries by type (CV, resume, website).
    public let summaries: [Summary]
    /// Professional skills and competencies.
    public let skills: [Skill]
    /// Published works and media appearances.
    public let publications: [Publication]
    /// Professional work history grouped by employer.
    public let work: [Employer]
    /// Academic credentials.
    public let education: [Education]
    /// Volunteer and community leadership roles.
    public let volunteer: [VolunteerRole]
}

/// An image reference used in the CV.
public struct Images: Codable {
    /// Category of image (e.g. "headshot", "logo").
    public let imageType: String
    /// File path or URL for the image asset.
    public let image: String
    /// Alt text describing the image content.
    public let imageDescription: String
}

/// A summary block with priority ordering and type classification.
public struct Summary: Codable {
    /// Sort order — lower values appear first.
    public let priority: Int
    /// Which context this summary targets.
    public let summaryType: SummaryType
    /// The summary text, split into paragraphs.
    public let summary: [String]

    /// Total word count across all paragraphs.
    public var wordCount: Int { return summary.joined(separator: "\n").split { !$0.isLetter }.count }

    /// Total character count across all paragraphs.
    public var charCount: Int { return summary.joined(separator: "\n").count }
}

/// Personal and contact information for the CV owner.
public struct Basics: Codable {
    /// Unique identifier.
    public let id: UUID
    /// Professional label or tagline.
    public let label: String?
    /// First name.
    public let firstName: String
    /// Last name.
    public let lastName: String
    /// URL to a profile picture.
    public let picture: String?
    /// Phone number.
    public let phone: String
    /// Email address.
    public let email: String
    /// Personal website URL.
    public let url: String
    /// Physical location details.
    public let location: Location
    /// Social media profiles.
    public let socialProfiles: [SocialProfile]

    /// Full display name combining first and last name.
    public var name: String { "\(firstName) \(lastName)" }
}

/// A geographic location with address components.
public struct Location: Codable {
    /// Postal or ZIP code.
    public let postalCode: String?
    /// ISO country code.
    public let countryCode: String
    /// City name.
    public let city: String
    /// State or province.
    public let state: String
    /// Street address.
    public let address: String?
}

/// A social media profile reference.
public struct SocialProfile: Codable {
    /// Username on the platform.
    public let username: String
    /// Unique identifier.
    public var id: UUID = UUID()
    /// Profile URL.
    public let url: String
    /// Platform name (e.g. "LinkedIn", "Twitter").
    public let network: String
}

/// A professional skill with proficiency level.
public struct Skill: Codable {
    /// Unique identifier.
    public var id: UUID = UUID()
    /// Proficiency level (e.g. "Expert", "Intermediate").
    public let level: String
    /// Skill name.
    public let name: String
    /// Related keywords or sub-skills.
    public let keywords: [String]
}

/// A company or organization where the CV owner has worked.
public struct Employer: Codable {
    /// Office location.
    public let location: Location
    /// End date of overall employment in "yyyy-MM-dd" format.
    public let endDate: String?
    /// Start date of overall employment in "yyyy-MM-dd" format.
    public let startDate: String?
    /// Company website URL.
    public let url: String?
    /// Individual roles held at this employer.
    public let positions: [Position]
    /// Unique identifier.
    public var id: UUID = UUID()
    /// Company name.
    public let name: String
    /// Overall position title.
    public let position: String?
    /// Schema.org `@type` for JSON-LD (e.g. "Organization", "Corporation"). Defaults to "Organization".
    public var schemaType: String?
}

/// A published work, article, or media appearance.
public struct Publication: Codable {
    /// Unique identifier.
    public var id: UUID = UUID()
    /// Publication date in "yyyy-MM-dd" format.
    public let releaseDate: String
    /// Notable achievements or descriptions.
    public let highlights: [String]
    /// Title of the publication.
    public let name: String
    /// Publisher or outlet name.
    public let publisher: String?
    /// URL to the publication.
    public let url: String
    /// Schema.org `@type` for JSON-LD (e.g. "Article", "SoftwareSourceCode", "TVEpisode"). Defaults to "Article".
    public var schemaType: String?
    /// Whether the CV owner is the author/creator (vs. being mentioned or featured). Defaults to `false`.
    public var isAuthor: Bool?
}

/// A STAR-format story used for behavioral interview preparation.
public struct Story: Codable {
    /// Unique identifier.
    public var id: UUID = UUID()
    /// Story title.
    public let title: String
    /// Brief summary of the story.
    public let summary: String
    /// The situation or context.
    public let situation: String
    /// The task or challenge faced.
    public let task: String
    /// The action taken.
    public let action: String
    /// The result achieved.
    public let result: String
    /// Tags for categorization.
    public let tags: [String]
    /// Whether this story has been used in an interview.
    public let used: Bool
}

/// A specific role or project within an employer or volunteer organization.
public struct Position: Codable {
    /// Office location for this position.
    public let location: Location
    /// Unique identifier.
    public var id: UUID = UUID()
    /// URL for more information about this role.
    public let url: String?
    /// Name of the role or team.
    public let name: String?
    /// End date in "yyyy-MM-dd" format.
    public let endDate: String?
    /// Start date in "yyyy-MM-dd" format.
    public let startDate: String?
    /// Job title.
    public let position: String?
    /// Project or initiative name.
    public let project: String
    /// Key accomplishments.
    public let highlights: [String]
    /// Associated behavioral stories.
    public let stories: [Story]?
    /// Skills used in this position.
    public let skill: [Skill]?

    /// Parsed start date, or `nil` if the date string is missing or invalid.
    public var start: Date? {
        guard let startDate else { return nil }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.date(from: startDate)
    }
}

/// An academic credential.
public struct Education: Codable {
    /// School location.
    public let location: Location
    /// Field of study.
    public let area: String
    /// Graduation date in "yyyy-MM-dd" format.
    public let endDate: String?
    /// Degree type (e.g. "A.B.", "M.B.A.").
    public let studyType: String
    /// Unique identifier.
    public var id: UUID
    /// Enrollment date in "yyyy-MM-dd" format.
    public let startDate: String?
    /// School website URL.
    public let url: String
    /// School name.
    public let institution: String
    /// Grade point average.
    public let gpa: String?
    /// Notable coursework or certificates.
    public let courses: [String]
    /// Positions held at the institution.
    public let positions: [Position]?
    /// Awards or recognition.
    public let recognition: [String]?
}

/// A volunteer or community leadership role.
public struct VolunteerRole: Codable {
    /// Organization location.
    public let location: Location
    /// Organization website URL.
    public let url: String
    /// End date in "yyyy-MM-dd" format.
    public let endDate: String?
    /// Unique identifier.
    public var id: UUID = UUID()
    /// Organization name.
    public let organization: String
    /// Individual positions held within this organization.
    public let positions: [Position]?
    /// Schema.org `@type` for JSON-LD (e.g. "Organization", "EducationalOrganization"). Defaults to "Organization".
    public var schemaType: String?

    /// Earliest start date across all positions, or `nil` if none.
    public var startDate: Date? {
        return positions?.sorted(by: { $0.start ?? .distantPast < $1.start ?? .distantFuture }).first?.start
    }

    /// Earliest start date formatted as "yyyy-MM-dd", or `nil` if unavailable.
    public var start: String? {
        guard let date = startDate else { return nil }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: date)
    }
}
