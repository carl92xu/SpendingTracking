//
//  ContentView.swift
//  SpendingTracking
//
//  Created by carl on 12/14/24.
//

import SwiftUI

struct Spending: Identifiable, Codable {
    var id: UUID
    let name: String
    let amount: Double
    let payer: String
    let participants: [String]

    // Add a default initializer
    init(id: UUID = UUID(), name: String, amount: Double, payer: String, participants: [String]) {
        self.id = id
        self.name = name
        self.amount = amount
        self.payer = payer
        self.participants = participants
    }
}

// Text Field Color
var textFieldColor: Color {
    Color(.white).opacity(0.7)
}

// Text Field Style
struct RoundedTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
//            .background(
//                RoundedRectangle(cornerRadius: 15)
//                    .fill(Color(.systemGray6).opacity(0.2))
//            )
//            .overlay(
//                RoundedRectangle(cornerRadius: 15)
//                    .stroke(Color.gray, lineWidth: 1)
//            )
            .background(
                RoundedRectangle(cornerRadius: 15)
//                    .fill(Color(.systemGray6))
                    .fill(textFieldColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray)
            )
            .padding(.horizontal)
    }
}

extension View {
    func roundedTextFieldStyle() -> some View {
        self.modifier(RoundedTextFieldModifier())
    }
}

struct ContentView: View {
//    @State private var spendings: [Spending] = []
    @State private var spendings: [Spending] = [
        Spending(name: "Lunch", amount: 20.00, payer: "Carl", participants: ["Carl", "Eric", "BU"]),
        Spending(name: "Coffee", amount: 5.50, payer: "Eric", participants: ["Eric", "Carl"]),
        Spending(name: "Groceries", amount: 100.00, payer: "BU", participants: ["Carl", "Eric", "BU"]),
        Spending(name: "Taxi Ride", amount: 25.00, payer: "Carl", participants: ["Carl", "Eric"]),
        Spending(name: "Movie Tickets", amount: 45.00, payer: "Eric", participants: ["Eric", "BU"]),
        Spending(name: "Gym Membership", amount: 60.00, payer: "BU", participants: ["BU"]),
        Spending(name: "Concert Tickets", amount: 120.00, payer: "Carl", participants: ["Carl", "Eric", "BU"]),
        Spending(name: "Dinner Party", amount: 80.00, payer: "Eric", participants: ["Carl", "Eric", "BU"]),
        Spending(name: "Office Supplies", amount: 30.00, payer: "BU", participants: ["Carl", "Eric", "BU", "Other"]),
        Spending(name: "Shared Rent", amount: 400.00, payer: "Carl", participants: ["Carl", "Eric", "BU", "Other"]),
        Spending(name: "Road Trip Gas", amount: 75.00, payer: "Other", participants: ["Carl", "Eric", "Other"]),
        Spending(name: "Gift for Boss", amount: 50.00, payer: "Eric", participants: ["Eric", "Other"]),
        Spending(name: "Holiday Groceries", amount: 200.00, payer: "BU", participants: ["Carl", "BU", "Other"]),
        Spending(name: "Streaming Subscription", amount: 15.00, payer: "Other", participants: ["Carl", "BU", "Other"]),
        Spending(name: "Shared Utilities", amount: 120.00, payer: "Carl", participants: ["Carl", "Eric", "BU", "Other"]),
        Spending(name: "Weekend Getaway", amount: 300.00, payer: "Eric", participants: ["Carl", "Eric", "Other"])
    ]
    
    @State private var payers: [String] = UserDefaults.standard.stringArray(forKey: "payers") ?? ["Eric", "BU", "Carl"]


