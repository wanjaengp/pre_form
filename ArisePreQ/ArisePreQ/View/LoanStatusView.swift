//
//  LoanStatusView.swift
//  PreQuestion
//
//  Created by Wanjaeng on 22/7/2568 BE.
//

import SwiftUICore
import SwiftUI

struct LoanStatusView: View {
    @StateObject private var viewModel = LoanStatusViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Check Loan Status")
                .font(.title2.bold())

            TextField("Enter Application ID", text: $viewModel.applicationId)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Check Status") {
                viewModel.fetchLoanStatus()
            }
            .buttonStyle(.borderedProminent)

            if viewModel.isLoading {
                ProgressView()
            }

            if let status = viewModel.loanStatus {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Application ID: \(status.applicationId)")
                    Text("Name: \(status.fullName)")
                    Text("Eligible: \(status.eligible ? "Yes" : "No")")
                    Text("Reason: \(status.reason)")
                    Text("Submitted: \(status.timestamp)")
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(12)
                .padding()
            }
        }
        .alert(item: $viewModel.activeAlert) { alert in
            switch alert {
            case .validationError(let message):
                return Alert(title: Text("Error"), message: Text(message), dismissButton: .default(Text("OK")))
            default:
                return Alert(title: Text("Unexpected Error"))
            }
        }
        .padding()
    }
}

struct LoanStatusView_Previews: PreviewProvider {
    static var previews: some View {
        LoanStatusView()
    }
}
