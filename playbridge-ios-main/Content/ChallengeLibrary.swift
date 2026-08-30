//
//  ChallengeLibrary.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import Foundation

/// Elle yazılmış çizim görevi havuzu — 6 kategori × 5 yaş kademesi.
///
/// Neden model değil de sabit liste? Çünkü bu özellik SUNUCUSUZ ve
/// ANAHTARSIZ çalışabilmeli. 180 görev, haftada 3 çizimle bir yıldan
/// fazla eder; model üretimi ancak görevler bayatlamaya başladığında
/// gerekir ve o zaman da yalnızca METİN üretir — fotoğraf hiçbir
/// koşulda cihazdan çıkmaz.
///
/// Kademelerin mantığı: 3-4 tek bir nesne ister, 5-6 nesneye bir tuhaflık
/// ekler, 7-8 bir sahne ya da kural verir, 9-10 sonuç/mantık ister,
/// 11-12 gerçek bir KISIT koyar. 12 yaşındaki bir çocuğa "bir ev çiz"
/// demek onu kaybetmenin en hızlı yolu.
enum ChallengeLibrary {

    static let pool: [AgeTier: [SketchCategory: [String]]] = [
        .tier3to4: [
            .creature: [
                "Draw a happy fish.",
                "Draw a cat.",
                "Draw a bird with big wings.",
                "Draw a bug with lots of legs.",
                "Draw a dog running.",
                "Draw a snake.",
            ],
            .machine: [
                "Draw a car.",
                "Draw a train.",
                "Draw a boat.",
                "Draw a plane.",
                "Draw a big truck.",
                "Draw a bicycle.",
            ],
            .place: [
                "Draw a house.",
                "Draw a big tree.",
                "Draw the sun and some clouds.",
                "Draw a park.",
                "Draw a mountain.",
                "Draw a long road.",
            ],
            .invention: [
                "Draw your own hat.",
                "Draw a magic spoon.",
                "Draw a new kind of cup.",
                "Draw a special shoe.",
                "Draw a toy nobody has.",
                "Draw a bag that holds everything.",
            ],
            .story: [
                "Draw your favourite toy.",
                "Draw someone smiling.",
                "Draw a birthday cake.",
                "Draw two friends.",
                "Draw someone jumping.",
                "Draw a present.",
            ],
            .portrait: [
                "Draw yourself.",
                "Draw someone in your family.",
                "Draw a happy face.",
                "Draw a face with big eyes.",
                "Draw someone with funny hair.",
                "Draw a face wearing glasses.",
            ],
        ],

        .tier5to6: [
            .creature: [
                "Draw an animal with five legs.",
                "Draw a fish that lives in a tree.",
                "Draw an animal made of two other animals.",
                "Draw a creature that is afraid of the dark.",
                "Draw an animal with a very long tail.",
                "Draw a bird that cannot fly.",
            ],
            .machine: [
                "Draw a car that can fly.",
                "Draw a machine that makes a lot of noise.",
                "Draw a boat with a house on it.",
                "Draw a robot with three arms.",
                "Draw a train that goes underwater.",
                "Draw a machine with wheels and wings.",
            ],
            .place: [
                "Draw a house above the clouds.",
                "Draw a park where everything is upside down.",
                "Draw a house with a slide instead of stairs.",
                "Draw a forest at night.",
                "Draw an island with one tree on it.",
                "Draw a room made of candy.",
            ],
            .invention: [
                "Draw a machine that wakes you up.",
                "Draw a hat that does something useful.",
                "Draw shoes that take you anywhere.",
                "Draw an umbrella with a surprise inside.",
                "Draw a pencil that draws by itself.",
                "Draw a box that is bigger on the inside.",
            ],
            .story: [
                "Draw someone who lost something.",
                "Draw a surprise nobody expected.",
                "Draw someone hiding.",
                "Draw two friends who disagree.",
                "Draw the moment before a race starts.",
                "Draw someone who just heard good news.",
            ],
            .portrait: [
                "Draw yourself at a hundred years old.",
                "Draw yourself as an animal.",
                "Draw someone you would like to meet.",
                "Draw a face trying not to laugh.",
                "Draw yourself doing your favourite thing.",
                "Draw someone from a dream.",
            ],
        ],

        .tier7to8: [
            .creature: [
                "Draw a creature that lives in the dark.",
                "Draw an animal nobody has ever seen.",
                "Draw a creature that eats only one thing.",
                "Draw an animal that changes colour.",
                "Draw a creature that lives underwater and hates water.",
                "Draw an animal that sleeps standing up.",
            ],
            .machine: [
                "Draw a machine that does a chore for you.",
                "Draw a robot that is afraid of something.",
                "Draw a vehicle for a place with no roads.",
                "Draw a machine that only works at night.",
                "Draw a machine that turns something small into something big.",
                "Draw a robot with one job that it does badly.",
            ],
            .place: [
                "Draw a city nobody knows about.",
                "Draw a place where it rains every single day.",
                "Draw a room that belongs to someone you invent.",
                "Draw a place hidden under your street.",
                "Draw a town built on water.",
                "Draw a place that used to be busy and is now empty.",
            ],
            .invention: [
                "Draw a gadget that does your homework — give it one flaw.",
                "Draw an invention for someone who is always cold.",
                "Draw a tool that finds lost things.",
                "Draw an invention that helps you fall asleep.",
                "Draw a device that makes one chore disappear.",
                "Draw an invention for someone with no hands free.",
            ],
            .story: [
                "Draw the moment something went wrong.",
                "Draw a secret being told.",
                "Draw someone who has been waiting a long time.",
                "Draw the end of a story you make up.",
                "Draw someone deciding between two things.",
                "Draw a goodbye.",
            ],
            .portrait: [
                "Draw someone you know without looking at them.",
                "Draw a face that is hiding something.",
                "Draw yourself in ten years.",
                "Draw someone who has just woken up.",
                "Draw a face showing two feelings at once.",
                "Draw someone as they were when they were small.",
            ],
        ],

        .tier9to10: [
            .creature: [
                "Draw a creature and show how it eats.",
                "Draw an animal built for a place with no light.",
                "Draw a creature whose body explains where it lives.",
                "Draw an animal that hunts something bigger than itself.",
                "Draw a creature with a weakness you can see.",
                "Draw an animal that survives without water.",
            ],
            .machine: [
                "Draw a machine made of only three parts.",
                "Draw a vehicle that carries something unusual.",
                "Draw a machine and mark the part that breaks first.",
                "Draw a robot designed for a job nobody wants.",
                "Draw a machine that needs two people to work.",
                "Draw a vehicle that moves without an engine.",
            ],
            .place: [
                "Draw a city using only triangles.",
                "Draw a place before and after something happened.",
                "Draw a map of a place you invent, with names on it.",
                "Draw a room and show who lives there without drawing them.",
                "Draw a place that is beautiful and dangerous at the same time.",
                "Draw a building for a planet with heavy gravity.",
            ],
            .invention: [
                "Draw an invention that solves a problem and creates a new one.",
                "Draw a tool only one person in the world would need.",
                "Draw an invention with a warning label.",
                "Draw a device that works only once.",
                "Draw an invention that would be banned.",
                "Draw a tool for a job that does not exist yet.",
            ],
            .story: [
                "Draw the beginning and the end of a story in two frames.",
                "Draw a scene where nobody is talking.",
                "Draw the moment of relief right after fear.",
                "Draw a room that shows an argument just happened.",
                "Draw someone about to make a mistake.",
                "Draw a scene where the weather matches the mood.",
            ],
            .portrait: [
                "Draw a person using only their belongings — no face.",
                "Draw someone's hands instead of their face.",
                "Draw yourself the way someone else would draw you.",
                "Draw a face where only the eyes are finished.",
                "Draw a person from behind and make them recognisable.",
                "Draw someone at the exact moment they change their mind.",
            ],
        ],

        .tier11to12: [
            .creature: [
                "Draw a creature and label three parts, each with a purpose.",
                "Draw an animal that evolved from something in your room.",
                "Draw a creature using only circles.",
                "Draw two animals of the same species at different ages.",
                "Draw a creature whose design solves a problem you name.",
                "Draw an animal from memory, then add one thing that could not be real.",
            ],
            .machine: [
                "Draw a machine and label how it works, step by step.",
                "Draw a machine that solves one problem and causes another.",
                "Draw a vehicle using only straight lines.",
                "Draw a machine from the inside, not the outside.",
                "Draw a device that will be useless in a hundred years.",
                "Draw a machine with a serious flaw you can point to.",
            ],
            .place: [
                "Draw a place from above as a map, then mark one secret.",
                "Draw a street using only straight lines and one curve.",
                "Draw a place at two different times of day, side by side.",
                "Draw a building whose shape explains its purpose.",
                "Draw a city that was designed by mistake.",
                "Draw a landscape without drawing the sky.",
            ],
            .invention: [
                "Draw an invention and write its instructions in three steps.",
                "Draw a device that fails safely — show how.",
                "Draw an invention that would change one ordinary day completely.",
                "Draw a tool built only from things in your kitchen.",
                "Draw an invention and mark the part you are least sure about.",
                "Draw a device for two people who cannot speak the same language.",
            ],
            .story: [
                "Draw three frames that tell a story with no words.",
                "Draw the same moment from two people's points of view.",
                "Draw a scene where the most important thing is off the edge of the paper.",
                "Draw a story whose ending is a question.",
                "Draw a moment that changes what came before it.",
                "Draw a scene using only shadows.",
            ],
            .portrait: [
                "Draw a portrait with no lines on the face — only shading.",
                "Draw someone using five shapes and no more.",
                "Draw a self-portrait without a mirror.",
                "Draw a person and let the background say who they are.",
                "Draw a face split between two ages.",
                "Draw someone in a way that shows what they are afraid of.",
            ],
        ],
    ]

    /// Bir kademedeki tüm görevler.
    static func challenges(for tier: AgeTier) -> [DrawingChallenge] {
        guard let categories = pool[tier] else { return [] }
        return categories.flatMap { category, texts in
            texts.map { DrawingChallenge(text: $0, category: category, tier: tier) }
        }
    }

    /// Rastgele bir görev seçer.
    ///
    /// `avoidingTexts` son kullanılan görevleri eler — aynı görevin arka
    /// arkaya gelmesi oyunun en hızlı sıkıcılaşma yolu. Eleme sonucu
    /// havuz boşalırsa kısıtı bırakıp yine de bir görev döndürüyoruz;
    /// kullanıcı hiçbir koşulda boş ekran görmemeli.
    static func random(for tier: AgeTier, avoidingTexts avoided: Set<String> = []) -> DrawingChallenge? {
        let all = challenges(for: tier)
        guard !all.isEmpty else { return nil }
        let fresh = all.filter { !avoided.contains($0.text) }
        return (fresh.isEmpty ? all : fresh).randomElement()
    }

    static var totalCount: Int {
        AgeTier.allCases.reduce(0) { $0 + challenges(for: $1).count }
    }
}
