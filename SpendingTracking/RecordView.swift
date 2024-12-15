//
//  RecordView.swift
//  SpendingTracking
//
//  Created by carl on 12/14/24.
//

import SwiftUI

// For Debugging Only
//struct RecordView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecordView(spendings: [
//            Spending(name: "Lunch", amount: 20.00, payer: "Carl", participants: ["Carl", "Eric", "BU"]),
//            Spending(name: "Coffee", amount: 5.50, payer: "Eric", participants: ["Eric", "Carl"]),
//            Spending(name: "Groceries", amount: 100.00, payer: "BU", participants: ["Carl", "Eric", "BU"]),
//            Spending(name: "Taxi Ride", amount: 25.00, payer: "Carl", participants: ["Carl", "Eric"]),
//            Spending(name: "Movie Tickets", amount: 45.00, payer: "Eric", participants: ["Eric", "BU"]),
//            Spending(name: "Gym Membership", amount: 60.00, payer: "BU", participants: ["BU"]),
//            Spending(name: "Concert Tickets", amount: 120.00, payer: "Carl", participants: ["Carl", "Eric", "BU"]),
//            Spending(name: "Dinner Party", amount: 80.00, payer: "Eric", participants: ["Carl", "Eric", "BU"])
//        ])
//    }
//}

struct RecordView: View {
    @Binding var spendings: [Spending] // Changed to @State to allow deletion
    
    var body: some View {
        NavigationView {
            VStack {
                // Summary Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(calculateParticipantSums().sorted(by: { $0.key < $1.key }), id: \.key) { participant, total in
                            VStack {
                                Text(participant)
                                    .font(.headline)
                                Text("\(total, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 86) // Fixed width for each participant
                            .padding()
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

    private func deleteSpending(at offsets: IndexSet) {
        spendings.remove(atOffsets: offsets)
    }
    
    private func calculateParticipantSums() -> [String: Double] {
        var participantSums: [String: Double] = [:]
        
        for spending in spendings {
            let share = spending.amount / Double(spending.participants.count)
            for participant in spending.participants {
                participantSums[participant, default: 0.0] += share
            }
        }
        
        return participantSums
    }
}
