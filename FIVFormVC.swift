//
//  FIVFormVC.swift
//  mCAS
//
//  Created by iMac on 20/02/20.
//  Copyright © 2020 Nucleus. All rights reserved.
//

import UIKit


class FIVFormVC: UIViewController {
    
    @IBOutlet weak var applicationDetailView: UIView!
    @IBOutlet weak var applicationDetailViewHeight: NSLayoutConstraint!
    @IBOutlet weak var detailSatckView: UIStackView!
    @IBOutlet weak var buttonView: NextBackButtonView!
    
    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var formViewHeight: NSLayoutConstraint!
    @IBOutlet weak var formStackView: UIStackView!

    private struct FIUserDetail  {
        let title: String
        let imageName: String
    }
    
    private var userDetailArray: [FIUserDetail] = []
    private var selectedLOVDic: [String: DropDown] = [:]
    private var FIVData: FIModelClasses.FIVData!
    private var dataObj: FIModelClasses.LoanVerificationCategoryVOList!
    private var fieldData: [FIModelClasses.DynamicVerificationTypeVOList]!
    private var subForm: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonView.setProperties(showNext: true, nextBtnTitle: "Continue", delegate: self)
        setupDetailView()
//        fetchOnlineFormData()
        setDynamicForm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let headerView = AppDelegate.instance.headerView {
            let navArray = AppDelegate.instance.applicationNavController.viewControllers
            let lastVC = navArray[navArray.count-2]
            var title = ""
            if let dataArr = FIVData?.loanFieldVerificationDetailVOList, !dataArr.isEmpty {
                title = dataArr.first?.loanVerificationCategoryVOList?.first?.customerName ?? ""
            }
            headerView.showHideStepHeader(isHide: false, title: title, landingPage: lastVC)
        }
    }
    
    func setData(FIVData: FIModelClasses.FIVData, fieldData: [FIModelClasses.DynamicVerificationTypeVOList], data: FIModelClasses.LoanVerificationCategoryVOList? = nil, isSubForm: Bool = false) {
        self.FIVData = FIVData
        self.dataObj = data
        self.subForm = isSubForm
        self.fieldData = fieldData
    }
    
    private func setupDetailView(showAll: Bool = true) {
        if subForm {
            applicationDetailViewHeight.constant = 0
        }
        else {
            applicationDetailView.backgroundColor = Color.BLUE
            userDetailArray.removeAll()
            if showAll {
                userDetailArray.append(FIUserDetail(title: self.dataObj.applicationId ?? "", imageName: "address_icon"))
                userDetailArray.append(FIUserDetail(title: self.dataObj.verificationNameKey ?? "", imageName: "address_icon"))
            }
            
            if let addrs = dataObj.customerAddressVO, let addrsArray = addrs.fivAddressDetailVOList, !addrsArray.isEmpty {
                
                userDetailArray.append(FIUserDetail(title: "\(addrsArray.first?.address ?? ""),\(addrsArray.first?.city  ?? ""),\(addrsArray.first?.state  ?? ""),\(addrsArray.first?.country  ?? ""),\(addrsArray.first?.zipCode  ?? "")", imageName: "address_icon"))
            }
            
            for (_, item) in userDetailArray.enumerated() {
                let view = CustomUserDetailView()
                view.setProperties(title:item.title, imageName: item.imageName)
                detailSatckView.addArrangedSubview(view)
            }
            
            applicationDetailViewHeight.constant = CGFloat(userDetailArray.count*38 + 40)
        }
    }
    
    private func setDynamicForm() {
        var heightOfView:CGFloat = 0.0
        var groupIDArray = self.fieldData?.map({ $0.groupId }) ?? []
        groupIDArray = groupIDArray.distinctElements
        for item in groupIDArray {
            
            let groupId = item
            let arrayByGroupId = self.fieldData?.filter({ $0.groupId == groupId }) ?? []
            let label = CommonFormUtils.shared().setupHeadinLabel(title: arrayByGroupId.first!.groupDescription!, font: CustomFont.shared().GETFONT_MEDIUM(16))
            label.backgroundColor = Color.EXTREME_LIGHT_GRAY
            formStackView.addArrangedSubview(label)
            formStackView.addConstraint(NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 35))
            heightOfView += 35
            for obj in arrayByGroupId {
                
                let label = CommonFormUtils.shared().setupHeadinLabel(title: obj.fieldLabel ?? "", isMandatory: (obj.isFieldMandatory ?? "" == "Y") ? true : false)
                formStackView.addArrangedSubview(label)
                formStackView.addConstraint(NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 35))
                
                let view = CommonFormUtils.shared().setupCustomviews(dataObj: obj, tag: 1000)
                if obj.controlType == "MUL_ENTRY" {
                    let btn = CommonFormUtils.shared().setupMultiFormButton(title: obj.fieldLabel!)
                    btn.accessibilityIdentifier = obj.fieldId
                    btn.addTarget(self, action: #selector(multiFormAction(_:)), for: .touchUpInside)
                    formStackView.addArrangedSubview(btn)
                    formStackView.addConstraint(NSLayoutConstraint(item: btn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 35))
                    heightOfView += 35 + 35
                }
                else {
                    formStackView.addArrangedSubview(view)
                    formStackView.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 65))
                    heightOfView += 35 + 65
                }
                
                
            }
        }
        
        //        making static fields
       
        if !subForm {
        let headingLabel = CommonFormUtils.shared().setupHeadinLabel(title: "Decision", font: CustomFont.shared().GETFONT_MEDIUM(16))
        headingLabel.backgroundColor = Color.EXTREME_LIGHT_GRAY
        formStackView.addArrangedSubview(headingLabel)
        formStackView.addConstraint(NSLayoutConstraint(item: headingLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 35))
        heightOfView += 35
        //No. Of Attempts
        let label = CommonFormUtils.shared().setupHeadinLabel(title: "No. Of Attempts", isMandatory: true)
        formStackView.addArrangedSubview(label)
        formStackView.addConstraint(NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 35))
        
        let view = CustomTextFieldView()
        view.setProperties(placeHolder: "Enter Value")
        
        formStackView.addArrangedSubview(view)
        formStackView.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 65))
        heightOfView += 35 + 65
        //remarks
        let label1 = CommonFormUtils.shared().setupHeadinLabel(title: "Remarks")
        formStackView.addArrangedSubview(label1)
        formStackView.addConstraint(NSLayoutConstraint(item: label1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 35))
        
        let view1 = CustomTextFieldView()
        view1.setProperties(placeHolder: "Enter Value")
        
        formStackView.addArrangedSubview(view1)
        formStackView.addConstraint(NSLayoutConstraint(item: view1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 65))
        heightOfView += 35 + 65
        //result
        let label2 = CommonFormUtils.shared().setupHeadinLabel(title: "Remarks", isMandatory: true)
        formStackView.addArrangedSubview(label2)
        formStackView.addConstraint(NSLayoutConstraint(item: label2, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 35))
        
        let view2 = LOVFieldView()
        view2.setLOVProperties(title: "", tag: 1000, delegate: self)
        
        formStackView.addArrangedSubview(view2)
        formStackView.addConstraint(NSLayoutConstraint(item: view2, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 65))
        heightOfView += 35 + 65
        
        }
        formViewHeight.constant = heightOfView
    }
   
     @objc private func multiFormAction(_ sender: UIButton) {
           
        print(sender.accessibilityIdentifier)
        let arr = fieldData.filter({$0.fieldId == sender.accessibilityIdentifier})
        print(arr.count)
        let data = arr.first?.multiEntryDynamicFormVOList ?? []
        let st = UIStoryboard.init(name: Storyboard.FI, bundle: nil)
        if let vc = st.instantiateViewController(withIdentifier: "FIVFormVC") as? FIVFormVC {
            vc.setData(FIVData: FIVData, fieldData: data, isSubForm: true)
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    @IBAction func showHideDetailButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        detailSatckView.removeAllSubviews()
        setupDetailView(showAll: !sender.isSelected)
    }
    
    private func fetchOnlineFormData() {
        
        let params = ["applicationId"    : "APPL00000794",
                      "verficationType"  : "OfficeAddress"]
        
        
        Webservices.shared().POST(urlString: ServiceUrl.GET_DYNAMIC_FORM_ONLINE_FI_URL, paramaters: params, autoHandleLoader: true, success: { (header, responseObj) in
            print(responseObj)
            if let response = responseObj as? [String: Any]
            {
                print(response)
            }
        }, failure: { (error) in
            
            if let error = error {
                CommonAlert.shared().showAlert(message: NSLocalizedString(error, comment: ""))
            }
            
        }, noNetwork: { (error) in
            
        })
    }
    
}


extension FIVFormVC: NextBackButtonDelegate {
    
    func nextButtonAction() {
        
        for view in formStackView.subviews {
            if let vw = view as? CustomTextFieldView {
                print(vw.getFieldValue())
            }
            if let vw = view as? LOVFieldView {
                print(selectedLOVDic["\(vw.tag)"]?.name ?? "")
            }
            
        }
        
    }
}

extension FIVFormVC: SelectedLOVDelegate {
    func selectedLOVResult(selectedObj: DropDown, btntag: Int) {
        selectedLOVDic["\(btntag)"] = selectedObj
    }
}
