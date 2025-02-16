import SwiftUI
import CoreData

struct UserDetailView: View {
    @ObservedObject var user: User
    @State private var date: Date
    @State private var months: Int
    @EnvironmentObject var paymentManager: PaymentManager
    @Environment(\.presentationMode) var presentationMode
    
    init(user: User, paymentManager: PaymentManager) {
        self.user = user
        
        if let firstPayment = user.payments?.allObjects.first as? Payment {
            _date = State(initialValue: firstPayment.paidDate ?? Date())
            _months = State(initialValue: Int(firstPayment.monthsCovered))
        } else {
            _date = State(initialValue: Date())
            _months = State(initialValue: 1)
        }
    }
    
    var body: some View {
        Form {
            TextField("Name", text: Binding(
                get: { user.name ?? "" },
                set: { newValue in
                    user.name = newValue
                    paymentManager.saveContext()
                }
            ))
            
            DatePicker("Paid Date", selection: $date, displayedComponents: .date)
            
            Stepper("Months: \(months)", value: $months, in: 1...12)
            
            Button("Save") {
                if let existingPayment = user.payments?.allObjects.first as? Payment {
                    existingPayment.paidDate = date
                    existingPayment.monthsCovered = Int16(months)
                } else {
                    paymentManager.addPayment(for: user, date: date, months: months)
                }
                paymentManager.saveContext()
                presentationMode.wrappedValue.dismiss()
            }
            
            Button("Delete User") {
                paymentManager.deleteUser(user)
                presentationMode.wrappedValue.dismiss()
            }
            .foregroundColor(.red)
            .padding(.top, 10)
        }
        .navigationTitle("Edit Payment")
    }
}
