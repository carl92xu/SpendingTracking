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
//var textFieldColor: Color {
//    Color(.white).opacity(0.7)
//}

// Text Field Style
struct RoundedTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(UIColor.separator), lineWidth: 1)
            )
            .padding(.horizontal)
    }
}

extension View {
    func roundedTextFieldStyle() -> some View {
        self.modifier(RoundedTextFieldModifier())
    }
}

struct TextStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.secondary)
            .padding(.top, 8)
            .padding(.bottom, 4)
            .padding(.leading, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension View {
    func headerStyle() -> some View {
        self.modifier(TextStyleModifier())
    }
}

struct MockData {
    static let spendings: [Spending] = [
        Spending(name: "租车", amount: 542, payer: "Eric", participants: ["Carl", "Eric"]),
        Spending(name: "圣诞礼物", amount: 39.55, payer: "Eric", participants: ["Carl"]),
        Spending(name: "Come From Away", amount: 456, payer: "Eric", participants: ["Carl", "Eric", "BU"])
    ]
}

struct ContentView: View {
    @State var spendings: [Spending]
    
//    @State private var spendings: [Spending] = []
    
//    @State private var spendings: [Spending] = [
//        Spending(name: "租车", amount: 542, payer: "Eric", participants: ["Carl", "Eric"]),
//        Spending(name: "圣诞礼物", amount: 39.55, payer: "Eric", participants: ["Carl"]),
//        Spending(name: "Come From Away", amount: 456, payer: "Eric", participants: ["Carl", "Eric", "BU"])
//    ]
//    @State private var spendings: [Spending] = [
//        Spending(name: "Lunch", amount: 20.00, payer: "Carl", participants: ["Carl", "Eric", "BU"]),
//        Spending(name: "Coffee", amount: 5.50, payer: "Eric", participants: ["Eric", "Carl"]),
//        Spending(name: "Groceries", amount: 100.00, payer: "BU", participants: ["Carl", "Eric", "BU"]),
//        Spending(name: "Taxi Ride", amount: 25.00, payer: "Carl", participants: ["Carl", "Eric"]),
//        Spending(name: "Movie Tickets", amount: 45.00, payer: "Eric", participants: ["Eric", "BU"]),
//        Spending(name: "Gym Membership", amount: 60.00, payer: "BU", participants: ["BU"]),
//        Spending(name: "Concert Tickets", amount: 120.00, payer: "Carl", participants: ["Carl", "Eric", "BU"]),
//        Spending(name: "Dinner Party", amount: 80.00, payer: "Eric", participants: ["Carl", "Eric", "BU"]),
//        Spending(name: "Office Supplies", amount: 30.00, payer: "BU", participants: ["Carl", "Eric", "BU", "Other"]),
//        Spending(name: "Shared Rent", amount: 400.00, payer: "Carl", participants: ["Carl", "Eric", "BU", "Other"]),
//        Spending(name: "Road Trip Gas", amount: 75.00, payer: "Other", participants: ["Carl", "Eric", "Other"]),
//        Spending(name: "Gift for Boss", amount: 50.00, payer: "Eric", participants: ["Eric", "Other"]),
//        Spending(name: "Holiday Groceries", amount: 200.00, payer: "BU", participants: ["Carl", "BU", "Other"]),
//        Spending(name: "Streaming Subscription", amount: 15.00, payer: "Other", participants: ["Carl", "BU", "Other"]),
//        Spending(name: "Shared Utilities", amount: 120.00, payer: "Carl", participants: ["Carl", "Eric", "BU", "Other"]),
//        Spending(name: "Weekend Getaway", amount: 300.00, payer: "Eric", participants: ["Carl", "Eric", "Other"])
//    ]
    
    @State private var payers: [String] = UserDefaults.standard.stringArray(forKey: "payers") ?? ["Eric", "BU", "Carl"]
    @State private var newParticipants: [String] = []

    var body: some View {
        TabView {
//            AddSpendingView(spendings: $spendings, payers: $payers, newParticipants: $newParticipants)
//                .tabItem {
//                    Label("Add", systemImage: "plus.app")
//                }

            RecordView(spendings: $spendings)
                .tabItem {
                    Label("Record", systemImage: "list.bullet")
                }

            SettingsView(payers: $payers, newParticipants: $newParticipants)
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

#Preview {
//    ContentView()
    ContentView(spendings: MockData.spendings)
}
