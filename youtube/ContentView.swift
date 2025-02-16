import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var paymentManager: PaymentManager
    
    init(context: NSManagedObjectContext) {
        _paymentManager = StateObject(wrappedValue: PaymentManager(context: context))
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(paymentManager.users, id: \.id) { user in
                    NavigationLink(destination: UserDetailView(user: user, paymentManager: paymentManager)) {
                        HStack {
                            Text(user.name ?? "Unknown User")
                            Spacer()
                            Text(paymentManager.getPaidUntil(for: user))
                                .foregroundColor(paymentManager.paymentStatusColor(for: user))
                        }
                    }
                }
                .onDelete(perform: deleteUser)
            }
            .navigationTitle("Payments")
            .onAppear {
                paymentManager.fetchPaymentsAndUsers() // Refresh data when the view appears
            }
            .navigationBarItems(trailing: Button(action: {
                paymentManager.addNewUser()  // Action to add new user
            }) {
                Text("Add User")
            })
        }
    }

    func deleteUser(at offsets: IndexSet) {
        for index in offsets {
            let user = paymentManager.users[index]
            paymentManager.deleteUser(user)  // Delete the user
        }
    }
}
