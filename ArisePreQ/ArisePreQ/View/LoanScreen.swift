//
//  LoanScreen.swift
//  PreQuestion
//
//  Created by Wanjaeng on 21/7/2568 BE.
//

import SwiftUI

enum ActiveAlert: Identifiable, Hashable {
    case validationError(String)
    case incomeLimit
    case amountLimit
    case validateAge
    
    var id: Int {
        switch self {
        case .validationError:
            return 0
        case .incomeLimit:
            return 1
        case .amountLimit:
            return 2
        case .validateAge:
            return 3
        }
    }
}

struct LoanScreen: View {
    //MARK:- PROPERTIES
    @StateObject private var viewModel = LoanFormViewModel()
    
    var body: some View {
        VStack{
            
            //MARK: Title
            VStack(spacing:15) {
                Text("PreQuestion")
                    .modifier(CustomTextM(fontName: "RobotoSlab-Bold", fontSize: 34, fontColor: Color("blue")))
                Text("Loan Pre-Qualification.")
                    .modifier(CustomTextM(fontName: "RobotoSlab-Light", fontSize: 18, fontColor: Color.secondary))
                Text("Get instant loan pre-qualification decisions.")
                    .modifier(CustomTextM(fontName: "RobotoSlab-Light", fontSize: 16, fontColor: Color.gray))
            }
            .padding(.top,45)
            Spacer()
            
            //MARK: Form
            VStack(spacing: 15) {
                let minLength = 2
                VStack(alignment: .center, spacing: 20) {
                    VStack(alignment: .center) {
                        CustomTextfield(placeholder:
                                            Text("Full Name*"),
                                        fontName: "RobotoSlab-Light",
                                        fontSize: 18,
                                        fontColor: Color.gray,
                                        foregroundColor: .black,
                                        isSecure: false,
                                        text: $viewModel.fullName,
                                        minLength: minLength)
                        Divider()
                            .background(Color.gray)
                    }
                    
                    if viewModel.fullName.count < minLength
                        && !viewModel.fullName.isEmpty {
                        Text("Minimum \(minLength) characters required")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    VStack(alignment: .center) {
                        CustomTextfield(placeholder:
                                            Text("Phone Number"),
                                        fontName: "RobotoSlab-Light",
                                        fontSize: 18,
                                        fontColor: Color.gray,
                                        foregroundColor: .black,
                                        isSecure: false,
                                        text: $viewModel.phoneNumber,
                                        allowedCharecters: "0123456789",
                                        maxLength: 10)
                        Divider()
                            .background(Color.gray)
                    }
                    
                    VStack(alignment: .center) {
                        CustomTextfield(
                            placeholder: Text("E-Mail"),
                            fontName: "RobotoSlab-Light",
                            fontSize: 18,
                            fontColor: Color.gray,
                            foregroundColor: .black,
                            isSecure: false,
                            text: $viewModel.email,
                            editingChanged: { _ in
                                viewModel.showEmailError = !isValidEmail(viewModel.email)
                            },
                            commit: {
                                viewModel.showEmailError = !isValidEmail(viewModel.email)
                            }
                        )
                        Divider()
                            .background(Color.gray)
                    }
                    
                    if viewModel.showEmailError {
                        Text("Must follow email format (e.g., user@example.com)")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    VStack(alignment: .center) {
                        CustomTextfield(placeholder:
                                            Text("Monthly Income*"),
                                        fontName: "RobotoSlab-Light",
                                        fontSize: 18,
                                        fontColor: Color.gray,
                                        foregroundColor: .black,
                                        isSecure: false,
                                        text: $viewModel.monthlyIncome,
                                        allowedCharecters: "1234567890")
                        Divider()
                            .background(Color.gray)
                            .onChange(of: viewModel.monthlyIncome) { newValue, _ in
                                if let intValue = Int(newValue), intValue > 5_000_000
                                    && !viewModel.monthlyIncome.isEmpty {
                                    viewModel.activeAlert = .incomeLimit
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        viewModel.monthlyIncome = ""
                                    }
                                }
                            }
                        
                        if let intValue = Int(viewModel.monthlyIncome), intValue < 5000
                            && !viewModel.monthlyIncome.isEmpty {
                            Text("Minimum income is 5,000")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    
                    VStack(alignment: .center) {
                        CustomTextfield(placeholder:
                                            Text("Loan Amount*"),
                                        fontName: "RobotoSlab-Light",
                                        fontSize: 18,
                                        fontColor: Color.gray,
                                        foregroundColor: .black,
                                        isSecure: false,
                                        text: $viewModel.loanAmount,
                                        allowedCharecters: "123456789")
                        Divider()
                            .background(Color.gray)
                            .onChange(of: viewModel.loanAmount) { newValue, _ in
                                if let intValue = Int(newValue), intValue > 5_000_000
                                    && !viewModel.loanAmount.isEmpty {
                                    viewModel.activeAlert = .amountLimit
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        viewModel.loanAmount = ""
                                    }
                                }
                            }
                        
                        if let intValue = Int(viewModel.loanAmount), intValue <= 1000
                            && !viewModel.loanAmount.isEmpty {
                            Text("Minimum income is 5,000")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    
                    VStack(alignment: .center) {
                        Menu {
                            ForEach(viewModel.loanPurposeOptions, id: \.self) { option in
                                Button(action: {
                                    viewModel.loanPurpose = option
                                }) {
                                    Text(option)
                                }
                            }
                        } label: {
                            HStack {
                                Text(viewModel.loanPurpose.isEmpty ? "Select Loan Purpose" : viewModel.loanPurpose)
                                    .font(.custom("RobotoSlab-Light", size: 18))
                                    .foregroundColor(viewModel.loanPurpose.isEmpty ? .gray : .primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 10)
                        }
                        
                        Divider()
                            .background(Color.gray)
                    }
                    
                    VStack(alignment: .center) {
                        CustomTextfield(placeholder:
                                            Text("Age"),
                                        fontName: "RobotoSlab-Light",
                                        fontSize: 18,
                                        fontColor: Color.gray,
                                        foregroundColor: .black,
                                        isSecure: false,
                                        text: $viewModel.age,
                                        allowedCharecters: "123456789",
                                        maxLength: 2)
                        Divider()
                            .background(Color.gray)
                            .onChange(of: viewModel.age) { newValue, _ in
                                if !validateAge()
                                    && !newValue.isEmpty { viewModel.activeAlert = .validateAge}
                            }
                    }
                }
            }
            .padding(.horizontal,35)
            
            // MARK: Button
            Button(action: {
                if validateForm() {
                    viewModel.submitLoanApplication()
                    print("proceed to next step")
                } else {
                    viewModel.activeAlert = .validationError("Please complete all required fields correctly.")
                }
            }) {
                ZStack{
                    Circle()
                        .foregroundColor(Color("blue"))
                        .frame(width: 60, height: 60)
                    Image(systemName: "arrow.right")
                        .font(.title)
                        .foregroundColor(Color.white)
                    
                }
            }
            
            // MARK: Alert PopUp
            .alert(item: $viewModel.activeAlert) { alert in
                switch alert {
                case .validationError(let message):
                    return Alert(title: Text("Validation Error"),
                                 message: Text(message),
                                 dismissButton: .default(Text("OK")))
                case .incomeLimit:
                    return Alert(title: Text("Monthly income is insufficient"),
                                 message: Text("Maximum income allowed is 5,000,000."),
                                 dismissButton: .default(Text("OK")))
                case .amountLimit:
                    return Alert(title: Text("Amount is insufficient"),
                                 message: Text("Maximum amount allowed is 5,000,000."),
                                 dismissButton: .default(Text("OK")))
                case .validateAge:
                    return Alert(title: Text("Age is insufficient"),
                                 message: Text("Please input your age"),
                                 dismissButton: .default(Text("OK")))
                }
            }
            .padding(.top,50)
            .padding(.bottom,30)
        }
    }
    
    // MARK: Logic
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
    
    func validateForm() -> Bool {
        let trimmedFullName = viewModel.fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhoneNumber = viewModel.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = viewModel.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMonthlyIncome = viewModel.monthlyIncome.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLoanAmount = viewModel.loanAmount.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAge = viewModel.age.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedFullName.isEmpty else { return false }
        guard !trimmedEmail.isEmpty, isValidEmail(trimmedEmail) else {
            viewModel.showEmailError = true
            return false
        }
        viewModel.showEmailError = false
        
        guard !trimmedMonthlyIncome.isEmpty else { return false }
        guard !trimmedLoanAmount.isEmpty else { return false }
        guard !viewModel.loanPurpose.isEmpty else { return false }
        guard !trimmedAge.isEmpty else { return false }
        
        if !trimmedPhoneNumber.isEmpty, trimmedPhoneNumber.count != 10 {
            return false
        }
        
        return true
    }
    
    func validateAge() -> Bool {
        guard let ageValue = Int(viewModel.age), ageValue > 0 else {
            return false
        }
        return true
    }
}

struct LoanScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoanScreen()
    }
}

struct CustomTextM: ViewModifier {
    //MARK:- PROPERTIES
    let fontName: String
    let fontSize: CGFloat
    let fontColor: Color
    
    func body(content: Content) -> some View {
        content
            .font(.custom(fontName, size: fontSize))
            .foregroundColor(fontColor)
    }
}
