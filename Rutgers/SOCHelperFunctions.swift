//
//  SOCHelperFunctions.swift
//  Rutgers
//
//  Created by Colin Walsh on 8/16/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import RxSwift


struct SOCHelperFunctions {
    
    static func getBuildings(meetingTimes: [MeetingTime]) ->
        Observable<(MeetingTime, Building)>{
            return Observable
                .from(meetingTimes)
                .flatMap {meetingTime -> Observable<(MeetingTime, Building)> in
                    if let buildingCode = meetingTime.buildingCode {
                        return RutgersAPI.sharedInstance.getBuilding(
                            buildingCode: buildingCode
                            ).flatMap {building -> Observable<(MeetingTime, Building)> in
                                return Observable.just((meetingTime, building))
                        }
                    } else {
                        return Observable.just(
                            meetingTime,
                            Building(
                                code: "",
                                campus: meetingTime.campusAbbrev ?? "",
                                name: "",
                                id: ""
                            )
                        )
                    }
            }
    }
}
