import Foundation

/// Builds JSON-LD graph nodes for the CV page from decoded `cv.json` data.
///
/// Returns an array of Schema.org node dictionaries (Organization, Article,
/// SoftwareApplication, CreativeWork) for employers, volunteer organizations,
/// and publications. These are merged into the site-wide `@graph` by `SiteGraphBuilder`.
enum CVStructuredData {

    /// Returns graph node dictionaries for all CV entities.
    static func graphNodes(from cv: CurriculumVitae) -> [[String: Any]] {
        var nodes: [[String: Any]] = []
        nodes.append(contentsOf: employerSchemas(from: cv.work))
        nodes.append(contentsOf: volunteerSchemas(from: cv.volunteer))
        nodes.append(contentsOf: publicationSchemas(from: cv.publications))
        return nodes
    }

    // MARK: - Employers

    private static func employerSchemas(from employers: [Employer]) -> [[String: Any]] {
        employers.map { employer in
            var org: [String: Any] = [
                "@type": employer.schemaType ?? "Organization",
                "name": employer.name
            ]
            if let url = employer.url, !url.isEmpty {
                org["url"] = url
            }
            org["address"] = postalAddress(from: employer.location)

            let roles = employer.positions.map { position -> [String: Any] in
                var role: [String: Any] = [
                    "@type": "OrganizationRole",
                    "roleName": position.position ?? position.project
                ]
                if let start = position.startDate { role["startDate"] = start }
                if let end = position.endDate { role["endDate"] = end }
                if let first = position.highlights.first { role["description"] = first }
                return role
            }
            if !roles.isEmpty {
                org["member"] = [
                    "@type": "Person",
                    "name": "Justin Purnell",
                    "roleName": roles
                ] as [String: Any]
            }

            return org
        }
    }

    // MARK: - Volunteer

    private static func volunteerSchemas(from roles: [VolunteerRole]) -> [[String: Any]] {
        roles.map { role in
            var org: [String: Any] = [
                "@type": role.schemaType ?? "Organization",
                "name": role.organization
            ]
            if !role.url.isEmpty {
                org["url"] = role.url
            }
            org["address"] = postalAddress(from: role.location)

            if let positions = role.positions, !positions.isEmpty {
                let volunteerRoles = positions.map { position -> [String: Any] in
                    var volRole: [String: Any] = [
                        "@type": "OrganizationRole",
                        "roleName": position.position ?? position.project
                    ]
                    if let start = position.startDate { volRole["startDate"] = start }
                    if let end = position.endDate { volRole["endDate"] = end }
                    if let first = position.highlights.first { volRole["description"] = first }
                    return volRole
                }
                org["member"] = [
                    "@type": "Person",
                    "name": "Justin Purnell",
                    "roleName": volunteerRoles
                ] as [String: Any]
            }

            return org
        }
    }

    // MARK: - Publications

    private static func publicationSchemas(from publications: [Publication]) -> [[String: Any]] {
        publications.map { pub in
            var schema: [String: Any] = [
                "@type": pub.schemaType ?? "Article",
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

            let cleanHighlights = pub.highlights
                .map { stripHTML($0) }
                .filter { !$0.isEmpty }
            if !cleanHighlights.isEmpty {
                schema["description"] = cleanHighlights.joined(separator: " ")
            }

            if pub.isAuthor == true {
                schema["author"] = [
                    "@type": "Person",
                    "name": "Justin Purnell",
                    "url": "https://www.justinpurnell.com"
                ] as [String: Any]
            }

            return schema
        }
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

    /// Strips HTML tags from a string for use in descriptions.
    private static func stripHTML(_ string: String) -> String {
        string.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression
        ).trimmingCharacters(in: .whitespaces)
    }
}
