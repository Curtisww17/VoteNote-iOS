//
//  EnvironmentVariables.swift
//  VoteNote
//
//  Created by Wesley Curtis on 2/13/21.
//

import Foundation
import SwiftUI


struct deepLinkKey: EnvironmentKey {
    static var defaultValue: URL? = nil
}
extension EnvironmentValues {
    var deepLink: URL? {
        get { self[deepLinkKey.self] }
        set { self[deepLinkKey.self] = newValue }
    }
}
