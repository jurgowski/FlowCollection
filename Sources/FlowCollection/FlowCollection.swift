//  Created by Krzysztof Jurgowski on 8/5/22.

import Foundation
import SwiftUI
import UIKit

@MainActor 
public struct FlowCollection<ViewModel: FlowCollectionItems, CellView: View>: View {
    
    /// Collection is backed by a UICollectionView with a UICollectionViewFlowLayout layout.
    ///
    /// - Parameters:
    ///   - viewModel: A view model conforming to CollectionItems
    ///   - wireCell: A view builder constructing the view of each cell.
    public init(_ viewModel: ViewModel, wireCell: @escaping (ViewModel.Item) -> CellView) {
        self.viewModel = viewModel
        self.wireCell = wireCell
        // Observe index changes
        self._focusedIndex = Binding { viewModel.focusedIndex } set: { viewModel.focusedIndex = $0 }
    }

    private let viewModel: ViewModel
    @ViewBuilder private let wireCell: (ViewModel.Item) -> CellView
    @Binding private var focusedIndex: Int
    
    var scrollDirection: UICollectionView.ScrollDirection = .vertical
    var paging = false
}

extension FlowCollection: UIViewRepresentable {
    public func makeUIView(context: Context) -> UICollectionView {
        context.coordinator.layout.scrollDirection = scrollDirection
        context.coordinator.layout.minimumLineSpacing = 0
        context.coordinator.layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: context.coordinator.layout)
        collectionView.delegate = context.coordinator
        collectionView.dataSource = context.coordinator.diffableDataSource(wireCell: wireCell, collectionView: collectionView)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }
    
    public func updateUIView(_ uiView: UICollectionView, context: Context) {
        uiView.isPagingEnabled = paging
        context.coordinator.layout.scrollDirection = scrollDirection
        context.coordinator.updateCollection(collectionView: uiView,
                                             viewModel: viewModel,
                                             transaction: context.transaction)
    }
    
    public func makeCoordinator() -> FlowCollectionCoordinator<ViewModel, CellView> {
        return FlowCollectionCoordinator<ViewModel, CellView>(viewModel: viewModel, layout: UICollectionViewFlowLayout())
    }
}
