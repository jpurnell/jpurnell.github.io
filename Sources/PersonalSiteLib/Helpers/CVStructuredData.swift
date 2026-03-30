import Foundation
import Ignite

/// Builds JSON-LD structured data for the CV page from decoded `cv.json` data.
///
/// Generates a single `@graph` containing Organization, Article, SoftwareApplication,
/// and CreativeWork schemas for all employers, volunteer organizations, and publications.
@MainActor
enum CVStructuredData {

    /// Creates a `StructuredData` element containing a JSON-LD `@graph` with all
    /// CV-related entities: employers, volunteer organizations, and publications.
    static func graph(from cv: CurriculumVitae) -> StructuredData? {
        var graph: [[String: Any]] = []

        graph.append(contentsOf: employerSchemas(from: cv.work))
        graph.append(contentsOf: volunteerSchemas(from: cv.volunteer))
        graph.append(contentsOf: publicationSchemas(from: cv.publications))

        guard !graph.isEmpty else { return nil }

        let wrapper: [String: Any] = [
            "@context": "https://schema.org",
            "@graph": graph
        ]

        guard JSONSerialization.isValidJSONObject(wrapper),
              let data = try? JSONSerialization.data(
                  withJSONObject: wrapper,
                  options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
              ),
              let json = String(data: data, encoding: .utf8)
        else { return nil }

        return StructuredData(json: json)
    }

    // MARK: - Employers

    private static func employerSchemas(from employers: [Employer]) -> [[String: Any]] {
        var schemas: [[String: Any]] = []

        for employer in employers {
            var org: [String: Any] = [
                "@type": "Organization",
                "name": employer.name
            ]
            if let url = employer.url, !url.isEmpty {
                org["url"] = url
            }
            org["address"] = postalAddress(from: employer.location)

            // Add member roles for each position
            var memberOf: [[String: Any]] = []
            for position in employer.positions {
                var role: [String: Any] = [
                    "@type": "OrganizationRole",
                    "roleName": position.position ?? position.project
                ]
                if let start = position.startDate { role["startDate"] = start }
                if let end = position.endDate { role["endDate"] = end }
                if !position.highlights.isEmpty {
                    role["description"] = position.highlights.first ?? ""
                }
                memberOf.append(role)
            }
            if !memberOf.isEmpty {
                org["member"] = [
                    "@type": "Person",
                    "name": "Justin Purnell",
                    "roleName": memberOf
                ] as [String: Any]
            }

            schemas.append(org)
        }

        return schemas
    }

    // MARK: - Volunteer

    private static func volunteerSchemas(from roles: [VolunteerRole]) -> [[String: Any]] {
        var schemas: [[String: Any]] = []

        for role in roles {
            let orgType = educationalOrgs.contains(role.organization)
                ? "EducationalOrganization"
                : "Organization"

            var org: [String: Any] = [
                "@type": orgType,
                "name": role.organization
            ]
            if !role.url.isEmpty {
                org["url"] = role.url
            }
            org["address"] = postalAddress(from: role.location)

            // Add volunteer roles
            if let positions = role.positions, !positions.isEmpty {
                var volunteerRoles: [[String: Any]] = []
                for position in positions {
                    var volRole: [String: Any] = [
                        "@type": "OrganizationRole",
                        "roleName": position.position ?? position.project
                    ]
                    if let start = position.startDate { volRole["startDate"] = start }
                    if let end = position.endDate { volRole["endDate"] = end }
                    if !position.highlights.isEmpty {
                        volRole["description"] = position.highlights.first ?? ""
                    }
                    volunteerRoles.append(volRole)
                }
                org["member"] = [
                    "@type": "Person",
                    "name": "Justin Purnell",
                    "roleName": volunteerRoles
                ] as [String: Any]
            }

            schemas.append(org)
        }

        return schemas
    }

    // MARK: - Publications

    private static func publicationSchemas(from publications: [Publication]) -> [[String: Any]] {
        var schemas: [[String: Any]] = []

        for pub in publications {
            let schemaType = publicationType(for: pub)

            var schema: [String: Any] = [
                "@type": schemaType,
                "name": pub.name,
                "url": pub.url
            ]

            if !pub.releaseDate.isEmpty {
                schema["datePublished"] = pub.releaseDate
            }

            if let publisher = pub.publisher, !publisher.isEmpty {
                schema["publisher"] = [
                    "@type": "Organization",
                    "name": publisher
                ] as [String: Any]
            }

            if !pub.highlights.isEmpty {
                let cleanHighlights = pub.highlights
                    .map { stripHTML($0) }
                    .filter { !$0.isEmpty }
                if !cleanHighlights.isEmpty {
                    schema["description"] = cleanHighlights.joined(separator: " ")
                }
            }

            // Add author for self-authored works
            if selfAuthoredTypes.contains(schemaType) {
                schema["author"] = [
                    "@type": "Person",
                    "name": "Justin Purnell",
                    "url": "https://www.justinpurnell.com"
                ] as [String: Any]
            }

            schemas.append(schema)
        }

        return schemas
    }

    // MARK: - Helpers

    private static func postalAddress(from location: Location) -> [String: String] {
        var address: [String: String] = ["@type": "PostalAddress"]
        address["addressLocality"] = location.city
        address["addressRegion"] = location.state
        address["addressCountry"] = location.countryCode
        if let postal = location.postalCode, !postal.isEmpty {
            address["postalCode"] = postal
        }
        return address
    }

    /// Determines the schema.org type for a publication based on its name and publisher.
    private static func publicationType(for pub: Publication) -> String {
        let name = pub.name.lowercased()
        let publisher = (pub.publisher ?? "").lowercased()

        // Software projects
        if name.contains("businessmath") { return "SoftwareSourceCode" }
        if name.contains("winetaster") { return "MobileApplication" }

        // Film
        if name.contains("sanatorium") { return "Movie" }

        // TV appearances
        if publisher.contains("comedy central") || name.contains("colbert") { return "TVEpisode" }
        if name.contains("late night") || name.contains("conan") { return "TVEpisode" }
        if publisher.contains("national press club") || name.contains("c-span") { return "TVEpisode" }

        // Video content
        if pub.url.contains("vimeo.com") || pub.url.contains("crowdcast") { return "VideoObject" }

        // Default to Article for text publications
        return "Article"
    }

    /// Strips HTML tags from a string for use in descriptions.
    private static func stripHTML(_ string: String) -> String {
        string.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression
        ).trimmingCharacters(in: .whitespaces)
    }

    /// Organizations classified as educational institutions.
    private static let educationalOrgs: Set<String> = [
        "Princeton University",
        "St. Albans School"
    ]

    /// Schema types where Justin is the author (not just mentioned/featured).
    private static let selfAuthoredTypes: Set<String> = [
        "SoftwareSourceCode",
        "MobileApplication"
    ]
}
