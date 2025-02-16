import SwiftUI
import CoreData

struct AddUserView: View {
    @State private var name: String = ""
    @State private var paidDate: Date = Date()
    @State private var monthsCovered: Int = 1
    
    @EnvironmentObject var paymentManager: PaymentManager // Access PaymentManager via EnvironmentObject
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            Section(header: Text("User Details")) {
                TextField("Name", text: $name)
                DatePicker("Paid Date", selection: $paidDate, displayedComponents: .date)
                Stepper("Months: \(monthsCovered)", value: $monthsCovered, in: 1...12)
            }
            
            Button("Save") {
                saveUser()
                presentationMode.wrappedValue.dismiss() // Close the form after saving
            }
        }
        .navigationTitle("Add New User")
    }
    
    func saveUser() {
        // Create a new User object
        let newUser = User(context: paymentManager.viewContext)
        newUser.name = name.isEmpty ? "New User" : name  // Default name if empty
        
        // Create a new Payment for the user
        let payment = Payment(context: paymentManager.viewContext)
        payment.paidDate = paidDate
        payment.monthsCovered = Int16(monthsCovered)
        payment.user = newUser
        
        // Add payment to user's payments relationship
        newUser.addToPayments(payment)
        
        // Save context to persist changes
        paymentManager.saveContext()
    }
}
