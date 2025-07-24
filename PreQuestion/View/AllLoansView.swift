//
//  AllLoansView.swift
//  PreQuestion
//
//  Created by Wanjaeng on 22/7/2568 BE.
//

import Foundation
import SwiftUI

struct AllLoansView: View {
    @StateObject private var viewModel = AllLoansViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.loans) { loan in
                    VStack(alignment: .leading) {
                        Text(loan.fullName)
                            .font(.headline)
                        Text("Loan Amount: \(loan.loanAmount)")
                        Text("Eligible: \(loan.eligible ? "Yes" : "No")")
                        Text("Purpose: \(loan.loanPurpose)")
                    }
                    .padding(.vertical, 5)
                    .onAppear {
                        if loan == viewModel.loans.last {
                            viewModel.loadNextPage()
                        }
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Applications Result")
            .alert(item: $viewModel.activeAlert) { alert in
                switch alert {
                case .validationError(let message):
                    return Alert(title: Text("Error"), message: Text(message), dismissButton: .default(Text("OK")))
                default:
                    return Alert(title: Text("Unknown Error"))
                }
            }
            .onAppear {
                viewModel.fetchLoans()
            }
        }
    }
}

struct AllLoansView_Previews: PreviewProvider {
    static var previews: some View {
        AllLoansView()
    }
}
