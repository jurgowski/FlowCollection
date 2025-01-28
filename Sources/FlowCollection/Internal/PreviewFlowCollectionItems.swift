//  Created by Krys Jurgowski on 1/27/25.

import Foundation
import SwiftUI

@Observable
internal final class PreviewFlowCollectionItems: FlowCollectionItems {
    let playback: PreviewPlayback
    var items: [PreviewItem]
    var focusedIndex: Int {
        didSet { playback.focusedId = String(describing: items[focusedIndex].id) }
    }
    
    init(pages: Int, index: Int, playback: PreviewPlayback) {
        self.playback = playback
        self.items = []
        focusedIndex = index
        (0..<pages).forEach { _ in addPage() }
    }
    
    func addPage() {
        items.append(
            PreviewItem(color: colors[items.count % colors.count],
                          page: items.count,
                          playback: playback)
        )
    }
    
    let colors: [Color] = [
        .red.opacity(0.3),
        .blue.opacity(0.3),
        .green.opacity(0.3),
    ]
}

@MainActor
@Observable
internal final class PreviewItem: Identifiable {
    var collection: PreviewFlowCollectionItems {
        guard let innerCollection = innerCollection else {
            let collection = PreviewFlowCollectionItems(pages: 3, index: 1, playback: playback)
            innerCollection = collection
            return collection
        }
        return innerCollection
    }

    let color: Color
    let page: Int
    
    init(color: Color, page: Int, playback: PreviewPlayback) {
        self.color = color
        self.page = page
        self.playback = playback
    }
    
    private let playback: PreviewPlayback
    private var innerCollection: PreviewFlowCollectionItems?
}

@Observable
internal final class PreviewPlayback {
    var focusedId: String = ""
}
