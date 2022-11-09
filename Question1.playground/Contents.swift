import Foundation

protocol CompanyProtocol {
    func increaseOf(budget amount: Double)
    func decreaseOf(budget amount: Double)
    func add(employee: Employee)
    func paySalariesOfEmployees(completion: (() -> Void)?)
}

protocol EmployeeProtocol {
    func calculateSalary() -> Double
}

class Company: CompanyProtocol {
    let companyName: String
    var companyEmployeeCount: Int {
        get {
            self.companyEmployees.count
        }
    }
    var companyBudget: Double
    let companyFoundationYear: Int
    
    var companyEmployees = [Int: Employee]()
    
    init(companyName: String, companyBudget: Double, companyFoundationYear: Int) {
        self.companyName = companyName
        self.companyBudget = companyBudget
        self.companyFoundationYear = companyFoundationYear
    }
    
    func increaseOf(budget amount:Double) {
        self.companyBudget += amount
    }
    
    func decreaseOf(budget amount:Double) {
        self.companyBudget -= amount
    }
    
    func add(employee: Employee) {
        companyEmployees[self.companyEmployeeCount] = employee
    }
    
    func paySalariesOfEmployees(completion: (() -> Void)? = nil) {
        var totalSalaryPayments: Double = 0
        for index in 0..<self.companyEmployeeCount {
            totalSalaryPayments += companyEmployees[index]!.calculateSalary()
        }
        
        self.decreaseOf(budget: totalSalaryPayments)
        
        if completion != nil {
            completion!()
        }
    }
}

struct Employee: EmployeeProtocol {
    let employeeName: String
    let employeeAge: Int
    var employeeMaritalStatus: EmployeeMaritalStatus
    var employeeType: EmployeeType
    
    func calculateSalary() -> Double {
        return Double((self.employeeAge * self.employeeType.rawValue * 1000))
    }
}

enum EmployeeMaritalStatus {
    case single
    case married
}

enum EmployeeType: Int {
    case juniour = 1
    case middle = 2
    case senior = 3
}

var vakifBank: Company

vakifBank = Company(companyName: "VakifBank", companyBudget: 500_000, companyFoundationYear: 1954)
vakifBank.increaseOf(budget: 500_000)

vakifBank.add(employee: Employee(employeeName: "Alihan KUZUCUK", employeeAge: 25, employeeMaritalStatus: EmployeeMaritalStatus.single, employeeType: EmployeeType.juniour))

vakifBank.add(employee: Employee(employeeName: "Kaan YILDIRIM", employeeAge: 30, employeeMaritalStatus: EmployeeMaritalStatus.single, employeeType: EmployeeType.senior))

vakifBank.paySalariesOfEmployees {
    print("\(vakifBank.companyEmployeeCount) salary paid on Company Budget. New budget is now \(vakifBank.companyBudget)")
}
