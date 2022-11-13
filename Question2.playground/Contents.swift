import Foundation

protocol ZooProtocol {
    func increaseOf(budget amount: Double)
    func decreaseOf(budget amount: Double)
    func increaseOf(dailyWaterLimit amount: Int)
    func decreaseOf(dailyWaterLimit amount: Int)
    
    func getDailyWaterLimit() -> Int
    func getZooBudget() -> Double
    func getZooKeepersCount() -> Int
    func getAnimalsCount() -> Int
    
    func add(zooKeeper: ZooKeeper)
    func add(animal: Animal, assignedZooKeeper: String, completion: ((_ nameOfAnimal:String, _ nameOfZooKeeper: String) -> Void)?)
    
    func waterAnimals(completion: ((WateringState) -> Void)?)
    
    func findByName(ofZooKeeper name: String) -> ZooKeeper?
    func findByName(ofAnimal name: String) -> Animal?
    func isAnimalHasAnyZooKeeper(animalName name: String) -> Bool
    func assignResponsibility(zooKeeperName: String, animalName: String) -> Bool
    func paySalariesOfZooKeepers(completion: ((PaymentState) -> Void)?)
}

protocol ZooKeeperProtocol {
    func isResponsibleOf(animal name: String) -> Bool
}

protocol AnimalProtocol {
    func noise() -> String
}

class Zoo: ZooProtocol {
    private var dailyWaterLimit: Int
    private var zooBudget: Double
    
    private var zooKeepers = [Int: ZooKeeper]()
    private var zooAnimals = [Int: Animal]()
    
    init(dailyWaterLimit: Int, zooBudget: Double) {
        self.dailyWaterLimit = dailyWaterLimit
        self.zooBudget = zooBudget
    }
    
    func increaseOf(budget amount: Double) {
        self.zooBudget += amount
    }
    
    func decreaseOf(budget amount: Double) {
        self.zooBudget -= amount
    }
    
    func increaseOf(dailyWaterLimit amount: Int) {
        self.dailyWaterLimit += amount
    }
    
    func decreaseOf(dailyWaterLimit amount: Int) {
        self.dailyWaterLimit -= amount
    }
    
    func getDailyWaterLimit() -> Int { self.dailyWaterLimit }
    func getZooBudget() -> Double { self.zooBudget }
    func getZooKeepersCount() -> Int { self.zooKeepers.count }
    func getAnimalsCount() -> Int { self.zooAnimals.count }
    
    /**
     This function adds a ZooKeeper to the Zoo, if there isn't any ZooKeeper
     with the same name in the Zoo
     */
    func add(zooKeeper: ZooKeeper) {
        if findByName(ofZooKeeper: zooKeeper.zooKeeperName) == nil {
            zooKeepers[(zooKeepers.count>0 ? zooKeepers.count : 0)] = zooKeeper
        }
    }
    
    /**
     This function adds an Animal to the Zoo, if there isn't any Animal
     with the same name in the Zoo and assigns to the ZooKeeper because of
     new animal has no any ZooKeeper
     */
    func add(animal: Animal, assignedZooKeeper: String, completion: ((_ nameOfAnimal:String, _ nameOfZooKeeper: String) -> Void)? = nil) {
        if findByName(ofAnimal: animal.animalName) == nil {
            if findByName(ofZooKeeper: assignedZooKeeper) != nil {
                zooAnimals[(zooAnimals.count>0 ? zooAnimals.count : 0)] = animal
                
                if completion != nil {
                    if assignResponsibility(zooKeeperName: assignedZooKeeper, animalName: animal.animalName) {
                        completion!(animal.animalName, assignedZooKeeper)
                    }
                } else {
                    assignResponsibility(zooKeeperName: assignedZooKeeper, animalName: animal.animalName)
                }
            }
        }
    }
    
