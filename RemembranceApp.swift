//
//  RemembranceApp.swift
//  Remembrance
//
//  Created by Stuart Grant on 6/8/2025.
//

import SwiftUI
import UserNotifications
import PhotosUI
import CoreData
import Foundation
import UIKit

// Photo storage that persists across tab switches with random selection
class PhotoStore: ObservableObject {
    @Published var images: [UIImage] = []
    
    // Store today's selected photo persistently
    @AppStorage("todaysPhotoFilename") private var todaysPhotoFilename: String = ""
    @AppStorage("todaysPhotoDateStore") private var todaysPhotoDateStore: String = ""
    
    // Keep track of filenames for each image
    private var imageFilenames: [String] = []
    @Published var quotes: [String] = [
        // Mixed quotes cycling through categories: Love -> Grief -> Hope -> Strength
        "\"The love we share transcends all boundaries, even those of life and death.\" - Unknown",
        "\"Grief is the price we pay for love.\" - Queen Elizabeth II",
        "\"Hope is the thing with feathers that perches in the soul.\" - Emily Dickinson",
        "\"This too shall pass.\" - Persian Proverb",
        "\"The reality is that you will grieve forever. You will not 'get over' the loss of a loved one; you'll learn to live with it.\" - Elisabeth Kubler-Ross",
        "\"Even the darkest night will end and the sun will rise.\" - Victor Hugo",
        "\"Rock bottom became the solid foundation on which I rebuilt my life.\" - J.K. Rowling",
        "\"The bond between a mother and child is not measured in time, but in love.\" - Unknown",
        "\"Grief is like the ocean; it comes on waves ebbing and flowing. Sometimes the water is calm, and sometimes it is overwhelming.\" - Vicki Harrison",
        "\"Hope is being able to see that there is light despite all of the darkness.\" - Desmond Tutu",
        "\"The human spirit is stronger than anything that can happen to it.\" - C.C. Scott",
        "\"Love knows not its own depth until the hour of separation.\" - Kahlil Gibran",
        "\"There is no pain so great as the memory of joy in present grief.\" - Aeschylus",
        "\"We must accept finite disappointment, but never lose infinite hope.\" - Martin Luther King Jr.",
        "\"You never know how strong you are until being strong is your only choice.\" - Bob Marley",
        "\"Where there is deep grief, there was great love.\" - Unknown",
        "\"Grief is the last act of love we have to give to those we loved. Where there is deep grief, there was great love.\" - Unknown",
        "\"Hope is the only thing stronger than fear.\" - Suzanne Collins",
        "\"Tough times never last, but tough people do.\" - Robert H. Schuller",
        "\"The heart that loves is always young.\" - Greek Proverb",
        "\"Love recognizes no barriers. It jumps hurdles, leaps fences, penetrates walls to arrive at its destination full of hope.\" - Maya Angelou",
        "\"The best and most beautiful things in the world cannot be seen or even touched. They must be felt with the heart.\" - Helen Keller",
        "\"Love is a fabric which never fades, no matter how often it is washed in the water of adversity and grief.\" - Unknown",
        "\"To love and be loved is to feel the sun from both sides.\" - David Viscott",
        "\"Love is the voice under all silences, the hope which has no opposite in fear.\" - E.E. Cummings",
        "\"The love we give away is the only love we keep.\" - Elbert Hubbard",
        "\"Love is not a matter of counting the years, but making the years count.\" - Michelle St. Amand",
        "\"A mother's love is the fuel that enables a normal human being to do the impossible.\" - Marion C. Garretty",
        "\"Love is the master key that opens the gates of happiness.\" - Oliver Wendell Holmes",
        "\"The love of a family is life's greatest blessing.\" - Unknown",
        "\"Love is composed of a single soul inhabiting two bodies.\" - Aristotle",
        "\"The greatest gift that you can give to others is the gift of unconditional love and acceptance.\" - Brian Tracy",
        "\"Love is patient, love is kind. It always protects, always trusts, always hopes, always perseveres.\" - 1 Corinthians 13:4-7",
        "\"A mother's love is endless, timeless, and knows no boundaries.\" - Unknown",
        "\"Love is the expansion of two natures in such fashion that each includes the other, each is enriched by the other.\" - Felix Adler",
        "\"The love between a parent and child is forever.\" - Unknown",
        "\"Love is the greatest refreshment in life.\" - Pablo Picasso",
        "\"Love is a canvas furnished by nature and embroidered by imagination.\" - Voltaire",
        "\"Love is the beauty of the soul.\" - Saint Augustine",
        "\"Where love is concerned, too much is not even enough.\" - Pierre Beaumarchais",
        "\"Love is the only gold.\" - Alfred Lord Tennyson",
        "\"The heart has its reasons which reason knows not.\" - Blaise Pascal",
        "\"Love is a fruit in season at all times, and within reach of every hand.\" - Mother Teresa",
        "\"Love is the bridge that connects everything.\" - Rumi",
        "\"Love is not consolation. It is light.\" - Simone Weil",
        "\"The love we have in our youth is superficial compared to the love that an old man has for his old wife.\" - Will Durant",
        "\"Love is life. And if you miss love, you miss life.\" - Leo Buscaglia",
        "\"Love is the ultimate truth at the heart of creation.\" - Rabindranath Tagore",
        "\"Love is the poetry of the senses.\" - Honoré de Balzac",
        "\"Love is the answer to everything. It's the only reason to do anything.\" - Ray Bradbury",
        "\"In this life we cannot do great things. We can only do small things with great love.\" - Mother Teresa",
        
        // Grief and Loss (Days 51-150)
        "\"Grief is the price we pay for love.\" - Queen Elizabeth II",
        "\"The reality is that you will grieve forever. You will not 'get over' the loss of a loved one; you'll learn to live with it.\" - Elisabeth Kubler-Ross",
        "\"Grief is like the ocean; it comes on waves ebbing and flowing. Sometimes the water is calm, and sometimes it is overwhelming.\" - Vicki Harrison",
        "\"There is no pain so great as the memory of joy in present grief.\" - Aeschylus",
        "\"Grief is the last act of love we have to give to those we loved. Where there is deep grief, there was great love.\" - Unknown",
        "\"The pain of grief is just as much part of life as the joy of love; it is perhaps the price we pay for love.\" - Colin Murray Parkes",
        "\"Grief is not a disorder, a disease or a sign of weakness. It is an emotional, physical and spiritual necessity, the price you pay for love.\" - Earl Grollman",
        "\"Tears are the silent language of grief.\" - Voltaire",
        "\"Grief can be the garden of compassion. If you keep your heart open through everything, your pain can become your greatest ally.\" - Rumi",
        "\"Give sorrow words; the grief that does not speak knits up the o-er wrought heart and bids it break.\" - William Shakespeare",
        "\"Grief is a passage, not a place to stay.\" - Unknown",
        "\"The deeper that sorrow carves into your being, the more joy you can contain.\" - Kahlil Gibran",
        "\"Grief is the agony of an instant. The indulgence of grief the blunder of a life.\" - Benjamin Disraeli",
        "\"Grief is not a sign of weakness, nor a lack of faith. It is the price of love.\" - Unknown",
        "\"We must embrace pain and burn it as fuel for our journey.\" - Kenji Miyazawa",
        "\"Grief is like a long valley, a winding valley where any bend may reveal a totally new landscape.\" - C.S. Lewis",
        "\"The risk of love is loss, and the price of loss is grief. But the pain of grief is only a shadow when compared with the pain of never risking love.\" - Hilary Stanton Zunin",
        "\"Grief is the great leveler. It knows no boundaries of age, race, or social status.\" - Unknown",
        "\"To weep is to make less the depth of grief.\" - William Shakespeare",
        "\"Grief is a normal and natural response to loss. It is originally an unlearned feeling process.\" - John James",
        "\"Grief is love with no place to go.\" - Unknown",
        "\"The grief of the heart is known only to the one who feels it.\" - Nigerian Proverb",
        "\"Grief is a journey, often perilous and without clear direction.\" - Molly Fumia",
        "\"Grief is not something you complete, but rather you endure.\" - Unknown",
        "\"In grief, nothing stays put. One keeps emerging from a phase, but it always recurs.\" - C.S. Lewis",
        "\"Grief is a most peculiar thing; we're so helpless in the face of it.\" - Arthur Golden",
        "\"The darkness of grief can make us feel isolated and alone.\" - Unknown",
        "\"Grief is the unwelcome houseguest that overstays its welcome.\" - Unknown",
        "\"Sometimes grief is a comfort we grant ourselves.\" - Dean Koontz",
        "\"Grief is the healing process of the heart, soul and mind.\" - Unknown",
        "\"The pain of loss is a reflection of the joy that was shared.\" - Unknown",
        "\"Grief is love's souvenir. It's our proof that we once loved.\" - Unknown",
        "\"In the night of death, hope sees a star, and listening love can hear the rustle of a wing.\" - Robert Green Ingersoll",
        "\"Grief is the tribute we pay to love.\" - Unknown",
        "\"The grief doesn't go away, but it changes. It softens.\" - Unknown",
        "\"Grief is a solitary journey. No one but you knows how great the hurt is.\" - Suzanne Clothier",
        "\"Grief is the price of being close to another human being.\" - Unknown",
        "\"The pain passes, but the beauty remains.\" - Pierre Auguste Renoir",
        "\"Grief is a wound that needs attention in order to heal.\" - Unknown",
        "\"Sometimes you will never know the value of a moment until it becomes a memory.\" - Dr. Seuss",
        "\"Grief is love turned into an eternal missing.\" - Unknown",
        "\"The reality of grief is far different from what we imagine.\" - Joan Didion",
        "\"Grief is the emotional contract we sign when choosing to love.\" - Unknown",
        "\"In grief, we find the depths of our love.\" - Unknown",
        "\"Grief is the reminder that love was present.\" - Unknown",
        "\"The pain of parting is nothing to the joy of meeting again.\" - Charles Dickens",
        "\"Grief is a lifelong journey. There is no finish line.\" - Unknown",
        "\"Through grief, we learn the true meaning of love.\" - Unknown",
        "\"Grief is just love with nowhere to go.\" - Jamie Anderson",
        "\"The grief journey is as individual as a fingerprint.\" - Unknown",
        "\"In every parting there is an image of death.\" - George Eliot",
        "\"Grief teaches the steadiest minds to waver.\" - Sophocles",
        "\"Heavy hearts, like heavy clouds in the sky, are best relieved by the letting of a little water.\" - Christopher Morley",
        "\"Grief is a tidal wave that overtakes you, smashes down upon you with unimaginable force.\" - Stephanie Ericsson",
        "\"The worst part of losing someone isn't saying goodbye, it's learning to live without them.\" - Unknown",
        "\"Grief is the price we pay for being able to love.\" - Unknown",
        "\"We grieve because we have loved.\" - Unknown",
        "\"Grief is a sacred emotion, not something to overcome.\" - Unknown",
        "\"The grief we carry is part of the love we shared.\" - Unknown",
        "\"Grief is love in its most wild form.\" - Unknown",
        "\"The weight of grief is the weight of love unexpressed.\" - Unknown",
        "\"Grief is the shadow that love casts.\" - Unknown",
        "\"In grief, love persists.\" - Unknown",
        "\"Grief is the continuation of love.\" - Unknown",
        "\"The depth of grief is equal to the height of love.\" - Unknown",
        "\"Grief is love looking for a home.\" - Unknown",
        "\"In grief, we discover how much we truly loved.\" - Unknown",
        "\"Grief is the tax we pay on our attachments.\" - Unknown",
        "\"The grief we feel is the love we shared.\" - Unknown",
        "\"Grief is love in different clothing.\" - Unknown",
        "\"The pain of loss teaches us the value of presence.\" - Unknown",
        "\"Grief is the echo of love.\" - Unknown",
        "\"In grief, we find the evidence of our capacity to love.\" - Unknown",
        "\"Grief is love's tribute.\" - Unknown",
        "\"The grief we bear is proportional to the love we shared.\" - Unknown",
        "\"Grief is the price tag of love.\" - Unknown",
        "\"In grief, love lives on.\" - Unknown",
        "\"Grief is love's shadow.\" - Unknown",
        "\"The pain of grief is the pain of continuing to love.\" - Unknown",
        "\"Grief is love persevering.\" - Unknown",
        "\"In grief, we honor the love that was.\" - Unknown",
        "\"Grief is the heart's way of honoring love.\" - Unknown",
        "\"The grief journey is love's pilgrimage.\" - Unknown",
        "\"Grief is love with broken wings.\" - Unknown",
        "\"In grief, love finds new expression.\" - Unknown",
        "\"Grief is the soul's testimony to love.\" - Unknown",
        "\"The pain of grief is love's labor.\" - Unknown",
        "\"Grief is love in the key of longing.\" - Unknown",
        "\"In grief, we discover love's permanence.\" - Unknown",
        "\"Grief is the memorial love builds.\" - Unknown",
        "\"The grief we carry is love we keep.\" - Unknown",
        "\"Grief is love's afterglow.\" - Unknown",
        "\"In grief, love transforms but never dies.\" - Unknown",
        "\"Grief is the keeper of love's flame.\" - Unknown",
        "\"The pain of grief guards the treasure of love.\" - Unknown",
        "\"Grief is love's loyalty.\" - Unknown",
        "\"In grief, we learn love's true depth.\" - Unknown",
        "\"Grief is the price love pays for permanence.\" - Unknown",
        "\"The grief we feel is love's immortality.\" - Unknown",
        "\"Grief is love refusing to let go.\" - Unknown",
        "\"In grief, love writes its final chapter.\" - Unknown",
        "\"Grief is the signature love leaves behind.\" - Unknown",
        "\"The tears of grief water the garden of love.\" - Unknown",
        "\"Grief is love's most honest expression.\" - Unknown",
        "\"In grief, we feel love's true weight.\" - Unknown",
        "\"Grief is the price of loving fully.\" - Unknown",
        "\"The sorrow of grief contains the seeds of love.\" - Unknown",
        "\"Grief is love without a destination.\" - Unknown",
        "\"In grief, we learn that love never dies.\" - Unknown",
        "\"Grief is the bridge between love and memory.\" - Unknown",
        "\"The pain of grief validates the power of love.\" - Unknown",
        "\"Grief is love's longest letter.\" - Unknown",
        "\"In grief, love finds its truest voice.\" - Unknown",
        "\"Grief is the silence where love still speaks.\" - Unknown",
        "\"The emptiness of grief is filled with love's presence.\" - Unknown",
        "\"Grief is love's way of saying goodbye.\" - Unknown",
        "\"In grief, we touch the infinite nature of love.\" - Unknown",
        "\"Grief is the proof that love survives all.\" - Unknown",
        "\"The darkness of grief cannot extinguish love's light.\" - Unknown",
        "\"Grief is love's most faithful companion.\" - Unknown",
        "\"In grief, we learn that love transcends time.\" - Unknown",
        
        // Hope and Healing (Days 151-250)
        "\"Hope is the thing with feathers that perches in the soul.\" - Emily Dickinson",
        "\"Even the darkest night will end and the sun will rise.\" - Victor Hugo",
        "\"Hope is being able to see that there is light despite all of the darkness.\" - Desmond Tutu",
        "\"We must accept finite disappointment, but never lose infinite hope.\" - Martin Luther King Jr.",
        "\"Hope is the only thing stronger than fear.\" - Suzanne Collins",
        "\"Where there is hope, there is faith. Where there is faith, miracles happen.\" - Unknown",
        "\"Hope is the companion of power, and mother of success.\" - Samuel Smiles",
        "\"Hope is a waking dream.\" - Aristotle",
        "\"Once you choose hope, anything's possible.\" - Christopher Reeve",
        "\"Hope is the heartbeat of the soul.\" - Michelle Horst",
        "\"Hope sees the invisible, feels the intangible, and achieves the impossible.\" - Helen Keller",
        "\"Hope is a good breakfast, but it is a bad supper.\" - Francis Bacon",
        "\"Hope is the power of being cheerful in circumstances that we know to be desperate.\" - G.K. Chesterton",
        "\"The road that is built in hope is more pleasant to the traveler than the road built in despair.\" - Marion Zimmer Bradley",
        "\"Hope is patience with the lamp lit.\" - Tertullian",
        "\"Hope is the dream of a waking man.\" - French Proverb",
        "\"While there's life, there's hope.\" - Marcus Tullius Cicero",
        "\"Hope is the physician of each misery.\" - Irish Proverb",
        "\"Hope is a force of nature. Don't let anyone tell you different.\" - Jim Butcher",
        "\"Hope is not a strategy, but it is a starting point.\" - Unknown",
        "\"In the midst of winter, I found there was, within me, an invincible summer.\" - Albert Camus",
        "\"Hope is the light that guides us through the darkness.\" - Unknown",
        "\"Hope whispers, 'Try it one more time.'\" - Unknown",
        "\"Hope is the anchor of the soul.\" - Hebrews 6:19",
        "\"Where flowers bloom, so does hope.\" - Lady Bird Johnson",
        "\"Hope is a beautiful thing. It gives us peace and strength, and keeps us going when all seems lost.\" - Unknown",
        "\"Hope is the belief that the future will be better than the present.\" - Unknown",
        "\"Stars can't shine without darkness.\" - Unknown",
        "\"Hope begins in the dark.\" - Anne Lamott",
        "\"There is hope, even when your brain tells you there isn't.\" - John Green",
        "\"Hope is the light at the end of the tunnel.\" - Unknown",
        "\"Hope means hoping when everything seems hopeless.\" - G.K. Chesterton",
        "\"The best way to not feel hopeless is to get up and do something.\" - Barack Obama",
        "\"Hope is a renewable option: If you run out of it at the end of the day, you get to start over in the morning.\" - Barbara Kingsolver",
        "\"Hope is the feeling that the feeling you have isn't permanent.\" - Jean Kerr",
        "\"However long the night, the dawn will break.\" - African Proverb",
        "\"Hope springs eternal in the human breast.\" - Alexander Pope",
        "\"The very least you can do in your life is figure out what you hope for.\" - Barbara Kingsolver",
        "\"Hope is not found in a way out but a way through.\" - Robert Frost",
        "\"Hope is the last thing ever lost.\" - Italian Proverb",
        "\"Hope is putting faith to work when doubting would be easier.\" - Unknown",
        "\"A single thread of hope is still a very powerful thing.\" - Unknown",
        "\"Hope is the promise that things will get better.\" - Unknown",
        "\"Never lose hope. Storms make people stronger and never last forever.\" - Roy T. Bennett",
        "\"Hope is a gift we give ourselves.\" - Unknown",
        "\"Hope is the rainbow over the waterfall of despair.\" - Unknown",
        "\"When you have lost hope, you have lost everything.\" - Unknown",
        "\"Hope costs nothing.\" - Colette",
        "\"Hope is the poor man's bread.\" - Gary Herbert",
        "\"Hope smiles from the threshold of the year to come.\" - Alfred Lord Tennyson",
        "\"Healing is a matter of time, but it is sometimes also a matter of opportunity.\" - Hippocrates",
        "\"The wound is the place where the Light enters you.\" - Rumi",
        "\"Healing doesn't mean the damage never existed. It means the damage no longer controls your life.\" - Akshay Dubey",
        "\"Time doesn't heal all wounds, but it does provide the opportunity for healing.\" - Unknown",
        "\"Healing is not linear.\" - Unknown",
        "\"The soul always knows what to do to heal itself. The challenge is to silence the mind.\" - Caroline Myss",
        "\"Healing requires from us to stop struggling, but to surrender.\" - Unknown",
        "\"Healing takes courage, and we all have courage, even if we have to dig a little to find it.\" - Tori Amos",
        "\"Eventually you will come to understand that love heals everything.\" - Gary Zukav",
        "\"Healing is an art. It takes time, it takes practice. It takes love.\" - Maza Dohta",
        "\"The greatest healing therapy is friendship and love.\" - Hubert H. Humphrey",
        "\"Healing comes in waves and maybe today the wave hits the rocks.\" - Ijeoma Umebinyuo",
        "\"We are healed of a suffering only by experiencing it to the full.\" - Marcel Proust",
        "\"Healing is a process. It takes time. It takes patience. It takes everything.\" - Unknown",
        "\"The practice of forgiveness is our most important contribution to the healing of the world.\" - Marianne Williamson",
        "\"Healing is not an overnight process. It is a daily cleansing of pain.\" - Leon Brown",
        "\"The healing power of love can work miracles.\" - Unknown",
        "\"Healing begins when we acknowledge our wounds.\" - Unknown",
        "\"Sometimes healing looks like falling apart first.\" - Unknown",
        "\"Healing is embracing what is most feared.\" - Jeanne Achterberg",
        "\"Your healing is your responsibility.\" - Unknown",
        "\"Healing is the journey. The destination is yourself.\" - Unknown",
        "\"The only way out is through.\" - Robert Frost",
        "\"Healing happens when we make peace with our broken pieces.\" - Unknown",
        "\"In the process of healing, you will lose many things from the past, but you will find yourself.\" - Unknown",
        "\"Healing is about accepting, not erasing.\" - Unknown",
        "\"Sometimes the healing is in the aching.\" - Unknown",
        "\"Healing begins with acceptance and culminates in letting go.\" - Unknown",
        "\"The wound that bleeds inwardly is the most dangerous.\" - Latin Proverb",
        "\"Healing is remembering who you are beneath the pain.\" - Unknown",
        "\"Hope is the first step towards healing.\" - Unknown",
        "\"In hope, we find the strength to heal.\" - Unknown",
        "\"Healing hope whispers of better days.\" - Unknown",
        "\"Hope is the medicine of the mind.\" - Unknown",
        "\"With hope, all healing is possible.\" - Unknown",
        "\"Hope heals the heart that grief has broken.\" - Unknown",
        "\"In hope, we find the courage to continue.\" - Unknown",
        "\"Hope is the bridge between despair and healing.\" - Unknown",
        "\"Where hope grows, healing follows.\" - Unknown",
        "\"Hope is the seed from which healing blooms.\" - Unknown",
        "\"In the garden of hope, healing flowers bloom.\" - Unknown",
        "\"Hope illuminates the path to healing.\" - Unknown",
        "\"With hope as our compass, we navigate towards healing.\" - Unknown",
        "\"Hope is the sunrise after grief's long night.\" - Unknown",
        "\"In hope, we discover our resilience.\" - Unknown",
        "\"Hope transforms wounds into wisdom.\" - Unknown",
        "\"Through hope, we find grace in grief.\" - Unknown",
        "\"Hope is the gentle rain that nurtures healing.\" - Unknown",
        "\"In hope's embrace, we find peace.\" - Unknown",
        "\"Hope writes the next chapter when grief ends the page.\" - Unknown",
        "\"Hope is the thread that weaves healing into our hearts.\" - Unknown",
        "\"In hope, we find the courage to love again.\" - Unknown",
        "\"Hope is the key that unlocks the door to healing.\" - Unknown",
        "\"Through hope, we transform pain into purpose.\" - Unknown",
        "\"Hope is the gentle voice that says, 'You will be okay.'\" - Unknown",
        "\"In hope, we find the strength to rebuild.\" - Unknown",
        "\"Hope is the foundation upon which healing is built.\" - Unknown",
        "\"Through hope, we learn to dance with sorrow.\" - Unknown",
        "\"Hope is the compass that guides us home to ourselves.\" - Unknown",
        "\"In hope, we find the gift of tomorrow.\" - Unknown",
        "\"Hope is the light that illuminates our darkest hours.\" - Unknown",
        "\"Through hope, we discover that broken can be beautiful.\" - Unknown",
        
        // Strength and Getting Through Hard Times (Days 251-365)
        "\"This too shall pass.\" - Persian Proverb",
        "\"Rock bottom became the solid foundation on which I rebuilt my life.\" - J.K. Rowling",
        "\"The human spirit is stronger than anything that can happen to it.\" - C.C. Scott",
        "\"You never know how strong you are until being strong is your only choice.\" - Bob Marley",
        "\"Tough times never last, but tough people do.\" - Robert H. Schuller",
        "\"The oak fought the wind and was broken, the willow bent when it must and survived.\" - Robert Jordan",
        "\"We must embrace pain and burn it as fuel for our journey.\" - Kenji Miyazawa",
        "\"The gem cannot be polished without friction, nor man perfected without trials.\" - Chinese Proverb",
        "\"In the middle of difficulty lies opportunity.\" - Albert Einstein",
        "\"When we are no longer able to change a situation, we are challenged to change ourselves.\" - Viktor E. Frankl",
        "\"The darkest hour has only sixty minutes.\" - Morris Mandel",
        "\"Every adversity, every failure, every heartache carries with it the seed of an equal or greater benefit.\" - Napoleon Hill",
        "\"Life isn't about waiting for the storm to pass. It's about learning how to dance in the rain.\" - Vivian Greene",
        "\"You are braver than you believe, stronger than you seem, and smarter than you think.\" - A.A. Milne",
        "\"Sometimes you don't realize your own strength until you come face to face with your greatest weakness.\" - Susan Gale",
        "\"Strength doesn't come from what you can do. It comes from overcoming the things you once thought you couldn't.\" - Rikki Rogers",
        "\"The struggle you're in today is developing the strength you need for tomorrow.\" - Unknown",
        "\"Hard times may have held you down, but they will not last forever.\" - Joel Osteen",
        "\"When everything seems to be going against you, remember that the airplane takes off against the wind.\" - Henry Ford",
        "\"The strongest people are not those who show strength in front of us but those who win battles we know nothing about.\" - Unknown",
        "\"Fall seven times, stand up eight.\" - Japanese Proverb",
        "\"It's not the load that breaks you down, it's the way you carry it.\" - Lou Holtz",
        "\"The pain you feel today is the strength you feel tomorrow.\" - Unknown",
        "\"Difficulties are meant to rouse, not discourage. The human spirit is to grow strong by conflict.\" - William Ellery Channing",
        "\"You have power over your mind - not outside events. Realize this, and you will find strength.\" - Marcus Aurelius",
        "\"A smooth sea never made a skilled sailor.\" - Franklin D. Roosevelt",
        "\"The only way out is through.\" - Robert Frost",
        "\"What lies behind us and what lies before us are tiny matters compared to what lies within us.\" - Ralph Waldo Emerson",
        "\"When you come out of the storm, you won't be the same person who walked in.\" - Haruki Murakami",
        "\"Sometimes it takes a good fall to really know where you stand.\" - Hayley Williams",
        "\"The world breaks everyone, and afterward, some are strong at the broken places.\" - Ernest Hemingway",
        "\"Turn your wounds into wisdom.\" - Oprah Winfrey",
        "\"Stars can't shine without darkness.\" - Unknown",
        "\"The harder the battle, the sweeter the victory.\" - Les Brown",
        "\"Strength grows in the moments when you think you can't go on but you keep going anyway.\" - Unknown",
        "\"Every storm runs out of rain.\" - Maya Angelou",
        "\"You were given this life because you are strong enough to live it.\" - Unknown",
        "\"The strongest hearts have the most scars.\" - Unknown",
        "\"Don't be pushed by your problems. Be led by your dreams.\" - Ralph Waldo Emerson",
        "\"The sun himself is weak when he first rises, and gathers strength and courage as the day gets on.\" - Charles Dickens",
        "\"One small crack does not mean that you are broken, it means that you were put to the test and you didn't fall apart.\" - Linda Poindexter",
        "\"Courage doesn't always roar. Sometimes courage is the quiet voice at the end of the day saying, 'I will try again tomorrow.'\" - Mary Anne Radmacher",
        "\"You may have to fight a battle more than once to win it.\" - Margaret Thatcher",
        "\"The bamboo that bends is stronger than the oak that resists.\" - Japanese Proverb",
        "\"Rivers know this: there is no hurry. We shall get there some day.\" - A.A. Milne",
        "\"Just when the caterpillar thought the world was ending, he turned into a butterfly.\" - Proverb",
        "\"Although the world is full of suffering, it is also full of the overcoming of it.\" - Helen Keller",
        "\"We are all broken, that's how the light gets in.\" - Ernest Hemingway",
        "\"The only way to get through hard times is to get through them.\" - Unknown",
        "\"Storms make trees take deeper roots.\" - Dolly Parton",
        "\"Remember that guy that gave up? Neither does anyone else.\" - Unknown",
        "\"It does not matter how slowly you go as long as you do not stop.\" - Confucius",
        "\"Our greatest glory is not in never falling, but in rising every time we fall.\" - Confucius",
        "\"Persistence is the twin sister of excellence.\" - Marabel Morgan",
        "\"The difference between a successful person and others is not lack of strength not a lack of knowledge but rather a lack of will.\" - Vince Lombardi",
        "\"Success is not final, failure is not fatal: it is the courage to continue that counts.\" - Winston Churchill",
        "\"When you feel like giving up, remember why you held on for so long in the first place.\" - Unknown",
        "\"The moment you're ready to quit is usually the moment right before a miracle happens.\" - Unknown",
        "\"It always seems impossible until it's done.\" - Nelson Mandela",
        "\"Character consists of what you do on the third and fourth tries.\" - James A. Michener",
        "\"Many of life's failures are people who did not realize how close they were to success when they gave up.\" - Thomas Edison",
        "\"A river cuts through rock, not because of its power, but because of its persistence.\" - Jim Watkins",
        "\"The man who moves a mountain begins by carrying away small stones.\" - Confucius",
        "\"Persistence can change failure into extraordinary achievement.\" - Matt Biondi",
        "\"Energy and persistence conquer all things.\" - Benjamin Franklin",
        "\"Through persistence, many people win success out of what seemed destined to be certain failure.\" - Benjamin Disraeli",
        "\"Nothing in this world can take the place of persistence.\" - Calvin Coolidge",
        "\"The most essential factor is persistence - the determination never to allow your energy or enthusiasm to be dampened.\" - James Whitcomb Riley",
        "\"Permanence, perseverance and persistence in spite of all obstacles, discouragements, and impossibilities.\" - Thomas Carlyle",
        "\"Keep going. Everything you need will come to you at the perfect time.\" - Unknown",
        "\"Sometimes life is about risking everything for a dream no one can see but you.\" - Unknown",
        "\"Courage is not the absence of fear, but the triumph over it.\" - Nelson Mandela",
        "\"Being deeply loved by someone gives you strength, while loving someone deeply gives you courage.\" - Lao Tzu",
        "\"Courage is grace under pressure.\" - Ernest Hemingway",
        "\"It takes courage to grow up and become who you really are.\" - E.E. Cummings",
        "\"Courage is the most important of all the virtues because without courage, you can't practice any other virtue consistently.\" - Maya Angelou",
        "\"You can choose courage, or you can choose comfort, but you cannot choose both.\" - Brené Brown",
        "\"Courage starts with showing up and letting ourselves be seen.\" - Brené Brown",
        "\"Courage is not having the strength to go on; it is going on when you don't have the strength.\" - Theodore Roosevelt",
        "\"Life shrinks or expands in proportion to one's courage.\" - Anaïs Nin",
        "\"Have courage for the great sorrows of life and patience for the small ones.\" - Victor Hugo",
        "\"Courage is resistance to fear, mastery of fear, not absence of fear.\" - Mark Twain",
        "\"All our dreams can come true, if we have the courage to pursue them.\" - Walt Disney",
        "\"The secret of happiness is freedom, the secret of freedom is courage.\" - Carrie Jones",
        "\"Courage is what it takes to stand up and speak; courage is also what it takes to sit down and listen.\" - Winston Churchill",
        "\"He who is not courageous enough to take risks will accomplish nothing in life.\" - Muhammad Ali",
        "\"Courage is the discovery that you may not win, and trying when you know you can lose.\" - Tom Krause",
        "\"Sometimes the smallest step in the right direction ends up being the biggest step of your life.\" - Unknown",
        "\"Real courage is when you know you're licked before you begin, but you begin anyway.\" - Harper Lee",
        "\"Courage is being scared to death, but saddling up anyway.\" - John Wayne",
        "\"Faith is taking the first step even when you don't see the whole staircase.\" - Martin Luther King Jr.",
        "\"Faith is the bird that feels the light when the dawn is still dark.\" - Rabindranath Tagore",
        "\"Faith is not the belief that everything will be okay, but the belief that you will be okay no matter how things turn out.\" - Unknown",
        "\"Keep faith. The most amazing things in life tend to happen right at the moment you're about to give up hope.\" - Unknown",
        "\"Faith is the strength by which a shattered world shall emerge into the light.\" - Helen Keller",
        "\"Faith does not eliminate questions. But faith knows where to take them.\" - Elisabeth Elliot",
        "\"Sometimes when you're in a dark place you think you've been buried, but actually you've been planted.\" - Unknown",
        "\"Faith is daring the soul to go beyond what the eyes can see.\" - William Newton Clark",
        "\"Faith is the art of holding on to things in spite of your changing moods and circumstances.\" - C.S. Lewis",
        "\"When you have come to the edge of all light that you know and are about to drop off into the darkness, faith is knowing one of two things will happen.\" - Patrick Overton",
        "\"Let your faith be bigger than your fear.\" - Unknown",
        "\"Faith is a knowledge within the heart, beyond the reach of proof.\" - Kahlil Gibran",
        "\"Faith is the substance of things hoped for, the evidence of things not seen.\" - Hebrews 11:1",
        "\"Faith makes all things possible. Love makes all things easy.\" - Dwight L. Moody",
        "\"Feed your faith and your doubts will starve to death.\" - Unknown",
        "\"A little faith will bring your soul to heaven; a great faith will bring heaven to your soul.\" - Charles Spurgeon",
        "\"Faith is like radar that sees through the fog.\" - Corrie Ten Boom",
        "\"Faith is the light that guides you through the darkness.\" - Unknown",
        "\"Never be afraid to trust an unknown future to a known God.\" - Corrie Ten Boom",
        "\"Faith is not believing that God can, it's knowing that He will.\" - Unknown",
        "\"The best way to find yourself is to lose yourself in the service of others.\" - Mahatma Gandhi",
        "\"We make a living by what we get, but we make a life by what we give.\" - Winston Churchill",
        "\"At the end of life, what really matters is not what we bought but what we built; not what we got but what we shared.\" - Unknown",
        "\"Love never dies. It lives on in the hearts of those touched by its beauty.\" - Unknown"
    ]
    
