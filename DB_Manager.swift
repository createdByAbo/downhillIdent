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
            print(error.localizedDescription)
        }
    }
    
    public func addIdentity(idVal: Int64, purchasedDownHillsVal: Int64, isDailyTicketPurchasedVal: Bool) {
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        do {
            if isDailyTicketPurchasedVal {
                try db.run(identities.insert(id <- idVal, purchasedDownHills <- INT64_MAX, isDailyTicketPurchased <- isDailyTicketPurchasedVal, creationTime <- df.string(from: date), currentDownHills <- INT64_MAX))
            } else {
                try db.run(identities.insert(id <- idVal, purchasedDownHills <- purchasedDownHillsVal, isDailyTicketPurchased <- isDailyTicketPurchasedVal, creationTime <- df.string(from: date), currentDownHills <- purchasedDownHillsVal))
            }
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
    
    public func getIdentitiesById(idVal: Int64) -> [IdentityModel] {
        var identityModels: [IdentityModel] = []
        
        identities = identities.filter(id == idVal)
        
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
    
    public func updateCurrentDownHillsById(idVal: Int64, count: Int64) {
        do {
            try db.transaction {
                let filtered = identities.filter(id == idVal)
                if try db.run(filtered.update(currentDownHills += count)) > 0 {
                    print("succ. updated")
                } else {
                    print("not found")
                }
            }
        } catch {
            print("transaction error: \(error)")
        }
    }
    
    public func calculateTotal(isDailyTicketPurchased: Bool, purchasedDownHills: Int64) -> Double {
        let total = (isDailyTicketPurchased) ? Double(35.0) : Double(1.5 * Double(purchasedDownHills));
        return total
    }
    
    public func dropTableData() {
        do {
            try db.transaction {
                try db.run(identities.delete())
                print("succ. deleted all data from table")
            }
        } catch {
            print("transaction error: \(error)")
        }
    }
    
    public func dropRowById(idVal: Int64) {
        do {
            try db.transaction {
                try db.run(identities.filter(id == idVal).delete())
                print("succ. deleted row with id \(idVal) from table")
            }
        } catch {
            print("transaction error: \(error)")
        }
    }
}
