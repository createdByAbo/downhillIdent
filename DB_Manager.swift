import Foundation
import SQLite

class DB_Manager {
    private var db: Connection!
    private var identities: Table!
    
    private var id: Expression<Int64>!
    private var creationTime: Expression<String>!
    private var purchasedDownHills: Expression<Int64>!
    private var currentDownHills: Expression<Int64>!
    private var isDailyTicketPurchased: Expression<Bool>!
    
    init () {
        do {
            let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
            
            db = try Connection("\(path)/identities.sqlite3")
            identities = Table("identities")
            
            id = Expression<Int64>("id")
            creationTime = Expression<String>("creationTime")
            purchasedDownHills = Expression<Int64>("purchasedDownHills")
            currentDownHills = Expression<Int64>("currentDownHills")
            isDailyTicketPurchased = Expression<Bool>("isDailyTicketPurchased")
            
            if (!UserDefaults.standard.bool(forKey: "is_db_created")) {
                try db.run(identities.create { (t) in
                    t.column(id, primaryKey: true)
                    t.column(creationTime)
                    t.column(purchasedDownHills)
                    t.column(currentDownHills)
                    t.column(isDailyTicketPurchased)
                })
                
                UserDefaults.standard.set(true, forKey: "is_db_created")
            }
        }
        catch {
            // show error message if any
            print(error.localizedDescription)
        }
    }
    
    public func addIdentity(idVal: Int64, purchasedDownHillsVal: Int64, isDailyTicketPurchasedVal: Bool) {
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        do {
            try db.run(identities.insert(id <- idVal, purchasedDownHills <- purchasedDownHillsVal, isDailyTicketPurchased <- isDailyTicketPurchasedVal, creationTime <- df.string(from: date), currentDownHills <- purchasedDownHillsVal))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func getIdentities() -> [IdentityModel] {
        var identityModels: [IdentityModel] = []
        
        identities = identities.order(currentDownHills.asc)
        
        do {
            for identity in try db.prepare(identities) {
                let identityModel: IdentityModel = IdentityModel()
                
                identityModel.id = identity[id]
                identityModel.creationTime = identity[creationTime]
                identityModel.currentDownHills = identity[currentDownHills]
                identityModel.purchasedDownHills = identity[purchasedDownHills]
                identityModel.isDailyTicketPurchased = identity[isDailyTicketPurchased]
                
                identityModels.append(identityModel)
            }
        } catch {
            print(error.localizedDescription)
        }
        return identityModels
    }
}
