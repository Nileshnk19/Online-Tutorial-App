
import Foundation
import FirebaseFirestore

class FirebaseDBHelper : ObservableObject{
    
    @Published var userList = [User]()
    @Published var allSessionList = [SessionList]()
    @Published var favouriteList = [SessionList]()
    @Published var purchaseList = [Purchase]()
    @Published var alreadyAddedToFavouriteList = false
    
    //singleton instance
    private static var shared : FirebaseDBHelper?
    
    private let db : Firestore
    
    private let COLLECTION_NAME = "User"
    var FIELD_EMAIL : String = "email"
    private let FIELD_NAME : String = "name"
    private let FIELD_CONTACT_NUMBER : String = "contactNumber"
    private let FIELD_CARD_DETAIL : String = "cardDetail"
    
    private let COLLECTION_SESSION = "Session"
    private let COLLECTION_PURCHASE = "PTicket"
    private let COLLECTION_FAVORITE  = "Favourite"
    private let FIELD_IS_FAVOURITE = "isFavorite"
    
    private var sessionList =
    [
        SessionList(name: "High Park Nature Walk", description: "Explore the diverse ecosystems of High Park, from lush forests to serene ponds, while learning about the local flora and fauna.", rating: 4.7, guideName: "Sarah Thompson", photo: ["HighParkImage1", "HighParkImage2"], price: 25.00, isFavorite: false, guidePhoneNumber: 5555551234, location: "375 Colborne Lodge Dr, Toronto, ON M6R 2Z3"),
        
        SessionList(name: "Don Valley Ravine Hike", description: "Discover the beauty of Toronto's ravine system as you trek through the Don Valley, spotting wildlife and enjoying stunning views of the city skyline.", rating: 4.5, guideName: "Mark Johnson", photo: ["DonValleyImage1", "DonValleyImage2"], price: 30.00, isFavorite: false, guidePhoneNumber: 5555555678, location: "Don Valley Pkwy, Toronto, ON"),
        
        SessionList(name: "Tommy Thompson Park Bird Watching Tour", description: "Join us for a guided bird watching excursion at Tommy Thompson Park, a designated Important Bird Area, where you'll observe a variety of migratory and resident bird species.", rating: 4.9, guideName: "Emily Chen", photo: ["TommyThompsonImage1", "TommyThompsonImage2"], price: 20.00, isFavorite: false, guidePhoneNumber: 5555559012, location: "1 Leslie St, Toronto, ON M4M 3M2"),
        
        SessionList(name: "Toronto Islands Nature Walk", description: "Embark on a leisurely stroll through the Toronto Islands, exploring sandy beaches, lush gardens, and tranquil lagoons, while learning about the islands' natural history.", rating: 4.8, guideName: "David Rodriguez", photo: ["TorontoIslandsImage1", "TorontoIslandsImage2"], price: 35.00, isFavorite: false, guidePhoneNumber: 5555553456, location: "Lakeshore Ave, Toronto, ON M5J 1X7"),
        
        SessionList(name: "Humber Bay Butterfly Sanctuary Tour", description: "Immerse yourself in the enchanting world of butterflies at the Humber Bay Butterfly Sanctuary, where you'll marvel at colorful wings and learn about the lifecycle of these fascinating insects.", rating: 4.6, guideName: "Samantha Lee", photo: ["HumberBayImage1", "HumberBayImage2"], price: 15.00, isFavorite: false, guidePhoneNumber: 5555557890, location: "100 Humber Bay Park Rd W, Etobicoke, ON M8V 3X7"),
        
        SessionList(name: "Rouge National Urban Wilderness Trail Trek", description: "Trek through the rugged beauty of Rouge National Urban Park, Canada's first national urban park, encountering diverse wildlife and breathtaking landscapes along the way.", rating: 4.7, guideName: "Michael Brown", photo: ["RougeNationalImage1", "RougeNationalImage2"], price: 40.00, isFavorite: false, guidePhoneNumber: 5555552345, location: "19 Reesor Rd, Scarborough, ON M1X 0A5"),
        
        SessionList(name: "Scarborough Bluffs Nature Walk", description: "Explore the dramatic cliffs and sandy shores of Scarborough Bluffs, marveling at stunning views of Lake Ontario and discovering the unique plant and animal life that call this area home.", rating: 4.5, guideName: "Jennifer Smith", photo: ["ScarboroughBluffsImage1", "ScarboroughBluffsImage2"], price: 25.00, isFavorite: false, guidePhoneNumber: 5555556789, location: "Scarborough, ON M1M 3W3")
        
    ]
    
    //initializer to initialze
    init(db: Firestore) {
        self.db = db
    }
    
