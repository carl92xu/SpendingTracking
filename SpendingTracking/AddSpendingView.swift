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
    
    @State private var newParticipantName: String = ""
        
    private var isSegmentedStyle: Bool {
        payers.count < 8
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    ScrollView {
                        VStack {
                            Spacer().frame(height: 10)
                            
                            // Payer Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Payer")
                                    .headerStyle()
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
                            }
                            
                            // TextFields
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Name")
                                    .headerStyle()
                                TextField("Spending Name", text: $name)
                                    .roundedTextFieldStyle()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Amount")
                                    .headerStyle()
                                TextField("Amount Paid", text: $amount)
                                    .keyboardType(.decimalPad)
                                    .roundedTextFieldStyle()
                            }
                            
                            // Multi-select for Participants
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Participants")
                                    .headerStyle()
                                
                                VStack(alignment: .leading) {
                                    ForEach(participants, id: \.self) { participant in
                                        VStack(spacing: 0) { // VStack to group content with Divider
                                            Button(action: {
                                                toggleParticipant(participant)
                                            }) {
                                                HStack {
                                                    Text(participant)
                                                        .font(.body)
                                                    Spacer()
                                                    Image(systemName: selectedParticipants.contains(participant) ? "checkmark.circle.fill" : "circle")
                                                        .foregroundColor(selectedParticipants.contains(participant) ? .blue : .gray)
                                                        .font(.title2)
                                                }
//                                                .padding(.top, -8)
                                                .padding(.vertical, 8)
                                                .contentShape(Rectangle()) // Ensures the button is tappable across the whole row
                                            }
                                            .buttonStyle(PlainButtonStyle()) // Removes the default button styling
                                            
//                                            Divider() // Adds a line between rows
                                        }
                                    }
                                    
                                    // TextField for adding custom participant
                                    HStack {
                                        TextField("Add Participant", text: $newParticipantName)
                                            .roundedTextFieldStyle()
                                            .padding(.leading, -20)
                                        Button(action: {
                                            addCustomParticipant()
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .padding(.top, 8)
                                }
                                .roundedTextFieldStyle()
                            }
                        }
                        
                        Spacer().frame(height: 100)
                    }
                    
                }
                .onAppear {
                    selectedPayer = payers.first ?? "" // Set selectedPlayer to be the first element in payers
                }
                .navigationTitle("Add Spending")
                .background(Color(UIColor.systemBackground)) // background color for the whole page
                .onTapGesture {
                    dismissKeyboard()
                }
                
                VStack {
                    Spacer()
                    
                    // Sticky Buttons at the Bottom
                    HStack {
                        @State var clearIsPressed: Bool = false
                        @State var saveIsPressed: Bool = false
                        
                        Button(action: {
                            withAnimation(.easeIn(duration: 0.2)) {
                                clearFields()
                            }
                        }) {
                            Text("Clear")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.2)) // Button background color
                                .foregroundColor(.red)
                                .cornerRadius(10)
                        }
                        .scaleEffect(clearIsPressed ? 0.9 : 1.0)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                clearIsPressed.toggle()
                            }
                        }
                        .background(Color(UIColor.secondarySystemBackground)) // Explicitly set button container background to non-transparent
                        .clipShape(RoundedRectangle(cornerRadius: 10)) // Ensure clipping to the corner radius
                        
                        Button(action: {
                            withAnimation(.easeIn(duration: 0.2)) {
                                saveSpending()
                                clearFields()
                                dismissKeyboard()
                            }
                        }) {
                            Text("Save")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                        }
                        .scaleEffect(saveIsPressed ? 0.9 : 1.0)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                saveIsPressed.toggle()
                            }
                        }
                        .background(Color(UIColor.secondarySystemBackground)) // Explicitly set button container background to non-transparent
                        .clipShape(RoundedRectangle(cornerRadius: 10)) // Ensure clipping to the corner radius
                        
                    }
                    .background(Color.clear)
                    .padding(.horizontal)
                    .padding(.bottom, 7)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: -2)
                }
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
    
    func addCustomParticipant() {
        let trimmedName = newParticipantName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty && !participants.contains(trimmedName) {
            payers.append(trimmedName) // Add to payers if needed
            selectedParticipants.append(trimmedName)
        }
        newParticipantName = "" // Clear input
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
