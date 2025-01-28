//  Created by Krys Jurgowski on 1/27/25.

import Foundation
import SwiftUI

@MainActor
internal struct PreviewCollection: View {
    let collection: PreviewCollectionItems
    
    var body: some View {
        TabView {
            NavigationStack {
                HStack {
                    Button("", systemImage: "minus.circle") {
                        withAnimation { collection.focusedIndex -= 1 }
                    }
                    Text(String(collection.focusedIndex))
                    Button("", systemImage: "plus.circle") {
                        withAnimation { collection.focusedIndex += 1 }
                    }
                }
                
                VStack {
                    FlowCollection(collection) {
                        PreviewPage(viewModel: $0, playback: collection.playback)
                    }
                    Button("", systemImage: "plus.circle") {
                        withAnimation { collection.addPage() }
                    }.padding()
                }
            }
            .tabItem {
                Label("", systemImage: "square.dotted")
            }
            NavigationStack {
                List {
                    ForEach(collection.items) { page in
                        NavigationLink("Go to \(page.page)") {
                            FlowCollection(page.collection) {
                                PreviewPage(viewModel: $0, playback: collection.playback)
                            }
                        }
                    }
                    
                }
            }.tabItem {
                Label("", systemImage: "list.bullet")
            }
        }
    }
}

@MainActor
private struct PreviewPage: View {
    var viewModel: PreviewItem
    let playback: PreviewPlayback
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Page \(viewModel.page)").bold()
            Text(String(describing:viewModel.id))
            NavigationLink("Inner Collection") {
                FlowCollection(viewModel.collection) {
                    PreviewPage(viewModel: $0, playback: playback)
                }
            }
            Text(playback.focusedId)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(viewModel.color)
    }
}
