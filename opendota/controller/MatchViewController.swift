//
//  ViewController.swift
//  opendota
//
//  Created by Linh Hoang on 1/1/17.
//  Copyright © 2017 Linh Hoang. All rights reserved.
//

import UIKit

class MatchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var table: UITableView!
    var c = 0
    let heroes = Heroes.info
    var player: Player?
    var id: Int64 = 191771962
    var matches: [MatchInfo] = []
    var receiveWinLose = false
    var receiveMMR = false
    var currentPage = 1
    var lastPage: Int {
        return Int(ceil(Double(matches.count) / 10))
    }

    var swipeGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    let swipeInteractionController = SlideInController()
    let slideinAnimator = SlideInAnimator()

    @IBOutlet weak var pagebutton: UIStackView!
    @IBOutlet weak var thirdButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view, typically from a nib.
        debugPrint(heroes.list.count)
        self.player = Player(id: self.id)
        player!.getAllMatches {
            matches in
            self.matches = matches
            self.table.reloadData()
            var count = 3 - self.lastPage
            if count <= 0 {
                return
            }
            for b in self.pagebutton.arrangedSubviews.reversed() {
                b.isHidden = true
                count -= 1
                if count == 0 {
                    break
                }
            }

        }
        player!.getWinLose {
            self.receiveWinLose = true
            self.table.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }

        player!.getMMR{
            self.receiveMMR = true
            self.table.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
        swipeInteractionController.wireToViewController(viewController: self)


    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    //Mark: -- UITableViewDelegate and DataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if matches.count - (currentPage - 1) * 10 < 10 {
            return matches.count - (currentPage - 1) * 10 + 1
        }

        return 11
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = table
                .dequeueReusableCell(withIdentifier: "profile", for: indexPath) as! ProfileCell

            if receiveWinLose {
                cell.configCellForWinLose(with: player!)
            }

            if receiveMMR {
                cell.configCellForMMR(with: player!)
            }
            return cell

        }
        let cell = table
            .dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MatchInfoCell

        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(red: 86/255, green: 48/255, blue: 68/255, alpha: 1)
        }
        cell.configCell(with: matches[indexPath.row - 1 + (currentPage - 1) * 10])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 173
        }
        return 67
    }

    @IBAction func changePage(_ sender: UIButton) {
        if sender.tag == 3 {
            currentPage = 1
        } else if sender.tag == 4 {
            currentPage = lastPage
        } else{
            guard currentPage != Int(sender.currentTitle!)! else {
                return
            }
            
            currentPage = Int(sender.currentTitle!)!
        }

        let attr = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 19)]
        let normalAttr = [NSFontAttributeName: UIFont.systemFont(ofSize: 15)]
        let buttons = pagebutton.arrangedSubviews as! [UIButton]

        if sender.tag == 1 && currentPage != lastPage{

            for b in buttons {
                let title = String(Int(b.currentTitle!)! + 1)
                if Int(b.currentTitle!)! + 1 == currentPage{

                    let attText = NSAttributedString(string: title, attributes: attr)
                    b.setTitle(title, for: .normal)
                    b.setAttributedTitle(attText, for: .normal)
                } else {
                    let attText = NSAttributedString(string: title, attributes: normalAttr)
                    b.setTitle(title, for: .normal)
                    b.setAttributedTitle(attText, for: .normal)
                }
            }
        } else if sender.tag == 2 && currentPage != 1{
            for b in buttons {
                let title = String(Int(b.currentTitle!)! - 1)
                if Int(b.currentTitle!)! - 1 == currentPage{

                    let attText = NSAttributedString(string: title, attributes: attr)
                    b.setTitle(title, for: .normal)
                    b.setAttributedTitle(attText, for: .normal)
                } else {
                    let attText = NSAttributedString(string: title, attributes: normalAttr)
                    b.setTitle(title, for: .normal)
                    b.setAttributedTitle(attText, for: .normal)
                }
            }

        } else if currentPage == 2 || currentPage == 1{
            var count = 1
            for b in buttons {
                let title = String(count)
                if count == currentPage{

                    let attText = NSAttributedString(string: title, attributes: attr)
                    b.setTitle(title, for: .normal)
                    b.setAttributedTitle(attText, for: .normal)
                } else {
                    let attText = NSAttributedString(string: title, attributes: normalAttr)
                    b.setTitle(title, for: .normal)
                    b.setAttributedTitle(attText, for: .normal)
                }
                count += 1
            }
        } else if currentPage == lastPage || currentPage == lastPage - 1 {
            var count = lastPage - 2
            for b in buttons {
                let title = String(count)
                if count == currentPage{

                    let attText = NSAttributedString(string: title, attributes: attr)
                    b.setTitle(title, for: .normal)
                    b.setAttributedTitle(attText, for: .normal)
                } else {
                    let attText = NSAttributedString(string: title, attributes: normalAttr)
                    b.setTitle(title, for: .normal)
                    b.setAttributedTitle(attText, for: .normal)
                }
                count += 1
            }

        }
        self.table.reloadData()
    }

    func showSecondViewController() {
        self.performSegue(withIdentifier: "option", sender: self)
    }

    @IBAction func returnToMatches(unwindSegue: UIStoryboardSegue){
        if unwindSegue.identifier == "option" {
            unwindSegue.source.transitioningDelegate = unwindSegue.source as? UIViewControllerTransitioningDelegate
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "option" {
            segue.destination.transitioningDelegate = self
        }

        if segue.identifier == "detail" {
            let des = segue.destination as! MatchInfoViewController
            let s = sender as! MatchInfoCell
            des.match = Match(id: s.info!.id!)
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "detail" {
            return true
        }
        return true
    }


}

extension MatchViewController: UIViewControllerTransitioningDelegate {
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.swipeInteractionController.interactionInProgress ? swipeInteractionController : nil
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.slideinAnimator
    }
}
