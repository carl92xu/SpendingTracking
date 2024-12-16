//
//  SettingsView.swift
//  SpendingTracking
//
//  Created by carl on 12/15/24.
//

import SwiftUI

struct SettingsView: View {
    @Binding var payers: [String]
    @State private var newPayer: String = ""

    var body: some View {
        NavigationView {
            VStack {
                // List of current payers
                List {
                    Section(header: Text("Payers").font(.headline).padding(.leading, -15)) {
                        ForEach(payers, id: \.self) { payer in
                            Text(payer)
                        }
                        .onDelete(perform: deletePayer)
                        .onMove(perform: movePayer)
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .toolbar {
                    EditButton()
                }

                // Add new payer
                HStack {
                    TextField("Add New Payer", text: $newPayer)
                        .roundedTextFieldStyle()
                        .padding(.horizontal, -10)

                    Button(action: addPayer) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title)
                    }
                }
                .padding()
                .padding(.top, -10)
            }
            .navigationTitle("Settings")
            .onTapGesture {
                dismissKeyboard()
            }
        }
    }

    // Add a new payer
    func addPayer() {
        guard !newPayer.isEmpty, !payers.contains(newPayer) else { return }
        payers.append(newPayer)
        savePayers()
        newPayer = ""
    }

    // Delete a payer
    func deletePayer(at offsets: IndexSet) {
        payers.remove(atOffsets: offsets)
        savePayers()
    }

    // Move a payer (reordering)
    func movePayer(from source: IndexSet, to destination: Int) {
        payers.move(fromOffsets: source, toOffset: destination)
        savePayers()
    }

    // Save payers to UserDefaults
    func savePayers() {
        UserDefaults.standard.set(payers, forKey: "payers")
    }
}


#Preview {
    @Previewable @State var payers: [String] = UserDefaults.standard.stringArray(forKey: "payers") ?? ["Eric", "BU", "Carl"]
    
    SettingsView(payers: $payers)
}
