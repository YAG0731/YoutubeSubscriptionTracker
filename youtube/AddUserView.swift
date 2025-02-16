import SwiftUI
import CoreData

struct AddUserView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var paymentManager: PaymentManager
    @State private var name = "New User"
    @State private var paidDate = Date()
    @State private var monthsCovered = 1
    
    var body: some View {
        Form {
            Section(header: Text("User Details")) {
                TextField("Name", text: $name)
                DatePicker("Paid Date", selection: $paidDate, displayedComponents: .date)
                Stepper("Months: \(monthsCovered)", value: $monthsCovered, in: 1...12)
            }
            
            Button("Save") {
                let newUser = User(context: paymentManager.viewContext)
                newUser.id = UUID()
                newUser.name = name
                
                let payment = Payment(context: paymentManager.viewContext)
                payment.paidDate = paidDate
                payment.monthsCovered = Int16(monthsCovered)
                payment.user = newUser
                newUser.addToPayments(payment)
                
                paymentManager.saveContext()
                paymentManager.fetchPaymentsAndUsers()
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationTitle("Add New User")
    }
}
