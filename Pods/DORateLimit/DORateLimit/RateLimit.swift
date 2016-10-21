//
//  RateLimit.swift
//  RateLimitExample
//
//  Created by Daniele Orrù on 28/06/15.
//  Copyright (c) 2015 Daniele Orru'. All rights reserved.
//

import Foundation

// TODO: Merge RateLimitInfo with RateLimitInfo2
class RateLimitInfo: NSObject {
    let lastExecutionDate: Date
    let timer: Timer?
    let throttleInfo: ThrottleInfo

    init(lastExecutionDate: Date, timer: Timer? = nil, throttleInfo: ThrottleInfo)
    {
        self.lastExecutionDate = lastExecutionDate
        self.timer = timer
        self.throttleInfo = throttleInfo
        super.init()
    }
}

// TODO: Rename class
class RateLimitInfo2: NSObject {
    let timer: Timer?
    let debounceInfo: DebounceInfo

    init(timer: Timer? = nil, debounceInfo: DebounceInfo)
    {
        self.timer = timer
        self.debounceInfo = debounceInfo
        super.init()
    }
}

// TODO: Merge ThrottleInfo with DebounceInfo
class ThrottleInfo: NSObject {
    let key: String
    let threshold: TimeInterval
    let trailing: Bool
    let closure: () -> ()

    init(key: String, threshold: TimeInterval, trailing: Bool, closure: @escaping () -> ())
    {
        self.key = key
        self.threshold = threshold
        self.trailing = trailing
        self.closure = closure
        super.init()
    }
}

// TODO: Merge ThrottleInfo with DebounceInfo
class DebounceInfo: NSObject {
    let key: String
    let threshold: TimeInterval
    let atBegin: Bool
    let closure: () -> ()

    init(key: String, threshold: TimeInterval, atBegin: Bool, closure: @escaping () -> ())
    {
        self.key = key
        self.threshold = threshold
        self.atBegin = atBegin
        self.closure = closure
        super.init()
    }
}

/**
*    Provide debounce and throttle functionality.
*/
open class RateLimit
{
    // TODO: Rename queue with a generic name
    fileprivate static let debounceQueue = DispatchQueue(label: "org.orru.RateLimit", attributes: [])

    // TODO: merge rateLimitDictionary with rateLimitDictionary2
    fileprivate static var rateLimitDictionary = [String : RateLimitInfo]()
    fileprivate static var rateLimitDictionary2 = [String : RateLimitInfo2]()

