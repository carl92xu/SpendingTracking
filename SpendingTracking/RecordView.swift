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

    private func deleteSpending(at offsets: IndexSet) {
        spendings.remove(atOffsets: offsets)
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
