//
//  ConversationModel.swift
//  Mandoub Services Platform
//
//  Created by Harish on 24/08/19.
//  Copyright © 2019 Ashutosh Mishra. All rights reserved.
//

import Foundation

class ConversationDetailsModel {

    var id:Int?
    var channelId:Int?
    var loginId:Int?
    var senderId:Int?
    var userId:Int?
    var senderName:String?
    var senderImage:String?
    var receiverId:Int?
    var message :String?
    var createdAt:String?
    var timestamp:String?
    var mediaType:String?
    var media:String?
    var isUserBlocked:Int?
    var isMandoobBlocked:Int?

init(data: JSON) {
    self.id = data["id"].intValue
    self.channelId = data["channel_id"].intValue
    self.loginId = data["login_id"].intValue
    self.senderId = data["sender_id"].intValue
    self.userId = data["user_id"].intValue
    self.senderName = data["sender_name"].stringValue
    self.senderImage = data["sender_image"].stringValue
    self.receiverId = data["receiver_id"].intValue
    self.timestamp = data["timestamp"].stringValue
    self.createdAt = data["created_at"].stringValue
    self.message = data["message"].stringValue
    self.mediaType = data["media_type"].stringValue
    self.media = data["media"].stringValue
    self.isUserBlocked = data["is_user_blocked"].intValue
    self.isMandoobBlocked = data["is_mandoob_blocked"].intValue
   }
}