    //Creating the singleton
    static func getInstance() -> FirebaseDBHelper {
        
        if (shared == nil) {
            shared = FirebaseDBHelper(db: Firestore.firestore())
        }
        return shared!
    }
    
    func insertUser(newUser : User){
        
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        self.FIELD_EMAIL = newUser.email
        
        if (loggedInUserEmail.isEmpty) {
            print(#function, "No Logged in user")
        } else {
            
            do {
                try self.db.collection(COLLECTION_NAME)
                    .document(loggedInUserEmail)
                    .collection("userdetail")
                    .addDocument(from: newUser)
                print(#function, "User added to firestore")
            } catch let err {
                print(#function, "Unable to insert the document to firestore: \(err)")
            }
        }
    }
    
    func getUser(){
        
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        self.FIELD_EMAIL = loggedInUserEmail
        
        if (loggedInUserEmail.isEmpty) {
            print(#function, "No Logged in user")
        } else {
            
            do {
                
                self.db.collection(COLLECTION_NAME)
                    .document(loggedInUserEmail)
                    .collection("userdetail")
                    .addSnapshotListener { (querySnapshot, error) in
                        if let error = error {
                            print("Error while loading user info: \(error.localizedDescription)")
                            return
                        }
                        
                        guard let documents = querySnapshot?.documents else {
                            print("No user documents found")
                            return
                        }
                        
                        self.userList = documents.compactMap { document in
                            do {
                                var userProfile = try document.data(as: User.self)
                                userProfile.id = document.documentID
                                return userProfile
                            } catch {
                                print("Error decoding user profile: \(error.localizedDescription)")
                                return nil
                            }
                        }
                        
                        if let user = self.userList.first {
                            print("Loaded user info for: \(user.name)")
                        } else {
                            print("No user info loaded")
                        }
                    }
            } catch let error {
                print(#function,"Unable to insert the document to firestore : \(error)")
            }//catch
        }//else
    }
    
    func updateUser(updatedUser : User){
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (loggedInUserEmail.isEmpty) {
            print(#function, "No Logged in user")
        } else {
            do{
                
                self.db.collection(COLLECTION_NAME)
                    .document(loggedInUserEmail)
                    .collection("userdetail")
                    .document(updatedUser.id!)
                    .updateData(
                        [
                            FIELD_NAME : updatedUser.name,
                            FIELD_CONTACT_NUMBER : updatedUser.contactNumber,
                            FIELD_CARD_DETAIL : updatedUser.cardDetail
                        ]
                    ){error in
                        
                        if let err = error {
                            print(#function, "Unable to update document : \(err)")
                        }else{
                            print(#function, "Successfully updated document : \(updatedUser.id) (\(updatedUser.name))")
                        }
                    }
                
            }catch let error{
                print(#function, "Unable to update the documents from firestore : \(error)")
            }
        }
    }
    
    func deleteUser(userToDelete : User){
        
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (loggedInUserEmail.isEmpty) {
            print(#function, "No Logged in user")
        } else {
            
            do {
                self.db.collection(COLLECTION_NAME)
                    .document(loggedInUserEmail)
                    .delete { error in
                        
                        if let err = error {
                            print(#function, "Unable to delete user: \(err)")
                        } else {
                            print(#function, "Successfully deleted user: \(userToDelete.id) (\(userToDelete.name)")
                        }
                    }
            } catch let error {
                print(#function,"Unable to delete the document to firestore : \(error)")
            }
        }
    }
    
    func inserrtSessionList() {
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        do {
            for session in sessionList {
                try self.db.collection(COLLECTION_SESSION)
                    .addDocument(from: session)
            }
        } catch let err {
            print(#function, "Unable to insert the document to firestore: \(err)")
        }
    }
    
    func getAllSesstionList() {
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        do {
            print("LogIN USer: \(loggedInUserEmail)")
            self.db.collection(COLLECTION_SESSION)
                .addSnapshotListener({(QuerySnapshot, error) in
                    //querySnapshot - query result set
                    
                    //check if result is not nil
                    guard let snapshot = QuerySnapshot else {
                        print(#function, "No results received from firestore : \(error)")
                        return
                    }
                    
                    //process the result
                    
                    //snapshot.documentChanges is array of all the documentchanges since last snapshot is retrieved by app
                    snapshot.documentChanges.forEach{(docChange) in
                        //work on each document that changed
                        do {
                            print(#function,"docChange : \(docChange)")
                            print(#function,"docChange.document : \(docChange.document)")
                            print(#function,"docChange.document.data : \(docChange.document.data())")
                            print(#function,"docChange.document.documentID : \(docChange.document.documentID)")
                            
                            var session: SessionList = try docChange.document.data(as: SessionList.self)
                            session.id = docChange.document.documentID
                            
                            print(#function,"session : \(session)")
                            
                            
                            let matchedIndex = self.allSessionList.firstIndex(where: {($0.id?.elementsEqual(session.id!) )! })
                            
                            //identify the changes that happened and process the document or object accordingly
                            switch (docChange.type) {
                            case .added:
                                //document change indicates the document was inserted
                                if (matchedIndex == nil) {
                                    self.allSessionList.append(session)
                                }
                                
                            case .modified:
                                //document change indicates the document was updated
                                print(#function,"Document modified : \(docChange.document.documentID)")
                                if (matchedIndex != nil) {
                                    self.allSessionList[matchedIndex!] = session
                                }
                                
                            case .removed:
                                print(#function,"Document deleted : \(docChange.document.documentID)")
                                
                                if (matchedIndex != nil) {
                                    self.allSessionList.remove(at: matchedIndex!)
                                } else {
                                }
                            }
                        } catch let error {
                            print(#function, "Unable to access document change : \(error)")
                        }
                    }
                })
        } catch let error {
            print(#function,"Unable to insert the document to firestore : \(error)")
        }//catch
    }
    
    func insertFavourite(newFavourite: SessionList) {
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (loggedInUserEmail.isEmpty) {
            print(#function, "No Logged in user")
        } else {
            
            do {
                try self.db.collection(COLLECTION_NAME)
                    .document(loggedInUserEmail)
                    .collection(COLLECTION_FAVORITE)
                    .whereField("name", isEqualTo: newFavourite.name)
                    .addSnapshotListener({(QuerySnapshot, error) in
                    
                        //check if result is not nil
                        guard let snapshot = QuerySnapshot else {
                            print(#function, "No results received from firestore : \(error)")
                            return
                        }
                        
                        self.alreadyAddedToFavouriteList = true
                        
                    })
                
                if self.alreadyAddedToFavouriteList {
                    print(#function, "Already added to favourite list.")
                } else {
                    try self.db.collection(COLLECTION_NAME)
                        .document(loggedInUserEmail)
                        .collection(COLLECTION_FAVORITE)
                        .addDocument(from: newFavourite)
                }
                
            } catch let err {
                print(#function, "Unable to insert the document to firestore: \(err)")
            }
        }
    }
    
    func getAllFavouriteList() {
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        if (loggedInUserEmail.isEmpty) {
            print(#function, "No Logged in user")
        } else {
            
            do {
                print("LogIN USer: \(loggedInUserEmail)")
                self.db.collection(COLLECTION_NAME)
                    .document(loggedInUserEmail)
                    .collection(COLLECTION_FAVORITE)
                    .addSnapshotListener({(QuerySnapshot, error) in
                        //querySnapshot - query result set
                        
                        //check if result is not nil
                        guard let snapshot = QuerySnapshot else {
                            print(#function, "No results received from firestore : \(error)")
                            return
                        }
                        
                        //process the result
                        
                        //snapshot.documentChanges is array of all the documentchanges since last snapshot is retrieved by app
                        snapshot.documentChanges.forEach{(docChange) in
                            //work on each document that changed
                            do {
                                print(#function,"docChange : \(docChange)")
                                print(#function,"docChange.document : \(docChange.document)")
                                print(#function,"docChange.document.data : \(docChange.document.data())")
                                print(#function,"docChange.document.documentID : \(docChange.document.documentID)")
                                
                                var session: SessionList = try docChange.document.data(as: SessionList.self)
                                session.id = docChange.document.documentID
                                
                                print(#function,"session : \(session)")
                                
                                
                                
                                let matchedIndex = self.favouriteList.firstIndex(where: {($0.id?.elementsEqual(session.id!) )! })
                                
                                //identify the changes that happened and process the document or object accordingly
                                switch (docChange.type) {
                                case .added:
                                    //document change indicates the document was inserted
                                    if (matchedIndex == nil) {
                                        self.favouriteList.append(session)
                                    }
                                    
                                case .modified:
                                    //document change indicates the document was updated
                                    print(#function,"Document modified : \(docChange.document.documentID)")
                                    if (matchedIndex != nil) {
                                        self.favouriteList[matchedIndex!] = session
                                    }
                                    
                                case .removed:
                                    print(#function,"Document deleted : \(docChange.document.documentID)")
                                    
                                    if (matchedIndex != nil) {
                                        self.favouriteList.remove(at: matchedIndex!)
                                    }
                                }
                            } catch let error {
                                print(#function, "Unable to access document change : \(error)")
                            }
                        }
                    })
            } catch let error {
                print(#function,"Unable to insert the document to firestore : \(error)")
            }//catch
        }//else
    }
    
    func updateFavourite(favouriteToUpdate: SessionList) {
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (loggedInUserEmail.isEmpty) {
            print(#function, "No Logged in user")
        } else {
            
            do {
                print(#function, "id: \(favouriteToUpdate.id!)")
                self.db.collection(COLLECTION_SESSION)
                    .document(favouriteToUpdate.id!)
                    .updateData([
                        FIELD_IS_FAVOURITE : favouriteToUpdate.isFavorite,
                        
                    ]) { error in
                        if let err = error {
                            print(#function, "Unable to update document: \(err)")
                        } else {
                            print(#function, "Successfully updated document: \(favouriteToUpdate.id) (\(favouriteToUpdate.isFavorite)")
                        }
                    }
            } catch let error {
                print(#function, "Unable to update the document to firestore: \(error)")
            }
        }
    }
    
    func deleteFavourite(favouriteTodelete: SessionList) {
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (loggedInUserEmail.isEmpty) {
            print(#function, "No Logged in user")
        } else {
            
            do {
                self.db.collection(COLLECTION_NAME)
                    .document(loggedInUserEmail)
                    .collection(COLLECTION_FAVORITE)
                    .document(favouriteTodelete.id!)
                    .delete{ error in
                        if let err = error {
                            print(#function, "Unable to delete document: \(err)")
                        } else {
                            print(#function, "Successfully deleted document: \(favouriteTodelete.id) ()")
                        }
                    }
            } catch let error {
                print(#function,"Unable to delete the document to firestore : \(error)")
            }
        }
    }
    
    func deleteAllFavourite() {
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (loggedInUserEmail.isEmpty) {
            print(#function, "No Logged in user")
        } else {
            
            do {
                self.db.collection(COLLECTION_NAME)
                    .document(loggedInUserEmail)
                    .collection(COLLECTION_FAVORITE)
                    .getDocuments{(QuerySnapshot, error) in
                        if let err = error {
                            print(#function, "Unable to delete all favourite list: \(err)")
                        }
                        
                        QuerySnapshot?.documents.forEach{ document in
                            document.reference.delete() { error in
                                if let err = error {
                                    print(#function, "Unable to delete all favourite list: \(err)")
                                }
                            }
                        }
                    }
            } catch let error {
                print(#function,"Unable to delete the document to firestore : \(error)")
            }
        }
    }
    
    func getPurchases() {
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        if (loggedInUserEmail.isEmpty) {
            print(#function, "No Logged in user")
        } else {
            
            do {
                print("LogIN USer: \(loggedInUserEmail)")
                self.db.collection(COLLECTION_NAME)
                    .document(loggedInUserEmail)
                    .collection(COLLECTION_PURCHASE)
                    .addSnapshotListener({(QuerySnapshot, error) in
                        //querySnapshot - query result set
                        
                        //check if result is not nil
                        guard let snapshot = QuerySnapshot else {
                            print(#function, "No results received from firestore : \(error)")
                            return
                        }
                        
                        snapshot.documentChanges.forEach{(docChange) in
                            do {
                                print(#function,"docChange : \(docChange)")
                                print(#function,"docChange.document : \(docChange.document)")
                                print(#function,"docChange.document.data : \(docChange.document.data())")
                                print(#function,"docChange.document.documentID : \(docChange.document.documentID)")
                                
                                var purchase: Purchase = try docChange.document.data(as: Purchase.self)
                                purchase.id = docChange.document.documentID
                                
                                print(#function,"purchase : \(purchase)")
                                
                                
                                let matchedIndex = self.purchaseList.firstIndex(where: {($0.id?.elementsEqual(purchase.id!) )! })
                                
                                switch (docChange.type) {
                                case .added:
                                    if (matchedIndex == nil) {
                                        self.purchaseList.append(purchase)
                                    }
                                    
                                case .modified:
                                    print(#function,"Document modified : \(docChange.document.documentID)")
                                    if (matchedIndex != nil) {
                                        self.purchaseList[matchedIndex!] = purchase
                                    }
                                    
                                case .removed:
                                    print(#function,"Document deleted : \(docChange.document.documentID)")
                                    
                                    if (matchedIndex != nil) {
                                        self.purchaseList.remove(at: matchedIndex!)
                                    }
                                }
                            } catch let error {
                                print(#function, "Unable to access document change : \(error)")
                            }
                        }
                    })
            } catch let error {
                print(#function,"Unable to insert the document to firestore : \(error)")
            }//catch
        }//else
    }
    
    func addPurchase(purchase: Purchase) {
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (loggedInUserEmail.isEmpty) {
            print(#function, "No Logged in user")
        } else {
            do {
                try self.db.collection(COLLECTION_NAME)
                    .document(loggedInUserEmail)
                    .collection(COLLECTION_PURCHASE)
                    .addDocument(from: purchase)
            } catch let error {
                print("Error adding purchase: \(error.localizedDescription)")
            }
        }
    }
}

