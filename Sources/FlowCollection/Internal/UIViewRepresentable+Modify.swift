//  Created by Krys Jurgowski on 1/27/25.

import Foundation
import SwiftUI

internal extension UIViewRepresentable {
    func modify(_ update: (inout Self) -> Void) -> Self {
        var copy = self
        update(&copy)
        return copy
    }
}
