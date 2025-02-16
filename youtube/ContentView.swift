import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var paymentManager: PaymentManager
    init(context: NSManagedObjectContext) {
        _paymentManager = StateObject(wrappedValue: PaymentManager(context: context))
    }
    @State private var selectedUser: User?
    @State private var showingAddUser = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(paymentManager.users, id: \.userID) { user in
                    NavigationLink(
                        destination: UserDetailView(user: user, paymentManager: paymentManager)
                    ) {
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
                paymentManager.fetchPaymentsAndUsers()
            }
            .navigationBarItems(trailing: Button(action: {
                showingAddUser = true
            }) {
                Text("Add User")
            })
            .sheet(isPresented: $showingAddUser) {
                NavigationView {
                    AddUserView()
                        .environmentObject(paymentManager)
                }
            }
        }
    }
    
    func deleteUser(at offsets: IndexSet) {
        for index in offsets {
            let user = paymentManager.users[index]
            paymentManager.deleteUser(user)
        }
    }
}

// 1. First, ensure User entity has a unique identifier
extension User {
    @objc dynamic var userID: String {
        get {
            return id?.uuidString ?? UUID().uuidString
        }
    }
}