    init() {
        loadImages()
        initializeMixedQuotes()
    }
    
    private func initializeMixedQuotes() {
        // Create properly mixed quotes cycling through categories
        let loveQuotes = [
            "\"The love we share transcends all boundaries, even those of life and death.\" - Unknown",
            "\"Those we love don't go away, they walk beside us every day.\" - Unknown",
            "\"Love is stronger than death even though it can't stop death from happening.\" - Unknown",
            "\"What we have once enjoyed we can never lose. All that we love deeply becomes a part of us.\" - Helen Keller",
            "\"Unable are the loved to die, for love is immortality.\" - Emily Dickinson",
            "\"The bond between a mother and child is not measured in time, but in love.\" - Unknown",
            "\"Love knows not its own depth until the hour of separation.\" - Kahlil Gibran",
            "\"Where there is deep grief, there was great love.\" - Unknown",
            "\"The heart that loves is always young.\" - Greek Proverb",
            "\"Love leaves a memory no one can steal.\" - Unknown",
            "\"Death ends a life, not a relationship.\" - Mitch Albom",
            "\"Love is how you stay alive, even after you are gone.\" - Mitch Albom"
        ]
        
        let griefQuotes = [
            "\"Grief is the price we pay for love.\" - Queen Elizabeth II",
            "\"The reality is that you will grieve forever. You will not 'get over' the loss of a loved one; you'll learn to live with it.\" - Elisabeth Kubler-Ross",
            "\"Grief is like the ocean; it comes on waves ebbing and flowing. Sometimes the water is calm, and sometimes it is overwhelming.\" - Vicki Harrison",
            "\"There is no pain so great as the memory of joy in present grief.\" - Aeschylus",
            "\"Grief is the last act of love we have to give to those we loved. Where there is deep grief, there was great love.\" - Unknown",
            "\"The pain of grief is just as much part of life as the joy of love; it is perhaps the price we pay for love.\" - Colin Murray Parkes",
            "\"Grief is not a disorder, a disease or a sign of weakness. It is an emotional, physical and spiritual necessity, the price you pay for love.\" - Earl Grollman",
            "\"Tears are the silent language of grief.\" - Voltaire",
            "\"Grief can be the garden of compassion. If you keep your heart open through everything, your pain can become your greatest ally.\" - Rumi",
            "\"Give sorrow words; the grief that does not speak knits up the o-er wrought heart and bids it break.\" - William Shakespeare",
            "\"Grief is a passage, not a place to stay.\" - Unknown",
            "\"The deeper that sorrow carves into your being, the more joy you can contain.\" - Kahlil Gibran"
        ]
        
        let hopeQuotes = [
            "\"Hope is the thing with feathers that perches in the soul.\" - Emily Dickinson",
            "\"Even the darkest night will end and the sun will rise.\" - Victor Hugo",
            "\"Hope is being able to see that there is light despite all of the darkness.\" - Desmond Tutu",
            "\"We must accept finite disappointment, but never lose infinite hope.\" - Martin Luther King Jr.",
            "\"Hope is the only thing stronger than fear.\" - Suzanne Collins",
            "\"Where there is hope, there is faith. Where there is faith, miracles happen.\" - Unknown",
            "\"Hope is the companion of power, and mother of success.\" - Samuel Smiles",
            "\"Hope is a waking dream.\" - Aristotle",
            "\"Once you choose hope, anything's possible.\" - Christopher Reeve",
            "\"Hope is the heartbeat of the soul.\" - Michelle Horst",
            "\"Hope sees the invisible, feels the intangible, and achieves the impossible.\" - Helen Keller",
            "\"In the midst of winter, I found there was, within me, an invincible summer.\" - Albert Camus"
        ]
        
        let strengthQuotes = [
            "\"This too shall pass.\" - Persian Proverb",
            "\"Rock bottom became the solid foundation on which I rebuilt my life.\" - J.K. Rowling",
            "\"The human spirit is stronger than anything that can happen to it.\" - C.C. Scott",
            "\"You never know how strong you are until being strong is your only choice.\" - Bob Marley",
            "\"Tough times never last, but tough people do.\" - Robert H. Schuller",
            "\"The oak fought the wind and was broken, the willow bent when it must and survived.\" - Robert Jordan",
            "\"In the middle of difficulty lies opportunity.\" - Albert Einstein",
            "\"When we are no longer able to change a situation, we are challenged to change ourselves.\" - Viktor E. Frankl",
            "\"The darkest hour has only sixty minutes.\" - Morris Mandel",
            "\"Life isn't about waiting for the storm to pass. It's about learning how to dance in the rain.\" - Vivian Greene",
            "\"You are braver than you believe, stronger than you seem, and smarter than you think.\" - A.A. Milne",
            "\"The struggle you're in today is developing the strength you need for tomorrow.\" - Unknown"
        ]
        
        // Mix quotes by cycling through categories
        var mixedQuotes: [String] = []
        let maxQuotes = 365
        let categories = [loveQuotes, griefQuotes, hopeQuotes, strengthQuotes]
        
        var categoryIndex = 0
        var quoteIndices = [0, 0, 0, 0] // Track position in each category
        
        for _ in 1...maxQuotes {
            let currentCategory = categories[categoryIndex]
            let currentQuoteIndex = quoteIndices[categoryIndex]
            
            if currentQuoteIndex < currentCategory.count {
                mixedQuotes.append(currentCategory[currentQuoteIndex])
                quoteIndices[categoryIndex] += 1
            } else {
                // If we've run out of quotes in this category, cycle back to beginning
                mixedQuotes.append(currentCategory[currentQuoteIndex % currentCategory.count])
                quoteIndices[categoryIndex] = (currentQuoteIndex + 1) % currentCategory.count
            }
            
            // Move to next category
            categoryIndex = (categoryIndex + 1) % categories.count
        }
        
        quotes = mixedQuotes
        print("PhotoStore: Initialized with \(quotes.count) mixed quotes")
    }
    
