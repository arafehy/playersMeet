//
//  LocationsViewController.swift
//  playersMeetup
//
//  Created by Nada Zeini on 4/26/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import UIKit
import Moya
import AlamofireImage
import Firebase
var locations = [[String:Any]]()
class LocationsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count   }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell") as! LocationTableViewCell
        let loc = locations[indexPath.row]
        cell.locationLabel.text = loc["name"] as? String
        let strURL = loc["image_url"] as! String
        if let url = URL(string: strURL){
            cell.locationImageView.af_setImage(withURL: url)
        }
        cell.distanceLabel.text = String(format: "%f", loc["distance"] as! Double)
        return cell
    }
//    func configure(with viewModel: CourtListViewModel){
//        locationNameLabel.text = viewModel.name
//    }
    @IBOutlet weak var tableView: UITableView!
     let service = MoyaProvider<YelpService.BusinessesProvider>()
    let jsonDecoder = JSONDecoder()
    let ref = Database.database().reference().ref.child("businesses")
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase ///letting it know camel case
                service.request(.search(lat: 37.251543524369715 , long: -121.94168787103503)) { (result) in switch result {
                case .success(let response):
                    let dataDictionary = try! JSONSerialization.jsonObject(with: response.data, options: []) as! [String: Any]
                    locations = dataDictionary["businesses"] as! [[String:Any]]
                    self.ref.setValue(locations)
                    self.tableView.reloadData()
//                    print(locations[1]["distance"] as! Double)
                case .failure(let error):
                    print("Error: \(error)")
                    }
                }
        
    }
}
