import FileTypes

// Reference examples:
//
// HTML.image(
//     "/assets/images/compressed/sky-onder.jpg",
//     widths: [640, 960, 1280],
//     alt: "Hero"
// )
//
// HTML.image(
//     sources: [
//         .init(
//             "/assets/images/compressed/sky-onder.jpg",
//             widths: [640, 960, 1280],
//             media: "(max-width: 768px)"
//         ),
//         .init(
//             "/assets/images/compressed/sitting-v2.jpg",
//             widths: [1280, 1920, 2560],
//             media: "(min-width: 769px)"
//         ),
//     ],
//     policy: .optimized,
//     pictureAttributes: ["class": "hero-banner-image"]
// )
//
// let explicitlyNamed = HTMLImageSourceSet(
//     prefix: "/assets/images/compressed",
//     candidates: [
//         .init("file-760.jpg", 760),
//         .init("file-1280.jpg", 1280),
//     ]
// )

public struct HTMLImageCandidate: Sendable, Hashable {
    public let reference: HTMLImageReference
    public let width: Int

    public init(
        _ reference: HTMLImageReference,
        width: Int
    ) {
        self.reference = reference
        self.width = width
    }

    public init(
        _ value: String,
        width: Int,
        filetype: PhotoFile? = nil
    ) {
        self.init(
            HTMLImageReference(
                value,
                filetype: filetype
            ),
            width: width
        )
    }

    public init(
        _ value: String,
        _ width: Int,
        filetype: PhotoFile? = nil
    ) {
        self.init(
            value,
            width: width,
            filetype: filetype
        )
    }

    public func source(
        as filetype: PhotoFile? = nil
    ) -> String {
        let value = filetype.map(
            reference.source(as:)
        ) ?? reference.fallback

        return "\(value) \(width)w"
    }

    public func prefixed(
        by prefix: String
    ) -> Self {
        let joined: String

        if prefix.isEmpty {
            joined = reference.path
        } else if prefix.hasSuffix("/")
            && reference.path.hasPrefix("/")
        {
            joined = prefix
                + String(
                    reference.path.dropFirst()
                )
        } else if prefix.hasSuffix("/")
            || reference.path.hasPrefix("/")
        {
            joined = prefix + reference.path
        } else {
            joined = prefix + "/" + reference.path
        }

        return Self(
            HTMLImageReference(
                joined + reference.suffix,
                filetype: reference.filetype
            ),
            width: width
        )
    }
}

public struct HTMLImageSourceSet: Sendable, Hashable {
    public let candidates: Set<HTMLImageCandidate>
    public let media: String?
    public let sizes: String

    public init(
        candidates: Set<HTMLImageCandidate>,
        media: String? = nil,
        sizes: String = "100vw"
    ) {
        self.candidates = candidates
        self.media = media
        self.sizes = sizes
    }

    public init(
        _ reference: HTMLImageReference,
        widths: Set<Int>,
        media: String? = nil,
        sizes: String = "100vw"
    ) {
        self.init(
            candidates: Set(
                widths.map { width in
                    HTMLImageCandidate(
                        HTMLImageReference(
                            "\(reference.path)-\(width)\(reference.suffix)",
                            filetype: reference.filetype
                        ),
                        width: width
                    )
                }
            ),
            media: media,
            sizes: sizes
        )
    }

    public init(
        _ value: String,
        widths: Set<Int>,
        filetype: PhotoFile? = nil,
        media: String? = nil,
        sizes: String = "100vw"
    ) {
        self.init(
            HTMLImageReference(
                value,
                filetype: filetype
            ),
            widths: widths,
            media: media,
            sizes: sizes
        )
    }

    public init(
        _ value: String,
        widths: Set<Int>,
        as filetype: PhotoFile,
        media: String? = nil,
        sizes: String = "100vw"
    ) {
        self.init(
            value,
            widths: widths,
            filetype: filetype,
            media: media,
            sizes: sizes
        )
    }

    public init(
        prefix: String,
        candidates: Set<HTMLImageCandidate>,
        media: String? = nil,
        sizes: String = "100vw"
    ) {
        self.init(
            candidates: Set(
                candidates.map {
                    $0.prefixed(
                        by: prefix
                    )
                }
            ),
            media: media,
            sizes: sizes
        )
    }

    public var orderedCandidates: [HTMLImageCandidate] {
        candidates.sorted { lhs, rhs in
            if lhs.width != rhs.width {
                return lhs.width < rhs.width
            }

            return lhs.reference.fallback
                < rhs.reference.fallback
        }
    }

    public var fallbackFiletype: PhotoFile? {
        guard let first =
            orderedCandidates.first?.reference.filetype
        else {
            return nil
        }

        guard orderedCandidates.allSatisfy({
            $0.reference.filetype == first
        }) else {
            return nil
        }

        return first
    }

    public var fallbackReference: HTMLImageReference? {
        orderedCandidates.first?.reference
    }

    public func preferredFiletypes(
        policy: HTMLImagePolicy
    ) -> [PhotoFile] {
        policy.filetypes.filter {
            $0 != fallbackFiletype
        }
    }

    public func attributes(
        as filetype: PhotoFile? = nil
    ) -> HTMLAttribute {
        let srcset = orderedCandidates
            .map {
                $0.source(
                    as: filetype
                )
            }
            .joined(
                separator: ", "
            )

        var attributes: HTMLAttribute = [
            "srcset": srcset,
            "sizes": sizes,
        ]

        if let filetype {
            attributes.merge(
                [
                    "type": filetype.media.rawValue,
                ]
            )
        }

        if let media {
            attributes.merge(
                [
                    "media": media,
                ]
            )
        }

        return attributes
    }
}
