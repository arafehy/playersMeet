//
//  FeedViewController.swift
//  playersMeetup
//
//  Created by Nada Zeini on 4/25/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        let url = URL(string: "https://api.yelp.com/v3/businesses/search?term=delis&latitude=37.786882&longitude=-122.399972")
//        guard let requestUrl = url else {
//            fatalError()
//        }
//        let parameters: [String: Any] = [
//            "request": [
//                    "xusercode" : "YOUR USERCODE HERE",
//                    "xpassword": "YOUR PASSWORD HERE"
//            ]
//        ]
//        var request = URLRequest(url: requestUrl)
//        request.httpMethod = "GET"
//        //send request
//        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//
//            // Check if Error took place
//            if let error = error {
//                print("Error took place \(error)")
//                return
//            }
//
//            // Read HTTP Response Status code
//            if let response = response as? HTTPURLResponse {
//                print("Response HTTP Status code: \(response.statusCode)")
//            }
//
//            // Convert HTTP Response Data to a simple String
//            if let data = data, let dataString = String(data: data, encoding: .utf8) {
//                print("Response data string:\n \(dataString)")
//            }
//
//        }
//        task.resume()
//
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 10
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell") as! LocationCell
        return cell
     }
}
