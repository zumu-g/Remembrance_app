import Foundation
import CoreData

class QuoteManager: ObservableObject {
    static let shared = QuoteManager()
    
    @Published var quotes: [Quote] = []
    @Published var currentQuote: Quote?
    
    private let persistenceController = PersistenceController.shared
    private var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    private init() {
        loadQuotes()
        checkAndInitializeQuotes()
    }
    
    func loadQuotes() {
        let request: NSFetchRequest<Quote> = Quote.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dayNumber", ascending: true)]
        
        do {
            quotes = try viewContext.fetch(request)
        } catch {
            print("Error loading quotes: \(error)")
        }
    }
    
    func loadTodaysQuote() {
        // Use same logic as photos - random selection with prime number hash
        let request: NSFetchRequest<Quote> = Quote.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dayNumber", ascending: true)]
        
        do {
            let allQuotes = try viewContext.fetch(request)
            
            if !allQuotes.isEmpty {
                let calendar = Calendar.current
                let today = Date()
                let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today) ?? 1
                let year = calendar.component(.year, from: today)
                let yearOffset = year - 2023
                
                // Use prime number hash for true randomization (same as photo system)
                let hash = (dayOfYear + yearOffset) * 73 + 37
                let quoteIndex = hash % allQuotes.count
                currentQuote = allQuotes[quoteIndex]
                
                print("Quote selection - Day: \(dayOfYear), Year offset: \(yearOffset), Hash: \(hash), Index: \(quoteIndex), Total quotes: \(allQuotes.count)")
            }
        } catch {
            print("Error loading today's quote: \(error)")
        }
    }
    
    func getQuoteForDay(_ dayNumber: Int) -> Quote? {
        return quotes.first { $0.dayNumber == Int32(dayNumber) }
    }
    
    private func checkAndInitializeQuotes() {
        if quotes.isEmpty || quotes.count < 365 {
            print("Initializing quotes - current count: \(quotes.count)")
            clearAllQuotes()
            initializeDefaultQuotes()
        }
    }
    
    func clearAllQuotes() {
        let request: NSFetchRequest<NSFetchRequestResult> = Quote.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
            quotes.removeAll()
            print("Cleared all existing quotes")
        } catch {
            print("Error clearing quotes: \(error)")
        }
    }
    
    private func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                try viewContext.parent?.save()
            } catch {
                print("Error saving quote context: \(error)")
            }
        }
    }
    
    private func initializeDefaultQuotes() {
        // Organized categories
        let loveQuotes = [
            ("The love we share transcends all boundaries, even those of life and death.", "Unknown", "love"),
            ("Those we love don't go away, they walk beside us every day.", "Unknown", "love"),
            ("Love is stronger than death even though it can't stop death from happening.", "Unknown", "love"),
            ("What we have once enjoyed we can never lose. All that we love deeply becomes a part of us.", "Helen Keller", "love"),
            ("Unable are the loved to die, for love is immortality.", "Emily Dickinson", "love"),
            ("The bond between a mother and child is not measured in time, but in love.", "Unknown", "love"),
            ("Love knows not its own depth until the hour of separation.", "Kahlil Gibran", "love"),
            ("Where there is deep grief, there was great love.", "Unknown", "love"),
            ("The heart that loves is always young.", "Greek Proverb", "love"),
            ("Love leaves a memory no one can steal.", "Unknown", "love"),
            ("Death ends a life, not a relationship.", "Mitch Albom", "love"),
            ("Love is how you stay alive, even after you are gone.", "Mitch Albom", "love"),
            ("The love between a mother and child knows no distance.", "Unknown", "love"),
            ("In the garden of memory, in the palace of dreams, that is where you and I shall meet.", "Lewis Carroll", "love"),
            ("Love is the bridge between two hearts, even when one has stopped beating.", "Unknown", "love"),
            ("A mother's love is always with her children. Losing a mother is one of the deepest sorrows a heart can know.", "Unknown", "love"),
            ("The love of a mother is never exhausted. It never changes, it never tires.", "Washington Irving", "love"),
            ("Love is the only force capable of transforming an enemy into a friend.", "Martin Luther King Jr.", "love"),
            ("We are shaped and fashioned by those we love.", "Goethe", "love"),
            ("Being deeply loved by someone gives you strength, while loving someone deeply gives you courage.", "Lao Tzu", "love"),
            ("Love recognizes no barriers. It jumps hurdles, leaps fences, penetrates walls to arrive at its destination full of hope.", "Maya Angelou", "love"),
            ("The best and most beautiful things in the world cannot be seen or even touched. They must be felt with the heart.", "Helen Keller", "love"),
            ("Love is a fabric which never fades, no matter how often it is washed in the water of adversity and grief.", "Unknown", "love"),
            ("To love and be loved is to feel the sun from both sides.", "David Viscott", "love"),
            ("Love is the voice under all silences, the hope which has no opposite in fear.", "E.E. Cummings", "love"),
            ("The love we give away is the only love we keep.", "Elbert Hubbard", "love"),
            ("Love is not a matter of counting the years, but making the years count.", "Michelle St. Amand", "love"),
            ("A mother's love is the fuel that enables a normal human being to do the impossible.", "Marion C. Garretty", "love"),
            ("Love is the master key that opens the gates of happiness.", "Oliver Wendell Holmes", "love"),
            ("The love of a family is life's greatest blessing.", "Unknown", "love"),
            ("Love is composed of a single soul inhabiting two bodies.", "Aristotle", "love"),
            ("The greatest gift that you can give to others is the gift of unconditional love and acceptance.", "Brian Tracy", "love"),
            ("Love is patient, love is kind. It always protects, always trusts, always hopes, always perseveres.", "1 Corinthians 13:4-7", "love"),
            ("A mother's love is endless, timeless, and knows no boundaries.", "Unknown", "love"),
            ("Love is the expansion of two natures in such fashion that each includes the other, each is enriched by the other.", "Felix Adler", "love"),
            ("The love between a parent and child is forever.", "Unknown", "love"),
            ("Love is the greatest refreshment in life.", "Pablo Picasso", "love"),
            ("Love is a canvas furnished by nature and embroidered by imagination.", "Voltaire", "love"),
            ("Love is the beauty of the soul.", "Saint Augustine", "love"),
            ("Where love is concerned, too much is not even enough.", "Pierre Beaumarchais", "love"),
            ("Love is the only gold.", "Alfred Lord Tennyson", "love"),
            ("The heart has its reasons which reason knows not.", "Blaise Pascal", "love"),
            ("Love is a fruit in season at all times, and within reach of every hand.", "Mother Teresa", "love"),
            ("Love is the bridge that connects everything.", "Rumi", "love"),
            ("Love is not consolation. It is light.", "Simone Weil", "love"),
            ("The love we have in our youth is superficial compared to the love that an old man has for his old wife.", "Will Durant", "love"),
            ("Love is life. And if you miss love, you miss life.", "Leo Buscaglia", "love"),
            ("Love is the ultimate truth at the heart of creation.", "Rabindranath Tagore", "love"),
            ("Love is the poetry of the senses.", "Honoré de Balzac", "love"),
            ("Love is the answer to everything. It's the only reason to do anything.", "Ray Bradbury", "love"),
            ("In this life we cannot do great things. We can only do small things with great love.", "Mother Teresa", "love"),
            ("The best way to find yourself is to lose yourself in the service of others.", "Mahatma Gandhi", "love"),
            ("We make a living by what we get, but we make a life by what we give.", "Winston Churchill", "love"),
            ("At the end of life, what really matters is not what we bought but what we built; not what we got but what we shared.", "Unknown", "love"),
            ("Love never dies. It lives on in the hearts of those touched by its beauty.", "Unknown", "love"),
            ("Love is the memory of water upon thirst.", "Leonard Cohen", "love"),
            ("The greatest happiness of life is the conviction that we are loved.", "Victor Hugo", "love"),
            ("Love is a temporary madness, it erupts like volcanoes and then subsides.", "Louis de Bernieres", "love"),
            ("Love is the only reality and it is not a mere sentiment.", "Rabindranath Tagore", "love"),
            ("There is only one happiness in this life, to love and be loved.", "George Sand", "love"),
            ("Love is an irresistible desire to be irresistibly desired.", "Robert Frost", "love"),
            ("The art of love is largely the art of persistence.", "Albert Ellis", "love"),
            ("Love is like a friendship caught on fire.", "Bruce Lee", "love"),
            ("To love is nothing. To be loved is something. But to love and be loved, that's everything.", "T. Tolis", "love"),
            ("Love does not dominate; it cultivates.", "Johann Wolfgang von Goethe", "love"),
            ("The course of true love never did run smooth.", "William Shakespeare", "love"),
            ("We are most alive when we're in love.", "John Updike", "love"),
            ("Love is when the other person's happiness is more important than your own.", "H. Jackson Brown Jr.", "love"),
            ("A mother's arms are made of tenderness and children sleep soundly in them.", "Victor Hugo", "love"),
            ("Mother: the most beautiful word on the lips of mankind.", "Kahil Gibran", "love"),
            ("A mother is your first friend, your best friend, your forever friend.", "Unknown", "love"),
            ("All that I am, or hope to be, I owe to my angel mother.", "Abraham Lincoln", "love"),
            ("A mother's love endures through all; in good repute, in bad repute.", "Washington Irving", "love"),
            ("The influence of a mother in the lives of her children is beyond calculation.", "James E. Faust", "love"),
            ("A mother understands what a child does not say.", "Jewish Proverb", "love"),
            ("There is no role in life that is more essential than that of motherhood.", "Elder M. Russell Ballard", "love"),
            ("Love as powerful as your mother's for you leaves its own mark.", "J.K. Rowling", "love"),
            ("A mother's love is patient and forgiving when all others are forsaking.", "Helen Rice", "love")
        ]
        
        let griefQuotes = [
            ("Grief is the price we pay for love.", "Queen Elizabeth II", "grief"),
            ("The reality is that you will grieve forever. You will not 'get over' the loss of a loved one; you'll learn to live with it.", "Elisabeth Kubler-Ross", "grief"),
            ("Grief is like the ocean; it comes on waves ebbing and flowing. Sometimes the water is calm, and sometimes it is overwhelming.", "Vicki Harrison", "grief"),
            ("There is no pain so great as the memory of joy in present grief.", "Aeschylus", "grief"),
            ("Grief is the last act of love we have to give to those we loved. Where there is deep grief, there was great love.", "Unknown", "grief"),
            ("The pain of grief is just as much part of life as the joy of love; it is perhaps the price we pay for love.", "Colin Murray Parkes", "grief"),
            ("Grief is not a disorder, a disease or a sign of weakness. It is an emotional, physical and spiritual necessity, the price you pay for love.", "Earl Grollman", "grief"),
            ("Tears are the silent language of grief.", "Voltaire", "grief"),
            ("Grief can be the garden of compassion. If you keep your heart open through everything, your pain can become your greatest ally.", "Rumi", "grief"),
            ("Give sorrow words; the grief that does not speak knits up the o-er wrought heart and bids it break.", "William Shakespeare", "grief"),
            ("Grief is a passage, not a place to stay.", "Unknown", "grief"),
            ("The deeper that sorrow carves into your being, the more joy you can contain.", "Kahlil Gibran", "grief"),
            ("Grief is the agony of an instant. The indulgence of grief the blunder of a life.", "Benjamin Disraeli", "grief"),
            ("Grief is not a sign of weakness, nor a lack of faith. It is the price of love.", "Unknown", "grief"),
            ("We must embrace pain and burn it as fuel for our journey.", "Kenji Miyazawa", "grief"),
            ("Grief is like a long valley, a winding valley where any bend may reveal a totally new landscape.", "C.S. Lewis", "grief"),
            ("The risk of love is loss, and the price of loss is grief. But the pain of grief is only a shadow when compared with the pain of never risking love.", "Hilary Stanton Zunin", "grief"),
            ("Grief is the great leveler. It knows no boundaries of age, race, or social status.", "Unknown", "grief"),
            ("To weep is to make less the depth of grief.", "William Shakespeare", "grief"),
            ("Grief is a normal and natural response to loss. It is originally an unlearned feeling process.", "John James", "grief"),
            ("Grief is love with no place to go.", "Unknown", "grief"),
            ("The grief of the heart is known only to the one who feels it.", "Nigerian Proverb", "grief"),
            ("Grief is a journey, often perilous and without clear direction.", "Molly Fumia", "grief"),
            ("Grief is not something you complete, but rather you endure.", "Unknown", "grief"),
            ("In grief, nothing stays put. One keeps emerging from a phase, but it always recurs.", "C.S. Lewis", "grief"),
            ("Grief is a most peculiar thing; we're so helpless in the face of it.", "Arthur Golden", "grief"),
            ("The darkness of grief can make us feel isolated and alone.", "Unknown", "grief"),
            ("Grief is the unwelcome houseguest that overstays its welcome.", "Unknown", "grief"),
            ("Sometimes grief is a comfort we grant ourselves.", "Dean Koontz", "grief"),
            ("Grief is the healing process of the heart, soul and mind.", "Unknown", "grief"),
            ("The pain of loss is a reflection of the joy that was shared.", "Unknown", "grief"),
            ("Grief is love's souvenir. It's our proof that we once loved.", "Unknown", "grief"),
            ("In the night of death, hope sees a star, and listening love can hear the rustle of a wing.", "Robert Green Ingersoll", "grief"),
            ("Grief is the tribute we pay to love.", "Unknown", "grief"),
            ("The grief doesn't go away, but it changes. It softens.", "Unknown", "grief"),
            ("Grief is a solitary journey. No one but you knows how great the hurt is.", "Suzanne Clothier", "grief"),
            ("Grief is the price of being close to another human being.", "Unknown", "grief"),
            ("The pain passes, but the beauty remains.", "Pierre Auguste Renoir", "grief"),
            ("Grief is a wound that needs attention in order to heal.", "Unknown", "grief"),
            ("Sometimes you will never know the value of a moment until it becomes a memory.", "Dr. Seuss", "grief"),
            ("Grief is love turned into an eternal missing.", "Unknown", "grief"),
            ("The reality of grief is far different from what we imagine.", "Joan Didion", "grief"),
            ("Grief is the emotional contract we sign when choosing to love.", "Unknown", "grief"),
            ("In grief, we find the depths of our love.", "Unknown", "grief"),
            ("Grief is the reminder that love was present.", "Unknown", "grief"),
            ("The pain of parting is nothing to the joy of meeting again.", "Charles Dickens", "grief"),
            ("Grief is a lifelong journey. There is no finish line.", "Unknown", "grief"),
            ("Through grief, we learn the true meaning of love.", "Unknown", "grief"),
            ("Grief is just love with nowhere to go.", "Jamie Anderson", "grief"),
            ("The grief journey is as individual as a fingerprint.", "Unknown", "grief"),
            ("In every parting there is an image of death.", "George Eliot", "grief"),
            ("Grief teaches the steadiest minds to waver.", "Sophocles", "grief"),
            ("Heavy hearts, like heavy clouds in the sky, are best relieved by the letting of a little water.", "Christopher Morley", "grief"),
            ("Grief is a tidal wave that overtakes you, smashes down upon you with unimaginable force.", "Stephanie Ericsson", "grief"),
            ("The worst part of losing someone isn't saying goodbye, it's learning to live without them.", "Unknown", "grief"),
            ("What we once enjoyed and deeply loved we can never lose, for all that we love deeply becomes part of us.", "Helen Keller", "grief"),
            ("The reality of the other person lies not in what he reveals to you, but what he cannot reveal.", "Kahlil Gibran", "grief"),
            ("Grief is in two parts. The first is loss. The second is the remaking of life after the loss.", "Anne Roiphe", "grief"),
            ("Perhaps they are not stars, but rather openings in heaven where the love of our lost ones pours through.", "Eskimo Proverb", "grief"),
            ("Those we love never truly leave us. They live on in our hearts, our memories.", "Unknown", "grief"),
            ("The darker the grief, the brighter the love that preceded it.", "Unknown", "grief"),
            ("To live in hearts we leave behind is not to die.", "Thomas Campbell", "grief"),
            ("What is grief, if not love persisting?", "WandaVision", "grief"),
            ("Grief is the final act of love.", "Unknown", "grief"),
            ("No one ever told me that grief felt so like fear.", "C.S. Lewis", "grief"),
            ("The truth is, once you lose someone, you never fully get over it.", "Unknown", "grief"),
            ("Memories are the treasures that we keep locked deep within the storehouse of our souls.", "Becky Aligada", "grief"),
            ("Gone yet not forgotten, although we are apart, your spirit lives within me, forever in my heart.", "Unknown", "grief"),
            ("Although it's difficult today to see beyond the sorrow, may looking back in memory help comfort you tomorrow.", "Unknown", "grief"),
            ("A mother's love is something that no one can explain — it is made of deep devotion and of sacrifice and pain.", "Helen Rice", "grief"),
            ("When someone you love becomes a memory, the memory becomes a treasure.", "Unknown", "grief"),
            ("Grief is like living two lives. One is where you pretend that everything is alright, and the other is where your heart silently screams in pain.", "Unknown", "grief"),
            ("Missing someone gets easier every day because even though you are one day further from the last time you saw them, you are one day closer to the next time you will.", "Unknown", "grief"),
            ("The song is ended, but the melody lingers on.", "Irving Berlin", "grief"),
            ("Your life was a blessing, your memory a treasure, you are loved beyond words and missed beyond measure.", "Unknown", "grief")
        ]
        
        let hopeQuotes = [
            ("Hope is the thing with feathers that perches in the soul.", "Emily Dickinson", "hope"),
            ("Even the darkest night will end and the sun will rise.", "Victor Hugo", "hope"),
            ("Hope is being able to see that there is light despite all of the darkness.", "Desmond Tutu", "hope"),
            ("We must accept finite disappointment, but never lose infinite hope.", "Martin Luther King Jr.", "hope"),
            ("Hope is the only thing stronger than fear.", "Suzanne Collins", "hope"),
            ("Where there is hope, there is faith. Where there is faith, miracles happen.", "Unknown", "hope"),
            ("Hope is the companion of power, and mother of success.", "Samuel Smiles", "hope"),
            ("Hope is a waking dream.", "Aristotle", "hope"),
            ("Once you choose hope, anything's possible.", "Christopher Reeve", "hope"),
            ("Hope is the heartbeat of the soul.", "Michelle Horst", "hope"),
            ("Hope sees the invisible, feels the intangible, and achieves the impossible.", "Helen Keller", "hope"),
            ("Hope is a good breakfast, but it is a bad supper.", "Francis Bacon", "hope"),
            ("Hope is the power of being cheerful in circumstances that we know to be desperate.", "G.K. Chesterton", "hope"),
            ("The road that is built in hope is more pleasant to the traveler than the road built in despair.", "Marion Zimmer Bradley", "hope"),
            ("Hope is patience with the lamp lit.", "Tertullian", "hope"),
            ("Hope is the dream of a waking man.", "French Proverb", "hope"),
            ("While there's life, there's hope.", "Marcus Tullius Cicero", "hope"),
            ("Hope is the physician of each misery.", "Irish Proverb", "hope"),
            ("Hope is a force of nature. Don't let anyone tell you different.", "Jim Butcher", "hope"),
            ("Hope is not a strategy, but it is a starting point.", "Unknown", "hope"),
            ("In the midst of winter, I found there was, within me, an invincible summer.", "Albert Camus", "hope"),
            ("Hope is the light that guides us through the darkness.", "Unknown", "hope"),
            ("Hope whispers, 'Try it one more time.'", "Unknown", "hope"),
            ("Hope is the anchor of the soul.", "Hebrews 6:19", "hope"),
            ("Where flowers bloom, so does hope.", "Lady Bird Johnson", "hope"),
            ("Hope is a beautiful thing. It gives us peace and strength, and keeps us going when all seems lost.", "Unknown", "hope"),
            ("Hope is the belief that the future will be better than the present.", "Unknown", "hope"),
            ("Stars can't shine without darkness.", "Unknown", "hope"),
            ("Hope begins in the dark.", "Anne Lamott", "hope"),
            ("There is hope, even when your brain tells you there isn't.", "John Green", "hope"),
            ("Hope is the light at the end of the tunnel.", "Unknown", "hope"),
            ("Hope means hoping when everything seems hopeless.", "G.K. Chesterton", "hope"),
            ("The best way to not feel hopeless is to get up and do something.", "Barack Obama", "hope"),
            ("Hope is a renewable option: If you run out of it at the end of the day, you get to start over in the morning.", "Barbara Kingsolver", "hope"),
            ("Hope is the feeling that the feeling you have isn't permanent.", "Jean Kerr", "hope"),
            ("However long the night, the dawn will break.", "African Proverb", "hope"),
            ("Hope springs eternal in the human breast.", "Alexander Pope", "hope"),
            ("The very least you can do in your life is figure out what you hope for.", "Barbara Kingsolver", "hope"),
            ("Hope is not found in a way out but a way through.", "Robert Frost", "hope"),
            ("Hope is the last thing ever lost.", "Italian Proverb", "hope"),
            ("Hope is putting faith to work when doubting would be easier.", "Unknown", "hope"),
            ("A single thread of hope is still a very powerful thing.", "Unknown", "hope"),
            ("Hope is the promise that things will get better.", "Unknown", "hope"),
            ("Never lose hope. Storms make people stronger and never last forever.", "Roy T. Bennett", "hope"),
            ("Hope is a gift we give ourselves.", "Unknown", "hope"),
            ("Hope is the rainbow over the waterfall of despair.", "Unknown", "hope"),
            ("When you have lost hope, you have lost everything.", "Unknown", "hope"),
            ("Hope costs nothing.", "Colette", "hope"),
            ("Hope is the poor man's bread.", "Gary Herbert", "hope"),
            ("Hope smiles from the threshold of the year to come.", "Alfred Lord Tennyson", "hope"),
            ("Healing is a matter of time, but it is sometimes also a matter of opportunity.", "Hippocrates", "healing"),
            ("The wound is the place where the Light enters you.", "Rumi", "healing"),
            ("Healing doesn't mean the damage never existed. It means the damage no longer controls your life.", "Akshay Dubey", "healing"),
            ("Time doesn't heal all wounds, but it does provide the opportunity for healing.", "Unknown", "healing"),
            ("Hope is a love letter to your future self.", "Unknown", "hope"),
            ("Hope is the bridge between despair and faith.", "Unknown", "hope"),
            ("Hope is like the sun, which, as we journey toward it, casts the shadow of our burden behind us.", "Samuel Smiles", "hope"),
            ("Hope is a kind of spiritual audacity.", "Gabriel Marcel", "hope"),
            ("We have always held to the hope, the belief, the conviction that there is a better life, a better world, beyond the horizon.", "Franklin D. Roosevelt", "hope"),
            ("Hope is important because it can make the present moment less difficult to bear.", "Thich Nhat Hanh", "hope"),
            ("Hope is being able to see that there is light despite all of the darkness.", "Desmond Tutu", "hope"),
            ("When you're at the end of your rope, tie a knot and hold on.", "Franklin D. Roosevelt", "hope"),
            ("Hope is the companion of power and mother of success.", "Samuel Smiles", "hope"),
            ("Keep your face always toward the sunshine—and shadows will fall behind you.", "Walt Whitman", "hope"),
            ("Hope is a powerful force. Nothing can get in the way of the power of hope.", "John Lewis", "hope"),
            ("Hope never abandons you, you abandon it.", "George Weinberg", "hope"),
            ("Hope is the pillar that holds up the world.", "Pliny the Elder", "hope"),
            ("Hope is the voice that whispers 'maybe' when the whole world shouts 'no'.", "Unknown", "hope"),
            ("Hope sees the invisible, feels the intangible, achieves the impossible.", "Unknown", "hope"),
            ("There is no medicine like hope, no incentive so great, no tonic so powerful.", "Orison Swett Marden", "hope"),
            ("Hope is not a strategy, but it's a starting point.", "Unknown", "hope"),
            ("Hope is the one thing that can help us get through the darkest of times.", "Unknown", "hope"),
            ("Even in the midst of darkness, hope finds a way to shine through.", "Unknown", "hope"),
            ("Hope is the heartbeat of the soul.", "Michelle Horst", "hope"),
            ("Hope is faith holding out its hand in the dark.", "George Iles", "hope"),
            ("Every great dream begins with a dreamer. Always remember, you have within you the strength, the patience, and the passion to reach for the stars to change the world.", "Harriet Tubman", "hope")
        ]
        
        let strengthQuotes = [
            ("This too shall pass.", "Persian Proverb", "strength"),
            ("Rock bottom became the solid foundation on which I rebuilt my life.", "J.K. Rowling", "strength"),
            ("The human spirit is stronger than anything that can happen to it.", "C.C. Scott", "strength"),
            ("You never know how strong you are until being strong is your only choice.", "Bob Marley", "strength"),
            ("Tough times never last, but tough people do.", "Robert H. Schuller", "strength"),
            ("The oak fought the wind and was broken, the willow bent when it must and survived.", "Robert Jordan", "strength"),
            ("The gem cannot be polished without friction, nor man perfected without trials.", "Chinese Proverb", "strength"),
            ("In the middle of difficulty lies opportunity.", "Albert Einstein", "strength"),
            ("When we are no longer able to change a situation, we are challenged to change ourselves.", "Viktor E. Frankl", "strength"),
            ("The darkest hour has only sixty minutes.", "Morris Mandel", "strength"),
            ("Every adversity, every failure, every heartache carries with it the seed of an equal or greater benefit.", "Napoleon Hill", "strength"),
            ("Life isn't about waiting for the storm to pass. It's about learning how to dance in the rain.", "Vivian Greene", "strength"),
            ("You are braver than you believe, stronger than you seem, and smarter than you think.", "A.A. Milne", "strength"),
            ("Sometimes you don't realize your own strength until you come face to face with your greatest weakness.", "Susan Gale", "strength"),
            ("Strength doesn't come from what you can do. It comes from overcoming the things you once thought you couldn't.", "Rikki Rogers", "strength"),
            ("The struggle you're in today is developing the strength you need for tomorrow.", "Unknown", "strength"),
            ("Hard times may have held you down, but they will not last forever.", "Joel Osteen", "strength"),
            ("When everything seems to be going against you, remember that the airplane takes off against the wind.", "Henry Ford", "strength"),
            ("The strongest people are not those who show strength in front of us but those who win battles we know nothing about.", "Unknown", "strength"),
            ("Fall seven times, stand up eight.", "Japanese Proverb", "strength"),
            ("It's not the load that breaks you down, it's the way you carry it.", "Lou Holtz", "strength"),
            ("The pain you feel today is the strength you feel tomorrow.", "Unknown", "strength"),
            ("Difficulties are meant to rouse, not discourage. The human spirit is to grow strong by conflict.", "William Ellery Channing", "strength"),
            ("You have power over your mind - not outside events. Realize this, and you will find strength.", "Marcus Aurelius", "strength"),
            ("A smooth sea never made a skilled sailor.", "Franklin D. Roosevelt", "strength"),
            ("The only way out is through.", "Robert Frost", "strength"),
            ("What lies behind us and what lies before us are tiny matters compared to what lies within us.", "Ralph Waldo Emerson", "strength"),
            ("When you come out of the storm, you won't be the same person who walked in.", "Haruki Murakami", "strength"),
            ("Sometimes it takes a good fall to really know where you stand.", "Hayley Williams", "strength"),
            ("The world breaks everyone, and afterward, some are strong at the broken places.", "Ernest Hemingway", "strength"),
            ("Turn your wounds into wisdom.", "Oprah Winfrey", "strength"),
            ("The harder the battle, the sweeter the victory.", "Les Brown", "strength"),
            ("Strength grows in the moments when you think you can't go on but you keep going anyway.", "Unknown", "strength"),
            ("Every storm runs out of rain.", "Maya Angelou", "strength"),
            ("You were given this life because you are strong enough to live it.", "Unknown", "strength"),
            ("The strongest hearts have the most scars.", "Unknown", "strength"),
            ("Don't be pushed by your problems. Be led by your dreams.", "Ralph Waldo Emerson", "strength"),
            ("The sun himself is weak when he first rises, and gathers strength and courage as the day gets on.", "Charles Dickens", "strength"),
            ("One small crack does not mean that you are broken, it means that you were put to the test and you didn't fall apart.", "Linda Poindexter", "strength"),
            ("Courage doesn't always roar. Sometimes courage is the quiet voice at the end of the day saying, 'I will try again tomorrow.'", "Mary Anne Radmacher", "strength"),
            ("You may have to fight a battle more than once to win it.", "Margaret Thatcher", "strength"),
            ("The bamboo that bends is stronger than the oak that resists.", "Japanese Proverb", "strength"),
            ("Rivers know this: there is no hurry. We shall get there some day.", "A.A. Milne", "strength"),
            ("Just when the caterpillar thought the world was ending, he turned into a butterfly.", "Proverb", "strength"),
            ("Although the world is full of suffering, it is also full of the overcoming of it.", "Helen Keller", "strength"),
            ("We are all broken, that's how the light gets in.", "Ernest Hemingway", "strength"),
            ("The only way to get through hard times is to get through them.", "Unknown", "strength"),
            ("Storms make trees take deeper roots.", "Dolly Parton", "strength"),
            ("Remember that guy that gave up? Neither does anyone else.", "Unknown", "persistence"),
            ("It does not matter how slowly you go as long as you do not stop.", "Confucius", "persistence"),
            ("Our greatest glory is not in never falling, but in rising every time we fall.", "Confucius", "persistence"),
            ("Persistence is the twin sister of excellence.", "Marabel Morgan", "persistence"),
            ("The difference between a successful person and others is not lack of strength not a lack of knowledge but rather a lack of will.", "Vince Lombardi", "persistence"),
            ("Success is not final, failure is not fatal: it is the courage to continue that counts.", "Winston Churchill", "persistence"),
            ("Faith is taking the first step even when you don't see the whole staircase.", "Martin Luther King Jr.", "faith"),
            ("Faith is the bird that feels the light when the dawn is still dark.", "Rabindranath Tagore", "faith"),
            ("Courage is not the absence of fear, but the triumph over it.", "Nelson Mandela", "courage"),
            ("The strongest people are forged by fires of adversity.", "Unknown", "strength"),
            ("Life doesn't get easier or more forgiving, we get stronger and more resilient.", "Steve Maraboli", "strength"),
            ("You have been assigned this mountain to show others it can be moved.", "Mel Robbins", "strength"),
            ("The way I see it, if you want the rainbow, you gotta put up with the rain.", "Dolly Parton", "strength"),
            ("Sometimes you need to sit lonely on the floor in a quiet room in order to hear your own voice and not let it drown in the noise of others.", "Charlotte Eriksson", "strength"),
            ("Be strong, because things will get better. It might be stormy now, but it never rains forever.", "Unknown", "strength"),
            ("You are not a victim. No matter what you have been through, you're still here.", "Unknown", "strength"),
            ("Rock bottom will teach you lessons that mountain tops never will.", "Unknown", "strength"),
            ("You are stronger than your challenges and your challenges are making you stronger.", "Karen Salmansohn", "strength"),
            ("Don't let yesterday take up too much of today.", "Will Rogers", "strength"),
            ("The only impossible journey is the one you never begin.", "Tony Robbins", "strength"),
            ("Your current situation is not your final destination.", "Unknown", "strength"),
            ("Believe you can and you're halfway there.", "Theodore Roosevelt", "strength"),
            ("It always seems impossible until it's done.", "Nelson Mandela", "strength"),
            ("The comeback is always stronger than the setback.", "Unknown", "strength"),
            ("You don't have to be great to get started, but you have to get started to be great.", "Les Brown", "strength"),
            ("What doesn't kill you makes you stronger.", "Friedrich Nietzsche", "strength"),
            ("The brave may not live forever, but the cautious do not live at all.", "Richard Branson", "strength"),
            ("Life is tough, my darling, but so are you.", "Stephanie Bennett Henry", "strength"),
            ("You were born to be real, not perfect.", "Unknown", "strength"),
            ("Stars can't shine without darkness.", "D.H. Sidebottom", "strength"),
            ("Be yourself; everyone else is already taken.", "Oscar Wilde", "strength"),
            ("In the middle of every difficulty lies opportunity.", "Albert Einstein", "strength"),
            ("The most beautiful people are those who have known trials, known struggles, known loss, and have found their way out of the depths.", "Elisabeth Kubler-Ross", "strength"),
            ("You are enough just as you are.", "Meghan Markle", "strength")
        ]
        
        // Mix quotes by cycling through categories
        var quotesData: [(String, String, String, Int)] = []
        let maxQuotes = 365
        let categories = [loveQuotes, griefQuotes, hopeQuotes, strengthQuotes]
        
        var categoryIndex = 0
        var quoteIndex = [0, 0, 0, 0] // Track position in each category
        
        for dayNumber in 1...maxQuotes {
            let currentCategory = categories[categoryIndex]
            let currentQuoteIndex = quoteIndex[categoryIndex]
            
            if currentQuoteIndex < currentCategory.count {
                let quote = currentCategory[currentQuoteIndex]
                quotesData.append((quote.0, quote.1, quote.2, dayNumber))
                quoteIndex[categoryIndex] += 1
            } else {
                // If we've run out of quotes in this category, use a fallback
                quotesData.append(("Love never ends. It lives on in memories and hearts.", "Unknown", "love", dayNumber))
            }
            
            // Move to next category
            categoryIndex = (categoryIndex + 1) % categories.count
        }
        
        for (index, quoteData) in quotesData.enumerated() {
            let quote = Quote(context: viewContext)
            quote.id = UUID()
            quote.text = quoteData.0
            quote.author = quoteData.1
            quote.category = quoteData.2
            quote.dayNumber = Int32(quoteData.3)
            quote.dateCreated = Date()
        }
        
        saveContext()
        loadQuotes()
    }
}