    /**
     This function calculates the total water consumption of animals in the zoo
     Then checks if dailyWaterLimit can afford to totalWaterConsumption
     If dailyWaterLimit can afford totalWaterConsumption, decrease totalWaterConsumption from the Zoo's dailyWaterConsumption
     */
    func waterAnimals(completion: ((WateringState) -> Void)? = nil) {
        var totalWaterConsumption = 0
        for index in 0..<self.zooAnimals.count {
            totalWaterConsumption += zooAnimals[index]!.dailyWaterConsumption
        }
        
        if completion != nil {
            if self.dailyWaterLimit < totalWaterConsumption {
                completion!(WateringState.inefficientWatering)
            } else {
                self.decreaseOf(dailyWaterLimit: totalWaterConsumption)
                
                completion!(WateringState.wateringSuccessful)
            }
        } else {
            if self.dailyWaterLimit < totalWaterConsumption {
                self.decreaseOf(dailyWaterLimit: totalWaterConsumption)
            }
        }
    }
    
    /**
     This function finds and returns ZooKeeper which has name of given as a parameter
     If it couldn't find returns nil
     */
    func findByName(ofZooKeeper name: String) -> ZooKeeper? {
        for index in 0..<self.zooKeepers.count {
            if zooKeepers[index]?.zooKeeperName == name {
                return zooKeepers[index]!
            }
        }
        
        return nil
    }
    
    /**
     This function finds and returns Animal which has name of given as a parameter
     If it couldn't find returns nil
     */
    func findByName(ofAnimal name: String) -> Animal? {
        for index in 0..<self.zooAnimals.count {
            if zooAnimals[index]?.animalName == name {
                return zooAnimals[index]!
            }
        }
        
        return nil
    }
    
    /**
     This function is looking for Animal which has name of given as a parameter, has any ZooKeper
     */
    func isAnimalHasAnyZooKeeper(animalName name: String) -> Bool {
        for index in 0..<self.zooKeepers.count {
            if zooKeepers[index]!.isResponsibleOf(animal: name) {
                return true
            }
        }
        
        return false
    }
    
    /**
     This function first checks if there is any ZooKeeper & Animal which passed
     Then checks for if given Animal has any ZooKeeper
     Then assigns ZooKeeper to the Animal
     */
    func assignResponsibility(zooKeeperName: String, animalName: String) -> Bool
    {
        // Checks for ZooKeeper exists
        if let zooKeeper = self.findByName(ofZooKeeper: zooKeeperName) {
            // Checks for Animal exists
            if let animal = self.findByName(ofAnimal: animalName) {
                // Checks for Animal if has any ZooKeeper
                if isAnimalHasAnyZooKeeper(animalName: animal.animalName) != true {
                    // Assings ZooKeeper to the Animal
                    zooKeeper.liableAnimalNames[(zooKeeper.liableAnimalNames.count > 0 ? zooKeeper.liableAnimalNames.count : 0)] = animal.animalName
                    return true
                }
            }
        }
        return false
    }
    
    /**
     This function calculates sum of all ZooKeepers' salary in the Zoo
     Then checks if budget can afford to totalSalaryPayments
     If budget can afford totalSalaryPayments, decrease totalSalaryPayments from the Budget of the Zoo
     */
    func paySalariesOfZooKeepers(completion: ((PaymentState) -> Void)? = nil) {
        var totalSalaryPayments: Double = 0
        for index in 0..<self.zooKeepers.count {
            totalSalaryPayments += zooKeepers[index]!.salary
        }
        
        if completion != nil {
            if self.zooBudget < totalSalaryPayments {
                completion!(PaymentState.inefficientBudget)
            } else {
                self.decreaseOf(budget: totalSalaryPayments)
                
                completion!(PaymentState.paymentSuccessful)
            }
        } else {
            if self.zooBudget < totalSalaryPayments {
                self.decreaseOf(budget: totalSalaryPayments)
            }
        }
    }
}

class ZooKeeper: ZooKeeperProtocol {
    let zooKeeperName: String
    var salary: Double {
        get {
            Double(((self.liableAnimalNames.count != 0 ? Double(self.liableAnimalNames.count) : 0.75) * 1000))
        }
    }
    var liableAnimalNames = [Int: String]()
    
