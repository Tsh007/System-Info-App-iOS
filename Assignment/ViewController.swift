//
//  ViewController.swift
//  Assignment
//
//  Created by Tejash Singh on 01/03/24.
//

import UIKit
import AVFoundation
//import IOKit
import MetalKit
//import IOKit
//import OpenCL
import Metal

class ViewController: UIViewController, UITableViewDelegate {
    
    let info=UIDeviceHardware()
    @IBOutlet var tableView: UITableView!
    
    //why use lazy as can't directly provide default value before self is created so this will be called when view needs it
    lazy var arr:[data]=[
        data(property: "Model Name", value: UIDevice.current.name),
        data(property: "system version", value: UIDevice.current.systemVersion),
        data(property: "total Disk", value:UIDevice.current.totalDiskSpaceInGB),
        data(property: "used Disk", value:UIDevice.current.usedDiskSpaceInGB),
        data(property: "free Disk", value:UIDevice.current.freeDiskSpaceInGB),
        data(property: "battery Level", value:getCurrentBatteryLevel()),
        data(property:"camera MegaPixel",value:getCameraPixels() ?? "N/A"),
        data(property: "Camera Aperture", value:getCameraAperture() ?? "N/A"),
        data(property: "CPU", value:getCPUInformation() ?? "N/A"),
        data(property: "Process ID", value:getProcessInfo()["processID"] ?? "N/A"),
        data(property: "Process Name", value:getProcessInfo()["processName"] ?? "N/A"),
        data(property: "RAM", value:info.ramString),
        data(property: "System Up Time", value:getProcessInfo()["SystemUpTime"] ?? "N/A"),
        data(property: "Processors total", value:getProcessInfo()["processorCount"] ?? "N/A"),
        data(property: "Active Processors", value:getProcessInfo()["activeProcessor"] ?? "N/A"),
        data(property: "Thermal State", value:getProcessInfo()["thermalState"] ?? "N/A"),
        data(property: "sys Built", value:getProcessInfo()["systemVersion"] ?? "N/A"),
        data(property: "GPU", value:info.gpu),
        data(property: "modelName", value:info.modelName),
        data(property: "Neural Engine", value:info.neuralEngine),
        data(property: "System Architecture", value:info.modelIdentifier),
        
        
        
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource=self
        tableView.delegate=self



        

//        print(info.processorName)//N/A
        
        
    }
    

    
    func getCurrentBatteryLevel() -> String {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        return "\(device.batteryLevel * 100 * -1)"
    }
    
    
    
    
        func getCameraPixels() ->String?{
            guard let backCamera = AVCaptureDevice.default(for: .video) else {
                return nil
            }
    
//            let width = backCamera.activeFormat.supportedMaxPhotoDimensions
            
//    depreciated but still usable also need the iphone to check reality
                let width = backCamera.activeFormat.highResolutionStillImageDimensions.width
                let height = backCamera.activeFormat.highResolutionStillImageDimensions.height
                let megapixels = Double(width * height) / 1_000_000.0
            
            return "\(megapixels)"
}
    
    func getCameraAperture()->String?{
        let session = AVCaptureSession()
        var aperture:Float=0.0
        var apertureObserver: NSKeyValueObservation?
            guard let device = AVCaptureDevice.default(for: .video) else {
//                        print("No video device found")
                        return nil
                    }
            do {
                    let input = try AVCaptureDeviceInput(device: device)
                    session.addInput(input)

            apertureObserver = device.observe(\.lensAperture, options: .new) { [weak self] (device, _) in
                aperture = device.lensAperture
//                print("Aperture: \(aperture)")
            }

            session.startRunning()
                } catch {
                    print("Error setting up capture session: \(error.localizedDescription)")
                }
        
            apertureObserver?.invalidate()
            return "\(aperture)"
    }
    
    
    
    func getCPUInformation() -> String? {
        var size: size_t = 0
        sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
        
        var cpuInfo = [CChar](repeating: 0, count: Int(size))
        sysctlbyname("machdep.cpu.brand_string", &cpuInfo, &size, nil, 0)
        
        let cpuString = String(cString: cpuInfo)
        return cpuString.isEmpty ? nil : cpuString
    }
    
    
    
    func getProcessInfo() -> [String:String] {
        let processInfo = ProcessInfo.processInfo

        let processID = processInfo.processIdentifier
        
        var dict=["processID":"\(processID)"]
        
        let processName = processInfo.processName
        
        dict["processName"]="\(processName)"


        let memoryUsage = processInfo.physicalMemory
//        print(convertGB(memoryUsage))
        //i don't know its giving correct value
        dict["RAM"]=convertGB(memoryUsage)
        
        let systemUpTime = processInfo.systemUptime
//        print(systemUpTime/60)
        dict["SystemUpTime"]="\(Int(systemUpTime/60)) minutes"
        
        let processorCount = processInfo.processorCount
//        print(processorCount)
        dict["processorCount"]="\(processorCount)"
        
        let activeProcessorCount=processInfo.activeProcessorCount
//        print(activeProcessorCount)
        dict["activeProcessor"]="\(activeProcessorCount)"
        
        let thermalState = processInfo.thermalState
//        print(thermalState)
        dict["thermalState"]="\(thermalState)"
        
//        print(processInfo.operatingSystemVersionString)
        dict["systemVersion"]=processInfo.operatingSystemVersionString
        
        return dict
    }
    
    

    
    func convertGB(_ bytes: UInt64)->String{
        
        return ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    
    
    
}







extension UIDevice {
    
    func MBFormatter(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = ByteCountFormatter.Units.useMB
        formatter.countStyle = ByteCountFormatter.CountStyle.decimal
        formatter.includesUnit = false
        return formatter.string(fromByteCount: bytes) as String
    }
    
    //MARK: Get String Value
    var totalDiskSpaceInGB:String {
       return ByteCountFormatter.string(fromByteCount: totalDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var freeDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: freeDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var usedDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: usedDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var totalDiskSpaceInMB:String {
        return MBFormatter(totalDiskSpaceInBytes)
    }
    
    var freeDiskSpaceInMB:String {
        return MBFormatter(freeDiskSpaceInBytes)
    }
    
    var usedDiskSpaceInMB:String {
        return MBFormatter(usedDiskSpaceInBytes)
    }
    
    //MARK: Get raw value
    var totalDiskSpaceInBytes:Int64 {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else { return 0 }
        return space
    }

    var freeDiskSpaceInBytes:Int64 {
        if #available(iOS 11.0, *) {
            if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String).resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
                return space
            } else {
                return 0
            }
        } else {
            if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value {
                return freeSpace
            } else {
                return 0
            }
        }
    }
    
    var usedDiskSpaceInBytes:Int64 {
       return totalDiskSpaceInBytes - freeDiskSpaceInBytes
    }

}




extension ViewController:UITableViewDataSource{
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableCell", for: indexPath) as! myCustomCell
        
        cell.valueLabel.text=arr[indexPath.row].value
        cell.propertyLabel.text=arr[indexPath.row].property
        return cell
//        UIListContentConfiguration.self
    }
    
    
}

class myCustomCell:UITableViewCell{
    

    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var propertyLabel: UILabel!
    
    
}

