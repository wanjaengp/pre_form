//
//  AllLoansViewModel.swift
//  PreQuestion
//
//  Created by Wanjaeng on 22/7/2568 BE.
//

import Foundation
import SwiftUI

class AllLoansViewModel: ObservableObject {
    @Published var loans: [LoanApplication] = []
    @Published var page = 1
    @Published var totalPages = 1
    @Published var isLoading = false
    @Published var activeAlert: ActiveAlert? = nil

    // Optional filters
    @Published var filterEligible: Bool? = nil
    @Published var filterPurpose: String? = nil

    private let pageSize = 10

    func fetchLoans(page: Int = 1) {
        guard page > 0 else { return }

        var urlComponents = URLComponents(string: "api/v1/loans")!
        var queryItems = [URLQueryItem(name: "page", value: String(page)),
                          URLQueryItem(name: "limit", value: String(pageSize))]

        if let eligible = filterEligible {
            queryItems.append(URLQueryItem(name: "eligible", value: eligible ? "true" : "false"))
        }
        if let purpose = filterPurpose, !purpose.isEmpty {
            queryItems.append(URLQueryItem(name: "purpose", value: purpose))
        }

        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
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
                    self.activeAlert = .validationError("Invalid server response.")
                    return
                }

                guard let data = data else {
                    self.activeAlert = .validationError("No data received.")
                    return
                }

                switch httpResponse.statusCode {
                case 200:
                    do {
                        let decoded = try JSONDecoder().decode(LoansPageResponse.self, from: data)
                        if page == 1 {
                            self.loans = decoded.applications
                        } else {
                            self.loans.append(contentsOf: decoded.applications)
                        }
                        self.page = decoded.page
                        self.totalPages = decoded.totalPages
                    } catch {
                        self.activeAlert = .validationError("Failed to parse response.")
                    }

                default:
                    self.activeAlert = .validationError("Server error: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }

    func loadNextPage() {
        guard page < totalPages, !isLoading else { return }
        fetchLoans(page: page + 1)
    }
}