    var body: some View {
        TabView {
            AddSpendingView(spendings: $spendings, payers: $payers)
                .tabItem {
                    Label("Add", systemImage: "plus.app")
                }

            RecordView(spendings: $spendings)
                .tabItem {
                    Label("Record", systemImage: "list.bullet")
                }

            SettingsView(payers: $payers)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .onAppear {
            loadSpendings()
            loadPayers()
        }
    }

    func loadPayers() {
        if let savedPayers = UserDefaults.standard.stringArray(forKey: "payers") {
            payers = savedPayers
        }
    }
    
    // Save spendings to a file
    func saveSpendings() {
        let fileURL = getDocumentDirectory().appendingPathComponent("spendings.json")
        do {
            let data = try JSONEncoder().encode(spendings)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save spendings: \(error)")
        }
    }

    // Load spendings from a file
    func loadSpendings() {
        let fileURL = getDocumentDirectory().appendingPathComponent("spendings.json")
        do {
            let data = try Data(contentsOf: fileURL)
            spendings = try JSONDecoder().decode([Spending].self, from: data)
        } catch {
            print("Failed to load spendings: \(error)")
        }
    }

    // Get the app's document directory
    func getDocumentDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

// Function to dismiss the keyboard
func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

//struct AddSpendingView: View {
//    @Binding var spendings: [Spending]
//    
////    private let payers = ["Eric", "BU", "Carl"]
//    @Binding var payers: [String]
//    private var participants: [String] {
//        payers + ["Other"]
//    }
//    
//    @State private var name: String = ""
//    @State private var amount: String = ""
//    @State private var selectedPayer: String = ""
//    @State private var selectedParticipants: [String] = []
//        
//    private var isSegmentedStyle: Bool {
//        payers.count < 8
//    }
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                ScrollView {
//                    VStack {
//                        Spacer().frame(height: 50)
//                        
//                        // Payer Picker
//                        Group {
//                            if isSegmentedStyle {
//                                Picker("Payer", selection: $selectedPayer) {
//                                    ForEach(payers, id: \.self) { payer in
//                                        Text(payer)
//                                    }
//                                }
//                                .pickerStyle(SegmentedPickerStyle())
//                            } else {
//                                Picker("Payer", selection: $selectedPayer) {
//                                    ForEach(payers, id: \.self) { payer in
//                                        Text(payer)
//                                    }
//                                }
//                                .pickerStyle(DefaultPickerStyle())
//                            }
//                        }
//                        .padding(.horizontal)
//                        
//                        // TextFields
//                        TextField("Spending Name", text: $name)
//                            .roundedTextFieldStyle()
//                        
//                        TextField("Amount", text: $amount)
//                            .keyboardType(.decimalPad)
//                            .roundedTextFieldStyle()
//                        
//                        // Multi-select for Participants
//                        VStack(alignment: .leading) {
//                            Text("Participants")
//                                .font(.headline)
//                                .padding(.bottom, 4)
//                            
//                            ForEach(participants, id: \.self) { participant in
//                                Button(action: {
//                                    toggleParticipant(participant)
//                                }) {
//                                    HStack {
//                                        Text(participant)
//                                            .font(.body)
//                                        Spacer()
//                                        Image(systemName: selectedParticipants.contains(participant) ? "checkmark.circle.fill" : "circle")
//                                            .foregroundColor(selectedParticipants.contains(participant) ? .blue : .gray)
//                                    }
//                                    .padding(.vertical, 8)
//                                    .contentShape(Rectangle()) // Ensures the button is tappable across the whole row
//                                }
//                                .buttonStyle(PlainButtonStyle()) // Removes the default button styling
//                            }
//                        }
//                        .padding()
//                        .background(
//                            RoundedRectangle(cornerRadius: 15)
//                                .fill(textFieldColor)
//                        )
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 15)
//                                .stroke(Color.gray, lineWidth: 1)
//                        )
//                        .padding(.horizontal)
//                    }
//                }
//                
//                // Sticky Buttons at the Bottom
//                HStack {
//                    Button("Clear") {
//                        clearFields()
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.red.opacity(0.2))
//                    .foregroundColor(.red)
//                    .cornerRadius(10)
//                    
//                    Button("Save") {
//                        saveSpending()
//                        clearFields()
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue.opacity(0.2))
//                    .foregroundColor(.blue)
//                    .cornerRadius(10)
//                }
////                .background(Color(.systemBackground)) // Ensures it stands out from scroll content
//                .padding(.horizontal)
//                .padding(.top, -3)
//                .padding(.bottom, 5)
//                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: -2)
//            }
//            .onAppear {
//                selectedPayer = payers.first ?? "" // Set selectedPlayer to be the first element in payers
//            }
//            .navigationTitle("Add Spending")
//            .background(Color(.systemGray6)) // background color for the whole page
//            .onTapGesture {
//                dismissKeyboard()
//            }
//        }
//    }
//
//    func saveSpending() {
//        guard let amountValue = Double(amount), !name.isEmpty else {
//            print("Invalid input")
//            return
//        }
//
//        let newSpending = Spending(name: name, amount: amountValue, payer: selectedPayer, participants: selectedParticipants)
//        spendings.append(newSpending)
//        saveSpendingsToFile()
//    }
//
//    func saveSpendingsToFile() {
//        let fileURL = getDocumentDirectory().appendingPathComponent("spendings.json")
//        do {
//            let data = try JSONEncoder().encode(spendings)
//            try data.write(to: fileURL)
//        } catch {
//            print("Failed to save spendings: \(error)")
//        }
//    }
//
//    func getDocumentDirectory() -> URL {
//        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//    }
//    
//    func clearFields() {
//        name = ""
//        amount = ""
////        selectedPayer = "Eric"
//        selectedParticipants = []
//    }
//    
//    // Toggle participant selection
//    func toggleParticipant(_ participant: String) {
//        if selectedParticipants.contains(participant) {
//            selectedParticipants.removeAll { $0 == participant }
//        } else {
//            selectedParticipants.append(participant)
//        }
//    }
//}


#Preview {
    ContentView()
}
