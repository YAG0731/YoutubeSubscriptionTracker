import Foundation
import CoreData
import SwiftUI

class PaymentManager: ObservableObject {
    @Published var payments: [Payment] = []
    @Published var users: [User] = []
    
    var viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchPaymentsAndUsers()
    }

    // Fetch payments and associated users
    func fetchPaymentsAndUsers() {
        let paymentFetchRequest: NSFetchRequest<Payment> = Payment.fetchRequest()
        let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        do {
            self.payments = try viewContext.fetch(paymentFetchRequest)
            self.users = try viewContext.fetch(userFetchRequest)
        } catch {
            print("Failed to fetch data: \(error.localizedDescription)")
        }
    }

    func addNewUser() -> User {
        let newUser = User(context: viewContext)
        newUser.id = UUID()
        newUser.name = "New User"
        saveContext()
        fetchPaymentsAndUsers()
        return newUser
    }

    // Add a payment for a user
    func addPayment(for user: User, date: Date, months: Int) {
        let payment = Payment(context: viewContext)
        payment.paidDate = date
        payment.monthsCovered = Int16(months)
        payment.user = user // associate payment with user
        user.addToPayments(payment)  // Update the user's payments relationship
        
        // Save to Core Data
        saveContext()
    }

    // Delete user and associated payments
    func deleteUser(_ user: User) {
        if let payments = user.payments?.allObjects as? [Payment] {
            for payment in payments {
                viewContext.delete(payment) // Delete all associated payments
            }
        }
        
        viewContext.delete(user) // Delete the user
        saveContext()
        fetchPaymentsAndUsers() // Reload users after deletion
    }

    // Helper function to save changes to Core Data
    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
    
    func paymentStatusColor(for user: User) -> Color {
        guard let payment = user.payments?.allObjects.first as? Payment else {
            return Calendar.current.component(.day, from: Date()) > 22 ? .red : .yellow
        }
        
        if let validUntil = Calendar.current.date(byAdding: .month, value: Int(payment.monthsCovered), to: payment.paidDate ?? Date()) {
            let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: Date())
            if validUntil >= (nextMonth ?? Date()) {
                return .green
            }
        }
        return Calendar.current.component(.day, from: Date()) > 22 ? .red : .yellow
    }

    // Get the paid until date for a user
    func getPaidUntil(for user: User) -> String {
        guard let payment = user.payments?.allObjects.first as? Payment else { return "Not Paid" }
        
        if let validUntil = Calendar.current.date(byAdding: .month, value: Int(payment.monthsCovered), to: payment.paidDate ?? Date()) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: validUntil)
        }
        
        return "Not Paid"
    }
}
