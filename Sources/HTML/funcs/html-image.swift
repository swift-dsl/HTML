import FileTypes

public extension HTML {
    static func image(
        _ value: String,
        alt: String = "",
        filetype: PhotoFile? = nil,
        policy: HTMLImagePolicy = .optimized,
        pictureAttributes: HTMLAttribute = HTMLAttribute(),
        _ imageAttributes: HTMLAttribute = HTMLAttribute()
    ) -> any HTMLNode {
        image(
            HTMLImageReference(
                value,
                filetype: filetype
            ),
            alt: alt,
            policy: policy,
            pictureAttributes: pictureAttributes,
            imageAttributes
        )
    }

    static func image(
        _ value: String,
        filetype: PhotoFile,
        alt: String = "",
        policy: HTMLImagePolicy = .optimized,
        pictureAttributes: HTMLAttribute = HTMLAttribute(),
        _ imageAttributes: HTMLAttribute = HTMLAttribute()
    ) -> any HTMLNode {
        image(
            HTMLImageReference(
                value,
                filetype: filetype
            ),
            alt: alt,
            policy: policy,
            pictureAttributes: pictureAttributes,
            imageAttributes
        )
    }

    static func image(
        _ value: String,
        as filetype: PhotoFile,
        alt: String = "",
        policy: HTMLImagePolicy = .optimized,
        pictureAttributes: HTMLAttribute = HTMLAttribute(),
        _ imageAttributes: HTMLAttribute = HTMLAttribute()
    ) -> any HTMLNode {
        image(
            HTMLImageReference(
                value,
                as: filetype
            ),
            alt: alt,
            policy: policy,
            pictureAttributes: pictureAttributes,
            imageAttributes
        )
    }

    static func image(
        _ reference: HTMLImageReference,
        alt: String = "",
        policy: HTMLImagePolicy = .optimized,
        pictureAttributes: HTMLAttribute = HTMLAttribute(),
        _ imageAttributes: HTMLAttribute = HTMLAttribute()
    ) -> any HTMLNode {
        let sourceFiletypes = policy.orderedFiletypes(
            for: reference
        )

        guard !sourceFiletypes.isEmpty else {
            return HTML.img(
                src: reference.fallback,
                alt: alt,
                imageAttributes
            )
        }

        return HTML.picture(
            pictureAttributes
        ) {
            for sourceFiletype in sourceFiletypes {
                HTML.source(
                    [
                        "type": sourceFiletype.media.rawValue,
                        "srcset": reference.source(
                            as: sourceFiletype
                        ),
                    ]
                )
            }

            HTML.img(
                src: reference.fallback,
                alt: alt,
                imageAttributes
            )
        }
    }
}