    // Cache for today's photo to ensure it never changes
    private var todaysPhotoCache: UIImage?
    private var todaysPhotoCacheDate: String = ""
    
    // Get today's photo (persistent selection)
    func getTodaysPhoto() -> UIImage? {
        // Get today's date string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())
        
        // If we have a cached photo for today, always return it (even if images array is temporarily empty)
        if todaysPhotoCacheDate == todayString && todaysPhotoCache != nil {
            print("PhotoStore: Returning cached photo for \(todayString)")
            return todaysPhotoCache
        }
        
        // Only proceed if we have images available
        guard !images.isEmpty else { 
            print("PhotoStore.getTodaysPhoto: No images available (count: \(images.count))")
            return nil
        }
        
        // Check if we already have a photo selected for today
        if todaysPhotoDateStore == todayString && !todaysPhotoFilename.isEmpty {
            // Find the previously selected photo by filename
            if let index = imageFilenames.firstIndex(of: todaysPhotoFilename),
               index < images.count {
                let photo = images[index]
                // Cache it
                todaysPhotoCache = photo
                todaysPhotoCacheDate = todayString
                print("PhotoStore: Found stored photo by filename for \(todayString)")
                return photo
            }
            // If filename not found, fall through to select a new photo
        }
        
        // Select a new photo for today using consistent daily selection
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        
        let selectedIndex: Int
        if images.count <= 365 {
            // Use sequential selection if 365 or fewer photos
            selectedIndex = (dayOfYear - 1) % images.count
        } else {
            // Use seeded random selection for consistent daily photo
            var generator = SeededRandomNumberGenerator(seed: UInt64(dayOfYear))
            selectedIndex = Int.random(in: 0..<images.count, using: &generator)
        }
        
        // Store this selection for today using filename
        if selectedIndex < imageFilenames.count {
            todaysPhotoFilename = imageFilenames[selectedIndex]
            todaysPhotoDateStore = todayString
            let photo = images[selectedIndex]
            // Cache it
            todaysPhotoCache = photo
            todaysPhotoCacheDate = todayString
            print("PhotoStore: Selected new photo for \(todayString)")
        }
        
        return images[selectedIndex]
    }
    
