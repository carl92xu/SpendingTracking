//
//  RecordView.swift
//  SpendingTracking
//
//  Created by carl on 12/14/24.
//

import SwiftUI

struct RecordView: View {
    @Binding var spendings: [Spending]
    
    var body: some View {
        NavigationView {
            VStack {
                // Summary Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(calculateParticipantSummary().sorted(by: { $0.key < $1.key }), id: \.key) { participant, summary in
                            VStack {
                                Text(participant)
                                    .font(.headline)
                                Text("Spent: \(summary.spent, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("Paid: \(summary.paid, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("Total: \(summary.spent-summary.paid, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                            .frame(width: 120, height: 94) // Fixed width for each participant
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.blue.opacity(0.2))
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color(.systemGray6)) // Background for the summary bar
                
                // Spending List
                List {
                    ForEach(spendings) { spending in
                        VStack(alignment: .leading) {
                            Text(spending.name)
                                .font(.headline)
                            Text("Amount: \(spending.amount, specifier: "%.2f")")
                            Text("Payer: \(spending.payer)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("Participants: \(spending.participants.joined(separator: ", "))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .onDelete(perform: deleteSpending) // Enable swipe-to-delete
                }
                .navigationTitle("Spendings")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton() // Adds an edit button for delete functionality
                    }
                }
            }
        }
    }

    func deleteSpending(at offsets: IndexSet) {
        spendings.remove(atOffsets: offsets)
        saveSpendingsToFile() // Ensure data persistence after deletion
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
    
    private func calculateParticipantSummary() -> [String: (spent: Double, paid: Double)] {
        var participantSummary: [String: (spent: Double, paid: Double)] = [:]
        
        for spending in spendings {
            let share = spending.amount / Double(spending.participants.count)
            
            // Add spent amount for each participant
            for participant in spending.participants {
                participantSummary[participant, default: (spent: 0.0, paid: 0.0)].spent += share
            }
            
            // Add paid amount for the payer
            participantSummary[spending.payer, default: (spent: 0.0, paid: 0.0)].paid += spending.amount
        }
        
        return participantSummary
    }
}

#Preview {
    @State var spendings: [Spending] = [
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
    
    RecordView(spendings: $spendings)
}
