//
//  LoanStatusViewModel.swift
//  PreQuestion
//
//  Created by Wanjaeng on 22/7/2568 BE.
//

import Foundation
import SwiftUI

class LoanStatusViewModel: ObservableObject {
    @Published var applicationId: String = ""
    @Published var loanStatus: LoanStatusResponse?
    @Published var activeAlert: ActiveAlert? = nil
    @Published var isLoading: Bool = false

    func fetchLoanStatus() {
        guard !applicationId.isEmpty else {
            activeAlert = .validationError("Application ID cannot be empty.")
            return
        }

        guard let url = URL(string: "api/v1/loans/\(applicationId)") else {
            activeAlert = .validationError("Invalid URL.")
            return
        }

        isLoading = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.activeAlert = .validationError("Network error: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.activeAlert = .validationError("Invalid response from server.")
                    return
                }

                guard let data = data else {
                    self.activeAlert = .validationError("No data received.")
                    return
                }

                switch httpResponse.statusCode {
                case 200:
                    do {
                        let decoded = try JSONDecoder().decode(LoanStatusResponse.self, from: data)
                        self.loanStatus = decoded
                    } catch {
                        self.activeAlert = .validationError("Failed to parse response.")
                    }

                case 404:
                    do {
                        let errorResponse = try JSONDecoder().decode(ErrorLoanStatusResponse.self, from: data)
                        self.activeAlert = .validationError("\(errorResponse.reason)")
                    } catch {
                        self.activeAlert = .validationError("Loan not found.")
                    }

                default:
                    self.activeAlert = .validationError("Server error: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
}
