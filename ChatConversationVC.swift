//
//  ChatConversationVC.swift
//  Project Name: Mandoub Services Platform
//
//  Created by Rakesh Sharma on 31/05/19.
//  
//  Copyright © 2019 Ashutosh Mishra. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import DropDown
import PopOverMenu

class ChatConversationVC: UIViewController, UITextViewDelegate,mediaSendDelegate,UIAdaptivePresentationControllerDelegate {
   
    @IBOutlet weak var chatConversationTableView: UITableView!
    @IBOutlet weak var bottomTextView: IQTextView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var btnUploadImg: UIButton!
    @IBOutlet weak var btnSendMsg: UIButton!
    @IBOutlet weak var customViewConstrants: NSLayoutConstraint!
    @IBOutlet weak var btnDisable: UIButton!
    
    var customView: ChatTopNavigation!
    var isScrollEnable: Bool?
    var chanalID:Int? 
    var userID:Int?
    var mandoobNam:String?
    var mandoobImg:String?
    var data: Data?
    var conversationData = [ConversationDetailsModel]()
    var sendMsg = [SendMsgModel]()
    var mediaType:Int?
    var url: String?
    var imageName: String?
    var statusC: Int = 1
    var isUserBlock:Int?
    var isMandoobBlock:Int?
    var notificationID:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       self.btnDisable.isHidden = true
        if isUserBlock == 1 {
             self.btnDisable.setTitle("      you blocked by mandoob.", for: .normal)
        } else {
             self.btnDisable.setTitle("      you blocked by user.", for: .normal)
        }
        chatConversationTableView.register(ChatYouTextTableViewCell.nib, forCellReuseIdentifier: ChatYouTextTableViewCell.identifier)
        chatConversationTableView.register(ChatMeTextTableViewCell.nib, forCellReuseIdentifier: ChatMeTextTableViewCell.identifier)
        chatConversationTableView.register(ChatImageTableViewCell.nib, forCellReuseIdentifier: ChatImageTableViewCell.identifier)
        chatConversationTableView.delegate = self
        chatConversationTableView.dataSource = self
        chatConversationTableView.reloadData()
        bottomTextView.textColor = UIColor.lightGray
        bottomTextView.delegate = self
        bottomTextView.isScrollEnabled = false
        isScrollEnable = false
        textViewDidChange(bottomTextView)
    
