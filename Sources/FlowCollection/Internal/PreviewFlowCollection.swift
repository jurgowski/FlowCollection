//  Created by Krys Jurgowski on 1/27/25.

import Foundation
import SwiftUI
import UIKit

@MainActor
internal struct PreviewFlowCollection: View {
    let collection: PreviewFlowCollectionItems
    
    var body: some View {
        TabView {
            NavigationStack {
                VStack {
                    FlowCollection(collection) {
                        PreviewPage(collection: collection,
                                    viewModel: $0,
                                    playback: collection.playback)
                    }
                    .isPaging(true)
                }
            }
            .tabItem {
                Label("", systemImage: "square.dotted")
            }
            NavigationStack {
                List {
                    NavigationLink("Horizontal scrolling") {
                        FlowCollection(collection) {
                            PreviewPage(collection: collection,
                                        viewModel: $0,
                                        playback: collection.playback)
                        }
                        .isPaging(true)
                        .scrollHorizontally(false)
                    }
                    NavigationLink("No paging") {
                        FlowCollection(collection) {
                            PreviewPage(collection: collection,
                                        viewModel: $0,
                                        playback: collection.playback)
                        }
                        .isPaging(false)
                    }
                }
            }
            .tabItem {
                Label("", systemImage: "list.bullet")
            }
        }
    }
}

@MainActor
private struct PreviewPage: View {
    let collection: PreviewFlowCollectionItems
    var viewModel: PreviewItem
    let playback: PreviewPlayback
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Page \(viewModel.page + 1) / \(collection.items.count)").bold()
            Text("Page id: \(String(describing:viewModel.id).suffix(8).dropLast())")
            Text("Focused id: \(playback.focusedId.suffix(8).dropLast())")
            NavigationLink("Inner Collection ➡") {
                FlowCollection(viewModel.collection) {
                    PreviewPage(collection: viewModel.collection,
                                viewModel: $0,
                                playback: playback)
                }
            }
            Button("Add Page", systemImage: "plus.circle") {
                withAnimation { collection.addPage() }
            }
            if (viewModel.page > 0) {
                Button("Scroll to Prev Page") {
                    withAnimation { collection.focusedIndex -= 1 }
                }
            }
            if (viewModel.page < collection.items.count - 1) {
                Button("Scroll to Next Page") {
                    withAnimation { collection.focusedIndex += 1 }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(viewModel.color)
    }
}

//MARK: - Preview
#Preview {
    PreviewFlowCollection(collection: PreviewFlowCollectionItems(pages: 6, index: 3, playback: PreviewPlayback()))
}
