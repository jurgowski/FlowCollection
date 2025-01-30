//  Created by Krys Jurgowski on 1/27/25.

import Foundation

@MainActor
public protocol FlowCollectionItems: AnyObject, Observable, Identifiable {
    associatedtype Item: Identifiable

    var items: [Item] { get }
    
    var focusedIndex: Int { get set }
}