    // Get today's quote
    func getTodaysQuote() -> String {
        // Use HistoricalQuoteManager to ensure today's quote is also persistent
        return HistoricalQuoteManager.shared.getQuoteForDate(Date(), from: quotes)
    }
    
    // Save images to disk
    func saveImages() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageDirectory = documentsPath.appendingPathComponent("MemorialImages")
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: imageDirectory, withIntermediateDirectories: true)
        
        print("PhotoStore.saveImages: Starting save of \(images.count) images")
        
        // First, clean up ALL existing image files
        do {
            let existingFiles = try FileManager.default.contentsOfDirectory(at: imageDirectory, includingPropertiesForKeys: nil)
            for fileURL in existingFiles {
                let filename = fileURL.lastPathComponent
                if filename.hasPrefix("image_") && filename.hasSuffix(".jpg") {
                    try FileManager.default.removeItem(at: fileURL)
                }
            }
            print("PhotoStore.saveImages: Cleaned up old files")
        } catch {
            print("Error cleaning up old files: \(error)")
        }
        
        // Then save all current images with fresh numbering
        for (index, image) in images.enumerated() {
            if let imageData = image.jpegData(compressionQuality: 0.6) {
                let imageURL = imageDirectory.appendingPathComponent("image_\(String(format: "%04d", index)).jpg")
                do {
                    try imageData.write(to: imageURL)
                } catch {
                    print("Error saving image \(index): \(error)")
                }
            }
        }
        
        print("PhotoStore.saveImages: Successfully saved \(images.count) images to disk")
    }
    
    // Load images from disk
    func loadImages() {
        print("PhotoStore.loadImages: Called - current image count: \(images.count)")
        
        // Perform file operations on background queue for better performance
        DispatchQueue.global(qos: .userInitiated).async {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let imageDirectory = documentsPath.appendingPathComponent("MemorialImages")
            
            guard FileManager.default.fileExists(atPath: imageDirectory.path) else {
                print("PhotoStore.loadImages: No saved images found")
                return
            }
            
            do {
                let imageFiles = try FileManager.default.contentsOfDirectory(at: imageDirectory, includingPropertiesForKeys: nil)
                
                // Filter and sort image files properly by index
                let validImageFiles = imageFiles.filter { $0.lastPathComponent.hasPrefix("image_") && $0.lastPathComponent.hasSuffix(".jpg") }
                let sortedFiles = validImageFiles.sorted { url1, url2 in
                    let name1 = url1.lastPathComponent
                    let name2 = url2.lastPathComponent
                    let index1 = Int(String(name1.dropFirst(6).dropLast(4))) ?? 0
                    let index2 = Int(String(name2.dropFirst(6).dropLast(4))) ?? 0
                    return index1 < index2
                }
                
                var loadedImages: [UIImage] = []
                var loadedFilenames: [String] = []
                
                for imageURL in sortedFiles {
                    autoreleasepool {
                        if let imageData = try? Data(contentsOf: imageURL),
                           let image = UIImage(data: imageData) {
                            loadedImages.append(image)
                            loadedFilenames.append(imageURL.lastPathComponent)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    print("PhotoStore.loadImages: Updating images array - OLD count: \(self.images.count), NEW count: \(loadedImages.count)")
                    if !loadedImages.isEmpty {
                        self.images = loadedImages
                        self.imageFilenames = loadedFilenames
                        print("PhotoStore.loadImages: Loaded \(loadedImages.count) images successfully")
                    } else {
                        print("PhotoStore.loadImages: No valid images found to load")
                    }
                }
            } catch {
                print("Error loading images: \(error)")
            }
        }
    }
    
    // Add images and save to disk
    func addImages(_ newImages: [UIImage]) {
        images.append(contentsOf: newImages)
        saveImages()
    }
    
    // Remove image and save to disk - instant UI update, fast file removal
    func removeImage(at index: Int) {
        guard index >= 0 && index < images.count else { return }
        
        // Remove from UI immediately
        images.remove(at: index)
        
        // Fast file removal - just rebuild the file system quickly
        quickSaveImages()
        
        print("PhotoStore: Removed image at index \(index), now have \(images.count) images")
    }
    
    // Fast save - optimized for deletions
    private func quickSaveImages() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageDirectory = documentsPath.appendingPathComponent("MemorialImages")
        
        // Create directory if needed
        try? FileManager.default.createDirectory(at: imageDirectory, withIntermediateDirectories: true)
        
        // Background save to avoid UI blocking
        DispatchQueue.global(qos: .userInitiated).async {
            // Clean and save in background
            do {
                // Remove all old files
                let existingFiles = try FileManager.default.contentsOfDirectory(at: imageDirectory, includingPropertiesForKeys: nil)
                for fileURL in existingFiles {
                    let filename = fileURL.lastPathComponent
                    if filename.hasPrefix("image_") && filename.hasSuffix(".jpg") {
                        try FileManager.default.removeItem(at: fileURL)
                    }
                }
                
                // Save current images
                for (index, image) in self.images.enumerated() {
                    if let imageData = image.jpegData(compressionQuality: 0.6) {
                        let imageURL = imageDirectory.appendingPathComponent("image_\(String(format: "%04d", index)).jpg")
                        try imageData.write(to: imageURL)
                    }
                }
                
                print("PhotoStore: Quick save completed - \(self.images.count) images")
            } catch {
                print("Error in quick save: \(error)")
            }
        }
    }
}

