//  Created by Krys Jurgowski on 1/29/25.

import Foundation

public extension FlowCollection {
    func scrollHorizontally(_ horizontal: Bool) -> Self {
        modify { $0.scrollDirection = horizontal ? .horizontal : .vertical }
    }
    
    func isPaging(_ paging: Bool) -> Self {
        modify { $0.paging = paging }
    }
    
    private func modify(_ update: (inout Self) -> Void) -> Self {
        var copy = self
        update(&copy)
        return copy
    }
}
