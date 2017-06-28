//
//  ScanDevicePage.swift
//  BLEAddress
//
//  Created by DatTran on 4/22/29 H.
//  Copyright © 29 Heisei ANSV. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

struct DisplayPeripheral {
    var peripheral      : CBPeripheral?
    var rssi            : Int?
    var uuid            : String?
    var localname       : String?
    var isconnect       : Bool?
    var dataManufacturer: NSData?
    var dataAdvertisement: String?
}

class ScanDevicePage2: UIViewController, UITableViewDataSource, UITableViewDelegate, CBCentralManagerDelegate {
    
    
    private var centralManager  : CBCentralManager?
    private var peripherals     : [DisplayPeripheral] = []
    private var update            : NSTimer?
    private var reScan          : NSTimer?
    
    private var currentPeripheral: CBPeripheral?
    
    private var scan_cell       = "scan_cell"
    
    private var header_cell     = "header_cell"
    
    private var _localname          : String = ""
    private var _bleName            : String = ""
    private var _dataManufacturer   : NSData?
    private var _rssi               : Int?
    private var _uuid               : String = ""
    private var _dataAdvertisement  : String = ""
    
    private var stateBLE            : String = ""

    lazy var tableview: UITableView = {
       
        let tb = UITableView()
        tb.dataSource = self
        tb.delegate = self
        return tb
        
    }()
    
    var sta: Bool = false
    
    func setupTableViews(v: UIView) {
        
        v.addSubview(tableview)
        
        tableview.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        tableview.backgroundColor = UIColor.whiteColor()
        
        tableview.separatorInset = UIEdgeInsetsZero
        
        tableview.separatorInset.right = tableview.separatorInset.left

        
        tableview.sectionHeaderHeight = 30
        
        tableview.rowHeight = UITableViewAutomaticDimension
        
        tableview.registerClass(ScanDeviceCell.self, forCellReuseIdentifier: scan_cell)
        
        tableview.registerClass(HeaderCell.self, forHeaderFooterViewReuseIdentifier: header_cell)
        
        let backgroundImage = UIImage(named: "iPhone 67_1")

        let imageView = UIImageView(image: backgroundImage)
        imageView.contentMode = .ScaleAspectFit

        tableview.backgroundView = imageView
        
        tableview.allowsSelection = false                       // disable when select into item

        tableview.tableFooterView = UIView(frame: CGRectZero)   // to delete all space in the rest

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationItem.title = "vAddress"
        let titleImage = UIImage(named: "ic_title3")
        let imageView = UIImageView(image: titleImage)
        imageView.contentMode = .ScaleAspectFit
        navigationItem.titleView = imageView

        setupTableViews(view)
  
        let distance = String(format: "%.1f", handleDistance(-55, rssi: -78))

        print ("DISTANCE: \(distance)m")

        
//        setRightNavigationBar()

    }
    

    func handleDistance(txPower: Double, rssi: Double) -> Double{
        
        let ratio: Double = rssi * 1.0 / txPower
        
//        let estimate: Double = (0.42093) * pow(ratio, 6.0476) + 0.54992
        let estimate: Double = (0.89976) * pow(ratio, 7.7095) + 0.111

        return estimate
        
    }

    override func viewDidAppear(animated: Bool) {
        let search = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: #selector(ScanDevicePage.handleSearch))

        self.navigationItem.rightBarButtonItem = search
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)

