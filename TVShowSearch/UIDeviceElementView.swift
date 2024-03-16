//
//  UIDeviceElementView.swift
//  TVShowSearch
//
//  Created by Michael Peters on 3/15/24.
//

import SwiftUI

struct UIDeviceElementView: View {
    
    let deviceElementTitle: String
    let deviceElementData: String
    
    var body: some View {
        HStack {
            Text(deviceElementTitle)
            Spacer()
            Text(deviceElementData)
        }
    }
}
