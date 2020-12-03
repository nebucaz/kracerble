# Publish Kettler Fitness Data over BLE
## Suopports Kettler Racer 9 and Kettler Treadmill "Track S5"
The Kettler Racer 9 is an ergometer with USB and Bluetooth interface. Similarly, Kettler Treadmill "Track S5" also features a USB Port. Unfortunately both lack Bluetooth Smart support and therefore can not be integrated/used together with the Zwift App. 

In order to be able to use mentioned fitness machnies as a source for Zwift, the project connects to the fitness machines over USB. The training data is polled and published over a BLE server. Everithing runs on Raspberry PI (tested with models 2, 3 and 4) and probably on other linux based systems:
* Kettler Racer 9 Ergometer: the instantaneous power value is published over Bluetooth Smart Characteristic "Cycling Power Measuermen [0x2A63](https://www.bluetooth.com/wp-content/uploads/Sitecore-Media-Library/Gatt/Xml/Characteristics/org.bluetooth.characteristic.cycling_power_measurement.xml) of the BLE Service Cycling Power Serivce [0x1818](https://www.bluetooth.com/wp-content/uploads/Sitecore-Media-Library/Gatt/Xml/Services/org.bluetooth.service.cycling_power.xml).  
* Kettler Treadmill Track S5: Instantaneous speed and total distance are transmitted over BLE using  RSC Service [0x1814]() (Running Speed and Cadence Service) containing RSC Measurement [0x2A53]() and RSC Feature [0x2A54]()

## Swift Linux on Raspberri Pi
Inspired by the great work of [360manu](https://github.com/360manu) and his 
great work published in [kettlerUSB2BLE](https://github.com/360manu/kettlerUSB2BLE). However, I wanted to rewrite the functionality using Swift language on Linux. Again, there has been great work already done by the community, namely [PureSwift](https://github.com/PureSwift)

## Polling and Publishing
The Program tries to connect to the machines (Kettler Racer 9, Kettler Treack S5) over USB. After successfully establishing communication, the training status of the device is requestet every second and broadcasted over Bluetooth Smart Service "Cycling Power Service" or "Running Speed and Cadence" respectively.

# Installation
## Swift on Linux
To compile swift source code on linux, [install swift on linux](https://lickability.com/blog/swift-on-raspberry-pi/). 
```
Repo: curl -s https://packagecloud.io/install/repositories/swift-arm/release/script.deb.sh | sudo bash
sudo apt-get install swift5
```

## Using XCode
You can use Xcode to develop and compile the software on a Mac. To get a executable to be run on raspberry, the code  must be compiled on the target-architecture (aarch64). Currently, the type of fitness machine type has to be choosen at compile time. Assign .racer9 or .track5 to machineType in main.swift (I'll add command line options in a future version).

```
let machineType : KettlerType = .track5 // .racer9
```

Fortunately, [thomaspaulman](https://github.com/thomaspaulmann) created a handy script to rsync the code to the raspberry and run the compilation on the remote machine: [Swish](https://github.com/thomaspaulmann/Swish). Compile the source with the following command

```
$ swish <user> <host>
```
# Running & Testing
## Running
The compiled source can be found in the .build directory.

## Connecting the Zwift App
Open the Zwift app and choose the KRacer9 Service after selecting the "Power" - button in the pairing dialogue

## Testing Blutooth Smart Cycling Power Service with fake data
You can broadcast random test values by uncommentin/commenting the followin section in main.swift 
```
//kettler?.provideFakeData()
kettler?.startPolling(portName)
```
