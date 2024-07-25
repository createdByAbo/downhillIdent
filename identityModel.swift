import Foundation

class IdentityModel: Identifiable {
    public var id: Int64 = 0
    public var creationTime: String = ""
    public var purchasedDownHills: Int64 = -1
    public var currentDownHills: Int64 = 0
    public var isDailyTicketPurchased: Bool = false
}