// Historical Photo Manager - Permanent photo assignments for past dates
class HistoricalPhotoManager {
    static let shared = HistoricalPhotoManager()
    private let userDefaults = UserDefaults.standard
    private let historicalPhotosKey = "historicalPhotoAssignments"
    
    private init() {}
    
    // Get photo for a specific date - if it doesn't exist, assign one permanently
    func getPhotoForDate(_ date: Date, from photoStore: PhotoStore) -> UIImage? {
        guard !photoStore.images.isEmpty else { 
            print("HistoricalPhotoManager: No images in PhotoStore")
            return nil 
        }
        
        let dateKey = dateKeyForDate(date)
        let fullKey = "\(historicalPhotosKey)_\(dateKey)"
        
        print("HistoricalPhotoManager: Getting photo for date \(dateKey) with key \(fullKey)")
        
        // Check if we already have a photo for this date
        if let photoData = userDefaults.data(forKey: fullKey),
           let photo = UIImage(data: photoData) {
            print("HistoricalPhotoManager: Retrieved existing photo for \(dateKey) - data size: \(photoData.count) bytes")
            return photo
        }
        
        print("HistoricalPhotoManager: No existing photo found for \(dateKey) - will create new assignment")
        
        // No photo assigned yet - create permanent assignment
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        let yearComponent = Calendar.current.component(.year, from: date)
        let yearOffset = yearComponent - 2000
        
        // Prime number hash for unique date-photo mapping
        let hash = (dayOfYear + yearOffset) * 73 + 37
        let photoIndex = hash % photoStore.images.count
        
        let photo = photoStore.images[photoIndex]
        
        // Save this photo permanently for this date
        if let photoData = photo.jpegData(compressionQuality: 0.6) {
            userDefaults.set(photoData, forKey: "\(historicalPhotosKey)_\(dateKey)")
            userDefaults.synchronize() // Force immediate save
            print("HistoricalPhotoManager: Permanently assigned photo index \(photoIndex) to \(dateKey) and synchronized")
            
            // Verify save was successful
            if userDefaults.data(forKey: "\(historicalPhotosKey)_\(dateKey)") != nil {
                print("HistoricalPhotoManager: Verified photo was saved successfully for \(dateKey)")
            } else {
                print("HistoricalPhotoManager: ERROR - Failed to verify saved photo for \(dateKey)")
            }
        }
        
        return photo
    }
    
    // Clear all historical photos (for debugging)
    func clearAllHistoricalPhotos() {
        let allKeys = userDefaults.dictionaryRepresentation().keys
        for key in allKeys {
            if key.hasPrefix(historicalPhotosKey) {
                userDefaults.removeObject(forKey: key)
            }
        }
        print("HistoricalPhotoManager: Cleared all historical photo assignments")
    }
    
    // Helper to create unique key for each date
    private func dateKeyForDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// Historical Quote Manager - Permanent quote assignments for past dates
class HistoricalQuoteManager {
    static let shared = HistoricalQuoteManager()
    private let userDefaults = UserDefaults.standard
    private let historicalQuotesKey = "historicalQuoteAssignments"
    
    private init() {}
    
    // Get quote for a specific date - if it doesn't exist, assign one permanently
    func getQuoteForDate(_ date: Date, from quotes: [String]) -> String {
        guard !quotes.isEmpty else { return "Every day is a gift of memories." }
        
        let dateKey = dateKeyForDate(date)
        
        // Check if we already have a quote for this date
        if let existingQuote = userDefaults.string(forKey: "\(historicalQuotesKey)_\(dateKey)") {
            print("HistoricalQuoteManager: Retrieved existing quote for \(dateKey)")
            return existingQuote
        }
        
        // No quote assigned yet - create permanent assignment
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        let yearComponent = Calendar.current.component(.year, from: date)
        let yearOffset = yearComponent - 2000
        
        // Prime number hash for unique date-quote mapping
        let hash = (dayOfYear + yearOffset) * 73 + 37
        let quoteIndex = hash % quotes.count
        
        let quote = quotes[quoteIndex]
        
        // Save this quote permanently for this date
        userDefaults.set(quote, forKey: "\(historicalQuotesKey)_\(dateKey)")
        print("HistoricalQuoteManager: Permanently assigned quote index \(quoteIndex) to \(dateKey)")
        
        return quote
    }
    
    // Clear all historical quotes (for debugging)
    func clearAllHistoricalQuotes() {
        let allKeys = userDefaults.dictionaryRepresentation().keys
        for key in allKeys {
            if key.hasPrefix(historicalQuotesKey) {
                userDefaults.removeObject(forKey: key)
            }
        }
        print("HistoricalQuoteManager: Cleared all historical quote assignments")
    }
    
    // Helper to create unique key for each date
    private func dateKeyForDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// Seeded random number generator for consistent daily photos
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        state = state &* 1103515245 &+ 12345
        return state
    }
}

// Gallery View for managing photos and quotes
struct GalleryView: View {
    @ObservedObject var photoStore: PhotoStore
    @State private var selectedPhotos: [PhotosPickerItem] = []
    
    var body: some View {
        ZStack {
            // Solid background
            Color(red: 0.2, green: 0.4, blue: 0.3) // Lighter memorial green
            .ignoresSafeArea(edges: [.top, .leading, .trailing])
            
            VStack(spacing: 20) {
                if photoStore.images.isEmpty {
                    VStack(spacing: 30) {
                        Spacer()
                        
                        VStack(spacing: 20) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 80))
                                .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                            
                            Text("GALLERY")
                                .font(.system(size: 28, weight: .bold, design: .serif))
                                .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                .kerning(1.0)
                            
                            Text("Manage photos and quotes for 365 days")
                                .font(.system(size: 16, design: .serif))
                                .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                                .multilineTextAlignment(.center)
                        }
                        
                        VStack(spacing: 20) {
                            Text("No photos uploaded yet")
                                .font(.system(size: 18, weight: .medium, design: .serif))
                                .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.8))
                            
                            PhotosPicker(
                                selection: $selectedPhotos,
                                maxSelectionCount: 500,
                                matching: .images
                            ) {
                                HStack(spacing: 15) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Select Multiple Photos")
                                            .font(.system(size: 16, weight: .medium, design: .serif))
                                            .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                        
                                        Text("Add photos for your 365-day journey")
                                            .font(.system(size: 12, design: .serif))
                                            .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.7))
                                    }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(red: 0.7, green: 0.6, blue: 0.3).opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .padding(.horizontal, 40)
                        }
                        
                        Spacer()
                    }
                } else {
                    VStack(spacing: 20) {
                        // Beautiful header
                        VStack(spacing: 10) {
                            Text("YOUR COLLECTION")
                                .font(.system(size: 24, weight: .bold, design: .serif))
                                .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                .kerning(1.0)
                            
                            Text("\(photoStore.images.count) photos in collection")
                                .font(.system(size: 16, design: .serif))
                                .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                        }
                        .padding(.top, 20)
                        
                        // Optimized photo grid
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                                ForEach(0..<photoStore.images.count, id: \.self) { index in
                                    let image = photoStore.images[index]
                                    GeometryReader { geo in
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: geo.size.width, height: geo.size.width)
                                            .clipped()
                                    }
                                    .aspectRatio(1, contentMode: .fit)
                                    .background(Color.gray.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(red: 0.7, green: 0.6, blue: 0.3).opacity(0.3), lineWidth: 1)
                                        )
                                        .overlay(
                                            VStack {
                                                HStack {
                                                    Spacer()
                                                    Button(action: {
                                                        // Instant delete - no animation delay
                                                        photoStore.removeImage(at: index)
                                                    }) {
                                                        Image(systemName: "minus")
                                                            .font(.system(size: 10, weight: .medium))
                                                            .foregroundColor(.white)
                                                            .frame(width: 16, height: 16)
                                                            .background(Color.black.opacity(0.6))
                                                            .clipShape(Circle())
                                                    }
                                                    .opacity(0.7)
                                                }
                                                Spacer()
                                                HStack {
                                                    Spacer()
                                                    Text("\(index + 1)")
                                                        .font(.system(size: 12, weight: .bold, design: .serif))
                                                        .foregroundColor(.white)
                                                        .padding(6)
                                                        .background(Color.black.opacity(0.7))
                                                        .clipShape(Circle())
                                                }
                                            }
                                            .padding(4)
                                        )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Add more photos button
                        PhotosPicker(
                            selection: $selectedPhotos,
                            maxSelectionCount: 500,
                            matching: .images
                        ) {
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                                
                                Text("Add More Photos")
                                    .font(.system(size: 16, weight: .medium, design: .serif))
                                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(red: 0.7, green: 0.6, blue: 0.3), lineWidth: 1)
                            )
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .onChange(of: selectedPhotos) { _ in
            loadImages()
        }
    }
    
    private func loadImages() {
        Task {
            let loadedImages = await withTaskGroup(of: UIImage?.self) { group in
                for item in selectedPhotos {
                    group.addTask {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            return image
                        }
                        return nil
                    }
                }
                
                var result: [UIImage] = []
                for await image in group {
                    if let image = image {
                        result.append(image)
                    }
                }
                return result
            }
            
            await MainActor.run {
                if !loadedImages.isEmpty {
                    photoStore.addImages(loadedImages)
                    // Clear the selection after loading
                    selectedPhotos.removeAll()
                }
            }
        }
    }
}

