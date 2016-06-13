//
//  UnicodeScalar+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 09/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension Character {
    var isEmoji: Bool {
        let scalars = String(self).unicodeScalars
        for scalar in scalars {
            if scalar.isEmoji { return true }
        }
        return false
    }
}

extension UnicodeScalar {

    var isEmoji: Bool {
        return UnicodeScalar.emojiScalars.contains(self)
    }

    /*List from http://unicode.org/emoji/charts/full-emoji-list.html
     download the page into a file emoji.html an then:
     #>  cat emoji.html | grep "<td class='code'>" | grep -hoe 'U[+][A-Z0-9]*' | sed 's/U+/0x/g' | awk '!seen[$0]++' | awk '{print "UnicodeScalar("$0"),"}' > final.txt
     */
    static let emojiScalars: Set<UnicodeScalar> =
        [UnicodeScalar(0x1F004),
         UnicodeScalar(0x1F0CF),
         UnicodeScalar(0x1F170),
         UnicodeScalar(0x1F171),
         UnicodeScalar(0x1F17E),
         UnicodeScalar(0x1F17F),
         UnicodeScalar(0x1F18E),
         UnicodeScalar(0x1F191),
         UnicodeScalar(0x1F192),
         UnicodeScalar(0x1F193),
         UnicodeScalar(0x1F194),
         UnicodeScalar(0x1F195),
         UnicodeScalar(0x1F196),
         UnicodeScalar(0x1F197),
         UnicodeScalar(0x1F198),
         UnicodeScalar(0x1F199),
         UnicodeScalar(0x1F19A),
         UnicodeScalar(0x1F1E6),
         UnicodeScalar(0x1F1E7),
         UnicodeScalar(0x1F1E8),
         UnicodeScalar(0x1F1E9),
         UnicodeScalar(0x1F1EA),
         UnicodeScalar(0x1F1EB),
         UnicodeScalar(0x1F1EC),
         UnicodeScalar(0x1F1ED),
         UnicodeScalar(0x1F1EE),
         UnicodeScalar(0x1F1EF),
         UnicodeScalar(0x1F1F0),
         UnicodeScalar(0x1F1F1),
         UnicodeScalar(0x1F1F2),
         UnicodeScalar(0x1F1F3),
         UnicodeScalar(0x1F1F4),
         UnicodeScalar(0x1F1F5),
         UnicodeScalar(0x1F1F6),
         UnicodeScalar(0x1F1F7),
         UnicodeScalar(0x1F1F8),
         UnicodeScalar(0x1F1F9),
         UnicodeScalar(0x1F1FA),
         UnicodeScalar(0x1F1FB),
         UnicodeScalar(0x1F1FC),
         UnicodeScalar(0x1F1FD),
         UnicodeScalar(0x1F1FE),
         UnicodeScalar(0x1F1FF),
         UnicodeScalar(0x1F201),
         UnicodeScalar(0x1F202),
         UnicodeScalar(0x1F21A),
         UnicodeScalar(0x1F22F),
         UnicodeScalar(0x1F232),
         UnicodeScalar(0x1F233),
         UnicodeScalar(0x1F234),
         UnicodeScalar(0x1F235),
         UnicodeScalar(0x1F236),
         UnicodeScalar(0x1F237),
         UnicodeScalar(0x1F238),
         UnicodeScalar(0x1F239),
         UnicodeScalar(0x1F23A),
         UnicodeScalar(0x1F250),
         UnicodeScalar(0x1F251),
         UnicodeScalar(0x1F300),
         UnicodeScalar(0x1F301),
         UnicodeScalar(0x1F302),
         UnicodeScalar(0x1F303),
         UnicodeScalar(0x1F304),
         UnicodeScalar(0x1F305),
         UnicodeScalar(0x1F306),
         UnicodeScalar(0x1F307),
         UnicodeScalar(0x1F308),
         UnicodeScalar(0x1F309),
         UnicodeScalar(0x1F30A),
         UnicodeScalar(0x1F30B),
         UnicodeScalar(0x1F30C),
         UnicodeScalar(0x1F30D),
         UnicodeScalar(0x1F30E),
         UnicodeScalar(0x1F30F),
         UnicodeScalar(0x1F310),
         UnicodeScalar(0x1F311),
         UnicodeScalar(0x1F312),
         UnicodeScalar(0x1F313),
         UnicodeScalar(0x1F314),
         UnicodeScalar(0x1F315),
         UnicodeScalar(0x1F316),
         UnicodeScalar(0x1F317),
         UnicodeScalar(0x1F318),
         UnicodeScalar(0x1F319),
         UnicodeScalar(0x1F31A),
         UnicodeScalar(0x1F31B),
         UnicodeScalar(0x1F31C),
         UnicodeScalar(0x1F31D),
         UnicodeScalar(0x1F31E),
         UnicodeScalar(0x1F31F),
         UnicodeScalar(0x1F320),
         UnicodeScalar(0x1F321),
         UnicodeScalar(0x1F324),
         UnicodeScalar(0x1F325),
         UnicodeScalar(0x1F326),
         UnicodeScalar(0x1F327),
         UnicodeScalar(0x1F328),
         UnicodeScalar(0x1F329),
         UnicodeScalar(0x1F32A),
         UnicodeScalar(0x1F32B),
         UnicodeScalar(0x1F32C),
         UnicodeScalar(0x1F32D),
         UnicodeScalar(0x1F32E),
         UnicodeScalar(0x1F32F),
         UnicodeScalar(0x1F330),
         UnicodeScalar(0x1F331),
         UnicodeScalar(0x1F332),
         UnicodeScalar(0x1F333),
         UnicodeScalar(0x1F334),
         UnicodeScalar(0x1F335),
         UnicodeScalar(0x1F336),
         UnicodeScalar(0x1F337),
         UnicodeScalar(0x1F338),
         UnicodeScalar(0x1F339),
         UnicodeScalar(0x1F33A),
         UnicodeScalar(0x1F33B),
         UnicodeScalar(0x1F33C),
         UnicodeScalar(0x1F33D),
         UnicodeScalar(0x1F33E),
         UnicodeScalar(0x1F33F),
         UnicodeScalar(0x1F340),
         UnicodeScalar(0x1F341),
         UnicodeScalar(0x1F342),
         UnicodeScalar(0x1F343),
         UnicodeScalar(0x1F344),
         UnicodeScalar(0x1F345),
         UnicodeScalar(0x1F346),
         UnicodeScalar(0x1F347),
         UnicodeScalar(0x1F348),
         UnicodeScalar(0x1F349),
         UnicodeScalar(0x1F34A),
         UnicodeScalar(0x1F34B),
         UnicodeScalar(0x1F34C),
         UnicodeScalar(0x1F34D),
         UnicodeScalar(0x1F34E),
         UnicodeScalar(0x1F34F),
         UnicodeScalar(0x1F350),
         UnicodeScalar(0x1F351),
         UnicodeScalar(0x1F352),
         UnicodeScalar(0x1F353),
         UnicodeScalar(0x1F354),
         UnicodeScalar(0x1F355),
         UnicodeScalar(0x1F356),
         UnicodeScalar(0x1F357),
         UnicodeScalar(0x1F358),
         UnicodeScalar(0x1F359),
         UnicodeScalar(0x1F35A),
         UnicodeScalar(0x1F35B),
         UnicodeScalar(0x1F35C),
         UnicodeScalar(0x1F35D),
         UnicodeScalar(0x1F35E),
         UnicodeScalar(0x1F35F),
         UnicodeScalar(0x1F360),
         UnicodeScalar(0x1F361),
         UnicodeScalar(0x1F362),
         UnicodeScalar(0x1F363),
         UnicodeScalar(0x1F364),
         UnicodeScalar(0x1F365),
         UnicodeScalar(0x1F366),
         UnicodeScalar(0x1F367),
         UnicodeScalar(0x1F368),
         UnicodeScalar(0x1F369),
         UnicodeScalar(0x1F36A),
         UnicodeScalar(0x1F36B),
         UnicodeScalar(0x1F36C),
         UnicodeScalar(0x1F36D),
         UnicodeScalar(0x1F36E),
         UnicodeScalar(0x1F36F),
         UnicodeScalar(0x1F370),
         UnicodeScalar(0x1F371),
         UnicodeScalar(0x1F372),
         UnicodeScalar(0x1F373),
         UnicodeScalar(0x1F374),
         UnicodeScalar(0x1F375),
         UnicodeScalar(0x1F376),
         UnicodeScalar(0x1F377),
         UnicodeScalar(0x1F378),
         UnicodeScalar(0x1F379),
         UnicodeScalar(0x1F37A),
         UnicodeScalar(0x1F37B),
         UnicodeScalar(0x1F37C),
         UnicodeScalar(0x1F37D),
         UnicodeScalar(0x1F37E),
         UnicodeScalar(0x1F37F),
         UnicodeScalar(0x1F380),
         UnicodeScalar(0x1F381),
         UnicodeScalar(0x1F382),
         UnicodeScalar(0x1F383),
         UnicodeScalar(0x1F384),
         UnicodeScalar(0x1F385),
         UnicodeScalar(0x1F386),
         UnicodeScalar(0x1F387),
         UnicodeScalar(0x1F388),
         UnicodeScalar(0x1F389),
         UnicodeScalar(0x1F38A),
         UnicodeScalar(0x1F38B),
         UnicodeScalar(0x1F38C),
         UnicodeScalar(0x1F38D),
         UnicodeScalar(0x1F38E),
         UnicodeScalar(0x1F38F),
         UnicodeScalar(0x1F390),
         UnicodeScalar(0x1F391),
         UnicodeScalar(0x1F392),
         UnicodeScalar(0x1F393),
         UnicodeScalar(0x1F396),
         UnicodeScalar(0x1F397),
         UnicodeScalar(0x1F399),
         UnicodeScalar(0x1F39A),
         UnicodeScalar(0x1F39B),
         UnicodeScalar(0x1F39E),
         UnicodeScalar(0x1F39F),
         UnicodeScalar(0x1F3A0),
         UnicodeScalar(0x1F3A1),
         UnicodeScalar(0x1F3A2),
         UnicodeScalar(0x1F3A3),
         UnicodeScalar(0x1F3A4),
         UnicodeScalar(0x1F3A5),
         UnicodeScalar(0x1F3A6),
         UnicodeScalar(0x1F3A7),
         UnicodeScalar(0x1F3A8),
         UnicodeScalar(0x1F3A9),
         UnicodeScalar(0x1F3AA),
         UnicodeScalar(0x1F3AB),
         UnicodeScalar(0x1F3AC),
         UnicodeScalar(0x1F3AD),
         UnicodeScalar(0x1F3AE),
         UnicodeScalar(0x1F3AF),
         UnicodeScalar(0x1F3B0),
         UnicodeScalar(0x1F3B1),
         UnicodeScalar(0x1F3B2),
         UnicodeScalar(0x1F3B3),
         UnicodeScalar(0x1F3B4),
         UnicodeScalar(0x1F3B5),
         UnicodeScalar(0x1F3B6),
         UnicodeScalar(0x1F3B7),
         UnicodeScalar(0x1F3B8),
         UnicodeScalar(0x1F3B9),
         UnicodeScalar(0x1F3BA),
         UnicodeScalar(0x1F3BB),
         UnicodeScalar(0x1F3BC),
         UnicodeScalar(0x1F3BD),
         UnicodeScalar(0x1F3BE),
         UnicodeScalar(0x1F3BF),
         UnicodeScalar(0x1F3C0),
         UnicodeScalar(0x1F3C1),
         UnicodeScalar(0x1F3C2),
         UnicodeScalar(0x1F3C3),
         UnicodeScalar(0x1F3C4),
         UnicodeScalar(0x1F3C5),
         UnicodeScalar(0x1F3C6),
         UnicodeScalar(0x1F3C7),
         UnicodeScalar(0x1F3C8),
         UnicodeScalar(0x1F3C9),
         UnicodeScalar(0x1F3CA),
         UnicodeScalar(0x1F3CB),
         UnicodeScalar(0x1F3CC),
         UnicodeScalar(0x1F3CD),
         UnicodeScalar(0x1F3CE),
         UnicodeScalar(0x1F3CF),
         UnicodeScalar(0x1F3D0),
         UnicodeScalar(0x1F3D1),
         UnicodeScalar(0x1F3D2),
         UnicodeScalar(0x1F3D3),
         UnicodeScalar(0x1F3D4),
         UnicodeScalar(0x1F3D5),
         UnicodeScalar(0x1F3D6),
         UnicodeScalar(0x1F3D7),
         UnicodeScalar(0x1F3D8),
         UnicodeScalar(0x1F3D9),
         UnicodeScalar(0x1F3DA),
         UnicodeScalar(0x1F3DB),
         UnicodeScalar(0x1F3DC),
         UnicodeScalar(0x1F3DD),
         UnicodeScalar(0x1F3DE),
         UnicodeScalar(0x1F3DF),
         UnicodeScalar(0x1F3E0),
         UnicodeScalar(0x1F3E1),
         UnicodeScalar(0x1F3E2),
         UnicodeScalar(0x1F3E3),
         UnicodeScalar(0x1F3E4),
         UnicodeScalar(0x1F3E5),
         UnicodeScalar(0x1F3E6),
         UnicodeScalar(0x1F3E7),
         UnicodeScalar(0x1F3E8),
         UnicodeScalar(0x1F3E9),
         UnicodeScalar(0x1F3EA),
         UnicodeScalar(0x1F3EB),
         UnicodeScalar(0x1F3EC),
         UnicodeScalar(0x1F3ED),
         UnicodeScalar(0x1F3EE),
         UnicodeScalar(0x1F3EF),
         UnicodeScalar(0x1F3F0),
         UnicodeScalar(0x1F3F3),
         UnicodeScalar(0x1F3F4),
         UnicodeScalar(0x1F3F5),
         UnicodeScalar(0x1F3F7),
         UnicodeScalar(0x1F3F8),
         UnicodeScalar(0x1F3F9),
         UnicodeScalar(0x1F3FA),
         UnicodeScalar(0x1F3FB),
         UnicodeScalar(0x1F3FC),
         UnicodeScalar(0x1F3FD),
         UnicodeScalar(0x1F3FE),
         UnicodeScalar(0x1F3FF),
         UnicodeScalar(0x1F400),
         UnicodeScalar(0x1F401),
         UnicodeScalar(0x1F402),
         UnicodeScalar(0x1F403),
         UnicodeScalar(0x1F404),
         UnicodeScalar(0x1F405),
         UnicodeScalar(0x1F406),
         UnicodeScalar(0x1F407),
         UnicodeScalar(0x1F408),
         UnicodeScalar(0x1F409),
         UnicodeScalar(0x1F40A),
         UnicodeScalar(0x1F40B),
         UnicodeScalar(0x1F40C),
         UnicodeScalar(0x1F40D),
         UnicodeScalar(0x1F40E),
         UnicodeScalar(0x1F40F),
         UnicodeScalar(0x1F410),
         UnicodeScalar(0x1F411),
         UnicodeScalar(0x1F412),
         UnicodeScalar(0x1F413),
         UnicodeScalar(0x1F414),
         UnicodeScalar(0x1F415),
         UnicodeScalar(0x1F416),
         UnicodeScalar(0x1F417),
         UnicodeScalar(0x1F418),
         UnicodeScalar(0x1F419),
         UnicodeScalar(0x1F41A),
         UnicodeScalar(0x1F41B),
         UnicodeScalar(0x1F41C),
         UnicodeScalar(0x1F41D),
         UnicodeScalar(0x1F41E),
         UnicodeScalar(0x1F41F),
         UnicodeScalar(0x1F420),
         UnicodeScalar(0x1F421),
         UnicodeScalar(0x1F422),
         UnicodeScalar(0x1F423),
         UnicodeScalar(0x1F424),
         UnicodeScalar(0x1F425),
         UnicodeScalar(0x1F426),
         UnicodeScalar(0x1F427),
         UnicodeScalar(0x1F428),
         UnicodeScalar(0x1F429),
         UnicodeScalar(0x1F42A),
         UnicodeScalar(0x1F42B),
         UnicodeScalar(0x1F42C),
         UnicodeScalar(0x1F42D),
         UnicodeScalar(0x1F42E),
         UnicodeScalar(0x1F42F),
         UnicodeScalar(0x1F430),
         UnicodeScalar(0x1F431),
         UnicodeScalar(0x1F432),
         UnicodeScalar(0x1F433),
         UnicodeScalar(0x1F434),
         UnicodeScalar(0x1F435),
         UnicodeScalar(0x1F436),
         UnicodeScalar(0x1F437),
         UnicodeScalar(0x1F438),
         UnicodeScalar(0x1F439),
         UnicodeScalar(0x1F43A),
         UnicodeScalar(0x1F43B),
         UnicodeScalar(0x1F43C),
         UnicodeScalar(0x1F43D),
         UnicodeScalar(0x1F43E),
         UnicodeScalar(0x1F43F),
         UnicodeScalar(0x1F440),
         UnicodeScalar(0x1F441),
         UnicodeScalar(0x1F442),
         UnicodeScalar(0x1F443),
         UnicodeScalar(0x1F444),
         UnicodeScalar(0x1F445),
         UnicodeScalar(0x1F446),
         UnicodeScalar(0x1F447),
         UnicodeScalar(0x1F448),
         UnicodeScalar(0x1F449),
         UnicodeScalar(0x1F44A),
         UnicodeScalar(0x1F44B),
         UnicodeScalar(0x1F44C),
         UnicodeScalar(0x1F44D),
         UnicodeScalar(0x1F44E),
         UnicodeScalar(0x1F44F),
         UnicodeScalar(0x1F450),
         UnicodeScalar(0x1F451),
         UnicodeScalar(0x1F452),
         UnicodeScalar(0x1F453),
         UnicodeScalar(0x1F454),
         UnicodeScalar(0x1F455),
         UnicodeScalar(0x1F456),
         UnicodeScalar(0x1F457),
         UnicodeScalar(0x1F458),
         UnicodeScalar(0x1F459),
         UnicodeScalar(0x1F45A),
         UnicodeScalar(0x1F45B),
         UnicodeScalar(0x1F45C),
         UnicodeScalar(0x1F45D),
         UnicodeScalar(0x1F45E),
         UnicodeScalar(0x1F45F),
         UnicodeScalar(0x1F460),
         UnicodeScalar(0x1F461),
         UnicodeScalar(0x1F462),
         UnicodeScalar(0x1F463),
         UnicodeScalar(0x1F464),
         UnicodeScalar(0x1F465),
         UnicodeScalar(0x1F466),
         UnicodeScalar(0x1F467),
         UnicodeScalar(0x1F468),
         UnicodeScalar(0x1F469),
         UnicodeScalar(0x1F46A),
         UnicodeScalar(0x1F46B),
         UnicodeScalar(0x1F46C),
         UnicodeScalar(0x1F46D),
         UnicodeScalar(0x1F46E),
         UnicodeScalar(0x1F46F),
         UnicodeScalar(0x1F470),
         UnicodeScalar(0x1F471),
         UnicodeScalar(0x1F472),
         UnicodeScalar(0x1F473),
         UnicodeScalar(0x1F474),
         UnicodeScalar(0x1F475),
         UnicodeScalar(0x1F476),
         UnicodeScalar(0x1F477),
         UnicodeScalar(0x1F478),
         UnicodeScalar(0x1F479),
         UnicodeScalar(0x1F47A),
         UnicodeScalar(0x1F47B),
         UnicodeScalar(0x1F47C),
         UnicodeScalar(0x1F47D),
         UnicodeScalar(0x1F47E),
         UnicodeScalar(0x1F47F),
         UnicodeScalar(0x1F480),
         UnicodeScalar(0x1F481),
         UnicodeScalar(0x1F482),
         UnicodeScalar(0x1F483),
         UnicodeScalar(0x1F484),
         UnicodeScalar(0x1F485),
         UnicodeScalar(0x1F486),
         UnicodeScalar(0x1F487),
         UnicodeScalar(0x1F488),
         UnicodeScalar(0x1F489),
         UnicodeScalar(0x1F48A),
         UnicodeScalar(0x1F48B),
         UnicodeScalar(0x1F48C),
         UnicodeScalar(0x1F48D),
         UnicodeScalar(0x1F48E),
         UnicodeScalar(0x1F48F),
         UnicodeScalar(0x1F490),
         UnicodeScalar(0x1F491),
         UnicodeScalar(0x1F492),
         UnicodeScalar(0x1F493),
         UnicodeScalar(0x1F494),
         UnicodeScalar(0x1F495),
         UnicodeScalar(0x1F496),
         UnicodeScalar(0x1F497),
         UnicodeScalar(0x1F498),
         UnicodeScalar(0x1F499),
         UnicodeScalar(0x1F49A),
         UnicodeScalar(0x1F49B),
         UnicodeScalar(0x1F49C),
         UnicodeScalar(0x1F49D),
         UnicodeScalar(0x1F49E),
         UnicodeScalar(0x1F49F),
         UnicodeScalar(0x1F4A0),
         UnicodeScalar(0x1F4A1),
         UnicodeScalar(0x1F4A2),
         UnicodeScalar(0x1F4A3),
         UnicodeScalar(0x1F4A4),
         UnicodeScalar(0x1F4A5),
         UnicodeScalar(0x1F4A6),
         UnicodeScalar(0x1F4A7),
         UnicodeScalar(0x1F4A8),
         UnicodeScalar(0x1F4A9),
         UnicodeScalar(0x1F4AA),
         UnicodeScalar(0x1F4AB),
         UnicodeScalar(0x1F4AC),
         UnicodeScalar(0x1F4AD),
         UnicodeScalar(0x1F4AE),
         UnicodeScalar(0x1F4AF),
         UnicodeScalar(0x1F4B0),
         UnicodeScalar(0x1F4B1),
         UnicodeScalar(0x1F4B2),
         UnicodeScalar(0x1F4B3),
         UnicodeScalar(0x1F4B4),
         UnicodeScalar(0x1F4B5),
         UnicodeScalar(0x1F4B6),
         UnicodeScalar(0x1F4B7),
         UnicodeScalar(0x1F4B8),
         UnicodeScalar(0x1F4B9),
         UnicodeScalar(0x1F4BA),
         UnicodeScalar(0x1F4BB),
         UnicodeScalar(0x1F4BC),
         UnicodeScalar(0x1F4BD),
         UnicodeScalar(0x1F4BE),
         UnicodeScalar(0x1F4BF),
         UnicodeScalar(0x1F4C0),
         UnicodeScalar(0x1F4C1),
         UnicodeScalar(0x1F4C2),
         UnicodeScalar(0x1F4C3),
         UnicodeScalar(0x1F4C4),
         UnicodeScalar(0x1F4C5),
         UnicodeScalar(0x1F4C6),
         UnicodeScalar(0x1F4C7),
         UnicodeScalar(0x1F4C8),
         UnicodeScalar(0x1F4C9),
         UnicodeScalar(0x1F4CA),
         UnicodeScalar(0x1F4CB),
         UnicodeScalar(0x1F4CC),
         UnicodeScalar(0x1F4CD),
         UnicodeScalar(0x1F4CE),
         UnicodeScalar(0x1F4CF),
         UnicodeScalar(0x1F4D0),
         UnicodeScalar(0x1F4D1),
         UnicodeScalar(0x1F4D2),
         UnicodeScalar(0x1F4D3),
         UnicodeScalar(0x1F4D4),
         UnicodeScalar(0x1F4D5),
         UnicodeScalar(0x1F4D6),
         UnicodeScalar(0x1F4D7),
         UnicodeScalar(0x1F4D8),
         UnicodeScalar(0x1F4D9),
         UnicodeScalar(0x1F4DA),
         UnicodeScalar(0x1F4DB),
         UnicodeScalar(0x1F4DC),
         UnicodeScalar(0x1F4DD),
         UnicodeScalar(0x1F4DE),
         UnicodeScalar(0x1F4DF),
         UnicodeScalar(0x1F4E0),
         UnicodeScalar(0x1F4E1),
         UnicodeScalar(0x1F4E2),
         UnicodeScalar(0x1F4E3),
         UnicodeScalar(0x1F4E4),
         UnicodeScalar(0x1F4E5),
         UnicodeScalar(0x1F4E6),
         UnicodeScalar(0x1F4E7),
         UnicodeScalar(0x1F4E8),
         UnicodeScalar(0x1F4E9),
         UnicodeScalar(0x1F4EA),
         UnicodeScalar(0x1F4EB),
         UnicodeScalar(0x1F4EC),
         UnicodeScalar(0x1F4ED),
         UnicodeScalar(0x1F4EE),
         UnicodeScalar(0x1F4EF),
         UnicodeScalar(0x1F4F0),
         UnicodeScalar(0x1F4F1),
         UnicodeScalar(0x1F4F2),
         UnicodeScalar(0x1F4F3),
         UnicodeScalar(0x1F4F4),
         UnicodeScalar(0x1F4F5),
         UnicodeScalar(0x1F4F6),
         UnicodeScalar(0x1F4F7),
         UnicodeScalar(0x1F4F8),
         UnicodeScalar(0x1F4F9),
         UnicodeScalar(0x1F4FA),
         UnicodeScalar(0x1F4FB),
         UnicodeScalar(0x1F4FC),
         UnicodeScalar(0x1F4FD),
         UnicodeScalar(0x1F4FF),
         UnicodeScalar(0x1F500),
         UnicodeScalar(0x1F501),
         UnicodeScalar(0x1F502),
         UnicodeScalar(0x1F503),
         UnicodeScalar(0x1F504),
         UnicodeScalar(0x1F505),
         UnicodeScalar(0x1F506),
         UnicodeScalar(0x1F507),
         UnicodeScalar(0x1F508),
         UnicodeScalar(0x1F509),
         UnicodeScalar(0x1F50A),
         UnicodeScalar(0x1F50B),
         UnicodeScalar(0x1F50C),
         UnicodeScalar(0x1F50D),
         UnicodeScalar(0x1F50E),
         UnicodeScalar(0x1F50F),
         UnicodeScalar(0x1F510),
         UnicodeScalar(0x1F511),
         UnicodeScalar(0x1F512),
         UnicodeScalar(0x1F513),
         UnicodeScalar(0x1F514),
         UnicodeScalar(0x1F515),
         UnicodeScalar(0x1F516),
         UnicodeScalar(0x1F517),
         UnicodeScalar(0x1F518),
         UnicodeScalar(0x1F519),
         UnicodeScalar(0x1F51A),
         UnicodeScalar(0x1F51B),
         UnicodeScalar(0x1F51C),
         UnicodeScalar(0x1F51D),
         UnicodeScalar(0x1F51E),
         UnicodeScalar(0x1F51F),
         UnicodeScalar(0x1F520),
         UnicodeScalar(0x1F521),
         UnicodeScalar(0x1F522),
         UnicodeScalar(0x1F523),
         UnicodeScalar(0x1F524),
         UnicodeScalar(0x1F525),
         UnicodeScalar(0x1F526),
         UnicodeScalar(0x1F527),
         UnicodeScalar(0x1F528),
         UnicodeScalar(0x1F529),
         UnicodeScalar(0x1F52A),
         UnicodeScalar(0x1F52B),
         UnicodeScalar(0x1F52C),
         UnicodeScalar(0x1F52D),
         UnicodeScalar(0x1F52E),
         UnicodeScalar(0x1F52F),
         UnicodeScalar(0x1F530),
         UnicodeScalar(0x1F531),
         UnicodeScalar(0x1F532),
         UnicodeScalar(0x1F533),
         UnicodeScalar(0x1F534),
         UnicodeScalar(0x1F535),
         UnicodeScalar(0x1F536),
         UnicodeScalar(0x1F537),
         UnicodeScalar(0x1F538),
         UnicodeScalar(0x1F539),
         UnicodeScalar(0x1F53A),
         UnicodeScalar(0x1F53B),
         UnicodeScalar(0x1F53C),
         UnicodeScalar(0x1F53D),
         UnicodeScalar(0x1F549),
         UnicodeScalar(0x1F54A),
         UnicodeScalar(0x1F54B),
         UnicodeScalar(0x1F54C),
         UnicodeScalar(0x1F54D),
         UnicodeScalar(0x1F54E),
         UnicodeScalar(0x1F550),
         UnicodeScalar(0x1F551),
         UnicodeScalar(0x1F552),
         UnicodeScalar(0x1F553),
         UnicodeScalar(0x1F554),
         UnicodeScalar(0x1F555),
         UnicodeScalar(0x1F556),
         UnicodeScalar(0x1F557),
         UnicodeScalar(0x1F558),
         UnicodeScalar(0x1F559),
         UnicodeScalar(0x1F55A),
         UnicodeScalar(0x1F55B),
         UnicodeScalar(0x1F55C),
         UnicodeScalar(0x1F55D),
         UnicodeScalar(0x1F55E),
         UnicodeScalar(0x1F55F),
         UnicodeScalar(0x1F560),
         UnicodeScalar(0x1F561),
         UnicodeScalar(0x1F562),
         UnicodeScalar(0x1F563),
         UnicodeScalar(0x1F564),
         UnicodeScalar(0x1F565),
         UnicodeScalar(0x1F566),
         UnicodeScalar(0x1F567),
         UnicodeScalar(0x1F56F),
         UnicodeScalar(0x1F570),
         UnicodeScalar(0x1F573),
         UnicodeScalar(0x1F574),
         UnicodeScalar(0x1F575),
         UnicodeScalar(0x1F576),
         UnicodeScalar(0x1F577),
         UnicodeScalar(0x1F578),
         UnicodeScalar(0x1F579),
         UnicodeScalar(0x1F57A),
         UnicodeScalar(0x1F587),
         UnicodeScalar(0x1F58A),
         UnicodeScalar(0x1F58B),
         UnicodeScalar(0x1F58C),
         UnicodeScalar(0x1F58D),
         UnicodeScalar(0x1F590),
         UnicodeScalar(0x1F595),
         UnicodeScalar(0x1F596),
         UnicodeScalar(0x1F5A4),
         UnicodeScalar(0x1F5A5),
         UnicodeScalar(0x1F5A8),
         UnicodeScalar(0x1F5B1),
         UnicodeScalar(0x1F5B2),
         UnicodeScalar(0x1F5BC),
         UnicodeScalar(0x1F5C2),
         UnicodeScalar(0x1F5C3),
         UnicodeScalar(0x1F5C4),
         UnicodeScalar(0x1F5D1),
         UnicodeScalar(0x1F5D2),
         UnicodeScalar(0x1F5D3),
         UnicodeScalar(0x1F5DC),
         UnicodeScalar(0x1F5DD),
         UnicodeScalar(0x1F5DE),
         UnicodeScalar(0x1F5E1),
         UnicodeScalar(0x1F5E3),
         UnicodeScalar(0x1F5E8),
         UnicodeScalar(0x1F5EF),
         UnicodeScalar(0x1F5F3),
         UnicodeScalar(0x1F5FA),
         UnicodeScalar(0x1F5FB),
         UnicodeScalar(0x1F5FC),
         UnicodeScalar(0x1F5FD),
         UnicodeScalar(0x1F5FE),
         UnicodeScalar(0x1F5FF),
         UnicodeScalar(0x1F600),
         UnicodeScalar(0x1F601),
         UnicodeScalar(0x1F602),
         UnicodeScalar(0x1F603),
         UnicodeScalar(0x1F604),
         UnicodeScalar(0x1F605),
         UnicodeScalar(0x1F606),
         UnicodeScalar(0x1F607),
         UnicodeScalar(0x1F608),
         UnicodeScalar(0x1F609),
         UnicodeScalar(0x1F60A),
         UnicodeScalar(0x1F60B),
         UnicodeScalar(0x1F60C),
         UnicodeScalar(0x1F60D),
         UnicodeScalar(0x1F60E),
         UnicodeScalar(0x1F60F),
         UnicodeScalar(0x1F610),
         UnicodeScalar(0x1F611),
         UnicodeScalar(0x1F612),
         UnicodeScalar(0x1F613),
         UnicodeScalar(0x1F614),
         UnicodeScalar(0x1F615),
         UnicodeScalar(0x1F616),
         UnicodeScalar(0x1F617),
         UnicodeScalar(0x1F618),
         UnicodeScalar(0x1F619),
         UnicodeScalar(0x1F61A),
         UnicodeScalar(0x1F61B),
         UnicodeScalar(0x1F61C),
         UnicodeScalar(0x1F61D),
         UnicodeScalar(0x1F61E),
         UnicodeScalar(0x1F61F),
         UnicodeScalar(0x1F620),
         UnicodeScalar(0x1F621),
         UnicodeScalar(0x1F622),
         UnicodeScalar(0x1F623),
         UnicodeScalar(0x1F624),
         UnicodeScalar(0x1F625),
         UnicodeScalar(0x1F626),
         UnicodeScalar(0x1F627),
         UnicodeScalar(0x1F628),
         UnicodeScalar(0x1F629),
         UnicodeScalar(0x1F62A),
         UnicodeScalar(0x1F62B),
         UnicodeScalar(0x1F62C),
         UnicodeScalar(0x1F62D),
         UnicodeScalar(0x1F62E),
         UnicodeScalar(0x1F62F),
         UnicodeScalar(0x1F630),
         UnicodeScalar(0x1F631),
         UnicodeScalar(0x1F632),
         UnicodeScalar(0x1F633),
         UnicodeScalar(0x1F634),
         UnicodeScalar(0x1F635),
         UnicodeScalar(0x1F636),
         UnicodeScalar(0x1F637),
         UnicodeScalar(0x1F638),
         UnicodeScalar(0x1F639),
         UnicodeScalar(0x1F63A),
         UnicodeScalar(0x1F63B),
         UnicodeScalar(0x1F63C),
         UnicodeScalar(0x1F63D),
         UnicodeScalar(0x1F63E),
         UnicodeScalar(0x1F63F),
         UnicodeScalar(0x1F640),
         UnicodeScalar(0x1F641),
         UnicodeScalar(0x1F642),
         UnicodeScalar(0x1F643),
         UnicodeScalar(0x1F644),
         UnicodeScalar(0x1F645),
         UnicodeScalar(0x1F646),
         UnicodeScalar(0x1F647),
         UnicodeScalar(0x1F648),
         UnicodeScalar(0x1F649),
         UnicodeScalar(0x1F64A),
         UnicodeScalar(0x1F64B),
         UnicodeScalar(0x1F64C),
         UnicodeScalar(0x1F64D),
         UnicodeScalar(0x1F64E),
         UnicodeScalar(0x1F64F),
         UnicodeScalar(0x1F680),
         UnicodeScalar(0x1F681),
         UnicodeScalar(0x1F682),
         UnicodeScalar(0x1F683),
         UnicodeScalar(0x1F684),
         UnicodeScalar(0x1F685),
         UnicodeScalar(0x1F686),
         UnicodeScalar(0x1F687),
         UnicodeScalar(0x1F688),
         UnicodeScalar(0x1F689),
         UnicodeScalar(0x1F68A),
         UnicodeScalar(0x1F68B),
         UnicodeScalar(0x1F68C),
         UnicodeScalar(0x1F68D),
         UnicodeScalar(0x1F68E),
         UnicodeScalar(0x1F68F),
         UnicodeScalar(0x1F690),
         UnicodeScalar(0x1F691),
         UnicodeScalar(0x1F692),
         UnicodeScalar(0x1F693),
         UnicodeScalar(0x1F694),
         UnicodeScalar(0x1F695),
         UnicodeScalar(0x1F696),
         UnicodeScalar(0x1F697),
         UnicodeScalar(0x1F698),
         UnicodeScalar(0x1F699),
         UnicodeScalar(0x1F69A),
         UnicodeScalar(0x1F69B),
         UnicodeScalar(0x1F69C),
         UnicodeScalar(0x1F69D),
         UnicodeScalar(0x1F69E),
         UnicodeScalar(0x1F69F),
         UnicodeScalar(0x1F6A0),
         UnicodeScalar(0x1F6A1),
         UnicodeScalar(0x1F6A2),
         UnicodeScalar(0x1F6A3),
         UnicodeScalar(0x1F6A4),
         UnicodeScalar(0x1F6A5),
         UnicodeScalar(0x1F6A6),
         UnicodeScalar(0x1F6A7),
         UnicodeScalar(0x1F6A8),
         UnicodeScalar(0x1F6A9),
         UnicodeScalar(0x1F6AA),
         UnicodeScalar(0x1F6AB),
         UnicodeScalar(0x1F6AC),
         UnicodeScalar(0x1F6AD),
         UnicodeScalar(0x1F6AE),
         UnicodeScalar(0x1F6AF),
         UnicodeScalar(0x1F6B0),
         UnicodeScalar(0x1F6B1),
         UnicodeScalar(0x1F6B2),
         UnicodeScalar(0x1F6B3),
         UnicodeScalar(0x1F6B4),
         UnicodeScalar(0x1F6B5),
         UnicodeScalar(0x1F6B6),
         UnicodeScalar(0x1F6B7),
         UnicodeScalar(0x1F6B8),
         UnicodeScalar(0x1F6B9),
         UnicodeScalar(0x1F6BA),
         UnicodeScalar(0x1F6BB),
         UnicodeScalar(0x1F6BC),
         UnicodeScalar(0x1F6BD),
         UnicodeScalar(0x1F6BE),
         UnicodeScalar(0x1F6BF),
         UnicodeScalar(0x1F6C0),
         UnicodeScalar(0x1F6C1),
         UnicodeScalar(0x1F6C2),
         UnicodeScalar(0x1F6C3),
         UnicodeScalar(0x1F6C4),
         UnicodeScalar(0x1F6C5),
         UnicodeScalar(0x1F6CB),
         UnicodeScalar(0x1F6CC),
         UnicodeScalar(0x1F6CD),
         UnicodeScalar(0x1F6CE),
         UnicodeScalar(0x1F6CF),
         UnicodeScalar(0x1F6D0),
         UnicodeScalar(0x1F6D1),
         UnicodeScalar(0x1F6D2),
         UnicodeScalar(0x1F6E0),
         UnicodeScalar(0x1F6E1),
         UnicodeScalar(0x1F6E2),
         UnicodeScalar(0x1F6E3),
         UnicodeScalar(0x1F6E4),
         UnicodeScalar(0x1F6E5),
         UnicodeScalar(0x1F6E9),
         UnicodeScalar(0x1F6EB),
         UnicodeScalar(0x1F6EC),
         UnicodeScalar(0x1F6F0),
         UnicodeScalar(0x1F6F3),
         UnicodeScalar(0x1F6F4),
         UnicodeScalar(0x1F6F5),
         UnicodeScalar(0x1F6F6),
         UnicodeScalar(0x1F910),
         UnicodeScalar(0x1F911),
         UnicodeScalar(0x1F912),
         UnicodeScalar(0x1F913),
         UnicodeScalar(0x1F914),
         UnicodeScalar(0x1F915),
         UnicodeScalar(0x1F916),
         UnicodeScalar(0x1F917),
         UnicodeScalar(0x1F918),
         UnicodeScalar(0x1F919),
         UnicodeScalar(0x1F91A),
         UnicodeScalar(0x1F91B),
         UnicodeScalar(0x1F91C),
         UnicodeScalar(0x1F91D),
         UnicodeScalar(0x1F91E),
         UnicodeScalar(0x1F920),
         UnicodeScalar(0x1F921),
         UnicodeScalar(0x1F922),
         UnicodeScalar(0x1F923),
         UnicodeScalar(0x1F924),
         UnicodeScalar(0x1F925),
         UnicodeScalar(0x1F926),
         UnicodeScalar(0x1F927),
         UnicodeScalar(0x1F930),
         UnicodeScalar(0x1F933),
         UnicodeScalar(0x1F934),
         UnicodeScalar(0x1F935),
         UnicodeScalar(0x1F936),
         UnicodeScalar(0x1F937),
         UnicodeScalar(0x1F938),
         UnicodeScalar(0x1F939),
         UnicodeScalar(0x1F93A),
         UnicodeScalar(0x1F93C),
         UnicodeScalar(0x1F93D),
         UnicodeScalar(0x1F93E),
         UnicodeScalar(0x1F940),
         UnicodeScalar(0x1F941),
         UnicodeScalar(0x1F942),
         UnicodeScalar(0x1F943),
         UnicodeScalar(0x1F944),
         UnicodeScalar(0x1F945),
         UnicodeScalar(0x1F947),
         UnicodeScalar(0x1F948),
         UnicodeScalar(0x1F949),
         UnicodeScalar(0x1F94A),
         UnicodeScalar(0x1F94B),
         UnicodeScalar(0x1F950),
         UnicodeScalar(0x1F951),
         UnicodeScalar(0x1F952),
         UnicodeScalar(0x1F953),
         UnicodeScalar(0x1F954),
         UnicodeScalar(0x1F955),
         UnicodeScalar(0x1F956),
         UnicodeScalar(0x1F957),
         UnicodeScalar(0x1F958),
         UnicodeScalar(0x1F959),
         UnicodeScalar(0x1F95A),
         UnicodeScalar(0x1F95B),
         UnicodeScalar(0x1F95C),
         UnicodeScalar(0x1F95D),
         UnicodeScalar(0x1F95E),
         UnicodeScalar(0x1F980),
         UnicodeScalar(0x1F981),
         UnicodeScalar(0x1F982),
         UnicodeScalar(0x1F983),
         UnicodeScalar(0x1F984),
         UnicodeScalar(0x1F985),
         UnicodeScalar(0x1F986),
         UnicodeScalar(0x1F987),
         UnicodeScalar(0x1F988),
         UnicodeScalar(0x1F989),
         UnicodeScalar(0x1F98A),
         UnicodeScalar(0x1F98B),
         UnicodeScalar(0x1F98C),
         UnicodeScalar(0x1F98D),
         UnicodeScalar(0x1F98E),
         UnicodeScalar(0x1F98F),
         UnicodeScalar(0x1F990),
         UnicodeScalar(0x1F991),
         UnicodeScalar(0x1F9C0),
         UnicodeScalar(0x200D),
         UnicodeScalar(0x203C),
         UnicodeScalar(0x2049),
         UnicodeScalar(0x20E3),
         UnicodeScalar(0x2122),
         UnicodeScalar(0x2139),
         UnicodeScalar(0x2194),
         UnicodeScalar(0x2195),
         UnicodeScalar(0x2196),
         UnicodeScalar(0x2197),
         UnicodeScalar(0x2198),
         UnicodeScalar(0x2199),
         UnicodeScalar(0x21A9),
         UnicodeScalar(0x21AA),
         UnicodeScalar(0x231A),
         UnicodeScalar(0x231B),
         UnicodeScalar(0x2328),
         UnicodeScalar(0x23CF),
         UnicodeScalar(0x23E9),
         UnicodeScalar(0x23EA),
         UnicodeScalar(0x23EB),
         UnicodeScalar(0x23EC),
         UnicodeScalar(0x23ED),
         UnicodeScalar(0x23EE),
         UnicodeScalar(0x23EF),
         UnicodeScalar(0x23F0),
         UnicodeScalar(0x23F1),
         UnicodeScalar(0x23F2),
         UnicodeScalar(0x23F3),
         UnicodeScalar(0x23F8),
         UnicodeScalar(0x23F9),
         UnicodeScalar(0x23FA),
         UnicodeScalar(0x24C2),
         UnicodeScalar(0x25AA),
         UnicodeScalar(0x25AB),
         UnicodeScalar(0x25B6),
         UnicodeScalar(0x25C0),
         UnicodeScalar(0x25FB),
         UnicodeScalar(0x25FC),
         UnicodeScalar(0x25FD),
         UnicodeScalar(0x25FE),
         UnicodeScalar(0x2600),
         UnicodeScalar(0x2601),
         UnicodeScalar(0x2602),
         UnicodeScalar(0x2603),
         UnicodeScalar(0x2604),
         UnicodeScalar(0x260E),
         UnicodeScalar(0x2611),
         UnicodeScalar(0x2614),
         UnicodeScalar(0x2615),
         UnicodeScalar(0x2618),
         UnicodeScalar(0x261D),
         UnicodeScalar(0x2620),
         UnicodeScalar(0x2622),
         UnicodeScalar(0x2623),
         UnicodeScalar(0x2626),
         UnicodeScalar(0x262A),
         UnicodeScalar(0x262E),
         UnicodeScalar(0x262F),
         UnicodeScalar(0x2638),
         UnicodeScalar(0x2639),
         UnicodeScalar(0x263A),
         UnicodeScalar(0x2648),
         UnicodeScalar(0x2649),
         UnicodeScalar(0x264A),
         UnicodeScalar(0x264B),
         UnicodeScalar(0x264C),
         UnicodeScalar(0x264D),
         UnicodeScalar(0x264E),
         UnicodeScalar(0x264F),
         UnicodeScalar(0x2650),
         UnicodeScalar(0x2651),
         UnicodeScalar(0x2652),
         UnicodeScalar(0x2653),
         UnicodeScalar(0x2660),
         UnicodeScalar(0x2663),
         UnicodeScalar(0x2665),
         UnicodeScalar(0x2666),
         UnicodeScalar(0x2668),
         UnicodeScalar(0x267B),
         UnicodeScalar(0x267F),
         UnicodeScalar(0x2692),
         UnicodeScalar(0x2693),
         UnicodeScalar(0x2694),
         UnicodeScalar(0x2696),
         UnicodeScalar(0x2697),
         UnicodeScalar(0x2699),
         UnicodeScalar(0x269B),
         UnicodeScalar(0x269C),
         UnicodeScalar(0x26A0),
         UnicodeScalar(0x26A1),
         UnicodeScalar(0x26AA),
         UnicodeScalar(0x26AB),
         UnicodeScalar(0x26B0),
         UnicodeScalar(0x26B1),
         UnicodeScalar(0x26BD),
         UnicodeScalar(0x26BE),
         UnicodeScalar(0x26C4),
         UnicodeScalar(0x26C5),
         UnicodeScalar(0x26C8),
         UnicodeScalar(0x26CE),
         UnicodeScalar(0x26CF),
         UnicodeScalar(0x26D1),
         UnicodeScalar(0x26D3),
         UnicodeScalar(0x26D4),
         UnicodeScalar(0x26E9),
         UnicodeScalar(0x26EA),
         UnicodeScalar(0x26F0),
         UnicodeScalar(0x26F1),
         UnicodeScalar(0x26F2),
         UnicodeScalar(0x26F3),
         UnicodeScalar(0x26F4),
         UnicodeScalar(0x26F5),
         UnicodeScalar(0x26F7),
         UnicodeScalar(0x26F8),
         UnicodeScalar(0x26F9),
         UnicodeScalar(0x26FA),
         UnicodeScalar(0x26FD),
         UnicodeScalar(0x2702),
         UnicodeScalar(0x2705),
         UnicodeScalar(0x2708),
         UnicodeScalar(0x2709),
         UnicodeScalar(0x270A),
         UnicodeScalar(0x270B),
         UnicodeScalar(0x270C),
         UnicodeScalar(0x270D),
         UnicodeScalar(0x270F),
         UnicodeScalar(0x2712),
         UnicodeScalar(0x2714),
         UnicodeScalar(0x2716),
         UnicodeScalar(0x271D),
         UnicodeScalar(0x2721),
         UnicodeScalar(0x2728),
         UnicodeScalar(0x2733),
         UnicodeScalar(0x2734),
         UnicodeScalar(0x2744),
         UnicodeScalar(0x2747),
         UnicodeScalar(0x274C),
         UnicodeScalar(0x274E),
         UnicodeScalar(0x2753),
         UnicodeScalar(0x2754),
         UnicodeScalar(0x2755),
         UnicodeScalar(0x2757),
         UnicodeScalar(0x2763),
         UnicodeScalar(0x2764),
         UnicodeScalar(0x2795),
         UnicodeScalar(0x2796),
         UnicodeScalar(0x2797),
         UnicodeScalar(0x27A1),
         UnicodeScalar(0x27B0),
         UnicodeScalar(0x27BF),
         UnicodeScalar(0x2934),
         UnicodeScalar(0x2935),
         UnicodeScalar(0x2B05),
         UnicodeScalar(0x2B06),
         UnicodeScalar(0x2B07),
         UnicodeScalar(0x2B1B),
         UnicodeScalar(0x2B1C),
         UnicodeScalar(0x2B50),
         UnicodeScalar(0x2B55),
         UnicodeScalar(0x3030),
         UnicodeScalar(0x303D),
         UnicodeScalar(0x3297),
         UnicodeScalar(0x3299),
         UnicodeScalar(0xFE0F)]
}
