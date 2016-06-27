//
//  GitOAuth.swift
//  GoGoGitHub
//
//  Created by Michael Sweeney on 6/27/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

import Foundation
import UIKit

let kAccessTokenKey = "kAccessTokenKey"
let kOAuthBaseUrl = "http://github.com/login/oauth/"
let kAccessTokenRegexPattern = "access_token=([^&]+)"

typealias GitHubOAuthCompletion = (success: Bool) -> ()

enum GitHubOAuthError : ErrorType {
    case MissingAccessToken(String)
    case ExtractingTokenFromString(String)
    case ExtractingTemporaryCode(String)
    case ResponseFromGitHub(String)
}

enum SaveOptions: Int {
    case userDefaults
}

