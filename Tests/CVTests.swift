import XCTest
@testable import YourModuleName

final class CVTests: XCTestCase {
    var cv: CV!
    
    override func setUp() {
        super.setUp()
        cv = CV()
    }
    
    override func tearDown() {
        cv = nil
        super.tearDown()
    }
    
    func testPersonalInformation() {
        XCTAssertNotNil(cv.personalInfo)
        XCTAssertFalse(cv.personalInfo.name.isEmpty)
        XCTAssertFalse(cv.personalInfo.email.isEmpty)
        // Add more assertions based on your CV structure
    }
    
    func testWorkExperience() {
        XCTAssertFalse(cv.workExperience.isEmpty)
        
        if let firstJob = cv.workExperience.first {
            XCTAssertFalse(firstJob.company.isEmpty)
            XCTAssertFalse(firstJob.position.isEmpty)
            XCTAssertNotNil(firstJob.startDate)
            // Add more specific assertions
        }
    }
    
    func testEducation() {
        XCTAssertFalse(cv.education.isEmpty)
        
        if let education = cv.education.first {
            XCTAssertFalse(education.institution.isEmpty)
            XCTAssertFalse(education.degree.isEmpty)
            XCTAssertNotNil(education.graduationDate)
        }
    }
    
    func testSkills() {
        XCTAssertFalse(cv.skills.isEmpty)
        // Test specific skills if you have categories
    }
} 