// Separate class to manage today's photo independently
class TodaysPhotoManager: ObservableObject {
    @Published private(set) var todaysPhoto: UIImage? {
        didSet {
            print("🔴 TodaysPhotoManager.todaysPhoto CHANGED: \(oldValue != nil ? "HAD PHOTO" : "WAS NIL") → \(todaysPhoto != nil ? "HAS PHOTO" : "NOW NIL")")
            // Save photo data immediately when it changes (only if not loading from storage)
            if !isLoadingFromStorage {
                saveTodaysPhotoToUserDefaults()
            }
        }
    }
    private var isLoadingFromStorage = false
    private var cachedDate: String = ""
    private var isInitialized = false
    private var loadCallCount = 0
    private var photoLocked = false // Prevent any changes once photo is set for the day
    
    init() {
        // Initialize without loading - photo will be loaded when needed
        print("TodaysPhotoManager: Initializing - photo will be loaded from HistoricalPhotoManager")
    }
    
    func loadTodaysPhoto(from photoStore: PhotoStore) {
        loadCallCount += 1
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())
        
        // Check if it's a new day (unlock for new day)
        if cachedDate != todayString {
            photoLocked = false
            print("TodaysPhotoManager: New day detected, unlocking photo")
        }
        
        // If photo is locked for today, ignore all requests
        if photoLocked {
            print("TodaysPhotoManager: Photo locked for today - call #\(loadCallCount) IGNORED")
            return
        }
        
        // Only reload if it's a new day OR if this is the first time loading OR if we don't have a photo yet
        if cachedDate != todayString || !isInitialized || todaysPhoto == nil {
            print("TodaysPhotoManager: Loading photo for date: \(todayString) (initialized: \(isInitialized), call #\(loadCallCount))")
            print("TodaysPhotoManager: PhotoStore has \(photoStore.images.count) images")
            
            // ALWAYS use HistoricalPhotoManager to get today's photo - ensures perfect consistency
            let newPhoto = HistoricalPhotoManager.shared.getPhotoForDate(Date(), from: photoStore)
            print("TodaysPhotoManager: Got photo from HistoricalPhotoManager: \(newPhoto != nil ? "YES" : "NO")")
            
            // Always update from HistoricalPhotoManager - it's the single source of truth
            if let newPhoto = newPhoto {
                // Only update if this is actually a different photo or we don't have one
                if todaysPhoto != newPhoto || todaysPhoto == nil {
                    todaysPhoto = newPhoto
                    print("TodaysPhotoManager: Updated photo from HistoricalPhotoManager")
                }
                cachedDate = todayString
                isInitialized = true
                photoLocked = true // Lock the photo for the day
                print("TodaysPhotoManager: Successfully synced with HistoricalPhotoManager and LOCKED for the day")
            } else if todaysPhoto == nil {
                // Only log this if we don't have any photo at all
                print("TodaysPhotoManager: No photo available from HistoricalPhotoManager (PhotoStore has \(photoStore.images.count) images)")
                // Only mark as initialized if we actually have images to choose from
                if photoStore.images.count > 0 {
                    cachedDate = todayString
                    isInitialized = true
                    // Don't lock if we don't have a photo
                } else {
                    print("TodaysPhotoManager: PhotoStore is empty, not marking as initialized to allow retry")
                }
            } else {
                print("TodaysPhotoManager: Keeping existing photo from HistoricalPhotoManager")
            }
        } else {
            print("TodaysPhotoManager: Using cached photo for \(todayString) - ignoring duplicate call #\(loadCallCount)")
        }
    }
    
    // Force refresh photo without date checking - for when images become available or notification tapped
    func forceRefreshPhoto(from photoStore: PhotoStore) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())
        
        print("TodaysPhotoManager: Force refresh requested for date: \(todayString)")
        
        // Check if it's a new day and unlock if needed
        if cachedDate != todayString {
            photoLocked = false
            print("TodaysPhotoManager: New day detected in force refresh, unlocking photo")
        }
        
        // Force unlock and refresh for notification taps to ensure correct photo
        photoLocked = false
        
        // Get photo from HistoricalPhotoManager regardless of current state
        let newPhoto = HistoricalPhotoManager.shared.getPhotoForDate(Date(), from: photoStore)
        if let newPhoto = newPhoto {
            todaysPhoto = newPhoto
            cachedDate = todayString
            isInitialized = true
            photoLocked = true // Lock it once set
            print("TodaysPhotoManager: Force refresh successful - synced with HistoricalPhotoManager and LOCKED for \(todayString)")
        } else {
            print("TodaysPhotoManager: Force refresh failed - no photo available from HistoricalPhotoManager (PhotoStore: \(photoStore.images.count) images)")
        }
    }
    
    private func saveTodaysPhotoToUserDefaults() {
        // Don't save here - let HistoricalPhotoManager handle all persistence
        // This prevents key conflicts and ensures consistency
        print("TodaysPhotoManager: Photo persistence handled by HistoricalPhotoManager")
    }
    
    private func loadTodaysPhotoFromUserDefaults() {
        // Don't load from UserDefaults - get photo directly from HistoricalPhotoManager
        // This ensures perfect consistency with Timeline
        print("TodaysPhotoManager: Photo loading handled by HistoricalPhotoManager - no direct UserDefaults access")
    }
}

// Full-screen Today View with photo and overlays
// Global photo manager to ensure it persists across view recreations
private let globalTodaysPhotoManager = TodaysPhotoManager()


struct TodayView: View {
    @ObservedObject var photoStore: PhotoStore
    @ObservedObject private var photoManager = globalTodaysPhotoManager
    @Binding var tabBarVisible: Bool
    @State private var showingFullScreen = false
    
    var body: some View {
        let _ = print("📱 TodayView.body: Rendering with photo state = \(photoManager.todaysPhoto != nil ? "HAS PHOTO" : "NO PHOTO"), PhotoStore count = \(photoStore.images.count)")
        
        ZStack {
            // Full-screen photo or fallback background
            if let todaysPhoto = photoManager.todaysPhoto {
                GeometryReader { geo in
                    Image(uiImage: todaysPhoto)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
                .ignoresSafeArea(edges: [.top, .leading, .trailing])
            } else {
                // Fallback solid background when no photos
                Color(red: 0.2, green: 0.4, blue: 0.3) // Lighter memorial green
                .ignoresSafeArea(edges: [.top, .leading, .trailing])
                
                VStack(spacing: 20) {
                    Image(systemName: "photo.circle")
                        .font(.system(size: 80))
                        .foregroundColor(Color.white.opacity(0.6))
                    
                    Text("No photos yet")
                        .font(.system(size: 24, weight: .medium, design: .serif))
                        .foregroundColor(.white)
                    
                    Text("Add photos in the Gallery tab to see today's memory")
                        .font(.system(size: 16, design: .serif))
                        .foregroundColor(Color.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
            
            // Top overlay with date and day counter - only when photos exist
            if photoManager.todaysPhoto != nil {
                GeometryReader { geometry in
                    VStack {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(getCurrentDateString())
                                    .font(.system(size: 11, weight: .medium, design: .serif))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                
                                Text("Day \(Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1) of 365")
                                    .font(.system(size: 10, design: .serif))
                                    .foregroundColor(Color.white.opacity(0.8))
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.black.opacity(0.6))
                            )
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, geometry.safeAreaInsets.top + 0)
                        
                        Spacer()
                    }
                }
            }
            
            // Bottom overlay with quote
            if photoManager.todaysPhoto != nil {
                VStack {
                    Spacer()
                    
                    HStack {
                        VStack(spacing: 8) {
                            Text(photoStore.getTodaysQuote())
                                .font(.system(size: 14, weight: .regular, design: .serif))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .italic()
                                .lineLimit(3)
                                .shadow(color: .black, radius: 2)
                                .minimumScaleFactor(0.8)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.7))
                        )
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120)
                }
            }
        }
        .onTapGesture {
            // Open full screen photo view like memories tab
            if photoManager.todaysPhoto != nil {
                showingFullScreen = true
            }
        }
        .sheet(isPresented: $showingFullScreen) {
            TodayFullScreenView(photoStore: photoStore)
        }
        .onAppear {
            print("TodayView: onAppear called")
            print("TodayView: Current photo state: \(photoManager.todaysPhoto != nil ? "HAS PHOTO" : "NO PHOTO")")
            print("TodayView: PhotoStore has \(photoStore.images.count) images")
            // Only load photo if we don't already have one
            if photoManager.todaysPhoto == nil {
                photoManager.loadTodaysPhoto(from: photoStore)
                
                // If no images are loaded yet, retry after a short delay (only once)
                if photoStore.images.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        print("TodayView: Retrying photo load after delay - PhotoStore now has \(photoStore.images.count) images")
                        if photoManager.todaysPhoto == nil {
                            photoManager.loadTodaysPhoto(from: photoStore)
                        }
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            // Only reload if app was backgrounded and returned AND we don't have a photo
            if photoManager.todaysPhoto == nil {
                print("TodayView: App became active, no photo - loading")
                photoManager.loadTodaysPhoto(from: photoStore)
            } else {
                print("TodayView: App became active, already have photo - keeping current")
            }
        }
    }
    
    private func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: Date())
    }
    
    private func getShortDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: Date())
    }
}

// Full-screen Today View (similar to MemoryDetailView)
struct TodayFullScreenView: View {
    @ObservedObject var photoStore: PhotoStore
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var photoManager = globalTodaysPhotoManager
    
    var body: some View {
        ZStack {
            // Full-screen photo or fallback background
            if let todaysPhoto = photoManager.todaysPhoto {
                GeometryReader { geo in
                    Image(uiImage: todaysPhoto)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
                .ignoresSafeArea()
            } else {
                // Fallback solid background
                Color(red: 0.2, green: 0.4, blue: 0.3) // Lighter memorial green
                .ignoresSafeArea()
            }
            
            // Top overlay with date and day counter
            GeometryReader { geometry in
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(getCurrentDateString())
                                .font(.system(size: 11, weight: .medium, design: .serif))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            Text("Day \(Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1) of 365")
                                .font(.system(size: 10, design: .serif))
                                .foregroundColor(Color.white.opacity(0.8))
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.black.opacity(0.6))
                        )
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, geometry.safeAreaInsets.top + 60)
                    
                    Spacer()
                }
            }
            
            // Bottom overlay with quote
            if photoManager.todaysPhoto != nil {
                VStack {
                    Spacer()
                    
                    HStack {
                        VStack(spacing: 8) {
                            Text(photoStore.getTodaysQuote())
                                .font(.system(size: 14, weight: .regular, design: .serif))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .italic()
                                .lineLimit(3)
                                .shadow(color: .black, radius: 2)
                                .minimumScaleFactor(0.8)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.7))
                        )
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 50)
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    // Swipe down to dismiss
                    if value.translation.height > 100 {
                        dismiss()
                    }
                }
        )
    }
    
    private func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: Date())
    }
}

// Memory Calendar View for past memories
struct MemoryCalendarView: View {
    @ObservedObject var photoStore: PhotoStore
    @State private var selectedDate = Date()
    @State private var memoryDays: [MemoryDay] = []
    
