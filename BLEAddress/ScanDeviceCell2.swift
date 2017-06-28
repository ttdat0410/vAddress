//
//  AddressCell.swift
//  BLEAddress
//
//  Created by DatTran on 4/21/29 H.
//  Copyright © 29 Heisei ANSV. All rights reserved.
//

import Foundation
import UIKit

class ScanDeviceCell2: UITableViewCell {
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var peri: DisplayPeripheral? {
        
        didSet {
            
//            nameLabel.text = peri?.localname
//
            
            setUI()
            
//            rssiLabel.text = "\(_rssi)db"
//
//            var rssiString: String = "icn_device_signal_0bar"
//            switch _rssi {
//            case -20 ..< 0:
//                
//                rssiString = "icn_device_signal_5bar"
//                rssiLabel.textColor = UIColor.greenColor()
//                
//            case (-40) ..< (-20):
//                
//                rssiString = "icn_device_signal_4bar"
//                rssiLabel.textColor = UIColor.greenColor()
//
//            case (-60) ..< (-40):
//                
//                rssiString = "icn_device_signal_3bar"
//                rssiLabel.textColor = UIColor.greenColor()
//
//                
//            case (-80) ..< (-60):
//                
//                rssiString = "icn_device_signal_2bar"
//                rssiLabel.textColor = UIColor.orangeColor()
//                
//            case (-90) ..< (-80):
//                
//                rssiString = "icn_device_signal_1bar"
//                rssiLabel.textColor = UIColor.orangeColor()
//
//                
//            default:
//                rssiString = "icn_device_signal_1bar"
//                rssiLabel.textColor = UIColor.orangeColor()
//
//            }
//            
//            rssiImg.image = UIImage(named: rssiString)
            
//            address.text = parseDataManufacturer(peri!.dataManufacturer!)
//            data.text = "\(peri!.dataAdvertisement)"
            
        }
        
    }
    
    func setUI() {
        
        if let name = peri?.localname {
            
            nameLabel.text = name
            
            
        }
//        nameLabel.text = peri?.localname
        
        if let _rssi = peri?.rssi {
        
//        rssiLabel.text = "\(_rssi)dB"
            
        let distance = String(format: "%.1f", handleDistance(-55, rssi: Double(_rssi)))

        rssiLabel.text = "\(_rssi) - \(distance)m"
        
        var rssiString: String = "icn_device_signal_0bar"
            
        switch _rssi {
        
        case -20 ..< 128:
            
            rssiString = "icn_device_signal_5bar"
            rssiLabel.textColor = UIColor.greenColor()
            
        case (-40) ..< (-20):
            
            rssiString = "icn_device_signal_4bar"
            rssiLabel.textColor = UIColor.greenColor()
            
        case (-60) ..< (-40):
            
            rssiString = "icn_device_signal_3bar"
            rssiLabel.textColor = UIColor.greenColor()
            
            
        case (-80) ..< (-60):
            
            rssiString = "icn_device_signal_2bar"
            rssiLabel.textColor = UIColor.orangeColor()
            
        case (-90) ..< (-80):
            
            rssiString = "icn_device_signal_1bar"
            rssiLabel.textColor = UIColor.orangeColor()
            
            
        default:
            rssiString = "icn_device_signal_1bar"
            rssiLabel.textColor = UIColor.orangeColor()
            
            }
            
            rssiImg.image = UIImage(named: rssiString)
            
        }
        
        

        if let nanufacData = peri?.dataManufacturer {
            
            address.text = parseDataManufacturer(peri!.dataManufacturer!)

        }
        
    }
    
