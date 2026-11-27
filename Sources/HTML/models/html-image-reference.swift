import FileTypes

public struct HTMLImageReference:
    Sendable,
    Hashable,
    ExpressibleByStringLiteral
{
    public let path: String
    public let suffix: String
    public let filetype: PhotoFile?

    public init(
        _ value: String,
        filetype: PhotoFile? = nil
    ) {
        let split = Self.splitSuffix(
            from: value
        )

        let embeddedFiletype = try? PhotoFile(
            filename: split.location
        )

        if let embeddedFiletype {
            self.path = String(
                split.location.dropLast(
                    embeddedFiletype.component.count
                )
            )
        } else {
            self.path = split.location
        }

        self.suffix = split.suffix
        self.filetype = filetype ?? embeddedFiletype
    }

    public init(
        _ value: String,
        as filetype: PhotoFile
    ) {
        self.init(
            value,
            filetype: filetype
        )
    }

    public init(
        stringLiteral value: String
    ) {
        self.init(
            value
        )
    }

    public var fallback: String {
        guard let filetype else {
            return path + suffix
        }

        return source(
            as: filetype
        )
    }

    public var supportsAlternativeRepresentations: Bool {
        !path.hasPrefix(
            "data:"
        )
            && !path.hasPrefix(
                "blob:"
            )
    }

    public func source(
        as filetype: PhotoFile
    ) -> String {
        path
            + filetype.component
            + suffix
    }

    private static func splitSuffix(
        from value: String
    ) -> (
        location: String,
        suffix: String
    ) {
        guard let suffixStart = value.firstIndex(
            where: {
                $0 == "?"
                    || $0 == "#"
            }
        ) else {
            return (
                value,
                ""
            )
        }

        return (
            String(
                value[..<suffixStart]
            ),
            String(
                value[suffixStart...]
            )
        )
    }
}

public struct HTMLImagePolicy:
    Sendable,
    Hashable
{
    public let filetypes: [PhotoFile]

    public init(
        filetypes: [PhotoFile]
    ) {
        var seen = Set<PhotoFile>()

        self.filetypes = filetypes.filter {
            seen.insert(
                $0
            ).inserted
        }
    }

    public init(
        _ filetypes: PhotoFile...
    ) {
        self.init(
            filetypes: filetypes
        )
    }

    public static let original = Self()

    public static let optimized = Self(
        .webp
    )

    public static let modern = Self(
        .avif,
        .webp
    )

    public func orderedFiletypes(
        for reference: HTMLImageReference
    ) -> [PhotoFile] {
        guard reference.supportsAlternativeRepresentations else {
            return []
        }

        return filetypes.filter {
            $0 != reference.filetype
        }
    }
}