    var body: some View {
        ZStack {
            // Solid background
            Color(red: 0.2, green: 0.4, blue: 0.3) // Lighter memorial green
            .ignoresSafeArea(edges: [.top, .leading, .trailing])
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 15) {
                        Image(systemName: "calendar")
                            .font(.system(size: 60))
                            .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                        
                        Text("MEMORY TIMELINE")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                            .kerning(1.0)
                        
                        Text("Your journey of remembrance")
                            .font(.system(size: 16, design: .serif))
                            .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                    }
                    .padding(.top, 20)
                    
                    // Memory cards in descending order (today first)
                    ForEach(memoryDays, id: \.id) { memoryDay in
                        MemoryDayCard(memoryDay: memoryDay, photoStore: photoStore)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .onAppear {
            loadMemoryDays()
        }
    }
    
    private func clearOldCachedData() {
        // Clear historical assignments to fix date mapping issues
        // This will force regeneration with the new correct algorithm
        HistoricalPhotoManager.shared.clearAllHistoricalPhotos()
        HistoricalQuoteManager.shared.clearAllHistoricalQuotes()
        print("MemoryCalendarView: Cleared old cached data to fix date mapping")
    }
    
    private func loadMemoryDays() {
        // Generate sample memory days (today and previous days)
        let today = Date()
        let calendar = Calendar.current
        
        memoryDays = (0..<14).compactMap { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { return nil }
            
            let isToday = daysAgo == 0
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE, MMMM d"
            
            return MemoryDay(
                id: UUID(),
                date: date,
                dayTitle: isToday ? "Today" : dayFormatter.string(from: date),
                dayNumber: getDayOfYear(for: date),
                isToday: isToday,
                hasMemory: !photoStore.images.isEmpty,
                memoryText: "", // Will be fetched fresh when needed
                photoCount: photoStore.images.isEmpty ? 0 : 1,
                cachedPhoto: nil // Will be fetched fresh when needed
            )
        }
    }
    
    private func getDayOfYear(for date: Date) -> Int {
        return Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
    }
    
    private func getDailyQuote(for date: Date) -> String {
        // Use the HistoricalQuoteManager for permanent, never-changing quote assignments
        return HistoricalQuoteManager.shared.getQuoteForDate(date, from: photoStore.quotes)
    }
    
    private func getDailyPhotoForDate(_ date: Date) -> UIImage? {
        // Use the HistoricalPhotoManager for permanent, never-changing photo assignments
        return HistoricalPhotoManager.shared.getPhotoForDate(date, from: photoStore)
    }
}

struct MemoryDay {
    let id: UUID
    let date: Date
    let dayTitle: String
    let dayNumber: Int
    let isToday: Bool
    let hasMemory: Bool
    let memoryText: String
    let photoCount: Int
    let cachedPhoto: UIImage? // Cache the photo to ensure consistency
}

struct MemoryDayCard: View {
    let memoryDay: MemoryDay
    @ObservedObject var photoStore: PhotoStore
    @State private var showingFullScreen = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(memoryDay.dayTitle)
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundColor(memoryDay.isToday ? Color(red: 0.7, green: 0.6, blue: 0.3) : Color(red: 0.98, green: 0.97, blue: 0.95))
                        
                        if memoryDay.isToday {
                            Image(systemName: "star.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                        }
                    }
                    
                    Text("Day \(memoryDay.dayNumber) of 365")
                        .font(.system(size: 14, design: .serif))
                        .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.7))
                }
                
                Spacer()
                
                if memoryDay.photoCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "photo")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                        Text("\(memoryDay.photoCount)")
                            .font(.system(size: 14, design: .serif))
                            .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                    }
                }
            }
            
            // Memory content
            if memoryDay.hasMemory {
                VStack(alignment: .leading, spacing: 10) {
                    // Photo for this day - fetch fresh from HistoricalPhotoManager
                    if let photo = HistoricalPhotoManager.shared.getPhotoForDate(memoryDay.date, from: photoStore) {
                        Image(uiImage: photo)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .cornerRadius(12)
                            .clipped()
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.2))
                            .frame(height: 120)
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 30))
                                        .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.6))
                                    Text("Memory Photo")
                                        .font(.system(size: 12, design: .serif))
                                        .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.6))
                                }
                            )
                    }
                    
                    // Memory text - fetch fresh from HistoricalQuoteManager
                    Text(HistoricalQuoteManager.shared.getQuoteForDate(memoryDay.date, from: photoStore.quotes))
                        .font(.system(size: 14, design: .serif))
                        .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                        .italic()
                        .lineLimit(3)
                }
            } else {
                // No memory placeholder
                VStack(spacing: 8) {
                    Image(systemName: "heart")
                        .font(.system(size: 24))
                        .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.3))
                    Text("No memory added yet")
                        .font(.system(size: 14, design: .serif))
                        .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.5))
                }
                .padding(.vertical, 20)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(memoryDay.isToday ? 0.3 : 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.7, green: 0.6, blue: 0.3).opacity(memoryDay.isToday ? 0.6 : 0.2), lineWidth: memoryDay.isToday ? 2 : 1)
                )
        )
        .onTapGesture {
            if memoryDay.hasMemory {
                showingFullScreen = true
            }
        }
        .sheet(isPresented: $showingFullScreen) {
            MemoryDetailView(memoryDay: memoryDay, photoStore: photoStore)
        }
    }
}

// Full-screen Memory Detail View (like Today tab)
struct MemoryDetailView: View {
    let memoryDay: MemoryDay
    @ObservedObject var photoStore: PhotoStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Full-screen photo or fallback background - fetch fresh from HistoricalPhotoManager
            if let photo = HistoricalPhotoManager.shared.getPhotoForDate(memoryDay.date, from: photoStore) {
                GeometryReader { geo in
                    Image(uiImage: photo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
                .ignoresSafeArea()
            } else {
                // Fallback solid background
                Color(red: 0.2, green: 0.4, blue: 0.3) // Lighter memorial green
                .ignoresSafeArea()
            }
            
            // Top overlay with date and day counter
            GeometryReader { geometry in
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(getDateString(for: memoryDay.date))
                                .font(.system(size: 11, weight: .medium, design: .serif))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            Text("Day \(memoryDay.dayNumber) of 365")
                                .font(.system(size: 10, design: .serif))
                                .foregroundColor(Color.white.opacity(0.8))
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.black.opacity(0.6))
                        )
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, geometry.safeAreaInsets.top + 60)
                    
                    Spacer()
                }
            }
            
            // Bottom overlay with quote
            if HistoricalPhotoManager.shared.getPhotoForDate(memoryDay.date, from: photoStore) != nil {
                VStack {
                    Spacer()
                    
                    HStack {
                        VStack(spacing: 8) {
                            Text(HistoricalQuoteManager.shared.getQuoteForDate(memoryDay.date, from: photoStore.quotes))
                                .font(.system(size: 14, weight: .regular, design: .serif))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .italic()
                                .lineLimit(3)
                                .shadow(color: .black, radius: 2)
                                .minimumScaleFactor(0.8)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.7))
                        )
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 50)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func getDateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func getShortDateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// Beautiful Settings View with notification functionality
struct SimpleSettingsView: View {
    @State private var showingTimePicker = false
    @State private var tempTime: Date = Date()
    @State private var notificationsEnabled = false
    @State private var selectedTime = Date()
    
    var body: some View {
        ZStack {
            // Solid background
            Color(red: 0.2, green: 0.4, blue: 0.3) // Lighter memorial green
            .ignoresSafeArea(edges: [.top, .leading, .trailing])
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 15) {
                        Image(systemName: "gear")
                            .font(.system(size: 60))
                            .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                        
                        Text("SETTINGS")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                            .kerning(1.0)
                    }
                    .padding(.top, 20)
                    
                    // Notifications Section
                    VStack(spacing: 20) {
                        Text("DAILY REMINDERS")
                            .font(.system(size: 18, weight: .semibold, design: .serif))
                            .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                            .kerning(0.5)
                        
                        VStack(spacing: 15) {
                            // Enable/Disable Toggle
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Enable Daily Reminders")
                                        .font(.system(size: 16, weight: .medium, design: .serif))
                                        .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                    
                                    Text("Get reminded to capture today's memory")
                                        .font(.system(size: 12, design: .serif))
                                        .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.7))
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $notificationsEnabled)
                                    .tint(Color(red: 0.7, green: 0.6, blue: 0.3))
                                    .onChange(of: notificationsEnabled) { newValue in
                                        if newValue {
                                            requestNotificationPermission()
                                        }
                                    }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(red: 0.7, green: 0.6, blue: 0.3).opacity(0.3), lineWidth: 1)
                                    )
                            )
                            
                            // Time Picker
                            Button(action: {
                                tempTime = selectedTime
                                showingTimePicker = true
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Reminder Time")
                                            .font(.system(size: 16, weight: .medium, design: .serif))
                                            .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                        
                                        Text(formatTime(selectedTime))
                                            .font(.system(size: 14, design: .serif))
                                            .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(red: 0.7, green: 0.6, blue: 0.3).opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .disabled(!notificationsEnabled)
                            .opacity(notificationsEnabled ? 1.0 : 0.5)
                            
                            // Test Notification Button
                            Button(action: {
                                sendTestNotification()
                            }) {
                                HStack {
                                    Image(systemName: "bell.badge")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                                    
                                    Text("Send Test Notification")
                                        .font(.system(size: 14, weight: .medium, design: .serif))
                                        .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(red: 0.7, green: 0.6, blue: 0.3), lineWidth: 1)
                                )
                            }
                            .disabled(!notificationsEnabled)
                            .opacity(notificationsEnabled ? 1.0 : 0.5)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // App Information Section
                    VStack(spacing: 20) {
                        Text("APP INFORMATION")
                            .font(.system(size: 18, weight: .semibold, design: .serif))
                            .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                            .kerning(0.5)
                        
                        VStack(spacing: 15) {
                            SettingsRow(
                                icon: "heart.fill",
                                iconColor: Color.red,
                                title: "Remembrance",
                                value: "Version 1.0"
                            )
                            
                            SettingsRow(
                                icon: "photo.on.rectangle",
                                iconColor: Color(red: 0.7, green: 0.6, blue: 0.3),
                                title: "Memorial Photos",
                                value: "Enabled"
                            )
                            
                            SettingsRow(
                                icon: "bell",
                                iconColor: Color(red: 0.7, green: 0.6, blue: 0.3),
                                title: "Daily Reminders",
                                value: getNotificationStatus()
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Support Section
                    VStack(spacing: 20) {
                        Text("SUPPORT")
                            .font(.system(size: 18, weight: .semibold, design: .serif))
                            .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                            .kerning(0.5)
                        
                        VStack(spacing: 15) {
                            SettingsButton(
                                icon: "questionmark.circle",
                                iconColor: Color.orange,
                                title: "Help & Support",
                                action: {}
                            )
                            
                            SettingsButton(
                                icon: "star.fill",
                                iconColor: Color.yellow,
                                title: "Rate the App",
                                action: {}
                            )
                            
                            SettingsButton(
                                icon: "envelope",
                                iconColor: Color(red: 0.7, green: 0.6, blue: 0.3),
                                title: "Contact Us",
                                action: {}
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            checkNotificationPermission()
        }
        .sheet(isPresented: $showingTimePicker) {
            TimePickerSheet(selectedTime: $tempTime, onSave: { time in
                selectedTime = time
                saveNotificationSettings()
                scheduleNotification()
            })
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound, .provisional]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                }
                
                print("Notification permission granted: \(granted)")
                notificationsEnabled = granted
                
                if granted {
                    // Set up notification categories
                    setupNotificationCategories()
                    scheduleNotification()
                } else {
                    print("Notification permission denied")
                }
                saveNotificationSettings()
            }
        }
    }
    
    private func setupNotificationCategories() {
        let openAction = UNNotificationAction(
            identifier: "OPEN_TODAY",
            title: "View Today's Memory",
            options: [.foreground]
        )
        
        let category = UNNotificationCategory(
            identifier: "DAILY_MEMORY",
            actions: [openAction],
            intentIdentifiers: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                let isAuthorized = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
                notificationsEnabled = isAuthorized
                
                print("Notification settings:")
                print("- Authorization Status: \(settings.authorizationStatus.rawValue)")
                print("- Alert Setting: \(settings.alertSetting.rawValue)")
                print("- Badge Setting: \(settings.badgeSetting.rawValue)")
                print("- Sound Setting: \(settings.soundSetting.rawValue)")
                print("- Notifications Enabled: \(isAuthorized)")
                
                loadNotificationSettings()
            }
        }
    }
    
    private func scheduleNotification() {
        guard notificationsEnabled else { return }
        
        // Cancel existing notifications
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_memory"])
        
        let content = UNMutableNotificationContent()
        content.title = "Today's Memory Awaits"
        content.body = "Take a moment to remember and reflect. Your daily memory is ready."
        content.sound = .default
        content.badge = 1
        content.userInfo = ["action": "showTodayTab"]
        content.categoryIdentifier = "DAILY_MEMORY"
        
        // Ensure notification persists in notification center
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .active
            content.relevanceScore = 1.0
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: selectedTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_memory", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled successfully for \(components.hour ?? 0):\(components.minute ?? 0)")
            }
        }
    }
    
    private func sendTestNotification() {
        guard notificationsEnabled else { 
            print("Test notification blocked: notifications not enabled")
            return 
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "Your daily memory notifications are working! This should appear in notification center."
        content.sound = .default
        content.badge = 1
        content.userInfo = ["action": "showTodayTab"]
        content.categoryIdentifier = "DAILY_MEMORY"
        
        // Ensure test notification persists in notification center
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .active
            content.relevanceScore = 1.0
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "test_notification_\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending test notification: \(error.localizedDescription)")
            } else {
                print("Test notification scheduled successfully - should appear in 2 seconds")
            }
        }
    }
    
    private func getNotificationStatus() -> String {
        if notificationsEnabled {
            return "Daily reminder set for \(formatTime(selectedTime))"
        } else {
            return "Notifications disabled"
        }
    }
    
    private func saveNotificationSettings() {
        UserDefaults.standard.set(notificationsEnabled, forKey: "notifications_enabled")
        UserDefaults.standard.set(selectedTime, forKey: "notification_time")
    }
    
    private func loadNotificationSettings() {
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notifications_enabled")
        if let savedTime = UserDefaults.standard.object(forKey: "notification_time") as? Date {
            selectedTime = savedTime
        } else {
            // Default to 9:00 AM
            let calendar = Calendar.current
            selectedTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        }
    }
}