 NotificationCenter.default.addObserver( self, selector: #selector(keyboardWasShown(notification:)), name:  UIResponder.keyboardWillShowNotification, object: nil )
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWasHide(notification:)), name:  UIResponder.keyboardWillHideNotification, object: nil )
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
       // print("keyboard open called")
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
          if CommonHelper.getIntance.hasNotch() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                self.customViewConstrants.constant = -40
                }
            } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                self.customViewConstrants.constant = -6
               }
            }
        }
    }
    @objc func keyboardWasHide(notification: NSNotification) {
       // print("keyboard hide called")
        print("keyboard hide called")
        self.customViewConstrants.constant = -8
    }
    //Custom Deleate Popup.
    @objc func moreBtnClicked(_ sender: UIButton) {
        var titles:NSArray = ["Delete", "Block"]
        if statusC == 1 {
            titles = ["Delete", "Block"]
        } else {
            titles = ["Delete", "Unblock"]
        }
            let rightItem:UIBarButtonItem = UIBarButtonItem.init(customView: sender as? UIButton ?? UIButton())
            let popOverViewController = PopOverViewController.instantiate()
            popOverViewController.set(titles: titles as! [String])
            // option parameteres
            popOverViewController.set(showsVerticalScrollIndicator: true)
            popOverViewController.set(separatorStyle: UITableViewCell.SeparatorStyle.singleLine)
            
            popOverViewController.popoverPresentationController?.barButtonItem = rightItem
            popOverViewController.preferredContentSize = CGSize(width: 150, height:100)
            popOverViewController.presentationController?.delegate = self
            popOverViewController.completionHandler = { selectRow in
                switch (selectRow) {
                case 0:
                    self.customView.sideDotButton .setTitle((titles[0] as? String), for: .normal)
                    
                    self.alertOkCancel(message: "Are you really want to delete all chats.", okayHandler: {
                        self.chatDetailDeletePostRequest()
                    })
                    break
                case 1:
                    let title = titles[1] as? String
                    if title == "Block" {
                        self.statusC = 1
                        self.alertOkCancel(message: "Are you really want to block.", okayHandler: {
                            var parameter = [String: Any]()
                            parameter["channel_id"] = self.chanalID
                            parameter["status"] = self.statusC
                            self.blockPostRequest(params: parameter)
                            if title == "Block" {
                                self.statusC = 0
                            } else {
                                self.statusC = 1
                            }
                        })
                    } else {
                        self.statusC = 0
                        self.alertOkCancel(message: "Are you really want to unblock.", okayHandler: {
                            var parameter = [String: Any]()
                            parameter["channel_id"] = self.chanalID
                            parameter["status"] = self.statusC
                            self.blockPostRequest(params: parameter)
                            if title == "Block" {
                                self.statusC = 0
                            } else {
                                self.statusC = 1
                            }
                        })
                    }
                    self.customView.sideDotButton .setTitle((titles[1] as? String), for: .normal)
//                    self.alertOkCancel(message: "Are you really want to block.", okayHandler: {
//                        var parameter = [String: Any]()
//                        parameter["channel_id"] = self.chanalID
//                        parameter["status"] = self.statusC
//                        self.blockPostRequest(params: parameter)
//                        if title == "Block" {
//                            self.statusC = 0
//                        } else {
//                            self.statusC = 1
//                        }
//                    })
                    
                    break
                default:
                    break
                }
            };
            self.present(popOverViewController, animated: true, completion: nil)
       
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        print(textView.text)
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                if estimatedSize.height >= 100 {
                    textView.isScrollEnabled = true
                    isScrollEnable = true
                    textViewHeight.constant = 100
                } else {
                    textView.isScrollEnabled = false
                    isScrollEnable = false
                    textViewHeight.constant = estimatedSize.height
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let window = UIApplication.shared.keyWindow ?? UIWindow()
        for view in window.subviews where view.tag == 9_999 {
                view.removeFromSuperview()
                break
        }

        let view = UIView(frame: CGRect(x: 0, y: 0, width: window.frame.width, height: 100))
        window.addSubview(view)
        view.backgroundColor = UIColor(hexString: "4D7BF3")
        view.tag = 9_999
        customView = ChatTopNavigation(frame: CGRect(x: 0, y: 20, width: window.frame.width, height: 80))
        customView.delegate = self
        customView.fullName.text = self.mandoobNam
        
        //Image Download.
        let imgURL = "\(ServiceUrls.imageBaseUrl)\(self.mandoobImg ?? "")"
        let url =  URL(string: imgURL ?? "")
        let image = UIImage(named: "user1")
        customView.profileImageView.kf.setImage(with: url, placeholder: image)
        customView.sideDotButton.addTarget(self, action: #selector(moreBtnClicked), for: .touchUpInside)
        view.addSubview(customView)
         self.conversationDetailsPostRequest()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    func commonViewWillAppair() {
         self.viewWillAppear(true)
    }
    
    @IBAction func didTapDisableBtn(_ sender: UIButton) {
        if Defaults().userType == "user" {
            if isUserBlock == 1 {
                
                self.statusC = 1
//                alertOkCancel(message: "Are you really want to Unblock.", okayHandler: {
//                    var parameter = [String: Any]()
//                    parameter["channel_id"] = self.chanalID
//                    parameter["status"] = self.statusC
//                    self.blockPostRequest(params: parameter)
//                })
                
            } else {
                if isMandoobBlock == 1 {
//                     self.statusC = 0
                    alertOkCancel(message: "Are you really want to Unblock.", okayHandler: {
                        var parameter = [String: Any]()
                        parameter["channel_id"] = self.chanalID
                        parameter["status"] = self.statusC
                        self.blockPostRequest(params: parameter)
                    })
                } else {
                    self.statusC = 1
                    alertOkCancel(message: "Are you really want to Unblock.", okayHandler: {
                        var parameter = [String: Any]()
                        parameter["channel_id"] = self.chanalID
                        parameter["status"] = self.statusC
                        self.blockPostRequest(params: parameter)
                    })
                }
            }
            
        } else {
            if isUserBlock == 1 {
                
                alertOkCancel(message: "Are you really want to Unblock.", okayHandler: {
                    var parameter = [String: Any]()
                    parameter["channel_id"] = self.chanalID
                    parameter["status"] = self.statusC
                    self.blockPostRequest(params: parameter)
                })
            } else {
                if isMandoobBlock == 1 {
                    self.statusC = 0
                    alertOkCancel(message: "Are you really want to Unblock.", okayHandler: {
                        var parameter = [String: Any]()
                        parameter["channel_id"] = self.chanalID
                        parameter["status"] = self.statusC
                        self.blockPostRequest(params: parameter)
                    })
                } else {
                    self.statusC = 1
                    alertOkCancel(message: "Are you really want to Unblock.", okayHandler: {
                        var parameter = [String: Any]()
                        parameter["channel_id"] = self.chanalID
                        parameter["status"] = self.statusC
                        self.blockPostRequest(params: parameter)
                    })
                }
            }

        }
    }
    
    @IBAction func didTapUploadImgBtn(_ sender: UIButton) {
        
        if Defaults().userType == "user" {
            guard  let chatConversationVC = AllDocumentsVC.instantiate(fromAppStoryboard: .Main) as? AllDocumentsVC else { return }
            chatConversationVC.isFrom = "chat"
            chatConversationVC.userID = userID
            chatConversationVC.comingFrom = ComingFrom.chat
            self.present(chatConversationVC, animated: true, completion: nil)
        } else {
            guard  let imgUploadPopupVC = UploadImgPopupVC.instantiate(fromAppStoryboard: .Vender) as? UploadImgPopupVC else { return }
            imgUploadPopupVC.chatTVText = self.bottomTextView.text
            imgUploadPopupVC.customView = self.customView
            imgUploadPopupVC.scrolling = isScrollEnable
            imgUploadPopupVC.delegate = self
            self.present(imgUploadPopupVC, animated: true, completion: nil)
            // self.navigationController?.present(imgUploadPopupVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapSendMsg(_ sender: UIButton) {
        
        if Defaults().userType == "user"{
            if isUserBlock == 0 {
                var parameter = [String: Any]()
                parameter["user_id"] = userID
                parameter["message"] = self.bottomTextView.text
                self.sendConversationPostRequest(params: parameter)
            } else {
                self.btnDisable.isHidden = false
                 self.btnDisable.isUserInteractionEnabled = false
            }
        } else {
            if isMandoobBlock == 0 {
                var parameter = [String: Any]()
                parameter["user_id"] = userID
                parameter["media_type"] = 0
                parameter["message"] = self.bottomTextView.text
                self.sendConversationPostRequest(params: parameter)
            }else {
                 self.btnDisable.isHidden = false
                 self.btnDisable.isUserInteractionEnabled = false
            }
        }
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
      if  textView == bottomTextView {
            becomeFirstResponder()
        }
        return true
    }
    //UploadPopupDelegate.
    func mediaSendDelegate(mediaName: String) {
      //  print(mediaName)
        self.commonViewWillAppair()
        
        var parameter = [String: Any]()
                parameter["user_id"] = userID
                parameter["media_type"] = 1
                parameter["media"] = mediaName
        self.sendConversationPostRequest(params: parameter)
    }
    
    ///Delete Chat.
    func chatDetailDeletePostRequest() {
        var parameter = [String: Any]()
        parameter["channel_id"] = self.chanalID
        
        NetworkManager.shared.callingHttpRequest(api: .chatDetailDelete(param: parameter), taskCallback: { (isSuccess, jsonResult) in
            if isSuccess == 1 {
                guard let jsonResponse = jsonResult else { return }
                self.conversationDetailsPostRequest()
                self.chatConversationTableView.reloadData()
            }
        })
    }
    
    ///Block Chat.
    func blockPostRequest(params: [String: Any]) {
        NetworkManager.shared.callingHttpRequest(api: .blockUser(param: params), taskCallback: { (isSuccess, jsonResult) in
            if isSuccess == 1 {
                guard let jsonResponse = jsonResult else { return }
                self.conversationDetailsPostRequest()
                self.chatConversationTableView.reloadData()
            }
        })
    }
    
    ///Conversion B/W API.
    func conversationDetailsPostRequest() {
        var parameter = [String: Any]()
        parameter["channel_id"] = self.chanalID
        
        NetworkManager.shared.callingHttpRequest(api: .conversationDetails(param: parameter), taskCallback: { (isSuccess, jsonResult) in
            if isSuccess == 1 {
                guard let jsonResponse = jsonResult else { return }
            //    self.viewWillAppear(true)
               
                let detailsArray: [JSON] = jsonResponse["data"].arrayValue
                self.conversationData = detailsArray.map({(value) -> ConversationDetailsModel in
                    return ConversationDetailsModel(data: JSON(value))
                })
                self.isUserBlock = jsonResponse["is_user_blocked"].intValue
                self.isMandoobBlock = jsonResponse["is_mandoob_blocked"].intValue
                
                if Defaults().userType == "user"{
                    if self.isUserBlock == 1 {
//                        if self.title == "Block" {
//                            self.statusC = 1
//                        } else {
//                            self.statusC = 0
//                        }
                      //   self.statusC = 0
                        self.btnDisable.isHidden = false
                         self.btnDisable.setTitle("      you blocked to user.", for: .normal)
                       // self.btnDisable.isUserInteractionEnabled = false
                        self.btnDisable.isUserInteractionEnabled = false
                        self.bottomTextView.isUserInteractionEnabled = false
                        self.btnUploadImg.isUserInteractionEnabled = false
                        self.btnSendMsg.isUserInteractionEnabled = false
                        
                    } else {
                        if self.isMandoobBlock == 1 {
                            self.statusC = 0
                            self.btnDisable.isHidden = false

//                            self.btnDisable.isUserInteractionEnabled = false
//                            self.bottomTextView.isUserInteractionEnabled = false
//                            self.btnUploadImg.isUserInteractionEnabled = false
//                            self.btnSendMsg.isUserInteractionEnabled = false
                            
                        } else {
                             self.statusC = 1
                             self.btnDisable.isHidden = true
                        }
                    }
                } else {
                    if self.isUserBlock == 1 {
                        self.btnDisable.isHidden = false
                        self.btnDisable.setTitle("      you blocked to mandoob.", for: .normal)
                        self.statusC = 0
                    } else {
                        if self.isMandoobBlock == 1 {
                            self.btnDisable.isHidden = false
                            self.btnDisable.isUserInteractionEnabled = false
                            self.bottomTextView.isUserInteractionEnabled = false
                            self.btnUploadImg.isUserInteractionEnabled = false
                            self.btnSendMsg.isUserInteractionEnabled = false
                            
                        } else {
                            self.statusC = 1
                            self.btnDisable.isHidden = true
                        }
                    }
                }
                self.chatConversationTableView.reloadData()

            }
        })
    }
    
    func imageUploadS3() {
       // CustomLoader.instance.showLoaderView()
         let activityData = ActivityData(); NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
        
        guard let fetchData = self.data else {
            return
        }
        AWSUploadImage.shared.uploadFile(fetchData, fileName: self.imageName ?? "test.png", fileUrl: self.url ?? "") { (result) in
          //  CustomLoader.instance.hideLoaderView()
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
        }
    }
    
    //Image Upload.
    func dataPass(data:Data, imageName: String , url: String) {
        self.data = data
       // self.imageName = imageName
        self.url = url
    }
    
    ///Conversion Send API.
    func sendConversationPostRequest(params: [String: Any]) {
        NetworkManager.shared.callingHttpRequest(api: .sendChat(param: params), taskCallback: { (isSuccess, jsonResult) in
            if isSuccess == 1 {
                guard let jsonResponse = jsonResult else { return }

                self.bottomTextView.text = ""

                let detailsArray: [JSON] = jsonResponse["data"].arrayValue
                self.sendMsg = detailsArray.map({(value) -> SendMsgModel in

                    return SendMsgModel(data: JSON(value))
                })
                self.conversationDetailsPostRequest()
            }
        })
    }

}

extension ChatConversationVC: UITableViewDelegate, UITableViewDataSource {
    
    @objc func userImageShw(_ sender: UIButton) {
        let imgURL = "\(ServiceUrls.imageBaseUrl)\(self.conversationData[sender.tag].media ?? "")"
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabVC = storyboard.instantiateViewController(withIdentifier: "DownLoadImageVC") as? DownLoadImageVC else { return }
        tabVC.imgUrl = imgURL
        self.present(tabVC, animated: false, completion: nil)
//        self.navigationController?.pushViewController(tabVC, animated: true)
    }
    @objc func senderImageShw(_ sender: UIButton) {
        let imgURL = "\(ServiceUrls.imageBaseUrl)\(self.conversationData[sender.tag].media ?? "")"
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabVC = storyboard.instantiateViewController(withIdentifier: "DownLoadImageVC") as? DownLoadImageVC else { return }
        tabVC.imgUrl = imgURL
        self.present(tabVC, animated: false, completion: nil)
//        self.navigationController?.pushViewController(tabVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return conversationData.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let senderId = conversationData[indexPath.row].senderId
        let loginId = conversationData[indexPath.row].loginId
        if senderId == loginId {
            if self.conversationData[indexPath.row].mediaType == "1" {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatImageTableViewCell.identifier) as? ChatImageTableViewCell else { return UITableViewCell() }
                cell.senderImg.isHidden = true
                cell.userImg.isHidden = false
                cell.lblTime.textAlignment = .right
                cell.btnUserImage.tag = indexPath.row
                cell.btnUserImage.addTarget(self, action: #selector(userImageShw), for: .touchUpInside)
                let imgURL = "\(ServiceUrls.imageBaseUrl)\(self.conversationData[indexPath.row].media ?? "")"
                let url =  URL(string: imgURL )
                let image = UIImage(named: "")
                cell.userImg?.kf.setImage(with: url, placeholder: image)
                let timeStamp =  self.conversationData[indexPath.row].timestamp ?? ""
                let unixTimeStamp: Int = Int(timeStamp) ?? 0 / 1000
                let exactDate = NSDate.init(timeIntervalSince1970: TimeInterval(unixTimeStamp))
                let dateFormatt = DateFormatter();
                dateFormatt.dateFormat = "dd MMMM yyy "
                print(dateFormatt.string(from: exactDate as Date))
                cell.lblTime.text = dateFormatt.string(from: exactDate as Date)
                 return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatMeTextTableViewCell.identifier) as? ChatMeTextTableViewCell else { return UITableViewCell() }
                cell.lblMsgShow.text = self.conversationData[indexPath.row].message
                
                //Find date from timeStemp.
                let timeStamp =  self.conversationData[indexPath.row].timestamp ?? ""
                let unixTimeStamp: Int = Int(timeStamp) ?? 0 / 1000
                let exactDate = NSDate.init(timeIntervalSince1970: TimeInterval(unixTimeStamp))
                let dateFormatt = DateFormatter();
                dateFormatt.dateFormat = "dd MMMM yyy "
                print(dateFormatt.string(from: exactDate as Date))
                cell.lblDateShow.text = dateFormatt.string(from: exactDate as Date)
                 return cell
            }
        } else {
            if self.conversationData[indexPath.row].mediaType == "1" {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatImageTableViewCell.identifier) as? ChatImageTableViewCell else { return UITableViewCell() }
                cell.senderImg.isHidden = false
                 cell.userImg.isHidden = true
                cell.lblTime.textAlignment = .left
                cell.btnSenderImg.tag = indexPath.row
                cell.btnSenderImg.addTarget(self, action: #selector(senderImageShw), for: .touchUpInside)
                let imgURL = "\(ServiceUrls.imageBaseUrl)\(self.conversationData[indexPath.row].media ?? "")"
                let url =  URL(string: imgURL )
                let image = UIImage(named: "")
                cell.userImg?.kf.setImage(with: url, placeholder: image)
                let timeStamp =  self.conversationData[indexPath.row].timestamp ?? ""
                let unixTimeStamp: Int = Int(timeStamp) ?? 0 / 1000
                let exactDate = NSDate.init(timeIntervalSince1970: TimeInterval(unixTimeStamp))
                let dateFormatt = DateFormatter();
                dateFormatt.dateFormat = "dd MMMM yyy "
                print(dateFormatt.string(from: exactDate as Date))
                cell.lblTime.text = dateFormatt.string(from: exactDate as Date)
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatYouTextTableViewCell.identifier) as? ChatYouTextTableViewCell else { return UITableViewCell() }
                
                cell.lblMsgShow.text = self.conversationData[indexPath.row].message
                
                // Image download.
                let imgURL = "\(ServiceUrls.imageBaseUrl)\(self.conversationData[indexPath.row].senderImage ?? "")"
                let url =  URL(string: imgURL ?? "")
                let image = UIImage(named: "user1")
                cell.userProfileImg?.kf.setImage(with: url, placeholder: image)
                let timeStamp =  self.conversationData[indexPath.row].timestamp ?? ""
                let unixTimeStamp: Int = Int(timeStamp) ?? 0 / 1000
                let exactDate = NSDate.init(timeIntervalSince1970: TimeInterval(unixTimeStamp))
                let dateFormatt = DateFormatter();
                dateFormatt.dateFormat = "dd MMMM yyy "
                print(dateFormatt.string(from: exactDate as Date))
                cell.lblDateShow.text = dateFormatt.string(from: exactDate as Date)
                return cell
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let senderId = conversationData[indexPath.row].senderId
        let loginId = conversationData[indexPath.row].loginId
        if senderId == loginId {
            if self.conversationData[indexPath.row].mediaType == "1" {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let tabVC = storyboard.instantiateViewController(withIdentifier: "DownLoadImageVC") as? DownLoadImageVC else { return }
                self.navigationController?.pushViewController(tabVC, animated: true)
            } else {
                
            }
        } else {
            if self.conversationData[indexPath.row].mediaType == "1" {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let tabVC = storyboard.instantiateViewController(withIdentifier: "DownLoadImageVC") as? DownLoadImageVC else { return }
                self.navigationController?.pushViewController(tabVC, animated: true)
            } else {
               
            }
        }

        
    }
    
}

extension ChatConversationVC: ChatScreenBackHandleDelegate {
    func popToRootControllerBack() {
        if self.navigationController != nil {
            if let navigationController = self.navigationController, navigationController.isBeingPresented {
                self.dismiss(animated: true, completion: nil)
            } else {
               var controller = self.previousViewController
              //  print(controller)
                if controller?.isKind(of: CategoryDetailsVC.self) == true {
                    self.navigationController?.popViewController(animated: true)
                } else {
                self.navigationController?.popToRootViewController(animated: true)
                }
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
/// For Get Previous Controller.
extension UIViewController{
    var previousViewController:UIViewController?{
        if let controllersOnNavStack = self.navigationController?.viewControllers, controllersOnNavStack.count >= 2 {
            let n = controllersOnNavStack.count
            return controllersOnNavStack[n - 2]
        }
        return nil
    }
}

extension ChatConversationVC  {
    
    func alertOkCancel (message:String, okayHandler: @escaping (() -> ())) {
        let alert = UIAlertController(title: "Mandoob", message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        let actionok = UIAlertAction.init(title: "Ok", style: .default) { (action) in
              okayHandler()
          //  self.chatDetailDeletePostRequest()
        }
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(actionok)
        alert.addAction(actionCancel)
    }
}
