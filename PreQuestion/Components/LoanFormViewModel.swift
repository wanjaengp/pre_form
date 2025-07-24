//
//  LoanFormViewModel.swift
//  PreQuestion
//
//  Created by Wanjaeng on 22/7/2568 BE.
//

import Foundation
import SwiftUI

class LoanFormViewModel: ObservableObject {
    // MARK: - Form Fields
    @Published var fullName = ""
    @Published var phoneNumber = ""
    @Published var monthlyIncome = ""
    @Published var loanAmount = ""
    @Published var age = ""
    @Published var loanPurpose = ""
    @Published var email = ""
    
    @Published var showEmailError = false
    @Published var activeAlert: ActiveAlert? = nil
    
    // MARK: - Constants
    let loanPurposeOptions = ["education", "home", "car", "business", "personal"]
    
    // MARK: - Validation
    func validateForm() -> Bool {
        let trimmedFullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMonthlyIncome = monthlyIncome.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLoanAmount = loanAmount.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAge = age.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedFullName.isEmpty else { return false }
        guard !trimmedEmail.isEmpty, isValidEmail(trimmedEmail) else {
            showEmailError = true
            return false
        }
        showEmailError = false
        guard !trimmedMonthlyIncome.isEmpty else { return false }
        guard !trimmedLoanAmount.isEmpty else { return false }
        guard !loanPurpose.isEmpty else { return false }
        guard !trimmedAge.isEmpty else { return false }
        
        if !phoneNumber.isEmpty, phoneNumber.count != 10 {
            return false
        }
        return true
    }
    
    func validateAge() -> Bool {
        guard let ageValue = Int(age), ageValue > 0 else {
            return false
        }
        return true
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
    
    // MARK: - Submit
    func submitLoanApplication() {
        guard
            let monthlyIncomeInt = Int(monthlyIncome),
            let loanAmountInt = Int(loanAmount),
            let ageInt = Int(age)
        else {
            activeAlert = .validationError("Invalid number input.")
            return
        }
        
        if monthlyIncomeInt > 5_000_000 {
            activeAlert = .incomeLimit
            monthlyIncome = ""
            return
        }
        
        if loanAmountInt > 5_000_000 {
            activeAlert = .amountLimit
            loanAmount = ""
            return
        }
        
        if !validateAge() {
            activeAlert = .validateAge
            return
        }
        
        let payload = LoanRequest(
            fullName: fullName,
            monthlyIncome: monthlyIncomeInt,
            loanAmount: loanAmountInt,
            loanPurpose: loanPurpose,
            age: ageInt,
            phoneNumber: phoneNumber,
            email: email
        )
        
        guard let url = URL(string: "api/v1/loans") else {
            activeAlert = .validationError("Invalid URL.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(payload)
            request.httpBody = jsonData
        } catch {
            activeAlert = .validationError("Failed to encode request.")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
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
                        let decoded = try JSONDecoder().decode(LoanResponse.self, from: data)
                        print("Application ID: \(decoded.applicationId)")
                        self.activeAlert = .validationError("\(decoded.reason)")
                    } catch {
                        self.activeAlert = .validationError("Failed to parse success response.")
                    }

                case 400:
                    do {
                        let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                        self.activeAlert = .validationError("\(errorResponse.reason)")
                    } catch {
                        self.activeAlert = .validationError("Bad request - unknown error.")
                    }

                default:
                    self.activeAlert = .validationError("Unexpected server response: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
}
