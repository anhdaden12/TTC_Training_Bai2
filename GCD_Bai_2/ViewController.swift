//
//  ViewController.swift
//  GCD_Bai_2
//
//  Created by Apple on 1/18/21.
//  Copyright © 2021 NgocNB. All rights reserved.
//

import UIKit
import Toast_Swift

class ViewController: UIViewController {
    //MARK: IBOULET
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    
    //MARK: VAR
    var listAlbums = [AlbumModel]()
    var currentTask: URLSessionDataTask?
    var isCanceled = false
    
    //MARK: LET
    let refresh = UIRefreshControl()
    
    
    //MARK: LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.register(UINib(nibName: "AlbumTableViewcell", bundle: nil), forCellReuseIdentifier: "AlbumTableViewcell")
        tableview.delegate = self
        tableview.dataSource = self
        getListAlbums()
        refresh.addTarget(self, action: #selector(refeshData), for: .valueChanged)
        self.tableview.addSubview(refresh)
    }
    
    //MARK: FUNCTION
    @objc func refeshData() {
        listAlbums.removeAll()
        tableview.reloadData()
        getListAlbums()
        refresh.endRefreshing()
    }

    func getListAlbums() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/photos") else { return}
        
        URLSession.shared.dataTask(with: url) { (data, reponse, error) in
            if let data = data {
                do {
                    let albums  = try JSONDecoder().decode([AlbumModel].self, from: data)
                    self.listAlbums = albums
                    DispatchQueue.main.async {
                        self.tableview.reloadData()
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    func downLoadImage(from link: String, completion: @escaping (Data) -> Void) {
        guard let url = URL(string: link) else { return }
        if isCanceled {
            return
        }
        var task:URLSessionDataTask!
        task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil
                else { return }
            completion(data)
        }
        self.currentTask = task
        task.resume()
    }
    
    func showMessage(msg: String) {
        DispatchQueue.main.async {
            self.view.makeToast(msg)
        }
    }
    
    // MARK: ACTION
    @IBAction func dispatchGroupAction(_ sender: Any) {
        self.cancelButton.isHidden = false
        let group = DispatchGroup()
        let firstTenItems = Array(listAlbums.prefix(10))
        for (index,album) in firstTenItems.enumerated() {
            group.enter()
            downLoadImage(from: album.url) { [weak self] (response) in
                guard let self = self else {return}
                sleep(3)
                self.listAlbums[index].imageData = response
                DispatchQueue.global().async {
                    DispatchQueue.main.async {
                        self.tableview.reloadRows(at: [IndexPath(item: index, section: 0)], with: .right)
                    }
                }
                print("Donwn load album \(index) success")
                group.leave()
            }
        }
        group.notify(queue: .main) {
            print("success fully")
            self.showMessage(msg: "DispatchGroup: all Image Downloaded")
            self.cancelButton.isHidden = true
            self.tableview.reloadData()
        }
    }
    
    @IBAction func semaphoreAction(_ sender: Any) {
        self.cancelButton.isHidden = false
        let semaphore = DispatchSemaphore(value: 2)
        let queue = DispatchQueue(label: "SemaphoreQueue")
            let firstTenItems = Array(self.listAlbums.prefix(10))
        for (index,album) in firstTenItems.enumerated() {
            queue.async {
                semaphore.wait()
                self.downLoadImage(from: album.url) { [weak self] (response) in
                    guard let self = self else {return}
                    self.listAlbums[index].imageData = response
                    sleep(3)
                    DispatchQueue.global().async {
                        DispatchQueue.main.async {
                            self.tableview.reloadRows(at: [IndexPath(item: index, section: 0)], with: .right)
                        }
                    }
                    print("Donwn load task \(index) success")
                    if index == 9 {
                        self.showMessage(msg: "DispatchSemaphore: all Image Downloaded")
                        DispatchQueue.main.async {
                            self.cancelButton.isHidden = true
                            self.tableview.reloadData()
                        }
                    }
                    semaphore.signal()
                }
            }
        }
    }

    @IBAction func normalDownloadAction(_ sender: Any) {
        let firstTenItems = Array(listAlbums.prefix(10))
        for (index,album) in firstTenItems.enumerated() {
            downLoadImage(from: album.url) { [weak self] (response) in
                guard let self = self else {return}
                self.listAlbums[index].imageData = response
                if index == 9 {
                    DispatchQueue.main.async {
                        self.tableview.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        currentTask?.cancel()
        self.isCanceled = true
    }
}


//MARK: UITableViewDataSource , UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listAlbums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumTableViewcell", for: indexPath) as! AlbumTableViewcell
        let obj = listAlbums[indexPath.row]
        cell.bindCell(obj: obj)
        return cell
    }
}
