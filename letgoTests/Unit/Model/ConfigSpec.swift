//
//  ConfigSpec.swift
//  LGCoreKit
//
//  Created by Dídac on 10/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Quick
import Nimble
import Argo
@testable import LetGoGodMode


class ConfigSpec: QuickSpec {
   
    override func spec() {
     
        var sut : Config!
        var json : JSON!

        describe("init") {
            beforeEach {
                let path = Bundle(for: self.classForCoder).path(forResource: "iOScfgMockOK", ofType: "json")
                let data = try! Data(contentsOf: URL(fileURLWithPath: path!))
                let jsonObject = try! JSONSerialization.jsonObject(with: data, options: [])
                json = JSON(jsonObject)
                
                sut = Config(json: json)
            }
            context("init with data") {
                it("object not nil") {
                    expect(sut).notTo(beNil())
                }
                it("should have buildNumber set") {
                    expect(sut.buildNumber).notTo(beNil())
                }
                it("should have forceUpdateVersions set") {
                    expect(sut.forceUpdateVersions).notTo(beNil())
                }
                it("should have configURL set") {
                    expect(sut.configURL).notTo(beNil())
                }
            }
            context("object to json") {
                
                it("should create a json representation from object") {
                    let jsonRepresentation = sut.jsonRepresentation()
                    expect(JSON(jsonRepresentation)).to(equal(json))
                }
            }
        }
    }
}