// Settings row component
struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium, design: .serif))
                        .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                    
                    Text(value)
                        .font(.system(size: 14, design: .serif))
                        .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.7))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.7, green: 0.6, blue: 0.3).opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// Settings button component
struct SettingsButton: View {
    let icon: String
    let iconColor: Color
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
                    .frame(width: 30)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.7, green: 0.6, blue: 0.3).opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

// Time picker sheet for setting notification time
struct TimePickerSheet: View {
    @Binding var selectedTime: Date
    let onSave: (Date) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.2, green: 0.4, blue: 0.3)
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 30) {
                    Text("Select Reminder Time")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                    
                    DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .colorScheme(.dark)
                        .environment(\.colorScheme, .dark)
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Reminder Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(selectedTime)
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                }
            }
        }
    }
}

// Daily Memory View for notifications
struct DailyMemoryView: View {
    @ObservedObject var photoStore: PhotoStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.2, green: 0.4, blue: 0.3)
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Header
                    VStack(spacing: 15) {
                        Text("TODAY'S MEMORY")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                            .kerning(1.0)
                        
                        Text(getCurrentDateString())
                            .font(.system(size: 16, design: .serif))
                            .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                    }
                    
                    // Photo
                    if let todaysPhoto = photoStore.getTodaysPhoto() {
                        Image(uiImage: todaysPhoto)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.3), radius: 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 0.7, green: 0.6, blue: 0.3).opacity(0.4), lineWidth: 2)
                            )
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "photo.circle")
                                .font(.system(size: 80))
                                .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.6))
                            Text("No photo for today")
                                .font(.system(size: 18, design: .serif))
                                .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                        }
                    }
                    
                    // Quote
                    VStack(spacing: 15) {
                        Text("💝")
                            .font(.system(size: 30))
                        
                        Text(photoStore.getTodaysQuote())
                            .font(.system(size: 16, weight: .regular, design: .serif))
                            .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.95))
                            .multilineTextAlignment(.center)
                            .italic()
                            .padding(.horizontal, 30)
                            .lineLimit(nil)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 0.7, green: 0.6, blue: 0.3).opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .navigationTitle("Daily Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                }
            }
        }
    }
    
    private func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: Date())
    }
}

// Main Tab Controller with auto-hiding tab bar for Today view
struct MainTabViewController: View {
    @ObservedObject var photoStore: PhotoStore
    @Binding var showingDailyMemory: Bool
    @State private var selectedTab = 0
    @State private var tabBarVisible = false
    @State private var lastInteractionTime = Date()
    
    var body: some View {
        ZStack {
            // Always show the TabView, but control tab bar visibility
            TabView(selection: $selectedTab) {
                TodayView(photoStore: photoStore, tabBarVisible: $tabBarVisible)
                    .id("TodayView") // Keep the same identity to prevent recreation
                    .tabItem {
                        Image(systemName: "heart.fill")
                        Text("Today")
                    }
                    .tag(0)
                    
                    MemoryCalendarView(photoStore: photoStore)
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("Memories")
                        }
                        .tag(1)
                    
                    GalleryView(photoStore: photoStore)
                        .tabItem {
                            Image(systemName: "photo.on.rectangle")
                            Text("Gallery")
                        }
                        .tag(2)
                    
                    SimpleSettingsView()
                        .tabItem {
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                        .tag(3)
                }
                .accentColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                .animation(nil, value: selectedTab) // Disable implicit animations on tab change
                .onAppear {
                    setupTabBarAppearance()
                }
                // Use toolbar visibility instead of complex view switching
                .toolbar(tabBarVisible ? .visible : .hidden, for: .tabBar)
            
        }
        .onAppear {
            setupNotificationDelegate()
            // Start with tabs hidden on Today screen
            tabBarVisible = false
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NavigateToTodayTab"))) { _ in
            selectedTab = 0
            tabBarVisible = true
            lastInteractionTime = Date()
            // Auto-hide tabs after notification navigation
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if selectedTab == 0 {
                    withAnimation(.easeOut(duration: 0.2)) {
                        tabBarVisible = false
                    }
                }
            }
        }
        .onChange(of: selectedTab) { newValue in
            lastInteractionTime = Date()
            if newValue != 0 {
                // On non-Today tabs - always show tab bar instantly
                tabBarVisible = true
            }
            // On Today tab - let user control tab visibility with tap
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.2, green: 0.4, blue: 0.3, alpha: 1.0)
        
        // Configure normal state
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(red: 0.95, green: 0.92, blue: 0.85, alpha: 1.0)
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(red: 0.95, green: 0.92, blue: 0.85, alpha: 1.0)
        
        // Configure selected state
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(red: 0.7, green: 0.6, blue: 0.3, alpha: 1.0)
        ]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 0.7, green: 0.6, blue: 0.3, alpha: 1.0)
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    private func setupNotificationDelegate() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
}

// Notification Delegate to handle notification presentation and interaction
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    // This method is called when a notification is delivered to a foreground app
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground and keep it in notification center
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .list, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    // This method is called when the user responds to the notification by opening the app
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let action = userInfo["action"] as? String {
            switch action {
            case "showTodayTab":
                // Navigate to Today tab
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name("NavigateToTodayTab"), object: nil)
                }
            default:
                break
            }
        }
        
        completionHandler()
    }
}

@main
struct RemembranceApp: App {
    @StateObject private var photoStore = PhotoStore()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showingDailyMemory = false
    @State private var showLaunchScreen = true
    @State private var showPrivacyScreen = false
    @State private var showOnboarding = false
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            if showLaunchScreen {
                LaunchScreenView()
                    .onAppear {
                        // Load images while showing launch screen
                        if photoStore.images.isEmpty {
                            print("App launched: Loading images during launch screen")
                            photoStore.loadImages()
                        }
                        
                        // Extended duration (20% more: 1.5 -> 1.8 seconds)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                            // Pre-load today's photo before showing content
                            if !photoStore.images.isEmpty {
                                globalTodaysPhotoManager.loadTodaysPhoto(from: photoStore)
                            }

                            // Check if onboarding is needed
                            if !hasCompletedOnboarding {
                                showOnboarding = true
                            }

                            withAnimation(.easeInOut(duration: 0.3)) {
                                showLaunchScreen = false
                            }
                        }
                    }
            } else {
                ZStack {
                    ContentView()
                        .environmentObject(photoStore)
                        .onAppear {
                            // Historical photos are now permanent - no clearing needed
                        }
                        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DailyReminderTapped"))) { _ in
                            print("Received daily reminder notification tap - refreshing today's photo")
                            // Force refresh the photo to ensure today's photo is shown
                            globalTodaysPhotoManager.forceRefreshPhoto(from: photoStore)
                        }
                        // Onboarding temporarily disabled
                        // .fullScreenCover(isPresented: $showOnboarding) {
                        //     OnboardingView()
                        //         .environmentObject(photoStore)
                        // }
                    
                    // Privacy overlay when app becomes inactive
                    if showPrivacyScreen {
                        LaunchScreenView()
                            .zIndex(999)
                    }
                }
                    .onChange(of: scenePhase) { newPhase in
                        switch newPhase {
                        case .active:
                            print("App became active")
                            // Hide privacy screen when app becomes active
                            showPrivacyScreen = false
                            if photoStore.images.isEmpty {
                                photoStore.loadImages()
                            }
                            // Force refresh today's photo to ensure it's current for the new day
                            // This prevents showing yesterday's image when returning from notifications
                            globalTodaysPhotoManager.forceRefreshPhoto(from: photoStore)
                        case .background:
                            print("App entered background - saving photos")
                            photoStore.saveImages()
                            // Show privacy screen immediately when backgrounded
                            showPrivacyScreen = true
                        case .inactive:
                            print("App became inactive - showing privacy screen")
                            photoStore.saveImages() // Also save when becoming inactive
                            // Immediately show privacy screen so iOS screenshots that instead
                            showPrivacyScreen = true
                            // Don't reset to launch screen - only do that for true app termination
                        @unknown default:
                            break
                        }
                    }
            }
        }
    }
    
}

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            // Memorial green background covering entire screen
            Color(red: 0.2, green: 0.4, blue: 0.3)
                .ignoresSafeArea(.all)
            
            VStack(spacing: 20) {
                // App icon/logo
                Image(systemName: "heart.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(red: 0.7, green: 0.6, blue: 0.3))
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            }
        }
        .background(Color(red: 0.2, green: 0.4, blue: 0.3)) // Double ensure coverage
    }
}