    init(_ zooKeeperName: String) {
        self.zooKeeperName = zooKeeperName
    }
    
    /**
     This function checks ZooKeeper's responsible animals
     and returns if ZooKeeper is responsible of given Animal as a parameter
     */
    func isResponsibleOf(animal name: String) -> Bool {
        for index in 0..<liableAnimalNames.count {
            if liableAnimalNames[index] == name {
                return true
            }
        }
        
        return false
    }
}

struct Animal: AnimalProtocol {
    let animalName: String
    let breedOfAnimal: String
    let dailyWaterConsumption: Int
    let animalNoise: String
    
    func noise() -> String {
        return animalNoise
    }
}

enum PaymentState {
    case paymentSuccessful
    case inefficientBudget
}

enum WateringState {
    case wateringSuccessful
    case inefficientWatering
}

// Zoo was established with 1000 liter of daily water limit and 1,000,000 budget
var zoo = Zoo(dailyWaterLimit: 1_000, zooBudget: 1_000_000)

// Alihan KUZUCUK is a new Zoo Keeper in the Zoo, not assigned any Animal yet
zoo.add(zooKeeper: ZooKeeper("Alihan KUZUCUK"))

// Because of Alihan KUZUCUK has no responsible animal his salary is low, he wants to look animals
zoo.findByName(ofZooKeeper: "Alihan KUZUCUK")?.salary

// Assigned to the new Zoo Keeper Alihan KUZUCUK an animal with closure
zoo.add(animal: Animal(animalName: "King Leo", breedOfAnimal: "Leo", dailyWaterConsumption: 10, animalNoise: "Krrrrr"), assignedZooKeeper: "Alihan KUZUCUK") { nameOfAnimal, nameOfZooKeeper in
    print("\(nameOfAnimal) added to the Zoo by assigning to the \(nameOfZooKeeper)")
}

// Alihan KUZUCUK's responsible animals is listed here
zoo.findByName(ofZooKeeper: "Alihan KUZUCUK")?.liableAnimalNames

// Alihan KUZUCUK's salary is increased
zoo.findByName(ofZooKeeper: "Alihan KUZUCUK")?.salary

// We can also assign an animal with no closure because it is an optinal parameter
zoo.add(animal: Animal(animalName: "Leo", breedOfAnimal: "Leo", dailyWaterConsumption: 5, animalNoise: "Hrrrrr"), assignedZooKeeper: "Alihan KUZUCUK")

// Alihan KUZUCUK's responsible animals is listed here
zoo.findByName(ofZooKeeper: "Alihan KUZUCUK")?.liableAnimalNames

// Alihan KUZUCUK's salary is increased
zoo.findByName(ofZooKeeper: "Alihan KUZUCUK")?.salary

// Animals are thirsty, If Alihan doesn't give water to them, he will die
zoo.findByName(ofAnimal: "King Leo")?.noise()
zoo.findByName(ofAnimal: "Leo")?.noise()

// Animals watered from the Zoo's daily water limit
zoo.waterAnimals{ wateringState in
    switch (wateringState) {
        case .wateringSuccessful:
            print("\(zoo.getAnimalsCount()) animal watered on daily water limit. New water limit is now \(zoo.getDailyWaterLimit())")
        case .inefficientWatering:
            print("\(zoo.getAnimalsCount()) animal in the zoo couldn't watered. Daily water limit is inefficient")
    }
}

// ZooKeeper's get their salaries from the Zoo's budget
zoo.paySalariesOfZooKeepers { paymentState in
    switch (paymentState) {
        case .paymentSuccessful:
            print("\(zoo.getZooKeepersCount()) salary paid on Zoo Budget. New budget is now \(zoo.getZooBudget())")
        case .inefficientBudget:
            print("Salary of \(zoo.getZooKeepersCount()) zookeeper couldn't paid. Budget is inefficient")
    }
}
