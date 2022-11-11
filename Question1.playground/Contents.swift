import Foundation

protocol CompanyProtocol {
    func increaseOf(budget amount: Double)
    func decreaseOf(budget amount: Double)
    func add(employee: Employee)
    func paySalariesOfEmployees(completion: ((PaymentState) -> Void)?)
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
    
    /**
     This function calculates sum of all Employees' salary in the Company
     Then checks if budget can afford to totalSalaryPayments
     If budget can afford totalSalaryPayments, decrease totalSalaryPayments from the Budget of the Company
     */
    func paySalariesOfEmployees(completion: ((PaymentState) -> Void)? = nil) {
        var totalSalaryPayments: Double = 0
        for index in 0..<self.companyEmployeeCount {
            totalSalaryPayments += companyEmployees[index]!.calculateSalary()
        }
        
        if completion != nil {
            if self.companyBudget < totalSalaryPayments {
                completion!(PaymentState.inefficientBudget)
            } else {
                self.decreaseOf(budget: totalSalaryPayments)
                
                completion!(PaymentState.paymentSuccessful)
            }
        } else {
            if self.companyBudget < totalSalaryPayments {
                self.decreaseOf(budget: totalSalaryPayments)
            }
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

enum PaymentState {
    case paymentSuccessful
    case inefficientBudget
}

var vakifBank: Company

vakifBank = Company(companyName: "VakifBank", companyBudget: 500_000, companyFoundationYear: 1954)
vakifBank.increaseOf(budget: 500_000)

vakifBank.add(employee: Employee(employeeName: "Alihan KUZUCUK", employeeAge: 25, employeeMaritalStatus: EmployeeMaritalStatus.single, employeeType: EmployeeType.juniour))

vakifBank.add(employee: Employee(employeeName: "Kaan YILDIRIM", employeeAge: 30, employeeMaritalStatus: EmployeeMaritalStatus.single, employeeType: EmployeeType.senior))

vakifBank.paySalariesOfEmployees{ paymentState in
    switch (paymentState) {
        case .paymentSuccessful:
            print("\(vakifBank.companyEmployeeCount) salary paid on Company Budget. New budget is now \(vakifBank.companyBudget)")
        case .inefficientBudget:
            print("Salary of \(vakifBank.companyEmployeeCount) employee couldn't paid. Budget is inefficient")
    }
}
