/// A model representing a Curriculum Vitae (CV) or resume
/// This class contains all the necessary information for a professional CV
public class CV {
    /// Personal information of the CV owner
    public struct PersonalInfo {
        /// Full name of the person
        public let name: String
        /// Professional email address
        public let email: String
        /// Contact phone number
        public let phone: String?
        /// Professional summary or objective statement
        public let summary: String?
    }
    
    /// Represents a work experience entry
    public struct WorkExperience {
        /// Name of the company or organization
        public let company: String
        /// Job title or position held
        public let position: String
        /// Start date of employment
        public let startDate: Date
        /// End date of employment (nil if current position)
        public let endDate: Date?
        /// Key responsibilities and achievements
        public let responsibilities: [String]
    }
    
    /// Represents an educational qualification
    public struct Education {
        /// Name of the educational institution
        public let institution: String
        /// Degree or qualification obtained
        public let degree: String
        /// Date of graduation
        public let graduationDate: Date
        /// Grade or GPA if applicable
        public let grade: String?
    }
    
    /// Personal information section of the CV
    public let personalInfo: PersonalInfo
    
    /// Collection of work experiences, ordered by date (most recent first)
    public let workExperience: [WorkExperience]
    
    /// Educational background and qualifications
    public let education: [Education]
    
    /// Professional skills and competencies
    public let skills: [String]
    
    /// Initialize a new CV with all required information
    /// - Parameters:
    ///   - personalInfo: Personal and contact information
    ///   - workExperience: Array of work experiences
    ///   - education: Array of educational qualifications
    ///   - skills: Array of professional skills
    public init(
        personalInfo: PersonalInfo,
        workExperience: [WorkExperience],
        education: [Education],
        skills: [String]
    ) {
        self.personalInfo = personalInfo
        self.workExperience = workExperience
        self.education = education
        self.skills = skills
    }
} 