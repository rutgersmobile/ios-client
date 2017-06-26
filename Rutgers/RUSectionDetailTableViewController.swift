//
//  RUSectionDetailTableViewController.swift
//  Rutgers
//
//  Created by Colin Walsh on 6/26/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class RUSOCSectionDetailTableViewController: UITableViewController {
    
    var section: Section!
    
    static func instantiate(
        withStoryboard storyboard: UIStoryboard,
        section: Section
        ) -> RUSOCSectionDetailTableViewController {
        let me = storyboard.instantiateViewController(
            withIdentifier: "RUSOCSectionDetailViewController"
            ) as! RUSOCSectionDetailTableViewController
        
        me.section = section
        
        return me
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.section)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }

}
