import SwiftUI
import CoreData

struct UserDetailView: View {
    @State var user: User
    @State private var date: Date
    @State private var months: Int
    @EnvironmentObject var paymentManager: PaymentManager
    @Environment(\.presentationMode) var presentationMode
    
    init(user: User, paymentManager: PaymentManager) {
        self._user = State(initialValue: user)
        
        // Safely unwrap the first payment if it exists, otherwise set default values
        if let firstPayment = user.payments?.allObjects.first as? Payment {
            self._date = State(initialValue: firstPayment.paidDate ?? Date())  // Use first payment date or fallback to current date
            self._months = State(initialValue: Int(firstPayment.monthsCovered)) // Use first payment's monthsCovered or fallback
        } else {
            self._date = State(initialValue: Date())  // Default to current date if no payments
            self._months = State(initialValue: 1)    // Default to 1 month if no payments
        }
    }
    
    var body: some View {
        Form {
            // Binding the name field to user.name
            TextField("Name", text: Binding(get: { user.name ?? "" }, set: { user.name = $0 }))
            
            DatePicker("Paid Date", selection: $date, displayedComponents: .date)
            
            Stepper("Months: \(months)", value: $months, in: 1...12)
            
            Button("Save") {
                if let existingPayment = user.payments?.allObjects.first as? Payment {
                    // Update existing payment
                    existingPayment.paidDate = date
                    existingPayment.monthsCovered = Int16(months)
                } else {
                    // Add new payment
                    paymentManager.addPayment(for: user, date: date, months: months)
                }
                paymentManager.saveContext()
                presentationMode.wrappedValue.dismiss()
            }
            
            Button("Delete User") {
                paymentManager.deleteUser(user)  // Delete the user
                presentationMode.wrappedValue.dismiss()  // Go back to the home screen
            }
            .foregroundColor(.red)
            .padding(.top, 10)
        }
        .navigationTitle("Edit Payment")
    }
}