        dispatch_async(dispatch_get_main_queue()) {

            self.centralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())

        }
        
        loadTimer()
        

    }
    private var startApp: Bool = false
    
    func loadTimer() {
        
        
        update = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(handleUpdate), userInfo: nil, repeats: true)
        
        reScan = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(handleReScan), userInfo: nil, repeats: true)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        update?.invalidate()
        reScan?.invalidate()
        startApp = false
    }
    
    func handleBegin() {
        
        loadTimer()
        
    }
    
    func handleUpdate() {
        
        
        
        if (peripherals.count > 0 && (centralManager?.isScanning)!) {
            
            startApp = true
            
            tableview.reloadData()
            
        } else {
            
            // nodata when cannot scan device
            peripherals = []
        }
        
    }
    
    func handleReScan() {
        
        update?.invalidate()
        if (centralManager!.isScanning) {
            centralManager?.stopScan()
        }
        peripherals.removeAll()
        peripherals = []
        tableview.reloadData()
        
        startScanning()
        
        startApp = false
        
        update = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(handleUpdate), userInfo: nil, repeats: true)

    }
    
    
    func handleSearch () {
        
        if (stateBLE == "ON") {
        
            if centralManager!.isScanning {
                
                centralManager?.stopScan()
                peripherals.removeAll()
                peripherals = []
                tableview.reloadData()
            }else{
                startScanning()
            }

        } else if (stateBLE == "OFF") {
            
            let alert = UIAlertController(title: "Bluetooth is powered off", message: "Please turn on your bluetooth in Settings or Control Center to continue", preferredStyle: .Alert);
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else if (stateBLE == "UNSUPPORT") {
            
            let alert = UIAlertController(title: "Bluetooth is not supported", message: "Please find another phone and try agian.", preferredStyle: .Alert);
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil)

            
        }
        
    }
    
    func startScanning() {
        
        peripherals = []
        peripherals.removeAll()
        
        self.centralManager?.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    
    }
    
    // TABLE VIEW DATA SOURCE
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return peripherals.count ?? 0
        
//        return 3
        
    }
    
    var lo: Int = 0
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ScanDeviceCell = tableView.dequeueReusableCellWithIdentifier(scan_cell, forIndexPath: indexPath) as! ScanDeviceCell
        
        
        if (peripherals.count > 0 && startApp) {
            
            peripherals = peripherals.sort({$0.rssi > $1.rssi})
            
            cell.peri = peripherals[indexPath.row]
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            
            if (indexPath.row == 0) {
                cell.backgroundColor = UIColor(red: 200/255, green: 80/255, blue: 100/255, alpha: 1)
                cell.address.textColor = UIColor.whiteColor()
            }
            
            
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableview.dequeueReusableHeaderFooterViewWithIdentifier(header_cell) as! HeaderCell
        
        header.name.text = "DANH SÁCH THIẾT BỊ"
        
        return header
        
    }
    
    // NAVIGATION BAR
    func setRightNavigationBar() {
        
//        let infoImage = UIImage(named: "ic_info_25")?.imageWithRenderingMode(.AlwaysOriginal)
        
        let scanButton  = UIBarButtonItem(title: "SCAN", style: .Plain, target: self, action: #selector (ScanDevicePage.handleScan))
        navigationItem.rightBarButtonItem = scanButton
        
    }
    
    /*
    func setLeftNavigationBar() {
    
        let logoutImage = UIImage(named: "ic_cancel_30")?.imageWithRenderingMode(.AlwaysOriginal)
        
        let logoutBarButtonItem = UIBarButtonItem(image: logoutImage, style: .Plain, target: self, action: #selector(handleBack))
        
        navigationItem.leftBarButtonItem = logoutBarButtonItem
        
    }
    */
    
    // HANDLE
    
    func handleScan () {
        
    }
    
    // CB_MANAGER_DELEGATE
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .PoweredOff:
            
            stateBLE = "OFF"
            peripherals.removeAll()
            peripherals = []
            tableview.reloadData()
            
            let alert = UIAlertController(title: "Bluetooth is powered off", message: "Please turn on your bluetooth in Settings or Control Center to continue", preferredStyle: .Alert);
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil)
            
        case .Unauthorized:
            let alert = UIAlertController(title: "Bluetooth is not authencated", message: "Please give me the access for bluetooth in Settings.", preferredStyle: .Alert);
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil)
            
        case .Unknown:
            let alert = UIAlertController(title: "Unknown state for bluetooth", message: "Please try to reboot your device and try again.", preferredStyle: .Alert);
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil)
            
        case .Unsupported:
            
            stateBLE = "UNSUPPORT"
            let alert = UIAlertController(title: "Bluetooth is not supported", message: "Please find another phone and try agian.", preferredStyle: .Alert);
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil));
            self.presentViewController(alert, animated: true, completion: nil)
            
        case .PoweredOn:
            
            stateBLE = "ON"
            startScanning()
