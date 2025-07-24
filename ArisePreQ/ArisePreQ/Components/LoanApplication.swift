//
//  LoanApplication.swift
//  PreQuestion
//
//  Created by Wanjaeng on 22/7/2568 BE.
//

import Foundation

struct LoanApplication: Codable, Identifiable, Equatable {
    let id = UUID()
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
    
    enum CodingKeys: String, CodingKey {
        case applicationId,
             fullName,
             monthlyIncome,
             loanAmount,
             loanPurpose,
             age,
             phoneNumber,
             email,
             eligible,
             reason,
             timestamp
    }
    
    static func == (lhs: LoanApplication, rhs: LoanApplication) -> Bool {
        return lhs.applicationId == rhs.applicationId
    }
}

struct LoansPageResponse: Codable {
    let applications: [LoanApplication]
    let page: Int
    let totalPages: Int
}
