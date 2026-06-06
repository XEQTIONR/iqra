//
//  InstructorFormView.swift
//  iqra
//
//  Created by Ovi Hussain on 2026-05-31.
//

import SwiftUI

struct InstructorMuslimFormView: View {
    
    @State private var settings = InstructorSettings()

    var body: some View {
        VStack {
                Text("Signup to teach")
                    .font(.title)
                    .padding(.top, 50)
                
                Spacer()
                    .frame(height: 50)
                
                VStack(spacing: 15) {
                    Text("Are you a Muslim?")
                        .multilineTextAlignment(.center)
                        .font(.title3)
                        .padding(.bottom, 50)
                    
                    VStack(spacing: 15) {
                            Text("Yes")
                                .foregroundStyle(settings.isMuslim == true ? .blue : .primary)
                                .padding(.all, 10)
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.1))
                                .onTapGesture {
                                    settings.isMuslim = true
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(settings.isMuslim == true ? .blue : .gray, lineWidth: 1.5)
                                )
                                .padding(.horizontal)
                                
                            
                            Text("No")
                                .foregroundStyle(settings.isMuslim == false ? .blue : .primary)
                                .padding(.all, 10)
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.1))
                                .onTapGesture {
                                    settings.isMuslim = false
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(settings.isMuslim == false ? .blue : .gray, lineWidth: 1.5)
                                )
                                .padding(.horizontal)
                                
                                
                        }
                        .frame(maxWidth: .infinity)
                    
                    Spacer()
                    
                    NavigationLink {
                        InstructorQualificationFormView()
                    } label: {
                        ZStack {
                            Text("Next")
                            HStack {
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .padding(.trailing, 20)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(settings.isMuslim == nil ? .gray.opacity(0.5) : .blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(settings.isMuslim == nil)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 20)
                    
                }
                
               
            }
    }
}

#Preview {
    InstructorMuslimFormView()
}
