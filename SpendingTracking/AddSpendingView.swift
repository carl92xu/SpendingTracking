//
//  AddSpendingView.swift
//  SpendingTracking
//
//  Created by carl on 12/16/24.
//

import SwiftUI

struct AddSpendingView: View {
    @Binding var spendings: [Spending]
    
//    private let payers = ["Eric", "BU", "Carl"]
    @Binding var payers: [String]
    private var participants: [String] {
        payers + ["Other"]
    }
    
    @State private var name: String = ""
    @State private var amount: String = ""
    @State private var selectedPayer: String = ""
    @State private var selectedParticipants: [String] = []
        
    private var isSegmentedStyle: Bool {
        payers.count < 8
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack {
                        Spacer().frame(height: 50)
                        
                        // Payer Picker
                        Group {
                            if isSegmentedStyle {
                                Picker("Payer", selection: $selectedPayer) {
                                    ForEach(payers, id: \.self) { payer in
                                        Text(payer)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            } else {
                                Picker("Payer", selection: $selectedPayer) {
                                    ForEach(payers, id: \.self) { payer in
                                        Text(payer)
                                    }
                                }
                                .pickerStyle(DefaultPickerStyle())
                            }
                        }
                        .padding(.horizontal)
                        
                        // TextFields
                        TextField("Spending Name", text: $name)
                            .roundedTextFieldStyle()
                        
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .roundedTextFieldStyle()
                        
                        // Multi-select for Participants
                        VStack(alignment: .leading) {
                            Text("Participants")
                                .font(.headline)
                                .padding(.bottom, 4)
                            
                            ForEach(participants, id: \.self) { participant in
                                Button(action: {
                                    toggleParticipant(participant)
                                }) {
                                    HStack {
                                        Text(participant)
                                            .font(.body)
                                        Spacer()
                                        Image(systemName: selectedParticipants.contains(participant) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(selectedParticipants.contains(participant) ? .blue : .gray)
                                    }
                                    .padding(.vertical, 8)
                                    .contentShape(Rectangle()) // Ensures the button is tappable across the whole row
                                }
                                .buttonStyle(PlainButtonStyle()) // Removes the default button styling
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(textFieldColor)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }
                }
                
                // Sticky Buttons at the Bottom
                HStack {
                    Button("Clear") {
                        clearFields()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .foregroundColor(.red)
                    .cornerRadius(10)
                    
                    Button("Save") {
                        saveSpending()
                        clearFields()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
//                .background(Color(.systemBackground)) // Ensures it stands out from scroll content
                .padding(.horizontal)
                .padding(.top, -3)
                .padding(.bottom, 5)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: -2)
            }
            .onAppear {
                selectedPayer = payers.first ?? "" // Set selectedPlayer to be the first element in payers
            }
            .navigationTitle("Add Spending")
            .background(Color(.systemGray6)) // background color for the whole page
            .onTapGesture {
                dismissKeyboard()
            }
        }
    }

    func saveSpending() {
        guard let amountValue = Double(amount), !name.isEmpty else {
            print("Invalid input")
            return
        }

        let newSpending = Spending(name: name, amount: amountValue, payer: selectedPayer, participants: selectedParticipants)
        spendings.append(newSpending)
        saveSpendingsToFile()
    }

    func saveSpendingsToFile() {
        let fileURL = getDocumentDirectory().appendingPathComponent("spendings.json")
        do {
            let data = try JSONEncoder().encode(spendings)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save spendings: \(error)")
        }
    }

    func getDocumentDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func clearFields() {
        name = ""
        amount = ""
//        selectedPayer = "Eric"
        selectedParticipants = []
    }
    
    // Toggle participant selection
    func toggleParticipant(_ participant: String) {
        if selectedParticipants.contains(participant) {
            selectedParticipants.removeAll { $0 == participant }
        } else {
            selectedParticipants.append(participant)
        }
    }
}
