public extension HTML {
    static func footnote(
        _ text: String
    ) -> any HTMLNode {
        Footnote(text)
    }

    static func footnote(
        content: HTMLFragment
    ) -> any HTMLNode {
        Footnote(
            content: content
        )
    }

    static func footnote(
        @HTMLBuilder _ content: () -> HTMLFragment
    ) -> any HTMLNode {
        Footnote(
            content: content()
        )
    }
}
