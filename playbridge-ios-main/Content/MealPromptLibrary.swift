//
//  MealPromptLibrary.swift
//  PlayBridgeAI
//
//  Created by Tuna Kömür on 30.08.2026.
//

import Foundation

/// Elle yazılmış yemek sohbeti havuzu — 4 kategori × 5 yaş kademesi.
///
/// İki işi var: (1) backend kapalıyken ya da model çökerken devreye
/// giren yedek, (2) uygulamanın internetsiz de anlamlı çalışması.
/// Önceki sabit liste yalnızca 3 cümleydi ve yaşı hiç dikkate almıyordu;
/// 80 soruluk bu havuz aynı işi yaparken kademeye de saygı gösteriyor.
///
/// Sorular MASADAKİ ve MUTFAKTAKİ gerçek nesnelere bakıyor — ebeveynin
/// hiçbir şey hazırlamasına gerek kalmasın diye. Kademeler yukarı
/// çıktıkça soru gözlemden yorumlamaya kayıyor: 3 yaşındakine "kaç
/// bardak var?", 12 yaşındakine "bu masa nasıl yaşadığımız hakkında
/// ne söylüyor?".
enum MealPromptLibrary {

    static let pool: [AgeTier: [MealPromptCategory: [String]]] = [
        .tier3to4: [
            .table: [
                "Can you find three red things on the table?",
                "What is the biggest thing on the table?",
                "Can you find something round?",
                "How many cups can you count?",
            ],
            .kitchen: [
                "What is the coldest thing in the kitchen?",
                "Can you hear anything in the kitchen right now?",
                "What is the loudest thing in our kitchen?",
                "Where does the water come from?",
            ],
            .food: [
                "What colour is your food?",
                "Is your food hot or cold?",
                "Which food on your plate is the sweetest?",
                "Can you name one thing on your plate that grew in the ground?",
            ],
            .story: [
                "Let's make up a three-word story together. You start!",
                "What sound does your dinner make?",
                "Who would you invite to eat with us?",
                "Tell me one thing that made you laugh today.",
            ],
        ],

        .tier5to6: [
            .table: [
                "Find something on the table that starts with the same sound as your name.",
                "What on this table is the oldest?",
                "Can you find two things that are the same colour?",
                "If you could keep only one thing on this table, which would it be?",
            ],
            .kitchen: [
                "What is the tallest thing in the kitchen?",
                "Which drawer has the most things in it, do you think?",
                "What smells the strongest in our kitchen?",
                "If the fridge could talk, what would it complain about?",
            ],
            .food: [
                "Which food on your plate grew on a tree?",
                "If your carrot could talk, what would it say?",
                "What food would you eat every single day?",
                "Which food on your plate is the crunchiest?",
            ],
            .story: [
                "If our table could fly, where would it take us?",
                "Tell me a story where the spoon is the hero.",
                "What is the best thing that happened today?",
                "Make up a name for this meal.",
            ],
        ],

        .tier7to8: [
            .table: [
                "Which thing on this table travelled the furthest to get here?",
                "Pick something on the table and guess how it was made.",
                "What is on this table that nobody really needs?",
                "Put three things in order from lightest to heaviest, without picking them up.",
            ],
            .kitchen: [
                "Which kitchen tool would be hardest to live without?",
                "What is in our kitchen that we almost never use?",
                "Guess how many spoons we own.",
                "What is the most dangerous thing in the kitchen, and why?",
            ],
            .food: [
                "Where do you think this food was before it came to us?",
                "Invent a new flavour of something on your plate.",
                "Which food on this plate takes the longest to grow?",
                "What food do you think you will still love when you are grown up?",
            ],
            .story: [
                "Tell me about today, but leave one thing out and I'll guess what it was.",
                "Tell me a story that ends at this table.",
                "What was the hardest part of today?",
                "If today were a chapter in a book, what would it be called?",
            ],
        ],

        .tier9to10: [
            .table: [
                "Choose something on the table and describe it so well I could draw it with my eyes closed.",
                "Which object here would be hardest to invent from scratch?",
                "What would a visitor from another country find strange about this table?",
                "Pick one thing and guess how many people it took to make it.",
            ],
            .kitchen: [
                "Which kitchen tool has not changed in a hundred years?",
                "If you could cook with only three tools, which three?",
                "What would you add to this kitchen if you could add one thing?",
                "Which machine in here uses the most electricity, do you think?",
            ],
            .food: [
                "How many people do you think touched this food before we did?",
                "What would you serve if you had to cook dinner tomorrow?",
                "Which food here would be hardest to grow at home?",
                "Invent a dish using only what is on this table.",
            ],
            .story: [
                "Tell me something you changed your mind about this week.",
                "Describe today in exactly five words.",
                "What did you learn today that surprised you?",
                "Tell me a story where someone made the wrong choice.",
            ],
        ],

        .tier11to12: [
            .table: [
                "If this table were a museum display, what would the label say?",
                "Which item here will still exist in a hundred years?",
                "Pick something and argue that it is the most important thing on this table.",
                "What does this table say about how we live?",
            ],
            .kitchen: [
                "Design a kitchen for someone who cannot stand up. What changes?",
                "Which invention in this room changed families the most?",
                "What in our kitchen would confuse someone from two hundred years ago?",
                "If this kitchen had to feed twenty people tonight, what breaks first?",
            ],
            .food: [
                "What would change if this food cost ten times more?",
                "Which food here travelled the furthest, and was that worth it?",
                "Design a meal that would still be good cold, three hours from now.",
                "What did people your age eat a hundred years ago?",
            ],
            .story: [
                "What is something you believe that most people your age don't?",
                "Tell me about a moment today you would do differently.",
                "Describe someone at school without saying their name.",
                "What is a rule you think should change, and why?",
            ],
        ],
    ]

    static func prompts(for tier: AgeTier, category: MealPromptCategory) -> [String] {
        pool[tier]?[category] ?? []
    }

    /// Yedek soru. Kademe ya da kategori bulunamazsa boş dönmüyoruz —
    /// ebeveyn hiçbir koşulda boş ekran görmemeli.
    static func random(
        for tier: AgeTier,
        category: MealPromptCategory,
        avoiding avoided: Set<String> = []
    ) -> String {
        let options = prompts(for: tier, category: category)
        guard !options.isEmpty else {
            return "Can you find three red things on the table?"
        }
        let fresh = options.filter { !avoided.contains($0) }
        return (fresh.isEmpty ? options : fresh).randomElement() ?? options[0]
    }

    static var totalCount: Int {
        pool.values.reduce(0) { $0 + $1.values.reduce(0) { $0 + $1.count } }
    }
}
