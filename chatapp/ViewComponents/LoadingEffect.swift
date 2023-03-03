//
//  LoadingView.swift
//  chatapp
//
//  Created by Leopold on 3/3/2023.
//

import SwiftUI

struct LoadingEffect: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color(.systemGray))
                .frame(width: 10, height: 10)
                .opacity(isAnimating ? 1 : 0)
            Circle()
                .fill(Color(.systemGray))
                .frame(width: 10, height: 10)
                .opacity(isAnimating ? 0.5 : 0)
            Circle()
                .fill(Color(.systemGray))
                .frame(width: 10, height: 10)
                .opacity(isAnimating ? 0.25 : 0)
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1).repeatForever()) {
                self.isAnimating = true
            }
        }
        .onDisappear {
            self.isAnimating = false
        }
    }
}

struct LoadingEffect_Previews: PreviewProvider {
    static var previews: some View {
        LoadingEffect()
    }
}
