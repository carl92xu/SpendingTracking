//
//  RecordView.swift
//  SpendingTracking
//
//  Created by carl on 12/14/24.
//

import SwiftUI

struct Transaction: Identifiable, Hashable {
    let id = UUID() // Generate a unique identifier
    let payer: String
    let payee: String
    let amount: Double
}

struct RecordView: View {
    @Binding var spendings: [Spending]
    @State private var isSummaryBarExpanded: Bool = true
    @State private var useIndividualTransactions: Bool = false // Toggle state for function selection
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Conditionally Show Summary Bars with Animation
                if isSummaryBarExpanded {
//                    // Toggle to switch between the two functions
//                    HStack {
//                        Text("Minimize Payments")
//                            .font(.headline)
//                        Spacer()
//                        Toggle(isOn: $useIndividualTransactions) {
//                            Text("")
//                        }
//                        .labelsHidden()
//                    }
//                    .padding()
                    
                    VStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(calculateParticipantSummary().sorted(by: { $0.key < $1.key }), id: \.key) { participant, summary in
                                    VStack(alignment: .leading) {
                                        Text(participant)
                                            .font(.headline)
                                        Text("Spent: $\(summary.spent, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .foregroundColor(Color(UIColor.secondaryLabel))
                                        Text("Paid: $\(summary.paid, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .foregroundColor(Color(UIColor.secondaryLabel))
                                        Text("Total: $\(summary.spent - summary.paid, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
//                                            .foregroundColor(.black)
                                    }
                                    .padding(.horizontal, -50)
//                                    .frame(width: 120, height: 94) // Fixed width for each participant
                                    .frame(
                                        width: (UIScreen.main.bounds.width - 40) / 3, // Alwasy only display three cards
                                        height: 94
                                    )
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.blue.opacity(0.2))
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 5)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                // Use selected function based on toggle
                                let calcMethod = useIndividualTransactions
                                    ? calculateIndividualTransactions()
                                    : calculateParticipantSummarySplit()
                                
                                ForEach(calcMethod
                                    .filter { abs($0.amount) > 1e-6 } // Filters out amounts close to 0
//                                    .filter { $0.amount != 0 } // Filter out transactions with $0
                                    .sorted(by: { $0.payer < $1.payer }), id: \.id) { transaction in
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("\(transaction.payer)")
                                                .font(.headline)
                                                .foregroundColor(Color(UIColor.systemBlue))
                                            Text("owes")
                                                .padding(.leading, -4)
                                                .foregroundColor(Color(UIColor.secondaryLabel))
                                        }
                                        Text("\(transaction.payee)")
                                            .font(.headline)
                                            .foregroundColor(Color(UIColor.label))
                                        Text("$\(transaction.amount, specifier: "%.2f")")
                                            .font(.headline)
                                            .padding(.top, 5)
                                    }
                                    .padding(.horizontal, -50)
                                    .frame(width: 120, height: 94)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.green.opacity(0.2))
                                    )
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                        }
                    }
                    // Animation for collapsing/expanding
//                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeInOut, value: isSummaryBarExpanded)
                }
                    
                // Spending List
                List {
                    Section(header: Text("Spendings").font(.headline).offset(x: -15)) {
                        ForEach(spendings) { spending in
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(spending.name)
                                        .font(.headline)
                                    Spacer()
                                    Text("$\(spending.amount, specifier: "%.2f")")
                                }
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
                }
                .listStyle(InsetGroupedListStyle()) // Ensure proper list style
                .padding(.top, isSummaryBarExpanded ? 0 : 16)
                
            }
            .background(Color(.systemGray6))
            .navigationTitle("Summary")
//            .navigationBarTitleDisplayMode(.inline) // large/small title
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            isSummaryBarExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: isSummaryBarExpanded ? "chevron.up" : "chevron.down")
                        }
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Toggle(isOn: $useIndividualTransactions) {
                        Image(systemName: "gearshape.arrow.triangle.2.circlepath")
                    }
                    EditButton()
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

    // Calculate each individual's balance separately first, then assign debtors to creitors
    private func calculateParticipantSummarySplit() -> [Transaction] {
        var participantBalances: [String: Double] = [:]
        
        // Calculate balances
        for spending in spendings {
            let share = spending.amount / Double(spending.participants.count)
            
            // Subtract share from each participant
            for participant in spending.participants {
                participantBalances[participant, default: 0.0] -= share
            }
            
            // Add full amount to the payer
            participantBalances[spending.payer, default: 0.0] += spending.amount
        }
        
        // Determine who owes whom
        var transactions: [Transaction] = []
        var creditors = participantBalances.filter { $0.value > 0 }.sorted { $0.value > $1.value }
        var debtors = participantBalances.filter { $0.value < 0 }.sorted { $0.value < $1.value }
        
        while !creditors.isEmpty && !debtors.isEmpty {
            let creditor = creditors.first!
            let debtor = debtors.first!
            
            let amount = min(creditor.value, -debtor.value)
            
            transactions.append(Transaction(payer: debtor.key, payee: creditor.key, amount: amount))
            
            // Update balances
            creditors[0].value -= amount
            debtors[0].value += amount
            
            if creditors[0].value == 0 {
                creditors.removeFirst()
            }
            if debtors[0].value == 0 {
                debtors.removeFirst()
            }
        }
        
        return transactions
    }
    
    // Calculates and returns aggregated transactions showing who owes whom how much
    private func calculateIndividualTransactions() -> [Transaction] {
        var aggregatedTransactions: [String: Double] = [:]
        
        // Iterate through all spendings
        for spending in spendings {
            let share = spending.amount / Double(spending.participants.count)
            
            // Each participant owes their share to the payer
            for participant in spending.participants where participant != spending.payer {
                let key = "\(participant)->\(spending.payer)" // Unique key for each payer-payee pair
                aggregatedTransactions[key, default: 0.0] += share
            }
        }
        
        // Convert aggregated transactions back to [Transaction]
        var transactions: [Transaction] = []
        for (key, amount) in aggregatedTransactions {
            let pair = key.split(separator: "->")
            let payer = String(pair[0])
            let payee = String(pair[1])
            transactions.append(Transaction(payer: payer, payee: payee, amount: amount))
        }
        
        return transactions
    }
}
