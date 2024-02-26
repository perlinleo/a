//
//  TotalBalanceView.swift
//  a
//
//  Created by Leonid Perlin on 2/24/24.
//

import SwiftUI

struct TotalBalanceView: View {
    @Binding var total: Decimal

    var body: some View {
        HStack {
            VStack(alignment: .leading, content: {
                Text("Total Balance")
                    .font(.largeTitle)
                Text("\(total, format: .currency(code: "USD"))")
                    .font(.title)
            })
        }
    }
}

#Preview {
    TotalBalanceView(total: .constant(100.02))
}
