//  Created by Krys Jurgowski on 12/10/24.

import Foundation
import UIKit
import SwiftUI

public final class FlowCollectionCoordinator<ViewModel: FlowCollectionItems, CellView: View>: NSObject, UICollectionViewDelegateFlowLayout {
    //MARK: - UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    //MARK: - UIScrollViewDelegate
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateIndexIfNeeded(scrollView)
    }
    
    //MARK: - UICollectionViewDelegate
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if targetContentOffset.pointee.y < 0 {
            targetContentOffset.pointee = CGPoint(x: targetContentOffset.pointee.x, y: 0)
        }
        updateIndexIfNeeded(scrollView, contentOffset: targetContentOffset.pointee)
    }

    //MARK: - Internal
    internal init(viewModel: ViewModel, layout: UICollectionViewFlowLayout) {
        self.viewModel = viewModel
        self.layout = layout
    }
    
    let layout: UICollectionViewFlowLayout
    
    var viewModel: ViewModel

    var lastPages: [ViewModel.Item]?
    var lastFocusedIndex: Int?
    
    var diffableDataSource: UICollectionViewDiffableDataSource<Int, ViewModel.Item.ID>!
}

//MARK: - Data Source
extension FlowCollectionCoordinator {
    internal func diffableDataSource(wireCell: @escaping (ViewModel.Item) -> CellView, collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, ViewModel.Item.ID> {
        assert(self.diffableDataSource == nil)
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, ViewModel.Item> {
            cell, indexPath, item in
            cell.contentConfiguration = UIHostingConfiguration {
                wireCell(item)
            }
            .margins(.all, 0)
        }
        let diffableDataSource = UICollectionViewDiffableDataSource<Int, ViewModel.Item.ID>(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                for: indexPath,
                                                                item: self.viewModel.items[indexPath.item])
        }
        self.diffableDataSource = diffableDataSource
        return diffableDataSource
    }
}

//MARK: - Index handling
extension FlowCollectionCoordinator {
    private func updateIndexIfNeeded(_ scrollView: UIScrollView, contentOffset: CGPoint? = nil) {
        let index: Int
        switch layout.scrollDirection {
        case .vertical:     index = Int((contentOffset?.y ?? scrollView.contentOffset.y) / scrollView.bounds.height)
        case .horizontal:   index = Int((contentOffset?.x ?? scrollView.contentOffset.x) / scrollView.bounds.width)
        @unknown default:   index = 0
        }
        guard index < viewModel.items.count else { return }
        viewModel.focusedIndex = index
        lastFocusedIndex = index
    }
}

//MARK: - Updates
extension FlowCollectionCoordinator {
    internal func updateCollection(collectionView: UICollectionView, viewModel: ViewModel, transaction: Transaction) {
        guard viewModel.id == self.viewModel.id else {
            updateViewModel(collectionView: collectionView, viewModel: viewModel, transaction: transaction)
            return
        }
        guard let lastPages, lastPages.map({ $0.id }) == viewModel.items.map({ $0.id }) else {
            updateItems(collectionView: collectionView, viewModel: viewModel, transaction: transaction)
            return
        }
        guard let lastFocusedIndex, lastFocusedIndex == viewModel.focusedIndex else {
            updateFocusedIndex(collectionView: collectionView, viewModel: viewModel, transaction: transaction)
            return
        }
    }
    
    private func updateViewModel(collectionView: UICollectionView, viewModel: ViewModel, transaction: Transaction) {
        self.viewModel = viewModel
        var snapshot = NSDiffableDataSourceSnapshot<Int, ViewModel.Item.ID>()
        snapshot.appendSections([0])
        snapshot.appendItems(viewModel.items.map { $0.id })
        diffableDataSource.applySnapshotUsingReloadData(snapshot) {
            collectionView.scrollToItem(at: IndexPath(row: viewModel.focusedIndex, section: 0),
                                        at: .top,
                                        animated: transaction.animation != nil)
        }
    }
    
    private func updateItems(collectionView: UICollectionView, viewModel: ViewModel, transaction: Transaction) {
        self.lastPages = viewModel.items
        var snapshot = NSDiffableDataSourceSnapshot<Int, ViewModel.Item.ID>()
        snapshot.appendSections([0])
        snapshot.appendItems(viewModel.items.map { $0.id })
        diffableDataSource.apply(snapshot)
    }
    
    private func updateFocusedIndex(collectionView: UICollectionView, viewModel: ViewModel, transaction: Transaction) {
        if viewModel.focusedIndex < 0 {
            viewModel.focusedIndex = 0
        }
        if viewModel.focusedIndex >= viewModel.items.count {
            viewModel.focusedIndex = viewModel.items.count - 1
        }

        self.lastFocusedIndex = viewModel.focusedIndex
        collectionView.scrollToItem(at: IndexPath(row: viewModel.focusedIndex, section: 0),
                                    at: .top,
                                    animated: transaction.animation != nil)
    }
}