// Quote View Model for UI
class QuoteViewModel: ObservableObject {
    @Published var currentQuote: Quote?
    @Published var allQuotes: [Quote] = []
    @Published var isLoading = false
    
    private let quoteManager = QuoteManager.shared
    private let persistenceController = PersistenceController.shared
    private var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    init() {
        loadAllQuotes()
    }
    
    func loadAllQuotes() {
        allQuotes = quoteManager.quotes
    }
    
    func loadTodaysQuote() async {
        await MainActor.run {
            quoteManager.loadTodaysQuote()
            self.currentQuote = quoteManager.currentQuote
        }
    }
    
    func refreshQuotes() async {
        await MainActor.run {
            isLoading = true
            quoteManager.loadQuotes()
            quoteManager.loadTodaysQuote()
            self.currentQuote = quoteManager.currentQuote
            self.allQuotes = quoteManager.quotes
            isLoading = false
        }
    }
    
    func hasCurrentQuote() -> Bool {
        return currentQuote != nil
    }
    
    func getQuoteText() -> String {
        return currentQuote?.text ?? ""
    }
    
    func getQuoteAuthor() -> String {
        if let author = currentQuote?.author, !author.isEmpty {
            return "— \(author)"
        }
        return "— Unknown"
    }
    
    func getQuotesCount() -> Int {
        return quoteManager.quotes.count
    }
    
    func addCustomQuote(text: String, author: String?, dayNumber: Int32) async -> Bool {
        await MainActor.run {
            let quote = Quote(context: viewContext)
            quote.id = UUID()
            quote.text = text
            quote.author = author ?? "Unknown"
            quote.category = "custom"
            quote.dayNumber = dayNumber
            quote.dateCreated = Date()
            quote.isCustom = true
            
            do {
                try viewContext.save()
                quoteManager.loadQuotes()
                self.allQuotes = quoteManager.quotes
                return true
            } catch {
                print("Error saving custom quote: \(error)")
                return false
            }
        }
    }
}