    func handleDistance(txPower: Double, rssi: Double) -> Double{
        
        let ratio: Double = rssi * 1.0 / txPower
        
        //        let estimate: Double = (0.42093) * pow(ratio, 6.0476) + 0.54992
        let estimate: Double = (0.89976) * pow(ratio, 7.7095) + 0.111
        
        return estimate
        
    }

    
    func parseDataManufacturer (data: NSData) -> String {
        
        // bonus: https://www.cloudcity.io/blog/2016/09/09/zero-to-ble-on-ios--part-two---swift-edition/
        
        let dataManu: NSData = data
        let len = dataManu.length
        
        let dataManufacturerLength = len / sizeof(UInt8)
        
        var dataArray = [UInt8](count:dataManufacturerLength, repeatedValue: 0)
        
        dataManu.getBytes(&dataArray, length: dataManufacturerLength * sizeof(Int8))
        
        var address: String = "nodata"
        
        let deviceType0     : UInt8 = dataArray[0]              // DEVICE TYPE
        let deviceType1     : UInt8 = dataArray[1]              // DEVICE TYPE
        let deviceDataLen   : UInt8 = dataArray[2]              // LENGTH
        
        if (convertToInt("\(dataManufacturerLength)") > 3 && convertToInt("\(deviceType0)") == Constant().DEVICE_TYPE_0 && convertToInt("\(deviceType1)") == Constant().DEVICE_TYPE_1) {
            
            if (convertToInt("\(deviceType0)") == Constant().DEVICE_TYPE_0 &&
                convertToInt("\(deviceType1)") == Constant().DEVICE_TYPE_1) {
                
                if (convertToInt("\(deviceDataLen)") >= 5) {

                    let province    : UInt8 = dataArray[4]              // TINH/THANH PHO
                    let district    : UInt8 = dataArray[5]              // QUAN/HUYEN
                    let ward        : UInt8 = dataArray[6]              // PHUONG XA
                    let street      : UInt8 = dataArray[7]              // DUONG
                    
                    let lenAddressHome    : Int = convertToInt("\(deviceDataLen)") - 5
                    
                    var addressHome: String = ""
                    
                    for j in 0..<lenAddressHome {
                        
                        addressHome += "\(convertUnicodeToString(dataArray[j + 8]))"
                        
                    }
                    
                    let setAddress = ModelManager.getInstance().getAddress(convertToInt("\(province)"), districtCode: convertToInt("\(district)"), wardCode: convertToInt("\(ward)"), streetCode: convertToInt("\(street)"))
                    
//                    address = "Địa chỉ: Số \(soNha), \(exportArray(duong, arrayString: SampleData().DUONG)), \(exportArray(phuong, arrayString: SampleData().PHUONG)), \(exportArray(quan, arrayString: SampleData().QUAN)), \(exportArray(tinh, arrayString: SampleData().TINH))"
                    
                    address = "Số \(addressHome), \(setAddress.street), \(setAddress.wards), \(setAddress.district), \(setAddress.province)"
                    
                }
                
            }
            
        }
 
        return address
    }
    
    func exportArray(index: UInt8, arrayString: [String]) -> String {
        
        return arrayString[convertToInt("\(index)")-1]
        
    }
    
    func convertToInt (input: String) -> Int {
        
        return Int(input)!
    }
    
    func convertUnicodeToString(input: UInt8) -> String {
        
        let inp: Int    = convertToInt("\(input)")
        let unicodeSca  = UnicodeScalar(inp)
        let out         = String(unicodeSca)
        
        return out
    }
    
    let locationImg: UIImageView = {
    
        let img = UIImageView()
        
        img.image = UIImage(named: "ic_item")
        img.contentMode = .ScaleAspectFit
        
        return img
        
    }()
    
    let nameLabel : UILabel = {
    
        let label = UILabel()
        label.text = "sensorNode"
        label.font = UIFont(name: "SanFranciscoDisplay-Black", size: 17)
        label.textAlignment = .Left
        label.textColor = UIColor(red: 61/255, green: 167/255, blue: 244/255, alpha: 1)
        
        return label
    }()
    
    let rssiLabel: UILabel = {
    
        let label = UILabel()
        label.text = "N/A"
        label.font = UIFont(name: "Courier-Oblique", size: 14)
        label.textAlignment = .Left
        label.textColor = UIColor.greenColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label


    
    }()
    
    let rssiImg : UIImageView = {

        let img = UIImageView()
        img.image = UIImage(named: "icn_device_signal_1bar")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .ScaleAspectFit
        
        return img
    }()
    
//    let rssiLabel : UILabel = {
//        
//        let label = UILabel()
//        label.text = "N/A"
//        label.font = UIFont(name: "Courier-Oblique", size: 14)
//        label.textAlignment = .Left
//        label.textColor = UIColor.blackColor()
//        
//        return label
//    }()

    
    let uuidLabel : UILabel = {
    
        let label = UILabel()
        label.text = "01234567-3333-4445-6455-455445566756"
        label.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        label.textAlignment = .Left
        label.textColor = UIColor.darkGrayColor()
        return label
    }()
    
    let dataLabel: UILabel = {
        
        let label = UILabel()
        label.text = "01234567-3333-4445-6455-455445566756"
        label.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        label.textAlignment = .Left
        label.textColor = UIColor.darkGrayColor()
        return label
    }()
    
    let data: UITextView = {
        
        let txt = UITextView()
        
        txt.scrollEnabled = true
        txt.textColor = UIColor.redColor()
        txt.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        txt.textAlignment = .Left
        txt.text = "dfgdfhgf gfhgfjghf hjghjghfd hdfghdfgjfdj ghjghfj dgfhgfh dgfhdfhfgj jghjghj hgfjghjghfkfgh jgfhjghjghf hgfjghjghfjgf hgjghfjfg jghfjfgjt tyurtyur rthdfgh dfghdfjdfj tyirti egdfghd fdghgfdh"

        return txt
        
    }()
    
