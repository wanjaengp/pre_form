//
//  CustomTextfield.swift
//  PreQuestion
//
//  Created by Wanjaeng on 21/7/2568 BE.
//

import SwiftUI

struct CustomTextfield: View {
    // MARK: - PROPERTIES
    var placeholder: Text
    var fontName: String
    var fontSize: CGFloat
    var fontColor: Color
    var foregroundColor: Color?
    var isSecure: Bool = false
    
    @Binding var text: String
    
    var editingChanged: (Bool) -> () = { _ in }
    var commit: () -> () = {}
    
    var allowedCharecters: String? = nil
    var maxLength: Int? = nil
    var minLength: Int? = nil
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                placeholder.modifier(CustomTextM(fontName: fontName,
                                                 fontSize: fontSize,
                                                 fontColor: fontColor))
            }
            
            if isSecure {
                SecureField("", text: $text, onCommit: commit)
                    .foregroundColor(foregroundColor ?? .primary)
            } else {
                TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
                    .foregroundColor(foregroundColor ?? .primary)
            }
        }
        .onChange(of: text) { newValue, _ in
            var filtered = newValue
            
            if let allowed = allowedCharecters {
                filtered = filtered.filter { allowed.contains($0) }
            }
            
            if let max = maxLength {
                filtered = String(filtered.prefix(max))
            }
            
            if filtered != newValue {
                text = filtered
            }
        }
    }
}