//            self.centralManager?.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])

        case .Resetting:
            break;
        }

    }
    
    func showAlertWithText (header : String = "Warning", message : String) {
        let alert = UIAlertController(title: header, message: message, preferredStyle:UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        alert.view.tintColor = UIColor.redColor()
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        let advertisement = advertisementData as NSDictionary
        
        let manufac: String = "\(advertisement.objectForKey(CBAdvertisementDataManufacturerDataKey))"
        
        let serviceUUID: String = "\(advertisement.objectForKey(CBAdvertisementDataServiceUUIDsKey))"
        
        if (serviceUUID.rangeOfString(Constant().BLE_ANSV) != nil && manufac.rangeOfString(Constant().BLE_ADDRESS) != nil){

            let adverData = advertisementData as NSDictionary
            
            for (index, newPeripheral) in peripherals.enumerate(){
                
                if (newPeripheral.peripheral?.identifier == peripheral.identifier && newPeripheral.peripheral?.identifier.UUIDString == peripheral.identifier.UUIDString){
                    
                    if (adverData.objectForKey(CBAdvertisementDataLocalNameKey) == nil) {
                        
                    } else{
                        
                        if(adverData.objectForKey(CBAdvertisementDataManufacturerDataKey) == nil) {
                            
                        } else {
                            
                            
                            peripherals[index].localname        = adverData.objectForKey(CBAdvertisementDataLocalNameKey) as! NSString as String
                                                        
                            peripherals[index].peripheral       = peripheral
                            
                            peripherals[index].uuid             = peripheral.identifier.UUIDString
                            
                            
                            peripherals[index].dataManufacturer = advertisementData[CBAdvertisementDataManufacturerDataKey] as? NSData
                            
                            peripherals[index].rssi             = RSSI as Int
                            
                            peripherals[index].isconnect        = advertisementData["kCBAdvDataIsConnectable"] as? Bool
                            
                            peripherals[index].dataAdvertisement = "\(adverData)"
                            
                            _localname = adverData.objectForKey(CBAdvertisementDataLocalNameKey) as! NSString as String
                            _rssi = RSSI as Int
                            
                            _dataManufacturer                   = advertisementData[CBAdvertisementDataManufacturerDataKey] as? NSData
                            
                            _dataAdvertisement                  = "\(adverData)"
                            
                            
                        }
                    }
                    
                    return
                    
                }
            }
            let isConnectable = advertisementData["kCBAdvDataIsConnectable"] as! Bool
            let displayPeripheral = DisplayPeripheral(
                peripheral          : peripheral,
                rssi                : _rssi,
                uuid                : peripheral.identifier.UUIDString,
                localname           : _localname,
                isconnect           : isConnectable,
                dataManufacturer    : _dataManufacturer,
                dataAdvertisement   : _dataAdvertisement
            )
            
            peripherals.append(displayPeripheral)
            
            
            tableview.reloadData()
        }

    }

}

extension ScanDevicePage: CBPeripheralDelegate {
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        peripheral.discoverServices(nil)
        
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
    }
    
    // Get data values when updated
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
    }
    
    // OTHER
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension UIView {
    
    func anchorToTop(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil) {
        
        anchorWithConstantsToTop(top, left: left, bottom: bottom, right: right, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
    }
    
    func anchorWithConstantsToTop(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraintEqualToAnchor(top, constant: topConstant).active = true
            
        }
        
        if let bottom = bottom {
            bottomAnchor.constraintEqualToAnchor(bottom, constant: -bottomConstant).active = true
        }
        
        if let left = left {
            leftAnchor.constraintEqualToAnchor(left, constant: leftConstant).active = true
        }
        
        if let right = right {
            rightAnchor.constraintEqualToAnchor(right, constant: -rightConstant).active = true
        }
        
    }
    
}