    let address: UILabel = {
        
        let label = UILabel()
        label.text = "N/A"
        label.font = UIFont(name: "SanFranciscoDisplay-Bold", size: 19)
        label.textColor = UIColor.blackColor()
        label.sizeToFit()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .Left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
    
    let scanBtn: UIButton = {
        
        let btn = UIButton()
        btn.setTitle("SCAN", forState: .Normal)
        btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btn.backgroundColor = UIColor.redColor()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 10
        btn.layer.masksToBounds = true
        
        return btn
    }()

    
    func setupViews() {
        
        let contentView = UIView()
        addSubview(contentView)
        addConstraintsWithFormat("H:|-1-[v0]-1-|", views: contentView)
        addConstraintsWithFormat("V:|-1-[v0]-1-|", views: contentView)
        
        
        /*contentView.addSubview(nameLabel)
        contentView.addSubview(rssiImg)
        contentView.addSubview(rssiLabel)
        contentView.addSubview(address)
        
        contentView.addConstraintsWithFormat("H:|-5-[v0]", views: nameLabel)
        contentView.addConstraintsWithFormat("H:[v0]-2-[v1]-5-|", views: rssiImg, rssiLabel)
        contentView.addConstraintsWithFormat("H:|-10-[v0]-5-|", views: address)

        contentView.addConstraintsWithFormat("V:|-5-[v0(20)]-5-[v1(40)]", views: nameLabel, address)

        contentView.addConstraintsWithFormat("V:[v0]", views: rssiImg)
        contentView.addConstraintsWithFormat("V:[v0]", views: rssiLabel)

        
        
        
        contentView.addConstraint(NSLayoutConstraint(item: rssiImg, attribute: .CenterY, relatedBy: .Equal, toItem: nameLabel, attribute: .CenterY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: rssiImg, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 0, constant: 20))
        contentView.addConstraint(NSLayoutConstraint(item: rssiImg, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 0, constant: 23))
        
        contentView.addConstraint(NSLayoutConstraint(item: rssiLabel, attribute: .CenterY, relatedBy: .Equal, toItem: nameLabel, attribute: .CenterY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: rssiLabel, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 0, constant: 17))*/
    
        
        let z1 = UIView()
        let z2 = UIView()
        
        contentView.addSubview(z1)
        contentView.addSubview(z2)
        
        contentView.addConstraintsWithFormat("H:|-1-[v0(70)]-5-[v1]-1-|", views: z1, z2)
        
        contentView.addConstraintsWithFormat("V:[v0(80)]", views: z1)
        
        contentView.addConstraintsWithFormat("V:[v0(80)]", views: z2)
        
        contentView.addConstraint(NSLayoutConstraint(item: z1, attribute: .CenterY, relatedBy: .Equal, toItem: contentView.self, attribute: .CenterY, multiplier: 1, constant: 0))
        
        contentView.addConstraint(NSLayoutConstraint(item: z2, attribute: .CenterY, relatedBy: .Equal, toItem: contentView.self, attribute: .CenterY, multiplier: 1, constant: 0))

        
        z1.addSubview(locationImg)
        z1.addConstraintsWithFormat("H:|-1-[v0]-1-|", views: locationImg)
        z1.addConstraintsWithFormat("V:|-1-[v0(70)]-1-|", views: locationImg)
        
        z2.addSubview(address)
        z2.addSubview(nameLabel)
        z2.addSubview(rssiImg)
        z2.addSubview(rssiLabel)
//        z2.addSubview(distanceLabel)
        z2.addConstraintsWithFormat("H:|-1-[v0]|", views: address)
        z2.addConstraintsWithFormat("V:[v0(40)]", views: address)
        
        z2.addConstraintsWithFormat("H:|-1-[v0]|", views: nameLabel)
        z2.addConstraintsWithFormat("V:[v0(20)]", views: nameLabel)
        
        z2.addConstraintsWithFormat("H:[v0]-2-[v1]-5-|", views: rssiImg, rssiLabel)
        z2.addConstraintsWithFormat("V:[v0]", views: rssiImg)
        z2.addConstraintsWithFormat("V:[v0]", views: rssiLabel)
        
//        z2.addConstraintsWithFormat("H:[v0]", views: distanceLabel)
//        z2.addConstraintsWithFormat("V:[v0]", views: distanceLabel)
        
        z2.addConstraint(NSLayoutConstraint(item: address, attribute: .CenterY, relatedBy: .Equal, toItem: z2.self, attribute: .CenterY, multiplier: 1, constant: 0))
        
        z2.addConstraint(NSLayoutConstraint(item: nameLabel, attribute: .Bottom, relatedBy: .Equal, toItem: address, attribute: .Top, multiplier: 1, constant: -5))
        
        z2.addConstraint(NSLayoutConstraint(item: rssiImg, attribute: .Bottom, relatedBy: .Equal, toItem: nameLabel, attribute: .Bottom, multiplier: 1, constant: 0))
        z2.addConstraint(NSLayoutConstraint(item: rssiImg, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 0, constant: 18))
        z2.addConstraint(NSLayoutConstraint(item: rssiImg, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 0, constant: 21))
        
        z2.addConstraint(NSLayoutConstraint(item: rssiLabel, attribute: .Bottom, relatedBy: .Equal, toItem: rssiImg, attribute: .Bottom, multiplier: 1, constant: 0))
        z2.addConstraint(NSLayoutConstraint(item: rssiLabel, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 0, constant: 17))
        
//        z2.addConstraint(NSLayoutConstraint(item: distanceLabel, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 0, constant: 2))
//        z2.addConstraint(NSLayoutConstraint(item: distanceLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 0, constant: 2))
        
        
    }
}