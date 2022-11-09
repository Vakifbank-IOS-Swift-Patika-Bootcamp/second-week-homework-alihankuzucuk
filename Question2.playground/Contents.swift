import Foundation

protocol ZooProtocol {
    func increaseOf(budget amount: Double)
    func decreaseOf(budget amount: Double)
    func increaseOf(dailyWaterLimit amount: Int)
    func decreaseOf(dailyWaterLimit amount: Int)
    
    func add(zooKeeper: ZooKeeper)
    func add(animal: Animal, completion: (() -> Void)?)
    
    func waterAnimals()
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
    
    func add(zooKeeper: ZooKeeper) {
        if findByName(ofZooKeeper: zooKeeper.zooKeeperName) == nil {
            zooKeepers[(zooKeepers.count>0 ? zooKeepers.count : 0)] = zooKeeper
        }
    }
    
    func add(animal: Animal, completion: (() -> Void)? = nil) {
        if findByName(ofAnimal: animal.animalName) == nil {
            zooAnimals[(zooAnimals.count>0 ? zooAnimals.count : 0)] = animal
        }
        
        if completion != nil {
            completion!()
        }
    }
    
    func waterAnimals() {
        var totalWater = 0
        for index in 0..<self.zooAnimals.count {
            totalWater += zooAnimals[index]!.dailyWaterConsumption
        }
        
        decreaseOf(dailyWaterLimit: totalWater)
    }
    
    func findByName(ofZooKeeper name: String) -> ZooKeeper? {
        for index in 0..<self.zooKeepers.count {
            if zooKeepers[index]?.zooKeeperName == name {
                return zooKeepers[index]!
            }
        }
        
        return nil
    }
    
    func findByName(ofAnimal name: String) -> Animal? {
        for index in 0..<self.zooAnimals.count {
            if zooAnimals[index]?.animalName == name {
                return zooAnimals[index]!
            }
        }
        
        return nil
    }
    
    func isAnimalHasAnyZooKeeper(animalName name: String) -> Bool {
        for index in 0..<self.zooKeepers.count {
            if zooKeepers[index]!.isResponsibleOf(animal: name) {
                return true
            }
        }
        
        return false
    }
    
    func assignResponsibility(zooKeeperName: String, animalName: String)
    {
        if let zooKeeper = self.findByName(ofZooKeeper: zooKeeperName) {
            if let animal = self.findByName(ofAnimal: animalName) {
                if isAnimalHasAnyZooKeeper(animalName: animal.animalName) != true {
                    zooKeeper.liableAnimalNames[(zooKeeper.liableAnimalNames.count > 0 ? zooKeeper.liableAnimalNames.count : 0)] = animal.animalName
                }
            }
        }
    }
    
    func paySalariesOfZooKeepers() {
        var totalSalaryPayments: Double = 0
        for index in 0..<self.zooKeepers.count {
            totalSalaryPayments += zooKeepers[index]!.salary
        }
        
        self.decreaseOf(budget: totalSalaryPayments)
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

var zoo = Zoo(dailyWaterLimit: 1_000, zooBudget: 1_000_000)

zoo.add(zooKeeper: ZooKeeper("Alihan KUZUCUK"))
zoo.findByName(ofZooKeeper: "Alihan KUZUCUK")?.salary
zoo.add(animal: Animal(animalName: "King Leo", breedOfAnimal: "Leo", dailyWaterConsumption: 10, animalNoise: "Krrrrr")) {
    zoo.assignResponsibility(zooKeeperName: "Alihan KUZUCUK", animalName: "King Leo")
}

zoo.findByName(ofZooKeeper: "Alihan KUZUCUK")?.liableAnimalNames
zoo.findByName(ofZooKeeper: "Alihan KUZUCUK")?.salary
zoo.add(animal: Animal(animalName: "Leo", breedOfAnimal: "Leo", dailyWaterConsumption: 5, animalNoise: "Hrrrrr"))
