import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var restorantsTabelView: UITableView!
    var restorants: Restorants = Restorants(data: [])
    var idSender = 0
    var restorantBackImageSender = ""
    var logoSener = ""
    var nameSender = ""
    var raitingSender:Float = 0
    var contantSender = ""
    var minimumCostSender:Double = 0
    var deliveryCostSender:Double = 0
    var deliveryMinTimeSender = 0
    var deliveryMaxTimeSender = 0
    var promotedLabelSender = ""
    let restorantsURL = "https://hungerstation-api.herokuapp.com/api/v1/restaurants"
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadRestorantData(restorantsURL)
        restorantsTabelView.delegate = self
        restorantsTabelView.dataSource = self
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let toMenu = segue.destination as? MenuController
        toMenu?.idResiver = idSender
        toMenu?.backImageResiver = restorantBackImageSender
        toMenu?.logoResiver = logoSener
        toMenu?.nameResiver = nameSender
        toMenu?.raitingResiver = raitingSender
        toMenu?.minimumCostResiver = minimumCostSender
        toMenu?.deliveryCostResiver = deliveryCostSender
        toMenu?.deliveryMinTimeResiver = deliveryMinTimeSender
        toMenu?.deliveryMaxTimeResiver = deliveryMaxTimeSender
        toMenu?.promotedLabelResiver = promotedLabelSender
    }
    @IBAction func getBack(segue:UIStoryboardSegue) {
    }
    func downloadRestorantData(_ FromURL: String) {
        if let urlData = URL(string: FromURL) {
            let urlSession = URLSession(configuration: .default)
            let urlTask = urlSession.dataTask(with: urlData) { data, response, error in
                if let error = error {
                    print("The URL Is Not Working", error.localizedDescription)
                }else {
                    if let restorantData = data {
                        do {
                            let decorder = JSONDecoder()
                            self.restorants = try decorder.decode(Restorants.self, from: restorantData)
                            DispatchQueue.main.async {
                                self.restorantsTabelView.reloadData()
                            }
                        }catch {
                            print("Somthing Wrongs In the JSON Struct", error.localizedDescription)
                        }
                    }
                }
            }
            urlTask.resume()
        }
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restorants.data.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = restorantsTabelView.dequeueReusableCell(withIdentifier: "cell") as! FoodsCell
        cell.restorantName.text = restorants.data[indexPath.row].name
        if restorants.data[indexPath.row].offer != nil {
            if let offer = restorants.data[indexPath.row].offer {
                if offer.value.contains("%") {
                    cell.priceCondition.text = "  \(offer.value) Your Order (spend \(offer.spend) SAR)     "
                }else {
                    cell.priceCondition.text = "  \(offer.value) (spend \(offer.spend) SAR)     "
                }
            }
        }else{
            cell.priceCondition.isHidden = true
        }
        if restorants.data[indexPath.row].is_promoted == true {
            cell.promoted.text = "Promoted"
        }else{
            cell.promoted.isHidden = true
        }
        cell.foodType.text = restorants.data[indexPath.row].category
        cell.raiting.text = "\(restorants.data[indexPath.row].rating)"
        cell.deliveryAndOtherThings.text = " \(restorants.data[indexPath.row].delivery.time.min) - \(restorants.data[indexPath.row].delivery.time.max) minutes | Delivery: \(restorants.data[indexPath.row].delivery.cost.value)\(restorants.data[indexPath.row].delivery.cost.currency) |"
        if let restorantlogo = URL(string: restorants.data[indexPath.row].resturant_image) {
            DispatchQueue.global().async {
                if let restorantlogo = try? Data(contentsOf: restorantlogo) {
                    let logo = restorantlogo
                    DispatchQueue.main.async {
                        cell.logo.image = UIImage(data: logo)
                    }
                }
            }
        }
        if let restorantBackImage = URL(string: restorants.data[indexPath.row].image) {
            DispatchQueue.global().async {
                if let restorantBackImage = try? Data(contentsOf: restorantBackImage) {
                    let backImage = restorantBackImage
                    DispatchQueue.main.async {
                        cell.restorandFoodImage.image = UIImage(data: backImage)
                    }
                }
            }
        }
        cell.logo.layer.masksToBounds = true
        cell.logo.layer.cornerRadius = 10
        cell.promoted.layer.masksToBounds = true
        cell.promoted.layer.cornerRadius = 6
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        idSender = restorants.data[indexPath.row].id
        restorantBackImageSender = restorants.data[indexPath.row].image
        logoSener = restorants.data[indexPath.row].resturant_image
        nameSender = restorants.data[indexPath.row].name
        raitingSender = restorants.data[indexPath.row].rating
        contantSender = restorants.data[indexPath.row].category
        minimumCostSender = restorants.data[indexPath.row].delivery.cost.value
        deliveryCostSender = restorants.data[indexPath.row].delivery.cost.value
        deliveryMinTimeSender = restorants.data[indexPath.row].delivery.time.min
        deliveryMaxTimeSender = restorants.data[indexPath.row].delivery.time.max
        if restorants.data[indexPath.row].offer != nil {
            if let offer = restorants.data[indexPath.row].offer {
                if offer.value.contains("%") {
                    promotedLabelSender = " \(offer.value) Your Order (spend \(offer.spend) SAR) "
                }else {
                    promotedLabelSender = " \(offer.value) (spend \(offer.spend) SAR) "
                }
            }
        }else {
            promotedLabelSender = ""
        }
        performSegue(withIdentifier: "toMenu", sender: self)
    }
}

