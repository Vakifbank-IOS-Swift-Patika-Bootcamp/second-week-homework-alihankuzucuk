import Foundation

protocol ZooProtocol {
    func increaseOf(budget amount: Double)
    func decreaseOf(budget amount: Double)
    func increaseOf(dailyWaterLimit amount: Int)
    func decreaseOf(dailyWaterLimit amount: Int)
    
    func add(zooKeeper: ZooKeeper)
    func add(animal: Animal, completion: (() -> Void)?)
    
    func waterAnimals(completion: ((WateringState) -> Void)?)
    
    func paySalariesOfZooKeepers(completion: ((PaymentState) -> Void)?)
}

protocol ZooKeeperProtocol {
    func isResponsibleOf(animal name: String) -> Bool
}

protocol AnimalProtocol {
    func noise() -> String
}

class Zoo: ZooProtocol {
    var dailyWaterLimit: Int
    var zooBudget: Double
    
    var zooKeepers = [Int: ZooKeeper]()
    var zooAnimals = [Int: Animal]()
    
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
     This function adds a Animal to the Zoo, if there isn't any Animal
     with the same name in the Zoo with the CompletionBlock which is allows
     to assign a ZooKeeper after added the Animal
     */
    func add(animal: Animal, completion: (() -> Void)? = nil) {
        if findByName(ofAnimal: animal.animalName) == nil {
            zooAnimals[(zooAnimals.count>0 ? zooAnimals.count : 0)] = animal
        }
        
        if completion != nil {
            completion!()
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
    func assignResponsibility(zooKeeperName: String, animalName: String)
    {
        // Checks for ZooKeeper exists
        if let zooKeeper = self.findByName(ofZooKeeper: zooKeeperName) {
            // Checks for Animal exists
            if let animal = self.findByName(ofAnimal: animalName) {
                // Checks for Animal if has any ZooKeeper
                if isAnimalHasAnyZooKeeper(animalName: animal.animalName) != true {
                    // Assings ZooKeeper to the Animal
                    zooKeeper.liableAnimalNames[(zooKeeper.liableAnimalNames.count > 0 ? zooKeeper.liableAnimalNames.count : 0)] = animal.animalName
                }
            }
        }
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

var zoo = Zoo(dailyWaterLimit: 1_000, zooBudget: 1_000_000)

zoo.add(zooKeeper: ZooKeeper("Alihan KUZUCUK"))
zoo.findByName(ofZooKeeper: "Alihan KUZUCUK")?.salary
zoo.add(animal: Animal(animalName: "King Leo", breedOfAnimal: "Leo", dailyWaterConsumption: 10, animalNoise: "Krrrrr")) {
    zoo.assignResponsibility(zooKeeperName: "Alihan KUZUCUK", animalName: "King Leo")
}

zoo.findByName(ofZooKeeper: "Alihan KUZUCUK")?.liableAnimalNames
zoo.findByName(ofZooKeeper: "Alihan KUZUCUK")?.salary
zoo.add(animal: Animal(animalName: "Leo", breedOfAnimal: "Leo", dailyWaterConsumption: 5, animalNoise: "Hrrrrr"))

zoo.waterAnimals{ wateringState in
    switch (wateringState) {
        case .wateringSuccessful:
        print("\(zoo.zooAnimals.count) animal watered on daily water limit. New water limit is now \(zoo.dailyWaterLimit)")
        case .inefficientWatering:
            print("\(zoo.zooAnimals.count) animal in the zoo couldn't watered. Daily water limit is inefficient")
    }
}

zoo.paySalariesOfZooKeepers { paymentState in
    switch (paymentState) {
        case .paymentSuccessful:
            print("\(zoo.zooKeepers.count) salary paid on Zoo Budget. New budget is now \(zoo.zooBudget)")
        case .inefficientBudget:
            print("Salary of \(zoo.zooKeepers.count) zookeeper couldn't paid. Budget is inefficient")
    }
}
