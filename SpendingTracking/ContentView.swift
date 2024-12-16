//
//  ContentView.swift
//  SpendingTracking
//
//  Created by carl on 12/14/24.
//

import SwiftUI

struct Spending: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let payer: String
    let participants: [String]
}

// Text Field Style
struct RoundedTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.systemGray6).opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray, lineWidth: 1)
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

    var body: some View {
        TabView {
            AddSpendingView(spendings: $spendings)
                .tabItem {
                    Label("Add", systemImage: "plus.app")
                }

            RecordView(spendings: $spendings) // Pass binding to RecordView
                .tabItem {
                    Label("Record", systemImage: "list.bullet")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

struct AddSpendingView: View {
    @Binding var spendings: [Spending]
    @State private var name: String = ""
    @State private var amount: String = ""
    @State private var selectedPayer: String = "Eric"
    @State private var selectedParticipants: [String] = [] // State for selected participants
    private let payers = ["Eric", "BU", "Carl"]
    private let participants = ["Eric", "BU", "Carl", "Other"]

    var body: some View {
        NavigationView {
            VStack {
                // Custom Horizontal Picker with Sliding Indicator
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: getSegmentWidth(), height: 39) // Dynamic width
                        .offset(x: getIndicatorOffset() - 11, y: -7)
                        .animation(.easeInOut(duration: 0.3), value: selectedPayer)

                    HStack(spacing: 0) {
                        ForEach(payers, id: \.self) { payer in
                            Text(payer)
                                .font(.system(size: 18, weight: .medium))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .onTapGesture {
                                    selectedPayer = payer
                                }
                                .foregroundColor(selectedPayer == payer ? .blue : .gray)
                        }
                    }
                }
                .frame(height: 48)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(.systemGray6).opacity(0.2))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray, lineWidth: 1)
                )
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
                        HStack {
                            Text(participant)
                                .font(.body)
                            Spacer()
                            Image(systemName: selectedParticipants.contains(participant) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedParticipants.contains(participant) ? .blue : .gray)
                                .onTapGesture {
                                    toggleParticipant(participant)
                                }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(.systemGray6).opacity(0.2))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.horizontal)

                // Action Buttons
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
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Add Spending")
        }
    }
    

    // Toggle participant selection
    func toggleParticipant(_ participant: String) {
        if selectedParticipants.contains(participant) {
            selectedParticipants.removeAll { $0 == participant }
        } else {
            selectedParticipants.append(participant)
        }
    }

    // Calculate the width of each segment
    func getSegmentWidth() -> CGFloat {
        let totalWidth = UIScreen.main.bounds.width - 32 // Subtract horizontal padding
        return totalWidth / CGFloat(payers.count)
    }

    // Calculate the X-offset for the sliding indicator
    func getIndicatorOffset() -> CGFloat {
        let index = payers.firstIndex(of: selectedPayer) ?? 0
        let segmentWidth = getSegmentWidth() - 21
        return CGFloat(index) * segmentWidth
    }

    func saveSpending() {
        guard let amountValue = Double(amount), !name.isEmpty else {
            print("Invalid input") // Add error handling here.
            return
        }

        let newSpending = Spending(name: name, amount: amountValue, payer: selectedPayer, participants: selectedParticipants)
        spendings.append(newSpending)
        print("Saved spending: \(newSpending)")
        clearFields()
    }

    func clearFields() {
        name = ""
        amount = ""
//        selectedPayer = "Eric"
        selectedParticipants = []
    }
}


#Preview {
    ContentView()
}