    /**
    Throttle call to a closure using a given threshold

    - parameter name:
    - parameter threshold:
    - parameter trailing:
    - parameter closure:
    */
    open static func throttle(_ key: String, threshold: TimeInterval, trailing: Bool = false, closure: @escaping ()->())
    {
        let now = Date()
        var canExecuteClosure = false
        if let rateLimitInfo = self.rateLimitInfoForKey(key) {
            let timeDifference = rateLimitInfo.lastExecutionDate.timeIntervalSince(now)
            if timeDifference < 0 && fabs(timeDifference) < threshold {
                if trailing && rateLimitInfo.timer == nil {
                    let timer = Timer.scheduledTimer(timeInterval: threshold, target: self, selector: #selector(RateLimit.throttleTimerFired(_:)), userInfo: ["rateLimitInfo" : rateLimitInfo], repeats: false)
                    let throttleInfo = ThrottleInfo(key: key, threshold: threshold, trailing: trailing, closure: closure)
                    self.setRateLimitInfoForKey(RateLimitInfo(lastExecutionDate: rateLimitInfo.lastExecutionDate, timer: timer, throttleInfo: throttleInfo), forKey: key)
                }
            } else {
                canExecuteClosure = true
            }
        } else {
            canExecuteClosure = true
        }
        if canExecuteClosure {
            let throttleInfo = ThrottleInfo(key: key, threshold: threshold, trailing: trailing, closure: closure)
            self.setRateLimitInfoForKey(RateLimitInfo(lastExecutionDate: now, timer: nil, throttleInfo: throttleInfo), forKey: key)
            closure()
        }
    }

    @objc fileprivate static func throttleTimerFired(_ timer: Timer)
    {
        // TODO: use constant for "rateLimitInfo"
        if let userInfo = timer.userInfo as? [String : AnyObject], let rateLimitInfo = userInfo["rateLimitInfo"] as? RateLimitInfo {
            self.throttle(rateLimitInfo.throttleInfo.key, threshold: rateLimitInfo.throttleInfo.threshold, trailing: rateLimitInfo.throttleInfo.trailing, closure: rateLimitInfo.throttleInfo.closure)
        }
    }

    /**
    Debounce call to a closure using a given threshold

    - parameter key:
    - parameter threshold:
    - parameter atBegin:
    - parameter closure:
    */
    open static func debounce(_ key: String, threshold: TimeInterval, atBegin: Bool = true, closure: @escaping ()->())
    {
        var canExecuteClosure = false
        if let rateLimitInfo = self.rateLimitInfoForKey2(key) {
            if let timer = rateLimitInfo.timer , timer.isValid {
                timer.invalidate()
                let debounceInfo = DebounceInfo(key: key, threshold: threshold, atBegin: atBegin, closure: closure)
                // TODO: use constant for "rateLimitInfo"
                let timer = Timer.scheduledTimer(timeInterval: threshold, target: self, selector: #selector(RateLimit.throttleTimerFired2(_:)), userInfo: ["rateLimitInfo" : debounceInfo], repeats: false)
                self.setRateLimitInfoForKey2(RateLimitInfo2(timer: timer, debounceInfo: debounceInfo), forKey: key)

            } else {
                if (atBegin) {
                    canExecuteClosure = true
                } else {
                    let debounceInfo = DebounceInfo(key: key, threshold: threshold, atBegin: atBegin, closure: closure)
                    // TODO: use constant for "rateLimitInfo"
                    let timer = Timer.scheduledTimer(timeInterval: threshold, target: self, selector: #selector(RateLimit.throttleTimerFired2(_:)), userInfo: ["rateLimitInfo" : debounceInfo], repeats: false)
                    self.setRateLimitInfoForKey2(RateLimitInfo2(timer: timer, debounceInfo: debounceInfo), forKey: key)
                }
            }
        } else {
            if (atBegin) {
                canExecuteClosure = true
            } else {
                let debounceInfo = DebounceInfo(key: key, threshold: threshold, atBegin: atBegin, closure: closure)
                // TODO: use constant for "rateLimitInfo"
                let timer = Timer.scheduledTimer(timeInterval: threshold, target: self, selector: #selector(RateLimit.throttleTimerFired2(_:)), userInfo: ["rateLimitInfo" : debounceInfo], repeats: false)
                self.setRateLimitInfoForKey2(RateLimitInfo2(timer: timer, debounceInfo: debounceInfo), forKey: key)
            }
        }
        if canExecuteClosure {
            let debounceInfo = DebounceInfo(key: key, threshold: threshold, atBegin: atBegin, closure: closure)
            // TODO: use constant for "rateLimitInfo"
            let timer = Timer.scheduledTimer(timeInterval: threshold, target: self, selector: #selector(RateLimit.throttleTimerFired2(_:)), userInfo: ["rateLimitInfo" : debounceInfo], repeats: false)
            self.setRateLimitInfoForKey2(RateLimitInfo2(timer: timer, debounceInfo: debounceInfo), forKey: key)
            closure()
        }
    }

    // TODO: Rename method
    @objc fileprivate static func throttleTimerFired2(_ timer: Timer)
    {
        // TODO: use constant for "rateLimitInfo"
        if let userInfo = timer.userInfo as? [String : AnyObject], let debounceInfo = userInfo["rateLimitInfo"] as? DebounceInfo , !debounceInfo.atBegin  {
            debounceInfo.closure()
        }
    }

    open static func resetAllRateLimit()
    {
        debounceQueue.sync {
            for key in self.rateLimitDictionary.keys {
                if let rateLimitInfo = self.rateLimitDictionary[key], let timer = rateLimitInfo.timer , timer.isValid {
                    timer.invalidate()
                }
                self.rateLimitDictionary[key] = nil
            }
            for key in self.rateLimitDictionary2.keys {
                if let rateLimitInfo = self.rateLimitDictionary2[key], let timer = rateLimitInfo.timer , timer.isValid {
                    timer.invalidate()
                }
                self.rateLimitDictionary2[key] = nil
            }
        }
    }

    open static func resetRateLimitForKey(_ key: String)
    {
        debounceQueue.sync {
            if let rateLimitInfo = self.rateLimitDictionary[key], let timer = rateLimitInfo.timer , timer.isValid {
                timer.invalidate()
            }
            self.rateLimitDictionary[key] = nil
            if let rateLimitInfo = self.rateLimitDictionary2[key], let timer = rateLimitInfo.timer , timer.isValid {
                timer.invalidate()
            }
            self.rateLimitDictionary2[key] = nil
        }
    }

    // TODO: merge rateLimitInfoForKey with rateLimitInfoForKey2
    fileprivate static func rateLimitInfoForKey(_ key: String) -> RateLimitInfo?
    {
        var rateLimitInfo: RateLimitInfo?
        debounceQueue.sync {
            rateLimitInfo = self.rateLimitDictionary[key]
        }
        return rateLimitInfo
    }

    // TODO: merge rateLimitInfoForKey with rateLimitInfoForKey2
    fileprivate static func rateLimitInfoForKey2(_ key: String) -> RateLimitInfo2?
    {
        var rateLimitInfo: RateLimitInfo2?
        debounceQueue.sync {
            rateLimitInfo = self.rateLimitDictionary2[key]
        }
        return rateLimitInfo
    }

    // TODO: merge setRateLimitInfoForKey with setRateLimitInfoForKey2
    fileprivate static func setRateLimitInfoForKey(_ rateLimitInfo: RateLimitInfo, forKey key: String)
    {
        debounceQueue.sync {
            self.rateLimitDictionary[key] = rateLimitInfo
        }
    }

    // TODO: merge setRateLimitInfoForKey with setRateLimitInfoForKey2
    fileprivate static func setRateLimitInfoForKey2(_ rateLimitInfo: RateLimitInfo2, forKey key: String)
    {
        debounceQueue.sync {
            self.rateLimitDictionary2[key] = rateLimitInfo
        }
    }
}
