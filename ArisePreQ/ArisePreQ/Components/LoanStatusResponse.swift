//
//  LoanStatusResponse.swift
//  PreQuestion
//
//  Created by Wanjaeng on 22/7/2568 BE.
//

struct LoanStatusResponse: Codable {
    let applicationId: String
    let fullName: String
    let monthlyIncome: Int
    let loanAmount: Int
    let loanPurpose: String
    let age: Int
    let phoneNumber: String
    let email: String
    let eligible: Bool
    let reason: String
    let timestamp: String
}

struct ErrorLoanStatusResponse: Codable {
    let message: String
    let reason: String
}
