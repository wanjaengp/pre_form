//
//  LoanRequest.swift
//  PreQuestion
//
//  Created by Wanjaeng on 22/7/2568 BE.
//

struct LoanRequest: Codable {
    let fullName: String
    let monthlyIncome: Int
    let loanAmount: Int
    let loanPurpose: String
    let age: Int
    let phoneNumber: String
    let email: String
}

struct LoanResponse: Codable {
    let applicationId: String
    let eligible: Bool
    let reason: String
    let timestamp: String
}

struct ErrorResponse: Codable {
    let message: String
    let reason: String
}
