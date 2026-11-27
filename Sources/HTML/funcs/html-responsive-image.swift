import FileTypes

public extension HTML {
    static func image(
        _ value: String,
        widths: Set<Int>,
        filetype: PhotoFile? = nil,
        media: String? = nil,
        sizes: String = "100vw",
        alt: String = "",
        policy: HTMLImagePolicy = .optimized,
        pictureAttributes: HTMLAttribute = HTMLAttribute(),
        _ imageAttributes: HTMLAttribute = HTMLAttribute()
    ) -> any HTMLNode {
        image(
            HTMLImageSourceSet(
                value,
                widths: widths,
                filetype: filetype,
                media: media,
                sizes: sizes
            ),
            alt: alt,
            policy: policy,
            pictureAttributes: pictureAttributes,
            imageAttributes
        )
    }

    static func image(
        _ source: HTMLImageSourceSet,
        fallback: HTMLImageReference? = nil,
        alt: String = "",
        policy: HTMLImagePolicy = .optimized,
        pictureAttributes: HTMLAttribute = HTMLAttribute(),
        _ imageAttributes: HTMLAttribute = HTMLAttribute()
    ) -> any HTMLNode {
        image(
            sources: [
                source,
            ],
            fallback: fallback,
            alt: alt,
            policy: policy,
            pictureAttributes: pictureAttributes,
            imageAttributes
        )
    }

    static func image(
        sources: [HTMLImageSourceSet],
        fallback: HTMLImageReference? = nil,
        alt: String = "",
        policy: HTMLImagePolicy = .optimized,
        pictureAttributes: HTMLAttribute = HTMLAttribute(),
        _ imageAttributes: HTMLAttribute = HTMLAttribute()
    ) -> any HTMLNode {
        guard let resolvedFallback = fallback
            ?? sources.last?.fallbackReference
        else {
            return HTML.comment(
                "Image source sets contain no fallback candidate"
            )
        }

        return HTML.picture(
            pictureAttributes
        ) {
            for source in sources {
                for sourceFiletype in source.preferredFiletypes(
                    policy: policy
                ) {
                    HTML.source(
                        source.attributes(
                            as: sourceFiletype
                        )
                    )
                }

                if !source.candidates.isEmpty {
                    HTML.source(
                        source.attributes(
                            as: source.fallbackFiletype
                        )
                    )
                }
            }

            HTML.img(
                src: resolvedFallback.fallback,
                alt: alt,
                imageAttributes
            )
        }
    }
}
